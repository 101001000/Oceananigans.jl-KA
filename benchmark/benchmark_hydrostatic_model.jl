
#= none:1 =#
push!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using Benchmarks
#= none:5 =#
using Oceananigans.TimeSteppers: update_state!
#= none:6 =#
using Oceananigans.Diagnostics: accurate_cell_advection_timescale
#= none:8 =#
using BenchmarkTools
#= none:9 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:10 =#
using Oceananigans
#= none:11 =#
using Statistics
#= none:14 =#
Nx = 256
#= none:15 =#
Ny = 128
#= none:17 =#
function set_divergent_velocity!(model)
    #= none:17 =#
    #= none:19 =#
    grid = model.grid
    #= none:21 =#
    (u, v, w) = model.velocities
    #= none:22 =#
    η = model.free_surface.η
    #= none:24 =#
    u .= 0
    #= none:25 =#
    v .= 0
    #= none:26 =#
    η .= 0
    #= none:28 =#
    imid = Int(floor(grid.Nx / 2)) + 1
    #= none:29 =#
    jmid = Int(floor(grid.Ny / 2)) + 1
    #= none:30 =#
    #= none:30 =# CUDA.@allowscalar u[imid, jmid, 1] = 1
    #= none:32 =#
    update_state!(model)
    #= none:34 =#
    return nothing
end
#= none:37 =#
grids = Dict((CPU, :RectilinearGrid) => RectilinearGrid(CPU(), size = (Nx, Ny, 1), extent = (1, 1, 1)), (CPU, :LatitudeLongitudeGrid) => LatitudeLongitudeGrid(CPU(), size = (Nx, Ny, 1), longitude = (-180, 180), latitude = (-80, 80), z = (-1, 0), precompute_metrics = true), (GPU, :RectilinearGrid) => RectilinearGrid(GPU(), size = (Nx, Ny, 1), extent = (1, 1, 1)), (GPU, :LatitudeLongitudeGrid) => LatitudeLongitudeGrid(GPU(), size = (Nx, Ny, 1), longitude = (-160, 160), latitude = (-80, 80), z = (-1, 0), precompute_metrics = true))
#= none:61 =#
free_surfaces = Dict(:ExplicitFreeSurface => ExplicitFreeSurface(), :PCGImplicitFreeSurface => ImplicitFreeSurface(solver_method = :PreconditionedConjugateGradient), :MatrixImplicitFreeSurfaceOrd2 => ImplicitFreeSurface(solver_method = :HeptadiagonalIterativeSolver), :MatrixImplicitFreeSurfaceSparsePreconditioner => ImplicitFreeSurface(solver_method = :HeptadiagonalIterativeSolver, preconditioner_method = :SparseInverse))
#= none:72 =#
function benchmark_hydrostatic_model(Arch, grid_type, free_surface_type)
    #= none:72 =#
    #= none:74 =#
    grid = grids[(Arch, grid_type)]
    #= none:76 =#
    model = HydrostaticFreeSurfaceModel(; grid, momentum_advection = VectorInvariant(), free_surface = free_surfaces[free_surface_type])
    #= none:80 =#
    set_divergent_velocity!(model)
    #= none:81 =#
    Δt = accurate_cell_advection_timescale(grid, model.velocities) / 2
    #= none:82 =#
    time_step!(model, Δt)
    #= none:84 =#
    trial = #= none:84 =# @benchmark(begin
                #= none:85 =#
                #= none:85 =# CUDA.@sync blocking = true time_step!($model, $Δt)
            end, samples = 10)
    #= none:88 =#
    return trial
end
#= none:94 =#
architectures = [CPU]
#= none:96 =#
grid_types = [:RectilinearGrid, :LatitudeLongitudeGrid]
#= none:104 =#
free_surface_types = collect(keys(free_surfaces))
#= none:107 =#
print_system_info()
#= none:108 =#
suite = run_benchmarks(benchmark_hydrostatic_model; architectures, grid_types, free_surface_types)
#= none:110 =#
df = benchmarks_dataframe(suite)
#= none:111 =#
benchmarks_pretty_table(df, title = "Hydrostatic model benchmarks")