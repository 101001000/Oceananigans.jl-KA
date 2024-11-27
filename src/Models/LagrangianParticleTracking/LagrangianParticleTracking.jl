
#= none:1 =#
module LagrangianParticleTracking
#= none:1 =#
#= none:3 =#
export LagrangianParticles
#= none:5 =#
using Printf
#= none:6 =#
using Adapt
#= none:7 =#
using KernelAbstractions
#= none:8 =#
using StructArrays
#= none:10 =#
using Oceananigans.Grids
#= none:11 =#
using Oceananigans.ImmersedBoundaries
#= none:13 =#
using Oceananigans.Grids: xnode, ynode, znode
#= none:14 =#
using Oceananigans.Grids: AbstractUnderlyingGrid, AbstractGrid, hack_cosd
#= none:15 =#
using Oceananigans.Grids: XFlatGrid, YFlatGrid, ZFlatGrid
#= none:16 =#
using Oceananigans.Grids: XYFlatGrid, YZFlatGrid, XZFlatGrid
#= none:17 =#
using Oceananigans.ImmersedBoundaries: immersed_cell
#= none:18 =#
using Oceananigans.Architectures: device, architecture
#= none:19 =#
using Oceananigans.Fields: interpolate, datatuple, compute!, location
#= none:20 =#
using Oceananigans.Fields: fractional_indices, truncate_fractional_indices
#= none:21 =#
using Oceananigans.TimeSteppers: AbstractLagrangianParticles
#= none:22 =#
using Oceananigans.Utils: prettysummary, launch!, SumOfArrays
#= none:24 =#
import Oceananigans.TimeSteppers: step_lagrangian_particles!
#= none:26 =#
import Base: size, length, show
#= none:28 =#
abstract type AbstractParticle end
#= none:30 =#
struct Particle{T} <: AbstractParticle
    #= none:31 =#
    x::T
    #= none:32 =#
    y::T
    #= none:33 =#
    z::T
end
#= none:36 =#
Base.show(io::IO, p::Particle) = begin
        #= none:36 =#
        print(io, "Particle at (", #= none:37 =# @sprintf("%-8s", prettysummary(p.x, true) * ", "), #= none:38 =# @sprintf("%-8s", prettysummary(p.y, true) * ", "), #= none:39 =# @sprintf("%-8s", prettysummary(p.z, true) * ")"))
    end
#= none:41 =#
struct LagrangianParticles{P, R, T, D, Π} <: AbstractLagrangianParticles
    #= none:42 =#
    properties::P
    #= none:43 =#
    restitution::R
    #= none:44 =#
    tracked_fields::T
    #= none:45 =#
    dynamics::D
    #= none:46 =#
    parameters::Π
end
#= none:49 =#
#= none:49 =# @inline no_dynamics(args...) = begin
            #= none:49 =#
            nothing
        end
#= none:51 =#
#= none:51 =# Core.@doc "    LagrangianParticles(; x, y, z, restitution=1.0, dynamics=no_dynamics, parameters=nothing)\n\nConstruct some `LagrangianParticles` that can be passed to a model. The particles will have initial locations\n`x`, `y`, and `z`. The coefficient of restitution for particle-wall collisions is specified by `restitution`.\n\n`dynamics` is a function of `(lagrangian_particles, model, Δt)` that is called prior to advecting particles.\n`parameters` can be accessed inside the `dynamics` function.\n" function LagrangianParticles(; x, y, z, restitution = 1.0, dynamics = no_dynamics, parameters = nothing)
        #= none:60 =#
        #= none:61 =#
        size(x) == size(y) == size(z) || throw(ArgumentError("x, y, z must all have the same size!"))
        #= none:64 =#
        ndims(x) == 1 && (ndims(y) == 1 && ndims(z) == 1) || throw(ArgumentError("x, y, z must have dimension 1 but ndims=($(ndims(x)), $(ndims(y)), $(ndims(z)))"))
        #= none:67 =#
        particles = StructArray{Particle}((x, y, z))
        #= none:69 =#
        return LagrangianParticles(particles; restitution, dynamics, parameters)
    end
#= none:72 =#
#= none:72 =# Core.@doc "    LagrangianParticles(particles::StructArray; restitution=1.0, tracked_fields::NamedTuple=NamedTuple(), dynamics=no_dynamics)\n\nConstruct some `LagrangianParticles` that can be passed to a model. The `particles` should be a `StructArray`\nand can contain custom fields. The coefficient of restitution for particle-wall collisions is specified by `restitution`.\n\nA number of `tracked_fields` may be passed in as a `NamedTuple` of fields. Each particle will track the value of each\nfield. Each tracked field must have a corresponding particle property. So if `T` is a tracked field, then `T` must also\nbe a custom particle property.\n\n`dynamics` is a function of `(lagrangian_particles, model, Δt)` that is called prior to advecting particles.\n`parameters` can be accessed inside the `dynamics` function.\n" function LagrangianParticles(particles::StructArray; restitution = 1.0, tracked_fields::NamedTuple = NamedTuple(), dynamics = no_dynamics, parameters = nothing)
        #= none:85 =#
        #= none:91 =#
        for (field_name, tracked_field) = pairs(tracked_fields)
            #= none:92 =#
            field_name in propertynames(particles) || throw(ArgumentError("$(field_name) is a tracked field but $(eltype(particles)) has no $(field_name) field! " * "You might have to define your own particle type."))
            #= none:95 =#
        end
        #= none:97 =#
        return LagrangianParticles(particles, restitution, tracked_fields, dynamics, parameters)
    end
#= none:100 =#
size(lagrangian_particles::LagrangianParticles) = begin
        #= none:100 =#
        size(lagrangian_particles.properties)
    end
#= none:101 =#
length(lagrangian_particles::LagrangianParticles) = begin
        #= none:101 =#
        length(lagrangian_particles.properties)
    end
#= none:103 =#
Base.summary(particles::LagrangianParticles) = begin
        #= none:103 =#
        string(length(particles), " LagrangianParticles with eltype ", nameof(eltype(particles.properties)), " and properties ", propertynames(particles.properties))
    end
#= none:107 =#
function Base.show(io::IO, lagrangian_particles::LagrangianParticles)
    #= none:107 =#
    #= none:108 =#
    particles = lagrangian_particles.properties
    #= none:109 =#
    Tparticle = nameof(eltype(particles))
    #= none:110 =#
    properties = propertynames(particles)
    #= none:111 =#
    fields = lagrangian_particles.tracked_fields
    #= none:112 =#
    Nparticles = length(particles)
    #= none:114 =#
    print(io, Nparticles, " LagrangianParticles with eltype ", Tparticle, ":", "\n", "├── ", length(properties), " properties: ", properties, "\n", "├── particle-wall restitution coefficient: ", lagrangian_particles.restitution, "\n", "├── ", length(fields), " tracked fields: ", propertynames(fields), "\n", "└── dynamics: ", prettysummary(lagrangian_particles.dynamics, false))
end
#= none:122 =#
#= none:122 =# @inline flattened_node((x, y, z), grid) = begin
            #= none:122 =#
            (x, y, z)
        end
#= none:123 =#
#= none:123 =# @inline flattened_node((x, y, z), grid::XFlatGrid) = begin
            #= none:123 =#
            (y, z)
        end
#= none:124 =#
#= none:124 =# @inline flattened_node((x, y, z), grid::YFlatGrid) = begin
            #= none:124 =#
            (x, z)
        end
#= none:125 =#
#= none:125 =# @inline flattened_node((x, y, z), grid::ZFlatGrid) = begin
            #= none:125 =#
            (x, y)
        end
#= none:126 =#
#= none:126 =# @inline flattened_node((x, y, z), grid::YZFlatGrid) = begin
            #= none:126 =#
            tuple(x)
        end
#= none:127 =#
#= none:127 =# @inline flattened_node((x, y, z), grid::XZFlatGrid) = begin
            #= none:127 =#
            tuple(y)
        end
#= none:128 =#
#= none:128 =# @inline flattened_node((x, y, z), grid::XYFlatGrid) = begin
            #= none:128 =#
            tuple(z)
        end
#= none:130 =#
include("update_lagrangian_particle_properties.jl")
#= none:131 =#
include("lagrangian_particle_advection.jl")
#= none:133 =#
step_lagrangian_particles!(::Nothing, model, Δt) = begin
        #= none:133 =#
        nothing
    end
#= none:135 =#
function step_lagrangian_particles!(particles::LagrangianParticles, model, Δt)
    #= none:135 =#
    #= none:137 =#
    update_lagrangian_particle_properties!(particles, model, Δt)
    #= none:140 =#
    particles.dynamics(particles, model, Δt)
    #= none:143 =#
    advect_lagrangian_particles!(particles, model, Δt)
end
end