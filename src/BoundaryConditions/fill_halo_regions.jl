
#= none:1 =#
using OffsetArrays: OffsetArray
#= none:2 =#
using Oceananigans.Utils
#= none:3 =#
using Oceananigans.Grids: architecture
#= none:5 =#
import Base
#= none:11 =#
fill_halo_regions!(::Nothing, args...; kwargs...) = begin
        #= none:11 =#
        nothing
    end
#= none:12 =#
fill_halo_regions!(::NamedTuple{(), Tuple{}}, args...; kwargs...) = begin
        #= none:12 =#
        nothing
    end
#= none:14 =#
"    fill_halo_regions!(fields::Union{Tuple, NamedTuple}, arch, args...)\n\nFill halo regions for each field in the tuple `fields` according to their boundary\nconditions, possibly recursing into `fields` if it is a nested tuple-of-tuples.\n"
#= none:21 =#
fill_halo_regions!(c::OffsetArray, ::Nothing, args...; kwargs...) = begin
        #= none:21 =#
        nothing
    end
#= none:25 =#
for dir = (:west, :east, :south, :north, :bottom, :top)
    #= none:26 =#
    extract_side_bc = Symbol(:extract_, dir, :_bc)
    #= none:27 =#
    #= none:27 =# @eval begin
            #= none:28 =#
            #= none:28 =# @inline $extract_side_bc(bc) = begin
                        #= none:28 =#
                        bc.$(dir)
                    end
            #= none:29 =#
            #= none:29 =# @inline $extract_side_bc(bc::Tuple) = begin
                        #= none:29 =#
                        map($extract_side_bc, bc)
                    end
        end
    #= none:31 =#
end
#= none:33 =#
#= none:33 =# @inline extract_bc(bc, ::Val{:west}) = begin
            #= none:33 =#
            tuple(extract_west_bc(bc))
        end
#= none:34 =#
#= none:34 =# @inline extract_bc(bc, ::Val{:east}) = begin
            #= none:34 =#
            tuple(extract_east_bc(bc))
        end
#= none:35 =#
#= none:35 =# @inline extract_bc(bc, ::Val{:south}) = begin
            #= none:35 =#
            tuple(extract_south_bc(bc))
        end
#= none:36 =#
#= none:36 =# @inline extract_bc(bc, ::Val{:north}) = begin
            #= none:36 =#
            tuple(extract_north_bc(bc))
        end
#= none:37 =#
#= none:37 =# @inline extract_bc(bc, ::Val{:bottom}) = begin
            #= none:37 =#
            tuple(extract_bottom_bc(bc))
        end
#= none:38 =#
#= none:38 =# @inline extract_bc(bc, ::Val{:top}) = begin
            #= none:38 =#
            tuple(extract_top_bc(bc))
        end
#= none:40 =#
#= none:40 =# @inline extract_bc(bc, ::Val{:west_and_east}) = begin
            #= none:40 =#
            (extract_west_bc(bc), extract_east_bc(bc))
        end
#= none:41 =#
#= none:41 =# @inline extract_bc(bc, ::Val{:south_and_north}) = begin
            #= none:41 =#
            (extract_south_bc(bc), extract_north_bc(bc))
        end
#= none:42 =#
#= none:42 =# @inline extract_bc(bc, ::Val{:bottom_and_top}) = begin
            #= none:42 =#
            (extract_bottom_bc(bc), extract_top_bc(bc))
        end
#= none:45 =#
const MaybeTupledData = Union{OffsetArray, NTuple{<:Any, OffsetArray}}
#= none:47 =#
#= none:47 =# Core.@doc "Fill halo regions in ``x``, ``y``, and ``z`` for a given field's data." function fill_halo_regions!(c::MaybeTupledData, boundary_conditions, indices, loc, grid, args...; fill_boundary_normal_velocities = true, kwargs...)
        #= none:48 =#
        #= none:50 =#
        arch = architecture(grid)
        #= none:52 =#
        if fill_boundary_normal_velocities
            #= none:53 =#
            fill_open_boundary_regions!(c, boundary_conditions, indices, loc, grid, args...; kwargs...)
        end
        #= none:56 =#
        (fill_halos!, bcs) = permute_boundary_conditions(boundary_conditions)
        #= none:57 =#
        number_of_tasks = length(fill_halos!)
        #= none:60 =#
        for task = 1:number_of_tasks
            #= none:61 =#
            fill_halo_event!(c, fill_halos![task], bcs[task], indices, loc, arch, grid, args...; kwargs...)
            #= none:62 =#
        end
        #= none:64 =#
        return nothing
    end
#= none:67 =#
function fill_halo_event!(c, fill_halos!, bcs, indices, loc, arch, grid, args...; kwargs...)
    #= none:67 =#
    #= none:72 =#
    size = fill_halo_size(c, fill_halos!, indices, bcs[1], loc, grid)
    #= none:73 =#
    offset = fill_halo_offset(size, fill_halos!, indices)
    #= none:75 =#
    fill_halos!(c, bcs..., size, offset, loc, arch, grid, args...; kwargs...)
    #= none:77 =#
    return nothing
end
#= none:85 =#
function permute_boundary_conditions(boundary_conditions)
    #= none:85 =#
    #= none:87 =#
    split_x_halo_filling = split_halo_filling(extract_west_bc(boundary_conditions), extract_east_bc(boundary_conditions))
    #= none:88 =#
    split_y_halo_filling = split_halo_filling(extract_south_bc(boundary_conditions), extract_north_bc(boundary_conditions))
    #= none:90 =#
    west_bc = extract_west_bc(boundary_conditions)
    #= none:91 =#
    east_bc = extract_east_bc(boundary_conditions)
    #= none:92 =#
    south_bc = extract_south_bc(boundary_conditions)
    #= none:93 =#
    north_bc = extract_north_bc(boundary_conditions)
    #= none:95 =#
    if split_x_halo_filling
        #= none:96 =#
        if split_y_halo_filling
            #= none:97 =#
            fill_halos! = [fill_west_halo!, fill_east_halo!, fill_south_halo!, fill_north_halo!, fill_bottom_and_top_halo!]
            #= none:98 =#
            sides = [:west, :east, :south, :north, :bottom_and_top]
            #= none:99 =#
            bcs_array = [west_bc, east_bc, south_bc, north_bc, extract_bottom_bc(boundary_conditions)]
        else
            #= none:101 =#
            fill_halos! = [fill_west_halo!, fill_east_halo!, fill_south_and_north_halo!, fill_bottom_and_top_halo!]
            #= none:102 =#
            sides = [:west, :east, :south_and_north, :bottom_and_top]
            #= none:103 =#
            bcs_array = [west_bc, east_bc, south_bc, extract_bottom_bc(boundary_conditions)]
        end
    else
        #= none:106 =#
        if split_y_halo_filling
            #= none:107 =#
            fill_halos! = [fill_west_and_east_halo!, fill_south_halo!, fill_north_halo!, fill_bottom_and_top_halo!]
            #= none:108 =#
            sides = [:west_and_east, :south, :north, :bottom_and_top]
            #= none:109 =#
            bcs_array = [west_bc, south_bc, north_bc, extract_bottom_bc(boundary_conditions)]
        else
            #= none:111 =#
            fill_halos! = [fill_west_and_east_halo!, fill_south_and_north_halo!, fill_bottom_and_top_halo!]
            #= none:112 =#
            sides = [:west_and_east, :south_and_north, :bottom_and_top]
            #= none:113 =#
            bcs_array = [west_bc, south_bc, extract_bottom_bc(boundary_conditions)]
        end
    end
    #= none:117 =#
    perm = sortperm(bcs_array, lt = fill_first)
    #= none:118 =#
    fill_halos! = fill_halos![perm]
    #= none:119 =#
    sides = sides[perm]
    #= none:121 =#
    boundary_conditions = Tuple((extract_bc(boundary_conditions, Val(side)) for side = sides))
    #= none:123 =#
    return (fill_halos!, boundary_conditions)
end
#= none:128 =#
split_halo_filling(bcs1, bcs2) = begin
        #= none:128 =#
        false
    end
#= none:129 =#
split_halo_filling(::DCBC, ::DCBC) = begin
        #= none:129 =#
        false
    end
#= none:130 =#
split_halo_filling(bcs1, ::DCBC) = begin
        #= none:130 =#
        true
    end
#= none:131 =#
split_halo_filling(::DCBC, bcs2) = begin
        #= none:131 =#
        true
    end
#= none:144 =#
const PBCT = Union{PBC, NTuple{<:Any, <:PBC}}
#= none:145 =#
const MCBCT = Union{MCBC, NTuple{<:Any, <:MCBC}}
#= none:146 =#
const DCBCT = Union{DCBC, NTuple{<:Any, <:DCBC}}
#= none:168 =#
#= none:168 =# @inline Base.isless(bc1::BoundaryCondition, bc2::BoundaryCondition) = begin
            #= none:168 =#
            fill_first(bc1, bc2)
        end
#= none:171 =#
#= none:171 =# @inline Base.isless(::Nothing, ::Nothing) = begin
            #= none:171 =#
            true
        end
#= none:172 =#
#= none:172 =# @inline Base.isless(::BoundaryCondition, ::Nothing) = begin
            #= none:172 =#
            false
        end
#= none:173 =#
#= none:173 =# @inline Base.isless(::Nothing, ::BoundaryCondition) = begin
            #= none:173 =#
            true
        end
#= none:174 =#
#= none:174 =# @inline Base.isless(::BoundaryCondition, ::Missing) = begin
            #= none:174 =#
            false
        end
#= none:175 =#
#= none:175 =# @inline Base.isless(::Missing, ::BoundaryCondition) = begin
            #= none:175 =#
            true
        end
#= none:177 =#
fill_first(bc1::DCBCT, bc2) = begin
        #= none:177 =#
        false
    end
#= none:178 =#
fill_first(bc1::PBCT, bc2::DCBCT) = begin
        #= none:178 =#
        true
    end
#= none:179 =#
fill_first(bc1::DCBCT, bc2::PBCT) = begin
        #= none:179 =#
        false
    end
#= none:180 =#
fill_first(bc1::MCBCT, bc2::DCBCT) = begin
        #= none:180 =#
        true
    end
#= none:181 =#
fill_first(bc1::DCBCT, bc2::MCBCT) = begin
        #= none:181 =#
        false
    end
#= none:182 =#
fill_first(bc1, bc2::DCBCT) = begin
        #= none:182 =#
        true
    end
#= none:183 =#
fill_first(bc1::DCBCT, bc2::DCBCT) = begin
        #= none:183 =#
        true
    end
#= none:184 =#
fill_first(bc1::PBCT, bc2) = begin
        #= none:184 =#
        false
    end
#= none:185 =#
fill_first(bc1::MCBCT, bc2) = begin
        #= none:185 =#
        false
    end
#= none:186 =#
fill_first(bc1::PBCT, bc2::MCBCT) = begin
        #= none:186 =#
        true
    end
#= none:187 =#
fill_first(bc1::MCBCT, bc2::PBCT) = begin
        #= none:187 =#
        false
    end
#= none:188 =#
fill_first(bc1, bc2::PBCT) = begin
        #= none:188 =#
        true
    end
#= none:189 =#
fill_first(bc1, bc2::MCBCT) = begin
        #= none:189 =#
        true
    end
#= none:190 =#
fill_first(bc1::PBCT, bc2::PBCT) = begin
        #= none:190 =#
        true
    end
#= none:191 =#
fill_first(bc1::MCBCT, bc2::MCBCT) = begin
        #= none:191 =#
        true
    end
#= none:192 =#
fill_first(bc1, bc2) = begin
        #= none:192 =#
        true
    end
#= none:198 =#
#= none:198 =# @kernel function _fill_west_and_east_halo!(c, west_bc, east_bc, loc, grid, args)
        #= none:198 =#
        #= none:199 =#
        (j, k) = #= none:199 =# @index(Global, NTuple)
        #= none:200 =#
        _fill_west_halo!(j, k, grid, c, west_bc, loc, args...)
        #= none:201 =#
        _fill_east_halo!(j, k, grid, c, east_bc, loc, args...)
    end
#= none:204 =#
#= none:204 =# @kernel function _fill_south_and_north_halo!(c, south_bc, north_bc, loc, grid, args)
        #= none:204 =#
        #= none:205 =#
        (i, k) = #= none:205 =# @index(Global, NTuple)
        #= none:206 =#
        _fill_south_halo!(i, k, grid, c, south_bc, loc, args...)
        #= none:207 =#
        _fill_north_halo!(i, k, grid, c, north_bc, loc, args...)
    end
#= none:210 =#
#= none:210 =# @kernel function _fill_bottom_and_top_halo!(c, bottom_bc, top_bc, loc, grid, args)
        #= none:210 =#
        #= none:211 =#
        (i, j) = #= none:211 =# @index(Global, NTuple)
        #= none:212 =#
        _fill_bottom_halo!(i, j, grid, c, bottom_bc, loc, args...)
        #= none:213 =#
        _fill_top_halo!(i, j, grid, c, top_bc, loc, args...)
    end
#= none:220 =#
#= none:220 =# @kernel function _fill_only_west_halo!(c, bc, loc, grid, args)
        #= none:220 =#
        #= none:221 =#
        (j, k) = #= none:221 =# @index(Global, NTuple)
        #= none:222 =#
        _fill_west_halo!(j, k, grid, c, bc, loc, args...)
    end
#= none:225 =#
#= none:225 =# @kernel function _fill_only_south_halo!(c, bc, loc, grid, args)
        #= none:225 =#
        #= none:226 =#
        (i, k) = #= none:226 =# @index(Global, NTuple)
        #= none:227 =#
        _fill_south_halo!(i, k, grid, c, bc, loc, args...)
    end
#= none:230 =#
#= none:230 =# @kernel function _fill_only_bottom_halo!(c, bc, loc, grid, args)
        #= none:230 =#
        #= none:231 =#
        (i, j) = #= none:231 =# @index(Global, NTuple)
        #= none:232 =#
        _fill_bottom_halo!(i, j, grid, c, bc, loc, args...)
    end
#= none:235 =#
#= none:235 =# @kernel function _fill_only_east_halo!(c, bc, loc, grid, args)
        #= none:235 =#
        #= none:236 =#
        (j, k) = #= none:236 =# @index(Global, NTuple)
        #= none:237 =#
        _fill_east_halo!(j, k, grid, c, bc, loc, args...)
    end
#= none:240 =#
#= none:240 =# @kernel function _fill_only_north_halo!(c, bc, loc, grid, args)
        #= none:240 =#
        #= none:241 =#
        (i, k) = #= none:241 =# @index(Global, NTuple)
        #= none:242 =#
        _fill_north_halo!(i, k, grid, c, bc, loc, args...)
    end
#= none:245 =#
#= none:245 =# @kernel function _fill_only_top_halo!(c, bc, loc, grid, args)
        #= none:245 =#
        #= none:246 =#
        (i, j) = #= none:246 =# @index(Global, NTuple)
        #= none:247 =#
        _fill_top_halo!(i, j, grid, c, bc, loc, args...)
    end
#= none:256 =#
import Oceananigans.Utils: @constprop
#= none:258 =#
#= none:258 =# @kernel function _fill_west_and_east_halo!(c::NTuple, west_bc, east_bc, loc, grid, args)
        #= none:258 =#
        #= none:259 =#
        (j, k) = #= none:259 =# @index(Global, NTuple)
        #= none:260 =#
        ntuple(Val(length(west_bc))) do n
            #= none:261 =#
            #= none:261 =# Base.@_inline_meta
            #= none:262 =#
            #= none:262 =# @constprop :aggressive
            #= none:263 =#
            #= none:263 =# @inbounds begin
                    #= none:264 =#
                    _fill_west_halo!(j, k, grid, c[n], west_bc[n], loc[n], args...)
                    #= none:265 =#
                    _fill_east_halo!(j, k, grid, c[n], east_bc[n], loc[n], args...)
                end
        end
    end
#= none:270 =#
#= none:270 =# @kernel function _fill_south_and_north_halo!(c::NTuple, south_bc, north_bc, loc, grid, args)
        #= none:270 =#
        #= none:271 =#
        (i, k) = #= none:271 =# @index(Global, NTuple)
        #= none:272 =#
        ntuple(Val(length(south_bc))) do n
            #= none:273 =#
            #= none:273 =# Base.@_inline_meta
            #= none:274 =#
            #= none:274 =# @constprop :aggressive
            #= none:275 =#
            #= none:275 =# @inbounds begin
                    #= none:276 =#
                    _fill_south_halo!(i, k, grid, c[n], south_bc[n], loc[n], args...)
                    #= none:277 =#
                    _fill_north_halo!(i, k, grid, c[n], north_bc[n], loc[n], args...)
                end
        end
    end
#= none:282 =#
#= none:282 =# @kernel function _fill_bottom_and_top_halo!(c::NTuple, bottom_bc, top_bc, loc, grid, args)
        #= none:282 =#
        #= none:283 =#
        (i, j) = #= none:283 =# @index(Global, NTuple)
        #= none:284 =#
        ntuple(Val(length(bottom_bc))) do n
            #= none:285 =#
            #= none:285 =# Base.@_inline_meta
            #= none:286 =#
            #= none:286 =# @constprop :aggressive
            #= none:287 =#
            #= none:287 =# @inbounds begin
                    #= none:288 =#
                    _fill_bottom_halo!(i, j, grid, c[n], bottom_bc[n], loc[n], args...)
                    #= none:289 =#
                    _fill_top_halo!(i, j, grid, c[n], top_bc[n], loc[n], args...)
                end
        end
    end
#= none:298 =#
fill_west_halo!(c, bc, size, offset, loc, arch, grid, args...; kwargs...) = begin
        #= none:298 =#
        launch!(arch, grid, KernelParameters(size, offset), _fill_only_west_halo!, c, bc, loc, grid, Tuple(args); kwargs...)
    end
#= none:302 =#
fill_east_halo!(c, bc, size, offset, loc, arch, grid, args...; kwargs...) = begin
        #= none:302 =#
        launch!(arch, grid, KernelParameters(size, offset), _fill_only_east_halo!, c, bc, loc, grid, Tuple(args); kwargs...)
    end
#= none:306 =#
fill_south_halo!(c, bc, size, offset, loc, arch, grid, args...; kwargs...) = begin
        #= none:306 =#
        launch!(arch, grid, KernelParameters(size, offset), _fill_only_south_halo!, c, bc, loc, grid, Tuple(args); kwargs...)
    end
#= none:310 =#
fill_north_halo!(c, bc, size, offset, loc, arch, grid, args...; kwargs...) = begin
        #= none:310 =#
        launch!(arch, grid, KernelParameters(size, offset), _fill_only_north_halo!, c, bc, loc, grid, Tuple(args); kwargs...)
    end
#= none:314 =#
fill_bottom_halo!(c, bc, size, offset, loc, arch, grid, args...; kwargs...) = begin
        #= none:314 =#
        launch!(arch, grid, KernelParameters(size, offset), _fill_only_bottom_halo!, c, bc, loc, grid, Tuple(args); kwargs...)
    end
#= none:318 =#
fill_top_halo!(c, bc, size, offset, loc, arch, grid, args...; kwargs...) = begin
        #= none:318 =#
        launch!(arch, grid, KernelParameters(size, offset), _fill_only_top_halo!, c, bc, loc, grid, Tuple(args); kwargs...)
    end
#= none:326 =#
function fill_west_and_east_halo!(c, west_bc, east_bc, size, offset, loc, arch, grid, args...; kwargs...)
    #= none:326 =#
    #= none:327 =#
    return launch!(arch, grid, KernelParameters(size, offset), _fill_west_and_east_halo!, c, west_bc, east_bc, loc, grid, Tuple(args); kwargs...)
end
#= none:331 =#
function fill_south_and_north_halo!(c, south_bc, north_bc, size, offset, loc, arch, grid, args...; kwargs...)
    #= none:331 =#
    #= none:332 =#
    return launch!(arch, grid, KernelParameters(size, offset), _fill_south_and_north_halo!, c, south_bc, north_bc, loc, grid, Tuple(args); kwargs...)
end
#= none:336 =#
function fill_bottom_and_top_halo!(c, bottom_bc, top_bc, size, offset, loc, arch, grid, args...; kwargs...)
    #= none:336 =#
    #= none:337 =#
    return launch!(arch, grid, KernelParameters(size, offset), _fill_bottom_and_top_halo!, c, bottom_bc, top_bc, loc, grid, Tuple(args); kwargs...)
end
#= none:345 =#
const WEB = Union{typeof(fill_west_and_east_halo!), typeof(fill_west_halo!), typeof(fill_east_halo!)}
#= none:346 =#
const SNB = Union{typeof(fill_south_and_north_halo!), typeof(fill_south_halo!), typeof(fill_north_halo!)}
#= none:347 =#
const TBB = Union{typeof(fill_bottom_and_top_halo!), typeof(fill_bottom_halo!), typeof(fill_top_halo!)}
#= none:350 =#
#= none:350 =# @inline fill_halo_size(::Tuple, ::WEB, args...) = begin
            #= none:350 =#
            :yz
        end
#= none:351 =#
#= none:351 =# @inline fill_halo_size(::Tuple, ::SNB, args...) = begin
            #= none:351 =#
            :xz
        end
#= none:352 =#
#= none:352 =# @inline fill_halo_size(::Tuple, ::TBB, args...) = begin
            #= none:352 =#
            :xy
        end
#= none:357 =#
#= none:357 =# @inline fill_halo_size(::OffsetArray, ::WEB, ::Tuple{<:Any, <:Colon, <:Colon}, args...) = begin
            #= none:357 =#
            :yz
        end
#= none:358 =#
#= none:358 =# @inline fill_halo_size(::OffsetArray, ::SNB, ::Tuple{<:Colon, <:Any, <:Colon}, args...) = begin
            #= none:358 =#
            :xz
        end
#= none:359 =#
#= none:359 =# @inline fill_halo_size(::OffsetArray, ::TBB, ::Tuple{<:Colon, <:Colon, <:Any}, args...) = begin
            #= none:359 =#
            :xy
        end
#= none:363 =#
#= none:363 =# @inline whole_halo(idx, loc) = begin
            #= none:363 =#
            false
        end
#= none:364 =#
#= none:364 =# @inline whole_halo(idx, ::Nothing) = begin
            #= none:364 =#
            false
        end
#= none:365 =#
#= none:365 =# @inline whole_halo(::Colon, ::Nothing) = begin
            #= none:365 =#
            false
        end
#= none:366 =#
#= none:366 =# @inline whole_halo(::Colon, loc) = begin
            #= none:366 =#
            true
        end
#= none:371 =#
#= none:371 =# @inline function fill_halo_size(c::OffsetArray, ::WEB, idx, bc, loc, grid)
        #= none:371 =#
        #= none:372 =#
        #= none:372 =# @inbounds begin
                #= none:373 =#
                whole_y_halo = whole_halo(idx[2], loc[2])
                #= none:374 =#
                whole_z_halo = whole_halo(idx[3], loc[3])
            end
        #= none:377 =#
        (_, Ny, Nz) = size(grid)
        #= none:378 =#
        (_, Cy, Cz) = size(c)
        #= none:380 =#
        Sy = ifelse(whole_y_halo, Ny, Cy)
        #= none:381 =#
        Sz = ifelse(whole_z_halo, Nz, Cz)
        #= none:383 =#
        return (Sy, Sz)
    end
#= none:386 =#
#= none:386 =# @inline function fill_halo_size(c::OffsetArray, ::SNB, idx, bc, loc, grid)
        #= none:386 =#
        #= none:387 =#
        #= none:387 =# @inbounds begin
                #= none:388 =#
                whole_x_halo = whole_halo(idx[1], loc[1])
                #= none:389 =#
                whole_z_halo = whole_halo(idx[3], loc[3])
            end
        #= none:392 =#
        (Nx, _, Nz) = size(grid)
        #= none:393 =#
        (Cx, _, Cz) = size(c)
        #= none:395 =#
        Sx = ifelse(whole_x_halo, Nx, Cx)
        #= none:396 =#
        Sz = ifelse(whole_z_halo, Nz, Cz)
        #= none:398 =#
        return (Sx, Sz)
    end
#= none:401 =#
#= none:401 =# @inline function fill_halo_size(c::OffsetArray, ::TBB, idx, bc, loc, grid)
        #= none:401 =#
        #= none:402 =#
        #= none:402 =# @inbounds begin
                #= none:403 =#
                whole_x_halo = whole_halo(idx[1], loc[1])
                #= none:404 =#
                whole_y_halo = whole_halo(idx[2], loc[2])
            end
        #= none:407 =#
        (Nx, Ny, _) = size(grid)
        #= none:408 =#
        (Cx, Cy, _) = size(c)
        #= none:410 =#
        Sx = ifelse(whole_x_halo, Nx, Cx)
        #= none:411 =#
        Sy = ifelse(whole_y_halo, Ny, Cy)
        #= none:413 =#
        return (Sx, Sy)
    end
#= none:417 =#
#= none:417 =# @inline fill_halo_size(c::OffsetArray, ::WEB, idx, ::PBC, args...) = begin
            #= none:417 =#
            tuple(size(c, 2), size(c, 3))
        end
#= none:418 =#
#= none:418 =# @inline fill_halo_size(c::OffsetArray, ::SNB, idx, ::PBC, args...) = begin
            #= none:418 =#
            tuple(size(c, 1), size(c, 3))
        end
#= none:419 =#
#= none:419 =# @inline fill_halo_size(c::OffsetArray, ::TBB, idx, ::PBC, args...) = begin
            #= none:419 =#
            tuple(size(c, 1), size(c, 2))
        end
#= none:421 =#
#= none:421 =# @inline function fill_halo_size(c::OffsetArray, ::WEB, ::Tuple{<:Any, <:Colon, <:Colon}, ::PBC, args...)
        #= none:421 =#
        #= none:422 =#
        (_, Cy, Cz) = size(c)
        #= none:423 =#
        return (Cy, Cz)
    end
#= none:426 =#
#= none:426 =# @inline function fill_halo_size(c::OffsetArray, ::SNB, ::Tuple{<:Colon, <:Any, <:Colon}, ::PBC, args...)
        #= none:426 =#
        #= none:427 =#
        (Cx, _, Cz) = size(c)
        #= none:428 =#
        return (Cx, Cz)
    end
#= none:431 =#
#= none:431 =# @inline function fill_halo_size(c::OffsetArray, ::TBB, ::Tuple{<:Colon, <:Colon, <:Any}, ::PBC, args...)
        #= none:431 =#
        #= none:432 =#
        (Cx, Cy, _) = size(c)
        #= none:433 =#
        return (Cx, Cy)
    end
#= none:437 =#
#= none:437 =# @inline fill_halo_offset(::Symbol, args...) = begin
            #= none:437 =#
            (0, 0)
        end
#= none:438 =#
#= none:438 =# @inline fill_halo_offset(::Tuple, ::WEB, idx) = begin
            #= none:438 =#
            (if idx[2] == Colon()
                    0
                else
                    first(idx[2]) - 1
                end, if idx[3] == Colon()
                    0
                else
                    first(idx[3]) - 1
                end)
        end
#= none:439 =#
#= none:439 =# @inline fill_halo_offset(::Tuple, ::SNB, idx) = begin
            #= none:439 =#
            (if idx[1] == Colon()
                    0
                else
                    first(idx[1]) - 1
                end, if idx[3] == Colon()
                    0
                else
                    first(idx[3]) - 1
                end)
        end
#= none:440 =#
#= none:440 =# @inline fill_halo_offset(::Tuple, ::TBB, idx) = begin
            #= none:440 =#
            (if idx[1] == Colon()
                    0
                else
                    first(idx[1]) - 1
                end, if idx[2] == Colon()
                    0
                else
                    first(idx[2]) - 1
                end)
        end