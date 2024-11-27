
#= none:1 =#
using MPI
#= none:3 =#
MPI.Init()
#= none:5 =#
include("dependencies_for_runtests.jl")
#= none:7 =#
using Oceananigans.DistributedComputations: TransposableField, transpose_z_to_y!, transpose_y_to_z!, transpose_y_to_x!, transpose_x_to_y!
#= none:13 =#
function test_transpose(grid_points, ranks, topo, child_arch)
    #= none:13 =#
    #= none:14 =#
    arch = Distributed(child_arch, partition = Partition(ranks...))
    #= none:15 =#
    grid = RectilinearGrid(arch, topology = topo, size = grid_points, extent = (2π, 2π, 2π))
    #= none:17 =#
    loc = (Center, Center, Center)
    #= none:18 =#
    ϕ = Field(loc, grid, ComplexF64)
    #= none:19 =#
    Φ = TransposableField(ϕ)
    #= none:21 =#
    ϕ₀ = on_architecture(child_arch, rand(ComplexF64, size(ϕ)))
    #= none:24 =#
    set!(ϕ, ϕ₀)
    #= none:25 =#
    set!(Φ.zfield, ϕ)
    #= none:28 =#
    transpose_z_to_y!(Φ)
    #= none:29 =#
    transpose_y_to_x!(Φ)
    #= none:30 =#
    transpose_x_to_y!(Φ)
    #= none:31 =#
    transpose_y_to_z!(Φ)
    #= none:34 =#
    same_real_part = all(real.(Array(interior(ϕ))) .== real.(Array(interior(Φ.zfield))))
    #= none:35 =#
    same_imag_part = all(imag.(Array(interior(ϕ))) .== imag.(Array(interior(Φ.zfield))))
    #= none:37 =#
    return same_real_part & same_imag_part
end
#= none:40 =#
#= none:40 =# @testset "Distributed Transpose" begin
        #= none:41 =#
        child_arch = test_child_arch()
        #= none:43 =#
        for topology = ((Periodic, Periodic, Periodic), (Periodic, Periodic, Bounded), (Periodic, Bounded, Bounded), (Bounded, Bounded, Bounded))
            #= none:47 =#
            #= none:47 =# @info "  Testing 3D transpose with topology $(topology)..."
            #= none:48 =#
            #= none:48 =# @test test_transpose((44, 44, 8), (4, 1, 1), topology, child_arch)
            #= none:49 =#
            #= none:49 =# @test test_transpose((16, 44, 8), (4, 1, 1), topology, child_arch)
            #= none:50 =#
            #= none:50 =# @test test_transpose((44, 44, 8), (1, 4, 1), topology, child_arch)
            #= none:51 =#
            #= none:51 =# @test test_transpose((44, 16, 8), (1, 4, 1), topology, child_arch)
            #= none:52 =#
            #= none:52 =# @test test_transpose((16, 44, 8), (1, 4, 1), topology, child_arch)
            #= none:53 =#
            #= none:53 =# @test test_transpose((44, 16, 8), (2, 2, 1), topology, child_arch)
            #= none:54 =#
            #= none:54 =# @test test_transpose((16, 44, 8), (2, 2, 1), topology, child_arch)
            #= none:55 =#
        end
    end