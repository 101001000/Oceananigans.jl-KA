
#= none:1 =#
#= none:1 =# Core.@doc "    insert_location(ex::Expr, location)\n\nInsert a symbolic representation of `location` into the arguments of an `expression`.\n\nUsed in the `@at` macro for specifying the location of an `AbstractOperation`.\n" function insert_location!(ex::Expr, location)
        #= none:8 =#
        #= none:9 =#
        if ex.head === :call && ex.args[1] ∈ operators
            #= none:10 =#
            push!(ex.args, ex.args[end])
            #= none:11 =#
            ex.args[3:end - 1] .= ex.args[2:end - 2]
            #= none:12 =#
            ex.args[2] = location
        end
        #= none:15 =#
        for arg = ex.args
            #= none:16 =#
            insert_location!(arg, location)
            #= none:17 =#
        end
        #= none:19 =#
        return nothing
    end
#= none:22 =#
#= none:22 =# Core.@doc "Fallback for when `insert_location` is called on objects other than expressions." insert_location!(anything, location) = begin
            #= none:23 =#
            nothing
        end
#= none:26 =#
#= none:26 =# @inline interpolate_identity(x) = begin
            #= none:26 =#
            x
        end
#= none:27 =#
#= none:27 =# @unary interpolate_identity
#= none:29 =#
interpolate_operation(L, x) = begin
        #= none:29 =#
        x
    end
#= none:31 =#
function interpolate_operation(L, x::AbstractField)
    #= none:31 =#
    #= none:32 =#
    L == location(x) && return x
    #= none:33 =#
    return interpolate_identity(L, x)
end
#= none:36 =#
#= none:36 =# Core.@doc "    @at location abstract_operation\n\nModify the `abstract_operation` so that it returns values at\n`location`, where `location` is a 3-tuple of `Face`s and `Center`s.\n" macro at(location, abstract_operation)
        #= none:42 =#
        #= none:43 =#
        insert_location!(abstract_operation, location)
        #= none:47 =#
        wrapped_operation = quote
                #= none:48 =#
                interpolate_operation($(esc(location)), $(esc(abstract_operation)))
            end
        #= none:51 =#
        return wrapped_operation
    end
#= none:54 =#
using Oceananigans.Fields: default_indices
#= none:57 =#
indices(f::Function) = begin
        #= none:57 =#
        default_indices(3)
    end
#= none:58 =#
indices(f::Number) = begin
        #= none:58 =#
        default_indices(3)
    end
#= none:60 =#
#= none:60 =# Core.@doc "    intersect_indices(loc, operands...)\n\nUtility to compute the intersection of `operands' indices.\n" function intersect_indices(loc, operands...)
        #= none:65 =#
        #= none:67 =#
        idx1 = compute_index_intersection(Colon(), loc[1], operands...; dim = 1)
        #= none:68 =#
        idx2 = compute_index_intersection(Colon(), loc[2], operands...; dim = 2)
        #= none:69 =#
        idx3 = compute_index_intersection(Colon(), loc[3], operands...; dim = 3)
        #= none:71 =#
        return (idx1, idx2, idx3)
    end
#= none:75 =#
compute_index_intersection(::Colon, to_loc; kw...) = begin
        #= none:75 =#
        Colon()
    end
#= none:77 =#
compute_index_intersection(to_idx, to_loc, op; dim) = begin
        #= none:77 =#
        _compute_index_intersection(to_idx, (indices(op))[dim], to_loc, location(op, dim))
    end
#= none:81 =#
#= none:81 =# Core.@doc "Compute index intersection recursively for `dim`ension ∈ (1, 2, 3)." function compute_index_intersection(to_idx, to_loc, op1, op2, more_ops...; dim)
        #= none:82 =#
        #= none:83 =#
        new_to_idx = _compute_index_intersection(to_idx, (indices(op1))[dim], to_loc, location(op1, dim))
        #= none:84 =#
        return compute_index_intersection(new_to_idx, to_loc, op2, more_ops...; dim)
    end
#= none:88 =#
_compute_index_intersection(to_idx::Colon, from_idx::Colon, args...) = begin
        #= none:88 =#
        Colon()
    end
#= none:91 =#
_compute_index_intersection(to_idx::UnitRange, from_idx::Colon, args...) = begin
        #= none:91 =#
        to_idx
    end
#= none:94 =#
function _compute_index_intersection(to_idx::Colon, from_idx::UnitRange, to_loc, from_loc)
    #= none:94 =#
    #= none:95 =#
    shifted_idx = restrict_index_for_interpolation(from_idx, from_loc, to_loc)
    #= none:96 =#
    validate_shifted_index(shifted_idx)
    #= none:97 =#
    return shifted_idx
end
#= none:101 =#
function _compute_index_intersection(to_idx::UnitRange, from_idx::UnitRange, to_loc, from_loc)
    #= none:101 =#
    #= none:102 =#
    shifted_idx = restrict_index_for_interpolation(from_idx, from_loc, to_loc)
    #= none:103 =#
    validate_shifted_index(shifted_idx)
    #= none:105 =#
    range_intersection = UnitRange(max(first(shifted_idx), first(to_idx)), min(last(shifted_idx), last(to_idx)))
    #= none:108 =#
    first(range_intersection) > last(range_intersection) && throw(ArgumentError("Indices $(from_idx) and $(to_idx) interpolated from $(from_loc) to $(to_loc) do not intersect!"))
    #= none:111 =#
    return range_intersection
end
#= none:114 =#
validate_shifted_index(shifted_idx) = begin
        #= none:114 =#
        first(shifted_idx) > last(shifted_idx) && throw(ArgumentError("Cannot compute index intersection for indices $(from_idx) interpolating from $(from_loc) to $(to_loc)!"))
    end
#= none:117 =#
#= none:117 =# Core.@doc "    restrict_index_for_interpolation(from_idx, from_loc, to_loc)\n\nReturn a \"restricted\" index range for the result of interpolating from\n`from_loc` to `to_loc`, over the index range `from_idx`:\n\n* Windowed fields interpolated from `Center`s to `Face`s lose the first index.\n* Conversely, windowed fields interpolated from `Face`s to `Center`s lose the last index\n" restrict_index_for_interpolation(from_idx, ::Type{Face}, ::Type{Face}) = begin
            #= none:126 =#
            UnitRange(first(from_idx), last(from_idx))
        end
#= none:127 =#
restrict_index_for_interpolation(from_idx, ::Type{Center}, ::Type{Center}) = begin
        #= none:127 =#
        UnitRange(first(from_idx), last(from_idx))
    end
#= none:128 =#
restrict_index_for_interpolation(from_idx, ::Type{Face}, ::Type{Center}) = begin
        #= none:128 =#
        UnitRange(first(from_idx), last(from_idx) - 1)
    end
#= none:129 =#
restrict_index_for_interpolation(from_idx, ::Type{Center}, ::Type{Face}) = begin
        #= none:129 =#
        UnitRange(first(from_idx) + 1, last(from_idx))
    end