
#= none:1 =#
module Logger
#= none:1 =#
#= none:3 =#
export OceananigansLogger
#= none:5 =#
using Dates
#= none:6 =#
using Logging
#= none:7 =#
using Crayons
#= none:9 =#
import Logging: shouldlog, min_enabled_level, catch_exceptions, handle_message
#= none:11 =#
const RED = Crayon(foreground = :red)
#= none:12 =#
const YELLOW = Crayon(foreground = :light_yellow)
#= none:13 =#
const CYAN = Crayon(foreground = :cyan)
#= none:14 =#
const BLUE = Crayon(foreground = :blue)
#= none:16 =#
const BOLD = Crayon(bold = true)
#= none:17 =#
const UNDERLINE = Crayon(underline = true)
#= none:19 =#
struct OceananigansLogger <: Logging.AbstractLogger
    #= none:20 =#
    stream::IO
    #= none:21 =#
    min_level::Logging.LogLevel
    #= none:22 =#
    message_limits::Dict{Any, Int}
    #= none:23 =#
    show_info_source::Bool
end
#= none:26 =#
#= none:26 =# Core.@doc "    OceananigansLogger(stream::IO=stdout, level=Logging.Info; show_info_source=false)\n\nBased on Logging.SimpleLogger, it tries to log all messages in the following format:\n\n    [yyyy/mm/dd HH:MM:SS.sss] log_level message [-@-> source_file:line_number]\n\nwhere the source of the message between the square brackets is included only if\n`show_info_source=true` or if the message is not an info level message.\n" OceananigansLogger(stream::IO = stdout, level = Logging.Info; show_info_source = false) = begin
            #= none:36 =#
            OceananigansLogger(stream, level, Dict{Any, Int}(), show_info_source)
        end
#= none:39 =#
shouldlog(logger::OceananigansLogger, level, _module, group, id) = begin
        #= none:39 =#
        get(logger.message_limits, id, 1) > 0
    end
#= none:42 =#
min_enabled_level(logger::OceananigansLogger) = begin
        #= none:42 =#
        logger.min_level
    end
#= none:44 =#
catch_exceptions(logger::OceananigansLogger) = begin
        #= none:44 =#
        false
    end
#= none:46 =#
function level_to_string(level)
    #= none:46 =#
    #= none:47 =#
    level == Logging.Error && return "ERROR"
    #= none:48 =#
    level == Logging.Warn && return "WARN "
    #= none:49 =#
    level == Logging.Info && return "INFO "
    #= none:50 =#
    level == Logging.Debug && return "DEBUG"
    #= none:51 =#
    return string(level)
end
#= none:54 =#
function level_to_crayon(level)
    #= none:54 =#
    #= none:55 =#
    level == Logging.Error && return RED
    #= none:56 =#
    level == Logging.Warn && return YELLOW
    #= none:57 =#
    level == Logging.Info && return CYAN
    #= none:58 =#
    level == Logging.Debug && return BLUE
    #= none:59 =#
    return identity
end
#= none:62 =#
function handle_message(logger::OceananigansLogger, level, message, _module, group, id, filepath, line; maxlog = nothing, kwargs...)
    #= none:62 =#
    #= none:65 =#
    if !(isnothing(maxlog)) && maxlog isa Int
        #= none:66 =#
        remaining = get!(logger.message_limits, id, maxlog)
        #= none:67 =#
        logger.message_limits[id] = remaining - 1
        #= none:68 =#
        remaining > 0 || return nothing
    end
    #= none:71 =#
    buf = IOBuffer()
    #= none:72 =#
    iob = IOContext(buf, logger.stream)
    #= none:74 =#
    level_name = level_to_string(level)
    #= none:75 =#
    crayon = level_to_crayon(level)
    #= none:77 =#
    module_name = something(_module, "nothing")
    #= none:78 =#
    file_name = something(filepath, "nothing")
    #= none:79 =#
    line_number = something(line, "nothing")
    #= none:80 =#
    msg_timestamp = Dates.format(Dates.now(), "[yyyy/mm/dd HH:MM:SS.sss]")
    #= none:82 =#
    formatted_message = "$(crayon(msg_timestamp)) $(BOLD(crayon(level_name))) $(message)"
    #= none:83 =#
    if logger.show_info_source || level != Logging.Info
        #= none:84 =#
        formatted_message *= " $(BOLD(crayon("-@->"))) $(UNDERLINE("$(file_name):$(line_number)"))"
    end
    #= none:87 =#
    println(iob, formatted_message)
    #= none:88 =#
    write(logger.stream, take!(buf))
    #= none:90 =#
    return nothing
end
end