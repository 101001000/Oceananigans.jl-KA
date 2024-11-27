
#= none:1 =#
module Architectures
#= none:1 =#
#= none:3 =#
export AbstractArchitecture, AbstractSerialArchitecture
#= none:4 =#
export CPU, GPU
#= none:5 =#
export device, architecture, unified_array, device_copy_to!
#= none:6 =#
export array_type, on_architecture, arch_array
#= none:8 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:9 =#
using KernelAbstractions
#= none:10 =#
using Adapt
#= none:11 =#
using OffsetArrays
#= none:13 =#
#= none:13 =# Core.@doc "    AbstractArchitecture\n\nAbstract supertype for architectures supported by Oceananigans.\n" abstract type AbstractArchitecture end
#= none:20 =#
#= none:20 =# Core.@doc "    AbstractSerialArchitecture\n\nAbstract supertype for serial architectures supported by Oceananigans.\n" abstract type AbstractSerialArchitecture <: AbstractArchitecture end
#= none:27 =#
#= none:27 =# Core.@doc "    CPU <: AbstractArchitecture\n\nRun Oceananigans on one CPU node. Uses multiple threads if the environment\nvariable `JULIA_NUM_THREADS` is set.\n" struct CPU <: AbstractSerialArchitecture
        #= none:33 =#
    end
#= none:35 =#
#= none:35 =# Core.@doc "    GPU <: AbstractArchitecture\n\nRun Oceananigans on a single NVIDIA CUDA GPU.\n" struct GPU <: AbstractSerialArchitecture
        #= none:40 =#
    end
#= none:46 =#
device(::CPU) = begin
        #= none:46 =#
        KernelAbstractions.CPU()
    end
#= none:47 =#
device(::GPU) = KAUtils.get_backend()
#= none:49 =#
architecture() = begin
        #= none:49 =#
        nothing
    end
#= none:50 =#
architecture(::Number) = begin
        #= none:50 =#
        nothing
    end
#= none:51 =#
architecture(::Array) = begin
        #= none:51 =#
        CPU()
    end
#= none:52 =#
architecture(::GPUArrays.AbstractGPUArray) = begin
        #= none:52 =#
        GPU()
    end
#= none:53 =#
architecture(a::SubArray) = begin
        #= none:53 =#
        architecture(parent(a))
    end
#= none:54 =#
architecture(a::OffsetArray) = begin
        #= none:54 =#
        architecture(parent(a))
    end
#= none:56 =#
#= none:56 =# Core.@doc "    child_architecture(arch)\n\nReturn `arch`itecture of child processes.\nOn single-process, non-distributed systems, return `arch`.\n" child_architecture(arch::AbstractSerialArchitecture) = begin
            #= none:62 =#
            arch
        end
#= none:64 =#
array_type(::CPU) = begin
        #= none:64 =#
        Array
    end
#= none:65 =#
array_type(::GPU) = GPUArrays.AbstractGPUArray
#= none:68 =#
on_architecture(arch, a) = begin
        #= none:68 =#
        a
    end
#= none:71 =#
on_architecture(arch::AbstractSerialArchitecture, t::Tuple) = begin
        #= none:71 =#
        Tuple((on_architecture(arch, elem) for elem = t))
    end
#= none:72 =#
on_architecture(arch::AbstractSerialArchitecture, nt::NamedTuple) = begin
        #= none:72 =#
        NamedTuple{keys(nt)}(on_architecture(arch, Tuple(nt)))
    end
#= none:75 =#
on_architecture(::CPU, a::Array) = begin
        #= none:75 =#
        a
    end
#= none:76 =#
on_architecture(::GPU, a::Array) = KAUtils.ArrayConstructor(KAUtils.get_backend(), a)
#= none:78 =#
on_architecture(::CPU, a::GPUArrays.AbstractGPUArray) = begin
        #= none:78 =#
        Array(a)
    end
#= none:79 =#
on_architecture(::GPU, a::GPUArrays.AbstractGPUArray) = begin
        #= none:79 =#
        a
    end
#= none:81 =#
on_architecture(::CPU, a::BitArray) = begin
        #= none:81 =#
        a
    end
#= none:82 =#
on_architecture(::GPU, a::BitArray) = KAUtils.ArrayConstructor(KAUtils.get_backend(), a)
#= none:84 =#
on_architecture(::CPU, a::SubArray{<:Any, <:Any, <:GPUArrays.AbstractGPUArray}) = begin
        #= none:84 =#
        Array(a)
    end
#= none:85 =#
on_architecture(::GPU, a::SubArray{<:Any, <:Any, <:GPUArrays.AbstractGPUArray}) = begin
        #= none:85 =#
        a
    end
#= none:87 =#
on_architecture(::CPU, a::SubArray{<:Any, <:Any, <:Array}) = begin
        #= none:87 =#
        a
    end
#= none:88 =#
on_architecture(::GPU, a::SubArray{<:Any, <:Any, <:Array}) = KAUtils.ArrayConstructor(KAUtils.get_backend(), a)
#= none:90 =#
on_architecture(arch::AbstractSerialArchitecture, a::OffsetArray) = begin
        #= none:90 =#
        OffsetArray(on_architecture(arch, a.parent), a.offsets...)
    end
#= none:92 =#
cpu_architecture(::CPU) = begin
        #= none:92 =#
        CPU()
    end
#= none:93 =#
cpu_architecture(::GPU) = begin
        #= none:93 =#
        CPU()
    end
#= none:95 =#
unified_array(::CPU, a) = begin
        #= none:95 =#
        a
    end
#= none:96 =#
unified_array(::GPU, a) = begin
        #= none:96 =#
        a
    end
#= none:99 =#
unified_array(::GPU, a::AbstractArray) = begin
        #= none:99 =#
        map(eltype(a), CUDA.cu(a; unified = true))
    end
#= none:102 =#
#= none:102 =# @inline function device_copy_to!(dst::GPUArrays.AbstractGPUArray, src::GPUArrays.AbstractGPUArray; async::Bool = false)
        #= none:102 =#
        #= none:103 =#
        n = length(src)
        #= none:104 =#
        CUDA.context!(CUDA.context(src)) do 
            #= none:105 =#
            #= none:105 =# GC.@preserve src dst begin
                    #= none:106 =#
                    unsafe_copyto!(pointer(dst, 1), pointer(src, 1), n; async)
                end
        end
        #= none:109 =#
        return dst
    end
#= none:112 =#
#= none:112 =# @inline device_copy_to!(dst::Array, src::Array; kw...) = begin
            #= none:112 =#
            Base.copyto!(dst, src)
        end
#= none:114 =#
#= none:114 =# @inline unsafe_free!(a::GPUArrays.AbstractGPUArray) = begin
            #= none:114 =#
            CUDA.unsafe_free!(a)
        end
#= none:115 =#
#= none:115 =# @inline unsafe_free!(a) = begin
            #= none:115 =#
            nothing
        end
#= none:118 =#
#= none:118 =# @inline convert_args(::CPU, args) = begin
            #= none:118 =#
            args
        end
#= none:119 =#
#= none:119 =# @inline convert_args(::GPU, args) = begin
            #= none:119 =#
            CUDA.cudaconvert(args)
        end
#= none:120 =#
#= none:120 =# @inline convert_args(::GPU, args::Tuple) = begin
            #= none:120 =#
            map(CUDA.cudaconvert, args)
        end
#= none:123 =#
function arch_array(arch, arr)
    #= none:123 =#
    #= none:124 =#
    #= none:124 =# @warn "`arch_array` is deprecated. Use `on_architecture` instead."
    #= none:125 =#
    return on_architecture(arch, arr)
end
end