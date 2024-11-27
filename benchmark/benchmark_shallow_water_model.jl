
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
using Oceananigans.Models: ShallowWaterModel
#= none:7 =#
using Benchmarks
#= none:8 =#
using Plots
#= none:9 =#
pyplot()
#= none:13 =#
function benchmark_shallow_water_model(Arch, FT, N)
    #= none:13 =#
    #= none:14 =#
    grid = RectilinearGrid(Arch(), FT, size = (N, N), extent = (1, 1), topology = (Periodic, Periodic, Flat), halo = (3, 3))
    #= none:15 =#
    model = ShallowWaterModel(grid = grid, gravitational_acceleration = 1.0)
    #= none:16 =#
    set!(model, h = 1)
    #= none:18 =#
    time_step!(model, 1)
    #= none:20 =#
    trial = #= none:20 =# @benchmark(begin
                #= none:21 =#
                #= none:21 =# CUDA.@sync blocking = true time_step!($model, 1)
            end, samples = 10)
    #= none:24 =#
    return trial
end
#= none:30 =#
Architectures = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:31 =#
Float_types = [Float64]
#= none:32 =#
Ns = [32, 64, 128, 256, 512, 1024, 2048, 4096]
#= none:35 =#
print_system_info()
#= none:36 =#
suite = run_benchmarks(benchmark_shallow_water_model; Architectures, Float_types, Ns)
#= none:38 =#
plot_num = length(Ns)
#= none:39 =#
cpu_times = zeros(Float64, plot_num)
#= none:40 =#
gpu_times = zeros(Float64, plot_num)
#= none:41 =#
plot_keys = collect(keys(suite))
#= none:42 =#
sort!(plot_keys, by = (v->begin
                #= none:42 =#
                [Symbol(v[1]), v[3]]
            end))
#= none:44 =#
for i = 1:plot_num
    #= none:45 =#
    cpu_times[i] = mean((suite[plot_keys[i]]).times) / 1.0e6
    #= none:46 =#
    gpu_times[i] = mean((suite[plot_keys[i + plot_num]]).times) / 1.0e6
    #= none:47 =#
end
#= none:49 =#
plt = plot(Ns, cpu_times, lw = 4, label = "cpu", xaxis = :log2, yaxis = :log, legend = :topleft, xlabel = "Nx", ylabel = "Times (ms)", title = "Shallow Water Benchmarks: CPU vs GPU")
#= none:51 =#
plot!(plt, Ns, gpu_times, lw = 4, label = "gpu")
#= none:52 =#
display(plt)
#= none:53 =#
savefig(plt, "shallow_water_times.png")
#= none:56 =#
plt2 = plot(Ns, cpu_times ./ gpu_times, lw = 4, xaxis = :log2, legend = :none, xlabel = "Nx", ylabel = "Speedup Ratio", title = "Shallow Water Benchmarks: CPU/GPU")
#= none:58 =#
display(plt2)
#= none:59 =#
savefig(plt2, "shallow_water_speedup.png")
#= none:61 =#
df = benchmarks_dataframe(suite)
#= none:62 =#
sort!(df, [:Architectures, :Float_types, :Ns], by = (string, string, identity))
#= none:63 =#
benchmarks_pretty_table(df, title = "Shallow water model benchmarks")
#= none:65 =#
if GPU in Architectures
    #= none:66 =#
    df_Δ = gpu_speedups_suite(suite) |> speedups_dataframe
    #= none:67 =#
    sort!(df_Δ, [:Float_types, :Ns], by = (string, identity))
    #= none:68 =#
    benchmarks_pretty_table(df_Δ, title = "Shallow water model CPU to GPU speedup")
end