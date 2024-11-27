
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
function active_tracers(n)
    #= none:10 =#
    #= none:11 =#
    n == 0 && return []
    #= none:12 =#
    n == 1 && return [:b]
    #= none:13 =#
    n == 2 && return [:T, :S]
    #= none:14 =#
    throw(ArgumentError("Can't have more than 2 active tracers!"))
end
#= none:17 =#
passive_tracers(n) = begin
        #= none:17 =#
        [Symbol("C" * string(m)) for m = 1:n]
    end
#= none:19 =#
tracer_list(n_active, n_passive) = begin
        #= none:19 =#
        Tuple(vcat(active_tracers(n_active), passive_tracers(n_passive)))
    end
#= none:22 =#
function buoyancy(n_active)
    #= none:22 =#
    #= none:23 =#
    n_active == 0 && return nothing
    #= none:24 =#
    n_active == 1 && return BuoyancyTracer()
    #= none:25 =#
    n_active == 2 && return SeawaterBuoyancy()
    #= none:26 =#
    throw(ArgumentError("Can't have more than 2 active tracers!"))
end
#= none:31 =#
function benchmark_tracers(Arch, N, n_tracers)
    #= none:31 =#
    #= none:32 =#
    (n_active, n_passive) = n_tracers
    #= none:33 =#
    grid = RectilinearGrid(Arch(), size = (N, N, N), extent = (1, 1, 1))
    #= none:34 =#
    model = NonhydrostaticModel(grid = grid, buoyancy = buoyancy(n_active), tracers = tracer_list(n_active, n_passive))
    #= none:37 =#
    time_step!(model, 1)
    #= none:39 =#
    trial = #= none:39 =# @benchmark(begin
                #= none:40 =#
                #= none:40 =# @sync_gpu time_step!($model, 1)
            end, samples = 10)
    #= none:43 =#
    return trial
end
#= none:48 =#
Architectures = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:49 =#
Ns = [128]
#= none:52 =#
tracers = [(0, 0), (0, 1), (0, 2), (1, 0), (2, 0), (2, 3), (2, 5), (2, 10)]
#= none:56 =#
print_system_info()
#= none:57 =#
suite = run_benchmarks(benchmark_tracers; Architectures, Ns, tracers)
#= none:59 =#
df = benchmarks_dataframe(suite)
#= none:60 =#
sort!(df, [:Architectures, :tracers, :Ns], by = (string, string, identity))
#= none:61 =#
benchmarks_pretty_table(df, title = "Arbitrary tracers benchmarks")
#= none:63 =#
if GPU in Architectures
    #= none:64 =#
    df_Δ = gpu_speedups_suite(suite) |> speedups_dataframe
    #= none:65 =#
    sort!(df_Δ, [:tracers, :Ns])
    #= none:66 =#
    benchmarks_pretty_table(df_Δ, title = "Arbitrary tracers CPU to GPU speedup")
end
#= none:69 =#
for Arch = Architectures
    #= none:70 =#
    suite_arch = speedups_suite(suite[#= none:70 =# @tagged(Arch)], base_case = (Arch, Ns[1], (0, 0)))
    #= none:71 =#
    df_arch = speedups_dataframe(suite_arch, slowdown = true)
    #= none:72 =#
    sort!(df_arch, [:tracers, :Ns], by = (string, identity))
    #= none:73 =#
    benchmarks_pretty_table(df_arch, title = "Arbitrary tracers relative performance ($(Arch))")
    #= none:74 =#
end