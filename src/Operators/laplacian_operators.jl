
#= none:5 =#
#= none:5 =# @inline function ∇²hᶜᶜᶜ(i, j, k, grid, c)
        #= none:5 =#
        #= none:6 =#
        return (1 / Vᶜᶜᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Ax_∂xᶠᶜᶜ, c) + δyᵃᶜᵃ(i, j, k, grid, Ay_∂yᶜᶠᶜ, c))
    end
#= none:10 =#
#= none:10 =# @inline function ∇²hᶠᶜᶜ(i, j, k, grid, u)
        #= none:10 =#
        #= none:11 =#
        return (1 / Vᶠᶜᶜ(i, j, k, grid)) * (δxᶠᵃᵃ(i, j, k, grid, Ax_∂xᶜᶜᶜ, u) + δyᵃᶜᵃ(i, j, k, grid, Ay_∂yᶠᶠᶜ, u))
    end
#= none:15 =#
#= none:15 =# @inline function ∇²hᶜᶠᶜ(i, j, k, grid, v)
        #= none:15 =#
        #= none:16 =#
        return (1 / Vᶜᶠᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Ax_∂xᶠᶠᶜ, v) + δyᵃᶠᵃ(i, j, k, grid, Ay_∂yᶜᶜᶜ, v))
    end
#= none:20 =#
#= none:20 =# @inline function ∇²hᶜᶜᶠ(i, j, k, grid, w)
        #= none:20 =#
        #= none:21 =#
        return (1 / Vᶜᶠᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Ax_∂xᶠᶠᶜ, v) + δyᵃᶠᵃ(i, j, k, grid, Ay_∂yᶜᶜᶜ, v))
    end
#= none:25 =#
#= none:25 =# Core.@doc "    ∇²ᶜᶜᶜ(i, j, k, grid, c)\n\nCalculate the Laplacian of ``c`` via\n\n```julia\n1/V * [δxᶜᵃᵃ(Ax * ∂xᶠᵃᵃ(c)) + δyᵃᶜᵃ(Ay * ∂yᵃᶠᵃ(c)) + δzᵃᵃᶜ(Az * ∂zᵃᵃᶠ(c))]\n```\n\nwhich ends up at the location `ccc`.\n" #= none:36 =# @inline(function ∇²ᶜᶜᶜ(i, j, k, grid, c)
            #= none:36 =#
            #= none:37 =#
            return (1 / Vᶜᶜᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Ax_∂xᶠᶜᶜ, c) + δyᵃᶜᵃ(i, j, k, grid, Ay_∂yᶜᶠᶜ, c) + δzᵃᵃᶜ(i, j, k, grid, Az_∂zᶜᶜᶠ, c))
        end)
#= none:42 =#
#= none:42 =# @inline function ∇²ᶠᶜᶜ(i, j, k, grid, u)
        #= none:42 =#
        #= none:43 =#
        return (1 / Vᶠᶜᶜ(i, j, k, grid)) * (δxᶠᵃᵃ(i, j, k, grid, Ax_∂xᶜᶜᶜ, u) + δyᵃᶜᵃ(i, j, k, grid, Ay_∂yᶠᶠᶜ, u) + δzᵃᵃᶜ(i, j, k, grid, Az_∂zᶠᶜᶠ, u))
    end
#= none:48 =#
#= none:48 =# @inline function ∇²ᶜᶠᶜ(i, j, k, grid, v)
        #= none:48 =#
        #= none:49 =#
        return (1 / Vᶜᶠᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Ax_∂xᶠᶠᶜ, v) + δyᵃᶠᵃ(i, j, k, grid, Ay_∂yᶜᶜᶜ, v) + δzᵃᵃᶜ(i, j, k, grid, Az_∂zᶜᶠᶠ, v))
    end
#= none:54 =#
#= none:54 =# @inline function ∇²ᶜᶜᶠ(i, j, k, grid, w)
        #= none:54 =#
        #= none:55 =#
        return (1 / Vᶜᶜᶠ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Ax_∂xᶠᶜᶠ, w) + δyᵃᶜᵃ(i, j, k, grid, Ay_∂yᶜᶠᶠ, w) + δzᵃᵃᶠ(i, j, k, grid, Az_∂zᶜᶜᶜ, w))
    end