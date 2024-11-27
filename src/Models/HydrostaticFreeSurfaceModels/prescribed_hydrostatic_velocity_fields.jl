
#= none:5 =#
using Oceananigans.Grids: Center, Face
#= none:6 =#
using Oceananigans.Fields: AbstractField, FunctionField, flatten_tuple
#= none:7 =#
using Oceananigans.TimeSteppers: tick!, step_lagrangian_particles!
#= none:9 =#
import Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:10 =#
import Oceananigans.Models: extract_boundary_conditions
#= none:11 =#
import Oceananigans.Utils: datatuple
#= none:12 =#
import Oceananigans.TimeSteppers: time_step!
#= none:14 =#
using Adapt
#= none:16 =#
struct PrescribedVelocityFields{U, V, W, P}
    #= none:17 =#
    u::U
    #= none:18 =#
    v::V
    #= none:19 =#
    w::W
    #= none:20 =#
    parameters::P
end
#= none:23 =#
#= none:23 =# @inline Base.getindex(U::PrescribedVelocityFields, i) = begin
            #= none:23 =#
            getindex((u = U.u, v = U.v, w = U.w), i)
        end
#= none:25 =#
#= none:25 =# Core.@doc "    PrescribedVelocityFields(; u = ZeroField(),\n                               v = ZeroField(),\n                               w = ZeroField(),\n                               parameters = nothing)\n\nBuilds `PrescribedVelocityFields` with prescribed functions `u`, `v`, and `w`.\n\nIf `isnothing(parameters)`, then `u, v, w` are called with the signature\n\n```\nu(x, y, z, t) = # something interesting\n```\n\nIf `!isnothing(parameters)`, then `u, v, w` are called with the signature\n\n```\nu(x, y, z, t, parameters) = # something parameterized and interesting\n```\n\nIn the constructor for `HydrostaticFreeSurfaceModel`, the functions `u, v, w` are wrapped\nin `FunctionField` and associated with the model's `grid` and `clock`.\n" function PrescribedVelocityFields(; u = ZeroField(), v = ZeroField(), w = ZeroField(), parameters = nothing)
        #= none:48 =#
        #= none:53 =#
        return PrescribedVelocityFields(u, v, w, parameters)
    end
#= none:56 =#
wrap_prescribed_field(X, Y, Z, f::Function, grid; kwargs...) = begin
        #= none:56 =#
        FunctionField{X, Y, Z}(f, grid; kwargs...)
    end
#= none:57 =#
wrap_prescribed_field(X, Y, Z, f, grid; kwargs...) = begin
        #= none:57 =#
        field((X, Y, Z), f, grid)
    end
#= none:59 =#
function HydrostaticFreeSurfaceVelocityFields(velocities::PrescribedVelocityFields, grid, clock, bcs)
    #= none:59 =#
    #= none:61 =#
    parameters = velocities.parameters
    #= none:62 =#
    u = wrap_prescribed_field(Face, Center, Center, velocities.u, grid; clock, parameters)
    #= none:63 =#
    v = wrap_prescribed_field(Center, Face, Center, velocities.v, grid; clock, parameters)
    #= none:64 =#
    w = wrap_prescribed_field(Center, Center, Face, velocities.w, grid; clock, parameters)
    #= none:66 =#
    fill_halo_regions!(u)
    #= none:67 =#
    fill_halo_regions!(v)
    #= none:68 =#
    fill_halo_regions!(w)
    #= none:69 =#
    prescribed_velocities = (; u, v, w)
    #= none:70 =#
    #= none:70 =# @apply_regionally replace_horizontal_vector_halos!(prescribed_velocities, grid)
    #= none:72 =#
    return PrescribedVelocityFields(u, v, w, parameters)
end
#= none:75 =#
function HydrostaticFreeSurfaceTendencyFields(::PrescribedVelocityFields, free_surface, grid, tracer_names)
    #= none:75 =#
    #= none:76 =#
    tracer_tendencies = TracerFields(tracer_names, grid)
    #= none:77 =#
    momentum_tendencies = (u = nothing, v = nothing, η = nothing)
    #= none:78 =#
    return merge(momentum_tendencies, tracer_tendencies)
end
#= none:81 =#
function HydrostaticFreeSurfaceTendencyFields(::PrescribedVelocityFields, ::ExplicitFreeSurface, grid, tracer_names)
    #= none:81 =#
    #= none:82 =#
    tracers = TracerFields(tracer_names, grid)
    #= none:83 =#
    return merge((u = nothing, v = nothing, η = nothing), tracers)
end
#= none:86 =#
#= none:86 =# @inline fill_halo_regions!(::PrescribedVelocityFields, args...) = begin
            #= none:86 =#
            nothing
        end
#= none:87 =#
#= none:87 =# @inline fill_halo_regions!(::FunctionField, args...) = begin
            #= none:87 =#
            nothing
        end
#= none:89 =#
#= none:89 =# @inline datatuple(obj::PrescribedVelocityFields) = begin
            #= none:89 =#
            (; u = datatuple(obj.u), v = datatuple(obj.v), w = datatuple(obj.w))
        end
#= none:91 =#
ab2_step_velocities!(::PrescribedVelocityFields, args...) = begin
        #= none:91 =#
        nothing
    end
#= none:92 =#
ab2_step_free_surface!(::Nothing, model, Δt, χ) = begin
        #= none:92 =#
        nothing
    end
#= none:93 =#
compute_w_from_continuity!(::PrescribedVelocityFields, args...; kwargs...) = begin
        #= none:93 =#
        nothing
    end
#= none:95 =#
validate_velocity_boundary_conditions(grid, ::PrescribedVelocityFields) = begin
        #= none:95 =#
        nothing
    end
#= none:96 =#
extract_boundary_conditions(::PrescribedVelocityFields) = begin
        #= none:96 =#
        NamedTuple()
    end
#= none:98 =#
free_surface_displacement_field(::PrescribedVelocityFields, ::Nothing, grid) = begin
        #= none:98 =#
        nothing
    end
#= none:99 =#
HorizontalVelocityFields(::PrescribedVelocityFields, grid) = begin
        #= none:99 =#
        (nothing, nothing)
    end
#= none:101 =#
materialize_free_surface(::ExplicitFreeSurface{Nothing}, ::PrescribedVelocityFields, grid) = begin
        #= none:101 =#
        nothing
    end
#= none:102 =#
materialize_free_surface(::ImplicitFreeSurface{Nothing}, ::PrescribedVelocityFields, grid) = begin
        #= none:102 =#
        nothing
    end
#= none:103 =#
materialize_free_surface(::SplitExplicitFreeSurface, ::PrescribedVelocityFields, grid) = begin
        #= none:103 =#
        nothing
    end
#= none:105 =#
hydrostatic_prognostic_fields(::PrescribedVelocityFields, ::Nothing, tracers) = begin
        #= none:105 =#
        tracers
    end
#= none:106 =#
compute_hydrostatic_momentum_tendencies!(model, ::PrescribedVelocityFields, kernel_parameters; kwargs...) = begin
        #= none:106 =#
        nothing
    end
#= none:108 =#
apply_flux_bcs!(::Nothing, c, arch, clock, model_fields) = begin
        #= none:108 =#
        nothing
    end
#= none:110 =#
Adapt.adapt_structure(to, velocities::PrescribedVelocityFields) = begin
        #= none:110 =#
        PrescribedVelocityFields(Adapt.adapt(to, velocities.u), Adapt.adapt(to, velocities.v), Adapt.adapt(to, velocities.w), nothing)
    end
#= none:116 =#
on_architecture(to, velocities::PrescribedVelocityFields) = begin
        #= none:116 =#
        PrescribedVelocityFields(on_architecture(to, velocities.u), on_architecture(to, velocities.v), on_architecture(to, velocities.w), on_architecture(to, velocities.parameters))
    end
#= none:123 =#
const OnlyParticleTrackingModel = (HydrostaticFreeSurfaceModel{TS, E, A, S, G, T, V, B, R, F, P, U, C} where {TS, E, A, S, G, T, V, B, R, F, P <: AbstractLagrangianParticles, U <: PrescribedVelocityFields, C <: NamedTuple{(), Tuple{}}})
#= none:126 =#
function time_step!(model::OnlyParticleTrackingModel, Δt; callbacks = [], kwargs...)
    #= none:126 =#
    #= none:127 =#
    tick!(model.clock, Δt)
    #= none:128 =#
    model.clock.last_Δt = Δt
    #= none:129 =#
    step_lagrangian_particles!(model, Δt)
    #= none:130 =#
    update_state!(model, callbacks)
end
#= none:133 =#
update_state!(model::OnlyParticleTrackingModel, callbacks) = begin
        #= none:133 =#
        [callback(model) for callback = callbacks if callback.callsite isa UpdateStateCallsite]
    end