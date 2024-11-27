
#= none:1 =#
import Oceananigans: tupleit
#= none:7 =#
tupleit(::Nothing) = begin
        #= none:7 =#
        ()
    end
#= none:8 =#
tupleit(t::NamedTuple) = begin
        #= none:8 =#
        t
    end
#= none:9 =#
tupleit(t::Tuple) = begin
        #= none:9 =#
        t
    end
#= none:10 =#
tupleit(nt) = begin
        #= none:10 =#
        tuple(nt)
    end
#= none:11 =#
tupleit(nt::Vector) = begin
        #= none:11 =#
        tuple(nt...)
    end
#= none:13 =#
parenttuple(obj) = begin
        #= none:13 =#
        Tuple((f.data.parent for f = obj))
    end
#= none:15 =#
#= none:15 =# @inline datatuple(obj::Nothing) = begin
            #= none:15 =#
            nothing
        end
#= none:16 =#
#= none:16 =# @inline datatuple(obj::AbstractArray) = begin
            #= none:16 =#
            obj
        end
#= none:17 =#
#= none:17 =# @inline datatuple(obj::Tuple) = begin
            #= none:17 =#
            Tuple((datatuple(o) for o = obj))
        end
#= none:18 =#
#= none:18 =# @inline datatuple(obj::NamedTuple) = begin
            #= none:18 =#
            NamedTuple{propertynames(obj)}((datatuple(o) for o = obj))
        end
#= none:19 =#
#= none:19 =# @inline datatuples(objs...) = begin
            #= none:19 =#
            (datatuple(obj) for obj = objs)
        end
#= none:21 =#
macro constprop(setting)
    #= none:21 =#
    #= none:22 =#
    if setting isa QuoteNode
        #= none:23 =#
        setting = setting.value
    end
    #= none:25 =#
    setting === :aggressive && return Expr(:meta, :aggressive_constprop)
    #= none:26 =#
    setting === :none && return Expr(:meta, :no_constprop)
    #= none:27 =#
    throw(ArgumentError("@constprop $(setting) not supported"))
end