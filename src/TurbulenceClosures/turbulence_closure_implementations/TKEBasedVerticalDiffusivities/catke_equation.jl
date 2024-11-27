
#= none:1 =#
#= none:1 =# Core.@doc "    struct CATKEEquation{FT}\n\nParameters for the evolution of oceanic turbulent kinetic energy at the O(1 m) scales associated with\nisotropic turbulence and diapycnal mixing.\n" #= none:7 =# Base.@kwdef(struct CATKEEquation{FT}
            #= none:8 =#
            CʰⁱD::FT = 0.579
            #= none:9 =#
            CˡᵒD::FT = 1.604
            #= none:10 =#
            CᵘⁿD::FT = 0.923
            #= none:11 =#
            CᶜD::FT = 3.254
            #= none:12 =#
            CᵉD::FT = 0.0
            #= none:13 =#
            Cᵂu★::FT = 3.179
            #= none:14 =#
            CᵂwΔ::FT = 0.383
            #= none:15 =#
            Cᵂϵ::FT = 1.0
        end)
#= none:36 =#
#= none:36 =# @inline dissipation(i, j, k, grid, closure::FlavorOfCATKE{<:VITD}, args...) = begin
            #= none:36 =#
            zero(grid)
        end
#= none:38 =#
#= none:38 =# @inline function dissipation_length_scaleᶜᶜᶜ(i, j, k, grid, closure::FlavorOfCATKE, velocities, tracers, buoyancy, surface_buoyancy_flux)
        #= none:38 =#
        #= none:42 =#
        Cᶜ = closure.turbulent_kinetic_energy_equation.CᶜD
        #= none:43 =#
        Cᵉ = closure.turbulent_kinetic_energy_equation.CᵉD
        #= none:44 =#
        Cˢᵖ = closure.mixing_length.Cˢᵖ
        #= none:45 =#
        Jᵇ = surface_buoyancy_flux
        #= none:46 =#
        ℓʰ = convective_length_scaleᶜᶜᶜ(i, j, k, grid, closure, Cᶜ, Cᵉ, Cˢᵖ, velocities, tracers, buoyancy, Jᵇ)
        #= none:49 =#
        Cˡᵒ = closure.turbulent_kinetic_energy_equation.CˡᵒD
        #= none:50 =#
        Cʰⁱ = closure.turbulent_kinetic_energy_equation.CʰⁱD
        #= none:51 =#
        Cᵘⁿ = closure.turbulent_kinetic_energy_equation.CᵘⁿD
        #= none:52 =#
        σᴰ = stability_functionᶜᶜᶜ(i, j, k, grid, closure, Cᵘⁿ, Cˡᵒ, Cʰⁱ, velocities, tracers, buoyancy)
        #= none:53 =#
        ℓ★ = stable_length_scaleᶜᶜᶜ(i, j, k, grid, closure, tracers.e, velocities, tracers, buoyancy)
        #= none:54 =#
        ℓ★ = ℓ★ / σᴰ
        #= none:57 =#
        ℓʰ = ifelse(isnan(ℓʰ), zero(grid), ℓʰ)
        #= none:58 =#
        ℓ★ = ifelse(isnan(ℓ★), zero(grid), ℓ★)
        #= none:59 =#
        ℓᴰ = max(ℓ★, ℓʰ)
        #= none:61 =#
        H = total_depthᶜᶜᵃ(i, j, grid)
        #= none:62 =#
        return min(H, ℓᴰ)
    end
#= none:65 =#
#= none:65 =# @inline function dissipation_rate(i, j, k, grid, closure::FlavorOfCATKE, velocities, tracers, buoyancy, diffusivities)
        #= none:65 =#
        #= none:68 =#
        ℓᴰ = dissipation_length_scaleᶜᶜᶜ(i, j, k, grid, closure, velocities, tracers, buoyancy, diffusivities.Jᵇ)
        #= none:69 =#
        e = tracers.e
        #= none:70 =#
        FT = eltype(grid)
        #= none:71 =#
        eᵢ = #= none:71 =# @inbounds(e[i, j, k])
        #= none:81 =#
        ω_numerical = 1 / closure.negative_tke_damping_time_scale
        #= none:82 =#
        ω_physical = sqrt(abs(eᵢ)) / ℓᴰ
        #= none:84 =#
        return ifelse(eᵢ < 0, ω_numerical, ω_physical)
    end
#= none:88 =#
#= none:88 =# @inline function dissipation(i, j, k, grid, closure::FlavorOfCATKE, velocities, tracers, args...)
        #= none:88 =#
        #= none:89 =#
        eᵢ = #= none:89 =# @inbounds(tracers.e[i, j, k])
        #= none:90 =#
        ω = dissipation_rate(i, j, k, grid, closure, velocities, tracers, args...)
        #= none:91 =#
        return ω * eᵢ
    end
#= none:98 =#
#= none:98 =# @inline function top_tke_flux(i, j, grid, clock, fields, parameters, closure::FlavorOfCATKE, buoyancy)
        #= none:98 =#
        #= none:99 =#
        closure = getclosure(i, j, closure)
        #= none:101 =#
        top_tracer_bcs = parameters.top_tracer_boundary_conditions
        #= none:102 =#
        top_velocity_bcs = parameters.top_velocity_boundary_conditions
        #= none:103 =#
        tke_parameters = closure.turbulent_kinetic_energy_equation
        #= none:105 =#
        return _top_tke_flux(i, j, grid, clock, fields, tke_parameters, closure, buoyancy, top_tracer_bcs, top_velocity_bcs)
    end
#= none:109 =#
#= none:109 =# @inline function _top_tke_flux(i, j, grid, clock, fields, tke::CATKEEquation, closure::CATKEVD, buoyancy, top_tracer_bcs, top_velocity_bcs)
        #= none:109 =#
        #= none:113 =#
        wΔ³ = top_convective_turbulent_velocity_cubed(i, j, grid, clock, fields, buoyancy, top_tracer_bcs)
        #= none:114 =#
        u★ = friction_velocity(i, j, grid, clock, fields, top_velocity_bcs)
        #= none:116 =#
        Cᵂu★ = tke.Cᵂu★
        #= none:117 =#
        CᵂwΔ = tke.CᵂwΔ
        #= none:119 =#
        return -Cᵂu★ * u★ ^ 3 - CᵂwΔ * wΔ³
    end
#= none:126 =#
#= none:126 =# Core.@doc " Add TKE boundary conditions specific to `CATKEVerticalDiffusivity`. " function add_closure_specific_boundary_conditions(closure::FlavorOfCATKE, user_bcs, grid, tracer_names, buoyancy)
        #= none:127 =#
        #= none:133 =#
        top_tracer_bcs = top_tracer_boundary_conditions(grid, tracer_names, user_bcs)
        #= none:134 =#
        top_velocity_bcs = top_velocity_boundary_conditions(grid, user_bcs)
        #= none:135 =#
        parameters = TKETopBoundaryConditionParameters(top_tracer_bcs, top_velocity_bcs)
        #= none:136 =#
        top_tke_bc = FluxBoundaryCondition(top_tke_flux, discrete_form = true, parameters = parameters)
        #= none:138 =#
        if :e ∈ keys(user_bcs)
            #= none:139 =#
            e_bcs = user_bcs[:e]
            #= none:141 =#
            tke_bcs = FieldBoundaryConditions(grid, (Center, Center, Center), top = top_tke_bc, bottom = e_bcs.bottom, north = e_bcs.north, south = e_bcs.south, east = e_bcs.east, west = e_bcs.west)
        else
            #= none:149 =#
            tke_bcs = FieldBoundaryConditions(grid, (Center, Center, Center), top = top_tke_bc)
        end
        #= none:152 =#
        new_boundary_conditions = merge(user_bcs, (; e = tke_bcs))
        #= none:154 =#
        return new_boundary_conditions
    end
#= none:157 =#
Base.summary(::CATKEEquation) = begin
        #= none:157 =#
        "TKEBasedVerticalDiffusivities.CATKEEquation"
    end
#= none:158 =#
Base.show(io::IO, tke::CATKEEquation) = begin
        #= none:158 =#
        print(io, "TKEBasedVerticalDiffusivities.CATKEEquation parameters:", '\n', "├── CʰⁱD: ", tke.CʰⁱD, '\n', "├── CˡᵒD: ", tke.CˡᵒD, '\n', "├── CᵘⁿD: ", tke.CᵘⁿD, '\n', "├── CᶜD:  ", tke.CᶜD, '\n', "├── CᵉD:  ", tke.CᵉD, '\n', "├── Cᵂu★: ", tke.Cᵂu★, '\n', "└── CᵂwΔ: ", tke.CᵂwΔ)
    end