
#= none:1 =#
using Oceananigans.Utils: prettykeys
#= none:3 =#
mutable struct NaNChecker{F}
    #= none:4 =#
    fields::F
    #= none:5 =#
    erroring::Bool
end
#= none:8 =#
NaNChecker(fields) = begin
        #= none:8 =#
        NaNChecker(fields, false)
    end
#= none:9 =#
default_nan_checker(model) = begin
        #= none:9 =#
        nothing
    end
#= none:11 =#
function Base.summary(nc::NaNChecker)
    #= none:11 =#
    #= none:12 =#
    fieldnames = prettykeys(nc.fields)
    #= none:13 =#
    if nc.erroring
        #= none:14 =#
        return "Erroring NaNChecker for $(fieldnames)"
    else
        #= none:16 =#
        return "NaNChecker for $(fieldnames)"
    end
end
#= none:20 =#
Base.show(io, nc::NaNChecker) = begin
        #= none:20 =#
        print(io, summary(nc))
    end
#= none:22 =#
#= none:22 =# Core.@doc "    NaNChecker(; fields, erroring=false)\n\nReturn a `NaNChecker`, which sets `sim.running=false` if a `NaN` is detected\nin any member of `fields` when `NaNChecker(sim)` is called. `fields` should be\na container with key-value pairs like a dictionary or `NamedTuple`.\n\nIf `erroring=true`, the `NaNChecker` will throw an error on NaN detection.\n" NaNChecker(; fields, erroring = false) = begin
            #= none:31 =#
            NaNChecker(fields, erroring)
        end
#= none:33 =#
hasnan(field) = begin
        #= none:33 =#
        any(isnan, parent(field))
    end
#= none:34 =#
hasnan(model::AbstractModel) = begin
        #= none:34 =#
        hasnan(first(fields(model)))
    end
#= none:36 =#
function (nc::NaNChecker)(simulation)
    #= none:36 =#
    #= none:37 =#
    for (name, field) = pairs(nc.fields)
        #= none:38 =#
        if hasnan(field)
            #= none:39 =#
            simulation.running = false
            #= none:40 =#
            clock = simulation.model.clock
            #= none:41 =#
            t = time(simulation)
            #= none:42 =#
            iter = iteration(simulation)
            #= none:44 =#
            if nc.erroring
                #= none:45 =#
                error("time = $(t), iteration = $(iter): NaN found in field $(name). Aborting simulation.")
            else
                #= none:47 =#
                #= none:47 =# @info "time = $(t), iteration = $(iter): NaN found in field $(name). Stopping simulation."
            end
        end
        #= none:50 =#
    end
    #= none:51 =#
    return nothing
end
#= none:54 =#
#= none:54 =# Core.@doc "    erroring_NaNChecker!(simulation)\n\nToggle `simulation`'s `NaNChecker` to throw an error when a `NaN` is detected.\n" function erroring_NaNChecker!(simulation)
        #= none:59 =#
        #= none:60 =#
        (simulation.callbacks[:nan_checker]).func.erroring = true
        #= none:61 =#
        return nothing
    end