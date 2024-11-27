
#= none:1 =#
struct FieldDataset{F, M, P, KW}
    #= none:2 =#
    fields::F
    #= none:3 =#
    metadata::M
    #= none:4 =#
    filepath::P
    #= none:5 =#
    reader_kw::KW
end
#= none:8 =#
#= none:8 =# Core.@doc "    FieldDataset(filepath;\n                 architecture=CPU(), grid=nothing, backend=InMemory(), metadata_paths=[\"metadata\"])\n\nReturns a `Dict` containing a `FieldTimeSeries` for each field in the JLD2 file located\nat `filepath`. Note that model output **must** have been saved with halos.\n\nKeyword arguments\n=================\n- `backend`: Either `InMemory()` (default) or `OnDisk()`. The `InMemory` backend will\nload the data fully in memory as a 4D multi-dimensional array while the `OnDisk()`\nbackend will lazily load field time snapshots when the `FieldTimeSeries` is indexed\nlinearly.\n\n- `metadata_paths`: A list of JLD2 paths to look for metadata. By default it looks in\n  `file[\"metadata\"]`.\n\n- `grid`: May be specified to override the grid used in the JLD2 file.\n\n- `reader_kw`: A dictionary of keyword arguments to pass to the reader (currently only JLD2)\n               to be used when opening files.\n" function FieldDataset(filepath; architecture = CPU(), grid = nothing, backend = InMemory(), metadata_paths = ["metadata"], reader_kw = Dict{Symbol, Any}())
        #= none:30 =#
        #= none:37 =#
        file = jldopen(filepath; reader_kw...)
        #= none:39 =#
        field_names = keys(file["timeseries"])
        #= none:40 =#
        filter!((k->begin
                    #= none:40 =#
                    k != "t"
                end), field_names)
        #= none:42 =#
        ds = Dict{String, FieldTimeSeries}((name => FieldTimeSeries(filepath, name; architecture, backend, grid, reader_kw) for name = field_names))
        #= none:47 =#
        metadata = Dict((k => file["$(mp)/$(k)"] for mp = metadata_paths if haskey(file, mp) for k = keys(file["$(mp)"])))
        #= none:53 =#
        close(file)
        #= none:55 =#
        return FieldDataset(ds, metadata, abspath(filepath), reader_kw)
    end
#= none:58 =#
Base.getindex(fds::FieldDataset, inds...) = begin
        #= none:58 =#
        Base.getindex(fds.fields, inds...)
    end
#= none:59 =#
Base.getindex(fds::FieldDataset, i::Symbol) = begin
        #= none:59 =#
        Base.getindex(fds, string(i))
    end
#= none:61 =#
function Base.getproperty(fds::FieldDataset, name::Symbol)
    #= none:61 =#
    #= none:62 =#
    if name in propertynames(fds)
        #= none:63 =#
        return getfield(fds, name)
    else
        #= none:65 =#
        return getindex(fds, name)
    end
end
#= none:69 =#
function Base.show(io::IO, fds::FieldDataset)
    #= none:69 =#
    #= none:70 =#
    s = "FieldDataset with $(length(fds.fields)) fields and $(length(fds.metadata)) metadata entries:\n"
    #= none:72 =#
    n_fields = length(fds.fields)
    #= none:74 =#
    for (i, (name, fts)) = enumerate(pairs(fds.fields))
        #= none:75 =#
        prefix = if i == n_fields
                "└── "
            else
                "├── "
            end
        #= none:76 =#
        s *= prefix * "$(name): " * summary(fts) * '\n'
        #= none:77 =#
    end
    #= none:79 =#
    return print(io, s)
end