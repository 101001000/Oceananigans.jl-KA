
#= none:1 =#
using Oceananigans.Fields: FunctionField, location
#= none:2 =#
using Oceananigans.Utils: @apply_regionally, apply_regionally!
#= none:4 =#
mutable struct QuasiAdamsBashforth2TimeStepper{FT, GT, IT} <: AbstractTimeStepper
    #= none:5 =#
    χ::FT
    #= none:6 =#
    Gⁿ::GT
    #= none:7 =#
    G⁻::GT
    #= none:8 =#
    implicit_solver::IT
end
#= none:11 =#
#= none:11 =# Core.@doc "    QuasiAdamsBashforth2TimeStepper(grid, tracers,\n                                    χ = 0.1;\n                                    implicit_solver = nothing,\n                                    Gⁿ = TendencyFields(grid, tracers),\n                                    G⁻ = TendencyFields(grid, tracers))\n\nReturn a 2nd-order quasi Adams-Bashforth (AB2) time stepper (`QuasiAdamsBashforth2TimeStepper`)\non `grid`, with `tracers`, and AB2 parameter `χ`. The tendency fields `Gⁿ` and `G⁻` can be\nspecified via  optional `kwargs`.\n\nThe 2nd-order quasi Adams-Bashforth timestepper steps forward the state `Uⁿ` by `Δt` via\n\n```julia\nUⁿ⁺¹ = Uⁿ + Δt * [(3/2 + χ) * Gⁿ - (1/2 + χ) * Gⁿ⁻¹]\n```\n\nwhere `Uⁿ` is the state at the ``n``-th timestep, `Gⁿ` is the tendency\nat the ``n``-th timestep, and `Gⁿ⁻¹` is the tendency at the previous\ntimestep (`G⁻`).\n\n!!! note \"First timestep\"\n    For the first timestep, since there are no saved tendencies from the previous timestep,\n    the `QuasiAdamsBashforth2TimeStepper` performs an Euler timestep:\n\n    ```julia\n    Uⁿ⁺¹ = Uⁿ + Δt * Gⁿ\n    ```\n" function QuasiAdamsBashforth2TimeStepper(grid, tracers, χ = 0.1; implicit_solver::IT = nothing, Gⁿ = TendencyFields(grid, tracers), G⁻ = TendencyFields(grid, tracers)) where IT
        #= none:40 =#
        #= none:46 =#
        FT = eltype(grid)
        #= none:47 =#
        GT = typeof(Gⁿ)
        #= none:48 =#
        χ = convert(FT, χ)
        #= none:50 =#
        return QuasiAdamsBashforth2TimeStepper{FT, GT, IT}(χ, Gⁿ, G⁻, implicit_solver)
    end
#= none:53 =#
reset!(timestepper::QuasiAdamsBashforth2TimeStepper) = begin
        #= none:53 =#
        nothing
    end
#= none:59 =#
#= none:59 =# Core.@doc "    time_step!(model::AbstractModel{<:QuasiAdamsBashforth2TimeStepper}, Δt; euler=false)\n\nStep forward `model` one time step `Δt` with a 2nd-order Adams-Bashforth method and\npressure-correction substep. Setting `euler=true` will take a forward Euler time step.\nThe tendencies are calculated by the `update_step!` at the end of the `time_step!` function.\n\nThe steps of the Quasi-Adams-Bashforth second-order (AB2) algorithm are:\n\n1. If this the first time step (`model.clock.iteration == 0`), then call `update_state!` and calculate the tendencies.\n2. Advance tracers in time and compute predictor velocities (including implicit vertical diffusion).\n3. Solve the elliptic equation for pressure (three dimensional for the non-hydrostatic model, two-dimensional for the hydrostatic model).\n4. Correct the velocities based on the results of step 3.\n5. Store the old tendencies.\n6. Update the model state.\n7. Compute tendencies for the next time step\n" function time_step!(model::AbstractModel{<:QuasiAdamsBashforth2TimeStepper}, Δt; callbacks = [], euler = false)
        #= none:76 =#
        #= none:79 =#
        Δt == 0 && #= none:79 =# @warn("Δt == 0 may cause model blowup!")
        #= none:82 =#
        model.clock.iteration == 0 && update_state!(model, callbacks)
        #= none:84 =#
        ab2_timestepper = model.timestepper
        #= none:92 =#
        euler = euler || Δt != model.clock.last_Δt
        #= none:95 =#
        minus_point_five = convert(eltype(model.grid), -0.5)
        #= none:96 =#
        χ = ifelse(euler, minus_point_five, ab2_timestepper.χ)
        #= none:99 =#
        χ₀ = ab2_timestepper.χ
        #= none:100 =#
        ab2_timestepper.χ = χ
        #= none:104 =#
        if euler
            #= none:105 =#
            #= none:105 =# @debug "Taking a forward Euler step."
            #= none:106 =#
            for field = ab2_timestepper.G⁻
                #= none:107 =#
                !(isnothing(field)) && #= none:107 =# @apply_regionally(fill!(field, 0))
                #= none:108 =#
            end
        end
        #= none:112 =#
        model.clock.iteration == 0 && update_state!(model, callbacks; compute_tendencies = true)
        #= none:114 =#
        ab2_step!(model, Δt)
        #= none:116 =#
        tick!(model.clock, Δt)
        #= none:117 =#
        model.clock.last_Δt = Δt
        #= none:118 =#
        model.clock.last_stage_Δt = Δt
        #= none:120 =#
        calculate_pressure_correction!(model, Δt)
        #= none:121 =#
        #= none:121 =# @apply_regionally correct_velocities_and_store_tendencies!(model, Δt)
        #= none:123 =#
        update_state!(model, callbacks; compute_tendencies = true)
        #= none:124 =#
        step_lagrangian_particles!(model, Δt)
        #= none:127 =#
        ab2_timestepper.χ = χ₀
        #= none:129 =#
        return nothing
    end
#= none:132 =#
function correct_velocities_and_store_tendencies!(model, Δt)
    #= none:132 =#
    #= none:133 =#
    pressure_correct_velocities!(model, Δt)
    #= none:134 =#
    store_tendencies!(model)
    #= none:135 =#
    return nothing
end
#= none:142 =#
#= none:142 =# Core.@doc " Generic implementation. " function ab2_step!(model, Δt)
        #= none:143 =#
        #= none:145 =#
        grid = model.grid
        #= none:146 =#
        arch = architecture(grid)
        #= none:147 =#
        model_fields = prognostic_fields(model)
        #= none:148 =#
        χ = model.timestepper.χ
        #= none:150 =#
        for (i, field) = enumerate(model_fields)
            #= none:151 =#
            kernel_args = (field, Δt, χ, model.timestepper.Gⁿ[i], model.timestepper.G⁻[i])
            #= none:152 =#
            launch!(arch, grid, :xyz, ab2_step_field!, kernel_args...; exclude_periphery = true)
            #= none:155 =#
            tracer_index = Val(i - 3)
            #= none:157 =#
            implicit_step!(field, model.timestepper.implicit_solver, model.closure, model.diffusivity_fields, tracer_index, model.clock, Δt)
            #= none:164 =#
        end
        #= none:166 =#
        return nothing
    end
#= none:169 =#
#= none:169 =# Core.@doc "Time step velocity fields via the 2nd-order quasi Adams-Bashforth method\n\n    `U^{n+1} = U^n + Δt ((3/2 + χ) * G^{n} - (1/2 + χ) G^{n-1})`\n\n" #= none:175 =# @kernel(function ab2_step_field!(u, Δt, χ, Gⁿ, G⁻)
            #= none:175 =#
            #= none:176 =#
            (i, j, k) = #= none:176 =# @index(Global, NTuple)
            #= none:178 =#
            FT = eltype(χ)
            #= none:179 =#
            one_point_five = convert(FT, 1.5)
            #= none:180 =#
            oh_point_five = convert(FT, 0.5)
            #= none:182 =#
            #= none:182 =# @inbounds u[i, j, k] += convert(FT, Δt) * ((one_point_five + χ) * Gⁿ[i, j, k] - (oh_point_five + χ) * G⁻[i, j, k])
        end)
#= none:185 =#
#= none:185 =# @kernel ab2_step_field!(::FunctionField, Δt, χ, Gⁿ, G⁻) = begin
            #= none:185 =#
            nothing
        end