
#= none:1 =#
import Adapt
#= none:3 =#
using Oceananigans.Grids: node
#= none:4 =#
using Oceananigans.Operators: assumed_field_location, index_and_interp_dependencies
#= none:5 =#
using Oceananigans.Fields: show_location
#= none:6 =#
using Oceananigans.Utils: user_function_arguments, tupleit, prettysummary
#= none:8 =#
#= none:8 =# Core.@doc "    ContinuousForcing{LX, LY, LZ, P, F, D, I, ℑ}\n\nA callable object that implements a \"continuous form\" forcing function\non a field at the location `LX, LY, LZ` with optional parameters.\n" struct ContinuousForcing{LX, LY, LZ, P, F, D, I, ℑ}
        #= none:15 =#
        func::F
        #= none:16 =#
        parameters::P
        #= none:17 =#
        field_dependencies::D
        #= none:18 =#
        field_dependencies_indices::I
        #= none:19 =#
        field_dependencies_interp::ℑ
        #= none:23 =#
        function ContinuousForcing(func, parameters, field_dependencies)
            #= none:23 =#
            #= none:24 =#
            field_dependencies = tupleit(field_dependencies)
            #= none:26 =#
            return new{Nothing, Nothing, Nothing, typeof(parameters), typeof(func), typeof(field_dependencies), Nothing, Nothing}(func, parameters, field_dependencies, nothing, nothing)
        end
        #= none:35 =#
        function ContinuousForcing{LX, LY, LZ}(func, parameters = nothing, field_dependencies = (), field_dependencies_indices = (), field_dependencies_interp = ()) where {LX, LY, LZ}
            #= none:35 =#
            #= none:37 =#
            return new{LX, LY, LZ, typeof(parameters), typeof(func), typeof(field_dependencies), typeof(field_dependencies_indices), typeof(field_dependencies_interp)}(func, parameters, field_dependencies, field_dependencies_indices, field_dependencies_interp)
        end
    end
#= none:47 =#
#= none:47 =# Core.@doc "    ContinuousForcing(func; parameters=nothing, field_dependencies=())\n\nConstruct a \"continuous form\" forcing with optional `parameters` and optional\n`field_dependencies` on other fields in a model.\n\nIf neither `parameters` nor `field_dependencies` are provided, then `func` must be\ncallable with the signature\n\n```julia\nfunc(X..., t)\n```\n\nwhere, on a three-dimensional grid with no `Flat` directions, `X = (x, y, z)`\nis a 3-tuple containing the east-west, north-south, and vertical spatial coordinates, and `t` is time.\n\nDimensions with `Flat` topology are omitted from the coordinate tuple `X`.\nFor example, on a grid with topology `(Periodic, Periodic, Flat)`, and with no `parameters` or `field_dependencies`,\nthen `func` must be callable\n\n```julia\nfunc(x, y, t)\n```\n\nwhere `x` and `y` are the east-west and north-south coordinates, respectively.\nFor another example, on a grid with topology `(Flat, Flat, Bounded)` (e.g. a single column), and\nfor a forcing with no `parameters` or `field_dependencies`, then `func` must be callable with\n\n```julia\nfunc(z, t)\n```\n\nwhere `z` is the vertical coordinate.\n\n\nIf `field_dependencies` are provided, the signature of `func` must include them.\nFor example, if `field_dependencies=(:u, :S)` (and `parameters` are _not_ provided), and\non a three-dimensional grid with no `Flat` dimensions, then `func` must be callable with the signature\n\n```julia\nfunc(x, y, z, t, u, S)\n```\n\nwhere `u` is assumed to be the `u`-velocity component, and `S` is a tracer. Note that any field\nwhich does not have the name `u`, `v`, or `w` is assumed to be a tracer and must be present\nin `model.tracers`.\n\nIf `parameters` are provided, then the _last_ argument to `func` must be `parameters`.\nFor example, if `func` has no `field_dependencies` but does depend on `parameters`, then\non a three-dimensional grid it must be callable with the signature\n\n```julia\nfunc(x, y, z, t, parameters)\n```\n\nWith `field_dependencies=(:u, :v, :w, :c)` and `parameters` and on a three-dimensional grid,\nthen `func` must be callable with the signature\n\n```julia\nfunc(x, y, z, t, u, v, w, c, parameters)\n```\n" ContinuousForcing(func; parameters = nothing, field_dependencies = ()) = begin
            #= none:109 =#
            ContinuousForcing(func, parameters, field_dependencies)
        end
#= none:112 =#
#= none:112 =# Core.@doc "    regularize_forcing(forcing::ContinuousForcing, field, field_name, model_field_names)\n\nRegularize `forcing::ContinuousForcing` by determining the indices of `forcing.field_dependencies`\nin `model_field_names`, and associated interpolation functions so `forcing` can be used during\ntime-stepping `NonhydrostaticModel`.\n" function regularize_forcing(forcing::ContinuousForcing, field, field_name, model_field_names)
        #= none:119 =#
        #= none:121 =#
        (LX, LY, LZ) = location(field)
        #= none:123 =#
        (indices, interps) = index_and_interp_dependencies(LX, LY, LZ, forcing.field_dependencies, model_field_names)
        #= none:127 =#
        return ContinuousForcing{LX, LY, LZ}(forcing.func, forcing.parameters, forcing.field_dependencies, indices, interps)
    end
#= none:135 =#
#= none:135 =# @inline function (forcing::ContinuousForcing{LX, LY, LZ, P, F})(i, j, k, grid, clock, model_fields) where {LX, LY, LZ, P, F}
        #= none:135 =#
        #= none:137 =#
        args = user_function_arguments(i, j, k, grid, model_fields, forcing.parameters, forcing)
        #= none:139 =#
        X = node(i, j, k, grid, LX(), LY(), LZ())
        #= none:141 =#
        return forcing.func(X..., clock.time, args...)
    end
#= none:144 =#
#= none:144 =# Core.@doc "Show the innards of a `ContinuousForcing` in the REPL." (Base.show(io::IO, forcing::ContinuousForcing{LX, LY, LZ, P}) where {LX, LY, LZ, P}) = begin
            #= none:145 =#
            print(io, "ContinuousForcing{$(P)} at ", show_location(LX, LY, LZ), "\n", "├── func: $(prettysummary(forcing.func))", "\n", "├── parameters: $(forcing.parameters)", "\n", "└── field dependencies: $(forcing.field_dependencies)")
        end
#= none:151 =#
#= none:151 =# Core.@doc "Show the innards of an \"non-regularized\" `ContinuousForcing` in the REPL." (Base.show(io::IO, forcing::ContinuousForcing{Nothing, Nothing, Nothing, P}) where P) = begin
            #= none:152 =#
            print(io, "ContinuousForcing{$(P)}", "\n", "├── func: $(prettysummary(forcing.func))", "\n", "├── parameters: $(forcing.parameters)", "\n", "└── field dependencies: $(forcing.field_dependencies)")
        end
#= none:158 =#
(Adapt.adapt_structure(to, forcing::ContinuousForcing{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:158 =#
        ContinuousForcing{LX, LY, LZ}(Adapt.adapt(to, forcing.func), Adapt.adapt(to, forcing.parameters), nothing, Adapt.adapt(to, forcing.field_dependencies_indices), Adapt.adapt(to, forcing.field_dependencies_interp))
    end
#= none:165 =#
(on_architecture(to, forcing::ContinuousForcing{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:165 =#
        ContinuousForcing{LX, LY, LZ}(on_architecture(to, forcing.func), on_architecture(to, forcing.parameters), on_architecture(to, forcing.field_dependencies), on_architecture(to, forcing.field_dependencies_indices), on_architecture(to, forcing.field_dependencies_interp))
    end