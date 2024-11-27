
#= none:1 =#
module BuoyancyModels
#= none:1 =#
#= none:3 =#
export Buoyancy, BuoyancyTracer, SeawaterBuoyancy, buoyancy_perturbationᶜᶜᶜ, LinearEquationOfState, RoquetIdealizedNonlinearEquationOfState, TEOS10, ∂x_b, ∂y_b, ∂z_b, buoyancy_perturbationᶜᶜᶜ, x_dot_g_bᶠᶜᶜ, y_dot_g_bᶜᶠᶜ, z_dot_g_bᶜᶜᶠ, top_buoyancy_flux, buoyancy_frequency_squared, BuoyancyField
#= none:11 =#
using Printf
#= none:12 =#
using Oceananigans.Grids
#= none:13 =#
using Oceananigans.Operators
#= none:14 =#
using Oceananigans.BoundaryConditions: getbc
#= none:16 =#
import SeawaterPolynomials: ρ′, thermal_expansion, haline_contraction
#= none:19 =#
const g_Earth = 9.80665
#= none:21 =#
#= none:21 =# Core.@doc "    AbstractBuoyancyModel{EOS}\n\nAbstract supertype for buoyancy models.\n" abstract type AbstractBuoyancyModel{EOS} end
#= none:28 =#
#= none:28 =# Core.@doc "    AbstractEquationOfState\n\nAbstract supertype for equations of state.\n" abstract type AbstractEquationOfState end
#= none:35 =#
function validate_buoyancy(buoyancy, tracers)
    #= none:35 =#
    #= none:36 =#
    req_tracers = required_tracers(buoyancy)
    #= none:38 =#
    all((tracer ∈ tracers for tracer = req_tracers)) || error("$(req_tracers) must be among the list of tracers to use $((typeof(buoyancy)).name.wrapper)")
    #= none:41 =#
    return nothing
end
#= none:44 =#
include("buoyancy.jl")
#= none:45 =#
include("no_buoyancy.jl")
#= none:46 =#
include("buoyancy_tracer.jl")
#= none:47 =#
include("seawater_buoyancy.jl")
#= none:48 =#
include("linear_equation_of_state.jl")
#= none:49 =#
include("nonlinear_equation_of_state.jl")
#= none:50 =#
include("g_dot_b.jl")
#= none:51 =#
include("buoyancy_field.jl")
end