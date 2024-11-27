
#= none:1 =#
import Oceananigans: tracer_tendency_kernel_function
#= none:2 =#
import Oceananigans.TimeSteppers: compute_tendencies!
#= none:3 =#
import Oceananigans.Models: complete_communication_and_compute_buffer!
#= none:4 =#
import Oceananigans.Models: interior_tendency_kernel_parameters
#= none:6 =#
using Oceananigans: fields, prognostic_fields, TendencyCallsite, UpdateStateCallsite
#= none:7 =#
using Oceananigans.Utils: work_layout, KernelParameters
#= none:8 =#
using Oceananigans.Grids: halo_size
#= none:9 =#
using Oceananigans.Fields: immersed_boundary_condition
#= none:10 =#
using Oceananigans.Biogeochemistry: update_tendencies!
#= none:11 =#
using Oceananigans.TurbulenceClosures.TKEBasedVerticalDiffusivities: FlavorOfCATKE, FlavorOfTD
#= none:13 =#
using Oceananigans.ImmersedBoundaries: retrieve_interior_active_cells_map, ActiveCellsIBG, active_linear_index_to_tuple
#= none:16 =#
#= none:16 =# Core.@doc "    compute_tendencies!(model::HydrostaticFreeSurfaceModel, callbacks)\n\nCalculate the interior and boundary contributions to tendency terms without the\ncontribution from non-hydrostatic pressure.\n" function compute_tendencies!(model::HydrostaticFreeSurfaceModel, callbacks)
        #= none:22 =#
        #= none:24 =#
        grid = model.grid
        #= none:25 =#
        arch = architecture(grid)
        #= none:30 =#
        active_cells_map = retrieve_interior_active_cells_map(model.grid, Val(:interior))
        #= none:31 =#
        kernel_parameters = interior_tendency_kernel_parameters(arch, grid)
        #= none:33 =#
        compute_hydrostatic_free_surface_tendency_contributions!(model, kernel_parameters; active_cells_map)
        #= none:34 =#
        complete_communication_and_compute_buffer!(model, grid, arch)
        #= none:38 =#
        compute_hydrostatic_boundary_tendency_contributions!(model.timestepper.Gⁿ, model.architecture, model.velocities, model.free_surface, model.tracers, model.clock, fields(model), model.closure, model.buoyancy)
        #= none:48 =#
        for callback = callbacks
            #= none:49 =#
            callback.callsite isa TendencyCallsite && callback(model)
            #= none:50 =#
        end
        #= none:52 =#
        update_tendencies!(model.biogeochemistry, model)
        #= none:54 =#
        return nothing
    end
#= none:57 =#
#= none:57 =# @inline function top_tracer_boundary_conditions(grid, tracers)
        #= none:57 =#
        #= none:58 =#
        names = propertynames(tracers)
        #= none:59 =#
        values = Tuple(((tracers[c]).boundary_conditions.top for c = names))
        #= none:62 =#
        return NamedTuple{tuple(names...)}(tuple(values...))
    end
#= none:65 =#
#= none:65 =# Core.@doc " Store previous value of the source term and compute current source term. " function compute_hydrostatic_free_surface_tendency_contributions!(model, kernel_parameters; active_cells_map = nothing)
        #= none:66 =#
        #= none:68 =#
        arch = model.architecture
        #= none:69 =#
        grid = model.grid
        #= none:71 =#
        compute_hydrostatic_momentum_tendencies!(model, model.velocities, kernel_parameters; active_cells_map)
        #= none:73 =#
        for (tracer_index, tracer_name) = enumerate(propertynames(model.tracers))
            #= none:75 =#
            #= none:75 =# @inbounds c_tendency = model.timestepper.Gⁿ[tracer_name]
            #= none:76 =#
            #= none:76 =# @inbounds c_advection = model.advection[tracer_name]
            #= none:77 =#
            #= none:77 =# @inbounds c_forcing = model.forcing[tracer_name]
            #= none:78 =#
            #= none:78 =# @inbounds c_immersed_bc = immersed_boundary_condition(model.tracers[tracer_name])
            #= none:80 =#
            args = tuple(Val(tracer_index), Val(tracer_name), c_advection, model.closure, c_immersed_bc, model.buoyancy, model.biogeochemistry, model.velocities, model.free_surface, model.tracers, model.diffusivity_fields, model.auxiliary_fields, c_forcing, model.clock)
            #= none:95 =#
            launch!(arch, grid, kernel_parameters, compute_hydrostatic_free_surface_Gc!, c_tendency, grid, active_cells_map, args; active_cells_map)
            #= none:102 =#
        end
        #= none:104 =#
        return nothing
    end
#= none:111 =#
function apply_flux_bcs!(Gcⁿ, c, arch, args)
    #= none:111 =#
    #= none:112 =#
    apply_x_bcs!(Gcⁿ, c, arch, args...)
    #= none:113 =#
    apply_y_bcs!(Gcⁿ, c, arch, args...)
    #= none:114 =#
    apply_z_bcs!(Gcⁿ, c, arch, args...)
    #= none:115 =#
    return nothing
end
#= none:118 =#
function compute_free_surface_tendency!(grid, model, kernel_parameters)
    #= none:118 =#
    #= none:120 =#
    arch = architecture(grid)
    #= none:122 =#
    args = tuple(model.velocities, model.free_surface, model.tracers, model.auxiliary_fields, model.forcing, model.clock)
    #= none:129 =#
    launch!(arch, grid, kernel_parameters, compute_hydrostatic_free_surface_Gη!, model.timestepper.Gⁿ.η, grid, args)
    #= none:133 =#
    return nothing
end
#= none:136 =#
#= none:136 =# Core.@doc " Calculate momentum tendencies if momentum is not prescribed." function compute_hydrostatic_momentum_tendencies!(model, velocities, kernel_parameters; active_cells_map = nothing)
        #= none:137 =#
        #= none:139 =#
        grid = model.grid
        #= none:140 =#
        arch = architecture(grid)
        #= none:142 =#
        u_immersed_bc = immersed_boundary_condition(velocities.u)
        #= none:143 =#
        v_immersed_bc = immersed_boundary_condition(velocities.v)
        #= none:145 =#
        start_momentum_kernel_args = (model.advection.momentum, model.coriolis, model.closure)
        #= none:149 =#
        end_momentum_kernel_args = (velocities, model.free_surface, model.tracers, model.buoyancy, model.diffusivity_fields, model.pressure.pHY′, model.auxiliary_fields, model.forcing, model.clock)
        #= none:159 =#
        u_kernel_args = tuple(start_momentum_kernel_args..., u_immersed_bc, end_momentum_kernel_args...)
        #= none:160 =#
        v_kernel_args = tuple(start_momentum_kernel_args..., v_immersed_bc, end_momentum_kernel_args...)
        #= none:162 =#
        launch!(arch, grid, kernel_parameters, compute_hydrostatic_free_surface_Gu!, model.timestepper.Gⁿ.u, grid, active_cells_map, u_kernel_args; active_cells_map)
        #= none:167 =#
        launch!(arch, grid, kernel_parameters, compute_hydrostatic_free_surface_Gv!, model.timestepper.Gⁿ.v, grid, active_cells_map, v_kernel_args; active_cells_map)
        #= none:172 =#
        compute_free_surface_tendency!(grid, model, :xy)
        #= none:174 =#
        return nothing
    end
#= none:177 =#
#= none:177 =# Core.@doc " Apply boundary conditions by adding flux divergences to the right-hand-side. " function compute_hydrostatic_boundary_tendency_contributions!(Gⁿ, arch, velocities, free_surface, tracers, args...)
        #= none:178 =#
        #= none:180 =#
        args = Tuple(args)
        #= none:183 =#
        for i = (:u, :v)
            #= none:184 =#
            apply_flux_bcs!(Gⁿ[i], velocities[i], arch, args)
            #= none:185 =#
        end
        #= none:188 =#
        apply_flux_bcs!(Gⁿ.η, displacement(free_surface), arch, args)
        #= none:191 =#
        for i = propertynames(tracers)
            #= none:192 =#
            apply_flux_bcs!(Gⁿ[i], tracers[i], arch, args)
            #= none:193 =#
        end
        #= none:195 =#
        return nothing
    end
#= none:202 =#
#= none:202 =# Core.@doc " Calculate the right-hand-side of the u-velocity equation. " #= none:203 =# @kernel(function compute_hydrostatic_free_surface_Gu!(Gu, grid, ::Nothing, args)
            #= none:203 =#
            #= none:204 =#
            (i, j, k) = #= none:204 =# @index(Global, NTuple)
            #= none:205 =#
            #= none:205 =# @inbounds Gu[i, j, k] = hydrostatic_free_surface_u_velocity_tendency(i, j, k, grid, args...)
        end)
#= none:208 =#
#= none:208 =# @kernel function compute_hydrostatic_free_surface_Gu!(Gu, grid, active_cells_map, args)
        #= none:208 =#
        #= none:209 =#
        idx = #= none:209 =# @index(Global, Linear)
        #= none:210 =#
        (i, j, k) = active_linear_index_to_tuple(idx, active_cells_map)
        #= none:211 =#
        #= none:211 =# @inbounds Gu[i, j, k] = hydrostatic_free_surface_u_velocity_tendency(i, j, k, grid, args...)
    end
#= none:214 =#
#= none:214 =# Core.@doc " Calculate the right-hand-side of the v-velocity equation. " #= none:215 =# @kernel(function compute_hydrostatic_free_surface_Gv!(Gv, grid, ::Nothing, args)
            #= none:215 =#
            #= none:216 =#
            (i, j, k) = #= none:216 =# @index(Global, NTuple)
            #= none:217 =#
            #= none:217 =# @inbounds Gv[i, j, k] = hydrostatic_free_surface_v_velocity_tendency(i, j, k, grid, args...)
        end)
#= none:220 =#
#= none:220 =# @kernel function compute_hydrostatic_free_surface_Gv!(Gv, grid, active_cells_map, args)
        #= none:220 =#
        #= none:221 =#
        idx = #= none:221 =# @index(Global, Linear)
        #= none:222 =#
        (i, j, k) = active_linear_index_to_tuple(idx, active_cells_map)
        #= none:223 =#
        #= none:223 =# @inbounds Gv[i, j, k] = hydrostatic_free_surface_v_velocity_tendency(i, j, k, grid, args...)
    end
#= none:230 =#
#= none:230 =# Core.@doc " Calculate the right-hand-side of the tracer advection-diffusion equation. " #= none:231 =# @kernel(function compute_hydrostatic_free_surface_Gc!(Gc, grid, ::Nothing, args)
            #= none:231 =#
            #= none:232 =#
            (i, j, k) = #= none:232 =# @index(Global, NTuple)
            #= none:233 =#
            #= none:233 =# @inbounds Gc[i, j, k] = hydrostatic_free_surface_tracer_tendency(i, j, k, grid, args...)
        end)
#= none:236 =#
#= none:236 =# @kernel function compute_hydrostatic_free_surface_Gc!(Gc, grid, active_cells_map, args)
        #= none:236 =#
        #= none:237 =#
        idx = #= none:237 =# @index(Global, Linear)
        #= none:238 =#
        (i, j, k) = active_linear_index_to_tuple(idx, active_cells_map)
        #= none:239 =#
        #= none:239 =# @inbounds Gc[i, j, k] = hydrostatic_free_surface_tracer_tendency(i, j, k, grid, args...)
    end
#= none:246 =#
#= none:246 =# Core.@doc " Calculate the right-hand-side of the free surface displacement (``η``) equation. " #= none:247 =# @kernel(function compute_hydrostatic_free_surface_Gη!(Gη, grid, args)
            #= none:247 =#
            #= none:248 =#
            (i, j) = #= none:248 =# @index(Global, NTuple)
            #= none:249 =#
            #= none:249 =# @inbounds Gη[i, j, grid.Nz + 1] = free_surface_tendency(i, j, grid, args...)
        end)