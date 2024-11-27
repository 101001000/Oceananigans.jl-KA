
#= none:1 =#
push!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using BenchmarkTools
#= none:4 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:5 =#
using Oceananigans
#= none:6 =#
using Oceananigans.Grids: metrics_precomputed
#= none:8 =#
N = 256
#= none:10 =#
function multiple_steps!(model)
    #= none:10 =#
    #= none:11 =#
    for i = 1:20
        #= none:12 =#
        time_step!(model, 1.0e-6)
        #= none:13 =#
    end
    #= none:14 =#
    return nothing
end
#= none:17 =#
for arch = [if true
                [CPU(), GPU()]
            else
                [CPU()]
            end]
    #= none:19 =#
    grid_fly = LatitudeLongitudeGrid(size = (N, N, 1), halo = (2, 2, 2), latitude = (-60, 60), longitude = (-180, 180), z = (-10, 0), architecture = arch)
    #= none:26 =#
    grid_pre = LatitudeLongitudeGrid(size = (N, N, 1), halo = (2, 2, 2), latitude = (-60, 60), longitude = (-180, 180), z = (-10, 0), architecture = arch, precompute_metrics = true)
    #= none:35 =#
    for grid = (grid_fly, grid_pre)
        #= none:37 =#
        model = HydrostaticFreeSurfaceModel(grid = grid, momentum_advection = VectorInvariant(), free_surface = ExplicitFreeSurface())
        #= none:41 =#
        time_step!(model, 1.0e-6)
        #= none:43 =#
        if metrics_precomputed(grid)
            a = "precomputed metrics"
        else
            a = "calculated metrics"
        end
        #= none:45 =#
        #= none:45 =# @info "Benchmarking $(arch) model with " * a * "..."
        #= none:46 =#
        #= none:46 =# @btime multiple_steps!($model)
        #= none:48 =#
    end
    #= none:49 =#
end