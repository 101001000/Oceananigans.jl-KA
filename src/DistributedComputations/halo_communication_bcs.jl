
#= none:1 =#
using Oceananigans.BoundaryConditions: DistributedCommunicationBoundaryCondition, FieldBoundaryConditions
#= none:2 =#
using Oceananigans.BoundaryConditions: AbstractBoundaryConditionClassification
#= none:3 =#
import Oceananigans.BoundaryConditions: bc_str
#= none:5 =#
struct HaloCommunicationRanks{F, T}
    #= none:6 =#
    from::F
    #= none:7 =#
    to::T
end
#= none:10 =#
HaloCommunicationRanks(; from, to) = begin
        #= none:10 =#
        HaloCommunicationRanks(from, to)
    end
#= none:12 =#
Base.summary(hcr::HaloCommunicationRanks) = begin
        #= none:12 =#
        "HaloCommunicationRanks from rank $(hcr.from) to rank $(hcr.to)"
    end
#= none:14 =#
function inject_halo_communication_boundary_conditions(field_bcs, local_rank, connectivity, topology)
    #= none:14 =#
    #= none:15 =#
    rank_east = connectivity.east
    #= none:16 =#
    rank_west = connectivity.west
    #= none:17 =#
    rank_north = connectivity.north
    #= none:18 =#
    rank_south = connectivity.south
    #= none:20 =#
    east_comm_ranks = HaloCommunicationRanks(from = local_rank, to = rank_east)
    #= none:21 =#
    west_comm_ranks = HaloCommunicationRanks(from = local_rank, to = rank_west)
    #= none:22 =#
    north_comm_ranks = HaloCommunicationRanks(from = local_rank, to = rank_north)
    #= none:23 =#
    south_comm_ranks = HaloCommunicationRanks(from = local_rank, to = rank_south)
    #= none:25 =#
    east_comm_bc = DistributedCommunicationBoundaryCondition(east_comm_ranks)
    #= none:26 =#
    west_comm_bc = DistributedCommunicationBoundaryCondition(west_comm_ranks)
    #= none:27 =#
    north_comm_bc = DistributedCommunicationBoundaryCondition(north_comm_ranks)
    #= none:28 =#
    south_comm_bc = DistributedCommunicationBoundaryCondition(south_comm_ranks)
    #= none:30 =#
    (TX, TY, _) = topology
    #= none:36 =#
    inject_west = !(isnothing(rank_west)) && TX != RightConnected
    #= none:37 =#
    inject_east = !(isnothing(rank_east)) && TX != LeftConnected
    #= none:38 =#
    inject_south = !(isnothing(rank_south)) && TY != RightConnected
    #= none:39 =#
    inject_north = !(isnothing(rank_north)) && TY != LeftConnected
    #= none:41 =#
    west = if inject_west
            west_comm_bc
        else
            field_bcs.west
        end
    #= none:42 =#
    east = if inject_east
            east_comm_bc
        else
            field_bcs.east
        end
    #= none:43 =#
    south = if inject_south
            south_comm_bc
        else
            field_bcs.south
        end
    #= none:44 =#
    north = if inject_north
            north_comm_bc
        else
            field_bcs.north
        end
    #= none:46 =#
    bottom = field_bcs.bottom
    #= none:47 =#
    top = field_bcs.top
    #= none:48 =#
    immersed = field_bcs.immersed
    #= none:50 =#
    return FieldBoundaryConditions(west, east, south, north, bottom, top, immersed)
end