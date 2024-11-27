
#= none:1 =#
using Oceananigans.Advection
#= none:2 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid, GridFittedBoundary
#= none:3 =#
using Oceananigans.Coriolis
#= none:4 =#
using Oceananigans.Operators
#= none:5 =#
using Oceananigans.TurbulenceClosures: ∇_dot_qᶜ, ∂ⱼ_τ₁ⱼ, ∂ⱼ_τ₂ⱼ
#= none:7 =#
#= none:7 =# @inline half_g_h²(i, j, k, grid, h, g) = begin
            #= none:7 =#
            #= none:7 =# @inbounds (1 / 2) * g * h[i, j, k] ^ 2
        end
#= none:8 =#
#= none:8 =# @inline h_plus_hB(i, j, k, grid, h, hB) = begin
            #= none:8 =#
            #= none:8 =# @inbounds h[i, j, k] + hB[i, j, k]
        end
#= none:10 =#
#= none:10 =# @inline x_pressure_gradient(i, j, k, grid, g, h, hB, formulation) = begin
            #= none:10 =#
            ∂xᶠᶜᶜ(i, j, k, grid, half_g_h², h, g)
        end
#= none:11 =#
#= none:11 =# @inline y_pressure_gradient(i, j, k, grid, g, h, hB, formulation) = begin
            #= none:11 =#
            ∂yᶜᶠᶜ(i, j, k, grid, half_g_h², h, g)
        end
#= none:13 =#
#= none:13 =# @inline x_pressure_gradient(i, j, k, grid, g, h, hB, ::VectorInvariantFormulation) = begin
            #= none:13 =#
            g * ∂xᶠᶜᶜ(i, j, k, grid, h_plus_hB, h, hB)
        end
#= none:14 =#
#= none:14 =# @inline y_pressure_gradient(i, j, k, grid, g, h, hB, ::VectorInvariantFormulation) = begin
            #= none:14 =#
            g * ∂yᶜᶠᶜ(i, j, k, grid, h_plus_hB, h, hB)
        end
#= none:16 =#
#= none:16 =# @inline bathymetry_contribution_x(i, j, k, grid, g, h, hB, formulation) = begin
            #= none:16 =#
            g * h[i, j, k] * ∂xᶠᶜᶜ(i, j, k, grid, hB)
        end
#= none:17 =#
#= none:17 =# @inline bathymetry_contribution_y(i, j, k, grid, g, h, hB, formulation) = begin
            #= none:17 =#
            g * h[i, j, k] * ∂yᶜᶠᶜ(i, j, k, grid, hB)
        end
#= none:19 =#
#= none:19 =# @inline bathymetry_contribution_x(i, j, k, grid, g, h, hB, ::VectorInvariantFormulation) = begin
            #= none:19 =#
            zero(grid)
        end
#= none:20 =#
#= none:20 =# @inline bathymetry_contribution_y(i, j, k, grid, g, h, hB, ::VectorInvariantFormulation) = begin
            #= none:20 =#
            zero(grid)
        end
#= none:22 =#
#= none:22 =# Core.@doc "Compute the tendency for the x-directional transport, uh\n" #= none:25 =# @inline(function uh_solution_tendency(i, j, k, grid, gravitational_acceleration, advection, velocities, coriolis, closure, bathymetry, solution, tracers, diffusivities, forcings, clock, formulation)
            #= none:25 =#
            #= none:39 =#
            g = gravitational_acceleration
            #= none:41 =#
            model_fields = shallow_water_fields(velocities, tracers, solution, formulation)
            #= none:43 =#
            return ((((-(div_mom_u(i, j, k, grid, advection, solution, formulation)) - x_pressure_gradient(i, j, k, grid, g, solution.h, bathymetry, formulation)) - x_f_cross_U(i, j, k, grid, coriolis, solution)) - bathymetry_contribution_x(i, j, k, grid, g, solution.h, bathymetry, formulation)) - sw_∂ⱼ_τ₁ⱼ(i, j, k, grid, closure, diffusivities, clock, model_fields, formulation)) + (forcings[1])(i, j, k, grid, clock, merge(solution, tracers))
        end)
#= none:51 =#
#= none:51 =# Core.@doc "Compute the tendency for the y-directional transport, vh.\n" #= none:54 =# @inline(function vh_solution_tendency(i, j, k, grid, gravitational_acceleration, advection, velocities, coriolis, closure, bathymetry, solution, tracers, diffusivities, forcings, clock, formulation)
            #= none:54 =#
            #= none:68 =#
            g = gravitational_acceleration
            #= none:70 =#
            model_fields = shallow_water_fields(velocities, tracers, solution, formulation)
            #= none:72 =#
            return ((((-(div_mom_v(i, j, k, grid, advection, solution, formulation)) - y_pressure_gradient(i, j, k, grid, g, solution.h, bathymetry, formulation)) - y_f_cross_U(i, j, k, grid, coriolis, solution)) - bathymetry_contribution_y(i, j, k, grid, g, solution.h, bathymetry, formulation)) - sw_∂ⱼ_τ₂ⱼ(i, j, k, grid, closure, diffusivities, clock, model_fields, formulation)) + (forcings[2])(i, j, k, grid, clock, merge(solution, tracers))
        end)
#= none:80 =#
#= none:80 =# Core.@doc "Compute the tendency for the height, h.\n" #= none:83 =# @inline(function h_solution_tendency(i, j, k, grid, gravitational_acceleration, advection, coriolis, closure, solution, tracers, diffusivities, forcings, clock, formulation)
            #= none:83 =#
            #= none:95 =#
            return -(div_Uh(i, j, k, grid, advection, solution, formulation)) + forcings.h(i, j, k, grid, clock, merge(solution, tracers))
        end)
#= none:99 =#
#= none:99 =# @inline function tracer_tendency(i, j, k, grid, val_tracer_index::Val{tracer_index}, advection, closure, solution, tracers, diffusivities, forcing, clock, formulation) where tracer_index
        #= none:99 =#
        #= none:110 =#
        #= none:110 =# @inbounds c = tracers[tracer_index]
        #= none:112 =#
        return -(div_Uc(i, j, k, grid, advection, solution, c, formulation)) + c_div_U(i, j, k, grid, solution, c, formulation) + forcing(i, j, k, grid, clock, merge(solution, tracers))
    end