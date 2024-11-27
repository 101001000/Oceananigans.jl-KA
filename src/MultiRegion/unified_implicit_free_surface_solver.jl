
#= none:1 =#
using Oceananigans.Solvers
#= none:2 =#
using Oceananigans.Operators
#= none:3 =#
using Oceananigans.Architectures
#= none:4 =#
using Oceananigans.Grids: on_architecture
#= none:5 =#
using Oceananigans.Fields: Field
#= none:7 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: compute_vertically_integrated_lateral_areas!, compute_matrix_coefficients, flux_div_xyᶜᶜᶠ, PCGImplicitFreeSurfaceSolver
#= none:12 =#
import Oceananigans.Models.HydrostaticFreeSurfaceModels: build_implicit_step_solver, compute_implicit_free_surface_right_hand_side!
#= none:15 =#
import Oceananigans.Architectures: architecture
#= none:16 =#
import Oceananigans.Solvers: solve!
#= none:18 =#
struct UnifiedImplicitFreeSurfaceSolver{S, R, T}
    #= none:19 =#
    unified_pcg_solver::S
    #= none:20 =#
    right_hand_side::R
    #= none:21 =#
    storage::T
end
#= none:24 =#
architecture(solver::UnifiedImplicitFreeSurfaceSolver) = begin
        #= none:24 =#
        architecture(solver.preconditioned_conjugate_gradient_solver)
    end
#= none:27 =#
function UnifiedImplicitFreeSurfaceSolver(mrg::MultiRegionGrids, settings, gravitational_acceleration::Number; multiple_devices = false)
    #= none:27 =#
    #= none:30 =#
    grid = reconstruct_global_grid(mrg)
    #= none:32 =#
    ∫ᶻ_Axᶠᶜᶜ = Field((Face, Center, Nothing), grid)
    #= none:33 =#
    ∫ᶻ_Ayᶜᶠᶜ = Field((Center, Face, Nothing), grid)
    #= none:35 =#
    vertically_integrated_lateral_areas = (xᶠᶜᶜ = ∫ᶻ_Axᶠᶜᶜ, yᶜᶠᶜ = ∫ᶻ_Ayᶜᶠᶜ)
    #= none:37 =#
    compute_vertically_integrated_lateral_areas!(vertically_integrated_lateral_areas)
    #= none:38 =#
    fill_halo_regions!(vertically_integrated_lateral_areas)
    #= none:40 =#
    arch = architecture(mrg)
    #= none:41 =#
    right_hand_side = unified_array(arch, zeros(eltype(grid), grid.Nx * grid.Ny))
    #= none:42 =#
    storage = deepcopy(right_hand_side)
    #= none:45 =#
    settings = Dict{Symbol, Any}(settings)
    #= none:46 =#
    maximum_iterations = get(settings, :maximum_iterations, grid.Nx * grid.Ny)
    #= none:47 =#
    settings[:maximum_iterations] = maximum_iterations
    #= none:49 =#
    coeffs = compute_matrix_coefficients(vertically_integrated_lateral_areas, grid, gravitational_acceleration)
    #= none:51 =#
    reduced_dim = (false, false, true)
    #= none:52 =#
    solver = if multiple_devices
            UnifiedDiagonalIterativeSolver(coeffs; reduced_dim, grid, mrg, settings...)
        else
            HeptadiagonalIterativeSolver(coeffs; reduced_dim, template = right_hand_side, grid, settings...)
        end
    #= none:58 =#
    return UnifiedImplicitFreeSurfaceSolver(solver, right_hand_side, storage)
end
#= none:61 =#
build_implicit_step_solver(::Val{:HeptadiagonalIterativeSolver}, grid::MultiRegionGrids, settings, gravitational_acceleration) = begin
        #= none:61 =#
        UnifiedImplicitFreeSurfaceSolver(grid, settings, gravitational_acceleration)
    end
#= none:63 =#
build_implicit_step_solver(::Val{:Default}, grid::MultiRegionGrids, settings, gravitational_acceleration) = begin
        #= none:63 =#
        UnifiedImplicitFreeSurfaceSolver(grid, settings, gravitational_acceleration)
    end
#= none:65 =#
build_implicit_step_solver(::Val{:PreconditionedConjugateGradient}, grid::MultiRegionGrids, settings, gravitational_acceleration) = begin
        #= none:65 =#
        throw(ArgumentError("Cannot use PCG solver with Multi-region grids!! Select :Default or :HeptadiagonalIterativeSolver as solver_method"))
    end
#= none:67 =#
build_implicit_step_solver(::Val{:Default}, grid::ConformalCubedSphereGrid, settings, gravitational_acceleration) = begin
        #= none:67 =#
        PCGImplicitFreeSurfaceSolver(grid, settings, gravitational_acceleration)
    end
#= none:69 =#
build_implicit_step_solver(::Val{:HeptadiagonalIterativeSolver}, grid::ConformalCubedSphereGrid, settings, gravitational_acceleration) = begin
        #= none:69 =#
        throw(ArgumentError("Cannot use Matrix solvers with ConformalCubedSphereGrid!! Select :Default or :PreconditionedConjugateGradient as solver_method"))
    end
#= none:72 =#
function compute_implicit_free_surface_right_hand_side!(rhs, implicit_solver::UnifiedImplicitFreeSurfaceSolver, g, Δt, ∫ᶻQ, η)
    #= none:72 =#
    #= none:73 =#
    grid = ∫ᶻQ.u.grid
    #= none:74 =#
    M = length(grid.partition)
    #= none:75 =#
    #= none:75 =# @apply_regionally compute_regional_rhs!(rhs, grid, g, Δt, ∫ᶻQ, η, Iterate(1:M), grid.partition)
    #= none:76 =#
    return nothing
end
#= none:79 =#
compute_regional_rhs!(rhs, grid, g, Δt, ∫ᶻQ, η, region, partition) = begin
        #= none:79 =#
        launch!(architecture(grid), grid, :xy, implicit_linearized_unified_free_surface_right_hand_side!, rhs, grid, g, Δt, ∫ᶻQ, η, region, partition)
    end
#= none:85 =#
#= none:85 =# @kernel function implicit_linearized_unified_free_surface_right_hand_side!(rhs, grid, g, Δt, ∫ᶻQ, η, region, partition)
        #= none:85 =#
        #= none:86 =#
        (i, j) = #= none:86 =# @index(Global, NTuple)
        #= none:87 =#
        Az = Azᶜᶜᶜ(i, j, 1, grid)
        #= none:88 =#
        δ_Q = flux_div_xyᶜᶜᶠ(i, j, 1, grid, ∫ᶻQ.u, ∫ᶻQ.v)
        #= none:89 =#
        t = displaced_xy_index(i, j, grid, region, partition)
        #= none:90 =#
        #= none:90 =# @inbounds rhs[t] = (δ_Q - (Az * η[i, j, grid.Nz + 1]) / Δt) / (g * Δt)
    end
#= none:93 =#
function solve!(η, implicit_free_surface_solver::UnifiedImplicitFreeSurfaceSolver, rhs, g, Δt)
    #= none:93 =#
    #= none:95 =#
    solver = implicit_free_surface_solver.unified_pcg_solver
    #= none:96 =#
    storage = implicit_free_surface_solver.storage
    #= none:98 =#
    sync_all_devices!(η.grid.devices)
    #= none:100 =#
    switch_device!(getdevice(solver.matrix_constructors[1]))
    #= none:101 =#
    solve!(storage, solver, rhs, Δt)
    #= none:103 =#
    arch = architecture(solver)
    #= none:104 =#
    grid = η.grid
    #= none:106 =#
    #= none:106 =# @apply_regionally redistribute_lhs!(η, storage, arch, grid, Iterate(1:length(grid)), grid.partition)
    #= none:108 =#
    fill_halo_regions!(η)
    #= none:110 =#
    return nothing
end
#= none:113 =#
redistribute_lhs!(η, sol, arch, grid, region, partition) = begin
        #= none:113 =#
        launch!(arch, grid, :xy, _redistribute_lhs!, η, sol, region, grid, partition)
    end
#= none:117 =#
#= none:117 =# @kernel function _redistribute_lhs!(η, sol, region, grid, partition)
        #= none:117 =#
        #= none:118 =#
        (i, j) = #= none:118 =# @index(Global, NTuple)
        #= none:119 =#
        t = displaced_xy_index(i, j, grid, region, partition)
        #= none:120 =#
        #= none:120 =# @inbounds η[i, j, grid.Nz + 1] = sol[t]
    end