
#= none:1 =#
using KernelAbstractions: @kernel, @index
#= none:2 =#
using OffsetArrays: OffsetArray
#= none:4 =#
using Oceananigans.Fields: fill_send_buffers!, recv_from_buffers!, reduced_dimensions, instantiated_location
#= none:9 =#
import Oceananigans.Fields: tupled_fill_halo_regions!
#= none:11 =#
using Oceananigans.BoundaryConditions: fill_halo_size, fill_halo_offset, permute_boundary_conditions, fill_open_boundary_regions!, PBCT, DCBCT, DCBC
#= none:18 =#
import Oceananigans.BoundaryConditions: fill_halo_regions!, fill_first, fill_halo_event!, fill_west_halo!, fill_east_halo!, fill_south_halo!, fill_north_halo!, fill_bottom_halo!, fill_top_halo!, fill_west_and_east_halo!, fill_south_and_north_halo!, fill_bottom_and_top_halo!
#= none:30 =#
sides = (:west, :east, :south, :north, :southwest, :southeast, :northwest, :northeast)
#= none:31 =#
side_id = Dict((side => n - 1 for (n, side) = enumerate(sides)))
#= none:33 =#
opposite_side = Dict(:west => :east, :east => :west, :south => :north, :north => :south, :southwest => :northeast, :southeast => :northwest, :northwest => :southeast, :northeast => :southwest)
#= none:49 =#
ID_DIGITS = 2
#= none:51 =#
#= none:51 =# @inline loc_id(::Face) = begin
            #= none:51 =#
            0
        end
#= none:52 =#
#= none:52 =# @inline loc_id(::Center) = begin
            #= none:52 =#
            1
        end
#= none:53 =#
#= none:53 =# @inline loc_id(::Nothing) = begin
            #= none:53 =#
            2
        end
#= none:54 =#
#= none:54 =# @inline loc_id(LX, LY, LZ) = begin
            #= none:54 =#
            loc_id(LZ)
        end
#= none:56 =#
for side = sides
    #= none:57 =#
    side_str = string(side)
    #= none:58 =#
    send_tag_fn_name = Symbol("$(side)_send_tag")
    #= none:59 =#
    recv_tag_fn_name = Symbol("$(side)_recv_tag")
    #= none:60 =#
    #= none:60 =# @eval begin
            #= none:61 =#
            function $send_tag_fn_name(arch, location)
                #= none:61 =#
                #= none:62 =#
                field_id = string(arch.mpi_tag[], pad = ID_DIGITS)
                #= none:63 =#
                loc_digit = string(loc_id(location...))
                #= none:64 =#
                side_digit = string(side_id[Symbol($side_str)])
                #= none:65 =#
                return parse(Int, field_id * loc_digit * side_digit)
            end
            #= none:68 =#
            function $recv_tag_fn_name(arch, location)
                #= none:68 =#
                #= none:69 =#
                field_id = string(arch.mpi_tag[], pad = ID_DIGITS)
                #= none:70 =#
                loc_digit = string(loc_id(location...))
                #= none:71 =#
                side_digit = string(side_id[opposite_side[Symbol($side_str)]])
                #= none:72 =#
                return parse(Int, field_id * loc_digit * side_digit)
            end
        end
    #= none:75 =#
end
#= none:81 =#
function tupled_fill_halo_regions!(full_fields, grid::DistributedGrid, args...; kwargs...)
    #= none:81 =#
    #= none:82 =#
    for field = full_fields
        #= none:83 =#
        fill_halo_regions!(field, args...; kwargs...)
        #= none:84 =#
    end
end
#= none:87 =#
function fill_halo_regions!(field::DistributedField, args...; kwargs...)
    #= none:87 =#
    #= none:88 =#
    reduced_dims = reduced_dimensions(field)
    #= none:90 =#
    return fill_halo_regions!(field.data, field.boundary_conditions, field.indices, instantiated_location(field), field.grid, field.boundary_buffers, args...; reduced_dimensions = reduced_dims, kwargs...)
end
#= none:101 =#
function fill_halo_regions!(c::OffsetArray, bcs, indices, loc, grid::DistributedGrid, buffers, args...; fill_boundary_normal_velocities = true, kwargs...)
    #= none:101 =#
    #= none:102 =#
    if fill_boundary_normal_velocities
        #= none:103 =#
        fill_open_boundary_regions!(c, bcs, indices, loc, grid, args...; kwargs...)
    end
    #= none:106 =#
    arch = architecture(grid)
    #= none:107 =#
    (fill_halos!, bcs) = permute_boundary_conditions(bcs)
    #= none:109 =#
    number_of_tasks = length(fill_halos!)
    #= none:111 =#
    for task = 1:number_of_tasks
        #= none:112 =#
        fill_halo_event!(c, fill_halos![task], bcs[task], indices, loc, arch, grid, buffers, args...; kwargs...)
        #= none:113 =#
    end
    #= none:115 =#
    fill_corners!(c, arch.connectivity, indices, loc, arch, grid, buffers, args...; kwargs...)
    #= none:118 =#
    arch.mpi_tag[] += 1
    #= none:120 =#
    return nothing
end
#= none:123 =#
#= none:123 =# @inline function pool_requests_or_complete_comm!(c, arch, grid, buffers, requests, async, side)
        #= none:123 =#
        #= none:126 =#
        if isnothing(requests)
            #= none:127 =#
            return nothing
        end
        #= none:132 =#
        if async && !(arch isa SynchronizedDistributed)
            #= none:133 =#
            push!(arch.mpi_requests, requests...)
            #= none:134 =#
            return nothing
        end
        #= none:138 =#
        cooperative_waitall!(requests)
        #= none:140 =#
        arch.mpi_tag[] -= arch.mpi_tag[]
        #= none:142 =#
        recv_from_buffers!(c, buffers, grid, Val(side))
        #= none:144 =#
        return nothing
    end
#= none:148 =#
function fill_corners!(c, connectivity, indices, loc, arch, grid, buffers, args...; async = false, only_local_halos = false, kwargs...)
    #= none:148 =#
    #= none:151 =#
    only_local_halos && return nothing
    #= none:154 =#
    fill_send_buffers!(c, buffers, grid, Val(:corners))
    #= none:155 =#
    sync_device!(arch)
    #= none:157 =#
    requests = MPI.Request[]
    #= none:159 =#
    reqsw = fill_southwest_halo!(c, connectivity.southwest, indices, loc, arch, grid, buffers, buffers.southwest, args...; kwargs...)
    #= none:160 =#
    reqse = fill_southeast_halo!(c, connectivity.southeast, indices, loc, arch, grid, buffers, buffers.southeast, args...; kwargs...)
    #= none:161 =#
    reqnw = fill_northwest_halo!(c, connectivity.northwest, indices, loc, arch, grid, buffers, buffers.northwest, args...; kwargs...)
    #= none:162 =#
    reqne = fill_northeast_halo!(c, connectivity.northeast, indices, loc, arch, grid, buffers, buffers.northeast, args...; kwargs...)
    #= none:164 =#
    !(isnothing(reqsw)) && push!(requests, reqsw...)
    #= none:165 =#
    !(isnothing(reqse)) && push!(requests, reqse...)
    #= none:166 =#
    !(isnothing(reqnw)) && push!(requests, reqnw...)
    #= none:167 =#
    !(isnothing(reqne)) && push!(requests, reqne...)
    #= none:169 =#
    pool_requests_or_complete_comm!(c, arch, grid, buffers, requests, async, :corners)
    #= none:171 =#
    return nothing
end
#= none:174 =#
#= none:174 =# @inline communication_side(::Val{fill_west_and_east_halo!}) = begin
            #= none:174 =#
            :west_and_east
        end
#= none:175 =#
#= none:175 =# @inline communication_side(::Val{fill_south_and_north_halo!}) = begin
            #= none:175 =#
            :south_and_north
        end
#= none:176 =#
#= none:176 =# @inline communication_side(::Val{fill_bottom_and_top_halo!}) = begin
            #= none:176 =#
            :bottom_and_top
        end
#= none:177 =#
#= none:177 =# @inline communication_side(::Val{fill_west_halo!}) = begin
            #= none:177 =#
            :west
        end
#= none:178 =#
#= none:178 =# @inline communication_side(::Val{fill_east_halo!}) = begin
            #= none:178 =#
            :east
        end
#= none:179 =#
#= none:179 =# @inline communication_side(::Val{fill_south_halo!}) = begin
            #= none:179 =#
            :south
        end
#= none:180 =#
#= none:180 =# @inline communication_side(::Val{fill_north_halo!}) = begin
            #= none:180 =#
            :north
        end
#= none:181 =#
#= none:181 =# @inline communication_side(::Val{fill_bottom_halo!}) = begin
            #= none:181 =#
            :bottom
        end
#= none:182 =#
#= none:182 =# @inline communication_side(::Val{fill_top_halo!}) = begin
            #= none:182 =#
            :top
        end
#= none:184 =#
cooperative_wait(req::MPI.Request) = begin
        #= none:184 =#
        MPI.Waitall(req)
    end
#= none:185 =#
cooperative_waitall!(req::Array{MPI.Request}) = begin
        #= none:185 =#
        MPI.Waitall(req)
    end
#= none:190 =#
function fill_halo_event!(c, fill_halos!, bcs, indices, loc, arch, grid::DistributedGrid, buffers, args...; async = false, only_local_halos = false, kwargs...)
    #= none:190 =#
    #= none:192 =#
    buffer_side = communication_side(Val(fill_halos!))
    #= none:194 =#
    if !only_local_halos
        #= none:195 =#
        fill_send_buffers!(c, buffers, grid, Val(buffer_side))
    end
    #= none:201 =#
    size = fill_halo_size(c, fill_halos!, indices, bcs[1], loc, grid)
    #= none:202 =#
    offset = fill_halo_offset(size, fill_halos!, indices)
    #= none:204 =#
    requests = fill_halos!(c, bcs..., size, offset, loc, arch, grid, buffers, args...; only_local_halos, kwargs...)
    #= none:206 =#
    pool_requests_or_complete_comm!(c, arch, grid, buffers, requests, async, buffer_side)
    #= none:208 =#
    return nothing
end
#= none:215 =#
for side = [:southwest, :southeast, :northwest, :northeast]
    #= none:216 =#
    fill_corner_halo! = Symbol("fill_$(side)_halo!")
    #= none:217 =#
    send_side_halo = Symbol("send_$(side)_halo")
    #= none:218 =#
    recv_and_fill_side_halo! = Symbol("recv_and_fill_$(side)_halo!")
    #= none:220 =#
    #= none:220 =# @eval begin
            #= none:221 =#
            $fill_corner_halo!(c, corner, indices, loc, arch, grid, buffers, ::Nothing, args...; kwargs...) = begin
                    #= none:221 =#
                    nothing
                end
            #= none:223 =#
            function $fill_corner_halo!(c, corner, indices, loc, arch, grid, buffers, sd, args...; kwargs...)
                #= none:223 =#
                #= none:224 =#
                child_arch = child_architecture(arch)
                #= none:225 =#
                local_rank = arch.local_rank
                #= none:227 =#
                recv_req = $recv_and_fill_side_halo!(c, grid, arch, loc, local_rank, corner, buffers)
                #= none:228 =#
                send_req = $send_side_halo(c, grid, arch, loc, local_rank, corner, buffers)
                #= none:230 =#
                return [send_req, recv_req]
            end
        end
    #= none:233 =#
end
#= none:239 =#
for (side, opposite_side) = zip([:west, :south], [:east, :north])
    #= none:240 =#
    fill_both_halo! = Symbol("fill_$(side)_and_$(opposite_side)_halo!")
    #= none:241 =#
    send_side_halo = Symbol("send_$(side)_halo")
    #= none:242 =#
    send_opposite_side_halo = Symbol("send_$(opposite_side)_halo")
    #= none:243 =#
    recv_and_fill_side_halo! = Symbol("recv_and_fill_$(side)_halo!")
    #= none:244 =#
    recv_and_fill_opposite_side_halo! = Symbol("recv_and_fill_$(opposite_side)_halo!")
    #= none:246 =#
    #= none:246 =# @eval begin
            #= none:247 =#
            function $fill_both_halo!(c, bc_side::DCBCT, bc_opposite_side::DCBCT, size, offset, loc, arch::Distributed, grid::DistributedGrid, buffers, args...; only_local_halos = false, kwargs...)
                #= none:247 =#
                #= none:250 =#
                only_local_halos && return nothing
                #= none:252 =#
                sync_device!(arch)
                #= none:254 =#
                #= none:254 =# @assert bc_side.condition.from == bc_opposite_side.condition.from
                #= none:255 =#
                local_rank = bc_side.condition.from
                #= none:257 =#
                recv_req1 = $recv_and_fill_side_halo!(c, grid, arch, loc, local_rank, bc_side.condition.to, buffers)
                #= none:258 =#
                recv_req2 = $recv_and_fill_opposite_side_halo!(c, grid, arch, loc, local_rank, bc_opposite_side.condition.to, buffers)
                #= none:260 =#
                send_req1 = $send_side_halo(c, grid, arch, loc, local_rank, bc_side.condition.to, buffers)
                #= none:261 =#
                send_req2 = $send_opposite_side_halo(c, grid, arch, loc, local_rank, bc_opposite_side.condition.to, buffers)
                #= none:263 =#
                return [send_req1, send_req2, recv_req1, recv_req2]
            end
        end
    #= none:266 =#
end
#= none:272 =#
for side = [:west, :east, :south, :north]
    #= none:273 =#
    fill_side_halo! = Symbol("fill_$(side)_halo!")
    #= none:274 =#
    send_side_halo = Symbol("send_$(side)_halo")
    #= none:275 =#
    recv_and_fill_side_halo! = Symbol("recv_and_fill_$(side)_halo!")
    #= none:277 =#
    #= none:277 =# @eval begin
            #= none:278 =#
            function $fill_side_halo!(c, bc_side::DCBCT, size, offset, loc, arch::Distributed, grid::DistributedGrid, buffers, args...; only_local_halos = false, kwargs...)
                #= none:278 =#
                #= none:281 =#
                only_local_halos && return nothing
                #= none:283 =#
                sync_device!(arch)
                #= none:285 =#
                child_arch = child_architecture(arch)
                #= none:286 =#
                local_rank = bc_side.condition.from
                #= none:288 =#
                recv_req = $recv_and_fill_side_halo!(c, grid, arch, loc, local_rank, bc_side.condition.to, buffers)
                #= none:289 =#
                send_req = $send_side_halo(c, grid, arch, loc, local_rank, bc_side.condition.to, buffers)
                #= none:291 =#
                return [send_req, recv_req]
            end
        end
    #= none:294 =#
end
#= none:300 =#
for side = sides
    #= none:301 =#
    side_str = string(side)
    #= none:302 =#
    send_side_halo = Symbol("send_$(side)_halo")
    #= none:303 =#
    underlying_side_boundary = Symbol("underlying_$(side)_boundary")
    #= none:304 =#
    side_send_tag = Symbol("$(side)_send_tag")
    #= none:305 =#
    get_side_send_buffer = Symbol("get_$(side)_send_buffer")
    #= none:307 =#
    #= none:307 =# @eval begin
            #= none:308 =#
            function $send_side_halo(c, grid, arch, location, local_rank, rank_to_send_to, buffers)
                #= none:308 =#
                #= none:309 =#
                send_buffer = $get_side_send_buffer(c, grid, buffers, arch)
                #= none:310 =#
                send_tag = $side_send_tag(arch, location)
                #= none:312 =#
                #= none:312 =# @debug "Sending " * $side_str * " halo: local_rank=$(local_rank), rank_to_send_to=$(rank_to_send_to), send_tag=$(send_tag)"
                #= none:314 =#
                send_req = MPI.Isend(send_buffer, rank_to_send_to, send_tag, arch.communicator)
                #= none:316 =#
                return send_req
            end
            #= none:319 =#
            #= none:319 =# @inline $get_side_send_buffer(c, grid, buffers, arch) = begin
                        #= none:319 =#
                        buffers.$(side).send
                    end
        end
    #= none:321 =#
end
#= none:327 =#
for side = sides
    #= none:328 =#
    side_str = string(side)
    #= none:329 =#
    recv_and_fill_side_halo! = Symbol("recv_and_fill_$(side)_halo!")
    #= none:330 =#
    underlying_side_halo = Symbol("underlying_$(side)_halo")
    #= none:331 =#
    side_recv_tag = Symbol("$(side)_recv_tag")
    #= none:332 =#
    get_side_recv_buffer = Symbol("get_$(side)_recv_buffer")
    #= none:334 =#
    #= none:334 =# @eval begin
            #= none:335 =#
            function $recv_and_fill_side_halo!(c, grid, arch, location, local_rank, rank_to_recv_from, buffers)
                #= none:335 =#
                #= none:336 =#
                recv_buffer = $get_side_recv_buffer(c, grid, buffers, arch)
                #= none:337 =#
                recv_tag = $side_recv_tag(arch, location)
                #= none:339 =#
                #= none:339 =# @debug "Receiving " * $side_str * " halo: local_rank=$(local_rank), rank_to_recv_from=$(rank_to_recv_from), recv_tag=$(recv_tag)"
                #= none:340 =#
                recv_req = MPI.Irecv!(recv_buffer, rank_to_recv_from, recv_tag, arch.communicator)
                #= none:342 =#
                return recv_req
            end
            #= none:345 =#
            #= none:345 =# @inline $get_side_recv_buffer(c, grid, buffers, arch) = begin
                        #= none:345 =#
                        buffers.$(side).recv
                    end
        end
    #= none:347 =#
end