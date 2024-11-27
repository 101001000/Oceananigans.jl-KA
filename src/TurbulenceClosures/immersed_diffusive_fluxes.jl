
#= none:1 =#
using Oceananigans.BoundaryConditions: Flux, Value, Gradient, BoundaryCondition, ContinuousBoundaryFunction
#= none:2 =#
using Oceananigans.BoundaryConditions: getbc, regularize_boundary_condition, LeftBoundary, RightBoundary
#= none:3 =#
using Oceananigans.BoundaryConditions: FBC, ZFBC
#= none:4 =#
using Oceananigans.BoundaryConditions: DefaultBoundaryCondition
#= none:5 =#
using Oceananigans.Operators: index_left, index_right, Δx, Δy, Δz, div
#= none:7 =#
using Oceananigans.Advection: conditional_flux
#= none:9 =#
using Oceananigans.Advection: conditional_flux_ccc, conditional_flux_ffc, conditional_flux_fcf, conditional_flux_cff, conditional_flux_fcc, conditional_flux_cfc, conditional_flux_ccf
#= none:17 =#
using Oceananigans.ImmersedBoundaries
#= none:18 =#
using Oceananigans.ImmersedBoundaries: GFIBG, IBC
#= none:20 =#
const IBG = ImmersedBoundaryGrid
#= none:27 =#
#= none:27 =# @inline _viscous_flux_ux(i, j, k, ibg::IBG, args...) = begin
            #= none:27 =#
            conditional_flux_ccc(i, j, k, ibg, zero(ibg), viscous_flux_ux(i, j, k, ibg, args...))
        end
#= none:28 =#
#= none:28 =# @inline _viscous_flux_uy(i, j, k, ibg::IBG, args...) = begin
            #= none:28 =#
            conditional_flux_ffc(i, j, k, ibg, zero(ibg), viscous_flux_uy(i, j, k, ibg, args...))
        end
#= none:29 =#
#= none:29 =# @inline _viscous_flux_uz(i, j, k, ibg::IBG, args...) = begin
            #= none:29 =#
            conditional_flux_fcf(i, j, k, ibg, zero(ibg), viscous_flux_uz(i, j, k, ibg, args...))
        end
#= none:32 =#
#= none:32 =# @inline _viscous_flux_vx(i, j, k, ibg::IBG, args...) = begin
            #= none:32 =#
            conditional_flux_ffc(i, j, k, ibg, zero(ibg), viscous_flux_vx(i, j, k, ibg, args...))
        end
#= none:33 =#
#= none:33 =# @inline _viscous_flux_vy(i, j, k, ibg::IBG, args...) = begin
            #= none:33 =#
            conditional_flux_ccc(i, j, k, ibg, zero(ibg), viscous_flux_vy(i, j, k, ibg, args...))
        end
#= none:34 =#
#= none:34 =# @inline _viscous_flux_vz(i, j, k, ibg::IBG, args...) = begin
            #= none:34 =#
            conditional_flux_cff(i, j, k, ibg, zero(ibg), viscous_flux_vz(i, j, k, ibg, args...))
        end
#= none:37 =#
#= none:37 =# @inline _viscous_flux_wx(i, j, k, ibg::IBG, args...) = begin
            #= none:37 =#
            conditional_flux_fcf(i, j, k, ibg, zero(ibg), viscous_flux_wx(i, j, k, ibg, args...))
        end
#= none:38 =#
#= none:38 =# @inline _viscous_flux_wy(i, j, k, ibg::IBG, args...) = begin
            #= none:38 =#
            conditional_flux_cff(i, j, k, ibg, zero(ibg), viscous_flux_wy(i, j, k, ibg, args...))
        end
#= none:39 =#
#= none:39 =# @inline _viscous_flux_wz(i, j, k, ibg::IBG, args...) = begin
            #= none:39 =#
            conditional_flux_ccc(i, j, k, ibg, zero(ibg), viscous_flux_wz(i, j, k, ibg, args...))
        end
#= none:42 =#
#= none:42 =# @inline _diffusive_flux_x(i, j, k, ibg::IBG, args...) = begin
            #= none:42 =#
            conditional_flux_fcc(i, j, k, ibg, zero(ibg), diffusive_flux_x(i, j, k, ibg, args...))
        end
#= none:43 =#
#= none:43 =# @inline _diffusive_flux_y(i, j, k, ibg::IBG, args...) = begin
            #= none:43 =#
            conditional_flux_cfc(i, j, k, ibg, zero(ibg), diffusive_flux_y(i, j, k, ibg, args...))
        end
#= none:44 =#
#= none:44 =# @inline _diffusive_flux_z(i, j, k, ibg::IBG, args...) = begin
            #= none:44 =#
            conditional_flux_ccf(i, j, k, ibg, zero(ibg), diffusive_flux_z(i, j, k, ibg, args...))
        end
#= none:56 =#
for side = (:west, :south, :bottom)
    #= none:57 =#
    side_ib_flux = Symbol(side, :_ib_flux)
    #= none:58 =#
    #= none:58 =# @eval begin
            #= none:59 =#
            #= none:59 =# @inline $side_ib_flux(i, j, k, ibg, ::Nothing, args...) = begin
                        #= none:59 =#
                        zero(eltype(ibg))
                    end
            #= none:60 =#
            #= none:60 =# @inline $side_ib_flux(i, j, k, ibg, bc::FBC, loc, c, closure, K, id, args...) = begin
                        #= none:60 =#
                        +(getbc(bc, i, j, k, ibg, args...))
                    end
        end
    #= none:62 =#
end
#= none:64 =#
for side = (:east, :north, :top)
    #= none:65 =#
    side_ib_flux = Symbol(side, :_ib_flux)
    #= none:66 =#
    #= none:66 =# @eval begin
            #= none:67 =#
            #= none:67 =# @inline $side_ib_flux(i, j, k, ibg, ::Nothing, args...) = begin
                        #= none:67 =#
                        zero(eltype(ibg))
                    end
            #= none:68 =#
            #= none:68 =# @inline $side_ib_flux(i, j, k, ibg, bc::FBC, loc, c, closure, K, id, args...) = begin
                        #= none:68 =#
                        -(getbc(bc, i, j, k, ibg, args...))
                    end
        end
    #= none:70 =#
end
#= none:77 =#
const VBC = BoundaryCondition{Value}
#= none:78 =#
const GBC = BoundaryCondition{Gradient}
#= none:79 =#
const VBCorGBC = Union{VBC, GBC}
#= none:80 =#
const ASD = AbstractScalarDiffusivity
#= none:83 =#
#= none:83 =# @inline right_gradient(i, j, k, ibg, κ, Δ, bc::GBC, c, clock, fields) = begin
            #= none:83 =#
            getbc(bc, i, j, k, ibg, clock, fields)
        end
#= none:84 =#
#= none:84 =# @inline left_gradient(i, j, k, ibg, κ, Δ, bc::GBC, c, clock, fields) = begin
            #= none:84 =#
            getbc(bc, i, j, k, ibg, clock, fields)
        end
#= none:86 =#
#= none:86 =# @inline function right_gradient(i, j, k, ibg, κ, Δ, bc::VBC, c, clock, fields)
        #= none:86 =#
        #= none:87 =#
        cᵇ = getbc(bc, i, j, k, ibg, clock, fields)
        #= none:88 =#
        cⁱʲᵏ = #= none:88 =# @inbounds(c[i, j, k])
        #= none:89 =#
        return (2 * (cᵇ - cⁱʲᵏ)) / Δ
    end
#= none:92 =#
#= none:92 =# @inline function left_gradient(i, j, k, ibg, κ, Δ, bc::VBC, c, clock, fields)
        #= none:92 =#
        #= none:93 =#
        cᵇ = getbc(bc, i, j, k, ibg, clock, fields)
        #= none:94 =#
        cⁱʲᵏ = #= none:94 =# @inbounds(c[i, j, k])
        #= none:95 =#
        return (2 * (cⁱʲᵏ - cᵇ)) / Δ
    end
#= none:100 =#
#= none:100 =# @inline flip(::Type{Face}) = begin
            #= none:100 =#
            Center
        end
#= none:101 =#
#= none:101 =# @inline flip(::Type{Center}) = begin
            #= none:101 =#
            Face
        end
#= none:103 =#
#= none:103 =# @inline flip(::Face) = begin
            #= none:103 =#
            Center()
        end
#= none:104 =#
#= none:104 =# @inline flip(::Center) = begin
            #= none:104 =#
            Face()
        end
#= none:106 =#
#= none:106 =# @inline function _west_ib_flux(i, j, k, ibg, bc::VBCorGBC, (LX, LY, LZ), c, closure::ASD, K, id, clock, fields)
        #= none:106 =#
        #= none:107 =#
        Δ = Δx(index_left(i, LX), j, k, ibg, LX, LY, LZ)
        #= none:108 =#
        κ = h_diffusivity(i, j, k, ibg, flip(LX), LY, LZ, closure, K, id, clock)
        #= none:109 =#
        ∇c = left_gradient(i, j, k, ibg, κ, Δ, bc, c, clock, fields)
        #= none:110 =#
        return -κ * ∇c
    end
#= none:113 =#
#= none:113 =# @inline function _east_ib_flux(i, j, k, ibg, bc::VBCorGBC, (LX, LY, LZ), c, closure::ASD, K, id, clock, fields)
        #= none:113 =#
        #= none:114 =#
        Δ = Δx(index_right(i, LX), j, k, ibg, LX, LY, LZ)
        #= none:115 =#
        κ = h_diffusivity(i, j, k, ibg, flip(LX), LY, LZ, closure, K, id, clock)
        #= none:116 =#
        ∇c = right_gradient(i, j, k, ibg, κ, Δ, bc, c, clock, fields)
        #= none:117 =#
        return -κ * ∇c
    end
#= none:120 =#
#= none:120 =# @inline function _south_ib_flux(i, j, k, ibg, bc::VBCorGBC, (LX, LY, LZ), c, closure::ASD, K, id, clock, fields)
        #= none:120 =#
        #= none:121 =#
        Δ = Δy(i, index_left(j, LY), k, ibg, LX, LY, LZ)
        #= none:122 =#
        κ = h_diffusivity(i, j, k, ibg, LX, flip(LY), LZ, closure, K, id, clock)
        #= none:123 =#
        ∇c = left_gradient(i, j, k, ibg, κ, Δ, bc, c, clock, fields)
        #= none:124 =#
        return -κ * ∇c
    end
#= none:127 =#
#= none:127 =# @inline function _north_ib_flux(i, j, k, ibg, bc::VBCorGBC, (LX, LY, LZ), c, closure::ASD, K, id, clock, fields)
        #= none:127 =#
        #= none:128 =#
        Δ = Δy(i, index_right(j, LY), k, ibg, LX, LY, LZ)
        #= none:129 =#
        κ = h_diffusivity(i, j, k, ibg, LX, flip(LY), LZ, closure, K, id, clock)
        #= none:130 =#
        ∇c = right_gradient(i, j, k, ibg, κ, Δ, bc, c, clock, fields)
        #= none:131 =#
        return -κ * ∇c
    end
#= none:134 =#
#= none:134 =# @inline function _bottom_ib_flux(i, j, k, ibg, bc::VBCorGBC, (LX, LY, LZ), c, closure::ASD, K, id, clock, fields)
        #= none:134 =#
        #= none:135 =#
        Δ = Δz(i, j, index_left(k, LZ), ibg, LX, LY, LZ)
        #= none:136 =#
        κ = z_diffusivity(i, j, k, ibg, LX, LY, flip(LZ), closure, K, id, clock)
        #= none:137 =#
        ∇c = left_gradient(i, j, k, ibg, κ, Δ, bc, c, clock, fields)
        #= none:138 =#
        return -κ * ∇c
    end
#= none:141 =#
#= none:141 =# @inline function _top_ib_flux(i, j, k, ibg, bc::VBCorGBC, (LX, LY, LZ), c, closure::ASD, K, id, clock, fields)
        #= none:141 =#
        #= none:142 =#
        Δ = Δz(i, j, index_right(k, LZ), ibg, LX, LY, LZ)
        #= none:143 =#
        κ = z_diffusivity(i, j, k, ibg, LX, LY, flip(LZ), closure, K, id, clock)
        #= none:144 =#
        ∇c = right_gradient(i, j, k, ibg, κ, Δ, bc, c, clock, fields)
        #= none:145 =#
        return -κ * ∇c
    end
#= none:148 =#
sides = [:west, :east, :south, :north, :bottom, :top]
#= none:150 =#
for side = sides
    #= none:151 =#
    flux = Symbol(side, "_ib_flux")
    #= none:152 =#
    _flux = Symbol("_", flux)
    #= none:154 =#
    #= none:154 =# @eval begin
            #= none:155 =#
            #= none:155 =# @inline $flux(i, j, k, ibg, bc::VBCorGBC, args...) = begin
                        #= none:155 =#
                        $_flux(i, j, k, ibg, bc::VBCorGBC, args...)
                    end
            #= none:156 =#
            #= none:156 =# @inline $_flux(i, j, k, ibg, bc::VBCorGBC, args...) = begin
                        #= none:156 =#
                        zero(ibg)
                    end
            #= none:158 =#
            #= none:158 =# @inline $flux(i, j, k, ibg, bc::VBCorGBC, loc, c, closures::Tuple{<:Any}, Ks, id, clock, fields) = begin
                        #= none:158 =#
                        $_flux(i, j, k, ibg, bc, loc, c, closures[1], Ks[1], id, clock, fields)
                    end
            #= none:161 =#
            #= none:161 =# @inline $flux(i, j, k, ibg, bc::VBCorGBC, loc, c, closures::Tuple{<:Any, <:Any}, Ks, id, clock, fields) = begin
                        #= none:161 =#
                        $_flux(i, j, k, ibg, bc, loc, c, closures[1], Ks[1], id, clock, fields) + $_flux(i, j, k, ibg, bc, loc, c, closures[2], Ks[2], id, clock, fields)
                    end
            #= none:165 =#
            #= none:165 =# @inline $flux(i, j, k, ibg, bc::VBCorGBC, loc, c, closures::Tuple{<:Any, <:Any, <:Any}, Ks, id, clock, fields) = begin
                        #= none:165 =#
                        $_flux(i, j, k, ibg, bc, loc, c, closures[1], Ks[1], id, clock, fields) + $_flux(i, j, k, ibg, bc, loc, c, closures[2], Ks[2], id, clock, fields) + $_flux(i, j, k, ibg, bc, loc, c, closures[3], Ks[3], id, clock, fields)
                    end
            #= none:170 =#
            #= none:170 =# @inline $flux(i, j, k, ibg, bc::VBCorGBC, loc, c, closures::Tuple{<:Any, <:Any, <:Any, <:Any}, Ks, id, clock, fields) = begin
                        #= none:170 =#
                        $_flux(i, j, k, ibg, bc, loc, c, closures[1], Ks[1], id, clock, fields) + $_flux(i, j, k, ibg, bc, loc, c, closures[2], Ks[2], id, clock, fields) + $_flux(i, j, k, ibg, bc, loc, c, closures[3], Ks[3], id, clock, fields) + $_flux(i, j, k, ibg, bc, loc, c, closures[4], Ks[4], id, clock, fields)
                    end
            #= none:176 =#
            #= none:176 =# @inline $flux(i, j, k, ibg, bc::VBCorGBC, loc, c, closures::Tuple, Ks, id, clock, fields) = begin
                        #= none:176 =#
                        $_flux(i, j, k, ibg, bc, loc, c, closures[1], Ks[1], id, clock, fields) + $flux(i, j, k, ibg, bc, loc, c, closures[2:end], Ks[2:end], id, clock, fields)
                    end
        end
    #= none:180 =#
end
#= none:187 =#
#= none:187 =# @inline immersed_flux_divergence(i, j, k, ibg::GFIBG, bc::ZFBC, loc, c, closure, K, id, clock, fields) = begin
            #= none:187 =#
            zero(ibg)
        end
#= none:189 =#
#= none:189 =# @inline function immersed_flux_divergence(i, j, k, ibg::GFIBG, bc, loc, c, closure, K, id, clock, fields)
        #= none:189 =#
        #= none:191 =#
        q̃ᵂ = west_ib_flux(i, j, k, ibg, bc.west, loc, c, closure, K, id, clock, fields)
        #= none:192 =#
        q̃ᴱ = east_ib_flux(i, j, k, ibg, bc.east, loc, c, closure, K, id, clock, fields)
        #= none:193 =#
        q̃ˢ = south_ib_flux(i, j, k, ibg, bc.south, loc, c, closure, K, id, clock, fields)
        #= none:194 =#
        q̃ᴺ = north_ib_flux(i, j, k, ibg, bc.north, loc, c, closure, K, id, clock, fields)
        #= none:195 =#
        q̃ᴮ = bottom_ib_flux(i, j, k, ibg, bc.bottom, loc, c, closure, K, id, clock, fields)
        #= none:196 =#
        q̃ᵀ = top_ib_flux(i, j, k, ibg, bc.top, loc, c, closure, K, id, clock, fields)
        #= none:198 =#
        (iᵂ, jˢ, kᴮ) = map(index_left, (i, j, k), loc)
        #= none:199 =#
        (iᴱ, jᴺ, kᵀ) = map(index_right, (i, j, k), loc)
        #= none:200 =#
        (LX, LY, LZ) = loc
        #= none:203 =#
        qᵂ = conditional_flux(iᵂ, j, k, ibg, flip(LX), LY, LZ, q̃ᵂ, zero(eltype(ibg)))
        #= none:204 =#
        qᴱ = conditional_flux(iᴱ, j, k, ibg, flip(LX), LY, LZ, q̃ᴱ, zero(eltype(ibg)))
        #= none:205 =#
        qˢ = conditional_flux(i, jˢ, k, ibg, LX, flip(LY), LZ, q̃ˢ, zero(eltype(ibg)))
        #= none:206 =#
        qᴺ = conditional_flux(i, jᴺ, k, ibg, LX, flip(LY), LZ, q̃ᴺ, zero(eltype(ibg)))
        #= none:207 =#
        qᴮ = conditional_flux(i, j, kᴮ, ibg, LX, LY, flip(LZ), q̃ᴮ, zero(eltype(ibg)))
        #= none:208 =#
        qᵀ = conditional_flux(i, j, kᵀ, ibg, LX, LY, flip(LZ), q̃ᵀ, zero(eltype(ibg)))
        #= none:210 =#
        return div(i, j, k, ibg, loc, qᵂ, qᴱ, qˢ, qᴺ, qᴮ, qᵀ)
    end
#= none:214 =#
#= none:214 =# @inline immersed_∂ⱼ_τ₁ⱼ(i, j, k, grid, args...) = begin
            #= none:214 =#
            zero(grid)
        end
#= none:215 =#
#= none:215 =# @inline immersed_∂ⱼ_τ₂ⱼ(i, j, k, grid, args...) = begin
            #= none:215 =#
            zero(grid)
        end
#= none:216 =#
#= none:216 =# @inline immersed_∂ⱼ_τ₃ⱼ(i, j, k, grid, args...) = begin
            #= none:216 =#
            zero(grid)
        end
#= none:217 =#
#= none:217 =# @inline immersed_∇_dot_qᶜ(i, j, k, grid, args...) = begin
            #= none:217 =#
            zero(grid)
        end
#= none:219 =#
#= none:219 =# @inline immersed_∂ⱼ_τ₁ⱼ(i, j, k, ibg::GFIBG, U, u_bc::IBC, closure, K, clock, fields) = begin
            #= none:219 =#
            immersed_flux_divergence(i, j, k, ibg, u_bc, (f, c, c), U.u, closure, K, nothing, clock, fields)
        end
#= none:222 =#
#= none:222 =# @inline immersed_∂ⱼ_τ₂ⱼ(i, j, k, ibg::GFIBG, U, v_bc::IBC, closure, K, clock, fields) = begin
            #= none:222 =#
            immersed_flux_divergence(i, j, k, ibg, v_bc, (c, f, c), U.v, closure, K, nothing, clock, fields)
        end
#= none:225 =#
#= none:225 =# @inline immersed_∂ⱼ_τ₃ⱼ(i, j, k, ibg::GFIBG, U, w_bc::IBC, closure, K, clock, fields) = begin
            #= none:225 =#
            immersed_flux_divergence(i, j, k, ibg, w_bc, (c, c, f), U.w, closure, K, nothing, clock, fields)
        end
#= none:228 =#
#= none:228 =# @inline immersed_∇_dot_qᶜ(i, j, k, ibg::GFIBG, C, c_bc::IBC, closure, K, id, clock, fields) = begin
            #= none:228 =#
            immersed_flux_divergence(i, j, k, ibg, c_bc, (c, c, c), C, closure, K, id, clock, fields)
        end