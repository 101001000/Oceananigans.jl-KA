
#= none:1 =#
module StokesDrifts
#= none:1 =#
#= none:3 =#
export UniformStokesDrift, StokesDrift, ∂t_uˢ, ∂t_vˢ, ∂t_wˢ, x_curl_Uˢ_cross_U, y_curl_Uˢ_cross_U, z_curl_Uˢ_cross_U
#= none:13 =#
using Adapt: adapt
#= none:15 =#
using Oceananigans.Fields
#= none:16 =#
using Oceananigans.Operators
#= none:18 =#
using Oceananigans.Grids: AbstractGrid, node
#= none:19 =#
using Oceananigans.Utils: prettysummary
#= none:21 =#
import Adapt: adapt_structure
#= none:27 =#
#= none:27 =# @inline ∂t_uˢ(i, j, k, grid, ::Nothing, time) = begin
            #= none:27 =#
            zero(grid)
        end
#= none:28 =#
#= none:28 =# @inline ∂t_vˢ(i, j, k, grid, ::Nothing, time) = begin
            #= none:28 =#
            zero(grid)
        end
#= none:29 =#
#= none:29 =# @inline ∂t_wˢ(i, j, k, grid, ::Nothing, time) = begin
            #= none:29 =#
            zero(grid)
        end
#= none:31 =#
#= none:31 =# @inline x_curl_Uˢ_cross_U(i, j, k, grid, ::Nothing, U, time) = begin
            #= none:31 =#
            zero(grid)
        end
#= none:32 =#
#= none:32 =# @inline y_curl_Uˢ_cross_U(i, j, k, grid, ::Nothing, U, time) = begin
            #= none:32 =#
            zero(grid)
        end
#= none:33 =#
#= none:33 =# @inline z_curl_Uˢ_cross_U(i, j, k, grid, ::Nothing, U, time) = begin
            #= none:33 =#
            zero(grid)
        end
#= none:39 =#
struct UniformStokesDrift{P, UZ, VZ, UT, VT}
    #= none:40 =#
    ∂z_uˢ::UZ
    #= none:41 =#
    ∂z_vˢ::VZ
    #= none:42 =#
    ∂t_uˢ::UT
    #= none:43 =#
    ∂t_vˢ::VT
    #= none:44 =#
    parameters::P
end
#= none:47 =#
adapt_structure(to, sd::UniformStokesDrift) = begin
        #= none:47 =#
        UniformStokesDrift(adapt(to, sd.∂z_uˢ), adapt(to, sd.∂z_vˢ), adapt(to, sd.∂t_uˢ), adapt(to, sd.∂t_vˢ), adapt(to, sd.parameters))
    end
#= none:53 =#
Base.summary(::UniformStokesDrift{Nothing}) = begin
        #= none:53 =#
        "UniformStokesDrift{Nothing}"
    end
#= none:55 =#
function Base.summary(usd::UniformStokesDrift)
    #= none:55 =#
    #= none:56 =#
    p_str = prettysummary(usd.parameters)
    #= none:57 =#
    return "UniformStokesDrift with parameters $(p_str)"
end
#= none:60 =#
function Base.show(io::IO, usd::UniformStokesDrift)
    #= none:60 =#
    #= none:61 =#
    print(io, summary(usd), ':', '\n')
    #= none:62 =#
    print(io, "├── ∂z_uˢ: ", prettysummary(usd.∂z_uˢ, false), '\n')
    #= none:63 =#
    print(io, "├── ∂z_vˢ: ", prettysummary(usd.∂z_vˢ, false), '\n')
    #= none:64 =#
    print(io, "├── ∂t_uˢ: ", prettysummary(usd.∂t_uˢ, false), '\n')
    #= none:65 =#
    print(io, "└── ∂t_vˢ: ", prettysummary(usd.∂t_vˢ, false))
end
#= none:68 =#
#= none:68 =# @inline zerofunction(args...) = begin
            #= none:68 =#
            0
        end
#= none:70 =#
#= none:70 =# Core.@doc "    UniformStokesDrift(; ∂z_uˢ=zerofunction, ∂z_vˢ=zerofunction, ∂t_uˢ=zerofunction, ∂t_vˢ=zerofunction, parameters=nothing)\n\nConstruct a set of functions for a Stokes drift velocity field\ncorresponding to a horizontally-uniform surface gravity wave field, with optional `parameters`.\n\nIf `parameters=nothing`, then the functions `∂z_uˢ`, `∂z_vˢ`, `∂t_uˢ`, `∂t_vˢ` must be callable\nwith signature `(z, t)`. If `!isnothing(parameters)`, then functions must be callable with\nthe signature `(z, t, parameters)`.\n\nTo resolve the evolution of the Lagrangian-mean momentum, we require vertical-derivatives\nand time-derivatives of the horizontal components of the Stokes drift, `uˢ` and `vˢ`.\n\nExamples\n========\n\nExponentially decaying Stokes drift corresponding to a surface Stokes drift of\n`uˢ(z=0) = 0.005` and decay scale `h = 20`:\n\n```jldoctest\nusing Oceananigans\n\n@inline uniform_stokes_shear(z, t) = 0.005 * exp(z / 20)\n\nstokes_drift = UniformStokesDrift(∂z_uˢ=uniform_stokes_shear)\n\n# output\n\nUniformStokesDrift{Nothing}:\n├── ∂z_uˢ: uniform_stokes_shear\n├── ∂z_vˢ: zerofunction\n├── ∂t_uˢ: zerofunction\n└── ∂t_vˢ: zerofunction\n```\n\nExponentially-decaying Stokes drift corresponding to a surface Stokes drift of\n`uˢ = 0.005` and decay scale `h = 20`, using parameters:\n\n```jldoctest\nusing Oceananigans\n\n@inline uniform_stokes_shear(z, t, p) = p.uˢ * exp(z / p.h)\n\nstokes_drift_parameters = (uˢ = 0.005, h = 20)\nstokes_drift = UniformStokesDrift(∂z_uˢ=uniform_stokes_shear, parameters=stokes_drift_parameters)\n\n# output\n\nUniformStokesDrift with parameters (uˢ=0.005, h=20):\n├── ∂z_uˢ: uniform_stokes_shear\n├── ∂z_vˢ: zerofunction\n├── ∂t_uˢ: zerofunction\n└── ∂t_vˢ: zerofunction\n```\n" UniformStokesDrift(; ∂z_uˢ = zerofunction, ∂z_vˢ = zerofunction, ∂t_uˢ = zerofunction, ∂t_vˢ = zerofunction, parameters = nothing) = begin
            #= none:125 =#
            UniformStokesDrift(∂z_uˢ, ∂z_vˢ, ∂t_uˢ, ∂t_vˢ, parameters)
        end
#= none:128 =#
const USD = UniformStokesDrift
#= none:129 =#
const USDnoP = UniformStokesDrift{<:Nothing}
#= none:130 =#
const f = Face()
#= none:131 =#
const c = Center()
#= none:133 =#
#= none:133 =# @inline ∂t_uˢ(i, j, k, grid, sw::USD, time) = begin
            #= none:133 =#
            sw.∂t_uˢ(znode(k, grid, c), time, sw.parameters)
        end
#= none:134 =#
#= none:134 =# @inline ∂t_vˢ(i, j, k, grid, sw::USD, time) = begin
            #= none:134 =#
            sw.∂t_vˢ(znode(k, grid, c), time, sw.parameters)
        end
#= none:135 =#
#= none:135 =# @inline ∂t_wˢ(i, j, k, grid, sw::USD, time) = begin
            #= none:135 =#
            zero(grid)
        end
#= none:137 =#
#= none:137 =# @inline x_curl_Uˢ_cross_U(i, j, k, grid, sw::USD, U, time) = begin
            #= none:137 =#
            ℑxzᶠᵃᶜ(i, j, k, grid, U.w) * sw.∂z_uˢ(znode(k, grid, c), time, sw.parameters)
        end
#= none:138 =#
#= none:138 =# @inline y_curl_Uˢ_cross_U(i, j, k, grid, sw::USD, U, time) = begin
            #= none:138 =#
            ℑyzᵃᶠᶜ(i, j, k, grid, U.w) * sw.∂z_vˢ(znode(k, grid, c), time, sw.parameters)
        end
#= none:139 =#
#= none:139 =# @inline z_curl_Uˢ_cross_U(i, j, k, grid, sw::USD, U, time) = begin
            #= none:139 =#
            -(ℑxzᶜᵃᶠ(i, j, k, grid, U.u)) * sw.∂z_uˢ(znode(k, grid, f), time, sw.parameters) - ℑyzᵃᶜᶠ(i, j, k, grid, U.v) * sw.∂z_vˢ(znode(k, grid, f), time, sw.parameters)
        end
#= none:143 =#
#= none:143 =# @inline ∂t_uˢ(i, j, k, grid, sw::USDnoP, time) = begin
            #= none:143 =#
            sw.∂t_uˢ(znode(k, grid, c), time)
        end
#= none:144 =#
#= none:144 =# @inline ∂t_vˢ(i, j, k, grid, sw::USDnoP, time) = begin
            #= none:144 =#
            sw.∂t_vˢ(znode(k, grid, c), time)
        end
#= none:146 =#
#= none:146 =# @inline x_curl_Uˢ_cross_U(i, j, k, grid, sw::USDnoP, U, time) = begin
            #= none:146 =#
            ℑxzᶠᵃᶜ(i, j, k, grid, U.w) * sw.∂z_uˢ(znode(k, grid, c), time)
        end
#= none:147 =#
#= none:147 =# @inline y_curl_Uˢ_cross_U(i, j, k, grid, sw::USDnoP, U, time) = begin
            #= none:147 =#
            ℑyzᵃᶠᶜ(i, j, k, grid, U.w) * sw.∂z_vˢ(znode(k, grid, c), time)
        end
#= none:148 =#
#= none:148 =# @inline z_curl_Uˢ_cross_U(i, j, k, grid, sw::USDnoP, U, time) = begin
            #= none:148 =#
            -(ℑxzᶜᵃᶠ(i, j, k, grid, U.u)) * sw.∂z_uˢ(znode(k, grid, f), time) - ℑyzᵃᶜᶠ(i, j, k, grid, U.v) * sw.∂z_vˢ(znode(k, grid, f), time)
        end
#= none:151 =#
struct StokesDrift{P, VX, WX, UY, WY, UZ, VZ, UT, VT, WT}
    #= none:152 =#
    ∂x_vˢ::VX
    #= none:153 =#
    ∂x_wˢ::WX
    #= none:154 =#
    ∂y_uˢ::UY
    #= none:155 =#
    ∂y_wˢ::WY
    #= none:156 =#
    ∂z_uˢ::UZ
    #= none:157 =#
    ∂z_vˢ::VZ
    #= none:158 =#
    ∂t_uˢ::UT
    #= none:159 =#
    ∂t_vˢ::VT
    #= none:160 =#
    ∂t_wˢ::WT
    #= none:161 =#
    parameters::P
end
#= none:164 =#
adapt_structure(to, sd::StokesDrift) = begin
        #= none:164 =#
        StokesDrift(adapt(to, sd.∂x_vˢ), adapt(to, sd.∂x_wˢ), adapt(to, sd.∂y_uˢ), adapt(to, sd.∂y_wˢ), adapt(to, sd.∂z_uˢ), adapt(to, sd.∂z_vˢ), adapt(to, sd.∂t_uˢ), adapt(to, sd.∂t_vˢ), adapt(to, sd.∂t_wˢ), adapt(to, sd.parameters))
    end
#= none:175 =#
Base.summary(::StokesDrift{Nothing}) = begin
        #= none:175 =#
        "StokesDrift{Nothing}"
    end
#= none:177 =#
function Base.summary(sd::StokesDrift)
    #= none:177 =#
    #= none:178 =#
    p_str = prettysummary(sd.parameters)
    #= none:179 =#
    return "StokesDrift with parameters $(p_str)"
end
#= none:182 =#
function Base.show(io::IO, sd::StokesDrift)
    #= none:182 =#
    #= none:183 =#
    print(io, summary(sd), ':', '\n')
    #= none:184 =#
    print(io, "├── ∂x_vˢ: ", prettysummary(sd.∂x_vˢ, false), '\n')
    #= none:185 =#
    print(io, "├── ∂x_wˢ: ", prettysummary(sd.∂x_wˢ, false), '\n')
    #= none:186 =#
    print(io, "├── ∂y_uˢ: ", prettysummary(sd.∂y_uˢ, false), '\n')
    #= none:187 =#
    print(io, "├── ∂y_wˢ: ", prettysummary(sd.∂y_wˢ, false), '\n')
    #= none:188 =#
    print(io, "├── ∂z_uˢ: ", prettysummary(sd.∂z_uˢ, false), '\n')
    #= none:189 =#
    print(io, "├── ∂z_vˢ: ", prettysummary(sd.∂z_vˢ, false), '\n')
    #= none:190 =#
    print(io, "├── ∂t_uˢ: ", prettysummary(sd.∂t_uˢ, false), '\n')
    #= none:191 =#
    print(io, "├── ∂t_vˢ: ", prettysummary(sd.∂t_vˢ, false), '\n')
    #= none:192 =#
    print(io, "└── ∂t_wˢ: ", prettysummary(sd.∂t_wˢ, false))
end
#= none:195 =#
#= none:195 =# Core.@doc "    StokesDrift(; ∂z_uˢ=zerofunction, ∂y_uˢ=zerofunction, ∂t_uˢ=zerofunction, \n                  ∂z_vˢ=zerofunction, ∂x_vˢ=zerofunction, ∂t_vˢ=zerofunction, \n                  ∂x_wˢ=zerofunction, ∂y_wˢ=zerofunction, ∂t_wˢ=zerofunction, parameters=nothing)\n\nConstruct a set of functions of space and time for a Stokes drift velocity field\ncorresponding to a surface gravity wave field with an envelope that (potentially) varies\nin the horizontal directions.\n\nTo resolve the evolution of the Lagrangian-mean momentum, we require all the components\nof the \"psuedovorticity\",\n\n```math\n𝛁 × 𝐯ˢ = \\hat{\\boldsymbol{x}} (∂_y wˢ - ∂_z vˢ) + \\hat{\\boldsymbol{y}} (∂_z uˢ - ∂_x wˢ) + \\hat{\\boldsymbol{z}} (∂_x vˢ - ∂_y uˢ)\n```\n\nas well as the time-derivatives of ``uˢ``, ``vˢ``, and ``wˢ``.\n\nNote that each function (e.g., `∂z_uˢ`) is generally a function of depth, horizontal coordinates,\nand time.Thus, the correct function signature depends on the grid, since `Flat` horizontal directions\nare omitted.\n\nFor example, on a grid with `topology = (Periodic, Flat, Bounded)` (and `parameters=nothing`),\nthen, e.g., `∂z_uˢ` is callable via `∂z_uˢ(x, z, t)`. When `!isnothing(parameters)`, then\n`∂z_uˢ` is callable via `∂z_uˢ(x, z, t, parameters)`. Similarly, on a grid with\n`topology = (Periodic, Periodic, Bounded)` and `parameters=nothing`, `∂z_uˢ` is called\nvia `∂z_uˢ(x, y, z, t)`.\n\nExample\n=======\n\nA wavepacket moving with the group velocity in the ``x``-direction.\nWe write the Stokes drift as:\n\n```math\nuˢ(x, y, z, t) = A(x - cᵍ \\, t, y) ûˢ(z)\n```\n\nwith ``A(ξ, η) = \\exp{[-(ξ^2 + η^2) / 2δ^2]}``. We also assume ``vˢ = 0``.\nIf ``𝐯ˢ`` represents the solenoidal component of the Stokes drift, then\nin this system from incompressibility requirement we have that\n``∂_z wˢ = - ∂_x uˢ = - (∂_ξ A) ûˢ`` and therefore, under the assumption\nthat ``wˢ`` tends to zero at large depths, we get ``wˢ = - (∂_ξ A / 2k) ûˢ``.\n\n```jldoctest\nusing Oceananigans\nusing Oceananigans.Units\n\ng = 9.81 # gravitational acceleration\n\nϵ = 0.1\nλ = 100meters  # horizontal wavelength\nconst k = 2π / λ  # horizontal wavenumber\nc = sqrt(g / k)  # phase speed\nconst δ = 400kilometers  # wavepacket spread\nconst cᵍ = c / 2  # group speed\nconst Uˢ = ϵ^2 * c\n\n@inline A(ξ, η) = exp(- (ξ^2 + η^2) / 2δ^2)\n\n@inline ∂ξ_A(ξ, η) = - ξ / δ^2 * A(ξ, η)\n@inline ∂η_A(ξ, η) = - η / δ^2 * A(ξ, η)\n@inline ∂η_∂ξ_A(ξ, η) = η * ξ / δ^4 * A(ξ, η)\n@inline ∂²ξ_A(ξ, η) = (ξ^2 / δ^2 - 1) * A(ξ, η) / δ^2\n\n@inline ûˢ(z) = Uˢ * exp(2k * z)\n@inline uˢ(x, y, z, t) = A(x - cᵍ * t, y) * ûˢ(z)\n\n@inline ∂z_uˢ(x, y, z, t) = 2k * A(x - cᵍ * t, y) * ûˢ(z)\n@inline ∂y_uˢ(x, y, z, t) = ∂η_A(x - cᵍ * t, y) * ûˢ(z)\n@inline ∂t_uˢ(x, y, z, t) = - cᵍ * ∂ξ_A(x - cᵍ * t, y) * ûˢ(z)\n@inline ∂x_wˢ(x, y, z, t) = - 1 / 2k * ∂²ξ_A(x - cᵍ * t, y) * ûˢ(z)\n@inline ∂y_wˢ(x, y, z, t) = - 1 / 2k * ∂η_∂ξ_A(x - cᵍ * t, y) * ûˢ(z)\n@inline ∂t_wˢ(x, y, z, t) = + cᵍ / 2k * ∂²ξ_A(x - cᵍ * t, y) * ûˢ(z)\n\nstokes_drift = StokesDrift(; ∂z_uˢ, ∂t_uˢ, ∂y_uˢ, ∂t_wˢ, ∂x_wˢ, ∂y_wˢ)\n\n# output\n\nStokesDrift{Nothing}:\n├── ∂x_vˢ: zerofunction\n├── ∂x_wˢ: ∂x_wˢ\n├── ∂y_uˢ: ∂y_uˢ\n├── ∂y_wˢ: ∂y_wˢ\n├── ∂z_uˢ: ∂z_uˢ\n├── ∂z_vˢ: zerofunction\n├── ∂t_uˢ: ∂t_uˢ\n├── ∂t_vˢ: zerofunction\n└── ∂t_wˢ: ∂t_wˢ\n```\n" function StokesDrift(; ∂x_vˢ = zerofunction, ∂x_wˢ = zerofunction, ∂y_uˢ = zerofunction, ∂y_wˢ = zerofunction, ∂z_uˢ = zerofunction, ∂z_vˢ = zerofunction, ∂t_uˢ = zerofunction, ∂t_vˢ = zerofunction, ∂t_wˢ = zerofunction, parameters = nothing)
        #= none:286 =#
        #= none:297 =#
        return StokesDrift(∂x_vˢ, ∂x_wˢ, ∂y_uˢ, ∂y_wˢ, ∂z_uˢ, ∂z_vˢ, ∂t_uˢ, ∂t_vˢ, ∂t_wˢ, parameters)
    end
#= none:300 =#
const SD = StokesDrift
#= none:301 =#
const SDnoP = StokesDrift{<:Nothing}
#= none:303 =#
#= none:303 =# @inline ∂t_uˢ(i, j, k, grid, sw::SD, time) = begin
            #= none:303 =#
            sw.∂t_uˢ(node(i, j, k, grid, f, c, c)..., time, sw.parameters)
        end
#= none:304 =#
#= none:304 =# @inline ∂t_vˢ(i, j, k, grid, sw::SD, time) = begin
            #= none:304 =#
            sw.∂t_vˢ(node(i, j, k, grid, c, f, c)..., time, sw.parameters)
        end
#= none:305 =#
#= none:305 =# @inline ∂t_wˢ(i, j, k, grid, sw::SD, time) = begin
            #= none:305 =#
            sw.∂t_wˢ(node(i, j, k, grid, c, c, f)..., time, sw.parameters)
        end
#= none:307 =#
#= none:307 =# @inline ∂t_uˢ(i, j, k, grid, sw::SDnoP, time) = begin
            #= none:307 =#
            sw.∂t_uˢ(node(i, j, k, grid, f, c, c)..., time)
        end
#= none:308 =#
#= none:308 =# @inline ∂t_vˢ(i, j, k, grid, sw::SDnoP, time) = begin
            #= none:308 =#
            sw.∂t_vˢ(node(i, j, k, grid, c, f, c)..., time)
        end
#= none:309 =#
#= none:309 =# @inline ∂t_wˢ(i, j, k, grid, sw::SDnoP, time) = begin
            #= none:309 =#
            sw.∂t_wˢ(node(i, j, k, grid, c, c, f)..., time)
        end
#= none:311 =#
#= none:311 =# @inline parameters_tuple(sw::SDnoP) = begin
            #= none:311 =#
            tuple()
        end
#= none:312 =#
#= none:312 =# @inline parameters_tuple(sw::SD) = begin
            #= none:312 =#
            tuple(sw.parameters)
        end
#= none:314 =#
#= none:314 =# @inline function x_curl_Uˢ_cross_U(i, j, k, grid, sw::SD, U, time)
        #= none:314 =#
        #= none:315 =#
        wᶠᶜᶜ = ℑxzᶠᵃᶜ(i, j, k, grid, U.w)
        #= none:316 =#
        vᶠᶜᶜ = ℑxyᶠᶜᵃ(i, j, k, grid, U.v)
        #= none:318 =#
        pt = parameters_tuple(sw)
        #= none:319 =#
        X = node(i, j, k, grid, f, c, c)
        #= none:320 =#
        ∂z_uˢ = sw.∂z_uˢ(X..., time, pt...)
        #= none:321 =#
        ∂x_wˢ = sw.∂x_wˢ(X..., time, pt...)
        #= none:322 =#
        ∂y_uˢ = sw.∂y_uˢ(X..., time, pt...)
        #= none:323 =#
        ∂x_vˢ = sw.∂x_vˢ(X..., time, pt...)
        #= none:325 =#
        return wᶠᶜᶜ * (∂z_uˢ - ∂x_wˢ) - vᶠᶜᶜ * (∂x_vˢ - ∂y_uˢ)
    end
#= none:329 =#
#= none:329 =# @inline function y_curl_Uˢ_cross_U(i, j, k, grid, sw::SD, U, time)
        #= none:329 =#
        #= none:330 =#
        wᶜᶠᶜ = ℑyzᵃᶠᶜ(i, j, k, grid, U.w)
        #= none:331 =#
        uᶜᶠᶜ = ℑxyᶜᶠᵃ(i, j, k, grid, U.u)
        #= none:333 =#
        pt = parameters_tuple(sw)
        #= none:334 =#
        X = node(i, j, k, grid, c, f, c)
        #= none:335 =#
        ∂z_vˢ = sw.∂z_vˢ(X..., time, pt...)
        #= none:336 =#
        ∂y_wˢ = sw.∂y_wˢ(X..., time, pt...)
        #= none:337 =#
        ∂x_vˢ = sw.∂x_vˢ(X..., time, pt...)
        #= none:338 =#
        ∂y_uˢ = sw.∂y_uˢ(X..., time, pt...)
        #= none:340 =#
        return uᶜᶠᶜ * (∂x_vˢ - ∂y_uˢ) - wᶜᶠᶜ * (∂y_wˢ - ∂z_vˢ)
    end
#= none:343 =#
#= none:343 =# @inline function z_curl_Uˢ_cross_U(i, j, k, grid, sw::SD, U, time)
        #= none:343 =#
        #= none:344 =#
        uᶜᶜᶠ = ℑxzᶜᵃᶠ(i, j, k, grid, U.u)
        #= none:345 =#
        vᶜᶜᶠ = ℑyzᵃᶜᶠ(i, j, k, grid, U.v)
        #= none:347 =#
        pt = parameters_tuple(sw)
        #= none:348 =#
        X = node(i, j, k, grid, c, c, f)
        #= none:349 =#
        ∂x_wˢ = sw.∂x_wˢ(X..., time, pt...)
        #= none:350 =#
        ∂z_uˢ = sw.∂z_uˢ(X..., time, pt...)
        #= none:351 =#
        ∂y_wˢ = sw.∂y_wˢ(X..., time, pt...)
        #= none:352 =#
        ∂z_vˢ = sw.∂z_vˢ(X..., time, pt...)
        #= none:354 =#
        return vᶜᶜᶠ * (∂y_wˢ - ∂z_vˢ) - uᶜᶜᶠ * (∂z_uˢ - ∂x_wˢ)
    end
end