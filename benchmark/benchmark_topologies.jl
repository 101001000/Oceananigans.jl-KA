
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
using Benchmarks
#= none:10 =#
function benchmark_topology(Arch, N, topo)
    #= none:10 =#
    #= none:11 =#
    grid = RectilinearGrid(Arch(), topology = topo, size = (N, N, N), extent = (1, 1, 1))
    #= none:12 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:14 =#
    time_step!(model, 1)
    #= none:16 =#
    trial = #= none:16 =# @benchmark(begin
                #= none:17 =#
                #= none:17 =# @sync_gpu time_step!($model, 1)
            end, samples = 10)
    #= none:20 =#
    return trial
end
#= none:25 =#
Architectures = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:26 =#
Ns = [128]
#= none:27 =#
PB = (Periodic, Bounded)
#= none:28 =#
Topologies = (collect(Iterators.product(PB, PB, PB)))[:]
#= none:32 =#
suite = run_benchmarks(benchmark_topology; Architectures, Ns, Topologies)
#= none:34 =#
df = benchmarks_dataframe(suite)
#= none:35 =#
sort!(df, [:Architectures, :Topologies, :Ns], by = (string, string, identity))
#= none:36 =#
benchmarks_pretty_table(df, title = "Topologies benchmarks")
#= none:38 =#
if GPU in Architectures
    #= none:39 =#
    df = gpu_speedups_suite(suite) |> speedups_dataframe
    #= none:40 =#
    sort!(df, [:Topologies, :Ns], by = (string, identity))
    #= none:41 =#
    benchmarks_pretty_table(df, title = "Topologies CPU to GPU speedup")
end
#= none:44 =#
for Arch = Architectures
    #= none:45 =#
    suite_arch = speedups_suite(suite[#= none:45 =# @tagged(Arch)], base_case = (Arch, Ns[1], (Periodic, Periodic, Periodic)))
    #= none:46 =#
    df_arch = speedups_dataframe(suite_arch, slowdown = true)
    #= none:47 =#
    sort!(df_arch, [:Topologies, :Ns], by = string)
    #= none:48 =#
    benchmarks_pretty_table(df_arch, title = "Topologies relative performance ($(Arch))")
    #= none:49 =#
end