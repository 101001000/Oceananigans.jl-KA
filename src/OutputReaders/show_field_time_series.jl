
#= none:1 =#
using Oceananigans.Fields: show_location, data_summary
#= none:2 =#
using Oceananigans.Utils: prettysummary
#= none:8 =#
Base.summary(::Clamp) = begin
        #= none:8 =#
        "Clamp()"
    end
#= none:9 =#
Base.summary(::Linear) = begin
        #= none:9 =#
        "Linear()"
    end
#= none:10 =#
Base.summary(ti::Cyclical) = begin
        #= none:10 =#
        string("Cyclical(period=", prettysummary(ti.period), ")")
    end
#= none:12 =#
function Base.summary(fts::FieldTimeSeries{LX, LY, LZ, K}) where {LX, LY, LZ, K}
    #= none:12 =#
    #= none:13 =#
    arch = architecture(fts)
    #= none:14 =#
    B = string((typeof(fts.backend)).name.wrapper)
    #= none:15 =#
    sz_str = string(join(size(fts), "×"))
    #= none:17 =#
    path = fts.path
    #= none:18 =#
    name = fts.name
    #= none:19 =#
    A = typeof(arch)
    #= none:21 =#
    if isnothing(path)
        #= none:22 =#
        suffix = " on $(A)"
    else
        #= none:24 =#
        suffix = " of $(name) at $(path)"
    end
    #= none:27 =#
    return string("$(sz_str) FieldTimeSeries{$(B)} located at ", show_location(fts), suffix)
end
#= none:30 =#
function Base.show(io::IO, fts::FieldTimeSeries{LX, LY, LZ, E}) where {LX, LY, LZ, E}
    #= none:30 =#
    #= none:32 =#
    extrapolation_str = string("├── time boundaries: $(E)")
    #= none:34 =#
    prefix = string(summary(fts), '\n', "├── grid: ", summary(fts.grid), '\n', "├── indices: ", indices_summary(fts), '\n', "├── time_indexing: ", summary(fts.time_indexing), '\n')
    #= none:39 =#
    suffix = field_time_series_suffix(fts)
    #= none:41 =#
    return print(io, prefix, suffix)
end
#= none:44 =#
function field_time_series_suffix(fts::InMemoryFTS)
    #= none:44 =#
    #= none:45 =#
    backend = fts.backend
    #= none:46 =#
    backend_str = string("├── backend: ", summary(backend))
    #= none:47 =#
    path_str = if isnothing(fts.path)
            ""
        else
            string("├── path: ", fts.path, '\n')
        end
    #= none:48 =#
    name_str = if isnothing(fts.name)
            ""
        else
            string("├── name: ", fts.name, '\n')
        end
    #= none:50 =#
    return string(backend_str, '\n', path_str, name_str, "└── data: ", summary(fts.data), '\n', "    └── ", data_summary(parent(fts)))
end
#= none:57 =#
field_time_series_suffix(fts::OnDiskFTS) = begin
        #= none:57 =#
        string("├── backend: ", summary(fts.backend), '\n', "├── path: ", fts.path, '\n', "└── name: ", fts.name)
    end