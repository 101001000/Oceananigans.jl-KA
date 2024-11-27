
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
function benchmark_vertically_stretched_nonhydrostatic_model(Arch, FT, N)
    #= none:10 =#
    #= none:11 =#
    grid = RectilinearGrid(Arch(), FT, size = (N, N, N), x = (0, 1), y = (0, 1), z = collect(0:N))
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
Float_types = [Float32, Float64]
#= none:27 =#
Ns = [32, 64, 128, 256]
#= none:31 =#
print_system_info()
#= none:32 =#
suite = run_benchmarks(benchmark_vertically_stretched_nonhydrostatic_model; Architectures, Float_types, Ns)
#= none:34 =#
df = benchmarks_dataframe(suite)
#= none:35 =#
sort!(df, [:Architectures, :Float_types, :Ns], by = (string, string, identity))
#= none:36 =#
benchmarks_pretty_table(df, title = "Vertically-stretched nonhydrostatic model benchmarks")
#= none:38 =#
if GPU in Architectures
    #= none:39 =#
    df_Δ = gpu_speedups_suite(suite) |> speedups_dataframe
    #= none:40 =#
    sort!(df_Δ, [:Float_types, :Ns], by = (string, identity))
    #= none:41 =#
    benchmarks_pretty_table(df_Δ, title = "Vertically-stretched nonhydrostatic model CPU to GPU speedup")
end