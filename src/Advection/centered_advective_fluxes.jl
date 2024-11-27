
#= none:7 =#
const CenteredScheme = AbstractCenteredAdvectionScheme
#= none:15 =#
#= none:15 =# @inline advective_momentum_flux_Uu(i, j, k, grid, scheme::CenteredScheme, U, u) = begin
            #= none:15 =#
            #= none:15 =# @inbounds Axᶜᶜᶜ(i, j, k, grid) * _symmetric_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme, U) * _symmetric_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme, u)
        end
#= none:16 =#
#= none:16 =# @inline advective_momentum_flux_Vu(i, j, k, grid, scheme::CenteredScheme, V, u) = begin
            #= none:16 =#
            #= none:16 =# @inbounds Ayᶠᶠᶜ(i, j, k, grid) * _symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, V) * _symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, u)
        end
#= none:17 =#
#= none:17 =# @inline advective_momentum_flux_Wu(i, j, k, grid, scheme::CenteredScheme, W, u) = begin
            #= none:17 =#
            #= none:17 =# @inbounds Azᶠᶜᶠ(i, j, k, grid) * _symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, W) * _symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, u)
        end
#= none:19 =#
#= none:19 =# @inline advective_momentum_flux_Uv(i, j, k, grid, scheme::CenteredScheme, U, v) = begin
            #= none:19 =#
            #= none:19 =# @inbounds Axᶠᶠᶜ(i, j, k, grid) * _symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, U) * _symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, v)
        end
#= none:20 =#
#= none:20 =# @inline advective_momentum_flux_Vv(i, j, k, grid, scheme::CenteredScheme, V, v) = begin
            #= none:20 =#
            #= none:20 =# @inbounds Ayᶜᶜᶜ(i, j, k, grid) * _symmetric_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme, V) * _symmetric_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme, v)
        end
#= none:21 =#
#= none:21 =# @inline advective_momentum_flux_Wv(i, j, k, grid, scheme::CenteredScheme, W, v) = begin
            #= none:21 =#
            #= none:21 =# @inbounds Azᶜᶠᶠ(i, j, k, grid) * _symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, W) * _symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, v)
        end
#= none:23 =#
#= none:23 =# @inline advective_momentum_flux_Uw(i, j, k, grid, scheme::CenteredScheme, U, w) = begin
            #= none:23 =#
            #= none:23 =# @inbounds Axᶠᶜᶠ(i, j, k, grid) * _symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, U) * _symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, w)
        end
#= none:24 =#
#= none:24 =# @inline advective_momentum_flux_Vw(i, j, k, grid, scheme::CenteredScheme, V, w) = begin
            #= none:24 =#
            #= none:24 =# @inbounds Ayᶜᶠᶠ(i, j, k, grid) * _symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, V) * _symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, w)
        end
#= none:25 =#
#= none:25 =# @inline advective_momentum_flux_Ww(i, j, k, grid, scheme::CenteredScheme, W, w) = begin
            #= none:25 =#
            #= none:25 =# @inbounds Azᶜᶜᶜ(i, j, k, grid) * _symmetric_interpolate_zᵃᵃᶜ(i, j, k, grid, scheme, W) * _symmetric_interpolate_zᵃᵃᶜ(i, j, k, grid, scheme, w)
        end
#= none:31 =#
#= none:31 =# @inline advective_tracer_flux_x(i, j, k, grid, scheme::CenteredScheme, U, c) = begin
            #= none:31 =#
            #= none:31 =# @inbounds Ax_qᶠᶜᶜ(i, j, k, grid, U) * _symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, c)
        end
#= none:32 =#
#= none:32 =# @inline advective_tracer_flux_y(i, j, k, grid, scheme::CenteredScheme, V, c) = begin
            #= none:32 =#
            #= none:32 =# @inbounds Ay_qᶜᶠᶜ(i, j, k, grid, V) * _symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, c)
        end
#= none:33 =#
#= none:33 =# @inline advective_tracer_flux_z(i, j, k, grid, scheme::CenteredScheme, W, c) = begin
            #= none:33 =#
            #= none:33 =# @inbounds Az_qᶜᶜᶠ(i, j, k, grid, W) * _symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, c)
        end