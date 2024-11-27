
#= none:1 =#
using Oceananigans.Fields: validate_indices, Reduction
#= none:2 =#
using Oceananigans.AbstractOperations: AbstractOperation, ComputedField
#= none:3 =#
using Oceananigans.Grids: default_indices
#= none:5 =#
restrict_to_interior(::Colon, loc, topo, N) = begin
        #= none:5 =#
        interior_indices(loc, topo, N)
    end
#= none:6 =#
restrict_to_interior(::Colon, ::Nothing, topo, N) = begin
        #= none:6 =#
        UnitRange(1, 1)
    end
#= none:7 =#
restrict_to_interior(index::UnitRange, ::Nothing, topo, N) = begin
        #= none:7 =#
        UnitRange(1, 1)
    end
#= none:9 =#
function restrict_to_interior(index::UnitRange, loc, topo, N)
    #= none:9 =#
    #= none:10 =#
    from = max(first(index), 1)
    #= none:11 =#
    to = min(last(index), last(interior_indices(loc, topo, N)))
    #= none:12 =#
    return UnitRange(from, to)
end
#= none:19 =#
function construct_output(output, grid, indices, with_halos)
    #= none:19 =#
    #= none:20 =#
    if !(indices isa typeof(default_indices(3)))
        #= none:21 =#
        output_type = if output isa Function
                "Function"
            else
                ""
            end
        #= none:22 =#
        #= none:22 =# @warn "Cannot slice $(output_type) $(output) with $(indices): output will be unsliced."
    end
    #= none:25 =#
    return output
end
#= none:32 =#
function output_indices(output::Union{AbstractField, Reduction}, grid, indices, with_halos)
    #= none:32 =#
    #= none:33 =#
    indices = validate_indices(indices, location(output), grid)
    #= none:35 =#
    if !with_halos
        #= none:36 =#
        loc = map(instantiate, location(output))
        #= none:37 =#
        topo = map(instantiate, topology(grid))
        #= none:38 =#
        indices = map(restrict_to_interior, indices, loc, topo, size(grid))
    end
    #= none:41 =#
    return indices
end
#= none:44 =#
function construct_output(user_output::Union{AbstractField, Reduction}, grid, user_indices, with_halos)
    #= none:44 =#
    #= none:45 =#
    indices = output_indices(user_output, grid, user_indices, with_halos)
    #= none:46 =#
    return Field(user_output; indices)
end
#= none:53 =#
function construct_output(averaged_output::WindowedTimeAverage{<:Field}, grid, indices, with_halos)
    #= none:53 =#
    #= none:54 =#
    output = construct_output(averaged_output.operand, grid, indices, with_halos)
    #= none:55 =#
    return WindowedTimeAverage(output; schedule = averaged_output.schedule)
end