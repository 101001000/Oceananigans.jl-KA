
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:2 =#
include("dependencies_for_poisson_solvers.jl")
#= none:8 =#
#= none:8 =# @testset "Poisson solvers 2" begin
        #= none:9 =#
        #= none:9 =# @info "Testing Poisson solvers (vertically stretched grid)..."
        #= none:12 =#
        vs_topos = [(Periodic, Periodic, Bounded), (Periodic, Bounded, Bounded), (Bounded, Periodic, Bounded), (Bounded, Bounded, Bounded), (Periodic, Bounded, Periodic), (Bounded, Periodic, Periodic), (Bounded, Bounded, Periodic), (Flat, Bounded, Bounded), (Flat, Periodic, Bounded), (Bounded, Flat, Bounded), (Periodic, Flat, Bounded)]
        #= none:26 =#
        for arch = archs, topo = vs_topos
            #= none:27 =#
            #= none:27 =# @testset "Irregular-grid Poisson solver [FACR, $(typeof(arch)), $(topo)]" begin
                    #= none:29 =#
                    faces_even = [1, 2, 4, 7, 11, 16, 22, 29, 37]
                    #= none:30 =#
                    faces_odd = [1, 2, 4, 7, 11, 16, 22, 29, 37, 51]
                    #= none:31 =#
                    for stretched_axis = (1, 2, 3)
                        #= none:32 =#
                        if topo[stretched_axis] == Bounded
                            #= none:33 =#
                            #= none:33 =# @info "  Testing stretched Poisson solver [FACR, $(typeof(arch)), $(topo), stretched axis = $(stretched_axis)]..."
                            #= none:34 =#
                            #= none:34 =# @test stretched_poisson_solver_correct_answer(Float64, arch, topo, 4, 5, 1:4; stretched_axis)
                            #= none:35 =#
                            #= none:35 =# @test stretched_poisson_solver_correct_answer(Float64, arch, topo, 8, 8, 1:8; stretched_axis)
                            #= none:36 =#
                            #= none:36 =# @test stretched_poisson_solver_correct_answer(Float64, arch, topo, 7, 7, 1:7; stretched_axis)
                            #= none:37 =#
                            #= none:37 =# @test stretched_poisson_solver_correct_answer(Float32, arch, topo, 8, 8, 1:8; stretched_axis)
                            #= none:39 =#
                            for faces = [faces_even, faces_odd]
                                #= none:40 =#
                                #= none:40 =# @test stretched_poisson_solver_correct_answer(Float64, arch, topo, 8, 8, faces; stretched_axis)
                                #= none:41 =#
                                #= none:41 =# @test stretched_poisson_solver_correct_answer(Float64, arch, topo, 16, 8, faces; stretched_axis)
                                #= none:42 =#
                                #= none:42 =# @test stretched_poisson_solver_correct_answer(Float64, arch, topo, 8, 16, faces; stretched_axis)
                                #= none:43 =#
                                #= none:43 =# @test stretched_poisson_solver_correct_answer(Float64, arch, topo, 8, 11, faces; stretched_axis)
                                #= none:44 =#
                                #= none:44 =# @test stretched_poisson_solver_correct_answer(Float64, arch, topo, 5, 8, faces; stretched_axis)
                                #= none:45 =#
                                #= none:45 =# @test stretched_poisson_solver_correct_answer(Float64, arch, topo, 7, 13, faces; stretched_axis)
                                #= none:46 =#
                            end
                        end
                        #= none:48 =#
                    end
                end
            #= none:50 =#
        end
    end