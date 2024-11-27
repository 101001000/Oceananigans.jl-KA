
#= none:1 =#
using Oceananigans.Architectures: architecture
#= none:2 =#
using Oceananigans: fields
#= none:4 =#
#= none:4 =# Core.@doc "    RungeKutta3TimeStepper{FT, TG} <: AbstractTimeStepper\n\nHolds parameters and tendency fields for a low storage, third-order Runge-Kutta-Wray\ntime-stepping scheme described by [LeMoin1991](@citet).\n" struct RungeKutta3TimeStepper{FT, TG, TI} <: AbstractTimeStepper
        #= none:11 =#
        γ¹::FT
        #= none:12 =#
        γ²::FT
        #= none:13 =#
        γ³::FT
        #= none:14 =#
        ζ²::FT
        #= none:15 =#
        ζ³::FT
        #= none:16 =#
        Gⁿ::TG
        #= none:17 =#
        G⁻::TG
        #= none:18 =#
        implicit_solver::TI
    end
#= none:21 =#
#= none:21 =# Core.@doc "    RungeKutta3TimeStepper(grid, tracers;\n                           implicit_solver = nothing,\n                           Gⁿ = TendencyFields(grid, tracers),\n                           G⁻ = TendencyFields(grid, tracers))\n\nReturn a 3rd-order Runge0Kutta timestepper (`RungeKutta3TimeStepper`) on `grid` and with `tracers`.\nThe tendency fields `Gⁿ` and `G⁻` can be specified via  optional `kwargs`.\n\nThe scheme described by [LeMoin1991](@citet). In a nutshel, the 3rd-order\nRunge Kutta timestepper steps forward the state `Uⁿ` by `Δt` via 3 substeps. A pressure correction\nstep is applied after at each substep.\n\nThe state `U` after each substep `m` is\n\n```julia\nUᵐ⁺¹ = Uᵐ + Δt * (γᵐ * Gᵐ + ζᵐ * Gᵐ⁻¹)\n```\n\nwhere `Uᵐ` is the state at the ``m``-th substep, `Gᵐ` is the tendency\nat the ``m``-th substep, `Gᵐ⁻¹` is the tendency at the previous substep,\nand constants ``γ¹ = 8/15``, ``γ² = 5/12``, ``γ³ = 3/4``,\n``ζ¹ = 0``, ``ζ² = -17/60``, ``ζ³ = -5/12``.\n\nThe state at the first substep is taken to be the one that corresponds to the ``n``-th timestep,\n`U¹ = Uⁿ`, and the state after the third substep is then the state at the `Uⁿ⁺¹ = U⁴`.\n" function RungeKutta3TimeStepper(grid, tracers; implicit_solver::TI = nothing, Gⁿ::TG = TendencyFields(grid, tracers), G⁻ = TendencyFields(grid, tracers)) where {TI, TG}
        #= none:48 =#
        #= none:53 =#
        !(isnothing(implicit_solver)) && #= none:54 =# @warn("Implicit-explicit time-stepping with RungeKutta3TimeStepper is not tested. " * "\n implicit_solver: $(typeof(implicit_solver))")
        #= none:57 =#
        γ¹ = 8 // 15
        #= none:58 =#
        γ² = 5 // 12
        #= none:59 =#
        γ³ = 3 // 4
        #= none:61 =#
        ζ² = -17 // 60
        #= none:62 =#
        ζ³ = -5 // 12
        #= none:64 =#
        FT = eltype(grid)
        #= none:66 =#
        return RungeKutta3TimeStepper{FT, TG, TI}(γ¹, γ², γ³, ζ², ζ³, Gⁿ, G⁻, implicit_solver)
    end
#= none:73 =#
#= none:73 =# Core.@doc "    time_step!(model::AbstractModel{<:RungeKutta3TimeStepper}, Δt)\n\nStep forward `model` one time step `Δt` with a 3rd-order Runge-Kutta method.\nThe 3rd-order Runge-Kutta method takes three intermediate substep stages to\nachieve a single timestep. A pressure correction step is applied at each intermediate\nstage.\n" function time_step!(model::AbstractModel{<:RungeKutta3TimeStepper}, Δt; callbacks = [])
        #= none:81 =#
        #= none:82 =#
        Δt == 0 && #= none:82 =# @warn("Δt == 0 may cause model blowup!")
        #= none:85 =#
        model.clock.iteration == 0 && update_state!(model, callbacks; compute_tendencies = true)
        #= none:87 =#
        γ¹ = model.timestepper.γ¹
        #= none:88 =#
        γ² = model.timestepper.γ²
        #= none:89 =#
        γ³ = model.timestepper.γ³
        #= none:91 =#
        ζ² = model.timestepper.ζ²
        #= none:92 =#
        ζ³ = model.timestepper.ζ³
        #= none:94 =#
        first_stage_Δt = γ¹ * Δt
        #= none:95 =#
        second_stage_Δt = (γ² + ζ²) * Δt
        #= none:96 =#
        third_stage_Δt = (γ³ + ζ³) * Δt
        #= none:99 =#
        tⁿ⁺¹ = next_time(model.clock, Δt)
        #= none:105 =#
        rk3_substep!(model, Δt, γ¹, nothing)
        #= none:107 =#
        tick!(model.clock, first_stage_Δt; stage = true)
        #= none:108 =#
        model.clock.last_stage_Δt = first_stage_Δt
        #= none:110 =#
        calculate_pressure_correction!(model, first_stage_Δt)
        #= none:111 =#
        pressure_correct_velocities!(model, first_stage_Δt)
        #= none:113 =#
        store_tendencies!(model)
        #= none:114 =#
        update_state!(model, callbacks; compute_tendencies = true)
        #= none:115 =#
        step_lagrangian_particles!(model, first_stage_Δt)
        #= none:121 =#
        rk3_substep!(model, Δt, γ², ζ²)
        #= none:123 =#
        tick!(model.clock, second_stage_Δt; stage = true)
        #= none:124 =#
        model.clock.last_stage_Δt = second_stage_Δt
        #= none:126 =#
        calculate_pressure_correction!(model, second_stage_Δt)
        #= none:127 =#
        pressure_correct_velocities!(model, second_stage_Δt)
        #= none:129 =#
        store_tendencies!(model)
        #= none:130 =#
        update_state!(model, callbacks; compute_tendencies = true)
        #= none:131 =#
        step_lagrangian_particles!(model, second_stage_Δt)
        #= none:137 =#
        rk3_substep!(model, Δt, γ³, ζ³)
        #= none:142 =#
        corrected_third_stage_Δt = tⁿ⁺¹ - model.clock.time
        #= none:144 =#
        tick!(model.clock, third_stage_Δt)
        #= none:145 =#
        model.clock.last_stage_Δt = corrected_third_stage_Δt
        #= none:146 =#
        model.clock.last_Δt = Δt
        #= none:148 =#
        calculate_pressure_correction!(model, third_stage_Δt)
        #= none:149 =#
        pressure_correct_velocities!(model, third_stage_Δt)
        #= none:151 =#
        update_state!(model, callbacks; compute_tendencies = true)
        #= none:152 =#
        step_lagrangian_particles!(model, third_stage_Δt)
        #= none:154 =#
        return nothing
    end
#= none:161 =#
stage_Δt(Δt, γⁿ, ζⁿ) = begin
        #= none:161 =#
        Δt * (γⁿ + ζⁿ)
    end
#= none:162 =#
stage_Δt(Δt, γⁿ, ::Nothing) = begin
        #= none:162 =#
        Δt * γⁿ
    end
#= none:164 =#
function rk3_substep!(model, Δt, γⁿ, ζⁿ)
    #= none:164 =#
    #= none:166 =#
    grid = model.grid
    #= none:167 =#
    arch = architecture(grid)
    #= none:168 =#
    model_fields = prognostic_fields(model)
    #= none:170 =#
    for (i, field) = enumerate(model_fields)
        #= none:171 =#
        kernel_args = (field, Δt, γⁿ, ζⁿ, model.timestepper.Gⁿ[i], model.timestepper.G⁻[i])
        #= none:172 =#
        launch!(arch, grid, :xyz, rk3_substep_field!, kernel_args...; exclude_periphery = true)
        #= none:175 =#
        tracer_index = Val(i - 3)
        #= none:177 =#
        implicit_step!(field, model.timestepper.implicit_solver, model.closure, model.diffusivity_fields, tracer_index, model.clock, stage_Δt(Δt, γⁿ, ζⁿ))
        #= none:184 =#
    end
    #= none:186 =#
    return nothing
end
#= none:189 =#
#= none:189 =# Core.@doc "Time step velocity fields via the 3rd-order Runge-Kutta method\n\n```\nUᵐ⁺¹ = Uᵐ + Δt * (γᵐ * Gᵐ + ζᵐ * Gᵐ⁻¹)\n```\n\nwhere `m` denotes the substage.\n" #= none:198 =# @kernel(function rk3_substep_field!(U, Δt, γⁿ::FT, ζⁿ, Gⁿ, G⁻) where FT
            #= none:198 =#
            #= none:199 =#
            (i, j, k) = #= none:199 =# @index(Global, NTuple)
            #= none:201 =#
            #= none:201 =# @inbounds begin
                    #= none:202 =#
                    U[i, j, k] += convert(FT, Δt) * (γⁿ * Gⁿ[i, j, k] + ζⁿ * G⁻[i, j, k])
                end
        end)
#= none:206 =#
#= none:206 =# @kernel function rk3_substep_field!(U, Δt, γ¹::FT, ::Nothing, G¹, G⁰) where FT
        #= none:206 =#
        #= none:207 =#
        (i, j, k) = #= none:207 =# @index(Global, NTuple)
        #= none:209 =#
        #= none:209 =# @inbounds begin
                #= none:210 =#
                U[i, j, k] += convert(FT, Δt) * γ¹ * G¹[i, j, k]
            end
    end