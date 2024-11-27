
#= none:1 =#
const multiary_operators = Set()
#= none:3 =#
struct MultiaryOperation{LX, LY, LZ, N, O, A, IN, G, T} <: AbstractOperation{LX, LY, LZ, G, T}
    #= none:4 =#
    op::O
    #= none:5 =#
    args::A
    #= none:6 =#
    ▶::IN
    #= none:7 =#
    grid::G
    #= none:9 =#
    function MultiaryOperation{LX, LY, LZ}(op::O, args::A, ▶::IN, grid::G) where {LX, LY, LZ, O, A, IN, G}
        #= none:9 =#
        #= none:10 =#
        T = eltype(grid)
        #= none:11 =#
        N = length(args)
        #= none:12 =#
        return new{LX, LY, LZ, N, O, A, IN, G, T}(op, args, ▶, grid)
    end
end
#= none:16 =#
#= none:16 =# @inline (Base.getindex(Π::MultiaryOperation{LX, LY, LZ, N}, i, j, k) where {LX, LY, LZ, N}) = begin
            #= none:16 =#
            Π.op(ntuple((γ->begin
                            #= none:17 =#
                            (Π.▶[γ])(i, j, k, Π.grid, Π.args[γ])
                        end), Val(N))...)
        end
#= none:23 =#
indices(Π::MultiaryOperation) = begin
        #= none:23 =#
        construct_regionally(intersect_indices, location(Π), Π.args...)
    end
#= none:25 =#
function _multiary_operation(L, op, args, Largs, grid)
    #= none:25 =#
    #= none:26 =#
    ▶ = Tuple((interpolation_operator(La, L) for La = Largs))
    #= none:27 =#
    return MultiaryOperation{L[1], L[2], L[3]}(op, Tuple((a for a = args)), ▶, grid)
end
#= none:31 =#
#= none:31 =# @inline at(loc, Π::MultiaryOperation) = begin
            #= none:31 =#
            Π.op(loc, Tuple((at(loc, a) for a = Π.args))...)
        end
#= none:33 =#
#= none:33 =# Core.@doc "Return an expression that defines an abstract `MultiaryOperator` named `op` for `AbstractField`." function define_multiary_operator(op)
        #= none:34 =#
        #= none:35 =#
        return quote
                #= none:36 =#
                function $op(Lop::Tuple, a::Union{Function, Number, Oceananigans.Fields.AbstractField}, b::Union{Function, Number, Oceananigans.Fields.AbstractField}, c::Union{Function, Number, Oceananigans.Fields.AbstractField}, d::Union{Function, Number, Oceananigans.Fields.AbstractField}...)
                    #= none:36 =#
                    #= none:42 =#
                    args = tuple(a, b, c, d...)
                    #= none:43 =#
                    grid = Oceananigans.AbstractOperations.validate_grid(args...)
                    #= none:46 =#
                    args = Tuple((Oceananigans.Fields.fieldify_function(Lop, a, grid) for a = args))
                    #= none:47 =#
                    Largs = Tuple((Oceananigans.Fields.location(a) for a = args))
                    #= none:49 =#
                    return Oceananigans.AbstractOperations._multiary_operation(Lop, $op, args, Largs, grid)
                end
                #= none:52 =#
                $op(a::Oceananigans.Fields.AbstractField, b::Union{Function, Oceananigans.Fields.AbstractField}, c::Union{Function, Oceananigans.Fields.AbstractField}, d::Union{Function, Oceananigans.Fields.AbstractField}...) = begin
                        #= none:52 =#
                        $op(Oceananigans.Fields.location(a), a, b, c, d...)
                    end
            end
    end
#= none:59 =#
#= none:59 =# Core.@doc "    @multiary op1 op2 op3...\n\nTurn each multiary operator in the list `(op1, op2, op3...)`\ninto a multiary operator on `Oceananigans.Fields` for use in `AbstractOperations`.\n\nNote that a multiary operator:\n  * is a function with two or more arguments: for example, `+(x, y, z)` is a multiary function;\n  * must be imported to be extended if part of `Base`: use `import Base: op; @multiary op`;\n  * can only be called on `Oceananigans.Field`s if the \"location\" is noted explicitly; see example.\n\nExample\n=======\n\n```jldoctest\njulia> using Oceananigans, Oceananigans.AbstractOperations\n\njulia> harmonic_plus(a, b, c) = 1/3 * (1/a + 1/b + 1/c)\nharmonic_plus (generic function with 1 method)\n\njulia> c, d, e = Tuple(CenterField(RectilinearGrid(size=(1, 1, 1), extent=(1, 1, 1))) for i = 1:3);\n\njulia> harmonic_plus(c, d, e) # before magic @multiary transformation\nBinaryOperation at (Center, Center, Center)\n├── grid: 1×1×1 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 1×1×1 halo\n└── tree:\n    * at (Center, Center, Center)\n    ├── 0.3333333333333333\n    └── + at (Center, Center, Center)\n        ├── / at (Center, Center, Center)\n        │   ├── 1\n        │   └── 1×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n        ├── / at (Center, Center, Center)\n        │   ├── 1\n        │   └── 1×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n        └── / at (Center, Center, Center)\n            ├── 1\n            └── 1×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n\njulia> @multiary harmonic_plus\nSet{Any} with 3 elements:\n  :+\n  :harmonic_plus\n  :*\n\njulia> harmonic_plus(c, d, e)\nMultiaryOperation at (Center, Center, Center)\n├── grid: 1×1×1 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 1×1×1 halo\n└── tree:\n    harmonic_plus at (Center, Center, Center)\n    ├── 1×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n    ├── 1×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n    └── 1×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n```\n" macro multiary(ops...)
        #= none:114 =#
        #= none:115 =#
        expr = Expr(:block)
        #= none:117 =#
        for op = ops
            #= none:118 =#
            defexpr = define_multiary_operator(op)
            #= none:119 =#
            push!(expr.args, :($(esc(defexpr))))
            #= none:121 =#
            add_to_operator_lists = quote
                    #= none:122 =#
                    push!(Oceananigans.AbstractOperations.operators, Symbol($op))
                    #= none:123 =#
                    push!(Oceananigans.AbstractOperations.multiary_operators, Symbol($op))
                end
            #= none:126 =#
            push!(expr.args, :($(esc(add_to_operator_lists))))
            #= none:127 =#
        end
        #= none:129 =#
        return expr
    end
#= none:136 =#
function compute_at!(Π::MultiaryOperation, time)
    #= none:136 =#
    #= none:137 =#
    for a = Π.args
        #= none:138 =#
        compute_at!(a, time)
        #= none:139 =#
    end
    #= none:140 =#
    return Π
end
#= none:147 =#
#= none:147 =# Core.@doc "Adapt `MultiaryOperation` to work on the GPU via CUDAnative and CUDAdrv." (Adapt.adapt_structure(to, multiary::MultiaryOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:148 =#
            MultiaryOperation{LX, LY, LZ}(Adapt.adapt(to, multiary.op), Adapt.adapt(to, multiary.args), Adapt.adapt(to, multiary.▶), Adapt.adapt(to, multiary.grid))
        end
#= none:154 =#
(on_architecture(to, multiary::MultiaryOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:154 =#
        MultiaryOperation{LX, LY, LZ}(on_architecture(to, multiary.op), on_architecture(to, multiary.args), on_architecture(to, multiary.▶), on_architecture(to, multiary.grid))
    end