
#= none:1 =#
using Oceananigans.Fields: validate_field_tuple_grid
#= none:7 =#
function DiffusivityFields(diffusivity_fields::NamedTuple, grid, tracer_names, bcs, closure)
    #= none:7 =#
    #= none:8 =#
    validate_field_tuple_grid("diffusivity_fields", diffusivity_fields, grid)
    #= none:10 =#
    return diffusivity_fields
end
#= none:13 =#
DiffusivityFields(::Nothing, grid, tracer_names, bcs, closure) = begin
        #= none:13 =#
        DiffusivityFields(grid, tracer_names, bcs, closure)
    end
#= none:20 =#
DiffusivityFields(grid, tracer_names, bcs, closure) = begin
        #= none:20 =#
        nothing
    end
#= none:26 =#
DiffusivityFields(grid, tracer_names, bcs, closure_tuple::Tuple) = begin
        #= none:26 =#
        Tuple((DiffusivityFields(grid, tracer_names, bcs, closure) for closure = closure_tuple))
    end