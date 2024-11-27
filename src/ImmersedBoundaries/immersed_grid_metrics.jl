
#= none:1 =#
using Oceananigans.AbstractOperations: GridMetricOperation
#= none:3 =#
import Oceananigans.Grids: coordinates
#= none:5 =#
const c = Center()
#= none:6 =#
const f = Face()
#= none:7 =#
const IBG = ImmersedBoundaryGrid
#= none:16 =#
for LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ), LZ = (:ᶜ, :ᶠ)
    #= none:17 =#
    for dir = (:x, :y, :z), operator = (:Δ, :A)
        #= none:19 =#
        metric = Symbol(operator, dir, LX, LY, LZ)
        #= none:20 =#
        #= none:20 =# @eval begin
                #= none:21 =#
                import Oceananigans.Operators: $metric
                #= none:22 =#
                #= none:22 =# @inline $metric(i, j, k, ibg::IBG) = begin
                            #= none:22 =#
                            $metric(i, j, k, ibg.underlying_grid)
                        end
            end
        #= none:24 =#
    end
    #= none:26 =#
    volume = Symbol(:V, LX, LY, LZ)
    #= none:27 =#
    #= none:27 =# @eval begin
            #= none:28 =#
            import Oceananigans.Operators: $volume
            #= none:29 =#
            #= none:29 =# @inline $volume(i, j, k, ibg::IBG) = begin
                        #= none:29 =#
                        $volume(i, j, k, ibg.underlying_grid)
                    end
        end
    #= none:31 =#
end
#= none:33 =#
#= none:33 =# @inline Δzᵃᵃᶜ(i, j, k, ibg::IBG) = begin
            #= none:33 =#
            Δzᵃᵃᶜ(i, j, k, ibg.underlying_grid)
        end
#= none:34 =#
#= none:34 =# @inline Δzᵃᵃᶠ(i, j, k, ibg::IBG) = begin
            #= none:34 =#
            Δzᵃᵃᶠ(i, j, k, ibg.underlying_grid)
        end
#= none:36 =#
coordinates(grid::IBG) = begin
        #= none:36 =#
        coordinates(grid.underlying_grid)
    end
#= none:37 =#
xspacings(X, grid::IBG) = begin
        #= none:37 =#
        xspacings(X, grid.underlying_grid)
    end
#= none:38 =#
yspacings(Y, grid::IBG) = begin
        #= none:38 =#
        yspacings(Y, grid.underlying_grid)
    end
#= none:39 =#
zspacings(Z, grid::IBG) = begin
        #= none:39 =#
        zspacings(Z, grid.underlying_grid)
    end