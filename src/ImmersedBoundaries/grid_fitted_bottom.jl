
#= none:1 =#
using Adapt
#= none:2 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:3 =#
using OffsetArrays: OffsetArray
#= none:4 =#
using Oceananigans.Utils: getnamewrapper
#= none:5 =#
using Oceananigans.Grids: total_size
#= none:6 =#
using Oceananigans.Fields: fill_halo_regions!
#= none:7 =#
using Oceananigans.BoundaryConditions: FBC
#= none:8 =#
using Printf
#= none:14 =#
abstract type AbstractGridFittedBottom{H} <: AbstractGridFittedBoundary end
#= none:18 =#
struct CenterImmersedCondition
    #= none:18 =#
end
#= none:19 =#
struct InterfaceImmersedCondition
    #= none:19 =#
end
#= none:21 =#
Base.summary(::CenterImmersedCondition) = begin
        #= none:21 =#
        "CenterImmersedCondition"
    end
#= none:22 =#
Base.summary(::InterfaceImmersedCondition) = begin
        #= none:22 =#
        "InterfaceImmersedCondition"
    end
#= none:24 =#
struct GridFittedBottom{H, I} <: AbstractGridFittedBottom{H}
    #= none:25 =#
    bottom_height::H
    #= none:26 =#
    immersed_condition::I
end
#= none:29 =#
const GFBIBG = ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:GridFittedBottom}
#= none:31 =#
#= none:31 =# Core.@doc "    GridFittedBottom(bottom_height, [immersed_condition=CenterImmersedCondition()])\n\nReturn a bottom immersed boundary.\n\nKeyword Arguments\n=================\n\n* `bottom_height`: an array or function that gives the height of the\n                   bottom in absolute ``z`` coordinates.\n\n* `immersed_condition`: Determine whether the part of the domain that is \n                        immersed are all the cell centers that lie below\n                        `bottom_height` (`CenterImmersedCondition()`; default)\n                        or all the cell faces that lie below `bottom_height`\n                        (`InterfaceImmersedCondition()`). The only purpose of\n                        `immersed_condition` to allow `GridFittedBottom` and\n                        `PartialCellBottom` to have the same behavior when the\n                        minimum fractional cell height for partial cells is set\n                        to 0.\n" GridFittedBottom(bottom_height) = begin
            #= none:52 =#
            GridFittedBottom(bottom_height, CenterImmersedCondition())
        end
#= none:54 =#
function Base.summary(ib::GridFittedBottom)
    #= none:54 =#
    #= none:55 =#
    zmax = maximum(ib.bottom_height)
    #= none:56 =#
    zmin = minimum(ib.bottom_height)
    #= none:57 =#
    zmean = mean(ib.bottom_height)
    #= none:59 =#
    summary1 = "GridFittedBottom("
    #= none:61 =#
    summary2 = string("mean(z)=", prettysummary(zmean), ", min(z)=", prettysummary(zmin), ", max(z)=", prettysummary(zmax))
    #= none:65 =#
    summary3 = ")"
    #= none:67 =#
    return summary1 * summary2 * summary3
end
#= none:70 =#
Base.summary(ib::GridFittedBottom{<:Function}) = begin
        #= none:70 =#
        #= none:70 =# @sprintf "GridFittedBottom(%s)" ib.bottom_height
    end
#= none:72 =#
function Base.show(io::IO, ib::GridFittedBottom)
    #= none:72 =#
    #= none:73 =#
    print(io, summary(ib), '\n')
    #= none:74 =#
    print(io, "├── bottom_height: ", prettysummary(ib.bottom_height), '\n')
    #= none:75 =#
    print(io, "└── immersed_condition: ", summary(ib.immersed_condition))
end
#= none:78 =#
#= none:78 =# @inline z_bottom(i, j, ibg::GFBIBG) = begin
            #= none:78 =#
            #= none:78 =# @inbounds ibg.immersed_boundary.bottom_height[i, j, 1]
        end
#= none:80 =#
#= none:80 =# Core.@doc "    ImmersedBoundaryGrid(grid, ib::GridFittedBottom)\n\nReturn a grid with `GridFittedBottom` immersed boundary (`ib`).\n\nComputes `ib.bottom_height` and wraps it in a Field.\n" function ImmersedBoundaryGrid(grid, ib::GridFittedBottom)
        #= none:87 =#
        #= none:88 =#
        bottom_field = Field{Center, Center, Nothing}(grid)
        #= none:89 =#
        set!(bottom_field, ib.bottom_height)
        #= none:90 =#
        #= none:90 =# @apply_regionally clamp_bottom_height!(bottom_field, grid)
        #= none:91 =#
        fill_halo_regions!(bottom_field)
        #= none:92 =#
        new_ib = GridFittedBottom(bottom_field, ib.immersed_condition)
        #= none:93 =#
        (TX, TY, TZ) = topology(grid)
        #= none:94 =#
        return ImmersedBoundaryGrid{TX, TY, TZ}(grid, new_ib)
    end
#= none:97 =#
#= none:97 =# @inline function _immersed_cell(i, j, k, underlying_grid, ib::GridFittedBottom{<:Any, <:InterfaceImmersedCondition})
        #= none:97 =#
        #= none:98 =#
        z = znode(i, j, k + 1, underlying_grid, c, c, f)
        #= none:99 =#
        h = #= none:99 =# @inbounds(ib.bottom_height[i, j, 1])
        #= none:100 =#
        return z ≤ h
    end
#= none:103 =#
#= none:103 =# @inline function _immersed_cell(i, j, k, underlying_grid, ib::GridFittedBottom{<:Any, <:CenterImmersedCondition})
        #= none:103 =#
        #= none:104 =#
        z = znode(i, j, k, underlying_grid, c, c, c)
        #= none:105 =#
        h = #= none:105 =# @inbounds(ib.bottom_height[i, j, 1])
        #= none:106 =#
        return z ≤ h
    end
#= none:109 =#
on_architecture(arch, ib::GridFittedBottom) = begin
        #= none:109 =#
        GridFittedBottom(ib.bottom_height, ib.immersed_condition)
    end
#= none:111 =#
function on_architecture(arch, ib::GridFittedBottom{<:Field})
    #= none:111 =#
    #= none:112 =#
    architecture(ib.bottom_height) == arch && return ib
    #= none:113 =#
    arch_grid = on_architecture(arch, ib.bottom_height.grid)
    #= none:114 =#
    new_bottom_height = Field{Center, Center, Nothing}(arch_grid)
    #= none:115 =#
    set!(new_bottom_height, ib.bottom_height)
    #= none:116 =#
    fill_halo_regions!(new_bottom_height)
    #= none:117 =#
    return GridFittedBottom(new_bottom_height, ib.immersed_condition)
end
#= none:120 =#
Adapt.adapt_structure(to, ib::GridFittedBottom) = begin
        #= none:120 =#
        GridFittedBottom(adapt(to, ib.bottom_height), ib.immersed_condition)
    end