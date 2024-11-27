
#= none:1 =#
using Oceananigans.Fields: AbstractField, indices
#= none:3 =#
import Oceananigans.AbstractOperations: ConditionalOperation, evaluate_condition
#= none:4 =#
import Oceananigans.Fields: condition_operand, conditional_length
#= none:11 =#
#= none:11 =# @inline truefunc(args...) = begin
            #= none:11 =#
            true
        end
#= none:13 =#
struct NotImmersed{F} <: Function
    #= none:14 =#
    func::F
end
#= none:18 =#
const IF = AbstractField{<:Any, <:Any, <:Any, <:ImmersedBoundaryGrid}
#= none:20 =#
#= none:20 =# @inline condition_operand(func::Function, op::IF, cond, mask) = begin
            #= none:20 =#
            ConditionalOperation(op; func, condition = NotImmersed(cond), mask)
        end
#= none:21 =#
#= none:21 =# @inline condition_operand(func::Function, op::IF, ::Nothing, mask) = begin
            #= none:21 =#
            ConditionalOperation(op; func, condition = NotImmersed(truefunc), mask)
        end
#= none:22 =#
#= none:22 =# @inline condition_operand(func::typeof(identity), op::IF, ::Nothing, mask) = begin
            #= none:22 =#
            ConditionalOperation(op; func, condition = NotImmersed(truefunc), mask)
        end
#= none:24 =#
#= none:24 =# @inline function condition_operand(func::Function, op::IF, cond::AbstractArray, mask)
        #= none:24 =#
        #= none:25 =#
        arch = architecture(op.grid)
        #= none:26 =#
        arch_condition = on_architecture(arch, cond)
        #= none:27 =#
        ni_condition = NotImmersed(arch_condition)
        #= none:28 =#
        return ConditionalOperation(op; func, condition = ni_condition, mask)
    end
#= none:31 =#
#= none:31 =# @inline conditional_length(c::IF) = begin
            #= none:31 =#
            conditional_length(condition_operand(identity, c, nothing, 0))
        end
#= none:32 =#
#= none:32 =# @inline conditional_length(c::IF, dims) = begin
            #= none:32 =#
            conditional_length(condition_operand(identity, c, nothing, 0), dims)
        end
#= none:34 =#
#= none:34 =# @inline function evaluate_condition(condition::NotImmersed, i, j, k, ibg, co::ConditionalOperation, args...)
        #= none:34 =#
        #= none:35 =#
        (ℓx, ℓy, ℓz) = map(instantiate, location(co))
        #= none:36 =#
        immersed = immersed_peripheral_node(i, j, k, ibg, ℓx, ℓy, ℓz) | inactive_node(i, j, k, ibg, ℓx, ℓy, ℓz)
        #= none:37 =#
        return !immersed & evaluate_condition(condition.func, i, j, k, ibg, args...)
    end
#= none:44 =#
struct NotImmersedColumn{IC, F} <: Function
    #= none:45 =#
    immersed_column::IC
    #= none:46 =#
    func::F
end
#= none:49 =#
using Oceananigans.Fields: reduced_dimensions, OneField
#= none:50 =#
using Oceananigans.AbstractOperations: ConditionalOperation
#= none:53 =#
const XIRF = AbstractField{Nothing, <:Any, <:Any, <:ImmersedBoundaryGrid}
#= none:54 =#
const YIRF = AbstractField{<:Any, Nothing, <:Any, <:ImmersedBoundaryGrid}
#= none:55 =#
const ZIRF = AbstractField{<:Any, <:Any, Nothing, <:ImmersedBoundaryGrid}
#= none:57 =#
const YZIRF = AbstractField{<:Any, Nothing, Nothing, <:ImmersedBoundaryGrid}
#= none:58 =#
const XZIRF = AbstractField{Nothing, <:Any, Nothing, <:ImmersedBoundaryGrid}
#= none:59 =#
const XYIRF = AbstractField{Nothing, Nothing, <:Any, <:ImmersedBoundaryGrid}
#= none:61 =#
const XYZIRF = AbstractField{Nothing, Nothing, Nothing, <:ImmersedBoundaryGrid}
#= none:63 =#
const IRF = Union{XIRF, YIRF, ZIRF, YZIRF, XZIRF, XYIRF, XYZIRF}
#= none:65 =#
#= none:65 =# @inline condition_operand(func::Function, op::IRF, cond, mask) = begin
            #= none:65 =#
            ConditionalOperation(op; func, condition = NotImmersedColumn(immersed_column(op), cond), mask)
        end
#= none:66 =#
#= none:66 =# @inline condition_operand(func::Function, op::IRF, ::Nothing, mask) = begin
            #= none:66 =#
            ConditionalOperation(op; func, condition = NotImmersedColumn(immersed_column(op), truefunc), mask)
        end
#= none:67 =#
#= none:67 =# @inline condition_operand(func::typeof(identity), op::IRF, ::Nothing, mask) = begin
            #= none:67 =#
            ConditionalOperation(op; func, condition = NotImmersedColumn(immersed_column(op), truefunc), mask)
        end
#= none:69 =#
#= none:69 =# @inline function immersed_column(field::IRF)
        #= none:69 =#
        #= none:70 =#
        grid = field.grid
        #= none:71 =#
        reduced_dims = reduced_dimensions(field)
        #= none:72 =#
        (LX, LY, LZ) = map(center_to_nothing, location(field))
        #= none:73 =#
        one_field = ConditionalOperation{LX, LY, LZ}(OneField(Int), identity, grid, NotImmersed(truefunc), zero(grid))
        #= none:74 =#
        return sum(one_field, dims = reduced_dims)
    end
#= none:77 =#
#= none:77 =# @inline center_to_nothing(::Type{Face}) = begin
            #= none:77 =#
            Face
        end
#= none:78 =#
#= none:78 =# @inline center_to_nothing(::Type{Center}) = begin
            #= none:78 =#
            Center
        end
#= none:79 =#
#= none:79 =# @inline center_to_nothing(::Type{Nothing}) = begin
            #= none:79 =#
            Center
        end
#= none:81 =#
#= none:81 =# @inline function evaluate_condition(condition::NotImmersedColumn, i, j, k, ibg, co::ConditionalOperation, args...)
        #= none:81 =#
        #= none:82 =#
        (LX, LY, LZ) = location(co)
        #= none:83 =#
        return evaluate_condition(condition.func, i, j, k, ibg, args...) & !(is_immersed_column(i, j, k, condition.immersed_column))
    end
#= none:86 =#
#= none:86 =# @inline is_immersed_column(i, j, k, column) = begin
            #= none:86 =#
            #= none:86 =# @inbounds column[i, j, k] == 0
        end