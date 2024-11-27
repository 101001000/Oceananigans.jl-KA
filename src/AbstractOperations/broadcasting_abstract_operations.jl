
#= none:1 =#
import Oceananigans.Fields: broadcasted_to_abstract_operation
#= none:3 =#
using Base.Broadcast: Broadcasted
#= none:4 =#
using Base: identity
#= none:6 =#
const BroadcastedIdentity = Broadcasted{<:Any, <:Any, typeof(identity), <:Any}
#= none:8 =#
#= none:8 =# @inline function broadcasted_to_abstract_operation(loc, grid, bc::BroadcastedIdentity)
        #= none:8 =#
        #= none:9 =#
        Nargs = length(bc.args)
        #= none:11 =#
        bc′ = ntuple(Val(Nargs)) do n
                #= none:12 =#
                broadcasted_to_abstract_operation(loc, grid, bc.args[n])
            end
        #= none:15 =#
        return interpolate_operation(loc, bc′...)
    end
#= none:18 =#
#= none:18 =# @inline broadcasted_to_abstract_operation(loc, grid, op::AbstractOperation) = begin
            #= none:18 =#
            at(loc, op)
        end
#= none:20 =#
#= none:20 =# @inline function broadcasted_to_abstract_operation(loc, grid, bc::Broadcasted{<:Any, <:Any, <:Any, <:Any})
        #= none:20 =#
        #= none:21 =#
        abstract_op = bc.f(loc, Tuple((broadcasted_to_abstract_operation(loc, grid, a) for a = bc.args))...)
        #= none:22 =#
        return interpolate_operation(loc, abstract_op)
    end