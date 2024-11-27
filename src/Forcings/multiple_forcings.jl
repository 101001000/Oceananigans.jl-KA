
#= none:1 =#
using Adapt
#= none:3 =#
struct MultipleForcings{N, F}
    #= none:4 =#
    forcings::F
end
#= none:7 =#
Adapt.adapt_structure(to, mf::MultipleForcings) = begin
        #= none:7 =#
        MultipleForcings(adapt(to, mf.forcings))
    end
#= none:8 =#
on_architecture(to, mf::MultipleForcings) = begin
        #= none:8 =#
        MultipleForcings(on_architecture(to, mf.forcings))
    end
#= none:10 =#
Base.getindex(mf::MultipleForcings, i) = begin
        #= none:10 =#
        mf.forcings[i]
    end
#= none:12 =#
#= none:12 =# Core.@doc "    MultipleForcings(forcings)\n\nReturn a lightweight tuple-wrapper representing multiple user-defined `forcings`.\nEach forcing in `forcings` is added to the specified field's tendency.\n" function MultipleForcings(forcings)
        #= none:18 =#
        #= none:19 =#
        N = length(forcings)
        #= none:20 =#
        F = typeof(forcings)
        #= none:21 =#
        return MultipleForcings{N, F}(forcings)
    end
#= none:24 =#
MultipleForcings(args...) = begin
        #= none:24 =#
        MultipleForcings(tuple(args...))
    end
#= none:26 =#
function regularize_forcing(forcing_tuple::Tuple, field, field_name, model_field_names)
    #= none:26 =#
    #= none:27 =#
    forcings = Tuple((regularize_forcing(f, field, field_name, model_field_names) for f = forcing_tuple))
    #= none:29 =#
    return MultipleForcings(forcings)
end
#= none:32 =#
regularize_forcing(mf::MultipleForcings, args...) = begin
        #= none:32 =#
        regularize_forcing(mf.forcings, args...)
    end
#= none:34 =#
#= none:34 =# @inline (mf::MultipleForcings{1})(i, j, k, grid, clock, model_fields) = begin
            #= none:34 =#
            (mf.forcings[1])(i, j, k, grid, clock, model_fields)
        end
#= none:36 =#
#= none:36 =# @inline (mf::MultipleForcings{2})(i, j, k, grid, clock, model_fields) = begin
            #= none:36 =#
            (mf.forcings[1])(i, j, k, grid, clock, model_fields) + (mf.forcings[2])(i, j, k, grid, clock, model_fields)
        end
#= none:39 =#
#= none:39 =# @inline (mf::MultipleForcings{3})(i, j, k, grid, clock, model_fields) = begin
            #= none:39 =#
            (mf.forcings[1])(i, j, k, grid, clock, model_fields) + (mf.forcings[2])(i, j, k, grid, clock, model_fields) + (mf.forcings[3])(i, j, k, grid, clock, model_fields)
        end
#= none:43 =#
#= none:43 =# @inline (mf::MultipleForcings{4})(i, j, k, grid, clock, model_fields) = begin
            #= none:43 =#
            (mf.forcings[1])(i, j, k, grid, clock, model_fields) + (mf.forcings[2])(i, j, k, grid, clock, model_fields) + (mf.forcings[3])(i, j, k, grid, clock, model_fields) + (mf.forcings[4])(i, j, k, grid, clock, model_fields)
        end
#= none:48 =#
#= none:48 =# @generated function (mf::MultipleForcings{N})(i, j, k, grid, clock, model_fields) where N
        #= none:48 =#
        #= none:49 =#
        quote
            #= none:50 =#
            total_forcing = zero(grid)
            #= none:51 =#
            forcings = mf.forcings
            #= none:52 =#
            #= none:52 =# Base.@_inline_meta
            #= none:53 =#
            $([:(#= none:53 =# @inbounds(total_forcing += (forcings[$n])(i, j, k, grid, clock, model_fields))) for n = 1:N]...)
            #= none:54 =#
            return total_forcing
        end
    end
#= none:58 =#
Base.summary(mf::MultipleForcings) = begin
        #= none:58 =#
        string("MultipleForcings with ", length(mf.forcings), " forcing", ifelse(length(mf.forcings) > 1, "s", ""))
    end
#= none:61 =#
function Base.show(io::IO, mf::MultipleForcings)
    #= none:61 =#
    #= none:62 =#
    start = summary(mf) * ":"
    #= none:64 =#
    Nf = length(mf.forcings)
    #= none:65 =#
    if Nf > 1
        #= none:66 =#
        body = [string("├ ", prettysummary(f), "\n") for f = mf.forcings[1:end - 1]]
    else
        #= none:68 =#
        body = []
    end
    #= none:71 =#
    push!(body, string("└ ", prettysummary(mf.forcings[end])))
    #= none:73 =#
    print(io, start, "\n", body...)
    #= none:75 =#
    return nothing
end