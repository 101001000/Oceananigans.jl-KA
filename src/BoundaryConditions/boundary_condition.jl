
#= none:1 =#
import Oceananigans.Architectures: on_architecture
#= none:3 =#
#= none:3 =# Core.@doc "    struct BoundaryCondition{C<:AbstractBoundaryConditionClassification, T}\n\nContainer for boundary conditions.\n" struct BoundaryCondition{C <: AbstractBoundaryConditionClassification, T}
        #= none:9 =#
        classification::C
        #= none:10 =#
        condition::T
    end
#= none:13 =#
#= none:13 =# Core.@doc "    BoundaryCondition(classification::AbstractBoundaryConditionClassification, condition::Function;\n                      parameters = nothing,\n                      discrete_form = false,\n                      field_dependencies=())\n\nConstruct a boundary condition of type `classification` with a function boundary `condition`.\n\nBy default, the function boudnary `condition` is assumed to have the 'continuous form'\n`condition(ξ, η, t)`, where `t` is time and `ξ` and `η` vary along the boundary.\nIn particular:\n\n- On `x`-boundaries, `condition(y, z, t)`.\n- On `y`-boundaries, `condition(x, z, t)`.\n- On `z`-boundaries, `condition(x, y, t)`.\n\nIf `parameters` is not `nothing`, then function boundary conditions have the form\n`func(ξ, η, t, parameters)`, where `ξ` and `η` are spatial coordinates varying along\nthe boundary as explained above.\n\nIf `discrete_form = true`, the function `condition` is assumed to have the \"discrete form\",\n```\ncondition(i, j, grid, clock, model_fields)\n```\nwhere `i`, and `j` are indices that vary along the boundary. If `discrete_form = true` and\n`parameters` is not `nothing`, the function `condition` is called with\n```\ncondition(i, j, grid, clock, model_fields, parameters)\n```\n" function BoundaryCondition(classification::AbstractBoundaryConditionClassification, condition::Function; parameters = nothing, discrete_form = false, field_dependencies = ())
        #= none:43 =#
        #= none:48 =#
        if discrete_form
            #= none:49 =#
            field_dependencies != () && error("Cannot set `field_dependencies` when `discrete_form=true`!")
            #= none:50 =#
            condition = DiscreteBoundaryFunction(condition, parameters)
        else
            #= none:53 =#
            condition = ContinuousBoundaryFunction(condition, parameters, field_dependencies)
        end
        #= none:56 =#
        return BoundaryCondition(classification, condition)
    end
#= none:60 =#
BoundaryCondition(Classification::DataType, args...; kwargs...) = begin
        #= none:60 =#
        BoundaryCondition(Classification(), args...; kwargs...)
    end
#= none:61 =#
BoundaryCondition(::Type{Open}, args...; kwargs...) = begin
        #= none:61 =#
        BoundaryCondition(Open(nothing), args...; kwargs...)
    end
#= none:64 =#
Adapt.adapt_structure(to, b::BoundaryCondition) = begin
        #= none:64 =#
        BoundaryCondition(Adapt.adapt(to, b.classification), Adapt.adapt(to, b.condition))
    end
#= none:68 =#
on_architecture(to, b::BoundaryCondition) = begin
        #= none:68 =#
        BoundaryCondition(on_architecture(to, b.classification), on_architecture(to, b.condition))
    end
#= none:76 =#
const BC = BoundaryCondition
#= none:77 =#
const FBC = BoundaryCondition{<:Flux}
#= none:78 =#
const PBC = BoundaryCondition{<:Periodic}
#= none:79 =#
const OBC = BoundaryCondition{<:Open}
#= none:80 =#
const VBC = BoundaryCondition{<:Value}
#= none:81 =#
const GBC = BoundaryCondition{<:Gradient}
#= none:82 =#
const ZFBC = BoundaryCondition{Flux, Nothing}
#= none:83 =#
const MCBC = BoundaryCondition{<:MultiRegionCommunication}
#= none:84 =#
const DCBC = BoundaryCondition{<:DistributedCommunication}
#= none:87 =#
PeriodicBoundaryCondition() = begin
        #= none:87 =#
        BoundaryCondition(Periodic(), nothing)
    end
#= none:88 =#
NoFluxBoundaryCondition() = begin
        #= none:88 =#
        BoundaryCondition(Flux(), nothing)
    end
#= none:89 =#
ImpenetrableBoundaryCondition() = begin
        #= none:89 =#
        BoundaryCondition(Open(), nothing)
    end
#= none:90 =#
MultiRegionCommunicationBoundaryCondition() = begin
        #= none:90 =#
        BoundaryCondition(MultiRegionCommunication(), nothing)
    end
#= none:91 =#
DistributedCommunicationBoundaryCondition() = begin
        #= none:91 =#
        BoundaryCondition(DistributedCommunication(), nothing)
    end
#= none:93 =#
FluxBoundaryCondition(val; kwargs...) = begin
        #= none:93 =#
        BoundaryCondition(Flux(), val; kwargs...)
    end
#= none:94 =#
ValueBoundaryCondition(val; kwargs...) = begin
        #= none:94 =#
        BoundaryCondition(Value(), val; kwargs...)
    end
#= none:95 =#
GradientBoundaryCondition(val; kwargs...) = begin
        #= none:95 =#
        BoundaryCondition(Gradient(), val; kwargs...)
    end
#= none:96 =#
OpenBoundaryCondition(val; kwargs...) = begin
        #= none:96 =#
        BoundaryCondition(Open(nothing), val; kwargs...)
    end
#= none:97 =#
MultiRegionCommunicationBoundaryCondition(val; kwargs...) = begin
        #= none:97 =#
        BoundaryCondition(MultiRegionCommunication(), val; kwargs...)
    end
#= none:98 =#
DistributedCommunicationBoundaryCondition(val; kwargs...) = begin
        #= none:98 =#
        BoundaryCondition(DistributedCommunication(), val; kwargs...)
    end
#= none:108 =#
#= none:108 =# @inline getbc(bc, args...) = begin
            #= none:108 =#
            bc.condition(args...)
        end
#= none:110 =#
#= none:110 =# @inline getbc(::BC{<:Open, Nothing}, ::Integer, ::Integer, grid::AbstractGrid, args...) = begin
            #= none:110 =#
            zero(grid)
        end
#= none:111 =#
#= none:111 =# @inline getbc(::BC{<:Flux, Nothing}, ::Integer, ::Integer, grid::AbstractGrid, args...) = begin
            #= none:111 =#
            zero(grid)
        end
#= none:112 =#
#= none:112 =# @inline getbc(::Nothing, ::Integer, ::Integer, grid::AbstractGrid, args...) = begin
            #= none:112 =#
            zero(grid)
        end
#= none:114 =#
#= none:114 =# @inline getbc(bc::BC{<:Any, <:Number}, args...) = begin
            #= none:114 =#
            bc.condition
        end
#= none:115 =#
#= none:115 =# @inline getbc(bc::BC{<:Any, <:AbstractArray}, i::Integer, j::Integer, grid::AbstractGrid, args...) = begin
            #= none:115 =#
            #= none:115 =# @inbounds bc.condition[i, j]
        end
#= none:118 =#
const NumberRef = Base.RefValue{<:Number}
#= none:119 =#
#= none:119 =# @inline getbc(bc::BC{<:Any, <:NumberRef}, args...) = begin
            #= none:119 =#
            bc.condition[]
        end
#= none:125 =#
validate_boundary_condition_topology(bc::Union{PBC, MCBC, Nothing}, topo::Grids.Periodic, side) = begin
        #= none:125 =#
        nothing
    end
#= none:126 =#
validate_boundary_condition_topology(bc, topo::Grids.Periodic, side) = begin
        #= none:126 =#
        throw(ArgumentError("Cannot set $(side) $(bc) in a `Periodic` direction!"))
    end
#= none:129 =#
validate_boundary_condition_topology(::Nothing, topo::Flat, side) = begin
        #= none:129 =#
        nothing
    end
#= none:130 =#
validate_boundary_condition_topology(bc, topo::Flat, side) = begin
        #= none:130 =#
        throw(ArgumentError("Cannot set $(side) $(bc) in a `Flat` direction!"))
    end
#= none:133 =#
validate_boundary_condition_topology(bc, topo, side) = begin
        #= none:133 =#
        nothing
    end
#= none:139 =#
validate_boundary_condition_architecture(bc, arch, side) = begin
        #= none:139 =#
        nothing
    end
#= none:141 =#
validate_boundary_condition_architecture(bc::BoundaryCondition, arch, side) = begin
        #= none:141 =#
        validate_boundary_condition_architecture(bc.condition, arch, bc, side)
    end
#= none:144 =#
validate_boundary_condition_architecture(condition, arch, bc, side) = begin
        #= none:144 =#
        nothing
    end
#= none:145 =#
validate_boundary_condition_architecture(::Array, ::CPU, bc, side) = begin
        #= none:145 =#
        nothing
    end
#= none:146 =#
validate_boundary_condition_architecture(::GPUArrays.AbstractGPUArray, ::GPU, bc, side) = begin
        #= none:146 =#
        nothing
    end
#= none:148 =#
validate_boundary_condition_architecture(::GPUArrays.AbstractGPUArray, ::CPU, bc, side) = begin
        #= none:148 =#
        throw(ArgumentError("$(side) $(bc) must use `Array` rather than `CuArray` on CPU architectures!"))
    end
#= none:151 =#
validate_boundary_condition_architecture(::Array, ::GPU, bc, side) = begin
        #= none:151 =#
        throw(ArgumentError("$(side) $(bc) must use `CuArray` rather than `Array` on GPU architectures!"))
    end