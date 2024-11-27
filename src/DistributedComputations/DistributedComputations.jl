
#= none:1 =#
module DistributedComputations
#= none:1 =#
#= none:3 =#
export Distributed, Partition, Equal, Fractional, child_architecture, reconstruct_global_grid, partition, inject_halo_communication_boundary_conditions, DistributedFFTBasedPoissonSolver
#= none:9 =#
using MPI
#= none:11 =#
using Oceananigans.Utils
#= none:12 =#
using Oceananigans.Grids
#= none:14 =#
include("distributed_architectures.jl")
#= none:15 =#
include("partition_assemble.jl")
#= none:16 =#
include("distributed_grids.jl")
#= none:17 =#
include("distributed_immersed_boundaries.jl")
#= none:18 =#
include("distributed_on_architecture.jl")
#= none:19 =#
include("distributed_kernel_launching.jl")
#= none:20 =#
include("halo_communication_bcs.jl")
#= none:21 =#
include("distributed_fields.jl")
#= none:22 =#
include("halo_communication.jl")
#= none:23 =#
include("transposable_field.jl")
#= none:24 =#
include("distributed_transpose.jl")
#= none:25 =#
include("plan_distributed_transforms.jl")
#= none:26 =#
include("distributed_fft_based_poisson_solver.jl")
#= none:27 =#
include("distributed_fft_tridiagonal_solver.jl")
end