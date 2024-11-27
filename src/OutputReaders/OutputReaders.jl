
#= none:1 =#
module OutputReaders
#= none:1 =#
#= none:3 =#
export FieldDataset
#= none:4 =#
export FieldTimeSeries
#= none:5 =#
export InMemory, OnDisk
#= none:6 =#
export Cyclical, Linear, Clamp
#= none:8 =#
include("field_time_series.jl")
#= none:9 =#
include("field_time_series_indexing.jl")
#= none:10 =#
include("set_field_time_series.jl")
#= none:11 =#
include("field_time_series_reductions.jl")
#= none:12 =#
include("show_field_time_series.jl")
#= none:13 =#
include("extract_field_time_series.jl")
#= none:16 =#
include("field_dataset.jl")
end