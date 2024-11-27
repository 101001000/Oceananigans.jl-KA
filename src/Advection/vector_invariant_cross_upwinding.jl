
#= none:20 =#
#= none:20 =# @inline function upwinded_divergence_flux_Uᶠᶜᶜ(i, j, k, grid, scheme::VectorInvariantCrossVerticalUpwinding, u, v)
        #= none:20 =#
        #= none:21 =#
        #= none:21 =# @inbounds û = u[i, j, k]
        #= none:22 =#
        δ_stencil = scheme.upwinding.divergence_stencil
        #= none:24 =#
        δᴿ = _biased_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, scheme.divergence_scheme, bias(û), flux_div_xyᶜᶜᶜ, δ_stencil, u, v)
        #= none:26 =#
        return û * δᴿ
    end
#= none:29 =#
#= none:29 =# @inline function upwinded_divergence_flux_Vᶜᶠᶜ(i, j, k, grid, scheme::VectorInvariantCrossVerticalUpwinding, u, v)
        #= none:29 =#
        #= none:30 =#
        #= none:30 =# @inbounds v̂ = v[i, j, k]
        #= none:31 =#
        δ_stencil = scheme.upwinding.divergence_stencil
        #= none:33 =#
        δᴿ = _biased_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, scheme.divergence_scheme, bias(v̂), flux_div_xyᶜᶜᶜ, δ_stencil, u, v)
        #= none:35 =#
        return v̂ * δᴿ
    end