
#= none:1 =#
#= none:1 =# Core.@doc "    struct DiscreteBoundaryFunction{P, F} <: Function\n\nA wrapper for boundary condition functions with optional parameters.\nWhen `parameters=nothing`, the boundary condition `func` is called with the signature\n\n```\nfunc(i, j, grid, clock, model_fields)\n```\n\nwhere `i, j` are the indices along the boundary,\nwhere `grid` is `model.grid`, `clock.time` is the current simulation time and\n`clock.iteration` is the current model iteration, and\n`model_fields` is a `NamedTuple` with `u, v, w`, the fields in `model.tracers`,\nand the fields in `model.diffusivity_fields`, each of which is an `OffsetArray`s (or `NamedTuple`s\nof `OffsetArray`s depending on the turbulence closure) of field data.\n\nWhen `parameters` is not `nothing`, the boundary condition `func` is called with\nthe signature\n\n```\nfunc(i, j, grid, clock, model_fields, parameters)\n```\n\n*Note* that the index `end` does *not* access the final physical grid point of\na model field in any direction. The final grid point must be explictly specified, as\nin `model_fields.u[i, j, grid.Nz]`.\n" struct DiscreteBoundaryFunction{P, F}
        #= none:30 =#
        func::F
        #= none:31 =#
        parameters::P
    end
#= none:34 =#
const UnparameterizedDBF = DiscreteBoundaryFunction{<:Nothing}
#= none:35 =#
const UnparameterizedDBFBC = BoundaryCondition{<:Any, <:UnparameterizedDBF}
#= none:36 =#
const DBFBC = BoundaryCondition{<:Any, <:DiscreteBoundaryFunction}
#= none:38 =#
#= none:38 =# @inline getbc(bc::UnparameterizedDBFBC, i::Integer, j::Integer, grid::AbstractGrid, clock, model_fields, args...) = begin
            #= none:38 =#
            bc.condition.func(i, j, grid, clock, model_fields)
        end
#= none:41 =#
#= none:41 =# @inline getbc(bc::DBFBC, i::Integer, j::Integer, grid::AbstractGrid, clock, model_fields, args...) = begin
            #= none:41 =#
            bc.condition.func(i, j, grid, clock, model_fields, bc.condition.parameters)
        end
#= none:45 =#
#= none:45 =# @inline getbc(bc::UnparameterizedDBFBC, i::Integer, j::Integer, k::Integer, grid::AbstractGrid, clock, model_fields, args...) = begin
            #= none:45 =#
            bc.condition.func(i, j, k, grid, clock, model_fields)
        end
#= none:48 =#
#= none:48 =# @inline getbc(bc::DBFBC, i::Integer, j::Integer, k::Integer, grid::AbstractGrid, clock, model_fields, args...) = begin
            #= none:48 =#
            bc.condition.func(i, j, k, grid, clock, model_fields, bc.condition.parameters)
        end
#= none:52 =#
BoundaryCondition(Classification::DataType, condition::DiscreteBoundaryFunction) = begin
        #= none:52 =#
        BoundaryCondition(Classification(), condition)
    end
#= none:54 =#
Base.summary(bf::DiscreteBoundaryFunction{<:Nothing}) = begin
        #= none:54 =#
        string("DiscreteBoundaryFunction with ", prettysummary(bf.func, false))
    end
#= none:55 =#
Base.summary(bf::DiscreteBoundaryFunction) = begin
        #= none:55 =#
        string("DiscreteBoundaryFunction ", prettysummary(bf.func, false), " with parameters ", prettysummary(bf.parameters, false))
    end
#= none:57 =#
Adapt.adapt_structure(to, bf::DiscreteBoundaryFunction) = begin
        #= none:57 =#
        DiscreteBoundaryFunction(Adapt.adapt(to, bf.func), Adapt.adapt(to, bf.parameters))
    end
#= none:60 =#
on_architecture(to, bf::DiscreteBoundaryFunction) = begin
        #= none:60 =#
        DiscreteBoundaryFunction(on_architecture(to, bf.func), on_architecture(to, bf.parameters))
    end