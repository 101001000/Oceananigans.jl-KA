
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
get_time_step(closure::CATKEVerticalDiffusivity) = begin
        #= none:10 =#
        closure.tke_time_step
    end
#= none:12 =#
function time_step_catke_equation!(model)
    #= none:12 =#
    #= none:15 =#
    if model.closure isa Tuple
        #= none:16 =#
        closure = first(model.closure)
        #= none:17 =#
        diffusivity_fields = first(model.diffusivity_fields)
    else
        #= none:19 =#
        closure = model.closure
        #= none:20 =#
        diffusivity_fields = model.diffusivity_fields
    end
    #= none:23 =#
    e = model.tracers.e
    #= none:24 =#
    arch = model.architecture
    #= none:25 =#
    grid = model.grid
    #= none:26 =#
    Gⁿe = model.timestepper.Gⁿ.e
    #= none:27 =#
    G⁻e = model.timestepper.G⁻.e
    #= none:29 =#
    κe = diffusivity_fields.κe
    #= none:30 =#
    Le = diffusivity_fields.Le
    #= none:31 =#
    previous_velocities = diffusivity_fields.previous_velocities
    #= none:32 =#
    tracer_index = findfirst((k->begin
                    #= none:32 =#
                    k == :e
                end), keys(model.tracers))
    #= none:33 =#
    implicit_solver = model.timestepper.implicit_solver
    #= none:35 =#
    Δt = model.clock.last_Δt
    #= none:36 =#
    Δτ = get_time_step(closure)
    #= none:38 =#
    if isnothing(Δτ)
        #= none:39 =#
        Δτ = Δt
        #= none:40 =#
        M = 1
    else
        #= none:42 =#
        M = ceil(Int, Δt / Δτ)
        #= none:43 =#
        Δτ = Δt / M
    end
    #= none:46 =#
    FT = eltype(grid)
    #= none:48 =#
    for m = 1:M
        #= none:49 =#
        if m == 1 && M != 1
            #= none:50 =#
            χ = convert(FT, -0.5)
        else
            #= none:52 =#
            χ = model.timestepper.χ
        end
        #= none:57 =#
        launch!(arch, grid, :xyz, substep_turbulent_kinetic_energy!, κe, Le, grid, closure, model.velocities, previous_velocities, model.tracers, model.buoyancy, diffusivity_fields, Δτ, χ, Gⁿe, G⁻e)
        #= none:70 =#
        implicit_step!(e, implicit_solver, closure, diffusivity_fields, Val(tracer_index), model.clock, Δτ)
        #= none:73 =#
    end
    #= none:75 =#
    return nothing
end
#= none:78 =#
#= none:78 =# @kernel function substep_turbulent_kinetic_energy!(κe, Le, grid, closure, next_velocities, previous_velocities, tracers, buoyancy, diffusivities, Δτ, χ, slow_Gⁿe, G⁻e)
        #= none:78 =#
        #= none:83 =#
        (i, j, k) = #= none:83 =# @index(Global, NTuple)
        #= none:85 =#
        Jᵇ = diffusivities.Jᵇ
        #= none:86 =#
        e = tracers.e
        #= none:87 =#
        closure_ij = getclosure(i, j, closure)
        #= none:90 =#
        κe★ = κeᶜᶜᶠ(i, j, k, grid, closure_ij, next_velocities, tracers, buoyancy, Jᵇ)
        #= none:91 =#
        κe★ = mask_diffusivity(i, j, k, grid, κe★)
        #= none:92 =#
        #= none:92 =# @inbounds κe[i, j, k] = κe★
        #= none:95 =#
        wb = explicit_buoyancy_flux(i, j, k, grid, closure_ij, next_velocities, tracers, buoyancy, diffusivities)
        #= none:96 =#
        wb⁻ = min(zero(grid), wb)
        #= none:97 =#
        wb⁺ = max(zero(grid), wb)
        #= none:99 =#
        eⁱʲᵏ = #= none:99 =# @inbounds(e[i, j, k])
        #= none:100 =#
        eᵐⁱⁿ = closure_ij.minimum_tke
        #= none:101 =#
        wb⁻_e = (wb⁻ / eⁱʲᵏ) * (eⁱʲᵏ > eᵐⁱⁿ)
        #= none:121 =#
        on_bottom = !(inactive_cell(i, j, k, grid)) & inactive_cell(i, j, k - 1, grid)
        #= none:122 =#
        Δz = Δzᶜᶜᶜ(i, j, k, grid)
        #= none:123 =#
        Cᵂϵ = closure_ij.turbulent_kinetic_energy_equation.Cᵂϵ
        #= none:124 =#
        e⁺ = clip(eⁱʲᵏ)
        #= none:125 =#
        w★ = sqrt(e⁺)
        #= none:126 =#
        div_Jᵉ_e = (-on_bottom * Cᵂϵ * w★) / Δz
        #= none:129 =#
        ω = dissipation_rate(i, j, k, grid, closure_ij, next_velocities, tracers, buoyancy, diffusivities)
        #= none:144 =#
        #= none:144 =# @inbounds Le[i, j, k] = (wb⁻_e - ω) + div_Jᵉ_e
        #= none:147 =#
        u⁺ = next_velocities.u
        #= none:148 =#
        v⁺ = next_velocities.v
        #= none:149 =#
        uⁿ = previous_velocities.u
        #= none:150 =#
        vⁿ = previous_velocities.v
        #= none:151 =#
        κu = diffusivities.κu
        #= none:155 =#
        P = shear_production(i, j, k, grid, κu, uⁿ, u⁺, vⁿ, v⁺)
        #= none:156 =#
        ϵ = dissipation(i, j, k, grid, closure_ij, next_velocities, tracers, buoyancy, diffusivities)
        #= none:157 =#
        fast_Gⁿe = (P + wb⁺) - ϵ
        #= none:160 =#
        FT = eltype(χ)
        #= none:161 =#
        Δτ = convert(FT, Δτ)
        #= none:164 =#
        α = convert(FT, 1.5) + χ
        #= none:165 =#
        β = convert(FT, 0.5) + χ
        #= none:167 =#
        #= none:167 =# @inbounds begin
                #= none:168 =#
                total_Gⁿe = slow_Gⁿe[i, j, k] + fast_Gⁿe
                #= none:169 =#
                e[i, j, k] += Δτ * (α * total_Gⁿe - β * G⁻e[i, j, k])
                #= none:170 =#
                G⁻e[i, j, k] = total_Gⁿe
            end
    end
#= none:174 =#
#= none:174 =# @inline function implicit_linear_coefficient(i, j, k, grid, closure::FlavorOfCATKE{<:VITD}, K, ::Val{id}, args...) where id
        #= none:174 =#
        #= none:175 =#
        L = K._tupled_implicit_linear_coefficients[id]
        #= none:176 =#
        return #= none:176 =# @inbounds(L[i, j, k])
    end