
#= none:1 =#
push!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using BenchmarkTools
#= none:4 =#
using BSON
#= none:5 =#
using Benchmarks
#= none:9 =#
N = 512
#= none:10 =#
n_threads = min.(2 .^ (0:10), Sys.CPU_THREADS) |> unique
#= none:14 =#
print_system_info()
#= none:16 =#
for t = n_threads
    #= none:17 =#
    #= none:17 =# @info "Benchmarking multithreading (N=$(N), threads=$(t))..."
    #= none:18 =#
    julia = Base.julia_cmd()
    #= none:19 =#
    run(`$julia -t $t --project benchmark_multithreading_single.jl $N`)
    #= none:20 =#
end
#= none:22 =#
suite = BenchmarkGroup(["size", "threads"])
#= none:23 =#
for t = n_threads
    #= none:24 =#
    suite[(N, t)] = (BSON.load("multithreading_benchmark_$(t).bson"))[:trial]
    #= none:25 =#
end
#= none:29 =#
df = benchmarks_dataframe(suite)
#= none:30 =#
sort!(df, :threads)
#= none:31 =#
benchmarks_pretty_table(df, title = "Multithreading benchmarks")
#= none:33 =#
suite_Δ = speedups_suite(suite, base_case = (N, 1))
#= none:34 =#
df_Δ = speedups_dataframe(suite_Δ)
#= none:35 =#
sort!(df_Δ, :threads)
#= none:36 =#
benchmarks_pretty_table(df_Δ, title = "Multithreading speedup")