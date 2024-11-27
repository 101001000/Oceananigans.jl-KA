
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
#= none:8 =#
using Oceananigans.Solvers
#= none:12 =#
function benchmark_fft_based_poisson_solver(Arch, N, topo)
    #= none:12 =#
    #= none:13 =#
    grid = RectilinearGrid(topology = topo, size = (N, N, N), extent = (1, 1, 1))
    #= none:14 =#
    solver = FFTBasedPoissonSolver(Arch(), grid)
    #= none:16 =#
    solve_poisson_equation!(solver)
    #= none:18 =#
    trial = #= none:18 =# @benchmark(begin
                #= none:19 =#
                #= none:19 =# @sync_gpu solve_poisson_equation!($solver)
            end, samples = 10)
    #= none:22 =#
    return trial
end
#= none:27 =#
Architectures = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:28 =#
Ns = [256]
#= none:29 =#
PB = (Periodic, Bounded)
#= none:30 =#
Topologies = (collect(Iterators.product(PB, PB, PB)))[:]
#= none:34 =#
suite = run_benchmarks(benchmark_fft_based_poisson_solver; Architectures, Ns, Topologies)
#= none:36 =#
df = benchmarks_dataframe(suite)
#= none:37 =#
sort!(df, [:Architectures, :Topologies, :Ns], by = (string, string, identity))
#= none:38 =#
benchmarks_pretty_table(df, title = "FFT-based Poisson solver benchmarks")
#= none:40 =#
if GPU in Architectures
    #= none:41 =#
    df = gpu_speedups_suite(suite) |> speedups_dataframe
    #= none:42 =#
    sort!(df, [:Topologies, :Ns], by = (string, identity))
    #= none:43 =#
    benchmarks_pretty_table(df, title = "FFT-based Poisson solver CPU to GPU speedup")
end
#= none:46 =#
for Arch = Architectures
    #= none:47 =#
    suite_arch = speedups_suite(suite[#= none:47 =# @tagged(Arch)], base_case = (Arch, Ns[1], (Periodic, Periodic, Periodic)))
    #= none:48 =#
    df_arch = speedups_dataframe(suite_arch, slowdown = true)
    #= none:49 =#
    sort!(df_arch, [:Topologies, :Ns], by = string)
    #= none:50 =#
    benchmarks_pretty_table(df_arch, title = "FFT-based Poisson solver relative performance ($(Arch))")
    #= none:51 =#
end