
#= none:1 =#
using MPI
#= none:2 =#
MPI.Init()
#= none:6 =#
using Random
#= none:7 =#
Random.seed!(1234)
#= none:9 =#
include("dependencies_for_runtests.jl")
#= none:10 =#
include("dependencies_for_poisson_solvers.jl")
#= none:33 =#
using Oceananigans.DistributedComputations: reconstruct_global_grid, DistributedGrid, Partition, DistributedFourierTridiagonalPoissonSolver
#= none:34 =#
using Oceananigans.Models.NonhydrostaticModels: solve_for_pressure!
#= none:36 =#
function random_divergent_source_term(grid::DistributedGrid)
    #= none:36 =#
    #= none:37 =#
    arch = architecture(grid)
    #= none:38 =#
    default_bcs = FieldBoundaryConditions()
    #= none:40 =#
    u_bcs = regularize_field_boundary_conditions(default_bcs, grid, :u)
    #= none:41 =#
    v_bcs = regularize_field_boundary_conditions(default_bcs, grid, :v)
    #= none:42 =#
    w_bcs = regularize_field_boundary_conditions(default_bcs, grid, :w)
    #= none:44 =#
    u_bcs = inject_halo_communication_boundary_conditions(u_bcs, arch.local_rank, arch.connectivity, topology(grid))
    #= none:45 =#
    v_bcs = inject_halo_communication_boundary_conditions(v_bcs, arch.local_rank, arch.connectivity, topology(grid))
    #= none:46 =#
    w_bcs = inject_halo_communication_boundary_conditions(w_bcs, arch.local_rank, arch.connectivity, topology(grid))
    #= none:48 =#
    Ru = XFaceField(grid, boundary_conditions = u_bcs)
    #= none:49 =#
    Rv = YFaceField(grid, boundary_conditions = v_bcs)
    #= none:50 =#
    Rw = ZFaceField(grid, boundary_conditions = w_bcs)
    #= none:51 =#
    U = (u = Ru, v = Rv, w = Rw)
    #= none:53 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:54 =#
    set!(Ru, rand(size(Ru)...))
    #= none:55 =#
    set!(Rv, rand(size(Rv)...))
    #= none:56 =#
    set!(Rw, rand(size(Rw)...))
    #= none:58 =#
    fill_halo_regions!(Ru)
    #= none:59 =#
    fill_halo_regions!(Rv)
    #= none:60 =#
    fill_halo_regions!(Rw)
    #= none:63 =#
    ArrayType = array_type(arch)
    #= none:64 =#
    R = zeros(Nx, Ny, Nz) |> ArrayType
    #= none:65 =#
    launch!(arch, grid, :xyz, divergence!, grid, U.u.data, U.v.data, U.w.data, R)
    #= none:67 =#
    return (R, U)
end
#= none:70 =#
function divergence_free_poisson_solution(grid_points, ranks, topo, child_arch)
    #= none:70 =#
    #= none:71 =#
    arch = Distributed(child_arch, partition = Partition(ranks...))
    #= none:72 =#
    local_grid = RectilinearGrid(arch, topology = topo, size = grid_points, extent = (2π, 2π, 2π))
    #= none:75 =#
    ϕ = CenterField(local_grid)
    #= none:76 =#
    ∇²ϕ = CenterField(local_grid)
    #= none:77 =#
    (R, U) = random_divergent_source_term(local_grid)
    #= none:79 =#
    global_grid = reconstruct_global_grid(local_grid)
    #= none:80 =#
    solver = DistributedFFTBasedPoissonSolver(global_grid, local_grid)
    #= none:83 =#
    solve_for_pressure!(ϕ, solver, 1, U)
    #= none:86 =#
    compute_∇²!(∇²ϕ, ϕ, arch, local_grid)
    #= none:88 =#
    return Array(interior(∇²ϕ)) ≈ Array(R)
end
#= none:91 =#
function divergence_free_poisson_tridiagonal_solution(grid_points, ranks, stretched_direction, child_arch)
    #= none:91 =#
    #= none:92 =#
    arch = Distributed(child_arch, partition = Partition(ranks...))
    #= none:94 =#
    if stretched_direction == :x
        #= none:95 =#
        x = collect(range(0, 2π, length = grid_points[1] + 1))
        #= none:96 =#
        y = (z = (0, 2π))
    elseif #= none:97 =# stretched_direction == :y
        #= none:98 =#
        y = collect(range(0, 2π, length = grid_points[2] + 1))
        #= none:99 =#
        x = (z = (0, 2π))
    elseif #= none:100 =# stretched_direction == :z
        #= none:101 =#
        z = collect(range(0, 2π, length = grid_points[3] + 1))
        #= none:102 =#
        x = (y = (0, 2π))
    end
    #= none:105 =#
    local_grid = RectilinearGrid(arch; topology = (Bounded, Bounded, Bounded), size = grid_points, x, y, z)
    #= none:108 =#
    ϕ = CenterField(local_grid)
    #= none:109 =#
    ∇²ϕ = CenterField(local_grid)
    #= none:110 =#
    (R, U) = random_divergent_source_term(local_grid)
    #= none:112 =#
    global_grid = reconstruct_global_grid(local_grid)
    #= none:113 =#
    solver = DistributedFourierTridiagonalPoissonSolver(global_grid, local_grid)
    #= none:116 =#
    solve_for_pressure!(ϕ, solver, 1, U)
    #= none:119 =#
    compute_∇²!(∇²ϕ, ϕ, arch, local_grid)
    #= none:121 =#
    return Array(interior(∇²ϕ)) ≈ Array(R)
end
#= none:124 =#
#= none:124 =# @testset "Distributed FFT-based Poisson solver" begin
        #= none:125 =#
        child_arch = test_child_arch()
        #= none:127 =#
        for topology = ((Periodic, Periodic, Periodic), (Periodic, Periodic, Bounded), (Periodic, Bounded, Bounded), (Bounded, Bounded, Bounded))
            #= none:132 =#
            #= none:132 =# @info "  Testing 3D distributed FFT-based Poisson solver with topology $(topology)..."
            #= none:133 =#
            #= none:133 =# @test divergence_free_poisson_solution((44, 44, 8), (4, 1, 1), topology, child_arch)
            #= none:134 =#
            #= none:134 =# @test divergence_free_poisson_solution((16, 44, 8), (4, 1, 1), topology, child_arch)
            #= none:135 =#
            #= none:135 =# @test divergence_free_poisson_solution((44, 44, 8), (1, 4, 1), topology, child_arch)
            #= none:136 =#
            #= none:136 =# @test divergence_free_poisson_solution((44, 16, 8), (1, 4, 1), topology, child_arch)
            #= none:137 =#
            #= none:137 =# @test divergence_free_poisson_solution((16, 44, 8), (1, 4, 1), topology, child_arch)
            #= none:138 =#
            #= none:138 =# @test divergence_free_poisson_solution((22, 44, 8), (2, 2, 1), topology, child_arch)
            #= none:139 =#
            #= none:139 =# @test divergence_free_poisson_solution((44, 22, 8), (2, 2, 1), topology, child_arch)
            #= none:141 =#
            #= none:141 =# @info "  Testing 2D distributed FFT-based Poisson solver with topology $(topology)..."
            #= none:142 =#
            #= none:142 =# @test divergence_free_poisson_solution((44, 16, 1), (4, 1, 1), topology, child_arch)
            #= none:143 =#
            #= none:143 =# @test divergence_free_poisson_solution((16, 44, 1), (4, 1, 1), topology, child_arch)
            #= none:144 =#
        end
        #= none:146 =#
        for stretched_direction = (:x, :y, :z)
            #= none:147 =#
            #= none:147 =# @info "  Testing 3D distributed Fourier Tridiagonal Poisson solver stretched in $(stretched_direction)"
            #= none:148 =#
            #= none:148 =# @test divergence_free_poisson_tridiagonal_solution((44, 44, 8), (1, 4, 1), stretched_direction, child_arch)
            #= none:149 =#
            #= none:149 =# @test divergence_free_poisson_tridiagonal_solution((44, 4, 8), (1, 4, 1), stretched_direction, child_arch)
            #= none:150 =#
            #= none:150 =# @test divergence_free_poisson_tridiagonal_solution((16, 44, 8), (1, 4, 1), stretched_direction, child_arch)
            #= none:151 =#
            #= none:151 =# @test divergence_free_poisson_tridiagonal_solution((22, 8, 8), (2, 2, 1), stretched_direction, child_arch)
            #= none:152 =#
            #= none:152 =# @test divergence_free_poisson_tridiagonal_solution((8, 22, 8), (2, 2, 1), stretched_direction, child_arch)
            #= none:153 =#
            #= none:153 =# @test divergence_free_poisson_tridiagonal_solution((44, 44, 8), (1, 4, 1), stretched_direction, child_arch)
            #= none:154 =#
            #= none:154 =# @test divergence_free_poisson_tridiagonal_solution((44, 4, 8), (1, 4, 1), stretched_direction, child_arch)
            #= none:155 =#
            #= none:155 =# @test divergence_free_poisson_tridiagonal_solution((16, 44, 8), (1, 4, 1), stretched_direction, child_arch)
            #= none:156 =#
            #= none:156 =# @test divergence_free_poisson_tridiagonal_solution((22, 8, 8), (2, 2, 1), stretched_direction, child_arch)
            #= none:157 =#
            #= none:157 =# @test divergence_free_poisson_tridiagonal_solution((8, 22, 8), (2, 2, 1), stretched_direction, child_arch)
            #= none:158 =#
        end
    end