
#= none:2 =#
#= none:2 =# @inline _advective_tracer_flux_x(args...) = begin
            #= none:2 =#
            advective_tracer_flux_x(args...)
        end
#= none:3 =#
#= none:3 =# @inline _advective_tracer_flux_y(args...) = begin
            #= none:3 =#
            advective_tracer_flux_y(args...)
        end
#= none:4 =#
#= none:4 =# @inline _advective_tracer_flux_z(args...) = begin
            #= none:4 =#
            advective_tracer_flux_z(args...)
        end
#= none:11 =#
#= none:11 =# @inline _advective_tracer_flux_x(i, j, k, grid, ::Nothing, args...) = begin
            #= none:11 =#
            zero(grid)
        end
#= none:12 =#
#= none:12 =# @inline _advective_tracer_flux_y(i, j, k, grid, ::Nothing, args...) = begin
            #= none:12 =#
            zero(grid)
        end
#= none:13 =#
#= none:13 =# @inline _advective_tracer_flux_z(i, j, k, grid, ::Nothing, args...) = begin
            #= none:13 =#
            zero(grid)
        end
#= none:19 =#
#= none:19 =# Core.@doc "    div_uc(i, j, k, grid, advection, U, c)\n\nCalculate the divergence of the flux of a tracer quantity ``c`` being advected by\na velocity field, ``𝛁⋅(𝐯 c)``,\n\n```\n1/V * [δxᶜᵃᵃ(Ax * u * ℑxᶠᵃᵃ(c)) + δyᵃᶜᵃ(Ay * v * ℑyᵃᶠᵃ(c)) + δzᵃᵃᶜ(Az * w * ℑzᵃᵃᶠ(c))]\n```\nwhich ends up at the location `ccc`.\n" #= none:30 =# @inline(function div_Uc(i, j, k, grid, advection, U, c)
            #= none:30 =#
            #= none:31 =#
            return (1 / Vᶜᶜᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, _advective_tracer_flux_x, advection, U.u, c) + δyᵃᶜᵃ(i, j, k, grid, _advective_tracer_flux_y, advection, U.v, c) + δzᵃᵃᶜ(i, j, k, grid, _advective_tracer_flux_z, advection, U.w, c))
        end)
#= none:37 =#
#= none:37 =# @inline div_Uc(i, j, k, grid, advection, ::ZeroU, c) = begin
            #= none:37 =#
            zero(grid)
        end
#= none:38 =#
#= none:38 =# @inline div_Uc(i, j, k, grid, advection, U, ::ZeroField) = begin
            #= none:38 =#
            zero(grid)
        end
#= none:39 =#
#= none:39 =# @inline div_Uc(i, j, k, grid, advection, ::ZeroU, ::ZeroField) = begin
            #= none:39 =#
            zero(grid)
        end
#= none:41 =#
#= none:41 =# @inline div_Uc(i, j, k, grid, ::Nothing, U, c) = begin
            #= none:41 =#
            zero(grid)
        end
#= none:42 =#
#= none:42 =# @inline div_Uc(i, j, k, grid, ::Nothing, ::ZeroU, c) = begin
            #= none:42 =#
            zero(grid)
        end
#= none:43 =#
#= none:43 =# @inline div_Uc(i, j, k, grid, ::Nothing, U, ::ZeroField) = begin
            #= none:43 =#
            zero(grid)
        end
#= none:44 =#
#= none:44 =# @inline div_Uc(i, j, k, grid, ::Nothing, ::ZeroU, ::ZeroField) = begin
            #= none:44 =#
            zero(grid)
        end