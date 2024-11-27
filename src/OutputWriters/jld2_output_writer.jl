
#= none:1 =#
using Printf
#= none:2 =#
using JLD2
#= none:3 =#
using Oceananigans.Utils
#= none:4 =#
using Oceananigans.Models
#= none:5 =#
using Oceananigans.Utils: TimeInterval, prettykeys
#= none:6 =#
using Oceananigans.Fields: boundary_conditions, indices
#= none:8 =#
default_included_properties(::NonhydrostaticModel) = begin
        #= none:8 =#
        [:grid, :coriolis, :buoyancy, :closure]
    end
#= none:9 =#
default_included_properties(::ShallowWaterModel) = begin
        #= none:9 =#
        [:grid, :coriolis, :closure]
    end
#= none:10 =#
default_included_properties(::HydrostaticFreeSurfaceModel) = begin
        #= none:10 =#
        [:grid, :coriolis, :buoyancy, :closure]
    end
#= none:12 =#
mutable struct JLD2OutputWriter{O, T, D, IF, IN, FS, KW} <: AbstractOutputWriter
    #= none:13 =#
    filepath::String
    #= none:14 =#
    outputs::O
    #= none:15 =#
    schedule::T
    #= none:16 =#
    array_type::D
    #= none:17 =#
    init::IF
    #= none:18 =#
    including::IN
    #= none:19 =#
    part::Int
    #= none:20 =#
    file_splitting::FS
    #= none:21 =#
    overwrite_existing::Bool
    #= none:22 =#
    verbose::Bool
    #= none:23 =#
    jld2_kw::KW
end
#= none:26 =#
noinit(args...) = begin
        #= none:26 =#
        nothing
    end
#= none:27 =#
ext(::Type{JLD2OutputWriter}) = begin
        #= none:27 =#
        ".jld2"
    end
#= none:29 =#
#= none:29 =# Core.@doc "    JLD2OutputWriter(model, outputs; filename, schedule,\n                              dir = \".\",\n                          indices = (:, :, :),\n                       with_halos = true,\n                       array_type = Array{Float64},\n                   file_splitting = NoFileSplitting(),\n               overwrite_existing = false,\n                             init = noinit,\n                        including = [:grid, :coriolis, :buoyancy, :closure],\n                          verbose = false,\n                             part = 1,\n                          jld2_kw = Dict{Symbol, Any}())\n\nConstruct a `JLD2OutputWriter` for an Oceananigans `model` that writes `label, output` pairs\nin `outputs` to a JLD2 file.\n\nThe argument `outputs` may be a `Dict` or `NamedTuple`. The keys of `outputs` are symbols or\nstrings that \"name\" output data. The values of `outputs` are either `AbstractField`s, objects that\nare called with the signature `output(model)`, or `WindowedTimeAverage`s of `AbstractFields`s,\nfunctions, or callable objects.\n\nKeyword arguments\n=================\n\n## Filenaming\n\n- `filename` (required): Descriptive filename. `\".jld2\"` is appended to `filename` in the file path\n                         if `filename` does not end in `\".jld2\"`.\n\n- `dir`: Directory to save output to. Default: `\".\"` (current working directory).\n\n## Output frequency and time-averaging\n\n- `schedule` (required): `AbstractSchedule` that determines when output is saved.\n\n## Slicing and type conversion prior to output\n\n- `indices`: Specifies the indices to write to disk with a `Tuple` of `Colon`, `UnitRange`,\n             or `Int` elements. Indices must be `Colon`, `Int`, or contiguous `UnitRange`.\n             Defaults to `(:, :, :)` or \"all indices\". If `!with_halos`,\n             halo regions are removed from `indices`. For example, `indices = (:, :, 1)`\n             will save xy-slices of the bottom-most index.\n\n- `with_halos` (Bool): Whether or not to slice off or keep halo regions from fields before writing output.\n                       Preserving halo region data can be useful for postprocessing. Default: true.\n\n- `array_type`: The array type to which output arrays are converted to prior to saving.\n                Default: `Array{Float64}`.\n\n## File management\n\n- `file_splitting`: Schedule for splitting the output file. The new files will be suffixed with\n                    `_part1`, `_part2`, etc. For example `file_splitting = FileSizeLimit(sz)` will\n                    split the output file when its size exceeds `sz`. Another example is \n                    `file_splitting = TimeInterval(30days)`, which will split files every 30 days of\n                    simulation time. The default incurs no splitting (`NoFileSplitting()`).\n                    \n- `overwrite_existing`: Remove existing files if their filenames conflict.\n                        Default: `false`.\n\n## Output file metadata management\n\n- `init`: A function of the form `init(file, model)` that runs when a JLD2 output file is initialized.\n          Default: `noinit(args...) = nothing`.\n\n- `including`: List of model properties to save with every file.\n               Default: `[:grid, :coriolis, :buoyancy, :closure]`\n\n## Miscellaneous keywords\n\n- `verbose`: Log what the output writer is doing with statistics on compute/write times and file sizes.\n             Default: `false`.\n\n- `part`: The starting part number used when file splitting.\n          Default: 1.\n\n- `jld2_kw`: Dict of kwargs to be passed to `jldopen` when data is written.\n\nExample\n=======\n\nWrite out 3D fields for ``u``, ``v``, ``w``, and a tracer ``c``, along with a horizontal average:\n\n```@example\nusing Oceananigans\nusing Oceananigans.Utils: hour, minute\n\nmodel = NonhydrostaticModel(grid=RectilinearGrid(size=(1, 1, 1), extent=(1, 1, 1)), tracers=:c)\nsimulation = Simulation(model, Δt=12, stop_time=1hour)\n\nfunction init_save_some_metadata!(file, model)\n    file[\"author\"] = \"Chim Riggles\"\n    file[\"parameters/coriolis_parameter\"] = 1e-4\n    file[\"parameters/density\"] = 1027\n    return nothing\nend\n\nc_avg =  Field(Average(model.tracers.c, dims=(1, 2)))\n\n# Note that model.velocities is NamedTuple\nsimulation.output_writers[:velocities] = JLD2OutputWriter(model, model.velocities,\n                                                          filename = \"some_data.jld2\",\n                                                          schedule = TimeInterval(20minute),\n                                                          init = init_save_some_metadata!)\n```\n\nand a time- and horizontal-average of tracer ``c`` every 20 minutes of simulation time\nto a file called `some_averaged_data.jld2`\n\n```@example\nsimulation.output_writers[:avg_c] = JLD2OutputWriter(model, (; c=c_avg),\n                                                     filename = \"some_averaged_data.jld2\",\n                                                     schedule = AveragedTimeInterval(20minute, window=5minute))\n```\n" function JLD2OutputWriter(model, outputs; filename, schedule, dir = ".", indices = (:, :, :), with_halos = true, array_type = Array{Float64}, file_splitting = NoFileSplitting(), overwrite_existing = false, init = noinit, including = default_included_properties(model), verbose = false, part = 1, jld2_kw = Dict{Symbol, Any}())
        #= none:145 =#
        #= none:158 =#
        mkpath(dir)
        #= none:159 =#
        filename = auto_extension(filename, ".jld2")
        #= none:160 =#
        filepath = abspath(joinpath(dir, filename))
        #= none:162 =#
        initialize!(file_splitting, model)
        #= none:163 =#
        update_file_splitting_schedule!(file_splitting, filepath)
        #= none:164 =#
        overwrite_existing && (isfile(filepath) && rm(filepath, force = true))
        #= none:166 =#
        outputs = NamedTuple((Symbol(name) => construct_output(outputs[name], model.grid, indices, with_halos) for name = keys(outputs)))
        #= none:170 =#
        (schedule, outputs) = time_average_outputs(schedule, outputs, model)
        #= none:172 =#
        initialize_jld2_file!(filepath, init, jld2_kw, including, outputs, model)
        #= none:174 =#
        return JLD2OutputWriter(filepath, outputs, schedule, array_type, init, including, part, file_splitting, overwrite_existing, verbose, jld2_kw)
    end
#= none:178 =#
function initialize_jld2_file!(filepath, init, jld2_kw, including, outputs, model)
    #= none:178 =#
    #= none:179 =#
    try
        #= none:180 =#
        jldopen(filepath, "a+"; jld2_kw...) do file
            #= none:181 =#
            init(file, model)
        end
    catch err
        #= none:184 =#
        #= none:184 =# @warn "Failed to execute user `init` for $(filepath) because $(typeof(err)): $(sprint(showerror, err))"
    end
    #= none:187 =#
    try
        #= none:188 =#
        jldopen(filepath, "a+"; jld2_kw...) do file
            #= none:189 =#
            saveproperties!(file, model, including)
            #= none:192 =#
            for property = including
                #= none:193 =#
                serializeproperty!(file, "serialized/$(property)", getproperty(model, property))
                #= none:194 =#
            end
        end
    catch err
        #= none:197 =#
        #= none:197 =# @warn "Failed to save and serialize $(including) in $(filepath) because $(typeof(err)): $(sprint(showerror, err))"
    end
    #= none:201 =#
    for (name, field) = pairs(outputs)
        #= none:202 =#
        try
            #= none:203 =#
            jldopen(filepath, "a+"; jld2_kw...) do file
                #= none:204 =#
                file["timeseries/$(name)/serialized/location"] = location(field)
                #= none:205 =#
                file["timeseries/$(name)/serialized/indices"] = indices(field)
                #= none:206 =#
                serializeproperty!(file, "timeseries/$(name)/serialized/boundary_conditions", boundary_conditions(field))
            end
        catch
            #= none:208 =#
        end
        #= none:210 =#
    end
    #= none:212 =#
    return nothing
end
#= none:215 =#
initialize_jld2_file!(writer::JLD2OutputWriter, model) = begin
        #= none:215 =#
        initialize_jld2_file!(writer.filepath, writer.init, writer.jld2_kw, writer.including, writer.outputs, model)
    end
#= none:218 =#
function iteration_exists(filepath, iter = 0)
    #= none:218 =#
    #= none:219 =#
    file = jldopen(filepath, "r")
    #= none:221 =#
    zero_exists = try
            #= none:222 =#
            t₀ = file["timeseries/t/$(iter)"]
            #= none:223 =#
            true
        catch
            #= none:226 =#
            false
        finally
            #= none:228 =#
            close(file)
        end
    #= none:231 =#
    return zero_exists
end
#= none:234 =#
function write_output!(writer::JLD2OutputWriter, model)
    #= none:234 =#
    #= none:236 =#
    verbose = writer.verbose
    #= none:237 =#
    current_iteration = model.clock.iteration
    #= none:240 =#
    if iteration_exists(writer.filepath, current_iteration)
        #= none:242 =#
        if writer.overwrite_existing
            #= none:244 =#
            rm(writer.filepath, force = true)
            #= none:245 =#
            initialize_jld2_file!(writer, model)
        else
            #= none:247 =#
            #= none:247 =# @warn "Iteration $(current_iteration) was found in $(writer.filepath). Skipping output writing (for now...)"
        end
    else
        #= none:253 =#
        verbose && #= none:253 =# @info(#= none:253 =# @sprintf("Fetching JLD2 output %s...", keys(writer.outputs)))
        #= none:255 =#
        tc = #= none:255 =# Base.@elapsed(data = NamedTuple((name => fetch_and_convert_output(output, model, writer) for (name, output) = zip(keys(writer.outputs), values(writer.outputs)))))
        #= none:258 =#
        verbose && #= none:258 =# @info("Fetching time: $(prettytime(tc))")
        #= none:261 =#
        writer.file_splitting(model) && start_next_file(model, writer)
        #= none:262 =#
        update_file_splitting_schedule!(writer.file_splitting, writer.filepath)
        #= none:264 =#
        verbose && #= none:264 =# @info("Writing JLD2 output $(keys(writer.outputs)) to $(path)...")
        #= none:266 =#
        (start_time, old_filesize) = (time_ns(), filesize(writer.filepath))
        #= none:267 =#
        jld2output!(writer.filepath, model.clock.iteration, model.clock.time, data, writer.jld2_kw)
        #= none:268 =#
        (end_time, new_filesize) = (time_ns(), filesize(writer.filepath))
        #= none:270 =#
        verbose && #= none:270 =# @info(#= none:270 =# @sprintf("Writing done: time=%s, size=%s, Δsize=%s", prettytime((end_time - start_time) / 1.0e9), pretty_filesize(new_filesize), pretty_filesize(new_filesize - old_filesize)))
    end
    #= none:276 =#
    return nothing
end
#= none:279 =#
#= none:279 =# Core.@doc "    jld2output!(path, iter, time, data, kwargs)\n\nWrite the (name, value) pairs in `data`, including the simulation\n`time`, to the JLD2 file at `path` in the `timeseries` group,\nstamping them with `iter` and using `kwargs` when opening\nthe JLD2 file.\n" function jld2output!(path, iter, time, data, kwargs)
        #= none:287 =#
        #= none:288 =#
        jldopen(path, "r+"; kwargs...) do file
            #= none:289 =#
            file["timeseries/t/$(iter)"] = time
            #= none:290 =#
            for name = keys(data)
                #= none:291 =#
                file["timeseries/$(name)/$(iter)"] = data[name]
                #= none:292 =#
            end
        end
        #= none:294 =#
        return nothing
    end
#= none:297 =#
function start_next_file(model, writer::JLD2OutputWriter)
    #= none:297 =#
    #= none:298 =#
    verbose = writer.verbose
    #= none:300 =#
    verbose && #= none:300 =# @info(begin
                #= none:301 =#
                schedule_type = summary(writer.file_splitting)
                #= none:302 =#
                "Splitting output because $(schedule_type) is activated."
            end)
    #= none:305 =#
    if writer.part == 1
        #= none:306 =#
        part1_path = replace(writer.filepath, r".jld2$" => "_part1.jld2")
        #= none:307 =#
        verbose && #= none:307 =# @info("Renaming first part: $(writer.filepath) -> $(part1_path)")
        #= none:308 =#
        mv(writer.filepath, part1_path, force = writer.overwrite_existing)
        #= none:309 =#
        writer.filepath = part1_path
    end
    #= none:312 =#
    writer.part += 1
    #= none:313 =#
    writer.filepath = replace(writer.filepath, r"part\d+.jld2$" => "part" * string(writer.part) * ".jld2")
    #= none:314 =#
    writer.overwrite_existing && (isfile(writer.filepath) && rm(writer.filepath, force = true))
    #= none:315 =#
    verbose && #= none:315 =# @info("Now writing to: $(writer.filepath)")
    #= none:317 =#
    initialize_jld2_file!(writer, model)
    #= none:319 =#
    return nothing
end
#= none:322 =#
Base.summary(ow::JLD2OutputWriter) = begin
        #= none:322 =#
        string("JLD2OutputWriter writing ", prettykeys(ow.outputs), " to ", ow.filepath, " on ", summary(ow.schedule))
    end
#= none:325 =#
function Base.show(io::IO, ow::JLD2OutputWriter)
    #= none:325 =#
    #= none:327 =#
    averaging_schedule = output_averaging_schedule(ow)
    #= none:328 =#
    Noutputs = length(ow.outputs)
    #= none:330 =#
    print(io, "JLD2OutputWriter scheduled on $(summary(ow.schedule)):", "\n", "├── filepath: ", relpath(ow.filepath), "\n", "├── $(Noutputs) outputs: ", prettykeys(ow.outputs), show_averaging_schedule(averaging_schedule), "\n", "├── array type: ", show_array_type(ow.array_type), "\n", "├── including: ", ow.including, "\n", "├── file_splitting: ", summary(ow.file_splitting), "\n", "└── file size: ", pretty_filesize(filesize(ow.filepath)))
end