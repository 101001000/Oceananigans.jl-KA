
#= none:1 =#
using Oceananigans.BoundaryConditions: MCBC, DCBC
#= none:2 =#
using Oceananigans.Architectures: on_architecture
#= none:3 =#
using Oceananigans.Grids: halo_size, size
#= none:4 =#
using Oceananigans.Utils: launch!
#= none:5 =#
using KernelAbstractions: @kernel, @index
#= none:7 =#
import Oceananigans.Architectures: on_architecture
#= none:9 =#
struct FieldBoundaryBuffers{W, E, S, N, SW, SE, NW, NE}
    #= none:10 =#
    west::W
    #= none:11 =#
    east::E
    #= none:12 =#
    south::S
    #= none:13 =#
    north::N
    #= none:14 =#
    southwest::SW
    #= none:15 =#
    southeast::SE
    #= none:16 =#
    northwest::NW
    #= none:17 =#
    northeast::NE
end
#= none:20 =#
FieldBoundaryBuffers() = begin
        #= none:20 =#
        nothing
    end
#= none:21 =#
FieldBoundaryBuffers(grid, data, ::Missing) = begin
        #= none:21 =#
        nothing
    end
#= none:22 =#
FieldBoundaryBuffers(grid, data, ::Nothing) = begin
        #= none:22 =#
        nothing
    end
#= none:26 =#
const OneDBuffers = FieldBoundaryBuffers{<:Any, <:Any, <:Any, <:Any, <:Nothing, <:Nothing, <:Nothing, <:Nothing}
#= none:28 =#
function FieldBoundaryBuffers(grid, data, boundary_conditions)
    #= none:28 =#
    #= none:29 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:30 =#
    arch = architecture(grid)
    #= none:32 =#
    (Hx, Hy, Hz) = halo_size(grid)
    #= none:34 =#
    arch = architecture(grid)
    #= none:36 =#
    west = create_buffer_x(architecture(grid), grid, data, Hx, boundary_conditions.west)
    #= none:37 =#
    east = create_buffer_x(architecture(grid), grid, data, Hx, boundary_conditions.east)
    #= none:38 =#
    south = create_buffer_y(architecture(grid), grid, data, Hy, boundary_conditions.south)
    #= none:39 =#
    north = create_buffer_y(architecture(grid), grid, data, Hy, boundary_conditions.north)
    #= none:41 =#
    if hasproperty(arch, :connectivity)
        #= none:42 =#
        sw = create_buffer_corner(arch, grid, data, Hx, Hy, west, south)
        #= none:43 =#
        se = create_buffer_corner(arch, grid, data, Hx, Hy, east, south)
        #= none:44 =#
        nw = create_buffer_corner(arch, grid, data, Hx, Hy, west, north)
        #= none:45 =#
        ne = create_buffer_corner(arch, grid, data, Hx, Hy, east, north)
    else
        #= none:47 =#
        sw = nothing
        #= none:48 =#
        se = nothing
        #= none:49 =#
        nw = nothing
        #= none:50 =#
        ne = nothing
    end
    #= none:53 =#
    return FieldBoundaryBuffers(west, east, south, north, sw, se, nw, ne)
end
#= none:56 =#
create_buffer_x(arch, grid, data, H, bc) = begin
        #= none:56 =#
        nothing
    end
#= none:57 =#
create_buffer_y(arch, grid, data, H, bc) = begin
        #= none:57 =#
        nothing
    end
#= none:61 =#
create_buffer_corner(arch, grid, data, Hx, Hy, edge1, ::Nothing) = begin
        #= none:61 =#
        nothing
    end
#= none:62 =#
create_buffer_corner(arch, grid, data, Hx, Hy, ::Nothing, edge2) = begin
        #= none:62 =#
        nothing
    end
#= none:63 =#
create_buffer_corner(arch, grid, data, Hx, Hy, ::Nothing, ::Nothing) = begin
        #= none:63 =#
        nothing
    end
#= none:65 =#
function create_buffer_corner(arch, grid, data, Hx, Hy, edge1, edge2)
    #= none:65 =#
    #= none:66 =#
    return (send = on_architecture(arch, zeros(eltype(data), Hx, Hy, size(parent(data), 3))), recv = on_architecture(arch, zeros(eltype(data), Hx, Hy, size(parent(data), 3))))
end
#= none:70 =#
function create_buffer_x(arch, grid, data, H, ::DCBC)
    #= none:70 =#
    #= none:72 =#
    size_y = if arch.ranks[2] == 1
            size(parent(data), 2)
        else
            size(grid, 2)
        end
    #= none:73 =#
    return (send = on_architecture(arch, zeros(eltype(data), H, size_y, size(parent(data), 3))), recv = on_architecture(arch, zeros(eltype(data), H, size_y, size(parent(data), 3))))
end
#= none:77 =#
function create_buffer_y(arch, grid, data, H, ::DCBC)
    #= none:77 =#
    #= none:79 =#
    size_x = if arch.ranks[1] == 1
            size(parent(data), 1)
        else
            size(grid, 1)
        end
    #= none:80 =#
    return (send = on_architecture(arch, zeros(eltype(data), size_x, H, size(parent(data), 3))), recv = on_architecture(arch, zeros(eltype(data), size_x, H, size(parent(data), 3))))
end
#= none:84 =#
create_buffer_x(arch, grid, data, H, ::MCBC) = begin
        #= none:84 =#
        (send = on_architecture(arch, zeros(eltype(data), H, size(parent(data), 2), size(parent(data), 3))), recv = on_architecture(arch, zeros(eltype(data), H, size(parent(data), 2), size(parent(data), 3))))
    end
#= none:88 =#
create_buffer_y(arch, grid, data, H, ::MCBC) = begin
        #= none:88 =#
        (send = on_architecture(arch, zeros(eltype(data), size(parent(data), 1), H, size(parent(data), 3))), recv = on_architecture(arch, zeros(eltype(data), size(parent(data), 1), H, size(parent(data), 3))))
    end
#= none:92 =#
Adapt.adapt_structure(to, buff::FieldBoundaryBuffers) = begin
        #= none:92 =#
        FieldBoundaryBuffers(Adapt.adapt(to, buff.west), Adapt.adapt(to, buff.east), Adapt.adapt(to, buff.north), Adapt.adapt(to, buff.south), Adapt.adapt(to, buff.southwest), Adapt.adapt(to, buff.southeast), Adapt.adapt(to, buff.northwest), Adapt.adapt(to, buff.northeast))
    end
#= none:102 =#
on_architecture(arch, buff::FieldBoundaryBuffers) = begin
        #= none:102 =#
        FieldBoundaryBuffers(on_architecture(arch, buff.west), on_architecture(arch, buff.east), on_architecture(arch, buff.north), on_architecture(arch, buff.south), on_architecture(arch, buff.southwest), on_architecture(arch, buff.southeast), on_architecture(arch, buff.northwest), on_architecture(arch, buff.northeast))
    end
#= none:112 =#
#= none:112 =# Core.@doc "    fill_send_buffers!(c::OffsetArray, buffers::FieldBoundaryBuffers, grid)\n\nfills `buffers.send` from OffsetArray `c` preparing for message passing. \n" function fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid)
        #= none:117 =#
        #= none:118 =#
        (Hx, Hy, _) = halo_size(grid)
        #= none:119 =#
        (Nx, Ny, _) = size(grid)
        #= none:121 =#
        _fill_west_send_buffer!(parent(c), buff, buff.west, Hx, Hy, Nx, Ny)
        #= none:122 =#
        _fill_east_send_buffer!(parent(c), buff, buff.east, Hx, Hy, Nx, Ny)
        #= none:123 =#
        _fill_south_send_buffer!(parent(c), buff, buff.south, Hx, Hy, Nx, Ny)
        #= none:124 =#
        _fill_north_send_buffer!(parent(c), buff, buff.north, Hx, Hy, Nx, Ny)
        #= none:126 =#
        _fill_southwest_send_buffer!(parent(c), buff, buff.southwest, Hx, Hy, Nx, Ny)
        #= none:127 =#
        _fill_southeast_send_buffer!(parent(c), buff, buff.southeast, Hx, Hy, Nx, Ny)
        #= none:128 =#
        _fill_northwest_send_buffer!(parent(c), buff, buff.northwest, Hx, Hy, Nx, Ny)
        #= none:129 =#
        _fill_northeast_send_buffer!(parent(c), buff, buff.northeast, Hx, Hy, Nx, Ny)
        #= none:131 =#
        return nothing
    end
#= none:134 =#
function fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:corners})
    #= none:134 =#
    #= none:135 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:136 =#
    (Nx, Ny, _) = size(grid)
    #= none:138 =#
    _fill_southwest_send_buffer!(parent(c), buff, buff.southwest, Hx, Hy, Nx, Ny)
    #= none:139 =#
    _fill_southeast_send_buffer!(parent(c), buff, buff.southeast, Hx, Hy, Nx, Ny)
    #= none:140 =#
    _fill_northwest_send_buffer!(parent(c), buff, buff.northwest, Hx, Hy, Nx, Ny)
    #= none:141 =#
    _fill_northeast_send_buffer!(parent(c), buff, buff.northeast, Hx, Hy, Nx, Ny)
    #= none:143 =#
    return nothing
end
#= none:150 =#
fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:west}) = begin
        #= none:150 =#
        _fill_west_send_buffer!(parent(c), buff, buff.west, (halo_size(grid))[[1, 2]]..., (size(grid))[[1, 2]]...)
    end
#= none:152 =#
fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:east}) = begin
        #= none:152 =#
        _fill_east_send_buffer!(parent(c), buff, buff.east, (halo_size(grid))[[1, 2]]..., (size(grid))[[1, 2]]...)
    end
#= none:154 =#
fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:south}) = begin
        #= none:154 =#
        _fill_south_send_buffer!(parent(c), buff, buff.south, (halo_size(grid))[[1, 2]]..., (size(grid))[[1, 2]]...)
    end
#= none:156 =#
fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:north}) = begin
        #= none:156 =#
        _fill_north_send_buffer!(parent(c), buff, buff.north, (halo_size(grid))[[1, 2]]..., (size(grid))[[1, 2]]...)
    end
#= none:158 =#
fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:bottom}) = begin
        #= none:158 =#
        nothing
    end
#= none:159 =#
fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:top}) = begin
        #= none:159 =#
        nothing
    end
#= none:165 =#
function fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:west_and_east})
    #= none:165 =#
    #= none:166 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:167 =#
    (Nx, Ny, _) = size(grid)
    #= none:169 =#
    _fill_west_send_buffer!(parent(c), buff, buff.west, Hx, Hy, Nx, Ny)
    #= none:170 =#
    _fill_east_send_buffer!(parent(c), buff, buff.east, Hx, Hy, Nx, Ny)
end
#= none:173 =#
function fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:south_and_north})
    #= none:173 =#
    #= none:174 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:175 =#
    (Nx, Ny, _) = size(grid)
    #= none:177 =#
    _fill_south_send_buffer!(parent(c), buff, buff.south, Hx, Hy, Nx, Ny)
    #= none:178 =#
    _fill_north_send_buffer!(parent(c), buff, buff.north, Hx, Hy, Nx, Ny)
end
#= none:181 =#
fill_send_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:bottom_and_top}) = begin
        #= none:181 =#
        nothing
    end
#= none:183 =#
#= none:183 =# Core.@doc "    recv_from_buffers!(c::OffsetArray, buffers::FieldBoundaryBuffers, grid)\n\nfills OffsetArray `c` from `buffers.recv` after message passing occurred. \n" function recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid)
        #= none:188 =#
        #= none:189 =#
        (Hx, Hy, _) = halo_size(grid)
        #= none:190 =#
        (Nx, Ny, _) = size(grid)
        #= none:192 =#
        _recv_from_west_buffer!(parent(c), buff, buff.west, Hx, Hy, Nx, Ny)
        #= none:193 =#
        _recv_from_east_buffer!(parent(c), buff, buff.east, Hx, Hy, Nx, Ny)
        #= none:194 =#
        _recv_from_south_buffer!(parent(c), buff, buff.south, Hx, Hy, Nx, Ny)
        #= none:195 =#
        _recv_from_north_buffer!(parent(c), buff, buff.north, Hx, Hy, Nx, Ny)
        #= none:197 =#
        _recv_from_southwest_buffer!(parent(c), buff, buff.southwest, Hx, Hy, Nx, Ny)
        #= none:198 =#
        _recv_from_southeast_buffer!(parent(c), buff, buff.southeast, Hx, Hy, Nx, Ny)
        #= none:199 =#
        _recv_from_northwest_buffer!(parent(c), buff, buff.northwest, Hx, Hy, Nx, Ny)
        #= none:200 =#
        _recv_from_northeast_buffer!(parent(c), buff, buff.northeast, Hx, Hy, Nx, Ny)
        #= none:202 =#
        return nothing
    end
#= none:205 =#
function recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:corners})
    #= none:205 =#
    #= none:206 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:207 =#
    (Nx, Ny, _) = size(grid)
    #= none:209 =#
    _recv_from_southwest_buffer!(parent(c), buff, buff.southwest, Hx, Hy, Nx, Ny)
    #= none:210 =#
    _recv_from_southeast_buffer!(parent(c), buff, buff.southeast, Hx, Hy, Nx, Ny)
    #= none:211 =#
    _recv_from_northwest_buffer!(parent(c), buff, buff.northwest, Hx, Hy, Nx, Ny)
    #= none:212 =#
    _recv_from_northeast_buffer!(parent(c), buff, buff.northeast, Hx, Hy, Nx, Ny)
    #= none:214 =#
    return nothing
end
#= none:221 =#
recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:west}) = begin
        #= none:221 =#
        _recv_from_west_buffer!(parent(c), buff, buff.west, (halo_size(grid))[[1, 2]]..., (size(grid))[[1, 2]]...)
    end
#= none:223 =#
recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:east}) = begin
        #= none:223 =#
        _recv_from_east_buffer!(parent(c), buff, buff.east, (halo_size(grid))[[1, 2]]..., (size(grid))[[1, 2]]...)
    end
#= none:225 =#
recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:south}) = begin
        #= none:225 =#
        _recv_from_south_buffer!(parent(c), buff, buff.south, (halo_size(grid))[[1, 2]]..., (size(grid))[[1, 2]]...)
    end
#= none:227 =#
recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:north}) = begin
        #= none:227 =#
        _recv_from_north_buffer!(parent(c), buff, buff.north, (halo_size(grid))[[1, 2]]..., (size(grid))[[1, 2]]...)
    end
#= none:229 =#
recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:bottom}) = begin
        #= none:229 =#
        nothing
    end
#= none:230 =#
recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:top}) = begin
        #= none:230 =#
        nothing
    end
#= none:236 =#
function recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:west_and_east})
    #= none:236 =#
    #= none:237 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:238 =#
    (Nx, Ny, _) = size(grid)
    #= none:240 =#
    _recv_from_west_buffer!(parent(c), buff, buff.west, Hx, Hy, Nx, Ny)
    #= none:241 =#
    _recv_from_east_buffer!(parent(c), buff, buff.east, Hx, Hy, Nx, Ny)
    #= none:243 =#
    return nothing
end
#= none:246 =#
function recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:south_and_north})
    #= none:246 =#
    #= none:247 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:248 =#
    (Nx, Ny, _) = size(grid)
    #= none:250 =#
    _recv_from_south_buffer!(parent(c), buff, buff.south, Hx, Hy, Nx, Ny)
    #= none:251 =#
    _recv_from_north_buffer!(parent(c), buff, buff.north, Hx, Hy, Nx, Ny)
    #= none:253 =#
    return nothing
end
#= none:256 =#
recv_from_buffers!(c::OffsetArray, buff::FieldBoundaryBuffers, grid, ::Val{:bottom_and_top}) = begin
        #= none:256 =#
        nothing
    end
#= none:262 =#
for dir = (:west, :east, :south, :north, :southwest, :southeast, :northwest, :northeast)
    #= none:263 =#
    _fill_send_buffer! = Symbol(:_fill_, dir, :_send_buffer!)
    #= none:264 =#
    _recv_from_buffer! = Symbol(:_recv_from_, dir, :_buffer!)
    #= none:266 =#
    #= none:266 =# @eval $_fill_send_buffer!(c, b, ::Nothing, args...) = begin
                #= none:266 =#
                nothing
            end
    #= none:267 =#
    #= none:267 =# @eval $_recv_from_buffer!(c, b, ::Nothing, args...) = begin
                #= none:267 =#
                nothing
            end
    #= none:268 =#
    #= none:268 =# @eval $_fill_send_buffer!(c, ::OneDBuffers, ::Nothing, args...) = begin
                #= none:268 =#
                nothing
            end
    #= none:269 =#
    #= none:269 =# @eval $_recv_from_buffer!(c, ::OneDBuffers, ::Nothing, args...) = begin
                #= none:269 =#
                nothing
            end
    #= none:270 =#
end
#= none:276 =#
_fill_west_send_buffer!(c, ::OneDBuffers, buff, Hx, Hy, Nx, Ny) = begin
        #= none:276 =#
        buff.send .= view(c, 1 + Hx:2Hx, :, :)
    end
#= none:277 =#
_fill_east_send_buffer!(c, ::OneDBuffers, buff, Hx, Hy, Nx, Ny) = begin
        #= none:277 =#
        buff.send .= view(c, 1 + Nx:Nx + Hx, :, :)
    end
#= none:278 =#
_fill_south_send_buffer!(c, ::OneDBuffers, buff, Hx, Hy, Nx, Ny) = begin
        #= none:278 =#
        buff.send .= view(c, :, 1 + Hy:2Hy, :)
    end
#= none:279 =#
_fill_north_send_buffer!(c, ::OneDBuffers, buff, Hx, Hy, Nx, Ny) = begin
        #= none:279 =#
        buff.send .= view(c, :, 1 + Ny:Ny + Hy, :)
    end
#= none:281 =#
_recv_from_west_buffer!(c, ::OneDBuffers, buff, Hx, Hy, Nx, Ny) = begin
        #= none:281 =#
        view(c, 1:Hx, :, :) .= buff.recv
    end
#= none:282 =#
_recv_from_east_buffer!(c, ::OneDBuffers, buff, Hx, Hy, Nx, Ny) = begin
        #= none:282 =#
        view(c, 1 + Nx + Hx:Nx + 2Hx, :, :) .= buff.recv
    end
#= none:283 =#
_recv_from_south_buffer!(c, ::OneDBuffers, buff, Hx, Hy, Nx, Ny) = begin
        #= none:283 =#
        view(c, :, 1:Hy, :) .= buff.recv
    end
#= none:284 =#
_recv_from_north_buffer!(c, ::OneDBuffers, buff, Hx, Hy, Nx, Ny) = begin
        #= none:284 =#
        view(c, :, 1 + Ny + Hy:Ny + 2Hy, :) .= buff.recv
    end
#= none:290 =#
_fill_west_send_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:290 =#
        buff.send .= view(c, 1 + Hx:2Hx, 1 + Hy:Ny + Hy, :)
    end
#= none:291 =#
_fill_east_send_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:291 =#
        buff.send .= view(c, 1 + Nx:Nx + Hx, 1 + Hy:Ny + Hy, :)
    end
#= none:292 =#
_fill_south_send_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:292 =#
        buff.send .= view(c, 1 + Hx:Nx + Hx, 1 + Hy:2Hy, :)
    end
#= none:293 =#
_fill_north_send_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:293 =#
        buff.send .= view(c, 1 + Hx:Nx + Hx, 1 + Ny:Ny + Hy, :)
    end
#= none:295 =#
_recv_from_west_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:295 =#
        view(c, 1:Hx, 1 + Hy:Ny + Hy, :) .= buff.recv
    end
#= none:296 =#
_recv_from_east_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:296 =#
        view(c, 1 + Nx + Hx:Nx + 2Hx, 1 + Hy:Ny + Hy, :) .= buff.recv
    end
#= none:297 =#
_recv_from_south_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:297 =#
        view(c, 1 + Hx:Nx + Hx, 1:Hy, :) .= buff.recv
    end
#= none:298 =#
_recv_from_north_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:298 =#
        view(c, 1 + Hx:Nx + Hx, 1 + Ny + Hy:Ny + 2Hy, :) .= buff.recv
    end
#= none:300 =#
_fill_southwest_send_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:300 =#
        buff.send .= view(c, 1 + Hx:2Hx, 1 + Hy:2Hy, :)
    end
#= none:301 =#
_fill_southeast_send_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:301 =#
        buff.send .= view(c, 1 + Nx:Nx + Hx, 1 + Hy:2Hy, :)
    end
#= none:302 =#
_fill_northwest_send_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:302 =#
        buff.send .= view(c, 1 + Hx:2Hx, 1 + Ny:Ny + Hy, :)
    end
#= none:303 =#
_fill_northeast_send_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:303 =#
        buff.send .= view(c, 1 + Nx:Nx + Hx, 1 + Ny:Ny + Hy, :)
    end
#= none:305 =#
_recv_from_southwest_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:305 =#
        view(c, 1:Hx, 1:Hy, :) .= buff.recv
    end
#= none:306 =#
_recv_from_southeast_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:306 =#
        view(c, 1 + Nx + Hx:Nx + 2Hx, 1:Hy, :) .= buff.recv
    end
#= none:307 =#
_recv_from_northwest_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:307 =#
        view(c, 1:Hx, 1 + Ny + Hy:Ny + 2Hy, :) .= buff.recv
    end
#= none:308 =#
_recv_from_northeast_buffer!(c, b, buff, Hx, Hy, Nx, Ny) = begin
        #= none:308 =#
        view(c, 1 + Nx + Hx:Nx + 2Hx, 1 + Ny + Hy:Ny + 2Hy, :) .= buff.recv
    end
#= none:311 =#
replace_horizontal_vector_halos!(vel, grid::AbstractGrid; signed = true) = begin
        #= none:311 =#
        nothing
    end