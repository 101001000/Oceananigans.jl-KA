
#= none:1 =#
using Oceananigans.AbstractOperations: AbstractOperation
#= none:2 =#
using Oceananigans.Fields: flattened_unique_values
#= none:8 =#
extract_field_time_series(t1, tn...) = begin
        #= none:8 =#
        extract_field_time_series(tuple(t1, tn...))
    end
#= none:11 =#
function extract_field_time_series(t)
    #= none:11 =#
    #= none:12 =#
    prop = propertynames(t)
    #= none:13 =#
    if isempty(prop)
        #= none:14 =#
        return nothing
    end
    #= none:17 =#
    extracted = Tuple((extract_field_time_series(getproperty(t, p)) for p = prop))
    #= none:18 =#
    flattened = flattened_unique_values(extracted)
    #= none:20 =#
    return flattened
end
#= none:24 =#
extract_field_time_series(f::FieldTimeSeries) = begin
        #= none:24 =#
        f
    end
#= none:27 =#
CannotPossiblyContainFTS = (:Number, :AbstractArray)
#= none:29 =#
for T = CannotPossiblyContainFTS
    #= none:30 =#
    #= none:30 =# @eval extract_field_time_series(::$T) = begin
                #= none:30 =#
                nothing
            end
    #= none:31 =#
end
#= none:34 =#
extract_field_time_series(t::AbstractField) = begin
        #= none:34 =#
        Tuple((extract_field_time_series(getproperty(t, p)) for p = propertynames(t)))
    end
#= none:35 =#
extract_field_time_series(t::AbstractOperation) = begin
        #= none:35 =#
        Tuple((extract_field_time_series(getproperty(t, p)) for p = propertynames(t)))
    end
#= none:37 =#
extract_field_time_series(t::Union{Tuple, NamedTuple}) = begin
        #= none:37 =#
        map(extract_field_time_series, t)
    end