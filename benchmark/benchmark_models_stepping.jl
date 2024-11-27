
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
#= none:7 =#
using Plots
#= none:8 =#
pyplot()
#= none:11 =#
function benchmark_nonhydrostatic_model(Arch, FT, N)
    #= none:11 =#
    #= none:12 =#
    grid = RectilinearGrid(Arch(), FT, size = (N, N, N), extent = (1, 1, 1))
    #= none:13 =#
    model = NonhydrostaticModel(grid = grid)
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
#= none:24 =#
function benchmark_hydrostatic_model(Arch, FT, N)
    #= none:24 =#
    #= none:25 =#
    grid = RectilinearGrid(Arch(), FT, size = (N, N, 10), extent = (1, 1, 1))
    #= none:26 =#
    model = HydrostaticFreeSurfaceModel(grid = grid, tracers = (), buoyancy = nothing, free_surface = ImplicitFreeSurface())
    #= none:31 =#
    time_step!(model, 0.001)
    #= none:33 =#
    trial = #= none:33 =# @benchmark(begin
                #= none:34 =#
                #= none:34 =# @sync_gpu time_step!($model, 0.001)
            end, samples = 10)
    #= none:37 =#
    return trial
end
#= none:40 =#
function benchmark_shallowwater_model(Arch, FT, N)
    #= none:40 =#
    #= none:41 =#
    grid = RectilinearGrid(Arch(), FT, size = (N, N), extent = (1, 1), topology = (Periodic, Periodic, Flat))
    #= none:42 =#
    model = ShallowWaterModel(grid = grid, gravitational_acceleration = 1.0)
    #= none:44 =#
    time_step!(model, 1)
    #= none:46 =#
    trial = #= none:46 =# @benchmark(begin
                #= none:47 =#
                #= none:47 =# @sync_gpu time_step!($model, 1)
            end, samples = 10)
    #= none:50 =#
    return trial
end
#= none:55 =#
Architectures = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:56 =#
Float_types = [Float64]
#= none:57 =#
Ns = [32, 64, 128, 256]
#= none:61 =#
print_system_info()
#= none:63 =#
for (model, name) = zip((:nonhydrostatic, :hydrostatic, :shallowwater), ("NonhydrostaticModel", "HydrostaticFreeSurfaceModel", "ShallowWaterModel"))
    #= none:65 =#
    benchmark_func = Symbol(:benchmark_, model, :_model)
    #= none:66 =#
    #= none:66 =# @eval begin
            #= none:67 =#
            suite = run_benchmarks($benchmark_func; Architectures, Float_types, Ns)
        end
    #= none:70 =#
    df = benchmarks_dataframe(suite)
    #= none:71 =#
    benchmarks_pretty_table(df, title = name * " benchmarks")
    #= none:72 =#
end