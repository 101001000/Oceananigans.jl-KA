
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
#= none:3 =# @testset "Conditional Reductions" begin
        #= none:4 =#
        for arch = archs
            #= none:5 =#
            #= none:5 =# @info "    Testing Reductions on Immersed fields"
            #= none:7 =#
            grid = RectilinearGrid(arch, size = (6, 1, 1), extent = (1, 1, 1))
            #= none:9 =#
            ibg = ImmersedBoundaryGrid(grid, GridFittedBoundary(((x, y, z)->begin
                                #= none:9 =#
                                x < 0.5
                            end)))
            #= none:11 =#
            fful = Field{Center, Center, Center}(grid)
            #= none:12 =#
            fimm = Field{Center, Center, Center}(ibg)
            #= none:14 =#
            #= none:14 =# @test conditional_length(fimm) == length(fimm) / 2
            #= none:16 =#
            fful .= 2
            #= none:17 =#
            fimm .= 2
            #= none:19 =#
            fimm[1, :, :] .= 1.0e6
            #= none:20 =#
            fimm[2, :, :] .= -10000.0
            #= none:21 =#
            fimm[3, :, :] .= -12.5
            #= none:23 =#
            #= none:23 =# @test norm(fful) ≈ √2 * norm(fimm)
            #= none:24 =#
            #= none:24 =# @test mean(fful) ≈ mean(fimm)
            #= none:26 =#
            for reduc = (mean, maximum, minimum)
                #= none:27 =#
                #= none:27 =# @test reduc(fful) == reduc(fimm)
                #= none:28 =#
                #= none:28 =# @test all(Array(interior(reduc(fful, dims = 1)) .== interior(reduc(fimm, dims = 1))))
                #= none:29 =#
            end
            #= none:31 =#
            #= none:31 =# @test sum(fful) == sum(fimm) * 2
            #= none:32 =#
            #= none:32 =# @test all(Array(interior(sum(fful, dims = 1)) .== interior(sum(fimm, dims = 1)) .* 2))
            #= none:34 =#
            #= none:34 =# @test prod(fful) == prod(fimm) * 8
            #= none:35 =#
            #= none:35 =# @test all(Array(interior(prod(fful, dims = 1)) .== interior(prod(fimm, dims = 1)) .* 8))
            #= none:37 =#
            #= none:37 =# @info "    Testing Reductions in Standard fields"
            #= none:39 =#
            fcon = Field{Center, Center, Center}(grid)
            #= none:41 =#
            fcon .= 2
            #= none:43 =#
            fcon[1, :, :] .= 1.0e6
            #= none:44 =#
            fcon[2, :, :] .= -10000.0
            #= none:45 =#
            fcon[3, :, :] .= -12.5
            #= none:47 =#
            #= none:47 =# @test norm(fful) ≈ √2 * norm(fcon, condition = ((i, j, k, x, y)->begin
                                        #= none:47 =#
                                        i > 3
                                    end))
            #= none:49 =#
            for reduc = (mean, maximum, minimum)
                #= none:50 =#
                #= none:50 =# @test reduc(fful) == reduc(fcon, condition = ((i, j, k, x, y)->begin
                                        #= none:50 =#
                                        i > 3
                                    end))
                #= none:51 =#
                #= none:51 =# @test all(Array(interior(reduc(fful, dims = 1)) .== interior(reduc(fcon, condition = ((i, j, k, x, y)->begin
                                                    #= none:51 =#
                                                    i > 3
                                                end), dims = 1))))
                #= none:52 =#
            end
            #= none:53 =#
            #= none:53 =# @test sum(fful) == sum(fcon, condition = ((i, j, k, x, y)->begin
                                        #= none:53 =#
                                        i > 3
                                    end)) * 2
            #= none:54 =#
            #= none:54 =# @test all(Array(interior(sum(fful, dims = 1)) .== interior(sum(fcon, condition = ((i, j, k, x, y)->begin
                                                    #= none:54 =#
                                                    i > 3
                                                end), dims = 1)) .* 2))
            #= none:56 =#
            #= none:56 =# @test prod(fful) == prod(fcon, condition = ((i, j, k, x, y)->begin
                                        #= none:56 =#
                                        i > 3
                                    end)) * 8
            #= none:57 =#
            #= none:57 =# @test all(Array(interior(prod(fful, dims = 1)) .== interior(prod(fcon, condition = ((i, j, k, x, y)->begin
                                                    #= none:57 =#
                                                    i > 3
                                                end), dims = 1)) .* 8))
            #= none:59 =#
            #= none:59 =# @info "    Testing in-place conditional reductions"
            #= none:61 =#
            redimm = Field{Nothing, Center, Center}(ibg)
            #= none:62 =#
            for (reduc, reduc!) = zip((mean, maximum, minimum, sum, prod), (mean!, maximum!, minimum!, sum!, prod!))
                #= none:63 =#
                #= none:63 =# @test #= none:63 =# CUDA.@allowscalar((reduc!(redimm, fimm))[1, 1, 1] == (reduc(fcon, condition = ((i, j, k, x, y)->(#= none:63 =#
                                            i > 3)), dims = 1))[1, 1, 1])
                #= none:64 =#
            end
            #= none:65 =#
        end
    end