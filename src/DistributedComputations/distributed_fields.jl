
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:2 =#
using OffsetArrays: OffsetArray
#= none:3 =#
using Oceananigans.Grids: topology
#= none:4 =#
using Oceananigans.Fields: validate_field_data, indices, validate_boundary_conditions
#= none:5 =#
using Oceananigans.Fields: validate_indices, recv_from_buffers!, set_to_array!, set_to_field!
#= none:7 =#
import Oceananigans.Fields: Field, FieldBoundaryBuffers, location, set!
#= none:8 =#
import Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:10 =#
function Field((LX, LY, LZ)::Tuple, grid::DistributedGrid, data, old_bcs, indices::Tuple, op, status)
    #= none:10 =#
    #= none:11 =#
    indices = validate_indices(indices, (LX, LY, LZ), grid)
    #= none:12 =#
    validate_field_data((LX, LY, LZ), data, grid, indices)
    #= none:13 =#
    validate_boundary_conditions((LX, LY, LZ), grid, old_bcs)
    #= none:15 =#
    arch = architecture(grid)
    #= none:16 =#
    rank = arch.local_rank
    #= none:17 =#
    new_bcs = inject_halo_communication_boundary_conditions(old_bcs, rank, arch.connectivity, topology(grid))
    #= none:18 =#
    buffers = FieldBoundaryBuffers(grid, data, new_bcs)
    #= none:20 =#
    return Field{LX, LY, LZ}(grid, data, new_bcs, indices, op, status, buffers)
end
#= none:23 =#
const DistributedField = Field{<:Any, <:Any, <:Any, <:Any, <:DistributedGrid}
#= none:24 =#
const DistributedFieldTuple = (NamedTuple{S, <:NTuple{N, DistributedField}} where {S, N})
#= none:26 =#
global_size(f::DistributedField) = begin
        #= none:26 =#
        global_size(architecture(f), size(f))
    end
#= none:29 =#
function set!(u::DistributedField, V::Union{Array, GPUArrays.AbstractGPUArray, OffsetArray})
    #= none:29 =#
    #= none:30 =#
    NV = size(V)
    #= none:31 =#
    Nu = global_size(u)
    #= none:34 =#
    NV′ = filter((n->begin
                    #= none:34 =#
                    n > 1
                end), NV)
    #= none:35 =#
    Nu′ = filter((n->begin
                    #= none:35 =#
                    n > 1
                end), Nu)
    #= none:37 =#
    if NV′ == Nu′
        #= none:38 =#
        v = partition(V, u)
    else
        #= none:40 =#
        v = V
    end
    #= none:43 =#
    return set_to_array!(u, v)
end
#= none:46 =#
function set!(u::DistributedField, V::Field)
    #= none:46 =#
    #= none:47 =#
    if size(V) == global_size(u)
        #= none:48 =#
        v = partition(V, u)
        #= none:49 =#
        return set_to_array!(u, v)
    else
        #= none:51 =#
        return set_to_field!(u, V)
    end
end
#= none:56 =#
#= none:56 =# Core.@doc "    synchronize_communication!(field)\n\ncomplete the halo passing of `field` among processors.\n" function synchronize_communication!(field)
        #= none:61 =#
        #= none:62 =#
        arch = architecture(field.grid)
        #= none:65 =#
        if !(isempty(arch.mpi_requests))
            #= none:66 =#
            cooperative_waitall!(arch.mpi_requests)
            #= none:69 =#
            arch.mpi_tag[] -= arch.mpi_tag[]
            #= none:72 =#
            empty!(arch.mpi_requests)
        end
        #= none:75 =#
        recv_from_buffers!(field.data, field.boundary_buffers, field.grid)
        #= none:77 =#
        return nothing
    end
#= none:81 =#
reconstruct_global_field(field) = begin
        #= none:81 =#
        field
    end
#= none:83 =#
#= none:83 =# Core.@doc "    reconstruct_global_field(field::DistributedField)\n\nReconstruct a global field from a local field by combining the data from all processes.\n" function reconstruct_global_field(field::DistributedField)
        #= none:88 =#
        #= none:89 =#
        global_grid = reconstruct_global_grid(field.grid)
        #= none:90 =#
        global_field = Field(location(field), global_grid)
        #= none:91 =#
        arch = architecture(field)
        #= none:93 =#
        global_data = construct_global_array(arch, interior(field), size(field))
        #= none:95 =#
        set!(global_field, global_data)
        #= none:97 =#
        return global_field
    end