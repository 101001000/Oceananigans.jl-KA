
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:2 =#
using OrderedCollections: OrderedDict
#= none:4 =#
using Oceananigans.Architectures: AbstractArchitecture
#= none:5 =#
using Oceananigans.DistributedComputations: Distributed
#= none:6 =#
using Oceananigans.Advection: CenteredSecondOrder, adapt_advection_order
#= none:7 =#
using Oceananigans.BuoyancyModels: validate_buoyancy, regularize_buoyancy, SeawaterBuoyancy
#= none:8 =#
using Oceananigans.Biogeochemistry: validate_biogeochemistry, AbstractBiogeochemistry, biogeochemical_auxiliary_fields
#= none:9 =#
using Oceananigans.BoundaryConditions: regularize_field_boundary_conditions
#= none:10 =#
using Oceananigans.Fields: BackgroundFields, Field, tracernames, VelocityFields, TracerFields, CenterField
#= none:11 =#
using Oceananigans.Forcings: model_forcing
#= none:12 =#
using Oceananigans.Grids: inflate_halo_size, with_halo, architecture
#= none:13 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid
#= none:14 =#
using Oceananigans.Models: AbstractModel, NaNChecker, extract_boundary_conditions
#= none:15 =#
using Oceananigans.Solvers: FFTBasedPoissonSolver
#= none:16 =#
using Oceananigans.TimeSteppers: Clock, TimeStepper, update_state!, AbstractLagrangianParticles
#= none:17 =#
using Oceananigans.TurbulenceClosures: validate_closure, with_tracers, DiffusivityFields, time_discretization, implicit_diffusion_solver
#= none:18 =#
using Oceananigans.TurbulenceClosures.TKEBasedVerticalDiffusivities: FlavorOfCATKE
#= none:19 =#
using Oceananigans.Utils: tupleit
#= none:20 =#
using Oceananigans.Grids: topology
#= none:22 =#
import Oceananigans.Architectures: architecture
#= none:23 =#
import Oceananigans.Models: total_velocities, default_nan_checker, timestepper
#= none:25 =#
const ParticlesOrNothing = Union{Nothing, AbstractLagrangianParticles}
#= none:26 =#
const AbstractBGCOrNothing = Union{Nothing, AbstractBiogeochemistry}
#= none:30 =#
struct DefaultHydrostaticPressureAnomaly
    #= none:30 =#
end
#= none:32 =#
mutable struct NonhydrostaticModel{TS, E, A <: AbstractArchitecture, G, T, B, R, SD, U, C, Φ, F, V, S, K, BG, P, BGC, AF} <: AbstractModel{TS}
    #= none:35 =#
    architecture::A
    #= none:36 =#
    grid::G
    #= none:37 =#
    clock::Clock{T}
    #= none:38 =#
    advection::V
    #= none:39 =#
    buoyancy::B
    #= none:40 =#
    coriolis::R
    #= none:41 =#
    stokes_drift::SD
    #= none:42 =#
    forcing::F
    #= none:43 =#
    closure::E
    #= none:44 =#
    background_fields::BG
    #= none:45 =#
    particles::P
    #= none:46 =#
    biogeochemistry::BGC
    #= none:47 =#
    velocities::U
    #= none:48 =#
    tracers::C
    #= none:49 =#
    pressures::Φ
    #= none:50 =#
    diffusivity_fields::K
    #= none:51 =#
    timestepper::TS
    #= none:52 =#
    pressure_solver::S
    #= none:53 =#
    auxiliary_fields::AF
end
#= none:56 =#
#= none:56 =# Core.@doc "    NonhydrostaticModel(;           grid,\n                                    clock = Clock{eltype(grid)}(time = 0),\n                                advection = CenteredSecondOrder(),\n                                 buoyancy = nothing,\n                                 coriolis = nothing,\n                             stokes_drift = nothing,\n                      forcing::NamedTuple = NamedTuple(),\n                                  closure = nothing,\n          boundary_conditions::NamedTuple = NamedTuple(),\n                                  tracers = (),\n                              timestepper = :RungeKutta3,\n            background_fields::NamedTuple = NamedTuple(),\n            particles::ParticlesOrNothing = nothing,\n    biogeochemistry::AbstractBGCOrNothing = nothing,\n                               velocities = nothing,\n                  nonhydrostatic_pressure = CenterField(grid),\n             hydrostatic_pressure_anomaly = DefaultHydrostaticPressureAnomaly(),\n                       diffusivity_fields = nothing,\n                          pressure_solver = nothing,\n                         auxiliary_fields = NamedTuple())\n\nConstruct a model for a non-hydrostatic, incompressible fluid on `grid`, using the Boussinesq\napproximation when `buoyancy != nothing`. By default, all Bounded directions are rigid and impenetrable.\n\nKeyword arguments\n=================\n\n  - `grid`: (required) The resolution and discrete geometry on which the `model` is solved. The\n            architecture (CPU/GPU) that the model is solved on is inferred from the architecture\n            of the `grid`. Note that the grid needs to be regularly spaced in the horizontal\n            dimensions, ``x`` and ``y``.\n  - `advection`: The scheme that advects velocities and tracers. See `Oceananigans.Advection`.\n  - `buoyancy`: The buoyancy model. See `Oceananigans.BuoyancyModels`.\n  - `coriolis`: Parameters for the background rotation rate of the model.\n  - `stokes_drift`: Parameters for Stokes drift fields associated with surface waves. Default: `nothing`.\n  - `forcing`: `NamedTuple` of user-defined forcing functions that contribute to solution tendencies.\n  - `closure`: The turbulence closure for `model`. See `Oceananigans.TurbulenceClosures`.\n  - `boundary_conditions`: `NamedTuple` containing field boundary conditions.\n  - `tracers`: A tuple of symbols defining the names of the modeled tracers, or a `NamedTuple` of\n               preallocated `CenterField`s.\n  - `timestepper`: A symbol that specifies the time-stepping method. Either `:QuasiAdamsBashforth2` or\n                   `:RungeKutta3` (default).\n  - `background_fields`: `NamedTuple` with background fields (e.g., background flow). Default: `nothing`.\n  - `particles`: Lagrangian particles to be advected with the flow. Default: `nothing`.\n  - `biogeochemistry`: Biogeochemical model for `tracers`.\n  - `velocities`: The model velocities. Default: `nothing`.\n  - `nonhydrostatic_pressure`: The nonhydrostatic pressure field. Default: `CenterField(grid)`.\n  - `hydrostatic_pressure_anomaly`: An optional field that stores the part of the nonhydrostatic pressure\n                                    in hydrostatic balance with the buoyancy field. If `CenterField(grid)` (default), the anomaly is precomputed by\n                                    vertically integrating the buoyancy field. In this case, the `nonhydrostatic_pressure` represents\n                                    only the part of pressure that deviates from the hydrostatic anomaly. If `nothing`, the anomaly\n                                    is not computed. \n  - `diffusivity_fields`: Diffusivity fields. Default: `nothing`.\n  - `pressure_solver`: Pressure solver to be used in the model. If `nothing` (default), the model constructor\n    chooses the default based on the `grid` provide.\n  - `auxiliary_fields`: `NamedTuple` of auxiliary fields. Default: `nothing`         \n" function NonhydrostaticModel(; grid, clock = Clock{eltype(grid)}(time = 0), advection = CenteredSecondOrder(), buoyancy = nothing, coriolis = nothing, stokes_drift = nothing, forcing::NamedTuple = NamedTuple(), closure = nothing, boundary_conditions::NamedTuple = NamedTuple(), tracers = (), timestepper = :RungeKutta3, background_fields::NamedTuple = NamedTuple(), particles::ParticlesOrNothing = nothing, biogeochemistry::AbstractBGCOrNothing = nothing, velocities = nothing, hydrostatic_pressure_anomaly = DefaultHydrostaticPressureAnomaly(), nonhydrostatic_pressure = CenterField(grid), diffusivity_fields = nothing, pressure_solver = nothing, auxiliary_fields = NamedTuple())
        #= none:114 =#
        #= none:135 =#
        arch = architecture(grid)
        #= none:137 =#
        tracers = tupleit(tracers)
        #= none:140 =#
        nonhydrostatic_pressure isa Field{Center, Center, Center} || throw(ArgumentError("nonhydrostatic_pressure must be CenterField(grid)."))
        #= none:143 =#
        if hydrostatic_pressure_anomaly isa DefaultHydrostaticPressureAnomaly
            #= none:146 =#
            if !(isnothing(buoyancy))
                #= none:152 =#
                hydrostatic_pressure_anomaly = CenterField(grid)
            else
                #= none:156 =#
                hydrostatic_pressure_anomaly = nothing
            end
        end
        #= none:161 =#
        isnothing(hydrostatic_pressure_anomaly) || (hydrostatic_pressure_anomaly isa Field{Center, Center, Center} || throw(ArgumentError("hydrostatic_pressure_anomaly must be `nothing` or `CenterField(grid)`.")))
        #= none:165 =#
        closure = validate_closure(closure)
        #= none:166 =#
        first_closure = if closure isa Tuple
                first(closure)
            else
                closure
            end
        #= none:167 =#
        first_closure isa FlavorOfCATKE && error("CATKEVerticalDiffusivity is not supported for NonhydrostaticModel --- yet!")
        #= none:170 =#
        all_auxiliary_fields = merge(auxiliary_fields, biogeochemical_auxiliary_fields(biogeochemistry))
        #= none:171 =#
        (tracers, auxiliary_fields) = validate_biogeochemistry(tracers, all_auxiliary_fields, biogeochemistry, grid, clock)
        #= none:172 =#
        validate_buoyancy(buoyancy, tracernames(tracers))
        #= none:173 =#
        buoyancy = regularize_buoyancy(buoyancy)
        #= none:178 =#
        advection = adapt_advection_order(advection, grid)
        #= none:183 =#
        grid = inflate_grid_halo_size(grid, advection, closure)
        #= none:192 =#
        embedded_boundary_conditions = merge(extract_boundary_conditions(velocities), extract_boundary_conditions(tracers), extract_boundary_conditions(diffusivity_fields))
        #= none:197 =#
        prognostic_field_names = (:u, :v, :w, tracernames(tracers)..., keys(auxiliary_fields)...)
        #= none:198 =#
        default_boundary_conditions = NamedTuple{prognostic_field_names}((FieldBoundaryConditions() for name = prognostic_field_names))
        #= none:203 =#
        boundary_conditions = merge(default_boundary_conditions, embedded_boundary_conditions, boundary_conditions)
        #= none:204 =#
        boundary_conditions = regularize_field_boundary_conditions(boundary_conditions, grid, prognostic_field_names)
        #= none:207 =#
        closure = with_tracers(tracernames(tracers), closure)
        #= none:210 =#
        velocities = VelocityFields(velocities, grid, boundary_conditions)
        #= none:211 =#
        tracers = TracerFields(tracers, grid, boundary_conditions)
        #= none:212 =#
        pressures = (pNHS = nonhydrostatic_pressure, pHY′ = hydrostatic_pressure_anomaly)
        #= none:213 =#
        diffusivity_fields = DiffusivityFields(diffusivity_fields, grid, tracernames(tracers), boundary_conditions, closure)
        #= none:215 =#
        if isnothing(pressure_solver)
            #= none:216 =#
            pressure_solver = nonhydrostatic_pressure_solver(grid)
        end
        #= none:220 =#
        background_fields = BackgroundFields(background_fields, tracernames(tracers), grid, clock)
        #= none:223 =#
        implicit_solver = implicit_diffusion_solver(time_discretization(closure), grid)
        #= none:224 =#
        timestepper = TimeStepper(timestepper, grid, tracernames(tracers), implicit_solver = implicit_solver)
        #= none:227 =#
        model_fields = merge(velocities, tracers, auxiliary_fields)
        #= none:228 =#
        forcing = model_forcing(model_fields; forcing...)
        #= none:230 =#
        model = NonhydrostaticModel(arch, grid, clock, advection, buoyancy, coriolis, stokes_drift, forcing, closure, background_fields, particles, biogeochemistry, velocities, tracers, pressures, diffusivity_fields, timestepper, pressure_solver, auxiliary_fields)
        #= none:234 =#
        update_state!(model; compute_tendencies = false)
        #= none:236 =#
        return model
    end
#= none:239 =#
architecture(model::NonhydrostaticModel) = begin
        #= none:239 =#
        model.architecture
    end
#= none:241 =#
function inflate_grid_halo_size(grid, tendency_terms...)
    #= none:241 =#
    #= none:242 =#
    user_halo = (grid.Hx, grid.Hy, grid.Hz)
    #= none:243 =#
    required_halo = ((Hx, Hy, Hz) = inflate_halo_size(user_halo..., grid, tendency_terms...))
    #= none:245 =#
    if any(user_halo .< required_halo)
        #= none:246 =#
        #= none:246 =# @warn "Inflating model grid halo size to ($(Hx), $(Hy), $(Hz)) and recreating grid. " * "Note that an ImmersedBoundaryGrid requires an extra halo point in all non-flat directions compared to a non-immersed boundary grid."
        #= none:248 =#
        "The model grid will be different from the input grid. To avoid this warning, " * "pass halo=($(Hx), $(Hy), $(Hz)) when constructing the grid."
        #= none:251 =#
        grid = with_halo((Hx, Hy, Hz), grid)
    end
    #= none:254 =#
    return grid
end
#= none:258 =#
#= none:258 =# @inline total_velocities(m::NonhydrostaticModel) = begin
            #= none:258 =#
            (u = SumOfArrays{2}(m.velocities.u, m.background_fields.velocities.u), v = SumOfArrays{2}(m.velocities.v, m.background_fields.velocities.v), w = SumOfArrays{2}(m.velocities.w, m.background_fields.velocities.w))
        end