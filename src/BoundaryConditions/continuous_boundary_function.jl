
#= none:1 =#
using Oceananigans.Operators: index_and_interp_dependencies
#= none:2 =#
using Oceananigans.Utils: tupleit, user_function_arguments
#= none:3 =#
using Oceananigans.Grids: XFlatGrid, YFlatGrid, ZFlatGrid, YZFlatGrid, XZFlatGrid, XYFlatGrid
#= none:4 =#
using Oceananigans.Grids: ξnode, ηnode, rnode
#= none:6 =#
import Oceananigans: location
#= none:7 =#
import Oceananigans.Utils: prettysummary
#= none:9 =#
struct LeftBoundary
    #= none:9 =#
end
#= none:10 =#
struct RightBoundary
    #= none:10 =#
end
#= none:12 =#
#= none:12 =# Core.@doc "    struct ContinuousBoundaryFunction{X, Y, Z, I, F, P, D, N, ℑ} <: Function\n\nA wrapper for the user-defined boundary condition function `func` at location\n`X, Y, Z`. `I` denotes the boundary-normal index (`I=1` at western boundaries,\n`I=grid.Nx` at eastern boundaries, etc). `F, P, D, N, ℑ` are, respectively, the \nuser-defined function, parameters, field dependencies, indices of the field dependencies\nin `model_fields`, and interpolation operators for interpolating `model_fields` to the\nlocation at which the boundary condition is applied.\n" struct ContinuousBoundaryFunction{X, Y, Z, S, F, P, D, N, ℑ}
        #= none:23 =#
        func::F
        #= none:24 =#
        parameters::P
        #= none:25 =#
        field_dependencies::D
        #= none:26 =#
        field_dependencies_indices::N
        #= none:27 =#
        field_dependencies_interp::ℑ
        #= none:29 =#
        " Returns a location-less wrapper for `func`, `parameters`, and `field_dependencies`."
        #= none:30 =#
        function ContinuousBoundaryFunction(func::F, parameters::P, field_dependencies) where {F, P}
            #= none:30 =#
            #= none:31 =#
            field_dependencies = tupleit(field_dependencies)
            #= none:32 =#
            D = typeof(field_dependencies)
            #= none:33 =#
            return new{Nothing, Nothing, Nothing, Nothing, F, P, D, Nothing, Nothing}(func, parameters, field_dependencies, nothing, nothing)
        end
        #= none:36 =#
        function ContinuousBoundaryFunction{X, Y, Z, S}(func::F, parameters::P, field_dependencies::D, field_dependencies_indices::N, field_dependencies_interp::ℑ) where {X, Y, Z, S, F, P, D, ℑ, N}
            #= none:36 =#
            #= none:42 =#
            return new{X, Y, Z, S, F, P, D, N, ℑ}(func, parameters, field_dependencies, field_dependencies_indices, field_dependencies_interp)
        end
    end
#= none:46 =#
(location(::ContinuousBoundaryFunction{X, Y, Z}) where {X, Y, Z}) = begin
        #= none:46 =#
        (X, Y, Z)
    end
#= none:52 =#
#= none:52 =# Core.@doc "    regularize_boundary_condition(bc::BoundaryCondition{C, <:ContinuousBoundaryFunction},\n                                  topo, loc, dim, I, prognostic_field_names) where C\n\nRegularizes `bc.condition` for location `loc`, boundary index `I`, and `prognostic_field_names`,\nreturning `BoundaryCondition(C, regularized_condition)`.\n\nThe regularization of `bc.condition::ContinuousBoundaryFunction` requries\n\n1. Setting the boundary location to `LX, LY, LZ`.\n   The location in the boundary-normal direction is `Nothing`.\n\n2. Setting the boundary-normal index `I` for indexing into `field_dependencies`.\n   `I` is either `1` (for left boundaries) or\n   `size(grid, n)` for a boundary in the `n`th direction where `n ∈ (1, 2, 3)` corresponds\n   to `x, y, z`.\n\n3. Determining the `indices` that map `model_fields` to `field_dependencies`.\n\n4. Determining the `interps` functions that interpolate field_dependencies to the location\n   of the boundary.\n" function regularize_boundary_condition(bc::BoundaryCondition{C, <:ContinuousBoundaryFunction}, grid, loc, dim, Side, prognostic_field_names) where C
        #= none:74 =#
        #= none:77 =#
        boundary_func = bc.condition
        #= none:80 =#
        (LX, LY, LZ) = Tuple((if i == dim
                    Nothing
                else
                    loc[i]
                end for i = 1:3))
        #= none:82 =#
        (indices, interps) = index_and_interp_dependencies(LX, LY, LZ, boundary_func.field_dependencies, prognostic_field_names)
        #= none:86 =#
        regularized_boundary_func = ContinuousBoundaryFunction{LX, LY, LZ, Side}(boundary_func.func, boundary_func.parameters, boundary_func.field_dependencies, indices, interps)
        #= none:91 =#
        return BoundaryCondition(bc.classification, regularized_boundary_func)
    end
#= none:94 =#
#= none:94 =# @inline domain_boundary_indices(::LeftBoundary, N) = begin
            #= none:94 =#
            (1, 1)
        end
#= none:95 =#
#= none:95 =# @inline domain_boundary_indices(::RightBoundary, N) = begin
            #= none:95 =#
            (N, N + 1)
        end
#= none:97 =#
#= none:97 =# @inline cell_boundary_index(::LeftBoundary, i) = begin
            #= none:97 =#
            i
        end
#= none:98 =#
#= none:98 =# @inline cell_boundary_index(::RightBoundary, i) = begin
            #= none:98 =#
            i + 1
        end
#= none:104 =#
#= none:104 =# @inline x_boundary_node(i, j, k, grid, ℓy, ℓz) = begin
            #= none:104 =#
            (ηnode(i, j, k, grid, Face(), ℓy, ℓz), rnode(i, j, k, grid, Face(), ℓy, ℓz))
        end
#= none:105 =#
#= none:105 =# @inline x_boundary_node(i, j, k, grid::YFlatGrid, ℓy, ℓz) = begin
            #= none:105 =#
            tuple(rnode(i, j, k, grid, Face(), nothing, ℓz))
        end
#= none:106 =#
#= none:106 =# @inline x_boundary_node(i, j, k, grid::ZFlatGrid, ℓy, ℓz) = begin
            #= none:106 =#
            tuple(ηnode(i, j, k, grid, Face(), ℓy, nothing))
        end
#= none:107 =#
#= none:107 =# @inline x_boundary_node(i, j, k, grid::YZFlatGrid, ℓy, ℓz) = begin
            #= none:107 =#
            tuple()
        end
#= none:109 =#
#= none:109 =# @inline y_boundary_node(i, j, k, grid, ℓx, ℓz) = begin
            #= none:109 =#
            (ξnode(i, j, k, grid, ℓx, Face(), ℓz), rnode(i, j, k, grid, ℓx, Face(), ℓz))
        end
#= none:110 =#
#= none:110 =# @inline y_boundary_node(i, j, k, grid::XFlatGrid, ℓx, ℓz) = begin
            #= none:110 =#
            tuple(rnode(i, j, k, grid, nothing, Face(), ℓz))
        end
#= none:111 =#
#= none:111 =# @inline y_boundary_node(i, j, k, grid::ZFlatGrid, ℓx, ℓz) = begin
            #= none:111 =#
            tuple(ξnode(i, j, k, grid, ℓx, Face(), nothing))
        end
#= none:112 =#
#= none:112 =# @inline y_boundary_node(i, j, k, grid::XZFlatGrid, ℓx, ℓz) = begin
            #= none:112 =#
            tuple()
        end
#= none:114 =#
#= none:114 =# @inline z_boundary_node(i, j, k, grid, ℓx, ℓy) = begin
            #= none:114 =#
            (ξnode(i, j, k, grid, ℓx, ℓy, Face()), ηnode(i, j, k, grid, ℓx, ℓy, Face()))
        end
#= none:115 =#
#= none:115 =# @inline z_boundary_node(i, j, k, grid::XFlatGrid, ℓx, ℓy) = begin
            #= none:115 =#
            tuple(ηnode(i, j, k, grid, nothing, ℓy, Face()))
        end
#= none:116 =#
#= none:116 =# @inline z_boundary_node(i, j, k, grid::YFlatGrid, ℓx, ℓy) = begin
            #= none:116 =#
            tuple(ξnode(i, j, k, grid, ℓx, nothing, Face()))
        end
#= none:117 =#
#= none:117 =# @inline z_boundary_node(i, j, k, grid::XYFlatGrid, ℓx, ℓy) = begin
            #= none:117 =#
            tuple()
        end
#= none:119 =#
const XBoundaryFunction{LY, LZ, S} = (BoundaryCondition{<:Any, <:ContinuousBoundaryFunction{Nothing, LY, LZ, S}} where {LY, LZ, S})
#= none:120 =#
const YBoundaryFunction{LX, LZ, S} = (BoundaryCondition{<:Any, <:ContinuousBoundaryFunction{LX, Nothing, LZ, S}} where {LX, LZ, S})
#= none:121 =#
const ZBoundaryFunction{LX, LY, S} = (BoundaryCondition{<:Any, <:ContinuousBoundaryFunction{LX, LY, Nothing, S}} where {LX, LY, S})
#= none:124 =#
#= none:124 =# @inline function getbc(bc::XBoundaryFunction{LY, LZ, S}, j::Integer, k::Integer, grid::AbstractGrid, clock, model_fields, args...) where {LY, LZ, S}
        #= none:124 =#
        #= none:127 =#
        cbf = bc.condition
        #= none:128 =#
        (i, i′) = domain_boundary_indices(S(), grid.Nx)
        #= none:129 =#
        args = user_function_arguments(i, j, k, grid, model_fields, cbf.parameters, cbf)
        #= none:130 =#
        X = x_boundary_node(i′, j, k, grid, LY(), LZ())
        #= none:132 =#
        return cbf.func(X..., clock.time, args...)
    end
#= none:136 =#
#= none:136 =# @inline function getbc(bc::YBoundaryFunction{LX, LZ, S}, i::Integer, k::Integer, grid::AbstractGrid, clock, model_fields, args...) where {LX, LZ, S}
        #= none:136 =#
        #= none:139 =#
        cbf = bc.condition
        #= none:140 =#
        (j, j′) = domain_boundary_indices(S(), grid.Ny)
        #= none:141 =#
        args = user_function_arguments(i, j, k, grid, model_fields, cbf.parameters, cbf)
        #= none:142 =#
        X = y_boundary_node(i, j′, k, grid, LX(), LZ())
        #= none:144 =#
        return cbf.func(X..., clock.time, args...)
    end
#= none:148 =#
#= none:148 =# @inline function getbc(bc::ZBoundaryFunction{LX, LY, S}, i::Integer, j::Integer, grid::AbstractGrid, clock, model_fields, args...) where {LX, LY, S}
        #= none:148 =#
        #= none:151 =#
        cbf = bc.condition
        #= none:152 =#
        (k, k′) = domain_boundary_indices(S(), grid.Nz)
        #= none:153 =#
        args = user_function_arguments(i, j, k, grid, model_fields, cbf.parameters, cbf)
        #= none:154 =#
        X = z_boundary_node(i, j, k′, grid, LX(), LY())
        #= none:156 =#
        return cbf.func(X..., clock.time, args...)
    end
#= none:164 =#
#= none:164 =# @inline function getbc(bc::XBoundaryFunction{LY, LZ, S}, i::Integer, j::Integer, k::Integer, grid::AbstractGrid, clock, model_fields, args...) where {LY, LZ, S}
        #= none:164 =#
        #= none:167 =#
        cbf = bc.condition
        #= none:168 =#
        i′ = cell_boundary_index(S(), i)
        #= none:169 =#
        args = user_function_arguments(i, j, k, grid, model_fields, cbf.parameters, cbf)
        #= none:170 =#
        X = node(i′, j, k, grid, Face(), LY(), LZ())
        #= none:172 =#
        return cbf.func(X..., clock.time, args...)
    end
#= none:176 =#
#= none:176 =# @inline function getbc(bc::YBoundaryFunction{LX, LZ, S}, i::Integer, j::Integer, k::Integer, grid::AbstractGrid, clock, model_fields, args...) where {LX, LZ, S}
        #= none:176 =#
        #= none:179 =#
        cbf = bc.condition
        #= none:180 =#
        j′ = cell_boundary_index(S(), j)
        #= none:181 =#
        args = user_function_arguments(i, j, k, grid, model_fields, cbf.parameters, cbf)
        #= none:182 =#
        X = node(i, j′, k, grid, LX(), Face(), LZ())
        #= none:184 =#
        return cbf.func(X..., clock.time, args...)
    end
#= none:188 =#
#= none:188 =# @inline function getbc(bc::ZBoundaryFunction{LX, LY, S}, i::Integer, j::Integer, k::Integer, grid::AbstractGrid, clock, model_fields, args...) where {LX, LY, S}
        #= none:188 =#
        #= none:191 =#
        cbf = bc.condition
        #= none:192 =#
        k′ = cell_boundary_index(S(), k)
        #= none:193 =#
        args = user_function_arguments(i, j, k, grid, model_fields, cbf.parameters, cbf)
        #= none:194 =#
        X = node(i, j, k′, grid, LX(), LY(), Face())
        #= none:196 =#
        return cbf.func(X..., clock.time, args...)
    end
#= none:204 =#
BoundaryCondition(Classification::DataType, condition::ContinuousBoundaryFunction) = begin
        #= none:204 =#
        BoundaryCondition(Classification(), condition)
    end
#= none:207 =#
function Base.summary(bf::ContinuousBoundaryFunction)
    #= none:207 =#
    #= none:208 =#
    loc = location(bf)
    #= none:209 =#
    return string("ContinuousBoundaryFunction ", prettysummary(bf.func, false), " at ", loc)
end
#= none:212 =#
prettysummary(bf::ContinuousBoundaryFunction) = begin
        #= none:212 =#
        summary(bf)
    end
#= none:214 =#
(Adapt.adapt_structure(to, bf::ContinuousBoundaryFunction{LX, LY, LZ, S}) where {LX, LY, LZ, S}) = begin
        #= none:214 =#
        ContinuousBoundaryFunction{LX, LY, LZ, S}(Adapt.adapt(to, bf.func), Adapt.adapt(to, bf.parameters), nothing, Adapt.adapt(to, bf.field_dependencies_indices), Adapt.adapt(to, bf.field_dependencies_interp))
    end
#= none:221 =#
(on_architecture(to, bf::ContinuousBoundaryFunction{LX, LY, LZ, S}) where {LX, LY, LZ, S}) = begin
        #= none:221 =#
        ContinuousBoundaryFunction{LX, LY, LZ, S}(on_architecture(to, bf.func), on_architecture(to, bf.parameters), on_architecture(to, bf.field_dependencies), on_architecture(to, bf.field_dependencies_indices), on_architecture(to, bf.field_dependencies_interp))
    end