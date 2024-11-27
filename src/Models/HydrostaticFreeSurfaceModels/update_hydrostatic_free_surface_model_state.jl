
#= none:1 =#
using Oceananigans.Architectures
#= none:2 =#
using Oceananigans.BoundaryConditions
#= none:4 =#
using Oceananigans: UpdateStateCallsite
#= none:5 =#
using Oceananigans.Biogeochemistry: update_biogeochemical_state!
#= none:6 =#
using Oceananigans.BoundaryConditions: update_boundary_condition!
#= none:7 =#
using Oceananigans.TurbulenceClosures: compute_diffusivities!
#= none:8 =#
using Oceananigans.ImmersedBoundaries: mask_immersed_field!, mask_immersed_field_xy!, inactive_node
#= none:9 =#
using Oceananigans.Models: update_model_field_time_series!
#= none:10 =#
using Oceananigans.Models.NonhydrostaticModels: update_hydrostatic_pressure!, p_kernel_parameters
#= none:11 =#
using Oceananigans.Fields: replace_horizontal_vector_halos!
#= none:13 =#
import Oceananigans.Models.NonhydrostaticModels: compute_auxiliaries!
#= none:14 =#
import Oceananigans.TimeSteppers: update_state!
#= none:16 =#
compute_auxiliary_fields!(auxiliary_fields) = begin
        #= none:16 =#
        Tuple((compute!(a) for a = auxiliary_fields))
    end
#= none:21 =#
#= none:21 =# Core.@doc "    update_state!(model::HydrostaticFreeSurfaceModel, callbacks=[]; compute_tendencies = true)\n\nUpdate peripheral aspects of the model (auxiliary fields, halo regions, diffusivities,\nhydrostatic pressure) to the current model state. If `callbacks` are provided (in an array),\nthey are called in the end. Finally, the tendencies for the new time-step are computed if \n`compute_tendencies = true`.\n" update_state!(model::HydrostaticFreeSurfaceModel, callbacks = []; compute_tendencies = true) = begin
            #= none:29 =#
            update_state!(model, model.grid, callbacks; compute_tendencies)
        end
#= none:32 =#
function update_state!(model::HydrostaticFreeSurfaceModel, grid, callbacks; compute_tendencies = true)
    #= none:32 =#
    #= none:33 =#
    #= none:33 =# @apply_regionally mask_immersed_model_fields!(model, grid)
    #= none:36 =#
    #= none:36 =# @apply_regionally update_model_field_time_series!(model, model.clock)
    #= none:39 =#
    #= none:39 =# @apply_regionally update_boundary_condition!(fields(model), model)
    #= none:41 =#
    fill_halo_regions!(prognostic_fields(model), model.clock, fields(model); async = true)
    #= none:42 =#
    #= none:42 =# @apply_regionally replace_horizontal_vector_halos!(model.velocities, model.grid)
    #= none:43 =#
    #= none:43 =# @apply_regionally compute_auxiliaries!(model)
    #= none:45 =#
    fill_halo_regions!(model.diffusivity_fields; only_local_halos = true)
    #= none:47 =#
    [callback(model) for callback = callbacks if callback.callsite isa UpdateStateCallsite]
    #= none:49 =#
    update_biogeochemical_state!(model.biogeochemistry, model)
    #= none:51 =#
    compute_tendencies && #= none:52 =# @apply_regionally(compute_tendencies!(model, callbacks))
    #= none:54 =#
    return nothing
end
#= none:58 =#
function mask_immersed_model_fields!(model, grid)
    #= none:58 =#
    #= none:59 =#
    η = displacement(model.free_surface)
    #= none:60 =#
    fields_to_mask = merge(model.auxiliary_fields, prognostic_fields(model))
    #= none:62 =#
    foreach(fields_to_mask) do field
        #= none:63 =#
        if field !== η
            #= none:64 =#
            mask_immersed_field!(field)
        end
    end
    #= none:67 =#
    mask_immersed_field_xy!(η, k = size(grid, 3) + 1, mask = inactive_node)
    #= none:69 =#
    return nothing
end
#= none:72 =#
function compute_auxiliaries!(model::HydrostaticFreeSurfaceModel; w_parameters = tuple(w_kernel_parameters(model.grid)), p_parameters = tuple(p_kernel_parameters(model.grid)), κ_parameters = tuple(:xyz))
    #= none:72 =#
    #= none:76 =#
    grid = model.grid
    #= none:77 =#
    closure = model.closure
    #= none:78 =#
    diffusivity = model.diffusivity_fields
    #= none:80 =#
    for (wpar, ppar, κpar) = zip(w_parameters, p_parameters, κ_parameters)
        #= none:81 =#
        compute_w_from_continuity!(model; parameters = wpar)
        #= none:82 =#
        compute_diffusivities!(diffusivity, closure, model; parameters = κpar)
        #= none:83 =#
        update_hydrostatic_pressure!(model.pressure.pHY′, architecture(grid), grid, model.buoyancy, model.tracers; parameters = ppar)
        #= none:86 =#
    end
    #= none:87 =#
    return nothing
end