
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
#= none:16 =#
Nz = parse(Int, ARGS[3])
#= none:18 =#
T = Threads.nthreads()
#= none:20 =#
#= none:20 =# @info "Setting up threaded serial nonhydrostatic model with N=($(Nx), $(Ny), $(Nz)) grid points and $(T) threads..."
#= none:22 =#
topo = (Periodic, Periodic, Periodic)
#= none:23 =#
grid = RectilinearGrid(topology = topo, size = (Nx, Ny, Nz), extent = (1, 1, 1))
#= none:24 =#
model = NonhydrostaticModel(grid = grid)
#= none:26 =#
#= none:26 =# @info "Warming up serial nonhydrostatic model..."
#= none:28 =#
time_step!(model, 1)
#= none:30 =#
#= none:30 =# @info "Benchmarking serial nonhydrostatic model..."
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
jldopen("distributed_nonhydrostatic_model_threads$(T).jld2", "w") do file
    #= none:41 =#
    file["trial"] = trial
end