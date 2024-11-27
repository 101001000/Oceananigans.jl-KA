
#= none:1 =#
using Oceananigans.Utils: prettysummary
#= none:3 =#
import Adapt
#= none:4 =#
import Oceananigans.Grids: required_halo_size_x, required_halo_size_y, required_halo_size_z
#= none:6 =#
struct ScalarDiffusivity{TD, F, N, V, K} <: AbstractScalarDiffusivity{TD, F, N}
    #= none:7 =#
    ν::V
    #= none:8 =#
    κ::K
    #= none:9 =#
    (ScalarDiffusivity{TD, F, N}(ν::V, κ::K) where {TD, F, N, V, K}) = begin
            #= none:9 =#
            new{TD, F, N, V, K}(ν, κ)
        end
end
#= none:12 =#
#= none:12 =# Core.@doc "    ScalarDiffusivity(time_discretization = ExplicitTimeDiscretization(),\n                      formulation = ThreeDimensionalFormulation(), FT = Float64;\n                      ν = 0,\n                      κ = 0,\n                      discrete_form = false,\n                      loc = (nothing, nothing, nothing),\n                      parameters = nothing)\n\nReturn `ScalarDiffusivity` turbulence closure with viscosity `ν` and tracer diffusivities `κ`\nfor each tracer field in `tracers`. If a single `κ` is provided, it is applied to all tracers.\nOtherwise `κ` must be a `NamedTuple` with values for every tracer individually.\n\nArguments\n=========\n\n* `time_discretization`: either `ExplicitTimeDiscretization()` (default)\n  or `VerticallyImplicitTimeDiscretization()`.\n\n* `formulation`:\n  - `HorizontalFormulation()` for diffusivity applied in the horizontal direction(s)\n  - `VerticalFormulation()` for diffusivity applied in the vertical direction,\n  - `ThreeDimensionalFormulation()` (default) for diffusivity applied isotropically to all directions\n\n* `FT`: the float datatype (default: `Float64`)\n\nKeyword arguments\n=================\n\n* `ν`: Viscosity. `Number`, `AbstractArray`, `Field`, or `Function`.\n\n* `κ`: Diffusivity. `Number`, `AbstractArray`, `Field`, `Function`, or\n       `NamedTuple` of diffusivities with entries for each tracer.\n\n* `discrete_form`: `Boolean`; default: `false`.\n\nWhen prescribing the viscosities or diffusivities as functions, depending on the\nvalue of keyword argument `discrete_form`, the constructor expects:\n\n* `discrete_form = false` (default): functions of the grid's native coordinates\n  and time, e.g., `(x, y, z, t)` for a `RectilinearGrid` or `(λ, φ, z, t)` for\n  a `LatitudeLongitudeGrid`.\n\n* `discrete_form = true`:\n  - with `loc = (nothing, nothing, nothing)` and `parameters = nothing` (default):\n    functions of `(i, j, k, grid, ℓx, ℓy, ℓz, clock, fields)` with `ℓx`, `ℓy`,\n    and `ℓz` either `Face()` or `Center()`.\n  - with `loc = (ℓx, ℓy, ℓz)` with `ℓx`, `ℓy`, and `ℓz` either\n    `Face()` or `Center()` and `parameters = nothing`: functions of `(i, j, k, grid, clock, fields)`.\n  - with `loc = (nothing, nothing, nothing)` and specified `parameters`:\n    functions of `(i, j, k, grid, ℓx, ℓy, ℓz, clock, fields, parameters)`.\n  - with `loc = (ℓx, ℓy, ℓz)` and specified `parameters`:\n    functions of `(i, j, k, grid, clock, fields, parameters)`.\n\n* `required_halo_size = 1`: the required halo size for the closure. This value should be an integer.\n  change only if using a function for `ν` or `κ` that requires a halo size larger than 1 to compute.\n\n* `parameters`: `NamedTuple` with parameters used by the functions\n  that compute viscosity and/or diffusivity; default: `nothing`.\n\nExamples\n========\n\n```jldoctest ScalarDiffusivity\njulia> using Oceananigans\n\njulia> ScalarDiffusivity(ν=1000, κ=2000)\nScalarDiffusivity{ExplicitTimeDiscretization}(ν=1000.0, κ=2000.0)\n```\n\n```jldoctest ScalarDiffusivity\njulia> const depth_scale = 100;\n\njulia> @inline ν(x, y, z) = 1000 * exp(z / depth_scale)\nν (generic function with 1 method)\n\njulia> ScalarDiffusivity(ν=ν)\nScalarDiffusivity{ExplicitTimeDiscretization}(ν=ν (generic function with 1 method), κ=0.0)\n```\n\n```jldoctest ScalarDiffusivity\njulia> using Oceananigans.Grids: znode\n\njulia> @inline function κ(i, j, k, grid, ℓx, ℓy, ℓz, clock, fields)\n           z = znode(i, j, k, grid, ℓx, ℓy, ℓz)\n           return 2000 * exp(z / depth_scale)\n       end\nκ (generic function with 1 method)\n\njulia> ScalarDiffusivity(κ=κ, discrete_form=true)\nScalarDiffusivity{ExplicitTimeDiscretization}(ν=0.0, κ=Oceananigans.TurbulenceClosures.DiscreteDiffusionFunction{Nothing, Nothing, Nothing, Nothing, typeof(κ)})\n```\n\n```jldoctest ScalarDiffusivity\njulia> @inline function another_κ(i, j, k, grid, clock, fields, p)\n           z = znode(i, j, k, grid, Center(), Center(), Face())\n           return 2000 * exp(z / p.depth_scale)\n       end\nanother_κ (generic function with 1 method)\n\njulia> ScalarDiffusivity(κ=another_κ, discrete_form=true, loc=(Center, Center, Face), parameters=(; depth_scale = 120.0))\nScalarDiffusivity{ExplicitTimeDiscretization}(ν=0.0, κ=Oceananigans.TurbulenceClosures.DiscreteDiffusionFunction{Center, Center, Face, @NamedTuple{depth_scale::Float64}, typeof(another_κ)})\n```\n" function ScalarDiffusivity(time_discretization = ExplicitTimeDiscretization(), formulation = ThreeDimensionalFormulation(), FT = Float64; ν = 0, κ = 0, discrete_form = false, loc = (nothing, nothing, nothing), parameters = nothing, required_halo_size::Int = 1)
        #= none:116 =#
        #= none:125 =#
        if formulation == HorizontalFormulation() && time_discretization == VerticallyImplicitTimeDiscretization()
            #= none:126 =#
            throw(ArgumentError("VerticallyImplicitTimeDiscretization is only supported for `VerticalFormulation` or `ThreeDimensionalFormulation`"))
        end
        #= none:130 =#
        κ = convert_diffusivity(FT, κ; discrete_form, loc, parameters)
        #= none:131 =#
        ν = convert_diffusivity(FT, ν; discrete_form, loc, parameters)
        #= none:136 =#
        if ν isa Number && κ isa Number
            #= none:137 =#
            return ScalarDiffusivity{typeof(time_discretization), typeof(formulation), 1}(ν, κ)
        end
        #= none:140 =#
        return ScalarDiffusivity{typeof(time_discretization), typeof(formulation), required_halo_size}(ν, κ)
    end
#= none:144 =#
#= none:144 =# @inline ScalarDiffusivity(formulation::AbstractDiffusivityFormulation, FT = Float64; kw...) = begin
            #= none:144 =#
            ScalarDiffusivity(ExplicitTimeDiscretization(), formulation, FT; kw...)
        end
#= none:147 =#
const VerticalScalarDiffusivity{TD} = (ScalarDiffusivity{TD, VerticalFormulation} where TD)
#= none:148 =#
const HorizontalScalarDiffusivity{TD} = (ScalarDiffusivity{TD, HorizontalFormulation} where TD)
#= none:149 =#
const HorizontalDivergenceScalarDiffusivity{TD} = (ScalarDiffusivity{TD, HorizontalDivergenceFormulation} where TD)
#= none:151 =#
#= none:151 =# Core.@doc "    VerticalScalarDiffusivity([time_discretization=ExplicitTimeDiscretization(),\n                              FT::DataType=Float64;]\n                              kwargs...)\n\nShorthand for a `ScalarDiffusivity` with `VerticalFormulation()`. See [`ScalarDiffusivity`](@ref).\n" #= none:158 =# @inline(VerticalScalarDiffusivity(time_discretization = ExplicitTimeDiscretization(), FT::DataType = Float64; kwargs...) = begin
                #= none:158 =#
                ScalarDiffusivity(time_discretization, VerticalFormulation(), FT; kwargs...)
            end)
#= none:161 =#
#= none:161 =# Core.@doc "    HorizontalScalarDiffusivity([time_discretization=ExplicitTimeDiscretization(),\n                                FT::DataType=Float64;]\n                                kwargs...)\n\nShorthand for a `ScalarDiffusivity` with `HorizontalFormulation()`. See [`ScalarDiffusivity`](@ref).\n" #= none:168 =# @inline(HorizontalScalarDiffusivity(time_discretization = ExplicitTimeDiscretization(), FT::DataType = Float64; kwargs...) = begin
                #= none:168 =#
                ScalarDiffusivity(time_discretization, HorizontalFormulation(), FT; kwargs...)
            end)
#= none:171 =#
#= none:171 =# Core.@doc "    HorizontalDivergenceScalarDiffusivity([time_discretization=ExplicitTimeDiscretization(),\n                                          FT::DataType=Float64;]\n                                          kwargs...)\n\nShorthand for a `ScalarDiffusivity` with `HorizontalDivergenceFormulation()`. See [`ScalarDiffusivity`](@ref).\n" #= none:178 =# @inline(HorizontalDivergenceScalarDiffusivity(time_discretization = ExplicitTimeDiscretization(), FT::DataType = Float64; kwargs...) = begin
                #= none:178 =#
                ScalarDiffusivity(time_discretization, HorizontalDivergenceFormulation(), FT; kwargs...)
            end)
#= none:182 =#
ScalarDiffusivity(FT::DataType; kwargs...) = begin
        #= none:182 =#
        ScalarDiffusivity(ExplicitTimeDiscretization(), ThreeDimensionalFormulation(), FT; kwargs...)
    end
#= none:183 =#
#= none:183 =# @inline VerticalScalarDiffusivity(FT::DataType; kwargs...) = begin
            #= none:183 =#
            ScalarDiffusivity(ExplicitTimeDiscretization(), VerticalFormulation(), FT; kwargs...)
        end
#= none:184 =#
HorizontalScalarDiffusivity(FT::DataType; kwargs...) = begin
        #= none:184 =#
        ScalarDiffusivity(ExplicitTimeDiscretization(), HorizontalFormulation(), FT; kwargs...)
    end
#= none:185 =#
HorizontalDivergenceScalarDiffusivity(FT::DataType; kwargs...) = begin
        #= none:185 =#
        ScalarDiffusivity(ExplicitTimeDiscretization(), HorizontalDivergenceFormulation(), FT; kwargs...)
    end
#= none:187 =#
#= none:187 =# @inline function with_tracers(tracers, closure::ScalarDiffusivity{TD, F, N}) where {TD, F, N}
        #= none:187 =#
        #= none:188 =#
        κ = tracer_diffusivities(tracers, closure.κ)
        #= none:189 =#
        return ScalarDiffusivity{TD, F, N}(closure.ν, κ)
    end
#= none:192 =#
#= none:192 =# @inline viscosity(closure::ScalarDiffusivity, K) = begin
            #= none:192 =#
            closure.ν
        end
#= none:193 =#
#= none:193 =# @inline (diffusivity(closure::ScalarDiffusivity, K, ::Val{id}) where id) = begin
            #= none:193 =#
            closure.κ[id]
        end
#= none:195 =#
compute_diffusivities!(diffusivities, ::ScalarDiffusivity, args...) = begin
        #= none:195 =#
        nothing
    end
#= none:204 =#
function Base.summary(closure::ScalarDiffusivity)
    #= none:204 =#
    #= none:205 =#
    TD = summary(time_discretization(closure))
    #= none:206 =#
    prefix = replace(summary(formulation(closure)), "Formulation" => "")
    #= none:207 =#
    prefix === "ThreeDimensional" && (prefix = "")
    #= none:209 =#
    if closure.κ == NamedTuple()
        #= none:210 =#
        summary_str = string(prefix, "ScalarDiffusivity{$(TD)}(ν=", prettysummary(closure.ν), ")")
    else
        #= none:212 =#
        summary_str = string(prefix, "ScalarDiffusivity{$(TD)}(ν=", prettysummary(closure.ν), ", κ=", prettysummary(closure.κ), ")")
    end
    #= none:215 =#
    return summary_str
end
#= none:218 =#
Base.show(io::IO, closure::ScalarDiffusivity) = begin
        #= none:218 =#
        print(io, summary(closure))
    end
#= none:220 =#
function Adapt.adapt_structure(to, closure::ScalarDiffusivity{TD, F, <:Any, <:Any, N}) where {TD, F, N}
    #= none:220 =#
    #= none:221 =#
    ν = Adapt.adapt(to, closure.ν)
    #= none:222 =#
    κ = Adapt.adapt(to, closure.κ)
    #= none:223 =#
    return ScalarDiffusivity{TD, F, N}(ν, κ)
end
#= none:226 =#
function on_architecture(to, closure::ScalarDiffusivity{TD, F, <:Any, <:Any, N}) where {TD, F, N}
    #= none:226 =#
    #= none:227 =#
    ν = on_architecture(to, closure.ν)
    #= none:228 =#
    κ = on_architecture(to, closure.κ)
    #= none:229 =#
    return ScalarDiffusivity{TD, F, N}(ν, κ)
end