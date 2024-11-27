
#= none:1 =#
using NCDatasets
#= none:3 =#
using Dates: AbstractTime, now
#= none:5 =#
using Oceananigans.Fields
#= none:7 =#
using Oceananigans.Grids: AbstractCurvilinearGrid, RectilinearGrid, topology, halo_size, parent_index_range, ξnodes, ηnodes, rnodes
#= none:8 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid
#= none:9 =#
using Oceananigans.Utils: versioninfo_with_gpu, oceananigans_versioninfo, prettykeys
#= none:10 =#
using Oceananigans.TimeSteppers: float_or_date_time
#= none:11 =#
using Oceananigans.Fields: reduced_dimensions, reduced_location, location, validate_indices
#= none:13 =#
mutable struct NetCDFOutputWriter{G, D, O, T, A, FS} <: AbstractOutputWriter
    #= none:14 =#
    grid::G
    #= none:15 =#
    filepath::String
    #= none:16 =#
    dataset::D
    #= none:17 =#
    outputs::O
    #= none:18 =#
    schedule::T
    #= none:19 =#
    array_type::A
    #= none:20 =#
    indices::Tuple
    #= none:21 =#
    with_halos::Bool
    #= none:22 =#
    global_attributes::Dict
    #= none:23 =#
    output_attributes::Dict
    #= none:24 =#
    dimensions::Dict
    #= none:25 =#
    overwrite_existing::Bool
    #= none:26 =#
    deflatelevel::Int
    #= none:27 =#
    part::Int
    #= none:28 =#
    file_splitting::FS
    #= none:29 =#
    verbose::Bool
end
#= none:32 =#
ext(::Type{NetCDFOutputWriter}) = begin
        #= none:32 =#
        ".nc"
    end
#= none:34 =#
dictify(outputs) = begin
        #= none:34 =#
        outputs
    end
#= none:35 =#
dictify(outputs::NamedTuple) = begin
        #= none:35 =#
        Dict((string(k) => dictify(v) for (k, v) = zip(keys(outputs), values(outputs))))
    end
#= none:37 =#
xdim(::Face) = begin
        #= none:37 =#
        tuple("xF")
    end
#= none:38 =#
ydim(::Face) = begin
        #= none:38 =#
        tuple("yF")
    end
#= none:39 =#
zdim(::Face) = begin
        #= none:39 =#
        tuple("zF")
    end
#= none:41 =#
xdim(::Center) = begin
        #= none:41 =#
        tuple("xC")
    end
#= none:42 =#
ydim(::Center) = begin
        #= none:42 =#
        tuple("yC")
    end
#= none:43 =#
zdim(::Center) = begin
        #= none:43 =#
        tuple("zC")
    end
#= none:45 =#
xdim(::Nothing) = begin
        #= none:45 =#
        tuple()
    end
#= none:46 =#
ydim(::Nothing) = begin
        #= none:46 =#
        tuple()
    end
#= none:47 =#
zdim(::Nothing) = begin
        #= none:47 =#
        tuple()
    end
#= none:49 =#
(netcdf_spatial_dimensions(::AbstractField{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:49 =#
        tuple(xdim(instantiate(LX))..., ydim(instantiate(LY))..., zdim(instantiate(LZ))...)
    end
#= none:52 =#
function native_dimensions_for_netcdf_output(grid, indices, TX, TY, TZ, Hx, Hy, Hz)
    #= none:52 =#
    #= none:53 =#
    with_halos = true
    #= none:55 =#
    xC = ξnodes(grid, c; with_halos)
    #= none:56 =#
    xF = ξnodes(grid, f; with_halos)
    #= none:57 =#
    yC = ηnodes(grid, c; with_halos)
    #= none:58 =#
    yF = ηnodes(grid, f; with_halos)
    #= none:59 =#
    zC = rnodes(grid, c; with_halos)
    #= none:60 =#
    zF = rnodes(grid, f; with_halos)
    #= none:62 =#
    xC = if isnothing(xC)
            [0.0]
        else
            parent(xC)
        end
    #= none:63 =#
    xF = if isnothing(xF)
            [0.0]
        else
            parent(xF)
        end
    #= none:64 =#
    yC = if isnothing(yC)
            [0.0]
        else
            parent(yC)
        end
    #= none:65 =#
    yF = if isnothing(yF)
            [0.0]
        else
            parent(yF)
        end
    #= none:66 =#
    zC = if isnothing(zC)
            [0.0]
        else
            parent(zC)
        end
    #= none:67 =#
    zF = if isnothing(zF)
            [0.0]
        else
            parent(zF)
        end
    #= none:69 =#
    dims = Dict("xC" => xC[parent_index_range((indices["xC"])[1], c, TX(), Hx)], "xF" => xF[parent_index_range((indices["xF"])[1], f, TX(), Hx)], "yC" => yC[parent_index_range((indices["yC"])[2], c, TY(), Hy)], "yF" => yF[parent_index_range((indices["yF"])[2], f, TY(), Hy)], "zC" => zC[parent_index_range((indices["zC"])[3], c, TZ(), Hz)], "zF" => zF[parent_index_range((indices["zF"])[3], f, TZ(), Hz)])
    #= none:76 =#
    return dims
end
#= none:79 =#
function default_dimensions(output, grid, indices, with_halos)
    #= none:79 =#
    #= none:80 =#
    (Hx, Hy, Hz) = halo_size(grid)
    #= none:81 =#
    (TX, TY, TZ) = (topo = topology(grid))
    #= none:83 =#
    locs = Dict("xC" => (c, c, c), "xF" => (f, c, c), "yC" => (c, c, c), "yF" => (c, f, c), "zC" => (c, c, c), "zF" => (c, c, f))
    #= none:90 =#
    topo = map(instantiate, topology(grid))
    #= none:92 =#
    indices = Dict((name => validate_indices(indices, locs[name], grid) for name = keys(locs)))
    #= none:94 =#
    if !with_halos
        #= none:95 =#
        indices = Dict((name => restrict_to_interior.(indices[name], locs[name], topo, size(grid)) for name = keys(locs)))
    end
    #= none:99 =#
    return native_dimensions_for_netcdf_output(grid, indices, TX, TY, TZ, Hx, Hy, Hz)
end
#= none:102 =#
const default_rectilinear_dimension_attributes = Dict("xC" => Dict("long_name" => "Locations of the cell centers in the x-direction.", "units" => "m"), "xF" => Dict("long_name" => "Locations of the cell faces in the x-direction.", "units" => "m"), "yC" => Dict("long_name" => "Locations of the cell centers in the y-direction.", "units" => "m"), "yF" => Dict("long_name" => "Locations of the cell faces in the y-direction.", "units" => "m"), "zC" => Dict("long_name" => "Locations of the cell centers in the z-direction.", "units" => "m"), "zF" => Dict("long_name" => "Locations of the cell faces in the z-direction.", "units" => "m"), "time" => Dict("long_name" => "Time", "units" => "s"), "particle_id" => Dict("long_name" => "Particle ID"))
#= none:113 =#
const default_curvilinear_dimension_attributes = Dict("xC" => Dict("long_name" => "Locations of the cell centers in the λ-direction.", "units" => "degrees"), "xF" => Dict("long_name" => "Locations of the cell faces in the λ-direction.", "units" => "degrees"), "yC" => Dict("long_name" => "Locations of the cell centers in the φ-direction.", "units" => "degrees"), "yF" => Dict("long_name" => "Locations of the cell faces in the φ-direction.", "units" => "degrees"), "zC" => Dict("long_name" => "Locations of the cell centers in the z-direction.", "units" => "m"), "zF" => Dict("long_name" => "Locations of the cell faces in the z-direction.", "units" => "m"), "time" => Dict("long_name" => "Time", "units" => "s"), "particle_id" => Dict("long_name" => "Particle ID"))
#= none:124 =#
const default_output_attributes = Dict("u" => Dict("long_name" => "Velocity in the x-direction", "units" => "m/s"), "v" => Dict("long_name" => "Velocity in the y-direction", "units" => "m/s"), "w" => Dict("long_name" => "Velocity in the z-direction", "units" => "m/s"), "b" => Dict("long_name" => "Buoyancy", "units" => "m/s²"), "T" => Dict("long_name" => "Conservative temperature", "units" => "°C"), "S" => Dict("long_name" => "Absolute salinity", "units" => "g/kg"))
#= none:133 =#
add_schedule_metadata!(attributes, schedule) = begin
        #= none:133 =#
        nothing
    end
#= none:135 =#
function add_schedule_metadata!(global_attributes, schedule::IterationInterval)
    #= none:135 =#
    #= none:136 =#
    global_attributes["schedule"] = "IterationInterval"
    #= none:137 =#
    global_attributes["interval"] = schedule.interval
    #= none:138 =#
    global_attributes["output iteration interval"] = "Output was saved every $(schedule.interval) iteration(s)."
    #= none:141 =#
    return nothing
end
#= none:144 =#
function add_schedule_metadata!(global_attributes, schedule::TimeInterval)
    #= none:144 =#
    #= none:145 =#
    global_attributes["schedule"] = "TimeInterval"
    #= none:146 =#
    global_attributes["interval"] = schedule.interval
    #= none:147 =#
    global_attributes["output time interval"] = "Output was saved every $(prettytime(schedule.interval))."
    #= none:150 =#
    return nothing
end
#= none:153 =#
function add_schedule_metadata!(global_attributes, schedule::WallTimeInterval)
    #= none:153 =#
    #= none:154 =#
    global_attributes["schedule"] = "WallTimeInterval"
    #= none:155 =#
    global_attributes["interval"] = schedule.interval
    #= none:156 =#
    global_attributes["output time interval"] = "Output was saved every $(prettytime(schedule.interval))."
    #= none:159 =#
    return nothing
end
#= none:162 =#
function add_schedule_metadata!(global_attributes, schedule::AveragedTimeInterval)
    #= none:162 =#
    #= none:163 =#
    add_schedule_metadata!(global_attributes, TimeInterval(schedule))
    #= none:165 =#
    global_attributes["time_averaging_window"] = schedule.window
    #= none:166 =#
    global_attributes["time averaging window"] = "Output was time averaged with a window size of $(prettytime(schedule.window))"
    #= none:169 =#
    global_attributes["time_averaging_stride"] = schedule.stride
    #= none:170 =#
    global_attributes["time averaging stride"] = "Output was time averaged with a stride of $(schedule.stride) iteration(s) within the time averaging window."
    #= none:173 =#
    return nothing
end
#= none:176 =#
#= none:176 =# Core.@doc "    NetCDFOutputWriter(model, outputs; filename, schedule,\n                       grid = model.grid,\n                       dir = \".\",\n                       array_type = Array{Float64},\n                       indices = nothing,\n                       with_halos = false,\n                       global_attributes = Dict(),\n                       output_attributes = Dict(),\n                       dimensions = Dict(),\n                       overwrite_existing = false,\n                       deflatelevel = 0,\n                       part = 1,\n                       file_splitting = NoFileSplitting(),\n                       verbose = false)\n\nConstruct a `NetCDFOutputWriter` that writes `(label, output)` pairs in `outputs` (which should\nbe a `Dict`) to a NetCDF file, where `label` is a string that labels the output and `output` is\neither a `Field` (e.g. `model.velocities.u`) or a function `f(model)` that\nreturns something to be written to disk.\n\nIf any of `outputs` are not `AbstractField`, their spatial `dimensions` must be provided.\n\nTo use `outputs` on a `grid` not equal to `model.grid`, provide the keyword argument `grid.`\n\nKeyword arguments\n=================\n\n- `grid`: The grid associated with `outputs`. Defaults to `model.grid`.\n\n## Filenaming\n\n- `filename` (required): Descriptive filename. `\".nc\"` is appended to `filename` if `filename` does\n                         not end in `\".nc\"`.\n\n- `dir`: Directory to save output to.\n\n## Output frequency and time-averaging\n\n- `schedule` (required): `AbstractSchedule` that determines when output is saved.\n\n## Slicing and type conversion prior to output\n\n- `indices`: Tuple of indices of the output variables to include. Default is `(:, :, :)`, which\n             includes the full fields.\n\n- `with_halos`: Boolean defining whether or not to include halos in the outputs. Default: `false`.\n                Note, that to postprocess saved output (e.g., compute derivatives, etc)\n                information about the boundary conditions is often crucial. In that case\n                you might need to set `with_halos = true`.\n\n- `array_type`: The array type to which output arrays are converted to prior to saving.\n                Default: `Array{Float64}`.\n\n- `dimensions`: A `Dict` of dimension tuples to apply to outputs (required for function outputs).\n\n## File management\n\n- `overwrite_existing`: If `false`, `NetCDFOutputWriter` will be set to append to `filepath`. If `true`,\n                        `NetCDFOutputWriter` will overwrite `filepath` if it exists or create it if not.\n                        Default: `false`. See [NCDatasets.jl documentation](https://alexander-barth.github.io/NCDatasets.jl/stable/)\n                        for more information about its `mode` option.\n\n- `deflatelevel`: Determines the NetCDF compression level of data (integer 0-9; 0 (default) means no compression\n                  and 9 means maximum compression). See [NCDatasets.jl documentation](https://alexander-barth.github.io/NCDatasets.jl/stable/variables/#Creating-a-variable)\n                  for more information.\n\n- `file_splitting`: Schedule for splitting the output file. The new files will be suffixed with\n          `_part1`, `_part2`, etc. For example `file_splitting = FileSizeLimit(sz)` will\n          split the output file when its size exceeds `sz`. Another example is\n          `file_splitting = TimeInterval(30days)`, which will split files every 30 days of\n          simulation time. The default incurs no splitting (`NoFileSplitting()`).\n\n## Miscellaneous keywords\n\n- `verbose`: Log what the output writer is doing with statistics on compute/write times and file sizes.\n             Default: `false`.\n\n- `part`: The starting part number used when file splitting.\n\n- `global_attributes`: Dict of model properties to save with every file. Default: `Dict()`.\n\n- `output_attributes`: Dict of attributes to be saved with each field variable (reasonable\n                       defaults are provided for velocities, buoyancy, temperature, and salinity;\n                       otherwise `output_attributes` *must* be user-provided).\n\nExamples\n========\n\nSaving the ``u`` velocity field and temperature fields, the full 3D fields and surface 2D slices\nto separate NetCDF files:\n\n```@example netcdf1\nusing Oceananigans\n\ngrid = RectilinearGrid(size=(16, 16, 16), extent=(1, 1, 1))\n\nmodel = NonhydrostaticModel(grid=grid, tracers=:c)\n\nsimulation = Simulation(model, Δt=12, stop_time=3600)\n\nfields = Dict(\"u\" => model.velocities.u, \"c\" => model.tracers.c)\n\nsimulation.output_writers[:field_writer] =\n    NetCDFOutputWriter(model, fields, filename=\"fields.nc\", schedule=TimeInterval(60))\n```\n\n```@example netcdf1\nsimulation.output_writers[:surface_slice_writer] =\n    NetCDFOutputWriter(model, fields, filename=\"surface_xy_slice.nc\",\n                       schedule=TimeInterval(60), indices=(:, :, grid.Nz))\n```\n\n```@example netcdf1\nsimulation.output_writers[:averaged_profile_writer] =\n    NetCDFOutputWriter(model, fields,\n                       filename = \"averaged_z_profile.nc\",\n                       schedule = AveragedTimeInterval(60, window=20),\n                       indices = (1, 1, :))\n```\n\n`NetCDFOutputWriter` also accepts output functions that write scalars and arrays to disk,\nprovided that their `dimensions` are provided:\n\n```@example\nusing Oceananigans\n\nNx, Ny, Nz = 16, 16, 16\n\ngrid = RectilinearGrid(size=(Nx, Ny, Nz), extent=(1, 2, 3))\n\nmodel = NonhydrostaticModel(; grid)\n\nsimulation = Simulation(model, Δt=1.25, stop_iteration=3)\n\nf(model) = model.clock.time^2 # scalar output\n\nzC = znodes(grid, Center())\ng(model) = model.clock.time .* exp.(zC) # vector/profile output\n\nxC, yF = xnodes(grid, Center()), ynodes(grid, Face())\nXC = [xC[i] for i in 1:Nx, j in 1:Ny]\nYF = [yF[j] for i in 1:Nx, j in 1:Ny]\nh(model) = @. model.clock.time * sin(XC) * cos(YF) # xy slice output\n\noutputs = Dict(\"scalar\" => f, \"profile\" => g, \"slice\" => h)\n\ndims = Dict(\"scalar\" => (), \"profile\" => (\"zC\",), \"slice\" => (\"xC\", \"yC\"))\n\noutput_attributes = Dict(\n    \"scalar\"  => Dict(\"long_name\" => \"Some scalar\", \"units\" => \"bananas\"),\n    \"profile\" => Dict(\"long_name\" => \"Some vertical profile\", \"units\" => \"watermelons\"),\n    \"slice\"   => Dict(\"long_name\" => \"Some slice\", \"units\" => \"mushrooms\")\n)\n\nglobal_attributes = Dict(\"location\" => \"Bay of Fundy\", \"onions\" => 7)\n\nsimulation.output_writers[:things] =\n    NetCDFOutputWriter(model, outputs,\n                       schedule=IterationInterval(1), filename=\"things.nc\", dimensions=dims, verbose=true,\n                       global_attributes=global_attributes, output_attributes=output_attributes)\n```\n\n`NetCDFOutputWriter` can also be configured for `outputs` that are interpolated or regridded\nto a different grid than `model.grid`. To use this functionality, include the keyword argument\n`grid = output_grid`.\n\n```@example\nusing Oceananigans\nusing Oceananigans.Fields: interpolate!\n\ngrid = RectilinearGrid(size=(1, 1, 8), extent=(1, 1, 1));\nmodel = NonhydrostaticModel(; grid)\n\ncoarse_grid = RectilinearGrid(size=(grid.Nx, grid.Ny, grid.Nz÷2), extent=(grid.Lx, grid.Ly, grid.Lz))\ncoarse_u = Field{Face, Center, Center}(coarse_grid)\n\ninterpolate_u(model) = interpolate!(coarse_u, model.velocities.u)\noutputs = (; u = interpolate_u)\n\noutput_writer = NetCDFOutputWriter(model, outputs;\n                                   grid = coarse_grid,\n                                   filename = \"coarse_u.nc\",\n                                   schedule = IterationInterval(1))\n```\n" function NetCDFOutputWriter(model, outputs; filename, schedule, grid = model.grid, dir = ".", array_type = Array{Float64}, indices = (:, :, :), with_halos = false, global_attributes = Dict(), output_attributes = Dict(), dimensions = Dict(), overwrite_existing = nothing, deflatelevel = 0, part = 1, file_splitting = NoFileSplitting(), verbose = false)
        #= none:362 =#
        #= none:378 =#
        mkpath(dir)
        #= none:379 =#
        filename = auto_extension(filename, ".nc")
        #= none:380 =#
        filepath = abspath(joinpath(dir, filename))
        #= none:382 =#
        initialize!(file_splitting, model)
        #= none:383 =#
        update_file_splitting_schedule!(file_splitting, filepath)
        #= none:385 =#
        if isnothing(overwrite_existing)
            #= none:386 =#
            if isfile(filepath)
                #= none:387 =#
                overwrite_existing = false
            else
                #= none:389 =#
                overwrite_existing = true
            end
        else
            #= none:392 =#
            if isfile(filepath) && !overwrite_existing
                #= none:393 =#
                #= none:393 =# @warn "$(filepath) already exists and `overwrite_existing = false`. Mode will be set to append to existing file. " * "You might experience errors when writing output if the existing file belonged to a different simulation!"
            elseif #= none:396 =# isfile(filepath) && overwrite_existing
                #= none:397 =#
                #= none:397 =# @warn "Overwriting existing $(filepath)."
            end
        end
        #= none:403 =#
        outputs = dictify(outputs)
        #= none:404 =#
        outputs = Dict((string(name) => construct_output(outputs[name], grid, indices, with_halos) for name = keys(outputs)))
        #= none:406 =#
        output_attributes = dictify(output_attributes)
        #= none:407 =#
        global_attributes = dictify(global_attributes)
        #= none:408 =#
        dimensions = dictify(dimensions)
        #= none:411 =#
        global_attributes = Dict{Any, Any}(global_attributes)
        #= none:413 =#
        (dataset, outputs, schedule) = initialize_nc_file!(filepath, outputs, schedule, array_type, indices, with_halos, global_attributes, output_attributes, dimensions, overwrite_existing, deflatelevel, grid, model)
        #= none:427 =#
        return NetCDFOutputWriter(grid, filepath, dataset, outputs, schedule, array_type, indices, with_halos, global_attributes, output_attributes, dimensions, overwrite_existing, deflatelevel, part, file_splitting, verbose)
    end
#= none:445 =#
get_default_dimension_attributes(::RectilinearGrid) = begin
        #= none:445 =#
        default_rectilinear_dimension_attributes
    end
#= none:448 =#
get_default_dimension_attributes(::AbstractCurvilinearGrid) = begin
        #= none:448 =#
        default_curvilinear_dimension_attributes
    end
#= none:451 =#
get_default_dimension_attributes(grid::ImmersedBoundaryGrid) = begin
        #= none:451 =#
        get_default_dimension_attributes(grid.underlying_grid)
    end
#= none:458 =#
materialize_output(func, model) = begin
        #= none:458 =#
        func(model)
    end
#= none:459 =#
materialize_output(field::AbstractField, model) = begin
        #= none:459 =#
        field
    end
#= none:460 =#
materialize_output(particles::LagrangianParticles, model) = begin
        #= none:460 =#
        particles
    end
#= none:461 =#
materialize_output(output::WindowedTimeAverage{<:AbstractField}, model) = begin
        #= none:461 =#
        output
    end
#= none:463 =#
#= none:463 =# Core.@doc " Defines empty variables for 'custom' user-supplied `output`. " function define_output_variable!(dataset, output, name, array_type, deflatelevel, attrib, dimensions, filepath)
        #= none:464 =#
        #= none:467 =#
        if name ∉ keys(dimensions)
            #= none:468 =#
            msg = string("dimensions[$(name)] for output $(name)=", typeof(output), " into ", filepath, '\n', " must be provided when constructing NetCDFOutputWriter")
            #= none:470 =#
            throw(ArgumentError(msg))
        end
        #= none:473 =#
        dims = dimensions[name]
        #= none:474 =#
        FT = eltype(array_type)
        #= none:475 =#
        defVar(dataset, name, FT, (dims..., "time"); deflatelevel, attrib)
        #= none:477 =#
        return nothing
    end
#= none:481 =#
#= none:481 =# Core.@doc " Defines empty field variable. " function define_output_variable!(dataset, output::AbstractField, name, array_type, deflatelevel, attrib, dimensions, filepath)
        #= none:482 =#
        #= none:485 =#
        dims = netcdf_spatial_dimensions(output)
        #= none:486 =#
        FT = eltype(array_type)
        #= none:487 =#
        defVar(dataset, name, FT, (dims..., "time"); deflatelevel, attrib)
        #= none:489 =#
        return nothing
    end
#= none:492 =#
#= none:492 =# Core.@doc " Defines empty field variable for `WindowedTimeAverage`s over fields. " define_output_variable!(dataset, output::WindowedTimeAverage{<:AbstractField}, args...) = begin
            #= none:493 =#
            define_output_variable!(dataset, output.operand, args...)
        end
#= none:500 =#
Base.open(nc::NetCDFOutputWriter) = begin
        #= none:500 =#
        NCDataset(nc.filepath, "a")
    end
#= none:501 =#
Base.close(nc::NetCDFOutputWriter) = begin
        #= none:501 =#
        close(nc.dataset)
    end
#= none:503 =#
function save_output!(ds, output, model, ow, time_index, name)
    #= none:503 =#
    #= none:504 =#
    data = fetch_and_convert_output(output, model, ow)
    #= none:505 =#
    data = drop_output_dims(output, data)
    #= none:506 =#
    colons = Tuple((Colon() for _ = 1:ndims(data)))
    #= none:507 =#
    (ds[name])[colons..., time_index:time_index] = data
    #= none:508 =#
    return nothing
end
#= none:511 =#
function save_output!(ds, output::LagrangianParticles, model, ow, time_index, name)
    #= none:511 =#
    #= none:512 =#
    data = fetch_and_convert_output(output, model, ow)
    #= none:513 =#
    for (particle_field, vals) = pairs(data)
        #= none:514 =#
        (ds[string(particle_field)])[:, time_index] = vals
        #= none:515 =#
    end
    #= none:517 =#
    return nothing
end
#= none:520 =#
#= none:520 =# Core.@doc "    write_output!(output_writer, model)\n\nWrite output to netcdf file `output_writer.filepath` at specified intervals. Increments the `time` dimension\nevery time an output is written to the file.\n" function write_output!(ow::NetCDFOutputWriter, model)
        #= none:526 =#
        #= none:528 =#
        ow.file_splitting(model) && start_next_file(model, ow)
        #= none:529 =#
        update_file_splitting_schedule!(ow.file_splitting, ow.filepath)
        #= none:531 =#
        ow.dataset = open(ow)
        #= none:533 =#
        (ds, verbose, filepath) = (ow.dataset, ow.verbose, ow.filepath)
        #= none:535 =#
        time_index = length(ds["time"]) + 1
        #= none:536 =#
        (ds["time"])[time_index] = float_or_date_time(model.clock.time)
        #= none:538 =#
        if verbose
            #= none:539 =#
            #= none:539 =# @info "Writing to NetCDF: $(filepath)..."
            #= none:540 =#
            #= none:540 =# @info "Computing NetCDF outputs for time index $(time_index): $(keys(ow.outputs))..."
            #= none:543 =#
            (t0, sz0) = (time_ns(), filesize(filepath))
        end
        #= none:546 =#
        for (name, output) = ow.outputs
            #= none:548 =#
            verbose && (t0′ = time_ns())
            #= none:550 =#
            save_output!(ds, output, model, ow, time_index, name)
            #= none:552 =#
            if verbose
                #= none:554 =#
                t1′ = time_ns()
                #= none:555 =#
                #= none:555 =# @info "Computing $(name) done: time=$(prettytime((t1′ - t0′) / 1.0e9))"
            end
            #= none:557 =#
        end
        #= none:559 =#
        if verbose
            #= none:561 =#
            (t1, sz1) = (time_ns(), filesize(filepath))
            #= none:562 =#
            verbose && #= none:562 =# @info(begin
                        #= none:563 =#
                        #= none:563 =# @sprintf "Writing done: time=%s, size=%s, Δsize=%s" prettytime((t1 - t0) / 1.0e9) pretty_filesize(sz1) pretty_filesize(sz1 - sz0)
                    end)
        end
        #= none:568 =#
        sync(ds)
        #= none:569 =#
        close(ow)
        #= none:571 =#
        return nothing
    end
#= none:574 =#
drop_output_dims(output, data) = begin
        #= none:574 =#
        data
    end
#= none:575 =#
drop_output_dims(output::Field, data) = begin
        #= none:575 =#
        dropdims(data, dims = reduced_dimensions(output))
    end
#= none:576 =#
drop_output_dims(output::WindowedTimeAverage{<:Field}, data) = begin
        #= none:576 =#
        dropdims(data, dims = reduced_dimensions(output.operand))
    end
#= none:582 =#
Base.summary(ow::NetCDFOutputWriter) = begin
        #= none:582 =#
        string("NetCDFOutputWriter writing ", prettykeys(ow.outputs), " to ", ow.filepath, " on ", summary(ow.schedule))
    end
#= none:585 =#
function Base.show(io::IO, ow::NetCDFOutputWriter)
    #= none:585 =#
    #= none:586 =#
    dims = NCDataset(ow.filepath, "r") do ds
            #= none:587 =#
            (join([dim * "(" * string(length(ds[dim])) * "), " for dim = keys(ds.dim)]))[1:end - 2]
        end
    #= none:591 =#
    averaging_schedule = output_averaging_schedule(ow)
    #= none:592 =#
    Noutputs = length(ow.outputs)
    #= none:594 =#
    print(io, "NetCDFOutputWriter scheduled on $(summary(ow.schedule)):", "\n", "├── filepath: ", relpath(ow.filepath), "\n", "├── dimensions: $(dims)", "\n", "├── $(Noutputs) outputs: ", prettykeys(ow.outputs), show_averaging_schedule(averaging_schedule), "\n", "└── array type: ", show_array_type(ow.array_type), "\n", "├── file_splitting: ", summary(ow.file_splitting), "\n", "└── file size: ", pretty_filesize(filesize(ow.filepath)))
end
#= none:607 =#
#= none:607 =# Core.@doc " Defines empty variable for particle trackting. " function define_output_variable!(dataset, output::LagrangianParticles, name, array_type, deflatelevel, output_attributes, dimensions, filepath)
        #= none:608 =#
        #= none:611 =#
        particle_fields = (eltype(output.properties) |> fieldnames) .|> string
        #= none:612 =#
        T = eltype(array_type)
        #= none:614 =#
        for particle_field = particle_fields
            #= none:615 =#
            defVar(dataset, particle_field, T, ("particle_id", "time"); deflatelevel)
            #= none:616 =#
        end
        #= none:618 =#
        return nothing
    end
#= none:621 =#
dictify(outputs::LagrangianParticles) = begin
        #= none:621 =#
        Dict("particles" => outputs)
    end
#= none:623 =#
default_dimensions(outputs::Dict{String, <:LagrangianParticles}, grid, indices, with_halos) = begin
        #= none:623 =#
        Dict("particle_id" => collect(1:length(outputs["particles"])))
    end
#= none:630 =#
function start_next_file(model, ow::NetCDFOutputWriter)
    #= none:630 =#
    #= none:631 =#
    verbose = ow.verbose
    #= none:633 =#
    verbose && #= none:633 =# @info(begin
                #= none:634 =#
                schedule_type = summary(ow.file_splitting)
                #= none:635 =#
                "Splitting output because $(schedule_type) is activated."
            end)
    #= none:638 =#
    if ow.part == 1
        #= none:639 =#
        part1_path = replace(ow.filepath, r".nc$" => "_part1.nc")
        #= none:640 =#
        verbose && #= none:640 =# @info("Renaming first part: $(ow.filepath) -> $(part1_path)")
        #= none:641 =#
        mv(ow.filepath, part1_path, force = ow.overwrite_existing)
        #= none:642 =#
        ow.filepath = part1_path
    end
    #= none:645 =#
    ow.part += 1
    #= none:646 =#
    ow.filepath = replace(ow.filepath, r"part\d+.nc$" => "part" * string(ow.part) * ".nc")
    #= none:647 =#
    ow.overwrite_existing && (isfile(ow.filepath) && rm(ow.filepath, force = true))
    #= none:648 =#
    verbose && #= none:648 =# @info("Now writing to: $(ow.filepath)")
    #= none:650 =#
    initialize_nc_file!(ow, model)
    #= none:652 =#
    return nothing
end
#= none:655 =#
function initialize_nc_file!(filepath, outputs, schedule, array_type, indices, with_halos, global_attributes, output_attributes, dimensions, overwrite_existing, deflatelevel, grid, model)
    #= none:655 =#
    #= none:669 =#
    mode = if overwrite_existing
            "c"
        else
            "a"
        end
    #= none:672 =#
    global_attributes["date"] = "This file was generated on $(now())."
    #= none:673 =#
    global_attributes["Julia"] = "This file was generated using " * versioninfo_with_gpu()
    #= none:674 =#
    global_attributes["Oceananigans"] = "This file was generated using " * oceananigans_versioninfo()
    #= none:676 =#
    add_schedule_metadata!(global_attributes, schedule)
    #= none:680 =#
    (schedule, outputs) = time_average_outputs(schedule, outputs, model)
    #= none:682 =#
    dims = default_dimensions(outputs, grid, indices, with_halos)
    #= none:685 =#
    dataset = NCDataset(filepath, mode, attrib = global_attributes)
    #= none:687 =#
    default_dimension_attributes = get_default_dimension_attributes(grid)
    #= none:690 =#
    if mode == "c"
        #= none:691 =#
        for (dim_name, dim_array) = dims
            #= none:692 =#
            defVar(dataset, dim_name, array_type(dim_array), (dim_name,), deflatelevel = deflatelevel, attrib = default_dimension_attributes[dim_name])
            #= none:694 =#
        end
        #= none:697 =#
        time_attrib = if model.clock.time isa AbstractTime
                Dict("long_name" => "Time", "units" => "seconds since 2000-01-01 00:00:00")
            else
                Dict("long_name" => "Time", "units" => "seconds")
            end
        #= none:702 =#
        defDim(dataset, "time", Inf)
        #= none:703 =#
        defVar(dataset, "time", eltype(grid), ("time",), attrib = time_attrib)
        #= none:707 =#
        for c = keys(outputs)
            #= none:708 =#
            if !(haskey(output_attributes, c))
                #= none:709 =#
                output_attributes[c] = if c in keys(default_output_attributes)
                        default_output_attributes[c]
                    else
                        ()
                    end
            end
            #= none:711 =#
        end
        #= none:713 =#
        for (name, output) = outputs
            #= none:714 =#
            attributes = try
                    #= none:714 =#
                    output_attributes[name]
                catch
                    #= none:714 =#
                    Dict()
                end
            #= none:715 =#
            materialized = materialize_output(output, model)
            #= none:716 =#
            define_output_variable!(dataset, materialized, name, array_type, deflatelevel, attributes, dimensions, filepath)
            #= none:724 =#
        end
        #= none:726 =#
        sync(dataset)
    end
    #= none:729 =#
    close(dataset)
    #= none:731 =#
    return (dataset, outputs, schedule)
end
#= none:734 =#
initialize_nc_file!(ow::NetCDFOutputWriter, model) = begin
        #= none:734 =#
        initialize_nc_file!(ow.filepath, ow.outputs, ow.schedule, ow.array_type, ow.indices, ow.with_halos, ow.global_attributes, ow.output_attributes, ow.dimensions, ow.overwrite_existing, ow.deflatelevel, ow.grid, model)
    end