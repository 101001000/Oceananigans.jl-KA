
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
#= none:11 =#
Logging.global_logger(OceananigansLogger())
#= none:13 =#
MPI.Init()
#= none:15 =#
comm = MPI.COMM_WORLD
#= none:16 =#
local_rank = MPI.Comm_rank(comm)
#= none:17 =#
R = MPI.Comm_size(comm)
#= none:19 =#
Nx = parse(Int, ARGS[1])
#= none:20 =#
Ny = parse(Int, ARGS[2])
#= none:21 =#
Nz = parse(Int, ARGS[3])
#= none:22 =#
Rx = parse(Int, ARGS[4])
#= none:23 =#
Ry = parse(Int, ARGS[5])
#= none:24 =#
Rz = parse(Int, ARGS[6])
#= none:26 =#
#= none:26 =# @assert Rx * Ry * Rz == R
#= none:28 =#
#= none:28 =# @info "Setting up distributed nonhydrostatic model with N=($(Nx), $(Ny), $(Nz)) grid points and ranks=($(Rx), $(Ry), $(Rz)) on rank $(local_rank)..."
#= none:30 =#
topo = (Periodic, Periodic, Periodic)
#= none:31 =#
arch = Distributed(CPU(), topology = topo, ranks = (Rx, Ry, Rz), communicator = MPI.COMM_WORLD)
#= none:32 =#
distributed_grid = RectilinearGrid(arch, topology = topo, size = (Nx, Ny, Nz), extent = (1, 1, 1))
#= none:33 =#
model = NonhydrostaticModel(grid = distributed_grid)
#= none:35 =#
#= none:35 =# @info "Warming up distributed nonhydrostatic model on rank $(local_rank)..."
#= none:37 =#
time_step!(model, 1)
#= none:39 =#
#= none:39 =# @info "Benchmarking distributed nonhydrostatic model on rank $(local_rank)..."
#= none:41 =#
MPI.Barrier(comm)
#= none:43 =#
trial = #= none:43 =# @benchmark(begin
            #= none:44 =#
            time_step!($model, 1)
        end, samples = 10, evals = 1)
#= none:47 =#
MPI.Barrier(comm)
#= none:49 =#
t_median = BenchmarkTools.prettytime((median(trial)).time)
#= none:50 =#
#= none:50 =# @info "Done benchmarking on rank $(local_rank). Median time: $(t_median)"
#= none:52 =#
jldopen("distributed_nonhydrostatic_model_$(R)ranks_$(local_rank).jld2", "w") do file
    #= none:53 =#
    file["trial"] = trial
end