
#= none:5 =#
using Base.Broadcast: DefaultArrayStyle
#= none:6 =#
using Base.Broadcast: Broadcasted
#= none:7 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:9 =#
struct FieldBroadcastStyle <: Broadcast.AbstractArrayStyle{3}
    #= none:9 =#
end
#= none:11 =#
Base.Broadcast.BroadcastStyle(::Type{<:AbstractField}) = begin
        #= none:11 =#
        FieldBroadcastStyle()
    end
#= none:14 =#
(Base.Broadcast.BroadcastStyle(::FieldBroadcastStyle, ::DefaultArrayStyle{N}) where N) = begin
        #= none:14 =#
        FieldBroadcastStyle()
    end
#= none:15 =#
(Base.Broadcast.BroadcastStyle(::FieldBroadcastStyle, ::CUDA.CuArrayStyle{N}) where N) = begin
        #= none:15 =#
        FieldBroadcastStyle()
    end
#= none:18 =#
(Base.similar(bc::Broadcasted{FieldBroadcastStyle}, ::Type{ElType}) where ElType) = begin
        #= none:18 =#
        similar(Array{ElType}, axes(bc))
    end
#= none:21 =#
const BroadcastedArrayOrCuArray = Union{Broadcasted{<:DefaultArrayStyle}, Broadcasted{<:CUDA.CuArrayStyle}}
#= none:24 =#
#= none:24 =# @inline function Base.Broadcast.materialize!(dest::Field, bc::BroadcastedArrayOrCuArray)
        #= none:24 =#
        #= none:25 =#
        if any((a isa OffsetArray for a = bc.args))
            #= none:26 =#
            return Base.Broadcast.materialize!(dest.data, bc)
        else
            #= none:28 =#
            return Base.Broadcast.materialize!(interior(dest), bc)
        end
    end
#= none:36 =#
#= none:36 =# @inline Base.Broadcast.materialize!(dest::WindowedField, bc::BroadcastedArrayOrCuArray) = begin
            #= none:36 =#
            Base.Broadcast.materialize!(parent(dest), bc)
        end
#= none:43 =#
#= none:43 =# @inline offset_compute_index(::Colon, i) = begin
            #= none:43 =#
            i
        end
#= none:44 =#
#= none:44 =# @inline offset_compute_index(range::UnitRange, i) = begin
            #= none:44 =#
            (range[1] + i) - 1
        end
#= none:46 =#
#= none:46 =# @inline offset_index(::Colon) = begin
            #= none:46 =#
            0
        end
#= none:47 =#
#= none:47 =# @inline offset_index(range::UnitRange) = begin
            #= none:47 =#
            range[1] - 1
        end
#= none:49 =#
#= none:49 =# @kernel function _broadcast_kernel!(dest, bc)
        #= none:49 =#
        #= none:50 =#
        (i, j, k) = #= none:50 =# @index(Global, NTuple)
        #= none:51 =#
        #= none:51 =# @inbounds dest[i, j, k] = bc[i, j, k]
    end
#= none:55 =#
#= none:55 =# @inline broadcasted_to_abstract_operation(loc, grid, a) = begin
            #= none:55 =#
            a
        end
#= none:60 =#
#= none:60 =# @inline function Base.Broadcast.materialize!(::Base.Broadcast.BroadcastStyle, dest::Field, bc::Broadcasted{<:FieldBroadcastStyle})
        #= none:60 =#
        #= none:64 =#
        return copyto!(dest, convert(Broadcasted{Nothing}, bc))
    end
#= none:67 =#
#= none:67 =# @inline function Base.copyto!(dest::Field, bc::Broadcasted{Nothing})
        #= none:67 =#
        #= none:69 =#
        grid = dest.grid
        #= none:70 =#
        arch = architecture(dest)
        #= none:71 =#
        bc′ = broadcasted_to_abstract_operation(location(dest), grid, bc)
        #= none:73 =#
        param = KernelParameters(size(dest), map(offset_index, dest.indices))
        #= none:74 =#
        launch!(arch, grid, param, _broadcast_kernel!, dest, bc′)
        #= none:76 =#
        return dest
    end