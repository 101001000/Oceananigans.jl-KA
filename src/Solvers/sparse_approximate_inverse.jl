
#= none:1 =#
using SparseArrays, LinearAlgebra, Statistics
#= none:3 =#
mutable struct SpaiIterator{VF <: AbstractVector, SV <: SparseVector, VI <: AbstractVector, Ti}
    #= none:4 =#
    mhat::VF
    #= none:5 =#
    e::SV
    #= none:6 =#
    r::SV
    #= none:7 =#
    J::VI
    #= none:8 =#
    I::VI
    #= none:9 =#
    J̃::VI
    #= none:10 =#
    Ĩ::VI
    #= none:11 =#
    Q::SparseMatrixCSC{Float64, Ti}
    #= none:12 =#
    R::SparseMatrixCSC{Float64, Ti}
end
#= none:15 =#
#= none:15 =# Core.@doc "    sparse_approximate_inverse(A::AbstractMatrix; ε::Float64, nzrel)\n\nCompute a sparse approximate inverse of `A`, `M ≈ A⁻¹`, that is a sparse version\nof the generally non-sparse `A⁻¹`. Sparse approximate inverse are very useful to\nbe used as preconditioners. Since they can be applied to the residual with just a\nmatrix multiplication instead of the solution of a triangular linear problem, it\nmakes it very appealing to use on the GPU.\n\nThe algorithm implemeted here computes `M` following the specifications found in\n\n> Grote M. J. & Huckle T, \"Parallel Preconditioning with sparse approximate inverses\" \n\nIn particular, the algorithm tries to minimize the Frobenius norm of\n\n```\n‖ A mⱼ - eⱼ ‖\n```\n\nwhere `mⱼ` and `eⱼ` denote the j-th column of matrix `M` and the identity\nmatrix `I`, respectively. Since we are solving for an \"sparse approximate\" inverse,\nwe start assuming that `mⱼ` has a sparsity pattern `J`, which means that\n\n```\nmⱼ(k) = 0 ∀k ∉ J\n```\n\nWe denote `m̂ⱼ = mⱼ(J)`. From here we calculate the set of row indices `I` for which\n\n```\nA(i, J) !=0 for i ∈ I\n```\n\nWe denote `Â = A(I, J)`. The problem is now reduced to a much smaller minimization\nproblem which can be solved with QR decomposition (which luckily we have neatly implemented\nin Julia: Hooray! but not on GPUs... booo)\n\nOnce solved for `m̂ⱼ` we compute the residuals of the minimization problem\n\n```\nr = eⱼ - A[:, J] * m̂\n```\n\nWe can repeat the computation on the indices for which `r != 0` (`J̃` and respective `Ĩ`\non the rows), so that we have `Â = A(I U Ĩ, J U J̃)` and `m̂ = mⱼ(J U J̃)`.\n\n(... in practice we choose only the more proficuous of the `J̃`, the ones that will have\nthe larger change in residual value ...)\n\nTo do that we do not need to recompute the entire QR factorization but just update it\nby appending the new terms (and recomputing QR for a small part of `Â`).\n\n```julia\nsparse_approximate_inverse(A; ε, nzrel)\n```\n\nreturns `M ≈ A⁻¹`, where `‖ AM - I ‖ ≈ ε` and `nnz(M) ≈ nnz(A) * nzrel`.\n\nIf we choose a sufficiently large `nzrel` (for example, `nzrel = size(A, 1)`), then\n`sparse_approximate_inverse(A, 0.0, nzrel) = A⁻¹ ± machine_precision`.\n" function sparse_approximate_inverse(A::AbstractMatrix; ε::Float64, nzrel)
        #= none:76 =#
        #= none:77 =#
        FT = eltype(A)
        #= none:78 =#
        n = size(A, 1)
        #= none:79 =#
        r = spzeros(FT, n)
        #= none:80 =#
        e = spzeros(FT, n)
        #= none:81 =#
        M = spzeros(FT, n, n)
        #= none:82 =#
        Q = spzeros(FT, 1, 1)
        #= none:83 =#
        J = Int64[1]
        #= none:85 =#
        iterator = SpaiIterator(e, e, r, J, J, J, J, Q, Q)
        #= none:88 =#
        for j = 1:n
            #= none:89 =#
            #= none:89 =# @show (j, n)
            #= none:91 =#
            ncolmax = nzrel * nnz(A[:, j])
            #= none:93 =#
            set_j_column!(iterator, A, j, ε, ncolmax, n, FT)
            #= none:94 =#
            mj = spzeros(FT, n, 1)
            #= none:95 =#
            mj[iterator.J] = iterator.mhat
            #= none:96 =#
            M[:, j] = mj
            #= none:97 =#
        end
        #= none:99 =#
        return M
    end
#= none:102 =#
function set_j_column!(iterator, A, j, ε, ncolmax, n, FT)
    #= none:102 =#
    #= none:103 =#
    #= none:103 =# @inbounds begin
            #= none:104 =#
            iterator.e = speyecolumn(FT, j, n)
            #= none:107 =#
            initial_sparsity_pattern!(iterator, j)
            #= none:110 =#
            find_mhat_given_col!(iterator, A, n)
            #= none:113 =#
            calc_residuals!(iterator, A)
            #= none:114 =#
            iterator.J̃ = setdiff(iterator.r.nzind, iterator.J)
            #= none:123 =#
            while norm(iterator.r) > ε && length(iterator.mhat) < ncolmax
                #= none:124 =#
                if isempty(iterator.J̃)
                    #= none:125 =#
                    iterator.r .= 0
                else
                    #= none:127 =#
                    update_mhat_given_col!(iterator, A, FT)
                    #= none:128 =#
                    calc_residuals!(iterator, A)
                    #= none:129 =#
                    iterator.J̃ = setdiff(iterator.r.nzind, iterator.J)
                end
                #= none:132 =#
            end
        end
end
#= none:136 =#
function initial_sparsity_pattern!(iterator, j)
    #= none:136 =#
    #= none:137 =#
    iterator.J = [j]
end
#= none:140 =#
function update_mhat_given_col!(iterator, A, FT)
    #= none:140 =#
    #= none:141 =#
    #= none:141 =# @inbounds begin
            #= none:142 =#
            A1 = A[:, iterator.J̃]
            #= none:143 =#
            A1I = A1[iterator.I, :]
            #= none:145 =#
            n₁ = length(iterator.I)
            #= none:146 =#
            n₂ = length(iterator.J)
            #= none:147 =#
            ñ₂ = length(iterator.J̃)
            #= none:149 =#
            push!(iterator.J, iterator.J̃...)
            #= none:150 =#
            Atmp = A[:, iterator.J]
            #= none:152 =#
            iterator.Ĩ = setdiff(unique(Atmp.rowval), iterator.I)
            #= none:154 =#
            A1Ĩ = A1[iterator.Ĩ, :]
            #= none:156 =#
            ñ₁ = length(iterator.Ĩ)
            #= none:158 =#
            B1 = spzeros(n₂, ñ₂)
            #= none:159 =#
            mul!(B1, (iterator.Q[:, 1:n₂])', A1I)
            #= none:160 =#
            B2 = (iterator.Q[:, n₂ + 1:end])' * A1I
            #= none:161 =#
            B2 = sparse(vcat(B2, A1Ĩ))
            #= none:164 =#
            F = qr(B2, ordering = false)
            #= none:166 =#
            Iₙ₁ = speye(FT, ñ₁)
            #= none:167 =#
            Iₙ₂ = speye(FT, n₂)
            #= none:168 =#
            hm = spzeros(n₁, ñ₁)
            #= none:169 =#
            iterator.Q = vcat(hcat(iterator.Q, hm), hcat(hm', Iₙ₁))
            #= none:170 =#
            hm = spzeros((ñ₁ + n₁) - n₂, n₂)
            #= none:171 =#
            iterator.Q = iterator.Q * vcat(hcat(Iₙ₂, hm'), hcat(hm, F.Q))
            #= none:173 =#
            hm = spzeros(ñ₂, n₂)
            #= none:174 =#
            iterator.R = vcat(hcat(iterator.R, B1), hcat(hm, F.R))
            #= none:176 =#
            push!(iterator.I, iterator.Ĩ...)
            #= none:178 =#
            bj = zeros(length(iterator.I))
            #= none:179 =#
            copyto!(bj, iterator.e[iterator.I])
            #= none:180 =#
            minimize!(iterator, bj)
        end
end
#= none:184 =#
function find_mhat_given_col!(iterator, A, n)
    #= none:184 =#
    #= none:186 =#
    A1 = spzeros(n, length(iterator.J))
    #= none:187 =#
    copyto!(A1, A[:, iterator.J])
    #= none:189 =#
    iterator.I = unique(A1.rowval)
    #= none:191 =#
    bj = zeros(length(iterator.I))
    #= none:192 =#
    copyto!(bj, iterator.e[iterator.I])
    #= none:194 =#
    F = qr(A1[iterator.I, :], ordering = false)
    #= none:195 =#
    iterator.Q = sparse(F.Q)
    #= none:196 =#
    iterator.R = sparse(F.R)
    #= none:198 =#
    minimize!(iterator, bj)
end
#= none:201 =#
function select_residuals!(iterator, A, n, FT)
    #= none:201 =#
    #= none:202 =#
    ρ = zeros(length(iterator.J̃))
    #= none:203 =#
    #= none:203 =# @inbounds for (t, k) = enumerate(iterator.J̃)
            #= none:204 =#
            ek = speyecolumn(FT, k, n)
            #= none:205 =#
            ρ[t] = norm(iterator.r) ^ 2 - norm((iterator.r)' * A * ek) ^ 2 / norm(A * ek) ^ 2
            #= none:206 =#
        end
    #= none:207 =#
    iterator.J̃ = iterator.J̃[ρ .< mean(ρ)]
end
#= none:210 =#
#= none:210 =# @inline calc_residuals!(i::SpaiIterator, A) = begin
            #= none:210 =#
            copyto!(i.r, i.e - A[:, i.J] * i.mhat)
        end
#= none:211 =#
#= none:211 =# @inline minimize!(i::SpaiIterator, bj) = begin
            #= none:211 =#
            i.mhat = i.R \ ((i.Q)' * bj)[1:length(i.J)]
        end
#= none:212 =#
#= none:212 =# @inline speye(FT, n) = begin
            #= none:212 =#
            spdiagm(0 => ones(FT, n))
        end
#= none:214 =#
#= none:214 =# @inline function speyecolumn(FT, j, n)
        #= none:214 =#
        #= none:215 =#
        e = spzeros(FT, n)
        #= none:216 =#
        e[j] = FT(1)
        #= none:217 =#
        return e
    end