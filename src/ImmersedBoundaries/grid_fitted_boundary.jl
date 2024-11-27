
#= none:1 =#
using OffsetArrays
#= none:3 =#
#= none:3 =# Core.@doc "\n   GridFittedBoundary(mask)\n\nReturn a immersed boundary with a three-dimensional `mask`.\n" struct GridFittedBoundary{M} <: AbstractGridFittedBoundary
        #= none:10 =#
        mask::M
    end
#= none:13 =#
#= none:13 =# @inline _immersed_cell(i, j, k, underlying_grid, ib::GridFittedBoundary{<:AbstractArray}) = begin
            #= none:13 =#
            #= none:13 =# @inbounds ib.mask[i, j, k]
        end
#= none:15 =#
#= none:15 =# @inline function _immersed_cell(i, j, k, underlying_grid, ib::GridFittedBoundary)
        #= none:15 =#
        #= none:16 =#
        (x, y, z) = node(i, j, k, underlying_grid, c, c, c)
        #= none:17 =#
        return ib.mask(x, y, z)
    end
#= none:20 =#
function compute_mask(grid, ib)
    #= none:20 =#
    #= none:21 =#
    mask_field = Field{Center, Center, Center}(grid, Bool)
    #= none:22 =#
    set!(mask_field, ib.mask)
    #= none:23 =#
    fill_halo_regions!(mask_field)
    #= none:24 =#
    return mask_field
end
#= none:27 =#
function ImmersedBoundaryGrid(grid, ib::GridFittedBoundary; precompute_mask = true)
    #= none:27 =#
    #= none:28 =#
    (TX, TY, TZ) = topology(grid)
    #= none:32 =#
    if precompute_mask
        #= none:33 =#
        mask_field = compute_mask(grid, ib)
        #= none:34 =#
        new_ib = GridFittedBoundary(mask_field)
        #= none:35 =#
        return ImmersedBoundaryGrid{TX, TY, TZ}(grid, new_ib)
    else
        #= none:37 =#
        return ImmersedBoundaryGrid{TX, TY, TZ}(grid, ib)
    end
end
#= none:41 =#
on_architecture(arch, ib::GridFittedBoundary{<:Field}) = begin
        #= none:41 =#
        GridFittedBoundary(compute_mask(on_architecture(arch, ib.mask.grid), ib))
    end
#= none:42 =#
on_architecture(arch, ib::GridFittedBoundary) = begin
        #= none:42 =#
        ib
    end
#= none:44 =#
Adapt.adapt_structure(to, ib::AbstractGridFittedBoundary) = begin
        #= none:44 =#
        GridFittedBoundary(adapt(to, ib.mask))
    end