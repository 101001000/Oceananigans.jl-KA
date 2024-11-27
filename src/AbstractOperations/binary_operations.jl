
#= none:1 =#
const binary_operators = Set()
#= none:3 =#
struct BinaryOperation{LX, LY, LZ, O, A, B, IA, IB, G, T} <: AbstractOperation{LX, LY, LZ, G, T}
    #= none:4 =#
    op::O
    #= none:5 =#
    a::A
    #= none:6 =#
    b::B
    #= none:7 =#
    ▶a::IA
    #= none:8 =#
    ▶b::IB
    #= none:9 =#
    grid::G
    #= none:11 =#
    #= none:11 =# @doc "    BinaryOperation{LX, LY, LZ}(op, a, b, ▶a, ▶b, grid)\n\nReturn an abstract representation of the binary operation `op(▶a(a), ▶b(b))` on\n`grid`, where `▶a` and `▶b` interpolate `a` and `b` to locations `(LX, LY, LZ)`.\n" function BinaryOperation{LX, LY, LZ}(op::O, a::A, b::B, ▶a::IA, ▶b::IB, grid::G) where {LX, LY, LZ, O, A, B, IA, IB, G}
            #= none:17 =#
            #= none:18 =#
            T = eltype(grid)
            #= none:19 =#
            return new{LX, LY, LZ, O, A, B, IA, IB, G, T}(op, a, b, ▶a, ▶b, grid)
        end
end
#= none:23 =#
#= none:23 =# @inline Base.getindex(β::BinaryOperation, i, j, k) = begin
            #= none:23 =#
            β.op(i, j, k, β.grid, β.▶a, β.▶b, β.a, β.b)
        end
#= none:30 =#
#= none:30 =# @inline at(loc, β::BinaryOperation) = begin
            #= none:30 =#
            β.op(loc, at(loc, β.a), at(loc, β.b))
        end
#= none:32 =#
indices(β::BinaryOperation) = begin
        #= none:32 =#
        construct_regionally(intersect_indices, location(β), β.a, β.b)
    end
#= none:34 =#
#= none:34 =# Core.@doc "Create a binary operation for `op` acting on `a` and `b` at `Lc`, where\n`a` and `b` have location `La` and `Lb`." function _binary_operation(Lc, op, a, b, La, Lb, grid)
        #= none:36 =#
        #= none:37 =#
        ▶a = interpolation_operator(La, Lc)
        #= none:38 =#
        ▶b = interpolation_operator(Lb, Lc)
        #= none:40 =#
        return BinaryOperation{Lc[1], Lc[2], Lc[3]}(op, a, b, ▶a, ▶b, grid)
    end
#= none:43 =#
const ConcreteLocationType = Union{Type{Face}, Type{Center}}
#= none:46 =#
choose_location(La, Lb, Lc) = begin
        #= none:46 =#
        Lc
    end
#= none:47 =#
choose_location(::Type{Face}, ::Type{Face}, Lc) = begin
        #= none:47 =#
        Face
    end
#= none:48 =#
choose_location(::Type{Center}, ::Type{Center}, Lc) = begin
        #= none:48 =#
        Center
    end
#= none:49 =#
choose_location(La::ConcreteLocationType, ::Type{Nothing}, Lc) = begin
        #= none:49 =#
        La
    end
#= none:50 =#
choose_location(::Type{Nothing}, Lb::ConcreteLocationType, Lc) = begin
        #= none:50 =#
        Lb
    end
#= none:52 =#
#= none:52 =# Core.@doc "Return an expression that defines an abstract `BinaryOperator` named `op` for `AbstractField`." function define_binary_operator(op)
        #= none:53 =#
        #= none:54 =#
        return quote
                #= none:55 =#
                import Oceananigans.Grids: AbstractGrid
                #= none:56 =#
                import Oceananigans.Fields: AbstractField
                #= none:58 =#
                local location = Oceananigans.Fields.location
                #= none:59 =#
                local FunctionField = Oceananigans.Fields.FunctionField
                #= none:60 =#
                local ConstantField = Oceananigans.Fields.ConstantField
                #= none:61 =#
                local AF = AbstractField
                #= none:63 =#
                #= none:63 =# @inline $op(i, j, k, grid::AbstractGrid, ▶a, ▶b, a, b) = begin
                            #= none:63 =#
                            #= none:64 =# @inbounds $op(▶a(i, j, k, grid, a), ▶b(i, j, k, grid, b))
                        end
                #= none:68 =#
                #= none:68 =# @inline function $op(i, j, k, grid::AbstractGrid, ▶a, ▶b, A::BinaryOperation, B::BinaryOperation)
                        #= none:68 =#
                        #= none:69 =#
                        #= none:69 =# @inline a(ii, jj, kk, grid) = begin
                                    #= none:69 =#
                                    A.op(A.▶a(ii, jj, kk, grid, A.a), A.▶b(ii, jj, kk, grid, A.b))
                                end
                        #= none:70 =#
                        #= none:70 =# @inline b(ii, jj, kk, grid) = begin
                                    #= none:70 =#
                                    B.op(B.▶a(ii, jj, kk, grid, B.a), B.▶b(ii, jj, kk, grid, B.b))
                                end
                        #= none:71 =#
                        return #= none:71 =# @inbounds($op(▶a(i, j, k, grid, a), ▶b(i, j, k, grid, b)))
                    end
                #= none:74 =#
                #= none:74 =# @inline function $op(i, j, k, grid::AbstractGrid, ▶a, ▶b, A::BinaryOperation, B::AbstractField)
                        #= none:74 =#
                        #= none:75 =#
                        #= none:75 =# @inline a(ii, jj, kk, grid) = begin
                                    #= none:75 =#
                                    A.op(A.▶a(ii, jj, kk, grid, A.a), A.▶b(ii, jj, kk, grid, A.b))
                                end
                        #= none:76 =#
                        return #= none:76 =# @inbounds($op(▶a(i, j, k, grid, a), ▶b(i, j, k, grid, B)))
                    end
                #= none:79 =#
                #= none:79 =# @inline function $op(i, j, k, grid::AbstractGrid, ▶a, ▶b, A::AbstractField, B::BinaryOperation)
                        #= none:79 =#
                        #= none:80 =#
                        #= none:80 =# @inline b(ii, jj, kk, grid) = begin
                                    #= none:80 =#
                                    B.op(B.▶a(ii, jj, kk, grid, B.a), B.▶b(ii, jj, kk, grid, B.b))
                                end
                        #= none:81 =#
                        return #= none:81 =# @inbounds($op(▶a(i, j, k, grid, A), ▶b(i, j, k, grid, b)))
                    end
                #= none:84 =#
                #= none:84 =# @inline function $op(i, j, k, grid::AbstractGrid, ▶a, ▶b, A::BinaryOperation, B::Number)
                        #= none:84 =#
                        #= none:85 =#
                        #= none:85 =# @inline a(ii, jj, kk, grid) = begin
                                    #= none:85 =#
                                    A.op(A.▶a(ii, jj, kk, grid, A.a), A.▶b(ii, jj, kk, grid, A.b))
                                end
                        #= none:86 =#
                        return #= none:86 =# @inbounds($op(▶a(i, j, k, grid, a), B))
                    end
                #= none:89 =#
                #= none:89 =# @inline function $op(i, j, k, grid::AbstractGrid, ▶a, ▶b, A::Number, B::BinaryOperation)
                        #= none:89 =#
                        #= none:90 =#
                        #= none:90 =# @inline b(ii, jj, kk, grid) = begin
                                    #= none:90 =#
                                    B.op(B.▶a(ii, jj, kk, grid, B.a), B.▶b(ii, jj, kk, grid, B.b))
                                end
                        #= none:91 =#
                        return #= none:91 =# @inbounds($op(A, ▶b(i, j, k, grid, b)))
                    end
                #= none:94 =#
                #= none:94 =# Core.@doc "    $($op)(Lc, a, b)\n\nReturn an abstract representation of the operator `$($op)` acting on `a` and `b`.\nThe operation occurs at `location(a)` except for Nothing dimensions. In that case,\nthe location of the dimension in question is supplied either by `location(b)` or\nif that is also Nothing, `Lc`.\n" function $op(Lc::Tuple, a, b)
                        #= none:102 =#
                        #= none:103 =#
                        La = location(a)
                        #= none:104 =#
                        Lb = location(b)
                        #= none:105 =#
                        Lab = choose_location.(La, Lb, Lc)
                        #= none:107 =#
                        grid = Oceananigans.AbstractOperations.validate_grid(a, b)
                        #= none:109 =#
                        return Oceananigans.AbstractOperations._binary_operation(Lab, $op, a, b, La, Lb, grid)
                    end
                #= none:113 =#
                $op(Lc::Tuple, a::Number, b::Number) = begin
                        #= none:113 =#
                        $op(a, b)
                    end
                #= none:116 =#
                $op(Lc::Tuple, f::Function, b::AbstractField) = begin
                        #= none:116 =#
                        $op(Lc, FunctionField(location(b), f, b.grid), b)
                    end
                #= none:117 =#
                $op(Lc::Tuple, a::AbstractField, f::Function) = begin
                        #= none:117 =#
                        $op(Lc, a, FunctionField(location(a), f, a.grid))
                    end
                #= none:119 =#
                $op(Lc::Tuple, m::AbstractGridMetric, b::AbstractField) = begin
                        #= none:119 =#
                        $op(Lc, GridMetricOperation(location(b), m, b.grid), b)
                    end
                #= none:120 =#
                $op(Lc::Tuple, a::AbstractField, m::AbstractGridMetric) = begin
                        #= none:120 =#
                        $op(Lc, a, GridMetricOperation(location(a), m, a.grid))
                    end
                #= none:123 =#
                $op(a::AF, b::AF) = begin
                        #= none:123 =#
                        $op(location(a), a, b)
                    end
                #= none:124 =#
                $op(a::AF, b) = begin
                        #= none:124 =#
                        $op(location(a), a, b)
                    end
                #= none:125 =#
                $op(a, b::AF) = begin
                        #= none:125 =#
                        $op(location(b), a, b)
                    end
                #= none:127 =#
                $op(a::AF, b::Number) = begin
                        #= none:127 =#
                        $op(location(a), a, b)
                    end
                #= none:128 =#
                $op(a::Number, b::AF) = begin
                        #= none:128 =#
                        $op(location(b), a, b)
                    end
                #= none:130 =#
                $op(a::AF, b::ConstantField) = begin
                        #= none:130 =#
                        $op(location(a), a, b.constant)
                    end
                #= none:131 =#
                $op(a::ConstantField, b::AF) = begin
                        #= none:131 =#
                        $op(location(b), a.constant, b)
                    end
                #= none:133 =#
                $op(a::Number, b::ConstantField) = begin
                        #= none:133 =#
                        ConstantField($op(a, b.constant))
                    end
                #= none:134 =#
                $op(a::ConstantField, b::Number) = begin
                        #= none:134 =#
                        ConstantField($op(a.constant, b))
                    end
            end
    end
#= none:138 =#
#= none:138 =# Core.@doc "    @binary op1 op2 op3...\n\nTurn each binary function in the list `(op1, op2, op3...)`\ninto a binary operator on `Oceananigans.Fields` for use in `AbstractOperations`.\n\nNote: a binary function is a function with two arguments: for example, `+(x, y)` is a binary function.\n\nAlso note: a binary function in `Base` must be imported to be extended: use `import Base: op; @binary op`.\n\nExample\n=======\n\n```jldoctest\njulia> using Oceananigans, Oceananigans.AbstractOperations\n\njulia> using Oceananigans.AbstractOperations: BinaryOperation, AbstractGridMetric, choose_location\n\njulia> plus_or_times(x, y) = x < 0 ? x + y : x * y\nplus_or_times (generic function with 1 method)\n\njulia> @binary plus_or_times\nSet{Any} with 6 elements:\n  :+\n  :/\n  :^\n  :-\n  :*\n  :plus_or_times\n\njulia> c, d = (CenterField(RectilinearGrid(size=(1, 1, 1), extent=(1, 1, 1))) for i = 1:2);\n\njulia> plus_or_times(c, d)\nBinaryOperation at (Center, Center, Center)\n├── grid: 1×1×1 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 1×1×1 halo\n└── tree:\n    plus_or_times at (Center, Center, Center)\n    ├── 1×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n    └── 1×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n```\n" macro binary(ops...)
        #= none:179 =#
        #= none:180 =#
        expr = Expr(:block)
        #= none:182 =#
        for op = ops
            #= none:183 =#
            defexpr = define_binary_operator(op)
            #= none:184 =#
            push!(expr.args, :($(esc(defexpr))))
            #= none:186 =#
            add_to_operator_lists = quote
                    #= none:187 =#
                    push!(Oceananigans.AbstractOperations.operators, Symbol($op))
                    #= none:188 =#
                    push!(Oceananigans.AbstractOperations.binary_operators, Symbol($op))
                end
            #= none:191 =#
            push!(expr.args, :($(esc(add_to_operator_lists))))
            #= none:192 =#
        end
        #= none:194 =#
        return expr
    end
#= none:201 =#
function compute_at!(β::BinaryOperation, time)
    #= none:201 =#
    #= none:202 =#
    compute_at!(β.a, time)
    #= none:203 =#
    compute_at!(β.b, time)
    #= none:204 =#
    return nothing
end
#= none:211 =#
#= none:211 =# Core.@doc "Adapt `BinaryOperation` to work on the GPU via CUDAnative and CUDAdrv." (Adapt.adapt_structure(to, binary::BinaryOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:212 =#
            BinaryOperation{LX, LY, LZ}(Adapt.adapt(to, binary.op), Adapt.adapt(to, binary.a), Adapt.adapt(to, binary.b), Adapt.adapt(to, binary.▶a), Adapt.adapt(to, binary.▶b), Adapt.adapt(to, binary.grid))
        end
#= none:221 =#
(on_architecture(to, binary::BinaryOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:221 =#
        BinaryOperation{LX, LY, LZ}(on_architecture(to, binary.op), on_architecture(to, binary.a), on_architecture(to, binary.b), on_architecture(to, binary.▶a), on_architecture(to, binary.▶b), on_architecture(to, binary.grid))
    end