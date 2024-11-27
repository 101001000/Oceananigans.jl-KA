
#= none:5 =#
using KernelAbstractions: @kernel, @index
#= none:6 =#
using Oceananigans.Grids: default_indices
#= none:7 =#
using Oceananigans.Fields: FunctionField, FieldStatus, validate_indices, offset_index
#= none:8 =#
using Oceananigans.Utils: launch!
#= none:10 =#
import Oceananigans.Fields: Field, compute!
#= none:12 =#
const OperationOrFunctionField = Union{AbstractOperation, FunctionField}
#= none:13 =#
const ComputedField = Field{<:Any, <:Any, <:Any, <:OperationOrFunctionField}
#= none:15 =#
#= none:15 =# Core.@doc "    Field(operand::OperationOrFunctionField;\n          data = nothing,\n          indices = indices(operand),\n          boundary_conditions = FieldBoundaryConditions(operand.grid, location(operand)),\n          recompute_safely = true)\n\nReturn a field `f` where `f.data` is computed from `f.operand` by calling `compute!(f)`.\n\nKeyword arguments\n=================\n\n`data` (`AbstractArray`): An offset Array or CuArray for storing the result of a computation.\n                          Must have `total_size(location(operand), grid)`.\n\n`boundary_conditions` (`FieldBoundaryConditions`): Boundary conditions for `f`. \n\n`recompute_safely` (`Bool`): whether or not to _always_ \"recompute\" `f` if `f` is\n                             nested within another computation via an `AbstractOperation` or `FunctionField`.\n                             If `data` is not provided then `recompute_safely=false` and\n                             recomputation is _avoided_. If `data` is provided, then\n                             `recompute_safely = true` by default.\n" function Field(operand::OperationOrFunctionField; data = nothing, indices = indices(operand), boundary_conditions = FieldBoundaryConditions(operand.grid, location(operand)), recompute_safely = true)
        #= none:38 =#
        #= none:44 =#
        grid = operand.grid
        #= none:45 =#
        loc = location(operand)
        #= none:46 =#
        indices = validate_indices(indices, loc, grid)
        #= none:48 =#
        #= none:48 =# @apply_regionally boundary_conditions = FieldBoundaryConditions(indices, boundary_conditions)
        #= none:50 =#
        if isnothing(data)
            #= none:51 =#
            data = new_data(grid, loc, indices)
            #= none:52 =#
            recompute_safely = false
        end
        #= none:55 =#
        status = if recompute_safely
                nothing
            else
                FieldStatus()
            end
        #= none:57 =#
        return Field(loc, grid, data, boundary_conditions, indices, operand, status)
    end
#= none:60 =#
#= none:60 =# Core.@doc "    compute!(comp::ComputedField)\n\nCompute `comp.operand` and store the result in `comp.data`.\n" function compute!(comp::ComputedField, time = nothing)
        #= none:65 =#
        #= none:67 =#
        compute_at!(comp.operand, time)
        #= none:70 =#
        #= none:70 =# @apply_regionally compute_computed_field!(comp)
        #= none:72 =#
        fill_halo_regions!(comp)
        #= none:74 =#
        return comp
    end
#= none:77 =#
function compute_computed_field!(comp)
    #= none:77 =#
    #= none:78 =#
    arch = architecture(comp)
    #= none:79 =#
    parameters = KernelParameters(size(comp), map(offset_index, comp.indices))
    #= none:80 =#
    launch!(arch, comp.grid, parameters, _compute!, comp.data, comp.operand)
    #= none:81 =#
    return comp
end
#= none:84 =#
#= none:84 =# Core.@doc "Compute an `operand` and store in `data`." #= none:85 =# @kernel(function _compute!(data, operand)
            #= none:85 =#
            #= none:86 =#
            (i, j, k) = #= none:86 =# @index(Global, NTuple)
            #= none:87 =#
            #= none:87 =# @inbounds data[i, j, k] = operand[i, j, k]
        end)