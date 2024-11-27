
#= none:8 =#
import Base: +, -, *, /, ==
#= none:9 =#
using Oceananigans.Fields: ZeroField, ConstantField
#= none:12 =#
::ZeroField == ::ZeroField = begin
        #= none:12 =#
        true
    end
#= none:14 =#
zf::ZeroField == cf::ConstantField = begin
        #= none:14 =#
        0 == cf.constant
    end
#= none:15 =#
cf::ConstantField == zf::ZeroField = begin
        #= none:15 =#
        0 == cf.constant
    end
#= none:16 =#
c1::ConstantField == c2::ConstantField = begin
        #= none:16 =#
        c1.constant == c2.constant
    end
#= none:18 =#
a::ZeroField + b::AbstractField = begin
        #= none:18 =#
        b
    end
#= none:19 =#
a::AbstractField + b::ZeroField = begin
        #= none:19 =#
        a
    end
#= none:20 =#
a::ZeroField + b::Number = begin
        #= none:20 =#
        ConstantField(b)
    end
#= none:21 =#
a::Number + b::ZeroField = begin
        #= none:21 =#
        ConstantField(a)
    end
#= none:23 =#
a::ZeroField - b::AbstractField = begin
        #= none:23 =#
        -b
    end
#= none:24 =#
a::AbstractField - b::ZeroField = begin
        #= none:24 =#
        a
    end
#= none:25 =#
a::ZeroField - b::Number = begin
        #= none:25 =#
        ConstantField(-b)
    end
#= none:26 =#
a::Number - b::ZeroField = begin
        #= none:26 =#
        ConstantField(a)
    end
#= none:28 =#
a::ZeroField * b::AbstractField = begin
        #= none:28 =#
        a
    end
#= none:29 =#
a::AbstractField * b::ZeroField = begin
        #= none:29 =#
        b
    end
#= none:30 =#
a::ZeroField * b::Number = begin
        #= none:30 =#
        a
    end
#= none:31 =#
a::Number * b::ZeroField = begin
        #= none:31 =#
        b
    end
#= none:33 =#
a::ZeroField / b::AbstractField = begin
        #= none:33 =#
        a
    end
#= none:34 =#
a::AbstractField / b::ZeroField = begin
        #= none:34 =#
        ConstantField(convert(eltype(a), Inf))
    end
#= none:35 =#
a::ZeroField / b::Number = begin
        #= none:35 =#
        a
    end
#= none:36 =#
a::Number / b::ZeroField = begin
        #= none:36 =#
        ConstantField(a / convert(eltype(a), 0))
    end
#= none:39 =#
for op = (:-, :+, :*)
    #= none:40 =#
    #= none:40 =# @eval begin
            #= none:41 =#
            function $op(z1::ZeroField{T1, N1}, z2::ZeroField{T2, N2}) where {T1, T2, N1, N2}
                #= none:41 =#
                #= none:42 =#
                T = Base.promote_type(T1, T2)
                #= none:43 =#
                N = max(N1, N2)
                #= none:44 =#
                return ZeroField{T, N}()
            end
        end
    #= none:47 =#
end
#= none:50 =#
-(a::ZeroField) = begin
        #= none:50 =#
        a
    end