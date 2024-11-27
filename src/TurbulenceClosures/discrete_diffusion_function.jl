
#= none:1 =#
using Oceananigans.Operators: ℑxyz
#= none:2 =#
using Oceananigans.Utils: instantiate
#= none:4 =#
#= none:4 =# Core.@doc "    struct DiscreteDiffusionFunction{LX, LY, LZ, P, F} \n\nA wrapper for a diffusivity functions with optional parameters at a specified locations.\n" struct DiscreteDiffusionFunction{LX, LY, LZ, P, F}
        #= none:10 =#
        func::F
        #= none:11 =#
        parameters::P
        #= none:13 =#
        (DiscreteDiffusionFunction{LX, LY, LZ}(func::F, parameters::P) where {LX, LY, LZ, F, P}) = begin
                #= none:13 =#
                new{LX, LY, LZ, P, F}(func, parameters)
            end
    end
#= none:17 =#
#= none:17 =# Core.@doc "    DiscreteDiffusionFunction(func; parameters, loc)\n\n!!! info \"Not user-facing method\"\n    This is not a user-facing method but instead it is used via various turbulence closures.\n    Users build the diffusivities via each turbulence closure constructor, e.g., [`ScalarDiffusivity`](@ref).\n\nReturn a discrete representation of a diffusivity `func`tion with optional `parameters`\nat specified `loc`ations.\n\nKeyword Arguments\n=================\n\n* `parameters`: A named tuple with parameters used by `func`; default: `nothing`.\n\n* `loc`: A tuple with the locations `(LX, LY, LZ)` that the diffusivity `func` is applied on.\n\n  **Without locations**\n\n  If `LX == LY == LZ == nothing` the diffusivity is evaluated at the required locations. In this case, the `func`tion\n  call *requires passing* the locations `ℓx, ℓy, ℓz` in the signature:\n\n  - Without parameters:\n\n    ```julia\n    func(i, j, k, grid, ℓx, ℓy, ℓz, clock, model_fields)\n    ```\n\n    where `i, j, k` are the indices, `grid` is `model.grid`, `ℓx, ℓy, ℓz` are the\n    instantiated versions of `LX, LY, LZ`, `clock.time` is the current simulation time,\n    `clock.iteration` is the current model iteration, and `model_fields` is a\n    `NamedTuple` with `u, v, w`, the fields in `model.tracers` and the `model.auxiliary_fields`.\n\n  - When `parameters` is not `nothing`, `func` is called with the signature\n\n    ```julia\n    func(i, j, k, grid, ℓx, ℓy, ℓz, clock, model_fields, parameters)\n    ```\n\n  **With locations**\n\n  If `LX, LY, LZ != (nothing, nothing, nothing)` the diffusivity is evaluated at `(LX, LY, LZ)` and interpolated onto\n  the required locations. In this case, the function call *does not require* locations in the signature. The diffusivity\n  `func`ion is called with the signature:\n\n  1. Without parameters:\n\n    ```julia\n    func(i, j, k, grid, clock, model_fields)\n    ```\n\n  2. When `parameters` is not `nothing`, `func` is called with the signature\n\n    ```julia\n    func(i, j, k, grid, clock, model_fields, parameters)\n    ```\n" function DiscreteDiffusionFunction(func; parameters, loc)
        #= none:74 =#
        #= none:75 =#
        loc = instantiate.(loc)
        #= none:76 =#
        return DiscreteDiffusionFunction{typeof(loc[1]), typeof(loc[2]), typeof(loc[3])}(func, parameters)
    end
#= none:79 =#
const UnparameterizedDDF{LX, LY, LZ} = (DiscreteDiffusionFunction{LX, LY, LZ, <:Nothing} where {LX, LY, LZ})
#= none:80 =#
const UnlocalizedDDF = DiscreteDiffusionFunction{<:Nothing, <:Nothing, <:Nothing}
#= none:81 =#
const UnlocalizedUnparametrizedDDF = DiscreteDiffusionFunction{<:Nothing, <:Nothing, <:Nothing, <:Nothing}
#= none:83 =#
#= none:83 =# @inline function getdiffusivity(dd::DiscreteDiffusionFunction{LX, LY, LZ}, i, j, k, grid, location, clock, fields) where {LX, LY, LZ}
        #= none:83 =#
        #= none:85 =#
        from = (LX(), LY(), LZ())
        #= none:86 =#
        return ℑxyz(i, j, k, grid, from, location, dd.func, clock, fields, dd.parameters)
    end
#= none:89 =#
#= none:89 =# @inline function getdiffusivity(dd::UnparameterizedDDF{LX, LY, LZ}, i, j, k, grid, location, clock, fields) where {LX, LY, LZ}
        #= none:89 =#
        #= none:91 =#
        from = (LX(), LY(), LZ())
        #= none:92 =#
        return ℑxyz(i, j, k, grid, from, location, dd.func, clock, fields)
    end
#= none:95 =#
#= none:95 =# @inline getdiffusivity(dd::UnlocalizedDDF, i, j, k, grid, location, clock, fields) = begin
            #= none:95 =#
            dd.func(i, j, k, grid, location..., clock, fields, dd.parameters)
        end
#= none:98 =#
#= none:98 =# @inline getdiffusivity(dd::UnlocalizedUnparametrizedDDF, i, j, k, grid, location, clock, fields) = begin
            #= none:98 =#
            dd.func(i, j, k, grid, location..., clock, fields)
        end
#= none:101 =#
(Adapt.adapt_structure(to, dd::DiscreteDiffusionFunction{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:101 =#
        DiscreteDiffusionFunction{LX, LY, LZ}(Adapt.adapt(to, dd.func), Adapt.adapt(to, dd.parameters))
    end
#= none:105 =#
(on_architecture(to, dd::DiscreteDiffusionFunction{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:105 =#
        DiscreteDiffusionFunction{LX, LY, LZ}(on_architecture(to, dd.func), on_architecture(to, dd.parameters))
    end