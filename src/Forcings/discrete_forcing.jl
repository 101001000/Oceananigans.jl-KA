
#= none:1 =#
import Adapt
#= none:3 =#
using Oceananigans.Utils: prettysummary
#= none:5 =#
#= none:5 =# Core.@doc "    struct DiscreteForcing{P, F}\n\nWrapper for \"discrete form\" forcing functions with optional `parameters`.\n" struct DiscreteForcing{P, F}
        #= none:11 =#
        func::F
        #= none:12 =#
        parameters::P
    end
#= none:15 =#
#= none:15 =# Core.@doc "    DiscreteForcing(func; parameters=nothing)\n\nConstruct a \"discrete form\" forcing function with optional parameters.\nThe forcing function is applied at grid point `i, j, k`.\n\nWhen `parameters` are not specified, `func` must be callable with the signature\n\n```\nfunc(i, j, k, grid, clock, model_fields)\n```\n\nwhere `grid` is `model.grid`, `clock.time` is the current simulation time and\n`clock.iteration` is the current model iteration, and `model_fields` is a\n`NamedTuple` with `u, v, w` and the fields in `model.tracers`.\n\n*Note* that the index `end` does *not* access the final physical grid point of\na model field in any direction. The final grid point must be explicitly specified, as\nin `model_fields.u[i, j, grid.Nz]`.\n\nWhen `parameters` _is_ specified, `func` must be callable with the signature.\n\n```\nfunc(i, j, k, grid, clock, model_fields, parameters)\n```\n    \nAbove, `parameters` is, in principle, arbitrary. Note, however, that GPU compilation\ncan place constraints on `typeof(parameters)`.\n" DiscreteForcing(func; parameters = nothing) = begin
            #= none:44 =#
            DiscreteForcing(func, parameters)
        end
#= none:46 =#
#= none:46 =# @inline function (forcing::DiscreteForcing{P, F})(i, j, k, grid, clock, model_fields) where {P, F <: Function}
        #= none:46 =#
        #= none:47 =#
        parameters = forcing.parameters
        #= none:48 =#
        return forcing.func(i, j, k, grid, clock, model_fields, parameters)
    end
#= none:51 =#
#= none:51 =# @inline ((forcing::DiscreteForcing{<:Nothing, F})(i, j, k, grid, clock, model_fields) where F <: Function) = begin
            #= none:51 =#
            forcing.func(i, j, k, grid, clock, model_fields)
        end
#= none:54 =#
#= none:54 =# Core.@doc "Show the innards of a `DiscreteForcing` in the REPL." (Base.show(io::IO, forcing::DiscreteForcing{P}) where P) = begin
            #= none:55 =#
            print(io, "DiscreteForcing{$(P)}", "\n", "├── func: $(prettysummary(forcing.func))", "\n", "└── parameters: $(forcing.parameters)")
        end
#= none:60 =#
Adapt.adapt_structure(to, forcing::DiscreteForcing) = begin
        #= none:60 =#
        DiscreteForcing(Adapt.adapt(to, forcing.func), Adapt.adapt(to, forcing.parameters))
    end
#= none:64 =#
on_architecture(to, forcing::DiscreteForcing) = begin
        #= none:64 =#
        DiscreteForcing(on_architecture(to, forcing.func), on_architecture(to, forcing.parameters))
    end