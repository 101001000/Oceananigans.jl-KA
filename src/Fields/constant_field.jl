
#= none:1 =#
using Oceananigans.Utils: prettysummary
#= none:3 =#
import Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:5 =#
struct ZeroField{T, N} <: AbstractField{Nothing, Nothing, Nothing, Nothing, T, N}
    #= none:5 =#
end
#= none:6 =#
struct OneField{T, N} <: AbstractField{Nothing, Nothing, Nothing, Nothing, T, N}
    #= none:6 =#
end
#= none:8 =#
ZeroField(T = Int) = begin
        #= none:8 =#
        ZeroField{T, 3}()
    end
#= none:9 =#
OneField(T = Int) = begin
        #= none:9 =#
        OneField{T, 3}()
    end
#= none:11 =#
#= none:11 =# @inline (Base.getindex(::ZeroField{T, N}, ind...) where {N, T}) = begin
            #= none:11 =#
            zero(T)
        end
#= none:12 =#
#= none:12 =# @inline (Base.getindex(::OneField{T, N}, ind...) where {N, T}) = begin
            #= none:12 =#
            one(T)
        end
#= none:14 =#
struct ConstantField{T, N} <: AbstractField{Nothing, Nothing, Nothing, Nothing, T, N}
    #= none:15 =#
    constant::T
    #= none:16 =#
    (ConstantField{N}(constant::T) where {T, N}) = begin
            #= none:16 =#
            new{T, N}(constant)
        end
end
#= none:20 =#
ConstantField(constant) = begin
        #= none:20 =#
        ConstantField{3}(constant)
    end
#= none:22 =#
#= none:22 =# @inline Base.getindex(f::ConstantField, ind...) = begin
            #= none:22 =#
            f.constant
        end
#= none:24 =#
const CF = Union{ConstantField, ZeroField, OneField}
#= none:26 =#
fill_halo_regions!(::ZeroField, args...; kw...) = begin
        #= none:26 =#
        nothing
    end
#= none:27 =#
fill_halo_regions!(::ConstantField, args...; kw...) = begin
        #= none:27 =#
        nothing
    end