
#= none:1 =#
using Oceananigans.Fields: ZeroField
#= none:8 =#
#= none:8 =# @inline _advective_momentum_flux_Uu(args...) = begin
            #= none:8 =#
            advective_momentum_flux_Uu(args...)
        end
#= none:9 =#
#= none:9 =# @inline _advective_momentum_flux_Vu(args...) = begin
            #= none:9 =#
            advective_momentum_flux_Vu(args...)
        end
#= none:10 =#
#= none:10 =# @inline _advective_momentum_flux_Wu(args...) = begin
            #= none:10 =#
            advective_momentum_flux_Wu(args...)
        end
#= none:12 =#
#= none:12 =# @inline _advective_momentum_flux_Uv(args...) = begin
            #= none:12 =#
            advective_momentum_flux_Uv(args...)
        end
#= none:13 =#
#= none:13 =# @inline _advective_momentum_flux_Vv(args...) = begin
            #= none:13 =#
            advective_momentum_flux_Vv(args...)
        end
#= none:14 =#
#= none:14 =# @inline _advective_momentum_flux_Wv(args...) = begin
            #= none:14 =#
            advective_momentum_flux_Wv(args...)
        end
#= none:16 =#
#= none:16 =# @inline _advective_momentum_flux_Uw(args...) = begin
            #= none:16 =#
            advective_momentum_flux_Uw(args...)
        end
#= none:17 =#
#= none:17 =# @inline _advective_momentum_flux_Vw(args...) = begin
            #= none:17 =#
            advective_momentum_flux_Vw(args...)
        end
#= none:18 =#
#= none:18 =# @inline _advective_momentum_flux_Ww(args...) = begin
            #= none:18 =#
            advective_momentum_flux_Ww(args...)
        end
#= none:20 =#
const ZeroU = NamedTuple{(:u, :v, :w), Tuple{ZeroField, ZeroField, ZeroField}}
#= none:23 =#
#= none:23 =# @inline div_𝐯u(i, j, k, grid, advection, ::ZeroU, u) = begin
            #= none:23 =#
            zero(grid)
        end
#= none:24 =#
#= none:24 =# @inline div_𝐯v(i, j, k, grid, advection, ::ZeroU, v) = begin
            #= none:24 =#
            zero(grid)
        end
#= none:25 =#
#= none:25 =# @inline div_𝐯w(i, j, k, grid, advection, ::ZeroU, w) = begin
            #= none:25 =#
            zero(grid)
        end
#= none:27 =#
#= none:27 =# @inline div_𝐯u(i, j, k, grid, advection, U, ::ZeroField) = begin
            #= none:27 =#
            zero(grid)
        end
#= none:28 =#
#= none:28 =# @inline div_𝐯v(i, j, k, grid, advection, U, ::ZeroField) = begin
            #= none:28 =#
            zero(grid)
        end
#= none:29 =#
#= none:29 =# @inline div_𝐯w(i, j, k, grid, advection, U, ::ZeroField) = begin
            #= none:29 =#
            zero(grid)
        end
#= none:31 =#
#= none:31 =# @inline div_𝐯u(i, j, k, grid, advection, ::ZeroU, ::ZeroField) = begin
            #= none:31 =#
            zero(grid)
        end
#= none:32 =#
#= none:32 =# @inline div_𝐯v(i, j, k, grid, advection, ::ZeroU, ::ZeroField) = begin
            #= none:32 =#
            zero(grid)
        end
#= none:33 =#
#= none:33 =# @inline div_𝐯w(i, j, k, grid, advection, ::ZeroU, ::ZeroField) = begin
            #= none:33 =#
            zero(grid)
        end
#= none:35 =#
#= none:35 =# Core.@doc "    div_𝐯u(i, j, k, grid, advection, U, u)\n\nCalculate the advection of momentum in the ``x``-direction using the conservative form, ``𝛁⋅(𝐯 u)``,\n\n```\n1/Vᵘ * [δxᶠᵃᵃ(ℑxᶜᵃᵃ(Ax * u) * ℑxᶜᵃᵃ(u)) + δy_fca(ℑxᶠᵃᵃ(Ay * v) * ℑyᵃᶠᵃ(u)) + δz_fac(ℑxᶠᵃᵃ(Az * w) * ℑzᵃᵃᶠ(u))]\n```\n\nwhich ends up at the location `fcc`.\n" #= none:46 =# @inline(function div_𝐯u(i, j, k, grid, advection, U, u)
            #= none:46 =#
            #= none:47 =#
            return (1 / Vᶠᶜᶜ(i, j, k, grid)) * (δxᶠᵃᵃ(i, j, k, grid, _advective_momentum_flux_Uu, advection, U[1], u) + δyᵃᶜᵃ(i, j, k, grid, _advective_momentum_flux_Vu, advection, U[2], u) + δzᵃᵃᶜ(i, j, k, grid, _advective_momentum_flux_Wu, advection, U[3], u))
        end)
#= none:52 =#
#= none:52 =# Core.@doc "    div_𝐯v(i, j, k, grid, advection, U, v)\n\nCalculate the advection of momentum in the ``y``-direction using the conservative form, ``𝛁⋅(𝐯 v)``,\n\n```\n1/Vʸ * [δx_cfa(ℑyᵃᶠᵃ(Ax * u) * ℑxᶠᵃᵃ(v)) + δyᵃᶠᵃ(ℑyᵃᶜᵃ(Ay * v) * ℑyᵃᶜᵃ(v)) + δz_afc(ℑxᶠᵃᵃ(Az * w) * ℑzᵃᵃᶠ(w))]\n```\n\nwhich ends up at the location `cfc`.\n" #= none:63 =# @inline(function div_𝐯v(i, j, k, grid, advection, U, v)
            #= none:63 =#
            #= none:64 =#
            return (1 / Vᶜᶠᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, _advective_momentum_flux_Uv, advection, U[1], v) + δyᵃᶠᵃ(i, j, k, grid, _advective_momentum_flux_Vv, advection, U[2], v) + δzᵃᵃᶜ(i, j, k, grid, _advective_momentum_flux_Wv, advection, U[3], v))
        end)
#= none:69 =#
#= none:69 =# Core.@doc "    div_𝐯w(i, j, k, grid, advection, U, w)\n\nCalculate the advection of momentum in the ``z``-direction using the conservative form, ``𝛁⋅(𝐯 w)``,\n\n```\n1/Vʷ * [δx_caf(ℑzᵃᵃᶠ(Ax * u) * ℑxᶠᵃᵃ(w)) + δy_acf(ℑzᵃᵃᶠ(Ay * v) * ℑyᵃᶠᵃ(w)) + δzᵃᵃᶠ(ℑzᵃᵃᶜ(Az * w) * ℑzᵃᵃᶜ(w))]\n```\nwhich ends up at the location `ccf`.\n" #= none:79 =# @inline(function div_𝐯w(i, j, k, grid, advection, U, w)
            #= none:79 =#
            #= none:80 =#
            return (1 / Vᶜᶜᶠ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, _advective_momentum_flux_Uw, advection, U[1], w) + δyᵃᶜᵃ(i, j, k, grid, _advective_momentum_flux_Vw, advection, U[2], w) + δzᵃᵃᶠ(i, j, k, grid, _advective_momentum_flux_Ww, advection, U[3], w))
        end)
#= none:90 =#
#= none:90 =# @inline _advective_momentum_flux_Uu(i, j, k, grid, ::Nothing, args...) = begin
            #= none:90 =#
            zero(grid)
        end
#= none:91 =#
#= none:91 =# @inline _advective_momentum_flux_Uv(i, j, k, grid, ::Nothing, args...) = begin
            #= none:91 =#
            zero(grid)
        end
#= none:92 =#
#= none:92 =# @inline _advective_momentum_flux_Uw(i, j, k, grid, ::Nothing, args...) = begin
            #= none:92 =#
            zero(grid)
        end
#= none:94 =#
#= none:94 =# @inline _advective_momentum_flux_Vu(i, j, k, grid, ::Nothing, args...) = begin
            #= none:94 =#
            zero(grid)
        end
#= none:95 =#
#= none:95 =# @inline _advective_momentum_flux_Vv(i, j, k, grid, ::Nothing, args...) = begin
            #= none:95 =#
            zero(grid)
        end
#= none:96 =#
#= none:96 =# @inline _advective_momentum_flux_Vw(i, j, k, grid, ::Nothing, args...) = begin
            #= none:96 =#
            zero(grid)
        end
#= none:98 =#
#= none:98 =# @inline _advective_momentum_flux_Wu(i, j, k, grid, ::Nothing, args...) = begin
            #= none:98 =#
            zero(grid)
        end
#= none:99 =#
#= none:99 =# @inline _advective_momentum_flux_Wv(i, j, k, grid, ::Nothing, args...) = begin
            #= none:99 =#
            zero(grid)
        end
#= none:100 =#
#= none:100 =# @inline _advective_momentum_flux_Ww(i, j, k, grid, ::Nothing, args...) = begin
            #= none:100 =#
            zero(grid)
        end