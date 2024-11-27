
#= none:1 =#
module TKEBasedVerticalDiffusivities
#= none:1 =#
#= none:3 =#
using Adapt
#= none:4 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:5 =#
using KernelAbstractions: @kernel, @index
#= none:7 =#
using Oceananigans.Architectures
#= none:8 =#
using Oceananigans.Grids
#= none:9 =#
using Oceananigans.Utils
#= none:10 =#
using Oceananigans.Units
#= none:11 =#
using Oceananigans.Fields
#= none:12 =#
using Oceananigans.Operators
#= none:14 =#
using Oceananigans.Utils: prettysummary
#= none:15 =#
using Oceananigans.Grids: peripheral_node, inactive_node, inactive_cell
#= none:16 =#
using Oceananigans.Fields: ZeroField
#= none:17 =#
using Oceananigans.BoundaryConditions: default_prognostic_bc, DefaultBoundaryCondition
#= none:18 =#
using Oceananigans.BoundaryConditions: BoundaryCondition, FieldBoundaryConditions
#= none:19 =#
using Oceananigans.BoundaryConditions: DiscreteBoundaryFunction, FluxBoundaryCondition
#= none:20 =#
using Oceananigans.BuoyancyModels: ∂z_b, top_buoyancy_flux
#= none:21 =#
using Oceananigans.Grids: inactive_cell
#= none:23 =#
using Oceananigans.TurbulenceClosures: getclosure, time_discretization, AbstractScalarDiffusivity, VerticallyImplicitTimeDiscretization, VerticalFormulation
#= none:30 =#
import Oceananigans.BoundaryConditions: getbc
#= none:31 =#
import Oceananigans.Utils: with_tracers
#= none:32 =#
import Oceananigans.TurbulenceClosures: validate_closure, shear_production, buoyancy_flux, dissipation, add_closure_specific_boundary_conditions, compute_diffusivities!, DiffusivityFields, implicit_linear_coefficient, viscosity, diffusivity, viscosity_location, diffusivity_location, diffusive_flux_x, diffusive_flux_y, diffusive_flux_z
#= none:49 =#
const c = Center()
#= none:50 =#
const f = Face()
#= none:51 =#
const VITD = VerticallyImplicitTimeDiscretization
#= none:53 =#
#= none:53 =# @inline ϕ²(i, j, k, grid, ϕ, args...) = begin
            #= none:53 =#
            ϕ(i, j, k, grid, args...) ^ 2
        end
#= none:55 =#
#= none:55 =# @inline function shearᶜᶜᶠ(i, j, k, grid, u, v)
        #= none:55 =#
        #= none:56 =#
        ∂z_u² = ℑxᶜᵃᵃ(i, j, k, grid, ϕ², ∂zᶠᶜᶠ, u)
        #= none:57 =#
        ∂z_v² = ℑyᵃᶜᵃ(i, j, k, grid, ϕ², ∂zᶜᶠᶠ, v)
        #= none:58 =#
        S² = ∂z_u² + ∂z_v²
        #= none:59 =#
        return S²
    end
#= none:62 =#
#= none:62 =# @inline function shearᶜᶜᶜ(i, j, k, grid, u, v)
        #= none:62 =#
        #= none:63 =#
        ∂z_u² = ℑxᶜᵃᵃ(i, j, k, grid, ℑbzᵃᵃᶜ, ϕ², ∂zᶠᶜᶠ, u)
        #= none:64 =#
        ∂z_v² = ℑyᵃᶜᵃ(i, j, k, grid, ℑbzᵃᵃᶜ, ϕ², ∂zᶜᶠᶠ, v)
        #= none:65 =#
        S² = ∂z_u² + ∂z_v²
        #= none:66 =#
        return S²
    end
#= none:69 =#
#= none:69 =# @inline Riᶜᶜᶜ(i, j, k, grid, velocities, tracers, buoyancy) = begin
            #= none:69 =#
            ℑbzᵃᵃᶜ(i, j, k, grid, Riᶜᶜᶠ, velocities, tracers, buoyancy)
        end
#= none:72 =#
#= none:72 =# @inline function Riᶜᶜᶠ(i, j, k, grid, velocities, tracers, buoyancy)
        #= none:72 =#
        #= none:73 =#
        u = velocities.u
        #= none:74 =#
        v = velocities.v
        #= none:75 =#
        S² = shearᶜᶜᶠ(i, j, k, grid, u, v)
        #= none:76 =#
        N² = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:77 =#
        Ri = N² / S²
        #= none:78 =#
        return ifelse(N² == 0, zero(grid), Ri)
    end
#= none:84 =#
#= none:84 =# @inline function ℑbzᵃᵃᶜ(i, j, k, grid, fᵃᵃᶠ, args...)
        #= none:84 =#
        #= none:85 =#
        k⁺ = k + 1
        #= none:86 =#
        k⁻ = k
        #= none:88 =#
        f⁺ = fᵃᵃᶠ(i, j, k⁺, grid, args...)
        #= none:89 =#
        f⁻ = fᵃᵃᶠ(i, j, k⁻, grid, args...)
        #= none:91 =#
        p⁺ = peripheral_node(i, j, k⁺, grid, c, c, f)
        #= none:92 =#
        p⁻ = peripheral_node(i, j, k⁻, grid, c, c, f)
        #= none:94 =#
        f⁺ = ifelse(p⁺, f⁻, f⁺)
        #= none:95 =#
        f⁻ = ifelse(p⁻, f⁺, f⁻)
        #= none:97 =#
        return (f⁺ + f⁻) / 2
    end
#= none:102 =#
#= none:102 =# @inline function buoyancy_fluxᶜᶜᶠ(i, j, k, grid, tracers, buoyancy, diffusivities)
        #= none:102 =#
        #= none:103 =#
        κc = #= none:103 =# @inbounds(diffusivities.κc[i, j, k])
        #= none:104 =#
        N² = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:105 =#
        return -κc * N²
    end
#= none:108 =#
#= none:108 =# @inline explicit_buoyancy_flux(i, j, k, grid, closure, velocities, tracers, buoyancy, diffusivities) = begin
            #= none:108 =#
            ℑbzᵃᵃᶜ(i, j, k, grid, buoyancy_fluxᶜᶜᶠ, tracers, buoyancy, diffusivities)
        end
#= none:112 =#
#= none:112 =# @inline Δz_νₑ_az_bzᶠᶜᶠ(i, j, k, grid, νₑ, a, b) = begin
            #= none:112 =#
            ℑxᶠᵃᵃ(i, j, k, grid, νₑ) * ∂zᶠᶜᶠ(i, j, k, grid, a) * Δzᶠᶜᶠ(i, j, k, grid) * ∂zᶠᶜᶠ(i, j, k, grid, b)
        end
#= none:115 =#
#= none:115 =# @inline Δz_νₑ_az_bzᶜᶠᶠ(i, j, k, grid, νₑ, a, b) = begin
            #= none:115 =#
            ℑyᵃᶠᵃ(i, j, k, grid, νₑ) * ∂zᶜᶠᶠ(i, j, k, grid, a) * Δzᶜᶠᶠ(i, j, k, grid) * ∂zᶜᶠᶠ(i, j, k, grid, b)
        end
#= none:118 =#
#= none:118 =# @inline function shear_production_xᶠᶜᶜ(i, j, k, grid, νₑ, uⁿ, u⁺)
        #= none:118 =#
        #= none:119 =#
        Δz_Pxⁿ = ℑbzᵃᵃᶜ(i, j, k, grid, Δz_νₑ_az_bzᶠᶜᶠ, νₑ, uⁿ, u⁺)
        #= none:120 =#
        Δz_Px⁺ = ℑbzᵃᵃᶜ(i, j, k, grid, Δz_νₑ_az_bzᶠᶜᶠ, νₑ, u⁺, u⁺)
        #= none:121 =#
        return (Δz_Pxⁿ + Δz_Px⁺) / (2 * Δzᶠᶜᶜ(i, j, k, grid))
    end
#= none:124 =#
#= none:124 =# @inline function shear_production_yᶜᶠᶜ(i, j, k, grid, νₑ, vⁿ, v⁺)
        #= none:124 =#
        #= none:125 =#
        Δz_Pyⁿ = ℑbzᵃᵃᶜ(i, j, k, grid, Δz_νₑ_az_bzᶜᶠᶠ, νₑ, vⁿ, v⁺)
        #= none:126 =#
        Δz_Py⁺ = ℑbzᵃᵃᶜ(i, j, k, grid, Δz_νₑ_az_bzᶜᶠᶠ, νₑ, v⁺, v⁺)
        #= none:127 =#
        return (Δz_Pyⁿ + Δz_Py⁺) / (2 * Δzᶜᶠᶜ(i, j, k, grid))
    end
#= none:130 =#
#= none:130 =# @inline function shear_production(i, j, k, grid, νₑ, uⁿ, u⁺, vⁿ, v⁺)
        #= none:130 =#
        #= none:137 =#
        return ℑxᶜᵃᵃ(i, j, k, grid, shear_production_xᶠᶜᶜ, νₑ, uⁿ, u⁺) + ℑyᵃᶜᵃ(i, j, k, grid, shear_production_yᶜᶠᶜ, νₑ, vⁿ, v⁺)
    end
#= none:141 =#
#= none:141 =# @inline function turbulent_velocityᶜᶜᶜ(i, j, k, grid, closure, e)
        #= none:141 =#
        #= none:142 =#
        eᵢ = #= none:142 =# @inbounds(e[i, j, k])
        #= none:143 =#
        eᵐⁱⁿ = closure.minimum_tke
        #= none:144 =#
        return sqrt(max(eᵐⁱⁿ, eᵢ))
    end
#= none:147 =#
#= none:147 =# @inline function mask_diffusivity(i, j, k, grid, κ★)
        #= none:147 =#
        #= none:148 =#
        on_periphery = peripheral_node(i, j, k, grid, c, c, f)
        #= none:149 =#
        within_inactive = inactive_node(i, j, k, grid, c, c, f)
        #= none:150 =#
        nan = convert(eltype(grid), NaN)
        #= none:151 =#
        return ifelse(on_periphery, zero(grid), ifelse(within_inactive, nan, κ★))
    end
#= none:154 =#
#= none:154 =# @inline clip(x) = begin
            #= none:154 =#
            max(zero(x), x)
        end
#= none:156 =#
function get_time_step(closure_array::AbstractArray)
    #= none:156 =#
    #= none:158 =#
    closure = #= none:158 =# CUDA.@allowscalar(closure_array[1, 1])
    #= none:159 =#
    return get_time_step(closure)
end
#= none:162 =#
include("tke_top_boundary_condition.jl")
#= none:164 =#
include("catke_vertical_diffusivity.jl")
#= none:165 =#
include("catke_mixing_length.jl")
#= none:166 =#
include("catke_equation.jl")
#= none:167 =#
include("time_step_catke_equation.jl")
#= none:169 =#
include("tke_dissipation_vertical_diffusivity.jl")
#= none:170 =#
include("tke_dissipation_stability_functions.jl")
#= none:171 =#
include("tke_dissipation_equations.jl")
#= none:173 =#
for S = (:CATKEMixingLength, :CATKEEquation, :StratifiedDisplacementScale, :ConstantStabilityFunctions, :VariableStabilityFunctions)
    #= none:179 =#
    #= none:179 =# @eval #= none:179 =# @inline((convert_eltype(::Type{FT}, s::$S) where FT) = begin
                    #= none:179 =#
                    $S{FT}(; Dict((p => getproperty(s, p) for p = propertynames(s)))...)
                end)
    #= none:182 =#
    #= none:182 =# @eval #= none:182 =# @inline((convert_eltype(::Type{FT}, s::$S{FT}) where FT) = begin
                    #= none:182 =#
                    s
                end)
    #= none:183 =#
end
end