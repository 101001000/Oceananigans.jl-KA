
#= none:1 =#
push!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using Logging
#= none:4 =#
using JLD2
#= none:5 =#
using BenchmarkTools
#= none:6 =#
using Benchmarks
#= none:8 =#
using Oceananigans
#= none:9 =#
using Oceananigans.Models
#= none:10 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:12 =#
Logging.global_logger(OceananigansLogger())
#= none:14 =#
Nx = parse(Int, ARGS[1])
#= none:15 =#
Ny = parse(Int, ARGS[2])
#= none:17 =#
T = Threads.nthreads()
#= none:19 =#
#= none:19 =# @info "Setting up threaded serial shallow water model with N=($(Nx), $(Ny)) grid points and $(T) threads..."
#= none:21 =#
topo = (Periodic, Periodic, Flat)
#= none:22 =#
grid = RectilinearGrid(topology = topo, size = (Nx, Ny), extent = (1, 1), halo = (3, 3))
#= none:23 =#
model = ShallowWaterModel(grid = grid, gravitational_acceleration = 1.0)
#= none:24 =#
set!(model, h = 1.0)
#= none:26 =#
#= none:26 =# @info "Warming up serial shallow water model..."
#= none:28 =#
time_step!(model, 1)
#= none:30 =#
#= none:30 =# @info "Benchmarking serial shallow water model..."
#= none:32 =#
trial = #= none:32 =# @benchmark(begin
            #= none:33 =#
            #= none:33 =# @sync_gpu time_step!($model, 1)
        end, samples = 10, evals = 1)
#= none:37 =#
t_median = BenchmarkTools.prettytime((median(trial)).time)
#= none:38 =#
#= none:38 =# @info "Done benchmarking. Median time: $(t_median)"
#= none:40 =#
jldopen("distributed_shallow_water_model_threads$(T).jld2", "w") do file
    #= none:41 =#
    file["trial"] = trial
end