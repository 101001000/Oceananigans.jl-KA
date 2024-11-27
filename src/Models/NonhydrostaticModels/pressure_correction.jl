
#= none:1 =#
import Oceananigans.TimeSteppers: calculate_pressure_correction!, pressure_correct_velocities!
#= none:3 =#
#= none:3 =# Core.@doc "    calculate_pressure_correction!(model::NonhydrostaticModel, Δt)\n\nCalculate the (nonhydrostatic) pressure correction associated `tendencies`, `velocities`, and step size `Δt`.\n" function calculate_pressure_correction!(model::NonhydrostaticModel, Δt)
        #= none:8 =#
        #= none:11 =#
        foreach(mask_immersed_field!, model.velocities)
        #= none:13 =#
        fill_halo_regions!(model.velocities, model.clock, fields(model))
        #= none:15 =#
        solve_for_pressure!(model.pressures.pNHS, model.pressure_solver, Δt, model.velocities)
        #= none:17 =#
        fill_halo_regions!(model.pressures.pNHS)
        #= none:19 =#
        return nothing
    end
#= none:26 =#
#= none:26 =# Core.@doc "Update the predictor velocities u, v, and w with the non-hydrostatic pressure via\n\n    `u^{n+1} = u^n - δₓp_{NH} / Δx * Δt`\n" #= none:31 =# @kernel(function _pressure_correct_velocities!(U, grid, Δt, pNHS)
            #= none:31 =#
            #= none:32 =#
            (i, j, k) = #= none:32 =# @index(Global, NTuple)
            #= none:34 =#
            #= none:34 =# @inbounds U.u[i, j, k] -= ∂xᶠᶜᶜ(i, j, k, grid, pNHS) * Δt
            #= none:35 =#
            #= none:35 =# @inbounds U.v[i, j, k] -= ∂yᶜᶠᶜ(i, j, k, grid, pNHS) * Δt
            #= none:36 =#
            #= none:36 =# @inbounds U.w[i, j, k] -= ∂zᶜᶜᶠ(i, j, k, grid, pNHS) * Δt
        end)
#= none:39 =#
#= none:39 =# Core.@doc "Update the solution variables (velocities and tracers)." function pressure_correct_velocities!(model::NonhydrostaticModel, Δt)
        #= none:40 =#
        #= none:42 =#
        launch!(model.architecture, model.grid, :xyz, _pressure_correct_velocities!, model.velocities, model.grid, Δt, model.pressures.pNHS)
        #= none:49 =#
        return nothing
    end