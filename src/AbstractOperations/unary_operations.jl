
#= none:1 =#
const unary_operators = Set()
#= none:3 =#
struct UnaryOperation{LX, LY, LZ, O, A, IN, G, T} <: AbstractOperation{LX, LY, LZ, G, T}
    #= none:4 =#
    op::O
    #= none:5 =#
    arg::A
    #= none:6 =#
    ▶::IN
    #= none:7 =#
    grid::G
    #= none:9 =#
    #= none:9 =# @doc "    UnaryOperation{LX, LY, LZ}(op, arg, ▶, grid)\n\nReturns an abstract `UnaryOperation` representing the action of `op` on `arg`,\nand subsequent interpolation by `▶` on `grid`.\n" function UnaryOperation{LX, LY, LZ}(op::O, arg::A, ▶::IN, grid::G) where {LX, LY, LZ, O, A, IN, G}
            #= none:15 =#
            #= none:16 =#
            T = eltype(grid)
            #= none:17 =#
            return new{LX, LY, LZ, O, A, IN, G, T}(op, arg, ▶, grid)
        end
end
#= none:21 =#
#= none:21 =# @inline Base.getindex(υ::UnaryOperation, i, j, k) = begin
            #= none:21 =#
            υ.▶(i, j, k, υ.grid, υ.op, υ.arg)
        end
#= none:27 =#
indices(υ::UnaryOperation) = begin
        #= none:27 =#
        indices(υ.arg)
    end
#= none:29 =#
#= none:29 =# Core.@doc "Create a unary operation for `operator` acting on `arg` which interpolates the\nresult from `Larg` to `L`." function _unary_operation(L, operator, arg, Larg, grid)
        #= none:31 =#
        #= none:32 =#
        ▶ = interpolation_operator(Larg, L)
        #= none:33 =#
        return UnaryOperation{L[1], L[2], L[3]}(operator, arg, ▶, grid)
    end
#= none:37 =#
#= none:37 =# @inline at(loc, υ::UnaryOperation) = begin
            #= none:37 =#
            υ.op(loc, at(loc, υ.arg))
        end
#= none:39 =#
#= none:39 =# Core.@doc "    @unary op1 op2 op3...\n\nTurn each unary function in the list `(op1, op2, op3...)`\ninto a unary operator on `Oceananigans.Fields` for use in `AbstractOperations`.\n\nNote: a unary function is a function with one argument: for example, `sin(x)` is a unary function.\n\nAlso note: a unary function in `Base` must be imported to be extended: use `import Base: op; @unary op`.\n\nExample\n=======\n\n```jldoctest\njulia> using Oceananigans, Oceananigans.Grids, Oceananigans.AbstractOperations\n\njulia> square_it(x) = x^2\nsquare_it (generic function with 1 method)\n\njulia> @unary square_it\nSet{Any} with 10 elements:\n  :+\n  :sqrt\n  :square_it\n  :cos\n  :exp\n  :interpolate_identity\n  :-\n  :tanh\n  :sin\n  :abs\n\njulia> c = CenterField(RectilinearGrid(size=(1, 1, 1), extent=(1, 1, 1)));\n\njulia> square_it(c)\nUnaryOperation at (Center, Center, Center)\n├── grid: 1×1×1 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 1×1×1 halo\n└── tree:\n    square_it at (Center, Center, Center) via identity\n    └── 1×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n```\n" macro unary(ops...)
        #= none:81 =#
        #= none:82 =#
        expr = Expr(:block)
        #= none:84 =#
        for op = ops
            #= none:85 =#
            define_unary_operator = quote
                    #= none:86 =#
                    import Oceananigans.Grids: AbstractGrid
                    #= none:87 =#
                    import Oceananigans.Fields: AbstractField
                    #= none:89 =#
                    local location = Oceananigans.Fields.location
                    #= none:91 =#
                    #= none:91 =# @inline $op(i, j, k, grid::AbstractGrid, a) = begin
                                #= none:91 =#
                                #= none:91 =# @inbounds $op(a[i, j, k])
                            end
                    #= none:92 =#
                    #= none:92 =# @inline $op(i, j, k, grid::AbstractGrid, a::Number) = begin
                                #= none:92 =#
                                $op(a)
                            end
                    #= none:94 =#
                    #= none:94 =# Core.@doc "    $($op)(Lop::Tuple, a::AbstractField)\n\nReturns an abstract representation of the operator `$($op)` acting on the Oceananigans `Field`\n`a`, and subsequently interpolated to the location indicated by `Lop`.\n" function $op(Lop::Tuple, a::AbstractField)
                            #= none:100 =#
                            #= none:101 =#
                            L = location(a)
                            #= none:102 =#
                            return Oceananigans.AbstractOperations._unary_operation(Lop, $op, a, L, a.grid)
                        end
                    #= none:105 =#
                    $op(a::AbstractField) = begin
                            #= none:105 =#
                            $op(location(a), a)
                        end
                    #= none:107 =#
                    push!(Oceananigans.AbstractOperations.operators, Symbol($op))
                    #= none:108 =#
                    push!(Oceananigans.AbstractOperations.unary_operators, Symbol($op))
                end
            #= none:111 =#
            push!(expr.args, :($(esc(define_unary_operator))))
            #= none:112 =#
        end
        #= none:114 =#
        return expr
    end
#= none:121 =#
compute_at!(υ::UnaryOperation, time) = begin
        #= none:121 =#
        compute_at!(υ.arg, time)
    end
#= none:127 =#
#= none:127 =# Core.@doc "Adapt `UnaryOperation` to work on the GPU via CUDAnative and CUDAdrv." (Adapt.adapt_structure(to, unary::UnaryOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:128 =#
            UnaryOperation{LX, LY, LZ}(Adapt.adapt(to, unary.op), Adapt.adapt(to, unary.arg), Adapt.adapt(to, unary.▶), Adapt.adapt(to, unary.grid))
        end
#= none:134 =#
(on_architecture(to, unary::UnaryOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:134 =#
        UnaryOperation{LX, LY, LZ}(on_architecture(to, unary.op), on_architecture(to, unary.arg), on_architecture(to, unary.▶), on_architecture(to, unary.grid))
    end