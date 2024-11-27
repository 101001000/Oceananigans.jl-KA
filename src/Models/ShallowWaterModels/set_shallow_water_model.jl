
#= none:1 =#
import Oceananigans.Fields: set!
#= none:3 =#
using Oceananigans.TimeSteppers: update_state!
#= none:5 =#
function set!(model::ShallowWaterModel; kwargs...)
    #= none:5 =#
    #= none:6 =#
    for (fldname, value) = kwargs
        #= none:7 =#
        if fldname ∈ propertynames(model.solution)
            #= none:8 =#
            ϕ = getproperty(model.solution, fldname)
        elseif #= none:9 =# fldname ∈ propertynames(model.tracers)
            #= none:10 =#
            ϕ = getproperty(model.tracers, fldname)
        else
            #= none:12 =#
            throw(ArgumentError("name $(fldname) not found in model.solution or model.tracers."))
        end
        #= none:14 =#
        set!(ϕ, value)
        #= none:15 =#
    end
    #= none:17 =#
    update_state!(model; compute_tendencies = false)
    #= none:19 =#
    return nothing
end