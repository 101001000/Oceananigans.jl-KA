
#= none:1 =#
"Returns the time-scale for advection on a regular grid across a single grid cell \n for ShallowWaterModel."
#= none:4 =#
import Oceananigans.Advection: cell_advection_timescale
#= none:6 =#
function cell_advection_timescale(model::ShallowWaterModel)
    #= none:6 =#
    #= none:7 =#
    (u, v, _) = shallow_water_velocities(model)
    #= none:8 =#
    τ = KernelFunctionOperation{Center, Center, Nothing}(shallow_water_cell_advection_timescaleᶜᶜᵃ, model.grid, u, v)
    #= none:9 =#
    return minimum(τ)
end
#= none:12 =#
#= none:12 =# @inline function shallow_water_cell_advection_timescaleᶜᶜᵃ(i, j, k, grid, u, v)
        #= none:12 =#
        #= none:13 =#
        Δx = Δxᶠᶜᶜ(i, j, k, grid)
        #= none:14 =#
        Δy = Δyᶜᶠᶜ(i, j, k, grid)
        #= none:15 =#
        return #= none:15 =# @inbounds(min(Δx / abs(u[i, j, k]), Δy / abs(v[i, j, k])))
    end