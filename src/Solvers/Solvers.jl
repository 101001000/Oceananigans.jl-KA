
#= none:1 =#
module Solvers
#= none:1 =#
#= none:3 =#
export BatchedTridiagonalSolver, solve!, FFTBasedPoissonSolver, FourierTridiagonalPoissonSolver, ConjugateGradientSolver, HeptadiagonalIterativeSolver
#= none:10 =#
using Statistics
#= none:11 =#
using FFTW
#= none:12 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:13 =#
using SparseArrays
#= none:14 =#
using KernelAbstractions
#= none:16 =#
using Oceananigans.Architectures: device, CPU, GPU, array_type, on_architecture
#= none:17 =#
using Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:18 =#
using Oceananigans.Utils
#= none:19 =#
using Oceananigans.Grids
#= none:20 =#
using Oceananigans.BoundaryConditions
#= none:21 =#
using Oceananigans.Fields
#= none:23 =#
using Oceananigans.Grids: unpack_grid, inactive_cell
#= none:24 =#
using Oceananigans.Grids: XYRegularRG, XZRegularRG, YZRegularRG, XYZRegularRG
#= none:26 =#
#= none:26 =# Core.@doc "    ω(M, k)\n\nReturn the `M`th root of unity raised to the `k`th power.\n" #= none:31 =# @inline(ω(M, k) = begin
                #= none:31 =#
                exp(((-2im) * π * k) / M)
            end)
#= none:33 =#
reshaped_size(N, dim) = begin
        #= none:33 =#
        if dim == 1
            (N, 1, 1)
        else
            if dim == 2
                (1, N, 1)
            else
                if dim == 3
                    (1, 1, N)
                else
                    nothing
                end
            end
        end
    end
#= none:37 =#
include("batched_tridiagonal_solver.jl")
#= none:38 =#
include("conjugate_gradient_solver.jl")
#= none:39 =#
include("poisson_eigenvalues.jl")
#= none:40 =#
include("index_permutations.jl")
#= none:41 =#
include("discrete_transforms.jl")
#= none:42 =#
include("plan_transforms.jl")
#= none:43 =#
include("fft_based_poisson_solver.jl")
#= none:44 =#
include("fourier_tridiagonal_poisson_solver.jl")
#= none:45 =#
include("conjugate_gradient_poisson_solver.jl")
#= none:46 =#
include("sparse_approximate_inverse.jl")
#= none:47 =#
include("matrix_solver_utils.jl")
#= none:48 =#
include("sparse_preconditioners.jl")
#= none:49 =#
include("heptadiagonal_iterative_solver.jl")
#= none:51 =#
const GridWithFFTSolver = Union{XYZRegularRG, XYRegularRG, XZRegularRG, YZRegularRG}
#= none:52 =#
const GridWithFourierTridiagonalSolver = Union{XYRegularRG, XZRegularRG, YZRegularRG}
#= none:54 =#
fft_poisson_solver(grid::XYZRegularRG) = begin
        #= none:54 =#
        FFTBasedPoissonSolver(grid)
    end
#= none:55 =#
fft_poisson_solver(grid::GridWithFourierTridiagonalSolver) = begin
        #= none:55 =#
        FourierTridiagonalPoissonSolver(grid.underlying_grid)
    end
end