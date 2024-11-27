
#= none:1 =#
module BoundaryConditions
#= none:1 =#
#= none:3 =#
export BCType, Flux, Gradient, Value, Open, BoundaryCondition, getbc, setbc!, PeriodicBoundaryCondition, OpenBoundaryCondition, NoFluxBoundaryCondition, MultiRegionCommunicationBoundaryCondition, FluxBoundaryCondition, ValueBoundaryCondition, GradientBoundaryCondition, DistributedCommunicationBoundaryCondition, validate_boundary_condition_topology, validate_boundary_condition_architecture, FieldBoundaryConditions, apply_x_bcs!, apply_y_bcs!, apply_z_bcs!, fill_halo_regions!
#= none:13 =#
using CUDA, Adapt, Juliana, GPUArrays
import KernelAbstractions
#= none:14 =#
using KernelAbstractions: @index, @kernel
#= none:16 =#
using Oceananigans.Architectures: CPU, GPU, device
#= none:17 =#
using Oceananigans.Utils: work_layout, launch!
#= none:18 =#
using Oceananigans.Operators: Ax, Ay, Az, volume
#= none:19 =#
using Oceananigans.Grids
#= none:21 =#
import Adapt: adapt_structure
#= none:23 =#
include("boundary_condition_classifications.jl")
#= none:24 =#
include("boundary_condition.jl")
#= none:25 =#
include("discrete_boundary_function.jl")
#= none:26 =#
include("continuous_boundary_function.jl")
#= none:27 =#
include("field_boundary_conditions.jl")
#= none:28 =#
include("show_boundary_conditions.jl")
#= none:30 =#
include("fill_halo_regions.jl")
#= none:31 =#
include("fill_halo_regions_value_gradient.jl")
#= none:32 =#
include("fill_halo_regions_open.jl")
#= none:33 =#
include("fill_halo_regions_periodic.jl")
#= none:34 =#
include("fill_halo_regions_flux.jl")
#= none:35 =#
include("fill_halo_regions_nothing.jl")
#= none:37 =#
include("apply_flux_bcs.jl")
#= none:39 =#
include("update_boundary_conditions.jl")
#= none:41 =#
include("flat_extrapolation_open_boundary_matching_scheme.jl")
end