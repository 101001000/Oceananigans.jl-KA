
#= none:1 =#
using Adapt
#= none:2 =#
using Dates: AbstractTime, DateTime, Nanosecond, Millisecond
#= none:3 =#
using Oceananigans.Utils: prettytime
#= none:5 =#
import Base: show
#= none:6 =#
import Oceananigans.Units: Time
#= none:8 =#
#= none:8 =# Core.@doc "    mutable struct Clock{T, FT}\n\nKeeps track of the current `time`, `last_Δt`, `iteration` number, and time-stepping `stage`.\nThe `stage` is updated only for multi-stage time-stepping methods. The `time::T` is\neither a number or a `DateTime` object.\n" mutable struct Clock{TT, DT}
        #= none:16 =#
        time::TT
        #= none:17 =#
        last_Δt::DT
        #= none:18 =#
        last_stage_Δt::DT
        #= none:19 =#
        iteration::Int
        #= none:20 =#
        stage::Int
    end
#= none:23 =#
#= none:23 =# Core.@doc "    Clock(; time, last_Δt=Inf, last_stage_Δt=Inf, iteration=0, stage=1)\n\nReturns a `Clock` object. By default, `Clock` is initialized to the zeroth `iteration`\nand first time step `stage` with `last_Δt=last_stage_Δt=Inf`.\n" function Clock(; time, last_Δt = Inf, last_stage_Δt = Inf, iteration = 0, stage = 1)
        #= none:29 =#
        #= none:35 =#
        TT = typeof(time)
        #= none:36 =#
        DT = typeof(last_Δt)
        #= none:37 =#
        last_stage_Δt = convert(DT, last_Δt)
        #= none:38 =#
        return Clock{TT, DT}(time, last_Δt, last_stage_Δt, iteration, stage)
    end
#= none:42 =#
time_step_type(TT) = begin
        #= none:42 =#
        TT
    end
#= none:44 =#
function Clock{TT}(; time, last_Δt = Inf, last_stage_Δt = Inf, iteration = 0, stage = 1) where TT
    #= none:44 =#
    #= none:50 =#
    DT = time_step_type(TT)
    #= none:51 =#
    last_Δt = convert(DT, last_Δt)
    #= none:52 =#
    last_stage_Δt = convert(DT, last_stage_Δt)
    #= none:54 =#
    return Clock{TT, DT}(time, last_Δt, last_stage_Δt, iteration, stage)
end
#= none:57 =#
function Base.summary(clock::Clock)
    #= none:57 =#
    #= none:58 =#
    TT = typeof(clock.time)
    #= none:59 =#
    DT = typeof(clock.last_Δt)
    #= none:60 =#
    return string("Clock{", TT, ", ", DT, "}", "(time=", prettytime(clock.time), ", iteration=", clock.iteration, ", last_Δt=", prettytime(clock.last_Δt), ")")
end
#= none:66 =#
function Base.show(io::IO, clock::Clock)
    #= none:66 =#
    #= none:67 =#
    return print(io, summary(clock), '\n', "├── stage: ", clock.stage, '\n', "└── last_stage_Δt: ", prettytime(clock.last_stage_Δt))
end
#= none:72 =#
next_time(clock, Δt) = begin
        #= none:72 =#
        clock.time + Δt
    end
#= none:73 =#
next_time(clock::Clock{<:AbstractTime}, Δt) = begin
        #= none:73 =#
        clock.time + Nanosecond(round(Int, 1.0e9Δt))
    end
#= none:75 =#
tick_time!(clock, Δt) = begin
        #= none:75 =#
        clock.time += Δt
    end
#= none:76 =#
tick_time!(clock::Clock{<:AbstractTime}, Δt) = begin
        #= none:76 =#
        clock.time += Nanosecond(round(Int, 1.0e9Δt))
    end
#= none:78 =#
Time(clock::Clock) = begin
        #= none:78 =#
        Time(clock.time)
    end
#= none:81 =#
unit_time(t) = begin
        #= none:81 =#
        t
    end
#= none:82 =#
unit_time(t::Millisecond) = begin
        #= none:82 =#
        t.value / 1000
    end
#= none:83 =#
unit_time(t::Nanosecond) = begin
        #= none:83 =#
        t.value / 1000000000
    end
#= none:86 =#
float_or_date_time(t) = begin
        #= none:86 =#
        t
    end
#= none:87 =#
float_or_date_time(t::AbstractTime) = begin
        #= none:87 =#
        DateTime(t)
    end
#= none:89 =#
function tick!(clock, Δt; stage = false)
    #= none:89 =#
    #= none:91 =#
    tick_time!(clock, Δt)
    #= none:93 =#
    if stage
        #= none:94 =#
        clock.stage += 1
    else
        #= none:96 =#
        clock.iteration += 1
        #= none:97 =#
        clock.stage = 1
    end
    #= none:100 =#
    return nothing
end
#= none:103 =#
#= none:103 =# Core.@doc "Adapt `Clock` for GPU." Adapt.adapt_structure(to, clock::Clock) = begin
            #= none:104 =#
            (time = clock.time, last_Δt = clock.last_Δt, last_stage_Δt = clock.last_stage_Δt, iteration = clock.iteration, stage = clock.stage)
        end