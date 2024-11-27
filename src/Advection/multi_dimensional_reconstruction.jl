
#= none:1 =#
#= none:1 =# @inline _multi_dimensional_reconstruction_x(args...) = begin
            #= none:1 =#
            multi_dimensional_reconstruction_x(args...)
        end
#= none:2 =#
#= none:2 =# @inline _multi_dimensional_reconstruction_y(args...) = begin
            #= none:2 =#
            multi_dimensional_reconstruction_y(args...)
        end
#= none:8 =#
const two_32 = Int32(2)
#= none:16 =#
const γ₀¹ = (1008 + 71 * sqrt(15)) / 5240
#= none:17 =#
const γ₁¹ = 408 / 655
#= none:18 =#
const γ₂¹ = (1008 - 71 * sqrt(15)) / 5240
#= none:20 =#
const γ₀³ = (1008 - 71 * sqrt(15)) / 5240
#= none:21 =#
const γ₁³ = 408 / 655
#= none:22 =#
const γ₂³ = (1008 + 71 * sqrt(15)) / 5240
#= none:24 =#
const σ⁺ = 214 / 80
#= none:25 =#
const σ⁻ = 67 / 40
#= none:27 =#
const γ₀²⁺ = (9.0 / 80) / σ⁺
#= none:28 =#
const γ₁²⁺ = (49.0 / 20) / σ⁺
#= none:29 =#
const γ₂²⁺ = (9.0 / 80) / σ⁺
#= none:31 =#
const γ₀²⁻ = (9.0 / 40) / σ⁻
#= none:32 =#
const γ₁²⁻ = (49.0 / 40) / σ⁻
#= none:33 =#
const γ₂²⁻ = (9.0 / 40) / σ⁻
#= none:38 =#
const a₀¹ = (2 - 3 * sqrt(15), -4 + 12 * sqrt(15), 62 - 9 * sqrt(15)) ./ 60
#= none:39 =#
const a₁¹ = (2 + 3 * sqrt(15), 56, 2 - 3 * sqrt(15)) ./ 60
#= none:40 =#
const a₂¹ = (62 + 9 * sqrt(15), -4 - 12 * sqrt(15), 2 + 3 * sqrt(15)) ./ 60
#= none:42 =#
const a₀² = (-1, 2, 23) ./ 24
#= none:43 =#
const a₁² = (-1, 26, -1) ./ 24
#= none:44 =#
const a₂² = (23, 2, -1) ./ 24
#= none:46 =#
const a₀³ = (2 + 3 * sqrt(15), -4 - 12 * sqrt(15), 62 + 9 * sqrt(15)) ./ 60
#= none:47 =#
const a₁³ = (2 - 3 * sqrt(15), 56, 2 + 3 * sqrt(15)) ./ 60
#= none:48 =#
const a₂³ = (62 - 9 * sqrt(15), -4 + 12 * sqrt(15), 2 - 3 * sqrt(15)) ./ 60
#= none:50 =#
#= none:50 =# @inline left_biased_β_constant(FT, ψ) = begin
            #= none:50 =#
            #= none:50 =# @inbounds FT(13 / 12) * ((ψ[1] - 2 * ψ[2]) + ψ[3]) ^ two_32 + FT(1 / 4) * ((ψ[1] - 4 * ψ[2]) + 3 * ψ[3]) ^ two_32
        end
#= none:51 =#
#= none:51 =# @inline center_biased_β_constant(FT, ψ) = begin
            #= none:51 =#
            #= none:51 =# @inbounds FT(13 / 12) * ((ψ[1] - 2 * ψ[2]) + ψ[3]) ^ two_32 + FT(1 / 4) * (ψ[1] - ψ[3]) ^ two_32
        end
#= none:52 =#
#= none:52 =# @inline right_biased_β_constant(FT, ψ) = begin
            #= none:52 =#
            #= none:52 =# @inbounds FT(13 / 12) * ((ψ[1] - 2 * ψ[2]) + ψ[3]) ^ two_32 + FT(1 / 4) * ((3 * ψ[1] - 4 * ψ[2]) + ψ[3]) ^ two_32
        end
#= none:54 =#
#= none:54 =# @inline function centered_reconstruction_weights(FT, β₀, β₁, β₂, γ₀, γ₁, γ₂)
        #= none:54 =#
        #= none:56 =#
        α₀ = FT(γ₀) / (β₀ + FT(ε)) ^ two_32
        #= none:57 =#
        α₁ = FT(γ₁) / (β₁ + FT(ε)) ^ two_32
        #= none:58 =#
        α₂ = FT(γ₂) / (β₂ + FT(ε)) ^ two_32
        #= none:60 =#
        Σα = α₀ + α₁ + α₂
        #= none:61 =#
        w₀ = α₀ / Σα
        #= none:62 =#
        w₁ = α₁ / Σα
        #= none:63 =#
        w₂ = α₂ / Σα
        #= none:65 =#
        return (w₀, w₁, w₂)
    end
#= none:68 =#
function fifth_order_weno_reconstruction(FT, S₀, S₁, S₂)
    #= none:68 =#
    #= none:70 =#
    q̂₀¹ = FT(a₀¹[1]) * S₀[1] + FT(a₀¹[2]) * S₀[2] + FT(a₀¹[3]) * S₀[3]
    #= none:71 =#
    q̂₁¹ = FT(a₁¹[1]) * S₁[1] + FT(a₁¹[2]) * S₁[2] + FT(a₁¹[3]) * S₁[3]
    #= none:72 =#
    q̂₂¹ = FT(a₂¹[1]) * S₂[1] + FT(a₂¹[2]) * S₂[2] + FT(a₂¹[3]) * S₂[3]
    #= none:74 =#
    q̂₀² = FT(a₀²[1]) * S₀[1] + FT(a₀²[2]) * S₀[2] + FT(a₀²[3]) * S₀[3]
    #= none:75 =#
    q̂₁² = FT(a₁²[1]) * S₁[1] + FT(a₁²[2]) * S₁[2] + FT(a₁²[3]) * S₁[3]
    #= none:76 =#
    q̂₂² = FT(a₂²[1]) * S₂[1] + FT(a₂²[2]) * S₂[2] + FT(a₂²[3]) * S₂[3]
    #= none:78 =#
    q̂₀³ = FT(a₀³[1]) * S₀[1] + FT(a₀³[2]) * S₀[2] + FT(a₀³[3]) * S₀[3]
    #= none:79 =#
    q̂₁³ = FT(a₁³[1]) * S₁[1] + FT(a₁³[2]) * S₁[2] + FT(a₁³[3]) * S₁[3]
    #= none:80 =#
    q̂₂³ = FT(a₂³[1]) * S₂[1] + FT(a₂³[2]) * S₂[2] + FT(a₂³[3]) * S₂[3]
    #= none:82 =#
    β₀ = left_biased_β_constant(FT, S₀)
    #= none:83 =#
    β₁ = center_biased_β_constant(FT, S₁)
    #= none:84 =#
    β₂ = right_biased_β_constant(FT, S₂)
    #= none:86 =#
    (w₀¹, w₁¹, w₂¹) = centered_reconstruction_weights(FT, β₀, β₁, β₂, γ₀¹, γ₁¹, γ₂¹)
    #= none:87 =#
    (w₀³, w₁³, w₂³) = centered_reconstruction_weights(FT, β₀, β₁, β₂, γ₀³, γ₁³, γ₂³)
    #= none:89 =#
    (w₀²⁺, w₁²⁺, w₂²⁺) = centered_reconstruction_weights(FT, β₀, β₁, β₂, γ₀²⁺, γ₁²⁺, γ₂²⁺)
    #= none:90 =#
    (w₀²⁻, w₁²⁻, w₂²⁻) = centered_reconstruction_weights(FT, β₀, β₁, β₂, γ₀²⁻, γ₁²⁻, γ₂²⁻)
    #= none:92 =#
    q¹ = w₀¹ * q̂₀¹ + w₁¹ * q̂₁¹ + w₂¹ * q̂₂¹
    #= none:93 =#
    q³ = w₀³ * q̂₀³ + w₁³ * q̂₁³ + w₂³ * q̂₂³
    #= none:95 =#
    q²⁺ = w₀²⁺ * q̂₀² + w₁²⁺ * q̂₁² + w₂²⁺ * q̂₂²
    #= none:96 =#
    q²⁻ = w₀²⁻ * q̂₀² + w₁²⁻ * q̂₁² + w₂²⁻ * q̂₂²
    #= none:98 =#
    q² = FT(σ⁺) * q²⁺ - FT(σ⁻) * q²⁻
    #= none:100 =#
    return q¹ / 6 + (2q²) / 3 + q³ / 6
end
#= none:102 =#
#= none:102 =# @inline function multi_dimensional_reconstruction_x(i, j, k, grid, scheme, _interpolate_y, args...)
        #= none:102 =#
        #= none:104 =#
        FT = eltype(grid)
        #= none:106 =#
        Q₋₂ = _interpolate_y(i - 2, j, k, grid, scheme, args...)
        #= none:107 =#
        Q₋₁ = _interpolate_y(i - 1, j, k, grid, scheme, args...)
        #= none:108 =#
        Q₀ = _interpolate_y(i, j, k, grid, scheme, args...)
        #= none:109 =#
        Q₊₁ = _interpolate_y(i + 1, j, k, grid, scheme, args...)
        #= none:110 =#
        Q₊₂ = _interpolate_y(i + 2, j, k, grid, scheme, args...)
        #= none:112 =#
        S₀ = (Q₋₂, Q₋₁, Q₀)
        #= none:113 =#
        S₁ = (Q₋₁, Q₀, Q₊₁)
        #= none:114 =#
        S₂ = (Q₀, Q₊₁, Q₊₂)
        #= none:116 =#
        return fifth_order_weno_reconstruction(FT, S₀, S₁, S₂)
    end
#= none:119 =#
#= none:119 =# @inline function multi_dimensional_reconstruction_y(i, j, k, grid, scheme, _interpolate_x, args...)
        #= none:119 =#
        #= none:121 =#
        FT = eltype(grid)
        #= none:123 =#
        Q₋₂ = _interpolate_x(i, j - 2, k, grid, scheme, args...)
        #= none:124 =#
        Q₋₁ = _interpolate_x(i, j - 1, k, grid, scheme, args...)
        #= none:125 =#
        Q₀ = _interpolate_x(i, j, k, grid, scheme, args...)
        #= none:126 =#
        Q₊₁ = _interpolate_x(i, j + 1, k, grid, scheme, args...)
        #= none:127 =#
        Q₊₂ = _interpolate_x(i, j + 2, k, grid, scheme, args...)
        #= none:129 =#
        S₀ = (Q₋₂, Q₋₁, Q₀)
        #= none:130 =#
        S₁ = (Q₋₁, Q₀, Q₊₁)
        #= none:131 =#
        S₂ = (Q₀, Q₊₁, Q₊₂)
        #= none:133 =#
        return fifth_order_weno_reconstruction(FT, S₀, S₁, S₂)
    end