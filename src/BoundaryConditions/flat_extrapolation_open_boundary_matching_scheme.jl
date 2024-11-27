
#= none:1 =#
using Oceananigans.Grids: xspacing, yspacing, zspacing
#= none:3 =#
#= none:3 =# Core.@doc "    FlatExtrapolation\n\nZero gradient perpendicular velocity boundary condition.\n\nWe find the boundary value by Taylor expanding the gradient at the boundary point (`xᵢ`)\nto second order:\n```math\nf′(xᵢ) ≈ f′(xᵢ₋₁) + f′′(xᵢ₋₁)(xᵢ₋₁ - xᵢ) + O(Δx²) = f′(xᵢ₋₁) + f′′(xᵢ₋₁)Δx + O(Δx²),\n```\nwhere ``Δx=xᵢ₋₁ - xᵢ`` (for simplicity, we will also assume the spacing is constant at\nall ``i`` for now).\nWe can substitute the gradient at some point ``j`` (``f′(xⱼ)``) with the central \ndifference approximation:\n```math\nf′(xⱼ) ≈ (f(xⱼ₊₁) - f(xⱼ₋₁)) / 2Δx,\n```\nand the second derivative at some point ``j`` (``f′′(xⱼ)``) can be approximated as:\n```math\nf′′(xⱼ) ≈ (f′(xⱼ₊₁) - f′(xⱼ₋₁)) / 2Δx = ((f(xⱼ₊₂) - f(xⱼ)) - (f(xⱼ) - f(xⱼ₋₂))) / (2Δx)².\n```\nWhen we then substitute for the boundary adjacent point ``f′′(xᵢ₋₁)`` we know that \n``f′(xⱼ₊₁)=f′(xᵢ)=0`` so the Taylor expansion becomes:\n```math\nf(xᵢ) ≈ f(xᵢ₋₂) - (f(xᵢ₋₁) - f(xᵢ₋₃))/2 + O(Δx²).\n```\n\nWhen the grid spacing is not constant the above can be repeated resulting in the factor \nof 1/2 changes to ``Δx₋₁/(Δx₋₂ + Δx₋₃)`` instead, i.e.:\n```math\nf(xᵢ) ≈ f(xᵢ₋₂) - (f(xᵢ₋₁) - f(xᵢ₋₃))Δxᵢ₋₁/(Δxᵢ₋₂ + Δxᵢ₋₃) + O(Δx²)\n```.\n" struct FlatExtrapolation{FT}
        #= none:37 =#
        relaxation_timescale::FT
    end
#= none:40 =#
const FEOBC = BoundaryCondition{<:Open{<:FlatExtrapolation}}
#= none:42 =#
function FlatExtrapolationOpenBoundaryCondition(val = nothing; relaxation_timescale = Inf, kwargs...)
    #= none:42 =#
    #= none:43 =#
    classification = Open(FlatExtrapolation(relaxation_timescale))
    #= none:45 =#
    return BoundaryCondition(classification, val; kwargs...)
end
#= none:48 =#
#= none:48 =# @inline function relax(l, m, grid, ϕ, bc, clock, model_fields)
        #= none:48 =#
        #= none:49 =#
        Δt = clock.last_stage_Δt
        #= none:50 =#
        τ = bc.classification.matching_scheme.relaxation_timescale
        #= none:52 =#
        Δt̄ = min(1, Δt / τ)
        #= none:53 =#
        ϕₑₓₜ = getbc(bc, l, m, grid, clock, model_fields)
        #= none:55 =#
        Δϕ = (ϕₑₓₜ - ϕ) * Δt̄
        #= none:56 =#
        not_relaxing = isnothing(bc.condition) | !(isfinite(clock.last_stage_Δt))
        #= none:57 =#
        Δϕ = ifelse(not_relaxing, zero(ϕ), Δϕ)
        #= none:59 =#
        return ϕ + Δϕ
    end
#= none:62 =#
const c = Center()
#= none:64 =#
#= none:64 =# @inline function _fill_west_open_halo!(j, k, grid, ϕ, bc::FEOBC, loc, clock, model_fields)
        #= none:64 =#
        #= none:65 =#
        Δx₁ = xspacing(1, j, k, grid, c, c, c)
        #= none:66 =#
        Δx₂ = xspacing(2, j, k, grid, c, c, c)
        #= none:67 =#
        Δx₃ = xspacing(3, j, k, grid, c, c, c)
        #= none:69 =#
        spacing_factor = Δx₁ / (Δx₂ + Δx₃)
        #= none:71 =#
        gradient_free_ϕ = #= none:71 =# @inbounds(ϕ[3, j, k] - (ϕ[2, j, k] - ϕ[4, j, k]) * spacing_factor)
        #= none:73 =#
        #= none:73 =# @inbounds ϕ[1, j, k] = relax(j, k, grid, gradient_free_ϕ, bc, clock, model_fields)
        #= none:75 =#
        return nothing
    end
#= none:78 =#
#= none:78 =# @inline function _fill_east_open_halo!(j, k, grid, ϕ, bc::FEOBC, loc, clock, model_fields)
        #= none:78 =#
        #= none:79 =#
        i = grid.Nx + 1
        #= none:81 =#
        Δx₁ = xspacing(i - 1, j, k, grid, c, c, c)
        #= none:82 =#
        Δx₂ = xspacing(i - 2, j, k, grid, c, c, c)
        #= none:83 =#
        Δx₃ = xspacing(i - 3, j, k, grid, c, c, c)
        #= none:85 =#
        spacing_factor = Δx₁ / (Δx₂ + Δx₃)
        #= none:87 =#
        gradient_free_ϕ = #= none:87 =# @inbounds(ϕ[i - 2, j, k] - (ϕ[i - 1, j, k] - ϕ[i - 3, j, k]) * spacing_factor)
        #= none:89 =#
        #= none:89 =# @inbounds ϕ[i, j, k] = relax(j, k, grid, gradient_free_ϕ, bc, clock, model_fields)
        #= none:91 =#
        return nothing
    end
#= none:94 =#
#= none:94 =# @inline function _fill_south_open_halo!(i, k, grid, ϕ, bc::FEOBC, loc, clock, model_fields)
        #= none:94 =#
        #= none:95 =#
        Δy₁ = yspacing(i, 1, k, grid, c, c, c)
        #= none:96 =#
        Δy₂ = yspacing(i, 2, k, grid, c, c, c)
        #= none:97 =#
        Δy₃ = yspacing(i, 3, k, grid, c, c, c)
        #= none:99 =#
        spacing_factor = Δy₁ / (Δy₂ + Δy₃)
        #= none:101 =#
        gradient_free_ϕ = ϕ[i, 3, k] - (ϕ[i, 2, k] - ϕ[i, 4, k]) * spacing_factor
        #= none:103 =#
        #= none:103 =# @inbounds ϕ[i, 1, k] = relax(i, k, grid, gradient_free_ϕ, bc, clock, model_fields)
        #= none:105 =#
        return nothing
    end
#= none:108 =#
#= none:108 =# @inline function _fill_north_open_halo!(i, k, grid, ϕ, bc::FEOBC, loc, clock, model_fields)
        #= none:108 =#
        #= none:109 =#
        j = grid.Ny + 1
        #= none:111 =#
        Δy₁ = yspacing(i, j - 1, k, grid, c, c, c)
        #= none:112 =#
        Δy₂ = yspacing(i, j - 2, k, grid, c, c, c)
        #= none:113 =#
        Δy₃ = yspacing(i, j - 3, k, grid, c, c, c)
        #= none:115 =#
        spacing_factor = Δy₁ / (Δy₂ + Δy₃)
        #= none:117 =#
        gradient_free_ϕ = #= none:117 =# @inbounds(ϕ[i, j - 2, k] - (ϕ[i, j - 1, k] - ϕ[i, j - 3, k]) * spacing_factor)
        #= none:119 =#
        #= none:119 =# @inbounds ϕ[i, j, k] = relax(i, k, grid, gradient_free_ϕ, bc, clock, model_fields)
        #= none:121 =#
        return nothing
    end
#= none:124 =#
#= none:124 =# @inline function _fill_bottom_open_halo!(i, j, grid, ϕ, bc::FEOBC, loc, clock, model_fields)
        #= none:124 =#
        #= none:125 =#
        Δz₁ = zspacing(i, j, 1, grid, c, c, c)
        #= none:126 =#
        Δz₂ = zspacing(i, j, 2, grid, c, c, c)
        #= none:127 =#
        Δz₃ = zspacing(i, j, 3, grid, c, c, c)
        #= none:129 =#
        spacing_factor = Δz₁ / (Δz₂ + Δz₃)
        #= none:131 =#
        gradient_free_ϕ = #= none:131 =# @inbounds(ϕ[i, j, 3] - (ϕ[i, j, 2] - ϕ[i, j, 4]) * spacing_factor)
        #= none:133 =#
        #= none:133 =# @inbounds ϕ[i, j, 1] = relax(i, j, grid, gradient_free_ϕ, bc, clock, model_fields)
        #= none:135 =#
        return nothing
    end
#= none:138 =#
#= none:138 =# @inline function _fill_top_open_halo!(i, j, grid, ϕ, bc::FEOBC, loc, clock, model_fields)
        #= none:138 =#
        #= none:139 =#
        k = grid.Nz + 1
        #= none:141 =#
        Δz₁ = zspacing(i, j, k - 1, grid, c, c, c)
        #= none:142 =#
        Δz₂ = zspacing(i, j, k - 2, grid, c, c, c)
        #= none:143 =#
        Δz₃ = zspacing(i, j, k - 3, grid, c, c, c)
        #= none:145 =#
        spacing_factor = Δz₁ / (Δz₂ + Δz₃)
        #= none:147 =#
        gradient_free_ϕ = #= none:147 =# @inbounds(ϕ[i, j, k - 2] - (ϕ[i, j, k - 1] - ϕ[i, j, k - 3]) * spacing_factor)
        #= none:149 =#
        #= none:149 =# @inbounds ϕ[i, j, k] = relax(i, j, grid, gradient_free_ϕ, bc, clock, model_fields)
        #= none:151 =#
        return nothing
    end