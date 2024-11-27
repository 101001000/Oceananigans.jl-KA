
#= none:1 =#
import Oceananigans.Models: compute_buffer_tendencies!
#= none:3 =#
using Oceananigans.TurbulenceClosures: required_halo_size_x, required_halo_size_y
#= none:4 =#
using Oceananigans.Grids: XFlatGrid, YFlatGrid
#= none:10 =#
function compute_buffer_tendencies!(model::NonhydrostaticModel)
    #= none:10 =#
    #= none:11 =#
    grid = model.grid
    #= none:12 =#
    arch = architecture(grid)
    #= none:14 =#
    p_parameters = buffer_p_kernel_parameters(grid, arch)
    #= none:15 =#
    κ_parameters = buffer_κ_kernel_parameters(grid, model.closure, arch)
    #= none:18 =#
    compute_auxiliaries!(model; p_parameters, κ_parameters)
    #= none:21 =#
    kernel_parameters = buffer_tendency_kernel_parameters(grid, arch)
    #= none:22 =#
    compute_interior_tendency_contributions!(model, kernel_parameters)
    #= none:24 =#
    return nothing
end
#= none:28 =#
function buffer_tendency_kernel_parameters(grid, arch)
    #= none:28 =#
    #= none:29 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:30 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:32 =#
    param_west = (1:Hx, 1:Ny, 1:Nz)
    #= none:33 =#
    param_east = ((Nx - Hx) + 1:Nx, 1:Ny, 1:Nz)
    #= none:34 =#
    param_south = (1:Nx, 1:Hy, 1:Nz)
    #= none:35 =#
    param_north = (1:Nx, (Ny - Hy) + 1:Ny, 1:Nz)
    #= none:37 =#
    params = (param_west, param_east, param_south, param_north)
    #= none:38 =#
    return buffer_parameters(params, grid, arch)
end
#= none:42 =#
function buffer_p_kernel_parameters(grid, arch)
    #= none:42 =#
    #= none:43 =#
    (Nx, Ny, _) = size(grid)
    #= none:45 =#
    param_west = (0:0, 1:Ny)
    #= none:46 =#
    param_east = (Nx + 1:Nx + 1, 1:Ny)
    #= none:47 =#
    param_south = (1:Nx, 0:0)
    #= none:48 =#
    param_north = (1:Nx, Ny + 1:Ny + 1)
    #= none:50 =#
    params = (param_west, param_east, param_south, param_north)
    #= none:51 =#
    return buffer_parameters(params, grid, arch)
end
#= none:55 =#
function buffer_κ_kernel_parameters(grid, closure, arch)
    #= none:55 =#
    #= none:56 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:58 =#
    Bx = required_halo_size_x(closure)
    #= none:59 =#
    By = required_halo_size_y(closure)
    #= none:61 =#
    param_west = (0:Bx, 1:Ny, 1:Nz)
    #= none:62 =#
    param_east = ((Nx - Bx) + 1:Nx + 1, 1:Ny, 1:Nz)
    #= none:63 =#
    param_south = (1:Nx, 0:By, 1:Nz)
    #= none:64 =#
    param_north = (1:Nx, (Ny - By) + 1:Ny + 1, 1:Nz)
    #= none:66 =#
    params = (param_west, param_east, param_south, param_north)
    #= none:67 =#
    return buffer_parameters(params, grid, arch)
end
#= none:71 =#
function buffer_parameters(parameters, grid, arch)
    #= none:71 =#
    #= none:72 =#
    (Rx, Ry, _) = arch.ranks
    #= none:73 =#
    (Tx, Ty, _) = topology(grid)
    #= none:75 =#
    include_west = !(grid isa XFlatGrid) && (Rx != 1 && !(Tx == RightConnected))
    #= none:76 =#
    include_east = !(grid isa XFlatGrid) && (Rx != 1 && !(Tx == LeftConnected))
    #= none:77 =#
    include_south = !(grid isa YFlatGrid) && (Ry != 1 && !(Ty == RightConnected))
    #= none:78 =#
    include_north = !(grid isa YFlatGrid) && (Ry != 1 && !(Ty == LeftConnected))
    #= none:80 =#
    include_side = (include_west, include_east, include_south, include_north)
    #= none:82 =#
    return Tuple((KernelParameters(parameters[i]...) for i = findall(include_side)))
end