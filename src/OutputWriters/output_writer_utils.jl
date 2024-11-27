
#= none:1 =#
using StructArrays: StructArray, replace_storage
#= none:2 =#
using Oceananigans.Grids: on_architecture, architecture
#= none:3 =#
using Oceananigans.DistributedComputations
#= none:4 =#
using Oceananigans.DistributedComputations: DistributedGrid, Partition
#= none:5 =#
using Oceananigans.Fields: AbstractField, indices, boundary_conditions, instantiated_location
#= none:6 =#
using Oceananigans.BoundaryConditions: bc_str, FieldBoundaryConditions, ContinuousBoundaryFunction, DiscreteBoundaryFunction
#= none:7 =#
using Oceananigans.TimeSteppers: QuasiAdamsBashforth2TimeStepper, RungeKutta3TimeStepper
#= none:8 =#
using Oceananigans.Models.LagrangianParticleTracking: LagrangianParticles
#= none:9 =#
using Oceananigans.Utils: AbstractSchedule
#= none:15 =#
struct NoFileSplitting
    #= none:15 =#
end
#= none:16 =#
(::NoFileSplitting)(model) = begin
        #= none:16 =#
        false
    end
#= none:17 =#
Base.summary(::NoFileSplitting) = begin
        #= none:17 =#
        "NoFileSplitting"
    end
#= none:18 =#
Base.show(io::IO, nfs::NoFileSplitting) = begin
        #= none:18 =#
        print(io, summary(nfs))
    end
#= none:19 =#
initialize!(::NoFileSplitting, model) = begin
        #= none:19 =#
        nothing
    end
#= none:21 =#
mutable struct FileSizeLimit <: AbstractSchedule
    #= none:22 =#
    size_limit::Float64
    #= none:23 =#
    path::String
end
#= none:26 =#
#= none:26 =# Core.@doc "    FileSizeLimit(size_limit [, path=\"\"])\n\nReturn a schedule that actuates when the file at `path` exceeds\nthe `size_limit`.\n\nThe `path` is automatically added and updated when `FileSizeLimit` is\nused with an output writer, and should not be provided manually.\n" FileSizeLimit(size_limit) = begin
            #= none:35 =#
            FileSizeLimit(size_limit, "")
        end
#= none:36 =#
(fsl::FileSizeLimit)(model) = begin
        #= none:36 =#
        filesize(fsl.path) ≥ fsl.size_limit
    end
#= none:38 =#
function Base.summary(fsl::FileSizeLimit)
    #= none:38 =#
    #= none:39 =#
    current_size_str = pretty_filesize(filesize(fsl.path))
    #= none:40 =#
    size_limit_str = pretty_filesize(fsl.size_limit)
    #= none:41 =#
    return string("FileSizeLimit(size_limit=", size_limit_str, ", path=", fsl.path, " (", current_size_str, ")")
end
#= none:45 =#
Base.show(io::IO, fsl::FileSizeLimit) = begin
        #= none:45 =#
        print(io, summary(fsl))
    end
#= none:48 =#
update_file_splitting_schedule!(schedule, filepath) = begin
        #= none:48 =#
        nothing
    end
#= none:50 =#
function update_file_splitting_schedule!(schedule::FileSizeLimit, filepath)
    #= none:50 =#
    #= none:51 =#
    schedule.path = filepath
    #= none:52 =#
    return nothing
end
#= none:55 =#
#= none:55 =# Core.@doc "    ext(ow)\n\nReturn the file extension for the output writer or output\nwriter type `ow`.\n" ext(ow::Type{AbstractOutputWriter}) = begin
            #= none:61 =#
            throw("Extension for $(ow) is not implemented.")
        end
#= none:62 =#
ext(ow::AbstractOutputWriter) = begin
        #= none:62 =#
        ext(typeof(fw))
    end
#= none:66 =#
#= none:66 =# Core.@doc "    saveproperty!(file, address, obj)\n\nSave data in `obj` to `file[address]` in a \"languate-agnostic\" way,\nthus primarily consisting of arrays and numbers, absent Julia-specific types\nor other data that can _only_ be interpreted by Julia.\n" saveproperty!(file, address, obj) = begin
            #= none:73 =#
            _saveproperty!(file, address, obj)
        end
#= none:76 =#
_saveproperty!(file, address, obj) = begin
        #= none:76 =#
        [saveproperty!(file, address * "/$(prop)", getproperty(obj, prop)) for prop = propertynames(obj)]
    end
#= none:79 =#
saveproperty!(file, address, p::Union{Number, Array}) = begin
        #= none:79 =#
        file[address] = p
    end
#= none:80 =#
saveproperty!(file, address, p::AbstractRange) = begin
        #= none:80 =#
        file[address] = collect(p)
    end
#= none:81 =#
saveproperty!(file, address, p::AbstractArray) = begin
        #= none:81 =#
        file[address] = Array(parent(p))
    end
#= none:82 =#
saveproperty!(file, address, p::Function) = begin
        #= none:82 =#
        nothing
    end
#= none:83 =#
saveproperty!(file, address, p::Tuple) = begin
        #= none:83 =#
        [saveproperty!(file, address * "/$(i)", p[i]) for i = 1:length(p)]
    end
#= none:84 =#
saveproperty!(file, address, grid::AbstractGrid) = begin
        #= none:84 =#
        _saveproperty!(file, address, on_architecture(CPU(), grid))
    end
#= none:86 =#
function saveproperty!(file, address, grid::DistributedGrid)
    #= none:86 =#
    #= none:87 =#
    arch = architecture(grid)
    #= none:88 =#
    cpu_arch = Distributed(CPU(); partition = Partition(arch.ranks...))
    #= none:89 =#
    _saveproperty!(file, address, on_architecture(cpu_arch, grid))
end
#= none:93 =#
function saveproperty!(file, address, bcs::FieldBoundaryConditions)
    #= none:93 =#
    #= none:94 =#
    for boundary = propertynames(bcs)
        #= none:95 =#
        bc = getproperty(bcs, endpoint)
        #= none:96 =#
        file[address * "/$(endpoint)/type"] = bc_str(bc)
        #= none:98 =#
        if bc.condition isa Function || bc.condition isa ContinuousBoundaryFunction
            #= none:99 =#
            file[address * "/$(boundary)/condition"] = missing
        else
            #= none:101 =#
            file[address * "/$(boundary)/condition"] = on_architecture(CPU(), bc.condition)
        end
        #= none:103 =#
    end
end
#= none:106 =#
#= none:106 =# Core.@doc "    serializeproperty!(file, address, obj)\n\nSerialize `obj` to `file[address]` in a \"friendly\" way; i.e. converting\n`CuArray` to `Array` so data can be loaded on any architecture,\nand not attempting to serialize objects that generally aren't\ndeserializable, like `Function`.\n" serializeproperty!(file, address, p) = begin
            #= none:114 =#
            file[address] = p
        end
#= none:115 =#
serializeproperty!(file, address, p::AbstractArray) = begin
        #= none:115 =#
        saveproperty!(file, address, p)
    end
#= none:117 =#
const CantSerializeThis = Union{Function, ContinuousBoundaryFunction, DiscreteBoundaryFunction}
#= none:121 =#
serializeproperty!(file, address, p::CantSerializeThis) = begin
        #= none:121 =#
        nothing
    end
#= none:125 =#
serializeproperty!(file, address, grid::AbstractGrid) = begin
        #= none:125 =#
        file[address] = on_architecture(CPU(), grid)
    end
#= none:127 =#
function serializeproperty!(file, address, grid::DistributedGrid)
    #= none:127 =#
    #= none:128 =#
    arch = architecture(grid)
    #= none:129 =#
    cpu_arch = Distributed(CPU(); partition = arch.partition)
    #= none:130 =#
    file[address] = on_architecture(cpu_arch, grid)
end
#= none:133 =#
function serializeproperty!(file, address, fbcs::FieldBoundaryConditions)
    #= none:133 =#
    #= none:136 =#
    if has_reference(Function, fbcs)
        #= none:137 =#
        file[address] = missing
    else
        #= none:139 =#
        file[address] = on_architecture(CPU(), fbcs)
    end
end
#= none:143 =#
function serializeproperty!(file, address, f::Field)
    #= none:143 =#
    #= none:144 =#
    serializeproperty!(file, address * "/location", instantiated_location(f))
    #= none:145 =#
    serializeproperty!(file, address * "/data", parent(f))
    #= none:146 =#
    serializeproperty!(file, address * "/indices", indices(f))
    #= none:147 =#
    serializeproperty!(file, address * "/boundary_conditions", boundary_conditions(f))
    #= none:148 =#
    return nothing
end
#= none:154 =#
function serializeproperty!(file, address, ts::RungeKutta3TimeStepper)
    #= none:154 =#
    #= none:155 =#
    serializeproperty!(file, address * "/Gⁿ", ts.Gⁿ)
    #= none:156 =#
    serializeproperty!(file, address * "/G⁻", ts.G⁻)
    #= none:157 =#
    return nothing
end
#= none:160 =#
function serializeproperty!(file, address, ts::QuasiAdamsBashforth2TimeStepper)
    #= none:160 =#
    #= none:161 =#
    serializeproperty!(file, address * "/Gⁿ", ts.Gⁿ)
    #= none:162 =#
    serializeproperty!(file, address * "/G⁻", ts.G⁻)
    #= none:163 =#
    return nothing
end
#= none:166 =#
serializeproperty!(file, address, p::NamedTuple) = begin
        #= none:166 =#
        [serializeproperty!(file, address * "/$(subp)", getproperty(p, subp)) for subp = keys(p)]
    end
#= none:167 =#
serializeproperty!(file, address, s::StructArray) = begin
        #= none:167 =#
        file[address] = replace_storage(Array, s)
    end
#= none:168 =#
serializeproperty!(file, address, p::LagrangianParticles) = begin
        #= none:168 =#
        serializeproperty!(file, address, p.properties)
    end
#= none:170 =#
saveproperties!(file, structure, ps) = begin
        #= none:170 =#
        [saveproperty!(file, "$(p)", getproperty(structure, p)) for p = ps]
    end
#= none:171 =#
serializeproperties!(file, structure, ps) = begin
        #= none:171 =#
        [serializeproperty!(file, "$(p)", getproperty(structure, p)) for p = ps]
    end
#= none:174 =#
has_reference(T, ::AbstractArray{<:Number}) = begin
        #= none:174 =#
        false
    end
#= none:177 =#
(has_reference(::Type{T}, ::NTuple{N, <:T}) where {N, T}) = begin
        #= none:177 =#
        true
    end
#= none:180 =#
has_reference(T::Type{Function}, f::Field) = begin
        #= none:180 =#
        has_reference(T, f.data) || has_reference(T, f.boundary_conditions)
    end
#= none:183 =#
#= none:183 =# Core.@doc "    has_reference(has_type, obj)\n\nCheck (or attempt to check) if `obj` contains, somewhere among its\nsubfields and subfields of fields, a reference to an object of type\n`has_type`. This function doesn't always work.\n" function has_reference(has_type, obj)
        #= none:190 =#
        #= none:191 =#
        if typeof(obj) <: has_type
            #= none:192 =#
            return true
        elseif #= none:193 =# applicable(iterate, obj) && length(obj) > 1
            #= none:194 =#
            return any([has_reference(has_type, elem) for elem = obj])
        elseif #= none:195 =# applicable(propertynames, obj) && length(propertynames(obj)) > 0
            #= none:196 =#
            return any([has_reference(has_type, getproperty(obj, p)) for p = propertynames(obj)])
        else
            #= none:198 =#
            return typeof(obj) <: has_type
        end
    end
#= none:202 =#
#= none:202 =# Core.@doc " Returns the schedule for output averaging determined by the first output value. " function output_averaging_schedule(ow::AbstractOutputWriter)
        #= none:203 =#
        #= none:204 =#
        first_output = first(values(ow.outputs))
        #= none:205 =#
        return output_averaging_schedule(first_output)
    end
#= none:208 =#
output_averaging_schedule(output) = begin
        #= none:208 =#
        nothing
    end
#= none:210 =#
(show_array_type(a::Type{Array{T}}) where T) = begin
        #= none:210 =#
        "Array{$(T)}"
    end
#= none:212 =#
#= none:212 =# Core.@doc "    auto_extension(filename, ext)                                                             \n\nIf `filename` ends in `ext`, return `filename`. Otherwise return `filename * ext`.\n" function auto_extension(filename, ext)
        #= none:217 =#
        #= none:218 =#
        if endswith(filename, ext)
            #= none:219 =#
            return filename
        else
            #= none:221 =#
            return filename * ext
        end
    end