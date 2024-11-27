
#= none:1 =#
using Oceananigans.Architectures
#= none:2 =#
using Oceananigans.Architectures: device
#= none:3 =#
import Oceananigans.Architectures: architecture
#= none:4 =#
begin
    using CUDA, CUDA.CUSPARSE, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:5 =#
using KernelAbstractions: @kernel, @index
#= none:7 =#
using LinearAlgebra, SparseArrays, IncompleteLU
#= none:8 =#
using SparseArrays: nnz
#= none:10 =#
import LinearAlgebra.ldiv!
#= none:12 =#
"`ILUFactorization` (`preconditioner_method = :ILUFactorization`)\n    stores two sparse lower and upper trianguilar matrices `L` and `U` such that `LU ≈ A`\n    is applied to `r` with `forward_substitution!(L, r)` followed by `backward_substitution!(U, r)`\n    constructed with `ilu(A, τ = drop_tolerance)`\n    \n`SparseInversePreconditioner` (`preconditioner_method = :SparseInverse` and `:AsymptoticInverse`)\n    stores a sparse matrix `M` such that `M ≈ A⁻¹` \n    is applied to `r` with a matrix multiplication `M * r`\n    constructed with\n    `asymptotic_diagonal_inverse_preconditioner(A)`\n        -> is an asymptotic expansion of the inverse of A assuming that A is diagonally dominant\n        -> it is possible to choose order 0 (Jacobi), 1 or 2\n    `sparse_approximate_preconditioner(A, ε = tolerance, nzrel = relative_maximum_number_of_elements)`\n        -> same formulation as Grote M. J. & Huckle T, \"Parallel Preconditioning with sparse approximate inverses\" \n        -> starts constructing the sparse inverse of A from identity matrix until, either a tolerance (ε) is met or nnz(M) = nzrel * nnz(A) \n\nThe suggested preconditioners are\n\non the `CPU`\n`ilu()` (superior to everything always and in every situation!)\n\non the `GPU`\n`aymptotic_diagonal_inverse_preconditioner()` (if `Δt` is variable or large problem_sizes)\n`sparse_inverse_preconditioner()` (if `Δt` is constant and problem_size is not too large)\n\nas a rule of thumb, for poisson solvers:\n`sparse_inverse_preconditioner` is better performing than `asymptotic_diagonal_inverse_preconditioner` only if `nzrel >= 2.0`\nAs such, we urge to use `sparse_inverse_preconditioner` only when\n- Δt is constant (we don't have to recalculate the preconditioner during the simulation)\n- it is feasible to choose `nzrel = 2.0` (for not too large problem sizes)\n\nNote that `asymptotic_diagonal_inverse_preconditioner` assumes the matrix to be diagonally dominant, for this reason it could \nbe detrimental when used on non-diagonally dominant system (cases where Δt is very large). In this case it is better \nto use `sparse_inverse_preconditioner`\n\n`ilu()` cannot be used on the GPU because preconditioning the solver with a direct LU (or Choleski) type \nof preconditioner would require too much computation for the `ldiv!(P, r)` step completely hindering the performances\n"
#= none:52 =#
validate_settings(T, arch, settings) = begin
        #= none:52 =#
        settings
    end
#= none:53 =#
validate_settings(::Val{:Default}, arch, settings) = begin
        #= none:53 =#
        if arch isa CPU
            (τ = 0.001,)
        else
            (order = 1,)
        end
    end
#= none:54 =#
validate_settings(::Val{:SparseInverse}, arch, settings::Nothing) = begin
        #= none:54 =#
        (ε = 0.1, nzrel = 2.0)
    end
#= none:55 =#
validate_settings(::Val{:ILUFactorization}, arch, settings::Nothing) = begin
        #= none:55 =#
        (τ = 0.001,)
    end
#= none:56 =#
validate_settings(::Val{:AsymptoticInverse}, arch, settings::Nothing) = begin
        #= none:56 =#
        (order = 1,)
    end
#= none:58 =#
validate_settings(::Val{:ILUFactorization}, arch, settings) = begin
        #= none:58 =#
        if haskey(settings, :τ)
            settings
        else
            throw(ArgumentError("τ has to be specified for ILUFactorization"))
        end
    end
#= none:61 =#
validate_settings(::Val{:SparseInverse}, arch, settings) = begin
        #= none:61 =#
        if haskey(settings, :ε) && haskey(settings, :nzrel)
            settings
        else
            throw(ArgumentError("both ε and nzrel have to be specified for SparseInverse"))
        end
    end
#= none:64 =#
validate_settings(::Val{:AsymptoticInverse}, arch, settings) = begin
        #= none:64 =#
        if haskey(settings, :order)
            settings
        else
            throw(ArgumentError("and order ∈ [0, 1, 2] has to be specified for AsymptoticInverse"))
        end
    end
#= none:69 =#
function build_preconditioner(::Val{:Default}, matrix, settings)
    #= none:69 =#
    #= none:70 =#
    default_method = if architecture(matrix) isa CPU
            :ILUFactorization
        else
            :AsymptoticInverse
        end
    #= none:71 =#
    return build_preconditioner(Val(default_method), matrix, settings)
end
#= none:74 =#
build_preconditioner(::Val{nothing}, A, settings) = begin
        #= none:74 =#
        Identity()
    end
#= none:75 =#
build_preconditioner(::Val{:SparseInverse}, A, settings) = begin
        #= none:75 =#
        sparse_inverse_preconditioner(A, ε = settings.ε, nzrel = settings.nzrel)
    end
#= none:76 =#
build_preconditioner(::Val{:AsymptoticInverse}, A, settings) = begin
        #= none:76 =#
        asymptotic_diagonal_inverse_preconditioner(A, asymptotic_order = settings.order)
    end
#= none:77 =#
build_preconditioner(::Val{:Multigrid}, A, settings) = begin
        #= none:77 =#
        multigrid_preconditioner(A)
    end
#= none:79 =#
function build_preconditioner(::Val{:ILUFactorization}, A, settings)
    #= none:79 =#
    #= none:80 =#
    if architecture(A) isa GPU
        #= none:81 =#
        throw(ArgumentError("the ILU factorization is not available on the GPU! choose another method"))
    else
        #= none:83 =#
        return ilu(A, τ = settings.τ)
    end
end
#= none:87 =#
#= none:87 =# @inline architecture(::CuSparseMatrixCSC) = begin
            #= none:87 =#
            GPU()
        end
#= none:88 =#
#= none:88 =# @inline architecture(::SparseMatrixCSC) = begin
            #= none:88 =#
            CPU()
        end
#= none:90 =#
abstract type AbstractInversePreconditioner{M} end
#= none:92 =#
function LinearAlgebra.ldiv!(u, precon::AbstractInversePreconditioner, v)
    #= none:92 =#
    #= none:93 =#
    mul!(u, matrix(precon), v)
end
#= none:96 =#
function LinearAlgebra.ldiv!(precon::AbstractInversePreconditioner, v)
    #= none:96 =#
    #= none:97 =#
    mul!(v, matrix(precon), v)
end
#= none:100 =#
struct SparseInversePreconditioner{M} <: AbstractInversePreconditioner{M}
    #= none:101 =#
    Minv::M
end
#= none:104 =#
#= none:104 =# @inline matrix(p::SparseInversePreconditioner) = begin
            #= none:104 =#
            p.Minv
        end
#= none:106 =#
#= none:106 =# Core.@doc "    asymptotic_diagonal_inverse_preconditioner(A::AbstractMatrix; asymptotic_order)\n\nCompute the diagonally-dominant inverse preconditioner is constructed with an asymptotic\nexpansion of `A⁻¹` up to the second order. If `I` is the Identity matrix and `D` is the matrix\ncontaining the diagonal of `A`, then\n\n- the 0th order expansion is the Jacobi preconditioner `M = D⁻¹ ≈ A⁻¹`\n\n- the 1st order expansion corresponds to `M = D⁻¹(I - (A - D)D⁻¹) ≈ A⁻¹`\n\n- the 2nd order expansion corresponds to `M = D⁻¹(I - (A - D)D⁻¹ + (A - D)D⁻¹(A - D)D⁻¹) ≈ A⁻¹`\n\nAll preconditioners are calculated on CPU and, if the model is based on a GPU architecture, then moved to the GPU.\n\nAdditionally, the first-order expansion has a method to calculate the preconditioner directly\non the GPU `asymptotic_diagonal_inverse_preconditioner_first_order(A)` in case of variable\ntime step where the preconditioner has to be recalculated often.\n" function asymptotic_diagonal_inverse_preconditioner(A::AbstractMatrix; asymptotic_order)
        #= none:125 =#
        #= none:127 =#
        arch = architecture(A)
        #= none:128 =#
        constr = deepcopy(constructors(arch, A))
        #= none:129 =#
        (colptr, rowval, nzval) = copy_unpack_constructors(arch, constr)
        #= none:130 =#
        dev = device(arch)
        #= none:132 =#
        M = size(A, 1)
        #= none:134 =#
        invdiag = on_architecture(arch, zeros(eltype(nzval), M))
        #= none:136 =#
        loop! = _get_inv_diag!(dev, 256, M)
        #= none:137 =#
        loop!(invdiag, colptr, rowval, nzval)
        #= none:139 =#
        if asymptotic_order == 0
            #= none:140 =#
            Minv_cpu = spdiagm(0 => on_architecture(CPU(), invdiag))
            #= none:141 =#
            Minv = arch_sparse_matrix(arch, Minv_cpu)
        elseif #= none:142 =# asymptotic_order == 1
            #= none:143 =#
            loop! = _initialize_asymptotic_diagonal_inverse_preconditioner_first_order!(dev, 256, M)
            #= none:144 =#
            loop!(nzval, colptr, rowval, invdiag)
            #= none:146 =#
            constr_new = (colptr, rowval, nzval)
            #= none:147 =#
            Minv = arch_sparse_matrix(arch, constructors(arch, M, M, constr_new))
        else
            #= none:149 =#
            D = spdiagm(0 => diag(arch_sparse_matrix(CPU(), A)))
            #= none:150 =#
            D⁻¹ = spdiagm(0 => on_architecture(CPU(), invdiag))
            #= none:151 =#
            Minv_cpu = D⁻¹ * ((I - (A - D) * D⁻¹) + (A - D) * D⁻¹ * (A - D) * D⁻¹)
            #= none:152 =#
            Minv = arch_sparse_matrix(arch, Minv_cpu)
        end
        #= none:155 =#
        return SparseInversePreconditioner(Minv)
    end
#= none:158 =#
#= none:158 =# @kernel function _initialize_asymptotic_diagonal_inverse_preconditioner_first_order!(nzval, colptr, rowval, invdiag)
        #= none:158 =#
        #= none:159 =#
        col = #= none:159 =# @index(Global, Linear)
        #= none:161 =#
        for idx = colptr[col]:colptr[col + 1] - 1
            #= none:162 =#
            if rowval[idx] == col
                #= none:163 =#
                nzval[idx] = invdiag[col]
            else
                #= none:165 =#
                nzval[idx] = -(nzval[idx]) * invdiag[rowval[idx]] * invdiag[col]
            end
            #= none:167 =#
        end
    end
#= none:170 =#
function sparse_inverse_preconditioner(A::AbstractMatrix; ε, nzrel)
    #= none:170 =#
    #= none:173 =#
    A_cpu = arch_sparse_matrix(CPU(), A)
    #= none:174 =#
    Minv_cpu = sparse_approximate_inverse(A_cpu, ε = ε, nzrel = nzrel)
    #= none:176 =#
    Minv = arch_sparse_matrix(architecture(A), Minv_cpu)
    #= none:177 =#
    return SparseInversePreconditioner(Minv)
end