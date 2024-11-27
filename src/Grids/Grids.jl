
#= none:1 =#
module Grids
#= none:1 =#
#= none:3 =#
export Center, Face
#= none:4 =#
export AbstractTopology, Periodic, Bounded, Flat, FullyConnected, LeftConnected, RightConnected, topology
#= none:6 =#
export AbstractGrid, AbstractUnderlyingGrid, halo_size, total_size
#= none:7 =#
export RectilinearGrid
#= none:8 =#
export AbstractCurvilinearGrid, AbstractHorizontallyCurvilinearGrid
#= none:9 =#
export XFlatGrid, YFlatGrid, ZFlatGrid
#= none:10 =#
export XRegularRG, YRegularRG, ZRegularRG, XYRegularRG, XYZRegularRG
#= none:11 =#
export LatitudeLongitudeGrid, XRegularLLG, YRegularLLG, ZRegularLLG
#= none:12 =#
export OrthogonalSphericalShellGrid, ConformalCubedSphereGrid, ZRegOrthogonalSphericalShellGrid
#= none:13 =#
export conformal_cubed_sphere_panel
#= none:14 =#
export node, nodes
#= none:15 =#
export ξnode, ηnode, rnode
#= none:16 =#
export xnode, ynode, znode, λnode, φnode
#= none:17 =#
export xnodes, ynodes, znodes, λnodes, φnodes
#= none:18 =#
export spacings
#= none:19 =#
export xspacings, yspacings, zspacings, xspacing, yspacing, zspacing
#= none:20 =#
export minimum_xspacing, minimum_yspacing, minimum_zspacing
#= none:21 =#
export offset_data, new_data
#= none:22 =#
export on_architecture
#= none:24 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:25 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:26 =#
using Adapt
#= none:27 =#
using OffsetArrays
#= none:29 =#
using Oceananigans
#= none:30 =#
using Oceananigans.Architectures
#= none:32 =#
import Base: size, length, eltype, show, -
#= none:33 =#
import Oceananigans.Architectures: architecture, on_architecture
#= none:36 =#
const R_Earth = 6.371e6
#= none:42 =#
#= none:42 =# Core.@doc "    Center\n\nA type describing the location at the center of a grid cell.\n" struct Center
        #= none:47 =#
    end
#= none:49 =#
#= none:49 =# Core.@doc "    Face\n\nA type describing the location at the face of a grid cell.\n" struct Face
        #= none:54 =#
    end
#= none:56 =#
#= none:56 =# Core.@doc "    AbstractTopology\n\nAbstract supertype for grid topologies.\n" abstract type AbstractTopology end
#= none:63 =#
#= none:63 =# Core.@doc "    Periodic\n\nGrid topology for periodic dimensions.\n" struct Periodic <: AbstractTopology
        #= none:68 =#
    end
#= none:70 =#
#= none:70 =# Core.@doc "    Bounded\n\nGrid topology for bounded dimensions, e.g., wall-bounded dimensions.\n" struct Bounded <: AbstractTopology
        #= none:75 =#
    end
#= none:77 =#
#= none:77 =# Core.@doc "    Flat\n\nGrid topology for flat dimensions, generally with one grid point, along which the solution\nis uniform and does not vary.\n" struct Flat <: AbstractTopology
        #= none:83 =#
    end
#= none:85 =#
#= none:85 =# Core.@doc "    FullyConnected\n\nGrid topology for dimensions that are connected to other models or domains.\n" struct FullyConnected <: AbstractTopology
        #= none:90 =#
    end
#= none:92 =#
#= none:92 =# Core.@doc "    LeftConnected\n\nGrid topology for dimensions that are connected to other models or domains only on the left (the other direction is bounded)\n" struct LeftConnected <: AbstractTopology
        #= none:97 =#
    end
#= none:99 =#
#= none:99 =# Core.@doc "    RightConnected\n\nGrid topology for dimensions that are connected to other models or domains only on the right (the other direction is bounded)\n" struct RightConnected <: AbstractTopology
        #= none:104 =#
    end
#= none:110 =#
abstract type AbstractDirection end
#= none:112 =#
struct XDirection <: AbstractDirection
    #= none:112 =#
end
#= none:113 =#
struct YDirection <: AbstractDirection
    #= none:113 =#
end
#= none:114 =#
struct ZDirection <: AbstractDirection
    #= none:114 =#
end
#= none:116 =#
struct NegativeZDirection <: AbstractDirection
    #= none:116 =#
end
#= none:118 =#
include("abstract_grid.jl")
#= none:119 =#
include("grid_utils.jl")
#= none:120 =#
include("nodes_and_spacings.jl")
#= none:121 =#
include("zeros_and_ones.jl")
#= none:122 =#
include("new_data.jl")
#= none:123 =#
include("inactive_node.jl")
#= none:124 =#
include("automatic_halo_sizing.jl")
#= none:125 =#
include("input_validation.jl")
#= none:126 =#
include("grid_generation.jl")
#= none:127 =#
include("rectilinear_grid.jl")
#= none:128 =#
include("orthogonal_spherical_shell_grid.jl")
#= none:129 =#
include("latitude_longitude_grid.jl")
end