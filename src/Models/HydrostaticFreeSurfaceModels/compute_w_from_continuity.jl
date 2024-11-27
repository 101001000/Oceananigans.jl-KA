
#= none:1 =#
using Oceananigans.Architectures: device
#= none:2 =#
using Oceananigans.Grids: halo_size, topology
#= none:3 =#
using Oceananigans.Grids: XFlatGrid, YFlatGrid
#= none:4 =#
using Oceananigans.Operators: div_xyᶜᶜᶜ, Δzᶜᶜᶜ
#= none:6 =#
#= none:6 =# Core.@doc "    compute_w_from_continuity!(model)\n\nCompute the vertical velocity ``w`` by integrating the continuity equation from the bottom upwards:\n\n```\nw^{n+1} = -∫ [∂/∂x (u^{n+1}) + ∂/∂y (v^{n+1})] dz\n```\n" compute_w_from_continuity!(model; kwargs...) = begin
            #= none:15 =#
            compute_w_from_continuity!(model.velocities, model.architecture, model.grid; kwargs...)
        end
#= none:18 =#
compute_w_from_continuity!(velocities, arch, grid; parameters = w_kernel_parameters(grid)) = begin
        #= none:18 =#
        launch!(arch, grid, parameters, _compute_w_from_continuity!, velocities, grid)
    end
#= none:21 =#
#= none:21 =# @kernel function _compute_w_from_continuity!(U, grid)
        #= none:21 =#
        #= none:22 =#
        (i, j) = #= none:22 =# @index(Global, NTuple)
        #= none:24 =#
        #= none:24 =# @inbounds U.w[i, j, 1] = 0
        #= none:25 =#
        for k = 2:grid.Nz + 1
            #= none:26 =#
            #= none:26 =# @inbounds U.w[i, j, k] = U.w[i, j, k - 1] - Δzᶜᶜᶜ(i, j, k - 1, grid) * div_xyᶜᶜᶜ(i, j, k - 1, grid, U.u, U.v)
            #= none:27 =#
        end
    end
#= none:36 =#
#= none:36 =# @inline function w_kernel_parameters(grid)
        #= none:36 =#
        #= none:37 =#
        (Nx, Ny, _) = size(grid)
        #= none:38 =#
        (Hx, Hy, _) = halo_size(grid)
        #= none:39 =#
        (Tx, Ty, _) = topology(grid)
        #= none:41 =#
        ii = ifelse(Tx == Flat, 1:Nx, -Hx + 2:(Nx + Hx) - 1)
        #= none:42 =#
        jj = ifelse(Ty == Flat, 1:Ny, -Hy + 2:(Ny + Hy) - 1)
        #= none:44 =#
        return KernelParameters(ii, jj)
    end