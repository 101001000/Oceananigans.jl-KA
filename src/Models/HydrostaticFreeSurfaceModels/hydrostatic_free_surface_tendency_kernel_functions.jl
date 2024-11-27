
#= none:1 =#
using Oceananigans.BuoyancyModels
#= none:2 =#
using Oceananigans.Coriolis
#= none:3 =#
using Oceananigans.Operators
#= none:4 =#
using Oceananigans.Operators: ∂xᶠᶜᶜ, ∂yᶜᶠᶜ
#= none:5 =#
using Oceananigans.TurbulenceClosures: ∂ⱼ_τ₁ⱼ, ∂ⱼ_τ₂ⱼ, ∇_dot_qᶜ
#= none:6 =#
using Oceananigans.Biogeochemistry: biogeochemical_transition, biogeochemical_drift_velocity
#= none:7 =#
using Oceananigans.TurbulenceClosures: immersed_∂ⱼ_τ₁ⱼ, immersed_∂ⱼ_τ₂ⱼ, immersed_∂ⱼ_τ₃ⱼ, immersed_∇_dot_qᶜ
#= none:8 =#
using Oceananigans.Advection: div_Uc, U_dot_∇u, U_dot_∇v
#= none:9 =#
using Oceananigans.Forcings: with_advective_forcing
#= none:10 =#
using Oceananigans.TurbulenceClosures: shear_production, buoyancy_flux, dissipation
#= none:11 =#
using Oceananigans.Utils: SumOfArrays
#= none:12 =#
using KernelAbstractions: @private
#= none:14 =#
import Oceananigans.TurbulenceClosures: hydrostatic_turbulent_kinetic_energy_tendency
#= none:16 =#
#= none:16 =# Core.@doc "Return the tendency for the horizontal velocity in the ``x``-direction, or the east-west \ndirection, ``u``, at grid point `i, j, k` for a `HydrostaticFreeSurfaceModel`.\n\nThe tendency for ``u`` is called ``G_u`` and defined via\n\n```\n∂_t u = G_u - ∂_x p_n\n```\n\nwhere `p_n` is the part of the barotropic kinematic pressure that's treated\nimplicitly during time-stepping.\n" #= none:29 =# @inline(function hydrostatic_free_surface_u_velocity_tendency(i, j, k, grid, advection, coriolis, closure, u_immersed_bc, velocities, free_surface, tracers, buoyancy, diffusivities, hydrostatic_pressure_anomaly, auxiliary_fields, forcings, clock)
            #= none:29 =#
            #= none:44 =#
            model_fields = merge(hydrostatic_fields(velocities, free_surface, tracers), auxiliary_fields)
            #= none:46 =#
            return (((((-(U_dot_∇u(i, j, k, grid, advection, velocities)) - explicit_barotropic_pressure_x_gradient(i, j, k, grid, free_surface)) - x_f_cross_U(i, j, k, grid, coriolis, velocities)) - ∂xᶠᶜᶜ(i, j, k, grid, hydrostatic_pressure_anomaly)) - ∂ⱼ_τ₁ⱼ(i, j, k, grid, closure, diffusivities, clock, model_fields, buoyancy)) - immersed_∂ⱼ_τ₁ⱼ(i, j, k, grid, velocities, u_immersed_bc, closure, diffusivities, clock, model_fields)) + forcings.u(i, j, k, grid, clock, hydrostatic_prognostic_fields(velocities, free_surface, tracers))
        end)
#= none:55 =#
#= none:55 =# Core.@doc "Return the tendency for the horizontal velocity in the ``y``-direction, or the east-west \ndirection, ``v``, at grid point `i, j, k` for a `HydrostaticFreeSurfaceModel`.\n\nThe tendency for ``v`` is called ``G_v`` and defined via\n\n```\n∂_t v = G_v - ∂_y p_n\n```\n\nwhere `p_n` is the part of the barotropic kinematic pressure that's treated\nimplicitly during time-stepping.\n" #= none:68 =# @inline(function hydrostatic_free_surface_v_velocity_tendency(i, j, k, grid, advection, coriolis, closure, v_immersed_bc, velocities, free_surface, tracers, buoyancy, diffusivities, hydrostatic_pressure_anomaly, auxiliary_fields, forcings, clock)
            #= none:68 =#
            #= none:83 =#
            model_fields = merge(hydrostatic_fields(velocities, free_surface, tracers), auxiliary_fields)
            #= none:85 =#
            return (((((-(U_dot_∇v(i, j, k, grid, advection, velocities)) - explicit_barotropic_pressure_y_gradient(i, j, k, grid, free_surface)) - y_f_cross_U(i, j, k, grid, coriolis, velocities)) - ∂yᶜᶠᶜ(i, j, k, grid, hydrostatic_pressure_anomaly)) - ∂ⱼ_τ₂ⱼ(i, j, k, grid, closure, diffusivities, clock, model_fields, buoyancy)) - immersed_∂ⱼ_τ₂ⱼ(i, j, k, grid, velocities, v_immersed_bc, closure, diffusivities, clock, model_fields)) + forcings.v(i, j, k, grid, clock, model_fields)
        end)
#= none:94 =#
#= none:94 =# Core.@doc "Return the tendency for a tracer field with index `tracer_index` \nat grid point `i, j, k`.\n\nThe tendency is called ``G_c`` and defined via\n\n```\n∂_t c = G_c\n```\n\nwhere `c = C[tracer_index]`. \n" #= none:106 =# @inline(function hydrostatic_free_surface_tracer_tendency(i, j, k, grid, val_tracer_index::Val{tracer_index}, val_tracer_name, advection, closure, c_immersed_bc, buoyancy, biogeochemistry, velocities, free_surface, tracers, diffusivities, auxiliary_fields, forcing, clock) where tracer_index
            #= none:106 =#
            #= none:122 =#
            #= none:122 =# @inbounds c = tracers[tracer_index]
            #= none:123 =#
            model_fields = merge(hydrostatic_fields(velocities, free_surface, tracers), auxiliary_fields)
            #= none:125 =#
            biogeochemical_velocities = biogeochemical_drift_velocity(biogeochemistry, val_tracer_name)
            #= none:127 =#
            total_velocities = (u = SumOfArrays{2}(velocities.u, biogeochemical_velocities.u), v = SumOfArrays{2}(velocities.v, biogeochemical_velocities.v), w = SumOfArrays{2}(velocities.w, biogeochemical_velocities.w))
            #= none:131 =#
            total_velocities = with_advective_forcing(forcing, total_velocities)
            #= none:133 =#
            return ((-(div_Uc(i, j, k, grid, advection, total_velocities, c)) - ∇_dot_qᶜ(i, j, k, grid, closure, diffusivities, val_tracer_index, c, clock, model_fields, buoyancy)) - immersed_∇_dot_qᶜ(i, j, k, grid, c, c_immersed_bc, closure, diffusivities, val_tracer_index, clock, model_fields)) + biogeochemical_transition(i, j, k, grid, biogeochemistry, val_tracer_name, clock, model_fields) + forcing(i, j, k, grid, clock, model_fields)
        end)
#= none:140 =#
#= none:140 =# Core.@doc "Return the tendency for an explicit free surface at horizontal grid point `i, j`.\n\nThe tendency is called ``G_η`` and defined via\n\n```\n∂_t η = G_η\n```\n" #= none:149 =# @inline(function free_surface_tendency(i, j, grid, velocities, free_surface, tracers, auxiliary_fields, forcings, clock)
            #= none:149 =#
            #= none:157 =#
            k_top = grid.Nz + 1
            #= none:158 =#
            model_fields = merge(hydrostatic_fields(velocities, free_surface, tracers), auxiliary_fields)
            #= none:160 =#
            return #= none:160 =# @inbounds(velocities.w[i, j, k_top] + forcings.η(i, j, k_top, grid, clock, model_fields))
        end)