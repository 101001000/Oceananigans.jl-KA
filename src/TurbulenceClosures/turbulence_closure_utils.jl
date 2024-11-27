
#= none:1 =#
using Oceananigans.Operators
#= none:3 =#
const PossibleDiffusivity = Union{Number, Function, DiscreteDiffusionFunction, AbstractArray}
#= none:5 =#
#= none:5 =# @inline tracer_diffusivities(tracers, κ::PossibleDiffusivity) = begin
            #= none:5 =#
            with_tracers(tracers, NamedTuple(), ((tracers, init)->begin
                        #= none:5 =#
                        κ
                    end))
        end
#= none:6 =#
#= none:6 =# @inline tracer_diffusivities(tracers, ::Nothing) = begin
            #= none:6 =#
            nothing
        end
#= none:8 =#
#= none:8 =# @inline function tracer_diffusivities(tracers, κ::NamedTuple)
        #= none:8 =#
        #= none:10 =#
        all((name ∈ propertynames(κ) for name = tracers)) || throw(ArgumentError("Tracer diffusivities or diffusivity parameters must either be a constants\n                            or a `NamedTuple` with a value for every tracer!"))
        #= none:14 =#
        return κ
    end
#= none:17 =#
#= none:17 =# @inline convert_diffusivity(FT, κ::Number; kw...) = begin
            #= none:17 =#
            convert(FT, κ)
        end
#= none:19 =#
#= none:19 =# @inline function convert_diffusivity(FT, κ; discrete_form = false, loc = (nothing, nothing, nothing), parameters = nothing)
        #= none:19 =#
        #= none:20 =#
        discrete_form && return DiscreteDiffusionFunction(κ; loc, parameters)
        #= none:21 =#
        return κ
    end
#= none:24 =#
#= none:24 =# @inline function convert_diffusivity(FT, κ::NamedTuple; discrete_form = false, loc = (nothing, nothing, nothing), parameters = nothing)
        #= none:24 =#
        #= none:25 =#
        κ_names = propertynames(κ)
        #= none:26 =#
        Nnames = length(κ_names)
        #= none:28 =#
        κ_values = ntuple(Val(Nnames)) do n
                #= none:29 =#
                #= none:29 =# Base.@_inline_meta
                #= none:30 =#
                κi = κ[n]
                #= none:31 =#
                convert_diffusivity(FT, κi; discrete_form, loc, parameters)
            end
        #= none:34 =#
        return NamedTuple{κ_names}(κ_values)
    end