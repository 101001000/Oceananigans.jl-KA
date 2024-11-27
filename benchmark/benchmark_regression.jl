
#= none:1 =#
push!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using PkgBenchmark
#= none:4 =#
using Oceananigans
#= none:5 =#
using Benchmarks
#= none:7 =#
baseline = BenchmarkConfig(id = "main")
#= none:8 =#
script = joinpath(#= none:8 =# @__DIR__(), "benchmarkable_nonhydrostatic_model.jl")
#= none:9 =#
resultfile = joinpath(#= none:9 =# @__DIR__(), "regression_benchmarks.json")
#= none:11 =#
print_system_info()
#= none:13 =#
judgement = judge(Oceananigans, baseline, script = script, resultfile = resultfile, verbose = true)
#= none:14 =#
results = PkgBenchmark.benchmarkgroup(judgement)
#= none:16 =#
for (case, trial) = results
    #= none:17 =#
    println("Results for $(case)")
    #= none:18 =#
    display(trial)
    #= none:19 =#
end