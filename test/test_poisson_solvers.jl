
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:2 =#
include("dependencies_for_poisson_solvers.jl")
#= none:8 =#
PB = (Periodic, Bounded)
#= none:9 =#
topos = (collect(Iterators.product(PB, PB, PB)))[:]
#= none:11 =#
two_dimensional_topologies = [(Flat, Bounded, Bounded), (Bounded, Flat, Bounded), (Bounded, Bounded, Flat), (Flat, Periodic, Bounded), (Periodic, Flat, Bounded), (Periodic, Bounded, Flat)]
#= none:18 =#
#= none:18 =# @testset "Poisson solvers 1" begin
        #= none:19 =#
        #= none:19 =# @info "Testing Poisson solvers..."
        #= none:21 =#
        for arch = archs
            #= none:22 =#
            #= none:22 =# @testset "Poisson solver instantiation [$(typeof(arch))]" begin
                    #= none:23 =#
                    #= none:23 =# @info "  Testing Poisson solver instantiation [$(typeof(arch))]..."
                    #= none:24 =#
                    for FT = float_types
                        #= none:26 =#
                        grids_3d = [RectilinearGrid(arch, FT, size = (2, 2, 2), extent = (1, 1, 1)), RectilinearGrid(arch, FT, size = (1, 2, 2), extent = (1, 1, 1)), RectilinearGrid(arch, FT, size = (2, 1, 2), extent = (1, 1, 1)), RectilinearGrid(arch, FT, size = (2, 2, 1), extent = (1, 1, 1))]
                        #= none:31 =#
                        grids_2d = [RectilinearGrid(arch, FT, size = (2, 2), extent = (1, 1), topology = topo) for topo = two_dimensional_topologies]
                        #= none:34 =#
                        grids = []
                        #= none:35 =#
                        push!(grids, grids_3d..., grids_2d...)
                        #= none:37 =#
                        for grid = grids
                            #= none:38 =#
                            #= none:38 =# @test poisson_solver_instantiates(grid, FFTW.ESTIMATE)
                            #= none:39 =#
                            #= none:39 =# @test poisson_solver_instantiates(grid, FFTW.MEASURE)
                            #= none:40 =#
                        end
                        #= none:41 =#
                    end
                end
            #= none:44 =#
            #= none:44 =# @testset "Divergence-free solution [$(typeof(arch))]" begin
                    #= none:45 =#
                    #= none:45 =# @info "  Testing divergence-free solution [$(typeof(arch))]..."
                    #= none:47 =#
                    for topo = topos
                        #= none:48 =#
                        for N = [7, 16]
                            #= none:50 =#
                            grids_3d = [RectilinearGrid(arch, topology = topo, size = (N, N, N), extent = (1, 1, 1)), RectilinearGrid(arch, topology = topo, size = (1, N, N), extent = (1, 1, 1)), RectilinearGrid(arch, topology = topo, size = (N, 1, N), extent = (1, 1, 1)), RectilinearGrid(arch, topology = topo, size = (N, N, 1), extent = (1, 1, 1))]
                            #= none:55 =#
                            grids_2d = [RectilinearGrid(arch, size = (N, N), extent = (1, 1), topology = topo) for topo = two_dimensional_topologies]
                            #= none:58 =#
                            grids = []
                            #= none:59 =#
                            push!(grids, grids_3d..., grids_2d...)
                            #= none:61 =#
                            for grid = grids
                                #= none:62 =#
                                N == 7 && #= none:62 =# @info("    Testing $(topology(grid)) topology on square grids [$(typeof(arch))]...")
                                #= none:63 =#
                                #= none:63 =# @test divergence_free_poisson_solution(grid)
                                #= none:64 =#
                            end
                            #= none:65 =#
                        end
                        #= none:66 =#
                    end
                    #= none:68 =#
                    Ns = [11, 16]
                    #= none:69 =#
                    for topo = topos
                        #= none:70 =#
                        #= none:70 =# @info "    Testing $(topo) topology on rectangular grids with even and prime sizes [$(typeof(arch))]..."
                        #= none:71 =#
                        for Nx = Ns, Ny = Ns, Nz = Ns
                            #= none:72 =#
                            grid = RectilinearGrid(arch, topology = topo, size = (Nx, Ny, Nz), extent = (1, 1, 1))
                            #= none:73 =#
                            #= none:73 =# @test divergence_free_poisson_solution(grid)
                            #= none:74 =#
                        end
                        #= none:75 =#
                    end
                    #= none:78 =#
                    Float32_grids = [RectilinearGrid(arch, Float32, topology = (Periodic, Bounded, Bounded), size = (16, 16, 16), extent = (1, 1, 1)), RectilinearGrid(arch, Float32, topology = (Bounded, Bounded, Periodic), size = (7, 11, 13), extent = (1, 1, 1))]
                    #= none:81 =#
                    for grid = Float32_grids
                        #= none:82 =#
                        #= none:82 =# @test divergence_free_poisson_solution(grid)
                        #= none:83 =#
                    end
                end
            #= none:86 =#
            #= none:86 =# @testset "Convergence to analytic solution [$(typeof(arch))]" begin
                    #= none:87 =#
                    #= none:87 =# @info "  Testing convergence to analytic solution [$(typeof(arch))]..."
                    #= none:88 =#
                    for topo = topos
                        #= none:89 =#
                        #= none:89 =# @test poisson_solver_convergence(arch, topo, 2 ^ 6, 2 ^ 7)
                        #= none:90 =#
                        #= none:90 =# @test poisson_solver_convergence(arch, topo, 67, 131, mode = 2)
                        #= none:91 =#
                    end
                end
            #= none:93 =#
        end
    end