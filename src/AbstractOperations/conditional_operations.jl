
#= none:1 =#
using Oceananigans.Fields: OneField
#= none:2 =#
using Oceananigans.Grids: architecture
#= none:4 =#
import Oceananigans.Architectures: on_architecture
#= none:5 =#
import Oceananigans.Fields: condition_operand, conditional_length, set!, compute_at!, indices
#= none:8 =#
struct ConditionalOperation{LX, LY, LZ, O, F, G, C, M, T} <: AbstractOperation{LX, LY, LZ, G, T}
    #= none:9 =#
    operand::O
    #= none:10 =#
    func::F
    #= none:11 =#
    grid::G
    #= none:12 =#
    condition::C
    #= none:13 =#
    mask::M
    #= none:15 =#
    function ConditionalOperation{LX, LY, LZ}(operand::O, func::F, grid::G, condition::C, mask::M) where {LX, LY, LZ, O, F, G, C, M}
        #= none:15 =#
        #= none:17 =#
        T = eltype(operand)
        #= none:18 =#
        return new{LX, LY, LZ, O, F, G, C, M, T}(operand, func, grid, condition, mask)
    end
end
#= none:22 =#
#= none:22 =# Core.@doc "    ConditionalOperation(operand::AbstractField;\n                         func = identity,\n                         condition = nothing,\n                         mask = 0)\n\nReturn an abstract representation of a masking procedure applied when `condition` is satisfied on a field\ndescribed by `func(operand)`.\n\nPositional arguments\n====================\n\n- `operand`: The `AbstractField` to be masked (it must have a `grid` property!)\n\nKeyword arguments\n=================\n\n- `func`: A unary transformation applied element-wise to the field `operand` at locations where\n          `condition == true`. Default is `identity`.\n\n- `condition`: either a function of `(i, j, k, grid, operand)` returning a Boolean,\n               or a 3-dimensional Boolean `AbstractArray`. At locations where `condition == false`,\n               operand will be masked by `mask`\n\n- `mask`: the scalar mask\n\n`condition_operand` is a convenience function used to construct a `ConditionalOperation`\n\n`condition_operand(func::Function, operand::AbstractField, condition, mask) = ConditionalOperation(operand; func, condition, mask)`\n\nExample\n=======\n\n```jldoctest\njulia> using Oceananigans\n\njulia> using Oceananigans.Fields: condition_operand\n\njulia> c = CenterField(RectilinearGrid(size=(2, 1, 1), extent=(1, 1, 1)));\n\njulia> add_2(c) = c + 2\nadd_2 (generic function with 1 method)\n\njulia> f(i, j, k, grid, c) = i < 2; d = condition_operand(add_2, c, f, 10.0)\nConditionalOperation at (Center, Center, Center)\n├── operand: 2×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n├── grid: 2×1×1 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 2×1×1 halo\n├── func: add_2 (generic function with 1 method)\n├── condition: f (generic function with 1 method)\n└── mask: 10.0\n\njulia> d[1, 1, 1]\n2.0\n\njulia> d[2, 1, 1]\n10.0\n```\n" function ConditionalOperation(operand::AbstractField; func = identity, condition = nothing, mask = zero(eltype(operand)))
        #= none:80 =#
        #= none:85 =#
        (LX, LY, LZ) = location(operand)
        #= none:86 =#
        return ConditionalOperation{LX, LY, LZ}(operand, func, operand.grid, condition, mask)
    end
#= none:89 =#
function ConditionalOperation(c::ConditionalOperation; func = c.func, condition = c.condition, mask = c.mask)
    #= none:89 =#
    #= none:94 =#
    (LX, LY, LZ) = location(c)
    #= none:95 =#
    return ConditionalOperation{LX, LY, LZ}(c.operand, func, c.grid, condition, mask)
end
#= none:98 =#
struct TrueCondition
    #= none:98 =#
end
#= none:100 =#
#= none:100 =# @inline function Base.getindex(c::ConditionalOperation, i, j, k)
        #= none:100 =#
        #= none:101 =#
        return ifelse(evaluate_condition(c.condition, i, j, k, c.grid, c), c.func(getindex(c.operand, i, j, k)), c.mask)
    end
#= none:106 =#
#= none:106 =# @inline evaluate_condition(condition, i, j, k, grid, args...) = begin
            #= none:106 =#
            condition(i, j, k, grid, args...)
        end
#= none:107 =#
#= none:107 =# @inline evaluate_condition(::TrueCondition, i, j, k, grid, args...) = begin
            #= none:107 =#
            true
        end
#= none:108 =#
#= none:108 =# @inline evaluate_condition(condition::AbstractArray, i, j, k, grid, args...) = begin
            #= none:108 =#
            #= none:108 =# @inbounds condition[i, j, k]
        end
#= none:110 =#
#= none:110 =# @inline condition_operand(func::Function, op::AbstractField, condition, mask) = begin
            #= none:110 =#
            ConditionalOperation(op; func, condition, mask)
        end
#= none:111 =#
#= none:111 =# @inline condition_operand(func::Function, op::AbstractField, ::Nothing, mask) = begin
            #= none:111 =#
            ConditionalOperation(op; func, condition = TrueCondition(), mask)
        end
#= none:113 =#
#= none:113 =# @inline function condition_operand(func::Function, operand::AbstractField, condition::AbstractArray, mask)
        #= none:113 =#
        #= none:114 =#
        condition = on_architecture(architecture(operand.grid), condition)
        #= none:115 =#
        return ConditionalOperation(operand; func, condition, mask)
    end
#= none:118 =#
#= none:118 =# @inline condition_operand(func::typeof(identity), c::ConditionalOperation, ::Nothing, mask) = begin
            #= none:118 =#
            ConditionalOperation(c; mask)
        end
#= none:119 =#
#= none:119 =# @inline condition_operand(func::Function, c::ConditionalOperation, ::Nothing, mask) = begin
            #= none:119 =#
            ConditionalOperation(c; func, mask)
        end
#= none:121 =#
#= none:121 =# @inline materialize_condition!(c::ConditionalOperation) = begin
            #= none:121 =#
            set!(c.operand, c)
        end
#= none:123 =#
function materialize_condition(c::ConditionalOperation)
    #= none:123 =#
    #= none:124 =#
    f = similar(c.operand)
    #= none:125 =#
    set!(f, c)
    #= none:126 =#
    return f
end
#= none:129 =#
#= none:129 =# @inline (condition_onefield(c::ConditionalOperation{LX, LY, LZ}, mask) where {LX, LY, LZ}) = begin
            #= none:129 =#
            ConditionalOperation{LX, LY, LZ}(OneField(Int), identity, c.grid, c.condition, mask)
        end
#= none:132 =#
#= none:132 =# @inline conditional_length(c::ConditionalOperation) = begin
            #= none:132 =#
            sum(condition_onefield(c, 0))
        end
#= none:133 =#
#= none:133 =# @inline conditional_length(c::ConditionalOperation, dims) = begin
            #= none:133 =#
            sum(condition_onefield(c, 0); dims = dims)
        end
#= none:135 =#
(Adapt.adapt_structure(to, c::ConditionalOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:135 =#
        ConditionalOperation{LX, LY, LZ}(adapt(to, c.operand), adapt(to, c.func), adapt(to, c.grid), adapt(to, c.condition), adapt(to, c.mask))
    end
#= none:142 =#
(on_architecture(to, c::ConditionalOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:142 =#
        ConditionalOperation{LX, LY, LZ}(on_architecture(to, c.operand), on_architecture(to, c.func), on_architecture(to, c.grid), on_architecture(to, c.condition), on_architecture(to, c.mask))
    end
#= none:149 =#
Base.summary(c::ConditionalOperation) = begin
        #= none:149 =#
        string("ConditionalOperation of ", summary(c.operand), " with condition ", summary(c.condition))
    end
#= none:151 =#
compute_at!(c::ConditionalOperation, time) = begin
        #= none:151 =#
        compute_at!(c.operand, time)
    end
#= none:152 =#
indices(c::ConditionalOperation) = begin
        #= none:152 =#
        indices(c.operand)
    end
#= none:154 =#
Base.show(io::IO, operation::ConditionalOperation) = begin
        #= none:154 =#
        print(io, "ConditionalOperation at $(location(operation))", "\n", "├── operand: ", summary(operation.operand), "\n", "├── grid: ", summary(operation.grid), "\n", "├── func: ", summary(operation.func), "\n", "├── condition: ", summary(operation.condition), "\n", "└── mask: ", operation.mask)
    end