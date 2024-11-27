
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
using Oceananigans.TurbulenceClosures
#= none:7 =#
using Benchmarks
#= none:11 =#
function benchmark_closure(Arch, Closure)
    #= none:11 =#
    #= none:12 =#
    grid = RectilinearGrid(Arch(), size = (128, 128, 128), extent = (1, 1, 1))
    #= none:13 =#
    model = NonhydrostaticModel(grid = grid, closure = Closure())
    #= none:15 =#
    time_step!(model, 1)
    #= none:17 =#
    trial = #= none:17 =# @benchmark(begin
                #= none:18 =#
                #= none:18 =# @sync_gpu time_step!($model, 1)
            end, samples = 10)
    #= none:21 =#
    return trial
end
#= none:26 =#
Architectures = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:28 =#
Closures = [Nothing, ScalarDiffusivity, ScalarBiharmonicDiffusivity, TwoDimensionalLeith, SmagorinskyLilly, AnisotropicMinimumDissipation]
#= none:37 =#
print_system_info()
#= none:38 =#
suite = run_benchmarks(benchmark_closure; Architectures, Closures)
#= none:40 =#
df = benchmarks_dataframe(suite)
#= none:41 =#
sort!(df, [:Architectures, :Closures], by = (string, string))
#= none:42 =#
benchmarks_pretty_table(df, title = "Turbulence closure benchmarks")
#= none:44 =#
if GPU in Architectures
    #= none:45 =#
    df_Δ = gpu_speedups_suite(suite) |> speedups_dataframe
    #= none:46 =#
    sort!(df_Δ, :Closures, by = string)
    #= none:47 =#
    benchmarks_pretty_table(df_Δ, title = "Turbulence closure CPU to GPU speedup")
end
#= none:50 =#
for Arch = Architectures
    #= none:51 =#
    suite_arch = speedups_suite(suite[#= none:51 =# @tagged(Arch)], base_case = (Arch, Nothing))
    #= none:52 =#
    df_arch = speedups_dataframe(suite_arch, slowdown = true)
    #= none:53 =#
    sort!(df_arch, :Closures, by = string)
    #= none:54 =#
    benchmarks_pretty_table(df_arch, title = "Turbulence closures relative performance ($(Arch))")
    #= none:55 =#
end