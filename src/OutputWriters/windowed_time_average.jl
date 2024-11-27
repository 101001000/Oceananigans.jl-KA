
#= none:1 =#
using Oceananigans.Diagnostics: AbstractDiagnostic
#= none:2 =#
using Oceananigans.OutputWriters: fetch_output
#= none:3 =#
using Oceananigans.Models: AbstractModel
#= none:4 =#
using Oceananigans.Utils: AbstractSchedule, prettytime
#= none:5 =#
using Oceananigans.TimeSteppers: Clock
#= none:7 =#
import Oceananigans: run_diagnostic!
#= none:8 =#
import Oceananigans.Utils: TimeInterval, SpecifiedTimes
#= none:9 =#
import Oceananigans.Fields: location, indices, set!
#= none:11 =#
#= none:11 =# Core.@doc "    mutable struct AveragedTimeInterval <: AbstractSchedule\n\nContainer for parameters that configure and handle time-averaged output.\n" mutable struct AveragedTimeInterval <: AbstractSchedule
        #= none:17 =#
        interval::Float64
        #= none:18 =#
        window::Float64
        #= none:19 =#
        stride::Int
        #= none:20 =#
        previous_interval_stop_time::Float64
        #= none:21 =#
        collecting::Bool
    end
#= none:24 =#
#= none:24 =# Core.@doc "    AveragedTimeInterval(interval; window=interval, stride=1)\n\nReturns a `schedule` that specifies periodic time-averaging of output.\nThe time `window` specifies the extent of the time-average, which\nreoccurs every `interval`.\n\n`output` is computed and accumulated into the average every `stride` iterations\nduring the averaging window. For example, `stride=1` computs output every iteration,\nwhereas `stride=2` computes output every other iteration. Time-averages with\nlonger `stride`s are faster to compute, but less accurate.\n\nThe time-average of ``a`` is a left Riemann sum corresponding to\n\n```math\n⟨a⟩ = T⁻¹ \\int_{tᵢ-T}^{tᵢ} a \\mathrm{d} t \\, ,\n```\n\nwhere ``⟨a⟩`` is the time-average of ``a``, ``T`` is the time-window for averaging,\nand the ``tᵢ`` are discrete times separated by the time `interval`. The ``tᵢ`` specify\nboth the end of the averaging window and the time at which output is written.\n\nExample\n=======\n\n```jldoctest averaged_time_interval\nusing Oceananigans.OutputWriters: AveragedTimeInterval\nusing Oceananigans.Utils: days\n\nschedule = AveragedTimeInterval(4days, window=2days)\n\n# output\nAveragedTimeInterval(window=2 days, stride=1, interval=4 days)\n```\n\nAn `AveragedTimeInterval` schedule directs an output writer\nto time-average its outputs before writing them to disk:\n\n```@example averaged_time_interval\nusing Oceananigans\nusing Oceananigans.Units\n\nmodel = NonhydrostaticModel(grid=RectilinearGrid(size=(1, 1, 1), extent=(1, 1, 1)))\n\nsimulation = Simulation(model, Δt=10minutes, stop_time=30days)\n\nsimulation.output_writers[:velocities] = JLD2OutputWriter(model, model.velocities,\n                                                          filename= \"averaged_velocity_data.jld2\",\n                                                          schedule = AveragedTimeInterval(4days, window=2days, stride=2))\n```\n" function AveragedTimeInterval(interval; window = interval, stride = 1)
        #= none:75 =#
        #= none:76 =#
        window > interval && throw(ArgumentError("Averaging window $(window) is greater than the output interval $(interval)."))
        #= none:77 =#
        return AveragedTimeInterval(Float64(interval), Float64(window), stride, 0.0, false)
    end
#= none:81 =#
(sch::AveragedTimeInterval)(model) = begin
        #= none:81 =#
        sch.collecting || model.clock.time >= (sch.previous_interval_stop_time + sch.interval) - sch.window
    end
#= none:82 =#
initialize_schedule!(sch::AveragedTimeInterval, clock) = begin
        #= none:82 =#
        sch.previous_interval_stop_time = clock.time - rem(clock.time, sch.interval)
    end
#= none:83 =#
outside_window(sch::AveragedTimeInterval, clock) = begin
        #= none:83 =#
        clock.time < (sch.previous_interval_stop_time + sch.interval) - sch.window
    end
#= none:84 =#
end_of_window(sch::AveragedTimeInterval, clock) = begin
        #= none:84 =#
        clock.time >= sch.previous_interval_stop_time + sch.interval
    end
#= none:86 =#
TimeInterval(schedule::AveragedTimeInterval) = begin
        #= none:86 =#
        TimeInterval(schedule.interval)
    end
#= none:87 =#
Base.copy(sch::AveragedTimeInterval) = begin
        #= none:87 =#
        AveragedTimeInterval(sch.interval, window = sch.window, stride = sch.stride)
    end
#= none:89 =#
#= none:89 =# Core.@doc "    mutable struct AveragedSpecifiedTimes <: AbstractSchedule\n\nA schedule for averaging over windows that precede SpecifiedTimes.\n" mutable struct AveragedSpecifiedTimes <: AbstractSchedule
        #= none:95 =#
        specified_times::SpecifiedTimes
        #= none:96 =#
        window::Float64
        #= none:97 =#
        stride::Int
        #= none:98 =#
        collecting::Bool
    end
#= none:101 =#
AveragedSpecifiedTimes(specified_times::SpecifiedTimes; window, stride = 1) = begin
        #= none:101 =#
        AveragedSpecifiedTimes(specified_times, window, stride, false)
    end
#= none:104 =#
AveragedSpecifiedTimes(times; kw...) = begin
        #= none:104 =#
        AveragedSpecifiedTimes(SpecifiedTimes(times); kw...)
    end
#= none:107 =#
function (schedule::AveragedSpecifiedTimes)(model)
    #= none:107 =#
    #= none:108 =#
    time = model.clock.time
    #= none:110 =#
    next = schedule.specified_times.previous_actuation + 1
    #= none:111 =#
    next > length(schedule.specified_times.times) && return false
    #= none:113 =#
    next_time = schedule.specified_times.times[next]
    #= none:114 =#
    window = schedule.window
    #= none:116 =#
    schedule.collecting || time >= next_time - window
end
#= none:119 =#
initialize_schedule!(sch::AveragedSpecifiedTimes, clock) = begin
        #= none:119 =#
        nothing
    end
#= none:121 =#
function outside_window(schedule::AveragedSpecifiedTimes, clock)
    #= none:121 =#
    #= none:122 =#
    next = schedule.specified_times.previous_actuation + 1
    #= none:123 =#
    next > length(schedule.specified_times.times) && return true
    #= none:124 =#
    next_time = schedule.specified_times.times[next]
    #= none:125 =#
    return clock.time < next_time - schedule.window
end
#= none:128 =#
function end_of_window(schedule::AveragedSpecifiedTimes, clock)
    #= none:128 =#
    #= none:129 =#
    next = schedule.specified_times.previous_actuation + 1
    #= none:130 =#
    next > length(schedule.specified_times.times) && return true
    #= none:131 =#
    next_time = schedule.specified_times.times[next]
    #= none:132 =#
    return clock.time >= next_time
end
#= none:139 =#
mutable struct WindowedTimeAverage{OP, R, S} <: AbstractDiagnostic
    #= none:140 =#
    result::R
    #= none:141 =#
    operand::OP
    #= none:142 =#
    window_start_time::Float64
    #= none:143 =#
    window_start_iteration::Int
    #= none:144 =#
    previous_collection_time::Float64
    #= none:145 =#
    schedule::S
    #= none:146 =#
    fetch_operand::Bool
end
#= none:149 =#
const IntervalWindowedTimeAverage = WindowedTimeAverage{<:Any, <:Any, <:AveragedTimeInterval}
#= none:150 =#
const SpecifiedWindowedTimeAverage = WindowedTimeAverage{<:Any, <:Any, <:AveragedSpecifiedTimes}
#= none:152 =#
stride(wta::IntervalWindowedTimeAverage) = begin
        #= none:152 =#
        wta.schedule.stride
    end
#= none:153 =#
stride(wta::SpecifiedWindowedTimeAverage) = begin
        #= none:153 =#
        wta.schedule.stride
    end
#= none:155 =#
#= none:155 =# Core.@doc "    WindowedTimeAverage(operand, model=nothing; schedule)\n\nReturns an object for computing running averages of `operand` over `schedule.window` and\nrecurring on `schedule.interval`, where `schedule` is an `AveragedTimeInterval`.\nDuring the collection period, averages are computed every `schedule.stride` iteration.\n\n`operand` may be a `Oceananigans.Field` or a function that returns an array or scalar.\n\nCalling `wta(model)` for `wta::WindowedTimeAverage` object returns `wta.result`.\n" function WindowedTimeAverage(operand, model = nothing; schedule, fetch_operand = true)
        #= none:166 =#
        #= none:168 =#
        if fetch_operand
            #= none:169 =#
            output = fetch_output(operand, model)
            #= none:170 =#
            result = similar(output)
            #= none:171 =#
            result .= output
        else
            #= none:173 =#
            result = similar(operand)
            #= none:174 =#
            result .= operand
        end
        #= none:177 =#
        return WindowedTimeAverage(result, operand, 0.0, 0, 0.0, schedule, fetch_operand)
    end
#= none:181 =#
location(wta::WindowedTimeAverage) = begin
        #= none:181 =#
        location(wta.operand)
    end
#= none:182 =#
indices(wta::WindowedTimeAverage) = begin
        #= none:182 =#
        indices(wta.operand)
    end
#= none:183 =#
set!(u::Field, wta::WindowedTimeAverage) = begin
        #= none:183 =#
        set!(u, wta.result)
    end
#= none:184 =#
Base.parent(wta::WindowedTimeAverage) = begin
        #= none:184 =#
        parent(wta.result)
    end
#= none:187 =#
function (wta::WindowedTimeAverage)(model)
    #= none:187 =#
    #= none:190 =#
    wta.schedule.collecting && (model.clock.iteration > 0 && #= none:192 =# @warn("Returning a WindowedTimeAverage before the collection period is complete."))
    #= none:194 =#
    return wta.result
end
#= none:197 =#
function accumulate_result!(wta, model::AbstractModel)
    #= none:197 =#
    #= none:198 =#
    integrand = if wta.fetch_operand
            fetch_output(wta.operand, model)
        else
            wta.operand
        end
    #= none:199 =#
    return accumulate_result!(wta, model.clock, integrand)
end
#= none:202 =#
function accumulate_result!(wta, clock::Clock, integrand = wta.operand)
    #= none:202 =#
    #= none:204 =#
    Δt = clock.time - wta.previous_collection_time
    #= none:207 =#
    T_current = clock.time - wta.window_start_time
    #= none:208 =#
    T_previous = wta.previous_collection_time - wta.window_start_time
    #= none:211 =#
    #= none:211 =# @__dot__ wta.result = (wta.result * T_previous + integrand * Δt) / T_current
    #= none:214 =#
    wta.previous_collection_time = clock.time
    #= none:216 =#
    return nothing
end
#= none:219 =#
function advance_time_average!(wta::WindowedTimeAverage, model)
    #= none:219 =#
    #= none:221 =#
    if model.clock.iteration == 0
        #= none:222 =#
        initialize_schedule!(wta.schedule, model.clock)
    end
    #= none:231 =#
    unscheduled = model.clock.iteration == 0 && outside_window(wta.schedule, model.clock)
    #= none:233 =#
    if unscheduled
        #= none:233 =#
    elseif #= none:246 =# !(wta.schedule.collecting)
        #= none:251 =#
        wta.schedule.collecting = true
        #= none:254 =#
        wta.result .= 0
        #= none:257 =#
        wta.window_start_time = model.clock.time
        #= none:258 =#
        wta.window_start_iteration = model.clock.iteration
        #= none:259 =#
        wta.previous_collection_time = model.clock.time
    elseif #= none:261 =# end_of_window(wta.schedule, model.clock)
        #= none:265 =#
        accumulate_result!(wta, model)
        #= none:268 =#
        wta.schedule.collecting = false
        #= none:271 =#
        initialize_schedule!(wta.schedule, model.clock)
    elseif #= none:273 =# mod(model.clock.iteration - wta.window_start_iteration, stride(wta)) == 0
        #= none:275 =#
        accumulate_result!(wta, model)
    end
    #= none:278 =#
    return nothing
end
#= none:282 =#
run_diagnostic!(wta::WindowedTimeAverage, model) = begin
        #= none:282 =#
        advance_time_average!(wta, model)
    end
#= none:284 =#
Base.show(io::IO, schedule::AveragedTimeInterval) = begin
        #= none:284 =#
        print(io, summary(schedule))
    end
#= none:286 =#
Base.summary(schedule::AveragedTimeInterval) = begin
        #= none:286 =#
        string("AveragedTimeInterval(", "window=", prettytime(schedule.window), ", ", "stride=", schedule.stride, ", ", "interval=", prettytime(schedule.interval), ")")
    end
#= none:291 =#
show_averaging_schedule(schedule) = begin
        #= none:291 =#
        ""
    end
#= none:292 =#
show_averaging_schedule(schedule::AveragedTimeInterval) = begin
        #= none:292 =#
        string(" averaged on ", summary(schedule))
    end
#= none:294 =#
output_averaging_schedule(output::WindowedTimeAverage) = begin
        #= none:294 =#
        output.schedule
    end
#= none:300 =#
time_average_outputs(schedule, outputs, model) = begin
        #= none:300 =#
        (schedule, outputs)
    end
#= none:302 =#
#= none:302 =# Core.@doc "    time_average_outputs(schedule::AveragedTimeInterval, outputs, model, field_slicer)\n\nWrap each `output` in a `WindowedTimeAverage` on the time-averaged `schedule` and with `field_slicer`.\n\nReturns the `TimeInterval` associated with `schedule` and a `NamedTuple` or `Dict` of the wrapped\noutputs.\n" function time_average_outputs(schedule::AveragedTimeInterval, outputs::Dict, model)
        #= none:310 =#
        #= none:311 =#
        averaged_outputs = Dict((name => WindowedTimeAverage(output, model; schedule = copy(schedule)) for (name, output) = outputs))
        #= none:314 =#
        return (TimeInterval(schedule), averaged_outputs)
    end
#= none:317 =#
function time_average_outputs(schedule::AveragedTimeInterval, outputs::NamedTuple, model)
    #= none:317 =#
    #= none:318 =#
    averaged_outputs = NamedTuple((name => WindowedTimeAverage(outputs[name], model; schedule = copy(schedule)) for name = keys(outputs)))
    #= none:321 =#
    return (TimeInterval(schedule), averaged_outputs)
end