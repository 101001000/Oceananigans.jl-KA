
#= none:1 =#
using Oceananigans.Operators
#= none:2 =#
using Oceananigans.DistributedComputations: DistributedFFTBasedPoissonSolver
#= none:3 =#
using Oceananigans.Grids: XDirection, YDirection, ZDirection, inactive_cell
#= none:4 =#
using Oceananigans.Solvers: FFTBasedPoissonSolver, FourierTridiagonalPoissonSolver
#= none:5 =#
using Oceananigans.Solvers: ConjugateGradientPoissonSolver
#= none:6 =#
using Oceananigans.Solvers: solve!
#= none:12 =#
#= none:12 =# @kernel function _compute_source_term!(rhs, grid, Δt, Ũ)
        #= none:12 =#
        #= none:13 =#
        (i, j, k) = #= none:13 =# @index(Global, NTuple)
        #= none:14 =#
        active = !(inactive_cell(i, j, k, grid))
        #= none:15 =#
        δ = divᶜᶜᶜ(i, j, k, grid, Ũ.u, Ũ.v, Ũ.w)
        #= none:16 =#
        #= none:16 =# @inbounds rhs[i, j, k] = (active * δ) / Δt
    end
#= none:19 =#
#= none:19 =# @kernel function _fourier_tridiagonal_source_term!(rhs, ::XDirection, grid, Δt, Ũ)
        #= none:19 =#
        #= none:20 =#
        (i, j, k) = #= none:20 =# @index(Global, NTuple)
        #= none:21 =#
        active = !(inactive_cell(i, j, k, grid))
        #= none:22 =#
        δ = divᶜᶜᶜ(i, j, k, grid, Ũ.u, Ũ.v, Ũ.w)
        #= none:23 =#
        #= none:23 =# @inbounds rhs[i, j, k] = (active * Δxᶜᶜᶜ(i, j, k, grid) * δ) / Δt
    end
#= none:26 =#
#= none:26 =# @kernel function _fourier_tridiagonal_source_term!(rhs, ::YDirection, grid, Δt, Ũ)
        #= none:26 =#
        #= none:27 =#
        (i, j, k) = #= none:27 =# @index(Global, NTuple)
        #= none:28 =#
        active = !(inactive_cell(i, j, k, grid))
        #= none:29 =#
        δ = divᶜᶜᶜ(i, j, k, grid, Ũ.u, Ũ.v, Ũ.w)
        #= none:30 =#
        #= none:30 =# @inbounds rhs[i, j, k] = (active * Δyᶜᶜᶜ(i, j, k, grid) * δ) / Δt
    end
#= none:33 =#
#= none:33 =# @kernel function _fourier_tridiagonal_source_term!(rhs, ::ZDirection, grid, Δt, Ũ)
        #= none:33 =#
        #= none:34 =#
        (i, j, k) = #= none:34 =# @index(Global, NTuple)
        #= none:35 =#
        active = !(inactive_cell(i, j, k, grid))
        #= none:36 =#
        δ = divᶜᶜᶜ(i, j, k, grid, Ũ.u, Ũ.v, Ũ.w)
        #= none:37 =#
        #= none:37 =# @inbounds rhs[i, j, k] = (active * Δzᶜᶜᶜ(i, j, k, grid) * δ) / Δt
    end
#= none:40 =#
function compute_source_term!(pressure, solver::DistributedFFTBasedPoissonSolver, Δt, Ũ)
    #= none:40 =#
    #= none:41 =#
    rhs = solver.storage.zfield
    #= none:42 =#
    arch = architecture(solver)
    #= none:43 =#
    grid = solver.local_grid
    #= none:44 =#
    launch!(arch, grid, :xyz, _compute_source_term!, rhs, grid, Δt, Ũ)
    #= none:45 =#
    return nothing
end
#= none:48 =#
function compute_source_term!(pressure, solver::DistributedFourierTridiagonalPoissonSolver, Δt, Ũ)
    #= none:48 =#
    #= none:49 =#
    rhs = solver.storage.zfield
    #= none:50 =#
    arch = architecture(solver)
    #= none:51 =#
    grid = solver.local_grid
    #= none:52 =#
    tdir = solver.batched_tridiagonal_solver.tridiagonal_direction
    #= none:53 =#
    launch!(arch, grid, :xyz, _fourier_tridiagonal_source_term!, rhs, tdir, grid, Δt, Ũ)
    #= none:54 =#
    return nothing
end
#= none:57 =#
function compute_source_term!(pressure, solver::FourierTridiagonalPoissonSolver, Δt, Ũ)
    #= none:57 =#
    #= none:58 =#
    rhs = solver.source_term
    #= none:59 =#
    arch = architecture(solver)
    #= none:60 =#
    grid = solver.grid
    #= none:61 =#
    tdir = solver.batched_tridiagonal_solver.tridiagonal_direction
    #= none:62 =#
    launch!(arch, grid, :xyz, _fourier_tridiagonal_source_term!, rhs, tdir, grid, Δt, Ũ)
    #= none:63 =#
    return nothing
end
#= none:66 =#
function compute_source_term!(pressure, solver::FFTBasedPoissonSolver, Δt, Ũ)
    #= none:66 =#
    #= none:67 =#
    rhs = solver.storage
    #= none:68 =#
    arch = architecture(solver)
    #= none:69 =#
    grid = solver.grid
    #= none:70 =#
    launch!(arch, grid, :xyz, _compute_source_term!, rhs, grid, Δt, Ũ)
    #= none:71 =#
    return nothing
end
#= none:78 =#
function solve_for_pressure!(pressure, solver, Δt, Ũ)
    #= none:78 =#
    #= none:79 =#
    compute_source_term!(pressure, solver, Δt, Ũ)
    #= none:80 =#
    solve!(pressure, solver)
    #= none:81 =#
    return pressure
end
#= none:84 =#
function solve_for_pressure!(pressure, solver::ConjugateGradientPoissonSolver, Δt, Ũ)
    #= none:84 =#
    #= none:85 =#
    rhs = solver.right_hand_side
    #= none:86 =#
    grid = solver.grid
    #= none:87 =#
    arch = architecture(grid)
    #= none:88 =#
    launch!(arch, grid, :xyz, _compute_source_term!, rhs, grid, Δt, Ũ)
    #= none:89 =#
    return solve!(pressure, solver.conjugate_gradient_solver, rhs)
end