
#= none:1 =#
using Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:2 =#
using Oceananigans.ImmersedBoundaries: mask_immersed_field!
#= none:3 =#
using Oceananigans.Models: update_model_field_time_series!
#= none:5 =#
import Oceananigans.TimeSteppers: update_state!
#= none:7 =#
#= none:7 =# Core.@doc "    update_state!(model::ShallowWaterModel, callbacks=[]; compute_tendencies=true)\n\nUpdate the diagnostic state of `ShallowWaterModel`.\n\nMask immersed cells for prognostic fields, update model time series,\ncompute diffusivity fields, fill halo regions for\n`model.solution` and `model.tracers`, and compute velocity fields\nif using `ConservativeFormulation`.\n\nNext, `callbacks` are executed.\n\nFinally, tendencies are computed if `compute_tendencies=true`.\n" function update_state!(model::ShallowWaterModel, callbacks = []; compute_tendencies = true)
        #= none:21 =#
        #= none:24 =#
        foreach(mask_immersed_field!, merge(model.solution, model.tracers))
        #= none:27 =#
        update_model_field_time_series!(model, model.clock)
        #= none:29 =#
        compute_diffusivities!(model.diffusivity_fields, model.closure, model)
        #= none:31 =#
        fill_halo_regions!(merge(model.solution, model.tracers), model.clock, fields(model))
        #= none:33 =#
        compute_velocities!(model.velocities, formulation(model))
        #= none:35 =#
        foreach(callbacks) do callback
            #= none:36 =#
            if callback.callsite isa UpdateStateCallsite
                #= none:37 =#
                callback(model)
            end
        end
        #= none:41 =#
        compute_tendencies && compute_tendencies!(model, callbacks)
        #= none:43 =#
        return nothing
    end
#= none:46 =#
compute_velocities!(U, ::VectorInvariantFormulation) = begin
        #= none:46 =#
        nothing
    end
#= none:48 =#
function compute_velocities!(U, ::ConservativeFormulation)
    #= none:48 =#
    #= none:49 =#
    compute!(U.u)
    #= none:50 =#
    compute!(U.v)
    #= none:51 =#
    return nothing
end