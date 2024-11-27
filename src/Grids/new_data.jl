
#= none:1 =#
using Oceananigans.Grids: total_length, topology
#= none:3 =#
using OffsetArrays: OffsetArray
#= none:10 =#
#= none:10 =# Core.@doc "Return a range of indices for a field located at either cell `Center`s or `Face`s along a\ngrid dimension which is `Periodic`, or cell `Center`s for a grid dimension which is `Bounded`.\nThe dimension has length `N` and `H` halo points.\n" offset_indices(loc, topo, N, H = 0) = begin
            #= none:15 =#
            1 - H:N + H
        end
#= none:17 =#
#= none:17 =# Core.@doc "Return a range of indices for a field located at cell `Face`s along a grid dimension which\nis `Bounded` and has length `N` and with halo points `H`.\n" offset_indices(::Face, ::BoundedTopology, N, H = 0) = begin
            #= none:21 =#
            1 - H:N + H + 1
        end
#= none:23 =#
#= none:23 =# Core.@doc "Return a range of indices for a field along a 'reduced' dimension.\n" offset_indices(::Nothing, topo, N, H = 0) = begin
            #= none:26 =#
            1:1
        end
#= none:28 =#
offset_indices(ℓ, topo, N, H, ::Colon) = begin
        #= none:28 =#
        offset_indices(ℓ, topo, N, H)
    end
#= none:29 =#
offset_indices(ℓ, topo, N, H, r::UnitRange) = begin
        #= none:29 =#
        r
    end
#= none:30 =#
offset_indices(::Nothing, topo, N, H, ::UnitRange) = begin
        #= none:30 =#
        1:1
    end
#= none:32 =#
instantiate(T::Type) = begin
        #= none:32 =#
        T()
    end
#= none:33 =#
instantiate(t) = begin
        #= none:33 =#
        t
    end
#= none:36 =#
function offset_data(underlying_data::A, loc, topo, N, H, indices::T = default_indices(length(loc))) where {A <: AbstractArray, T}
    #= none:36 =#
    #= none:37 =#
    loc = map(instantiate, loc)
    #= none:38 =#
    topo = map(instantiate, topo)
    #= none:39 =#
    ii = map(offset_indices, loc, topo, N, H, indices)
    #= none:42 =#
    extra_ii = ntuple(Val(ndims(underlying_data) - length(ii))) do i
            #= none:43 =#
            #= none:43 =# Base.@_inline_meta
            #= none:44 =#
            axes(underlying_data, i + length(ii))
        end
    #= none:47 =#
    return OffsetArray(underlying_data, ii..., extra_ii...)
end
#= none:50 =#
#= none:50 =# Core.@doc "    offset_data(underlying_data, grid::AbstractGrid, loc, indices=default_indices(length(loc)))\n\nReturn an `OffsetArray` that maps to `underlying_data` in memory, with offset indices\nappropriate for the `data` of a field on a `grid` of `size(grid)` and located at `loc`.\n" offset_data(underlying_data::AbstractArray, grid::AbstractGrid, loc, indices = default_indices(length(loc))) = begin
            #= none:56 =#
            offset_data(underlying_data, loc, topology(grid), size(grid), halo_size(grid), indices)
        end
#= none:59 =#
#= none:59 =# Core.@doc "    new_data(FT, arch, loc, topo, sz, halo_sz, indices)\n\nReturn an `OffsetArray` of zeros of float type `FT` on `arch`itecture,\nwith indices corresponding to a field on a `grid` of `size(grid)` and located at `loc`.\n" function new_data(FT::DataType, arch, loc, topo, sz, halo_sz, indices = default_indices(length(loc)))
        #= none:65 =#
        #= none:66 =#
        (Tx, Ty, Tz) = total_size(loc, topo, sz, halo_sz, indices)
        #= none:67 =#
        underlying_data = zeros(FT, arch, Tx, Ty, Tz)
        #= none:68 =#
        indices = validate_indices(indices, loc, topo, sz, halo_sz)
        #= none:69 =#
        return offset_data(underlying_data, loc, topo, sz, halo_sz, indices)
    end
#= none:72 =#
new_data(FT::DataType, grid::AbstractGrid, loc, indices = default_indices(length(loc))) = begin
        #= none:72 =#
        new_data(FT, architecture(grid), loc, topology(grid), size(grid), halo_size(grid), indices)
    end
#= none:75 =#
new_data(grid::AbstractGrid, loc, indices = default_indices) = begin
        #= none:75 =#
        new_data(eltype(grid), grid, loc, indices)
    end