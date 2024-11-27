
#= none:1 =#
using Oceananigans.AbstractOperations: AbstractOperation
#= none:2 =#
using Oceananigans.Fields: AbstractField, FunctionField
#= none:5 =#
const CubedSphereField{LX, LY, LZ} = Union{Field{LX, LY, LZ, <:Nothing, <:ConformalCubedSphereGrid}, Field{LX, LY, LZ, <:AbstractOperation, <:ConformalCubedSphereGrid}}
#= none:9 =#
const CubedSphereFunctionField{LX, LY, LZ} = FunctionField{LX, LY, LZ, <:Any, <:Any, <:Any, <:ConformalCubedSphereGrid}
#= none:12 =#
const CubedSphereAbstractField{LX, LY, LZ} = AbstractField{LX, LY, LZ, <:ConformalCubedSphereGrid}
#= none:15 =#
const AbstractCubedSphereField{LX, LY, LZ} = Union{CubedSphereAbstractField{LX, LY, LZ}, CubedSphereField{LX, LY, LZ}}
#= none:19 =#
(Base.summary(::AbstractCubedSphereField{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:19 =#
        "CubedSphereField{$(LX), $(LY), $(LZ)}"
    end