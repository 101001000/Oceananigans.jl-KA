
#= none:1 =#
using Oceananigans.Grids: AbstractGrid
#= none:3 =#
abstract type AbstractTimeDiscretization end
#= none:5 =#
#= none:5 =# Core.@doc "    struct ExplicitTimeDiscretization <: AbstractTimeDiscretization\n\nA fully-explicit time-discretization of a `TurbulenceClosure`.\n" struct ExplicitTimeDiscretization <: AbstractTimeDiscretization
        #= none:10 =#
    end
#= none:12 =#
Base.summary(::ExplicitTimeDiscretization) = begin
        #= none:12 =#
        "ExplicitTimeDiscretization"
    end
#= none:14 =#
#= none:14 =# Core.@doc "    struct VerticallyImplicitTimeDiscretization <: AbstractTimeDiscretization\n\nA vertically-implicit time-discretization of a `TurbulenceClosure`.\n\nThis implies that a flux divergence such as ``𝛁 ⋅ 𝐪`` at the ``n``-th timestep is \ntime-discretized as\n\n```julia\n[∇ ⋅ q]ⁿ = [explicit_flux_divergence]ⁿ + [∂z (κ ∂z c)]ⁿ⁺¹\n```\n" struct VerticallyImplicitTimeDiscretization <: AbstractTimeDiscretization
        #= none:26 =#
    end
#= none:28 =#
Base.summary(::VerticallyImplicitTimeDiscretization) = begin
        #= none:28 =#
        "VerticallyImplicitTimeDiscretization"
    end
#= none:30 =#
#= none:30 =# @inline (time_discretization(::AbstractTurbulenceClosure{TimeDiscretization}) where TimeDiscretization) = begin
            #= none:30 =#
            TimeDiscretization()
        end
#= none:31 =#
#= none:31 =# @inline time_discretization(::Nothing) = begin
            #= none:31 =#
            ExplicitTimeDiscretization()
        end
#= none:37 =#
const ATD = AbstractTimeDiscretization
#= none:39 =#
#= none:39 =# @inline diffusive_flux_x(i, j, k, grid, ::ATD, args...) = begin
            #= none:39 =#
            diffusive_flux_x(i, j, k, grid, args...)
        end
#= none:40 =#
#= none:40 =# @inline diffusive_flux_y(i, j, k, grid, ::ATD, args...) = begin
            #= none:40 =#
            diffusive_flux_y(i, j, k, grid, args...)
        end
#= none:41 =#
#= none:41 =# @inline diffusive_flux_z(i, j, k, grid, ::ATD, args...) = begin
            #= none:41 =#
            diffusive_flux_z(i, j, k, grid, args...)
        end
#= none:43 =#
#= none:43 =# @inline viscous_flux_ux(i, j, k, grid, ::ATD, args...) = begin
            #= none:43 =#
            viscous_flux_ux(i, j, k, grid, args...)
        end
#= none:44 =#
#= none:44 =# @inline viscous_flux_uy(i, j, k, grid, ::ATD, args...) = begin
            #= none:44 =#
            viscous_flux_uy(i, j, k, grid, args...)
        end
#= none:45 =#
#= none:45 =# @inline viscous_flux_uz(i, j, k, grid, ::ATD, args...) = begin
            #= none:45 =#
            viscous_flux_uz(i, j, k, grid, args...)
        end
#= none:47 =#
#= none:47 =# @inline viscous_flux_vx(i, j, k, grid, ::ATD, args...) = begin
            #= none:47 =#
            viscous_flux_vx(i, j, k, grid, args...)
        end
#= none:48 =#
#= none:48 =# @inline viscous_flux_vy(i, j, k, grid, ::ATD, args...) = begin
            #= none:48 =#
            viscous_flux_vy(i, j, k, grid, args...)
        end
#= none:49 =#
#= none:49 =# @inline viscous_flux_vz(i, j, k, grid, ::ATD, args...) = begin
            #= none:49 =#
            viscous_flux_vz(i, j, k, grid, args...)
        end
#= none:51 =#
#= none:51 =# @inline viscous_flux_wx(i, j, k, grid, ::ATD, args...) = begin
            #= none:51 =#
            viscous_flux_wx(i, j, k, grid, args...)
        end
#= none:52 =#
#= none:52 =# @inline viscous_flux_wy(i, j, k, grid, ::ATD, args...) = begin
            #= none:52 =#
            viscous_flux_wy(i, j, k, grid, args...)
        end
#= none:53 =#
#= none:53 =# @inline viscous_flux_wz(i, j, k, grid, ::ATD, args...) = begin
            #= none:53 =#
            viscous_flux_wz(i, j, k, grid, args...)
        end