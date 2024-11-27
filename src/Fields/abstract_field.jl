
#= none:1 =#
using Base: @propagate_inbounds
#= none:2 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:3 =#
using Adapt
#= none:4 =#
using OffsetArrays
#= none:5 =#
using Statistics
#= none:7 =#
using Oceananigans.Architectures
#= none:8 =#
using Oceananigans.Utils
#= none:9 =#
using Oceananigans.Grids: interior_indices, interior_parent_indices
#= none:11 =#
import Base: minimum, maximum, extrema
#= none:12 =#
import Oceananigans: location, instantiated_location
#= none:13 =#
import Oceananigans.Architectures: architecture, child_architecture
#= none:14 =#
import Oceananigans.Grids: interior_x_indices, interior_y_indices, interior_z_indices
#= none:15 =#
import Oceananigans.Grids: total_size, topology, nodes, xnodes, ynodes, znodes, node, xnode, ynode, znode
#= none:16 =#
import Oceananigans.Utils: datatuple
#= none:18 =#
const ArchOrNothing = Union{AbstractArchitecture, Nothing}
#= none:19 =#
const GridOrNothing = Union{AbstractGrid, Nothing}
#= none:21 =#
#= none:21 =# Core.@doc "    AbstractField{LX, LY, LZ, G, T, N}\n\nAbstract supertype for fields located at `(LX, LY, LZ)`\nand defined on a grid `G` with eltype `T` and `N` dimensions.\n\nNote: we need the parameter `T` to subtype AbstractArray.\n" abstract type AbstractField{LX, LY, LZ, G <: GridOrNothing, T, N} <: AbstractArray{T, N} end
#= none:31 =#
Base.IndexStyle(::AbstractField) = begin
        #= none:31 =#
        IndexCartesian()
    end
#= none:37 =#
#= none:37 =# Core.@doc "Returns the location `(LX, LY, LZ)` of an `AbstractField{LX, LY, LZ}`." #= none:38 =# @inline(location(a) = begin
                #= none:38 =#
                (Nothing, Nothing, Nothing)
            end)
#= none:39 =#
#= none:39 =# @inline location(a, i) = begin
            #= none:39 =#
            (location(a))[i]
        end
#= none:40 =#
#= none:40 =# @inline (location(::AbstractField{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:40 =#
            (LX, LY, LZ)
        end
#= none:41 =#
#= none:41 =# @inline (instantiated_location(::AbstractField{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:41 =#
            (LX(), LY(), LZ())
        end
#= none:42 =#
(Base.eltype(::AbstractField{<:Any, <:Any, <:Any, <:Any, T}) where T) = begin
        #= none:42 =#
        T
    end
#= none:44 =#
#= none:44 =# Core.@doc "Returns the architecture of on which `f` is defined." architecture(f::AbstractField) = begin
            #= none:45 =#
            architecture(f.grid)
        end
#= none:46 =#
child_architecture(f::AbstractField) = begin
        #= none:46 =#
        child_architecture(architecture(f))
    end
#= none:48 =#
#= none:48 =# Core.@doc "Returns the topology of a fields' `grid`." #= none:49 =# @inline(topology(f::AbstractField, args...) = begin
                #= none:49 =#
                topology(f.grid, args...)
            end)
#= none:51 =#
#= none:51 =# Core.@doc "    size(f::AbstractField)\n\nReturns the size of an `AbstractField{LX, LY, LZ}` located at `LX, LY, LZ`.\nThis is a 3-tuple of integers corresponding to the number of interior nodes\nof `f` along `x, y, z`.\n" Base.size(f::AbstractField) = begin
            #= none:58 =#
            size(f.grid, location(f))
        end
#= none:59 =#
Base.length(f::AbstractField) = begin
        #= none:59 =#
        prod(size(f))
    end
#= none:60 =#
Base.parent(f::AbstractField) = begin
        #= none:60 =#
        f
    end
#= none:62 =#
const Abstract3DField = AbstractField{<:Any, <:Any, <:Any, <:Any, <:Any, 3}
#= none:63 =#
const Abstract4DField = AbstractField{<:Any, <:Any, <:Any, <:Any, <:Any, 4}
#= none:67 =#
#= none:67 =# @inline axis(::Colon, N) = begin
            #= none:67 =#
            Base.OneTo(N)
        end
#= none:68 =#
#= none:68 =# @inline axis(index::UnitRange, N) = begin
            #= none:68 =#
            index
        end
#= none:70 =#
#= none:70 =# @inline function Base.axes(f::Abstract3DField)
        #= none:70 =#
        #= none:71 =#
        (Nx, Ny, Nz) = size(f)
        #= none:72 =#
        (ix, iy, iz) = indices(f)
        #= none:74 =#
        ax = axis(ix, Nx)
        #= none:75 =#
        ay = axis(iy, Ny)
        #= none:76 =#
        az = axis(iz, Nz)
        #= none:78 =#
        return (ax, ay, az)
    end
#= none:81 =#
#= none:81 =# @inline function Base.axes(f::Abstract4DField)
        #= none:81 =#
        #= none:82 =#
        (Nx, Ny, Nz, Nt) = size(f)
        #= none:83 =#
        (ix, iy, iz) = indices(f)
        #= none:85 =#
        ax = axis(ix, Nx)
        #= none:86 =#
        ay = axis(iy, Ny)
        #= none:87 =#
        az = axis(iz, Nz)
        #= none:88 =#
        at = Base.OneTo(Nt)
        #= none:90 =#
        return (ax, ay, az, at)
    end
#= none:95 =#
#= none:95 =# Core.@doc "    total_size(field::AbstractField)\n\nReturns a 3-tuple that gives the \"total\" size of a field including\nboth interior points and halo points.\n" total_size(f::AbstractField) = begin
            #= none:101 =#
            total_size(f.grid, location(f))
        end
#= none:103 =#
interior(f::AbstractField) = begin
        #= none:103 =#
        f
    end
#= none:109 =#
#= none:109 =# @propagate_inbounds node(i, j, k, ψ::AbstractField) = begin
            #= none:109 =#
            node(i, j, k, ψ.grid, instantiated_location(ψ)...)
        end
#= none:110 =#
#= none:110 =# @propagate_inbounds xnode(i, j, k, ψ::AbstractField) = begin
            #= none:110 =#
            xnode(i, j, k, ψ.grid, instantiated_location(ψ)...)
        end
#= none:111 =#
#= none:111 =# @propagate_inbounds ynode(i, j, k, ψ::AbstractField) = begin
            #= none:111 =#
            ynode(i, j, k, ψ.grid, instantiated_location(ψ)...)
        end
#= none:112 =#
#= none:112 =# @propagate_inbounds znode(i, j, k, ψ::AbstractField) = begin
            #= none:112 =#
            znode(i, j, k, ψ.grid, instantiated_location(ψ)...)
        end
#= none:114 =#
xnodes(ψ::AbstractField; kwargs...) = begin
        #= none:114 =#
        xnodes(ψ.grid, instantiated_location(ψ)...; kwargs...)
    end
#= none:115 =#
ynodes(ψ::AbstractField; kwargs...) = begin
        #= none:115 =#
        ynodes(ψ.grid, instantiated_location(ψ)...; kwargs...)
    end
#= none:116 =#
znodes(ψ::AbstractField; kwargs...) = begin
        #= none:116 =#
        znodes(ψ.grid, instantiated_location(ψ)...; kwargs...)
    end
#= none:118 =#
nodes(ψ::AbstractField; kwargs...) = begin
        #= none:118 =#
        nodes(ψ.grid, instantiated_location(ψ); kwargs...)
    end
#= none:124 =#
for f = (:+, :-)
    #= none:125 =#
    #= none:125 =# @eval Base.$(f)(ϕ::AbstractArray, ψ::AbstractField) = begin
                #= none:125 =#
                $f(ϕ, interior(ψ))
            end
    #= none:126 =#
    #= none:126 =# @eval Base.$(f)(ϕ::AbstractField, ψ::AbstractArray) = begin
                #= none:126 =#
                $f(interior(ϕ), ψ)
            end
    #= none:127 =#
end