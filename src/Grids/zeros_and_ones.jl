
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:2 =#
using Oceananigans.Architectures: CPU, GPU, AbstractArchitecture
#= none:4 =#
import Base: zeros
#= none:6 =#
zeros(FT, ::CPU, N...) = begin
        #= none:6 =#
        zeros(FT, N...)
    end
#= none:7 =#
zeros(FT, ::GPU, N...) = KAUtils.zeros(KAUtils.get_backend(), FT, N...)
#= none:9 =#
zeros(arch::AbstractArchitecture, grid, N...) = begin
        #= none:9 =#
        zeros(eltype(grid), arch, N...)
    end
#= none:10 =#
zeros(grid::AbstractGrid, N...) = begin
        #= none:10 =#
        zeros(eltype(grid), architecture(grid), N...)
    end
#= none:12 =#
#= none:12 =# @inline Base.zero(grid::AbstractGrid) = begin
            #= none:12 =#
            zero(eltype(grid))
        end
#= none:13 =#
#= none:13 =# @inline Base.one(grid::AbstractGrid) = begin
            #= none:13 =#
            one(eltype(grid))
        end