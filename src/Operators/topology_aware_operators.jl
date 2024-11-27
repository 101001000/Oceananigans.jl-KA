
#= none:1 =#
using Oceananigans.Grids: AbstractUnderlyingGrid
#= none:3 =#
const AGXB = (AbstractUnderlyingGrid{FT, Bounded} where FT)
#= none:4 =#
const AGXP = (AbstractUnderlyingGrid{FT, Periodic} where FT)
#= none:5 =#
const AGXR = (AbstractUnderlyingGrid{FT, RightConnected} where FT)
#= none:6 =#
const AGXL = (AbstractUnderlyingGrid{FT, LeftConnected} where FT)
#= none:8 =#
const AGYB = (AbstractUnderlyingGrid{FT, <:Any, Bounded} where FT)
#= none:9 =#
const AGYP = (AbstractUnderlyingGrid{FT, <:Any, Periodic} where FT)
#= none:10 =#
const AGYR = (AbstractUnderlyingGrid{FT, <:Any, RightConnected} where FT)
#= none:11 =#
const AGYL = (AbstractUnderlyingGrid{FT, <:Any, LeftConnected} where FT)
#= none:25 =#
#= none:25 =# @inline δxTᶠᵃᵃ(i, j, k, grid, f::Function, args...) = begin
            #= none:25 =#
            δxᶠᵃᵃ(i, j, k, grid, f, args...)
        end
#= none:26 =#
#= none:26 =# @inline δyTᵃᶠᵃ(i, j, k, grid, f::Function, args...) = begin
            #= none:26 =#
            δyᵃᶠᵃ(i, j, k, grid, f, args...)
        end
#= none:27 =#
#= none:27 =# @inline δxTᶜᵃᵃ(i, j, k, grid, f::Function, args...) = begin
            #= none:27 =#
            δxᶜᵃᵃ(i, j, k, grid, f, args...)
        end
#= none:28 =#
#= none:28 =# @inline δyTᵃᶜᵃ(i, j, k, grid, f::Function, args...) = begin
            #= none:28 =#
            δyᵃᶜᵃ(i, j, k, grid, f, args...)
        end
#= none:32 =#
#= none:32 =# @inline δxTᶠᵃᵃ(i, j, k, grid::AGXP, f::Function, args...) = begin
            #= none:32 =#
            ifelse(i == 1, f(1, j, k, grid, args...) - f(grid.Nx, j, k, grid, args...), δxᶠᵃᵃ(i, j, k, grid, f, args...))
        end
#= none:33 =#
#= none:33 =# @inline δyTᵃᶠᵃ(i, j, k, grid::AGYP, f::Function, args...) = begin
            #= none:33 =#
            ifelse(j == 1, f(i, 1, k, grid, args...) - f(i, grid.Ny, k, grid, args...), δyᵃᶠᵃ(i, j, k, grid, f, args...))
        end
#= none:35 =#
#= none:35 =# @inline δxTᶜᵃᵃ(i, j, k, grid::AGXP, f::Function, args...) = begin
            #= none:35 =#
            ifelse(i == grid.Nx, f(1, j, k, grid, args...) - f(grid.Nx, j, k, grid, args...), δxᶜᵃᵃ(i, j, k, grid, f, args...))
        end
#= none:36 =#
#= none:36 =# @inline δyTᵃᶜᵃ(i, j, k, grid::AGYP, f::Function, args...) = begin
            #= none:36 =#
            ifelse(j == grid.Ny, f(i, 1, k, grid, args...) - f(i, grid.Ny, k, grid, args...), δyᵃᶜᵃ(i, j, k, grid, f, args...))
        end
#= none:40 =#
#= none:40 =# @inline (δxTᶠᵃᵃ(i, j, k, grid::AGXB{FT}, f::Function, args...) where FT) = begin
            #= none:40 =#
            ifelse(i == 1, zero(FT), δxᶠᵃᵃ(i, j, k, grid, f, args...))
        end
#= none:41 =#
#= none:41 =# @inline (δyTᵃᶠᵃ(i, j, k, grid::AGYB{FT}, f::Function, args...) where FT) = begin
            #= none:41 =#
            ifelse(j == 1, zero(FT), δyᵃᶠᵃ(i, j, k, grid, f, args...))
        end
#= none:43 =#
#= none:43 =# @inline (δxTᶠᵃᵃ(i, j, k, grid::AGXR{FT}, f::Function, args...) where FT) = begin
            #= none:43 =#
            ifelse(i == 1, zero(FT), δxᶠᵃᵃ(i, j, k, grid, f, args...))
        end
#= none:44 =#
#= none:44 =# @inline (δyTᵃᶠᵃ(i, j, k, grid::AGYR{FT}, f::Function, args...) where FT) = begin
            #= none:44 =#
            ifelse(j == 1, zero(FT), δyᵃᶠᵃ(i, j, k, grid, f, args...))
        end
#= none:48 =#
#= none:48 =# @inline δxTᶜᵃᵃ(i, j, k, grid::AGXB, f::Function, args...) = begin
            #= none:48 =#
            ifelse(i == grid.Nx, -(f(i, j, k, grid, args...)), ifelse(i == 1, f(2, j, k, grid, args...), δxᶜᵃᵃ(i, j, k, grid, f, args...)))
        end
#= none:53 =#
#= none:53 =# @inline δyTᵃᶜᵃ(i, j, k, grid::AGYB, f::Function, args...) = begin
            #= none:53 =#
            ifelse(j == grid.Ny, -(f(i, j, k, grid, args...)), ifelse(j == 1, f(i, 2, k, grid, args...), δyᵃᶜᵃ(i, j, k, grid, f, args...)))
        end
#= none:58 =#
#= none:58 =# @inline δxTᶜᵃᵃ(i, j, k, grid::AGXL, f::Function, args...) = begin
            #= none:58 =#
            ifelse(i == grid.Nx, -(f(i, j, k, grid, args...)), δxᶜᵃᵃ(i, j, k, grid, f, args...))
        end
#= none:59 =#
#= none:59 =# @inline δyTᵃᶜᵃ(i, j, k, grid::AGYL, f::Function, args...) = begin
            #= none:59 =#
            ifelse(j == grid.Ny, -(f(i, j, k, grid, args...)), δyᵃᶜᵃ(i, j, k, grid, f, args...))
        end
#= none:61 =#
#= none:61 =# @inline δxTᶜᵃᵃ(i, j, k, grid::AGXR, f::Function, args...) = begin
            #= none:61 =#
            ifelse(i == 1, f(2, j, k, grid, args...), δxᶜᵃᵃ(i, j, k, grid, f, args...))
        end
#= none:62 =#
#= none:62 =# @inline δyTᵃᶜᵃ(i, j, k, grid::AGYR, f::Function, args...) = begin
            #= none:62 =#
            ifelse(j == 1, f(i, 2, k, grid, args...), δyᵃᶜᵃ(i, j, k, grid, f, args...))
        end
#= none:66 =#
#= none:66 =# @inline ∂xTᶠᶜᶠ(i, j, k, grid, f::Function, args...) = begin
            #= none:66 =#
            δxTᶠᵃᵃ(i, j, k, grid, f, args...) / Δxᶠᶜᶠ(i, j, k, grid)
        end
#= none:67 =#
#= none:67 =# @inline ∂yTᶜᶠᶠ(i, j, k, grid, f::Function, args...) = begin
            #= none:67 =#
            δyTᵃᶠᵃ(i, j, k, grid, f, args...) / Δyᶜᶠᶠ(i, j, k, grid)
        end