
#= none:1 =#
module Utils
#= none:1 =#
#= none:3 =#
export configure_kernel, launch!, KernelParameters
#= none:4 =#
export prettytime, pretty_filesize
#= none:5 =#
export tupleit, parenttuple, datatuple, datatuples
#= none:6 =#
export validate_intervals, time_to_run
#= none:7 =#
export ordered_dict_show
#= none:8 =#
export instantiate
#= none:9 =#
export with_tracers
#= none:10 =#
export versioninfo_with_gpu, oceananigans_versioninfo
#= none:11 =#
export TimeInterval, IterationInterval, WallTimeInterval, SpecifiedTimes, AndSchedule, OrSchedule
#= none:12 =#
export apply_regionally!, construct_regionally, @apply_regionally, @regional, MultiRegionObject
#= none:13 =#
export isregional, getregion, _getregion, getdevice, switch_device!, sync_device!, sync_all_devices!
#= none:15 =#
import CUDA
#= none:21 =#
instantiate(T::Type) = begin
        #= none:21 =#
        T()
    end
#= none:22 =#
instantiate(t) = begin
        #= none:22 =#
        t
    end
#= none:24 =#
getnamewrapper(type) = begin
        #= none:24 =#
        (typeof(type)).name.wrapper
    end
#= none:30 =#
include("prettysummary.jl")
#= none:31 =#
include("kernel_launching.jl")
#= none:32 =#
include("prettytime.jl")
#= none:33 =#
include("pretty_filesize.jl")
#= none:34 =#
include("tuple_utils.jl")
#= none:35 =#
include("output_writer_diagnostic_utils.jl")
#= none:36 =#
include("ordered_dict_show.jl")
#= none:37 =#
include("with_tracers.jl")
#= none:38 =#
include("versioninfo.jl")
#= none:39 =#
include("schedules.jl")
#= none:40 =#
include("user_function_arguments.jl")
#= none:41 =#
include("multi_region_transformation.jl")
#= none:42 =#
include("coordinate_transformations.jl")
#= none:43 =#
include("sum_of_arrays.jl")
end