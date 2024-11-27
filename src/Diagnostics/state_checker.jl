
#= none:1 =#
using Printf
#= none:2 =#
using Statistics
#= none:4 =#
struct StateChecker{T, F} <: AbstractDiagnostic
    #= none:5 =#
    schedule::T
    #= none:6 =#
    fields::F
end
#= none:9 =#
#= none:9 =# Core.@doc "    StateChecker(; schedule, fields)\n\nReturns a `StateChecker` that logs field information (minimum, maximum, mean)\nfor each field in a named tuple of `fields` when `schedule` actuates.\n" StateChecker(model; schedule, fields = fields(model)) = begin
            #= none:15 =#
            StateChecker(schedule, fields)
        end
#= none:17 =#
function run_diagnostic!(sc::StateChecker, model)
    #= none:17 =#
    #= none:18 =#
    pad = ((keys(sc.fields) .|> string) .|> length) |> maximum
    #= none:20 =#
    #= none:20 =# @info "State check @ $(summary(model.clock))"
    #= none:22 =#
    for (name, field) = pairs(sc.fields)
        #= none:23 =#
        state_check(field, name, pad)
        #= none:24 =#
    end
    #= none:26 =#
    return nothing
end
#= none:29 =#
function state_check(field, name, pad)
    #= none:29 =#
    #= none:30 =#
    min_val = minimum(field)
    #= none:31 =#
    max_val = maximum(field)
    #= none:32 =#
    mean_val = mean(field)
    #= none:34 =#
    name = lpad(name, pad)
    #= none:36 =#
    #= none:36 =# @info #= none:36 =# @sprintf("%s | min = %+.15e | max = %+.15e | mean = %+.15e", name, min_val, max_val, mean_val)
    #= none:37 =#
    return nothing
end
#= none:40 =#
(sc::StateChecker)(model) = begin
        #= none:40 =#
        run_diagnostic!(sc, model)
    end
#= none:42 =#
Base.show(io::IO, sc::StateChecker) = begin
        #= none:42 =#
        print(io, "StateChecker checking $(length(sc.fields)) fields: $(keys(sc.fields))")
    end