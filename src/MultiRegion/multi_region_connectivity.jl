
#= none:1 =#
using Oceananigans.Grids: topology
#= none:3 =#
#= none:3 =# Core.@doc "    struct RegionalConnectivity{S <: AbstractRegionSide, FS <: AbstractRegionSide} <: AbstractConnectivity\n\nThe connectivity among various regions in a multi-region partition.\n\n$(TYPEDFIELDS)\n" struct RegionalConnectivity{S <: AbstractRegionSide, FS <: AbstractRegionSide} <: AbstractConnectivity
        #= none:11 =#
        "the current region rank"
        #= none:12 =#
        rank::Int
        #= none:13 =#
        "the region from which boundary condition comes from"
        #= none:14 =#
        from_rank::Int
        #= none:15 =#
        "the current region side"
        #= none:16 =#
        side::S
        #= none:17 =#
        "the side of the region from which boundary condition comes from"
        #= none:18 =#
        from_side::FS
    end
#= none:21 =#
function Connectivity(devices, partition::Union{XPartition, YPartition}, global_grid::AbstractGrid)
    #= none:21 =#
    #= none:22 =#
    regions = MultiRegionObject(Tuple(1:length(devices)), devices)
    #= none:23 =#
    #= none:23 =# @apply_regionally connectivity = find_regional_connectivities(regions, partition, global_grid)
    #= none:24 =#
    return connectivity
end
#= none:27 =#
function find_regional_connectivities(region, partition, global_grid)
    #= none:27 =#
    #= none:28 =#
    west = find_west_connectivity(region, partition, global_grid)
    #= none:29 =#
    east = find_east_connectivity(region, partition, global_grid)
    #= none:30 =#
    north = find_north_connectivity(region, partition, global_grid)
    #= none:31 =#
    south = find_south_connectivity(region, partition, global_grid)
    #= none:33 =#
    return (; west, east, north, south)
end
#= none:36 =#
find_north_connectivity(region, ::XPartition, global_grid) = begin
        #= none:36 =#
        nothing
    end
#= none:38 =#
find_south_connectivity(region, ::XPartition, global_grid) = begin
        #= none:38 =#
        nothing
    end
#= none:40 =#
function find_east_connectivity(region, p::XPartition, global_grid)
    #= none:40 =#
    #= none:41 =#
    topo = topology(global_grid)
    #= none:42 =#
    if region == length(p)
        #= none:43 =#
        connectivity = if topo[1] <: Periodic
                RegionalConnectivity(region, 1, East(), West())
            else
                nothing
            end
    else
        #= none:45 =#
        connectivity = RegionalConnectivity(region, region + 1, East(), West())
    end
    #= none:48 =#
    return connectivity
end
#= none:51 =#
function find_west_connectivity(region, p::XPartition, global_grid)
    #= none:51 =#
    #= none:52 =#
    topo = topology(global_grid)
    #= none:54 =#
    if region == 1
        #= none:55 =#
        connectivity = if topo[1] <: Periodic
                RegionalConnectivity(region, length(p), West(), East())
            else
                nothing
            end
    else
        #= none:57 =#
        connectivity = RegionalConnectivity(region, region - 1, West(), East())
    end
    #= none:60 =#
    return connectivity
end
#= none:63 =#
find_east_connectivity(region, ::YPartition, global_grid) = begin
        #= none:63 =#
        nothing
    end
#= none:65 =#
find_west_connectivity(region, ::YPartition, global_grid) = begin
        #= none:65 =#
        nothing
    end
#= none:67 =#
function find_south_connectivity(region, p::YPartition, global_grid)
    #= none:67 =#
    #= none:68 =#
    topo = topology(global_grid)
    #= none:70 =#
    if region == 1
        #= none:71 =#
        connectivity = if topo[1] <: Periodic
                RegionalConnectivity(region, length(p), South(), North())
            else
                nothing
            end
    else
        #= none:73 =#
        connectivity = RegionalConnectivity(region, region - 1, South(), North())
    end
    #= none:76 =#
    return connectivity
end
#= none:79 =#
function find_north_connectivity(region, p::YPartition, global_grid)
    #= none:79 =#
    #= none:80 =#
    topo = topology(global_grid)
    #= none:82 =#
    if region == length(p)
        #= none:83 =#
        connectivity = if topo[1] <: Periodic
                RegionalConnectivity(region, 1, North(), South())
            else
                nothing
            end
    else
        #= none:85 =#
        connectivity = RegionalConnectivity(region, region + 1, North(), South())
    end
    #= none:88 =#
    return connectivity
end