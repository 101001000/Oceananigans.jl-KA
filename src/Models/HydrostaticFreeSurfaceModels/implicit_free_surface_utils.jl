
#= none:1 =#
#= none:1 =# Core.@doc "Compute the horizontal divergence of vertically-uniform quantity using\nvertically-integrated face areas `∫ᶻ_Axᶠᶜᶜ` and `∫ᶻ_Ayᶜᶠᶜ`.\n" #= none:5 =# @inline(Az_∇h²ᶜᶜᶜ(i, j, k, grid, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, η) = begin
                #= none:5 =#
                δxᶜᵃᵃ(i, j, k, grid, ∫ᶻ_Ax_∂x_ηᶠᶜᶜ, ∫ᶻ_Axᶠᶜᶜ, η) + δyᵃᶜᵃ(i, j, k, grid, ∫ᶻ_Ay_∂y_ηᶜᶠᶜ, ∫ᶻ_Ayᶜᶠᶜ, η)
            end)