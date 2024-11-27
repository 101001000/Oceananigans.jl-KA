
#= none:1 =#
using Oceananigans.Utils: prettysummary
#= none:2 =#
using Oceananigans.OutputWriters: WindowedTimeAverage, advance_time_average!
#= none:3 =#
using Oceananigans: TimeStepCallsite, TendencyCallsite, UpdateStateCallsite
#= none:5 =#
import Oceananigans: initialize!
#= none:7 =#
struct Callback{P, F, S, CS}
    #= none:8 =#
    func::F
    #= none:9 =#
    schedule::S
    #= none:10 =#
    parameters::P
    #= none:11 =#
    callsite::CS
end
#= none:14 =#
#= none:14 =# @inline (callback::Callback)(sim) = begin
            #= none:14 =#
            callback.func(sim, callback.parameters)
        end
#= none:15 =#
#= none:15 =# @inline (callback::Callback{<:Nothing})(sim) = begin
            #= none:15 =#
            callback.func(sim)
        end
#= none:17 =#
#= none:17 =# Core.@doc "    initialize!(callback::Callback, sim)\n\nInitialize `callback`. By default, this does nothing, but\ncan be optionally specialized on the type parameters of `Callback`.\n" initialize!(callback::Callback, sim) = begin
            #= none:23 =#
            nothing
        end
#= none:25 =#
#= none:25 =# Core.@doc "    Callback(func, schedule=IterationInterval(1);\n             parameters=nothing, callsite=TimeStepCallsite())\n\nReturn `Callback` that executes `func` on `schedule`\nat the `callsite` with optional `parameters`. By default,\n`schedule = IterationInterval(1)` and `callsite = TimeStepCallsite()`.\n\nIf `isnothing(parameters)`, `func(sim::Simulation)` is called.\nOtherwise, `func` is called via `func(sim::Simulation, parameters)`.\n\nThe `callsite` determines where `Callback` is executed. The possible values for \n`callsite` are\n\n* `TimeStepCallsite()`: after a time-step.\n\n* `TendencyCallsite()`: after tendencies are calculated, but before taking\n  a time-step (useful for modifying tendency calculations).\n\n* `UpdateStateCallsite()`: within `update_state!`, after auxiliary variables have\n  been computed (for multi-stage time-steppers, `update_state!` may be called multiple\n  times per time-step).\n" function Callback(func, schedule = IterationInterval(1); parameters = nothing, callsite = TimeStepCallsite())
        #= none:48 =#
        #= none:52 =#
        return Callback(func, schedule, parameters, callsite)
    end
#= none:55 =#
Base.summary(cb::Callback{Nothing}) = begin
        #= none:55 =#
        string("Callback of ", prettysummary(cb.func, false), " on ", summary(cb.schedule))
    end
#= none:56 =#
Base.summary(cb::Callback) = begin
        #= none:56 =#
        string("Callback of ", prettysummary(cb.func, false), " on ", summary(cb.schedule), " with parameters ", cb.parameters)
    end
#= none:59 =#
Base.show(io::IO, cb::Callback) = begin
        #= none:59 =#
        print(io, summary(cb))
    end
#= none:61 =#
function Callback(wta::WindowedTimeAverage)
    #= none:61 =#
    #= none:62 =#
    function func(sim)
        #= none:62 =#
        #= none:63 =#
        model = sim.model
        #= none:64 =#
        advance_time_average!(wta, model)
        #= none:65 =#
        return nothing
    end
    #= none:67 =#
    return Callback(func, wta.schedule, nothing)
end
#= none:70 =#
Callback(wta::WindowedTimeAverage, schedule; kw...) = begin
        #= none:70 =#
        throw(ArgumentError("Schedule must be inferred from WindowedTimeAverage. \n                        Use Callback(windowed_time_average)"))
    end
#= none:74 =#
struct GenericName
    #= none:74 =#
end
#= none:76 =#
function unique_callback_name(name, existing_names)
    #= none:76 =#
    #= none:77 =#
    if name ∈ existing_names
        #= none:78 =#
        return Symbol(:another_, name)
    else
        #= none:80 =#
        return name
    end
end
#= none:84 =#
function unique_callback_name(::GenericName, existing_names)
    #= none:84 =#
    #= none:85 =#
    prefix = :callback
    #= none:88 =#
    n = 1
    #= none:89 =#
    while Symbol(prefix, n) ∈ existing_names
        #= none:90 =#
        n += 1
        #= none:91 =#
    end
    #= none:93 =#
    return Symbol(prefix, n)
end
#= none:96 =#
#= none:96 =# Core.@doc "    add_callback!(simulation, callback::Callback; name = GenericName(), callback_kw...)\n\n    add_callback!(simulation, func, schedule=IterationInterval(1); name = GenericName(), callback_kw...)\n\nAdd `Callback(func, schedule)` to `simulation.callbacks` under `name`. The default\n`GenericName()` generates a name of the form `:callbackN`, where `N`\nis big enough for the name to be unique.\n\nIf `name::Symbol` is supplied, it may be modified if `simulation.callbacks[name]`\nalready exists.\n\n`callback_kw` are passed to the constructor for [`Callback`](@ref).\n\nThe `callback` (which contains a schedule) can also be supplied directly.\n" function add_callback!(simulation, callback::Callback; name = GenericName())
        #= none:112 =#
        #= none:113 =#
        name = unique_callback_name(name, keys(simulation.callbacks))
        #= none:114 =#
        simulation.callbacks[name] = callback
        #= none:115 =#
        return nothing
    end
#= none:118 =#
function add_callback!(simulation, func, schedule = IterationInterval(1); name = GenericName(), callback_kw...)
    #= none:118 =#
    #= none:121 =#
    callback = Callback(func, schedule; callback_kw...)
    #= none:122 =#
    return add_callback!(simulation, callback; name)
end