
#= none:1 =#
import Oceananigans.Grids: prettysummary
#= none:3 =#
prettysummary(x, args...) = begin
        #= none:3 =#
        summary(x)
    end
#= none:5 =#
function prettysummary(f::Function, showmethods = true)
    #= none:5 =#
    #= none:6 =#
    ft = typeof(f)
    #= none:7 =#
    mt = ft.name.mt
    #= none:8 =#
    name = mt.name
    #= none:9 =#
    n = length(methods(f))
    #= none:10 =#
    m = if n == 1
            "method"
        else
            "methods"
        end
    #= none:11 =#
    sname = string(name)
    #= none:12 =#
    isself = isdefined(ft.name.module, name) && ft == typeof(getfield(ft.name.module, name))
    #= none:13 =#
    ns = if isself || '#' in sname
            sname
        else
            string("(::", ft, ")")
        end
    #= none:14 =#
    if showmethods
        #= none:15 =#
        return string(ns, " (", "generic function", " with $(n) $(m))")
    else
        #= none:17 =#
        return string(ns)
    end
end
#= none:21 =#
prettysummary(x::Int, args...) = begin
        #= none:21 =#
        string(x)
    end
#= none:24 =#
function prettysummary(nt::NamedTuple, args...)
    #= none:24 =#
    #= none:25 =#
    n = nfields(nt)
    #= none:27 =#
    if n == 0
        #= none:28 =#
        return "NamedTuple()"
    else
        #= none:30 =#
        str = "("
        #= none:31 =#
        for i = 1:n
            #= none:32 =#
            f = nt[i]
            #= none:33 =#
            str = string(str, fieldname(typeof(nt), i), "=", prettysummary(getfield(nt, i)))
            #= none:34 =#
            if n == 1
                #= none:35 =#
                str = string(str, ",")
            elseif #= none:36 =# i < n
                #= none:37 =#
                str = string(str, ", ")
            end
            #= none:39 =#
        end
    end
    #= none:42 =#
    return string(str, ")")
end
#= none:45 =#
function prettykeys(t)
    #= none:45 =#
    #= none:46 =#
    names = collect(keys(t))
    #= none:47 =#
    length(names) == 0 && return "()"
    #= none:48 =#
    length(names) == 1 && return string(first(names))
    #= none:49 =#
    return string("(", (string(n, ", ") for n = names[1:end - 1])..., last(names), ")")
end