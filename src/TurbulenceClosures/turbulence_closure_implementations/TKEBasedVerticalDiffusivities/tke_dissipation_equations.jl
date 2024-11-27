
#= none:1 =#
using Oceananigans: fields
#= none:2 =#
using Oceananigans.Advection: div_Uc, U_dot_∇u, U_dot_∇v
#= none:3 =#
using Oceananigans.Fields: immersed_boundary_condition
#= none:4 =#
using Oceananigans.Grids: retrieve_interior_active_cells_map
#= none:5 =#
using Oceananigans.BoundaryConditions: apply_x_bcs!, apply_y_bcs!, apply_z_bcs!
#= none:6 =#
using Oceananigans.TimeSteppers: store_field_tendencies!, ab2_step_field!, implicit_step!
#= none:7 =#
using Oceananigans.TurbulenceClosures: ∇_dot_qᶜ, immersed_∇_dot_qᶜ, hydrostatic_turbulent_kinetic_energy_tendency
#= none:8 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:10 =#
#= none:10 =# Base.@kwdef struct TKEDissipationEquations{FT}
        #= none:11 =#
        Cᵋϵ::FT = 1.92
        #= none:12 =#
        Cᴾϵ::FT = 1.44
        #= none:13 =#
        Cᵇϵ::FT = -0.65
        #= none:14 =#
        Cᵂu★::FT = 0.0
        #= none:15 =#
        CᵂwΔ::FT = 0.0
        #= none:16 =#
        Cᵂα::FT = 0.11
        #= none:17 =#
        gravitational_acceleration::FT = 9.8065
        #= none:18 =#
        minimum_roughness_length::FT = 0.0001
    end
#= none:21 =#
get_time_step(closure::TKEDissipationVerticalDiffusivity) = begin
        #= none:21 =#
        closure.tke_dissipation_time_step
    end
#= none:23 =#
function time_step_tke_dissipation_equations!(model)
    #= none:23 =#
    #= none:26 =#
    closure = model.closure
    #= none:28 =#
    e = model.tracers.e
    #= none:29 =#
    ϵ = model.tracers.ϵ
    #= none:30 =#
    arch = model.architecture
    #= none:31 =#
    grid = model.grid
    #= none:32 =#
    Gⁿe = model.timestepper.Gⁿ.e
    #= none:33 =#
    G⁻e = model.timestepper.G⁻.e
    #= none:34 =#
    Gⁿϵ = model.timestepper.Gⁿ.ϵ
    #= none:35 =#
    G⁻ϵ = model.timestepper.G⁻.ϵ
    #= none:37 =#
    diffusivity_fields = model.diffusivity_fields
    #= none:38 =#
    κe = diffusivity_fields.κe
    #= none:39 =#
    κϵ = diffusivity_fields.κϵ
    #= none:40 =#
    Le = diffusivity_fields.Le
    #= none:41 =#
    Lϵ = diffusivity_fields.Lϵ
    #= none:42 =#
    previous_velocities = diffusivity_fields.previous_velocities
    #= none:43 =#
    e_index = findfirst((k->begin
                    #= none:43 =#
                    k == :e
                end), keys(model.tracers))
    #= none:44 =#
    ϵ_index = findfirst((k->begin
                    #= none:44 =#
                    k == :ϵ
                end), keys(model.tracers))
    #= none:45 =#
    implicit_solver = model.timestepper.implicit_solver
    #= none:47 =#
    Δt = model.clock.last_Δt
    #= none:48 =#
    Δτ = get_time_step(closure)
    #= none:50 =#
    if isnothing(Δτ)
        #= none:51 =#
        Δτ = Δt
        #= none:52 =#
        M = 1
    else
        #= none:54 =#
        M = ceil(Int, Δt / Δτ)
        #= none:55 =#
        Δτ = Δt / M
    end
    #= none:58 =#
    FT = eltype(grid)
    #= none:60 =#
    for m = 1:M
        #= none:61 =#
        if m == 1 && M != 1
            #= none:62 =#
            χ = convert(FT, -0.5)
        else
            #= none:64 =#
            χ = model.timestepper.χ
        end
        #= none:69 =#
        launch!(arch, grid, :xyz, substep_tke_dissipation!, κe, κϵ, Le, Lϵ, grid, closure, model.velocities, previous_velocities, model.tracers, model.buoyancy, diffusivity_fields, Δτ, χ, Gⁿe, G⁻e, Gⁿϵ, G⁻ϵ)
        #= none:77 =#
        implicit_step!(e, implicit_solver, closure, model.diffusivity_fields, Val(e_index), model.clock, Δτ)
        #= none:81 =#
        implicit_step!(ϵ, implicit_solver, closure, model.diffusivity_fields, Val(ϵ_index), model.clock, Δτ)
        #= none:84 =#
    end
    #= none:86 =#
    return nothing
end
#= none:89 =#
#= none:89 =# @kernel function substep_tke_dissipation!(κe, κϵ, Le, Lϵ, grid, closure, next_velocities, previous_velocities, tracers, buoyancy, diffusivities, Δτ, χ, slow_Gⁿe, G⁻e, slow_Gⁿϵ, G⁻ϵ)
        #= none:89 =#
        #= none:95 =#
        (i, j, k) = #= none:95 =# @index(Global, NTuple)
        #= none:97 =#
        e = tracers.e
        #= none:98 =#
        ϵ = tracers.ϵ
        #= none:100 =#
        closure_ij = getclosure(i, j, closure)
        #= none:103 =#
        κe★ = κeᶜᶜᶠ(i, j, k, grid, closure_ij, next_velocities, tracers, buoyancy)
        #= none:104 =#
        κϵ★ = κϵᶜᶜᶠ(i, j, k, grid, closure_ij, next_velocities, tracers, buoyancy)
        #= none:106 =#
        κe★ = mask_diffusivity(i, j, k, grid, κe★)
        #= none:107 =#
        κϵ★ = mask_diffusivity(i, j, k, grid, κϵ★)
        #= none:109 =#
        #= none:109 =# @inbounds κe[i, j, k] = κe★
        #= none:110 =#
        #= none:110 =# @inbounds κϵ[i, j, k] = κϵ★
        #= none:113 =#
        ϵ★ = dissipationᶜᶜᶜ(i, j, k, grid, closure_ij, tracers, buoyancy)
        #= none:114 =#
        e★ = turbulent_kinetic_energyᶜᶜᶜ(i, j, k, grid, closure_ij, tracers)
        #= none:115 =#
        eⁱʲᵏ = #= none:115 =# @inbounds(e[i, j, k])
        #= none:116 =#
        ϵⁱʲᵏ = #= none:116 =# @inbounds(ϵ[i, j, k])
        #= none:119 =#
        ω★ = ϵ★ / e★
        #= none:120 =#
        ωe⁻ = closure_ij.negative_tke_damping_time_scale
        #= none:121 =#
        ωe = ifelse(eⁱʲᵏ < 0, ωe⁻, ω★)
        #= none:122 =#
        ωϵ = ϵⁱʲᵏ / e★
        #= none:125 =#
        wb = explicit_buoyancy_flux(i, j, k, grid, closure_ij, next_velocities, tracers, buoyancy, diffusivities)
        #= none:128 =#
        wb⁻ = min(wb, zero(grid))
        #= none:129 =#
        wb⁺ = max(wb, zero(grid))
        #= none:131 =#
        eᵐⁱⁿ = closure_ij.minimum_tke
        #= none:132 =#
        wb⁻_e = (wb⁻ / eⁱʲᵏ) * (eⁱʲᵏ > eᵐⁱⁿ)
        #= none:135 =#
        Cᵋϵ = closure_ij.tke_dissipation_equations.Cᵋϵ
        #= none:136 =#
        Cᵇϵ = closure_ij.tke_dissipation_equations.Cᵇϵ
        #= none:138 =#
        Cᵇϵ_wb⁻ = min(Cᵇϵ * wb, zero(grid))
        #= none:139 =#
        Cᵇϵ_wb⁺ = max(Cᵇϵ * wb, zero(grid))
        #= none:142 =#
        #= none:142 =# @inbounds Le[i, j, k] = wb⁻_e - ωe
        #= none:143 =#
        #= none:143 =# @inbounds Lϵ[i, j, k] = Cᵇϵ_wb⁻ / e★ - Cᵋϵ * ωϵ
        #= none:146 =#
        u⁺ = next_velocities.u
        #= none:147 =#
        v⁺ = next_velocities.v
        #= none:148 =#
        uⁿ = previous_velocities.u
        #= none:149 =#
        vⁿ = previous_velocities.v
        #= none:150 =#
        κu = diffusivities.κu
        #= none:151 =#
        Cᴾϵ = closure_ij.tke_dissipation_equations.Cᴾϵ
        #= none:155 =#
        P = shear_production(i, j, k, grid, κu, uⁿ, u⁺, vⁿ, v⁺)
        #= none:157 =#
        #= none:157 =# @inbounds begin
                #= none:158 =#
                fast_Gⁿe = P + wb⁺
                #= none:159 =#
                fast_Gⁿϵ = ωϵ * (Cᴾϵ * P + Cᵇϵ_wb⁺)
            end
        #= none:163 =#
        FT = eltype(χ)
        #= none:164 =#
        Δτ = convert(FT, Δτ)
        #= none:167 =#
        α = convert(FT, 1.5) + χ
        #= none:168 =#
        β = convert(FT, 0.5) + χ
        #= none:170 =#
        #= none:170 =# @inbounds begin
                #= none:171 =#
                total_Gⁿe = slow_Gⁿe[i, j, k] + fast_Gⁿe
                #= none:172 =#
                total_Gⁿϵ = slow_Gⁿϵ[i, j, k] + fast_Gⁿϵ
                #= none:174 =#
                e[i, j, k] += Δτ * (α * total_Gⁿe - β * G⁻e[i, j, k])
                #= none:175 =#
                ϵ[i, j, k] += Δτ * (α * total_Gⁿϵ - β * G⁻ϵ[i, j, k])
                #= none:177 =#
                G⁻e[i, j, k] = total_Gⁿe
                #= none:178 =#
                G⁻ϵ[i, j, k] = total_Gⁿϵ
            end
    end
#= none:182 =#
#= none:182 =# @inline function implicit_linear_coefficient(i, j, k, grid, closure::FlavorOfTD{<:VITD}, K, ::Val{id}, args...) where id
        #= none:182 =#
        #= none:183 =#
        L = K._tupled_implicit_linear_coefficients[id]
        #= none:184 =#
        return #= none:184 =# @inbounds(L[i, j, k])
    end
#= none:191 =#
#= none:191 =# @inline function top_tke_flux(i, j, grid, clock, fields, parameters, closure::FlavorOfTD, buoyancy)
        #= none:191 =#
        #= none:192 =#
        closure = getclosure(i, j, closure)
        #= none:194 =#
        top_tracer_bcs = parameters.top_tracer_boundary_conditions
        #= none:195 =#
        top_velocity_bcs = parameters.top_velocity_boundary_conditions
        #= none:196 =#
        tke_dissipation_parameters = closure.tke_dissipation_equations
        #= none:198 =#
        return _top_tke_flux(i, j, grid, clock, fields, tke_dissipation_parameters, closure, buoyancy, top_tracer_bcs, top_velocity_bcs)
    end
#= none:202 =#
#= none:202 =# @inline function _top_tke_flux(i, j, grid, clock, fields, parameters::TKEDissipationEquations, closure::TDVD, buoyancy, top_tracer_bcs, top_velocity_bcs)
        #= none:202 =#
        #= none:206 =#
        wΔ³ = top_convective_turbulent_velocity_cubed(i, j, grid, clock, fields, buoyancy, top_tracer_bcs)
        #= none:207 =#
        u★ = friction_velocity(i, j, grid, clock, fields, top_velocity_bcs)
        #= none:209 =#
        Cᵂu★ = parameters.Cᵂu★
        #= none:210 =#
        CᵂwΔ = parameters.CᵂwΔ
        #= none:212 =#
        return -Cᵂu★ * u★ ^ 3
    end
#= none:215 =#
#= none:215 =# @inline function top_dissipation_flux(i, j, grid, clock, fields, parameters, closure::FlavorOfTD, buoyancy)
        #= none:215 =#
        #= none:216 =#
        closure = getclosure(i, j, closure)
        #= none:218 =#
        top_tracer_bcs = parameters.top_tracer_boundary_conditions
        #= none:219 =#
        top_velocity_bcs = parameters.top_velocity_boundary_conditions
        #= none:220 =#
        tke_dissipation_parameters = closure.tke_dissipation_equations
        #= none:222 =#
        return _top_dissipation_flux(i, j, grid, clock, fields, tke_dissipation_parameters, closure, buoyancy, top_tracer_bcs, top_velocity_bcs)
    end
#= none:226 =#
#= none:226 =# @inline function _top_dissipation_flux(i, j, grid, clock, fields, parameters::TKEDissipationEquations, closure::TDVD, buoyancy, top_tracer_bcs, top_velocity_bcs)
        #= none:226 =#
        #= none:229 =#
        𝕊u₀ = closure.stability_functions.𝕊u₀
        #= none:230 =#
        σϵ = closure.stability_functions.Cσϵ
        #= none:232 =#
        u★ = friction_velocity(i, j, grid, clock, fields, top_velocity_bcs)
        #= none:233 =#
        α = parameters.Cᵂα
        #= none:234 =#
        g = parameters.gravitational_acceleration
        #= none:235 =#
        ℓ_charnock = (α * u★ ^ 2) / g
        #= none:237 =#
        ℓmin = parameters.minimum_roughness_length
        #= none:238 =#
        ℓᵣ = max(ℓmin, ℓ_charnock)
        #= none:240 =#
        k = grid.Nz
        #= none:241 =#
        e★ = turbulent_kinetic_energyᶜᶜᶜ(i, j, k, grid, closure, fields)
        #= none:242 =#
        z = znode(i, j, k, grid, c, c, c)
        #= none:243 =#
        d = -z
        #= none:245 =#
        return ((-(𝕊u₀ ^ 4) / σϵ) * e★ ^ 2) / (d + ℓᵣ)
    end
#= none:252 =#
#= none:252 =# Core.@doc " Add TKE boundary conditions specific to `TKEDissipationVerticalDiffusivity`. " function add_closure_specific_boundary_conditions(closure::FlavorOfTD, user_bcs, grid, tracer_names, buoyancy)
        #= none:253 =#
        #= none:259 =#
        top_tracer_bcs = top_tracer_boundary_conditions(grid, tracer_names, user_bcs)
        #= none:260 =#
        top_velocity_bcs = top_velocity_boundary_conditions(grid, user_bcs)
        #= none:261 =#
        parameters = TKETopBoundaryConditionParameters(top_tracer_bcs, top_velocity_bcs)
        #= none:262 =#
        top_tke_bc = FluxBoundaryCondition(top_tke_flux, discrete_form = true, parameters = parameters)
        #= none:264 =#
        top_dissipation_bc = FluxBoundaryCondition(top_dissipation_flux, discrete_form = true, parameters = parameters)
        #= none:267 =#
        if :e ∈ keys(user_bcs)
            #= none:268 =#
            e_bcs = user_bcs[:e]
            #= none:270 =#
            tke_bcs = FieldBoundaryConditions(grid, (Center, Center, Center), top = top_tke_bc, bottom = e_bcs.bottom, north = e_bcs.north, south = e_bcs.south, east = e_bcs.east, west = e_bcs.west)
        else
            #= none:278 =#
            tke_bcs = FieldBoundaryConditions(grid, (Center, Center, Center), top = top_tke_bc)
        end
        #= none:281 =#
        if :ϵ ∈ keys(user_bcs)
            #= none:282 =#
            ϵ_bcs = user_bcs[:ϵ]
            #= none:284 =#
            dissipation_bcs = FieldBoundaryConditions(grid, (Center, Center, Center), top = top_dissipation_bc, bottom = e_bcs.bottom, north = e_bcs.north, south = e_bcs.south, east = e_bcs.east, west = e_bcs.west)
        else
            #= none:292 =#
            dissipation_bcs = FieldBoundaryConditions(grid, (Center, Center, Center), top = top_dissipation_bc)
        end
        #= none:295 =#
        new_boundary_conditions = merge(user_bcs, (e = tke_bcs, ϵ = dissipation_bcs))
        #= none:297 =#
        return new_boundary_conditions
    end