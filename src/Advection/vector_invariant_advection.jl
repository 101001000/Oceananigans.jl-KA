
#= none:1 =#
using Oceananigans.Operators
#= none:2 =#
using Oceananigans.Operators: flux_div_xyᶜᶜᶜ, Γᶠᶠᶜ
#= none:5 =#
struct EnergyConserving{FT} <: AbstractAdvectionScheme{1, FT}
    #= none:5 =#
end
#= none:6 =#
struct EnstrophyConserving{FT} <: AbstractAdvectionScheme{1, FT}
    #= none:6 =#
end
#= none:8 =#
EnergyConserving(FT::DataType = Float64) = begin
        #= none:8 =#
        EnergyConserving{FT}()
    end
#= none:9 =#
EnstrophyConserving(FT::DataType = Float64) = begin
        #= none:9 =#
        EnstrophyConserving{FT}()
    end
#= none:11 =#
struct VectorInvariant{N, FT, M, Z, ZS, V, K, D, U} <: AbstractAdvectionScheme{N, FT}
    #= none:12 =#
    vorticity_scheme::Z
    #= none:13 =#
    vorticity_stencil::ZS
    #= none:14 =#
    vertical_scheme::V
    #= none:15 =#
    kinetic_energy_gradient_scheme::K
    #= none:16 =#
    divergence_scheme::D
    #= none:17 =#
    upwinding::U
    #= none:19 =#
    function VectorInvariant{N, FT, M}(vorticity_scheme::Z, vorticity_stencil::ZS, vertical_scheme::V, kinetic_energy_gradient_scheme::K, divergence_scheme::D, upwinding::U) where {N, FT, M, Z, ZS, V, K, D, U}
        #= none:19 =#
        #= none:26 =#
        return new{N, FT, M, Z, ZS, V, K, D, U}(vorticity_scheme, vorticity_stencil, vertical_scheme, kinetic_energy_gradient_scheme, divergence_scheme, upwinding)
    end
end
#= none:35 =#
#= none:35 =# Core.@doc "    VectorInvariant(; vorticity_scheme = EnstrophyConserving(),\n                      vorticity_stencil = VelocityStencil(),\n                      vertical_scheme = EnergyConserving(),\n                      divergence_scheme = vertical_scheme,\n                      kinetic_energy_gradient_scheme = divergence_scheme,\n                      upwinding  = OnlySelfUpwinding(; cross_scheme = divergence_scheme),\n                      multi_dimensional_stencil = false)\n\nReturn a vector-invariant momentum advection scheme.\n\nKeyword arguments\n=================\n\n- `vorticity_scheme`: Scheme used for `Center` reconstruction of vorticity. Default: `EnstrophyConserving()`. Options:\n  * `UpwindBiased()`\n  * `WENO()`\n  * `EnergyConserving()`\n  * `EnstrophyConserving()`\n\n- `vorticity_stencil`: Stencil used for smoothness indicators for `WENO` schemes. Default: `VelocityStencil()`. Options:\n  * `VelocityStencil()` (smoothness based on horizontal velocities)\n  * `DefaultStencil()` (smoothness based on variable being reconstructed)\n\n- `vertical_scheme`: Scheme used for vertical advection of horizontal momentum. Default: `EnergyConserving()`.\n\n- `kinetic_energy_gradient_scheme`: Scheme used for kinetic energy gradient reconstruction. Default: `vertical_scheme`.\n\n- `divergence_scheme`: Scheme used for divergence flux. Only upwinding schemes are supported. Default: `vorticity_scheme`.\n\n- `upwinding`: Treatment of upwinded reconstruction of divergence and kinetic energy gradient. Default: `OnlySelfUpwinding()`. Options:\n  * `CrossAndSelfUpwinding()`\n  * `OnlySelfUpwinding()`\n\n- `multi_dimensional_stencil`: whether or not to use a horizontal two-dimensional stencil for the reconstruction\n                               of vorticity, divergence and kinetic energy gradient. Currently the \"tangential\"\n                               direction uses 5th-order centered WENO reconstruction. Default: false\n\nExamples\n========\n\n```jldoctest\njulia> using Oceananigans\n\njulia> VectorInvariant()\nVector Invariant, Dimension-by-dimension reconstruction \n Vorticity flux scheme: \n └── EnstrophyConserving{Float64} \n Vertical advection / Divergence flux scheme: \n └── EnergyConserving{Float64}\n```\n\n```jldoctest\njulia> using Oceananigans\n\njulia> VectorInvariant(vorticity_scheme = WENO(), vertical_scheme = WENO(order = 3))\nVector Invariant, Dimension-by-dimension reconstruction \n Vorticity flux scheme: \n ├── WENO reconstruction order 5 \n └── smoothness ζ: Oceananigans.Advection.VelocityStencil()\n Vertical advection / Divergence flux scheme: \n ├── WENO reconstruction order 3\n └── upwinding treatment: OnlySelfUpwinding \n KE gradient and Divergence flux cross terms reconstruction: \n └── Centered reconstruction order 2\n Smoothness measures: \n ├── smoothness δU: FunctionStencil f = divergence_smoothness\n ├── smoothness δV: FunctionStencil f = divergence_smoothness\n ├── smoothness δu²: FunctionStencil f = u_smoothness\n └── smoothness δv²: FunctionStencil f = v_smoothness      \n```\n" function VectorInvariant(; vorticity_scheme = EnstrophyConserving(), vorticity_stencil = VelocityStencil(), vertical_scheme = EnergyConserving(), divergence_scheme = vertical_scheme, kinetic_energy_gradient_scheme = divergence_scheme, upwinding = OnlySelfUpwinding(; cross_scheme = divergence_scheme), multi_dimensional_stencil = false)
        #= none:107 =#
        #= none:115 =#
        N = max(required_halo_size_x(vorticity_scheme), required_halo_size_y(vorticity_scheme), required_halo_size_x(divergence_scheme), required_halo_size_y(divergence_scheme), required_halo_size_x(kinetic_energy_gradient_scheme), required_halo_size_y(kinetic_energy_gradient_scheme), required_halo_size_z(vertical_scheme))
        #= none:123 =#
        FT = eltype(vorticity_scheme)
        #= none:125 =#
        return VectorInvariant{N, FT, multi_dimensional_stencil}(vorticity_scheme, vorticity_stencil, vertical_scheme, kinetic_energy_gradient_scheme, divergence_scheme, upwinding)
    end
#= none:135 =#
const MultiDimensionalVectorInvariant = VectorInvariant{<:Any, <:Any, true}
#= none:138 =#
const VectorInvariantEnergyConserving = VectorInvariant{<:Any, <:Any, <:Any, <:EnergyConserving}
#= none:139 =#
const VectorInvariantEnstrophyConserving = VectorInvariant{<:Any, <:Any, <:Any, <:EnstrophyConserving}
#= none:140 =#
const VectorInvariantUpwindVorticity = VectorInvariant{<:Any, <:Any, <:Any, <:AbstractUpwindBiasedAdvectionScheme}
#= none:143 =#
const VectorInvariantVerticalEnergyConserving = VectorInvariant{<:Any, <:Any, <:Any, <:Any, <:Any, <:EnergyConserving}
#= none:146 =#
const VectorInvariantKEGradientEnergyConserving = VectorInvariant{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:EnergyConserving}
#= none:147 =#
const VectorInvariantKineticEnergyUpwinding = VectorInvariant{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:AbstractUpwindBiasedAdvectionScheme}
#= none:151 =#
const VectorInvariantCrossVerticalUpwinding = VectorInvariant{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:AbstractUpwindBiasedAdvectionScheme, <:CrossAndSelfUpwinding}
#= none:152 =#
const VectorInvariantSelfVerticalUpwinding = VectorInvariant{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:AbstractUpwindBiasedAdvectionScheme, <:OnlySelfUpwinding}
#= none:154 =#
Base.summary(a::VectorInvariant) = begin
        #= none:154 =#
        string("Vector Invariant, Dimension-by-dimension reconstruction")
    end
#= none:155 =#
Base.summary(a::MultiDimensionalVectorInvariant) = begin
        #= none:155 =#
        string("Vector Invariant, Multidimensional reconstruction")
    end
#= none:157 =#
(Base.show(io::IO, a::VectorInvariant{N, FT}) where {N, FT}) = begin
        #= none:157 =#
        print(io, summary(a), " \n", " Vorticity flux scheme: ", "\n", " $(if a.vorticity_scheme isa WENO
    "├"
else
    "└"
end)── $(summary(a.vorticity_scheme))", " $(if a.vorticity_scheme isa WENO
    "\n └── smoothness ζ: $(a.vorticity_stencil)\n"
else
    "\n"
end)", " Vertical advection / Divergence flux scheme: ", "\n", " $(if a.vertical_scheme isa WENO
    "├"
else
    "└"
end)── $(summary(a.vertical_scheme))", "$(if a.vertical_scheme isa AbstractUpwindBiasedAdvectionScheme
    "\n └── upwinding treatment: $(a.upwinding)"
else
    ""
end)")
    end
#= none:171 =#
nothing_to_default(user_value; default) = begin
        #= none:171 =#
        if isnothing(user_value)
            default
        else
            user_value
        end
    end
#= none:173 =#
#= none:173 =# Core.@doc "    WENOVectorInvariant(FT = Float64; \n                        upwinding = nothing,\n                        vorticity_stencil = VelocityStencil(),\n                        order = nothing,\n                        vorticity_order = nothing,\n                        vertical_order = nothing,\n                        divergence_order = nothing,\n                        kinetic_energy_gradient_order = nothing, \n                        multi_dimensional_stencil = false,\n                        weno_kw...)\n\nReturn a vector-invariant weighted essentially non-oscillatory (WENO) scheme.\nSee [`VectorInvariant`](@ref) and [`WENO`](@ref) for kwargs definitions.\n\nIf `multi_dimensional_stencil = true` is selected, then a 2D horizontal stencil\nis implemented for the WENO scheme (instead of a 1D stencil). This 2D horizontal\nstencil performs a centered 5th-order WENO reconstruction of vorticity,\ndivergence and kinetic energy in the horizontal direction tangential to the upwind direction.\n" function WENOVectorInvariant(FT::DataType = Float64; upwinding = nothing, vorticity_stencil = VelocityStencil(), order = nothing, vorticity_order = nothing, vertical_order = nothing, divergence_order = nothing, kinetic_energy_gradient_order = nothing, multi_dimensional_stencil = false, weno_kw...)
        #= none:193 =#
        #= none:204 =#
        if isnothing(order)
            #= none:205 =#
            vorticity_order = nothing_to_default(vorticity_order, default = 9)
            #= none:206 =#
            vertical_order = nothing_to_default(vertical_order, default = 5)
            #= none:207 =#
            divergence_order = nothing_to_default(divergence_order, default = 5)
            #= none:208 =#
            kinetic_energy_gradient_order = nothing_to_default(kinetic_energy_gradient_order, default = 5)
        else
            #= none:210 =#
            vorticity_order = nothing_to_default(vorticity_order, default = order)
            #= none:211 =#
            vertical_order = nothing_to_default(vertical_order, default = order)
            #= none:212 =#
            divergence_order = nothing_to_default(divergence_order, default = order)
            #= none:213 =#
            kinetic_energy_gradient_order = nothing_to_default(kinetic_energy_gradient_order, default = order)
        end
        #= none:216 =#
        vorticity_scheme = WENO(FT; order = vorticity_order, weno_kw...)
        #= none:217 =#
        vertical_scheme = WENO(FT; order = vertical_order, weno_kw...)
        #= none:218 =#
        kinetic_energy_gradient_scheme = WENO(FT; order = kinetic_energy_gradient_order, weno_kw...)
        #= none:219 =#
        divergence_scheme = WENO(FT; order = divergence_order, weno_kw...)
        #= none:221 =#
        default_upwinding = OnlySelfUpwinding(cross_scheme = divergence_scheme)
        #= none:222 =#
        upwinding = nothing_to_default(upwinding; default = default_upwinding)
        #= none:224 =#
        N = max(required_halo_size_x(vorticity_scheme), required_halo_size_y(vorticity_scheme), required_halo_size_x(divergence_scheme), required_halo_size_y(divergence_scheme), required_halo_size_x(kinetic_energy_gradient_scheme), required_halo_size_y(kinetic_energy_gradient_scheme), required_halo_size_z(vertical_scheme))
        #= none:232 =#
        FT = eltype(vorticity_scheme)
        #= none:234 =#
        return VectorInvariant{N, FT, multi_dimensional_stencil}(vorticity_scheme, vorticity_stencil, vertical_scheme, kinetic_energy_gradient_scheme, divergence_scheme, upwinding)
    end
#= none:244 =#
#= none:244 =# @inline function required_halo_size_x(scheme::VectorInvariant)
        #= none:244 =#
        #= none:245 =#
        Hx₁ = required_halo_size_x(scheme.vorticity_scheme)
        #= none:246 =#
        Hx₂ = required_halo_size_x(scheme.divergence_scheme)
        #= none:247 =#
        Hx₃ = required_halo_size_x(scheme.kinetic_energy_gradient_scheme)
        #= none:249 =#
        Hx = max(Hx₁, Hx₂, Hx₃)
        #= none:250 =#
        return if Hx == 1
                Hx
            else
                Hx + 1
            end
    end
#= none:253 =#
#= none:253 =# @inline required_halo_size_y(scheme::VectorInvariant) = begin
            #= none:253 =#
            required_halo_size_x(scheme)
        end
#= none:254 =#
#= none:254 =# @inline required_halo_size_z(scheme::VectorInvariant) = begin
            #= none:254 =#
            required_halo_size_z(scheme.vertical_scheme)
        end
#= none:256 =#
(Adapt.adapt_structure(to, scheme::VectorInvariant{N, FT, M}) where {N, FT, M}) = begin
        #= none:256 =#
        VectorInvariant{N, FT, M}(Adapt.adapt(to, scheme.vorticity_scheme), Adapt.adapt(to, scheme.vorticity_stencil), Adapt.adapt(to, scheme.vertical_scheme), Adapt.adapt(to, scheme.kinetic_energy_gradient_scheme), Adapt.adapt(to, scheme.divergence_scheme), Adapt.adapt(to, scheme.upwinding))
    end
#= none:264 =#
(on_architecture(to, scheme::VectorInvariant{N, FT, M}) where {N, FT, M}) = begin
        #= none:264 =#
        VectorInvariant{N, FT, M}(on_architecture(to, scheme.vorticity_scheme), on_architecture(to, scheme.vorticity_stencil), on_architecture(to, scheme.vertical_scheme), on_architecture(to, scheme.kinetic_energy_gradient_scheme), on_architecture(to, scheme.divergence_scheme), on_architecture(to, scheme.upwinding))
    end
#= none:272 =#
#= none:272 =# @inline U_dot_∇u(i, j, k, grid, scheme::VectorInvariant, U) = begin
            #= none:272 =#
            horizontal_advection_U(i, j, k, grid, scheme, U.u, U.v) + vertical_advection_U(i, j, k, grid, scheme, U) + bernoulli_head_U(i, j, k, grid, scheme, U.u, U.v)
        end
#= none:276 =#
#= none:276 =# @inline U_dot_∇v(i, j, k, grid, scheme::VectorInvariant, U) = begin
            #= none:276 =#
            horizontal_advection_V(i, j, k, grid, scheme, U.u, U.v) + vertical_advection_V(i, j, k, grid, scheme, U) + bernoulli_head_V(i, j, k, grid, scheme, U.u, U.v)
        end
#= none:281 =#
for bias = (:_biased, :_symmetric)
    #= none:282 =#
    for (dir1, dir2) = zip((:xᶠᵃᵃ, :xᶜᵃᵃ, :yᵃᶠᵃ, :yᵃᶜᵃ), (:y, :y, :x, :x))
        #= none:283 =#
        interp_func = Symbol(bias, :_interpolate_, dir1)
        #= none:284 =#
        multidim_interp = Symbol(:_multi_dimensional_reconstruction_, dir2)
        #= none:286 =#
        #= none:286 =# @eval begin
                #= none:287 =#
                #= none:287 =# @inline $interp_func(i, j, k, grid, ::VectorInvariant, interp_scheme, args...) = begin
                            #= none:287 =#
                            $interp_func(i, j, k, grid, interp_scheme, args...)
                        end
                #= none:290 =#
                #= none:290 =# @inline $interp_func(i, j, k, grid, ::MultiDimensionalVectorInvariant, interp_scheme, args...) = begin
                            #= none:290 =#
                            $multidim_interp(i, j, k, grid, interp_scheme, $interp_func, args...)
                        end
            end
        #= none:293 =#
    end
    #= none:294 =#
end
#= none:307 =#
#= none:307 =# @inline ϕ²(i, j, k, grid, ϕ) = begin
            #= none:307 =#
            #= none:307 =# @inbounds ϕ[i, j, k] ^ 2
        end
#= none:308 =#
#= none:308 =# @inline Khᶜᶜᶜ(i, j, k, grid, u, v) = begin
            #= none:308 =#
            (ℑxᶜᵃᵃ(i, j, k, grid, ϕ², u) + ℑyᵃᶜᵃ(i, j, k, grid, ϕ², v)) / 2
        end
#= none:310 =#
#= none:310 =# @inline bernoulli_head_U(i, j, k, grid, ::VectorInvariantKEGradientEnergyConserving, u, v) = begin
            #= none:310 =#
            ∂xᶠᶜᶜ(i, j, k, grid, Khᶜᶜᶜ, u, v)
        end
#= none:311 =#
#= none:311 =# @inline bernoulli_head_V(i, j, k, grid, ::VectorInvariantKEGradientEnergyConserving, u, v) = begin
            #= none:311 =#
            ∂yᶜᶠᶜ(i, j, k, grid, Khᶜᶜᶜ, u, v)
        end
#= none:318 =#
#= none:318 =# @inbounds ζ₂wᶠᶜᶠ(i, j, k, grid, u, w) = begin
            #= none:318 =#
            ℑxᶠᵃᵃ(i, j, k, grid, Az_qᶜᶜᶠ, w) * ∂zᶠᶜᶠ(i, j, k, grid, u)
        end
#= none:319 =#
#= none:319 =# @inbounds ζ₁wᶜᶠᶠ(i, j, k, grid, v, w) = begin
            #= none:319 =#
            ℑyᵃᶠᵃ(i, j, k, grid, Az_qᶜᶜᶠ, w) * ∂zᶜᶠᶠ(i, j, k, grid, v)
        end
#= none:321 =#
#= none:321 =# @inline vertical_advection_U(i, j, k, grid, ::VectorInvariantVerticalEnergyConserving, U) = begin
            #= none:321 =#
            ℑzᵃᵃᶜ(i, j, k, grid, ζ₂wᶠᶜᶠ, U.u, U.w) / Azᶠᶜᶜ(i, j, k, grid)
        end
#= none:322 =#
#= none:322 =# @inline vertical_advection_V(i, j, k, grid, ::VectorInvariantVerticalEnergyConserving, U) = begin
            #= none:322 =#
            ℑzᵃᵃᶜ(i, j, k, grid, ζ₁wᶜᶠᶠ, U.v, U.w) / Azᶜᶠᶜ(i, j, k, grid)
        end
#= none:328 =#
#= none:328 =# @inline function vertical_advection_U(i, j, k, grid, scheme::VectorInvariant, U)
        #= none:328 =#
        #= none:330 =#
        Φᵟ = upwinded_divergence_flux_Uᶠᶜᶜ(i, j, k, grid, scheme, U.u, U.v)
        #= none:331 =#
        𝒜ᶻ = δzᵃᵃᶜ(i, j, k, grid, _advective_momentum_flux_Wu, scheme.vertical_scheme, U.w, U.u)
        #= none:333 =#
        return (1 / Vᶠᶜᶜ(i, j, k, grid)) * (Φᵟ + 𝒜ᶻ)
    end
#= none:336 =#
#= none:336 =# @inline function vertical_advection_V(i, j, k, grid, scheme::VectorInvariant, U)
        #= none:336 =#
        #= none:338 =#
        Φᵟ = upwinded_divergence_flux_Vᶜᶠᶜ(i, j, k, grid, scheme, U.u, U.v)
        #= none:339 =#
        𝒜ᶻ = δzᵃᵃᶜ(i, j, k, grid, _advective_momentum_flux_Wv, scheme.vertical_scheme, U.w, U.v)
        #= none:341 =#
        return (1 / Vᶜᶠᶜ(i, j, k, grid)) * (Φᵟ + 𝒜ᶻ)
    end
#= none:357 =#
#= none:357 =# @inline ζ_ℑx_vᶠᶠᵃ(i, j, k, grid, u, v) = begin
            #= none:357 =#
            ζ₃ᶠᶠᶜ(i, j, k, grid, u, v) * ℑxᶠᵃᵃ(i, j, k, grid, Δx_qᶜᶠᶜ, v)
        end
#= none:358 =#
#= none:358 =# @inline ζ_ℑy_uᶠᶠᵃ(i, j, k, grid, u, v) = begin
            #= none:358 =#
            ζ₃ᶠᶠᶜ(i, j, k, grid, u, v) * ℑyᵃᶠᵃ(i, j, k, grid, Δy_qᶠᶜᶜ, u)
        end
#= none:360 =#
#= none:360 =# @inline horizontal_advection_U(i, j, k, grid, ::VectorInvariantEnergyConserving, u, v) = begin
            #= none:360 =#
            -(ℑyᵃᶜᵃ(i, j, k, grid, ζ_ℑx_vᶠᶠᵃ, u, v)) / Δxᶠᶜᶜ(i, j, k, grid)
        end
#= none:361 =#
#= none:361 =# @inline horizontal_advection_V(i, j, k, grid, ::VectorInvariantEnergyConserving, u, v) = begin
            #= none:361 =#
            +(ℑxᶜᵃᵃ(i, j, k, grid, ζ_ℑy_uᶠᶠᵃ, u, v)) / Δyᶜᶠᶜ(i, j, k, grid)
        end
#= none:363 =#
#= none:363 =# @inline horizontal_advection_U(i, j, k, grid, ::VectorInvariantEnstrophyConserving, u, v) = begin
            #= none:363 =#
            (-(ℑyᵃᶜᵃ(i, j, k, grid, ζ₃ᶠᶠᶜ, u, v)) * ℑxᶠᵃᵃ(i, j, k, grid, ℑyᵃᶜᵃ, Δx_qᶜᶠᶜ, v)) / Δxᶠᶜᶜ(i, j, k, grid)
        end
#= none:364 =#
#= none:364 =# @inline horizontal_advection_V(i, j, k, grid, ::VectorInvariantEnstrophyConserving, u, v) = begin
            #= none:364 =#
            (+(ℑxᶜᵃᵃ(i, j, k, grid, ζ₃ᶠᶠᶜ, u, v)) * ℑyᵃᶠᵃ(i, j, k, grid, ℑxᶜᵃᵃ, Δy_qᶠᶜᶜ, u)) / Δyᶜᶠᶜ(i, j, k, grid)
        end
#= none:370 =#
#= none:370 =# @inline function horizontal_advection_U(i, j, k, grid, scheme::VectorInvariantUpwindVorticity, u, v)
        #= none:370 =#
        #= none:372 =#
        Sζ = scheme.vorticity_stencil
        #= none:374 =#
        #= none:374 =# @inbounds v̂ = ℑxᶠᵃᵃ(i, j, k, grid, ℑyᵃᶜᵃ, Δx_qᶜᶠᶜ, v) / Δxᶠᶜᶜ(i, j, k, grid)
        #= none:375 =#
        ζᴿ = _biased_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme, scheme.vorticity_scheme, bias(v̂), ζ₃ᶠᶠᶜ, Sζ, u, v)
        #= none:377 =#
        return -v̂ * ζᴿ
    end
#= none:380 =#
#= none:380 =# @inline function horizontal_advection_V(i, j, k, grid, scheme::VectorInvariantUpwindVorticity, u, v)
        #= none:380 =#
        #= none:382 =#
        Sζ = scheme.vorticity_stencil
        #= none:384 =#
        #= none:384 =# @inbounds û = ℑyᵃᶠᵃ(i, j, k, grid, ℑxᶜᵃᵃ, Δy_qᶠᶜᶜ, u) / Δyᶜᶠᶜ(i, j, k, grid)
        #= none:385 =#
        ζᴿ = _biased_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme, scheme.vorticity_scheme, bias(û), ζ₃ᶠᶠᶜ, Sζ, u, v)
        #= none:387 =#
        return +û * ζᴿ
    end
#= none:394 =#
#= none:394 =# @inline function U_dot_∇u(i, j, k, grid, advection::AbstractAdvectionScheme, U)
        #= none:394 =#
        #= none:396 =#
        v̂ = ℑxᶠᵃᵃ(i, j, k, grid, ℑyᵃᶜᵃ, Δx_qᶜᶠᶜ, U.v) / Δxᶠᶜᶜ(i, j, k, grid)
        #= none:397 =#
        û = #= none:397 =# @inbounds(U.u[i, j, k])
        #= none:399 =#
        return (div_𝐯u(i, j, k, grid, advection, U, U.u) - (v̂ * v̂ * δxᶠᵃᵃ(i, j, k, grid, Δyᶜᶜᶜ)) / Azᶠᶜᶜ(i, j, k, grid)) + (v̂ * û * δyᵃᶜᵃ(i, j, k, grid, Δxᶠᶠᶜ)) / Azᶠᶜᶜ(i, j, k, grid)
    end
#= none:404 =#
#= none:404 =# @inline function U_dot_∇v(i, j, k, grid, advection::AbstractAdvectionScheme, U)
        #= none:404 =#
        #= none:406 =#
        û = ℑyᵃᶠᵃ(i, j, k, grid, ℑxᶜᵃᵃ, Δy_qᶠᶜᶜ, U.u) / Δyᶜᶠᶜ(i, j, k, grid)
        #= none:407 =#
        v̂ = #= none:407 =# @inbounds(U.v[i, j, k])
        #= none:409 =#
        return (div_𝐯v(i, j, k, grid, advection, U, U.v) + (û * v̂ * δxᶜᵃᵃ(i, j, k, grid, Δyᶠᶠᶜ)) / Azᶜᶠᶜ(i, j, k, grid)) - (û * û * δyᵃᶠᵃ(i, j, k, grid, Δxᶜᶜᶜ)) / Azᶜᶠᶜ(i, j, k, grid)
    end
#= none:420 =#
#= none:420 =# @inline U_dot_∇u(i, j, k, grid::RectilinearGrid, advection::ACAS, U) = begin
            #= none:420 =#
            div_𝐯u(i, j, k, grid, advection, U, U.u)
        end
#= none:421 =#
#= none:421 =# @inline U_dot_∇v(i, j, k, grid::RectilinearGrid, advection::ACAS, U) = begin
            #= none:421 =#
            div_𝐯v(i, j, k, grid, advection, U, U.v)
        end
#= none:422 =#
#= none:422 =# @inline U_dot_∇u(i, j, k, grid::RectilinearGrid, advection::AUAS, U) = begin
            #= none:422 =#
            div_𝐯u(i, j, k, grid, advection, U, U.u)
        end
#= none:423 =#
#= none:423 =# @inline U_dot_∇v(i, j, k, grid::RectilinearGrid, advection::AUAS, U) = begin
            #= none:423 =#
            div_𝐯v(i, j, k, grid, advection, U, U.v)
        end
#= none:429 =#
#= none:429 =# @inline (U_dot_∇u(i, j, k, grid::AbstractGrid{FT}, scheme::Nothing, U) where FT) = begin
            #= none:429 =#
            zero(FT)
        end
#= none:430 =#
#= none:430 =# @inline (U_dot_∇v(i, j, k, grid::AbstractGrid{FT}, scheme::Nothing, U) where FT) = begin
            #= none:430 =#
            zero(FT)
        end
#= none:432 =#
const UB{N} = UpwindBiased{N}
#= none:433 =#
const UBX{N} = UpwindBiased{N, <:Any, <:Nothing}
#= none:434 =#
const UBY{N} = UpwindBiased{N, <:Any, <:Any, <:Nothing}
#= none:435 =#
const UBZ{N} = UpwindBiased{N, <:Any, <:Any, <:Any, <:Nothing}
#= none:437 =#
const C{N} = Centered{N, <:Any}
#= none:438 =#
const CX{N} = Centered{N, <:Any, <:Nothing}
#= none:439 =#
const CY{N} = Centered{N, <:Any, <:Any, <:Nothing}
#= none:440 =#
const CZ{N} = Centered{N, <:Any, <:Any, <:Any, <:Nothing}
#= none:442 =#
const AS = AbstractSmoothnessStencil
#= none:445 =#
for b = 1:6
    #= none:446 =#
    #= none:446 =# @eval begin
            #= none:447 =#
            #= none:447 =# @inline inner_symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, s::C{$b}, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:447 =#
                        inner_symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, s, f, idx, loc, args...)
                    end
            #= none:448 =#
            #= none:448 =# @inline inner_symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, s::C{$b}, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:448 =#
                        inner_symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, s, f, idx, loc, args...)
                    end
            #= none:449 =#
            #= none:449 =# @inline inner_symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, s::C{$b}, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:449 =#
                        inner_symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, s, f, idx, loc, args...)
                    end
            #= none:450 =#
            #= none:450 =# @inline inner_symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, s::CX{$b}, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:450 =#
                        inner_symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, s, f, idx, loc, args...)
                    end
            #= none:451 =#
            #= none:451 =# @inline inner_symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, s::CY{$b}, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:451 =#
                        inner_symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, s, f, idx, loc, args...)
                    end
            #= none:452 =#
            #= none:452 =# @inline inner_symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, s::CZ{$b}, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:452 =#
                        inner_symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, s, f, idx, loc, args...)
                    end
            #= none:454 =#
            #= none:454 =# @inline inner_biased_interpolate_xᶠᵃᵃ(i, j, k, grid, s::UB{$b}, bias, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:454 =#
                        inner_biased_interpolate_xᶠᵃᵃ(i, j, k, grid, s, bias, f, idx, loc, args...)
                    end
            #= none:455 =#
            #= none:455 =# @inline inner_biased_interpolate_yᵃᶠᵃ(i, j, k, grid, s::UB{$b}, bias, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:455 =#
                        inner_biased_interpolate_yᵃᶠᵃ(i, j, k, grid, s, bias, f, idx, loc, args...)
                    end
            #= none:456 =#
            #= none:456 =# @inline inner_biased_interpolate_zᵃᵃᶠ(i, j, k, grid, s::UB{$b}, bias, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:456 =#
                        inner_biased_interpolate_zᵃᵃᶠ(i, j, k, grid, s, bias, f, idx, loc, args...)
                    end
            #= none:457 =#
            #= none:457 =# @inline inner_biased_interpolate_xᶠᵃᵃ(i, j, k, grid, s::UBX{$b}, bias, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:457 =#
                        inner_biased_interpolate_xᶠᵃᵃ(i, j, k, grid, s, bias, f, idx, loc, args...)
                    end
            #= none:458 =#
            #= none:458 =# @inline inner_biased_interpolate_yᵃᶠᵃ(i, j, k, grid, s::UBY{$b}, bias, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:458 =#
                        inner_biased_interpolate_yᵃᶠᵃ(i, j, k, grid, s, bias, f, idx, loc, args...)
                    end
            #= none:459 =#
            #= none:459 =# @inline inner_biased_interpolate_zᵃᵃᶠ(i, j, k, grid, s::UBZ{$b}, bias, f::Function, idx, loc, ::AS, args...) = begin
                        #= none:459 =#
                        inner_biased_interpolate_zᵃᵃᶠ(i, j, k, grid, s, bias, f, idx, loc, args...)
                    end
        end
    #= none:461 =#
end