
#= none:1 =#
using ..TurbulenceClosures: wall_vertical_distanceᶜᶜᶠ, wall_vertical_distanceᶜᶜᶜ, depthᶜᶜᶠ, height_above_bottomᶜᶜᶠ, depthᶜᶜᶜ, height_above_bottomᶜᶜᶜ, total_depthᶜᶜᵃ
#= none:10 =#
#= none:10 =# Core.@doc "    struct CATKEMixingLength{FT}\n\nContains mixing length parameters for CATKE vertical diffusivity.\n" #= none:15 =# Base.@kwdef(struct CATKEMixingLength{FT}
            #= none:16 =#
            Cˢ::FT = 1.131
            #= none:17 =#
            Cᵇ::FT = Inf
            #= none:18 =#
            Cˢᵖ::FT = 0.505
            #= none:19 =#
            CRiᵟ::FT = 1.02
            #= none:20 =#
            CRi⁰::FT = 0.254
            #= none:21 =#
            Cʰⁱu::FT = 0.242
            #= none:22 =#
            Cˡᵒu::FT = 0.361
            #= none:23 =#
            Cᵘⁿu::FT = 0.37
            #= none:24 =#
            Cᶜu::FT = 3.705
            #= none:25 =#
            Cᵉu::FT = 0.0
            #= none:26 =#
            Cʰⁱc::FT = 0.098
            #= none:27 =#
            Cˡᵒc::FT = 0.369
            #= none:28 =#
            Cᵘⁿc::FT = 0.572
            #= none:29 =#
            Cᶜc::FT = 4.793
            #= none:30 =#
            Cᵉc::FT = 0.112
            #= none:31 =#
            Cʰⁱe::FT = 0.548
            #= none:32 =#
            Cˡᵒe::FT = 7.863
            #= none:33 =#
            Cᵘⁿe::FT = 1.447
            #= none:34 =#
            Cᶜe::FT = 3.642
            #= none:35 =#
            Cᵉe::FT = 0.0
        end)
#= none:42 =#
#= none:42 =# @inline function stratification_mixing_lengthᶜᶜᶠ(i, j, k, grid, closure, e, tracers, buoyancy)
        #= none:42 =#
        #= none:43 =#
        FT = eltype(grid)
        #= none:44 =#
        N² = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:45 =#
        N²⁺ = clip(N²)
        #= none:46 =#
        w★ = ℑzᵃᵃᶠ(i, j, k, grid, turbulent_velocityᶜᶜᶜ, closure, e)
        #= none:47 =#
        return ifelse(N²⁺ == 0, FT(Inf), w★ / sqrt(N²⁺))
    end
#= none:50 =#
#= none:50 =# @inline function stratification_mixing_lengthᶜᶜᶜ(i, j, k, grid, closure, e, tracers, buoyancy)
        #= none:50 =#
        #= none:51 =#
        FT = eltype(grid)
        #= none:52 =#
        N² = ℑbzᵃᵃᶜ(i, j, k, grid, ∂z_b, buoyancy, tracers)
        #= none:53 =#
        N²⁺ = clip(N²)
        #= none:54 =#
        w★ = turbulent_velocityᶜᶜᶜ(i, j, k, grid, closure, e)
        #= none:55 =#
        return ifelse(N²⁺ == 0, FT(Inf), w★ / sqrt(N²⁺))
    end
#= none:58 =#
#= none:58 =# @inline function stable_length_scaleᶜᶜᶠ(i, j, k, grid, closure, e, velocities, tracers, buoyancy)
        #= none:58 =#
        #= none:59 =#
        Cˢ = closure.mixing_length.Cˢ
        #= none:60 =#
        Cᵇ = closure.mixing_length.Cᵇ
        #= none:62 =#
        d_up = Cˢ * depthᶜᶜᶠ(i, j, k, grid)
        #= none:63 =#
        d_down = Cᵇ * height_above_bottomᶜᶜᶠ(i, j, k, grid)
        #= none:64 =#
        d = min(d_up, d_down)
        #= none:66 =#
        ℓᴺ = stratification_mixing_lengthᶜᶜᶠ(i, j, k, grid, closure, e, tracers, buoyancy)
        #= none:68 =#
        ℓ = min(d, ℓᴺ)
        #= none:69 =#
        ℓ = ifelse(isnan(ℓ), d, ℓ)
        #= none:71 =#
        return ℓ
    end
#= none:74 =#
#= none:74 =# @inline function stable_length_scaleᶜᶜᶜ(i, j, k, grid, closure, e, velocities, tracers, buoyancy)
        #= none:74 =#
        #= none:75 =#
        Cˢ = closure.mixing_length.Cˢ
        #= none:76 =#
        Cᵇ = closure.mixing_length.Cᵇ
        #= none:78 =#
        d_up = Cˢ * depthᶜᶜᶜ(i, j, k, grid)
        #= none:79 =#
        d_down = Cᵇ * height_above_bottomᶜᶜᶜ(i, j, k, grid)
        #= none:80 =#
        d = min(d_up, d_down)
        #= none:82 =#
        ℓᴺ = stratification_mixing_lengthᶜᶜᶜ(i, j, k, grid, closure, e, tracers, buoyancy)
        #= none:84 =#
        ℓ = min(d, ℓᴺ)
        #= none:85 =#
        ℓ = ifelse(isnan(ℓ), d, ℓ)
        #= none:87 =#
        return ℓ
    end
#= none:90 =#
#= none:90 =# @inline three_halves_tkeᶜᶜᶜ(i, j, k, grid, closure, e) = begin
            #= none:90 =#
            turbulent_velocityᶜᶜᶜ(i, j, k, grid, closure, e) ^ 3
        end
#= none:91 =#
#= none:91 =# @inline squared_tkeᶜᶜᶜ(i, j, k, grid, closure, e) = begin
            #= none:91 =#
            turbulent_velocityᶜᶜᶜ(i, j, k, grid, closure, e) ^ 2
        end
#= none:93 =#
#= none:93 =# @inline function convective_length_scaleᶜᶜᶠ(i, j, k, grid, closure, Cᶜ::Number, Cᵉ::Number, Cˢᵖ::Number, velocities, tracers, buoyancy, surface_buoyancy_flux)
        #= none:93 =#
        #= none:96 =#
        u = velocities.u
        #= none:97 =#
        v = velocities.v
        #= none:99 =#
        Jᵇᵋ = closure.minimum_convective_buoyancy_flux
        #= none:100 =#
        Jᵇ = #= none:100 =# @inbounds(surface_buoyancy_flux[i, j, 1])
        #= none:101 =#
        w★ = ℑzᵃᵃᶠ(i, j, k, grid, turbulent_velocityᶜᶜᶜ, closure, tracers.e)
        #= none:102 =#
        w★³ = ℑzᵃᵃᶠ(i, j, k, grid, three_halves_tkeᶜᶜᶜ, closure, tracers.e)
        #= none:103 =#
        S² = shearᶜᶜᶠ(i, j, k, grid, u, v)
        #= none:104 =#
        N² = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:105 =#
        N²_above = ∂z_b(i, j, k + 1, grid, buoyancy, tracers)
        #= none:109 =#
        ℓᶜ = (Cᶜ * w★³) / (Jᵇ + Jᵇᵋ)
        #= none:110 =#
        ℓᶜ = ifelse(isnan(ℓᶜ), zero(grid), ℓᶜ)
        #= none:119 =#
        d = depthᶜᶜᶠ(i, j, k, grid)
        #= none:120 =#
        Riᶠ = (d * w★ * S²) / (Jᵇ + Jᵇᵋ)
        #= none:121 =#
        ϵˢᵖ = 1 - Cˢᵖ * Riᶠ
        #= none:122 =#
        ℓᶜ = clip(ϵˢᵖ * ℓᶜ)
        #= none:126 =#
        ℓᵉ = (Cᵉ * Jᵇ) / (w★ * N² + Jᵇᵋ)
        #= none:136 =#
        convecting = (Jᵇ > Jᵇᵋ) & (N² < 0)
        #= none:137 =#
        entraining = ((Jᵇ > Jᵇᵋ) & (N² > 0)) & (N²_above < 0)
        #= none:139 =#
        ℓ = ifelse(convecting, ℓᶜ, ifelse(entraining, ℓᵉ, zero(grid)))
        #= none:142 =#
        return ifelse(isnan(ℓ), zero(grid), ℓ)
    end
#= none:145 =#
#= none:145 =# @inline function convective_length_scaleᶜᶜᶜ(i, j, k, grid, closure, Cᶜ::Number, Cᵉ::Number, Cˢᵖ::Number, velocities, tracers, buoyancy, surface_buoyancy_flux)
        #= none:145 =#
        #= none:148 =#
        u = velocities.u
        #= none:149 =#
        v = velocities.v
        #= none:151 =#
        Jᵇᵋ = closure.minimum_convective_buoyancy_flux
        #= none:152 =#
        Jᵇ = #= none:152 =# @inbounds(surface_buoyancy_flux[i, j, 1])
        #= none:153 =#
        w★ = turbulent_velocityᶜᶜᶜ(i, j, k, grid, closure, tracers.e)
        #= none:154 =#
        w★³ = turbulent_velocityᶜᶜᶜ(i, j, k, grid, closure, tracers.e) ^ 3
        #= none:155 =#
        S² = shearᶜᶜᶜ(i, j, k, grid, u, v)
        #= none:156 =#
        N² = ℑbzᵃᵃᶜ(i, j, k, grid, ∂z_b, buoyancy, tracers)
        #= none:157 =#
        N²_above = ℑbzᵃᵃᶜ(i, j, k + 1, grid, ∂z_b, buoyancy, tracers)
        #= none:161 =#
        ℓᶜ = (Cᶜ * w★³) / (Jᵇ + Jᵇᵋ)
        #= none:162 =#
        ℓᶜ = ifelse(isnan(ℓᶜ), zero(grid), ℓᶜ)
        #= none:165 =#
        convecting = (Jᵇ > Jᵇᵋ) & (N² < 0)
        #= none:173 =#
        d = depthᶜᶜᶜ(i, j, k, grid)
        #= none:174 =#
        Riᶠ = (d * S² * w★) / (Jᵇ + Jᵇᵋ)
        #= none:175 =#
        ϵˢᵖ = 1 - Cˢᵖ * Riᶠ
        #= none:176 =#
        ℓᶜ = clip(ϵˢᵖ * ℓᶜ)
        #= none:180 =#
        ℓᵉ = (Cᵉ * Jᵇ) / (w★ * N² + Jᵇᵋ)
        #= none:187 =#
        entraining = ((Jᵇ > Jᵇᵋ) & (N² > 0)) & (N²_above < 0)
        #= none:189 =#
        ℓ = ifelse(convecting, ℓᶜ, ifelse(entraining, ℓᵉ, zero(grid)))
        #= none:192 =#
        return ifelse(isnan(ℓ), zero(grid), ℓ)
    end
#= none:195 =#
#= none:195 =# Core.@doc "Piecewise linear function between 0 (when x < c) and 1 (when x - c > w)." #= none:196 =# @inline(step(x, c, w) = begin
                #= none:196 =#
                max(zero(x), min(one(x), (x - c) / w))
            end)
#= none:198 =#
#= none:198 =# @inline function scale(Ri, σ⁻, σ⁰, σ∞, c, w)
        #= none:198 =#
        #= none:199 =#
        σ⁺ = σ⁰ + (σ∞ - σ⁰) * step(Ri, c, w)
        #= none:200 =#
        σ = σ⁻ * (Ri < 0) + σ⁺ * (Ri ≥ 0)
        #= none:201 =#
        return σ
    end
#= none:204 =#
#= none:204 =# @inline function stability_functionᶜᶜᶠ(i, j, k, grid, closure, Cᵘⁿ, Cˡᵒ, Cʰⁱ, velocities, tracers, buoyancy)
        #= none:204 =#
        #= none:205 =#
        Ri = Riᶜᶜᶠ(i, j, k, grid, velocities, tracers, buoyancy)
        #= none:206 =#
        CRi⁰ = closure.mixing_length.CRi⁰
        #= none:207 =#
        CRiᵟ = closure.mixing_length.CRiᵟ
        #= none:208 =#
        return scale(Ri, Cᵘⁿ, Cˡᵒ, Cʰⁱ, CRi⁰, CRiᵟ)
    end
#= none:211 =#
#= none:211 =# @inline function stability_functionᶜᶜᶜ(i, j, k, grid, closure, Cᵘⁿ, Cˡᵒ, Cʰⁱ, velocities, tracers, buoyancy)
        #= none:211 =#
        #= none:212 =#
        Ri = Riᶜᶜᶜ(i, j, k, grid, velocities, tracers, buoyancy)
        #= none:213 =#
        CRi⁰ = closure.mixing_length.CRi⁰
        #= none:214 =#
        CRiᵟ = closure.mixing_length.CRiᵟ
        #= none:215 =#
        return scale(Ri, Cᵘⁿ, Cˡᵒ, Cʰⁱ, CRi⁰, CRiᵟ)
    end
#= none:218 =#
#= none:218 =# @inline function momentum_mixing_lengthᶜᶜᶠ(i, j, k, grid, closure, velocities, tracers, buoyancy, surface_buoyancy_flux)
        #= none:218 =#
        #= none:219 =#
        Cᶜ = closure.mixing_length.Cᶜu
        #= none:220 =#
        Cᵉ = closure.mixing_length.Cᵉu
        #= none:221 =#
        Cˢᵖ = closure.mixing_length.Cˢᵖ
        #= none:222 =#
        ℓʰ = convective_length_scaleᶜᶜᶠ(i, j, k, grid, closure, Cᶜ, Cᵉ, Cˢᵖ, velocities, tracers, buoyancy, surface_buoyancy_flux)
        #= none:224 =#
        Cᵘⁿ = closure.mixing_length.Cᵘⁿu
        #= none:225 =#
        Cˡᵒ = closure.mixing_length.Cˡᵒu
        #= none:226 =#
        Cʰⁱ = closure.mixing_length.Cʰⁱu
        #= none:227 =#
        σ = stability_functionᶜᶜᶠ(i, j, k, grid, closure, Cᵘⁿ, Cˡᵒ, Cʰⁱ, velocities, tracers, buoyancy)
        #= none:229 =#
        ℓ★ = σ * stable_length_scaleᶜᶜᶠ(i, j, k, grid, closure, tracers.e, velocities, tracers, buoyancy)
        #= none:231 =#
        ℓʰ = ifelse(isnan(ℓʰ), zero(grid), ℓʰ)
        #= none:232 =#
        ℓ★ = ifelse(isnan(ℓ★), zero(grid), ℓ★)
        #= none:233 =#
        ℓu = max(ℓ★, ℓʰ)
        #= none:235 =#
        H = total_depthᶜᶜᵃ(i, j, grid)
        #= none:236 =#
        return min(H, ℓu)
    end
#= none:239 =#
#= none:239 =# @inline function tracer_mixing_lengthᶜᶜᶠ(i, j, k, grid, closure, velocities, tracers, buoyancy, surface_buoyancy_flux)
        #= none:239 =#
        #= none:240 =#
        Cᶜ = closure.mixing_length.Cᶜc
        #= none:241 =#
        Cᵉ = closure.mixing_length.Cᵉc
        #= none:242 =#
        Cˢᵖ = closure.mixing_length.Cˢᵖ
        #= none:243 =#
        ℓʰ = convective_length_scaleᶜᶜᶠ(i, j, k, grid, closure, Cᶜ, Cᵉ, Cˢᵖ, velocities, tracers, buoyancy, surface_buoyancy_flux)
        #= none:245 =#
        Cᵘⁿ = closure.mixing_length.Cᵘⁿc
        #= none:246 =#
        Cˡᵒ = closure.mixing_length.Cˡᵒc
        #= none:247 =#
        Cʰⁱ = closure.mixing_length.Cʰⁱc
        #= none:248 =#
        σ = stability_functionᶜᶜᶠ(i, j, k, grid, closure, Cᵘⁿ, Cˡᵒ, Cʰⁱ, velocities, tracers, buoyancy)
        #= none:249 =#
        ℓ★ = σ * stable_length_scaleᶜᶜᶠ(i, j, k, grid, closure, tracers.e, velocities, tracers, buoyancy)
        #= none:251 =#
        ℓʰ = ifelse(isnan(ℓʰ), zero(grid), ℓʰ)
        #= none:252 =#
        ℓ★ = ifelse(isnan(ℓ★), zero(grid), ℓ★)
        #= none:253 =#
        ℓc = max(ℓ★, ℓʰ)
        #= none:255 =#
        H = total_depthᶜᶜᵃ(i, j, grid)
        #= none:256 =#
        return min(H, ℓc)
    end
#= none:259 =#
#= none:259 =# @inline function TKE_mixing_lengthᶜᶜᶠ(i, j, k, grid, closure, velocities, tracers, buoyancy, surface_buoyancy_flux)
        #= none:259 =#
        #= none:260 =#
        Cᶜ = closure.mixing_length.Cᶜe
        #= none:261 =#
        Cᵉ = closure.mixing_length.Cᵉe
        #= none:262 =#
        Cˢᵖ = closure.mixing_length.Cˢᵖ
        #= none:263 =#
        ℓʰ = convective_length_scaleᶜᶜᶠ(i, j, k, grid, closure, Cᶜ, Cᵉ, Cˢᵖ, velocities, tracers, buoyancy, surface_buoyancy_flux)
        #= none:265 =#
        Cᵘⁿ = closure.mixing_length.Cᵘⁿe
        #= none:266 =#
        Cˡᵒ = closure.mixing_length.Cˡᵒe
        #= none:267 =#
        Cʰⁱ = closure.mixing_length.Cʰⁱe
        #= none:268 =#
        σ = stability_functionᶜᶜᶠ(i, j, k, grid, closure, Cᵘⁿ, Cˡᵒ, Cʰⁱ, velocities, tracers, buoyancy)
        #= none:269 =#
        ℓ★ = σ * stable_length_scaleᶜᶜᶠ(i, j, k, grid, closure, tracers.e, velocities, tracers, buoyancy)
        #= none:271 =#
        ℓʰ = ifelse(isnan(ℓʰ), zero(grid), ℓʰ)
        #= none:272 =#
        ℓ★ = ifelse(isnan(ℓ★), zero(grid), ℓ★)
        #= none:273 =#
        ℓe = max(ℓ★, ℓʰ)
        #= none:275 =#
        H = total_depthᶜᶜᵃ(i, j, grid)
        #= none:276 =#
        return min(H, ℓe)
    end
#= none:279 =#
Base.summary(::CATKEMixingLength) = begin
        #= none:279 =#
        "TKEBasedVerticalDiffusivities.CATKEMixingLength"
    end
#= none:281 =#
Base.show(io::IO, ml::CATKEMixingLength) = begin
        #= none:281 =#
        print(io, "TKEBasedVerticalDiffusivities.CATKEMixingLength parameters:", '\n', " ├── Cˢ:   ", ml.Cˢ, '\n', " ├── Cᵇ:   ", ml.Cᵇ, '\n', " ├── Cʰⁱu: ", ml.Cʰⁱu, '\n', " ├── Cʰⁱc: ", ml.Cʰⁱc, '\n', " ├── Cʰⁱe: ", ml.Cʰⁱe, '\n', " ├── Cˡᵒu: ", ml.Cˡᵒu, '\n', " ├── Cˡᵒc: ", ml.Cˡᵒc, '\n', " ├── Cˡᵒe: ", ml.Cˡᵒe, '\n', " ├── Cᵘⁿu: ", ml.Cᵘⁿu, '\n', " ├── Cᵘⁿc: ", ml.Cᵘⁿc, '\n', " ├── Cᵘⁿe: ", ml.Cᵘⁿe, '\n', " ├── Cᶜu:  ", ml.Cᶜu, '\n', " ├── Cᶜc:  ", ml.Cᶜc, '\n', " ├── Cᶜe:  ", ml.Cᶜe, '\n', " ├── Cᵉc:  ", ml.Cᵉc, '\n', " ├── Cᵉe:  ", ml.Cᵉe, '\n', " ├── Cˢᵖ:  ", ml.Cˢᵖ, '\n', " ├── CRiᵟ: ", ml.CRiᵟ, '\n', " └── CRi⁰: ", ml.CRi⁰)
    end