
#= none:1 =#
using Oceananigans.Fields: AbstractField
#= none:2 =#
using Oceananigans.Grids: znode
#= none:3 =#
using Oceananigans.Operators: Δzᶜᶜᶠ, Δzᶜᶜᶜ
#= none:5 =#
const c = Center()
#= none:6 =#
const f = Face()
#= none:8 =#
#= none:8 =# Core.@doc " Return the geopotential height at `i, j, k` at cell centers. " #= none:9 =# @inline(Zᶜᶜᶜ(i, j, k, grid) = begin
                #= none:9 =#
                ifelse(k < 1, znode(i, j, 1, grid, c, c, c) + (1 - k) * Δzᶜᶜᶠ(i, j, 1, grid), ifelse(k > grid.Nz, znode(i, j, grid.Nz, grid, c, c, c) + (k - grid.Nz) * Δzᶜᶜᶠ(i, j, grid.Nz + 1, grid), znode(i, j, k, grid, c, c, c)))
            end)
#= none:14 =#
#= none:14 =# Core.@doc " Return the geopotential height at `i, j, k` at cell z-interfaces. " #= none:15 =# @inline(Zᶜᶜᶠ(i, j, k, grid) = begin
                #= none:15 =#
                ifelse(k < 1, znode(i, j, 1, grid, c, c, f) + (1 - k) * Δzᶜᶜᶜ(i, j, 1, grid), ifelse(k > grid.Nz + 1, znode(i, j, grid.Nz + 1, grid, c, c, f) + ((k - grid.Nz) - 1) * Δzᶜᶜᶜ(i, j, grid.Nz, grid), znode(i, j, k, grid, c, c, f)))
            end)
#= none:20 =#
#= none:20 =# @inline θ_and_sᴬ(i, j, k, θ::AbstractArray, sᴬ::AbstractArray) = begin
            #= none:20 =#
            #= none:20 =# @inbounds (θ[i, j, k], sᴬ[i, j, k])
        end
#= none:21 =#
#= none:21 =# @inline θ_and_sᴬ(i, j, k, θ::Number, sᴬ::AbstractArray) = begin
            #= none:21 =#
            #= none:21 =# @inbounds (θ, sᴬ[i, j, k])
        end
#= none:22 =#
#= none:22 =# @inline θ_and_sᴬ(i, j, k, θ::AbstractArray, sᴬ::Number) = begin
            #= none:22 =#
            #= none:22 =# @inbounds (θ[i, j, k], sᴬ)
        end
#= none:23 =#
#= none:23 =# @inline θ_and_sᴬ(i, j, k, θ::Number, sᴬ::Number) = begin
            #= none:23 =#
            (θ, sᴬ)
        end
#= none:26 =#
#= none:26 =# @inline ρ′(i, j, k, grid, eos, θ, sᴬ) = begin
            #= none:26 =#
            ρ′(θ_and_sᴬ(i, j, k, θ, sᴬ)..., Zᶜᶜᶜ(i, j, k, grid), eos)
        end
#= none:28 =#
#= none:28 =# @inline thermal_expansionᶜᶜᶜ(i, j, k, grid, eos, θ, sᴬ) = begin
            #= none:28 =#
            thermal_expansion(θ_and_sᴬ(i, j, k, θ, sᴬ)..., Zᶜᶜᶜ(i, j, k, grid), eos)
        end
#= none:29 =#
#= none:29 =# @inline thermal_expansionᶠᶜᶜ(i, j, k, grid, eos, θ, sᴬ) = begin
            #= none:29 =#
            thermal_expansion(ℑxᶠᵃᵃ(i, j, k, grid, θ), ℑxᶠᵃᵃ(i, j, k, grid, sᴬ), Zᶜᶜᶜ(i, j, k, grid), eos)
        end
#= none:30 =#
#= none:30 =# @inline thermal_expansionᶜᶠᶜ(i, j, k, grid, eos, θ, sᴬ) = begin
            #= none:30 =#
            thermal_expansion(ℑyᵃᶠᵃ(i, j, k, grid, θ), ℑyᵃᶠᵃ(i, j, k, grid, sᴬ), Zᶜᶜᶜ(i, j, k, grid), eos)
        end
#= none:31 =#
#= none:31 =# @inline thermal_expansionᶜᶜᶠ(i, j, k, grid, eos, θ, sᴬ) = begin
            #= none:31 =#
            thermal_expansion(ℑzᵃᵃᶠ(i, j, k, grid, θ), ℑzᵃᵃᶠ(i, j, k, grid, sᴬ), Zᶜᶜᶠ(i, j, k, grid), eos)
        end
#= none:33 =#
#= none:33 =# @inline haline_contractionᶜᶜᶜ(i, j, k, grid, eos, θ, sᴬ) = begin
            #= none:33 =#
            haline_contraction(θ_and_sᴬ(i, j, k, θ, sᴬ)..., Zᶜᶜᶜ(i, j, k, grid), eos)
        end
#= none:34 =#
#= none:34 =# @inline haline_contractionᶠᶜᶜ(i, j, k, grid, eos, θ, sᴬ) = begin
            #= none:34 =#
            haline_contraction(ℑxᶠᵃᵃ(i, j, k, grid, θ), ℑxᶠᵃᵃ(i, j, k, grid, sᴬ), Zᶜᶜᶜ(i, j, k, grid), eos)
        end
#= none:35 =#
#= none:35 =# @inline haline_contractionᶜᶠᶜ(i, j, k, grid, eos, θ, sᴬ) = begin
            #= none:35 =#
            haline_contraction(ℑyᵃᶠᵃ(i, j, k, grid, θ), ℑyᵃᶠᵃ(i, j, k, grid, sᴬ), Zᶜᶜᶜ(i, j, k, grid), eos)
        end
#= none:36 =#
#= none:36 =# @inline haline_contractionᶜᶜᶠ(i, j, k, grid, eos, θ, sᴬ) = begin
            #= none:36 =#
            haline_contraction(ℑzᵃᵃᶠ(i, j, k, grid, θ), ℑzᵃᵃᶠ(i, j, k, grid, sᴬ), Zᶜᶜᶠ(i, j, k, grid), eos)
        end