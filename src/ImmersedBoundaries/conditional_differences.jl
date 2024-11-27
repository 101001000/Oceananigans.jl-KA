
#= none:1 =#
import Oceananigans.Operators: δxᶠᶜᶜ, δxᶠᶜᶠ, δxᶠᶠᶜ, δxᶠᶠᶠ, δxᶜᶜᶜ, δxᶜᶜᶠ, δxᶜᶠᶜ, δxᶜᶠᶠ, δyᶜᶠᶜ, δyᶜᶠᶠ, δyᶠᶠᶜ, δyᶠᶠᶠ, δyᶜᶜᶜ, δyᶜᶜᶠ, δyᶠᶜᶜ, δyᶠᶜᶠ, δzᶜᶜᶠ, δzᶜᶠᶠ, δzᶠᶜᶠ, δzᶠᶠᶠ, δzᶜᶜᶜ, δzᶜᶠᶜ, δzᶠᶜᶜ, δzᶠᶠᶜ
#= none:9 =#
import Oceananigans.Operators: δxTᶜᵃᵃ, δyTᵃᶜᵃ, ∂xTᶠᶜᶠ, ∂yTᶜᶠᶠ
#= none:25 =#
#= none:25 =# @inline conditional_δx_f(ℓy, ℓz, i, j, k, ibg::IBG, δx, args...) = begin
            #= none:25 =#
            ifelse(immersed_inactive_node(i, j, k, ibg, c, ℓy, ℓz) | immersed_inactive_node(i - 1, j, k, ibg, c, ℓy, ℓz), zero(ibg), δx(i, j, k, ibg.underlying_grid, args...))
        end
#= none:30 =#
#= none:30 =# @inline conditional_δx_c(ℓy, ℓz, i, j, k, ibg::IBG, δx, args...) = begin
            #= none:30 =#
            ifelse(immersed_inactive_node(i, j, k, ibg, f, ℓy, ℓz) | immersed_inactive_node(i + 1, j, k, ibg, f, ℓy, ℓz), zero(ibg), δx(i, j, k, ibg.underlying_grid, args...))
        end
#= none:35 =#
#= none:35 =# @inline conditional_δy_f(ℓx, ℓz, i, j, k, ibg::IBG, δy, args...) = begin
            #= none:35 =#
            ifelse(immersed_inactive_node(i, j, k, ibg, ℓx, c, ℓz) | immersed_inactive_node(i, j - 1, k, ibg, ℓx, c, ℓz), zero(ibg), δy(i, j, k, ibg.underlying_grid, args...))
        end
#= none:40 =#
#= none:40 =# @inline conditional_δy_c(ℓx, ℓz, i, j, k, ibg::IBG, δy, args...) = begin
            #= none:40 =#
            ifelse(immersed_inactive_node(i, j, k, ibg, ℓx, f, ℓz) | immersed_inactive_node(i, j + 1, k, ibg, ℓx, f, ℓz), zero(ibg), δy(i, j, k, ibg.underlying_grid, args...))
        end
#= none:45 =#
#= none:45 =# @inline conditional_δz_f(ℓx, ℓy, i, j, k, ibg::IBG, δz, args...) = begin
            #= none:45 =#
            ifelse(immersed_inactive_node(i, j, k, ibg, ℓx, ℓy, c) | immersed_inactive_node(i, j, k - 1, ibg, ℓx, ℓy, c), zero(ibg), δz(i, j, k, ibg.underlying_grid, args...))
        end
#= none:50 =#
#= none:50 =# @inline conditional_δz_c(ℓx, ℓy, i, j, k, ibg::IBG, δz, args...) = begin
            #= none:50 =#
            ifelse(immersed_inactive_node(i, j, k, ibg, ℓx, ℓy, f) | immersed_inactive_node(i, j, k + 1, ibg, ℓx, ℓy, f), zero(ibg), δz(i, j, k, ibg.underlying_grid, args...))
        end
#= none:55 =#
#= none:55 =# @inline translate_loc(a) = begin
            #= none:55 =#
            if a == :ᶠ
                :f
            else
                :c
            end
        end
#= none:57 =#
for (d, ξ) = enumerate((:x, :y, :z))
    #= none:58 =#
    for ℓx = (:ᶠ, :ᶜ), ℓy = (:ᶠ, :ᶜ), ℓz = (:ᶠ, :ᶜ)
        #= none:60 =#
        δξ = Symbol(:δ, ξ, ℓx, ℓy, ℓz)
        #= none:61 =#
        loc = translate_loc.((ℓx, ℓy, ℓz))
        #= none:62 =#
        conditional_δξ = Symbol(:conditional_δ, ξ, :_, loc[d])
        #= none:65 =#
        other_locs = []
        #= none:66 =#
        for l = 1:3
            #= none:67 =#
            if l != d
                #= none:68 =#
                push!(other_locs, loc[l])
            end
            #= none:70 =#
        end
        #= none:72 =#
        #= none:72 =# @eval begin
                #= none:73 =#
                #= none:73 =# @inline $δξ(i, j, k, ibg::IBG, args...) = begin
                            #= none:73 =#
                            $conditional_δξ($(other_locs[1]), $(other_locs[2]), i, j, k, ibg, $δξ, args...)
                        end
                #= none:74 =#
                #= none:74 =# @inline $δξ(i, j, k, ibg::IBG, f::Function, args...) = begin
                            #= none:74 =#
                            $conditional_δξ($(other_locs[1]), $(other_locs[2]), i, j, k, ibg, $δξ, f::Function, args...)
                        end
            end
        #= none:76 =#
    end
    #= none:77 =#
end
#= none:83 =#
#= none:83 =# @inline conditional_U_fcc(i, j, k, grid, ibg::IBG, f::Function, args...) = begin
            #= none:83 =#
            ifelse(peripheral_node(i, j, k, ibg, f, c, c), zero(ibg), f(i, j, k, grid, args...))
        end
#= none:84 =#
#= none:84 =# @inline conditional_V_cfc(i, j, k, grid, ibg::IBG, f::Function, args...) = begin
            #= none:84 =#
            ifelse(peripheral_node(i, j, k, ibg, c, f, c), zero(ibg), f(i, j, k, grid, args...))
        end
#= none:86 =#
#= none:86 =# @inline conditional_∂xTᶠᶜᶠ(i, j, k, ibg::IBG, args...) = begin
            #= none:86 =#
            ifelse(inactive_node(i, j, k, ibg, c, c, f) | inactive_node(i - 1, j, k, ibg, c, c, f), zero(ibg), ∂xTᶠᶜᶠ(i, j, k, ibg.underlying_grid, args...))
        end
#= none:87 =#
#= none:87 =# @inline conditional_∂yTᶜᶠᶠ(i, j, k, ibg::IBG, args...) = begin
            #= none:87 =#
            ifelse(inactive_node(i, j, k, ibg, c, c, f) | inactive_node(i, j - 1, k, ibg, c, c, f), zero(ibg), ∂yTᶜᶠᶠ(i, j, k, ibg.underlying_grid, args...))
        end
#= none:89 =#
#= none:89 =# @inline δxTᶜᵃᵃ(i, j, k, ibg::IBG, f::Function, args...) = begin
            #= none:89 =#
            δxTᶜᵃᵃ(i, j, k, ibg.underlying_grid, conditional_U_fcc, ibg, f, args...)
        end
#= none:90 =#
#= none:90 =# @inline δyTᵃᶜᵃ(i, j, k, ibg::IBG, f::Function, args...) = begin
            #= none:90 =#
            δyTᵃᶜᵃ(i, j, k, ibg.underlying_grid, conditional_V_cfc, ibg, f, args...)
        end
#= none:91 =#
#= none:91 =# @inline ∂xTᶠᶜᶠ(i, j, k, ibg::IBG, f::Function, args...) = begin
            #= none:91 =#
            conditional_∂xTᶠᶜᶠ(i, j, k, ibg, f, args...)
        end
#= none:92 =#
#= none:92 =# @inline ∂yTᶜᶠᶠ(i, j, k, ibg::IBG, f::Function, args...) = begin
            #= none:92 =#
            conditional_∂yTᶜᶠᶠ(i, j, k, ibg, f, args...)
        end