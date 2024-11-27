
#= none:1 =#
using Oceananigans.Grids: peripheral_node
#= none:3 =#
#= none:3 =# Core.@doc "    abstract type AbstractScalarBiharmonicDiffusivity <: AbstractTurbulenceClosure end\n\nAbstract type for closures with scalar biharmonic diffusivities.\n" abstract type AbstractScalarBiharmonicDiffusivity{F, N} <: AbstractTurbulenceClosure{ExplicitTimeDiscretization, N} end
#= none:10 =#
#= none:10 =# @inline (formulation(::AbstractScalarBiharmonicDiffusivity{F}) where F) = begin
            #= none:10 =#
            F()
        end
#= none:12 =#
const ASBD = AbstractScalarBiharmonicDiffusivity
#= none:18 =#
const ccc = (Center(), Center(), Center())
#= none:19 =#
#= none:19 =# @inline νᶜᶜᶜ(i, j, k, grid, closure::ASBD, K, clock, fields) = begin
            #= none:19 =#
            νᶜᶜᶜ(i, j, k, grid, ccc, viscosity(closure, K), clock, fields)
        end
#= none:20 =#
#= none:20 =# @inline νᶠᶠᶜ(i, j, k, grid, closure::ASBD, K, clock, fields) = begin
            #= none:20 =#
            νᶠᶠᶜ(i, j, k, grid, ccc, viscosity(closure, K), clock, fields)
        end
#= none:21 =#
#= none:21 =# @inline νᶠᶜᶠ(i, j, k, grid, closure::ASBD, K, clock, fields) = begin
            #= none:21 =#
            νᶠᶜᶠ(i, j, k, grid, ccc, viscosity(closure, K), clock, fields)
        end
#= none:22 =#
#= none:22 =# @inline νᶜᶠᶠ(i, j, k, grid, closure::ASBD, K, clock, fields) = begin
            #= none:22 =#
            νᶜᶠᶠ(i, j, k, grid, ccc, viscosity(closure, K), clock, fields)
        end
#= none:24 =#
#= none:24 =# @inline κᶠᶜᶜ(i, j, k, grid, closure::ASBD, K, id, clock, fields) = begin
            #= none:24 =#
            κᶠᶜᶜ(i, j, k, grid, ccc, diffusivity(closure, K, id), clock, fields)
        end
#= none:25 =#
#= none:25 =# @inline κᶜᶠᶜ(i, j, k, grid, closure::ASBD, K, id, clock, fields) = begin
            #= none:25 =#
            κᶜᶠᶜ(i, j, k, grid, ccc, diffusivity(closure, K, id), clock, fields)
        end
#= none:26 =#
#= none:26 =# @inline κᶜᶜᶠ(i, j, k, grid, closure::ASBD, K, id, clock, fields) = begin
            #= none:26 =#
            κᶜᶜᶠ(i, j, k, grid, ccc, diffusivity(closure, K, id), clock, fields)
        end
#= none:32 =#
const AIBD = AbstractScalarBiharmonicDiffusivity{<:ThreeDimensionalFormulation}
#= none:33 =#
const AHBD = AbstractScalarBiharmonicDiffusivity{<:HorizontalFormulation}
#= none:34 =#
const ADBD = AbstractScalarBiharmonicDiffusivity{<:HorizontalDivergenceFormulation}
#= none:35 =#
const AVBD = AbstractScalarBiharmonicDiffusivity{<:VerticalFormulation}
#= none:37 =#
#= none:37 =# @inline viscous_flux_ux(i, j, k, grid, closure::AIBD, K, clk, fields, b) = begin
            #= none:37 =#
            +(ν_σᶜᶜᶜ(i, j, k, grid, closure, K, clk, fields, ∂xᶜᶜᶜ, biharmonic_mask_x, ∇²ᶠᶜᶜ, fields.u))
        end
#= none:38 =#
#= none:38 =# @inline viscous_flux_vx(i, j, k, grid, closure::AIBD, K, clk, fields, b) = begin
            #= none:38 =#
            +(ν_σᶠᶠᶜ(i, j, k, grid, closure, K, clk, fields, biharmonic_mask_x, ∂xᶠᶠᶜ, ∇²ᶜᶠᶜ, fields.v))
        end
#= none:39 =#
#= none:39 =# @inline viscous_flux_wx(i, j, k, grid, closure::AIBD, K, clk, fields, b) = begin
            #= none:39 =#
            +(ν_σᶠᶜᶠ(i, j, k, grid, closure, K, clk, fields, biharmonic_mask_x, ∂xᶠᶜᶠ, ∇²ᶜᶜᶠ, fields.w))
        end
#= none:40 =#
#= none:40 =# @inline viscous_flux_uy(i, j, k, grid, closure::AIBD, K, clk, fields, b) = begin
            #= none:40 =#
            +(ν_σᶠᶠᶜ(i, j, k, grid, closure, K, clk, fields, biharmonic_mask_y, ∂yᶠᶠᶜ, ∇²ᶠᶜᶜ, fields.u))
        end
#= none:41 =#
#= none:41 =# @inline viscous_flux_vy(i, j, k, grid, closure::AIBD, K, clk, fields, b) = begin
            #= none:41 =#
            +(ν_σᶜᶜᶜ(i, j, k, grid, closure, K, clk, fields, ∂yᶜᶜᶜ, biharmonic_mask_y, ∇²ᶜᶠᶜ, fields.v))
        end
#= none:42 =#
#= none:42 =# @inline viscous_flux_wy(i, j, k, grid, closure::AIBD, K, clk, fields, b) = begin
            #= none:42 =#
            +(ν_σᶜᶠᶠ(i, j, k, grid, closure, K, clk, fields, biharmonic_mask_y, ∂yᶜᶠᶠ, ∇²ᶜᶜᶠ, fields.w))
        end
#= none:43 =#
#= none:43 =# @inline viscous_flux_uz(i, j, k, grid, closure::AIBD, K, clk, fields, b) = begin
            #= none:43 =#
            +(ν_σᶠᶜᶠ(i, j, k, grid, closure, K, clk, fields, biharmonic_mask_z, ∂zᶠᶜᶠ, ∇²ᶠᶜᶜ, fields.u))
        end
#= none:44 =#
#= none:44 =# @inline viscous_flux_vz(i, j, k, grid, closure::AIBD, K, clk, fields, b) = begin
            #= none:44 =#
            +(ν_σᶜᶠᶠ(i, j, k, grid, closure, K, clk, fields, biharmonic_mask_z, ∂zᶜᶠᶠ, ∇²ᶜᶠᶜ, fields.v))
        end
#= none:45 =#
#= none:45 =# @inline viscous_flux_wz(i, j, k, grid, closure::AIBD, K, clk, fields, b) = begin
            #= none:45 =#
            +(ν_σᶜᶜᶜ(i, j, k, grid, closure, K, clk, fields, ∂zᶜᶜᶜ, biharmonic_mask_z, ∇²ᶜᶜᶠ, fields.w))
        end
#= none:46 =#
#= none:46 =# @inline viscous_flux_ux(i, j, k, grid, closure::AHBD, K, clk, fields, b) = begin
            #= none:46 =#
            +(ν_σᶜᶜᶜ(i, j, k, grid, closure, K, clk, fields, δ★ᶜᶜᶜ, fields.u, fields.v))
        end
#= none:47 =#
#= none:47 =# @inline viscous_flux_vx(i, j, k, grid, closure::AHBD, K, clk, fields, b) = begin
            #= none:47 =#
            +(ν_σᶠᶠᶜ(i, j, k, grid, closure, K, clk, fields, ζ★ᶠᶠᶜ, fields.u, fields.v))
        end
#= none:48 =#
#= none:48 =# @inline viscous_flux_wx(i, j, k, grid, closure::AHBD, K, clk, fields, b) = begin
            #= none:48 =#
            +(ν_σᶠᶜᶠ(i, j, k, grid, closure, K, clk, fields, biharmonic_mask_x, ∂xᶠᶜᶠ, ∇²ᶜᶜᶠ, fields.w))
        end
#= none:49 =#
#= none:49 =# @inline viscous_flux_uy(i, j, k, grid, closure::AHBD, K, clk, fields, b) = begin
            #= none:49 =#
            -(ν_σᶠᶠᶜ(i, j, k, grid, closure, K, clk, fields, ζ★ᶠᶠᶜ, fields.u, fields.v))
        end
#= none:50 =#
#= none:50 =# @inline viscous_flux_vy(i, j, k, grid, closure::AHBD, K, clk, fields, b) = begin
            #= none:50 =#
            +(ν_σᶜᶜᶜ(i, j, k, grid, closure, K, clk, fields, δ★ᶜᶜᶜ, fields.u, fields.v))
        end
#= none:51 =#
#= none:51 =# @inline viscous_flux_wy(i, j, k, grid, closure::AHBD, K, clk, fields, b) = begin
            #= none:51 =#
            +(ν_σᶜᶠᶠ(i, j, k, grid, closure, K, clk, fields, biharmonic_mask_y, ∂yᶜᶠᶠ, ∇²ᶜᶜᶠ, fields.w))
        end
#= none:52 =#
#= none:52 =# @inline viscous_flux_uz(i, j, k, grid, closure::AVBD, K, clk, fields, b) = begin
            #= none:52 =#
            +(ν_σᶠᶜᶠ(i, j, k, grid, closure, K, clk, fields, biharmonic_mask_z, ∂zᶠᶜᶠ, ∂²zᶠᶜᶜ, fields.u))
        end
#= none:53 =#
#= none:53 =# @inline viscous_flux_vz(i, j, k, grid, closure::AVBD, K, clk, fields, b) = begin
            #= none:53 =#
            +(ν_σᶜᶠᶠ(i, j, k, grid, closure, K, clk, fields, biharmonic_mask_z, ∂zᶜᶠᶠ, ∂²zᶜᶠᶜ, fields.v))
        end
#= none:54 =#
#= none:54 =# @inline viscous_flux_wz(i, j, k, grid, closure::AVBD, K, clk, fields, b) = begin
            #= none:54 =#
            +(ν_σᶜᶜᶜ(i, j, k, grid, closure, K, clk, fields, ∂zᶜᶜᶜ, biharmonic_mask_z, ∂²zᶜᶜᶠ, fields.w))
        end
#= none:56 =#
#= none:56 =# @inline viscous_flux_ux(i, j, k, grid, closure::ADBD, K, clk, fields, b) = begin
            #= none:56 =#
            +(ν_σᶜᶜᶜ(i, j, k, grid, closure, K, clk, fields, δ★ᶜᶜᶜ, fields.u, fields.v))
        end
#= none:57 =#
#= none:57 =# @inline viscous_flux_vy(i, j, k, grid, closure::ADBD, K, clk, fields, b) = begin
            #= none:57 =#
            +(ν_σᶜᶜᶜ(i, j, k, grid, closure, K, clk, fields, δ★ᶜᶜᶜ, fields.u, fields.v))
        end
#= none:63 =#
#= none:63 =# @inline (diffusive_flux_x(i, j, k, grid, clo::AIBD, K, ::Val{id}, c, clk, fields, b) where id) = begin
            #= none:63 =#
            κ_σᶠᶜᶜ(i, j, k, grid, clo, K, Val(id), clk, fields, biharmonic_mask_x, ∂xᶠᶜᶜ, ∇²ᶜᶜᶜ, c)
        end
#= none:64 =#
#= none:64 =# @inline (diffusive_flux_y(i, j, k, grid, clo::AIBD, K, ::Val{id}, c, clk, fields, b) where id) = begin
            #= none:64 =#
            κ_σᶜᶠᶜ(i, j, k, grid, clo, K, Val(id), clk, fields, biharmonic_mask_y, ∂yᶜᶠᶜ, ∇²ᶜᶜᶜ, c)
        end
#= none:65 =#
#= none:65 =# @inline (diffusive_flux_z(i, j, k, grid, clo::AIBD, K, ::Val{id}, c, clk, fields, b) where id) = begin
            #= none:65 =#
            κ_σᶜᶜᶠ(i, j, k, grid, clo, K, Val(id), clk, fields, biharmonic_mask_z, ∂zᶜᶜᶠ, ∇²ᶜᶜᶜ, c)
        end
#= none:66 =#
#= none:66 =# @inline (diffusive_flux_x(i, j, k, grid, clo::AHBD, K, ::Val{id}, c, clk, fields, b) where id) = begin
            #= none:66 =#
            κ_σᶠᶜᶜ(i, j, k, grid, clo, K, Val(id), clk, fields, biharmonic_mask_x, ∂x_∇²h_cᶠᶜᶜ, c)
        end
#= none:67 =#
#= none:67 =# @inline (diffusive_flux_y(i, j, k, grid, clo::AHBD, K, ::Val{id}, c, clk, fields, b) where id) = begin
            #= none:67 =#
            κ_σᶜᶠᶜ(i, j, k, grid, clo, K, Val(id), clk, fields, biharmonic_mask_y, ∂y_∇²h_cᶜᶠᶜ, c)
        end
#= none:68 =#
#= none:68 =# @inline (diffusive_flux_z(i, j, k, grid, clo::AVBD, K, ::Val{id}, c, clk, fields, b) where id) = begin
            #= none:68 =#
            κ_σᶜᶜᶠ(i, j, k, grid, clo, K, Val(id), clk, fields, biharmonic_mask_z, ∂³zᶜᶜᶠ, c)
        end
#= none:75 =#
#= none:75 =# @inline function δ★ᶜᶜᶜ(i, j, k, grid, u, v)
        #= none:75 =#
        #= none:79 =#
        #= none:79 =# @inline Δy_∇²u(i, j, k, grid, u) = begin
                    #= none:79 =#
                    Δy_qᶠᶜᶜ(i, j, k, grid, biharmonic_mask_x, ∇²hᶠᶜᶜ, u)
                end
        #= none:80 =#
        #= none:80 =# @inline Δx_∇²v(i, j, k, grid, v) = begin
                    #= none:80 =#
                    Δx_qᶜᶠᶜ(i, j, k, grid, biharmonic_mask_y, ∇²hᶜᶠᶜ, v)
                end
        #= none:82 =#
        return (1 / Azᶜᶜᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Δy_∇²u, u) + δyᵃᶜᵃ(i, j, k, grid, Δx_∇²v, v))
    end
#= none:86 =#
#= none:86 =# @inline function ζ★ᶠᶠᶜ(i, j, k, grid, u, v)
        #= none:86 =#
        #= none:90 =#
        #= none:90 =# @inline Δy_∇²v(i, j, k, grid, v) = begin
                    #= none:90 =#
                    Δy_qᶜᶠᶜ(i, j, k, grid, biharmonic_mask_y, ∇²hᶜᶠᶜ, v)
                end
        #= none:91 =#
        #= none:91 =# @inline Δx_∇²u(i, j, k, grid, u) = begin
                    #= none:91 =#
                    Δx_qᶠᶜᶜ(i, j, k, grid, biharmonic_mask_x, ∇²hᶠᶜᶜ, u)
                end
        #= none:93 =#
        return (1 / Azᶠᶠᶜ(i, j, k, grid)) * (δxᶠᵃᵃ(i, j, k, grid, Δy_∇²v, v) - δyᵃᶠᵃ(i, j, k, grid, Δx_∇²u, u))
    end
#= none:101 =#
#= none:101 =# @inline ∂x_∇²h_cᶠᶜᶜ(i, j, k, grid, c) = begin
            #= none:101 =#
            (1 / Azᶠᶜᶜ(i, j, k, grid)) * δxᶠᵃᵃ(i, j, k, grid, Δy_qᶜᶜᶜ, ∇²hᶜᶜᶜ, c)
        end
#= none:102 =#
#= none:102 =# @inline ∂y_∇²h_cᶜᶠᶜ(i, j, k, grid, c) = begin
            #= none:102 =#
            (1 / Azᶜᶠᶜ(i, j, k, grid)) * δyᵃᶠᵃ(i, j, k, grid, Δx_qᶜᶜᶜ, ∇²hᶜᶜᶜ, c)
        end
#= none:110 =#
#= none:110 =# @inline biharmonic_mask_x(i, j, k, grid, f, args...) = begin
            #= none:110 =#
            ifelse(x_peripheral_node(i, j, k, grid), zero(grid), f(i, j, k, grid, args...))
        end
#= none:111 =#
#= none:111 =# @inline biharmonic_mask_y(i, j, k, grid, f, args...) = begin
            #= none:111 =#
            ifelse(y_peripheral_node(i, j, k, grid), zero(grid), f(i, j, k, grid, args...))
        end
#= none:112 =#
#= none:112 =# @inline biharmonic_mask_z(i, j, k, grid, f, args...) = begin
            #= none:112 =#
            ifelse(z_peripheral_node(i, j, k, grid), zero(grid), f(i, j, k, grid, args...))
        end
#= none:114 =#
#= none:114 =# @inline x_peripheral_node(i, j, k, grid) = begin
            #= none:114 =#
            peripheral_node(i, j, k, grid, Face(), Center(), Center())
        end
#= none:115 =#
#= none:115 =# @inline y_peripheral_node(i, j, k, grid) = begin
            #= none:115 =#
            peripheral_node(i, j, k, grid, Center(), Face(), Center())
        end
#= none:116 =#
#= none:116 =# @inline z_peripheral_node(i, j, k, grid) = begin
            #= none:116 =#
            peripheral_node(i, j, k, grid, Center(), Center(), Face())
        end