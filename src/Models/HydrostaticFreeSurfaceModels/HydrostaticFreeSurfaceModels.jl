
#= none:1 =#
module HydrostaticFreeSurfaceModels
#= none:1 =#
#= none:3 =#
export HydrostaticFreeSurfaceModel, ExplicitFreeSurface, ImplicitFreeSurface, SplitExplicitFreeSurface, PrescribedVelocityFields
#= none:8 =#
using KernelAbstractions: @index, @kernel
#= none:9 =#
using KernelAbstractions.Extras.LoopInfo: @unroll
#= none:11 =#
using Oceananigans.Utils
#= none:12 =#
using Oceananigans.Utils: launch!, SumOfArrays
#= none:13 =#
using Oceananigans.Grids: AbstractGrid
#= none:15 =#
using DocStringExtensions
#= none:17 =#
import Oceananigans: fields, prognostic_fields, initialize!
#= none:18 =#
import Oceananigans.Advection: cell_advection_timescale
#= none:19 =#
import Oceananigans.TimeSteppers: step_lagrangian_particles!
#= none:20 =#
import Oceananigans.Architectures: on_architecture
#= none:22 =#
abstract type AbstractFreeSurface{E, G} end
#= none:25 =#
fill_horizontal_velocity_halos!(args...) = begin
        #= none:25 =#
        nothing
    end
#= none:31 =#
free_surface_displacement_field(velocities, free_surface, grid) = begin
        #= none:31 =#
        ZFaceField(grid, indices = (:, :, size(grid, 3) + 1))
    end
#= none:32 =#
free_surface_displacement_field(velocities, ::Nothing, grid) = begin
        #= none:32 =#
        nothing
    end
#= none:34 =#
include("compute_w_from_continuity.jl")
#= none:35 =#
include("rigid_lid.jl")
#= none:38 =#
include("explicit_free_surface.jl")
#= none:41 =#
include("implicit_free_surface_utils.jl")
#= none:42 =#
include("compute_vertically_integrated_variables.jl")
#= none:43 =#
include("fft_based_implicit_free_surface_solver.jl")
#= none:44 =#
include("pcg_implicit_free_surface_solver.jl")
#= none:45 =#
include("matrix_implicit_free_surface_solver.jl")
#= none:46 =#
include("implicit_free_surface.jl")
#= none:49 =#
include("split_explicit_free_surface.jl")
#= none:50 =#
include("distributed_split_explicit_free_surface.jl")
#= none:51 =#
include("split_explicit_free_surface_kernels.jl")
#= none:53 =#
include("hydrostatic_free_surface_field_tuples.jl")
#= none:54 =#
include("hydrostatic_free_surface_model.jl")
#= none:55 =#
include("show_hydrostatic_free_surface_model.jl")
#= none:56 =#
include("set_hydrostatic_free_surface_model.jl")
#= none:62 =#
cell_advection_timescale(model::HydrostaticFreeSurfaceModel) = begin
        #= none:62 =#
        cell_advection_timescale(model.grid, model.velocities)
    end
#= none:64 =#
#= none:64 =# Core.@doc "    fields(model::HydrostaticFreeSurfaceModel)\n\nReturn a flattened `NamedTuple` of the fields in `model.velocities`, `model.free_surface`,\n`model.tracers`, and any auxiliary fields for a `HydrostaticFreeSurfaceModel` model.\n" #= none:70 =# @inline(fields(model::HydrostaticFreeSurfaceModel) = begin
                #= none:70 =#
                merge(hydrostatic_fields(model.velocities, model.free_surface, model.tracers), model.auxiliary_fields, biogeochemical_auxiliary_fields(model.biogeochemistry))
            end)
#= none:75 =#
#= none:75 =# Core.@doc "    prognostic_fields(model::HydrostaticFreeSurfaceModel)\n\nReturn a flattened `NamedTuple` of the prognostic fields associated with `HydrostaticFreeSurfaceModel`.\n" #= none:80 =# @inline(prognostic_fields(model::HydrostaticFreeSurfaceModel) = begin
                #= none:80 =#
                hydrostatic_prognostic_fields(model.velocities, model.free_surface, model.tracers)
            end)
#= none:83 =#
#= none:83 =# @inline hydrostatic_prognostic_fields(velocities, free_surface, tracers) = begin
            #= none:83 =#
            merge((u = velocities.u, v = velocities.v, η = free_surface.η), tracers)
        end
#= none:88 =#
#= none:88 =# @inline hydrostatic_prognostic_fields(velocities, ::Nothing, tracers) = begin
            #= none:88 =#
            merge((u = velocities.u, v = velocities.v), tracers)
        end
#= none:92 =#
#= none:92 =# @inline hydrostatic_fields(velocities, free_surface, tracers) = begin
            #= none:92 =#
            merge((u = velocities.u, v = velocities.v, w = velocities.w), tracers, (; η = free_surface.η))
        end
#= none:98 =#
#= none:98 =# @inline hydrostatic_fields(velocities, ::Nothing, tracers) = begin
            #= none:98 =#
            merge((u = velocities.u, v = velocities.v, w = velocities.w), tracers)
        end
#= none:103 =#
displacement(free_surface) = begin
        #= none:103 =#
        free_surface.η
    end
#= none:104 =#
displacement(::Nothing) = begin
        #= none:104 =#
        nothing
    end
#= none:107 =#
step_lagrangian_particles!(model::HydrostaticFreeSurfaceModel, Δt) = begin
        #= none:107 =#
        step_lagrangian_particles!(model.particles, model, Δt)
    end
#= none:109 =#
include("barotropic_pressure_correction.jl")
#= none:110 =#
include("hydrostatic_free_surface_tendency_kernel_functions.jl")
#= none:111 =#
include("compute_hydrostatic_free_surface_tendencies.jl")
#= none:112 =#
include("compute_hydrostatic_free_surface_buffers.jl")
#= none:113 =#
include("update_hydrostatic_free_surface_model_state.jl")
#= none:114 =#
include("hydrostatic_free_surface_ab2_step.jl")
#= none:115 =#
include("store_hydrostatic_free_surface_tendencies.jl")
#= none:116 =#
include("prescribed_hydrostatic_velocity_fields.jl")
#= none:117 =#
include("single_column_model_mode.jl")
#= none:118 =#
include("slice_ensemble_model_mode.jl")
#= none:124 =#
include("vertical_vorticity_field.jl")
end