
#= none:1 =#
using Statistics
#= none:2 =#
import Statistics.mean
#= none:3 =#
import Statistics.norm
#= none:4 =#
import Statistics.dot
#= none:6 =#
reductions = (:(Base.sum), :(Base.maximum), :(Base.minimum), :(Base.prod), :(Base.any), :(Base.all), :(Statistics.mean))
#= none:17 =#
for reduction = reductions
    #= none:18 =#
    #= none:18 =# @eval begin
            #= none:19 =#
            function $reduction(f::Function, c::MultiRegionField; kwargs...)
                #= none:19 =#
                #= none:20 =#
                mr = construct_regionally($reduction, f, c; kwargs...)
                #= none:21 =#
                if mr.regional_objects isa NTuple{<:Any, <:Number}
                    #= none:22 =#
                    return $reduction([r for r = mr.regional_objects])
                else
                    #= none:24 =#
                    FT = eltype(first(mr.regional_objects))
                    #= none:25 =#
                    loc = location(first(mr.regional_objects))
                    #= none:26 =#
                    validate_reduction_location!(loc, c.grid.partition)
                    #= none:27 =#
                    mrg = MultiRegionGrid{FT, loc[1], loc[2], loc[3]}(architecture(c), c.grid.partition, MultiRegionObject(collect_grid(mr.regional_objects), devices(mr)), devices(mr))
                    #= none:29 =#
                    data = MultiRegionObject(collect_data(mr.regional_objects), devices(mr))
                    #= none:30 =#
                    bcs = MultiRegionObject(collect_bcs(mr.regional_objects), devices(mr))
                    #= none:31 =#
                    return Field{loc[1], loc[2], loc[3]}(mrg, data, bcs, c.operand, c.status)
                end
            end
        end
    #= none:35 =#
end
#= none:37 =#
Statistics.mean(c::MultiRegionField; kwargs...) = begin
        #= none:37 =#
        Statistics.mean(identity, c; kwargs...)
    end
#= none:39 =#
validate_reduction_location!(loc, p) = begin
        #= none:39 =#
        nothing
    end
#= none:40 =#
validate_reduction_location!(loc, ::XPartition) = begin
        #= none:40 =#
        loc[1] == Nothing && error("Partial reductions across X with XPartition are not supported yet")
    end
#= none:41 =#
validate_reduction_location!(loc, ::YPartition) = begin
        #= none:41 =#
        loc[2] == Nothing && error("Partial reductions across Y with YPartition are not supported yet")
    end
#= none:43 =#
(collect_data(f::NTuple{N, <:Field}) where N) = begin
        #= none:43 =#
        Tuple(((f[i]).data for i = 1:N))
    end
#= none:44 =#
(collect_bcs(f::NTuple{N, <:Field}) where N) = begin
        #= none:44 =#
        Tuple(((f[i]).boundary_conditions for i = 1:N))
    end
#= none:45 =#
(collect_grid(f::NTuple{N, <:Field}) where N) = begin
        #= none:45 =#
        Tuple(((f[i]).grid for i = 1:N))
    end
#= none:47 =#
const MRD = Union{MultiRegionField, MultiRegionObject}
#= none:50 =#
Statistics.dot(f::MRD, g::MRD) = begin
        #= none:50 =#
        sum([r for r = (construct_regionally(dot, f, g)).regional_objects])
    end
#= none:51 =#
Statistics.norm(f::MRD) = begin
        #= none:51 =#
        sqrt(dot(f, f))
    end