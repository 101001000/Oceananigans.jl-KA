
#= none:1 =#
pushfirst!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using Oceananigans
#= none:4 =#
using Oceananigans.TimeSteppers: time_step!
#= none:5 =#
using BenchmarkTools
#= none:7 =#
N = 256
#= none:9 =#
xy_grid = RegularRectilinearGrid(size = (N, N, 1), halo = (3, 3, 3), extent = (2π, 2π, 2π), topology = (Periodic, Periodic, Bounded))
#= none:10 =#
xz_grid = RegularRectilinearGrid(size = (N, 1, N), halo = (3, 3, 3), extent = (2π, 2π, 2π), topology = (Periodic, Periodic, Bounded))
#= none:11 =#
yz_grid = RegularRectilinearGrid(size = (1, N, N), halo = (3, 3, 3), extent = (2π, 2π, 2π), topology = (Periodic, Periodic, Bounded))
#= none:13 =#
function ten_steps!(model)
    #= none:13 =#
    #= none:14 =#
    for _ = 1:10
        #= none:15 =#
        time_step!(model, 1.0e-6)
        #= none:16 =#
    end
    #= none:17 =#
    return nothing
end
#= none:20 =#
for arch = (CPU(), GPU())
    #= none:22 =#
    for grid = (xy_grid, xz_grid, yz_grid)
        #= none:26 =#
        model = NonhydrostaticModel(timestepper = :QuasiAdamsBashforth2, grid = grid, advection = nothing, closure = nothing, buoyancy = nothing, tracers = nothing)
        #= none:33 =#
        time_step!(model, 1.0e-6)
        #= none:35 =#
        #= none:35 =# @info "Benchmarking $(arch) model with $(summary(grid))..."
        #= none:36 =#
        #= none:36 =# @btime ten_steps!($model)
        #= none:37 =#
    end
    #= none:38 =#
end