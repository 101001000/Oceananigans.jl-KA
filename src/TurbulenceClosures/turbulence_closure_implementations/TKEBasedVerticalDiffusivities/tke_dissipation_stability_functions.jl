
#= none:1 =#
abstract type AbstractConstantSchmidtStabilityFunctions end
#= none:3 =#
const ConstantSchmidtStabilityTDVD = TKEDissipationVerticalDiffusivity{<:Any, <:Any, <:AbstractConstantSchmidtStabilityFunctions}
#= none:5 =#
#= none:5 =# @inline function tke_stability_functionᶜᶜᶠ(i, j, k, grid, closure::ConstantSchmidtStabilityTDVD, args...)
        #= none:5 =#
        #= none:6 =#
        Cσe = closure.stability_functions.Cσe
        #= none:7 =#
        𝕊u = momentum_stability_functionᶜᶜᶠ(i, j, k, grid, closure, args...)
        #= none:8 =#
        return 𝕊u / Cσe
    end
#= none:11 =#
#= none:11 =# @inline function dissipation_stability_functionᶜᶜᶠ(i, j, k, grid, closure::ConstantSchmidtStabilityTDVD, args...)
        #= none:11 =#
        #= none:12 =#
        Cσϵ = closure.stability_functions.Cσϵ
        #= none:13 =#
        𝕊u = momentum_stability_functionᶜᶜᶠ(i, j, k, grid, closure, args...)
        #= none:14 =#
        return 𝕊u / Cσϵ
    end
#= none:17 =#
#= none:17 =# Base.@kwdef struct ConstantStabilityFunctions{FT} <: AbstractConstantSchmidtStabilityFunctions
        #= none:18 =#
        Cσe::FT = 1.0
        #= none:19 =#
        Cσϵ::FT = 1.2
        #= none:20 =#
        Cu₀::FT = 0.53
        #= none:21 =#
        Cc₀::FT = 0.53
        #= none:22 =#
        𝕊u₀::FT = 0.53
    end
#= none:25 =#
(Base.summary(s::ConstantStabilityFunctions{FT}) where FT) = begin
        #= none:25 =#
        "ConstantStabilityFunctions{$(FT)}"
    end
#= none:27 =#
(summarize_stability_functions(s::ConstantStabilityFunctions{FT}, prefix = "", sep = "│   ") where FT) = begin
        #= none:27 =#
        string(prefix, "ConstantStabilityFunctions{$(FT)}:", '\n', "    ├── 𝕊u₀: ", prettysummary(s.𝕊u₀), '\n', "    ├── Cσe: ", prettysummary(s.Cσe), '\n', "    ├── Cσϵ: ", prettysummary(s.Cσϵ), '\n', "    ├── Cu₀: ", prettysummary(s.Cu₀), '\n', "    └── Cc₀: ", prettysummary(s.Cc₀))
    end
#= none:35 =#
const ConstantStabilityTDVD = TKEDissipationVerticalDiffusivity{<:Any, <:Any, <:ConstantStabilityFunctions}
#= none:37 =#
#= none:37 =# @inline momentum_stability_functionᶜᶜᶠ(i, j, k, grid, c::ConstantStabilityTDVD, args...) = begin
            #= none:37 =#
            c.stability_functions.Cu₀
        end
#= none:38 =#
#= none:38 =# @inline tracer_stability_functionᶜᶜᶠ(i, j, k, grid, c::ConstantStabilityTDVD, args...) = begin
            #= none:38 =#
            c.stability_functions.Cc₀
        end
#= none:40 =#
struct VariableStabilityFunctions{FT} <: AbstractConstantSchmidtStabilityFunctions
    #= none:41 =#
    Cσe::FT
    #= none:42 =#
    Cσϵ::FT
    #= none:43 =#
    Cu₀::FT
    #= none:44 =#
    Cu₁::FT
    #= none:45 =#
    Cu₂::FT
    #= none:46 =#
    Cc₀::FT
    #= none:47 =#
    Cc₁::FT
    #= none:48 =#
    Cc₂::FT
    #= none:49 =#
    Cd₀::FT
    #= none:50 =#
    Cd₁::FT
    #= none:51 =#
    Cd₂::FT
    #= none:52 =#
    Cd₃::FT
    #= none:53 =#
    Cd₄::FT
    #= none:54 =#
    Cd₅::FT
    #= none:55 =#
    𝕊u₀::FT
end
#= none:58 =#
function VariableStabilityFunctions(FT = Float64; Cσe = 1.0, Cσϵ = 1.2, Cu₀ = 0.1067, Cu₁ = 0.0173, Cu₂ = -0.0001205, Cc₀ = 0.112, Cc₁ = 0.003766, Cc₂ = 0.0008871, Cd₀ = 1.0, Cd₁ = 0.2398, Cd₂ = 0.02872, Cd₃ = 0.005154, Cd₄ = 0.00693, Cd₅ = -0.0003372, 𝕊u₀ = nothing)
    #= none:58 =#
    #= none:75 =#
    if isnothing(𝕊u₀)
        #= none:79 =#
        a = Cd₅ - Cu₂
        #= none:80 =#
        b = Cd₂ - Cu₀
        #= none:81 =#
        c = Cd₀
        #= none:82 =#
        𝕊u₀ = ((2a) / (-b - sqrt(b ^ 2 - (4a) * c))) ^ (1 / 4)
    end
    #= none:85 =#
    return VariableStabilityFunctions(convert(FT, Cσe), convert(FT, Cσϵ), convert(FT, Cu₀), convert(FT, Cu₁), convert(FT, Cu₂), convert(FT, Cc₀), convert(FT, Cc₁), convert(FT, Cc₂), convert(FT, Cd₀), convert(FT, Cd₁), convert(FT, Cd₂), convert(FT, Cd₃), convert(FT, Cd₄), convert(FT, Cd₅), convert(FT, 𝕊u₀))
end
#= none:102 =#
(Base.summary(s::VariableStabilityFunctions{FT}) where FT) = begin
        #= none:102 =#
        "VariableStabilityFunctions{$(FT)}"
    end
#= none:104 =#
(summarize_stability_functions(s::VariableStabilityFunctions{FT}, prefix = "", sep = "") where FT) = begin
        #= none:104 =#
        string("VariableStabilityFunctions{$(FT)}:", '\n', "    ├── Cσe: ", prettysummary(s.Cσe), '\n', "    ├── Cσϵ: ", prettysummary(s.Cσϵ), '\n', "    ├── Cu₀: ", prettysummary(s.Cu₀), '\n', "    ├── Cu₁: ", prettysummary(s.Cu₁), '\n', "    ├── Cu₂: ", prettysummary(s.Cu₂), '\n', "    ├── Cc₀: ", prettysummary(s.Cc₀), '\n', "    ├── Cc₁: ", prettysummary(s.Cc₁), '\n', "    ├── Cc₂: ", prettysummary(s.Cc₂), '\n', "    ├── Cd₀: ", prettysummary(s.Cd₀), '\n', "    ├── Cd₁: ", prettysummary(s.Cd₁), '\n', "    ├── Cd₂: ", prettysummary(s.Cd₂), '\n', "    ├── Cd₃: ", prettysummary(s.Cd₃), '\n', "    ├── Cd₄: ", prettysummary(s.Cd₄), '\n', "    └── Cd₅: ", prettysummary(s.Cd₅))
    end
#= none:121 =#
#= none:121 =# @inline function square_time_scaleᶜᶜᶜ(i, j, k, grid, closure, tracers, buoyancy)
        #= none:121 =#
        #= none:122 =#
        e★ = turbulent_kinetic_energyᶜᶜᶜ(i, j, k, grid, closure, tracers)
        #= none:123 =#
        ϵ★ = dissipationᶜᶜᶜ(i, j, k, grid, closure, tracers, buoyancy)
        #= none:124 =#
        return e★ ^ 2 / ϵ★ ^ 2
    end
#= none:127 =#
#= none:127 =# @inline function shear_numberᶜᶜᶠ(i, j, k, grid, closure, velocities, tracers, buoyancy)
        #= none:127 =#
        #= none:128 =#
        τ² = ℑzᵃᵃᶠ(i, j, k, grid, square_time_scaleᶜᶜᶜ, closure, tracers, buoyancy)
        #= none:129 =#
        S² = shearᶜᶜᶠ(i, j, k, grid, velocities.u, velocities.v)
        #= none:130 =#
        return τ² * S²
    end
#= none:133 =#
#= none:133 =# @inline function stratification_numberᶜᶜᶠ(i, j, k, grid, closure, tracers, buoyancy)
        #= none:133 =#
        #= none:134 =#
        τ² = ℑzᵃᵃᶠ(i, j, k, grid, square_time_scaleᶜᶜᶜ, closure, tracers, buoyancy)
        #= none:135 =#
        N² = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:136 =#
        return τ² * N²
    end
#= none:139 =#
#= none:139 =# @inline maximum_stratification_number(closure) = begin
            #= none:139 =#
            1.0e10
        end
#= none:141 =#
#= none:141 =# Core.@doc "Based on an argument for free convection, assuming a balance between\nbuoyancy production and dissipation.\n\nSee Umlauf and Burchard (2005) equation A.22.\n\nNote that _another_ condition could arise depending on the time discretization,\nas discussed in the text surrounding equation 45-46 in Umlauf and Buchard (2005).\n" #= none:150 =# @inline(function minimum_stratification_number(closure)
            #= none:150 =#
            #= none:151 =#
            m₀ = closure.stability_functions.Cc₀
            #= none:152 =#
            m₁ = closure.stability_functions.Cc₁
            #= none:153 =#
            m₂ = closure.stability_functions.Cc₂
            #= none:155 =#
            d₀ = closure.stability_functions.Cd₀
            #= none:156 =#
            d₁ = closure.stability_functions.Cd₁
            #= none:157 =#
            d₂ = closure.stability_functions.Cd₂
            #= none:158 =#
            d₃ = closure.stability_functions.Cd₃
            #= none:159 =#
            d₄ = closure.stability_functions.Cd₄
            #= none:160 =#
            d₅ = closure.stability_functions.Cd₅
            #= none:162 =#
            a = d₄ + m₁
            #= none:163 =#
            b = d₁ + m₀
            #= none:164 =#
            c = d₀
            #= none:166 =#
            αᴺmin = (-b + sqrt(b ^ 2 - (4a) * c)) / (2a)
            #= none:169 =#
            ϵ = closure.minimum_stratification_number_safety_factor
            #= none:170 =#
            αᴺmin *= ϵ
            #= none:172 =#
            return αᴺmin
        end)
#= none:175 =#
#= none:175 =# @inline minimum_shear_number(closure::FlavorOfTD) = begin
            #= none:175 =#
            zero(eltype(closure))
        end
#= none:177 =#
#= none:177 =# Core.@doc "Based on the condition that shear aniostropy must increase.\n\nSee Umlauf and Burchard (2005) equation 44.\n" #= none:182 =# @inline(function maximum_shear_number(closure, αᴺ)
            #= none:182 =#
            #= none:183 =#
            n₀ = closure.stability_functions.Cu₀
            #= none:184 =#
            n₁ = closure.stability_functions.Cu₁
            #= none:185 =#
            n₂ = closure.stability_functions.Cu₂
            #= none:187 =#
            d₀ = closure.stability_functions.Cd₀
            #= none:188 =#
            d₁ = closure.stability_functions.Cd₁
            #= none:189 =#
            d₂ = closure.stability_functions.Cd₂
            #= none:190 =#
            d₃ = closure.stability_functions.Cd₃
            #= none:191 =#
            d₄ = closure.stability_functions.Cd₄
            #= none:192 =#
            d₅ = closure.stability_functions.Cd₅
            #= none:194 =#
            ϵ₀ = d₀ * n₀
            #= none:195 =#
            ϵ₁ = d₀ * n₁ + d₁ * n₀
            #= none:196 =#
            ϵ₂ = d₁ * n₁ + d₄ * n₀
            #= none:197 =#
            ϵ₃ = d₄ * n₁
            #= none:198 =#
            ϵ₄ = d₂ * n₀
            #= none:199 =#
            ϵ₅ = d₂ * n₁ + d₃ * n₀
            #= none:200 =#
            ϵ₆ = d₃ * n₁
            #= none:202 =#
            num = ϵ₀ + ϵ₁ * αᴺ + ϵ₂ * αᴺ ^ 2 + ϵ₃ * αᴺ ^ 3
            #= none:203 =#
            den = ϵ₄ + ϵ₅ * αᴺ + ϵ₆ * αᴺ ^ 2
            #= none:205 =#
            return num / den
        end)
#= none:208 =#
const VariableStabilityTDVD = TKEDissipationVerticalDiffusivity{<:Any, <:Any, <:VariableStabilityFunctions}
#= none:210 =#
#= none:210 =# @inline function momentum_stability_functionᶜᶜᶠ(i, j, k, grid, closure::VariableStabilityTDVD, velocities, tracers, buoyancy)
        #= none:210 =#
        #= none:211 =#
        αᴺ = stratification_numberᶜᶜᶠ(i, j, k, grid, closure, tracers, buoyancy)
        #= none:212 =#
        αᴹ = shear_numberᶜᶜᶠ(i, j, k, grid, closure, velocities, tracers, buoyancy)
        #= none:214 =#
        αᴺmin = minimum_stratification_number(closure)
        #= none:215 =#
        αᴺmax = maximum_stratification_number(closure)
        #= none:216 =#
        αᴺ = clamp(αᴺ, αᴺmin, αᴺmax)
        #= none:218 =#
        αᴹmin = minimum_shear_number(closure)
        #= none:219 =#
        αᴹmax = maximum_shear_number(closure, αᴺ)
        #= none:220 =#
        αᴹ = clamp(αᴹ, αᴹmin, αᴹmax)
        #= none:222 =#
        𝕊u = momentum_stability_function(closure, αᴺ, αᴹ)
        #= none:223 =#
        return 𝕊u
    end
#= none:226 =#
#= none:226 =# @inline function momentum_stability_function(closure::VariableStabilityTDVD, αᴺ::Number, αᴹ::Number)
        #= none:226 =#
        #= none:227 =#
        Cu₀ = closure.stability_functions.Cu₀
        #= none:228 =#
        Cu₁ = closure.stability_functions.Cu₁
        #= none:229 =#
        Cu₂ = closure.stability_functions.Cu₂
        #= none:231 =#
        Cd₀ = closure.stability_functions.Cd₀
        #= none:232 =#
        Cd₁ = closure.stability_functions.Cd₁
        #= none:233 =#
        Cd₂ = closure.stability_functions.Cd₂
        #= none:234 =#
        Cd₃ = closure.stability_functions.Cd₃
        #= none:235 =#
        Cd₄ = closure.stability_functions.Cd₄
        #= none:236 =#
        Cd₅ = closure.stability_functions.Cd₅
        #= none:238 =#
        num = Cu₀ + Cu₁ * αᴺ + Cu₂ * αᴹ
        #= none:242 =#
        den = Cd₀ + Cd₁ * αᴺ + Cd₂ * αᴹ + Cd₃ * αᴺ * αᴹ + Cd₄ * αᴺ ^ 2 + Cd₅ * αᴹ ^ 2
        #= none:248 =#
        return num / den
    end
#= none:251 =#
#= none:251 =# @inline function tracer_stability_functionᶜᶜᶠ(i, j, k, grid, closure::VariableStabilityTDVD, velocities, tracers, buoyancy)
        #= none:251 =#
        #= none:252 =#
        αᴺ = stratification_numberᶜᶜᶠ(i, j, k, grid, closure, tracers, buoyancy)
        #= none:253 =#
        αᴹ = shear_numberᶜᶜᶠ(i, j, k, grid, closure, velocities, tracers, buoyancy)
        #= none:255 =#
        αᴺmin = minimum_stratification_number(closure)
        #= none:256 =#
        αᴺmax = maximum_stratification_number(closure)
        #= none:257 =#
        αᴺ = clamp(αᴺ, αᴺmin, αᴺmax)
        #= none:259 =#
        αᴹmin = minimum_shear_number(closure)
        #= none:260 =#
        αᴹmax = maximum_shear_number(closure, αᴺ)
        #= none:261 =#
        αᴹ = clamp(αᴹ, αᴹmin, αᴹmax)
        #= none:263 =#
        𝕊c = tracer_stability_function(closure, αᴺ, αᴹ)
        #= none:264 =#
        return 𝕊c
    end
#= none:267 =#
#= none:267 =# @inline function tracer_stability_function(closure::VariableStabilityTDVD, αᴺ::Number, αᴹ::Number)
        #= none:267 =#
        #= none:268 =#
        Cc₀ = closure.stability_functions.Cc₀
        #= none:269 =#
        Cc₁ = closure.stability_functions.Cc₁
        #= none:270 =#
        Cc₂ = closure.stability_functions.Cc₂
        #= none:272 =#
        Cd₀ = closure.stability_functions.Cd₀
        #= none:273 =#
        Cd₁ = closure.stability_functions.Cd₁
        #= none:274 =#
        Cd₂ = closure.stability_functions.Cd₂
        #= none:275 =#
        Cd₃ = closure.stability_functions.Cd₃
        #= none:276 =#
        Cd₄ = closure.stability_functions.Cd₄
        #= none:277 =#
        Cd₅ = closure.stability_functions.Cd₅
        #= none:279 =#
        num = Cc₀ + Cc₁ * αᴺ + Cc₂ * αᴹ
        #= none:283 =#
        den = Cd₀ + Cd₁ * αᴺ + Cd₂ * αᴹ + Cd₃ * αᴺ * αᴹ + Cd₄ * αᴺ ^ 2 + Cd₅ * αᴹ ^ 2
        #= none:290 =#
        return num / den
    end