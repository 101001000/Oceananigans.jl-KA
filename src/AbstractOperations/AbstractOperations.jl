
#= none:1 =#
module AbstractOperations
#= none:1 =#
#= none:3 =#
export ∂x, ∂y, ∂z, @at, @unary, @binary, @multiary
#= none:4 =#
export Δx, Δy, Δz, Ax, Ay, Az, volume
#= none:5 =#
export Average, Integral, CumulativeIntegral, KernelFunctionOperation
#= none:6 =#
export UnaryOperation, Derivative, BinaryOperation, MultiaryOperation, ConditionalOperation
#= none:8 =#
using Base: @propagate_inbounds
#= none:10 =#
import Adapt
#= none:11 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:13 =#
using Oceananigans
#= none:14 =#
using Oceananigans.Architectures
#= none:15 =#
using Oceananigans.Grids
#= none:16 =#
using Oceananigans.Operators
#= none:17 =#
using Oceananigans.BoundaryConditions
#= none:18 =#
using Oceananigans.Fields
#= none:19 =#
using Oceananigans.Utils
#= none:21 =#
using Oceananigans.Operators: interpolation_operator
#= none:22 =#
using Oceananigans.Architectures: device
#= none:23 =#
using Oceananigans: AbstractModel
#= none:25 =#
import Oceananigans.Architectures: architecture, on_architecture
#= none:26 =#
import Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:27 =#
import Oceananigans.Fields: compute_at!, indices
#= none:33 =#
abstract type AbstractOperation{LX, LY, LZ, G, T} <: AbstractField{LX, LY, LZ, G, T, 3} end
#= none:35 =#
const AF = AbstractField
#= none:38 =#
#= none:38 =# @inline fill_halo_regions!(::AbstractOperation, args...; kwargs...) = begin
            #= none:38 =#
            nothing
        end
#= none:40 =#
architecture(a::AbstractOperation) = begin
        #= none:40 =#
        architecture(a.grid)
    end
#= none:43 =#
const operators = Set()
#= none:45 =#
#= none:45 =# Core.@doc "    at(loc, abstract_operation)\n\nReturn `abstract_operation` relocated to `loc`ation.\n" at(loc, f) = begin
            #= none:50 =#
            f
        end
#= none:52 =#
include("grid_validation.jl")
#= none:53 =#
include("grid_metrics.jl")
#= none:54 =#
include("metric_field_reductions.jl")
#= none:55 =#
include("unary_operations.jl")
#= none:56 =#
include("binary_operations.jl")
#= none:57 =#
include("multiary_operations.jl")
#= none:58 =#
include("derivatives.jl")
#= none:59 =#
include("constant_field_abstract_operations.jl")
#= none:60 =#
include("kernel_function_operation.jl")
#= none:61 =#
include("conditional_operations.jl")
#= none:62 =#
include("computed_field.jl")
#= none:63 =#
include("at.jl")
#= none:64 =#
include("broadcasting_abstract_operations.jl")
#= none:65 =#
include("show_abstract_operations.jl")
#= none:70 =#
import Base: sqrt, sin, cos, exp, tanh, abs, -, +, /, ^, *
#= none:71 =#
import Base: abs
#= none:73 =#
#= none:73 =# @unary sqrt sin cos exp tanh abs
#= none:74 =#
#= none:74 =# @unary -
#= none:75 =#
#= none:75 =# @unary +
#= none:77 =#
#= none:77 =# @binary +
#= none:78 =#
#= none:78 =# @binary -
#= none:79 =#
#= none:79 =# @binary /
#= none:80 =#
#= none:80 =# @binary ^
#= none:82 =#
#= none:82 =# @multiary +
#= none:86 =#
import Base: *
#= none:88 =#
eval(define_binary_operator(:*))
#= none:89 =#
push!(operators, :*)
#= none:90 =#
push!(binary_operators, :*)
#= none:92 =#
eval(define_multiary_operator(:*))
#= none:93 =#
push!(operators, :*)
#= none:94 =#
push!(multiary_operators, :*)
end