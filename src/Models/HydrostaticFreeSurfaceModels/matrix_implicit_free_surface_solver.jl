
#= none:1 =#
using Oceananigans.Solvers
#= none:2 =#
using Oceananigans.Operators
#= none:3 =#
using Oceananigans.Grids: with_halo
#= none:4 =#
using Oceananigans.Architectures
#= none:5 =#
using Oceananigans.Grids: AbstractGrid
#= none:6 =#
using Oceananigans.Fields: ReducedField
#= none:7 =#
using Oceananigans.Solvers: HeptadiagonalIterativeSolver
#= none:9 =#
import Oceananigans.Solvers: solve!
#= none:11 =#
#= none:11 =# Core.@doc "    struct MatrixImplicitFreeSurfaceSolver{S, R, T}\n\nThe matrix-based implicit free-surface solver.\n\n$(TYPEDFIELDS)\n" struct MatrixImplicitFreeSurfaceSolver{S, R, T}
        #= none:19 =#
        "The matrix iterative solver"
        #= none:20 =#
        matrix_iterative_solver::S
        #= none:21 =#
        "The right hand side of the free surface evolution equation"
        #= none:22 =#
        right_hand_side::R
        #= none:23 =#
        storage::T
    end
#= none:26 =#
#= none:26 =# Core.@doc "    MatrixImplicitFreeSurfaceSolver(grid::AbstractGrid, settings, gravitational_acceleration::Number)\n    \nReturn a solver for the elliptic equation with one of the iterative solvers of IterativeSolvers.jl\nwith a sparse matrix formulation.\n        \n```math\n[∇ ⋅ H ∇ - 1 / (g Δt²)] ηⁿ⁺¹ = (∇ʰ ⋅ Q★ - ηⁿ / Δt) / (g Δt) \n```\n    \nrepresenting an implicit time discretization of the linear free surface evolution equation\nfor a fluid with variable depth `H`, horizontal areas `Az`, barotropic volume flux `Q★`, time\nstep `Δt`, gravitational acceleration `g`, and free surface at time-step `n` `ηⁿ`.\n" function MatrixImplicitFreeSurfaceSolver(grid::AbstractGrid, settings, gravitational_acceleration::Number)
        #= none:40 =#
        #= none:43 =#
        ∫ᶻ_Axᶠᶜᶜ = Field((Face, Center, Nothing), grid)
        #= none:44 =#
        ∫ᶻ_Ayᶜᶠᶜ = Field((Center, Face, Nothing), grid)
        #= none:46 =#
        vertically_integrated_lateral_areas = (xᶠᶜᶜ = ∫ᶻ_Axᶠᶜᶜ, yᶜᶠᶜ = ∫ᶻ_Ayᶜᶠᶜ)
        #= none:48 =#
        compute_vertically_integrated_lateral_areas!(vertically_integrated_lateral_areas)
        #= none:50 =#
        arch = architecture(grid)
        #= none:51 =#
        right_hand_side = on_architecture(arch, zeros(grid.Nx * grid.Ny))
        #= none:53 =#
        storage = deepcopy(right_hand_side)
        #= none:56 =#
        settings = Dict{Symbol, Any}(settings)
        #= none:57 =#
        maximum_iterations = get(settings, :maximum_iterations, grid.Nx * grid.Ny)
        #= none:58 =#
        settings[:maximum_iterations] = maximum_iterations
        #= none:60 =#
        coeffs = compute_matrix_coefficients(vertically_integrated_lateral_areas, grid, gravitational_acceleration)
        #= none:61 =#
        solver = HeptadiagonalIterativeSolver(coeffs; template = right_hand_side, reduced_dim = (false, false, true), grid, settings...)
        #= none:63 =#
        return MatrixImplicitFreeSurfaceSolver(solver, right_hand_side, storage)
    end
#= none:66 =#
build_implicit_step_solver(::Val{:HeptadiagonalIterativeSolver}, grid, settings, gravitational_acceleration) = begin
        #= none:66 =#
        MatrixImplicitFreeSurfaceSolver(grid, settings, gravitational_acceleration)
    end
#= none:73 =#
function solve!(η, implicit_free_surface_solver::MatrixImplicitFreeSurfaceSolver, rhs, g, Δt)
    #= none:73 =#
    #= none:74 =#
    solver = implicit_free_surface_solver.matrix_iterative_solver
    #= none:75 =#
    storage = implicit_free_surface_solver.storage
    #= none:77 =#
    solve!(storage, solver, rhs, Δt)
    #= none:79 =#
    set!(η, reshape(storage, solver.problem_size...))
    #= none:81 =#
    return nothing
end
#= none:84 =#
function compute_implicit_free_surface_right_hand_side!(rhs, implicit_solver::MatrixImplicitFreeSurfaceSolver, g, Δt, ∫ᶻQ, η)
    #= none:84 =#
    #= none:88 =#
    solver = implicit_solver.matrix_iterative_solver
    #= none:89 =#
    grid = solver.grid
    #= none:90 =#
    arch = architecture(grid)
    #= none:92 =#
    launch!(arch, grid, :xy, implicit_linearized_free_surface_right_hand_side!, rhs, grid, g, Δt, ∫ᶻQ, η)
    #= none:96 =#
    return nothing
end
#= none:100 =#
#= none:100 =# @kernel function implicit_linearized_free_surface_right_hand_side!(rhs, grid, g, Δt, ∫ᶻQ, η)
        #= none:100 =#
        #= none:101 =#
        (i, j) = #= none:101 =# @index(Global, NTuple)
        #= none:102 =#
        k_top = grid.Nz + 1
        #= none:103 =#
        Az = Azᶜᶜᶠ(i, j, k_top, grid)
        #= none:104 =#
        δ_Q = flux_div_xyᶜᶜᶠ(i, j, k_top, grid, ∫ᶻQ.u, ∫ᶻQ.v)
        #= none:105 =#
        t = i + grid.Nx * (j - 1)
        #= none:106 =#
        #= none:106 =# @inbounds rhs[t] = (δ_Q - (Az * η[i, j, k_top]) / Δt) / (g * Δt)
    end
#= none:109 =#
function compute_matrix_coefficients(vertically_integrated_areas, grid, gravitational_acceleration)
    #= none:109 =#
    #= none:111 =#
    arch = grid.architecture
    #= none:113 =#
    (Nx, Ny) = (grid.Nx, grid.Ny)
    #= none:115 =#
    C = on_architecture(arch, zeros(eltype(grid), Nx, Ny, 1))
    #= none:116 =#
    diag = on_architecture(arch, zeros(eltype(grid), Nx, Ny, 1))
    #= none:117 =#
    Ax = on_architecture(arch, zeros(eltype(grid), Nx, Ny, 1))
    #= none:118 =#
    Ay = on_architecture(arch, zeros(eltype(grid), Nx, Ny, 1))
    #= none:119 =#
    Az = on_architecture(arch, zeros(eltype(grid), Nx, Ny, 1))
    #= none:121 =#
    ∫Ax = vertically_integrated_areas.xᶠᶜᶜ
    #= none:122 =#
    ∫Ay = vertically_integrated_areas.yᶜᶠᶜ
    #= none:124 =#
    launch!(arch, grid, :xy, _compute_coefficients!, diag, Ax, Ay, ∫Ax, ∫Ay, grid, gravitational_acceleration)
    #= none:127 =#
    return (Ax, Ay, Az, C, diag)
end
#= none:130 =#
#= none:130 =# @kernel function _compute_coefficients!(diag, Ax, Ay, ∫Ax, ∫Ay, grid, g)
        #= none:130 =#
        #= none:131 =#
        (i, j) = #= none:131 =# @index(Global, NTuple)
        #= none:132 =#
        #= none:132 =# @inbounds begin
                #= none:133 =#
                Ay[i, j, 1] = ∫Ay[i, j, 1] / Δyᶜᶠᶠ(i, j, grid.Nz + 1, grid)
                #= none:134 =#
                Ax[i, j, 1] = ∫Ax[i, j, 1] / Δxᶠᶜᶠ(i, j, grid.Nz + 1, grid)
                #= none:135 =#
                diag[i, j, 1] = -(Azᶜᶜᶠ(i, j, grid.Nz + 1, grid)) / g
            end
    end