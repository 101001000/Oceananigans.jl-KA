
#= none:1 =#
using Oceananigans.Solvers
#= none:2 =#
using Oceananigans.Operators
#= none:3 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid, GridFittedBottom
#= none:4 =#
using Oceananigans.Architectures
#= none:5 =#
using Oceananigans.Grids: with_halo, isrectilinear, halo_size
#= none:6 =#
using Oceananigans.Architectures: device
#= none:8 =#
import Oceananigans.Solvers: solve!, precondition!
#= none:9 =#
import Oceananigans.Architectures: architecture
#= none:11 =#
#= none:11 =# Core.@doc "    struct PCGImplicitFreeSurfaceSolver{V, S, R}\n\nThe preconditioned conjugate gradient iterative implicit free-surface solver.\n\n$(TYPEDFIELDS)\n" struct PCGImplicitFreeSurfaceSolver{V, S, R}
        #= none:19 =#
        "The vertically-integrated lateral areas"
        #= none:20 =#
        vertically_integrated_lateral_areas::V
        #= none:21 =#
        "The preconditioned conjugate gradient solver"
        #= none:22 =#
        preconditioned_conjugate_gradient_solver::S
        #= none:23 =#
        "The right hand side of the free surface evolution equation"
        #= none:24 =#
        right_hand_side::R
    end
#= none:27 =#
architecture(solver::PCGImplicitFreeSurfaceSolver) = begin
        #= none:27 =#
        architecture(solver.preconditioned_conjugate_gradient_solver)
    end
#= none:30 =#
#= none:30 =# Core.@doc "    PCGImplicitFreeSurfaceSolver(grid, settings)\n\nReturn a solver based on a preconditioned conjugate gradient method for\nthe elliptic equation\n    \n```math\n[∇ ⋅ H ∇ - 1 / (g Δt²)] ηⁿ⁺¹ = (∇ʰ ⋅ Q★ - ηⁿ / Δt) / (g Δt)\n```\n\nrepresenting an implicit time discretization of the linear free surface evolution equation\nfor a fluid with variable depth `H`, horizontal areas `Az`, barotropic volume flux `Q★`, time\nstep `Δt`, gravitational acceleration `g`, and free surface at time-step `n` `ηⁿ`.\n" function PCGImplicitFreeSurfaceSolver(grid::AbstractGrid, settings, gravitational_acceleration = nothing)
        #= none:44 =#
        #= none:47 =#
        ∫ᶻ_Axᶠᶜᶜ = Field((Face, Center, Nothing), grid)
        #= none:48 =#
        ∫ᶻ_Ayᶜᶠᶜ = Field((Center, Face, Nothing), grid)
        #= none:50 =#
        vertically_integrated_lateral_areas = (xᶠᶜᶜ = ∫ᶻ_Axᶠᶜᶜ, yᶜᶠᶜ = ∫ᶻ_Ayᶜᶠᶜ)
        #= none:52 =#
        #= none:52 =# @apply_regionally compute_vertically_integrated_lateral_areas!(vertically_integrated_lateral_areas)
        #= none:53 =#
        fill_halo_regions!(vertically_integrated_lateral_areas)
        #= none:56 =#
        settings = Dict{Symbol, Any}(settings)
        #= none:57 =#
        settings[:maxiter] = get(settings, :maxiter, grid.Nx * grid.Ny)
        #= none:58 =#
        settings[:reltol] = get(settings, :reltol, min(1.0e-7, 10 * sqrt(eps(eltype(grid)))))
        #= none:61 =#
        settings[:preconditioner] = if isrectilinear(grid)
                get(settings, :preconditioner, FFTImplicitFreeSurfaceSolver(grid))
            else
                get(settings, :preconditioner, nothing)
            end
        #= none:66 =#
        right_hand_side = ZFaceField(grid, indices = (:, :, size(grid, 3) + 1))
        #= none:68 =#
        solver = ConjugateGradientSolver(implicit_free_surface_linear_operation!; template_field = right_hand_side, settings...)
        #= none:72 =#
        return PCGImplicitFreeSurfaceSolver(vertically_integrated_lateral_areas, solver, right_hand_side)
    end
#= none:75 =#
build_implicit_step_solver(::Val{:PreconditionedConjugateGradient}, grid, settings, gravitational_acceleration) = begin
        #= none:75 =#
        PCGImplicitFreeSurfaceSolver(grid, settings, gravitational_acceleration)
    end
#= none:82 =#
function solve!(η, implicit_free_surface_solver::PCGImplicitFreeSurfaceSolver, rhs, g, Δt)
    #= none:82 =#
    #= none:87 =#
    ∫ᶻA = implicit_free_surface_solver.vertically_integrated_lateral_areas
    #= none:88 =#
    solver = implicit_free_surface_solver.preconditioned_conjugate_gradient_solver
    #= none:91 =#
    solve!(η, solver, rhs, ∫ᶻA.xᶠᶜᶜ, ∫ᶻA.yᶜᶠᶜ, g, Δt)
    #= none:93 =#
    return nothing
end
#= none:96 =#
function compute_implicit_free_surface_right_hand_side!(rhs, implicit_solver::PCGImplicitFreeSurfaceSolver, g, Δt, ∫ᶻQ, η)
    #= none:96 =#
    #= none:99 =#
    solver = implicit_solver.preconditioned_conjugate_gradient_solver
    #= none:100 =#
    arch = architecture(solver)
    #= none:101 =#
    grid = solver.grid
    #= none:103 =#
    #= none:103 =# @apply_regionally compute_regional_rhs!(rhs, arch, grid, g, Δt, ∫ᶻQ, η)
    #= none:105 =#
    return nothing
end
#= none:108 =#
compute_regional_rhs!(rhs, arch, grid, g, Δt, ∫ᶻQ, η) = begin
        #= none:108 =#
        launch!(arch, grid, :xy, implicit_free_surface_right_hand_side!, rhs, grid, g, Δt, ∫ᶻQ, η)
    end
#= none:113 =#
#= none:113 =# Core.@doc " Compute the divergence of fluxes Qu and Qv. " #= none:114 =# @inline(flux_div_xyᶜᶜᶠ(i, j, k, grid, Qu, Qv) = begin
                #= none:114 =#
                δxᶜᵃᵃ(i, j, k, grid, Qu) + δyᵃᶜᵃ(i, j, k, grid, Qv)
            end)
#= none:116 =#
#= none:116 =# @kernel function implicit_free_surface_right_hand_side!(rhs, grid, g, Δt, ∫ᶻQ, η)
        #= none:116 =#
        #= none:117 =#
        (i, j) = #= none:117 =# @index(Global, NTuple)
        #= none:118 =#
        k_top = grid.Nz + 1
        #= none:119 =#
        Az = Azᶜᶜᶠ(i, j, k_top, grid)
        #= none:120 =#
        δ_Q = flux_div_xyᶜᶜᶠ(i, j, k_top, grid, ∫ᶻQ.u, ∫ᶻQ.v)
        #= none:121 =#
        #= none:121 =# @inbounds rhs[i, j, k_top] = (δ_Q - (Az * η[i, j, k_top]) / Δt) / (g * Δt)
    end
#= none:124 =#
#= none:124 =# Core.@doc "    implicit_free_surface_linear_operation!(L_ηⁿ⁺¹, ηⁿ⁺¹, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)\n\nReturn `L(ηⁿ)`, where `ηⁿ` is the free surface displacement at time step `n`\nand `L` is the linear operator that arises\nin an implicit time step for the free surface displacement `η`.\n\n(See the docs section on implicit time stepping.)\n" function implicit_free_surface_linear_operation!(L_ηⁿ⁺¹, ηⁿ⁺¹, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)
        #= none:133 =#
        #= none:134 =#
        grid = L_ηⁿ⁺¹.grid
        #= none:135 =#
        arch = architecture(L_ηⁿ⁺¹)
        #= none:139 =#
        fill_halo_regions!(ηⁿ⁺¹)
        #= none:141 =#
        launch!(arch, grid, :xy, _implicit_free_surface_linear_operation!, L_ηⁿ⁺¹, grid, ηⁿ⁺¹, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)
        #= none:144 =#
        return nothing
    end
#= none:148 =#
#= none:148 =# @inline ∫ᶻ_Ax_∂x_ηᶠᶜᶜ(i, j, k, grid, ∫ᶻ_Axᶠᶜᶜ, η) = begin
            #= none:148 =#
            #= none:148 =# @inbounds ∫ᶻ_Axᶠᶜᶜ[i, j, k] * ∂xᶠᶜᶠ(i, j, k, grid, η)
        end
#= none:149 =#
#= none:149 =# @inline ∫ᶻ_Ay_∂y_ηᶜᶠᶜ(i, j, k, grid, ∫ᶻ_Ayᶜᶠᶜ, η) = begin
            #= none:149 =#
            #= none:149 =# @inbounds ∫ᶻ_Ayᶜᶠᶜ[i, j, k] * ∂yᶜᶠᶠ(i, j, k, grid, η)
        end
#= none:151 =#
#= none:151 =# Core.@doc "    _implicit_free_surface_linear_operation!(L_ηⁿ⁺¹, grid, ηⁿ⁺¹, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)\n\nReturn the left side of the \"implicit ``η`` equation\"\n\n```math\n(∇ʰ⋅ H ∇ʰ - 1 / (g Δt²)) ηⁿ⁺¹ = 1 / (g Δt) ∇ʰ ⋅ Q★ - 1 / (g Δt²) ηⁿ\n----------------------\n        ≡ L_ηⁿ⁺¹\n```\n\nwhich is derived from the discretely summed barotropic mass conservation equation,\nand arranged in a symmetric form by multiplying by horizontal areas Az:\n\n```\nδⁱÂʷ∂ˣηⁿ⁺¹ + δʲÂˢ∂ʸηⁿ⁺¹ - Az ηⁿ⁺¹ / (g Δt²) = 1 / (g Δt) (δⁱÂʷu̅ˢᵗᵃʳ + δʲÂˢv̅ˢᵗᵃʳ) - Az ηⁿ / (g Δt²) \n```\n\nwhere  ̂ indicates a vertical integral, and\n       ̅ indicates a vertical average                         \n" #= none:172 =# @kernel(function _implicit_free_surface_linear_operation!(L_ηⁿ⁺¹, grid, ηⁿ⁺¹, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)
            #= none:172 =#
            #= none:173 =#
            (i, j) = #= none:173 =# @index(Global, NTuple)
            #= none:174 =#
            k_top = grid.Nz + 1
            #= none:175 =#
            Az = Azᶜᶜᶜ(i, j, grid.Nz, grid)
            #= none:176 =#
            #= none:176 =# @inbounds L_ηⁿ⁺¹[i, j, k_top] = Az_∇h²ᶜᶜᶜ(i, j, k_top, grid, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, ηⁿ⁺¹) - (Az * ηⁿ⁺¹[i, j, k_top]) / (g * Δt ^ 2)
        end)
#= none:183 =#
#= none:183 =# Core.@doc "Add  `- H⁻¹ ∇H ⋅ ∇ηⁿ` to the right-hand-side.\n" #= none:186 =# @inline(function precondition!(P_r, preconditioner::FFTImplicitFreeSurfaceSolver, r, η, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)
            #= none:186 =#
            #= none:187 =#
            poisson_solver = preconditioner.fft_poisson_solver
            #= none:188 =#
            arch = architecture(poisson_solver)
            #= none:189 =#
            grid = preconditioner.three_dimensional_grid
            #= none:190 =#
            Az = grid.Δxᶜᵃᵃ * grid.Δyᵃᶜᵃ
            #= none:191 =#
            Lz = grid.Lz
            #= none:193 =#
            launch!(arch, grid, :xy, fft_preconditioner_right_hand_side!, poisson_solver.storage, r, η, grid, Az, Lz)
            #= none:197 =#
            return solve!(P_r, preconditioner, poisson_solver.storage, g, Δt)
        end)
#= none:200 =#
#= none:200 =# @kernel function fft_preconditioner_right_hand_side!(fft_rhs, pcg_rhs, η, grid, Az, Lz)
        #= none:200 =#
        #= none:201 =#
        (i, j) = #= none:201 =# @index(Global, NTuple)
        #= none:202 =#
        #= none:202 =# @inbounds fft_rhs[i, j, 1] = pcg_rhs[i, j, grid.Nz + 1] / (Lz * Az)
    end
#= none:234 =#
struct DiagonallyDominantInversePreconditioner
    #= none:234 =#
end
#= none:236 =#
#= none:236 =# @inline precondition!(P_r, ::DiagonallyDominantInversePreconditioner, r, η, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt) = begin
            #= none:236 =#
            diagonally_dominant_precondition!(P_r, r, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)
        end
#= none:239 =#
#= none:239 =# Core.@doc "    _diagonally_dominant_precondition!(P_r, grid, r, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)\n\nReturn the diagonally dominant inverse preconditioner applied to the residuals consistently\nwith `M = D⁻¹(I - (A - D)D⁻¹) ≈ A⁻¹` where `I` is the identity matrix, `A` is the linear\noperator applied to the free surface `η`, and `D` is the diagonal of `A`.\n\n```math\nP_r = M * r\n```\n\nwhich expanded in components is\n\n```math\nP_rᵢⱼ = rᵢⱼ / Acᵢⱼ - 1 / Acᵢⱼ ( Ax⁻ / Acᵢ₋₁ rᵢ₋₁ⱼ + Ax⁺ / Acᵢ₊₁ rᵢ₊₁ⱼ + Ay⁻ / Acⱼ₋₁ rᵢⱼ₋₁+ Ay⁺ / Acⱼ₊₁ rᵢⱼ₊₁ )\n```\n\nwhere `Ac`, `Ax⁻`, `Ax⁺`, `Ay⁻` and `Ay⁺` are the coefficients of `ηᵢⱼ`, `ηᵢ₋₁ⱼ`, `ηᵢ₊₁ⱼ`, `ηᵢⱼ₋₁`,\nand `ηᵢⱼ₊₁` in `_implicit_free_surface_linear_operation!`\n" function diagonally_dominant_precondition!(P_r, r, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)
        #= none:259 =#
        #= none:260 =#
        grid = ∫ᶻ_Axᶠᶜᶜ.grid
        #= none:261 =#
        arch = architecture(P_r)
        #= none:263 =#
        fill_halo_regions!(r)
        #= none:265 =#
        launch!(arch, grid, :xy, _diagonally_dominant_precondition!, P_r, grid, r, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)
        #= none:268 =#
        return nothing
    end
#= none:272 =#
#= none:272 =# @inline Ax⁻(i, j, grid, ax) = begin
            #= none:272 =#
            #= none:272 =# @inbounds ax[i, j, 1] / Δxᶠᶜᶠ(i, j, grid.Nz + 1, grid)
        end
#= none:273 =#
#= none:273 =# @inline Ay⁻(i, j, grid, ay) = begin
            #= none:273 =#
            #= none:273 =# @inbounds ay[i, j, 1] / Δyᶜᶠᶠ(i, j, grid.Nz + 1, grid)
        end
#= none:274 =#
#= none:274 =# @inline Ax⁺(i, j, grid, ax) = begin
            #= none:274 =#
            #= none:274 =# @inbounds ax[i + 1, j, 1] / Δxᶠᶜᶠ(i + 1, j, grid.Nz + 1, grid)
        end
#= none:275 =#
#= none:275 =# @inline Ay⁺(i, j, grid, ay) = begin
            #= none:275 =#
            #= none:275 =# @inbounds ay[i, j + 1, 1] / Δyᶜᶠᶠ(i, j + 1, grid.Nz + 1, grid)
        end
#= none:277 =#
#= none:277 =# @inline Ac(i, j, grid, g, Δt, ax, ay) = begin
            #= none:277 =#
            (((-(Ax⁻(i, j, grid, ax)) - Ax⁺(i, j, grid, ax)) - Ay⁻(i, j, grid, ay)) - Ay⁺(i, j, grid, ay)) - Azᶜᶜᶜ(i, j, 1, grid) / (g * Δt ^ 2)
        end
#= none:283 =#
#= none:283 =# @inline heuristic_inverse_times_residuals(i, j, r, grid, g, Δt, ax, ay) = begin
            #= none:283 =#
            #= none:284 =# @inbounds (1 / Ac(i, j, grid, g, Δt, ax, ay)) * ((((r[i, j, 1] - ((2 * Ax⁻(i, j, grid, ax)) / (Ac(i - 1, j, grid, g, Δt, ax, ay) + Ac(i, j, grid, g, Δt, ax, ay))) * r[i - 1, j, grid.Nz + 1]) - ((2 * Ax⁺(i, j, grid, ax)) / (Ac(i + 1, j, grid, g, Δt, ax, ay) + Ac(i, j, grid, g, Δt, ax, ay))) * r[i + 1, j, grid.Nz + 1]) - ((2 * Ay⁻(i, j, grid, ay)) / (Ac(i, j - 1, grid, g, Δt, ax, ay) + Ac(i, j, grid, g, Δt, ax, ay))) * r[i, j - 1, grid.Nz + 1]) - ((2 * Ay⁺(i, j, grid, ay)) / (Ac(i, j + 1, grid, g, Δt, ax, ay) + Ac(i, j, grid, g, Δt, ax, ay))) * r[i, j + 1, grid.Nz + 1])
        end
#= none:289 =#
#= none:289 =# @kernel function _diagonally_dominant_precondition!(P_r, grid, r, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)
        #= none:289 =#
        #= none:290 =#
        (i, j) = #= none:290 =# @index(Global, NTuple)
        #= none:291 =#
        #= none:291 =# @inbounds P_r[i, j, grid.Nz + 1] = heuristic_inverse_times_residuals(i, j, r, grid, g, Δt, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ)
    end