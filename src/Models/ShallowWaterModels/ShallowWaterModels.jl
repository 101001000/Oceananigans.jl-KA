
#= none:1 =#
module ShallowWaterModels
#= none:1 =#
#= none:3 =#
export ShallowWaterModel, ShallowWaterScalarDiffusivity, ConservativeFormulation, VectorInvariantFormulation
#= none:6 =#
using KernelAbstractions: @index, @kernel
#= none:8 =#
using Adapt
#= none:9 =#
using Oceananigans.Utils: launch!
#= none:11 =#
import Oceananigans: fields, prognostic_fields
#= none:17 =#
include("shallow_water_model.jl")
#= none:18 =#
include("set_shallow_water_model.jl")
#= none:19 =#
include("show_shallow_water_model.jl")
#= none:25 =#
#= none:25 =# Core.@doc "    fields(model::ShallowWaterModel)\n\nReturn a flattened `NamedTuple` of the fields in `model.solution` and `model.tracers` for\na `ShallowWaterModel` model.\n" fields(model::ShallowWaterModel) = begin
            #= none:31 =#
            merge(model.solution, model.tracers)
        end
#= none:33 =#
#= none:33 =# Core.@doc "    prognostic_fields(model::HydrostaticFreeSurfaceModel)\n\nReturn a flattened `NamedTuple` of the prognostic fields associated with `ShallowWaterModel`.\n" prognostic_fields(model::ShallowWaterModel) = begin
            #= none:38 =#
            fields(model)
        end
#= none:40 =#
include("solution_and_tracer_tendencies.jl")
#= none:41 =#
include("compute_shallow_water_tendencies.jl")
#= none:42 =#
include("update_shallow_water_state.jl")
#= none:43 =#
include("shallow_water_advection_operators.jl")
#= none:44 =#
include("shallow_water_diffusion_operators.jl")
#= none:45 =#
include("shallow_water_cell_advection_timescale.jl")
end