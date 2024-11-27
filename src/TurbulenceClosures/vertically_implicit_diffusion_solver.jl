
#= none:1 =#
using Oceananigans.Operators: Δz
#= none:2 =#
using Oceananigans.Solvers: BatchedTridiagonalSolver, solve!
#= none:3 =#
using Oceananigans.ImmersedBoundaries: immersed_peripheral_node, ImmersedBoundaryGrid
#= none:4 =#
using Oceananigans.Grids: ZDirection
#= none:6 =#
import Oceananigans.Solvers: get_coefficient
#= none:7 =#
import Oceananigans.TimeSteppers: implicit_step!
#= none:9 =#
const IBG = ImmersedBoundaryGrid
#= none:26 =#
#= none:26 =# @inline implicit_linear_coefficient(i, j, k, grid, closure, diffusivity_fields, tracer_index, ℓx, ℓy, ℓz, clock, Δt, κz) = begin
            #= none:26 =#
            zero(grid)
        end
#= none:29 =#
#= none:29 =# @inline νzᶠᶜᶠ(i, j, k, grid, closure, diffusivity_fields, clock, args...) = begin
            #= none:29 =#
            zero(grid)
        end
#= none:30 =#
#= none:30 =# @inline νzᶜᶠᶠ(i, j, k, grid, closure, diffusivity_fields, clock, args...) = begin
            #= none:30 =#
            zero(grid)
        end
#= none:31 =#
#= none:31 =# @inline νzᶜᶜᶜ(i, j, k, grid, closure, diffusivity_fields, clock, args...) = begin
            #= none:31 =#
            zero(grid)
        end
#= none:32 =#
#= none:32 =# @inline κzᶜᶜᶠ(i, j, k, grid, closure, diffusivity_fields, tracer_index, clock, args...) = begin
            #= none:32 =#
            zero(grid)
        end
#= none:38 =#
implicit_diffusion_solver(::ExplicitTimeDiscretization, args...; kwargs...) = begin
        #= none:38 =#
        nothing
    end
#= none:45 =#
const c = Center()
#= none:46 =#
const f = Face()
#= none:49 =#
#= none:49 =# @inline function ivd_upper_diagonal(i, j, k, grid, closure, K, id, ℓx, ℓy, ::Center, clock, Δt, κz)
        #= none:49 =#
        #= none:50 =#
        closure_ij = getclosure(i, j, closure)
        #= none:51 =#
        κᵏ⁺¹ = κz(i, j, k + 1, grid, closure_ij, K, id, clock)
        #= none:52 =#
        Δzᶜₖ = Δz(i, j, k, grid, ℓx, ℓy, c)
        #= none:53 =#
        Δzᶠₖ₊₁ = Δz(i, j, k + 1, grid, ℓx, ℓy, f)
        #= none:54 =#
        du = (-Δt * κᵏ⁺¹) / (Δzᶜₖ * Δzᶠₖ₊₁)
        #= none:57 =#
        return ifelse(k > grid.Nz - 1, zero(grid), du)
    end
#= none:60 =#
#= none:60 =# @inline function ivd_lower_diagonal(i, j, k′, grid, closure, K, id, ℓx, ℓy, ::Center, clock, Δt, κz)
        #= none:60 =#
        #= none:61 =#
        k = k′ + 1
        #= none:62 =#
        closure_ij = getclosure(i, j, closure)
        #= none:63 =#
        κᵏ = κz(i, j, k, grid, closure_ij, K, id, clock)
        #= none:64 =#
        Δzᶜₖ = Δz(i, j, k, grid, ℓx, ℓy, c)
        #= none:65 =#
        Δzᶠₖ = Δz(i, j, k, grid, ℓx, ℓy, f)
        #= none:66 =#
        dl = (-Δt * κᵏ) / (Δzᶜₖ * Δzᶠₖ)
        #= none:71 =#
        return ifelse(k′ < 1, zero(grid), dl)
    end
#= none:80 =#
#= none:80 =# @inline function ivd_upper_diagonal(i, j, k, grid, closure, K, id, ℓx, ℓy, ::Face, clock, Δt, νzᶜᶜᶜ)
        #= none:80 =#
        #= none:81 =#
        closure_ij = getclosure(i, j, closure)
        #= none:82 =#
        νᵏ = νzᶜᶜᶜ(i, j, k, grid, closure_ij, K, clock)
        #= none:83 =#
        Δzᶜₖ = Δz(i, j, k, grid, ℓx, ℓy, c)
        #= none:84 =#
        Δzᶠₖ = Δz(i, j, k, grid, ℓx, ℓy, f)
        #= none:85 =#
        du = (-Δt * νᵏ) / (Δzᶜₖ * Δzᶠₖ)
        #= none:86 =#
        return ifelse(k < 1, zero(grid), du)
    end
#= none:89 =#
#= none:89 =# @inline function ivd_lower_diagonal(i, j, k, grid, closure, K, id, ℓx, ℓy, ::Face, clock, Δt, νzᶜᶜᶜ)
        #= none:89 =#
        #= none:90 =#
        k′ = k + 2
        #= none:91 =#
        closure_ij = getclosure(i, j, closure)
        #= none:92 =#
        νᵏ⁻¹ = νzᶜᶜᶜ(i, j, k′ - 1, grid, closure_ij, K, clock)
        #= none:93 =#
        Δzᶜₖ = Δz(i, j, k′, grid, ℓx, ℓy, c)
        #= none:94 =#
        Δzᶠₖ₋₁ = Δz(i, j, k′ - 1, grid, ℓx, ℓy, f)
        #= none:95 =#
        dl = (-Δt * νᵏ⁻¹) / (Δzᶜₖ * Δzᶠₖ₋₁)
        #= none:96 =#
        return ifelse(k < 1, zero(grid), dl)
    end
#= none:101 =#
#= none:101 =# @inline ivd_diagonal(i, j, k, grid, closure, K, id, ℓx, ℓy, ℓz, clock, Δt, κz) = begin
            #= none:101 =#
            ((one(grid) - Δt * _implicit_linear_coefficient(i, j, k, grid, closure, K, id, ℓx, ℓy, ℓz, clock, Δt, κz)) - _ivd_upper_diagonal(i, j, k, grid, closure, K, id, ℓx, ℓy, ℓz, clock, Δt, κz)) - _ivd_lower_diagonal(i, j, k - 1, grid, closure, K, id, ℓx, ℓy, ℓz, clock, Δt, κz)
        end
#= none:106 =#
#= none:106 =# @inline _implicit_linear_coefficient(args...) = begin
            #= none:106 =#
            implicit_linear_coefficient(args...)
        end
#= none:107 =#
#= none:107 =# @inline _ivd_upper_diagonal(args...) = begin
            #= none:107 =#
            ivd_upper_diagonal(args...)
        end
#= none:108 =#
#= none:108 =# @inline _ivd_lower_diagonal(args...) = begin
            #= none:108 =#
            ivd_lower_diagonal(args...)
        end
#= none:124 =#
for (locate_coeff, loc) = ((:κᶠᶜᶜ, (f, c, c)), (:κᶜᶠᶜ, (c, f, c)), (:κᶜᶜᶠ, (c, c, f)), (:νᶜᶜᶜ, (c, c, c)), (:νᶠᶠᶜ, (f, f, c)), (:νᶠᶜᶠ, (f, c, f)), (:νᶜᶠᶠ, (c, f, f)))
    #= none:132 =#
    #= none:132 =# @eval begin
            #= none:133 =#
            #= none:133 =# @inline ($locate_coeff(i, j, k, ibg::IBG{FT}, coeff) where FT) = begin
                        #= none:133 =#
                        ifelse(inactive_node(i, j, k, ibg, loc...), $locate_coeff(i, j, k, ibg.underlying_grid, coeff), zero(FT))
                    end
        end
    #= none:136 =#
end
#= none:138 =#
#= none:138 =# @inline immersed_ivd_peripheral_node(i, j, k, ibg, ℓx, ℓy, ::Center) = begin
            #= none:138 =#
            immersed_peripheral_node(i, j, k + 1, ibg, ℓx, ℓy, Face())
        end
#= none:139 =#
#= none:139 =# @inline immersed_ivd_peripheral_node(i, j, k, ibg, ℓx, ℓy, ::Face) = begin
            #= none:139 =#
            immersed_peripheral_node(i, j, k, ibg, ℓx, ℓy, Center())
        end
#= none:143 =#
for location = (:upper_, :lower_)
    #= none:144 =#
    ordinary_func = Symbol(:ivd_, location, :diagonal)
    #= none:145 =#
    immersed_func = Symbol(:immersed_ivd_, location, :diagonal)
    #= none:146 =#
    #= none:146 =# @eval begin
            #= none:148 =#
            #= none:148 =# @inline $ordinary_func(i, j, k, ibg::IBG, closure, K, id, ℓx, ℓy, ℓz::Face, clock, Δt, κz) = begin
                        #= none:148 =#
                        $immersed_func(i, j, k, ibg::IBG, closure, K, id, ℓx, ℓy, ℓz, clock, Δt, κz)
                    end
            #= none:151 =#
            #= none:151 =# @inline $ordinary_func(i, j, k, ibg::IBG, closure, K, id, ℓx, ℓy, ℓz::Center, clock, Δt, κz) = begin
                        #= none:151 =#
                        $immersed_func(i, j, k, ibg::IBG, closure, K, id, ℓx, ℓy, ℓz, clock, Δt, κz)
                    end
            #= none:154 =#
            #= none:154 =# @inline $immersed_func(i, j, k, ibg::IBG, closure, K, id, ℓx, ℓy, ℓz, clock, Δt, κz) = begin
                        #= none:154 =#
                        ifelse(immersed_ivd_peripheral_node(i, j, k, ibg, ℓx, ℓy, ℓz), zero(ibg), $ordinary_func(i, j, k, ibg.underlying_grid, closure, K, id, ℓx, ℓy, ℓz, clock, Δt, κz))
                    end
        end
    #= none:159 =#
end
#= none:165 =#
struct VerticallyImplicitDiffusionLowerDiagonal
    #= none:165 =#
end
#= none:166 =#
struct VerticallyImplicitDiffusionDiagonal
    #= none:166 =#
end
#= none:167 =#
struct VerticallyImplicitDiffusionUpperDiagonal
    #= none:167 =#
end
#= none:169 =#
#= none:169 =# Core.@doc "    implicit_diffusion_solver(::VerticallyImplicitTimeDiscretization, grid)\n\nBuild tridiagonal solvers for the elliptic equations\n\n```math\n(1 - Δt ∂z κz ∂z - Δt L) cⁿ⁺¹ = c★\n```\n\nand\n\n```math\n(1 - Δt ∂z νz ∂z - Δt L) wⁿ⁺¹ = w★\n```\n\nwhere `cⁿ⁺¹` and `c★` live at cell `Center`s in the vertical,\nand `wⁿ⁺¹` and `w★` lives at cell `Face`s in the vertical.\n" function implicit_diffusion_solver(::VerticallyImplicitTimeDiscretization, grid)
        #= none:187 =#
        #= none:188 =#
        topo = topology(grid)
        #= none:190 =#
        topo[3] == Periodic && error("VerticallyImplicitTimeDiscretization can only be specified on " * "grids that are Bounded in the z-direction.")
        #= none:193 =#
        z_solver = BatchedTridiagonalSolver(grid; lower_diagonal = VerticallyImplicitDiffusionLowerDiagonal(), diagonal = VerticallyImplicitDiffusionDiagonal(), upper_diagonal = VerticallyImplicitDiffusionUpperDiagonal())
        #= none:198 =#
        return z_solver
    end
#= none:202 =#
#= none:202 =# @inline get_coefficient(i, j, k, grid, ::VerticallyImplicitDiffusionLowerDiagonal, p, ::ZDirection, args...) = begin
            #= none:202 =#
            _ivd_lower_diagonal(i, j, k, grid, args...)
        end
#= none:203 =#
#= none:203 =# @inline get_coefficient(i, j, k, grid, ::VerticallyImplicitDiffusionUpperDiagonal, p, ::ZDirection, args...) = begin
            #= none:203 =#
            _ivd_upper_diagonal(i, j, k, grid, args...)
        end
#= none:204 =#
#= none:204 =# @inline get_coefficient(i, j, k, grid, ::VerticallyImplicitDiffusionDiagonal, p, ::ZDirection, args...) = begin
            #= none:204 =#
            ivd_diagonal(i, j, k, grid, args...)
        end
#= none:211 =#
#= none:211 =# @inline νzᶠᶜᶠ(i, j, k, grid, closure, K, ::Nothing, clock, args...) = begin
            #= none:211 =#
            νzᶠᶜᶠ(i, j, k, grid, closure, K, clock, args...)
        end
#= none:212 =#
#= none:212 =# @inline νzᶜᶠᶠ(i, j, k, grid, closure, K, ::Nothing, clock, args...) = begin
            #= none:212 =#
            νzᶜᶠᶠ(i, j, k, grid, closure, K, clock, args...)
        end
#= none:214 =#
is_vertically_implicit(closure) = begin
        #= none:214 =#
        time_discretization(closure) isa VerticallyImplicitTimeDiscretization
    end
#= none:216 =#
#= none:216 =# Core.@doc "    implicit_step!(field, implicit_solver::BatchedTridiagonalSolver,\n                   closure, diffusivity_fields, tracer_index, clock, Δt)\n\nInitialize the right hand side array `solver.batched_tridiagonal_solver.f`, and then solve the\ntridiagonal system for vertically-implicit diffusion, passing the arguments\n`clock, Δt, κ⁻⁻ᶠ, κ` into the coefficient functions that return coefficients of the\nlower diagonal, diagonal, and upper diagonal of the resulting tridiagonal system.\n\n`args...` are passed into `z_diffusivity` and `z_viscosity` appropriately for the purpose of retrieving\nthe diffusivities / viscosities associated with `closure`.\n" function implicit_step!(field::Field, implicit_solver::BatchedTridiagonalSolver, closure::Union{AbstractTurbulenceClosure, AbstractArray{<:AbstractTurbulenceClosure}, Tuple}, diffusivity_fields, tracer_index, clock, Δt; kwargs...)
        #= none:228 =#
        #= none:237 =#
        loc = location(field)
        #= none:242 =#
        κz = if loc === (Center, Center, Center)
                κzᶜᶜᶠ
            else
                if loc === (Face, Center, Center)
                    νzᶠᶜᶠ
                else
                    if loc === (Center, Face, Center)
                        νzᶜᶠᶠ
                    else
                        if loc === (Center, Center, Face)
                            νzᶜᶜᶜ
                        else
                            error("Cannot take an implicit_step! for a field at $(location)")
                        end
                    end
                end
            end
        #= none:250 =#
        κz === κzᶜᶜᶠ || (tracer_index = nothing)
        #= none:253 =#
        if closure isa Tuple
            #= none:254 =#
            closure_tuple = closure
            #= none:255 =#
            N = length(closure_tuple)
            #= none:256 =#
            vi_closure = Tuple((closure[n] for n = 1:N if is_vertically_implicit(closure[n])))
            #= none:257 =#
            vi_diffusivity_fields = Tuple((diffusivity_fields[n] for n = 1:N if is_vertically_implicit(closure[n])))
        else
            #= none:259 =#
            vi_closure = closure
            #= none:260 =#
            vi_diffusivity_fields = diffusivity_fields
        end
        #= none:263 =#
        return solve!(field, implicit_solver, field, vi_closure, vi_diffusivity_fields, tracer_index, map((ℓ->begin
                            #= none:265 =#
                            ℓ()
                        end), loc)..., clock, Δt, κz; kwargs...)
    end