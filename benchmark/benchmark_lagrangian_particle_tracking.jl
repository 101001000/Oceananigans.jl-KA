
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
function benchmark_particle_tracking(Arch, N_particles)
    #= none:10 =#
    #= none:11 =#
    grid = RectilinearGrid(Arch(), size = (128, 128, 128), extent = (1, 1, 1))
    #= none:13 =#
    if N_particles == 0
        #= none:14 =#
        particles = nothing
    else
        #= none:16 =#
        ArrayType = if Arch == CPU
                Array
            else
                GPUArrays.AbstractGPUArray
            end
        #= none:17 =#
        x₀ = zeros(N_particles) |> ArrayType
        #= none:18 =#
        y₀ = zeros(N_particles) |> ArrayType
        #= none:19 =#
        z₀ = zeros(N_particles) |> ArrayType
        #= none:20 =#
        particles = LagrangianParticles(x = x₀, y = y₀, z = z₀)
    end
    #= none:23 =#
    model = NonhydrostaticModel(grid = grid, particles = particles)
    #= none:25 =#
    time_step!(model, 1)
    #= none:27 =#
    trial = #= none:27 =# @benchmark(begin
                #= none:28 =#
                #= none:28 =# @sync_gpu time_step!($model, 1)
            end, samples = 10)
    #= none:31 =#
    return trial
end
#= none:36 =#
Architectures = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:37 =#
N_particles = [0, 1, 10, 10 ^ 2, 10 ^ 3, 10 ^ 4, 10 ^ 5, 10 ^ 6, 10 ^ 7, 10 ^ 8]
#= none:41 =#
print_system_info()
#= none:42 =#
suite = run_benchmarks(benchmark_particle_tracking; Architectures, N_particles)
#= none:44 =#
df = benchmarks_dataframe(suite)
#= none:45 =#
sort!(df, [:Architectures, :N_particles], by = (string, identity))
#= none:46 =#
benchmarks_pretty_table(df, title = "Lagrangian particle tracking benchmarks")
#= none:48 =#
if GPU in Architectures
    #= none:49 =#
    df_Δ = gpu_speedups_suite(suite) |> speedups_dataframe
    #= none:50 =#
    sort!(df_Δ, :N_particles)
    #= none:51 =#
    benchmarks_pretty_table(df_Δ, title = "Lagrangian particle tracking CPU to GPU speedup")
end
#= none:54 =#
for Arch = Architectures
    #= none:55 =#
    suite_arch = speedups_suite(suite[#= none:55 =# @tagged(Arch)], base_case = (Arch, N_particles[1]))
    #= none:56 =#
    df_arch = speedups_dataframe(suite_arch, slowdown = true)
    #= none:57 =#
    sort!(df_arch, :N_particles)
    #= none:58 =#
    benchmarks_pretty_table(df_arch, title = "Lagrangian particle tracking relative performance ($(Arch))")
    #= none:59 =#
end