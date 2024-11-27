
#= none:1 =#
using Glob
#= none:3 =#
using Oceananigans
#= none:4 =#
using Oceananigans: fields, prognostic_fields
#= none:5 =#
using Oceananigans.Fields: offset_data
#= none:6 =#
using Oceananigans.TimeSteppers: RungeKutta3TimeStepper, QuasiAdamsBashforth2TimeStepper
#= none:8 =#
import Oceananigans.Fields: set!
#= none:10 =#
mutable struct Checkpointer{T, P} <: AbstractOutputWriter
    #= none:11 =#
    schedule::T
    #= none:12 =#
    dir::String
    #= none:13 =#
    prefix::String
    #= none:14 =#
    properties::P
    #= none:15 =#
    overwrite_existing::Bool
    #= none:16 =#
    verbose::Bool
    #= none:17 =#
    cleanup::Bool
end
#= none:20 =#
#= none:20 =# Core.@doc "    Checkpointer(model;\n                 schedule,\n                 dir = \".\",\n                 prefix = \"checkpoint\",\n                 overwrite_existing = false,\n                 verbose = false,\n                 cleanup = false,\n                 properties = [:grid, :clock, :coriolis,\n                               :buoyancy, :closure, :timestepper, :particles])\n\nConstruct a `Checkpointer` that checkpoints the model to a JLD2 file on `schedule.`\nThe `model.clock.iteration` is included in the filename to distinguish between multiple checkpoint files.\n\nTo restart or \"pickup\" a model from a checkpoint, specify `pickup = true` when calling `run!`, ensuring\nthat the checkpoint file is in directory `dir`. See [`run!`](@ref) for more details.\n\nNote that extra model `properties` can be specified, but removing crucial properties\nsuch as `:timestepper` will render restoring from the checkpoint impossible.\n\nThe checkpointer attempts to serialize as much of the model to disk as possible,\nbut functions or objects containing functions cannot be serialized at this time.\n\nKeyword arguments\n=================\n\n- `schedule` (required): Schedule that determines when to checkpoint.\n\n- `dir`: Directory to save output to. Default: `\".\"` (current working directory).\n\n- `prefix`: Descriptive filename prefixed to all output files. Default: `\"checkpoint\"`.\n\n- `overwrite_existing`: Remove existing files if their filenames conflict. Default: `false`.\n\n- `verbose`: Log what the output writer is doing with statistics on compute/write times\n             and file sizes. Default: `false`.\n\n- `cleanup`: Previous checkpoint files will be deleted once a new checkpoint file is written.\n             Default: `false`.\n\n- `properties`: List of model properties to checkpoint. This list _must_ contain\n                `:grid`, `:timestepper`, and `:particles`.\n                Default: `[:grid, :timestepper, :particles, :clock, :coriolis, :buoyancy, :closure]`\n" function Checkpointer(model; schedule, dir = ".", prefix = "checkpoint", overwrite_existing = false, verbose = false, cleanup = false, properties = [:grid, :timestepper, :particles, :clock, :coriolis, :buoyancy, :closure])
        #= none:64 =#
        #= none:74 =#
        required_properties = (:grid, :timestepper, :particles)
        #= none:76 =#
        for rp = required_properties
            #= none:77 =#
            if rp ∉ properties
                #= none:78 =#
                #= none:78 =# @warn "$(rp) is required for checkpointing. It will be added to checkpointed properties"
                #= none:79 =#
                push!(properties, rp)
            end
            #= none:81 =#
        end
        #= none:83 =#
        for p = properties
            #= none:84 =#
            p isa Symbol || error("Property $(p) to be checkpointed must be a Symbol.")
            #= none:85 =#
            p ∉ propertynames(model) && error("Cannot checkpoint $(p), it is not a model property!")
            #= none:87 =#
            if p ∉ required_properties && has_reference(Function, getproperty(model, p))
                #= none:88 =#
                #= none:88 =# @warn "model.$(p) contains a function somewhere in its hierarchy and will not be checkpointed."
                #= none:89 =#
                filter!((e->begin
                            #= none:89 =#
                            e != p
                        end), properties)
            end
            #= none:91 =#
        end
        #= none:93 =#
        mkpath(dir)
        #= none:95 =#
        return Checkpointer(schedule, dir, prefix, properties, overwrite_existing, verbose, cleanup)
    end
#= none:102 =#
#= none:102 =# Core.@doc " Return the full prefix (the `superprefix`) associated with `checkpointer`. " checkpoint_superprefix(prefix) = begin
            #= none:103 =#
            prefix * "_iteration"
        end
#= none:105 =#
#= none:105 =# Core.@doc "    checkpoint_path(iteration::Int, c::Checkpointer)\n\nReturn the path to the `c`heckpointer file associated with model `iteration`.\n" checkpoint_path(iteration::Int, c::Checkpointer) = begin
            #= none:110 =#
            joinpath(c.dir, string(checkpoint_superprefix(c.prefix), iteration, ".jld2"))
        end
#= none:114 =#
defaultname(::Checkpointer, nelems) = begin
        #= none:114 =#
        :checkpointer
    end
#= none:116 =#
#= none:116 =# Core.@doc " Returns `filepath`. Shortcut for `run!(simulation, pickup=filepath)`. " checkpoint_path(filepath::AbstractString, output_writers) = begin
            #= none:117 =#
            filepath
        end
#= none:119 =#
function checkpoint_path(pickup, output_writers)
    #= none:119 =#
    #= none:120 =#
    checkpointers = filter((writer->begin
                    #= none:120 =#
                    writer isa Checkpointer
                end), collect(values(output_writers)))
    #= none:121 =#
    length(checkpointers) == 0 && error("No checkpointers found: cannot pickup simulation!")
    #= none:122 =#
    length(checkpointers) > 1 && error("Multiple checkpointers found: not sure which one to pickup simulation from!")
    #= none:123 =#
    return checkpoint_path(pickup, first(checkpointers))
end
#= none:126 =#
#= none:126 =# Core.@doc "    checkpoint_path(pickup::Bool, checkpointer)\n\nFor `pickup=true`, parse the filenames in `checkpointer.dir` associated with\n`checkpointer.prefix` and return the path to the file whose name contains\nthe largest iteration.\n" function checkpoint_path(pickup::Bool, checkpointer::Checkpointer)
        #= none:133 =#
        #= none:134 =#
        filepaths = glob(checkpoint_superprefix(checkpointer.prefix) * "*.jld2", checkpointer.dir)
        #= none:136 =#
        if length(filepaths) == 0
            #= none:138 =#
            #= none:138 =# @warn "pickup=true but no checkpoints were found. Simulation will run without picking up."
            #= none:139 =#
            return nothing
        else
            #= none:141 =#
            return latest_checkpoint(checkpointer, filepaths)
        end
    end
#= none:145 =#
function latest_checkpoint(checkpointer, filepaths)
    #= none:145 =#
    #= none:146 =#
    filenames = basename.(filepaths)
    #= none:147 =#
    leading = length(checkpoint_superprefix(checkpointer.prefix))
    #= none:148 =#
    trailing = length(".jld2")
    #= none:149 =#
    iterations = map((name->begin
                    #= none:149 =#
                    parse(Int, name[leading + 1:end - trailing])
                end), filenames)
    #= none:150 =#
    (latest_iteration, idx) = findmax(iterations)
    #= none:151 =#
    return filepaths[idx]
end
#= none:158 =#
function write_output!(c::Checkpointer, model)
    #= none:158 =#
    #= none:159 =#
    filepath = checkpoint_path(model.clock.iteration, c)
    #= none:160 =#
    c.verbose && #= none:160 =# @info("Checkpointing to file $(filepath)...")
    #= none:162 =#
    t1 = time_ns()
    #= none:163 =#
    jldopen(filepath, "w") do file
        #= none:164 =#
        file["checkpointed_properties"] = c.properties
        #= none:165 =#
        serializeproperties!(file, model, c.properties)
        #= none:167 =#
        model_fields = fields(model)
        #= none:168 =#
        field_names = keys(model_fields)
        #= none:169 =#
        for name = field_names
            #= none:170 =#
            serializeproperty!(file, string(name), model_fields[name])
            #= none:171 =#
        end
    end
    #= none:174 =#
    (t2, sz) = (time_ns(), filesize(filepath))
    #= none:175 =#
    c.verbose && #= none:175 =# @info("Checkpointing done: time=$(prettytime((t2 - t1) / 1.0e9)), size=$(pretty_filesize(sz))")
    #= none:177 =#
    c.cleanup && cleanup_checkpoints(c)
    #= none:179 =#
    return nothing
end
#= none:182 =#
function cleanup_checkpoints(checkpointer)
    #= none:182 =#
    #= none:183 =#
    filepaths = glob(checkpoint_superprefix(checkpointer.prefix) * "*.jld2", checkpointer.dir)
    #= none:184 =#
    latest_checkpoint_filepath = latest_checkpoint(checkpointer, filepaths)
    #= none:185 =#
    [rm(filepath) for filepath = filepaths if filepath != latest_checkpoint_filepath]
    #= none:186 =#
    return nothing
end
#= none:193 =#
set!(model, ::Nothing) = begin
        #= none:193 =#
        nothing
    end
#= none:195 =#
#= none:195 =# Core.@doc "    set!(model, filepath::AbstractString)\n\nSet data in `model.velocities`, `model.tracers`, `model.timestepper.Gⁿ`, and\n`model.timestepper.G⁻` to checkpointed data stored at `filepath`.\n" function set!(model, filepath::AbstractString)
        #= none:201 =#
        #= none:203 =#
        jldopen(filepath, "r") do file
            #= none:206 =#
            checkpointed_grid = file["grid"]
            #= none:207 =#
            model.grid == checkpointed_grid || #= none:208 =# @warn("The grid associated with $(filepath) and model.grid are not the same!")
            #= none:210 =#
            model_fields = prognostic_fields(model)
            #= none:212 =#
            for name = propertynames(model_fields)
                #= none:213 =#
                if string(name) ∈ keys(file)
                    #= none:214 =#
                    model_field = model_fields[name]
                    #= none:215 =#
                    parent_data = file["$(name)/data"]
                    #= none:216 =#
                    copyto!(model_field.data.parent, parent_data)
                else
                    #= none:218 =#
                    #= none:218 =# @warn "Field $(name) does not exist in checkpoint and could not be restored."
                end
                #= none:220 =#
            end
            #= none:222 =#
            set_time_stepper!(model.timestepper, file, model_fields)
            #= none:224 =#
            if !(isnothing(model.particles))
                #= none:225 =#
                copyto!(model.particles.properties, file["particles"])
            end
            #= none:228 =#
            checkpointed_clock = file["clock"]
            #= none:231 =#
            model.clock.iteration = checkpointed_clock.iteration
            #= none:232 =#
            model.clock.time = checkpointed_clock.time
            #= none:233 =#
            model.clock.last_Δt = checkpointed_clock.last_Δt
        end
        #= none:236 =#
        return nothing
    end
#= none:239 =#
function set_time_stepper_tendencies!(timestepper, file, model_fields)
    #= none:239 =#
    #= none:240 =#
    for name = propertynames(model_fields)
        #= none:241 =#
        if string(name) ∈ keys(file["timestepper/Gⁿ"])
            #= none:243 =#
            parent_data = file["timestepper/Gⁿ/$(name)/data"]
            #= none:245 =#
            tendencyⁿ_field = timestepper.Gⁿ[name]
            #= none:246 =#
            copyto!(tendencyⁿ_field.data.parent, parent_data)
            #= none:249 =#
            parent_data = file["timestepper/G⁻/$(name)/data"]
            #= none:251 =#
            tendency⁻_field = timestepper.G⁻[name]
            #= none:252 =#
            copyto!(tendency⁻_field.data.parent, parent_data)
        else
            #= none:254 =#
            #= none:254 =# @warn "Tendencies for $(name) do not exist in checkpoint and could not be restored."
        end
        #= none:256 =#
    end
    #= none:258 =#
    return nothing
end
#= none:261 =#
set_time_stepper!(timestepper::RungeKutta3TimeStepper, file, model_fields) = begin
        #= none:261 =#
        set_time_stepper_tendencies!(timestepper, file, model_fields)
    end
#= none:264 =#
set_time_stepper!(timestepper::QuasiAdamsBashforth2TimeStepper, file, model_fields) = begin
        #= none:264 =#
        set_time_stepper_tendencies!(timestepper, file, model_fields)
    end