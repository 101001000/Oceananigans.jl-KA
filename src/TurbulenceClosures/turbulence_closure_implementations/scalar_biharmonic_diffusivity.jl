
#= none:1 =#
import Oceananigans.Grids: required_halo_size_x, required_halo_size_y, required_halo_size_z
#= none:2 =#
using Oceananigans.Utils: prettysummary
#= none:4 =#
#= none:4 =# Core.@doc "    struct ScalarBiharmonicDiffusivity{F, N, K} <: AbstractScalarBiharmonicDiffusivity{F}\n\nHolds viscosity and diffusivities for models with prescribed isotropic diffusivities.\n" struct ScalarBiharmonicDiffusivity{F, N, V, K} <: AbstractScalarBiharmonicDiffusivity{F, N}
        #= none:10 =#
        ν::V
        #= none:11 =#
        κ::K
        #= none:12 =#
        (ScalarBiharmonicDiffusivity{F, N}(ν::V, κ::K) where {F, V, K, N}) = begin
                #= none:12 =#
                new{F, N, V, K}(ν, κ)
            end
    end
#= none:16 =#
ScalarBiharmonicDiffusivity(FT::DataType; kwargs...) = begin
        #= none:16 =#
        ScalarBiharmonicDiffusivity(ThreeDimensionalFormulation(), FT; kwargs...)
    end
#= none:17 =#
VerticalScalarBiharmonicDiffusivity(FT::DataType = Float64; kwargs...) = begin
        #= none:17 =#
        ScalarBiharmonicDiffusivity(VerticalFormulation(), FT; kwargs...)
    end
#= none:18 =#
HorizontalScalarBiharmonicDiffusivity(FT::DataType = Float64; kwargs...) = begin
        #= none:18 =#
        ScalarBiharmonicDiffusivity(HorizontalFormulation(), FT; kwargs...)
    end
#= none:19 =#
HorizontalDivergenceScalarBiharmonicDiffusivity(FT::DataType = Float64; kwargs...) = begin
        #= none:19 =#
        ScalarBiharmonicDiffusivity(HorizontalDivergenceFormulation(), FT; kwargs...)
    end
#= none:21 =#
#= none:21 =# Core.@doc "    ScalarBiharmonicDiffusivity(formulation = ThreeDimensionalFormulation(), FT = Float64;\n                                ν = 0,\n                                κ = 0,\n                                discrete_form = false,\n                                loc = (nothing, nothing, nothing),\n                                parameters = nothing)\n\nReturn a scalar biharmonic diffusivity turbulence closure with viscosity coefficient `ν` and tracer\ndiffusivities `κ` for each tracer field in `tracers`. If a single `κ` is provided, it is applied to\nall tracers. Otherwise `κ` must be a `NamedTuple` with values for every tracer individually.\n\nArguments\n=========\n\n* `formulation`:\n  - `HorizontalFormulation()` for diffusivity applied in the horizontal direction(s)\n  - `VerticalFormulation()` for diffusivity applied in the vertical direction,\n  - `ThreeDimensionalFormulation()` (default) for diffusivity applied isotropically to all directions\n\n* `FT`: the float datatype (default: `Float64`)\n\nKeyword arguments\n=================\n\n* `ν`: Viscosity. `Number`, `AbstractArray`, `Field`, or `Function`.\n\n* `κ`: Diffusivity. `Number`, `AbstractArray`, `Field`, `Function`, or\n       `NamedTuple` of diffusivities with entries for each tracer.\n\n* `discrete_form`: `Boolean`; default: `false`.\n\n* `required_halo_size = 2`: the required halo size for the closure. This value should be an integer.\n  change only if using a function for `ν` or `κ` that requires a halo size larger than 1 to compute.\n\nWhen prescribing the viscosities or diffusivities as functions, depending on the\nvalue of keyword argument `discrete_form`, the constructor expects:\n\n* `discrete_form = false` (default): functions of the grid's native coordinates\n  and time, e.g., `(x, y, z, t)` for a `RectilinearGrid` or `(λ, φ, z, t)` for\n  a `LatitudeLongitudeGrid`.\n\n* `discrete_form = true`:\n  - with `loc = (nothing, nothing, nothing)` (default):\n    functions of `(i, j, k, grid, ℓx, ℓy, ℓz)` with `ℓx`, `ℓy`,\n    and `ℓz` either `Face()` or `Center()`.\n  - with `loc = (ℓx, ℓy, ℓz)` with `ℓx`, `ℓy`, and `ℓz` either\n    `Face()` or `Center()`: functions of `(i, j, k, grid)`.\n\n* `parameters`: `NamedTuple` with parameters used by the functions\n  that compute viscosity and/or diffusivity; default: `nothing`.\n\nFor examples see [`ScalarDiffusivity`](@ref).\n" function ScalarBiharmonicDiffusivity(formulation = ThreeDimensionalFormulation(), FT = Float64; ν = 0, κ = 0, discrete_form = false, loc = (nothing, nothing, nothing), parameters = nothing, required_halo_size::Int = 2)
        #= none:75 =#
        #= none:83 =#
        ν = convert_diffusivity(FT, ν; discrete_form, loc, parameters)
        #= none:84 =#
        κ = convert_diffusivity(FT, κ; discrete_form, loc, parameters)
        #= none:89 =#
        if ν isa Number && κ isa Number
            #= none:90 =#
            return ScalarBiharmonicDiffusivity{typeof(formulation), 2}(ν, κ)
        end
        #= none:93 =#
        return ScalarBiharmonicDiffusivity{typeof(formulation), required_halo_size}(ν, κ)
    end
#= none:96 =#
function with_tracers(tracers, closure::ScalarBiharmonicDiffusivity{F, N, V, K}) where {F, N, V, K}
    #= none:96 =#
    #= none:97 =#
    κ = tracer_diffusivities(tracers, closure.κ)
    #= none:98 =#
    return ScalarBiharmonicDiffusivity{F, N}(closure.ν, κ)
end
#= none:101 =#
#= none:101 =# @inline viscosity(closure::ScalarBiharmonicDiffusivity, K) = begin
            #= none:101 =#
            closure.ν
        end
#= none:102 =#
#= none:102 =# @inline (diffusivity(closure::ScalarBiharmonicDiffusivity, K, ::Val{id}) where id) = begin
            #= none:102 =#
            closure.κ[id]
        end
#= none:104 =#
compute_diffusivities!(diffusivities, closure::ScalarBiharmonicDiffusivity, args...) = begin
        #= none:104 =#
        nothing
    end
#= none:106 =#
function Base.summary(closure::ScalarBiharmonicDiffusivity)
    #= none:106 =#
    #= none:107 =#
    F = summary(formulation(closure))
    #= none:109 =#
    if closure.κ == NamedTuple()
        #= none:110 =#
        summary_str = string("ScalarBiharmonicDiffusivity{$(F)}(ν=", prettysummary(closure.ν), ")")
    else
        #= none:112 =#
        summary_str = string("ScalarBiharmonicDiffusivity{$(F)}(ν=", prettysummary(closure.ν), ", κ=", prettysummary(closure.κ), ")")
    end
    #= none:115 =#
    return summary_str
end
#= none:118 =#
Base.show(io::IO, closure::ScalarBiharmonicDiffusivity) = begin
        #= none:118 =#
        print(io, summary(closure))
    end
#= none:120 =#
function Adapt.adapt_structure(to, closure::ScalarBiharmonicDiffusivity{F, <:Any, <:Any, N}) where {F, N}
    #= none:120 =#
    #= none:121 =#
    ν = Adapt.adapt(to, closure.ν)
    #= none:122 =#
    κ = Adapt.adapt(to, closure.κ)
    #= none:123 =#
    return ScalarBiharmonicDiffusivity{F, N}(ν, κ)
end
#= none:126 =#
function on_architecture(to, closure::ScalarBiharmonicDiffusivity{F, <:Any, <:Any, N}) where {F, N}
    #= none:126 =#
    #= none:127 =#
    ν = on_architecture(to, closure.ν)
    #= none:128 =#
    κ = on_architecture(to, closure.κ)
    #= none:129 =#
    return ScalarBiharmonicDiffusivity{F, N}(ν, κ)
end