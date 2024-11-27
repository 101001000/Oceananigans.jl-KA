
#= none:1 =#
push!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using BenchmarkTools
#= none:4 =#
using BSON
#= none:5 =#
using Oceananigans
#= none:6 =#
using Benchmarks
#= none:8 =#
N = parse(Int, ARGS[1])
#= none:9 =#
grid = RectilinearGrid(size = (N, N, N), extent = (1, 1, 1))
#= none:10 =#
model = NonhydrostaticModel(grid = grid)
#= none:12 =#
time_step!(model, 1)
#= none:14 =#
trial = #= none:14 =# @benchmark(begin
            #= none:15 =#
            #= none:15 =# @sync_gpu time_step!($model, 1)
        end, samples = 10)
#= none:18 =#
bson("multithreading_benchmark_$(Threads.nthreads()).bson", Dict(:trial => trial))