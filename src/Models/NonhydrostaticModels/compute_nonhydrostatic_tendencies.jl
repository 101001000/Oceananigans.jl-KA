
#= none:1 =#
using Oceananigans.Biogeochemistry: update_tendencies!
#= none:2 =#
using Oceananigans: fields, TendencyCallsite
#= none:3 =#
using Oceananigans.Utils: work_layout
#= none:4 =#
using Oceananigans.Models: complete_communication_and_compute_buffer!, interior_tendency_kernel_parameters
#= none:6 =#
using Oceananigans.ImmersedBoundaries: retrieve_interior_active_cells_map, ActiveCellsIBG, active_linear_index_to_tuple
#= none:9 =#
import Oceananigans.TimeSteppers: compute_tendencies!
#= none:11 =#
#= none:11 =# Core.@doc "    compute_tendencies!(model::NonhydrostaticModel, callbacks)\n\nCalculate the interior and boundary contributions to tendency terms without the\ncontribution from non-hydrostatic pressure.\n" function compute_tendencies!(model::NonhydrostaticModel, callbacks)
        #= none:17 =#
        #= none:27 =#
        grid = model.grid
        #= none:28 =#
        arch = architecture(grid)
        #= none:32 =#
        kernel_parameters = interior_tendency_kernel_parameters(arch, grid)
        #= none:33 =#
        active_cells_map = retrieve_interior_active_cells_map(model.grid, Val(:interior))
        #= none:35 =#
        compute_interior_tendency_contributions!(model, kernel_parameters; active_cells_map)
        #= none:36 =#
        complete_communication_and_compute_buffer!(model, grid, arch)
        #= none:40 =#
        compute_boundary_tendency_contributions!(model.timestepper.Gⁿ, model.architecture, model.velocities, model.tracers, model.clock, fields(model))
        #= none:47 =#
        for callback = callbacks
            #= none:48 =#
            callback.callsite isa TendencyCallsite && callback(model)
            #= none:49 =#
        end
        #= none:51 =#
        update_tendencies!(model.biogeochemistry, model)
        #= none:53 =#
        return nothing
    end
#= none:56 =#
#= none:56 =# Core.@doc " Store previous value of the source term and compute current source term. " function compute_interior_tendency_contributions!(model, kernel_parameters; active_cells_map = nothing)
        #= none:57 =#
        #= none:59 =#
        tendencies = model.timestepper.Gⁿ
        #= none:60 =#
        arch = model.architecture
        #= none:61 =#
        grid = model.grid
        #= none:62 =#
        advection = model.advection
        #= none:63 =#
        coriolis = model.coriolis
        #= none:64 =#
        buoyancy = model.buoyancy
        #= none:65 =#
        biogeochemistry = model.biogeochemistry
        #= none:66 =#
        stokes_drift = model.stokes_drift
        #= none:67 =#
        closure = model.closure
        #= none:68 =#
        background_fields = model.background_fields
        #= none:69 =#
        velocities = model.velocities
        #= none:70 =#
        tracers = model.tracers
        #= none:71 =#
        auxiliary_fields = model.auxiliary_fields
        #= none:72 =#
        hydrostatic_pressure = model.pressures.pHY′
        #= none:73 =#
        diffusivities = model.diffusivity_fields
        #= none:74 =#
        forcings = model.forcing
        #= none:75 =#
        clock = model.clock
        #= none:76 =#
        u_immersed_bc = velocities.u.boundary_conditions.immersed
        #= none:77 =#
        v_immersed_bc = velocities.v.boundary_conditions.immersed
        #= none:78 =#
        w_immersed_bc = velocities.w.boundary_conditions.immersed
        #= none:80 =#
        start_momentum_kernel_args = (advection, coriolis, stokes_drift, closure)
        #= none:85 =#
        end_momentum_kernel_args = (buoyancy, background_fields, velocities, tracers, auxiliary_fields, diffusivities)
        #= none:92 =#
        u_kernel_args = tuple(start_momentum_kernel_args..., u_immersed_bc, end_momentum_kernel_args..., forcings, hydrostatic_pressure, clock)
        #= none:96 =#
        v_kernel_args = tuple(start_momentum_kernel_args..., v_immersed_bc, end_momentum_kernel_args..., forcings, hydrostatic_pressure, clock)
        #= none:100 =#
        w_kernel_args = tuple(start_momentum_kernel_args..., w_immersed_bc, end_momentum_kernel_args..., forcings, hydrostatic_pressure, clock)
        #= none:104 =#
        exclude_periphery = true
        #= none:105 =#
        launch!(arch, grid, kernel_parameters, compute_Gu!, tendencies.u, grid, active_cells_map, u_kernel_args; active_cells_map, exclude_periphery)
        #= none:109 =#
        launch!(arch, grid, kernel_parameters, compute_Gv!, tendencies.v, grid, active_cells_map, v_kernel_args; active_cells_map, exclude_periphery)
        #= none:113 =#
        launch!(arch, grid, kernel_parameters, compute_Gw!, tendencies.w, grid, active_cells_map, w_kernel_args; active_cells_map, exclude_periphery)
        #= none:117 =#
        start_tracer_kernel_args = (advection, closure)
        #= none:118 =#
        end_tracer_kernel_args = (buoyancy, biogeochemistry, background_fields, velocities, tracers, auxiliary_fields, diffusivities)
        #= none:121 =#
        for tracer_index = 1:length(tracers)
            #= none:122 =#
            #= none:122 =# @inbounds c_tendency = tendencies[tracer_index + 3]
            #= none:123 =#
            #= none:123 =# @inbounds forcing = forcings[tracer_index + 3]
            #= none:124 =#
            #= none:124 =# @inbounds c_immersed_bc = (tracers[tracer_index]).boundary_conditions.immersed
            #= none:125 =#
            #= none:125 =# @inbounds tracer_name = (keys(tracers))[tracer_index]
            #= none:127 =#
            args = tuple(Val(tracer_index), Val(tracer_name), start_tracer_kernel_args..., c_immersed_bc, end_tracer_kernel_args..., forcing, clock)
            #= none:133 =#
            launch!(arch, grid, kernel_parameters, compute_Gc!, c_tendency, grid, active_cells_map, args; active_cells_map)
            #= none:136 =#
        end
        #= none:138 =#
        return nothing
    end
#= none:145 =#
#= none:145 =# Core.@doc " Calculate the right-hand-side of the u-velocity equation. " #= none:146 =# @kernel(function compute_Gu!(Gu, grid, ::Nothing, args)
            #= none:146 =#
            #= none:147 =#
            (i, j, k) = #= none:147 =# @index(Global, NTuple)
            #= none:148 =#
            #= none:148 =# @inbounds Gu[i, j, k] = u_velocity_tendency(i, j, k, grid, args...)
        end)
#= none:151 =#
#= none:151 =# @kernel function compute_Gu!(Gu, grid, interior_map, args)
        #= none:151 =#
        #= none:152 =#
        idx = #= none:152 =# @index(Global, Linear)
        #= none:153 =#
        (i, j, k) = active_linear_index_to_tuple(idx, interior_map)
        #= none:154 =#
        #= none:154 =# @inbounds Gu[i, j, k] = u_velocity_tendency(i, j, k, grid, args...)
    end
#= none:157 =#
#= none:157 =# Core.@doc " Calculate the right-hand-side of the v-velocity equation. " #= none:158 =# @kernel(function compute_Gv!(Gv, grid, ::Nothing, args)
            #= none:158 =#
            #= none:159 =#
            (i, j, k) = #= none:159 =# @index(Global, NTuple)
            #= none:160 =#
            #= none:160 =# @inbounds Gv[i, j, k] = v_velocity_tendency(i, j, k, grid, args...)
        end)
#= none:163 =#
#= none:163 =# @kernel function compute_Gv!(Gv, grid, interior_map, args)
        #= none:163 =#
        #= none:164 =#
        idx = #= none:164 =# @index(Global, Linear)
        #= none:165 =#
        (i, j, k) = active_linear_index_to_tuple(idx, interior_map)
        #= none:166 =#
        #= none:166 =# @inbounds Gv[i, j, k] = v_velocity_tendency(i, j, k, grid, args...)
    end
#= none:169 =#
#= none:169 =# Core.@doc " Calculate the right-hand-side of the w-velocity equation. " #= none:170 =# @kernel(function compute_Gw!(Gw, grid, ::Nothing, args)
            #= none:170 =#
            #= none:171 =#
            (i, j, k) = #= none:171 =# @index(Global, NTuple)
            #= none:172 =#
            #= none:172 =# @inbounds Gw[i, j, k] = w_velocity_tendency(i, j, k, grid, args...)
        end)
#= none:175 =#
#= none:175 =# @kernel function compute_Gw!(Gw, grid, interior_map, args)
        #= none:175 =#
        #= none:176 =#
        idx = #= none:176 =# @index(Global, Linear)
        #= none:177 =#
        (i, j, k) = active_linear_index_to_tuple(idx, interior_map)
        #= none:178 =#
        #= none:178 =# @inbounds Gw[i, j, k] = w_velocity_tendency(i, j, k, grid, args...)
    end
#= none:185 =#
#= none:185 =# Core.@doc " Calculate the right-hand-side of the tracer advection-diffusion equation. " #= none:186 =# @kernel(function compute_Gc!(Gc, grid, ::Nothing, args)
            #= none:186 =#
            #= none:187 =#
            (i, j, k) = #= none:187 =# @index(Global, NTuple)
            #= none:188 =#
            #= none:188 =# @inbounds Gc[i, j, k] = tracer_tendency(i, j, k, grid, args...)
        end)
#= none:191 =#
#= none:191 =# @kernel function compute_Gc!(Gc, grid, interior_map, args)
        #= none:191 =#
        #= none:192 =#
        idx = #= none:192 =# @index(Global, Linear)
        #= none:193 =#
        (i, j, k) = active_linear_index_to_tuple(idx, interior_map)
        #= none:194 =#
        #= none:194 =# @inbounds Gc[i, j, k] = tracer_tendency(i, j, k, grid, args...)
    end
#= none:201 =#
#= none:201 =# Core.@doc " Apply boundary conditions by adding flux divergences to the right-hand-side. " function compute_boundary_tendency_contributions!(Gⁿ, arch, velocities, tracers, clock, model_fields)
        #= none:202 =#
        #= none:203 =#
        fields = merge(velocities, tracers)
        #= none:205 =#
        foreach((i->begin
                    #= none:205 =#
                    apply_x_bcs!(Gⁿ[i], fields[i], arch, clock, model_fields)
                end), 1:length(fields))
        #= none:206 =#
        foreach((i->begin
                    #= none:206 =#
                    apply_y_bcs!(Gⁿ[i], fields[i], arch, clock, model_fields)
                end), 1:length(fields))
        #= none:207 =#
        foreach((i->begin
                    #= none:207 =#
                    apply_z_bcs!(Gⁿ[i], fields[i], arch, clock, model_fields)
                end), 1:length(fields))
        #= none:209 =#
        return nothing
    end