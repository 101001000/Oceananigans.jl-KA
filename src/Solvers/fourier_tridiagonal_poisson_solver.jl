
#= none:1 =#
using Oceananigans.Operators: Δxᶜᵃᵃ, Δxᶠᵃᵃ, Δyᵃᶜᵃ, Δyᵃᶠᵃ, Δzᵃᵃᶜ, Δzᵃᵃᶠ
#= none:2 =#
using Oceananigans.Grids: XYRegularRG, XZRegularRG, YZRegularRG, stretched_dimensions
#= none:4 =#
import Oceananigans.Architectures: architecture
#= none:6 =#
struct FourierTridiagonalPoissonSolver{G, B, R, S, β, T}
    #= none:7 =#
    grid::G
    #= none:8 =#
    batched_tridiagonal_solver::B
    #= none:9 =#
    source_term::R
    #= none:10 =#
    storage::S
    #= none:11 =#
    buffer::β
    #= none:12 =#
    transforms::T
end
#= none:15 =#
architecture(solver::FourierTridiagonalPoissonSolver) = begin
        #= none:15 =#
        architecture(solver.grid)
    end
#= none:17 =#
#= none:17 =# @kernel function compute_main_diagonal!(D, grid, λy, λz, ::XDirection)
        #= none:17 =#
        #= none:18 =#
        (j, k) = #= none:18 =# @index(Global, NTuple)
        #= none:19 =#
        Nx = size(grid, 1)
        #= none:22 =#
        #= none:22 =# @inbounds D[1, j, k] = -1 / Δxᶠᵃᵃ(2, j, k, grid) - Δxᶜᵃᵃ(1, j, k, grid) * (λy[j] + λz[k])
        #= none:23 =#
        for i = 2:Nx - 1
            #= none:24 =#
            #= none:24 =# @inbounds D[i, j, k] = -((1 / Δxᶠᵃᵃ(i + 1, j, k, grid) + 1 / Δxᶠᵃᵃ(i, j, k, grid))) - Δxᶜᵃᵃ(i, j, k, grid) * (λy[j] + λz[k])
            #= none:25 =#
        end
        #= none:26 =#
        #= none:26 =# @inbounds D[Nx, j, k] = -1 / Δxᶠᵃᵃ(Nx, j, k, grid) - Δxᶜᵃᵃ(Nx, j, k, grid) * (λy[j] + λz[k])
    end
#= none:29 =#
#= none:29 =# @kernel function compute_main_diagonal!(D, grid, λx, λz, ::YDirection)
        #= none:29 =#
        #= none:30 =#
        (i, k) = #= none:30 =# @index(Global, NTuple)
        #= none:31 =#
        Ny = size(grid, 2)
        #= none:34 =#
        #= none:34 =# @inbounds D[i, 1, k] = -1 / Δyᵃᶠᵃ(i, 2, k, grid) - Δyᵃᶜᵃ(i, 1, k, grid) * (λx[i] + λz[k])
        #= none:35 =#
        for j = 2:Ny - 1
            #= none:36 =#
            #= none:36 =# @inbounds D[i, j, k] = -((1 / Δyᵃᶠᵃ(i, j + 1, k, grid) + 1 / Δyᵃᶠᵃ(i, j, k, grid))) - Δyᵃᶜᵃ(i, j, k, grid) * (λx[i] + λz[k])
            #= none:37 =#
        end
        #= none:38 =#
        #= none:38 =# @inbounds D[i, Ny, k] = -1 / Δyᵃᶠᵃ(i, Ny, k, grid) - Δyᵃᶜᵃ(i, Ny, k, grid) * (λx[i] + λz[k])
    end
#= none:41 =#
#= none:41 =# @kernel function compute_main_diagonal!(D, grid, λx, λy, ::ZDirection)
        #= none:41 =#
        #= none:42 =#
        (i, j) = #= none:42 =# @index(Global, NTuple)
        #= none:43 =#
        Nz = size(grid, 3)
        #= none:46 =#
        #= none:46 =# @inbounds D[i, j, 1] = -1 / Δzᵃᵃᶠ(i, j, 2, grid) - Δzᵃᵃᶜ(i, j, 1, grid) * (λx[i] + λy[j])
        #= none:47 =#
        for k = 2:Nz - 1
            #= none:48 =#
            #= none:48 =# @inbounds D[i, j, k] = -((1 / Δzᵃᵃᶠ(i, j, k + 1, grid) + 1 / Δzᵃᵃᶠ(i, j, k, grid))) - Δzᵃᵃᶜ(i, j, k, grid) * (λx[i] + λy[j])
            #= none:49 =#
        end
        #= none:50 =#
        #= none:50 =# @inbounds D[i, j, Nz] = -1 / Δzᵃᵃᶠ(i, j, Nz, grid) - Δzᵃᵃᶜ(i, j, Nz, grid) * (λx[i] + λy[j])
    end
#= none:53 =#
stretched_direction(::YZRegularRG) = begin
        #= none:53 =#
        XDirection()
    end
#= none:54 =#
stretched_direction(::XZRegularRG) = begin
        #= none:54 =#
        YDirection()
    end
#= none:55 =#
stretched_direction(::XYRegularRG) = begin
        #= none:55 =#
        ZDirection()
    end
#= none:57 =#
Δξᶠ(i, grid::YZRegularRG) = begin
        #= none:57 =#
        Δxᶠᵃᵃ(i, 1, 1, grid)
    end
#= none:58 =#
Δξᶠ(j, grid::XZRegularRG) = begin
        #= none:58 =#
        Δyᵃᶠᵃ(1, j, 1, grid)
    end
#= none:59 =#
Δξᶠ(k, grid::XYRegularRG) = begin
        #= none:59 =#
        Δzᵃᵃᶠ(1, 1, k, grid)
    end
#= none:61 =#
extent(grid) = begin
        #= none:61 =#
        (grid.Lx, grid.Ly, grid.Lz)
    end
#= none:63 =#
function FourierTridiagonalPoissonSolver(grid, planner_flag = FFTW.PATIENT)
    #= none:63 =#
    #= none:64 =#
    irreg_dim = (stretched_dimensions(grid))[1]
    #= none:66 =#
    (regular_top1, regular_top2) = Tuple((el for (i, el) = enumerate(topology(grid)) if i ≠ irreg_dim))
    #= none:67 =#
    (regular_siz1, regular_siz2) = Tuple((el for (i, el) = enumerate(size(grid)) if i ≠ irreg_dim))
    #= none:68 =#
    (regular_ext1, regular_ext2) = Tuple((el for (i, el) = enumerate(extent(grid)) if i ≠ irreg_dim))
    #= none:70 =#
    topology(grid, irreg_dim) != Bounded && error("`FourierTridiagonalPoissonSolver` can only be used when the stretched direction's topology is `Bounded`.")
    #= none:73 =#
    λ1 = poisson_eigenvalues(regular_siz1, regular_ext1, 1, regular_top1())
    #= none:74 =#
    λ2 = poisson_eigenvalues(regular_siz2, regular_ext2, 2, regular_top2())
    #= none:76 =#
    arch = architecture(grid)
    #= none:77 =#
    λ1 = on_architecture(arch, λ1)
    #= none:78 =#
    λ2 = on_architecture(arch, λ2)
    #= none:81 =#
    sol_storage = on_architecture(arch, zeros(complex(eltype(grid)), size(grid)...))
    #= none:82 =#
    transforms = plan_transforms(grid, sol_storage, planner_flag)
    #= none:85 =#
    lower_diagonal = #= none:85 =# CUDA.@allowscalar([1 / Δξᶠ(q, grid) for q = 2:size(grid, irreg_dim)])
    #= none:86 =#
    lower_diagonal = on_architecture(arch, lower_diagonal)
    #= none:87 =#
    upper_diagonal = lower_diagonal
    #= none:90 =#
    diagonal = on_architecture(arch, zeros(size(grid)...))
    #= none:91 =#
    launch_config = if grid isa YZRegularRG
            #= none:92 =#
            :yz
        elseif #= none:93 =# grid isa XZRegularRG
            #= none:94 =#
            :xz
        elseif #= none:95 =# grid isa XYRegularRG
            #= none:96 =#
            :xy
        end
    #= none:99 =#
    tridiagonal_direction = stretched_direction(grid)
    #= none:100 =#
    launch!(arch, grid, launch_config, compute_main_diagonal!, diagonal, grid, λ1, λ2, tridiagonal_direction)
    #= none:103 =#
    btsolver = BatchedTridiagonalSolver(grid; lower_diagonal, diagonal, upper_diagonal, tridiagonal_direction)
    #= none:106 =#
    buffer_needed = arch isa GPU && Bounded in (regular_top1, regular_top2)
    #= none:107 =#
    buffer = if buffer_needed
            similar(sol_storage)
        else
            nothing
        end
    #= none:110 =#
    rhs = on_architecture(arch, zeros(complex(eltype(grid)), size(grid)...))
    #= none:112 =#
    return FourierTridiagonalPoissonSolver(grid, btsolver, rhs, sol_storage, buffer, transforms)
end
#= none:115 =#
function solve!(x, solver::FourierTridiagonalPoissonSolver, b = nothing)
    #= none:115 =#
    #= none:116 =#
    !(isnothing(b)) && set_source_term!(solver, b)
    #= none:118 =#
    arch = architecture(solver)
    #= none:119 =#
    ϕ = solver.storage
    #= none:122 =#
    for transform! = solver.transforms.forward
        #= none:123 =#
        transform!(solver.source_term, solver.buffer)
        #= none:124 =#
    end
    #= none:127 =#
    solve!(ϕ, solver.batched_tridiagonal_solver, solver.source_term)
    #= none:130 =#
    for transform! = solver.transforms.backward
        #= none:131 =#
        transform!(ϕ, solver.buffer)
        #= none:132 =#
    end
    #= none:138 =#
    ϕ .= ϕ .- mean(ϕ)
    #= none:140 =#
    launch!(arch, solver.grid, :xyz, copy_real_component!, x, ϕ, indices(x))
    #= none:142 =#
    return nothing
end
#= none:145 =#
#= none:145 =# Core.@doc "    set_source_term!(solver, source_term)\n\nSets the source term in the discrete Poisson equation `solver` to `source_term` by\nmultiplying it by the vertical grid spacing at cell centers in the stretched direction.\n" function set_source_term!(solver::FourierTridiagonalPoissonSolver, source_term)
        #= none:151 =#
        #= none:152 =#
        grid = solver.grid
        #= none:153 =#
        arch = architecture(solver)
        #= none:154 =#
        solver.source_term .= source_term
        #= none:155 =#
        launch!(arch, grid, :xyz, multiply_by_stretched_spacing!, solver.source_term, grid)
        #= none:156 =#
        return nothing
    end
#= none:160 =#
#= none:160 =# @kernel function multiply_by_stretched_spacing!(a, grid::YZRegularRG)
        #= none:160 =#
        #= none:161 =#
        (i, j, k) = #= none:161 =# @index(Global, NTuple)
        #= none:162 =#
        #= none:162 =# @inbounds a[i, j, k] *= Δxᶜᵃᵃ(i, j, k, grid)
    end
#= none:165 =#
#= none:165 =# @kernel function multiply_by_stretched_spacing!(a, grid::XZRegularRG)
        #= none:165 =#
        #= none:166 =#
        (i, j, k) = #= none:166 =# @index(Global, NTuple)
        #= none:167 =#
        #= none:167 =# @inbounds a[i, j, k] *= Δyᵃᶜᵃ(i, j, k, grid)
    end
#= none:170 =#
#= none:170 =# @kernel function multiply_by_stretched_spacing!(a, grid::XYRegularRG)
        #= none:170 =#
        #= none:171 =#
        (i, j, k) = #= none:171 =# @index(Global, NTuple)
        #= none:172 =#
        #= none:172 =# @inbounds a[i, j, k] *= Δzᵃᵃᶜ(i, j, k, grid)
    end