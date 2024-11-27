
#= none:1 =#
using Oceananigans.Operators: Δy_qᶠᶜᶜ, Δx_qᶜᶠᶜ, Δx_qᶠᶜᶜ
#= none:4 =#
#= none:4 =# @inline _viscous_flux_ux(args...) = begin
            #= none:4 =#
            viscous_flux_ux(args...)
        end
#= none:5 =#
#= none:5 =# @inline _viscous_flux_uy(args...) = begin
            #= none:5 =#
            viscous_flux_uy(args...)
        end
#= none:6 =#
#= none:6 =# @inline _viscous_flux_uz(args...) = begin
            #= none:6 =#
            viscous_flux_uz(args...)
        end
#= none:7 =#
#= none:7 =# @inline _viscous_flux_vx(args...) = begin
            #= none:7 =#
            viscous_flux_vx(args...)
        end
#= none:8 =#
#= none:8 =# @inline _viscous_flux_vy(args...) = begin
            #= none:8 =#
            viscous_flux_vy(args...)
        end
#= none:9 =#
#= none:9 =# @inline _viscous_flux_vz(args...) = begin
            #= none:9 =#
            viscous_flux_vz(args...)
        end
#= none:10 =#
#= none:10 =# @inline _viscous_flux_wx(args...) = begin
            #= none:10 =#
            viscous_flux_wx(args...)
        end
#= none:11 =#
#= none:11 =# @inline _viscous_flux_wy(args...) = begin
            #= none:11 =#
            viscous_flux_wy(args...)
        end
#= none:12 =#
#= none:12 =# @inline _viscous_flux_wz(args...) = begin
            #= none:12 =#
            viscous_flux_wz(args...)
        end
#= none:14 =#
#= none:14 =# @inline _diffusive_flux_x(args...) = begin
            #= none:14 =#
            diffusive_flux_x(args...)
        end
#= none:15 =#
#= none:15 =# @inline _diffusive_flux_y(args...) = begin
            #= none:15 =#
            diffusive_flux_y(args...)
        end
#= none:16 =#
#= none:16 =# @inline _diffusive_flux_z(args...) = begin
            #= none:16 =#
            diffusive_flux_z(args...)
        end
#= none:22 =#
#= none:22 =# @inline function ∂ⱼ_τ₁ⱼ(i, j, k, grid, closure::AbstractTurbulenceClosure, args...)
        #= none:22 =#
        #= none:23 =#
        disc = time_discretization(closure)
        #= none:24 =#
        return (1 / Vᶠᶜᶜ(i, j, k, grid)) * (δxᶠᵃᵃ(i, j, k, grid, Ax_qᶜᶜᶜ, _viscous_flux_ux, disc, closure, args...) + δyᵃᶜᵃ(i, j, k, grid, Ay_qᶠᶠᶜ, _viscous_flux_uy, disc, closure, args...) + δzᵃᵃᶜ(i, j, k, grid, Az_qᶠᶜᶠ, _viscous_flux_uz, disc, closure, args...))
    end
#= none:29 =#
#= none:29 =# @inline function ∂ⱼ_τ₂ⱼ(i, j, k, grid, closure::AbstractTurbulenceClosure, args...)
        #= none:29 =#
        #= none:30 =#
        disc = time_discretization(closure)
        #= none:31 =#
        return (1 / Vᶜᶠᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Ax_qᶠᶠᶜ, _viscous_flux_vx, disc, closure, args...) + δyᵃᶠᵃ(i, j, k, grid, Ay_qᶜᶜᶜ, _viscous_flux_vy, disc, closure, args...) + δzᵃᵃᶜ(i, j, k, grid, Az_qᶜᶠᶠ, _viscous_flux_vz, disc, closure, args...))
    end
#= none:36 =#
#= none:36 =# @inline function ∂ⱼ_τ₃ⱼ(i, j, k, grid, closure::AbstractTurbulenceClosure, args...)
        #= none:36 =#
        #= none:37 =#
        disc = time_discretization(closure)
        #= none:38 =#
        return (1 / Vᶜᶜᶠ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Ax_qᶠᶜᶠ, _viscous_flux_wx, disc, closure, args...) + δyᵃᶜᵃ(i, j, k, grid, Ay_qᶜᶠᶠ, _viscous_flux_wy, disc, closure, args...) + δzᵃᵃᶠ(i, j, k, grid, Az_qᶜᶜᶜ, _viscous_flux_wz, disc, closure, args...))
    end
#= none:43 =#
#= none:43 =# @inline function ∇_dot_qᶜ(i, j, k, grid, closure::AbstractTurbulenceClosure, diffusivities, tracer_index, args...)
        #= none:43 =#
        #= none:44 =#
        disc = time_discretization(closure)
        #= none:45 =#
        return (1 / Vᶜᶜᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Ax_qᶠᶜᶜ, _diffusive_flux_x, disc, closure, diffusivities, tracer_index, args...) + δyᵃᶜᵃ(i, j, k, grid, Ay_qᶜᶠᶜ, _diffusive_flux_y, disc, closure, diffusivities, tracer_index, args...) + δzᵃᵃᶜ(i, j, k, grid, Az_qᶜᶜᶠ, _diffusive_flux_z, disc, closure, diffusivities, tracer_index, args...))
    end