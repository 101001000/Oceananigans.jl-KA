
#= none:1 =#
#= none:1 =# @inline field_arguments(i, j, k, grid, model_fields, ℑ, idx::NTuple{1}) = begin
            #= none:1 =#
            #= none:2 =# @inbounds ((ℑ[1])(i, j, k, grid, model_fields[idx[1]]),)
        end
#= none:4 =#
#= none:4 =# @inline field_arguments(i, j, k, grid, model_fields, ℑ, idx::NTuple{2}) = begin
            #= none:4 =#
            #= none:5 =# @inbounds ((ℑ[1])(i, j, k, grid, model_fields[idx[1]]), (ℑ[2])(i, j, k, grid, model_fields[idx[2]]))
        end
#= none:8 =#
#= none:8 =# @inline field_arguments(i, j, k, grid, model_fields, ℑ, idx::NTuple{3}) = begin
            #= none:8 =#
            #= none:9 =# @inbounds ((ℑ[1])(i, j, k, grid, model_fields[idx[1]]), (ℑ[2])(i, j, k, grid, model_fields[idx[2]]), (ℑ[3])(i, j, k, grid, model_fields[idx[3]]))
        end
#= none:13 =#
#= none:13 =# @inline (field_arguments(i, j, k, grid, model_fields, ℑ, idx::NTuple{N}) where N) = begin
            #= none:13 =#
            #= none:14 =# @inbounds ntuple((n->begin
                            #= none:14 =#
                            (ℑ[n])(i, j, k, grid, model_fields[idx[n]])
                        end), Val(N))
        end
#= none:16 =#
#= none:16 =# Core.@doc " Returns field arguments in user-defined functions for forcing and boundary conditions." #= none:17 =# @inline(function user_function_arguments(i, j, k, grid, model_fields, ::Nothing, user_func)
            #= none:17 =#
            #= none:19 =#
            ℑ = user_func.field_dependencies_interp
            #= none:20 =#
            idx = user_func.field_dependencies_indices
            #= none:21 =#
            return field_arguments(i, j, k, grid, model_fields, ℑ, idx)
        end)
#= none:24 =#
#= none:24 =# Core.@doc " Returns field arguments plus parameters in user-defined functions for forcing and boundary conditions." #= none:25 =# @inline(function user_function_arguments(i, j, k, grid, model_fields, parameters, user_func)
            #= none:25 =#
            #= none:27 =#
            ℑ = user_func.field_dependencies_interp
            #= none:28 =#
            idx = user_func.field_dependencies_indices
            #= none:29 =#
            parameters = user_func.parameters
            #= none:31 =#
            field_args = field_arguments(i, j, k, grid, model_fields, ℑ, idx)
            #= none:33 =#
            return tuple(field_args..., parameters)
        end)