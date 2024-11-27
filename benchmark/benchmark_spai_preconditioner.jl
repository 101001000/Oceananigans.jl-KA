
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
using DataDeps
#= none:6 =#
using Oceananigans
#= none:7 =#
using Benchmarks
#= none:8 =#
using Statistics
#= none:9 =#
using Oceananigans.Solvers: sparse_approximate_inverse
#= none:11 =#
function benchmark_spai_preconditioner(N, ε, nzrel, inverse)
    #= none:11 =#
    #= none:13 =#
    grid = RectilinearGrid(CPU(), size = (N, N, 1), extent = (1, 1, 1))
    #= none:15 =#
    model = HydrostaticFreeSurfaceModel(grid = grid, momentum_advection = VectorInvariant(), free_surface = ImplicitFreeSurface(solver_method = :HeptadiagonalIterativeSolver, preconditioner_method = nothing))
    #= none:22 =#
    time_step!(model, 1)
    #= none:24 =#
    matrix = model.free_surface.implicit_step_solver.matrix_iterative_solver.matrix
    #= none:26 =#
    if !inverse
        #= none:27 =#
        trial = #= none:27 =# @benchmark(begin
                    #= none:28 =#
                    #= none:28 =# CUDA.@sync blocking = true sparse_approximate_inverse($matrix, ε = $ε, nzrel = $nzrel)
                end, samples = 5)
    else
        #= none:31 =#
        trial = #= none:31 =# @benchmark(begin
                    #= none:32 =#
                    #= none:32 =# CUDA.@sync blocking = true inv(Array($matrix))
                end, samples = 5)
    end
    #= none:36 =#
    return trial
end
#= none:39 =#
N = [64, 128, 256]
#= none:40 =#
ε = [0.1, 0.3]
#= none:41 =#
nzrel = [0.5, 1.0, 2.0]
#= none:42 =#
inverse = (false,)
#= none:45 =#
print_system_info()
#= none:46 =#
suite = run_benchmarks(benchmark_spai_preconditioner; N, ε, nzrel, inverse)
#= none:48 =#
df = benchmarks_dataframe(suite)
#= none:49 =#
benchmarks_pretty_table(df, title = "SPAI preconditioner benchmarks")