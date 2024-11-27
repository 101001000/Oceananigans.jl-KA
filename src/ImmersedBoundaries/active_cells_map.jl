
#= none:1 =#
using Oceananigans
#= none:2 =#
using Oceananigans.Utils
#= none:3 =#
using Oceananigans.Grids: AbstractGrid
#= none:5 =#
using KernelAbstractions: @kernel, @index
#= none:7 =#
import Oceananigans.Grids: retrieve_surface_active_cells_map, retrieve_interior_active_cells_map
#= none:13 =#
const WholeActiveCellsMapIBG = ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:AbstractArray}
#= none:19 =#
const SplitActiveCellsMapIBG = ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:NamedTuple}
#= none:21 =#
#= none:21 =# Core.@doc "A constant representing an immersed boundary grid, where interior active cells are mapped to linear indices in grid.interior_active_cells\n" const ActiveCellsIBG = ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Union{AbstractArray, NamedTuple}}
#= none:26 =#
#= none:26 =# Core.@doc "A constant representing an immersed boundary grid, where active columns in the Z-direction are mapped to linear indices in grid.active_z_columns\n" const ActiveZColumnsIBG = ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:AbstractArray}
#= none:31 =#
#= none:31 =# @inline retrieve_surface_active_cells_map(grid::ActiveZColumnsIBG) = begin
            #= none:31 =#
            grid.active_z_columns
        end
#= none:33 =#
#= none:33 =# @inline retrieve_interior_active_cells_map(grid::WholeActiveCellsMapIBG, ::Val{:interior}) = begin
            #= none:33 =#
            grid.interior_active_cells
        end
#= none:34 =#
#= none:34 =# @inline retrieve_interior_active_cells_map(grid::SplitActiveCellsMapIBG, ::Val{:interior}) = begin
            #= none:34 =#
            grid.interior_active_cells.halo_independent_cells
        end
#= none:35 =#
#= none:35 =# @inline retrieve_interior_active_cells_map(grid::SplitActiveCellsMapIBG, ::Val{:west}) = begin
            #= none:35 =#
            grid.interior_active_cells.west_halo_dependent_cells
        end
#= none:36 =#
#= none:36 =# @inline retrieve_interior_active_cells_map(grid::SplitActiveCellsMapIBG, ::Val{:east}) = begin
            #= none:36 =#
            grid.interior_active_cells.east_halo_dependent_cells
        end
#= none:37 =#
#= none:37 =# @inline retrieve_interior_active_cells_map(grid::SplitActiveCellsMapIBG, ::Val{:south}) = begin
            #= none:37 =#
            grid.interior_active_cells.south_halo_dependent_cells
        end
#= none:38 =#
#= none:38 =# @inline retrieve_interior_active_cells_map(grid::SplitActiveCellsMapIBG, ::Val{:north}) = begin
            #= none:38 =#
            grid.interior_active_cells.north_halo_dependent_cells
        end
#= none:39 =#
#= none:39 =# @inline retrieve_interior_active_cells_map(grid::ActiveZColumnsIBG, ::Val{:surface}) = begin
            #= none:39 =#
            grid.active_z_columns
        end
#= none:41 =#
#= none:41 =# Core.@doc "    active_linear_index_to_tuple(idx, map, grid)\n\nConverts a linear index to a tuple of indices based on the given map and grid.\n\n# Arguments\n- `idx`: The linear index to convert.\n- `active_cells_map`: The map containing the N-dimensional index of the active cells\n\n# Returns\nA tuple of indices corresponding to the linear index.\n" #= none:53 =# @inline(active_linear_index_to_tuple(idx, active_cells_map) = begin
                #= none:53 =#
                #= none:53 =# @inbounds Base.map(Int, active_cells_map[idx])
            end)
#= none:55 =#
function ImmersedBoundaryGrid(grid, ib; active_cells_map::Bool = true)
    #= none:55 =#
    #= none:57 =#
    ibg = ImmersedBoundaryGrid(grid, ib)
    #= none:58 =#
    (TX, TY, TZ) = topology(ibg)
    #= none:61 =#
    if active_cells_map
        #= none:62 =#
        interior_map = map_interior_active_cells(ibg)
        #= none:63 =#
        column_map = map_active_z_columns(ibg)
    else
        #= none:65 =#
        interior_map = nothing
        #= none:66 =#
        column_map = nothing
    end
    #= none:69 =#
    return ImmersedBoundaryGrid{TX, TY, TZ}(ibg.underlying_grid, ibg.immersed_boundary, interior_map, column_map)
end
#= none:75 =#
with_halo(halo, ibg::ActiveCellsIBG) = begin
        #= none:75 =#
        ImmersedBoundaryGrid(with_halo(halo, ibg.underlying_grid), ibg.immersed_boundary; active_cells_map = true)
    end
#= none:78 =#
#= none:78 =# @inline active_cell(i, j, k, ibg) = begin
            #= none:78 =#
            !(immersed_cell(i, j, k, ibg))
        end
#= none:79 =#
#= none:79 =# @inline active_column(i, j, k, grid, column) = begin
            #= none:79 =#
            column[i, j, k] != 0
        end
#= none:81 =#
#= none:81 =# @kernel function _set_active_indices!(active_cells_field, grid)
        #= none:81 =#
        #= none:82 =#
        (i, j, k) = #= none:82 =# @index(Global, NTuple)
        #= none:83 =#
        #= none:83 =# @inbounds active_cells_field[i, j, k] = active_cell(i, j, k, grid)
    end
#= none:86 =#
function compute_interior_active_cells(ibg; parameters = :xyz)
    #= none:86 =#
    #= none:87 =#
    active_cells_field = Field{Center, Center, Center}(ibg, Bool)
    #= none:88 =#
    fill!(active_cells_field, false)
    #= none:89 =#
    launch!(architecture(ibg), ibg, parameters, _set_active_indices!, active_cells_field, ibg)
    #= none:90 =#
    return active_cells_field
end
#= none:93 =#
function compute_active_z_columns(ibg)
    #= none:93 =#
    #= none:94 =#
    one_field = OneField(Int)
    #= none:95 =#
    condition = NotImmersed(truefunc)
    #= none:96 =#
    mask = 0
    #= none:99 =#
    conditional_active_cells = ConditionalOperation{Center, Center, Center}(one_field, identity, ibg, condition, mask)
    #= none:100 =#
    active_cells_in_column = sum(conditional_active_cells, dims = 3)
    #= none:103 =#
    is_immersed_column = KernelFunctionOperation{Center, Center, Nothing}(active_column, ibg, active_cells_in_column)
    #= none:104 =#
    active_z_columns = Field{Center, Center, Nothing}(ibg, Bool)
    #= none:105 =#
    set!(active_z_columns, is_immersed_column)
    #= none:107 =#
    return active_z_columns
end
#= none:112 =#
const MAXUInt8 = 2 ^ 8 - 1
#= none:113 =#
const MAXUInt16 = 2 ^ 16 - 1
#= none:114 =#
const MAXUInt32 = 2 ^ 32 - 1
#= none:116 =#
#= none:116 =# Core.@doc "    interior_active_indices(ibg; parameters = :xyz)\n\nCompute the indices of the active interior cells in the given immersed boundary grid within the indices\nspecified by the `parameters` keyword argument\n\n# Arguments\n- `ibg`: The immersed boundary grid.\n- `parameters`: (optional) The parameters to be used for computing the active cells. Default is `:xyz`.\n\n# Returns\nAn array of tuples representing the indices of the active interior cells.\n" function interior_active_indices(ibg; parameters = :xyz)
        #= none:129 =#
        #= none:130 =#
        active_cells_field = compute_interior_active_cells(ibg; parameters)
        #= none:132 =#
        N = maximum(size(ibg))
        #= none:133 =#
        IntType = if N > MAXUInt8
                if N > MAXUInt16
                    if N > MAXUInt32
                        UInt64
                    else
                        UInt32
                    end
                else
                    UInt16
                end
            else
                UInt8
            end
        #= none:135 =#
        IndicesType = Tuple{IntType, IntType, IntType}
        #= none:140 =#
        active_indices = IndicesType[]
        #= none:141 =#
        active_indices = findall_active_indices!(active_indices, active_cells_field, ibg, IndicesType)
        #= none:142 =#
        active_indices = on_architecture(architecture(ibg), active_indices)
        #= none:144 =#
        return active_indices
    end
#= none:150 =#
function findall_active_indices!(active_indices, active_cells_field, ibg, IndicesType)
    #= none:150 =#
    #= none:152 =#
    for k = 1:size(ibg, 3)
        #= none:153 =#
        interior_indices = findall(on_architecture(CPU(), interior(active_cells_field, :, :, k:k)))
        #= none:154 =#
        interior_indices = convert_interior_indices(interior_indices, k, IndicesType)
        #= none:155 =#
        active_indices = vcat(active_indices, interior_indices)
        #= none:156 =#
        GC.gc()
        #= none:157 =#
    end
    #= none:159 =#
    return active_indices
end
#= none:162 =#
function convert_interior_indices(interior_indices, k, IndicesType)
    #= none:162 =#
    #= none:163 =#
    interior_indices = getproperty.(interior_indices, :I)
    #= none:164 =#
    interior_indices = add_3rd_index.(interior_indices, k) |> Array{IndicesType}
    #= none:165 =#
    return interior_indices
end
#= none:168 =#
#= none:168 =# @inline add_3rd_index(ij::Tuple, k) = begin
            #= none:168 =#
            (ij[1], ij[2], k)
        end
#= none:173 =#
map_interior_active_cells(ibg) = begin
        #= none:173 =#
        interior_active_indices(ibg; parameters = :xyz)
    end
#= none:177 =#
function map_active_z_columns(ibg)
    #= none:177 =#
    #= none:178 =#
    active_cells_field = compute_active_z_columns(ibg)
    #= none:179 =#
    interior_cells = on_architecture(CPU(), interior(active_cells_field, :, :, 1))
    #= none:181 =#
    full_indices = findall(interior_cells)
    #= none:183 =#
    (Nx, Ny, _) = size(ibg)
    #= none:185 =#
    N = max(Nx, Ny)
    #= none:186 =#
    IntType = if N > MAXUInt8
            if N > MAXUInt16
                if N > MAXUInt32
                    UInt64
                else
                    UInt32
                end
            else
                UInt16
            end
        else
            UInt8
        end
    #= none:187 =#
    surface_map = getproperty.(full_indices, Ref(:I)) .|> Tuple{IntType, IntType}
    #= none:188 =#
    surface_map = on_architecture(architecture(ibg), surface_map)
    #= none:190 =#
    return surface_map
end