
#= none:1 =#
using Oceananigans.Fields: set!
#= none:2 =#
using Oceananigans.OutputWriters: WindowedTimeAverage, checkpoint_superprefix
#= none:3 =#
using Oceananigans.TimeSteppers: QuasiAdamsBashforth2TimeStepper, RungeKutta3TimeStepper, update_state!, next_time, unit_time
#= none:5 =#
using Oceananigans: AbstractModel, run_diagnostic!, write_output!
#= none:7 =#
import Oceananigans: initialize!
#= none:8 =#
import Oceananigans.OutputWriters: checkpoint_path, set!
#= none:9 =#
import Oceananigans.TimeSteppers: time_step!
#= none:10 =#
import Oceananigans.Utils: schedule_aligned_time_step
#= none:18 =#
function collect_scheduled_activities(sim)
    #= none:18 =#
    #= none:19 =#
    writers = values(sim.output_writers)
    #= none:20 =#
    callbacks = values(sim.callbacks)
    #= none:21 =#
    return tuple(writers..., callbacks...)
end
#= none:24 =#
function schedule_aligned_time_step(sim, aligned_Δt)
    #= none:24 =#
    #= none:25 =#
    clock = sim.model.clock
    #= none:26 =#
    activities = collect_scheduled_activities(sim)
    #= none:28 =#
    for activity = activities
        #= none:29 =#
        aligned_Δt = schedule_aligned_time_step(activity.schedule, clock, aligned_Δt)
        #= none:30 =#
    end
    #= none:32 =#
    return aligned_Δt
end
#= none:35 =#
#= none:35 =# Core.@doc "    aligned_time_step(sim, Δt)\n\nReturn a time step 'aligned' with `sim.stop_time`, output writer schedules, \nand callback schedules. Alignment with `sim.stop_time` takes precedence.\n" function aligned_time_step(sim::Simulation, Δt)
        #= none:41 =#
        #= none:42 =#
        clock = sim.model.clock
        #= none:44 =#
        aligned_Δt = Δt
        #= none:47 =#
        aligned_Δt = schedule_aligned_time_step(sim, aligned_Δt)
        #= none:50 =#
        aligned_Δt = min(aligned_Δt, unit_time(sim.stop_time - clock.time))
        #= none:53 =#
        aligned_Δt = if aligned_Δt <= 0
                Δt
            else
                aligned_Δt
            end
        #= none:55 =#
        return aligned_Δt
    end
#= none:58 =#
#= none:58 =# Core.@doc "    run!(simulation; pickup=false)\n\nRun a `simulation` until one of `simulation.stop_criteria` evaluates `true`.\nThe simulation will then stop.\n\n# Picking simulations up from a checkpoint\n\nSimulations are \"picked up\" from a checkpoint if `pickup` is either `true`, a `String`, or an\n`Integer` greater than 0.\n\nPicking up a simulation sets field and tendency data to the specified checkpoint,\nleaving all other model properties unchanged.\n\nPossible values for `pickup` are:\n\n  * `pickup=true` picks a simulation up from the latest checkpoint associated with\n    the `Checkpointer` in `simulation.output_writers`.\n\n  * `pickup=iteration::Int` picks a simulation up from the checkpointed file associated\n     with `iteration` and the `Checkpointer` in `simulation.output_writers`.\n\n  * `pickup=filepath::String` picks a simulation up from checkpointer data in `filepath`.\n\nNote that `pickup=true` and `pickup=iteration` fails if `simulation.output_writers` contains\nmore than one checkpointer.\n" function run!(sim; pickup = false)
        #= none:85 =#
        #= none:87 =#
        if we_want_to_pickup(pickup)
            #= none:88 =#
            checkpoint_file_path = checkpoint_path(pickup, sim.output_writers)
            #= none:89 =#
            set!(sim.model, checkpoint_file_path)
        end
        #= none:92 =#
        sim.initialized = false
        #= none:93 =#
        sim.running = true
        #= none:94 =#
        sim.run_wall_time = 0.0
        #= none:96 =#
        while sim.running
            #= none:97 =#
            time_step!(sim)
            #= none:98 =#
        end
        #= none:100 =#
        return nothing
    end
#= none:103 =#
const ModelCallsite = Union{TendencyCallsite, UpdateStateCallsite}
#= none:105 =#
#= none:105 =# Core.@doc " Step `sim`ulation forward by one time step. " function time_step!(sim::Simulation)
        #= none:106 =#
        #= none:108 =#
        start_time_step = time_ns()
        #= none:109 =#
        model_callbacks = Tuple((cb for cb = values(sim.callbacks) if cb.callsite isa ModelCallsite))
        #= none:111 =#
        if !(sim.initialized)
            #= none:112 =#
            initialize!(sim)
            #= none:113 =#
            initialize!(sim.model)
            #= none:115 =#
            if sim.running
                #= none:116 =#
                if sim.verbose
                    #= none:117 =#
                    #= none:117 =# @info "Executing initial time step..."
                    #= none:118 =#
                    start_time = time_ns()
                end
                #= none:121 =#
                Δt = aligned_time_step(sim, sim.Δt)
                #= none:122 =#
                time_step!(sim.model, Δt, callbacks = model_callbacks)
                #= none:124 =#
                if sim.verbose
                    #= none:125 =#
                    elapsed_initial_step_time = prettytime(1.0e-9 * (time_ns() - start_time))
                    #= none:126 =#
                    #= none:126 =# @info "    ... initial time step complete ($(elapsed_initial_step_time))."
                end
            else
                #= none:129 =#
                #= none:129 =# @warn "Simulation stopped during initialization."
            end
        else
            #= none:133 =#
            Δt = aligned_time_step(sim, sim.Δt)
            #= none:134 =#
            time_step!(sim.model, Δt, callbacks = model_callbacks)
        end
        #= none:138 =#
        for diag = values(sim.diagnostics)
            #= none:139 =#
            diag.schedule(sim.model) && run_diagnostic!(diag, sim.model)
            #= none:140 =#
        end
        #= none:142 =#
        for callback = values(sim.callbacks)
            #= none:143 =#
            callback.callsite isa TimeStepCallsite && (callback.schedule(sim.model) && callback(sim))
            #= none:144 =#
        end
        #= none:146 =#
        for writer = values(sim.output_writers)
            #= none:147 =#
            writer.schedule(sim.model) && write_output!(writer, sim.model)
            #= none:148 =#
        end
        #= none:150 =#
        end_time_step = time_ns()
        #= none:153 =#
        sim.run_wall_time += 1.0e-9 * (end_time_step - start_time_step)
        #= none:155 =#
        return nothing
    end
#= none:162 =#
add_dependency!(diagnostics, output) = begin
        #= none:162 =#
        nothing
    end
#= none:163 =#
add_dependency!(diags, wta::WindowedTimeAverage) = begin
        #= none:163 =#
        wta ∈ values(diags) || push!(diags, wta)
    end
#= none:165 =#
add_dependencies!(diags, writer) = begin
        #= none:165 =#
        [add_dependency!(diags, out) for out = values(writer.outputs)]
    end
#= none:166 =#
add_dependencies!(sim, ::Checkpointer) = begin
        #= none:166 =#
        nothing
    end
#= none:168 =#
we_want_to_pickup(pickup::Bool) = begin
        #= none:168 =#
        pickup
    end
#= none:169 =#
we_want_to_pickup(pickup::Integer) = begin
        #= none:169 =#
        true
    end
#= none:170 =#
we_want_to_pickup(pickup::String) = begin
        #= none:170 =#
        true
    end
#= none:171 =#
we_want_to_pickup(pickup) = begin
        #= none:171 =#
        throw(ArgumentError("Cannot run! with pickup=$(pickup)"))
    end
#= none:173 =#
#= none:173 =# Core.@doc " \n    initialize!(sim::Simulation, pickup=false)\n\nInitialize a simulation:\n\n- Update the auxiliary state of the simulation (filling halo regions, computing auxiliary fields)\n- Evaluate all diagnostics, callbacks, and output writers if sim.model.clock.iteration == 0\n- Add diagnostics that \"depend\" on output writers\n" function initialize!(sim::Simulation)
        #= none:182 =#
        #= none:183 =#
        if sim.verbose
            #= none:184 =#
            #= none:184 =# @info "Initializing simulation..."
            #= none:185 =#
            start_time = time_ns()
        end
        #= none:188 =#
        model = sim.model
        #= none:189 =#
        clock = model.clock
        #= none:191 =#
        update_state!(model)
        #= none:194 =#
        [add_dependencies!(sim.diagnostics, writer) for writer = values(sim.output_writers)]
        #= none:197 =#
        scheduled_activities = Iterators.flatten((values(sim.diagnostics), values(sim.callbacks), values(sim.output_writers)))
        #= none:201 =#
        for activity = scheduled_activities
            #= none:202 =#
            initialize!(activity.schedule, sim.model)
            #= none:203 =#
        end
        #= none:206 =#
        if clock.iteration == 0
            #= none:207 =#
            reset!(timestepper(sim.model))
            #= none:210 =#
            for diag = values(sim.diagnostics)
                #= none:211 =#
                run_diagnostic!(diag, model)
                #= none:212 =#
            end
            #= none:214 =#
            for callback = values(sim.callbacks)
                #= none:215 =#
                callback.callsite isa TimeStepCallsite && callback(sim)
                #= none:216 =#
            end
            #= none:218 =#
            for writer = values(sim.output_writers)
                #= none:219 =#
                writer.schedule(sim.model)
                #= none:220 =#
                write_output!(writer, model)
                #= none:221 =#
            end
        end
        #= none:224 =#
        sim.initialized = true
        #= none:226 =#
        if sim.verbose
            #= none:227 =#
            initialization_time = prettytime(1.0e-9 * (time_ns() - start_time))
            #= none:228 =#
            #= none:228 =# @info "    ... simulation initialization complete ($(initialization_time))"
        end
        #= none:231 =#
        return nothing
    end