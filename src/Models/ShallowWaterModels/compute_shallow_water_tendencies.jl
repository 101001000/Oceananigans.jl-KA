
#= none:1 =#
import Oceananigans.TimeSteppers: compute_tendencies!
#= none:3 =#
using Oceananigans.Utils: launch!
#= none:4 =#
using Oceananigans: fields, TimeStepCallsite, TendencyCallsite, UpdateStateCallsite
#= none:5 =#
using KernelAbstractions: @index, @kernel
#= none:7 =#
using Oceananigans.Architectures: device
#= none:9 =#
using Oceananigans.BoundaryConditions
#= none:12 =#
#= none:12 =# Core.@doc "    compute_tendencies!(model::ShallowWaterModel)\n\nCalculate the interior and boundary contributions to tendency terms without the\ncontribution from non-hydrostatic pressure.\n" function compute_tendencies!(model::ShallowWaterModel, callbacks)
        #= none:18 =#
        #= none:30 =#
        compute_interior_tendency_contributions!(model.timestepper.Gⁿ, model.architecture, model.grid, model.gravitational_acceleration, model.advection, model.velocities, model.coriolis, model.closure, model.bathymetry, model.solution, model.tracers, model.diffusivity_fields, model.forcing, model.clock, model.formulation)
        #= none:48 =#
        compute_boundary_tendency_contributions!(model.timestepper.Gⁿ, model.architecture, model.solution, model.tracers, model.clock, fields(model))
        #= none:55 =#
        [callback(model) for callback = callbacks if callback.callsite isa TendencyCallsite]
        #= none:57 =#
        return nothing
    end
#= none:60 =#
#= none:60 =# Core.@doc " Store previous value of the source term and calculate current source term. " function compute_interior_tendency_contributions!(tendencies, arch, grid, gravitational_acceleration, advection, velocities, coriolis, closure, bathymetry, solution, tracers, diffusivities, forcings, clock, formulation)
        #= none:61 =#
        #= none:77 =#
        transport_args = (grid, gravitational_acceleration, advection.momentum, velocities, coriolis, closure, bathymetry, solution, tracers, diffusivities, forcings, clock, formulation)
        #= none:80 =#
        h_args = (grid, gravitational_acceleration, advection.mass, coriolis, closure, solution, tracers, diffusivities, forcings, clock, formulation)
        #= none:83 =#
        launch!(arch, grid, :xyz, compute_Guh!, tendencies[1], transport_args...; exclude_periphery = true)
        #= none:84 =#
        launch!(arch, grid, :xyz, compute_Gvh!, tendencies[2], transport_args...; exclude_periphery = true)
        #= none:85 =#
        launch!(arch, grid, :xyz, compute_Gh!, tendencies[3], h_args...)
        #= none:87 =#
        for (tracer_index, tracer_name) = enumerate(propertynames(tracers))
            #= none:88 =#
            #= none:88 =# @inbounds Gc = tendencies[tracer_index + 3]
            #= none:89 =#
            #= none:89 =# @inbounds forcing = forcings[tracer_index + 3]
            #= none:90 =#
            #= none:90 =# @inbounds c_advection = advection[tracer_name]
            #= none:92 =#
            launch!(arch, grid, :xyz, compute_Gc!, Gc, grid, Val(tracer_index), c_advection, closure, solution, tracers, diffusivities, forcing, clock, formulation)
            #= none:94 =#
        end
        #= none:96 =#
        return nothing
    end
#= none:103 =#
#= none:103 =# Core.@doc " Calculate the right-hand-side of the uh-transport equation. " #= none:104 =# @kernel(function compute_Guh!(Guh, grid, gravitational_acceleration, advection, velocities, coriolis, closure, bathymetry, solution, tracers, diffusivities, forcings, clock, formulation)
            #= none:104 =#
            #= none:119 =#
            (i, j, k) = #= none:119 =# @index(Global, NTuple)
            #= none:121 =#
            #= none:121 =# @inbounds Guh[i, j, k] = uh_solution_tendency(i, j, k, grid, gravitational_acceleration, advection, velocities, coriolis, closure, bathymetry, solution, tracers, diffusivities, forcings, clock, formulation)
        end)
#= none:125 =#
#= none:125 =# Core.@doc " Calculate the right-hand-side of the vh-transport equation. " #= none:126 =# @kernel(function compute_Gvh!(Gvh, grid, gravitational_acceleration, advection, velocities, coriolis, closure, bathymetry, solution, tracers, diffusivities, forcings, clock, formulation)
            #= none:126 =#
            #= none:141 =#
            (i, j, k) = #= none:141 =# @index(Global, NTuple)
            #= none:143 =#
            #= none:143 =# @inbounds Gvh[i, j, k] = vh_solution_tendency(i, j, k, grid, gravitational_acceleration, advection, velocities, coriolis, closure, bathymetry, solution, tracers, diffusivities, forcings, clock, formulation)
        end)
#= none:147 =#
#= none:147 =# Core.@doc " Calculate the right-hand-side of the height equation. " #= none:148 =# @kernel(function compute_Gh!(Gh, grid, gravitational_acceleration, advection, coriolis, closure, solution, tracers, diffusivities, forcings, clock, formulation)
            #= none:148 =#
            #= none:161 =#
            (i, j, k) = #= none:161 =# @index(Global, NTuple)
            #= none:163 =#
            #= none:163 =# @inbounds Gh[i, j, k] = h_solution_tendency(i, j, k, grid, gravitational_acceleration, advection, coriolis, closure, solution, tracers, diffusivities, forcings, clock, formulation)
        end)
#= none:171 =#
#= none:171 =# Core.@doc " Calculate the right-hand-side of the tracer advection-diffusion equation. " #= none:172 =# @kernel(function compute_Gc!(Gc, grid, tracer_index, advection, closure, solution, tracers, diffusivities, forcing, clock, formulation)
            #= none:172 =#
            #= none:184 =#
            (i, j, k) = #= none:184 =# @index(Global, NTuple)
            #= none:186 =#
            #= none:186 =# @inbounds Gc[i, j, k] = tracer_tendency(i, j, k, grid, tracer_index, advection, closure, solution, tracers, diffusivities, forcing, clock, formulation)
        end)
#= none:194 =#
#= none:194 =# Core.@doc " Apply boundary conditions by adding flux divergences to the right-hand-side. " function compute_boundary_tendency_contributions!(Gⁿ, arch, solution, tracers, clock, model_fields)
        #= none:195 =#
        #= none:196 =#
        prognostic_fields = merge(solution, tracers)
        #= none:199 =#
        for i = 1:length(Gⁿ)
            #= none:200 =#
            apply_x_bcs!(Gⁿ[i], prognostic_fields[i], arch, clock, model_fields)
            #= none:201 =#
            apply_y_bcs!(Gⁿ[i], prognostic_fields[i], arch, clock, model_fields)
            #= none:202 =#
        end
        #= none:204 =#
        return nothing
    end