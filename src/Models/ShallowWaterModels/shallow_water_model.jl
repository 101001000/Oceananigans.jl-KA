
#= none:1 =#
using Oceananigans: AbstractModel, AbstractOutputWriter, AbstractDiagnostic
#= none:3 =#
using Oceananigans.Architectures: AbstractArchitecture, CPU
#= none:4 =#
using Oceananigans.AbstractOperations: @at, KernelFunctionOperation
#= none:5 =#
using Oceananigans.DistributedComputations
#= none:6 =#
using Oceananigans.Advection: CenteredSecondOrder, VectorInvariant
#= none:7 =#
using Oceananigans.BoundaryConditions: regularize_field_boundary_conditions
#= none:8 =#
using Oceananigans.Fields: Field, tracernames, TracerFields, XFaceField, YFaceField, CenterField, compute!
#= none:9 =#
using Oceananigans.Forcings: model_forcing
#= none:10 =#
using Oceananigans.Grids: topology, Flat, architecture, RectilinearGrid, Face, Center
#= none:11 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid
#= none:12 =#
using Oceananigans.Models: validate_model_halo, NaNChecker, validate_tracer_advection
#= none:13 =#
using Oceananigans.TimeSteppers: Clock, TimeStepper, update_state!
#= none:14 =#
using Oceananigans.TurbulenceClosures: with_tracers, DiffusivityFields
#= none:15 =#
using Oceananigans.Utils: tupleit
#= none:17 =#
import Oceananigans.Architectures: architecture
#= none:18 =#
import Oceananigans.Models: default_nan_checker, timestepper
#= none:20 =#
const RectilinearGrids = Union{RectilinearGrid, ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:RectilinearGrid}}
#= none:22 =#
function ShallowWaterTendencyFields(grid, tracer_names, prognostic_names)
    #= none:22 =#
    #= none:23 =#
    u = XFaceField(grid)
    #= none:24 =#
    v = YFaceField(grid)
    #= none:25 =#
    h = CenterField(grid)
    #= none:26 =#
    tracers = TracerFields(tracer_names, grid)
    #= none:28 =#
    return NamedTuple{prognostic_names}((u, v, h, Tuple(tracers)...))
end
#= none:31 =#
function ShallowWaterSolutionFields(grid, bcs, prognostic_names)
    #= none:31 =#
    #= none:32 =#
    u = XFaceField(grid, boundary_conditions = getproperty(bcs, prognostic_names[1]))
    #= none:33 =#
    v = YFaceField(grid, boundary_conditions = getproperty(bcs, prognostic_names[2]))
    #= none:34 =#
    h = CenterField(grid, boundary_conditions = getproperty(bcs, prognostic_names[3]))
    #= none:36 =#
    return NamedTuple{prognostic_names[1:3]}((u, v, h))
end
#= none:39 =#
mutable struct ShallowWaterModel{G, A <: AbstractArchitecture, T, GR, V, U, R, F, E, B, Q, C, K, TS, FR} <: AbstractModel{TS}
    #= none:40 =#
    grid::G
    #= none:41 =#
    architecture::A
    #= none:42 =#
    clock::Clock{T}
    #= none:43 =#
    gravitational_acceleration::GR
    #= none:44 =#
    advection::V
    #= none:45 =#
    velocities::U
    #= none:46 =#
    coriolis::R
    #= none:47 =#
    forcing::F
    #= none:48 =#
    closure::E
    #= none:49 =#
    bathymetry::B
    #= none:50 =#
    solution::Q
    #= none:51 =#
    tracers::C
    #= none:52 =#
    diffusivity_fields::K
    #= none:53 =#
    timestepper::TS
    #= none:54 =#
    formulation::FR
end
#= none:57 =#
struct ConservativeFormulation
    #= none:57 =#
end
#= none:59 =#
struct VectorInvariantFormulation
    #= none:59 =#
end
#= none:61 =#
#= none:61 =# Core.@doc "    ShallowWaterModel(; grid,\n                        gravitational_acceleration,\n                              clock = Clock{eltype(grid)}(time = 0),\n                 momentum_advection = UpwindBiasedFifthOrder(),\n                   tracer_advection = WENO(),\n                     mass_advection = WENO(),\n                           coriolis = nothing,\n                forcing::NamedTuple = NamedTuple(),\n                            closure = nothing,\n                         bathymetry = nothing,\n                            tracers = (),\n                 diffusivity_fields = nothing,\n    boundary_conditions::NamedTuple = NamedTuple(),\n                timestepper::Symbol = :RungeKutta3,\n                        formulation = ConservativeFormulation())\n\nConstruct a shallow water model on `grid` with `gravitational_acceleration` constant.\n\nKeyword arguments\n=================\n\n  - `grid`: (required) The resolution and discrete geometry on which `model` is solved. The\n            architecture (CPU/GPU) that the model is solve is inferred from the architecture\n            of the grid.\n  - `gravitational_acceleration`: (required) The gravitational acceleration constant.\n  - `clock`: The `clock` for the model.\n  - `momentum_advection`: The scheme that advects velocities. See `Oceananigans.Advection`.\n    Default: `UpwindBiasedFifthOrder()`.\n  - `tracer_advection`: The scheme that advects tracers. See `Oceananigans.Advection`. Default: `WENO()`.\n  - `mass_advection`: The scheme that advects the mass equation. See `Oceananigans.Advection`. Default:\n    `WENO()`.\n  - `coriolis`: Parameters for the background rotation rate of the model.\n  - `forcing`: `NamedTuple` of user-defined forcing functions that contribute to solution tendencies.\n  - `closure`: The turbulence closure for `model`. See `Oceananigans.TurbulenceClosures`.\n  - `bathymetry`: The bottom bathymetry.\n  - `tracers`: A tuple of symbols defining the names of the modeled tracers, or a `NamedTuple` of\n               preallocated `CenterField`s.\n  - `diffusivity_fields`: Stores diffusivity fields when the closures require a diffusivity to be\n                          calculated at each timestep.\n  - `boundary_conditions`: `NamedTuple` containing field boundary conditions.\n  - `timestepper`: A symbol that specifies the time-stepping method. Either `:QuasiAdamsBashforth2` or\n                   `:RungeKutta3` (default).\n  - `formulation`: Whether the dynamics are expressed in conservative form (`ConservativeFormulation()`;\n                   default) or in non-conservative form with a vector-invariant formulation for the\n                   non-linear terms (`VectorInvariantFormulation()`).\n\n!!! warning \"Formulation-grid compatibility requirements\"\n    The `ConservativeFormulation()` requires `RectilinearGrid`.\n    Use `VectorInvariantFormulation()` with `LatitudeLongitudeGrid`.\n" function ShallowWaterModel(; grid, gravitational_acceleration, clock = Clock{eltype(grid)}(time = 0), momentum_advection = UpwindBiasedFifthOrder(), tracer_advection = WENO(), mass_advection = WENO(), coriolis = nothing, forcing::NamedTuple = NamedTuple(), closure = nothing, bathymetry = nothing, tracers = (), diffusivity_fields = nothing, boundary_conditions::NamedTuple = NamedTuple(), timestepper::Symbol = :RungeKutta3, formulation = ConservativeFormulation())
        #= none:112 =#
        #= none:129 =#
        #= none:129 =# @warn "The ShallowWaterModel is currently unvalidated, subject to change, and should not be used for scientific research without adequate validation."
        #= none:131 =#
        arch = architecture(grid)
        #= none:133 =#
        tracers = tupleit(tracers)
        #= none:135 =#
        topology(grid, 3) === Flat || throw(ArgumentError("ShallowWaterModel requires `topology(grid, 3) === Flat`. " * "Use `topology = ($(topology(grid, 1)), $(topology(grid, 2)), Flat)` " * "when constructing `grid`."))
        #= none:140 =#
        (typeof(grid) <: RectilinearGrids || formulation == VectorInvariantFormulation()) || throw(ArgumentError("`ConservativeFormulation()` requires a rectilinear `grid`. \n" * "Use `VectorInvariantFormulation()` or change your grid to a rectilinear one."))
        #= none:145 =#
        validate_model_halo(grid, momentum_advection, tracer_advection, closure)
        #= none:147 =#
        prognostic_field_names = if formulation isa ConservativeFormulation
                (:uh, :vh, :h, tracers...)
            else
                (:u, :v, :h, tracers...)
            end
        #= none:148 =#
        default_boundary_conditions = NamedTuple{prognostic_field_names}(Tuple((FieldBoundaryConditions() for name = prognostic_field_names)))
        #= none:151 =#
        momentum_advection = validate_momentum_advection(momentum_advection, formulation)
        #= none:153 =#
        if isnothing(tracer_advection)
            #= none:154 =#
            tracer_advection_tuple = NamedTuple{tracernames(tracers)}((nothing for tracer = 1:length(tracers)))
        else
            #= none:156 =#
            (default_tracer_advection, tracer_advection) = validate_tracer_advection(tracer_advection, grid)
            #= none:159 =#
            tracer_advection_tuple = with_tracers(tracernames(tracers), tracer_advection, ((name, tracer_advection)->begin
                            #= none:161 =#
                            default_tracer_advection
                        end), with_velocities = false)
        end
        #= none:165 =#
        advection = merge((momentum = momentum_advection, mass = mass_advection), tracer_advection_tuple)
        #= none:167 =#
        bathymetry_field = CenterField(grid)
        #= none:168 =#
        if !(isnothing(bathymetry))
            #= none:169 =#
            set!(bathymetry_field, bathymetry)
            #= none:170 =#
            fill_halo_regions!(bathymetry_field)
        else
            #= none:172 =#
            fill!(bathymetry_field, 0)
        end
        #= none:175 =#
        boundary_conditions = merge(default_boundary_conditions, boundary_conditions)
        #= none:176 =#
        boundary_conditions = regularize_field_boundary_conditions(boundary_conditions, grid, prognostic_field_names)
        #= none:178 =#
        solution = ShallowWaterSolutionFields(grid, boundary_conditions, prognostic_field_names)
        #= none:179 =#
        tracers = TracerFields(tracers, grid, boundary_conditions)
        #= none:180 =#
        diffusivity_fields = DiffusivityFields(diffusivity_fields, grid, tracernames(tracers), boundary_conditions, closure)
        #= none:183 =#
        timestepper = TimeStepper(timestepper, grid, tracernames(tracers); Gⁿ = ShallowWaterTendencyFields(grid, tracernames(tracers), prognostic_field_names), G⁻ = ShallowWaterTendencyFields(grid, tracernames(tracers), prognostic_field_names))
        #= none:188 =#
        model_fields = merge(solution, tracers)
        #= none:189 =#
        forcing = model_forcing(model_fields; forcing...)
        #= none:190 =#
        closure = with_tracers(tracernames(tracers), closure)
        #= none:192 =#
        model = ShallowWaterModel(grid, arch, clock, (eltype(grid))(gravitational_acceleration), advection, shallow_water_velocities(formulation, solution), coriolis, forcing, closure, bathymetry_field, solution, tracers, diffusivity_fields, timestepper, formulation)
        #= none:208 =#
        update_state!(model; compute_tendencies = false)
        #= none:210 =#
        return model
    end
#= none:213 =#
validate_momentum_advection(momentum_advection, formulation) = begin
        #= none:213 =#
        momentum_advection
    end
#= none:214 =#
validate_momentum_advection(momentum_advection, ::VectorInvariantFormulation) = begin
        #= none:214 =#
        throw(ArgumentError("VectorInvariantFormulation requires a vector invariant momentum advection scheme. \n" * "Use `momentum_advection = VectorInvariant()`."))
    end
#= none:217 =#
validate_momentum_advection(momentum_advection::Union{VectorInvariant, Nothing}, ::VectorInvariantFormulation) = begin
        #= none:217 =#
        momentum_advection
    end
#= none:219 =#
formulation(model::ShallowWaterModel) = begin
        #= none:219 =#
        model.formulation
    end
#= none:220 =#
architecture(model::ShallowWaterModel) = begin
        #= none:220 =#
        model.architecture
    end
#= none:223 =#
shallow_water_velocities(::VectorInvariantFormulation, solution) = begin
        #= none:223 =#
        (u = solution.u, v = solution.v, w = nothing)
    end
#= none:226 =#
function shallow_water_velocities(::ConservativeFormulation, solution)
    #= none:226 =#
    #= none:227 =#
    u = compute!(Field(solution.uh / solution.h))
    #= none:228 =#
    v = compute!(Field(solution.vh / solution.h))
    #= none:229 =#
    return (; u, v, w = nothing)
end
#= none:232 =#
shallow_water_velocities(model::ShallowWaterModel) = begin
        #= none:232 =#
        shallow_water_velocities(model.formulation, model.solution)
    end
#= none:234 =#
shallow_water_fields(velocities, solution, tracers, ::ConservativeFormulation) = begin
        #= none:234 =#
        merge(velocities, solution, tracers)
    end
#= none:235 =#
shallow_water_fields(velocities, solution, tracers, ::VectorInvariantFormulation) = begin
        #= none:235 =#
        merge(solution, (; w = velocities.w), tracers)
    end