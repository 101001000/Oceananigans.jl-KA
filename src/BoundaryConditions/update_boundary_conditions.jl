
#= none:1 =#
using Oceananigans: boundary_conditions
#= none:3 =#
#= none:3 =# @inline update_boundary_condition!(bc, args...) = begin
            #= none:3 =#
            nothing
        end
#= none:5 =#
function update_boundary_condition!(bcs::FieldBoundaryConditions, field, model)
    #= none:5 =#
    #= none:6 =#
    update_boundary_condition!(bcs.west, Val(:west), field, model)
    #= none:7 =#
    update_boundary_condition!(bcs.east, Val(:east), field, model)
    #= none:8 =#
    update_boundary_condition!(bcs.south, Val(:south), field, model)
    #= none:9 =#
    update_boundary_condition!(bcs.north, Val(:north), field, model)
    #= none:10 =#
    update_boundary_condition!(bcs.bottom, Val(:bottom), field, model)
    #= none:11 =#
    update_boundary_condition!(bcs.top, Val(:top), field, model)
    #= none:12 =#
    update_boundary_condition!(bcs.immersed, Val(:immersed), field, model)
    #= none:13 =#
    return nothing
end
#= none:16 =#
update_boundary_condition!(fields::NamedTuple, model) = begin
        #= none:16 =#
        update_boundary_condition!(values(fields), model)
    end
#= none:18 =#
function update_boundary_condition!(fields::Tuple, model)
    #= none:18 =#
    #= none:19 =#
    N = length(fields)
    #= none:20 =#
    ntuple(Val(N)) do n
        #= none:21 =#
        field = fields[n]
        #= none:22 =#
        bcs = boundary_conditions(field)
        #= none:23 =#
        update_boundary_condition!(bcs, field, model)
    end
    #= none:26 =#
    return nothing
end