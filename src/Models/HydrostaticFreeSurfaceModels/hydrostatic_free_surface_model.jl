
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:2 =#
using OrderedCollections: OrderedDict
#= none:4 =#
using Oceananigans.DistributedComputations
#= none:5 =#
using Oceananigans.Architectures: AbstractArchitecture
#= none:6 =#
using Oceananigans.Advection: AbstractAdvectionScheme, CenteredSecondOrder, VectorInvariant, adapt_advection_order
#= none:7 =#
using Oceananigans.BuoyancyModels: validate_buoyancy, regularize_buoyancy, SeawaterBuoyancy, g_Earth
#= none:8 =#
using Oceananigans.BoundaryConditions: regularize_field_boundary_conditions
#= none:9 =#
using Oceananigans.Biogeochemistry: validate_biogeochemistry, AbstractBiogeochemistry, biogeochemical_auxiliary_fields
#= none:10 =#
using Oceananigans.Fields: Field, CenterField, tracernames, VelocityFields, TracerFields
#= none:11 =#
using Oceananigans.Forcings: model_forcing
#= none:12 =#
using Oceananigans.Grids: AbstractCurvilinearGrid, AbstractHorizontallyCurvilinearGrid, architecture, halo_size
#= none:13 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid
#= none:14 =#
using Oceananigans.Models: AbstractModel, validate_model_halo, NaNChecker, validate_tracer_advection, extract_boundary_conditions
#= none:15 =#
using Oceananigans.TimeSteppers: Clock, TimeStepper, update_state!, AbstractLagrangianParticles
#= none:16 =#
using Oceananigans.TurbulenceClosures: validate_closure, with_tracers, DiffusivityFields, add_closure_specific_boundary_conditions
#= none:17 =#
using Oceananigans.TurbulenceClosures: time_discretization, implicit_diffusion_solver
#= none:18 =#
using Oceananigans.Utils: tupleit
#= none:20 =#
import Oceananigans: initialize!
#= none:21 =#
import Oceananigans.Models: total_velocities, default_nan_checker, timestepper
#= none:23 =#
PressureField(grid) = begin
        #= none:23 =#
        (; pHY′ = CenterField(grid))
    end
#= none:25 =#
const ParticlesOrNothing = Union{Nothing, AbstractLagrangianParticles}
#= none:26 =#
const AbstractBGCOrNothing = Union{Nothing, AbstractBiogeochemistry}
#= none:28 =#
mutable struct HydrostaticFreeSurfaceModel{TS, E, A <: AbstractArchitecture, S, G, T, V, B, R, F, P, BGC, U, C, Φ, K, AF} <: AbstractModel{TS}
    #= none:31 =#
    architecture::A
    #= none:32 =#
    grid::G
    #= none:33 =#
    clock::Clock{T}
    #= none:34 =#
    advection::V
    #= none:35 =#
    buoyancy::B
    #= none:36 =#
    coriolis::R
    #= none:37 =#
    free_surface::S
    #= none:38 =#
    forcing::F
    #= none:39 =#
    closure::E
    #= none:40 =#
    particles::P
    #= none:41 =#
    biogeochemistry::BGC
    #= none:42 =#
    velocities::U
    #= none:43 =#
    tracers::C
    #= none:44 =#
    pressure::Φ
    #= none:45 =#
    diffusivity_fields::K
    #= none:46 =#
    timestepper::TS
    #= none:47 =#
    auxiliary_fields::AF
end
#= none:50 =#
default_free_surface(grid::XYRegularRG; gravitational_acceleration = g_Earth) = begin
        #= none:50 =#
        ImplicitFreeSurface(; gravitational_acceleration)
    end
#= none:53 =#
default_free_surface(grid; gravitational_acceleration = g_Earth) = begin
        #= none:53 =#
        SplitExplicitFreeSurface(grid; cfl = 0.7, gravitational_acceleration)
    end
#= none:56 =#
#= none:56 =# Core.@doc "    HydrostaticFreeSurfaceModel(; grid,\n                                clock = Clock{eltype(grid)}(time = 0),\n                                momentum_advection = VectorInvariant(),\n                                tracer_advection = CenteredSecondOrder(),\n                                buoyancy = SeawaterBuoyancy(eltype(grid)),\n                                coriolis = nothing,\n                                free_surface = default_free_surface(grid, gravitational_acceleration=g_Earth),\n                                forcing::NamedTuple = NamedTuple(),\n                                closure = nothing,\n                                boundary_conditions::NamedTuple = NamedTuple(),\n                                tracers = (:T, :S),\n                                particles::ParticlesOrNothing = nothing,\n                                biogeochemistry::AbstractBGCOrNothing = nothing,\n                                velocities = nothing,\n                                pressure = nothing,\n                                diffusivity_fields = nothing,\n                                auxiliary_fields = NamedTuple())\n\nConstruct a hydrostatic model with a free surface on `grid`.\n\nKeyword arguments\n=================\n\n  - `grid`: (required) The resolution and discrete geometry on which `model` is solved. The\n            architecture (CPU/GPU) that the model is solved is inferred from the architecture\n            of the `grid`.\n  - `momentum_advection`: The scheme that advects velocities. See `Oceananigans.Advection`.\n  - `tracer_advection`: The scheme that advects tracers. See `Oceananigans.Advection`.\n  - `buoyancy`: The buoyancy model. See `Oceananigans.BuoyancyModels`.\n  - `coriolis`: Parameters for the background rotation rate of the model.\n  - `free_surface`: The free surface model. The default free-surface solver depends on the\n                    geometry of the `grid`. If the `grid` is a `RectilinearGrid` that is\n                    regularly spaced in the horizontal the default is an `ImplicitFreeSurface`\n                    solver with `solver_method = :FFTBasedPoissonSolver`. In all other cases,\n                    the default is a `SplitExplicitFreeSurface`.\n  - `tracers`: A tuple of symbols defining the names of the modeled tracers, or a `NamedTuple` of\n               preallocated `CenterField`s.\n  - `forcing`: `NamedTuple` of user-defined forcing functions that contribute to solution tendencies.\n  - `closure`: The turbulence closure for `model`. See `Oceananigans.TurbulenceClosures`.\n  - `boundary_conditions`: `NamedTuple` containing field boundary conditions.\n  - `particles`: Lagrangian particles to be advected with the flow. Default: `nothing`.\n  - `biogeochemistry`: Biogeochemical model for `tracers`.\n  - `velocities`: The model velocities. Default: `nothing`.\n  - `pressure`: Hydrostatic pressure field. Default: `nothing`.\n  - `diffusivity_fields`: Diffusivity fields. Default: `nothing`.\n  - `auxiliary_fields`: `NamedTuple` of auxiliary fields. Default: `nothing`.\n" function HydrostaticFreeSurfaceModel(; grid, clock = Clock{eltype(grid)}(time = 0), momentum_advection = VectorInvariant(), tracer_advection = CenteredSecondOrder(), buoyancy = nothing, coriolis = nothing, free_surface = default_free_surface(grid, gravitational_acceleration = g_Earth), tracers = nothing, forcing::NamedTuple = NamedTuple(), closure = nothing, boundary_conditions::NamedTuple = NamedTuple(), particles::ParticlesOrNothing = nothing, biogeochemistry::AbstractBGCOrNothing = nothing, velocities = nothing, pressure = nothing, diffusivity_fields = nothing, auxiliary_fields = NamedTuple())
        #= none:104 =#
        #= none:123 =#
        #= none:123 =# @apply_regionally validate_model_halo(grid, momentum_advection, tracer_advection, closure)
        #= none:126 =#
        tracers = tupleit(tracers)
        #= none:127 =#
        biogeochemical_fields = merge(auxiliary_fields, biogeochemical_auxiliary_fields(biogeochemistry))
        #= none:128 =#
        (tracers, auxiliary_fields) = validate_biogeochemistry(tracers, biogeochemical_fields, biogeochemistry, grid, clock)
        #= none:131 =#
        #= none:131 =# @apply_regionally momentum_advection = validate_momentum_advection(momentum_advection, grid)
        #= none:132 =#
        (default_tracer_advection, tracer_advection) = validate_tracer_advection(tracer_advection, grid)
        #= none:133 =#
        default_generator(name, tracer_advection) = begin
                #= none:133 =#
                default_tracer_advection
            end
        #= none:136 =#
        tracer_advection_tuple = with_tracers(tracernames(tracers), tracer_advection, default_generator, with_velocities = false)
        #= none:137 =#
        momentum_advection_tuple = (; momentum = momentum_advection)
        #= none:138 =#
        advection = merge(momentum_advection_tuple, tracer_advection_tuple)
        #= none:139 =#
        advection = NamedTuple((name => adapt_advection_order(scheme, grid) for (name, scheme) = pairs(advection)))
        #= none:141 =#
        validate_buoyancy(buoyancy, tracernames(tracers))
        #= none:142 =#
        buoyancy = regularize_buoyancy(buoyancy)
        #= none:151 =#
        embedded_boundary_conditions = merge(extract_boundary_conditions(velocities), extract_boundary_conditions(tracers), extract_boundary_conditions(pressure), extract_boundary_conditions(diffusivity_fields))
        #= none:157 =#
        prognostic_field_names = (:u, :v, :w, tracernames(tracers)..., :η, keys(auxiliary_fields)...)
        #= none:158 =#
        default_boundary_conditions = NamedTuple{prognostic_field_names}(Tuple((FieldBoundaryConditions() for name = prognostic_field_names)))
        #= none:163 =#
        boundary_conditions = merge(default_boundary_conditions, embedded_boundary_conditions, boundary_conditions)
        #= none:164 =#
        boundary_conditions = regularize_field_boundary_conditions(boundary_conditions, grid, prognostic_field_names)
        #= none:168 =#
        boundary_conditions = add_closure_specific_boundary_conditions(closure, boundary_conditions, grid, tracernames(tracers), buoyancy)
        #= none:175 =#
        closure = with_tracers(tracernames(tracers), closure)
        #= none:178 =#
        closure = validate_closure(closure)
        #= none:181 =#
        velocities = HydrostaticFreeSurfaceVelocityFields(velocities, grid, clock, boundary_conditions)
        #= none:182 =#
        tracers = TracerFields(tracers, grid, boundary_conditions)
        #= none:183 =#
        pressure = PressureField(grid)
        #= none:184 =#
        diffusivity_fields = DiffusivityFields(diffusivity_fields, grid, tracernames(tracers), boundary_conditions, closure)
        #= none:186 =#
        #= none:186 =# @apply_regionally validate_velocity_boundary_conditions(grid, velocities)
        #= none:188 =#
        arch = architecture(grid)
        #= none:189 =#
        free_surface = validate_free_surface(arch, free_surface)
        #= none:190 =#
        free_surface = materialize_free_surface(free_surface, velocities, grid)
        #= none:193 =#
        implicit_solver = implicit_diffusion_solver(time_discretization(closure), grid)
        #= none:194 =#
        timestepper = TimeStepper(:QuasiAdamsBashforth2, grid, tracernames(tracers); implicit_solver = implicit_solver, Gⁿ = HydrostaticFreeSurfaceTendencyFields(velocities, free_surface, grid, tracernames(tracers)), G⁻ = HydrostaticFreeSurfaceTendencyFields(velocities, free_surface, grid, tracernames(tracers)))
        #= none:200 =#
        model_fields = merge(hydrostatic_prognostic_fields(velocities, free_surface, tracers), auxiliary_fields)
        #= none:201 =#
        forcing = model_forcing(model_fields; forcing...)
        #= none:203 =#
        model = HydrostaticFreeSurfaceModel(arch, grid, clock, advection, buoyancy, coriolis, free_surface, forcing, closure, particles, biogeochemistry, velocities, tracers, pressure, diffusivity_fields, timestepper, auxiliary_fields)
        #= none:207 =#
        update_state!(model; compute_tendencies = false)
        #= none:209 =#
        return model
    end
#= none:212 =#
validate_velocity_boundary_conditions(grid, velocities) = begin
        #= none:212 =#
        validate_vertical_velocity_boundary_conditions(velocities.w)
    end
#= none:214 =#
function validate_vertical_velocity_boundary_conditions(w)
    #= none:214 =#
    #= none:215 =#
    w.boundary_conditions.top === nothing || error("Top boundary condition for HydrostaticFreeSurfaceModel velocities.w\n                                                    must be `nothing`!")
    #= none:217 =#
    return nothing
end
#= none:220 =#
validate_free_surface(::Distributed, free_surface::SplitExplicitFreeSurface) = begin
        #= none:220 =#
        free_surface
    end
#= none:221 =#
validate_free_surface(::Distributed, free_surface::ExplicitFreeSurface) = begin
        #= none:221 =#
        free_surface
    end
#= none:222 =#
validate_free_surface(arch::Distributed, free_surface) = begin
        #= none:222 =#
        error("$(typeof(free_surface)) is not supported with $(typeof(arch))")
    end
#= none:223 =#
validate_free_surface(arch, free_surface) = begin
        #= none:223 =#
        free_surface
    end
#= none:225 =#
validate_momentum_advection(momentum_advection, ibg::ImmersedBoundaryGrid) = begin
        #= none:225 =#
        validate_momentum_advection(momentum_advection, ibg.underlying_grid)
    end
#= none:226 =#
validate_momentum_advection(momentum_advection, grid::RectilinearGrid) = begin
        #= none:226 =#
        momentum_advection
    end
#= none:227 =#
validate_momentum_advection(momentum_advection, grid::AbstractHorizontallyCurvilinearGrid) = begin
        #= none:227 =#
        momentum_advection
    end
#= none:228 =#
validate_momentum_advection(momentum_advection::Nothing, grid::OrthogonalSphericalShellGrid) = begin
        #= none:228 =#
        momentum_advection
    end
#= none:229 =#
validate_momentum_advection(momentum_advection::VectorInvariant, grid::OrthogonalSphericalShellGrid) = begin
        #= none:229 =#
        momentum_advection
    end
#= none:230 =#
validate_momentum_advection(momentum_advection, grid::OrthogonalSphericalShellGrid) = begin
        #= none:230 =#
        error("$(typeof(momentum_advection)) is not supported with $(typeof(grid))")
    end
#= none:232 =#
initialize!(model::HydrostaticFreeSurfaceModel) = begin
        #= none:232 =#
        initialize_free_surface!(model.free_surface, model.grid, model.velocities)
    end
#= none:233 =#
initialize_free_surface!(free_surface, grid, velocities) = begin
        #= none:233 =#
        nothing
    end
#= none:236 =#
#= none:236 =# @inline total_velocities(model::HydrostaticFreeSurfaceModel) = begin
            #= none:236 =#
            model.velocities
        end