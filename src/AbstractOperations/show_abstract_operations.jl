
#= none:1 =#
import Oceananigans: summary
#= none:2 =#
using Oceananigans.Fields: show_location
#= none:4 =#
for op_string = ("UnaryOperation", "BinaryOperation", "MultiaryOperation", "Derivative", "KernelFunctionOperation")
    #= none:5 =#
    op = eval(Symbol(op_string))
    #= none:6 =#
    #= none:6 =# @eval begin
            #= none:7 =#
            operation_name(::$op) = begin
                    #= none:7 =#
                    $op_string
                end
        end
    #= none:9 =#
end
#= none:11 =#
operation_name(op::GridMetricOperation) = begin
        #= none:11 =#
        string(op.metric)
    end
#= none:13 =#
function show_interp(op)
    #= none:13 =#
    #= none:14 =#
    op_str = string(op)
    #= none:15 =#
    if length(op_str) >= 8 && op_str[1:8] == "identity"
        #= none:16 =#
        return "identity"
    else
        #= none:18 =#
        return op_str
    end
end
#= none:22 =#
Base.summary(operation::AbstractOperation) = begin
        #= none:22 =#
        string(operation_name(operation), " at ", show_location(operation))
    end
#= none:24 =#
Base.show(io::IO, operation::AbstractOperation) = begin
        #= none:24 =#
        print(io, summary(operation), "\n", "├── grid: ", summary(operation.grid), "\n", "└── tree: ", "\n", "    ", tree_show(operation, 1, 0))
    end
#= none:30 =#
#= none:30 =# Core.@doc "Return a representation of number or function leaf within a tree visualization of an `AbstractOperation`." tree_show(a::Union{Number, Function}, depth, nesting) = begin
            #= none:31 =#
            string(a)
        end
#= none:33 =#
#= none:33 =# Core.@doc "Fallback for displaying a leaf within a tree visualization of an `AbstractOperation`." tree_show(a, depth, nesting) = begin
            #= none:34 =#
            summary(a)
        end
#= none:36 =#
#= none:36 =# Core.@doc "Returns a string corresponding to padding characters for a tree visualization of an `AbstractOperation`." get_tree_padding(depth, nesting) = begin
            #= none:37 =#
            "    " ^ (depth - nesting) * "│   " ^ nesting
        end
#= none:39 =#
#= none:39 =# Core.@doc "Return a string representaion of a `UnaryOperation` leaf within a tree visualization of an `AbstractOperation`." function tree_show(unary::UnaryOperation, depth, nesting)
        #= none:40 =#
        #= none:41 =#
        padding = get_tree_padding(depth, nesting)
        #= none:42 =#
        (LX, LY, LZ) = location(unary)
        #= none:44 =#
        return string(unary.op, " at ", show_location(LX, LY, LZ), " via ", show_interp(unary.▶), "\n", padding, "└── ", tree_show(unary.arg, depth + 1, nesting))
    end
#= none:48 =#
#= none:48 =# Core.@doc "Return a string representaion of a `BinaryOperation` leaf within a tree visualization of an `AbstractOperation`." function tree_show(binary::BinaryOperation, depth, nesting)
        #= none:49 =#
        #= none:50 =#
        padding = get_tree_padding(depth, nesting)
        #= none:51 =#
        (LX, LY, LZ) = location(binary)
        #= none:53 =#
        return string(binary.op, " at ", show_location(LX, LY, LZ), "\n", padding, "├── ", tree_show(binary.a, depth + 1, nesting + 1), "\n", padding, "└── ", tree_show(binary.b, depth + 1, nesting))
    end
#= none:58 =#
#= none:58 =# Core.@doc "Return a string representaion of a `MultiaryOperation` leaf within a tree visualization of an `AbstractOperation`." function tree_show(multiary::MultiaryOperation, depth, nesting)
        #= none:59 =#
        #= none:60 =#
        padding = get_tree_padding(depth, nesting)
        #= none:61 =#
        (LX, LY, LZ) = location(multiary)
        #= none:62 =#
        N = length(multiary.args)
        #= none:64 =#
        out = string(multiary.op, " at ", show_location(LX, LY, LZ), "\n", ntuple((i->begin
                            #= none:65 =#
                            padding * "├── " * tree_show(multiary.args[i], depth + 1, nesting + 1) * "\n"
                        end), Val(N - 1))..., padding * "└── " * tree_show(multiary.args[N], depth + 1, nesting))
        #= none:67 =#
        return out
    end
#= none:70 =#
#= none:70 =# Core.@doc "Return a string representaion of a `Derivative` leaf within a tree visualization of an `AbstractOperation`." function tree_show(deriv::Derivative, depth, nesting)
        #= none:71 =#
        #= none:72 =#
        padding = get_tree_padding(depth, nesting)
        #= none:73 =#
        (LX, LY, LZ) = location(deriv)
        #= none:75 =#
        return string(deriv.∂, " at ", show_location(LX, LY, LZ), " via ", show_interp(deriv.▶), "\n", padding, "└── ", tree_show(deriv.arg, depth + 1, nesting))
    end