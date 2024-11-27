
#= none:1 =#
using Oceananigans.Advection
#= none:2 =#
using Oceananigans.BuoyancyModels
#= none:3 =#
using Oceananigans.Coriolis
#= none:4 =#
using Oceananigans.Operators
#= none:5 =#
using Oceananigans.StokesDrifts
#= none:7 =#
using Oceananigans.Biogeochemistry: biogeochemical_transition, biogeochemical_drift_velocity
#= none:8 =#
using Oceananigans.TurbulenceClosures: ∂ⱼ_τ₁ⱼ, ∂ⱼ_τ₂ⱼ, ∂ⱼ_τ₃ⱼ, ∇_dot_qᶜ
#= none:9 =#
using Oceananigans.TurbulenceClosures: immersed_∂ⱼ_τ₁ⱼ, immersed_∂ⱼ_τ₂ⱼ, immersed_∂ⱼ_τ₃ⱼ, immersed_∇_dot_qᶜ
#= none:10 =#
using Oceananigans.Forcings: with_advective_forcing
#= none:12 =#
#= none:12 =# Core.@doc "return the ``x``-gradient of hydrostatic pressure" hydrostatic_pressure_gradient_x(i, j, k, grid, hydrostatic_pressure) = begin
            #= none:13 =#
            ∂xᶠᶜᶜ(i, j, k, grid, hydrostatic_pressure)
        end
#= none:14 =#
hydrostatic_pressure_gradient_x(i, j, k, grid, ::Nothing) = begin
        #= none:14 =#
        zero(grid)
    end
#= none:16 =#
#= none:16 =# Core.@doc "return the ``y``-gradient of hydrostatic pressure" hydrostatic_pressure_gradient_y(i, j, k, grid, hydrostatic_pressure) = begin
            #= none:17 =#
            ∂yᶜᶠᶜ(i, j, k, grid, hydrostatic_pressure)
        end
#= none:18 =#
hydrostatic_pressure_gradient_y(i, j, k, grid, ::Nothing) = begin
        #= none:18 =#
        zero(grid)
    end
#= none:20 =#
#= none:20 =# Core.@doc "    $(SIGNATURES)\n\nReturn the tendency for the horizontal velocity in the ``x``-direction, or the east-west\ndirection, ``u``, at grid point `i, j, k`.\n\nThe tendency for ``u`` is called ``G_u`` and defined via\n\n```math\n∂_t u = G_u - ∂_x p_n ,\n```\n\nwhere ``∂_x p_n`` is the non-hydrostatic kinematic pressure gradient in the ``x``-direction.\n\n`coriolis`, `stokes_drift`, and `closure` are types encoding information about Coriolis\nforces, surface waves, and the prescribed turbulence closure.\n\n`background_fields` is a `NamedTuple` containing background velocity and tracer\n`FunctionFields`.\n\nThe arguments `velocities`, `tracers`, and `diffusivities` are `NamedTuple`s with the three\nvelocity components, tracer fields, and precalculated diffusivities where applicable.\n`forcings` is a named tuple of forcing functions. `hydrostatic_pressure` is the hydrostatic\npressure anomaly.\n\n`clock` keeps track of `clock.time` and `clock.iteration`.\n" #= none:47 =# @inline(function u_velocity_tendency(i, j, k, grid, advection, coriolis, stokes_drift, closure, u_immersed_bc, buoyancy, background_fields, velocities, tracers, auxiliary_fields, diffusivities, forcings, hydrostatic_pressure, clock)
            #= none:47 =#
            #= none:63 =#
            model_fields = merge(velocities, tracers, auxiliary_fields)
            #= none:65 =#
            total_velocities = (u = SumOfArrays{2}(velocities.u, background_fields.velocities.u), v = SumOfArrays{2}(velocities.v, background_fields.velocities.v), w = SumOfArrays{2}(velocities.w, background_fields.velocities.w))
            #= none:69 =#
            total_velocities = with_advective_forcing(forcings.u, total_velocities)
            #= none:71 =#
            return ((((((-(div_𝐯u(i, j, k, grid, advection, total_velocities, velocities.u)) - div_𝐯u(i, j, k, grid, advection, velocities, background_fields.velocities.u)) + x_dot_g_bᶠᶜᶜ(i, j, k, grid, buoyancy, tracers)) - x_f_cross_U(i, j, k, grid, coriolis, velocities)) - hydrostatic_pressure_gradient_x(i, j, k, grid, hydrostatic_pressure)) - ∂ⱼ_τ₁ⱼ(i, j, k, grid, closure, diffusivities, clock, model_fields, buoyancy)) - immersed_∂ⱼ_τ₁ⱼ(i, j, k, grid, velocities, u_immersed_bc, closure, diffusivities, clock, model_fields)) + x_curl_Uˢ_cross_U(i, j, k, grid, stokes_drift, velocities, clock.time) + ∂t_uˢ(i, j, k, grid, stokes_drift, clock.time) + forcings.u(i, j, k, grid, clock, model_fields)
        end)
#= none:83 =#
#= none:83 =# Core.@doc "    $(SIGNATURES)\n\nReturn the tendency for the horizontal velocity in the ``y``-direction, or the north-south\ndirection, ``v``, at grid point `i, j, k`.\n\nThe tendency for ``v`` is called ``G_v`` and defined via\n\n```math\n∂_t v = G_v - ∂_y p_n ,\n```\n\nwhere ``∂_y p_n`` is the non-hydrostatic kinematic pressure gradient in the ``y``-direction.\n\n`coriolis`, `stokes_drift`, and `closure` are types encoding information about Coriolis\nforces, surface waves, and the prescribed turbulence closure.\n\n`background_fields` is a `NamedTuple` containing background velocity and tracer\n`FunctionFields`.\n\nThe arguments `velocities`, `tracers`, and `diffusivities` are `NamedTuple`s with the three\nvelocity components, tracer fields, and precalculated diffusivities where applicable.\n`forcings` is a named tuple of forcing functions. `hydrostatic_pressure` is the hydrostatic\npressure anomaly.\n\n`clock` keeps track of `clock.time` and `clock.iteration`.\n" #= none:110 =# @inline(function v_velocity_tendency(i, j, k, grid, advection, coriolis, stokes_drift, closure, v_immersed_bc, buoyancy, background_fields, velocities, tracers, auxiliary_fields, diffusivities, forcings, hydrostatic_pressure, clock)
            #= none:110 =#
            #= none:126 =#
            model_fields = merge(velocities, tracers, auxiliary_fields)
            #= none:128 =#
            total_velocities = (u = SumOfArrays{2}(velocities.u, background_fields.velocities.u), v = SumOfArrays{2}(velocities.v, background_fields.velocities.v), w = SumOfArrays{2}(velocities.w, background_fields.velocities.w))
            #= none:132 =#
            total_velocities = with_advective_forcing(forcings.v, total_velocities)
            #= none:134 =#
            return ((((((-(div_𝐯v(i, j, k, grid, advection, total_velocities, velocities.v)) - div_𝐯v(i, j, k, grid, advection, velocities, background_fields.velocities.v)) + y_dot_g_bᶜᶠᶜ(i, j, k, grid, buoyancy, tracers)) - y_f_cross_U(i, j, k, grid, coriolis, velocities)) - hydrostatic_pressure_gradient_y(i, j, k, grid, hydrostatic_pressure)) - ∂ⱼ_τ₂ⱼ(i, j, k, grid, closure, diffusivities, clock, model_fields, buoyancy)) - immersed_∂ⱼ_τ₂ⱼ(i, j, k, grid, velocities, v_immersed_bc, closure, diffusivities, clock, model_fields)) + y_curl_Uˢ_cross_U(i, j, k, grid, stokes_drift, velocities, clock.time) + ∂t_vˢ(i, j, k, grid, stokes_drift, clock.time) + forcings.v(i, j, k, grid, clock, model_fields)
        end)
#= none:147 =#
#= none:147 =# @inline maybe_z_dot_g_bᶜᶜᶠ(i, j, k, grid, hydrostatic_pressure, buoyancy, tracers) = begin
            #= none:147 =#
            zero(grid)
        end
#= none:148 =#
#= none:148 =# @inline maybe_z_dot_g_bᶜᶜᶠ(i, j, k, grid, ::Nothing, buoyancy, tracers) = begin
            #= none:148 =#
            z_dot_g_bᶜᶜᶠ(i, j, k, grid, buoyancy, tracers)
        end
#= none:151 =#
#= none:151 =# Core.@doc "    $(SIGNATURES)\n\nReturn the tendency for the vertical velocity ``w`` at grid point `i, j, k`.\n\nThe tendency for ``w`` is called ``G_w`` and defined via\n\n```math\n∂_t w = G_w - ∂_z p_n ,\n```\n\nwhere ``∂_z p_n`` is the non-hydrostatic kinematic pressure gradient in the ``z``-direction.\n\n`coriolis`, `stokes_drift`, and `closure` are types encoding information about Coriolis\nforces, surface waves, and the prescribed turbulence closure.\n\n`background_fields` is a `NamedTuple` containing background velocity and tracer\n`FunctionFields`.\n\nThe arguments `velocities`, `tracers`, and `diffusivities` are `NamedTuple`s with the three\nvelocity components, tracer fields, and precalculated diffusivities where applicable.\n`forcings` is a named tuple of forcing functions.\n\n`clock` keeps track of `clock.time` and `clock.iteration`.\n" #= none:176 =# @inline(function w_velocity_tendency(i, j, k, grid, advection, coriolis, stokes_drift, closure, w_immersed_bc, buoyancy, background_fields, velocities, tracers, auxiliary_fields, diffusivities, forcings, hydrostatic_pressure, clock)
            #= none:176 =#
            #= none:192 =#
            model_fields = merge(velocities, tracers, auxiliary_fields)
            #= none:194 =#
            total_velocities = (u = SumOfArrays{2}(velocities.u, background_fields.velocities.u), v = SumOfArrays{2}(velocities.v, background_fields.velocities.v), w = SumOfArrays{2}(velocities.w, background_fields.velocities.w))
            #= none:198 =#
            total_velocities = with_advective_forcing(forcings.w, total_velocities)
            #= none:200 =#
            return (((((-(div_𝐯w(i, j, k, grid, advection, total_velocities, velocities.w)) - div_𝐯w(i, j, k, grid, advection, velocities, background_fields.velocities.w)) + maybe_z_dot_g_bᶜᶜᶠ(i, j, k, grid, hydrostatic_pressure, buoyancy, tracers)) - z_f_cross_U(i, j, k, grid, coriolis, velocities)) - ∂ⱼ_τ₃ⱼ(i, j, k, grid, closure, diffusivities, clock, model_fields, buoyancy)) - immersed_∂ⱼ_τ₃ⱼ(i, j, k, grid, velocities, w_immersed_bc, closure, diffusivities, clock, model_fields)) + z_curl_Uˢ_cross_U(i, j, k, grid, stokes_drift, velocities, clock.time) + ∂t_wˢ(i, j, k, grid, stokes_drift, clock.time) + forcings.w(i, j, k, grid, clock, model_fields)
        end)
#= none:211 =#
#= none:211 =# Core.@doc "    $(SIGNATURES)\n\nReturn the tendency for a tracer field with index `tracer_index`\nat grid point `i, j, k`.\n\nThe tendency is called ``G_c`` and defined via\n\n```math\n∂_t c = G_c ,\n```\n\nwhere `c = C[tracer_index]`.\n\n`closure` and `buoyancy` are types encoding information about the prescribed\nturbulence closure and buoyancy model.\n\n`background_fields` is a `NamedTuple` containing background velocity and tracer\n`FunctionFields`.\n\nThe arguments `velocities`, `tracers`, and `diffusivities` are `NamedTuple`s with the three\nvelocity components, tracer fields, and precalculated diffusivities where applicable.\n`forcings` is a named tuple of forcing functions.\n\n`clock` keeps track of `clock.time` and `clock.iteration`.\n" #= none:237 =# @inline(function tracer_tendency(i, j, k, grid, val_tracer_index::Val{tracer_index}, val_tracer_name, advection, closure, c_immersed_bc, buoyancy, biogeochemistry, background_fields, velocities, tracers, auxiliary_fields, diffusivities, forcing, clock) where tracer_index
            #= none:237 =#
            #= none:253 =#
            #= none:253 =# @inbounds c = tracers[tracer_index]
            #= none:254 =#
            #= none:254 =# @inbounds background_fields_c = background_fields.tracers[tracer_index]
            #= none:255 =#
            model_fields = merge(velocities, tracers, auxiliary_fields)
            #= none:257 =#
            biogeochemical_velocities = biogeochemical_drift_velocity(biogeochemistry, val_tracer_name)
            #= none:259 =#
            total_velocities = (u = SumOfArrays{3}(velocities.u, background_fields.velocities.u, biogeochemical_velocities.u), v = SumOfArrays{3}(velocities.v, background_fields.velocities.v, biogeochemical_velocities.v), w = SumOfArrays{3}(velocities.w, background_fields.velocities.w, biogeochemical_velocities.w))
            #= none:263 =#
            total_velocities = with_advective_forcing(forcing, total_velocities)
            #= none:265 =#
            return (((-(div_Uc(i, j, k, grid, advection, total_velocities, c)) - div_Uc(i, j, k, grid, advection, velocities, background_fields_c)) - ∇_dot_qᶜ(i, j, k, grid, closure, diffusivities, val_tracer_index, c, clock, model_fields, buoyancy)) - immersed_∇_dot_qᶜ(i, j, k, grid, c, c_immersed_bc, closure, diffusivities, val_tracer_index, clock, model_fields)) + biogeochemical_transition(i, j, k, grid, biogeochemistry, val_tracer_name, clock, model_fields) + forcing(i, j, k, grid, clock, model_fields)
        end)