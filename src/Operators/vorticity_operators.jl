
#= none:1 =#
using Oceananigans.Grids: ConformalCubedSpherePanel
#= none:3 =#
#= none:3 =# Core.@doc " Vertical circulation associated with horizontal velocities u, v. " #= none:4 =# @inline(Γᶠᶠᶜ(i, j, k, grid, u, v) = begin
                #= none:4 =#
                δxᶠᶠᶜ(i, j, k, grid, Δy_qᶜᶠᶜ, v) - δyᶠᶠᶜ(i, j, k, grid, Δx_qᶠᶜᶜ, u)
            end)
#= none:6 =#
#= none:6 =# Core.@doc "    ζ₃ᶠᶠᶜ(i, j, k, grid, u, v)\n\nThe vertical vorticity associated with horizontal velocities ``u`` and ``v``.\n" #= none:11 =# @inline(ζ₃ᶠᶠᶜ(i, j, k, grid, u, v) = begin
                #= none:11 =#
                Γᶠᶠᶜ(i, j, k, grid, u, v) / Azᶠᶠᶜ(i, j, k, grid)
            end)
#= none:14 =#
#= none:14 =# @inline on_south_west_corner(i, j, grid) = begin
            #= none:14 =#
            (i == 1) & (j == 1)
        end
#= none:15 =#
#= none:15 =# @inline on_south_east_corner(i, j, grid) = begin
            #= none:15 =#
            (i == grid.Nx + 1) & (j == 1)
        end
#= none:16 =#
#= none:16 =# @inline on_north_east_corner(i, j, grid) = begin
            #= none:16 =#
            (i == grid.Nx + 1) & (j == grid.Ny + 1)
        end
#= none:17 =#
#= none:17 =# @inline on_north_west_corner(i, j, grid) = begin
            #= none:17 =#
            (i == 1) & (j == grid.Ny + 1)
        end
#= none:24 =#
#= none:24 =# Core.@doc "    Γᶠᶠᶜ(i, j, k, grid, u, v)\n\nThe vertical circulation associated with horizontal velocities ``u`` and ``v``.\n" #= none:29 =# @inline(function Γᶠᶠᶜ(i, j, k, grid::ConformalCubedSpherePanel, u, v)
            #= none:29 =#
            #= none:30 =#
            (Hx, Hy) = (grid.Hx, grid.Hy)
            #= none:31 =#
            Γ = ifelse(on_south_west_corner(i, j, grid) | on_north_west_corner(i, j, grid), (Δy_qᶜᶠᶜ(i, j, k, grid, v) - Δx_qᶠᶜᶜ(i, j, k, grid, u)) + Δx_qᶠᶜᶜ(i, j - 1, k, grid, u), ifelse(on_south_east_corner(i, j, grid) | on_north_east_corner(i, j, grid), (-(Δy_qᶜᶠᶜ(i - 1, j, k, grid, v)) + Δx_qᶠᶜᶜ(i, j - 1, k, grid, u)) - Δx_qᶠᶜᶜ(i, j, k, grid, u), δxᶠᶠᶜ(i, j, k, grid, Δy_qᶜᶠᶜ, v) - δyᶠᶠᶜ(i, j, k, grid, Δx_qᶠᶜᶜ, u)))
            #= none:38 =#
            return Γ
        end)