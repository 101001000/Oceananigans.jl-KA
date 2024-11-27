
#= none:1 =#
using Base: @propagate_inbounds
#= none:3 =#
import Adapt: adapt_structure
#= none:4 =#
import Base: getindex
#= none:6 =#
#= none:6 =# Core.@doc "    SumOfArrays{N, F}\n\n`SumOfArrays` objects hold `N` arrays/fields and return their sum when indexed.\n" struct SumOfArrays{N, F}
        #= none:12 =#
        arrays::F
        #= none:13 =#
        (SumOfArrays{N}(arrays...) where N) = begin
                #= none:13 =#
                new{N, typeof(arrays)}(arrays)
            end
    end
#= none:16 =#
#= none:16 =# @propagate_inbounds function getindex(s::SumOfArrays{N}, i...) where N
        #= none:16 =#
        #= none:17 =#
        first = getindex(SumOfArrays{3}(s.arrays[1], s.arrays[2], s.arrays[3]), i...)
        #= none:18 =#
        last = getindex(SumOfArrays{N - 3}(s.arrays[4:N]...), i...)
        #= none:19 =#
        return first + last
    end
#= none:22 =#
#= none:22 =# @propagate_inbounds getindex(s::SumOfArrays{1}, i...) = begin
            #= none:22 =#
            getindex(s.arrays[1], i...)
        end
#= none:23 =#
#= none:23 =# @propagate_inbounds getindex(s::SumOfArrays{2}, i...) = begin
            #= none:23 =#
            getindex(s.arrays[1], i...) + getindex(s.arrays[2], i...)
        end
#= none:25 =#
#= none:25 =# @propagate_inbounds getindex(s::SumOfArrays{3}, i...) = begin
            #= none:25 =#
            getindex(s.arrays[1], i...) + getindex(s.arrays[2], i...) + getindex(s.arrays[3], i...)
        end
#= none:28 =#
#= none:28 =# @propagate_inbounds getindex(s::SumOfArrays{4}, i...) = begin
            #= none:28 =#
            getindex(s.arrays[1], i...) + getindex(s.arrays[2], i...) + getindex(s.arrays[3], i...) + getindex(s.arrays[4], i...)
        end
#= none:31 =#
(adapt_structure(to, sum::SumOfArrays{N}) where N) = begin
        #= none:31 =#
        SumOfArrays{N}((adapt_structure(to, array) for array = sum.arrays)...)
    end