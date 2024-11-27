
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:3 =#
using Oceananigans: UpdateStateCallsite
#= none:4 =#
using Oceananigans.Advection: AbstractAdvectionScheme
#= none:5 =#
using Oceananigans.Grids: Flat, Bounded
#= none:6 =#
using Oceananigans.Fields: ZeroField
#= none:7 =#
using Oceananigans.Coriolis: AbstractRotation
#= none:8 =#
using Oceananigans.TurbulenceClosures: AbstractTurbulenceClosure
#= none:9 =#
using Oceananigans.TurbulenceClosures.TKEBasedVerticalDiffusivities: CATKEVDArray
#= none:11 =#
import Oceananigans.Grids: validate_size, validate_halo
#= none:12 =#
import Oceananigans.Models: validate_tracer_advection
#= none:13 =#
import Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:14 =#
import Oceananigans.TurbulenceClosures: time_discretization, compute_diffusivities!
#= none:15 =#
import Oceananigans.TurbulenceClosures: ∂ⱼ_τ₁ⱼ, ∂ⱼ_τ₂ⱼ, ∇_dot_qᶜ
#= none:16 =#
import Oceananigans.Coriolis: x_f_cross_U, y_f_cross_U, z_f_cross_U
#= none:22 =#
const SingleColumnGrid = AbstractGrid{<:AbstractFloat, <:Flat, <:Flat, <:Bounded}
#= none:28 =#
PressureField(arch, ::SingleColumnGrid) = begin
        #= none:28 =#
        (pHY′ = nothing,)
    end
#= none:29 =#
materialize_free_surface(free_surface::ExplicitFreeSurface{Nothing}, velocities, ::SingleColumnGrid) = begin
        #= none:29 =#
        nothing
    end
#= none:30 =#
materialize_free_surface(free_surface::ImplicitFreeSurface{Nothing}, velocities, ::SingleColumnGrid) = begin
        #= none:30 =#
        nothing
    end
#= none:31 =#
materialize_free_surface(free_surface::SplitExplicitFreeSurface, velocities, ::SingleColumnGrid) = begin
        #= none:31 =#
        nothing
    end
#= none:32 =#
materialize_free_surface(free_surface::ExplicitFreeSurface{Nothing}, ::PrescribedVelocityFields, ::SingleColumnGrid) = begin
        #= none:32 =#
        nothing
    end
#= none:33 =#
materialize_free_surface(free_surface::ImplicitFreeSurface{Nothing}, ::PrescribedVelocityFields, ::SingleColumnGrid) = begin
        #= none:33 =#
        nothing
    end
#= none:34 =#
materialize_free_surface(free_surface::SplitExplicitFreeSurface, ::PrescribedVelocityFields, ::SingleColumnGrid) = begin
        #= none:34 =#
        nothing
    end
#= none:36 =#
function HydrostaticFreeSurfaceVelocityFields(::Nothing, grid::SingleColumnGrid, clock, bcs = NamedTuple())
    #= none:36 =#
    #= none:37 =#
    u = XFaceField(grid, boundary_conditions = bcs.u)
    #= none:38 =#
    v = YFaceField(grid, boundary_conditions = bcs.v)
    #= none:39 =#
    w = ZeroField()
    #= none:40 =#
    return (u = u, v = v, w = w)
end
#= none:43 =#
validate_velocity_boundary_conditions(::SingleColumnGrid, velocities) = begin
        #= none:43 =#
        nothing
    end
#= none:44 =#
validate_velocity_boundary_conditions(::SingleColumnGrid, ::PrescribedVelocityFields) = begin
        #= none:44 =#
        nothing
    end
#= none:45 =#
validate_momentum_advection(momentum_advection, ::SingleColumnGrid) = begin
        #= none:45 =#
        nothing
    end
#= none:46 =#
validate_tracer_advection(tracer_advection_tuple::NamedTuple, ::SingleColumnGrid) = begin
        #= none:46 =#
        (CenteredSecondOrder(), tracer_advection_tuple)
    end
#= none:47 =#
validate_tracer_advection(tracer_advection::AbstractAdvectionScheme, ::SingleColumnGrid) = begin
        #= none:47 =#
        (tracer_advection, NamedTuple())
    end
#= none:49 =#
compute_w_from_continuity!(velocities, arch, ::SingleColumnGrid; kwargs...) = begin
        #= none:49 =#
        nothing
    end
#= none:50 =#
compute_w_from_continuity!(::PrescribedVelocityFields, arch, ::SingleColumnGrid; kwargs...) = begin
        #= none:50 =#
        nothing
    end
#= none:56 =#
compute_free_surface_tendency!(::SingleColumnGrid, args...) = begin
        #= none:56 =#
        nothing
    end
#= none:59 =#
compute_free_surface_tendency!(::SingleColumnGrid, ::ImplicitFreeSurfaceHFSM, args...) = begin
        #= none:59 =#
        nothing
    end
#= none:60 =#
compute_free_surface_tendency!(::SingleColumnGrid, ::SplitExplicitFreeSurfaceHFSM, args...) = begin
        #= none:60 =#
        nothing
    end
#= none:64 =#
function update_state!(model::HydrostaticFreeSurfaceModel, grid::SingleColumnGrid, callbacks; compute_tendencies = true)
    #= none:64 =#
    #= none:66 =#
    fill_halo_regions!(prognostic_fields(model), model.clock, fields(model))
    #= none:69 =#
    compute_auxiliary_fields!(model.auxiliary_fields)
    #= none:72 =#
    compute_diffusivities!(model.diffusivity_fields, model.closure, model)
    #= none:74 =#
    fill_halo_regions!(model.diffusivity_fields, model.clock, fields(model))
    #= none:76 =#
    for callback = callbacks
        #= none:77 =#
        callback.callsite isa UpdateStateCallsite && callback(model)
        #= none:78 =#
    end
    #= none:80 =#
    update_biogeochemical_state!(model.biogeochemistry, model)
    #= none:82 =#
    compute_tendencies && #= none:83 =# @apply_regionally(compute_tendencies!(model, callbacks))
    #= none:85 =#
    return nothing
end
#= none:88 =#
const ClosureArray = AbstractArray{<:AbstractTurbulenceClosure}
#= none:90 =#
#= none:90 =# @inline function ∂ⱼ_τ₁ⱼ(i, j, k, grid::SingleColumnGrid, closure_array::ClosureArray, args...)
        #= none:90 =#
        #= none:91 =#
        #= none:91 =# @inbounds closure = closure_array[i, j]
        #= none:92 =#
        return ∂ⱼ_τ₁ⱼ(i, j, k, grid, closure, args...)
    end
#= none:95 =#
#= none:95 =# @inline function ∂ⱼ_τ₂ⱼ(i, j, k, grid::SingleColumnGrid, closure_array::ClosureArray, args...)
        #= none:95 =#
        #= none:96 =#
        #= none:96 =# @inbounds closure = closure_array[i, j]
        #= none:97 =#
        return ∂ⱼ_τ₂ⱼ(i, j, k, grid, closure, args...)
    end
#= none:100 =#
#= none:100 =# @inline function ∇_dot_qᶜ(i, j, k, grid::SingleColumnGrid, closure_array::ClosureArray, c, tracer_index, args...)
        #= none:100 =#
        #= none:101 =#
        #= none:101 =# @inbounds closure = closure_array[i, j]
        #= none:102 =#
        return ∇_dot_qᶜ(i, j, k, grid, closure, c, tracer_index, args...)
    end
#= none:105 =#
struct ColumnEnsembleSize{C <: Tuple{Int, Int}}
    #= none:106 =#
    ensemble::C
    #= none:107 =#
    Nz::Int
    #= none:108 =#
    Hz::Int
end
#= none:111 =#
ColumnEnsembleSize(; Nz, ensemble = (0, 0), Hz = 1) = begin
        #= none:111 =#
        ColumnEnsembleSize(ensemble, Nz, Hz)
    end
#= none:113 =#
validate_size(TX, TY, TZ, e::ColumnEnsembleSize) = begin
        #= none:113 =#
        tuple(e.ensemble[1], e.ensemble[2], e.Nz)
    end
#= none:114 =#
validate_halo(TX, TY, TZ, size, e::ColumnEnsembleSize) = begin
        #= none:114 =#
        tuple(0, 0, e.Hz)
    end
#= none:116 =#
#= none:116 =# @inline function time_discretization(closure_array::AbstractArray)
        #= none:116 =#
        #= none:117 =#
        first_closure = #= none:117 =# @allowscalar(first(closure_array))
        #= none:118 =#
        return time_discretization(first_closure)
    end
#= none:125 =#
#= none:125 =# @inline tracer_tendency_kernel_function(model::HydrostaticFreeSurfaceModel, closure::CATKEVDArray, ::Val{:e}) = begin
            #= none:125 =#
            hydrostatic_turbulent_kinetic_energy_tendency
        end
#= none:128 =#
#= none:128 =# @inline function hydrostatic_turbulent_kinetic_energy_tendency(i, j, k, grid::SingleColumnGrid, val_tracer_index::Val{tracer_index}, advection, closure_array::CATKEVDArray, args...) where tracer_index
        #= none:128 =#
        #= none:133 =#
        #= none:133 =# @inbounds closure = closure_array[i, j]
        #= none:134 =#
        return hydrostatic_turbulent_kinetic_energy_tendency(i, j, k, grid, val_tracer_index, advection, closure, args...)
    end
#= none:141 =#
const CoriolisArray = AbstractArray{<:AbstractRotation}
#= none:143 =#
#= none:143 =# @inline function x_f_cross_U(i, j, k, grid::SingleColumnGrid, coriolis_array::CoriolisArray, U)
        #= none:143 =#
        #= none:144 =#
        #= none:144 =# @inbounds coriolis = coriolis_array[i, j]
        #= none:145 =#
        return x_f_cross_U(i, j, k, grid, coriolis, U)
    end
#= none:148 =#
#= none:148 =# @inline function y_f_cross_U(i, j, k, grid::SingleColumnGrid, coriolis_array::CoriolisArray, U)
        #= none:148 =#
        #= none:149 =#
        #= none:149 =# @inbounds coriolis = coriolis_array[i, j]
        #= none:150 =#
        return y_f_cross_U(i, j, k, grid, coriolis, U)
    end