
#= none:8 =#
const UpwindScheme = AbstractUpwindBiasedAdvectionScheme
#= none:10 =#
#= none:10 =# @inline upwind_biased_product(ũ, ψᴸ, ψᴿ) = begin
            #= none:10 =#
            ((ũ + abs(ũ)) * ψᴸ + (ũ - abs(ũ)) * ψᴿ) / 2
        end
#= none:18 =#
struct LeftBias
    #= none:18 =#
end
#= none:19 =#
struct RightBias
    #= none:19 =#
end
#= none:21 =#
#= none:21 =# @inline bias(u::Number) = begin
            #= none:21 =#
            ifelse(u > 0, LeftBias(), RightBias())
        end
#= none:23 =#
#= none:23 =# @inline function advective_momentum_flux_Uu(i, j, k, grid, scheme::UpwindScheme, U, u)
        #= none:23 =#
        #= none:25 =#
        ũ = _symmetric_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme, Ax_qᶠᶜᶜ, U)
        #= none:26 =#
        uᴿ = _biased_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme, bias(ũ), u)
        #= none:28 =#
        return ũ * uᴿ
    end
#= none:31 =#
#= none:31 =# @inline function advective_momentum_flux_Vu(i, j, k, grid, scheme::UpwindScheme, V, u)
        #= none:31 =#
        #= none:33 =#
        ṽ = _symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, Ay_qᶜᶠᶜ, V)
        #= none:34 =#
        uᴿ = _biased_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, bias(ṽ), u)
        #= none:36 =#
        return ṽ * uᴿ
    end
#= none:39 =#
#= none:39 =# @inline function advective_momentum_flux_Wu(i, j, k, grid, scheme::UpwindScheme, W, u)
        #= none:39 =#
        #= none:41 =#
        w̃ = _symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, Az_qᶜᶜᶠ, W)
        #= none:42 =#
        uᴿ = _biased_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, bias(w̃), u)
        #= none:44 =#
        return w̃ * uᴿ
    end
#= none:47 =#
#= none:47 =# @inline function advective_momentum_flux_Uv(i, j, k, grid, scheme::UpwindScheme, U, v)
        #= none:47 =#
        #= none:49 =#
        ũ = _symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, Ax_qᶠᶜᶜ, U)
        #= none:50 =#
        vᴿ = _biased_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, bias(ũ), v)
        #= none:52 =#
        return ũ * vᴿ
    end
#= none:55 =#
#= none:55 =# @inline function advective_momentum_flux_Vv(i, j, k, grid, scheme::UpwindScheme, V, v)
        #= none:55 =#
        #= none:57 =#
        ṽ = _symmetric_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme, Ay_qᶜᶠᶜ, V)
        #= none:58 =#
        vᴿ = _biased_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme, bias(ṽ), v)
        #= none:60 =#
        return ṽ * vᴿ
    end
#= none:63 =#
#= none:63 =# @inline function advective_momentum_flux_Wv(i, j, k, grid, scheme::UpwindScheme, W, v)
        #= none:63 =#
        #= none:65 =#
        w̃ = _symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, Az_qᶜᶜᶠ, W)
        #= none:66 =#
        vᴿ = _biased_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, bias(w̃), v)
        #= none:68 =#
        return w̃ * vᴿ
    end
#= none:71 =#
#= none:71 =# @inline function advective_momentum_flux_Uw(i, j, k, grid, scheme::UpwindScheme, U, w)
        #= none:71 =#
        #= none:73 =#
        ũ = _symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, Ax_qᶠᶜᶜ, U)
        #= none:74 =#
        wᴿ = _biased_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, bias(ũ), w)
        #= none:76 =#
        return ũ * wᴿ
    end
#= none:79 =#
#= none:79 =# @inline function advective_momentum_flux_Vw(i, j, k, grid, scheme::UpwindScheme, V, w)
        #= none:79 =#
        #= none:81 =#
        ṽ = _symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, Ay_qᶜᶠᶜ, V)
        #= none:82 =#
        wᴿ = _biased_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, bias(ṽ), w)
        #= none:84 =#
        return ṽ * wᴿ
    end
#= none:87 =#
#= none:87 =# @inline function advective_momentum_flux_Ww(i, j, k, grid, scheme::UpwindScheme, W, w)
        #= none:87 =#
        #= none:89 =#
        w̃ = _symmetric_interpolate_zᵃᵃᶜ(i, j, k, grid, scheme, Az_qᶜᶜᶠ, W)
        #= none:90 =#
        wᴿ = _biased_interpolate_zᵃᵃᶜ(i, j, k, grid, scheme, bias(w̃), w)
        #= none:92 =#
        return w̃ * wᴿ
    end
#= none:99 =#
#= none:99 =# @inline function advective_tracer_flux_x(i, j, k, grid, scheme::UpwindScheme, U, c)
        #= none:99 =#
        #= none:101 =#
        #= none:101 =# @inbounds ũ = U[i, j, k]
        #= none:102 =#
        cᴿ = _biased_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, bias(ũ), c)
        #= none:104 =#
        return Axᶠᶜᶜ(i, j, k, grid) * ũ * cᴿ
    end
#= none:107 =#
#= none:107 =# @inline function advective_tracer_flux_y(i, j, k, grid, scheme::UpwindScheme, V, c)
        #= none:107 =#
        #= none:109 =#
        #= none:109 =# @inbounds ṽ = V[i, j, k]
        #= none:110 =#
        cᴿ = _biased_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, bias(ṽ), c)
        #= none:112 =#
        return Ayᶜᶠᶜ(i, j, k, grid) * ṽ * cᴿ
    end
#= none:115 =#
#= none:115 =# @inline function advective_tracer_flux_z(i, j, k, grid, scheme::UpwindScheme, W, c)
        #= none:115 =#
        #= none:117 =#
        #= none:117 =# @inbounds w̃ = W[i, j, k]
        #= none:118 =#
        cᴿ = _biased_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, bias(w̃), c)
        #= none:120 =#
        return Azᶜᶜᶠ(i, j, k, grid) * w̃ * cᴿ
    end