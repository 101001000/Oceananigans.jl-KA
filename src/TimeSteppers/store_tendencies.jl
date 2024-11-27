
#= none:1 =#
using Oceananigans: prognostic_fields
#= none:2 =#
using Oceananigans.Grids: AbstractGrid
#= none:3 =#
using Oceananigans.Utils: launch!
#= none:5 =#
#= none:5 =# Core.@doc " Store source terms for `u`, `v`, and `w`. " #= none:6 =# @kernel(function store_field_tendencies!(G⁻, G⁰)
            #= none:6 =#
            #= none:7 =#
            (i, j, k) = #= none:7 =# @index(Global, NTuple)
            #= none:8 =#
            #= none:8 =# @inbounds G⁻[i, j, k] = G⁰[i, j, k]
        end)
#= none:11 =#
#= none:11 =# Core.@doc " Store previous source terms before updating them. " function store_tendencies!(model)
        #= none:12 =#
        #= none:13 =#
        model_fields = prognostic_fields(model)
        #= none:15 =#
        for field_name = keys(model_fields)
            #= none:16 =#
            launch!(model.architecture, model.grid, :xyz, store_field_tendencies!, model.timestepper.G⁻[field_name], model.timestepper.Gⁿ[field_name])
            #= none:19 =#
        end
        #= none:21 =#
        return nothing
    end