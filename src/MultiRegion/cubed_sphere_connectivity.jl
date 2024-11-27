
#= none:1 =#
using Oceananigans.Grids: cpu_face_constructor_x, cpu_face_constructor_y, cpu_face_constructor_z, default_indices
#= none:3 =#
using Rotations
#= none:4 =#
using DocStringExtensions
#= none:9 =#
struct ↺
    #= none:9 =#
end
#= none:10 =#
struct ↻
    #= none:10 =#
end
#= none:12 =#
default_rotations = (RotX(π / 2) * RotY(π / 2), RotY(π) * RotX(-π / 2), RotZ(π), RotX(π) * RotY(-π / 2), RotY(π / 2) * RotX(π / 2), RotZ(π / 2) * RotX(π))
#= none:19 =#
struct CubedSphereConnectivity{C, R}
    #= none:20 =#
    connections::C
    #= none:21 =#
    rotations::R
end
#= none:24 =#
function CubedSphereConnectivity(devices, partition::CubedSpherePartition, rotations::Tuple = default_rotations)
    #= none:24 =#
    #= none:25 =#
    regions = MultiRegionObject(Tuple(1:length(devices)), devices)
    #= none:26 =#
    rotations = MultiRegionObject(rotations, devices)
    #= none:27 =#
    #= none:27 =# @apply_regionally connectivity = find_regional_connectivities(regions, partition)
    #= none:29 =#
    return CubedSphereConnectivity(connectivity, rotations)
end
#= none:32 =#
#= none:32 =# @inline getregion(connectivity::CubedSphereConnectivity, r) = begin
            #= none:32 =#
            _getregion(connectivity.connections, r)
        end
#= none:33 =#
#= none:33 =# @inline _getregion(connectivity::CubedSphereConnectivity, r) = begin
            #= none:33 =#
            getregion(connectivity.connections, r)
        end
#= none:35 =#
#= none:35 =# Core.@doc "    struct CubedSphereRegionalConnectivity{S, FS, R}\n\nThe connectivity among various regions for a cubed sphere grid. Parameter `R`\ndenotes the rotation of the `from_rank` region to the current region.\n\n$(TYPEDFIELDS)\n" struct CubedSphereRegionalConnectivity{S, FS, R} <: AbstractConnectivity
        #= none:44 =#
        "the current region rank"
        #= none:45 =#
        rank::Int
        #= none:46 =#
        "the region from which boundary condition comes from"
        #= none:47 =#
        from_rank::Int
        #= none:48 =#
        "the current region side"
        #= none:49 =#
        side::S
        #= none:50 =#
        "the side of the region from which boundary condition comes from"
        #= none:51 =#
        from_side::FS
        #= none:52 =#
        "rotation of the region from which boundary condition comes from compare to host region"
        #= none:53 =#
        rotation::R
        #= none:55 =#
        #= none:55 =# @doc "    CubedSphereRegionalConnectivity(rank, from_rank, side, from_side, rotation=nothing)\n\nReturn a `CubedSphereRegionalConnectivity`: `from_rank :: Int` → `rank :: Int` and\n`from_side :: AbstractRegionSide` → `side :: AbstractRegionSide`. The rotation of\nthe adjacent region relative to the host region is prescribed via `rotation` argument\n(default `rotation=nothing`).\n\nExample\n=======\n\nA connectivity that implies that the boundary condition for the\neast side of region 1 comes from the west side of region 2 is:\n\n```jldoctest cubedsphereconnectivity\njulia> using Oceananigans\n\njulia> using Oceananigans.MultiRegion: CubedSphereRegionalConnectivity, East, West, North, South, ↺, ↻\n\njulia> CubedSphereRegionalConnectivity(1, 2, East(), West())\nCubedSphereRegionalConnectivity\n├── from: Oceananigans.MultiRegion.West side, region 2\n├── to:   Oceananigans.MultiRegion.East side, region 1\n└── no rotation\n```\n\nA connectivity that implies that the boundary condition for the\nnorth side of region 1 comes from the east side of region 3 is \n\n```jldoctest cubedsphereconnectivity\njulia> CubedSphereRegionalConnectivity(1, 3, North(), East(), ↺())\nCubedSphereRegionalConnectivity\n├── from: Oceananigans.MultiRegion.East side, region 3\n├── to:   Oceananigans.MultiRegion.North side, region 1\n└── counter-clockwise rotation ↺\n```\n" CubedSphereRegionalConnectivity(rank, from_rank, side, from_side, rotation = nothing) = begin
                    #= none:92 =#
                    new{typeof(side), typeof(from_side), typeof(rotation)}(rank, from_rank, side, from_side, rotation)
                end
    end
#= none:96 =#
function Base.summary(c::CubedSphereRegionalConnectivity)
    #= none:96 =#
    #= none:97 =#
    return "CubedSphereRegionalConnectivity: from $(typeof(c.from_side)) region #$(c.from_rank) → $(typeof(c.side)) region #$(c.rank)"
end
#= none:100 =#
function Base.show(io::IO, c::CubedSphereRegionalConnectivity{S, FS, R}) where {S, FS, R}
    #= none:100 =#
    #= none:101 =#
    if R == Nothing
        #= none:102 =#
        rotation_description = "no rotation"
    elseif #= none:103 =# R == (↺)
        #= none:104 =#
        rotation_description = "counter-clockwise rotation ↺"
    elseif #= none:105 =# R == (↻)
        #= none:106 =#
        rotation_description = "clockwise rotation ↻"
    end
    #= none:109 =#
    return print(io, "CubedSphereRegionalConnectivity", "\n", "├── from: $(typeof(c.from_side)) side, region $(c.from_rank) \n", "├── to:   $(typeof(c.side)) side, region $(c.rank) \n", "└── ", rotation_description)
end
#= none:115 =#
"                                                         [5][6]\nconnectivity for a cubed sphere with configuration    [3][4]    or subdisions of this config.\n                                                   [1][2]\n"
#= none:121 =#
function find_west_connectivity(region, partition::CubedSpherePartition)
    #= none:121 =#
    #= none:122 =#
    pᵢ = intra_panel_index_x(region, partition)
    #= none:123 =#
    pⱼ = intra_panel_index_y(region, partition)
    #= none:125 =#
    pidx = panel_index(region, partition)
    #= none:127 =#
    if pᵢ == 1
        #= none:128 =#
        if mod(pidx, 2) == 0
            #= none:129 =#
            from_side = East()
            #= none:130 =#
            from_panel = pidx - 1
            #= none:131 =#
            from_pᵢ = Rx(from_panel, partition)
            #= none:132 =#
            from_pⱼ = pⱼ
        else
            #= none:134 =#
            from_side = North()
            #= none:135 =#
            from_panel = mod(pidx + 3, 6) + 1
            #= none:136 =#
            from_pᵢ = (Rx(from_panel, partition) - pⱼ) + 1
            #= none:137 =#
            from_pⱼ = Ry(from_panel, partition)
        end
        #= none:139 =#
        from_rank = rank_from_panel_idx(from_pᵢ, from_pⱼ, from_panel, partition)
    else
        #= none:141 =#
        from_side = East()
        #= none:142 =#
        from_rank = rank_from_panel_idx(pᵢ - 1, pⱼ, pidx, partition)
    end
    #= none:145 =#
    if from_side == North()
        #= none:146 =#
        rotation = ↻()
    elseif #= none:147 =# from_side == East()
        #= none:148 =#
        rotation = nothing
    end
    #= none:151 =#
    return CubedSphereRegionalConnectivity(region, from_rank, West(), from_side, rotation)
end
#= none:154 =#
function find_east_connectivity(region, partition::CubedSpherePartition)
    #= none:154 =#
    #= none:155 =#
    pᵢ = intra_panel_index_x(region, partition)
    #= none:156 =#
    pⱼ = intra_panel_index_y(region, partition)
    #= none:158 =#
    pidx = panel_index(region, partition)
    #= none:160 =#
    if pᵢ == partition.Rx
        #= none:161 =#
        if mod(pidx, 2) != 0
            #= none:162 =#
            from_side = West()
            #= none:163 =#
            from_panel = pidx + 1
            #= none:164 =#
            from_pᵢ = 1
            #= none:165 =#
            from_pⱼ = pⱼ
        else
            #= none:167 =#
            from_side = South()
            #= none:168 =#
            from_panel = mod(pidx + 1, 6) + 1
            #= none:169 =#
            from_pᵢ = (Rx(from_panel, partition) - pⱼ) + 1
            #= none:170 =#
            from_pⱼ = 1
        end
        #= none:172 =#
        from_rank = rank_from_panel_idx(from_pᵢ, from_pⱼ, from_panel, partition)
    else
        #= none:174 =#
        from_side = West()
        #= none:175 =#
        from_rank = rank_from_panel_idx(pᵢ + 1, pⱼ, pidx, partition)
    end
    #= none:178 =#
    if from_side == South()
        #= none:179 =#
        rotation = ↻()
    elseif #= none:180 =# from_side == West()
        #= none:181 =#
        rotation = nothing
    end
    #= none:184 =#
    return CubedSphereRegionalConnectivity(region, from_rank, East(), from_side, rotation)
end
#= none:187 =#
function find_south_connectivity(region, partition::CubedSpherePartition)
    #= none:187 =#
    #= none:188 =#
    pᵢ = intra_panel_index_x(region, partition)
    #= none:189 =#
    pⱼ = intra_panel_index_y(region, partition)
    #= none:191 =#
    pidx = panel_index(region, partition)
    #= none:193 =#
    if pⱼ == 1
        #= none:194 =#
        if mod(pidx, 2) != 0
            #= none:195 =#
            from_side = North()
            #= none:196 =#
            from_panel = mod(pidx + 4, 6) + 1
            #= none:197 =#
            from_pᵢ = pᵢ
            #= none:198 =#
            from_pⱼ = Ry(from_panel, partition)
        else
            #= none:200 =#
            from_side = East()
            #= none:201 =#
            from_panel = mod(pidx + 3, 6) + 1
            #= none:202 =#
            from_pᵢ = Rx(from_panel, partition)
            #= none:203 =#
            from_pⱼ = (Ry(from_panel, partition) - pᵢ) + 1
        end
        #= none:205 =#
        from_rank = rank_from_panel_idx(from_pᵢ, from_pⱼ, from_panel, partition)
    else
        #= none:207 =#
        from_side = North()
        #= none:208 =#
        from_rank = rank_from_panel_idx(pᵢ, pⱼ - 1, pidx, partition)
    end
    #= none:211 =#
    if from_side == East()
        #= none:212 =#
        rotation = ↺()
    elseif #= none:213 =# from_side == North()
        #= none:214 =#
        rotation = nothing
    end
    #= none:217 =#
    return CubedSphereRegionalConnectivity(region, from_rank, South(), from_side, rotation)
end
#= none:220 =#
function find_north_connectivity(region, partition::CubedSpherePartition)
    #= none:220 =#
    #= none:221 =#
    pᵢ = intra_panel_index_x(region, partition)
    #= none:222 =#
    pⱼ = intra_panel_index_y(region, partition)
    #= none:224 =#
    pidx = panel_index(region, partition)
    #= none:226 =#
    if pⱼ == partition.Ry
        #= none:227 =#
        if mod(pidx, 2) == 0
            #= none:228 =#
            from_side = South()
            #= none:229 =#
            from_panel = mod(pidx, 6) + 1
            #= none:230 =#
            from_pᵢ = pᵢ
            #= none:231 =#
            from_pⱼ = 1
        else
            #= none:233 =#
            from_side = West()
            #= none:234 =#
            from_panel = mod(pidx + 1, 6) + 1
            #= none:235 =#
            from_pᵢ = 1
            #= none:236 =#
            from_pⱼ = (Rx(from_panel, partition) - pᵢ) + 1
        end
        #= none:238 =#
        from_rank = rank_from_panel_idx(from_pᵢ, from_pⱼ, from_panel, partition)
    else
        #= none:240 =#
        from_side = South()
        #= none:241 =#
        from_rank = rank_from_panel_idx(pᵢ, pⱼ + 1, pidx, partition)
    end
    #= none:244 =#
    if from_side == West()
        #= none:245 =#
        rotation = ↺()
    elseif #= none:246 =# from_side == South()
        #= none:247 =#
        rotation = nothing
    end
    #= none:250 =#
    return CubedSphereRegionalConnectivity(region, from_rank, North(), from_side, rotation)
end
#= none:253 =#
function find_regional_connectivities(region, partition::CubedSpherePartition)
    #= none:253 =#
    #= none:254 =#
    west = find_west_connectivity(region, partition)
    #= none:255 =#
    east = find_east_connectivity(region, partition)
    #= none:256 =#
    north = find_north_connectivity(region, partition)
    #= none:257 =#
    south = find_south_connectivity(region, partition)
    #= none:259 =#
    return (; west, east, north, south)
end
#= none:262 =#
Base.summary(::CubedSphereConnectivity) = begin
        #= none:262 =#
        "CubedSphereConnectivity"
    end
#= none:268 =#
#= none:268 =# Core.@doc "Trivial connectivities are East ↔ West, North ↔ South. Anything else is referred to as non-trivial." const NonTrivialConnectivity = Union{CubedSphereRegionalConnectivity{East, South}, CubedSphereRegionalConnectivity{East, North}, CubedSphereRegionalConnectivity{West, South}, CubedSphereRegionalConnectivity{West, North}, CubedSphereRegionalConnectivity{South, East}, CubedSphereRegionalConnectivity{South, West}, CubedSphereRegionalConnectivity{North, East}, CubedSphereRegionalConnectivity{North, West}}
#= none:274 =#
#= none:274 =# @inline flip_west_and_east_indices(buff, loc, conn) = begin
            #= none:274 =#
            buff
        end
#= none:275 =#
#= none:275 =# @inline flip_west_and_east_indices(buff, ::Center, ::NonTrivialConnectivity) = begin
            #= none:275 =#
            reverse(permutedims(buff, (2, 1, 3)), dims = 2)
        end
#= none:276 =#
#= none:276 =# @inline flip_west_and_east_indices(buff, ::Face, ::NonTrivialConnectivity) = begin
            #= none:276 =#
            reverse(permutedims(buff, (2, 1, 3)), dims = 2)
        end
#= none:278 =#
#= none:278 =# @inline flip_south_and_north_indices(buff, loc, conn) = begin
            #= none:278 =#
            buff
        end
#= none:279 =#
#= none:279 =# @inline flip_south_and_north_indices(buff, ::Center, ::NonTrivialConnectivity) = begin
            #= none:279 =#
            reverse(permutedims(buff, (2, 1, 3)), dims = 1)
        end
#= none:280 =#
#= none:280 =# @inline flip_south_and_north_indices(buff, ::Face, ::NonTrivialConnectivity) = begin
            #= none:280 =#
            reverse(permutedims(buff, (2, 1, 3)), dims = 1)
        end