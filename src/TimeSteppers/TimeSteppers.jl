
#= none:1 =#
module TimeSteppers
#= none:1 =#
#= none:3 =#
export QuasiAdamsBashforth2TimeStepper, RungeKutta3TimeStepper, time_step!, Clock, tendencies
#= none:10 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:11 =#
using KernelAbstractions
#= none:12 =#
using Oceananigans: AbstractModel, prognostic_fields
#= none:13 =#
using Oceananigans.Architectures: device
#= none:14 =#
using Oceananigans.Fields: TendencyFields
#= none:15 =#
using Oceananigans.Utils: work_layout
#= none:17 =#
#= none:17 =# Core.@doc "    abstract type AbstractTimeStepper\n\nAbstract supertype for time steppers.\n" abstract type AbstractTimeStepper end
#= none:24 =#
#= none:24 =# Core.@doc "    TimeStepper(name::Symbol, args...; kwargs...)\n\nReturns a timestepper with name `name`, instantiated with `args...` and `kwargs...`.\n\nExample\n=======\n\n```julia\njulia> stepper = TimeStepper(:QuasiAdamsBashforth2, CPU(), grid, tracernames)\n```\n" function TimeStepper(name::Symbol, args...; kwargs...)
        #= none:36 =#
        #= none:37 =#
        fullname = Symbol(name, :TimeStepper)
        #= none:38 =#
        TS = getglobal(#= none:38 =# @__MODULE__(), fullname)
        #= none:39 =#
        return TS(args...; kwargs...)
    end
#= none:43 =#
TimeStepper(stepper::AbstractTimeStepper, args...; kwargs...) = begin
        #= none:43 =#
        stepper
    end
#= none:45 =#
function update_state! end
#= none:46 =#
function compute_tendencies! end
#= none:48 =#
calculate_pressure_correction!(model, Δt) = begin
        #= none:48 =#
        nothing
    end
#= none:49 =#
pressure_correct_velocities!(model, Δt) = begin
        #= none:49 =#
        nothing
    end
#= none:52 =#
abstract type AbstractLagrangianParticles end
#= none:53 =#
step_lagrangian_particles!(model, Δt) = begin
        #= none:53 =#
        nothing
    end
#= none:55 =#
reset!(timestepper) = begin
        #= none:55 =#
        nothing
    end
#= none:56 =#
implicit_step!(field, ::Nothing, args...; kwargs...) = begin
        #= none:56 =#
        nothing
    end
#= none:58 =#
include("clock.jl")
#= none:59 =#
include("store_tendencies.jl")
#= none:60 =#
include("quasi_adams_bashforth_2.jl")
#= none:61 =#
include("runge_kutta_3.jl")
end