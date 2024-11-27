
#= none:1 =#
using Printf
#= none:2 =#
using Dates: AbstractTime
#= none:4 =#
using Oceananigans.Units
#= none:6 =#
maybe_int(t) = begin
        #= none:6 =#
        if isinteger(t)
            Int(t)
        else
            t
        end
    end
#= none:8 =#
#= none:8 =# Core.@doc "    prettytime(t, longform=true)\n\nConvert a floating point value `t` representing an amount of time in\nSI units of seconds to a human-friendly string with three decimal places.\nDepending on the value of `t` the string will be formatted to show `t` in\nnanoseconds (ns), microseconds (μs), milliseconds (ms),\nseconds, minutes, hours, or days.\n\nWith `longform=false`, we use s, m, hrs, and d in place of seconds,\nminutes, and hours.\n" function prettytime(t, longform = true)
        #= none:20 =#
        #= none:24 =#
        s = if longform
                "seconds"
            else
                "s"
            end
        #= none:25 =#
        iszero(t) && return "0 $(s)"
        #= none:26 =#
        t < 1.0e-9 && return #= none:26 =# @sprintf("%.3e %s", t, s)
        #= none:28 =#
        t = maybe_int(t)
        #= none:29 =#
        (value, units) = prettytimeunits(t, longform)
        #= none:31 =#
        if isinteger(value)
            #= none:32 =#
            return #= none:32 =# @sprintf("%d %s", value, units)
        else
            #= none:34 =#
            return #= none:34 =# @sprintf("%.3f %s", value, units)
        end
    end
#= none:38 =#
function prettytimeunits(t, longform = true)
    #= none:38 =#
    #= none:39 =#
    t < 1.0e-9 && return (t, "")
    #= none:40 =#
    t < 1.0e-6 && return (t * 1.0e9, "ns")
    #= none:41 =#
    t < 0.001 && return (t * 1.0e6, "μs")
    #= none:42 =#
    t < 1 && return (t * 1000.0, "ms")
    #= none:43 =#
    if t < minute
        #= none:44 =#
        value = t
        #= none:45 =#
        !longform && return (value, "s")
        #= none:46 =#
        units = if value == 1
                "second"
            else
                "seconds"
            end
        #= none:47 =#
        return (value, units)
    elseif #= none:48 =# t < hour
        #= none:49 =#
        value = maybe_int(t / minute)
        #= none:50 =#
        !longform && return (value, "m")
        #= none:51 =#
        units = if value == 1
                "minute"
            else
                "minutes"
            end
        #= none:52 =#
        return (value, units)
    elseif #= none:53 =# t < day
        #= none:54 =#
        value = maybe_int(t / hour)
        #= none:55 =#
        units = if value == 1
                if longform
                    "hour"
                else
                    "hr"
                end
            else
                if longform
                    "hours"
                else
                    "hrs"
                end
            end
        #= none:57 =#
        return (value, units)
    else
        #= none:59 =#
        value = maybe_int(t / day)
        #= none:60 =#
        !longform && return (value, "d")
        #= none:61 =#
        units = if value == 1
                "day"
            else
                "days"
            end
        #= none:62 =#
        return (value, units)
    end
end
#= none:66 =#
prettytime(dt::AbstractTime) = begin
        #= none:66 =#
        "$(dt)"
    end