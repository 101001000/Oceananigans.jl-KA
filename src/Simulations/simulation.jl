
#= none:1 =#
using Oceananigans: prognostic_fields
#= none:2 =#
using Oceananigans.Models: default_nan_checker, NaNChecker, timestepper
#= none:3 =#
using Oceananigans.DistributedComputations: Distributed, all_reduce
#= none:5 =#
import Oceananigans.Models: iteration
#= none:6 =#
import Oceananigans.Utils: prettytime
#= none:7 =#
import Oceananigans.TimeSteppers: reset!
#= none:9 =#
default_progress(simulation) = begin
        #= none:9 =#
        nothing
    end
#= none:11 =#
mutable struct Simulation{ML, DT, ST, DI, OW, CB}
    #= none:12 =#
    model::ML
    #= none:13 =#
    Δt::DT
    #= none:14 =#
    stop_iteration::Float64
    #= none:15 =#
    stop_time::ST
    #= none:16 =#
    wall_time_limit::Float64
    #= none:17 =#
    diagnostics::DI
    #= none:18 =#
    output_writers::OW
    #= none:19 =#
    callbacks::CB
    #= none:20 =#
    run_wall_time::Float64
    #= none:21 =#
    running::Bool
    #= none:22 =#
    initialized::Bool
    #= none:23 =#
    verbose::Bool
end
#= none:26 =#
#= none:26 =# Core.@doc "    Simulation(model; Δt,\n               verbose = true,\n               stop_iteration = Inf,\n               stop_time = Inf,\n               wall_time_limit = Inf)\n\nConstruct a `Simulation` for a `model` with time step `Δt`.\n\nKeyword arguments\n=================\n\n- `Δt`: Required keyword argument specifying the simulation time step. Can be a `Number`\n        for constant time steps or a `TimeStepWizard` for adaptive time-stepping.\n\n- `stop_iteration`: Stop the simulation after this many iterations.\n\n- `stop_time`: Stop the simulation once this much model clock time has passed.\n\n- `wall_time_limit`: Stop the simulation if it's been running for longer than this many\n                     seconds of wall clock time.\n" function Simulation(model; Δt, verbose = true, stop_iteration = Inf, stop_time = Inf, wall_time_limit = Inf)
        #= none:48 =#
        #= none:54 =#
        if stop_iteration == Inf && (stop_time == Inf && wall_time_limit == Inf)
            #= none:55 =#
            #= none:55 =# @warn "This simulation will run forever as stop iteration = stop time " * "= wall time limit = Inf."
        end
        #= none:59 =#
        Δt = validate_Δt(Δt, architecture(model))
        #= none:61 =#
        diagnostics = OrderedDict{Symbol, AbstractDiagnostic}()
        #= none:62 =#
        output_writers = OrderedDict{Symbol, AbstractOutputWriter}()
        #= none:63 =#
        callbacks = OrderedDict{Symbol, Callback}()
        #= none:65 =#
        callbacks[:stop_time_exceeded] = Callback(stop_time_exceeded)
        #= none:66 =#
        callbacks[:stop_iteration_exceeded] = Callback(stop_iteration_exceeded)
        #= none:67 =#
        callbacks[:wall_time_limit_exceeded] = Callback(wall_time_limit_exceeded)
        #= none:69 =#
        nan_checker = default_nan_checker(model)
        #= none:70 =#
        if !(isnothing(nan_checker))
            #= none:71 =#
            callbacks[:nan_checker] = Callback(nan_checker, IterationInterval(100))
        end
        #= none:76 =#
        TT = eltype(model.grid)
        #= none:77 =#
        Δt = if Δt isa Number
                TT(Δt)
            else
                Δt
            end
        #= none:78 =#
        stop_time = if stop_time isa Number
                TT(stop_time)
            else
                stop_time
            end
        #= none:80 =#
        return Simulation(model, Δt, Float64(stop_iteration), stop_time, Float64(wall_time_limit), diagnostics, output_writers, callbacks, 0.0, false, false, verbose)
    end
#= none:94 =#
function Base.show(io::IO, s::Simulation)
    #= none:94 =#
    #= none:95 =#
    modelstr = summary(s.model)
    #= none:96 =#
    return print(io, "Simulation of ", modelstr, "\n", "├── Next time step: $(prettytime(s.Δt))", "\n", "├── Elapsed wall time: $(prettytime(s.run_wall_time))", "\n", "├── Wall time per iteration: $(prettytime(s.run_wall_time / iteration(s)))", "\n", "├── Stop time: $(prettytime(s.stop_time))", "\n", "├── Stop iteration : $(s.stop_iteration)", "\n", "├── Wall time limit: $(s.wall_time_limit)", "\n", "├── Callbacks: $(ordered_dict_show(s.callbacks, "│"))", "\n", "├── Output writers: $(ordered_dict_show(s.output_writers, "│"))", "\n", "└── Diagnostics: $(ordered_dict_show(s.diagnostics, "│"))")
end
#= none:112 =#
#= none:112 =# Core.@doc "    validate_Δt(Δt, arch)\n\nMake sure different workers are using the same time step\n" function validate_Δt(Δt, arch::Distributed)
        #= none:117 =#
        #= none:118 =#
        Δt_min = all_reduce(min, Δt, arch)
        #= none:119 =#
        if Δt != Δt_min
            #= none:120 =#
            #= none:120 =# @warn "On rank $(arch.local_rank), Δt = $(Δt) is not the same as for the other workers. Using the minimum Δt = $(Δt_min) instead."
        end
        #= none:122 =#
        return Δt_min
    end
#= none:126 =#
validate_Δt(Δt, arch) = begin
        #= none:126 =#
        Δt
    end
#= none:128 =#
#= none:128 =# Core.@doc "    time(sim::Simulation)\n\nReturn the current simulation time.\n" Base.time(sim::Simulation) = begin
            #= none:133 =#
            time(sim.model)
        end
#= none:135 =#
#= none:135 =# Core.@doc "    iteration(sim::Simulation)\n\nReturn the current simulation iteration.\n" iteration(sim::Simulation) = begin
            #= none:140 =#
            iteration(sim.model)
        end
#= none:142 =#
#= none:142 =# Core.@doc "    prettytime(sim::Simulation)\n\nReturn `sim.model.clock.time` as a prettily formatted string.\"\n" prettytime(sim::Simulation, longform = true) = begin
            #= none:147 =#
            prettytime(time(sim))
        end
#= none:149 =#
#= none:149 =# Core.@doc "    run_wall_time(sim::Simulation)\n\nReturn `sim.run_wall_time` as a prettily formatted string.\"\n" run_wall_time(sim::Simulation) = begin
            #= none:154 =#
            prettytime(sim.run_wall_time)
        end
#= none:156 =#
#= none:156 =# Core.@doc "    reset!(sim)\n\nReset `sim`ulation, `model.clock`, and `model.timestepper` to their initial state.\n" function reset!(sim::Simulation)
        #= none:161 =#
        #= none:162 =#
        sim.model.clock.time = 0
        #= none:163 =#
        sim.model.clock.last_Δt = Inf
        #= none:164 =#
        sim.model.clock.iteration = 0
        #= none:165 =#
        sim.model.clock.stage = 1
        #= none:166 =#
        sim.stop_iteration = Inf
        #= none:167 =#
        sim.stop_time = Inf
        #= none:168 =#
        sim.wall_time_limit = Inf
        #= none:169 =#
        sim.run_wall_time = 0.0
        #= none:170 =#
        sim.initialized = false
        #= none:171 =#
        sim.running = true
        #= none:172 =#
        reset!(timestepper(sim.model))
        #= none:173 =#
        return nothing
    end
#= none:180 =#
wall_time_msg(sim) = begin
        #= none:180 =#
        string("Simulation is stopping after running for ", run_wall_time(sim), ".")
    end
#= none:182 =#
function stop_iteration_exceeded(sim)
    #= none:182 =#
    #= none:183 =#
    if sim.model.clock.iteration >= sim.stop_iteration
        #= none:184 =#
        if sim.verbose
            #= none:185 =#
            msg = string("Model iteration ", iteration(sim), " equals or exceeds stop iteration ", Int(sim.stop_iteration), ".")
            #= none:186 =#
            #= none:186 =# @info wall_time_msg(sim)
            #= none:187 =#
            #= none:187 =# @info msg
        end
        #= none:190 =#
        sim.running = false
    end
    #= none:193 =#
    return nothing
end
#= none:196 =#
function stop_time_exceeded(sim)
    #= none:196 =#
    #= none:197 =#
    if sim.model.clock.time >= sim.stop_time
        #= none:198 =#
        if sim.verbose
            #= none:199 =#
            msg = string("Simulation time ", prettytime(sim), " equals or exceeds stop time ", prettytime(sim.stop_time), ".")
            #= none:200 =#
            #= none:200 =# @info wall_time_msg(sim)
            #= none:201 =#
            #= none:201 =# @info msg
        end
        #= none:204 =#
        sim.running = false
    end
    #= none:207 =#
    return nothing
end
#= none:210 =#
function wall_time_limit_exceeded(sim)
    #= none:210 =#
    #= none:211 =#
    if sim.run_wall_time >= sim.wall_time_limit
        #= none:212 =#
        if sim.verbose
            #= none:213 =#
            msg = string("Simulation run time ", run_wall_time(sim), " equals or exceeds wall time limit ", prettytime(sim.wall_time_limit), ".")
            #= none:214 =#
            #= none:214 =# @info wall_time_msg(sim)
            #= none:215 =#
            #= none:215 =# @info msg
        end
        #= none:218 =#
        sim.running = false
    end
    #= none:221 =#
    return nothing
end