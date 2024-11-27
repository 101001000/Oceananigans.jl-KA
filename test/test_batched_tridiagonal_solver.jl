
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using LinearAlgebra
#= none:4 =#
using Oceananigans.Architectures: array_type
#= none:5 =#
using Oceananigans.Grids: XDirection, YDirection, ZDirection
#= none:7 =#
function can_solve_single_tridiagonal_system(arch, N; tridiagonal_direction = ZDirection())
    #= none:7 =#
    #= none:8 =#
    ArrayType = array_type(arch)
    #= none:10 =#
    a = rand(N - 1)
    #= none:11 =#
    b = 3 .+ rand(N)
    #= none:12 =#
    c = rand(N - 1)
    #= none:13 =#
    f = rand(N)
    #= none:16 =#
    M = Tridiagonal(a, b, c)
    #= none:17 =#
    ϕ_correct = M \ f
    #= none:20 =#
    (a, b, c, f) = ArrayType.([a, b, c, f])
    #= none:22 =#
    if tridiagonal_direction isa XDirection
        #= none:23 =#
        ϕ = reshape(zeros(N), (N, 1, 1)) |> ArrayType
        #= none:24 =#
        grid = RectilinearGrid(arch, size = (N, 1, 1), extent = (1, 1, 1))
    elseif #= none:25 =# tridiagonal_direction isa YDirection
        #= none:26 =#
        ϕ = reshape(zeros(N), (1, N, 1)) |> ArrayType
        #= none:27 =#
        grid = RectilinearGrid(arch, size = (1, N, 1), extent = (1, 1, 1))
    elseif #= none:28 =# tridiagonal_direction isa ZDirection
        #= none:29 =#
        ϕ = reshape(zeros(N), (1, 1, N)) |> ArrayType
        #= none:30 =#
        grid = RectilinearGrid(arch, size = (1, 1, N), extent = (1, 1, 1))
    end
    #= none:33 =#
    btsolver = BatchedTridiagonalSolver(grid; lower_diagonal = a, diagonal = b, upper_diagonal = c, tridiagonal_direction)
    #= none:39 =#
    solve!(ϕ, btsolver, f)
    #= none:41 =#
    return Array(ϕ[:]) ≈ ϕ_correct
end
#= none:44 =#
function can_solve_batched_tridiagonal_system_with_3D_RHS(arch, Nx, Ny, Nz; tridiagonal_direction = ZDirection())
    #= none:44 =#
    #= none:45 =#
    ArrayType = array_type(arch)
    #= none:47 =#
    N = if tridiagonal_direction isa XDirection
            #= none:48 =#
            Nx
        elseif #= none:49 =# tridiagonal_direction == YDirection()
            #= none:50 =#
            Ny
        elseif #= none:51 =# tridiagonal_direction isa ZDirection
            #= none:52 =#
            Nz
        end
    #= none:55 =#
    a = rand(N - 1)
    #= none:56 =#
    b = 3 .+ rand(N)
    #= none:57 =#
    c = rand(N - 1)
    #= none:58 =#
    f = rand(Nx, Ny, Nz)
    #= none:60 =#
    M = Tridiagonal(a, b, c)
    #= none:61 =#
    ϕ_correct = zeros(Nx, Ny, Nz)
    #= none:64 =#
    if tridiagonal_direction isa XDirection
        #= none:65 =#
        for j = 1:Ny, k = 1:Nz
            #= none:66 =#
            ϕ_correct[:, j, k] .= M \ f[:, j, k]
            #= none:67 =#
        end
    elseif #= none:68 =# tridiagonal_direction isa YDirection
        #= none:69 =#
        for i = 1:Nx, k = 1:Nz
            #= none:70 =#
            ϕ_correct[i, :, k] .= M \ f[i, :, k]
            #= none:71 =#
        end
    elseif #= none:72 =# tridiagonal_direction isa ZDirection
        #= none:73 =#
        for i = 1:Nx, j = 1:Ny
            #= none:74 =#
            ϕ_correct[i, j, :] .= M \ f[i, j, :]
            #= none:75 =#
        end
    end
    #= none:79 =#
    (a, b, c, f) = ArrayType.([a, b, c, f])
    #= none:81 =#
    grid = RectilinearGrid(arch, size = (Nx, Ny, Nz), extent = (1, 1, 1))
    #= none:82 =#
    btsolver = BatchedTridiagonalSolver(grid; lower_diagonal = a, diagonal = b, upper_diagonal = c, tridiagonal_direction)
    #= none:88 =#
    ϕ = zeros(Nx, Ny, Nz) |> ArrayType
    #= none:90 =#
    solve!(ϕ, btsolver, f)
    #= none:92 =#
    return Array(ϕ) ≈ ϕ_correct
end
#= none:95 =#
#= none:95 =# @testset "Batched tridiagonal solvers" begin
        #= none:96 =#
        #= none:96 =# @info "Testing BatchedTridiagonalSolver..."
        #= none:98 =#
        for arch = archs
            #= none:99 =#
            #= none:99 =# @testset "Batched tridiagonal solver [$(arch)]" begin
                    #= none:100 =#
                    for Nx = [3, 8], Ny = [5, 16], Nz = [8, 11]
                        #= none:101 =#
                        #= none:101 =# @test can_solve_batched_tridiagonal_system_with_3D_RHS(arch, Nx, Ny, Nz)
                        #= none:102 =#
                        for tridiagonal_direction = (XDirection(), YDirection(), ZDirection())
                            #= none:103 =#
                            #= none:103 =# @test can_solve_single_tridiagonal_system(arch, Nz; tridiagonal_direction)
                            #= none:104 =#
                        end
                        #= none:105 =#
                    end
                    #= none:107 =#
                    for Nx = [3, 8], Ny = [5, 16], Nz = [8, 11]
                        #= none:108 =#
                        for tridiagonal_direction = (XDirection(), YDirection(), ZDirection())
                            #= none:109 =#
                            #= none:109 =# @test can_solve_batched_tridiagonal_system_with_3D_RHS(arch, Nx, Ny, Nz; tridiagonal_direction)
                            #= none:110 =#
                        end
                        #= none:111 =#
                    end
                end
            #= none:113 =#
        end
    end