
#= none:1 =#
#= none:1 =# @inline zeroforcing(args...) = begin
            #= none:1 =#
            0
        end
#= none:3 =#
#= none:3 =# Core.@doc "    regularize_forcing(forcing, field, field_name, model_field_names)\n\n\"Regularizes\" or \"adds information\" to user-defined forcing objects that are passed to\nmodel constructors. `regularize_forcing` is called inside `model_forcing`.\n\nWe need `regularize_forcing` because it is only until `model_forcing` is called that\nthe fields (and field locations) of various forcing functions are available. The `field`\ncan be used to infer the location at which the forcing is applied, or to add a field\ndependency to a special forcing object, as for `Relxation`.\n" regularize_forcing(forcing, field, field_name, model_field_names) = begin
            #= none:14 =#
            forcing
        end
#= none:16 =#
#= none:16 =# Core.@doc "    regularize_forcing(forcing::Function, field, field_name, model_field_names)\n\nWrap `forcing` in a `ContinuousForcing` at the location of `field`.\n" function regularize_forcing(forcing::Function, field, field_name, model_field_names)
        #= none:21 =#
        #= none:22 =#
        (LX, LY, LZ) = location(field)
        #= none:23 =#
        return ContinuousForcing{LX, LY, LZ}(forcing)
    end
#= none:26 =#
regularize_forcing(::Nothing, field::AbstractField, field_name, model_field_names) = begin
        #= none:26 =#
        zeroforcing
    end
#= none:29 =#
regularize_forcing(array::AbstractArray, field::AbstractField, field_name, model_field_names) = begin
        #= none:29 =#
        Forcing(array)
    end
#= none:30 =#
regularize_forcing(fts::FlavorOfFTS, field::AbstractField, field_name, model_field_names) = begin
        #= none:30 =#
        Forcing(fts)
    end
#= none:33 =#
#= none:33 =# Core.@doc "    model_forcing(model_fields; forcings...)\n\nReturn a `NamedTuple` of forcing functions for each field in `model_fields`, wrapping\nforcing functions in `ContinuousForcing`s and ensuring that `ContinuousForcing`s are\nlocated correctly for each field.\n" function model_forcing(model_fields; forcings...)
        #= none:40 =#
        #= none:42 =#
        model_field_names = keys(model_fields)
        #= none:44 =#
        regularized_forcings = Tuple((if field_name in keys(forcings)
                    regularize_forcing(forcings[field_name], field, field_name, model_field_names)
                else
                    regularize_forcing(nothing, field, field_name, model_field_names)
                end for (field_name, field) = pairs(model_fields)))
        #= none:51 =#
        specified_forcings = NamedTuple{model_field_names}(regularized_forcings)
        #= none:53 =#
        return specified_forcings
    end