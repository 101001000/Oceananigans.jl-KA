
#= none:1 =#
module MultiRegion
#= none:1 =#
#= none:3 =#
export MultiRegionGrid, MultiRegionField
#= none:4 =#
export XPartition, YPartition, Connectivity
#= none:5 =#
export AbstractRegionSide, East, West, North, South
#= none:6 =#
export CubedSpherePartition, ConformalCubedSphereGrid, CubedSphereField
#= none:8 =#
using Oceananigans
#= none:9 =#
using Oceananigans.Grids
#= none:10 =#
using Oceananigans.Fields
#= none:11 =#
using Oceananigans.Models
#= none:12 =#
using Oceananigans.Architectures
#= none:13 =#
using Oceananigans.BoundaryConditions
#= none:14 =#
using Oceananigans.Utils
#= none:16 =#
using Adapt
#= none:17 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:18 =#
using DocStringExtensions
#= none:19 =#
using OffsetArrays
#= none:21 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid
#= none:22 =#
using Oceananigans.Utils: Reference, Iterate, getnamewrapper
#= none:23 =#
using Oceananigans.Grids: AbstractUnderlyingGrid
#= none:25 =#
using KernelAbstractions: @kernel, @index
#= none:27 =#
import Base: show, length, size
#= none:29 =#
import Oceananigans.Utils: getdevice, switch_device!, devices, isregional, getregion, _getregion, sync_all_devices!
#= none:38 =#
abstract type AbstractMultiRegionGrid{FT, TX, TY, TZ, Arch} <: AbstractUnderlyingGrid{FT, TX, TY, TZ, Arch} end
#= none:40 =#
abstract type AbstractPartition end
#= none:42 =#
abstract type AbstractConnectivity end
#= none:44 =#
abstract type AbstractRegionSide end
#= none:46 =#
struct West <: AbstractRegionSide
    #= none:46 =#
end
#= none:47 =#
struct East <: AbstractRegionSide
    #= none:47 =#
end
#= none:48 =#
struct North <: AbstractRegionSide
    #= none:48 =#
end
#= none:49 =#
struct South <: AbstractRegionSide
    #= none:49 =#
end
#= none:51 =#
struct XPartition{N} <: AbstractPartition
    #= none:52 =#
    div::N
    #= none:54 =#
    function XPartition(sizes)
        #= none:54 =#
        #= none:55 =#
        if length(sizes) > 1 && all((y->begin
                            #= none:55 =#
                            y == sizes[1]
                        end), sizes)
            #= none:56 =#
            sizes = length(sizes)
        end
        #= none:59 =#
        return new{typeof(sizes)}(sizes)
    end
end
#= none:63 =#
struct YPartition{N} <: AbstractPartition
    #= none:64 =#
    div::N
    #= none:66 =#
    function YPartition(sizes)
        #= none:66 =#
        #= none:67 =#
        if length(sizes) > 1 && all((y->begin
                            #= none:67 =#
                            y == sizes[1]
                        end), sizes)
            #= none:68 =#
            sizes = length(sizes)
        end
        #= none:71 =#
        return new{typeof(sizes)}(sizes)
    end
end
#= none:75 =#
include("multi_region_utils.jl")
#= none:76 =#
include("multi_region_connectivity.jl")
#= none:77 =#
include("x_partitions.jl")
#= none:78 =#
include("y_partitions.jl")
#= none:79 =#
include("cubed_sphere_partitions.jl")
#= none:80 =#
include("cubed_sphere_connectivity.jl")
#= none:81 =#
include("multi_region_grid.jl")
#= none:82 =#
include("cubed_sphere_grid.jl")
#= none:83 =#
include("cubed_sphere_field.jl")
#= none:84 =#
include("cubed_sphere_boundary_conditions.jl")
#= none:85 =#
include("multi_region_field.jl")
#= none:86 =#
include("multi_region_abstract_operations.jl")
#= none:87 =#
include("multi_region_boundary_conditions.jl")
#= none:88 =#
include("multi_region_reductions.jl")
#= none:89 =#
include("unified_implicit_free_surface_solver.jl")
#= none:90 =#
include("multi_region_split_explicit_free_surface.jl")
#= none:91 =#
include("multi_region_models.jl")
#= none:92 =#
include("multi_region_output_writers.jl")
end