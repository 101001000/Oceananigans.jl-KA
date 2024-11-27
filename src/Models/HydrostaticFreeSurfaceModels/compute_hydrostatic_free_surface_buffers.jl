
#= none:1 =#
import Oceananigans.Models: compute_buffer_tendencies!
#= none:3 =#
using Oceananigans.Grids: halo_size
#= none:4 =#
using Oceananigans.DistributedComputations: DistributedActiveCellsIBG
#= none:5 =#
using Oceananigans.ImmersedBoundaries: retrieve_interior_active_cells_map
#= none:6 =#
using Oceananigans.Models.NonhydrostaticModels: buffer_tendency_kernel_parameters, buffer_p_kernel_parameters, buffer_κ_kernel_parameters, buffer_parameters
#= none:12 =#
function compute_buffer_tendencies!(model::HydrostaticFreeSurfaceModel)
    #= none:12 =#
    #= none:13 =#
    grid = model.grid
    #= none:14 =#
    arch = architecture(grid)
    #= none:16 =#
    w_parameters = buffer_w_kernel_parameters(grid, arch)
    #= none:17 =#
    p_parameters = buffer_p_kernel_parameters(grid, arch)
    #= none:18 =#
    κ_parameters = buffer_κ_kernel_parameters(grid, model.closure, arch)
    #= none:21 =#
    compute_auxiliaries!(model; w_parameters, p_parameters, κ_parameters)
    #= none:24 =#
    compute_buffer_tendency_contributions!(grid, arch, model)
    #= none:26 =#
    return nothing
end
#= none:29 =#
function compute_buffer_tendency_contributions!(grid, arch, model)
    #= none:29 =#
    #= none:30 =#
    kernel_parameters = buffer_tendency_kernel_parameters(grid, arch)
    #= none:31 =#
    compute_hydrostatic_free_surface_tendency_contributions!(model, kernel_parameters)
    #= none:32 =#
    return nothing
end
#= none:35 =#
function compute_buffer_tendency_contributions!(grid::DistributedActiveCellsIBG, arch, model)
    #= none:35 =#
    #= none:36 =#
    maps = grid.interior_active_cells
    #= none:38 =#
    for (name, map) = zip(keys(maps), maps)
        #= none:43 =#
        compute_buffer = name != :interior && !(isnothing(map))
        #= none:45 =#
        if compute_buffer
            #= none:46 =#
            active_cells_map = retrieve_interior_active_cells_map(grid, Val(name))
            #= none:47 =#
            compute_hydrostatic_free_surface_tendency_contributions!(model, :xyz; active_cells_map)
        end
        #= none:49 =#
    end
    #= none:51 =#
    return nothing
end
#= none:55 =#
function buffer_w_kernel_parameters(grid, arch)
    #= none:55 =#
    #= none:56 =#
    (Nx, Ny, _) = size(grid)
    #= none:57 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:59 =#
    Sx = (Hx, Ny + 2)
    #= none:60 =#
    Sy = (Nx + 2, Hy)
    #= none:64 =#
    param_west = (-Hx + 2:1, 0:Ny + 1)
    #= none:65 =#
    param_east = (Nx:(Nx + Hx) - 1, 0:Ny + 1)
    #= none:66 =#
    param_south = (0:Nx + 1, -Hy + 2:1)
    #= none:67 =#
    param_north = (0:Nx + 1, Ny:(Ny + Hy) - 1)
    #= none:69 =#
    params = (param_west, param_east, param_south, param_north)
    #= none:71 =#
    return buffer_parameters(params, grid, arch)
end