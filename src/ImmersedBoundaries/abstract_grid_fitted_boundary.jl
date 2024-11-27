
#= none:1 =#
abstract type AbstractGridFittedBoundary <: AbstractImmersedBoundary end
#= none:3 =#
const GFIBG = ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:AbstractGridFittedBoundary}
#= none:8 =#
const AGFB = AbstractGridFittedBoundary
#= none:10 =#
#= none:10 =# @inline immersed_cell(i, j, k, grid, ib) = begin
            #= none:10 =#
            _immersed_cell(i, j, k, grid, ib)
        end
#= none:12 =#
#= none:12 =# @eval begin
        #= none:13 =#
        #= none:13 =# @inline immersed_cell(i, j, k, grid::AbstractGrid{<:Any, Flat, <:Any, <:Any}, ib::AGFB) = begin
                    #= none:13 =#
                    _immersed_cell(1, j, k, grid, ib)
                end
        #= none:14 =#
        #= none:14 =# @inline immersed_cell(i, j, k, grid::AbstractGrid{<:Any, <:Any, Flat, <:Any}, ib::AGFB) = begin
                    #= none:14 =#
                    _immersed_cell(i, 1, k, grid, ib)
                end
        #= none:15 =#
        #= none:15 =# @inline immersed_cell(i, j, k, grid::AbstractGrid{<:Any, <:Any, <:Any, Flat}, ib::AGFB) = begin
                    #= none:15 =#
                    _immersed_cell(i, j, 1, grid, ib)
                end
        #= none:16 =#
        #= none:16 =# @inline immersed_cell(i, j, k, grid::AbstractGrid{<:Any, Flat, Flat, <:Any}, ib::AGFB) = begin
                    #= none:16 =#
                    _immersed_cell(1, 1, k, grid, ib)
                end
        #= none:17 =#
        #= none:17 =# @inline immersed_cell(i, j, k, grid::AbstractGrid{<:Any, Flat, <:Any, Flat}, ib::AGFB) = begin
                    #= none:17 =#
                    _immersed_cell(1, j, 1, grid, ib)
                end
        #= none:18 =#
        #= none:18 =# @inline immersed_cell(i, j, k, grid::AbstractGrid{<:Any, <:Any, Flat, Flat}, ib::AGFB) = begin
                    #= none:18 =#
                    _immersed_cell(i, 1, 1, grid, ib)
                end
        #= none:19 =#
        #= none:19 =# @inline immersed_cell(i, j, k, grid::AbstractGrid{<:Any, Flat, Flat, Flat}, ib::AGFB) = begin
                    #= none:19 =#
                    _immersed_cell(1, 1, 1, grid, ib)
                end
    end
#= none:22 =#
function clamp_bottom_height!(bottom_field, grid)
    #= none:22 =#
    #= none:23 =#
    launch!(architecture(grid), grid, :xy, _clamp_bottom_height!, bottom_field, grid)
    #= none:24 =#
    return nothing
end
#= none:27 =#
const c = Center()
#= none:28 =#
const f = Face()
#= none:30 =#
#= none:30 =# @kernel function _clamp_bottom_height!(z, grid)
        #= none:30 =#
        #= none:31 =#
        (i, j) = #= none:31 =# @index(Global, NTuple)
        #= none:32 =#
        Nz = size(grid, 3)
        #= none:33 =#
        zmin = znode(i, j, 1, grid, c, c, f)
        #= none:34 =#
        zmax = znode(i, j, Nz + 1, grid, c, c, f)
        #= none:35 =#
        #= none:35 =# @inbounds z[i, j, 1] = clamp(z[i, j, 1], zmin, zmax)
    end