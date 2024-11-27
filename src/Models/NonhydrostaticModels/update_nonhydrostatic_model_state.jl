
#= none:1 =#
using Oceananigans: UpdateStateCallsite
#= none:2 =#
using Oceananigans.Architectures
#= none:3 =#
using Oceananigans.BoundaryConditions
#= none:4 =#
using Oceananigans.Biogeochemistry: update_biogeochemical_state!
#= none:5 =#
using Oceananigans.BoundaryConditions: update_boundary_condition!
#= none:6 =#
using Oceananigans.TurbulenceClosures: compute_diffusivities!
#= none:7 =#
using Oceananigans.Fields: compute!
#= none:8 =#
using Oceananigans.ImmersedBoundaries: mask_immersed_field!
#= none:9 =#
using Oceananigans.Models: update_model_field_time_series!
#= none:11 =#
import Oceananigans.TimeSteppers: update_state!
#= none:13 =#
#= none:13 =# Core.@doc "    update_state!(model::NonhydrostaticModel, callbacks=[])\n\nUpdate peripheral aspects of the model (halo regions, diffusivities, hydrostatic\npressure) to the current model state. If `callbacks` are provided (in an array),\nthey are called in the end.\n" function update_state!(model::NonhydrostaticModel, callbacks = []; compute_tendencies = true)
        #= none:20 =#
        #= none:23 =#
        foreach(model.tracers) do tracer
            #= none:24 =#
            #= none:24 =# @apply_regionally mask_immersed_field!(tracer)
        end
        #= none:28 =#
        update_model_field_time_series!(model, model.clock)
        #= none:31 =#
        update_boundary_condition!(fields(model), model)
        #= none:34 =#
        fill_halo_regions!(merge(model.velocities, model.tracers), model.clock, fields(model); fill_boundary_normal_velocities = false, async = true)
        #= none:38 =#
        for aux_field = model.auxiliary_fields
            #= none:39 =#
            compute!(aux_field)
            #= none:40 =#
        end
        #= none:43 =#
        #= none:43 =# @apply_regionally compute_auxiliaries!(model)
        #= none:44 =#
        fill_halo_regions!(model.diffusivity_fields; only_local_halos = true)
        #= none:46 =#
        for callback = callbacks
            #= none:47 =#
            callback.callsite isa UpdateStateCallsite && callback(model)
            #= none:48 =#
        end
        #= none:50 =#
        update_biogeochemical_state!(model.biogeochemistry, model)
        #= none:52 =#
        compute_tendencies && #= none:53 =# @apply_regionally(compute_tendencies!(model, callbacks))
        #= none:55 =#
        return nothing
    end
#= none:58 =#
function compute_auxiliaries!(model::NonhydrostaticModel; p_parameters = tuple(p_kernel_parameters(model.grid)), κ_parameters = tuple(:xyz))
    #= none:58 =#
    #= none:61 =#
    closure = model.closure
    #= none:62 =#
    diffusivity = model.diffusivity_fields
    #= none:64 =#
    for (ppar, κpar) = zip(p_parameters, κ_parameters)
        #= none:65 =#
        compute_diffusivities!(diffusivity, closure, model; parameters = κpar)
        #= none:66 =#
        update_hydrostatic_pressure!(model; parameters = ppar)
        #= none:67 =#
    end
    #= none:68 =#
    return nothing
end