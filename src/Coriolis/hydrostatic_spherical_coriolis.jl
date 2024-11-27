
#= none:1 =#
using Oceananigans.Grids: LatitudeLongitudeGrid, OrthogonalSphericalShellGrid, peripheral_node, φnode
#= none:2 =#
using Oceananigans.Operators: Δx_qᶜᶠᶜ, Δy_qᶠᶜᶜ, Δxᶠᶜᶜ, Δyᶜᶠᶜ, hack_sind
#= none:3 =#
using Oceananigans.Advection: EnergyConserving, EnstrophyConserving
#= none:4 =#
using Oceananigans.BoundaryConditions
#= none:5 =#
using Oceananigans.Fields
#= none:6 =#
using Oceananigans.AbstractOperations: KernelFunctionOperation
#= none:7 =#
using Oceananigans.ImmersedBoundaries
#= none:9 =#
#= none:9 =# Core.@doc "    struct ActiveCellEnstrophyConserving\n\nA parameter object for an enstrophy-conserving Coriolis scheme that excludes inactive (dry/land) edges\n(indices for which `peripheral_node == true`) from the velocity interpolation.\n" struct ActiveCellEnstrophyConserving
        #= none:15 =#
    end
#= none:17 =#
#= none:17 =# Core.@doc "    struct HydrostaticSphericalCoriolis{S, FT} <: AbstractRotation\n\nA parameter object for constant rotation around a vertical axis on the sphere.\n" struct HydrostaticSphericalCoriolis{S, FT} <: AbstractRotation
        #= none:23 =#
        rotation_rate::FT
        #= none:24 =#
        scheme::S
    end
#= none:27 =#
#= none:27 =# Core.@doc "    HydrostaticSphericalCoriolis([FT=Float64;]\n                                 rotation_rate = Ω_Earth,\n                                 scheme = ActiveCellEnstrophyConserving())\n\nReturn a parameter object for Coriolis forces on a sphere rotating at `rotation_rate`.\n\nKeyword arguments\n=================\n\n- `rotation_rate`: Sphere's rotation rate; default: [`Ω_Earth`](@ref).\n- `scheme`: Either `EnergyConserving()`, `EnstrophyConserving()`, or `ActiveCellEnstrophyConserving()` (default).\n" function HydrostaticSphericalCoriolis(FT::DataType = Float64; rotation_rate = Ω_Earth, scheme::S = ActiveCellEnstrophyConserving()) where S
        #= none:40 =#
        #= none:44 =#
        return HydrostaticSphericalCoriolis{S, FT}(rotation_rate, scheme)
    end
#= none:47 =#
Adapt.adapt_structure(to, coriolis::HydrostaticSphericalCoriolis) = begin
        #= none:47 =#
        HydrostaticSphericalCoriolis(Adapt.adapt(to, coriolis.rotation_rate), Adapt.adapt(to, coriolis.scheme))
    end
#= none:51 =#
#= none:51 =# @inline φᶠᶠᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:51 =#
            φnode(j, grid, Face())
        end
#= none:52 =#
#= none:52 =# @inline φᶠᶠᵃ(i, j, k, grid::OrthogonalSphericalShellGrid) = begin
            #= none:52 =#
            φnode(i, j, grid, Face(), Face())
        end
#= none:53 =#
#= none:53 =# @inline φᶠᶠᵃ(i, j, k, grid::ImmersedBoundaryGrid) = begin
            #= none:53 =#
            φᶠᶠᵃ(i, j, k, grid.underlying_grid)
        end
#= none:55 =#
#= none:55 =# @inline fᶠᶠᵃ(i, j, k, grid, coriolis::HydrostaticSphericalCoriolis) = begin
            #= none:55 =#
            2 * coriolis.rotation_rate * hack_sind(φᶠᶠᵃ(i, j, k, grid))
        end
#= none:58 =#
#= none:58 =# @inline z_f_cross_U(i, j, k, grid, coriolis::HydrostaticSphericalCoriolis, U) = begin
            #= none:58 =#
            zero(grid)
        end
#= none:68 =#
const CoriolisActiveCellEnstrophyConserving = HydrostaticSphericalCoriolis{<:ActiveCellEnstrophyConserving}
#= none:70 =#
#= none:70 =# @inline not_peripheral_node(args...) = begin
            #= none:70 =#
            !(peripheral_node(args...))
        end
#= none:72 =#
#= none:72 =# @inline function mask_inactive_points_ℑxyᶠᶜᵃ(i, j, k, grid, f::Function, args...)
        #= none:72 =#
        #= none:73 =#
        neighboring_active_nodes = ℑxyᶠᶜᵃ(i, j, k, grid, not_peripheral_node, Center(), Face(), Center())
        #= none:74 =#
        return ifelse(neighboring_active_nodes == 0, zero(grid), ℑxyᶠᶜᵃ(i, j, k, grid, f, args...) / neighboring_active_nodes)
    end
#= none:78 =#
#= none:78 =# @inline function mask_inactive_points_ℑxyᶜᶠᵃ(i, j, k, grid, f::Function, args...)
        #= none:78 =#
        #= none:79 =#
        neighboring_active_nodes = #= none:79 =# @inbounds(ℑxyᶜᶠᵃ(i, j, k, grid, not_peripheral_node, Face(), Center(), Center()))
        #= none:80 =#
        return ifelse(neighboring_active_nodes == 0, zero(grid), ℑxyᶜᶠᵃ(i, j, k, grid, f, args...) / neighboring_active_nodes)
    end
#= none:84 =#
#= none:84 =# @inline x_f_cross_U(i, j, k, grid, coriolis::CoriolisActiveCellEnstrophyConserving, U) = begin
            #= none:84 =#
            #= none:85 =# @inbounds (-(ℑyᵃᶜᵃ(i, j, k, grid, fᶠᶠᵃ, coriolis)) * mask_inactive_points_ℑxyᶠᶜᵃ(i, j, k, grid, Δx_qᶜᶠᶜ, U[2])) / Δxᶠᶜᶜ(i, j, k, grid)
        end
#= none:88 =#
#= none:88 =# @inline y_f_cross_U(i, j, k, grid, coriolis::CoriolisActiveCellEnstrophyConserving, U) = begin
            #= none:88 =#
            #= none:89 =# @inbounds (+(ℑxᶜᵃᵃ(i, j, k, grid, fᶠᶠᵃ, coriolis)) * mask_inactive_points_ℑxyᶜᶠᵃ(i, j, k, grid, Δy_qᶠᶜᶜ, U[1])) / Δyᶜᶠᶜ(i, j, k, grid)
        end
#= none:96 =#
const CoriolisEnstrophyConserving = HydrostaticSphericalCoriolis{<:EnstrophyConserving}
#= none:98 =#
#= none:98 =# @inline x_f_cross_U(i, j, k, grid, coriolis::CoriolisEnstrophyConserving, U) = begin
            #= none:98 =#
            #= none:99 =# @inbounds (-(ℑyᵃᶜᵃ(i, j, k, grid, fᶠᶠᵃ, coriolis)) * ℑxᶠᵃᵃ(i, j, k, grid, ℑyᵃᶜᵃ, Δx_qᶜᶠᶜ, U[2])) / Δxᶠᶜᶜ(i, j, k, grid)
        end
#= none:102 =#
#= none:102 =# @inline y_f_cross_U(i, j, k, grid, coriolis::CoriolisEnstrophyConserving, U) = begin
            #= none:102 =#
            #= none:103 =# @inbounds (+(ℑxᶜᵃᵃ(i, j, k, grid, fᶠᶠᵃ, coriolis)) * ℑyᵃᶠᵃ(i, j, k, grid, ℑxᶜᵃᵃ, Δy_qᶠᶜᶜ, U[1])) / Δyᶜᶠᶜ(i, j, k, grid)
        end
#= none:110 =#
const CoriolisEnergyConserving = HydrostaticSphericalCoriolis{<:EnergyConserving}
#= none:112 =#
#= none:112 =# @inline f_ℑx_vᶠᶠᵃ(i, j, k, grid, coriolis, v) = begin
            #= none:112 =#
            fᶠᶠᵃ(i, j, k, grid, coriolis) * ℑxᶠᵃᵃ(i, j, k, grid, Δx_qᶜᶠᶜ, v)
        end
#= none:113 =#
#= none:113 =# @inline f_ℑy_uᶠᶠᵃ(i, j, k, grid, coriolis, u) = begin
            #= none:113 =#
            fᶠᶠᵃ(i, j, k, grid, coriolis) * ℑyᵃᶠᵃ(i, j, k, grid, Δy_qᶠᶜᶜ, u)
        end
#= none:115 =#
#= none:115 =# @inline x_f_cross_U(i, j, k, grid, coriolis::CoriolisEnergyConserving, U) = begin
            #= none:115 =#
            #= none:116 =# @inbounds -(ℑyᵃᶜᵃ(i, j, k, grid, f_ℑx_vᶠᶠᵃ, coriolis, U[2])) / Δxᶠᶜᶜ(i, j, k, grid)
        end
#= none:118 =#
#= none:118 =# @inline y_f_cross_U(i, j, k, grid, coriolis::CoriolisEnergyConserving, U) = begin
            #= none:118 =#
            #= none:119 =# @inbounds +(ℑxᶜᵃᵃ(i, j, k, grid, f_ℑy_uᶠᶠᵃ, coriolis, U[1])) / Δyᶜᶠᶜ(i, j, k, grid)
        end
#= none:125 =#
function Base.show(io::IO, hydrostatic_spherical_coriolis::HydrostaticSphericalCoriolis)
    #= none:125 =#
    #= none:126 =#
    coriolis_scheme = hydrostatic_spherical_coriolis.scheme
    #= none:127 =#
    rotation_rate = hydrostatic_spherical_coriolis.rotation_rate
    #= none:128 =#
    rotation_rate_Earth = rotation_rate / Ω_Earth
    #= none:129 =#
    rotation_rate_str = #= none:129 =# @sprintf("%.2e s⁻¹ = %.2e Ω_Earth", rotation_rate, rotation_rate_Earth)
    #= none:131 =#
    return print(io, "HydrostaticSphericalCoriolis", '\n', "├─ rotation rate: ", rotation_rate_str, '\n', "└─ scheme: ", summary(coriolis_scheme))
end