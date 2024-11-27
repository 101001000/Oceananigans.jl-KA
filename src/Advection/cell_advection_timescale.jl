
#= none:1 =#
using Oceananigans.AbstractOperations: KernelFunctionOperation
#= none:3 =#
#= none:3 =# Core.@doc "    cell_advection_timescale(grid, velocities)\n\nReturn the advection timescale for `grid` with `velocities`. The advection timescale\nis the minimum over all `i, j, k` in the `grid` of\n\n```\n  1 / (|u(i, j, k)| / Δxᶠᶜᶜ(i, j, k) + |v(i, j, k)| / Δyᶜᶠᶜ(i, j, k) + |w(i, j, k)| / Δzᶜᶜᶠ(i, j, k))\n```\n" function cell_advection_timescale(grid, velocities)
        #= none:13 =#
        #= none:14 =#
        (u, v, w) = velocities
        #= none:15 =#
        τ = KernelFunctionOperation{Center, Center, Center}(cell_advection_timescaleᶜᶜᶜ, grid, u, v, w)
        #= none:16 =#
        return minimum(τ)
    end
#= none:19 =#
#= none:19 =# @inline _inverse_timescale(i, j, k, Δ, U, topo) = begin
            #= none:19 =#
            #= none:19 =# @inbounds abs(U[i, j, k]) / Δ
        end
#= none:20 =#
#= none:20 =# @inline _inverse_timescale(i, j, k, Δ, U, topo::Flat) = begin
            #= none:20 =#
            0
        end
#= none:22 =#
#= none:22 =# @inline function cell_advection_timescaleᶜᶜᶜ(i, j, k, grid::AbstractGrid{FT, TX, TY, TZ}, u, v, w) where {FT, TX, TY, TZ}
        #= none:22 =#
        #= none:23 =#
        Δx = Δxᶠᶜᶜ(i, j, k, grid)
        #= none:24 =#
        Δy = Δyᶜᶠᶜ(i, j, k, grid)
        #= none:25 =#
        Δz = Δzᶜᶜᶠ(i, j, k, grid)
        #= none:27 =#
        inverse_timescale_x = _inverse_timescale(i, j, k, Δx, u, TX())
        #= none:28 =#
        inverse_timescale_y = _inverse_timescale(i, j, k, Δy, v, TY())
        #= none:29 =#
        inverse_timescale_z = _inverse_timescale(i, j, k, Δz, w, TZ())
        #= none:31 =#
        inverse_timescale = inverse_timescale_x + inverse_timescale_y + inverse_timescale_z
        #= none:33 =#
        return 1 / inverse_timescale
    end