
#= none:1 =#
using Oceananigans.Operators
#= none:3 =#
#= none:3 =# Core.@doc "    AnisotropicMinimumDissipation{FT} <: AbstractTurbulenceClosure\n\nParameters for the \"anisotropic minimum dissipation\" turbulence closure for large eddy simulation\nproposed originally by [Rozema15](@citet) and [Abkar16](@citet), then modified by [Verstappen18](@citet),\nand finally described and validated for by [Vreugdenhil18](@citet).\n" struct AnisotropicMinimumDissipation{TD, PK, PN, PB} <: AbstractScalarDiffusivity{TD, ThreeDimensionalFormulation, 2}
        #= none:11 =#
        Cν::PN
        #= none:12 =#
        Cκ::PK
        #= none:13 =#
        Cb::PB
        #= none:15 =#
        function AnisotropicMinimumDissipation{TD}(Cν::PN, Cκ::PK, Cb::PB) where {TD, PN, PK, PB}
            #= none:15 =#
            #= none:16 =#
            return new{TD, PK, PN, PB}(Cν, Cκ, Cb)
        end
    end
#= none:20 =#
const AMD = AnisotropicMinimumDissipation
#= none:22 =#
#= none:22 =# @inline viscosity(::AMD, K) = begin
            #= none:22 =#
            K.νₑ
        end
#= none:23 =#
#= none:23 =# @inline (diffusivity(::AMD, K, ::Val{id}) where id) = begin
            #= none:23 =#
            K.κₑ[id]
        end
#= none:25 =#
(Base.show(io::IO, closure::AMD{TD}) where TD) = begin
        #= none:25 =#
        print(io, "AnisotropicMinimumDissipation{$(TD)} turbulence closure with:\n", "           Poincaré constant for momentum eddy viscosity Cν: ", closure.Cν, "\n", "    Poincaré constant for tracer(s) eddy diffusivit(ies) Cκ: ", closure.Cκ, "\n", "                        Buoyancy modification multiplier Cb: ", closure.Cb)
    end
#= none:31 =#
#= none:31 =# Core.@doc "    AnisotropicMinimumDissipation([time_discretization = ExplicitTimeDiscretization, FT = Float64;]\n                                  C = 1/12, Cν = nothing, Cκ = nothing, Cb = nothing)\n                                  \n                                       \nReturn parameters of type `FT` for the `AnisotropicMinimumDissipation`\nturbulence closure.\n\nArguments\n=========\n\n* `time_discretization`: Either `ExplicitTimeDiscretization()` or `VerticallyImplicitTimeDiscretization()`, \n                         which integrates the terms involving only ``z``-derivatives in the\n                         viscous and diffusive fluxes with an implicit time discretization.\n                         Default `ExplicitTimeDiscretization()`.\n\n* `FT`: Float type; default `Float64`.\n\n\nKeyword arguments\n=================\n* `C`: Poincaré constant for both eddy viscosity and eddy diffusivities. `C` is overridden\n       for eddy viscosity or eddy diffusivity if `Cν` or `Cκ` are set, respecitvely.\n\n* `Cν`: Poincaré constant for momentum eddy viscosity.\n\n* `Cκ`: Poincaré constant for tracer eddy diffusivities. If one number or function, the same\n        number or function is applied to all tracers. If a `NamedTuple`, it must possess\n        a field specifying the Poncaré constant for every tracer.\n\n* `Cb`: Buoyancy modification multiplier (`Cb = nothing` turns it off, `Cb = 1` was used by [Abkar16](@citet)).\n        *Note*: that we _do not_ subtract the horizontally-average component before computing this\n        buoyancy modification term. This implementation differs from [Abkar16](@citet)'s proposal\n        and the impact of this approximation has not been tested or validated.\n\nBy default: `C = Cν = Cκ = 1/12`, which is appropriate for a finite-volume method employing a\nsecond-order advection scheme, and `Cb = nothing`, which turns off the buoyancy modification term.\n\n`Cν` or `Cκ` may be numbers, or functions of `x, y, z`.\n\nExamples\n========\n\n```jldoctest\njulia> using Oceananigans\n\njulia> pretty_diffusive_closure = AnisotropicMinimumDissipation(C=1/2)\nAnisotropicMinimumDissipation{ExplicitTimeDiscretization} turbulence closure with:\n           Poincaré constant for momentum eddy viscosity Cν: 0.5\n    Poincaré constant for tracer(s) eddy diffusivit(ies) Cκ: 0.5\n                        Buoyancy modification multiplier Cb: nothing\n```\n\n```jldoctest\njulia> using Oceananigans\n\njulia> const Δz = 0.5; # grid resolution at surface\n\njulia> surface_enhanced_tracer_C(x, y, z) = 1/12 * (1 + exp((z + Δz/2) / 8Δz));\n\njulia> fancy_closure = AnisotropicMinimumDissipation(Cκ=surface_enhanced_tracer_C)\nAnisotropicMinimumDissipation{ExplicitTimeDiscretization} turbulence closure with:\n           Poincaré constant for momentum eddy viscosity Cν: 0.08333333333333333\n    Poincaré constant for tracer(s) eddy diffusivit(ies) Cκ: surface_enhanced_tracer_C\n                        Buoyancy modification multiplier Cb: nothing\n```\n\n```jldoctest\njulia> using Oceananigans\n\njulia> tracer_specific_closure = AnisotropicMinimumDissipation(Cκ=(c₁=1/12, c₂=1/6))\nAnisotropicMinimumDissipation{ExplicitTimeDiscretization} turbulence closure with:\n           Poincaré constant for momentum eddy viscosity Cν: 0.08333333333333333\n    Poincaré constant for tracer(s) eddy diffusivit(ies) Cκ: (c₁ = 0.08333333333333333, c₂ = 0.16666666666666666)\n                        Buoyancy modification multiplier Cb: nothing\n```\n\nReferences\n==========\n\nVreugdenhil C., and Taylor J. (2018), \"Large-eddy simulations of stratified plane Couette\n    flow using the anisotropic minimum-dissipation model\", Physics of Fluids 30, 085104.\n\nVerstappen, R. (2018), \"How much eddy dissipation is needed to counterbalance the nonlinear\n    production of small, unresolved scales in a large-eddy simulation of turbulence?\",\n    Computers & Fluids 176, pp. 276-284.\n" function AnisotropicMinimumDissipation(time_disc::TD = ExplicitTimeDiscretization(), FT = Float64; C = FT(1 / 12), Cν = nothing, Cκ = nothing, Cb = nothing) where TD
        #= none:118 =#
        #= none:121 =#
        Cν = if Cν === nothing
                C
            else
                Cν
            end
        #= none:122 =#
        Cκ = if Cκ === nothing
                C
            else
                Cκ
            end
        #= none:124 =#
        !(isnothing(Cb)) && #= none:124 =# @warn("AnisotropicMinimumDissipation with buoyancy modification is unvalidated.")
        #= none:126 =#
        return AnisotropicMinimumDissipation{TD}(Cν, Cκ, Cb)
    end
#= none:129 =#
AnisotropicMinimumDissipation(FT::DataType; kw...) = begin
        #= none:129 =#
        AnisotropicMinimumDissipation(ExplicitTimeDiscretization(), FT; kw...)
    end
#= none:131 =#
function with_tracers(tracers, closure::AnisotropicMinimumDissipation{TD}) where TD
    #= none:131 =#
    #= none:132 =#
    Cκ = tracer_diffusivities(tracers, closure.Cκ)
    #= none:133 =#
    return AnisotropicMinimumDissipation{TD}(closure.Cν, Cκ, closure.Cb)
end
#= none:142 =#
#= none:142 =# @inline Cᴾᵒⁱⁿ(i, j, k, grid, C::Number) = begin
            #= none:142 =#
            C
        end
#= none:143 =#
#= none:143 =# @inline Cᴾᵒⁱⁿ(i, j, k, grid, C::AbstractArray) = begin
            #= none:143 =#
            #= none:143 =# @inbounds C[i, j, k]
        end
#= none:144 =#
#= none:144 =# @inline Cᴾᵒⁱⁿ(i, j, k, grid, C::Function) = begin
            #= none:144 =#
            C(xnode(i, grid, Center()), ynode(j, grid, Center()), znode(k, grid, Center()))
        end
#= none:146 =#
#= none:146 =# @kernel function _compute_AMD_viscosity!(νₑ, grid, closure::AMD, buoyancy, velocities, tracers)
        #= none:146 =#
        #= none:147 =#
        (i, j, k) = #= none:147 =# @index(Global, NTuple)
        #= none:149 =#
        FT = eltype(grid)
        #= none:150 =#
        ijk = (i, j, k, grid)
        #= none:151 =#
        q = norm_tr_∇uᶜᶜᶜ(ijk..., velocities.u, velocities.v, velocities.w)
        #= none:152 =#
        Cb = closure.Cb
        #= none:154 =#
        if q == 0
            #= none:155 =#
            νˢᵍˢ = zero(FT)
        else
            #= none:157 =#
            r = norm_uᵢₐ_uⱼₐ_Σᵢⱼᶜᶜᶜ(ijk..., closure, velocities.u, velocities.v, velocities.w)
            #= none:160 =#
            Cb_ζ = Cb_norm_wᵢ_bᵢᶜᶜᶜ(ijk..., Cb, closure, buoyancy, velocities.w, tracers) / Δᶠzᶜᶜᶜ(ijk...)
            #= none:162 =#
            δ² = 3 / (1 / Δᶠxᶜᶜᶜ(ijk...) ^ 2 + 1 / Δᶠyᶜᶜᶜ(ijk...) ^ 2 + 1 / Δᶠzᶜᶜᶜ(ijk...) ^ 2)
            #= none:164 =#
            νˢᵍˢ = (-(Cᴾᵒⁱⁿ(i, j, k, grid, closure.Cν)) * δ² * (r - Cb_ζ)) / q
        end
        #= none:167 =#
        #= none:167 =# @inbounds νₑ[i, j, k] = max(zero(FT), νˢᵍˢ)
    end
#= none:170 =#
#= none:170 =# @kernel function _compute_AMD_diffusivity!(κₑ, grid, closure::AMD, tracer, ::Val{tracer_index}, velocities) where tracer_index
        #= none:170 =#
        #= none:171 =#
        (i, j, k) = #= none:171 =# @index(Global, NTuple)
        #= none:173 =#
        FT = eltype(grid)
        #= none:174 =#
        ijk = (i, j, k, grid)
        #= none:176 =#
        #= none:176 =# @inbounds Cκ = closure.Cκ[tracer_index]
        #= none:178 =#
        σ = norm_θᵢ²ᶜᶜᶜ(i, j, k, grid, tracer)
        #= none:180 =#
        if σ == 0
            #= none:181 =#
            κˢᵍˢ = zero(FT)
        else
            #= none:183 =#
            ϑ = norm_uᵢⱼ_cⱼ_cᵢᶜᶜᶜ(ijk..., closure, velocities.u, velocities.v, velocities.w, tracer)
            #= none:184 =#
            δ² = 3 / (1 / Δᶠxᶜᶜᶜ(ijk...) ^ 2 + 1 / Δᶠyᶜᶜᶜ(ijk...) ^ 2 + 1 / Δᶠzᶜᶜᶜ(ijk...) ^ 2)
            #= none:185 =#
            κˢᵍˢ = (-(Cᴾᵒⁱⁿ(i, j, k, grid, Cκ)) * δ² * ϑ) / σ
        end
        #= none:188 =#
        #= none:188 =# @inbounds κₑ[i, j, k] = max(zero(FT), κˢᵍˢ)
    end
#= none:191 =#
function compute_diffusivities!(diffusivity_fields, closure::AnisotropicMinimumDissipation, model; parameters = :xyz)
    #= none:191 =#
    #= none:192 =#
    grid = model.grid
    #= none:193 =#
    arch = model.architecture
    #= none:194 =#
    velocities = model.velocities
    #= none:195 =#
    tracers = model.tracers
    #= none:196 =#
    buoyancy = model.buoyancy
    #= none:198 =#
    launch!(arch, grid, parameters, _compute_AMD_viscosity!, diffusivity_fields.νₑ, grid, closure, buoyancy, velocities, tracers)
    #= none:201 =#
    for (tracer_index, κₑ) = enumerate(diffusivity_fields.κₑ)
        #= none:202 =#
        #= none:202 =# @inbounds tracer = tracers[tracer_index]
        #= none:203 =#
        launch!(arch, grid, parameters, _compute_AMD_diffusivity!, κₑ, grid, closure, tracer, Val(tracer_index), velocities)
        #= none:205 =#
    end
    #= none:207 =#
    return nothing
end
#= none:216 =#
#= none:216 =# @inline Δᶠxᶜᶜᶜ(i, j, k, grid) = begin
            #= none:216 =#
            2 * Δxᶜᶜᶜ(i, j, k, grid)
        end
#= none:217 =#
#= none:217 =# @inline Δᶠyᶜᶜᶜ(i, j, k, grid) = begin
            #= none:217 =#
            2 * Δyᶜᶜᶜ(i, j, k, grid)
        end
#= none:218 =#
#= none:218 =# @inline Δᶠzᶜᶜᶜ(i, j, k, grid) = begin
            #= none:218 =#
            2 * Δzᶜᶜᶜ(i, j, k, grid)
        end
#= none:220 =#
for loc = (:ccf, :fcc, :cfc, :ffc, :cff, :fcf), ξ = (:x, :y, :z)
    #= none:221 =#
    Δ_loc = Symbol(:Δᶠ, ξ, :_, loc)
    #= none:222 =#
    Δᶜᶜᶜ = Symbol(:Δᶠ, ξ, :ᶜᶜᶜ)
    #= none:223 =#
    #= none:223 =# @eval begin
            #= none:224 =#
            const $Δ_loc = $Δᶜᶜᶜ
        end
    #= none:226 =#
end
#= none:232 =#
#= none:232 =# @inline function norm_uᵢₐ_uⱼₐ_Σᵢⱼᶜᶜᶜ(i, j, k, grid, closure, u, v, w)
        #= none:232 =#
        #= none:233 =#
        ijk = (i, j, k, grid)
        #= none:234 =#
        uvw = (u, v, w)
        #= none:235 =#
        ijkuvw = (i, j, k, grid, u, v, w)
        #= none:237 =#
        uᵢ₁_uⱼ₁_Σ₁ⱼ = norm_Σ₁₁(ijkuvw...) * norm_∂x_u(ijk..., u) ^ 2 + norm_Σ₂₂(ijkuvw...) * ℑxyᶜᶜᵃ(ijk..., norm_∂x_v², uvw...) + norm_Σ₃₃(ijkuvw...) * ℑxzᶜᵃᶜ(ijk..., norm_∂x_w², uvw...) + 2 * norm_∂x_u(ijkuvw...) * ℑxyᶜᶜᵃ(ijk..., norm_∂x_v_Σ₁₂, uvw...) + 2 * norm_∂x_u(ijkuvw...) * ℑxzᶜᵃᶜ(ijk..., norm_∂x_w_Σ₁₃, uvw...) + 2 * ℑxyᶜᶜᵃ(ijk..., norm_∂x_v, uvw...) * ℑxzᶜᵃᶜ(ijk..., norm_∂x_w, uvw...) * ℑyzᵃᶜᶜ(ijk..., norm_Σ₂₃, uvw...)
        #= none:248 =#
        uᵢ₂_uⱼ₂_Σ₂ⱼ = +(norm_Σ₁₁(ijkuvw...)) * ℑxyᶜᶜᵃ(ijk..., norm_∂y_u², uvw...) + norm_Σ₂₂(ijkuvw...) * norm_∂y_v(ijk..., v) ^ 2 + norm_Σ₃₃(ijkuvw...) * ℑyzᵃᶜᶜ(ijk..., norm_∂y_w², uvw...) + 2 * norm_∂y_v(ijkuvw...) * ℑxyᶜᶜᵃ(ijk..., norm_∂y_u_Σ₁₂, uvw...) + 2 * ℑxyᶜᶜᵃ(ijk..., norm_∂y_u, uvw...) * ℑyzᵃᶜᶜ(ijk..., norm_∂y_w, uvw...) * ℑxzᶜᵃᶜ(ijk..., norm_Σ₁₃, uvw...) + 2 * norm_∂y_v(ijkuvw...) * ℑyzᵃᶜᶜ(ijk..., norm_∂y_w_Σ₂₃, uvw...)
        #= none:259 =#
        uᵢ₃_uⱼ₃_Σ₃ⱼ = +(norm_Σ₁₁(ijkuvw...)) * ℑxzᶜᵃᶜ(ijk..., norm_∂z_u², uvw...) + norm_Σ₂₂(ijkuvw...) * ℑyzᵃᶜᶜ(ijk..., norm_∂z_v², uvw...) + norm_Σ₃₃(ijkuvw...) * norm_∂z_w(ijk..., w) ^ 2 + 2 * ℑxzᶜᵃᶜ(ijk..., norm_∂z_u, uvw...) * ℑyzᵃᶜᶜ(ijk..., norm_∂z_v, uvw...) * ℑxyᶜᶜᵃ(ijk..., norm_Σ₁₂, uvw...) + 2 * norm_∂z_w(ijkuvw...) * ℑxzᶜᵃᶜ(ijk..., norm_∂z_u_Σ₁₃, uvw...) + 2 * norm_∂z_w(ijkuvw...) * ℑyzᵃᶜᶜ(ijk..., norm_∂z_v_Σ₂₃, uvw...)
        #= none:270 =#
        return uᵢ₁_uⱼ₁_Σ₁ⱼ + uᵢ₂_uⱼ₂_Σ₂ⱼ + uᵢ₃_uⱼ₃_Σ₃ⱼ
    end
#= none:277 =#
#= none:277 =# @inline function norm_tr_∇uᶜᶜᶜ(i, j, k, grid, uvw...)
        #= none:277 =#
        #= none:278 =#
        ijk = (i, j, k, grid)
        #= none:280 =#
        return norm_∂x_u²(ijk..., uvw...) + norm_∂y_v²(ijk..., uvw...) + norm_∂z_w²(ijk..., uvw...) + ℑxyᶜᶜᵃ(ijk..., norm_∂x_v², uvw...) + ℑxyᶜᶜᵃ(ijk..., norm_∂y_u², uvw...) + ℑxzᶜᵃᶜ(ijk..., norm_∂x_w², uvw...) + ℑxzᶜᵃᶜ(ijk..., norm_∂z_u², uvw...) + ℑyzᵃᶜᶜ(ijk..., norm_∂y_w², uvw...) + ℑyzᵃᶜᶜ(ijk..., norm_∂z_v², uvw...)
    end
#= none:300 =#
#= none:300 =# @inline (Cb_norm_wᵢ_bᵢᶜᶜᶜ(i, j, k, grid::AbstractGrid{FT}, ::Nothing, args...) where FT) = begin
            #= none:300 =#
            zero(FT)
        end
#= none:302 =#
#= none:302 =# @inline function Cb_norm_wᵢ_bᵢᶜᶜᶜ(i, j, k, grid, Cb, closure, buoyancy, w, tracers)
        #= none:302 =#
        #= none:303 =#
        ijk = (i, j, k, grid)
        #= none:305 =#
        wx_bx = ℑxzᶜᵃᶜ(ijk..., norm_∂x_w, w) * Δᶠxᶜᶜᶜ(ijk...) * ℑxᶜᵃᵃ(ijk..., ∂xᶠᶜᶜ, buoyancy_perturbationᶜᶜᶜ, buoyancy.model, tracers)
        #= none:308 =#
        wy_by = ℑyzᵃᶜᶜ(ijk..., norm_∂y_w, w) * Δᶠyᶜᶜᶜ(ijk...) * ℑyᵃᶜᵃ(ijk..., ∂yᶜᶠᶜ, buoyancy_perturbationᶜᶜᶜ, buoyancy.model, tracers)
        #= none:311 =#
        wz_bz = norm_∂z_w(ijk..., w) * Δᶠzᶜᶜᶜ(ijk...) * ℑzᵃᵃᶜ(ijk..., ∂zᶜᶜᶠ, buoyancy_perturbationᶜᶜᶜ, buoyancy.model, tracers)
        #= none:314 =#
        return Cb * (wx_bx + wy_by + wz_bz)
    end
#= none:317 =#
#= none:317 =# @inline function norm_uᵢⱼ_cⱼ_cᵢᶜᶜᶜ(i, j, k, grid, closure, u, v, w, c)
        #= none:317 =#
        #= none:318 =#
        ijk = (i, j, k, grid)
        #= none:320 =#
        cx_ux = norm_∂x_u(ijk..., u) * ℑxᶜᵃᵃ(ijk..., norm_∂x_c², c) + ℑxyᶜᶜᵃ(ijk..., norm_∂x_v, v) * ℑxᶜᵃᵃ(ijk..., norm_∂x_c, c) * ℑyᵃᶜᵃ(ijk..., norm_∂y_c, c) + ℑxzᶜᵃᶜ(ijk..., norm_∂x_w, w) * ℑxᶜᵃᵃ(ijk..., norm_∂x_c, c) * ℑzᵃᵃᶜ(ijk..., norm_∂z_c, c)
        #= none:326 =#
        cy_uy = ℑxyᶜᶜᵃ(ijk..., norm_∂y_u, u) * ℑyᵃᶜᵃ(ijk..., norm_∂y_c, c) * ℑxᶜᵃᵃ(ijk..., norm_∂x_c, c) + norm_∂y_v(ijk..., v) * ℑyᵃᶜᵃ(ijk..., norm_∂y_c², c) + ℑxzᶜᵃᶜ(ijk..., norm_∂y_w, w) * ℑyᵃᶜᵃ(ijk..., norm_∂y_c, c) * ℑzᵃᵃᶜ(ijk..., norm_∂z_c, c)
        #= none:332 =#
        cz_uz = ℑxzᶜᵃᶜ(ijk..., norm_∂z_u, u) * ℑzᵃᵃᶜ(ijk..., norm_∂z_c, c) * ℑxᶜᵃᵃ(ijk..., norm_∂x_c, c) + ℑyzᵃᶜᶜ(ijk..., norm_∂z_v, v) * ℑzᵃᵃᶜ(ijk..., norm_∂z_c, c) * ℑyᵃᶜᵃ(ijk..., norm_∂y_c, c) + norm_∂z_w(ijk..., w) * ℑzᵃᵃᶜ(ijk..., norm_∂z_c², c)
        #= none:338 =#
        return cx_ux + cy_uy + cz_uz
    end
#= none:341 =#
#= none:341 =# @inline norm_θᵢ²ᶜᶜᶜ(i, j, k, grid, c) = begin
            #= none:341 =#
            ℑxᶜᵃᵃ(i, j, k, grid, norm_∂x_c², c) + ℑyᵃᶜᵃ(i, j, k, grid, norm_∂y_c², c) + ℑzᵃᵃᶜ(i, j, k, grid, norm_∂z_c², c)
        end
#= none:349 =#
function DiffusivityFields(grid, tracer_names, user_bcs, ::AMD)
    #= none:349 =#
    #= none:351 =#
    default_diffusivity_bcs = FieldBoundaryConditions(grid, (Center, Center, Center))
    #= none:352 =#
    default_κₑ_bcs = NamedTuple((c => default_diffusivity_bcs for c = tracer_names))
    #= none:353 =#
    κₑ_bcs = if :κₑ ∈ keys(user_bcs)
            merge(default_κₑ_bcs, user_bcs.κₑ)
        else
            default_κₑ_bcs
        end
    #= none:355 =#
    bcs = merge((; νₑ = default_diffusivity_bcs, κₑ = κₑ_bcs), user_bcs)
    #= none:357 =#
    νₑ = CenterField(grid, boundary_conditions = bcs.νₑ)
    #= none:358 =#
    κₑ = NamedTuple((c => CenterField(grid, boundary_conditions = bcs.κₑ[c]) for c = tracer_names))
    #= none:360 =#
    return (; νₑ, κₑ)
end