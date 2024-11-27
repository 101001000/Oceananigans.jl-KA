
#= none:1 =#
#= none:1 =# Core.@doc "    validate_grid(a::AbstractField, b::AbstractField)\n\nConfirm that `a` and `b` are on the same grid if both are fields and return `a.grid`.\n" function validate_grid(a::AbstractField, b::AbstractField)
        #= none:6 =#
        #= none:7 =#
        a.grid == b.grid || throw(ArgumentError("Fields in an AbstractOperation must be on the same grid."))
        #= none:8 =#
        return a.grid
    end
#= none:11 =#
#= none:11 =# Core.@doc "Return `a.grid` when `b` is not an `AbstractField`." validate_grid(a::AbstractField, b) = begin
            #= none:12 =#
            a.grid
        end
#= none:14 =#
#= none:14 =# Core.@doc "Return `b.grid` when `a` is not an `AbstractField`." validate_grid(a, b::AbstractField) = begin
            #= none:15 =#
            b.grid
        end
#= none:17 =#
#= none:17 =# Core.@doc "Fallback when neither `a` nor `b` are `AbstractField`s." validate_grid(a, b) = begin
            #= none:18 =#
            nothing
        end
#= none:20 =#
#= none:20 =# Core.@doc "    validate_grid(a, b, c...)\n\nConfirm that the grids associated with the 3+ long list `a, b, c...` are\nconsistent by checking each member against `a`.\nThis function is only correct when `a` is an `AbstractField`, though the\nsubsequent members `b, c...` may be anything.\n" function validate_grid(a, b, c, d...)
        #= none:28 =#
        #= none:29 =#
        grids = []
        #= none:30 =#
        push!(grids, validate_grid(a, b))
        #= none:31 =#
        push!(grids, validate_grid(a, c))
        #= none:32 =#
        append!(grids, [validate_grid(a, di) for di = d])
        #= none:34 =#
        for g = grids
            #= none:35 =#
            if !(g === nothing)
                #= none:36 =#
                return g
            end
            #= none:38 =#
        end
        #= none:40 =#
        return nothing
    end