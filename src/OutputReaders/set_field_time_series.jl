
#= none:1 =#
using Printf
#= none:2 =#
using Oceananigans.Architectures: cpu_architecture
#= none:8 =#
iterations_from_file(file) = begin
        #= none:8 =#
        parse.(Int, keys(file["timeseries/t"]))
    end
#= none:10 =#
find_time_index(time::Number, file_times) = begin
        #= none:10 =#
        findfirst((t->begin
                    #= none:10 =#
                    t ≈ time
                end), file_times)
    end
#= none:11 =#
find_time_index(time::AbstractTime, file_times) = begin
        #= none:11 =#
        findfirst((t->begin
                    #= none:11 =#
                    t == time
                end), file_times)
    end
#= none:13 =#
function set!(fts::InMemoryFTS, path::String = fts.path, name::String = fts.name)
    #= none:13 =#
    #= none:14 =#
    file = jldopen(path; fts.reader_kw...)
    #= none:15 =#
    file_iterations = iterations_from_file(file)
    #= none:16 =#
    file_times = [file["timeseries/t/$(i)"] for i = file_iterations]
    #= none:17 =#
    close(file)
    #= none:19 =#
    arch = architecture(fts)
    #= none:24 =#
    for n = time_indices(fts)
        #= none:25 =#
        t = fts.times[n]
        #= none:26 =#
        file_index = find_time_index(t, file_times)
        #= none:28 =#
        if isnothing(file_index)
            #= none:29 =#
            msg = string("Error setting ", summary(fts), '\n')
            #= none:30 =#
            msg *= #= none:30 =# @sprintf("Can't find data for time %.1e and time index %d\n", t, n)
            #= none:31 =#
            msg *= #= none:31 =# @sprintf("for field %s at path %s", path, name)
            #= none:32 =#
            error(msg)
        end
        #= none:35 =#
        file_iter = file_iterations[file_index]
        #= none:38 =#
        field_n = Field(location(fts), path, name, file_iter, architecture = cpu_architecture(arch), indices = fts.indices, boundary_conditions = fts.boundary_conditions)
        #= none:44 =#
        set!(fts[n], field_n)
        #= none:45 =#
    end
    #= none:47 =#
    return nothing
end
#= none:50 =#
set!(fts::InMemoryFTS, value, n::Int) = begin
        #= none:50 =#
        set!(fts[n], value)
    end
#= none:52 =#
function set!(fts::InMemoryFTS, fields_vector::AbstractVector{<:AbstractField})
    #= none:52 =#
    #= none:53 =#
    raw_data = parent(fts)
    #= none:54 =#
    file = jldopen(path; fts.reader_kw...)
    #= none:56 =#
    for (n, field) = enumerate(fields_vector)
        #= none:57 =#
        nth_raw_data = view(raw_data, :, :, :, n)
        #= none:58 =#
        copyto!(nth_raw_data, parent(field))
        #= none:60 =#
    end
    #= none:62 =#
    close(file)
    #= none:64 =#
    return nothing
end
#= none:68 =#
function maybe_write_property!(file, property, data)
    #= none:68 =#
    #= none:69 =#
    try
        #= none:70 =#
        test = file[property]
    catch
        #= none:72 =#
        file[property] = data
    end
end
#= none:76 =#
#= none:76 =# Core.@doc "    set!(fts::OnDiskFieldTimeSeries, field::Field, n::Int, time=fts.times[time_index])\n\nWrite the data in `parent(field)` to the file at `fts.path`,\nunder `fts.name` and at `time_index`. The save field is assigned `time`,\nwhich is extracted from `fts.times[time_index]` if not provided.\n" function set!(fts::OnDiskFTS, field::Field, n::Int, time = fts.times[n])
        #= none:83 =#
        #= none:84 =#
        fts.grid == field.grid || error("The grids attached to the Field and FieldTimeSeries appear to be different.")
        #= none:86 =#
        path = fts.path
        #= none:87 =#
        name = fts.name
        #= none:88 =#
        jldopen(path, "a+") do file
            #= none:89 =#
            initialize_file!(file, name, fts)
            #= none:90 =#
            maybe_write_property!(file, "timeseries/t/$(n)", time)
            #= none:91 =#
            maybe_write_property!(file, "timeseries/$(name)/$(n)", Array(parent(field)))
        end
    end
#= none:95 =#
function initialize_file!(file, name, fts)
    #= none:95 =#
    #= none:96 =#
    maybe_write_property!(file, "serialized/grid", fts.grid)
    #= none:97 =#
    maybe_write_property!(file, "timeseries/$(name)/serialized/location", location(fts))
    #= none:98 =#
    maybe_write_property!(file, "timeseries/$(name)/serialized/indices", indices(fts))
    #= none:99 =#
    maybe_write_property!(file, "timeseries/$(name)/serialized/boundary_conditions", boundary_conditions(fts))
    #= none:100 =#
    return nothing
end
#= none:103 =#
set!(fts::OnDiskFTS, path::String, name::String) = begin
        #= none:103 =#
        nothing
    end