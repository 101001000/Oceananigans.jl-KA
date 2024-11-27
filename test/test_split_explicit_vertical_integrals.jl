
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels
#= none:4 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: SplitExplicitFreeSurface
#= none:5 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: SplitExplicitState, SplitExplicitAuxiliaryFields, SplitExplicitSettings
#= none:8 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: compute_barotropic_mode!, barotropic_split_explicit_corrector!, initialize_free_surface_state!
#= none:12 =#
#= none:12 =# @testset "Barotropic Kernels" begin
        #= none:14 =#
        for arch = archs
            #= none:15 =#
            FT = Float64
            #= none:16 =#
            topology = (Periodic, Periodic, Bounded)
            #= none:17 =#
            (Nx, Ny, Nz) = (128, 64, 32)
            #= none:18 =#
            Lx = (Ly = (Lz = 2π))
            #= none:20 =#
            grid = RectilinearGrid(arch, topology = topology, size = (Nx, Ny, Nz), x = (0, Lx), y = (0, Ly), z = (-Lz, 0))
            #= none:22 =#
            tmp = SplitExplicitFreeSurface(substeps = 200)
            #= none:24 =#
            sefs = SplitExplicitState(grid, tmp.settings.timestepper)
            #= none:25 =#
            sefs = SplitExplicitAuxiliaryFields(grid)
            #= none:26 =#
            sefs = SplitExplicitFreeSurface(substeps = 200)
            #= none:27 =#
            sefs = materialize_free_surface(sefs, nothing, grid)
            #= none:29 =#
            state = sefs.state
            #= none:30 =#
            auxiliary = sefs.auxiliary
            #= none:31 =#
            (U, V, η̅, U̅, V̅) = (state.U, state.V, state.η̅, state.U̅, state.V̅)
            #= none:32 =#
            (Gᵁ, Gⱽ) = (auxiliary.Gᵁ, auxiliary.Gⱽ)
            #= none:34 =#
            u = Field{Face, Center, Center}(grid)
            #= none:35 =#
            v = Field{Center, Face, Center}(grid)
            #= none:37 =#
            #= none:37 =# @testset "Average to zero" begin
                    #= none:39 =#
                    η̅ .= (U̅ .= (V̅ .= 1.0))
                    #= none:42 =#
                    initialize_free_surface_state!(sefs.state, sefs.η, sefs.settings.timestepper)
                    #= none:45 =#
                    fill_halo_regions!(η̅)
                    #= none:46 =#
                    fill_halo_regions!(U̅)
                    #= none:47 =#
                    fill_halo_regions!(V̅)
                    #= none:50 =#
                    #= none:50 =# @test all(Array(η̅.data.parent) .== 0.0)
                    #= none:51 =#
                    #= none:51 =# @test all(Array(U̅.data.parent .== 0.0))
                    #= none:52 =#
                    #= none:52 =# @test all(Array(V̅.data.parent .== 0.0))
                end
            #= none:55 =#
            #= none:55 =# @testset "Inexact integration" begin
                    #= none:57 =#
                    Δz = zeros(Nz)
                    #= none:58 =#
                    Δz .= grid.Δzᵃᵃᶠ
                    #= none:60 =#
                    set_u_check(x, y, z) = begin
                            #= none:60 =#
                            cos(((π / 2) * z) / Lz)
                        end
                    #= none:61 =#
                    set_U_check(x, y, z) = begin
                            #= none:61 =#
                            sin(0) - (-2Lz) / π
                        end
                    #= none:62 =#
                    set!(u, set_u_check)
                    #= none:63 =#
                    exact_U = similar(U)
                    #= none:64 =#
                    set!(exact_U, set_U_check)
                    #= none:65 =#
                    compute_barotropic_mode!(U, V, grid, u, v)
                    #= none:66 =#
                    tolerance = 0.001
                    #= none:67 =#
                    #= none:67 =# @test all(Array(interior(U) .- interior(exact_U)) .< tolerance)
                    #= none:69 =#
                    set_v_check(x, y, z) = begin
                            #= none:69 =#
                            sin(x * y) * cos(((π / 2) * z) / Lz)
                        end
                    #= none:70 =#
                    set_V_check(x, y, z) = begin
                            #= none:70 =#
                            sin(x * y) * (sin(0) - (-2Lz) / π)
                        end
                    #= none:71 =#
                    set!(v, set_v_check)
                    #= none:72 =#
                    exact_V = similar(V)
                    #= none:73 =#
                    set!(exact_V, set_V_check)
                    #= none:74 =#
                    compute_barotropic_mode!(U, V, grid, u, v)
                    #= none:75 =#
                    #= none:75 =# @test all(Array(interior(V) .- interior(exact_V)) .< tolerance)
                end
            #= none:78 =#
            #= none:78 =# @testset "Vertical Integral " begin
                    #= none:79 =#
                    Δz = zeros(Nz)
                    #= none:80 =#
                    Δz .= grid.Δzᵃᵃᶜ
                    #= none:82 =#
                    u .= 0.0
                    #= none:83 =#
                    U .= 1.0
                    #= none:84 =#
                    compute_barotropic_mode!(U, V, grid, u, v)
                    #= none:85 =#
                    #= none:85 =# @test all(Array(U.data.parent) .== 0.0)
                    #= none:87 =#
                    u .= 1.0
                    #= none:88 =#
                    U .= 1.0
                    #= none:89 =#
                    compute_barotropic_mode!(U, V, grid, u, v)
                    #= none:90 =#
                    #= none:90 =# @test all(Array(interior(U)) .≈ Lz)
                    #= none:92 =#
                    set_u_check(x, y, z) = begin
                            #= none:92 =#
                            sin(x)
                        end
                    #= none:93 =#
                    set_U_check(x, y, z) = begin
                            #= none:93 =#
                            sin(x) * Lz
                        end
                    #= none:94 =#
                    set!(u, set_u_check)
                    #= none:95 =#
                    exact_U = similar(U)
                    #= none:96 =#
                    set!(exact_U, set_U_check)
                    #= none:97 =#
                    compute_barotropic_mode!(U, V, grid, u, v)
                    #= none:98 =#
                    #= none:98 =# @test all(Array(interior(U)) .≈ Array(interior(exact_U)))
                    #= none:100 =#
                    set_v_check(x, y, z) = begin
                            #= none:100 =#
                            sin(x) * z * cos(y)
                        end
                    #= none:101 =#
                    set_V_check(x, y, z) = begin
                            #= none:101 =#
                            ((-(sin(x)) * Lz ^ 2) / 2.0) * cos(y)
                        end
                    #= none:102 =#
                    set!(v, set_v_check)
                    #= none:103 =#
                    exact_V = similar(V)
                    #= none:104 =#
                    set!(exact_V, set_V_check)
                    #= none:105 =#
                    compute_barotropic_mode!(U, V, grid, u, v)
                    #= none:106 =#
                    #= none:106 =# @test all(Array(interior(V)) .≈ Array(interior(exact_V)))
                end
            #= none:109 =#
            #= none:109 =# @testset "Barotropic Correction" begin
                    #= none:111 =#
                    FT = Float64
                    #= none:112 =#
                    topology = (Periodic, Periodic, Bounded)
                    #= none:113 =#
                    (Nx, Ny, Nz) = (128, 64, 32)
                    #= none:114 =#
                    Lx = (Ly = (Lz = 2π))
                    #= none:116 =#
                    grid = RectilinearGrid(arch, topology = topology, size = (Nx, Ny, Nz), x = (0, Lx), y = (0, Ly), z = (-Lz, 0))
                    #= none:118 =#
                    sefs = SplitExplicitFreeSurface(grid, cfl = 0.7)
                    #= none:119 =#
                    sefs = materialize_free_surface(sefs, nothing, grid)
                    #= none:121 =#
                    state = sefs.state
                    #= none:122 =#
                    auxiliary = sefs.auxiliary
                    #= none:123 =#
                    (U, V, η̅, U̅, V̅) = (state.U, state.V, state.η̅, state.U̅, state.V̅)
                    #= none:124 =#
                    (Gᵁ, Gⱽ) = (auxiliary.Gᵁ, auxiliary.Gⱽ)
                    #= none:126 =#
                    u = Field{Face, Center, Center}(grid)
                    #= none:127 =#
                    v = Field{Center, Face, Center}(grid)
                    #= none:128 =#
                    u_corrected = similar(u)
                    #= none:129 =#
                    v_corrected = similar(v)
                    #= none:131 =#
                    set_u(x, y, z) = begin
                            #= none:131 =#
                            z + Lz / 2 + sin(x)
                        end
                    #= none:132 =#
                    set_U̅(x, y, z) = begin
                            #= none:132 =#
                            cos(x) * Lz
                        end
                    #= none:133 =#
                    set_u_corrected(x, y, z) = begin
                            #= none:133 =#
                            z + Lz / 2 + cos(x)
                        end
                    #= none:134 =#
                    set!(u, set_u)
                    #= none:135 =#
                    set!(U̅, set_U̅)
                    #= none:136 =#
                    set!(u_corrected, set_u_corrected)
                    #= none:138 =#
                    set_v(x, y, z) = begin
                            #= none:138 =#
                            (z + Lz / 2) * sin(y) + sin(x)
                        end
                    #= none:139 =#
                    set_V̅(x, y, z) = begin
                            #= none:139 =#
                            (cos(x) + x) * Lz
                        end
                    #= none:140 =#
                    set_v_corrected(x, y, z) = begin
                            #= none:140 =#
                            (z + Lz / 2) * sin(y) + cos(x) + x
                        end
                    #= none:141 =#
                    set!(v, set_v)
                    #= none:142 =#
                    set!(V̅, set_V̅)
                    #= none:143 =#
                    set!(v_corrected, set_v_corrected)
                    #= none:145 =#
                    Δz = zeros(Nz)
                    #= none:146 =#
                    Δz .= grid.Δzᵃᵃᶜ
                    #= none:148 =#
                    barotropic_split_explicit_corrector!(u, v, sefs, grid)
                    #= none:149 =#
                    #= none:149 =# @test all(Array(interior(u) .- interior(u_corrected)) .< 1.0e-14)
                    #= none:150 =#
                    #= none:150 =# @test all(Array(interior(v) .- interior(v_corrected)) .< 1.0e-14)
                end
            #= none:152 =#
        end
    end