
#= none:1 =#
#= none:1 =# Core.@doc "    AbstractGrid{FT, TX, TY, TZ}\n\nAbstract supertype for grids with elements of type `FT` and topology `{TX, TY, TZ}`.\n" abstract type AbstractGrid{FT, TX, TY, TZ, Arch} end
#= none:8 =#
#= none:8 =# Core.@doc "    AbstractUnderlyingGrid{FT, TX, TY, TZ}\n\nAbstract supertype for \"primary\" grids (as opposed to grids with immersed boundaries)\nwith elements of type `FT` and topology `{TX, TY, TZ}`.\n" abstract type AbstractUnderlyingGrid{FT, TX, TY, TZ, Arch} <: AbstractGrid{FT, TX, TY, TZ, Arch} end
#= none:16 =#
#= none:16 =# Core.@doc "    AbstractCurvilinearGrid{FT, TX, TY, TZ}\n\nAbstract supertype for curvilinear grids with elements of type `FT` and topology `{TX, TY, TZ}`.\n" abstract type AbstractCurvilinearGrid{FT, TX, TY, TZ, Arch} <: AbstractUnderlyingGrid{FT, TX, TY, TZ, Arch} end
#= none:23 =#
#= none:23 =# Core.@doc "    AbstractHorizontallyCurvilinearGrid{FT, TX, TY, TZ}\n\nAbstract supertype for horizontally-curvilinear grids with elements of type `FT` and topology `{TX, TY, TZ}`.\n" abstract type AbstractHorizontallyCurvilinearGrid{FT, TX, TY, TZ, Arch} <: AbstractCurvilinearGrid{FT, TX, TY, TZ, Arch} end
#= none:30 =#
const XFlatGrid = AbstractGrid{<:Any, Flat}
#= none:31 =#
const YFlatGrid = AbstractGrid{<:Any, <:Any, Flat}
#= none:32 =#
const ZFlatGrid = AbstractGrid{<:Any, <:Any, <:Any, Flat}
#= none:34 =#
const XYFlatGrid = AbstractGrid{<:Any, Flat, Flat}
#= none:35 =#
const XZFlatGrid = AbstractGrid{<:Any, Flat, <:Any, Flat}
#= none:36 =#
const YZFlatGrid = AbstractGrid{<:Any, <:Any, Flat, Flat}
#= none:38 =#
const XYZFlatGrid = AbstractGrid{<:Any, Flat, Flat, Flat}
#= none:40 =#
isrectilinear(grid) = begin
        #= none:40 =#
        false
    end
#= none:43 =#
#= none:43 =# @inline retrieve_surface_active_cells_map(::AbstractGrid) = begin
            #= none:43 =#
            nothing
        end
#= none:44 =#
#= none:44 =# @inline retrieve_interior_active_cells_map(::AbstractGrid, any_map_type) = begin
            #= none:44 =#
            nothing
        end
#= none:46 =#
#= none:46 =# Core.@doc "    topology(grid)\n\nReturn a tuple with the topology of the `grid` for each dimension.\n" #= none:51 =# @inline((topology(::AbstractGrid{FT, TX, TY, TZ}) where {FT, TX, TY, TZ}) = begin
                #= none:51 =#
                (TX, TY, TZ)
            end)
#= none:53 =#
#= none:53 =# Core.@doc "    topology(grid, dim)\n\nReturn the topology of the `grid` for the `dim`-th dimension.\n" #= none:58 =# @inline(topology(grid, dim) = begin
                #= none:58 =#
                (topology(grid))[dim]
            end)
#= none:60 =#
#= none:60 =# Core.@doc "    architecture(grid::AbstractGrid)\n\nReturn the architecture (CPU or GPU) that the `grid` lives on.\n" #= none:65 =# @inline(architecture(grid::AbstractGrid) = begin
                #= none:65 =#
                grid.architecture
            end)
#= none:67 =#
#= none:67 =# Core.@doc "    size(grid)\n\nReturn a 3-tuple of the number of \"center\" cells on a grid in (x, y, z).\nCenter cells have the location (Center, Center, Center).\n" #= none:73 =# @inline(Base.size(grid::AbstractGrid) = begin
                #= none:73 =#
                (grid.Nx, grid.Ny, grid.Nz)
            end)
#= none:74 =#
(Base.eltype(::AbstractGrid{FT}) where FT) = begin
        #= none:74 =#
        FT
    end
#= none:75 =#
(Base.eps(::AbstractGrid{FT}) where FT) = begin
        #= none:75 =#
        eps(FT)
    end
#= none:77 =#
function Base.:(==)(grid1::AbstractGrid, grid2::AbstractGrid)
    #= none:77 =#
    #= none:79 =#
    !(grid2 isa (typeof(grid1)).name.wrapper) && return false
    #= none:81 =#
    topology(grid1) !== topology(grid2) && return false
    #= none:83 =#
    (x1, y1, z1) = nodes(grid1, (Face(), Face(), Face()))
    #= none:84 =#
    (x2, y2, z2) = nodes(grid2, (Face(), Face(), Face()))
    #= none:86 =#
    #= none:86 =# CUDA.@allowscalar return x1 == x2 && (y1 == y2 && z1 == z2)
end
#= none:89 =#
#= none:89 =# Core.@doc "    halo_size(grid)\n\nReturn a 3-tuple with the number of halo cells on either side of the\ndomain in (x, y, z).\n" halo_size(grid) = begin
            #= none:95 =#
            (grid.Hx, grid.Hy, grid.Hz)
        end
#= none:96 =#
halo_size(grid, d) = begin
        #= none:96 =#
        (halo_size(grid))[d]
    end
#= none:98 =#
#= none:98 =# @inline Base.size(grid::AbstractGrid, d::Int) = begin
            #= none:98 =#
            (size(grid))[d]
        end
#= none:100 =#
grid_name(grid::AbstractGrid) = begin
        #= none:100 =#
        (typeof(grid)).name.wrapper
    end