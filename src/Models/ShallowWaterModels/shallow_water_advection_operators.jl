
#= none:1 =#
using Oceananigans.Advection: _advective_momentum_flux_Uu, _advective_momentum_flux_Uv, _advective_momentum_flux_Vu, _advective_momentum_flux_Vv, _advective_tracer_flux_x, _advective_tracer_flux_y, horizontal_advection_U, horizontal_advection_V, bernoulli_head_U, bernoulli_head_V
#= none:13 =#
using Oceananigans.Grids: AbstractGrid
#= none:14 =#
using Oceananigans.Operators: Ax_qᶠᶜᶜ, Ay_qᶜᶠᶜ
#= none:21 =#
#= none:21 =# @inline momentum_flux_huu(i, j, k, grid, advection, solution) = begin
            #= none:21 =#
            #= none:22 =# @inbounds _advective_momentum_flux_Uu(i, j, k, grid, advection, solution[1], solution[1]) / solution.h[i, j, k]
        end
#= none:24 =#
#= none:24 =# @inline momentum_flux_hvu(i, j, k, grid, advection, solution) = begin
            #= none:24 =#
            #= none:25 =# @inbounds _advective_momentum_flux_Vu(i, j, k, grid, advection, solution[2], solution[1]) / ℑxyᶠᶠᵃ(i, j, k, grid, solution.h)
        end
#= none:27 =#
#= none:27 =# @inline momentum_flux_huv(i, j, k, grid, advection, solution) = begin
            #= none:27 =#
            #= none:28 =# @inbounds _advective_momentum_flux_Uv(i, j, k, grid, advection, solution[1], solution[2]) / ℑxyᶠᶠᵃ(i, j, k, grid, solution.h)
        end
#= none:30 =#
#= none:30 =# @inline momentum_flux_hvv(i, j, k, grid, advection, solution) = begin
            #= none:30 =#
            #= none:31 =# @inbounds _advective_momentum_flux_Vv(i, j, k, grid, advection, solution[2], solution[2]) / solution.h[i, j, k]
        end
#= none:37 =#
#= none:37 =# @inline div_mom_u(i, j, k, grid, advection, solution, formulation) = begin
            #= none:37 =#
            (1 / Azᶠᶜᶜ(i, j, k, grid)) * (δxᶠᵃᵃ(i, j, k, grid, momentum_flux_huu, advection, solution) + δyᵃᶜᵃ(i, j, k, grid, momentum_flux_hvu, advection, solution))
        end
#= none:41 =#
#= none:41 =# @inline div_mom_v(i, j, k, grid, advection, solution, formulation) = begin
            #= none:41 =#
            (1 / Azᶜᶠᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, momentum_flux_huv, advection, solution) + δyᵃᶠᵃ(i, j, k, grid, momentum_flux_hvv, advection, solution))
        end
#= none:45 =#
#= none:45 =# @inline div_mom_u(i, j, k, grid, advection, solution, ::VectorInvariantFormulation) = begin
            #= none:45 =#
            +(horizontal_advection_U(i, j, k, grid, advection, solution[1], solution[2])) + bernoulli_head_U(i, j, k, grid, advection, solution[1], solution[2])
        end
#= none:49 =#
#= none:49 =# @inline div_mom_v(i, j, k, grid, advection, solution, ::VectorInvariantFormulation) = begin
            #= none:49 =#
            +(horizontal_advection_V(i, j, k, grid, advection, solution[1], solution[2])) + bernoulli_head_V(i, j, k, grid, advection, solution[1], solution[2])
        end
#= none:54 =#
#= none:54 =# @inline (div_mom_u(i, j, k, grid::AbstractGrid{FT}, ::Nothing, solution, formulation) where FT) = begin
            #= none:54 =#
            zero(FT)
        end
#= none:55 =#
#= none:55 =# @inline (div_mom_v(i, j, k, grid::AbstractGrid{FT}, ::Nothing, solution, formulation) where FT) = begin
            #= none:55 =#
            zero(FT)
        end
#= none:56 =#
#= none:56 =# @inline (div_mom_u(i, j, k, grid::AbstractGrid{FT}, ::Nothing, solution, ::VectorInvariantFormulation) where FT) = begin
            #= none:56 =#
            zero(FT)
        end
#= none:57 =#
#= none:57 =# @inline (div_mom_v(i, j, k, grid::AbstractGrid{FT}, ::Nothing, solution, ::VectorInvariantFormulation) where FT) = begin
            #= none:57 =#
            zero(FT)
        end
#= none:63 =#
#= none:63 =# Core.@doc "    div_Uh(i, j, k, grid, advection, solution, formulation)\n\nCalculate the divergence of the mass flux into a cell,\n\n```\n1/Az * [δxᶜᵃᵃ(Δy * uh) + δyᵃᶜᵃ(Δx * vh)]\n```\n\nwhich ends up at the location `ccc`.\n" #= none:74 =# @inline(function div_Uh(i, j, k, grid, advection, solution, formulation)
            #= none:74 =#
            #= none:75 =#
            return (1 / Azᶜᶜᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Δy_qᶠᶜᶜ, solution[1]) + δyᵃᶜᵃ(i, j, k, grid, Δx_qᶜᶠᶜ, solution[2]))
        end)
#= none:79 =#
#= none:79 =# @inline div_Uh(i, j, k, grid, advection, solution, formulation::VectorInvariantFormulation) = begin
            #= none:79 =#
            div_Uc(i, j, k, grid, advection, solution, solution.h, formulation)
        end
#= none:86 =#
#= none:86 =# @inline transport_tracer_flux_x(i, j, k, grid, advection, uh, h, c) = begin
            #= none:86 =#
            #= none:87 =# @inbounds _advective_tracer_flux_x(i, j, k, grid, advection, uh, c) / ℑxᶠᵃᵃ(i, j, k, grid, h)
        end
#= none:89 =#
#= none:89 =# @inline transport_tracer_flux_y(i, j, k, grid, advection, vh, h, c) = begin
            #= none:89 =#
            #= none:90 =# @inbounds _advective_tracer_flux_y(i, j, k, grid, advection, vh, c) / ℑyᵃᶠᵃ(i, j, k, grid, h)
        end
#= none:92 =#
"    div_Uc(i, j, k, grid, advection, solution, c, formulation)\n\nCalculate the divergence of the flux of a tracer quantity ``c`` being advected by\na velocity field ``𝐔 = (u, v)``, ``𝛁·(𝐔c)``,\n\n```\n1/Az * [δxᶜᵃᵃ(Δy * uh * ℑxᶠᵃᵃ(c) / h) + δyᵃᶜᵃ(Δx * vh * ℑyᵃᶠᵃ(c) / h)]\n```\n\nwhich ends up at the location `ccc`.\n"
#= none:105 =#
#= none:105 =# @inline function div_Uc(i, j, k, grid, advection, solution, c, formulation)
        #= none:105 =#
        #= none:106 =#
        return (1 / Azᶜᶜᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, transport_tracer_flux_x, advection, solution[1], solution.h, c) + δyᵃᶜᵃ(i, j, k, grid, transport_tracer_flux_y, advection, solution[2], solution.h, c))
    end
#= none:110 =#
#= none:110 =# @inline function div_Uc(i, j, k, grid, advection, solution, c, ::VectorInvariantFormulation)
        #= none:110 =#
        #= none:111 =#
        return (1 / Azᶜᶜᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, _advective_tracer_flux_x, advection, solution[1], c) + δyᵃᶜᵃ(i, j, k, grid, _advective_tracer_flux_y, advection, solution[2], c))
    end
#= none:116 =#
#= none:116 =# @inline div_Uc(i, j, k, grid::AbstractGrid, ::Nothing, solution, c, formulation) = begin
            #= none:116 =#
            zero(grid)
        end
#= none:117 =#
#= none:117 =# @inline div_Uh(i, j, k, grid::AbstractGrid, ::Nothing, solution, formulation) = begin
            #= none:117 =#
            zero(grid)
        end
#= none:120 =#
#= none:120 =# @inline div_Uc(i, j, k, grid::AbstractGrid, ::Nothing, solution, c, ::VectorInvariantFormulation) = begin
            #= none:120 =#
            zero(grid)
        end
#= none:121 =#
#= none:121 =# @inline div_Uh(i, j, k, grid::AbstractGrid, ::Nothing, solution, ::VectorInvariantFormulation) = begin
            #= none:121 =#
            zero(grid)
        end
#= none:123 =#
#= none:123 =# @inline u(i, j, k, grid, solution) = begin
            #= none:123 =#
            #= none:123 =# @inbounds solution.uh[i, j, k] / ℑxᶠᵃᵃ(i, j, k, grid, solution.h)
        end
#= none:124 =#
#= none:124 =# @inline v(i, j, k, grid, solution) = begin
            #= none:124 =#
            #= none:124 =# @inbounds solution.vh[i, j, k] / ℑyᵃᶠᵃ(i, j, k, grid, solution.h)
        end
#= none:126 =#
#= none:126 =# Core.@doc "    c_div_U(i, j, k, grid, solution, c, formulation)\n\nCalculate the product of the tracer concentration ``c`` with \nthe horizontal divergence of the velocity field ``𝐔 = (u, v)``, ``c ∇·𝐔``,\n\n```\nc * 1/Az * [δxᶜᵃᵃ(Δy * uh / h) + δyᵃᶜᵃ(Δx * vh / h)]\n```\n\nwhich ends up at the location `ccc`.\n" #= none:138 =# @inline(c_div_U(i, j, k, grid, solution, c, formulation) = begin
                #= none:138 =#
                #= none:139 =# @inbounds ((c[i, j, k] * 1) / Azᶜᶜᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Δy_qᶠᶜᶜ, u, solution) + δyᵃᶜᵃ(i, j, k, grid, Δx_qᶜᶠᶜ, v, solution))
            end)
#= none:141 =#
#= none:141 =# @inline c_div_U(i, j, k, grid, solution, c, ::VectorInvariantFormulation) = begin
            #= none:141 =#
            #= none:142 =# @inbounds ((c[i, j, k] * 1) / Azᶜᶜᶜ(i, j, k, grid)) * (δxᶜᵃᵃ(i, j, k, grid, Δy_qᶠᶜᶜ, solution[1]) + δyᵃᶜᵃ(i, j, k, grid, Δx_qᶜᶠᶜ, solution[2]))
        end
#= none:145 =#
#= none:145 =# @inline (c_div_Uc(i, j, k, grid::AbstractGrid{FT}, ::Nothing, solution, c, formulation) where FT) = begin
            #= none:145 =#
            zero(FT)
        end