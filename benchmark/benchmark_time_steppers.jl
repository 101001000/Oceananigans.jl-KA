
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
function benchmark_time_stepper(Arch, N, TimeStepper)
    #= none:10 =#
    #= none:11 =#
    grid = RectilinearGrid(Arch(), size = (N, N, N), extent = (1, 1, 1))
    #= none:12 =#
    model = NonhydrostaticModel(grid = grid, timestepper = TimeStepper)
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
Ns = [192]
#= none:27 =#
TimeSteppers = [:QuasiAdamsBashforth2, :RungeKutta3]
#= none:31 =#
print_system_info()
#= none:32 =#
suite = run_benchmarks(benchmark_time_stepper; Architectures, Ns, TimeSteppers)
#= none:34 =#
df = benchmarks_dataframe(suite)
#= none:35 =#
sort!(df, [:Architectures, :TimeSteppers, :Ns], by = (string, string, identity))
#= none:36 =#
benchmarks_pretty_table(df, title = "Time stepping benchmarks")
#= none:38 =#
if GPU in Architectures
    #= none:39 =#
    df_Δ = gpu_speedups_suite(suite) |> speedups_dataframe
    #= none:40 =#
    sort!(df_Δ, [:TimeSteppers, :Ns], by = (string, identity))
    #= none:41 =#
    benchmarks_pretty_table(df_Δ, title = "Time stepping CPU to GPU speedup")
end
#= none:44 =#
for Arch = Architectures
    #= none:45 =#
    suite_arch = speedups_suite(suite[#= none:45 =# @tagged(Arch)], base_case = (Arch, Ns[1], :QuasiAdamsBashforth2))
    #= none:46 =#
    df_arch = speedups_dataframe(suite_arch, slowdown = true)
    #= none:47 =#
    sort!(df_arch, :TimeSteppers, by = string)
    #= none:48 =#
    benchmarks_pretty_table(df_arch, title = "Time stepping relative performance ($(Arch))")
    #= none:49 =#
end