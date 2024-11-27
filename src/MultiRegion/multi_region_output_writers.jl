
#= none:1 =#
using Oceananigans.Fields: compute_at!
#= none:3 =#
import Oceananigans.OutputWriters: fetch_output, construct_output, serializeproperty!
#= none:10 =#
function fetch_output(mrf::MultiRegionField, model)
    #= none:10 =#
    #= none:11 =#
    field = reconstruct_global_field(mrf)
    #= none:12 =#
    compute_at!(field, model.clock.time)
    #= none:13 =#
    return parent(field)
end
#= none:16 =#
function construct_output(mrf::MultiRegionField, grid, user_indices, with_halos)
    #= none:16 =#
    #= none:21 =#
    indices = (:, :, user_indices[3])
    #= none:23 =#
    return construct_output(mrf, indices)
end
#= none:26 =#
function serializeproperty!(file, location, mrf::MultiRegionField{LX, LY, LZ}) where {LX, LY, LZ}
    #= none:26 =#
    #= none:27 =#
    p = reconstruct_global_field(mrf)
    #= none:28 =#
    serializeproperty!(file, location * "/location", (LX(), LY(), LZ()))
    #= none:29 =#
    serializeproperty!(file, location * "/data", parent(p))
    #= none:30 =#
    serializeproperty!(file, location * "/boundary_conditions", p.boundary_conditions)
    #= none:32 =#
    return nothing
end
#= none:35 =#
function serializeproperty!(file, location, mrg::MultiRegionGrids)
    #= none:35 =#
    #= none:36 =#
    file[location] = on_architecture(CPU(), reconstruct_global_grid(mrg))
end