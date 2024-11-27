
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Fields: regrid_in_x!, regrid_in_y!, regrid_in_z!
#= none:5 =#
#= none:5 =# @testset "Field regridding" begin
        #= none:6 =#
        #= none:6 =# @info "  Testing field regridding..."
        #= none:8 =#
        L = 1.1
        #= none:9 =#
        ℓ = 0.5
        #= none:11 =#
        regular_ξ = (0, L)
        #= none:12 =#
        fine_stretched_ξ = [0, ℓ, L]
        #= none:13 =#
        very_fine_stretched_ξ = [0, 0.2, 0.6, L]
        #= none:14 =#
        super_fine_stretched_ξ = [0, 0.1, 0.3, 0.65, L]
        #= none:16 =#
        topologies_1d = (x = (Bounded, Flat, Flat), y = (Flat, Bounded, Flat), z = (Flat, Flat, Bounded))
        #= none:20 =#
        sizes = (x = (2, 4, 6), y = (4, 2, 6), z = (4, 6, 2))
        #= none:24 =#
        topologies_3d = (x = (Bounded, Periodic, Periodic), y = (Periodic, Bounded, Periodic), z = (Periodic, Periodic, Bounded))
        #= none:28 =#
        regrid_xyz! = (x = regrid_in_x!, y = regrid_in_y!, z = regrid_in_z!)
        #= none:32 =#
        for arch = archs
            #= none:33 =#
            for dim = (:x, :y, :z)
                #= none:34 =#
                #= none:34 =# @testset "Regridding in $(dim)" begin
                        #= none:35 =#
                        regrid! = regrid_xyz![dim]
                        #= none:36 =#
                        topology = topologies_1d[dim]
                        #= none:39 =#
                        coarse_1d_regular_grid = RectilinearGrid(arch, size = 1; topology, Dict(dim => regular_ξ)...)
                        #= none:40 =#
                        fine_1d_regular_grid = RectilinearGrid(arch, size = 2; topology, Dict(dim => regular_ξ)...)
                        #= none:41 =#
                        fine_1d_stretched_grid = RectilinearGrid(arch, size = 2; topology, Dict(dim => fine_stretched_ξ)...)
                        #= none:42 =#
                        very_fine_1d_stretched_grid = RectilinearGrid(arch, size = 3; topology, Dict(dim => very_fine_stretched_ξ)...)
                        #= none:43 =#
                        super_fine_1d_stretched_grid = RectilinearGrid(arch, size = 4; topology, Dict(dim => super_fine_stretched_ξ)...)
                        #= none:44 =#
                        super_fine_1d_regular_grid = RectilinearGrid(arch, size = 5; topology, Dict(dim => regular_ξ)...)
                        #= none:47 =#
                        topology = topologies_3d[dim]
                        #= none:48 =#
                        sz = sizes[dim]
                        #= none:50 =#
                        regular_kw = Dict{Any, Any}((d => (0, 1) for d = (:x, :y, :z) if d != dim))
                        #= none:51 =#
                        regular_kw[dim] = regular_ξ
                        #= none:52 =#
                        fine_regular_grid = RectilinearGrid(arch, size = sz; topology, regular_kw...)
                        #= none:54 =#
                        fine_stretched_kw = Dict{Any, Any}((d => (0, 1) for d = (:x, :y, :z) if d != dim))
                        #= none:55 =#
                        fine_stretched_kw[dim] = fine_stretched_ξ
                        #= none:56 =#
                        fine_stretched_grid = RectilinearGrid(arch, size = sz; topology, fine_stretched_kw...)
                        #= none:58 =#
                        fine_stretched_c = CenterField(fine_stretched_grid)
                        #= none:60 =#
                        coarse_1d_regular_c = CenterField(coarse_1d_regular_grid)
                        #= none:61 =#
                        fine_1d_regular_c = CenterField(fine_1d_regular_grid)
                        #= none:62 =#
                        fine_1d_stretched_c = CenterField(fine_1d_stretched_grid)
                        #= none:63 =#
                        very_fine_1d_stretched_c = CenterField(very_fine_1d_stretched_grid)
                        #= none:64 =#
                        super_fine_1d_stretched_c = CenterField(super_fine_1d_stretched_grid)
                        #= none:65 =#
                        super_fine_1d_regular_c = CenterField(super_fine_1d_regular_grid)
                        #= none:66 =#
                        super_fine_from_reduction_regular_c = CenterField(super_fine_1d_regular_grid)
                        #= none:70 =#
                        c₁ = 1
                        #= none:71 =#
                        c₂ = 3
                        #= none:73 =#
                        #= none:73 =# CUDA.@allowscalar begin
                                #= none:74 =#
                                (interior(fine_1d_stretched_c))[1] = c₁
                                #= none:75 =#
                                (interior(fine_1d_stretched_c))[2] = c₂
                            end
                        #= none:79 =#
                        regrid!(coarse_1d_regular_c, fine_1d_stretched_c)
                        #= none:81 =#
                        #= none:81 =# CUDA.@allowscalar begin
                                #= none:82 =#
                                #= none:82 =# @test (interior(coarse_1d_regular_c))[1] ≈ (ℓ / L) * c₁ + (1 - ℓ / L) * c₂
                            end
                        #= none:85 =#
                        regrid!(fine_1d_regular_c, fine_1d_stretched_c)
                        #= none:87 =#
                        #= none:87 =# CUDA.@allowscalar begin
                                #= none:88 =#
                                #= none:88 =# @test (interior(fine_1d_regular_c))[1] ≈ (ℓ / (L / 2)) * c₁ + (1 - ℓ / (L / 2)) * c₂
                                #= none:89 =#
                                #= none:89 =# @test (interior(fine_1d_regular_c))[2] ≈ c₂
                            end
                        #= none:93 =#
                        regrid!(very_fine_1d_stretched_c, fine_1d_stretched_c)
                        #= none:95 =#
                        #= none:95 =# CUDA.@allowscalar begin
                                #= none:96 =#
                                #= none:96 =# @test (interior(very_fine_1d_stretched_c))[1] ≈ c₁
                                #= none:97 =#
                                #= none:97 =# @test (interior(very_fine_1d_stretched_c))[2] ≈ ((ℓ - 0.2) / 0.4) * c₁ + ((0.6 - ℓ) / 0.4) * c₂
                                #= none:98 =#
                                #= none:98 =# @test (interior(very_fine_1d_stretched_c))[3] ≈ c₂
                            end
                        #= none:101 =#
                        regrid!(super_fine_1d_stretched_c, fine_1d_stretched_c)
                        #= none:103 =#
                        #= none:103 =# CUDA.@allowscalar begin
                                #= none:104 =#
                                #= none:104 =# @test (interior(super_fine_1d_stretched_c))[1] ≈ c₁
                                #= none:105 =#
                                #= none:105 =# @test (interior(super_fine_1d_stretched_c))[2] ≈ c₁
                                #= none:106 =#
                                #= none:106 =# @test (interior(super_fine_1d_stretched_c))[3] ≈ ((ℓ - 0.3) / 0.35) * c₁ + ((0.65 - ℓ) / 0.35) * c₂
                                #= none:107 =#
                                #= none:107 =# @test (interior(super_fine_1d_stretched_c))[4] ≈ c₂
                            end
                        #= none:110 =#
                        regrid!(super_fine_1d_regular_c, fine_1d_stretched_c)
                        #= none:112 =#
                        #= none:112 =# CUDA.@allowscalar begin
                                #= none:113 =#
                                #= none:113 =# @test (interior(super_fine_1d_regular_c))[1] ≈ c₁
                                #= none:114 =#
                                #= none:114 =# @test (interior(super_fine_1d_regular_c))[2] ≈ c₁
                                #= none:115 =#
                                #= none:115 =# @test (interior(super_fine_1d_regular_c))[3] ≈ (3 - ℓ / (L / 5)) * c₂ + (-2 + ℓ / (L / 5)) * c₁
                                #= none:116 =#
                                #= none:116 =# @test (interior(super_fine_1d_regular_c))[4] ≈ c₂
                                #= none:117 =#
                                #= none:117 =# @test (interior(super_fine_1d_regular_c))[5] ≈ c₂
                            end
                    end
                #= none:150 =#
            end
            #= none:151 =#
        end
    end