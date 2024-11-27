
#= none:1 =#
using Oceananigans.Utils: getnamewrapper
#= none:2 =#
using Oceananigans.ImmersedBoundaries
#= none:3 =#
using Oceananigans.ImmersedBoundaries: AbstractGridFittedBottom, GridFittedBottom, GridFittedBoundary, compute_mask, interior_active_indices
#= none:9 =#
import Oceananigans.ImmersedBoundaries: map_interior_active_cells
#= none:15 =#
const DistributedImmersedBoundaryGrid = (ImmersedBoundaryGrid{FT, TX, TY, TZ, <:DistributedGrid, I, M, <:Distributed} where {FT, TX, TY, TZ, I, M})
#= none:17 =#
function reconstruct_global_grid(grid::ImmersedBoundaryGrid)
    #= none:17 =#
    #= none:18 =#
    arch = grid.architecture
    #= none:19 =#
    local_ib = grid.immersed_boundary
    #= none:20 =#
    global_ug = reconstruct_global_grid(grid.underlying_grid)
    #= none:21 =#
    global_ib = (getnamewrapper(local_ib))(construct_global_array(arch, local_ib.bottom_height, size(grid)))
    #= none:22 =#
    return ImmersedBoundaryGrid(global_ug, global_ib)
end
#= none:25 =#
function with_halo(new_halo, grid::DistributedImmersedBoundaryGrid)
    #= none:25 =#
    #= none:26 =#
    immersed_boundary = grid.immersed_boundary
    #= none:27 =#
    underlying_grid = grid.underlying_grid
    #= none:28 =#
    new_underlying_grid = with_halo(new_halo, underlying_grid)
    #= none:29 =#
    new_immersed_boundary = resize_immersed_boundary(immersed_boundary, new_underlying_grid)
    #= none:30 =#
    return ImmersedBoundaryGrid(new_underlying_grid, new_immersed_boundary)
end
#= none:33 =#
function scatter_local_grids(global_grid::ImmersedBoundaryGrid, arch::Distributed, local_size)
    #= none:33 =#
    #= none:34 =#
    ib = global_grid.immersed_boundary
    #= none:35 =#
    ug = global_grid.underlying_grid
    #= none:37 =#
    local_ug = scatter_local_grids(ug, arch, local_size)
    #= none:40 =#
    local_bottom_height = partition(ib.bottom_height, arch, local_size)
    #= none:41 =#
    ImmersedBoundaryConstructor = getnamewrapper(ib)
    #= none:42 =#
    local_ib = ImmersedBoundaryConstructor(local_bottom_height)
    #= none:44 =#
    return ImmersedBoundaryGrid(local_ug, local_ib)
end
#= none:47 =#
#= none:47 =# Core.@doc "    function resize_immersed_boundary!(ib, grid)\n\nIf the immersed condition is an `OffsetArray`, resize it to match \nthe total size of `grid`\n" resize_immersed_boundary(ib::AbstractGridFittedBottom, grid) = begin
            #= none:53 =#
            ib
        end
#= none:54 =#
resize_immersed_boundary(ib::GridFittedBoundary, grid) = begin
        #= none:54 =#
        ib
    end
#= none:56 =#
function resize_immersed_boundary(ib::GridFittedBoundary{<:OffsetArray}, grid)
    #= none:56 =#
    #= none:58 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:59 =#
    (Hx, Hy, Nz) = halo_size(grid)
    #= none:61 =#
    mask_size = (Nx, Ny, Nz) .+ 2 .* (Hx, Hy, Hz)
    #= none:65 =#
    if any(size(ib.mask) .!= mask_size)
        #= none:66 =#
        #= none:66 =# @warn "Resizing the mask to match the grids' halos"
        #= none:67 =#
        mask = compute_mask(grid, ib)
        #= none:68 =#
        return (getnamewrapper(ib))(mask)
    end
    #= none:71 =#
    return ib
end
#= none:74 =#
function resize_immersed_boundary(ib::AbstractGridFittedBottom{<:OffsetArray}, grid)
    #= none:74 =#
    #= none:76 =#
    (Nx, Ny, _) = size(grid)
    #= none:77 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:79 =#
    bottom_heigth_size = (Nx, Ny) .+ 2 .* (Hx, Hy)
    #= none:83 =#
    if any(size(ib.bottom_height) .!= bottom_heigth_size)
        #= none:84 =#
        #= none:84 =# @warn "Resizing the bottom field to match the grids' halos"
        #= none:85 =#
        bottom_field = Field((Center, Center, Nothing), grid)
        #= none:86 =#
        cpu_bottom = (on_architecture(CPU(), ib.bottom_height))[1:Nx, 1:Ny]
        #= none:87 =#
        set!(bottom_field, cpu_bottom)
        #= none:88 =#
        fill_halo_regions!(bottom_field)
        #= none:89 =#
        offset_bottom_array = dropdims(bottom_field.data, dims = 3)
        #= none:91 =#
        return (getnamewrapper(ib))(offset_bottom_array)
    end
    #= none:94 =#
    return ib
end
#= none:98 =#
const DistributedActiveCellsIBG = ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:DistributedGrid, <:Any, <:NamedTuple}
#= none:109 =#
function map_interior_active_cells(ibg::ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:DistributedGrid})
    #= none:109 =#
    #= none:111 =#
    arch = architecture(ibg)
    #= none:115 =#
    if arch isa SynchronizedDistributed
        #= none:116 =#
        return interior_active_indices(ibg; parameters = :xyz)
    end
    #= none:119 =#
    (Rx, Ry, _) = arch.ranks
    #= none:120 =#
    (Tx, Ty, _) = topology(ibg)
    #= none:121 =#
    (Nx, Ny, Nz) = size(ibg)
    #= none:122 =#
    (Hx, Hy, _) = halo_size(ibg)
    #= none:124 =#
    x_boundary = (Hx, Ny, Nz)
    #= none:125 =#
    y_boundary = (Nx, Hy, Nz)
    #= none:127 =#
    left_offsets = (0, 0, 0)
    #= none:128 =#
    right_x_offsets = (Nx - Hx, 0, 0)
    #= none:129 =#
    right_y_offsets = (0, Ny - Hy, 0)
    #= none:131 =#
    include_west = !(ibg isa XFlatGrid) && (Rx != 1 && !(Tx == RightConnected))
    #= none:132 =#
    include_east = !(ibg isa XFlatGrid) && (Rx != 1 && !(Tx == LeftConnected))
    #= none:133 =#
    include_south = !(ibg isa YFlatGrid) && (Ry != 1 && !(Ty == RightConnected))
    #= none:134 =#
    include_north = !(ibg isa YFlatGrid) && (Ry != 1 && !(Ty == LeftConnected))
    #= none:136 =#
    west_halo_dependent_cells = if include_west
            interior_active_indices(ibg; parameters = KernelParameters(x_boundary, left_offsets))
        else
            nothing
        end
    #= none:137 =#
    east_halo_dependent_cells = if include_east
            interior_active_indices(ibg; parameters = KernelParameters(x_boundary, right_x_offsets))
        else
            nothing
        end
    #= none:138 =#
    south_halo_dependent_cells = if include_south
            interior_active_indices(ibg; parameters = KernelParameters(y_boundary, left_offsets))
        else
            nothing
        end
    #= none:139 =#
    north_halo_dependent_cells = if include_north
            interior_active_indices(ibg; parameters = KernelParameters(y_boundary, right_y_offsets))
        else
            nothing
        end
    #= none:141 =#
    nx = if Rx == 1
            Nx
        else
            if Tx == RightConnected || Tx == LeftConnected
                Nx - Hx
            else
                Nx - 2Hx
            end
        end
    #= none:142 =#
    ny = if Ry == 1
            Ny
        else
            if Ty == RightConnected || Ty == LeftConnected
                Ny - Hy
            else
                Ny - 2Hy
            end
        end
    #= none:144 =#
    ox = if Rx == 1 || Tx == RightConnected
            0
        else
            Hx
        end
    #= none:145 =#
    oy = if Ry == 1 || Ty == RightConnected
            0
        else
            Hy
        end
    #= none:147 =#
    halo_independent_cells = interior_active_indices(ibg; parameters = KernelParameters((nx, ny, Nz), (ox, oy, 0)))
    #= none:149 =#
    return (; halo_independent_cells, west_halo_dependent_cells, east_halo_dependent_cells, south_halo_dependent_cells, north_halo_dependent_cells)
end