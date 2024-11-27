
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
#= none:3 =# @testset "Field broadcasting" begin
        #= none:4 =#
        #= none:4 =# @info "  Testing broadcasting with fields..."
        #= none:6 =#
        for arch = archs
            #= none:12 =#
            grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
            #= none:13 =#
            (a, b, c) = [CenterField(grid) for i = 1:3]
            #= none:15 =#
            (Nx, Ny, Nz) = size(a)
            #= none:17 =#
            a .= 1
            #= none:18 =#
            #= none:18 =# @test #= none:18 =# CUDA.@allowscalar(all(a .== 1))
            #= none:20 =#
            b .= 2
            #= none:22 =#
            c .= a .+ b
            #= none:23 =#
            #= none:23 =# @test #= none:23 =# CUDA.@allowscalar(all(c .== 3))
            #= none:25 =#
            c .= (a .+ b) .+ 1
            #= none:26 =#
            #= none:26 =# @test #= none:26 =# CUDA.@allowscalar(all(c .== 4))
            #= none:29 =#
            fill_halo_regions!(c)
            #= none:31 =#
            #= none:31 =# CUDA.@allowscalar begin
                    #= none:32 =#
                    #= none:32 =# @test c[1, 1, 0] == 4
                    #= none:33 =#
                    #= none:33 =# @test c[1, 1, Nz + 1] == 4
                end
            #= none:40 =#
            three_point_grid = RectilinearGrid(arch, size = (1, 1, 3), extent = (1, 1, 1))
            #= none:42 =#
            a2 = CenterField(three_point_grid)
            #= none:44 =#
            b2_bcs = FieldBoundaryConditions(grid, (Center, Center, Face), top = OpenBoundaryCondition(0), bottom = OpenBoundaryCondition(0))
            #= none:45 =#
            b2 = ZFaceField(three_point_grid, boundary_conditions = b2_bcs)
            #= none:47 =#
            b2 .= 1
            #= none:48 =#
            fill_halo_regions!(b2)
            #= none:50 =#
            #= none:50 =# CUDA.@allowscalar begin
                    #= none:51 =#
                    #= none:51 =# @test b2[1, 1, 1] == 0
                    #= none:52 =#
                    #= none:52 =# @test b2[1, 1, 2] == 1
                    #= none:53 =#
                    #= none:53 =# @test b2[1, 1, 3] == 1
                    #= none:54 =#
                    #= none:54 =# @test b2[1, 1, 4] == 0
                end
            #= none:57 =#
            a2 .= b2
            #= none:59 =#
            #= none:59 =# CUDA.@allowscalar begin
                    #= none:60 =#
                    #= none:60 =# @test a2[1, 1, 1] == 0.5
                    #= none:61 =#
                    #= none:61 =# @test a2[1, 1, 2] == 1.0
                    #= none:62 =#
                    #= none:62 =# @test a2[1, 1, 3] == 0.5
                end
            #= none:65 =#
            a2 .= b2 .+ 1
            #= none:67 =#
            #= none:67 =# CUDA.@allowscalar begin
                    #= none:68 =#
                    #= none:68 =# @test a2[1, 1, 1] == 1.5
                    #= none:69 =#
                    #= none:69 =# @test a2[1, 1, 2] == 2.0
                    #= none:70 =#
                    #= none:70 =# @test a2[1, 1, 3] == 1.5
                end
            #= none:77 =#
            for loc = [(Nothing, Center, Center), (Center, Nothing, Center), (Center, Center, Nothing), (Center, Nothing, Nothing), (Nothing, Center, Nothing), (Nothing, Nothing, Center), (Nothing, Nothing, Nothing)]
                #= none:87 =#
                #= none:87 =# @info "    Testing broadcasting to location $(loc)..."
                #= none:89 =#
                (r, p, q) = [Field(loc, grid) for i = 1:3]
                #= none:91 =#
                r .= 2
                #= none:92 =#
                #= none:92 =# @test #= none:92 =# CUDA.@allowscalar(all(r .== 2))
                #= none:94 =#
                p .= 3
                #= none:96 =#
                q .= r .* p
                #= none:97 =#
                #= none:97 =# @test #= none:97 =# CUDA.@allowscalar(all(q .== 6))
                #= none:99 =#
                q .= r .* p .+ 1
                #= none:100 =#
                #= none:100 =# @test #= none:100 =# CUDA.@allowscalar(all(q .== 7))
                #= none:101 =#
            end
            #= none:108 =#
            two_two_two_grid = RectilinearGrid(arch, size = (2, 2, 2), extent = (1, 1, 1))
            #= none:110 =#
            c = CenterField(two_two_two_grid)
            #= none:111 =#
            random_column = on_architecture(arch, reshape(rand(2), 1, 1, 2))
            #= none:113 =#
            c .= random_column
            #= none:115 =#
            c_cpu = Array(interior(c))
            #= none:116 =#
            random_column_cpu = Array(random_column)
            #= none:118 =#
            #= none:118 =# @test all(c_cpu[1, 1, :] .== random_column_cpu[:])
            #= none:119 =#
            #= none:119 =# @test all(c_cpu[2, 1, :] .== random_column_cpu[:])
            #= none:120 =#
            #= none:120 =# @test all(c_cpu[1, 2, :] .== random_column_cpu[:])
            #= none:121 =#
            #= none:121 =# @test all(c_cpu[2, 2, :] .== random_column_cpu[:])
            #= none:122 =#
        end
    end