
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Solvers: solve!, HeptadiagonalIterativeSolver, sparse_approximate_inverse
#= none:4 =#
using Oceananigans.Operators: volume, Δyᶠᶜᵃ, Δyᶜᶠᵃ, Δyᶜᶜᵃ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶜᶜᵃ, Δyᵃᶜᵃ, Δxᶜᵃᵃ, Δzᵃᵃᶠ, Δzᵃᵃᶜ, ∇²ᶜᶜᶜ
#= none:6 =#
function identity_operator!(b, x)
    #= none:6 =#
    #= none:7 =#
    parent(b) .= parent(x)
    #= none:8 =#
    return nothing
end
#= none:11 =#
function run_identity_operator_test(grid)
    #= none:11 =#
    #= none:12 =#
    N = size(grid)
    #= none:13 =#
    M = prod(N)
    #= none:15 =#
    A = zeros(grid, N...)
    #= none:16 =#
    D = zeros(grid, N...)
    #= none:17 =#
    C = zeros(grid, N...)
    #= none:18 =#
    fill!(C, 1)
    #= none:20 =#
    solver = HeptadiagonalIterativeSolver((A, A, A, C, D), grid = grid)
    #= none:22 =#
    b = on_architecture(architecture(grid), rand(M))
    #= none:24 =#
    arch = architecture(grid)
    #= none:25 =#
    storage = on_architecture(arch, zeros(size(b)))
    #= none:26 =#
    solve!(storage, solver, b, 1.0)
    #= none:28 =#
    #= none:28 =# @test norm(Array(storage) .- Array(b)) .< solver.tolerance
end
#= none:31 =#
#= none:31 =# @kernel function _multiply_by_volume!(r, grid)
        #= none:31 =#
        #= none:32 =#
        (i, j, k) = #= none:32 =# @index(Global, NTuple)
        #= none:33 =#
        r[i, j, k] *= volume(i, j, k, grid, Center(), Center(), Center())
    end
#= none:36 =#
#= none:36 =# @kernel function _compute_poisson_weights(Ax, Ay, Az, grid)
        #= none:36 =#
        #= none:37 =#
        (i, j, k) = #= none:37 =# @index(Global, NTuple)
        #= none:38 =#
        Ax[i, j, k] = (Δzᵃᵃᶜ(i, j, k, grid) * Δyᶠᶜᵃ(i, j, k, grid)) / Δxᶠᶜᵃ(i, j, k, grid)
        #= none:39 =#
        Ay[i, j, k] = (Δzᵃᵃᶜ(i, j, k, grid) * Δxᶜᶠᵃ(i, j, k, grid)) / Δyᶜᶠᵃ(i, j, k, grid)
        #= none:40 =#
        Az[i, j, k] = (Δxᶜᶜᵃ(i, j, k, grid) * Δyᶜᶜᵃ(i, j, k, grid)) / Δzᵃᵃᶠ(i, j, k, grid)
    end
#= none:43 =#
function compute_poisson_weights(grid)
    #= none:43 =#
    #= none:44 =#
    N = size(grid)
    #= none:45 =#
    Ax = on_architecture(architecture(grid), zeros(N...))
    #= none:46 =#
    Ay = on_architecture(architecture(grid), zeros(N...))
    #= none:47 =#
    Az = on_architecture(architecture(grid), zeros(N...))
    #= none:48 =#
    C = on_architecture(architecture(grid), zeros(grid, N...))
    #= none:49 =#
    D = on_architecture(architecture(grid), zeros(grid, N...))
    #= none:51 =#
    launch!(architecture(grid), grid, :xyz, _compute_poisson_weights, Ax, Ay, Az, grid)
    #= none:53 =#
    return (Ax, Ay, Az, C, D)
end
#= none:56 =#
poisson_rhs!(r, grid) = begin
        #= none:56 =#
        launch!(architecture(grid), grid, :xyz, _multiply_by_volume!, r, grid)
    end
#= none:58 =#
random_numbers(x, y = 0, z = 0) = begin
        #= none:58 =#
        rand()
    end
#= none:60 =#
function run_poisson_equation_test(grid)
    #= none:60 =#
    #= none:61 =#
    arch = architecture(grid)
    #= none:64 =#
    ϕ_truth = CenterField(grid)
    #= none:67 =#
    set!(ϕ_truth, random_numbers)
    #= none:68 =#
    parent(ϕ_truth) .-= mean(ϕ_truth)
    #= none:69 =#
    fill_halo_regions!(ϕ_truth)
    #= none:72 =#
    ∇²ϕ = CenterField(grid)
    #= none:73 =#
    compute_∇²!(∇²ϕ, ϕ_truth, arch, grid)
    #= none:75 =#
    rhs = deepcopy(∇²ϕ)
    #= none:76 =#
    poisson_rhs!(rhs, grid)
    #= none:77 =#
    rhs = copy(interior(rhs))
    #= none:78 =#
    rhs = reshape(rhs, length(rhs))
    #= none:79 =#
    weights = compute_poisson_weights(grid)
    #= none:80 =#
    solver = HeptadiagonalIterativeSolver(weights, grid = grid, preconditioner_method = nothing)
    #= none:83 =#
    ϕ_solution = CenterField(grid)
    #= none:85 =#
    arch = architecture(grid)
    #= none:86 =#
    storage = on_architecture(arch, zeros(size(rhs)))
    #= none:87 =#
    solve!(storage, solver, rhs, 1.0)
    #= none:88 =#
    set!(ϕ_solution, reshape(storage, solver.problem_size...))
    #= none:89 =#
    fill_halo_regions!(ϕ_solution)
    #= none:92 =#
    ∇²ϕ_solution = CenterField(grid)
    #= none:93 =#
    compute_∇²!(∇²ϕ_solution, ϕ_solution, arch, grid)
    #= none:95 =#
    parent(ϕ_solution) .-= mean(ϕ_solution)
    #= none:97 =#
    #= none:97 =# CUDA.@allowscalar begin
            #= none:98 =#
            #= none:98 =# @test all(interior(∇²ϕ_solution) .≈ interior(∇²ϕ))
            #= none:99 =#
            #= none:99 =# @test all(interior(ϕ_solution) .≈ interior(ϕ_truth))
        end
    #= none:102 =#
    return nothing
end
#= none:105 =#
#= none:105 =# @testset "HeptadiagonalIterativeSolver" begin
        #= none:106 =#
        topologies = [(Periodic, Periodic, Flat), (Bounded, Bounded, Flat), (Periodic, Bounded, Flat), (Bounded, Periodic, Flat)]
        #= none:108 =#
        for arch = archs, topo = topologies
            #= none:109 =#
            #= none:109 =# @info "Testing 2D HeptadiagonalIterativeSolver [$(typeof(arch)) $(topo)]..."
            #= none:111 =#
            grid = RectilinearGrid(arch, size = (4, 8), extent = (1, 3), topology = topo)
            #= none:112 =#
            run_identity_operator_test(grid)
            #= none:113 =#
            run_poisson_equation_test(grid)
            #= none:114 =#
        end
        #= none:116 =#
        topologies = [(Periodic, Periodic, Periodic), (Bounded, Bounded, Periodic), (Periodic, Bounded, Periodic), (Bounded, Periodic, Bounded)]
        #= none:118 =#
        for arch = archs, topo = topologies
            #= none:119 =#
            #= none:119 =# @info "Testing 3D HeptadiagonalIterativeSolver [$(typeof(arch)) $(topo)]..."
            #= none:121 =#
            grid = RectilinearGrid(arch, size = (4, 8, 6), extent = (1, 3, 4), topology = topo)
            #= none:122 =#
            run_identity_operator_test(grid)
            #= none:123 =#
            run_poisson_equation_test(grid)
            #= none:124 =#
        end
        #= none:126 =#
        stretched_faces = [0, 1.5, 3, 7, 8.5, 10]
        #= none:127 =#
        topo = (Periodic, Periodic, Periodic)
        #= none:128 =#
        sz = (5, 5, 5)
        #= none:130 =#
        for arch = archs
            #= none:131 =#
            grids = [RectilinearGrid(arch, size = sz, x = stretched_faces, y = (0, 10), z = (0, 10), topology = topo), RectilinearGrid(arch, size = sz, x = (0, 10), y = stretched_faces, z = (0, 10), topology = topo), RectilinearGrid(arch, size = sz, x = (0, 10), y = (0, 10), z = stretched_faces, topology = topo)]
            #= none:135 =#
            for (grid, stretched_direction) = zip(grids, [:x, :y, :z])
                #= none:136 =#
                #= none:136 =# @info "  Testing HeptadiagonalIterativeSolver [stretched in $(stretched_direction), $(typeof(arch))]..."
                #= none:137 =#
                run_poisson_equation_test(grid)
                #= none:138 =#
            end
            #= none:140 =#
            if arch isa CPU
                #= none:141 =#
                #= none:141 =# @info "  Testing Sparse Approximate Inverse..."
                #= none:143 =#
                A = sprand(10, 10, 0.1)
                #= none:144 =#
                A = A + A' + 1I
                #= none:145 =#
                A⁻¹ = sparse(inv(Array(A)))
                #= none:146 =#
                M = sparse_approximate_inverse(A, ε = eps(eltype(A)), nzrel = size(A, 1))
                #= none:148 =#
                #= none:148 =# @test all(Array(M) .≈ A⁻¹)
            end
            #= none:150 =#
        end
    end