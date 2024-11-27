
#= none:1 =#
using Oceananigans.Architectures: architecture
#= none:2 =#
using Oceananigans.Grids: interior_parent_indices
#= none:3 =#
using Oceananigans.Utils: prettysummary
#= none:4 =#
using Statistics: norm, dot
#= none:5 =#
using LinearAlgebra
#= none:7 =#
import Oceananigans.Architectures: architecture
#= none:9 =#
mutable struct ConjugateGradientSolver{A, G, L, T, F, M, P}
    #= none:10 =#
    architecture::A
    #= none:11 =#
    grid::G
    #= none:12 =#
    linear_operation!::L
    #= none:13 =#
    reltol::T
    #= none:14 =#
    abstol::T
    #= none:15 =#
    maxiter::Int
    #= none:16 =#
    iteration::Int
    #= none:17 =#
    ρⁱ⁻¹::T
    #= none:18 =#
    linear_operator_product::F
    #= none:19 =#
    search_direction::F
    #= none:20 =#
    residual::F
    #= none:21 =#
    preconditioner::M
    #= none:22 =#
    preconditioner_product::P
end
#= none:25 =#
architecture(solver::ConjugateGradientSolver) = begin
        #= none:25 =#
        solver.architecture
    end
#= none:26 =#
iteration(cgs::ConjugateGradientSolver) = begin
        #= none:26 =#
        cgs.iteration
    end
#= none:28 =#
initialize_precondition_product(preconditioner, template_field) = begin
        #= none:28 =#
        similar(template_field)
    end
#= none:29 =#
initialize_precondition_product(::Nothing, template_field) = begin
        #= none:29 =#
        nothing
    end
#= none:31 =#
Base.summary(::ConjugateGradientSolver) = begin
        #= none:31 =#
        "ConjugateGradientSolver"
    end
#= none:34 =#
#= none:34 =# @inline precondition!(z, ::Nothing, r, args...) = begin
            #= none:34 =#
            r
        end
#= none:36 =#
#= none:36 =# Core.@doc "    ConjugateGradientSolver(linear_operation;\n                                          template_field,\n                                          maxiter = size(template_field.grid),\n                                          reltol = sqrt(eps(template_field.grid)),\n                                          abstol = 0,\n                                          preconditioner = nothing)\n\nReturns a `ConjugateGradientSolver` that solves the linear equation\n``A x = b`` using a iterative conjugate gradient method with optional preconditioning.\n\nThe solver is used by calling\n\n```\nsolve!(x, solver::PreconditionedConjugateGradientOperator, b, args...)\n```\n\nfor `solver`, right-hand side `b`, solution `x`, and optional arguments `args...`.\n\nArguments\n=========\n\n* `linear_operation`: Function with signature `linear_operation!(p, y, args...)` that calculates\n                      `A * y` and stores the result in `p` for a \"candidate solution\" `y`. `args...`\n                      are optional positional arguments passed from `solve!(x, solver, b, args...)`.\n\n* `template_field`: Dummy field that is the same type and size as `x` and `b`, which\n                    is used to infer the `architecture`, `grid`, and to create work arrays\n                    that are used internally by the solver.\n\n* `maxiter`: Maximum number of iterations the solver may perform before exiting.\n\n* `reltol, abstol`: Relative and absolute tolerance for convergence of the algorithm.\n                    The iteration stops when `norm(A * x - b) < tolerance`.\n\n* `preconditioner`: Object for which `precondition!(z, preconditioner, r, args...)` computes `z = P * r`,\n                    where `r` is the residual. Typically `P` is approximately `A⁻¹`.\n\nSee [`solve!`](@ref) for more information about the preconditioned conjugate-gradient algorithm.\n" function ConjugateGradientSolver(linear_operation; template_field::AbstractField, maxiter = prod(size(template_field)), reltol = sqrt(eps(eltype(template_field.grid))), abstol = 0, preconditioner = nothing)
        #= none:76 =#
        #= none:83 =#
        arch = architecture(template_field)
        #= none:84 =#
        grid = template_field.grid
        #= none:87 =#
        linear_operator_product = similar(template_field)
        #= none:88 =#
        search_direction = similar(template_field)
        #= none:89 =#
        residual = similar(template_field)
        #= none:92 =#
        precondition_product = initialize_precondition_product(preconditioner, template_field)
        #= none:94 =#
        FT = eltype(grid)
        #= none:96 =#
        return ConjugateGradientSolver(arch, grid, linear_operation, FT(reltol), FT(abstol), maxiter, 0, zero(FT), linear_operator_product, search_direction, residual, preconditioner, precondition_product)
    end
#= none:111 =#
#= none:111 =# Core.@doc "    solve!(x, solver::ConjugateGradientSolver, b, args...)\n\nSolve `A * x = b` using an iterative conjugate-gradient method, where `A * x` is\ndetermined by `solver.linear_operation`\n    \nSee figure 2.5 in\n\n> The Preconditioned Conjugate Gradient Method in \"Templates for the Solution of Linear Systems: Building Blocks for Iterative Methods\" Barrett et. al, 2nd Edition.\n    \nGiven:\n  * Linear Preconditioner operator `M!(solution, x, other_args...)` that computes `M * x = solution`\n  * A matrix operator `A` as a function `A()`;\n  * A dot product function `norm()`;\n  * A right-hand side `b`;\n  * An initial guess `x`; and\n  * Local vectors: `z`, `r`, `p`, `q`\n\nThis function executes the psuedocode algorithm\n    \n```\nβ  = 0\nr = b - A(x)\niteration  = 0\n\nLoop:\n     if iteration > maxiter\n        break\n     end\n\n     ρ = r ⋅ z\n\n     z = M(r)\n     β = ρⁱ⁻¹ / ρ\n     p = z + β * p\n     q = A(p)\n\n     α = ρ / (p ⋅ q)\n     x = x + α * p\n     r = r - α * q\n\n     if |r| < tolerance\n        break\n     end\n\n     iteration += 1\n     ρⁱ⁻¹ = ρ\n```\n" function solve!(x, solver::ConjugateGradientSolver, b, args...)
        #= none:160 =#
        #= none:163 =#
        solver.iteration = 0
        #= none:166 =#
        q = solver.linear_operator_product
        #= none:168 =#
        #= none:168 =# @apply_regionally initialize_solution!(q, x, b, solver, args...)
        #= none:170 =#
        residual_norm = norm(solver.residual)
        #= none:171 =#
        tolerance = max(solver.reltol * residual_norm, solver.abstol)
        #= none:173 =#
        #= none:173 =# @debug "ConjugateGradientSolver, |b|: $(norm(b))"
        #= none:174 =#
        #= none:174 =# @debug "ConjugateGradientSolver, |A * x|: $(norm(q))"
        #= none:176 =#
        while iterating(solver, tolerance)
            #= none:177 =#
            iterate!(x, solver, b, args...)
            #= none:178 =#
        end
        #= none:180 =#
        return x
    end
#= none:183 =#
function iterate!(x, solver, b, args...)
    #= none:183 =#
    #= none:184 =#
    r = solver.residual
    #= none:185 =#
    p = solver.search_direction
    #= none:186 =#
    q = solver.linear_operator_product
    #= none:188 =#
    #= none:188 =# @debug "ConjugateGradientSolver $(solver.iteration), |r|: $(norm(r))"
    #= none:192 =#
    #= none:192 =# @apply_regionally z = precondition!(solver.preconditioner_product, solver.preconditioner, r, x, args...)
    #= none:194 =#
    ρ = dot(z, r)
    #= none:196 =#
    #= none:196 =# @debug "ConjugateGradientSolver $(solver.iteration), ρ: $(ρ)"
    #= none:197 =#
    #= none:197 =# @debug "ConjugateGradientSolver $(solver.iteration), |z|: $(norm(z))"
    #= none:199 =#
    #= none:199 =# @apply_regionally perform_iteration!(q, p, ρ, z, solver, args...)
    #= none:201 =#
    α = ρ / dot(p, q)
    #= none:203 =#
    #= none:203 =# @debug "ConjugateGradientSolver $(solver.iteration), |q|: $(norm(q))"
    #= none:204 =#
    #= none:204 =# @debug "ConjugateGradientSolver $(solver.iteration), α: $(α)"
    #= none:206 =#
    #= none:206 =# @apply_regionally update_solution_and_residuals!(x, r, q, p, α)
    #= none:208 =#
    solver.iteration += 1
    #= none:209 =#
    solver.ρⁱ⁻¹ = ρ
    #= none:211 =#
    return nothing
end
#= none:214 =#
#= none:214 =# Core.@doc " first iteration of the PCG " function initialize_solution!(q, x, b, solver, args...)
        #= none:215 =#
        #= none:216 =#
        solver.linear_operation!(q, x, args...)
        #= none:218 =#
        parent(solver.residual) .= parent(b) .- parent(q)
        #= none:220 =#
        return nothing
    end
#= none:223 =#
#= none:223 =# Core.@doc " one conjugate gradient iteration " function perform_iteration!(q, p, ρ, z, solver, args...)
        #= none:224 =#
        #= none:225 =#
        pp = parent(p)
        #= none:226 =#
        zp = parent(z)
        #= none:228 =#
        if solver.iteration == 0
            #= none:229 =#
            pp .= zp
        else
            #= none:231 =#
            β = ρ / solver.ρⁱ⁻¹
            #= none:232 =#
            pp .= zp .+ β .* pp
            #= none:234 =#
            #= none:234 =# @debug "ConjugateGradientSolver $(solver.iteration), β: $(β)"
        end
        #= none:238 =#
        solver.linear_operation!(q, p, args...)
        #= none:240 =#
        return nothing
    end
#= none:243 =#
function update_solution_and_residuals!(x, r, q, p, α)
    #= none:243 =#
    #= none:244 =#
    xp = parent(x)
    #= none:245 =#
    rp = parent(r)
    #= none:246 =#
    qp = parent(q)
    #= none:247 =#
    pp = parent(p)
    #= none:249 =#
    xp .+= α .* pp
    #= none:250 =#
    rp .-= α .* qp
    #= none:252 =#
    return nothing
end
#= none:255 =#
function iterating(solver, tolerance)
    #= none:255 =#
    #= none:257 =#
    solver.iteration >= solver.maxiter && return false
    #= none:258 =#
    norm(solver.residual) <= tolerance && return false
    #= none:259 =#
    return true
end
#= none:262 =#
function Base.show(io::IO, solver::ConjugateGradientSolver)
    #= none:262 =#
    #= none:263 =#
    print(io, "ConjugateGradientSolver on ", summary(solver.architecture), "\n", "├── template_field: ", summary(solver.residual), "\n", "├── grid: ", summary(solver.grid), "\n", "├── linear_operation!: ", prettysummary(solver.linear_operation!), "\n", "├── preconditioner: ", prettysummary(solver.preconditioner), "\n", "├── reltol: ", prettysummary(solver.reltol), "\n", "├── abstol: ", prettysummary(solver.abstol), "\n", "└── maxiter: ", solver.maxiter)
end