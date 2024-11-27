
#= none:1 =#
module OutputWriters
#= none:1 =#
#= none:3 =#
export JLD2OutputWriter, NetCDFOutputWriter, written_names, Checkpointer, WindowedTimeAverage, FileSizeLimit, TimeInterval, IterationInterval, WallTimeInterval, AveragedTimeInterval
#= none:8 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:10 =#
using Oceananigans.Architectures
#= none:11 =#
using Oceananigans.Grids
#= none:12 =#
using Oceananigans.Fields
#= none:13 =#
using Oceananigans.Models
#= none:15 =#
using Oceananigans: AbstractOutputWriter
#= none:16 =#
using Oceananigans.Grids: interior_indices
#= none:17 =#
using Oceananigans.Utils: TimeInterval, IterationInterval, WallTimeInterval, instantiate
#= none:18 =#
using Oceananigans.Utils: pretty_filesize
#= none:20 =#
using OffsetArrays
#= none:22 =#
import Oceananigans: write_output!, initialize!
#= none:24 =#
const c = Center()
#= none:25 =#
const f = Face()
#= none:27 =#
Base.open(ow::AbstractOutputWriter) = begin
        #= none:27 =#
        nothing
    end
#= none:28 =#
Base.close(ow::AbstractOutputWriter) = begin
        #= none:28 =#
        nothing
    end
#= none:30 =#
include("output_writer_utils.jl")
#= none:31 =#
include("fetch_output.jl")
#= none:32 =#
include("windowed_time_average.jl")
#= none:33 =#
include("output_construction.jl")
#= none:34 =#
include("jld2_output_writer.jl")
#= none:35 =#
include("netcdf_output_writer.jl")
#= none:36 =#
include("checkpointer.jl")
#= none:38 =#
function written_names(filename)
    #= none:38 =#
    #= none:39 =#
    field_names = String[]
    #= none:40 =#
    jldopen(filename, "r") do file
        #= none:41 =#
        all_names = keys(file["timeseries"])
        #= none:42 =#
        field_names = filter((n->begin
                        #= none:42 =#
                        n != "t"
                    end), all_names)
    end
    #= none:44 =#
    return field_names
end
end