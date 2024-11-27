
#= none:1 =#
module Units
#= none:1 =#
#= none:3 =#
export Time, second, minute, hour, day, meter, kilometer, seconds, minutes, hours, days, meters, kilometers, KiB, MiB, GiB, TiB
#= none:11 =#
#= none:11 =# Core.@doc "    second\n\nA `Float64` constant equal to 1.0. Useful for increasing the clarity of scripts, e.g. `Δt = 1second`.\n" const second = 1.0
#= none:18 =#
#= none:18 =# Core.@doc "    seconds\n\nA `Float64` constant equal to 1.0. Useful for increasing the clarity of scripts, e.g. `Δt = 7seconds`.\n" const seconds = second
#= none:25 =#
#= none:25 =# Core.@doc "    minute\n\nA `Float64` constant equal to 60`seconds`. Useful for increasing the clarity of scripts, e.g. `Δt = 1minute`.\n" const minute = 60seconds
#= none:32 =#
#= none:32 =# Core.@doc "    minutes\n\nA `Float64` constant equal to 60`seconds`. Useful for increasing the clarity of scripts, e.g. `Δt = 15minutes`.\n" const minutes = minute
#= none:39 =#
#= none:39 =# Core.@doc "    hour\n\nA `Float64` constant equal to 60`minutes`. Useful for increasing the clarity of scripts, e.g. `Δt = 1hour`.\n" const hour = 60minutes
#= none:46 =#
#= none:46 =# Core.@doc "    hours\n\nA `Float64` constant equal to 60`minutes`. Useful for increasing the clarity of scripts, e.g. `Δt = 3hours`.\n" const hours = hour
#= none:53 =#
#= none:53 =# Core.@doc "    day\n\nA `Float64` constant equal to 24`hours`. Useful for increasing the clarity of scripts, e.g. `stop_time = 1day`.\n" const day = 24hours
#= none:60 =#
#= none:60 =# Core.@doc "    days\n\nA `Float64` constant equal to 24`hours`. Useful for increasing the clarity of scripts, e.g. `stop_time = 7days`.\n" const days = day
#= none:67 =#
#= none:67 =# Core.@doc "    meter\n\nA `Float64` constant equal to 1.0. Useful for increasing the clarity of scripts, e.g. `Lx = 1meter`.\n" const meter = 1.0
#= none:74 =#
#= none:74 =# Core.@doc "    meters\n\nA `Float64` constant equal to 1.0. Useful for increasing the clarity of scripts, e.g. `Lx = 50meters`.\n" const meters = meter
#= none:81 =#
#= none:81 =# Core.@doc "    kilometer\n\nA `Float64` constant equal to 1000`meters`. Useful for increasing the clarity of scripts, e.g. `Lx = 1kilometer`.\n" const kilometer = 1000meters
#= none:88 =#
#= none:88 =# Core.@doc "    kilometers\n\nA `Float64` constant equal to 1000`meters`. Useful for increasing the clarity of scripts, e.g. `Lx = 5000kilometers`.\n" const kilometers = kilometer
#= none:95 =#
#= none:95 =# Core.@doc "    KiB\n\nA `Float64` constant equal to 1024.0. Useful for increasing the clarity of scripts, e.g. `max_filesize = 250KiB`.\n" const KiB = 1024.0
#= none:102 =#
#= none:102 =# Core.@doc "    MiB\n\nA `Float64` constant equal to 1024`KiB`. Useful for increasing the clarity of scripts, e.g. `max_filesize = 100MiB`.\n" const MiB = 1024KiB
#= none:109 =#
#= none:109 =# Core.@doc "    GiB\n\nA `Float64` constant equal to 1024`MiB`. Useful for increasing the clarity of scripts, e.g. `max_filesize = 50GiB`.\n" const GiB = 1024MiB
#= none:116 =#
#= none:116 =# Core.@doc "    TiB\n\nA `Float64` constant equal to 1024`GiB`. Useful for increasing the clarity of scripts, e.g. `max_filesize = 2TiB`.\n" const TiB = 1024GiB
#= none:123 =#
#= none:123 =# Core.@doc "    Time(t)\n\nReturn a time \"selector\" at the continuous time `t` for linearly interpolating `FieldTimeSeries`.\n\nExamples\n=======\n\n```julia\n# Interpolate `field_time_series` to `t=0.1`, returning `interpolated::Field`\ninterpolated = field_time_series[Time(0.1)]\n\n# Interpolate `field_time_series` at `i, j, k` and `t=0.1`\ninterpolated_ijk = field_time_series[i, j, k, Time(0.1)]\n```\n" struct Time{T}
        #= none:140 =#
        time::T
    end
end