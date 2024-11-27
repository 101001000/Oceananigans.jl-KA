
#= none:1 =#
using Oceananigans.Architectures: architecture
#= none:2 =#
using Oceananigans.BuoyancyModels: ∂z_b
#= none:3 =#
using Oceananigans.Operators
#= none:4 =#
using Oceananigans.Grids: inactive_node
#= none:5 =#
using Oceananigans.Operators: ℑzᵃᵃᶜ
#= none:7 =#
struct RiBasedVerticalDiffusivity{TD, FT, R, HR} <: AbstractScalarDiffusivity{TD, VerticalFormulation, 1}
    #= none:8 =#
    ν₀::FT
    #= none:9 =#
    κ₀::FT
    #= none:10 =#
    κᶜᵃ::FT
    #= none:11 =#
    Cᵉⁿ::FT
    #= none:12 =#
    Cᵃᵛ::FT
    #= none:13 =#
    Ri₀::FT
    #= none:14 =#
    Riᵟ::FT
    #= none:15 =#
    Ri_dependent_tapering::R
    #= none:16 =#
    horizontal_Ri_filter::HR
    #= none:17 =#
    minimum_entrainment_buoyancy_gradient::FT
    #= none:18 =#
    maximum_diffusivity::FT
    #= none:19 =#
    maximum_viscosity::FT
end
#= none:22 =#
function RiBasedVerticalDiffusivity{TD}(ν₀::FT, κ₀::FT, κᶜᵃ::FT, Cᵉⁿ::FT, Cᵃᵛ::FT, Ri₀::FT, Riᵟ::FT, Ri_dependent_tapering::R, horizontal_Ri_filter::HR, minimum_entrainment_buoyancy_gradient::FT, maximum_diffusivity::FT, maximum_viscosity::FT) where {TD, FT, R, HR}
    #= none:22 =#
    #= none:36 =#
    return RiBasedVerticalDiffusivity{TD, FT, R, HR}(ν₀, κ₀, κᶜᵃ, Cᵉⁿ, Cᵃᵛ, Ri₀, Riᵟ, Ri_dependent_tapering, horizontal_Ri_filter, minimum_entrainment_buoyancy_gradient, maximum_diffusivity, maximum_viscosity)
end
#= none:45 =#
struct PiecewiseLinearRiDependentTapering
    #= none:45 =#
end
#= none:46 =#
struct ExponentialRiDependentTapering
    #= none:46 =#
end
#= none:47 =#
struct HyperbolicTangentRiDependentTapering
    #= none:47 =#
end
#= none:49 =#
Base.summary(::HyperbolicTangentRiDependentTapering) = begin
        #= none:49 =#
        "HyperbolicTangentRiDependentTapering"
    end
#= none:50 =#
Base.summary(::ExponentialRiDependentTapering) = begin
        #= none:50 =#
        "ExponentialRiDependentTapering"
    end
#= none:51 =#
Base.summary(::PiecewiseLinearRiDependentTapering) = begin
        #= none:51 =#
        "PiecewiseLinearRiDependentTapering"
    end
#= none:54 =#
struct FivePointHorizontalFilter
    #= none:54 =#
end
#= none:55 =#
#= none:55 =# @inline filter_horizontally(i, j, k, grid, ::Nothing, ϕ) = begin
            #= none:55 =#
            #= none:55 =# @inbounds ϕ[i, j, k]
        end
#= none:56 =#
#= none:56 =# @inline filter_horizontally(i, j, k, grid, ::FivePointHorizontalFilter, ϕ) = begin
            #= none:56 =#
            ℑxyᶜᶜᵃ(i, j, k, grid, ℑxyᶠᶠᵃ, ϕ)
        end
#= none:58 =#
#= none:58 =# Core.@doc "    RiBasedVerticalDiffusivity([time_discretization = VerticallyImplicitTimeDiscretization(),\n                               FT = Float64;]\n                               Ri_dependent_tapering = HyperbolicTangentRiDependentTapering(),\n                               horizontal_Ri_filter = nothing,\n                               minimum_entrainment_buoyancy_gradient = 1e-10,\n                               maximum_diffusivity = Inf,\n                               maximum_viscosity = Inf,\n                               ν₀  = 0.7,\n                               κ₀  = 0.5,\n                               κᶜᵃ = 1.7,\n                               Cᵉⁿ = 0.1,\n                               Cᵃᵛ = 0.6,\n                               Ri₀ = 0.1,\n                               Riᵟ = 0.4,\n                               warning = true)\n\nReturn a closure that estimates the vertical viscosity and diffusivity\nfrom \"convective adjustment\" coefficients `ν₀` and `κ₀` multiplied by\na decreasing function of the Richardson number, ``Ri``. \n\nArguments\n=========\n\n* `time_discretization`: Either `ExplicitTimeDiscretization()` or `VerticallyImplicitTimeDiscretization()`, \n                         which integrates the terms involving only ``z``-derivatives in the\n                         viscous and diffusive fluxes with an implicit time discretization.\n                         Default `VerticallyImplicitTimeDiscretization()`.\n\n* `FT`: Float type; default `Float64`.\n\nKeyword arguments\n=================\n\n* `Ri_dependent_tapering`: The ``Ri``-dependent tapering.\n  Options are: `PiecewiseLinearRiDependentTapering()`,\n  `HyperbolicTangentRiDependentTapering()` (default), and\n  `ExponentialRiDependentTapering()`.\n\n* `ν₀`: Non-convective viscosity (units of kinematic viscosity, typically m² s⁻¹).\n\n* `κ₀`: Non-convective diffusivity for tracers (units of diffusivity, typically m² s⁻¹).\n\n* `κᶜᵃ`: Convective adjustment diffusivity for tracers (units of diffusivity, typically m² s⁻¹).\n\n* `Cᵉⁿ`: Entrainment coefficient for tracers (non-dimensional).\n         Set `Cᵉⁿ = 0` to turn off the penetrative entrainment diffusivity.\n\n* `Cᵃᵛ`: Time-averaging coefficient for viscosity and diffusivity (non-dimensional).\n\n* `Ri₀`: ``Ri`` threshold for decreasing viscosity and diffusivity (non-dimensional).\n\n* `Riᵟ`: ``Ri``-width over which viscosity and diffusivity decreases to 0 (non-dimensional).\n\n* `minimum_entrainment_buoyancy_gradient`: Minimum buoyancy gradient for application of the entrainment\n                                           diffusvity. If the entrainment buoyancy gradient is less than the\n                                           minimum value, the entrainment diffusivity is 0. Units of \n                                           buoyancy gradient (typically s⁻²).\n\n* `maximum_diffusivity`: A limiting maximum tracer diffusivity (units of diffusivity, typically m² s⁻¹).\n\n* `maximum_viscosity`: A limiting maximum viscosity (units of kinematic viscosity, typically m² s⁻¹).\n\n* `horizontal_Ri_filter`: Horizontal filter to apply to Ri, which can help alleviate noise for\n                          some simulations. The default is `nothing`, or no filtering. The other\n                          option is `horizontal_Ri_filter = FivePointHorizontalFilter()`.\n" function RiBasedVerticalDiffusivity(time_discretization = VerticallyImplicitTimeDiscretization(), FT = Float64; Ri_dependent_tapering = HyperbolicTangentRiDependentTapering(), horizontal_Ri_filter = nothing, minimum_entrainment_buoyancy_gradient = 1.0e-10, maximum_diffusivity = Inf, maximum_viscosity = Inf, ν₀ = 0.7, κ₀ = 0.5, κᶜᵃ = 1.7, Cᵉⁿ = 0.1, Cᵃᵛ = 0.6, Ri₀ = 0.1, Riᵟ = 0.4, warning = true)
        #= none:125 =#
        #= none:140 =#
        if warning
            #= none:141 =#
            #= none:141 =# @warn "RiBasedVerticalDiffusivity is an experimental turbulence closure that \n" * "is unvalidated and whose default parameters are not calibrated for \n" * "realistic ocean conditions or for use in a three-dimensional \n" * "simulation. Use with caution and report bugs and problems with physics \n" * "to https://github.com/CliMA/Oceananigans.jl/issues."
        end
        #= none:148 =#
        TD = typeof(time_discretization)
        #= none:150 =#
        return RiBasedVerticalDiffusivity{TD}(convert(FT, ν₀), convert(FT, κ₀), convert(FT, κᶜᵃ), convert(FT, Cᵉⁿ), convert(FT, Cᵃᵛ), convert(FT, Ri₀), convert(FT, Riᵟ), Ri_dependent_tapering, horizontal_Ri_filter, convert(FT, minimum_entrainment_buoyancy_gradient), convert(FT, maximum_diffusivity), convert(FT, maximum_viscosity))
    end
#= none:164 =#
RiBasedVerticalDiffusivity(FT::DataType; kw...) = begin
        #= none:164 =#
        RiBasedVerticalDiffusivity(VerticallyImplicitTimeDiscretization(), FT; kw...)
    end
#= none:171 =#
const RBVD = RiBasedVerticalDiffusivity
#= none:172 =#
const RBVDArray = AbstractArray{<:RBVD}
#= none:173 =#
const FlavorOfRBVD = Union{RBVD, RBVDArray}
#= none:174 =#
const c = Center()
#= none:175 =#
const f = Face()
#= none:177 =#
#= none:177 =# @inline viscosity_location(::FlavorOfRBVD) = begin
            #= none:177 =#
            (c, c, f)
        end
#= none:178 =#
#= none:178 =# @inline diffusivity_location(::FlavorOfRBVD) = begin
            #= none:178 =#
            (c, c, f)
        end
#= none:180 =#
#= none:180 =# @inline viscosity(::FlavorOfRBVD, diffusivities) = begin
            #= none:180 =#
            diffusivities.κu
        end
#= none:181 =#
#= none:181 =# @inline diffusivity(::FlavorOfRBVD, diffusivities, id) = begin
            #= none:181 =#
            diffusivities.κc
        end
#= none:183 =#
with_tracers(tracers, closure::FlavorOfRBVD) = begin
        #= none:183 =#
        closure
    end
#= none:186 =#
function DiffusivityFields(grid, tracer_names, bcs, closure::FlavorOfRBVD)
    #= none:186 =#
    #= none:187 =#
    κc = Field((Center, Center, Face), grid)
    #= none:188 =#
    κu = Field((Center, Center, Face), grid)
    #= none:189 =#
    Ri = Field((Center, Center, Face), grid)
    #= none:190 =#
    return (; κc, κu, Ri)
end
#= none:193 =#
function compute_diffusivities!(diffusivities, closure::FlavorOfRBVD, model; parameters = :xyz)
    #= none:193 =#
    #= none:194 =#
    arch = model.architecture
    #= none:195 =#
    grid = model.grid
    #= none:196 =#
    clock = model.clock
    #= none:197 =#
    tracers = model.tracers
    #= none:198 =#
    buoyancy = model.buoyancy
    #= none:199 =#
    velocities = model.velocities
    #= none:200 =#
    top_tracer_bcs = NamedTuple((c => (tracers[c]).boundary_conditions.top for c = propertynames(tracers)))
    #= none:202 =#
    launch!(arch, grid, parameters, compute_ri_number!, diffusivities, grid, closure, velocities, tracers, buoyancy, top_tracer_bcs, clock)
    #= none:215 =#
    fill_halo_regions!(diffusivities.Ri; only_local_halos = true)
    #= none:217 =#
    launch!(arch, grid, parameters, compute_ri_based_diffusivities!, diffusivities, grid, closure, velocities, tracers, buoyancy, top_tracer_bcs, clock)
    #= none:228 =#
    return nothing
end
#= none:235 =#
const Linear = PiecewiseLinearRiDependentTapering
#= none:236 =#
const Exp = ExponentialRiDependentTapering
#= none:237 =#
const Tanh = HyperbolicTangentRiDependentTapering
#= none:239 =#
#= none:239 =# @inline (taper(::Linear, x::T, x₀, δ) where T) = begin
            #= none:239 =#
            one(T) - min(one(T), max(zero(T), (x - x₀) / δ))
        end
#= none:240 =#
#= none:240 =# @inline (taper(::Exp, x::T, x₀, δ) where T) = begin
            #= none:240 =#
            exp(-(max(zero(T), (x - x₀) / δ)))
        end
#= none:241 =#
#= none:241 =# @inline (taper(::Tanh, x::T, x₀, δ) where T) = begin
            #= none:241 =#
            (one(T) - tanh((x - x₀) / δ)) / 2
        end
#= none:243 =#
#= none:243 =# @inline ϕ²(i, j, k, grid, ϕ, args...) = begin
            #= none:243 =#
            ϕ(i, j, k, grid, args...) ^ 2
        end
#= none:245 =#
#= none:245 =# @inline function shear_squaredᶜᶜᶠ(i, j, k, grid, velocities)
        #= none:245 =#
        #= none:246 =#
        ∂z_u² = ℑxᶜᵃᵃ(i, j, k, grid, ϕ², ∂zᶠᶜᶠ, velocities.u)
        #= none:247 =#
        ∂z_v² = ℑyᵃᶜᵃ(i, j, k, grid, ϕ², ∂zᶜᶠᶠ, velocities.v)
        #= none:248 =#
        return ∂z_u² + ∂z_v²
    end
#= none:251 =#
#= none:251 =# @inline function Riᶜᶜᶠ(i, j, k, grid, velocities, buoyancy, tracers)
        #= none:251 =#
        #= none:252 =#
        S² = shear_squaredᶜᶜᶠ(i, j, k, grid, velocities)
        #= none:253 =#
        N² = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:254 =#
        Ri = N² / S²
        #= none:257 =#
        return ifelse(N² <= 0, zero(grid), Ri)
    end
#= none:260 =#
const c = Center()
#= none:261 =#
const f = Face()
#= none:263 =#
#= none:263 =# @kernel function compute_ri_number!(diffusivities, grid, closure::FlavorOfRBVD, velocities, tracers, buoyancy, tracer_bcs, clock)
        #= none:263 =#
        #= none:265 =#
        (i, j, k) = #= none:265 =# @index(Global, NTuple)
        #= none:266 =#
        #= none:266 =# @inbounds diffusivities.Ri[i, j, k] = Riᶜᶜᶠ(i, j, k, grid, velocities, buoyancy, tracers)
    end
#= none:269 =#
#= none:269 =# @kernel function compute_ri_based_diffusivities!(diffusivities, grid, closure::FlavorOfRBVD, velocities, tracers, buoyancy, tracer_bcs, clock)
        #= none:269 =#
        #= none:271 =#
        (i, j, k) = #= none:271 =# @index(Global, NTuple)
        #= none:272 =#
        _compute_ri_based_diffusivities!(i, j, k, diffusivities, grid, closure, velocities, tracers, buoyancy, tracer_bcs, clock)
    end
#= none:277 =#
#= none:277 =# @inline function _compute_ri_based_diffusivities!(i, j, k, diffusivities, grid, closure, velocities, tracers, buoyancy, tracer_bcs, clock)
        #= none:277 =#
        #= none:281 =#
        closure_ij = getclosure(i, j, closure)
        #= none:283 =#
        ν₀ = closure_ij.ν₀
        #= none:284 =#
        κ₀ = closure_ij.κ₀
        #= none:285 =#
        κᶜᵃ = closure_ij.κᶜᵃ
        #= none:286 =#
        Cᵉⁿ = closure_ij.Cᵉⁿ
        #= none:287 =#
        Cᵃᵛ = closure_ij.Cᵃᵛ
        #= none:288 =#
        Ri₀ = closure_ij.Ri₀
        #= none:289 =#
        Riᵟ = closure_ij.Riᵟ
        #= none:290 =#
        tapering = closure_ij.Ri_dependent_tapering
        #= none:291 =#
        Ri_filter = closure_ij.horizontal_Ri_filter
        #= none:292 =#
        N²ᵉⁿ = closure_ij.minimum_entrainment_buoyancy_gradient
        #= none:293 =#
        Jᵇ = top_buoyancy_flux(i, j, grid, buoyancy, tracer_bcs, clock, merge(velocities, tracers))
        #= none:296 =#
        N² = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:297 =#
        N²_above = ∂z_b(i, j, k + 1, grid, buoyancy, tracers)
        #= none:301 =#
        convecting = N² < 0
        #= none:302 =#
        entraining = ((N² > N²ᵉⁿ) & (N²_above < 0)) & (Jᵇ > 0)
        #= none:305 =#
        κᶜᵃ = ifelse(convecting, κᶜᵃ, zero(grid))
        #= none:308 =#
        κᵉⁿ = ifelse(entraining, (Cᵉⁿ * Jᵇ) / N², zero(grid))
        #= none:311 =#
        Ri = filter_horizontally(i, j, k, grid, Ri_filter, diffusivities.Ri)
        #= none:314 =#
        τ = taper(tapering, Ri, Ri₀, Riᵟ)
        #= none:315 =#
        κc★ = κ₀ * τ
        #= none:316 =#
        κu★ = ν₀ * τ
        #= none:319 =#
        κc = diffusivities.κc
        #= none:320 =#
        κu = diffusivities.κu
        #= none:323 =#
        κc⁺ = κᶜᵃ + κᵉⁿ + κc★
        #= none:324 =#
        κu⁺ = κu★
        #= none:327 =#
        κc⁺ = min(κc⁺, closure_ij.maximum_diffusivity)
        #= none:328 =#
        κu⁺ = min(κu⁺, closure_ij.maximum_viscosity)
        #= none:331 =#
        on_periphery = peripheral_node(i, j, k, grid, c, c, f)
        #= none:332 =#
        within_inactive = inactive_node(i, j, k, grid, c, c, f)
        #= none:333 =#
        κc⁺ = ifelse(on_periphery, zero(grid), ifelse(within_inactive, NaN, κc⁺))
        #= none:334 =#
        κu⁺ = ifelse(on_periphery, zero(grid), ifelse(within_inactive, NaN, κu⁺))
        #= none:337 =#
        #= none:337 =# @inbounds κc[i, j, k] = (Cᵃᵛ * κc[i, j, k] + κc⁺) / (1 + Cᵃᵛ)
        #= none:338 =#
        #= none:338 =# @inbounds κu[i, j, k] = (Cᵃᵛ * κu[i, j, k] + κu⁺) / (1 + Cᵃᵛ)
        #= none:340 =#
        return nothing
    end
#= none:347 =#
(Base.summary(closure::RiBasedVerticalDiffusivity{TD}) where TD) = begin
        #= none:347 =#
        string("RiBasedVerticalDiffusivity{$(TD)}")
    end
#= none:349 =#
function Base.show(io::IO, closure::RiBasedVerticalDiffusivity)
    #= none:349 =#
    #= none:350 =#
    print(io, summary(closure), '\n')
    #= none:351 =#
    print(io, "├── Ri_dependent_tapering: ", prettysummary(closure.Ri_dependent_tapering), '\n')
    #= none:352 =#
    print(io, "├── κ₀: ", prettysummary(closure.κ₀), '\n')
    #= none:353 =#
    print(io, "├── ν₀: ", prettysummary(closure.ν₀), '\n')
    #= none:354 =#
    print(io, "├── κᶜᵃ: ", prettysummary(closure.κᶜᵃ), '\n')
    #= none:355 =#
    print(io, "├── Cᵉⁿ: ", prettysummary(closure.Cᵉⁿ), '\n')
    #= none:356 =#
    print(io, "├── Cᵃᵛ: ", prettysummary(closure.Cᵃᵛ), '\n')
    #= none:357 =#
    print(io, "├── Ri₀: ", prettysummary(closure.Ri₀), '\n')
    #= none:358 =#
    print(io, "├── Riᵟ: ", prettysummary(closure.Riᵟ), '\n')
    #= none:359 =#
    print(io, "├── maximum_diffusivity: ", prettysummary(closure.maximum_diffusivity), '\n')
    #= none:360 =#
    print(io, "└── maximum_viscosity: ", prettysummary(closure.maximum_viscosity))
end