
#= none:1 =#
using Oceananigans.Fields: location
#= none:2 =#
using Oceananigans.TimeSteppers: ab2_step_field!
#= none:3 =#
using Oceananigans.TurbulenceClosures: implicit_step!
#= none:4 =#
using Oceananigans.ImmersedBoundaries: retrieve_interior_active_cells_map, retrieve_surface_active_cells_map
#= none:6 =#
import Oceananigans.TimeSteppers: ab2_step!
#= none:12 =#
setup_free_surface!(model, free_surface, χ) = begin
        #= none:12 =#
        nothing
    end
#= none:14 =#
function ab2_step!(model::HydrostaticFreeSurfaceModel, Δt)
    #= none:14 =#
    #= none:16 =#
    χ = model.timestepper.χ
    #= none:17 =#
    setup_free_surface!(model, model.free_surface, χ)
    #= none:20 =#
    #= none:20 =# @apply_regionally local_ab2_step!(model, Δt, χ)
    #= none:23 =#
    ab2_step_free_surface!(model.free_surface, model, Δt, χ)
    #= none:25 =#
    return nothing
end
#= none:28 =#
function local_ab2_step!(model, Δt, χ)
    #= none:28 =#
    #= none:29 =#
    ab2_step_velocities!(model.velocities, model, Δt, χ)
    #= none:30 =#
    ab2_step_tracers!(model.tracers, model, Δt, χ)
    #= none:31 =#
    return nothing
end
#= none:38 =#
function ab2_step_velocities!(velocities, model, Δt, χ)
    #= none:38 =#
    #= none:40 =#
    for (i, name) = enumerate((:u, :v))
        #= none:41 =#
        Gⁿ = model.timestepper.Gⁿ[name]
        #= none:42 =#
        G⁻ = model.timestepper.G⁻[name]
        #= none:43 =#
        velocity_field = model.velocities[name]
        #= none:45 =#
        launch!(model.architecture, model.grid, :xyz, ab2_step_field!, velocity_field, Δt, χ, Gⁿ, G⁻)
        #= none:51 =#
        implicit_step!(velocity_field, model.timestepper.implicit_solver, model.closure, model.diffusivity_fields, nothing, model.clock, Δt)
        #= none:58 =#
    end
    #= none:60 =#
    return nothing
end
#= none:67 =#
const EmptyNamedTuple = NamedTuple{(), Tuple{}}
#= none:69 =#
ab2_step_tracers!(::EmptyNamedTuple, model, Δt, χ) = begin
        #= none:69 =#
        nothing
    end
#= none:71 =#
function ab2_step_tracers!(tracers, model, Δt, χ)
    #= none:71 =#
    #= none:73 =#
    closure = model.closure
    #= none:76 =#
    for (tracer_index, tracer_name) = enumerate(propertynames(tracers))
        #= none:79 =#
        if closure isa FlavorOfCATKE && tracer_name == :e
            #= none:80 =#
            #= none:80 =# @debug "Skipping AB2 step for e"
        elseif #= none:81 =# closure isa FlavorOfTD && tracer_name == :ϵ
            #= none:82 =#
            #= none:82 =# @debug "Skipping AB2 step for ϵ"
        elseif #= none:83 =# closure isa FlavorOfTD && tracer_name == :e
            #= none:84 =#
            #= none:84 =# @debug "Skipping AB2 step for e"
        else
            #= none:86 =#
            Gⁿ = model.timestepper.Gⁿ[tracer_name]
            #= none:87 =#
            G⁻ = model.timestepper.G⁻[tracer_name]
            #= none:88 =#
            tracer_field = tracers[tracer_name]
            #= none:89 =#
            closure = model.closure
            #= none:91 =#
            launch!(model.architecture, model.grid, :xyz, ab2_step_field!, tracer_field, Δt, χ, Gⁿ, G⁻)
            #= none:94 =#
            implicit_step!(tracer_field, model.timestepper.implicit_solver, closure, model.diffusivity_fields, Val(tracer_index), model.clock, Δt)
        end
        #= none:102 =#
    end
    #= none:104 =#
    return nothing
end