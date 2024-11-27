
#= none:1 =#
import Oceananigans: initialize!
#= none:3 =#
#= none:3 =# Core.@doc "    AbstractSchedule\n\nSupertype for objects that schedule `OutputWriter`s and `Diagnostics`.\nSchedule must define the functor `Schedule(model)` that returns true or\nfalse.\n" abstract type AbstractSchedule end
#= none:13 =#
schedule_aligned_time_step(schedule, clock, Δt) = begin
        #= none:13 =#
        Δt
    end
#= none:18 =#
function initialize!(schedule::AbstractSchedule, model)
    #= none:18 =#
    #= none:19 =#
    schedule(model)
    #= none:23 =#
    return true
end
#= none:30 =#
#= none:30 =# Core.@doc "    struct TimeInterval <: AbstractSchedule\n\nCallable `TimeInterval` schedule for periodic output or diagnostic evaluation\naccording to `model.clock.time`.\n" mutable struct TimeInterval <: AbstractSchedule
        #= none:37 =#
        interval::Float64
        #= none:38 =#
        first_actuation_time::Float64
        #= none:39 =#
        actuations::Int
    end
#= none:42 =#
#= none:42 =# Core.@doc "    TimeInterval(interval)\n\nReturn a callable `TimeInterval` that schedules periodic output or diagnostic evaluation\non a `interval` of simulation time, as kept by `model.clock`.\n" TimeInterval(interval) = begin
            #= none:48 =#
            TimeInterval(convert(Float64, interval), 0.0, 0)
        end
#= none:50 =#
function initialize!(schedule::TimeInterval, first_actuation_time::Number)
    #= none:50 =#
    #= none:51 =#
    schedule.first_actuation_time = first_actuation_time
    #= none:52 =#
    schedule.actuations = 0
    #= none:53 =#
    return true
end
#= none:56 =#
initialize!(schedule::TimeInterval, model) = begin
        #= none:56 =#
        initialize!(schedule, model.clock.time)
    end
#= none:58 =#
function next_actuation_time(schedule::TimeInterval)
    #= none:58 =#
    #= none:59 =#
    t₀ = schedule.first_actuation_time
    #= none:60 =#
    N = schedule.actuations
    #= none:61 =#
    T = schedule.interval
    #= none:62 =#
    return t₀ + (N + 1) * T
end
#= none:65 =#
function (schedule::TimeInterval)(model)
    #= none:65 =#
    #= none:66 =#
    t = model.clock.time
    #= none:67 =#
    t★ = next_actuation_time(schedule)
    #= none:69 =#
    if t >= t★
        #= none:70 =#
        if schedule.actuations < typemax(Int)
            #= none:71 =#
            schedule.actuations += 1
        else
            #= none:73 =#
            initialize!(schedule, t★)
        end
        #= none:75 =#
        return true
    else
        #= none:77 =#
        return false
    end
end
#= none:81 =#
function schedule_aligned_time_step(schedule::TimeInterval, clock, Δt)
    #= none:81 =#
    #= none:82 =#
    t★ = next_actuation_time(schedule)
    #= none:83 =#
    t = clock.time
    #= none:84 =#
    return min(Δt, t★ - t)
end
#= none:91 =#
struct IterationInterval <: AbstractSchedule
    #= none:92 =#
    interval::Int
    #= none:93 =#
    offset::Int
end
#= none:96 =#
#= none:96 =# Core.@doc "    IterationInterval(interval; offset=0)\n\nReturn a callable `IterationInterval` that \"actuates\" (schedules output or callback execution)\nwhenever the model iteration (modified by `offset`) is a multiple of `interval`.\n\nFor example, \n\n* `IterationInterval(100)` actuates at iterations `[100, 200, 300, ...]`.\n* `IterationInterval(100, offset=-1)` actuates at iterations `[99, 199, 299, ...]`.\n" IterationInterval(interval; offset = 0) = begin
            #= none:107 =#
            IterationInterval(interval, offset)
        end
#= none:109 =#
(schedule::IterationInterval)(model) = begin
        #= none:109 =#
        (model.clock.iteration - schedule.offset) % schedule.interval == 0
    end
#= none:115 =#
mutable struct WallTimeInterval <: AbstractSchedule
    #= none:116 =#
    interval::Float64
    #= none:117 =#
    previous_actuation_time::Float64
end
#= none:120 =#
#= none:120 =# Core.@doc "    WallTimeInterval(interval; start_time = time_ns() * 1e-9)\n\nReturn a callable `WallTimeInterval` that schedules periodic output or diagnostic evaluation\non a `interval` of \"wall time\" while a simulation runs, in units of seconds.\n\nThe \"wall time\" is the actual real world time in seconds, as kept by an actual\nor hypothetical clock hanging on your wall.\n\nThe keyword argument `start_time` can be used to specify a starting wall time\nother than the moment `WallTimeInterval` is constructed.\n" WallTimeInterval(interval; start_time = time_ns() * 1.0e-9) = begin
            #= none:132 =#
            WallTimeInterval(Float64(interval), Float64(start_time))
        end
#= none:134 =#
function (schedule::WallTimeInterval)(model)
    #= none:134 =#
    #= none:135 =#
    wall_time = time_ns() * 1.0e-9
    #= none:137 =#
    if wall_time >= schedule.previous_actuation_time + schedule.interval
        #= none:139 =#
        schedule.previous_actuation_time = wall_time - rem(wall_time, schedule.interval)
        #= none:140 =#
        return true
    else
        #= none:142 =#
        return false
    end
end
#= none:150 =#
mutable struct SpecifiedTimes <: AbstractSchedule
    #= none:151 =#
    times::Vector{Float64}
    #= none:152 =#
    previous_actuation::Int
end
#= none:155 =#
#= none:155 =# Core.@doc "    SpecifiedTimes(times)\n\nReturn a callable `TimeInterval` that \"actuates\" (schedules output or callback execution)\nwhenever the model's clock equals the specified values in `times`. For example, \n\n* `SpecifiedTimes([1, 15.3])` actuates when `model.clock.time` is `1` and `15.3`.\n\n!!! info \"Sorting specified times\"\n    The specified `times` need not be ordered as the `SpecifiedTimes` constructor\n    will check and order them in ascending order if needed.\n" (SpecifiedTimes(times::Vararg{T}) where T <: Number) = begin
            #= none:167 =#
            SpecifiedTimes(sort([Float64(t) for t = times]), 0)
        end
#= none:168 =#
SpecifiedTimes(times) = begin
        #= none:168 =#
        SpecifiedTimes(times...)
    end
#= none:170 =#
function next_actuation_time(st::SpecifiedTimes)
    #= none:170 =#
    #= none:171 =#
    if st.previous_actuation >= length(st.times)
        #= none:172 =#
        return Inf
    else
        #= none:174 =#
        return st.times[st.previous_actuation + 1]
    end
end
#= none:178 =#
function (st::SpecifiedTimes)(model)
    #= none:178 =#
    #= none:179 =#
    current_time = model.clock.time
    #= none:181 =#
    if current_time >= next_actuation_time(st)
        #= none:182 =#
        st.previous_actuation += 1
        #= none:183 =#
        return true
    end
    #= none:186 =#
    return false
end
#= none:189 =#
initialize!(st::SpecifiedTimes, model) = begin
        #= none:189 =#
        st(model)
    end
#= none:191 =#
function schedule_aligned_time_step(schedule::SpecifiedTimes, clock, Δt)
    #= none:191 =#
    #= none:192 =#
    δt = next_actuation_time(schedule) - clock.time
    #= none:193 =#
    return min(Δt, δt)
end
#= none:196 =#
function specified_times_str(st)
    #= none:196 =#
    #= none:197 =#
    str_elems = ["$(prettytime(t)), " for t = st.times]
    #= none:198 =#
    str = string("[", str_elems...)
    #= none:201 =#
    str = str[1:end - 2]
    #= none:204 =#
    return string(str, "]")
end
#= none:211 =#
mutable struct ConsecutiveIterations{S} <: AbstractSchedule
    #= none:212 =#
    parent::S
    #= none:213 =#
    consecutive_iterations::Int
    #= none:214 =#
    previous_parent_actuation_iteration::Int
end
#= none:217 =#
#= none:217 =# Core.@doc "    ConsecutiveIterations(parent_schedule)\n\nReturn a `schedule::ConsecutiveIterations` that actuates both when `parent_schedule`\nactuates, and at iterations immediately following the actuation of `parent_schedule`.\nThis can be used, for example, when one wants to use output to reproduce a first-order approximation\nof the time derivative of a quantity.\n" ConsecutiveIterations(parent_schedule, N = 1) = begin
            #= none:225 =#
            ConsecutiveIterations(parent_schedule, N, 0)
        end
#= none:227 =#
function (schedule::ConsecutiveIterations)(model)
    #= none:227 =#
    #= none:228 =#
    if schedule.parent(model)
        #= none:229 =#
        schedule.previous_parent_actuation_iteration = model.clock.iteration
        #= none:230 =#
        return true
    elseif #= none:231 =# model.clock.iteration - schedule.consecutive_iterations <= schedule.previous_parent_actuation_iteration
        #= none:232 =#
        return true
    else
        #= none:234 =#
        return false
    end
end
#= none:238 =#
schedule_aligned_time_step(schedule::ConsecutiveIterations, clock, Δt) = begin
        #= none:238 =#
        schedule_aligned_time_step(schedule.parent, clock, Δt)
    end
#= none:245 =#
struct AndSchedule{S} <: AbstractSchedule
    #= none:246 =#
    schedules::S
    #= none:247 =#
    (AndSchedule(schedules::S) where S <: Tuple) = begin
            #= none:247 =#
            new{S}(schedules)
        end
end
#= none:250 =#
#= none:250 =# Core.@doc "    AndSchedule(schedules...)\n\nReturn a schedule that actuates when all `child_schedule`s actuate.\n" AndSchedule(schedules...) = begin
            #= none:255 =#
            AndSchedule(Tuple(schedules))
        end
#= none:259 =#
(as::AndSchedule)(model) = begin
        #= none:259 =#
        all((schedule(model) for schedule = as.schedules))
    end
#= none:261 =#
struct OrSchedule{S} <: AbstractSchedule
    #= none:262 =#
    schedules::S
    #= none:263 =#
    (OrSchedule(schedules::S) where S <: Tuple) = begin
            #= none:263 =#
            new{S}(schedules)
        end
end
#= none:266 =#
#= none:266 =# Core.@doc "    OrSchedule(schedules...)\n\nReturn a schedule that actuates when any of the `child_schedule`s actuates.\n" OrSchedule(schedules...) = begin
            #= none:271 =#
            OrSchedule(Tuple(schedules))
        end
#= none:273 =#
function (as::OrSchedule)(model)
    #= none:273 =#
    #= none:275 =#
    actuations = Tuple((schedule(model) for schedule = as.schedules))
    #= none:276 =#
    return any(actuations)
end
#= none:279 =#
schedule_aligned_time_step(any_or_all_schedule::Union{OrSchedule, AndSchedule}, clock, Δt) = begin
        #= none:279 =#
        minimum((schedule_aligned_time_step(schedule, clock, Δt) for schedule = any_or_all_schedule.schedules))
    end
#= none:287 =#
Base.summary(schedule::IterationInterval) = begin
        #= none:287 =#
        string("IterationInterval(", schedule.interval, ")")
    end
#= none:288 =#
Base.summary(schedule::TimeInterval) = begin
        #= none:288 =#
        string("TimeInterval(", prettytime(schedule.interval), ")")
    end
#= none:289 =#
Base.summary(schedule::SpecifiedTimes) = begin
        #= none:289 =#
        string("SpecifiedTimes(", specified_times_str(schedule), ")")
    end
#= none:290 =#
Base.summary(schedule::ConsecutiveIterations) = begin
        #= none:290 =#
        string("ConsecutiveIterations(", summary(schedule.parent), ", ", schedule.consecutive_iterations, ")")
    end