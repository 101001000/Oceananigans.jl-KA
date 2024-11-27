
#= none:1 =#
using Statistics
#= none:2 =#
import Oceananigans.Fields: conditional_length
#= none:4 =#
#= none:4 =# @inline conditional_length(fts::FieldTimeSeries) = begin
            #= none:4 =#
            length(fts) * conditional_length(fts[1])
        end
#= none:11 =#
#= none:11 =# @inline Base.size(fts::FieldTimeSeries) = begin
            #= none:11 =#
            (size(fts.grid, location(fts), fts.indices)..., length(fts.times))
        end
#= none:12 =#
#= none:12 =# @propagate_inbounds Base.setindex!(fts::FieldTimeSeries, val, inds...) = begin
            #= none:12 =#
            Base.setindex!(fts.data, val, inds...)
        end
#= none:20 =#
for reduction = (:sum, :maximum, :minimum, :all, :any, :prod)
    #= none:21 =#
    reduction! = Symbol(reduction, '!')
    #= none:23 =#
    #= none:23 =# @eval begin
            #= none:26 =#
            function Base.$(reduction)(f::Function, fts::FTS; dims = (:), kw...)
                #= none:26 =#
                #= none:27 =#
                if dims isa Colon
                    #= none:28 =#
                    return Base.$(reduction)(($reduction(f, fts[n]; kw...) for n = 1:length(fts.times)))
                else
                    #= none:30 =#
                    T = filltype(Base.$(reduction!), fts)
                    #= none:31 =#
                    loc = ((LX, LY, LZ) = reduced_location(location(fts); dims))
                    #= none:32 =#
                    times = fts.times
                    #= none:33 =#
                    rts = FieldTimeSeries{LX, LY, LZ}(grid, times, T; indices = fts.indices)
                    #= none:34 =#
                    return Base.$(reduction!)(f, rts, fts; kw...)
                end
            end
            #= none:38 =#
            Base.$(reduction)(fts::FTS; kw...) = begin
                    #= none:38 =#
                    Base.$(reduction)(identity, fts; kw...)
                end
            #= none:40 =#
            function Base.$(reduction!)(f::Function, rts::FTS, fts::FTS; dims = (:), kw...)
                #= none:40 =#
                #= none:41 =#
                dims isa Tuple && (4 ∈ dims && error("Reduction across the time dimension (dim=4) is not yet supported!"))
                #= none:42 =#
                for n = 1:length(rts)
                    #= none:43 =#
                    Base.$(reduction!)(f, rts[i], fts[i]; dims, kw...)
                    #= none:44 =#
                end
                #= none:45 =#
                return rts
            end
            #= none:48 =#
            Base.$(reduction!)(rts::FTS, fts::FTS; kw...) = begin
                    #= none:48 =#
                    Base.$(reduction!)(identity, rts, fts; kw...)
                end
        end
    #= none:50 =#
end