
#= none:1 =#
using Oceananigans.Operators: divᶜᶜᶜ, ∇²ᶜᶜᶜ
#= none:2 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid
#= none:3 =#
using Statistics: mean
#= none:5 =#
using KernelAbstractions: @kernel, @index
#= none:7 =#
import Oceananigans.Architectures: architecture
#= none:9 =#
struct ConjugateGradientPoissonSolver{G, R, S}
    #= none:10 =#
    grid::G
    #= none:11 =#
    right_hand_side::R
    #= none:12 =#
    conjugate_gradient_solver::S
end
#= none:15 =#
architecture(solver::ConjugateGradientPoissonSolver) = begin
        #= none:15 =#
        architecture(cgps.grid)
    end
#= none:16 =#
iteration(cgps::ConjugateGradientPoissonSolver) = begin
        #= none:16 =#
        iteration(cgps.conjugate_gradient_solver)
    end
#= none:18 =#
Base.summary(ips::ConjugateGradientPoissonSolver) = begin
        #= none:18 =#
        summary("ConjugateGradientPoissonSolver on ", summary(ips.grid))
    end
#= none:21 =#
function Base.show(io::IO, ips::ConjugateGradientPoissonSolver)
    #= none:21 =#
    #= none:22 =#
    A = architecture(ips.grid)
    #= none:23 =#
    print(io, "ConjugateGradientPoissonSolver:", '\n', "├── grid: ", summary(ips.grid), '\n', "└── conjugate_gradient_solver: ", summary(ips.conjugate_gradient_solver), '\n', "    ├── maxiter: ", prettysummary(ips.conjugate_gradient_solver.maxiter), '\n', "    ├── reltol: ", prettysummary(ips.conjugate_gradient_solver.reltol), '\n', "    ├── abstol: ", prettysummary(ips.conjugate_gradient_solver.abstol), '\n', "    ├── preconditioner: ", prettysummary(ips.conjugate_gradient_solver.preconditioner), '\n', "    └── iteration: ", prettysummary(ips.conjugate_gradient_solver.iteration))
end
#= none:33 =#
#= none:33 =# @kernel function laplacian!(∇²ϕ, grid, ϕ)
        #= none:33 =#
        #= none:34 =#
        (i, j, k) = #= none:34 =# @index(Global, NTuple)
        #= none:35 =#
        #= none:35 =# @inbounds ∇²ϕ[i, j, k] = ∇²ᶜᶜᶜ(i, j, k, grid, ϕ)
    end
#= none:38 =#
function compute_laplacian!(∇²ϕ, ϕ)
    #= none:38 =#
    #= none:39 =#
    grid = ϕ.grid
    #= none:40 =#
    arch = architecture(grid)
    #= none:41 =#
    fill_halo_regions!(ϕ)
    #= none:42 =#
    launch!(arch, grid, :xyz, laplacian!, ∇²ϕ, grid, ϕ)
    #= none:43 =#
    return nothing
end
#= none:46 =#
struct DefaultPreconditioner
    #= none:46 =#
end
#= none:48 =#
function ConjugateGradientPoissonSolver(grid; preconditioner = DefaultPreconditioner(), reltol = sqrt(eps(grid)), abstol = sqrt(eps(grid)), kw...)
    #= none:48 =#
    #= none:54 =#
    if preconditioner isa DefaultPreconditioner
        #= none:55 =#
        if grid isa ImmersedBoundaryGrid && grid.underlying_grid isa GridWithFFTSolver
            #= none:56 =#
            preconditioner = fft_poisson_solver(grid.underlying_grid)
        else
            #= none:58 =#
            preconditioner = DiagonallyDominantPreconditioner()
        end
    end
    #= none:62 =#
    rhs = CenterField(grid)
    #= none:64 =#
    conjugate_gradient_solver = ConjugateGradientSolver(compute_laplacian!; reltol, abstol, preconditioner, template_field = rhs, kw...)
    #= none:71 =#
    return ConjugateGradientPoissonSolver(grid, rhs, conjugate_gradient_solver)
end
#= none:78 =#
#= none:78 =# @kernel function fft_preconditioner_rhs!(preconditioner_rhs, rhs)
        #= none:78 =#
        #= none:79 =#
        (i, j, k) = #= none:79 =# @index(Global, NTuple)
        #= none:80 =#
        #= none:80 =# @inbounds preconditioner_rhs[i, j, k] = rhs[i, j, k]
    end
#= none:83 =#
#= none:83 =# @kernel function fourier_tridiagonal_preconditioner_rhs!(preconditioner_rhs, ::XDirection, grid, rhs)
        #= none:83 =#
        #= none:84 =#
        (i, j, k) = #= none:84 =# @index(Global, NTuple)
        #= none:85 =#
        #= none:85 =# @inbounds preconditioner_rhs[i, j, k] = Δxᶜᶜᶜ(i, j, k, grid) * rhs[i, j, k]
    end
#= none:88 =#
#= none:88 =# @kernel function fourier_tridiagonal_preconditioner_rhs!(preconditioner_rhs, ::YDirection, grid, rhs)
        #= none:88 =#
        #= none:89 =#
        (i, j, k) = #= none:89 =# @index(Global, NTuple)
        #= none:90 =#
        #= none:90 =# @inbounds preconditioner_rhs[i, j, k] = Δyᶜᶜᶜ(i, j, k, grid) * rhs[i, j, k]
    end
#= none:93 =#
#= none:93 =# @kernel function fourier_tridiagonal_preconditioner_rhs!(preconditioner_rhs, ::ZDirection, grid, rhs)
        #= none:93 =#
        #= none:94 =#
        (i, j, k) = #= none:94 =# @index(Global, NTuple)
        #= none:95 =#
        #= none:95 =# @inbounds preconditioner_rhs[i, j, k] = Δzᶜᶜᶜ(i, j, k, grid) * rhs[i, j, k]
    end
#= none:98 =#
function compute_preconditioner_rhs!(solver::FFTBasedPoissonSolver, rhs)
    #= none:98 =#
    #= none:99 =#
    grid = solver.grid
    #= none:100 =#
    arch = architecture(grid)
    #= none:101 =#
    launch!(arch, grid, :xyz, fft_preconditioner_rhs!, solver.storage, rhs)
    #= none:102 =#
    return nothing
end
#= none:105 =#
function compute_preconditioner_rhs!(solver::FourierTridiagonalPoissonSolver, rhs)
    #= none:105 =#
    #= none:106 =#
    grid = solver.grid
    #= none:107 =#
    arch = architecture(grid)
    #= none:108 =#
    tridiagonal_dir = solver.batched_tridiagonal_solver.tridiagonal_direction
    #= none:109 =#
    launch!(arch, grid, :xyz, fourier_tridiagonal_preconditioner_rhs!, solver.storage, tridiagonal_dir, rhs)
    #= none:111 =#
    return nothing
end
#= none:114 =#
const FFTBasedPreconditioner = Union{FFTBasedPoissonSolver, FourierTridiagonalPoissonSolver}
#= none:116 =#
function precondition!(p, preconditioner::FFTBasedPreconditioner, r, args...)
    #= none:116 =#
    #= none:117 =#
    compute_preconditioner_rhs!(preconditioner, r)
    #= none:118 =#
    p = solve!(p, preconditioner)
    #= none:120 =#
    mean_p = mean(p)
    #= none:121 =#
    grid = p.grid
    #= none:122 =#
    arch = architecture(grid)
    #= none:123 =#
    launch!(arch, grid, :xyz, subtract_and_mask!, p, grid, mean_p)
    #= none:125 =#
    return p
end
#= none:128 =#
#= none:128 =# @kernel function subtract_and_mask!(a, grid, b)
        #= none:128 =#
        #= none:129 =#
        (i, j, k) = #= none:129 =# @index(Global, NTuple)
        #= none:130 =#
        active = !(inactive_cell(i, j, k, grid))
        #= none:131 =#
        a[i, j, k] = (a[i, j, k] - b) * active
    end
#= none:138 =#
struct DiagonallyDominantPreconditioner
    #= none:138 =#
end
#= none:139 =#
Base.summary(::DiagonallyDominantPreconditioner) = begin
        #= none:139 =#
        "DiagonallyDominantPreconditioner"
    end
#= none:141 =#
#= none:141 =# @inline function precondition!(p, ::DiagonallyDominantPreconditioner, r, args...)
        #= none:141 =#
        #= none:142 =#
        grid = r.grid
        #= none:143 =#
        arch = architecture(p)
        #= none:144 =#
        fill_halo_regions!(r)
        #= none:145 =#
        launch!(arch, grid, :xyz, _diagonally_dominant_precondition!, p, grid, r)
        #= none:147 =#
        mean_p = mean(p)
        #= none:148 =#
        launch!(arch, grid, :xyz, subtract_and_mask!, p, grid, mean_p)
        #= none:150 =#
        return p
    end
#= none:154 =#
#= none:154 =# @inline Ax⁻(i, j, k, grid) = begin
            #= none:154 =#
            (Axᶠᶜᶜ(i, j, k, grid) / Δxᶠᶜᶜ(i, j, k, grid)) / Vᶜᶜᶜ(i, j, k, grid)
        end
#= none:155 =#
#= none:155 =# @inline Ax⁺(i, j, k, grid) = begin
            #= none:155 =#
            (Axᶠᶜᶜ(i + 1, j, k, grid) / Δxᶠᶜᶜ(i + 1, j, k, grid)) / Vᶜᶜᶜ(i, j, k, grid)
        end
#= none:156 =#
#= none:156 =# @inline Ay⁻(i, j, k, grid) = begin
            #= none:156 =#
            (Ayᶜᶠᶜ(i, j, k, grid) / Δyᶜᶠᶜ(i, j, k, grid)) / Vᶜᶜᶜ(i, j, k, grid)
        end
#= none:157 =#
#= none:157 =# @inline Ay⁺(i, j, k, grid) = begin
            #= none:157 =#
            (Ayᶜᶠᶜ(i, j + 1, k, grid) / Δyᶜᶠᶜ(i, j + 1, k, grid)) / Vᶜᶜᶜ(i, j, k, grid)
        end
#= none:158 =#
#= none:158 =# @inline Az⁻(i, j, k, grid) = begin
            #= none:158 =#
            (Azᶜᶜᶠ(i, j, k, grid) / Δzᶜᶜᶠ(i, j, k, grid)) / Vᶜᶜᶜ(i, j, k, grid)
        end
#= none:159 =#
#= none:159 =# @inline Az⁺(i, j, k, grid) = begin
            #= none:159 =#
            (Azᶜᶜᶠ(i, j, k + 1, grid) / Δzᶜᶜᶠ(i, j, k + 1, grid)) / Vᶜᶜᶜ(i, j, k, grid)
        end
#= none:161 =#
#= none:161 =# @inline Ac(i, j, k, grid) = begin
            #= none:161 =#
            ((((-(Ax⁻(i, j, k, grid)) - Ax⁺(i, j, k, grid)) - Ay⁻(i, j, k, grid)) - Ay⁺(i, j, k, grid)) - Az⁻(i, j, k, grid)) - Az⁺(i, j, k, grid)
        end
#= none:165 =#
#= none:165 =# @inline heuristic_residual(i, j, k, grid, r) = begin
            #= none:165 =#
            #= none:166 =# @inbounds (1 / Ac(i, j, k, grid)) * ((((((r[i, j, k] - ((2 * Ax⁻(i, j, k, grid)) / (Ac(i, j, k, grid) + Ac(i - 1, j, k, grid))) * r[i - 1, j, k]) - ((2 * Ax⁺(i, j, k, grid)) / (Ac(i, j, k, grid) + Ac(i + 1, j, k, grid))) * r[i + 1, j, k]) - ((2 * Ay⁻(i, j, k, grid)) / (Ac(i, j, k, grid) + Ac(i, j - 1, k, grid))) * r[i, j - 1, k]) - ((2 * Ay⁺(i, j, k, grid)) / (Ac(i, j, k, grid) + Ac(i, j + 1, k, grid))) * r[i, j + 1, k]) - ((2 * Az⁻(i, j, k, grid)) / (Ac(i, j, k, grid) + Ac(i, j, k - 1, grid))) * r[i, j, k - 1]) - ((2 * Az⁺(i, j, k, grid)) / (Ac(i, j, k, grid) + Ac(i, j, k + 1, grid))) * r[i, j, k + 1])
        end
#= none:173 =#
#= none:173 =# @kernel function _diagonally_dominant_precondition!(p, grid, r)
        #= none:173 =#
        #= none:174 =#
        (i, j, k) = #= none:174 =# @index(Global, NTuple)
        #= none:175 =#
        active = !(inactive_cell(i, j, k, grid))
        #= none:176 =#
        #= none:176 =# @inbounds p[i, j, k] = heuristic_residual(i, j, k, grid, r) * active
    end