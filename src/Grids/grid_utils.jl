
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:2 =#
using Printf
#= none:3 =#
using Base.Ryu: writeshortest
#= none:4 =#
using LinearAlgebra: dot, cross
#= none:5 =#
using OffsetArrays: IdOffsetRange
#= none:7 =#
#= none:7 =# Core.@doc "    _property(ξ, T, ℓ, N, with_halos=false)\n\nReturn the grid property `ξ`, either `with_halos` or without,\nfor topology `T`, (instantiated) location `ℓ`, and dimension length `N`.\n" #= none:13 =# @inline(function _property(ξ, ℓ, T, N, with_halos)
            #= none:13 =#
            #= none:14 =#
            if with_halos
                #= none:15 =#
                return ξ
            else
                #= none:17 =#
                i = interior_indices(ℓ, T(), N)
                #= none:18 =#
                return view(ξ, i)
            end
        end)
#= none:22 =#
#= none:22 =# @inline function _property(ξ, ℓx, ℓy, Tx, Ty, Nx, Ny, with_halos)
        #= none:22 =#
        #= none:23 =#
        if with_halos
            #= none:24 =#
            return ξ
        else
            #= none:26 =#
            i = interior_indices(ℓx, Tx(), Nx)
            #= none:27 =#
            j = interior_indices(ℓy, Ty(), Ny)
            #= none:28 =#
            return view(ξ, i, j)
        end
    end
#= none:32 =#
#= none:32 =# @inline _property(ξ::Number, args...) = begin
            #= none:32 =#
            ξ
        end
#= none:33 =#
#= none:33 =# @inline _property(::Nothing, args...) = begin
            #= none:33 =#
            nothing
        end
#= none:36 =#
#= none:36 =# @inline default_indices(N::Int) = begin
            #= none:36 =#
            default_indices(Val(N))
        end
#= none:38 =#
#= none:38 =# @inline function default_indices(::Val{N}) where N
        #= none:38 =#
        #= none:39 =#
        ntuple(Val(N)) do n
            #= none:40 =#
            #= none:40 =# Base.@_inline_meta
            #= none:41 =#
            Colon()
        end
    end
#= none:45 =#
const BoundedTopology = Union{Bounded, LeftConnected}
#= none:46 =#
const AT = AbstractTopology
#= none:48 =#
Base.length(::Face, ::BoundedTopology, N) = begin
        #= none:48 =#
        N + 1
    end
#= none:49 =#
Base.length(::Nothing, ::AT, N) = begin
        #= none:49 =#
        1
    end
#= none:50 =#
Base.length(::Face, ::AT, N) = begin
        #= none:50 =#
        N
    end
#= none:51 =#
Base.length(::Center, ::AT, N) = begin
        #= none:51 =#
        N
    end
#= none:52 =#
Base.length(::Nothing, ::Flat, N) = begin
        #= none:52 =#
        N
    end
#= none:53 =#
Base.length(::Face, ::Flat, N) = begin
        #= none:53 =#
        N
    end
#= none:54 =#
Base.length(::Center, ::Flat, N) = begin
        #= none:54 =#
        N
    end
#= none:57 =#
Base.length(loc, topo::AT, N, ::Colon) = begin
        #= none:57 =#
        length(loc, topo, N)
    end
#= none:58 =#
Base.length(loc, topo::AT, N, ind::UnitRange) = begin
        #= none:58 =#
        min(length(loc, topo, N), length(ind))
    end
#= none:60 =#
#= none:60 =# Core.@doc "    total_length(loc, topo, N, H=0, ind=Colon())\n\nReturn the total length of a field at `loc`ation along\none dimension of `topo`logy with `N` centered cells and\n`H` halo cells. If `ind` is provided the total_length\nis restricted by `length(ind)`.\n" total_length(::Face, ::AT, N, H = 0) = begin
            #= none:68 =#
            N + 2H
        end
#= none:69 =#
total_length(::Center, ::AT, N, H = 0) = begin
        #= none:69 =#
        N + 2H
    end
#= none:70 =#
total_length(::Face, ::BoundedTopology, N, H = 0) = begin
        #= none:70 =#
        N + 1 + 2H
    end
#= none:71 =#
total_length(::Nothing, ::AT, N, H = 0) = begin
        #= none:71 =#
        1
    end
#= none:72 =#
total_length(::Nothing, ::Flat, N, H = 0) = begin
        #= none:72 =#
        N
    end
#= none:73 =#
total_length(::Face, ::Flat, N, H = 0) = begin
        #= none:73 =#
        N
    end
#= none:74 =#
total_length(::Center, ::Flat, N, H = 0) = begin
        #= none:74 =#
        N
    end
#= none:77 =#
total_length(loc, topo, N, H, ::Colon) = begin
        #= none:77 =#
        total_length(loc, topo, N, H)
    end
#= none:78 =#
total_length(loc, topo, N, H, ind::UnitRange) = begin
        #= none:78 =#
        min(total_length(loc, topo, N, H), length(ind))
    end
#= none:80 =#
#= none:80 =# @inline Base.size(grid::AbstractGrid, loc::Tuple, indices = default_indices(Val(length(loc)))) = begin
            #= none:80 =#
            size(loc, topology(grid), size(grid), indices)
        end
#= none:83 =#
#= none:83 =# @inline function Base.size(loc, topo, sz, indices = default_indices(Val(length(loc))))
        #= none:83 =#
        #= none:84 =#
        D = length(loc)
        #= none:87 =#
        return ntuple(Val(D)) do d
                #= none:88 =#
                #= none:88 =# Base.@_inline_meta
                #= none:89 =#
                length(Oceananigans.Utils.instantiate(loc[d]), Oceananigans.Utils.instantiate(topo[d]), sz[d], indices[d])
            end
    end
#= none:93 =#
Base.size(grid::AbstractGrid, loc::Tuple, d::Int) = begin
        #= none:93 =#
        (size(grid, loc))[d]
    end
#= none:95 =#
total_size(a) = begin
        #= none:95 =#
        size(a)
    end
#= none:97 =#
#= none:97 =# Core.@doc "    total_size(grid, loc)\n\nReturn the \"total\" size of a `grid` at `loc`. This is a 3-tuple of integers\ncorresponding to the number of grid points along `x, y, z`.\n" function total_size(loc, topo, sz, halo_sz, indices = default_indices(Val(length(loc))))
        #= none:103 =#
        #= none:104 =#
        D = length(loc)
        #= none:105 =#
        return Tuple((total_length(Oceananigans.Utils.instantiate(loc[d]), Oceananigans.Utils.instantiate(topo[d]), sz[d], halo_sz[d], indices[d]) for d = 1:D))
    end
#= none:108 =#
total_size(grid::AbstractGrid, loc, indices = default_indices(Val(length(loc)))) = begin
        #= none:108 =#
        total_size(loc, topology(grid), size(grid), halo_size(grid), indices)
    end
#= none:111 =#
#= none:111 =# Core.@doc "    total_extent(topology, H, Δ, L)\n\nReturn the total extent, including halo regions, of constant-spaced\n`Periodic` and `Flat` dimensions with number of halo points `H`,\nconstant grid spacing `Δ`, and interior extent `L`.\n" #= none:118 =# @inline(total_extent(topo, H, Δ, L) = begin
                #= none:118 =#
                L + (2H - 1) * Δ
            end)
#= none:119 =#
#= none:119 =# @inline total_extent(::BoundedTopology, H, Δ, L) = begin
            #= none:119 =#
            L + (2H) * Δ
        end
#= none:122 =#
#= none:122 =# @inline domain(topo, N, ξ) = begin
            #= none:122 =#
            #= none:122 =# CUDA.@allowscalar (ξ[1], ξ[N + 1])
        end
#= none:123 =#
#= none:123 =# @inline domain(::Flat, N, ξ::AbstractArray) = begin
            #= none:123 =#
            ξ[1]
        end
#= none:124 =#
#= none:124 =# @inline domain(::Flat, N, ξ::Number) = begin
            #= none:124 =#
            ξ
        end
#= none:125 =#
#= none:125 =# @inline domain(::Flat, N, ::Nothing) = begin
            #= none:125 =#
            nothing
        end
#= none:127 =#
#= none:127 =# @inline x_domain(grid) = begin
            #= none:127 =#
            domain((topology(grid, 1))(), grid.Nx, grid.xᶠᵃᵃ)
        end
#= none:128 =#
#= none:128 =# @inline y_domain(grid) = begin
            #= none:128 =#
            domain((topology(grid, 2))(), grid.Ny, grid.yᵃᶠᵃ)
        end
#= none:129 =#
#= none:129 =# @inline z_domain(grid) = begin
            #= none:129 =#
            domain((topology(grid, 3))(), grid.Nz, grid.zᵃᵃᶠ)
        end
#= none:131 =#
regular_dimensions(grid) = begin
        #= none:131 =#
        ()
    end
#= none:137 =#
#= none:137 =# @inline left_halo_indices(loc, ::AT, N, H) = begin
            #= none:137 =#
            1 - H:0
        end
#= none:138 =#
#= none:138 =# @inline left_halo_indices(::Nothing, ::AT, N, H) = begin
            #= none:138 =#
            1:0
        end
#= none:140 =#
#= none:140 =# @inline right_halo_indices(loc, ::AT, N, H) = begin
            #= none:140 =#
            N + 1:N + H
        end
#= none:141 =#
#= none:141 =# @inline right_halo_indices(::Face, ::BoundedTopology, N, H) = begin
            #= none:141 =#
            N + 2:N + 1 + H
        end
#= none:142 =#
#= none:142 =# @inline right_halo_indices(::Nothing, ::AT, N, H) = begin
            #= none:142 =#
            1:0
        end
#= none:144 =#
#= none:144 =# @inline underlying_left_halo_indices(loc, ::AT, N, H) = begin
            #= none:144 =#
            1:H
        end
#= none:145 =#
#= none:145 =# @inline underlying_left_halo_indices(::Nothing, ::AT, N, H) = begin
            #= none:145 =#
            1:0
        end
#= none:147 =#
#= none:147 =# @inline underlying_right_halo_indices(loc, ::AT, N, H) = begin
            #= none:147 =#
            N + 1 + H:N + 2H
        end
#= none:148 =#
#= none:148 =# @inline underlying_right_halo_indices(::Face, ::BoundedTopology, N, H) = begin
            #= none:148 =#
            N + 2 + H:N + 1 + 2H
        end
#= none:149 =#
#= none:149 =# @inline underlying_right_halo_indices(::Nothing, ::AT, N, H) = begin
            #= none:149 =#
            1:0
        end
#= none:151 =#
#= none:151 =# @inline interior_indices(loc, ::AT, N) = begin
            #= none:151 =#
            1:N
        end
#= none:152 =#
#= none:152 =# @inline interior_indices(::Face, ::BoundedTopology, N) = begin
            #= none:152 =#
            1:N + 1
        end
#= none:153 =#
#= none:153 =# @inline interior_indices(::Nothing, ::AT, N) = begin
            #= none:153 =#
            1:1
        end
#= none:155 =#
#= none:155 =# @inline interior_indices(::Nothing, ::Flat, N) = begin
            #= none:155 =#
            1:N
        end
#= none:156 =#
#= none:156 =# @inline interior_indices(::Face, ::Flat, N) = begin
            #= none:156 =#
            1:N
        end
#= none:157 =#
#= none:157 =# @inline interior_indices(::Center, ::Flat, N) = begin
            #= none:157 =#
            1:N
        end
#= none:159 =#
#= none:159 =# @inline interior_x_indices(grid, loc) = begin
            #= none:159 =#
            interior_indices(loc[1], (topology(grid, 1))(), size(grid, 1))
        end
#= none:160 =#
#= none:160 =# @inline interior_y_indices(grid, loc) = begin
            #= none:160 =#
            interior_indices(loc[2], (topology(grid, 2))(), size(grid, 2))
        end
#= none:161 =#
#= none:161 =# @inline interior_z_indices(grid, loc) = begin
            #= none:161 =#
            interior_indices(loc[3], (topology(grid, 3))(), size(grid, 3))
        end
#= none:163 =#
#= none:163 =# @inline interior_parent_offset(loc, ::AT, H) = begin
            #= none:163 =#
            H
        end
#= none:164 =#
#= none:164 =# @inline interior_parent_offset(::Nothing, ::AT, H) = begin
            #= none:164 =#
            0
        end
#= none:166 =#
#= none:166 =# @inline interior_parent_indices(::Nothing, ::AT, N, H) = begin
            #= none:166 =#
            1:1
        end
#= none:167 =#
#= none:167 =# @inline interior_parent_indices(::Face, ::BoundedTopology, N, H) = begin
            #= none:167 =#
            1 + H:N + 1 + H
        end
#= none:168 =#
#= none:168 =# @inline interior_parent_indices(loc, ::AT, N, H) = begin
            #= none:168 =#
            1 + H:N + H
        end
#= none:170 =#
#= none:170 =# @inline interior_parent_indices(::Nothing, ::Flat, N, H) = begin
            #= none:170 =#
            1:N
        end
#= none:171 =#
#= none:171 =# @inline interior_parent_indices(::Face, ::Flat, N, H) = begin
            #= none:171 =#
            1:N
        end
#= none:172 =#
#= none:172 =# @inline interior_parent_indices(::Center, ::Flat, N, H) = begin
            #= none:172 =#
            1:N
        end
#= none:175 =#
#= none:175 =# @inline all_indices(::Nothing, ::AT, N, H) = begin
            #= none:175 =#
            1:1
        end
#= none:176 =#
#= none:176 =# @inline all_indices(::Face, ::BoundedTopology, N, H) = begin
            #= none:176 =#
            1 - H:N + 1 + H
        end
#= none:177 =#
#= none:177 =# @inline all_indices(loc, ::AT, N, H) = begin
            #= none:177 =#
            1 - H:N + H
        end
#= none:179 =#
#= none:179 =# @inline all_indices(::Nothing, ::Flat, N, H) = begin
            #= none:179 =#
            1:N
        end
#= none:180 =#
#= none:180 =# @inline all_indices(::Face, ::Flat, N, H) = begin
            #= none:180 =#
            1:N
        end
#= none:181 =#
#= none:181 =# @inline all_indices(::Center, ::Flat, N, H) = begin
            #= none:181 =#
            1:N
        end
#= none:183 =#
#= none:183 =# @inline all_x_indices(grid, loc) = begin
            #= none:183 =#
            all_indices((loc[1])(), (topology(grid, 1))(), size(grid, 1), halo_size(grid, 1))
        end
#= none:184 =#
#= none:184 =# @inline all_y_indices(grid, loc) = begin
            #= none:184 =#
            all_indices((loc[2])(), (topology(grid, 2))(), size(grid, 2), halo_size(grid, 2))
        end
#= none:185 =#
#= none:185 =# @inline all_z_indices(grid, loc) = begin
            #= none:185 =#
            all_indices((loc[3])(), (topology(grid, 3))(), size(grid, 3), halo_size(grid, 3))
        end
#= none:187 =#
#= none:187 =# @inline all_parent_indices(loc, ::AT, N, H) = begin
            #= none:187 =#
            1:N + 2H
        end
#= none:188 =#
#= none:188 =# @inline all_parent_indices(::Face, ::BoundedTopology, N, H) = begin
            #= none:188 =#
            1:N + 1 + 2H
        end
#= none:189 =#
#= none:189 =# @inline all_parent_indices(::Nothing, ::AT, N, H) = begin
            #= none:189 =#
            1:1
        end
#= none:191 =#
#= none:191 =# @inline all_parent_indices(::Nothing, ::Flat, N, H) = begin
            #= none:191 =#
            1:N
        end
#= none:192 =#
#= none:192 =# @inline all_parent_indices(::Face, ::Flat, N, H) = begin
            #= none:192 =#
            1:N
        end
#= none:193 =#
#= none:193 =# @inline all_parent_indices(::Center, ::Flat, N, H) = begin
            #= none:193 =#
            1:N
        end
#= none:195 =#
#= none:195 =# @inline all_parent_x_indices(grid, loc) = begin
            #= none:195 =#
            all_parent_indices((loc[1])(), (topology(grid, 1))(), size(grid, 1), halo_size(grid, 1))
        end
#= none:196 =#
#= none:196 =# @inline all_parent_y_indices(grid, loc) = begin
            #= none:196 =#
            all_parent_indices((loc[2])(), (topology(grid, 2))(), size(grid, 2), halo_size(grid, 2))
        end
#= none:197 =#
#= none:197 =# @inline all_parent_z_indices(grid, loc) = begin
            #= none:197 =#
            all_parent_indices((loc[3])(), (topology(grid, 3))(), size(grid, 3), halo_size(grid, 3))
        end
#= none:200 =#
parent_index_range(::Colon, loc, topo, halo) = begin
        #= none:200 =#
        Colon()
    end
#= none:201 =#
parent_index_range(::Base.Slice{<:IdOffsetRange}, loc, topo, halo) = begin
        #= none:201 =#
        Colon()
    end
#= none:202 =#
parent_index_range(view_indices::UnitRange, ::Nothing, ::Flat, halo) = begin
        #= none:202 =#
        view_indices
    end
#= none:203 =#
parent_index_range(view_indices::UnitRange, ::Nothing, ::AT, halo) = begin
        #= none:203 =#
        1:1
    end
#= none:204 =#
parent_index_range(view_indices::UnitRange, loc, topo, halo) = begin
        #= none:204 =#
        view_indices .+ interior_parent_offset(loc, topo, halo)
    end
#= none:207 =#
parent_index_range(::Colon, args...) = begin
        #= none:207 =#
        parent_index_range(args...)
    end
#= none:209 =#
parent_index_range(parent_indices::UnitRange, ::Colon, args...) = begin
        #= none:209 =#
        parent_index_range(parent_indices, parent_indices, args...)
    end
#= none:212 =#
function parent_index_range(parent_indices::UnitRange, view_indices, args...)
    #= none:212 =#
    #= none:213 =#
    start = (first(view_indices) - first(parent_indices)) + 1
    #= none:214 =#
    stop = (start + length(view_indices)) - 1
    #= none:215 =#
    return UnitRange(start, stop)
end
#= none:219 =#
index_range_contains(range, subset::UnitRange) = begin
        #= none:219 =#
        (first(subset) ∈ range) & (last(subset) ∈ range)
    end
#= none:220 =#
index_range_contains(::Colon, ::UnitRange) = begin
        #= none:220 =#
        true
    end
#= none:221 =#
index_range_contains(::Colon, ::Colon) = begin
        #= none:221 =#
        true
    end
#= none:222 =#
index_range_contains(::UnitRange, ::Colon) = begin
        #= none:222 =#
        true
    end
#= none:225 =#
parent_windowed_indices(::Colon, loc, topo, halo) = begin
        #= none:225 =#
        Colon()
    end
#= none:226 =#
parent_windowed_indices(indices::UnitRange, loc, topo, halo) = begin
        #= none:226 =#
        UnitRange(1, length(indices))
    end
#= none:228 =#
index_range_offset(index::UnitRange, loc, topo, halo) = begin
        #= none:228 =#
        index[1] - interior_parent_offset(loc, topo, halo)
    end
#= none:229 =#
index_range_offset(::Colon, loc, topo, halo) = begin
        #= none:229 =#
        -(interior_parent_offset(loc, topo, halo))
    end
#= none:231 =#
const c = Center()
#= none:232 =#
const f = Face()
#= none:235 =#
#= none:235 =# @inline cpu_face_constructor_x(grid) = begin
            #= none:235 =#
            Array((getindex(nodes(grid, f, c, c; with_halos = true), 1))[1:size(grid, 1) + 1])
        end
#= none:236 =#
#= none:236 =# @inline cpu_face_constructor_y(grid) = begin
            #= none:236 =#
            Array((getindex(nodes(grid, c, f, c; with_halos = true), 2))[1:size(grid, 2) + 1])
        end
#= none:237 =#
#= none:237 =# @inline cpu_face_constructor_z(grid) = begin
            #= none:237 =#
            Array((getindex(nodes(grid, c, c, f; with_halos = true), 3))[1:size(grid, 3) + 1])
        end
#= none:243 =#
unpack_grid(grid) = begin
        #= none:243 =#
        (grid.Nx, grid.Ny, grid.Nz, grid.Lx, grid.Ly, grid.Lz)
    end
#= none:245 =#
flatten_halo(TX, TY, TZ, halo) = begin
        #= none:245 =#
        Tuple((if T === Flat
                0
            else
                halo[i]
            end for (i, T) = enumerate((TX, TY, TZ))))
    end
#= none:246 =#
flatten_size(TX, TY, TZ, halo) = begin
        #= none:246 =#
        Tuple((if T === Flat
                0
            else
                halo[i]
            end for (i, T) = enumerate((TX, TY, TZ))))
    end
#= none:248 =#
#= none:248 =# Core.@doc "    pop_flat_elements(tup, topo)\n\nReturn a new tuple that contains the elements of `tup`,\nexcept for those elements corresponding to the `Flat` directions\nin `topo`.\n" function pop_flat_elements(tup, topo)
        #= none:255 =#
        #= none:256 =#
        new_tup = []
        #= none:257 =#
        for i = 1:3
            #= none:258 =#
            topo[i] != Flat && push!(new_tup, tup[i])
            #= none:259 =#
        end
        #= none:260 =#
        return Tuple(new_tup)
    end
#= none:267 =#
-(::NegativeZDirection) = begin
        #= none:267 =#
        ZDirection()
    end
#= none:268 =#
-(::ZDirection) = begin
        #= none:268 =#
        NegativeZDirection()
    end
#= none:274 =#
Base.summary(::XDirection) = begin
        #= none:274 =#
        "XDirection()"
    end
#= none:275 =#
Base.summary(::YDirection) = begin
        #= none:275 =#
        "YDirection()"
    end
#= none:276 =#
Base.summary(::ZDirection) = begin
        #= none:276 =#
        "ZDirection()"
    end
#= none:277 =#
Base.summary(::NegativeZDirection) = begin
        #= none:277 =#
        "NegativeZDirection()"
    end
#= none:279 =#
Base.show(io::IO, dir::AbstractDirection) = begin
        #= none:279 =#
        print(io, summary(dir))
    end
#= none:281 =#
size_summary(sz) = begin
        #= none:281 =#
        string(sz[1], "×", sz[2], "×", sz[3])
    end
#= none:282 =#
prettysummary(σ::AbstractFloat, plus = false) = begin
        #= none:282 =#
        writeshortest(σ, plus, false, true, -1, UInt8('e'), false, UInt8('.'), false, true)
    end
#= none:284 =#
domain_summary(topo::Flat, name, ::Nothing) = begin
        #= none:284 =#
        "Flat $(name)"
    end
#= none:285 =#
domain_summary(topo::Flat, name, coord::Number) = begin
        #= none:285 =#
        "Flat $(name) = $(coord)"
    end
#= none:287 =#
function domain_summary(topo, name, (left, right))
    #= none:287 =#
    #= none:288 =#
    interval = if topo isa Bounded || topo isa LeftConnected
            "]"
        else
            ")"
        end
    #= none:291 =#
    topo_string = if topo isa Periodic
            "Periodic "
        else
            if topo isa Bounded
                "Bounded  "
            else
                if topo isa FullyConnected
                    "FullyConnected "
                else
                    if topo isa LeftConnected
                        "LeftConnected  "
                    else
                        if topo isa RightConnected
                            "RightConnected  "
                        else
                            error("Unexpected topology $(topo) together with the domain end points ($(left), $(right))")
                        end
                    end
                end
            end
        end
    #= none:298 =#
    return string(topo_string, name, " ∈ [", prettysummary(left), ", ", prettysummary(right), interval)
end
#= none:303 =#
function dimension_summary(topo, name, dom, spacing, pad_domain = 0)
    #= none:303 =#
    #= none:304 =#
    prefix = domain_summary(topo, name, dom)
    #= none:305 =#
    padding = " " ^ (pad_domain + 1)
    #= none:306 =#
    return string(prefix, padding, coordinate_summary(topo, spacing, name))
end
#= none:309 =#
coordinate_summary(::Flat, Δ::Number, name) = begin
        #= none:309 =#
        ""
    end
#= none:310 =#
coordinate_summary(topo, Δ::Number, name) = begin
        #= none:310 =#
        #= none:310 =# @sprintf "regularly spaced with Δ%s=%s" name prettysummary(Δ)
    end
#= none:312 =#
coordinate_summary(topo, Δ::Union{AbstractVector, AbstractMatrix}, name) = begin
        #= none:312 =#
        #= none:313 =# @sprintf "variably spaced with min(Δ%s)=%s, max(Δ%s)=%s" name prettysummary(minimum(parent(Δ))) name prettysummary(maximum(parent(Δ)))
    end
#= none:321 =#
#= none:321 =# Core.@doc "    spherical_area_triangle(a::Number, b::Number, c::Number)\n\nReturn the area of a spherical triangle on the unit sphere with sides `a`, `b`, and `c`.\n\nThe area of a spherical triangle on the unit sphere is ``E = A + B + C - π``, where ``A``, ``B``, and ``C``\nare the triangle's inner angles.\n\nIt has been known since the time of Euler and Lagrange that\n``\\tan(E/2) = P / (1 + \\cos a + \\cos b + \\cos c)``, where\n``P = (1 - \\cos²a - \\cos²b - \\cos²c + 2 \\cos a \\cos b \\cos c)^{1/2}``.\n\nReferences\n==========\n* Euler, L. (1778) De mensura angulorum solidorum, Opera omnia, 26, 204-233 (Orig. in Acta adac. sc. Petrop. 1778)\n* Lagrange,  J.-L. (1798) Solutions de quilquies problèmes relatifs au triangles sphéruques, Oeuvres, 7, 331-359.\n" function spherical_area_triangle(a::Number, b::Number, c::Number)
        #= none:338 =#
        #= none:339 =#
        cosa = cos(a)
        #= none:340 =#
        cosb = cos(b)
        #= none:341 =#
        cosc = cos(c)
        #= none:343 =#
        tan½E = sqrt((((1 - cosa ^ 2) - cosb ^ 2) - cosc ^ 2) + (2cosa) * cosb * cosc)
        #= none:344 =#
        tan½E /= 1 + cosa + cosb + cosc
        #= none:346 =#
        return 2 * atan(tan½E)
    end
#= none:349 =#
#= none:349 =# Core.@doc "    spherical_area_triangle(a::AbstractVector, b::AbstractVector, c::AbstractVector)\n\nReturn the area of a spherical triangle on the unit sphere with vertices given by the 3-vectors\n`a`, `b`, and `c` whose origin is the the center of the sphere. The formula was first given by\nEriksson (1990).\n\nIf we denote with ``A``, ``B``, and ``C`` the inner angles of the spherical triangle and with\n``a``, ``b``, and ``c`` the side of the triangle then, it has been known since Euler and Lagrange\nthat ``\\tan(E/2) = P / (1 + \\cos a + \\cos b + \\cos c)``, where ``E = A + B + C - π`` is the\ntriangle's excess and ``P = (1 - \\cos²a - \\cos²b - \\cos²c + 2 \\cos a \\cos b \\cos c)^{1/2}``.\nOn the unit sphere, ``E`` is precisely the area of the spherical triangle. Erikkson (1990) showed\nthat ``P`` above is the same as the volume defined by the vectors `a`, `b`, and `c`, that is\n``P = |𝐚 \\cdot (𝐛 \\times 𝐜)|``.\n\nReferences\n==========\n* Eriksson, F. (1990) On the measure of solid angles, Mathematics Magazine, 63 (3), 184-187, doi:10.1080/0025570X.1990.11977515\n" function spherical_area_triangle(a₁::AbstractVector, a₂::AbstractVector, a₃::AbstractVector)
        #= none:368 =#
        #= none:369 =#
        sum(a₁ .^ 2) ≈ 1 && (sum(a₂ .^ 2) ≈ 1 && sum(a₃ .^ 2) ≈ 1) || error("a₁, a₂, a₃ must be unit vectors")
        #= none:371 =#
        tan½E = abs(dot(a₁, cross(a₂, a₃)))
        #= none:372 =#
        tan½E /= 1 + dot(a₁, a₂) + dot(a₂, a₃) + dot(a₁, a₃)
        #= none:374 =#
        return 2 * atan(tan½E)
    end
#= none:377 =#
#= none:377 =# Core.@doc "    spherical_area_quadrilateral(a₁, a₂, a₃, a₄)\n\nReturn the area of a spherical quadrilateral on the unit sphere whose points are given by 3-vectors,\n`a`, `b`, `c`, and `d`. The area of the quadrilateral is given as the sum of the ares of the two\nnon-overlapping triangles. To avoid having to pick the triangles appropriately ensuring they are not\noverlapping, we compute the area of the quadrilateral as the half the sum of the areas of all four potential\ntriangles formed by `a₁`, `a₂`, `a₃`, and `a₄`.\n" spherical_area_quadrilateral(a::AbstractVector, b::AbstractVector, c::AbstractVector, d::AbstractVector) = begin
            #= none:386 =#
            (1 / 2) * (spherical_area_triangle(a, b, c) + spherical_area_triangle(a, b, d) + spherical_area_triangle(a, c, d) + spherical_area_triangle(b, c, d))
        end
#= none:390 =#
#= none:390 =# Core.@doc "    add_halos(data, loc, topo, sz, halo_sz; warnings=true)\n\nAdd halos of size `halo_sz :: NTuple{3}{Int}` to `data` that corresponds to\nsize `sz :: NTuple{3}{Int}`, location `loc :: NTuple{3}`, and topology\n`topo :: NTuple{3}`.\n\nSetting the keyword `warning = false` will spare you from warnings regarding\nthe size of `data` being too big or too small for the `loc`, `topo`, and `sz`\nprovided.\n\nExample\n=======\n\n```julia\njulia> using Oceananigans\n\njulia> using Oceananigans.Grids: add_halos, total_length\n\njulia> Nx, Ny, Nz = (3, 3, 1);\n\njulia> loc = (Face, Center, Nothing);\n\njulia> topo = (Bounded, Periodic, Bounded);\n\njulia> data = rand(total_length(loc[1](), topo[1](), Nx, 0), total_length(loc[2](), topo[2](), Ny, 0))\n4×3 Matrix{Float64}:\n 0.771924  0.998196   0.48775\n 0.499878  0.470224   0.669928\n 0.254603  0.73885    0.0821657\n 0.997512  0.0440224  0.726334\n\njulia> add_halos(data, loc, topo, (Nx, Ny, Nz), (1, 2, 0))\n6×7 OffsetArray(::Matrix{Float64}, 0:5, -1:5) with eltype Float64 with indices 0:5×-1:5:\n 0.0  0.0  0.0       0.0        0.0        0.0  0.0\n 0.0  0.0  0.771924  0.998196   0.48775    0.0  0.0\n 0.0  0.0  0.499878  0.470224   0.669928   0.0  0.0\n 0.0  0.0  0.254603  0.73885    0.0821657  0.0  0.0\n 0.0  0.0  0.997512  0.0440224  0.726334   0.0  0.0\n 0.0  0.0  0.0       0.0        0.0        0.0  0.0\n\n julia> data = rand(8, 2)\n8×2 Matrix{Float64}:\n 0.910064  0.491983\n 0.597547  0.775168\n 0.711421  0.519057\n 0.697258  0.450122\n 0.300358  0.510102\n 0.865862  0.579322\n 0.196049  0.217199\n 0.799729  0.822402\n\njulia> add_halos(data, loc, topo, (Nx, Ny, Nz), (1, 2, 0))\n┌ Warning: data has larger size than expected in first dimension; some data is lost\n└ @ Oceananigans.Grids ~/Oceananigans.jl/src/Grids/grid_utils.jl:650\n┌ Warning: data has smaller size than expected in second dimension; rest of entries are filled with zeros.\n└ @ Oceananigans.Grids ~/Oceananigans.jl/src/Grids/grid_utils.jl:655\n6×7 OffsetArray(::Matrix{Float64}, 0:5, -1:5) with eltype Float64 with indices 0:5×-1:5:\n 0.0  0.0  0.0       0.0       0.0  0.0  0.0\n 0.0  0.0  0.910064  0.491983  0.0  0.0  0.0\n 0.0  0.0  0.597547  0.775168  0.0  0.0  0.0\n 0.0  0.0  0.711421  0.519057  0.0  0.0  0.0\n 0.0  0.0  0.697258  0.450122  0.0  0.0  0.0\n 0.0  0.0  0.0       0.0       0.0  0.0  0.0\n```\n" function add_halos(data, loc, topo, sz, halo_sz; warnings = true)
        #= none:456 =#
        #= none:458 =#
        (Nx, Ny, Nz) = size(data)
        #= none:460 =#
        arch = architecture(data)
        #= none:463 =#
        map((a->begin
                    #= none:463 =#
                    on_architecture(CPU(), a)
                end), data)
        #= none:465 =#
        (nx, ny, nz) = (total_length((loc[1])(), (topo[1])(), sz[1], 0), total_length((loc[2])(), (topo[2])(), sz[2], 0), total_length((loc[3])(), (topo[3])(), sz[3], 0))
        #= none:469 =#
        if warnings
            #= none:470 =#
            Nx > nx && #= none:470 =# @warn("data has larger size than expected in first dimension; some data is lost")
            #= none:471 =#
            Ny > ny && #= none:471 =# @warn("data has larger size than expected in second dimension; some data is lost")
            #= none:472 =#
            Nz > nz && #= none:472 =# @warn("data has larger size than expected in third dimension; some data is lost")
            #= none:474 =#
            Nx < nx && #= none:474 =# @warn("data has smaller size than expected in first dimension; rest of entries are filled with zeros.")
            #= none:475 =#
            Ny < ny && #= none:475 =# @warn("data has smaller size than expected in second dimension; rest of entries are filled with zeros.")
            #= none:476 =#
            Nz < nz && #= none:476 =# @warn("data has smaller size than expected in third dimension; rest of entries are filled with zeros.")
        end
        #= none:479 =#
        offset_array = dropdims(new_data(eltype(data), CPU(), loc, topo, sz, halo_sz), dims = 3)
        #= none:481 =#
        nx = minimum((nx, Nx))
        #= none:482 =#
        ny = minimum((ny, Ny))
        #= none:483 =#
        nz = minimum((nz, Nz))
        #= none:485 =#
        offset_array[1:nx, 1:ny, 1:nz] = data[1:nx, 1:ny, 1:nz]
        #= none:488 =#
        map((a->begin
                    #= none:488 =#
                    on_architecture(arch, a)
                end), offset_array)
        #= none:490 =#
        return offset_array
    end
#= none:493 =#
function add_halos(data::(AbstractArray{FT, 2} where FT), loc, topo, sz, halo_sz; warnings = true)
    #= none:493 =#
    #= none:494 =#
    (Nx, Ny) = size(data)
    #= none:495 =#
    return add_halos(reshape(data, (Nx, Ny, 1)), loc, topo, sz, halo_sz; warnings)
end