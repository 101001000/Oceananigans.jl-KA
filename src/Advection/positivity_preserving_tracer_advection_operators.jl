
#= none:1 =#
using Oceananigans.Grids: AbstractGrid
#= none:3 =#
const ω̂₁ = 5 / 18
#= none:4 =#
const ω̂ₙ = 5 / 18
#= none:5 =#
const ε₂ = 1.0e-20
#= none:8 =#
const BoundPreservingScheme = PositiveWENO
#= none:11 =#
#= none:11 =# @inline function div_Uc(i, j, k, grid, advection::BoundPreservingScheme, U, c)
        #= none:11 =#
        #= none:13 =#
        div_x = bounded_tracer_flux_divergence_x(i, j, k, grid, advection, U.u, c)
        #= none:14 =#
        div_y = bounded_tracer_flux_divergence_y(i, j, k, grid, advection, U.v, c)
        #= none:15 =#
        div_z = bounded_tracer_flux_divergence_z(i, j, k, grid, advection, U.w, c)
        #= none:17 =#
        return (1 / Vᶜᶜᶜ(i, j, k, grid)) * (div_x + div_y + div_z)
    end
#= none:21 =#
#= none:21 =# @inline (bounded_tracer_flux_divergence_x(i, j, k, ::AbstractGrid{FT, Flat, TY, TZ}, advection::BoundPreservingScheme, args...) where {FT, TY, TZ}) = begin
            #= none:21 =#
            zero(FT)
        end
#= none:22 =#
#= none:22 =# @inline (bounded_tracer_flux_divergence_y(i, j, k, ::AbstractGrid{FT, TX, Flat, TZ}, advection::BoundPreservingScheme, args...) where {FT, TX, TZ}) = begin
            #= none:22 =#
            zero(FT)
        end
#= none:23 =#
#= none:23 =# @inline (bounded_tracer_flux_divergence_z(i, j, k, ::AbstractGrid{FT, TX, TY, Flat}, advection::BoundPreservingScheme, args...) where {FT, TX, TY}) = begin
            #= none:23 =#
            zero(FT)
        end
#= none:25 =#
#= none:25 =# @inline function bounded_tracer_flux_divergence_x(i, j, k, grid, advection::BoundPreservingScheme, u, c)
        #= none:25 =#
        #= none:27 =#
        lower_limit = #= none:27 =# @inbounds(advection.bounds[1])
        #= none:28 =#
        upper_limit = #= none:28 =# @inbounds(advection.bounds[2])
        #= none:30 =#
        cᵢⱼ = #= none:30 =# @inbounds(c[i, j, k])
        #= none:32 =#
        c₊ᴸ = _biased_interpolate_xᶠᵃᵃ(i + 1, j, k, grid, advection, LeftBias(), c)
        #= none:33 =#
        c₊ᴿ = _biased_interpolate_xᶠᵃᵃ(i + 1, j, k, grid, advection, RightBias(), c)
        #= none:34 =#
        c₋ᴸ = _biased_interpolate_xᶠᵃᵃ(i, j, k, grid, advection, LeftBias(), c)
        #= none:35 =#
        c₋ᴿ = _biased_interpolate_xᶠᵃᵃ(i, j, k, grid, advection, RightBias(), c)
        #= none:37 =#
        p̃ = ((cᵢⱼ - ω̂₁ * c₋ᴿ) - ω̂ₙ * c₊ᴸ) / (1 - 2ω̂₁)
        #= none:38 =#
        M = max(p̃, c₊ᴸ, c₋ᴿ)
        #= none:39 =#
        m = min(p̃, c₊ᴸ, c₋ᴿ)
        #= none:40 =#
        θ = min(abs((upper_limit - cᵢⱼ) / ((M - cᵢⱼ) + ε₂)), abs((lower_limit - cᵢⱼ) / ((m - cᵢⱼ) + ε₂)), one(grid))
        #= none:42 =#
        c₊ᴸ = θ * (c₊ᴸ - cᵢⱼ) + cᵢⱼ
        #= none:43 =#
        c₋ᴿ = θ * (c₋ᴿ - cᵢⱼ) + cᵢⱼ
        #= none:45 =#
        return #= none:45 =# @inbounds(Axᶠᶜᶜ(i + 1, j, k, grid) * upwind_biased_product(u[i + 1, j, k], c₊ᴸ, c₊ᴿ) - Axᶠᶜᶜ(i, j, k, grid) * upwind_biased_product(u[i, j, k], c₋ᴸ, c₋ᴿ))
    end
#= none:49 =#
#= none:49 =# @inline function bounded_tracer_flux_divergence_y(i, j, k, grid, advection::BoundPreservingScheme, v, c)
        #= none:49 =#
        #= none:51 =#
        lower_limit = #= none:51 =# @inbounds(advection.bounds[1])
        #= none:52 =#
        upper_limit = #= none:52 =# @inbounds(advection.bounds[2])
        #= none:54 =#
        cᵢⱼ = #= none:54 =# @inbounds(c[i, j, k])
        #= none:56 =#
        c₊ᴸ = _biased_interpolate_yᵃᶠᵃ(i, j + 1, k, grid, advection, LeftBias(), c)
        #= none:57 =#
        c₊ᴿ = _biased_interpolate_yᵃᶠᵃ(i, j + 1, k, grid, advection, RightBias(), c)
        #= none:58 =#
        c₋ᴸ = _biased_interpolate_yᵃᶠᵃ(i, j, k, grid, advection, LeftBias(), c)
        #= none:59 =#
        c₋ᴿ = _biased_interpolate_yᵃᶠᵃ(i, j, k, grid, advection, RightBias(), c)
        #= none:61 =#
        p̃ = ((cᵢⱼ - ω̂₁ * c₋ᴿ) - ω̂ₙ * c₊ᴸ) / (1 - 2ω̂₁)
        #= none:62 =#
        M = max(p̃, c₊ᴸ, c₋ᴿ)
        #= none:63 =#
        m = min(p̃, c₊ᴸ, c₋ᴿ)
        #= none:64 =#
        θ = min(abs((upper_limit - cᵢⱼ) / ((M - cᵢⱼ) + ε₂)), abs((lower_limit - cᵢⱼ) / ((m - cᵢⱼ) + ε₂)), one(grid))
        #= none:66 =#
        c₊ᴸ = θ * (c₊ᴸ - cᵢⱼ) + cᵢⱼ
        #= none:67 =#
        c₋ᴿ = θ * (c₋ᴿ - cᵢⱼ) + cᵢⱼ
        #= none:69 =#
        return #= none:69 =# @inbounds(Ayᶜᶠᶜ(i, j + 1, k, grid) * upwind_biased_product(v[i, j + 1, k], c₊ᴸ, c₊ᴿ) - Ayᶜᶠᶜ(i, j, k, grid) * upwind_biased_product(v[i, j, k], c₋ᴸ, c₋ᴿ))
    end
#= none:73 =#
#= none:73 =# @inline function bounded_tracer_flux_divergence_z(i, j, k, grid, advection::BoundPreservingScheme, w, c)
        #= none:73 =#
        #= none:75 =#
        lower_limit = #= none:75 =# @inbounds(advection.bounds[1])
        #= none:76 =#
        upper_limit = #= none:76 =# @inbounds(advection.bounds[2])
        #= none:78 =#
        cᵢⱼ = #= none:78 =# @inbounds(c[i, j, k])
        #= none:80 =#
        c₊ᴸ = _biased_interpolate_zᵃᵃᶠ(i, j, k + 1, grid, advection, LeftBias(), c)
        #= none:81 =#
        c₊ᴿ = _biased_interpolate_zᵃᵃᶠ(i, j, k + 1, grid, advection, RightBias(), c)
        #= none:82 =#
        c₋ᴸ = _biased_interpolate_zᵃᵃᶠ(i, j, k, grid, advection, LeftBias(), c)
        #= none:83 =#
        c₋ᴿ = _biased_interpolate_zᵃᵃᶠ(i, j, k, grid, advection, RightBias(), c)
        #= none:85 =#
        p̃ = ((cᵢⱼ - ω̂₁ * c₋ᴿ) - ω̂ₙ * c₊ᴸ) / (1 - 2ω̂₁)
        #= none:86 =#
        M = max(p̃, c₊ᴸ, c₋ᴿ)
        #= none:87 =#
        m = min(p̃, c₊ᴸ, c₋ᴿ)
        #= none:88 =#
        θ = min(abs((upper_limit - cᵢⱼ) / ((M - cᵢⱼ) + ε₂)), abs((lower_limit - cᵢⱼ) / ((m - cᵢⱼ) + ε₂)), one(grid))
        #= none:90 =#
        c₊ᴸ = θ * (c₊ᴸ - cᵢⱼ) + cᵢⱼ
        #= none:91 =#
        c₋ᴿ = θ * (c₋ᴿ - cᵢⱼ) + cᵢⱼ
        #= none:93 =#
        return #= none:93 =# @inbounds(Azᶜᶜᶠ(i, j, k + 1, grid) * upwind_biased_product(w[i, j, k + 1], c₊ᴸ, c₊ᴿ) - Azᶜᶜᶠ(i, j, k, grid) * upwind_biased_product(w[i, j, k], c₋ᴸ, c₋ᴿ))
    end