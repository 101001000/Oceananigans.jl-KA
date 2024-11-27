
#= none:1 =#
push!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using Logging
#= none:4 =#
using MPI
#= none:5 =#
using JLD2
#= none:6 =#
using BenchmarkTools
#= none:8 =#
using Oceananigans
#= none:9 =#
using Oceananigans.DistributedComputations
#= none:10 =#
using Benchmarks
#= none:12 =#
Logging.global_logger(OceananigansLogger())
#= none:14 =#
MPI.Init()
#= none:16 =#
comm = MPI.COMM_WORLD
#= none:17 =#
local_rank = MPI.Comm_rank(comm)
#= none:18 =#
R = MPI.Comm_size(comm)
#= none:23 =#
Nx = parse(Int, ARGS[1])
#= none:24 =#
Ny = parse(Int, ARGS[2])
#= none:25 =#
Rx = parse(Int, ARGS[3])
#= none:26 =#
Ry = parse(Int, ARGS[4])
#= none:28 =#
#= none:28 =# @assert Rx * Ry == R
#= none:30 =#
#= none:30 =# @info "Setting up distributed shallow water model with N=($(Nx), $(Ny)) grid points and ranks=($(Rx), $(Ry)) on rank $(local_rank)..."
#= none:32 =#
topo = (Periodic, Periodic, Flat)
#= none:33 =#
arch = Distributed(CPU(), topology = topo, ranks = (Rx, Ry, 1), communicator = MPI.COMM_WORLD)
#= none:34 =#
distributed_grid = RectilinearGrid(arch, topology = topo, size = (Nx, Ny), extent = (1, 1))
#= none:35 =#
model = ShallowWaterModel(grid = distributed_grid, gravitational_acceleration = 1.0)
#= none:36 =#
set!(model, h = 1)
#= none:38 =#
#= none:38 =# @info "Warming up distributed shallow water model on rank $(local_rank)..."
#= none:40 =#
time_step!(model, 1)
#= none:42 =#
#= none:42 =# @info "Benchmarking distributed shallow water model on rank $(local_rank)..."
#= none:44 =#
MPI.Barrier(comm)
#= none:46 =#
trial = #= none:46 =# @benchmark(begin
            #= none:47 =#
            #= none:47 =# @sync_gpu time_step!($model, 1)
        end, samples = 10, evals = 1)
#= none:50 =#
MPI.Barrier(comm)
#= none:52 =#
t_median = BenchmarkTools.prettytime((median(trial)).time)
#= none:53 =#
#= none:53 =# @info "Done benchmarking on rank $(local_rank). Median time: $(t_median)"
#= none:55 =#
jldopen("distributed_shallow_water_model_$(R)ranks_$(local_rank).jld2", "w") do file
    #= none:56 =#
    file["trial"] = trial
end