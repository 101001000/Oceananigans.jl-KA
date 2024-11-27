
#= none:1 =#
module Models
#= none:1 =#
#= none:3 =#
export NonhydrostaticModel, ShallowWaterModel, ConservativeFormulation, VectorInvariantFormulation, HydrostaticFreeSurfaceModel, ExplicitFreeSurface, ImplicitFreeSurface, SplitExplicitFreeSurface, PrescribedVelocityFields, PressureField, LagrangianParticles, seawater_density
#= none:12 =#
using Oceananigans: AbstractModel, fields, prognostic_fields
#= none:13 =#
using Oceananigans.AbstractOperations: AbstractOperation
#= none:14 =#
using Oceananigans.Advection: AbstractAdvectionScheme, CenteredSecondOrder, VectorInvariant
#= none:15 =#
using Oceananigans.Fields: AbstractField, Field, flattened_unique_values, boundary_conditions
#= none:16 =#
using Oceananigans.Grids: AbstractGrid, halo_size, inflate_halo_size
#= none:17 =#
using Oceananigans.OutputReaders: update_field_time_series!, extract_field_time_series
#= none:18 =#
using Oceananigans.TimeSteppers: AbstractTimeStepper, Clock
#= none:19 =#
using Oceananigans.Utils: Time
#= none:21 =#
import Oceananigans: initialize!
#= none:22 =#
import Oceananigans.Architectures: architecture
#= none:23 =#
import Oceananigans.TimeSteppers: reset!
#= none:24 =#
import Oceananigans.Solvers: iteration
#= none:35 =#
iteration(model::AbstractModel) = begin
        #= none:35 =#
        model.clock.iteration
    end
#= none:36 =#
Base.time(model::AbstractModel) = begin
        #= none:36 =#
        model.clock.time
    end
#= none:37 =#
architecture(model::AbstractModel) = begin
        #= none:37 =#
        model.grid.architecture
    end
#= none:38 =#
initialize!(model::AbstractModel) = begin
        #= none:38 =#
        nothing
    end
#= none:39 =#
total_velocities(model::AbstractModel) = begin
        #= none:39 =#
        nothing
    end
#= none:40 =#
timestepper(model::AbstractModel) = begin
        #= none:40 =#
        model.timestepper
    end
#= none:43 =#
update_model_field_time_series!(model::AbstractModel, clock::Clock) = begin
        #= none:43 =#
        nothing
    end
#= none:49 =#
function validate_model_halo(grid, momentum_advection, tracer_advection, closure)
    #= none:49 =#
    #= none:50 =#
    user_halo = halo_size(grid)
    #= none:51 =#
    required_halo = inflate_halo_size(1, 1, 1, grid, momentum_advection, tracer_advection, closure)
    #= none:56 =#
    any(user_halo .< required_halo) && throw(ArgumentError("The grid halo $(user_halo) must be at least equal to $(required_halo). \n Note that an ImmersedBoundaryGrid requires an extra halo point in all \n non-flat directions compared to a non-immersed boundary grid."))
end
#= none:68 =#
extract_boundary_conditions(::Nothing) = begin
        #= none:68 =#
        NamedTuple()
    end
#= none:69 =#
extract_boundary_conditions(::Tuple) = begin
        #= none:69 =#
        NamedTuple()
    end
#= none:71 =#
function extract_boundary_conditions(field_tuple::NamedTuple)
    #= none:71 =#
    #= none:72 =#
    names = propertynames(field_tuple)
    #= none:73 =#
    bcs = Tuple((extract_boundary_conditions(field) for field = field_tuple))
    #= none:74 =#
    return NamedTuple{names}(bcs)
end
#= none:77 =#
extract_boundary_conditions(field::Field) = begin
        #= none:77 =#
        field.boundary_conditions
    end
#= none:81 =#
#= none:81 =# Core.@doc " Returns a default_tracer_advection, tracer_advection `tuple`. " validate_tracer_advection(invalid_tracer_advection, grid) = begin
            #= none:82 =#
            error("$(invalid_tracer_advection) is invalid tracer_advection!")
        end
#= none:83 =#
validate_tracer_advection(tracer_advection_tuple::NamedTuple, grid) = begin
        #= none:83 =#
        (CenteredSecondOrder(), tracer_advection_tuple)
    end
#= none:84 =#
validate_tracer_advection(tracer_advection::AbstractAdvectionScheme, grid) = begin
        #= none:84 =#
        (tracer_advection, NamedTuple())
    end
#= none:85 =#
validate_tracer_advection(tracer_advection::Nothing, grid) = begin
        #= none:85 =#
        (nothing, NamedTuple())
    end
#= none:88 =#
include("nan_checker.jl")
#= none:91 =#
include("interleave_communication_and_computation.jl")
#= none:97 =#
include("NonhydrostaticModels/NonhydrostaticModels.jl")
#= none:98 =#
include("HydrostaticFreeSurfaceModels/HydrostaticFreeSurfaceModels.jl")
#= none:99 =#
include("ShallowWaterModels/ShallowWaterModels.jl")
#= none:100 =#
include("LagrangianParticleTracking/LagrangianParticleTracking.jl")
#= none:102 =#
using .NonhydrostaticModels: NonhydrostaticModel, PressureField
#= none:104 =#
using .HydrostaticFreeSurfaceModels: HydrostaticFreeSurfaceModel, ExplicitFreeSurface, ImplicitFreeSurface, SplitExplicitFreeSurface, PrescribedVelocityFields
#= none:109 =#
using .ShallowWaterModels: ShallowWaterModel, ConservativeFormulation, VectorInvariantFormulation
#= none:111 =#
using .LagrangianParticleTracking: LagrangianParticles
#= none:113 =#
const OceananigansModels = Union{HydrostaticFreeSurfaceModel, NonhydrostaticModel, ShallowWaterModel}
#= none:117 =#
#= none:117 =# Core.@doc "    possible_field_time_series(model::HydrostaticFreeSurfaceModel)\n\nReturn a `Tuple` containing properties of and `OceananigansModel` that could contain `FieldTimeSeries`.\n" function possible_field_time_series(model::OceananigansModels)
        #= none:122 =#
        #= none:123 =#
        forcing = model.forcing
        #= none:124 =#
        model_fields = fields(model)
        #= none:127 =#
        return tuple(model_fields, forcing)
    end
#= none:134 =#
function update_model_field_time_series!(model::OceananigansModels, clock::Clock)
    #= none:134 =#
    #= none:135 =#
    time = Time(clock.time)
    #= none:137 =#
    possible_fts = possible_field_time_series(model)
    #= none:138 =#
    time_series_tuple = extract_field_time_series(possible_fts)
    #= none:139 =#
    time_series_tuple = flattened_unique_values(time_series_tuple)
    #= none:141 =#
    for fts = time_series_tuple
        #= none:142 =#
        update_field_time_series!(fts, time)
        #= none:143 =#
    end
    #= none:145 =#
    return nothing
end
#= none:148 =#
import Oceananigans.TimeSteppers: reset!
#= none:150 =#
function reset!(model::OceananigansModels)
    #= none:150 =#
    #= none:152 =#
    for field = fields(model)
        #= none:153 =#
        fill!(field, 0)
        #= none:154 =#
    end
    #= none:156 =#
    for field = model.timestepper.G⁻
        #= none:157 =#
        fill!(field, 0)
        #= none:158 =#
    end
    #= none:160 =#
    for field = model.timestepper.Gⁿ
        #= none:161 =#
        fill!(field, 0)
        #= none:162 =#
    end
    #= none:164 =#
    return nothing
end
#= none:168 =#
function default_nan_checker(model::OceananigansModels)
    #= none:168 =#
    #= none:169 =#
    model_fields = prognostic_fields(model)
    #= none:171 =#
    if isempty(model_fields)
        #= none:172 =#
        return nothing
    end
    #= none:175 =#
    first_name = first(keys(model_fields))
    #= none:176 =#
    field_to_check_nans = NamedTuple{tuple(first_name)}(model_fields)
    #= none:177 =#
    nan_checker = NaNChecker(field_to_check_nans)
    #= none:178 =#
    return nan_checker
end
#= none:181 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: OnlyParticleTrackingModel
#= none:185 =#
default_nan_checker(::OnlyParticleTrackingModel) = begin
        #= none:185 =#
        nothing
    end
#= none:189 =#
include("seawater_density.jl")
end