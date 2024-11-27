
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
using Oceananigans.Advection
#= none:7 =#
using Benchmarks
#= none:11 =#
function benchmark_advection_scheme(Arch, Scheme, order)
    #= none:11 =#
    #= none:12 =#
    grid = RectilinearGrid(Arch(); size = (192, 192, 192), extent = (1, 1, 1))
    #= none:13 =#
    order = if Scheme == Centered
            order + 1
        else
            order
        end
    #= none:14 =#
    model = NonhydrostaticModel(grid = grid, advection = Scheme(; order))
    #= none:16 =#
    time_step!(model, 1)
    #= none:18 =#
    trial = #= none:18 =# @benchmark(begin
                #= none:19 =#
                #= none:19 =# @sync_gpu time_step!($model, 1)
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
Schemes = (Centered, UpwindBiased, WENO)
#= none:29 =#
orders = (1, 3, 5, 7, 9)
#= none:33 =#
print_system_info()
#= none:34 =#
suite = run_benchmarks(benchmark_advection_scheme; Architectures, Schemes, orders)
#= none:36 =#
df = benchmarks_dataframe(suite)
#= none:37 =#
sort!(df, [:Architectures, :Schemes], by = string)
#= none:38 =#
benchmarks_pretty_table(df, title = "Advection scheme benchmarks")
#= none:40 =#
if GPU in Architectures
    #= none:41 =#
    df_Δ = gpu_speedups_suite(suite) |> speedups_dataframe
    #= none:42 =#
    sort!(df_Δ, :Schemes, by = string)
    #= none:43 =#
    benchmarks_pretty_table(df_Δ, title = "Advection schemes CPU to GPU speedup")
end
#= none:46 =#
for Arch = Architectures
    #= none:47 =#
    suite_arch = speedups_suite(suite[#= none:47 =# @tagged(Arch)], base_case = (Arch, CenteredSecondOrder))
    #= none:48 =#
    df_arch = speedups_dataframe(suite_arch, slowdown = true)
    #= none:49 =#
    sort!(df_arch, :Schemes, by = string)
    #= none:50 =#
    benchmarks_pretty_table(df_arch, title = "Advection schemes relative performance ($(Arch))")
    #= none:51 =#
end