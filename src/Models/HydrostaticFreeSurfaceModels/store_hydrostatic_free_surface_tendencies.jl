
#= none:1 =#
using KernelAbstractions: @index, @kernel
#= none:3 =#
using Oceananigans.TimeSteppers: store_field_tendencies!
#= none:5 =#
using Oceananigans: prognostic_fields
#= none:6 =#
using Oceananigans.Grids: AbstractGrid
#= none:7 =#
using Oceananigans.ImmersedBoundaries: retrieve_interior_active_cells_map
#= none:9 =#
using Oceananigans.Utils: launch!
#= none:11 =#
import Oceananigans.TimeSteppers: store_tendencies!
#= none:13 =#
#= none:13 =# Core.@doc " Store source terms for `η`. " #= none:14 =# @kernel(function _store_free_surface_tendency!(Gη⁻, grid, Gη⁰)
            #= none:14 =#
            #= none:15 =#
            (i, j) = #= none:15 =# @index(Global, NTuple)
            #= none:16 =#
            #= none:16 =# @inbounds Gη⁻[i, j, grid.Nz + 1] = Gη⁰[i, j, grid.Nz + 1]
        end)
#= none:19 =#
store_free_surface_tendency!(free_surface, model) = begin
        #= none:19 =#
        nothing
    end
#= none:21 =#
function store_free_surface_tendency!(::ExplicitFreeSurface, model)
    #= none:21 =#
    #= none:22 =#
    launch!(model.architecture, model.grid, :xy, _store_free_surface_tendency!, model.timestepper.G⁻.η, model.grid, model.timestepper.Gⁿ.η)
end
#= none:29 =#
#= none:29 =# Core.@doc " Store previous source terms before updating them. " function store_tendencies!(model::HydrostaticFreeSurfaceModel)
        #= none:30 =#
        #= none:31 =#
        prognostic_field_names = keys(prognostic_fields(model))
        #= none:32 =#
        three_dimensional_prognostic_field_names = filter((name->begin
                        #= none:32 =#
                        name != :η
                    end), prognostic_field_names)
        #= none:34 =#
        closure = model.closure
        #= none:36 =#
        for field_name = three_dimensional_prognostic_field_names
            #= none:38 =#
            if closure isa FlavorOfCATKE && field_name == :e
                #= none:39 =#
                #= none:39 =# @debug "Skipping store tendencies for e"
            elseif #= none:40 =# closure isa FlavorOfTD && field_name == :ϵ
                #= none:41 =#
                #= none:41 =# @debug "Skipping store tendencies for ϵ"
            elseif #= none:42 =# closure isa FlavorOfTD && field_name == :e
                #= none:43 =#
                #= none:43 =# @debug "Skipping store tendencies for e"
            else
                #= none:45 =#
                launch!(model.architecture, model.grid, :xyz, store_field_tendencies!, model.timestepper.G⁻[field_name], model.timestepper.Gⁿ[field_name])
            end
            #= none:50 =#
        end
        #= none:52 =#
        store_free_surface_tendency!(model.free_surface, model)
        #= none:54 =#
        return nothing
    end