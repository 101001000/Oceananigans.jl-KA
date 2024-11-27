
#= none:1 =#
module Coriolis
#= none:1 =#
#= none:3 =#
export FPlane, ConstantCartesianCoriolis, BetaPlane, NonTraditionalBetaPlane, HydrostaticSphericalCoriolis, ActiveCellEnstrophyConserving, x_f_cross_U, y_f_cross_U, z_f_cross_U
#= none:8 =#
using Printf
#= none:9 =#
using Adapt
#= none:10 =#
using Oceananigans.Grids
#= none:11 =#
using Oceananigans.Operators
#= none:14 =#
using Oceananigans.Grids: R_Earth
#= none:16 =#
#= none:16 =# Core.@doc "Earth's rotation rate [s⁻¹]; see https://en.wikipedia.org/wiki/Earth%27s_rotation#Angular_speed" const Ω_Earth = 7.292115e-5
#= none:19 =#
#= none:19 =# Core.@doc "    AbstractRotation\n\nAbstract supertype for parameters related to background rotation rates.\n" abstract type AbstractRotation end
#= none:26 =#
include("no_rotation.jl")
#= none:27 =#
include("f_plane.jl")
#= none:28 =#
include("constant_cartesian_coriolis.jl")
#= none:29 =#
include("beta_plane.jl")
#= none:30 =#
include("non_traditional_beta_plane.jl")
#= none:31 =#
include("hydrostatic_spherical_coriolis.jl")
end