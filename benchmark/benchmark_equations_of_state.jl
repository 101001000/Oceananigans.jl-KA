
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
using Oceananigans.BuoyancyModels
#= none:7 =#
using SeawaterPolynomials
#= none:8 =#
using Benchmarks
#= none:12 =#
function benchmark_equation_of_state(Arch, EOS)
    #= none:12 =#
    #= none:13 =#
    grid = RectilinearGrid(Arch(), size = (192, 192, 192), extent = (1, 1, 1))
    #= none:14 =#
    buoyancy = SeawaterBuoyancy(equation_of_state = EOS())
    #= none:15 =#
    model = NonhydrostaticModel(grid = grid, buoyancy = buoyancy)
    #= none:17 =#
    time_step!(model, 1)
    #= none:19 =#
    trial = #= none:19 =# @benchmark(begin
                #= none:20 =#
                #= none:20 =# @sync_gpu time_step!($model, 1)
            end, samples = 10)
    #= none:23 =#
    return trial
end
#= none:28 =#
Architectures = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:29 =#
EquationsOfState = [LinearEquationOfState, SeawaterPolynomials.RoquetEquationOfState, SeawaterPolynomials.TEOS10EquationOfState]
#= none:33 =#
print_system_info()
#= none:34 =#
suite = run_benchmarks(benchmark_equation_of_state; Architectures, EquationsOfState)
#= none:36 =#
df = benchmarks_dataframe(suite)
#= none:37 =#
sort!(df, [:Architectures, :EquationsOfState], by = string)
#= none:38 =#
benchmarks_pretty_table(df, title = "Equation of state benchmarks")
#= none:40 =#
if GPU in Architectures
    #= none:41 =#
    df_Δ = gpu_speedups_suite(suite) |> speedups_dataframe
    #= none:42 =#
    sort!(df_Δ, :EquationsOfState, by = string)
    #= none:43 =#
    benchmarks_pretty_table(df_Δ, title = "Equation of state CPU to GPU speedup")
end
#= none:46 =#
for Arch = Architectures
    #= none:47 =#
    suite_arch = speedups_suite(suite[#= none:47 =# @tagged(Arch)], base_case = (Arch, LinearEquationOfState))
    #= none:48 =#
    df_arch = speedups_dataframe(suite_arch, slowdown = true)
    #= none:49 =#
    sort!(df_arch, :EquationsOfState, by = string)
    #= none:50 =#
    benchmarks_pretty_table(df_arch, title = "Equation of state relative performance ($(Arch))")
    #= none:51 =#
end