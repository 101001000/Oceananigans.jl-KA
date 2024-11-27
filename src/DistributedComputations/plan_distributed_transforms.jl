
#= none:1 =#
using Oceananigans.Architectures: array_type
#= none:2 =#
using Oceananigans.Solvers: plan_forward_transform, plan_backward_transform, DiscreteTransform
#= none:3 =#
using Oceananigans.Solvers: Forward, Backward
#= none:5 =#
#= none:5 =# @inline reshaped_size(grid) = begin
            #= none:5 =#
            (size(grid, 2), size(grid, 1), size(grid, 3))
        end
#= none:7 =#
function plan_distributed_transforms(global_grid, storage::TransposableField, planner_flag)
    #= none:7 =#
    #= none:8 =#
    topo = topology(global_grid)
    #= none:9 =#
    arch = architecture(global_grid)
    #= none:11 =#
    grids = (storage.zfield.grid, storage.yfield.grid, storage.xfield.grid)
    #= none:13 =#
    rs_size = reshaped_size(grids[2])
    #= none:14 =#
    rs_storage = reshape(parent(storage.yfield), rs_size)
    #= none:16 =#
    forward_plan_x = plan_forward_transform(parent(storage.xfield), (topo[1])(), [1], planner_flag)
    #= none:17 =#
    forward_plan_z = plan_forward_transform(parent(storage.zfield), (topo[3])(), [3], planner_flag)
    #= none:18 =#
    backward_plan_x = plan_backward_transform(parent(storage.xfield), (topo[1])(), [1], planner_flag)
    #= none:19 =#
    backward_plan_z = plan_backward_transform(parent(storage.zfield), (topo[3])(), [3], planner_flag)
    #= none:21 =#
    if arch isa GPU
        #= none:22 =#
        forward_plan_y = plan_forward_transform(rs_storage, (topo[2])(), [1], planner_flag)
        #= none:23 =#
        backward_plan_y = plan_backward_transform(rs_storage, (topo[2])(), [1], planner_flag)
    else
        #= none:25 =#
        forward_plan_y = plan_forward_transform(parent(storage.yfield), (topo[2])(), [2], planner_flag)
        #= none:26 =#
        backward_plan_y = plan_backward_transform(parent(storage.yfield), (topo[2])(), [2], planner_flag)
    end
    #= none:29 =#
    forward_operations = (z! = DiscreteTransform(forward_plan_z, Forward(), grids[1], [3]), y! = DiscreteTransform(forward_plan_y, Forward(), grids[2], [2]), x! = DiscreteTransform(forward_plan_x, Forward(), grids[3], [1]))
    #= none:35 =#
    backward_operations = (x! = DiscreteTransform(backward_plan_x, Backward(), grids[3], [1]), y! = DiscreteTransform(backward_plan_y, Backward(), grids[2], [2]), z! = DiscreteTransform(backward_plan_z, Backward(), grids[1], [3]))
    #= none:41 =#
    return (; forward = forward_operations, backward = backward_operations)
end