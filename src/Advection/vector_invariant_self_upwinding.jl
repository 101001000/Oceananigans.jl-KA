
#= none:5 =#
#= none:5 =# @inline δx_U(i, j, k, grid, u, v) = begin
            #= none:5 =#
            δxᶜᵃᵃ(i, j, k, grid, Ax_qᶠᶜᶜ, u)
        end
#= none:6 =#
#= none:6 =# @inline δy_V(i, j, k, grid, u, v) = begin
            #= none:6 =#
            δyᵃᶜᵃ(i, j, k, grid, Ay_qᶜᶠᶜ, v)
        end
#= none:9 =#
#= none:9 =# @inline U_smoothness(i, j, k, grid, u, v) = begin
            #= none:9 =#
            ℑxᶜᵃᵃ(i, j, k, grid, Ax_qᶠᶜᶜ, u)
        end
#= none:10 =#
#= none:10 =# @inline V_smoothness(i, j, k, grid, u, v) = begin
            #= none:10 =#
            ℑyᵃᶜᵃ(i, j, k, grid, Ay_qᶜᶠᶜ, v)
        end
#= none:13 =#
#= none:13 =# @inline divergence_smoothness(i, j, k, grid, u, v) = begin
            #= none:13 =#
            δx_U(i, j, k, grid, u, v) + δy_V(i, j, k, grid, u, v)
        end
#= none:15 =#
#= none:15 =# @inline function upwinded_divergence_flux_Uᶠᶜᶜ(i, j, k, grid, scheme::VectorInvariantSelfVerticalUpwinding, u, v)
        #= none:15 =#
        #= none:17 =#
        δU_stencil = scheme.upwinding.δU_stencil
        #= none:18 =#
        cross_scheme = scheme.upwinding.cross_scheme
        #= none:20 =#
        #= none:20 =# @inbounds û = u[i, j, k]
        #= none:21 =#
        δvˢ = _symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, cross_scheme, δy_V, u, v)
        #= none:22 =#
        δuᴿ = _biased_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, scheme.divergence_scheme, bias(û), δx_U, δU_stencil, u, v)
        #= none:24 =#
        return û * (δvˢ + δuᴿ)
    end
#= none:27 =#
#= none:27 =# @inline function upwinded_divergence_flux_Vᶜᶠᶜ(i, j, k, grid, scheme::VectorInvariantSelfVerticalUpwinding, u, v)
        #= none:27 =#
        #= none:29 =#
        δV_stencil = scheme.upwinding.δV_stencil
        #= none:30 =#
        cross_scheme = scheme.upwinding.cross_scheme
        #= none:32 =#
        #= none:32 =# @inbounds v̂ = v[i, j, k]
        #= none:33 =#
        δuˢ = _symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, cross_scheme, δx_U, u, v)
        #= none:34 =#
        δvᴿ = _biased_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, scheme.divergence_scheme, bias(v̂), δy_V, δV_stencil, u, v)
        #= none:36 =#
        return v̂ * (δuˢ + δvᴿ)
    end
#= none:43 =#
#= none:43 =# @inline half_ϕ²(i, j, k, grid, ϕ) = begin
            #= none:43 =#
            #= none:43 =# @inbounds ϕ[i, j, k] ^ 2 / 2
        end
#= none:45 =#
#= none:45 =# @inline δx_u²(i, j, k, grid, u, v) = begin
            #= none:45 =#
            δxᶜᵃᵃ(i, j, k, grid, half_ϕ², u)
        end
#= none:46 =#
#= none:46 =# @inline δy_u²(i, j, k, grid, u, v) = begin
            #= none:46 =#
            δyᶠᶠᶜ(i, j, k, grid, half_ϕ², u)
        end
#= none:48 =#
#= none:48 =# @inline δx_v²(i, j, k, grid, u, v) = begin
            #= none:48 =#
            δxᶠᶠᶜ(i, j, k, grid, half_ϕ², v)
        end
#= none:49 =#
#= none:49 =# @inline δy_v²(i, j, k, grid, u, v) = begin
            #= none:49 =#
            δyᵃᶜᵃ(i, j, k, grid, half_ϕ², v)
        end
#= none:51 =#
#= none:51 =# @inline u_smoothness(i, j, k, grid, u, v) = begin
            #= none:51 =#
            ℑxᶜᵃᵃ(i, j, k, grid, u)
        end
#= none:52 =#
#= none:52 =# @inline v_smoothness(i, j, k, grid, u, v) = begin
            #= none:52 =#
            ℑyᵃᶜᵃ(i, j, k, grid, v)
        end
#= none:54 =#
#= none:54 =# @inline function bernoulli_head_U(i, j, k, grid, scheme::VectorInvariantKineticEnergyUpwinding, u, v)
        #= none:54 =#
        #= none:56 =#
        #= none:56 =# @inbounds û = u[i, j, k]
        #= none:58 =#
        δu²_stencil = scheme.upwinding.δu²_stencil
        #= none:59 =#
        cross_scheme = scheme.upwinding.cross_scheme
        #= none:61 =#
        δKvˢ = _symmetric_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme, cross_scheme, δx_v², u, v)
        #= none:62 =#
        δKuᴿ = _biased_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, scheme.kinetic_energy_gradient_scheme, bias(û), δx_u², δu²_stencil, u, v)
        #= none:64 =#
        return (δKuᴿ + δKvˢ) / Δxᶠᶜᶜ(i, j, k, grid)
    end
#= none:67 =#
#= none:67 =# @inline function bernoulli_head_V(i, j, k, grid, scheme::VectorInvariantKineticEnergyUpwinding, u, v)
        #= none:67 =#
        #= none:69 =#
        #= none:69 =# @inbounds v̂ = v[i, j, k]
        #= none:71 =#
        δv²_stencil = scheme.upwinding.δv²_stencil
        #= none:72 =#
        cross_scheme = scheme.upwinding.cross_scheme
        #= none:74 =#
        δKuˢ = _symmetric_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme, cross_scheme, δy_u², u, v)
        #= none:75 =#
        δKvᴿ = _biased_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, scheme.kinetic_energy_gradient_scheme, bias(v̂), δy_v², δv²_stencil, u, v)
        #= none:77 =#
        return (δKvᴿ + δKuˢ) / Δyᶜᶠᶜ(i, j, k, grid)
    end