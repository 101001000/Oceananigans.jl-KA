
#= none:1 =#
#= none:1 =# Core.@doc "    with_tracers(tracer_names, initial_tuple, tracer_default)\n\nCreate a tuple corresponding to the solution variables `u`, `v`, `w`,\nand `tracer_names`. `initial_tuple` is a `NamedTuple` that at least has\nfields `u`, `v`, and `w`, and may have some fields corresponding to\nthe names in `tracer_names`. `tracer_default` is a function that produces\na default tuple value for each tracer if not included in `initial_tuple`.\n" #= none:10 =# @inline(with_tracers(tracer_names, initial_tuple::NamedTuple, tracer_default; with_velocities = false) = begin
                #= none:10 =#
                with_tracers(tracer_names, initial_tuple::NamedTuple, tracer_default, with_velocities)
            end)
#= none:13 =#
#= none:13 =# @inline function with_tracers(tracer_names::TN, initial_tuple::IT, tracer_default, with_velocities) where {TN, IT <: NamedTuple}
        #= none:13 =#
        #= none:16 =#
        if with_velocities
            #= none:17 =#
            solution_values = (initial_tuple.u, initial_tuple.v, initial_tuple.w)
            #= none:21 =#
            solution_names = (:u, :v, :w)
        else
            #= none:23 =#
            solution_values = tuple()
            #= none:24 =#
            solution_names = tuple()
        end
        #= none:27 =#
        next = ntuple(Val(length(tracer_names))) do n
                #= none:28 =#
                #= none:28 =# Base.@_inline_meta
                #= none:29 =#
                name = tracer_names[n]
                #= none:30 =#
                if name ∈ propertynames(initial_tuple)
                    #= none:31 =#
                    getproperty(initial_tuple, name)
                else
                    #= none:33 =#
                    tracer_default(tracer_names, initial_tuple)
                end
            end
        #= none:37 =#
        solution_values = (solution_values..., next...)
        #= none:38 =#
        solution_names = (solution_names..., tracer_names...)
        #= none:40 =#
        return NamedTuple{solution_names}(solution_values)
    end
#= none:44 =#
with_tracers(tracer_names, ::Nothing, args...; kwargs...) = begin
        #= none:44 =#
        nothing
    end