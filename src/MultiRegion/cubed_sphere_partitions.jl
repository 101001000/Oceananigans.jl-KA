
#= none:1 =#
using Oceananigans.Grids: cpu_face_constructor_x, cpu_face_constructor_y, cpu_face_constructor_z, default_indices
#= none:3 =#
using DocStringExtensions
#= none:5 =#
import Oceananigans.Fields: replace_horizontal_vector_halos!
#= none:7 =#
struct CubedSpherePartition{M, P} <: AbstractPartition
    #= none:8 =#
    div::Int
    #= none:9 =#
    Rx::M
    #= none:10 =#
    Ry::P
    #= none:12 =#
    (CubedSpherePartition(div, Rx::M, Ry::P) where {M, P}) = begin
            #= none:12 =#
            new{M, P}(div, Rx, Ry)
        end
end
#= none:15 =#
#= none:15 =# Core.@doc "    CubedSpherePartition(; R = 1)\n\nReturn a cubed sphere partition with `R` partitions in each horizontal dimension of each\npanel of the sphere.\n" function CubedSpherePartition(; R = 1)
        #= none:21 =#
        #= none:23 =#
        Rx = (Ry = R)
        #= none:25 =#
        if R isa Number
            #= none:26 =#
            div = 6 * R ^ 2
        else
            #= none:28 =#
            div = sum(R .* R)
        end
        #= none:31 =#
        #= none:31 =# @assert mod(div, 6) == 0 "Total number of regions (div = $(div)) must be a multiple of 6 for a cubed sphere partition."
        #= none:33 =#
        return CubedSpherePartition(div, Rx, Ry)
    end
#= none:36 =#
const RegularCubedSpherePartition = CubedSpherePartition{<:Number, <:Number}
#= none:37 =#
const XRegularCubedSpherePartition = CubedSpherePartition{<:Number}
#= none:38 =#
const YRegularCubedSpherePartition = CubedSpherePartition{<:Any, <:Number}
#= none:40 =#
Base.length(p::CubedSpherePartition) = begin
        #= none:40 =#
        p.div
    end
#= none:43 =#
#= none:43 =# @inline div_per_panel(panel_idx, partition::RegularCubedSpherePartition) = begin
            #= none:43 =#
            partition.Rx * partition.Ry
        end
#= none:44 =#
#= none:44 =# @inline div_per_panel(panel_idx, partition::XRegularCubedSpherePartition) = begin
            #= none:44 =#
            partition.Rx * partition.Ry[panel_idx]
        end
#= none:45 =#
#= none:45 =# @inline div_per_panel(panel_idx, partition::YRegularCubedSpherePartition) = begin
            #= none:45 =#
            partition.Rx[panel_idx] * partition.Ry
        end
#= none:47 =#
#= none:47 =# @inline Rx(panel_idx, partition::XRegularCubedSpherePartition) = begin
            #= none:47 =#
            partition.Rx
        end
#= none:48 =#
#= none:48 =# @inline Rx(panel_idx, partition::CubedSpherePartition) = begin
            #= none:48 =#
            partition.Rx[panel_idx]
        end
#= none:50 =#
#= none:50 =# @inline Ry(panel_idx, partition::YRegularCubedSpherePartition) = begin
            #= none:50 =#
            partition.Ry
        end
#= none:51 =#
#= none:51 =# @inline Ry(panel_idx, partition::CubedSpherePartition) = begin
            #= none:51 =#
            partition.Ry[panel_idx]
        end
#= none:53 =#
#= none:53 =# @inline panel_index(r, partition) = begin
            #= none:53 =#
            (r - 1) ÷ div_per_panel(r, partition) + 1
        end
#= none:54 =#
#= none:54 =# @inline intra_panel_index(r, partition) = begin
            #= none:54 =#
            mod(r - 1, div_per_panel(r, partition)) + 1
        end
#= none:55 =#
#= none:55 =# @inline intra_panel_index_x(r, partition) = begin
            #= none:55 =#
            mod(intra_panel_index(r, partition) - 1, Rx(r, partition)) + 1
        end
#= none:56 =#
#= none:56 =# @inline intra_panel_index_y(r, partition) = begin
            #= none:56 =#
            (intra_panel_index(r, partition) - 1) ÷ Rx(r, partition) + 1
        end
#= none:58 =#
#= none:58 =# @inline rank_from_panel_idx(pᵢ, pⱼ, panel_idx, partition::CubedSpherePartition) = begin
            #= none:58 =#
            (panel_idx - 1) * div_per_panel(panel_idx, partition) + Rx(panel_idx, partition) * (pⱼ - 1) + pᵢ
        end
#= none:61 =#
#= none:61 =# @inline function region_corners(r, p::CubedSpherePartition)
        #= none:61 =#
        #= none:62 =#
        pᵢ = intra_panel_index_x(r, p)
        #= none:63 =#
        pⱼ = intra_panel_index_y(r, p)
        #= none:65 =#
        bottom_left = if pᵢ == 1 && pⱼ == 1
                true
            else
                false
            end
        #= none:66 =#
        bottom_right = if pᵢ == p.Rx && pⱼ == 1
                true
            else
                false
            end
        #= none:67 =#
        top_left = if pᵢ == 1 && pⱼ == p.Ry
                true
            else
                false
            end
        #= none:68 =#
        top_right = if pᵢ == p.Rx && pⱼ == p.Ry
                true
            else
                false
            end
        #= none:70 =#
        return (; bottom_left, bottom_right, top_left, top_right)
    end
#= none:73 =#
#= none:73 =# @inline function region_edge(r, p::CubedSpherePartition)
        #= none:73 =#
        #= none:74 =#
        pᵢ = intra_panel_index_x(r, p)
        #= none:75 =#
        pⱼ = intra_panel_index_y(r, p)
        #= none:77 =#
        west = if pᵢ == 1
                true
            else
                false
            end
        #= none:78 =#
        east = if pᵢ == p.Rx
                true
            else
                false
            end
        #= none:79 =#
        south = if pⱼ == 1
                true
            else
                false
            end
        #= none:80 =#
        north = if pⱼ == p.Ry
                true
            else
                false
            end
        #= none:82 =#
        return (; west, east, south, north)
    end
#= none:90 =#
const SpherePanelGrid = OrthogonalSphericalShellGrid{<:Any, FullyConnected, FullyConnected}
#= none:93 =#
replace_horizontal_vector_halos!(::PrescribedVelocityFields, ::AbstractGrid; kw...) = begin
        #= none:93 =#
        nothing
    end
#= none:94 =#
replace_horizontal_vector_halos!(::PrescribedVelocityFields, ::SpherePanelGrid; kw...) = begin
        #= none:94 =#
        nothing
    end
#= none:96 =#
function replace_horizontal_vector_halos!(velocities, grid::SpherePanelGrid; signed = true)
    #= none:96 =#
    #= none:97 =#
    (u, v, _) = velocities
    #= none:99 =#
    ubuff = u.boundary_buffers
    #= none:100 =#
    vbuff = v.boundary_buffers
    #= none:102 =#
    conn_west = u.boundary_conditions.west.condition.from_side
    #= none:103 =#
    conn_east = u.boundary_conditions.east.condition.from_side
    #= none:104 =#
    conn_south = u.boundary_conditions.south.condition.from_side
    #= none:105 =#
    conn_north = u.boundary_conditions.north.condition.from_side
    #= none:107 =#
    (Hx, Hy, _) = halo_size(u.grid)
    #= none:108 =#
    (Nx, Ny, _) = size(grid)
    #= none:110 =#
    replace_west_u_halos!(parent(u), vbuff, Nx, Hx, conn_west; signed)
    #= none:111 =#
    replace_east_u_halos!(parent(u), vbuff, Nx, Hx, conn_east; signed)
    #= none:112 =#
    replace_south_u_halos!(parent(u), vbuff, Ny, Hy, conn_south; signed)
    #= none:113 =#
    replace_north_u_halos!(parent(u), vbuff, Ny, Hy, conn_north; signed)
    #= none:115 =#
    replace_west_v_halos!(parent(v), ubuff, Nx, Hx, conn_west; signed)
    #= none:116 =#
    replace_east_v_halos!(parent(v), ubuff, Nx, Hx, conn_east; signed)
    #= none:117 =#
    replace_south_v_halos!(parent(v), ubuff, Ny, Hy, conn_south; signed)
    #= none:118 =#
    replace_north_v_halos!(parent(v), ubuff, Ny, Hy, conn_north; signed)
    #= none:120 =#
    return nothing
end
#= none:123 =#
for vel = (:u, :v), dir = (:east, :west, :north, :south)
    #= none:124 =#
    #= none:124 =# @eval ($(Symbol(:replace_, dir, :_, vel, :_halos!)))(u, buff, N, H, conn; signed = true) = begin
                #= none:124 =#
                nothing
            end
    #= none:125 =#
end
#= none:127 =#
function replace_west_u_halos!(u, vbuff, N, H, ::North; signed)
    #= none:127 =#
    #= none:128 =#
    view(u, 1:H, :, :) .= vbuff.west.recv
    #= none:129 =#
    return nothing
end
#= none:132 =#
function replace_west_v_halos!(v, ubuff, N, H, ::North; signed)
    #= none:132 =#
    #= none:133 =#
    Nv = size(v, 2)
    #= none:134 =#
    view(v, 1:H, 2:Nv, :) .= view(ubuff.west.recv, :, 1:Nv - 1, :)
    #= none:135 =#
    if signed
        #= none:136 =#
        view(v, 1:H, :, :) .*= -1
    end
    #= none:138 =#
    return nothing
end
#= none:141 =#
function replace_east_u_halos!(u, vbuff, N, H, ::South; signed)
    #= none:141 =#
    #= none:142 =#
    view(u, N + 1 + H:N + 2H, :, :) .= vbuff.east.recv
    #= none:143 =#
    return nothing
end
#= none:146 =#
function replace_east_v_halos!(v, ubuff, N, H, ::South; signed)
    #= none:146 =#
    #= none:147 =#
    Nv = size(v, 2)
    #= none:148 =#
    view(v, N + 1 + H:N + 2H, 2:Nv, :) .= view(ubuff.east.recv, :, 1:Nv - 1, :)
    #= none:149 =#
    if signed
        #= none:150 =#
        view(v, N + 1 + H:N + 2H, :, :) .*= -1
    end
    #= none:152 =#
    return nothing
end
#= none:155 =#
function replace_south_u_halos!(u, vbuff, N, H, ::East; signed)
    #= none:155 =#
    #= none:156 =#
    Nu = size(u, 1)
    #= none:157 =#
    view(u, 2:Nu, 1:H, :) .= view(vbuff.south.recv, 1:Nu - 1, :, :)
    #= none:158 =#
    if signed
        #= none:159 =#
        view(u, :, 1:H, :) .*= -1
    end
    #= none:161 =#
    return nothing
end
#= none:164 =#
function replace_south_v_halos!(v, ubuff, N, H, ::East; signed)
    #= none:164 =#
    #= none:165 =#
    view(v, :, 1:H, :) .= ubuff.south.recv
    #= none:166 =#
    return nothing
end
#= none:169 =#
function replace_north_u_halos!(u, vbuff, N, H, ::West; signed)
    #= none:169 =#
    #= none:170 =#
    Nv = size(u, 1)
    #= none:171 =#
    view(u, 2:Nv, N + 1 + H:N + 2H, :) .= view(vbuff.north.recv, 1:Nv - 1, :, :)
    #= none:172 =#
    if signed
        #= none:173 =#
        view(u, :, N + 1 + H:N + 2H, :) .*= -1
    end
    #= none:175 =#
    return nothing
end
#= none:178 =#
function replace_north_v_halos!(v, ubuff, N, H, ::West; signed)
    #= none:178 =#
    #= none:179 =#
    view(v, :, N + 1 + H:N + 2H, :) .= ubuff.north.recv
    #= none:180 =#
    return nothing
end
#= none:183 =#
function Base.summary(p::CubedSpherePartition)
    #= none:183 =#
    #= none:184 =#
    region_str = if p.Rx * p.Ry > 1
            "regions"
        else
            "region"
        end
    #= none:186 =#
    return "CubedSpherePartition with ($(p.Rx * p.Ry) $(region_str) in each panel)"
end
#= none:189 =#
Base.show(io::IO, p::CubedSpherePartition) = begin
        #= none:189 =#
        print(io, summary(p), "\n", "├── Rx: ", p.Rx, "\n", "├── Ry: ", p.Ry, "\n", "└── div: ", p.div)
    end