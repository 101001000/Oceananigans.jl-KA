
#= none:1 =#
using Oceananigans: instantiated_location
#= none:2 =#
using Oceananigans.Architectures: on_architecture, device_copy_to!
#= none:3 =#
using Oceananigans.Operators: assumed_field_location
#= none:4 =#
using Oceananigans.Fields: reduced_dimensions
#= none:5 =#
using Oceananigans.DistributedComputations: communication_side
#= none:7 =#
using Oceananigans.BoundaryConditions: ContinuousBoundaryFunction, DiscreteBoundaryFunction, permute_boundary_conditions, extract_west_bc, extract_east_bc, extract_south_bc, extract_north_bc, extract_top_bc, extract_bottom_bc, fill_halo_event!, MCBCT, MCBC, fill_open_boundary_regions!
#= none:18 =#
import Oceananigans.Fields: tupled_fill_halo_regions!, boundary_conditions, data, fill_send_buffers!
#= none:20 =#
import Oceananigans.BoundaryConditions: fill_halo_regions!, fill_west_and_east_halo!, fill_south_and_north_halo!, fill_bottom_and_top_halo!, fill_west_halo!, fill_east_halo!, fill_south_halo!, fill_north_halo!
#= none:30 =#
#= none:30 =# @inline bc_str(::MultiRegionObject) = begin
            #= none:30 =#
            "MultiRegion Boundary Conditions"
        end
#= none:32 =#
#= none:32 =# @inline extract_field_buffers(field::Field) = begin
            #= none:32 =#
            field.boundary_buffers
        end
#= none:33 =#
#= none:33 =# @inline boundary_conditions(field::MultiRegionField) = begin
            #= none:33 =#
            field.boundary_conditions
        end
#= none:36 =#
#= none:36 =# @inline function tupled_fill_halo_regions!(full_fields, grid::MultiRegionGrids, args...; kwargs...)
        #= none:36 =#
        #= none:37 =#
        for field = full_fields
            #= none:38 =#
            fill_halo_regions!(field, args...; kwargs...)
            #= none:39 =#
        end
    end
#= none:42 =#
function fill_halo_regions!(field::MultiRegionField, args...; kwargs...)
    #= none:42 =#
    #= none:43 =#
    reduced_dims = reduced_dimensions(field)
    #= none:45 =#
    return fill_halo_regions!(field.data, field.boundary_conditions, field.indices, instantiated_location(field), field.grid, field.boundary_buffers, args...; reduced_dimensions = reduced_dims, kwargs...)
end
#= none:56 =#
fill_halo_regions!(c::MultiRegionObject, ::Nothing, args...; kwargs...) = begin
        #= none:56 =#
        nothing
    end
#= none:72 =#
extract_west_or_east_bc(bc) = begin
        #= none:72 =#
        max(bc.west, bc.east)
    end
#= none:73 =#
extract_south_or_north_bc(bc) = begin
        #= none:73 =#
        max(bc.south, bc.north)
    end
#= none:74 =#
extract_bottom_or_top_bc(bc) = begin
        #= none:74 =#
        max(bc.bottom, bc.top)
    end
#= none:76 =#
function multi_region_permute_boundary_conditions(bcs)
    #= none:76 =#
    #= none:77 =#
    fill_halos! = [fill_west_and_east_halo!, fill_south_and_north_halo!, fill_bottom_and_top_halo!]
    #= none:83 =#
    boundary_conditions_array = [extract_west_or_east_bc(bcs), extract_south_or_north_bc(bcs), extract_bottom_or_top_bc(bcs)]
    #= none:89 =#
    boundary_conditions = [(extract_west_bc(bcs), extract_east_bc(bcs)), (extract_south_bc(bcs), extract_north_bc(bcs)), (extract_bottom_bc(bcs), extract_top_bc(bcs))]
    #= none:95 =#
    perm = sortperm(boundary_conditions_array)
    #= none:96 =#
    fill_halos! = fill_halos![perm]
    #= none:97 =#
    boundary_conditions = boundary_conditions[perm]
    #= none:99 =#
    return (fill_halos!, boundary_conditions)
end
#= none:102 =#
function fill_halo_regions!(c::MultiRegionObject, bcs, indices, loc, mrg::MultiRegionGrid, buffers, args...; fill_boundary_normal_velocities = true, kwargs...)
    #= none:102 =#
    #= none:103 =#
    arch = architecture(mrg)
    #= none:104 =#
    #= none:104 =# @apply_regionally (fill_halos!, bcs) = multi_region_permute_boundary_conditions(bcs)
    #= none:109 =#
    for task = 1:3
        #= none:110 =#
        #= none:110 =# @apply_regionally begin
                #= none:111 =#
                bcs_side = getindex(bcs, task)
                #= none:112 =#
                fill_halo_side! = getindex(fill_halos!, task)
                #= none:113 =#
                fill_multiregion_send_buffers!(c, buffers, mrg, bcs_side)
            end
        #= none:116 =#
        buff = Reference(buffers.regional_objects)
        #= none:118 =#
        if fill_boundary_normal_velocities
            #= none:119 =#
            apply_regionally!(fill_open_boundary_regions!, c, bcs_side, indices, loc, mrg, args...)
        end
        #= none:122 =#
        apply_regionally!(fill_halo_event!, c, fill_halo_side!, bcs_side, indices, loc, arch, mrg, buff, args...; kwargs...)
        #= none:126 =#
    end
    #= none:128 =#
    return nothing
end
#= none:132 =#
function fill_multiregion_send_buffers!(c, buffers, grid, bcs)
    #= none:132 =#
    #= none:134 =#
    if !(isempty(filter((x->begin
                            #= none:134 =#
                            x isa MCBCT
                        end), bcs)))
        #= none:135 =#
        fill_send_buffers!(c, buffers, grid)
    end
    #= none:138 =#
    return nothing
end
#= none:146 =#
for (lside, rside) = zip([:west, :south, :bottom], [:east, :north, :top])
    #= none:147 =#
    fill_both_halo! = Symbol(:fill_, lside, :_and_, rside, :_halo!)
    #= none:148 =#
    fill_left_halo! = Symbol(:fill_, lside, :_halo!)
    #= none:149 =#
    fill_right_halo! = Symbol(:fill_, rside, :_halo!)
    #= none:151 =#
    #= none:151 =# @eval begin
            #= none:152 =#
            function $fill_both_halo!(c, left_bc::MCBC, right_bc, kernel_size, offset, loc, arch, grid, buffers, args...; kwargs...)
                #= none:152 =#
                #= none:153 =#
                $fill_right_halo!(c, right_bc, kernel_size, offset, loc, arch, grid, args...; kwargs...)
                #= none:154 =#
                $fill_left_halo!(c, left_bc, kernel_size, offset, loc, arch, grid, buffers, args...; kwargs...)
                #= none:155 =#
                return nothing
            end
            #= none:158 =#
            function $fill_both_halo!(c, left_bc, right_bc::MCBC, kernel_size, offset, loc, arch, grid, buffers, args...; kwargs...)
                #= none:158 =#
                #= none:159 =#
                $fill_left_halo!(c, left_bc, kernel_size, offset, loc, arch, grid, args...; kwargs...)
                #= none:160 =#
                $fill_right_halo!(c, right_bc, kernel_size, offset, loc, arch, grid, buffers, args...; kwargs...)
                #= none:161 =#
                return nothing
            end
        end
    #= none:164 =#
end
#= none:166 =#
getside(x, ::North) = begin
        #= none:166 =#
        x.north
    end
#= none:167 =#
getside(x, ::South) = begin
        #= none:167 =#
        x.south
    end
#= none:168 =#
getside(x, ::West) = begin
        #= none:168 =#
        x.west
    end
#= none:169 =#
getside(x, ::East) = begin
        #= none:169 =#
        x.east
    end
#= none:171 =#
function fill_west_and_east_halo!(c, westbc::MCBC, eastbc::MCBC, kernel_size, offset, loc, arch, grid, buffers, args...; kwargs...)
    #= none:171 =#
    #= none:172 =#
    H = (halo_size(grid))[1]
    #= none:173 =#
    N = (size(grid))[1]
    #= none:175 =#
    westdst = (buffers[westbc.condition.rank]).west.recv
    #= none:176 =#
    eastdst = (buffers[eastbc.condition.rank]).east.recv
    #= none:178 =#
    westsrc = (getside(buffers[westbc.condition.from_rank], westbc.condition.from_side)).send
    #= none:179 =#
    eastsrc = (getside(buffers[eastbc.condition.from_rank], eastbc.condition.from_side)).send
    #= none:181 =#
    devicewest = getdevice(westsrc)
    #= none:182 =#
    deviceeast = getdevice(eastsrc)
    #= none:184 =#
    switch_device!(devicewest)
    #= none:185 =#
    westsrc = flip_west_and_east_indices(westsrc, loc[1], westbc.condition)
    #= none:187 =#
    switch_device!(deviceeast)
    #= none:188 =#
    eastsrc = flip_west_and_east_indices(eastsrc, loc[1], eastbc.condition)
    #= none:190 =#
    switch_device!(getdevice(c))
    #= none:191 =#
    device_copy_to!(westdst, westsrc)
    #= none:192 =#
    device_copy_to!(eastdst, eastsrc)
    #= none:194 =#
    if loc[2] == Face() && westbc.condition isa NonTrivialConnectivity
        #= none:195 =#
        (Mx, My, _) = size(parent(c))
        #= none:196 =#
        view(parent(c), 1:H, 2:My, :) .= view(westdst, :, 1:My - 1, :)
    else
        #= none:198 =#
        view(parent(c), 1:H, :, :) .= westdst
    end
    #= none:201 =#
    if loc[2] == Face() && eastbc.condition isa NonTrivialConnectivity
        #= none:202 =#
        (Mx, My, _) = size(parent(c))
        #= none:203 =#
        view(parent(c), N + 1 + H:N + 2H, 2:My, :) .= view(eastdst, :, 1:My - 1, :)
    else
        #= none:205 =#
        view(parent(c), N + H + 1:N + 2H, :, :) .= eastdst
    end
    #= none:208 =#
    return nothing
end
#= none:211 =#
function fill_south_and_north_halo!(c, southbc::MCBC, northbc::MCBC, kernel_size, offset, loc, arch, grid, buffers, args...; kwargs...)
    #= none:211 =#
    #= none:212 =#
    H = (halo_size(grid))[2]
    #= none:213 =#
    N = (size(grid))[2]
    #= none:215 =#
    southdst = (buffers[southbc.condition.rank]).south.recv
    #= none:216 =#
    northdst = (buffers[northbc.condition.rank]).north.recv
    #= none:218 =#
    southsrc = (getside(buffers[southbc.condition.from_rank], southbc.condition.from_side)).send
    #= none:219 =#
    northsrc = (getside(buffers[northbc.condition.from_rank], northbc.condition.from_side)).send
    #= none:221 =#
    devicesouth = getdevice(southsrc)
    #= none:222 =#
    devicenorth = getdevice(northsrc)
    #= none:224 =#
    switch_device!(devicesouth)
    #= none:225 =#
    southsrc = flip_south_and_north_indices(southsrc, loc[2], southbc.condition)
    #= none:227 =#
    switch_device!(devicenorth)
    #= none:228 =#
    northsrc = flip_south_and_north_indices(northsrc, loc[2], northbc.condition)
    #= none:230 =#
    switch_device!(getdevice(c))
    #= none:231 =#
    device_copy_to!(southdst, southsrc)
    #= none:232 =#
    device_copy_to!(northdst, northsrc)
    #= none:234 =#
    if loc[1] == Face() && southbc.condition isa NonTrivialConnectivity
        #= none:235 =#
        (Mx, My, _) = size(parent(c))
        #= none:236 =#
        view(parent(c), 2:Mx, 1:H, :) .= view(southdst, 1:Mx - 1, :, :)
    else
        #= none:238 =#
        view(parent(c), :, 1:H, :) .= southdst
    end
    #= none:241 =#
    if loc[1] == Face() && (loc[2] == Face() && northbc.condition isa NonTrivialConnectivity)
        #= none:242 =#
        (Mx, My, _) = size(parent(c))
        #= none:243 =#
        view(parent(c), 2:Mx, N + H + 1:N + 2H, :) .= view(northdst, 1:Mx - 1, :, :)
    elseif #= none:244 =# loc[1] == Face() && (loc[2] == Center() && northbc.condition isa NonTrivialConnectivity)
        #= none:245 =#
        (Mx, My, _) = size(parent(c))
        #= none:246 =#
        view(parent(c), :, N + H + 1:N + 2H, :) .= view(northdst, :, :, :)
    else
        #= none:248 =#
        view(parent(c), :, N + H + 1:N + 2H, :) .= northdst
    end
    #= none:251 =#
    return nothing
end
#= none:261 =#
function fill_west_halo!(c, bc::MCBC, kernel_size, offset, loc, arch, grid, buffers, args...; kwargs...)
    #= none:261 =#
    #= none:262 =#
    H = (halo_size(grid))[1]
    #= none:263 =#
    N = (size(grid))[1]
    #= none:265 =#
    dst = (buffers[bc.condition.rank]).west.recv
    #= none:266 =#
    src = (getside(buffers[bc.condition.from_rank], bc.condition.from_side)).send
    #= none:268 =#
    dev = getdevice(src)
    #= none:269 =#
    switch_device!(dev)
    #= none:270 =#
    src = flip_west_and_east_indices(src, loc[1], bc.condition)
    #= none:272 =#
    switch_device!(getdevice(c))
    #= none:273 =#
    device_copy_to!(dst, src)
    #= none:275 =#
    p = view(parent(c), 1:H, :, :)
    #= none:276 =#
    p .= dst
    #= none:278 =#
    return nothing
end
#= none:281 =#
function fill_east_halo!(c, bc::MCBC, kernel_size, offset, loc, arch, grid, buffers, args...; kwargs...)
    #= none:281 =#
    #= none:282 =#
    H = (halo_size(grid))[1]
    #= none:283 =#
    N = (size(grid))[1]
    #= none:285 =#
    dst = (buffers[bc.condition.rank]).east.recv
    #= none:286 =#
    src = (getside(buffers[bc.condition.from_rank], bc.condition.from_side)).send
    #= none:288 =#
    dev = getdevice(src)
    #= none:289 =#
    switch_device!(dev)
    #= none:290 =#
    src = flip_west_and_east_indices(src, loc[1], bc.condition)
    #= none:292 =#
    switch_device!(getdevice(c))
    #= none:293 =#
    device_copy_to!(dst, src)
    #= none:295 =#
    p = view(parent(c), N + H + 1:N + 2H, :, :)
    #= none:296 =#
    p .= dst
    #= none:298 =#
    return nothing
end
#= none:301 =#
function fill_south_halo!(c, bc::MCBC, kernel_size, offset, loc, arch, grid, buffers, args...; kwargs...)
    #= none:301 =#
    #= none:302 =#
    H = (halo_size(grid))[2]
    #= none:303 =#
    N = (size(grid))[2]
    #= none:305 =#
    dst = (buffers[bc.condition.rank]).south.recv
    #= none:306 =#
    src = (getside(buffers[bc.condition.from_rank], bc.condition.from_side)).send
    #= none:308 =#
    dev = getdevice(src)
    #= none:309 =#
    switch_device!(dev)
    #= none:310 =#
    src = flip_south_and_north_indices(src, loc[2], bc.condition)
    #= none:312 =#
    switch_device!(getdevice(c))
    #= none:313 =#
    device_copy_to!(dst, src)
    #= none:315 =#
    p = view(parent(c), :, 1:H, :)
    #= none:316 =#
    p .= dst
    #= none:318 =#
    return nothing
end
#= none:321 =#
function fill_north_halo!(c, bc::MCBC, kernel_size, offset, loc, arch, grid, buffers, args...; kwargs...)
    #= none:321 =#
    #= none:322 =#
    H = (halo_size(grid))[2]
    #= none:323 =#
    N = (size(grid))[2]
    #= none:325 =#
    dst = (buffers[bc.condition.rank]).north.recv
    #= none:326 =#
    src = (getside(buffers[bc.condition.from_rank], bc.condition.from_side)).send
    #= none:328 =#
    dev = getdevice(src)
    #= none:329 =#
    switch_device!(dev)
    #= none:330 =#
    src = flip_south_and_north_indices(src, loc[2], bc.condition)
    #= none:332 =#
    switch_device!(getdevice(c))
    #= none:333 =#
    device_copy_to!(dst, src)
    #= none:335 =#
    p = view(parent(c), :, N + H + 1:N + 2H, :)
    #= none:337 =#
    if loc[1] == Center()
        #= none:338 =#
        p .= dst
    elseif #= none:339 =# loc[1] == Face()
        #= none:340 =#
        (Mx, My, _) = size(p)
        #= none:341 =#
        view(p, 2:My, :, :) .= view(dst, 1:My - 1, :, :)
    end
    #= none:344 =#
    return nothing
end
#= none:351 =#
#= none:351 =# @inline getregion(fc::FieldBoundaryConditions, i) = begin
            #= none:351 =#
            FieldBoundaryConditions(_getregion(fc.west, i), _getregion(fc.east, i), _getregion(fc.south, i), _getregion(fc.north, i), _getregion(fc.bottom, i), _getregion(fc.top, i), fc.immersed)
        end
#= none:360 =#
#= none:360 =# @inline getregion(bc::BoundaryCondition, i) = begin
            #= none:360 =#
            BoundaryCondition(bc.classification, _getregion(bc.condition, i))
        end
#= none:362 =#
#= none:362 =# @inline (getregion(cf::ContinuousBoundaryFunction{X, Y, Z, I}, i) where {X, Y, Z, I}) = begin
            #= none:362 =#
            ContinuousBoundaryFunction{X, Y, Z, I}(cf.func::F, _getregion(cf.parameters, i), cf.field_dependencies, cf.field_dependencies_indices, cf.field_dependencies_interp)
        end
#= none:369 =#
#= none:369 =# @inline getregion(df::DiscreteBoundaryFunction, i) = begin
            #= none:369 =#
            DiscreteBoundaryFunction(df.func, _getregion(df.parameters, i))
        end
#= none:372 =#
#= none:372 =# @inline _getregion(fc::FieldBoundaryConditions, i) = begin
            #= none:372 =#
            FieldBoundaryConditions(getregion(fc.west, i), getregion(fc.east, i), getregion(fc.south, i), getregion(fc.north, i), getregion(fc.bottom, i), getregion(fc.top, i), fc.immersed)
        end
#= none:381 =#
#= none:381 =# @inline _getregion(bc::BoundaryCondition, i) = begin
            #= none:381 =#
            BoundaryCondition(bc.classification, getregion(bc.condition, i))
        end
#= none:383 =#
#= none:383 =# @inline (_getregion(cf::ContinuousBoundaryFunction{X, Y, Z, I}, i) where {X, Y, Z, I}) = begin
            #= none:383 =#
            ContinuousBoundaryFunction{X, Y, Z, I}(cf.func::F, getregion(cf.parameters, i), cf.field_dependencies, cf.field_dependencies_indices, cf.field_dependencies_interp)
        end
#= none:390 =#
#= none:390 =# @inline _getregion(df::DiscreteBoundaryFunction, i) = begin
            #= none:390 =#
            DiscreteBoundaryFunction(df.func, getregion(df.parameters, i))
        end
#= none:393 =#
validate_boundary_condition_location(::MultiRegionObject, ::Center, side) = begin
        #= none:393 =#
        nothing
    end
#= none:394 =#
validate_boundary_condition_location(::MultiRegionObject, ::Face, side) = begin
        #= none:394 =#
        nothing
    end
#= none:396 =#
validate_boundary_condition_topology(::MultiRegionObject, ::Periodic, side) = begin
        #= none:396 =#
        nothing
    end
#= none:397 =#
validate_boundary_condition_topology(::MultiRegionObject, ::Flat, side) = begin
        #= none:397 =#
        nothing
    end
#= none:399 =#
inject_west_boundary(connectivity, global_bc) = begin
        #= none:399 =#
        if connectivity.west === nothing
            global_bc
        else
            MultiRegionCommunicationBoundaryCondition(connectivity.west)
        end
    end
#= none:400 =#
inject_east_boundary(connectivity, global_bc) = begin
        #= none:400 =#
        if connectivity.east === nothing
            global_bc
        else
            MultiRegionCommunicationBoundaryCondition(connectivity.east)
        end
    end
#= none:401 =#
inject_south_boundary(connectivity, global_bc) = begin
        #= none:401 =#
        if connectivity.south === nothing
            global_bc
        else
            MultiRegionCommunicationBoundaryCondition(connectivity.south)
        end
    end
#= none:402 =#
inject_north_boundary(connectivity, global_bc) = begin
        #= none:402 =#
        if connectivity.north === nothing
            global_bc
        else
            MultiRegionCommunicationBoundaryCondition(connectivity.north)
        end
    end