
#= none:1 =#
using Oceananigans.AbstractOperations: UnaryOperation, BinaryOperation, MultiaryOperation, Derivative, KernelFunctionOperation, ConditionalOperation
#= none:4 =#
const MultiRegionUnaryOperation{LX, LY, LZ, O, A, I} = (UnaryOperation{LX, LY, LZ, O, A, I, <:MultiRegionGrids} where {LX, LY, LZ, O, A, I})
#= none:5 =#
const MultiRegionBinaryOperation{LX, LY, LZ, O, A, B, IA, IB} = (BinaryOperation{LX, LY, LZ, O, A, B, IA, IB, <:MultiRegionGrids} where {LX, LY, LZ, O, A, B, IA, IB})
#= none:6 =#
const MultiRegionMultiaryOperation{LX, LY, LZ, N, O, A, I} = (MultiaryOperation{LX, LY, LZ, N, O, A, I, <:MultiRegionGrids} where {LX, LY, LZ, N, O, A, I})
#= none:7 =#
const MultiRegionDerivative{LX, LY, LZ, D, A, IN, AD} = (Derivative{LX, LY, LZ, D, A, IN, AD, <:MultiRegionGrids} where {LX, LY, LZ, D, A, IN, AD})
#= none:8 =#
const MultiRegionKernelFunctionOperation{LX, LY, LZ} = (KernelFunctionOperation{LX, LY, LZ, <:MultiRegionGrids} where {LX, LY, LZ, P})
#= none:9 =#
const MultiRegionConditionalOperation{LX, LY, LZ, O, F} = (ConditionalOperation{LX, LY, LZ, O, F, <:MultiRegionGrids} where {LX, LY, LZ, O, F})
#= none:11 =#
const MultiRegionAbstractOperation = Union{MultiRegionBinaryOperation, MultiRegionUnaryOperation, MultiRegionMultiaryOperation, MultiRegionDerivative, MultiRegionKernelFunctionOperation, MultiRegionConditionalOperation}
#= none:18 =#
Base.size(f::MultiRegionAbstractOperation) = begin
        #= none:18 =#
        size(getregion(f.grid, 1))
    end
#= none:20 =#
#= none:20 =# @inline isregional(f::MultiRegionAbstractOperation) = begin
            #= none:20 =#
            true
        end
#= none:21 =#
#= none:21 =# @inline devices(f::MultiRegionAbstractOperation) = begin
            #= none:21 =#
            devices(f.grid)
        end
#= none:22 =#
sync_all_devices!(f::MultiRegionAbstractOperation) = begin
        #= none:22 =#
        sync_all_devices!(devices(f.grid))
    end
#= none:24 =#
#= none:24 =# @inline switch_device!(f::MultiRegionAbstractOperation, d) = begin
            #= none:24 =#
            switch_device!(f.grid, d)
        end
#= none:25 =#
#= none:25 =# @inline getdevice(f::MultiRegionAbstractOperation, d) = begin
            #= none:25 =#
            getdevice(f.grid, d)
        end
#= none:27 =#
for T = [:BinaryOperation, :UnaryOperation, :MultiaryOperation, :Derivative, :ConditionalOperation]
    #= none:28 =#
    #= none:28 =# @eval begin
            #= none:29 =#
            #= none:29 =# @inline (getregion(f::$T{LX, LY, LZ}, r) where {LX, LY, LZ}) = begin
                        #= none:29 =#
                        $T{LX, LY, LZ}(Tuple((_getregion(getproperty(f, n), r) for n = fieldnames($T)))...)
                    end
            #= none:32 =#
            #= none:32 =# @inline (_getregion(f::$T{LX, LY, LZ}, r) where {LX, LY, LZ}) = begin
                        #= none:32 =#
                        $T{LX, LY, LZ}(Tuple((getregion(getproperty(f, n), r) for n = fieldnames($T)))...)
                    end
        end
    #= none:35 =#
end
#= none:37 =#
#= none:37 =# @inline (getregion(κ::KernelFunctionOperation{LX, LY, LZ}, r) where {LX, LY, LZ}) = begin
            #= none:37 =#
            KernelFunctionOperation{LX, LY, LZ}(_getregion(κ.kernel_function, r), _getregion(κ.grid, r), _getregion(κ.arguments, r)...)
        end
#= none:42 =#
#= none:42 =# @inline (_getregion(κ::KernelFunctionOperation{LX, LY, LZ}, r) where {LX, LY, LZ}) = begin
            #= none:42 =#
            KernelFunctionOperation{LX, LY, LZ}(getregion(κ.kernel_function, r), getregion(κ.grid, r), getregion(κ.arguments, r)...)
        end