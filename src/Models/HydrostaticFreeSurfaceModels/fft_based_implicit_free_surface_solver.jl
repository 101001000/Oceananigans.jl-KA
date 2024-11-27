
#= none:1 =#
using Oceananigans.Grids
#= none:2 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid
#= none:3 =#
using Oceananigans.Grids: x_domain, y_domain
#= none:4 =#
using Oceananigans.Solvers
#= none:5 =#
using Oceananigans.Operators
#= none:6 =#
using Oceananigans.Architectures
#= none:7 =#
using Oceananigans.Fields: ReducedField
#= none:8 =#
using Statistics
#= none:10 =#
import Oceananigans.Solvers: solve!
#= none:12 =#
struct FFTImplicitFreeSurfaceSolver{S, G3, G2, R}
    #= none:13 =#
    fft_poisson_solver::S
    #= none:14 =#
    three_dimensional_grid::G3
    #= none:15 =#
    horizontal_grid::G2
    #= none:16 =#
    right_hand_side::R
end
#= none:19 =#
validate_fft_implicit_solver_grid(grid) = begin
        #= none:19 =#
        grid isa XYZRegularRG || (grid isa XYRegularRG || throw(ArgumentError("FFTImplicitFreeSurfaceSolver requires horizontally-regular rectilinear grids.")))
    end
#= none:23 =#
validate_fft_implicit_solver_grid(ibg::ImmersedBoundaryGrid) = begin
        #= none:23 =#
        validate_fft_implicit_solver_grid(ibg.underlying_grid)
    end
#= none:26 =#
#= none:26 =# Core.@doc "    FFTImplicitFreeSurfaceSolver(grid, settings=nothing, gravitational_acceleration=nothing)\n\nReturn a solver based on the fast Fourier transform for the elliptic equation\n    \n```math\n[∇² - 1 / (g H Δt²)] ηⁿ⁺¹ = (∇ʰ ⋅ Q★ - ηⁿ / Δt) / (g H Δt)\n```\n\nrepresenting an implicit time discretization of the linear free surface evolution equation\nfor a fluid with constant depth `H`, horizontal areas `Az`, barotropic volume flux `Q★`, time\nstep `Δt`, gravitational acceleration `g`, and free surface at time-step `n`, `ηⁿ`.\n" function FFTImplicitFreeSurfaceSolver(grid, settings = nothing, gravitational_acceleration = nothing)
        #= none:39 =#
        #= none:41 =#
        validate_fft_implicit_solver_grid(grid)
        #= none:44 =#
        (TX, TY, TZ) = topology(grid)
        #= none:45 =#
        sz = ((Nx, Ny) = (grid.Nx, grid.Ny))
        #= none:46 =#
        halo = (grid.Hx, grid.Hy)
        #= none:47 =#
        domain = (x = x_domain(grid), y = y_domain(grid))
        #= none:51 =#
        nonflat_dims = findall((T->begin
                        #= none:51 =#
                        !(T() isa Flat)
                    end), (TX, TY))
        #= none:53 =#
        sz = Tuple((sz[i] for i = nonflat_dims))
        #= none:54 =#
        halo = Tuple((halo[i] for i = nonflat_dims))
        #= none:55 =#
        domain = NamedTuple((((:x, :y))[i] => domain[i] for i = nonflat_dims))
        #= none:61 =#
        horizontal_grid = RectilinearGrid(architecture(grid), eltype(grid); topology = (TX, TY, Flat), size = sz, halo = halo, domain...)
        #= none:67 =#
        solver = FFTBasedPoissonSolver(horizontal_grid)
        #= none:68 =#
        right_hand_side = solver.storage
        #= none:70 =#
        return FFTImplicitFreeSurfaceSolver(solver, grid, horizontal_grid, right_hand_side)
    end
#= none:73 =#
build_implicit_step_solver(::Val{:FastFourierTransform}, grid, settings, gravitational_acceleration) = begin
        #= none:73 =#
        FFTImplicitFreeSurfaceSolver(grid, settings, gravitational_acceleration)
    end
#= none:80 =#
function solve!(η, implicit_free_surface_solver::FFTImplicitFreeSurfaceSolver, rhs, g, Δt)
    #= none:80 =#
    #= none:81 =#
    solver = implicit_free_surface_solver.fft_poisson_solver
    #= none:82 =#
    grid = implicit_free_surface_solver.three_dimensional_grid
    #= none:83 =#
    Lz = grid.Lz
    #= none:86 =#
    m = -1 / (g * Lz * Δt ^ 2)
    #= none:89 =#
    solve!(η, solver, rhs, m)
    #= none:91 =#
    return η
end
#= none:94 =#
function compute_implicit_free_surface_right_hand_side!(rhs, implicit_solver::FFTImplicitFreeSurfaceSolver, g, Δt, ∫ᶻQ, η)
    #= none:94 =#
    #= none:97 =#
    poisson_solver = implicit_solver.fft_poisson_solver
    #= none:98 =#
    arch = architecture(poisson_solver)
    #= none:99 =#
    grid = implicit_solver.three_dimensional_grid
    #= none:100 =#
    Lz = grid.Lz
    #= none:102 =#
    launch!(arch, grid, :xy, fft_implicit_free_surface_right_hand_side!, rhs, grid, g, Lz, Δt, ∫ᶻQ, η)
    #= none:106 =#
    return nothing
end
#= none:109 =#
#= none:109 =# @kernel function fft_implicit_free_surface_right_hand_side!(rhs, grid, g, Lz, Δt, ∫ᶻQ, η)
        #= none:109 =#
        #= none:110 =#
        (i, j) = #= none:110 =# @index(Global, NTuple)
        #= none:111 =#
        k_top = grid.Nz + 1
        #= none:112 =#
        Az = Azᶜᶜᶠ(i, j, k_top, grid)
        #= none:113 =#
        δ_Q = flux_div_xyᶜᶜᶠ(i, j, k_top, grid, ∫ᶻQ.u, ∫ᶻQ.v)
        #= none:114 =#
        #= none:114 =# @inbounds rhs[i, j, 1] = (δ_Q - (Az * η[i, j, k_top]) / Δt) / (g * Lz * Δt * Az)
    end