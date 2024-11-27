
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels
#= none:4 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: calculate_substeps, calculate_adaptive_settings, constant_averaging_kernel, materialize_free_surface, SplitExplicitFreeSurface, SplitExplicitState, SplitExplicitAuxiliaryFields, SplitExplicitSettings, iterate_split_explicit!
#= none:14 =#
#= none:14 =# @testset "Split-Explicit Dynamics" begin
        #= none:16 =#
        for FT = float_types
            #= none:17 =#
            for arch = archs
                #= none:18 =#
                topology = (Periodic, Periodic, Bounded)
                #= none:20 =#
                (Nx, Ny, Nz) = (128, 64, 1)
                #= none:21 =#
                Lx = (Ly = 2π)
                #= none:22 =#
                Lz = 1 / Oceananigans.BuoyancyModels.g_Earth
                #= none:24 =#
                grid = RectilinearGrid(arch, FT; topology, size = (Nx, Ny, Nz), x = (0, Lx), y = (0, Ly), z = (-Lz, 0), halo = (1, 1, 1))
                #= none:29 =#
                sefs = SplitExplicitFreeSurface(substeps = 200, averaging_kernel = constant_averaging_kernel)
                #= none:30 =#
                sefs = materialize_free_surface(sefs, nothing, grid)
                #= none:32 =#
                sefs.η .= 0
                #= none:34 =#
                #= none:34 =# @testset " One timestep test " begin
                        #= none:35 =#
                        state = sefs.state
                        #= none:36 =#
                        (U, V, η̅, U̅, V̅) = (state.U, state.V, state.η̅, state.U̅, state.V̅)
                        #= none:38 =#
                        η = sefs.η
                        #= none:39 =#
                        Δτ = 1.0
                        #= none:41 =#
                        η₀(x, y, z) = begin
                                #= none:41 =#
                                sin(x)
                            end
                        #= none:42 =#
                        set!(η, η₀)
                        #= none:44 =#
                        Nsubsteps = calculate_substeps(sefs.settings.substepping, 1)
                        #= none:45 =#
                        (fractional_Δt, weights) = calculate_adaptive_settings(sefs.settings.substepping, Nsubsteps)
                        #= none:47 =#
                        iterate_split_explicit!(sefs, grid, Δτ, weights, Val(1))
                        #= none:49 =#
                        U_computed = (Array(U.data.parent))[2:Nx + 1, 2:Ny + 1]
                        #= none:50 =#
                        U_exact = (reshape(-(cos.(grid.xᶠᵃᵃ)), (length(grid.xᶜᵃᵃ), 1)) .+ reshape(0 * grid.yᵃᶜᵃ, (1, length(grid.yᵃᶜᵃ))))[2:Nx + 1, 2:Ny + 1]
                        #= none:52 =#
                        #= none:52 =# @test maximum(abs.(U_exact - U_computed)) < 0.001
                    end
                #= none:55 =#
                #= none:55 =# @testset "Multi-timestep test " begin
                        #= none:56 =#
                        state = sefs.state
                        #= none:57 =#
                        auxiliary = sefs.auxiliary
                        #= none:58 =#
                        (U, V, η̅, U̅, V̅) = (state.U, state.V, state.η̅, state.U̅, state.V̅)
                        #= none:59 =#
                        (Gᵁ, Gⱽ) = (auxiliary.Gᵁ, auxiliary.Gⱽ)
                        #= none:60 =#
                        η = sefs.η
                        #= none:62 =#
                        T = 2π
                        #= none:63 =#
                        Δτ = ((2π) / maximum([Nx, Ny])) * 0.05
                        #= none:64 =#
                        Nt = floor(Int, T / Δτ)
                        #= none:65 =#
                        Δτ_end = T - Nt * Δτ
                        #= none:67 =#
                        sefs = SplitExplicitFreeSurface(substeps = Nt, averaging_kernel = constant_averaging_kernel)
                        #= none:68 =#
                        sefs = materialize_free_surface(sefs, nothing, grid)
                        #= none:71 =#
                        η₀(x, y, z) = begin
                                #= none:71 =#
                                sin(x)
                            end
                        #= none:72 =#
                        set!(η, η₀)
                        #= none:73 =#
                        U₀(x, y, z) = begin
                                #= none:73 =#
                                0
                            end
                        #= none:74 =#
                        set!(U, U₀)
                        #= none:75 =#
                        V₀(x, y, z) = begin
                                #= none:75 =#
                                0
                            end
                        #= none:76 =#
                        set!(V, V₀)
                        #= none:78 =#
                        η̅ .= 0
                        #= none:79 =#
                        U̅ .= 0
                        #= none:80 =#
                        V̅ .= 0
                        #= none:81 =#
                        Gᵁ .= 0
                        #= none:82 =#
                        Gⱽ .= 0
                        #= none:84 =#
                        weights = sefs.settings.substepping.averaging_weights
                        #= none:86 =#
                        for _ = 1:Nt
                            #= none:87 =#
                            iterate_split_explicit!(sefs, grid, Δτ, weights, Val(1))
                            #= none:88 =#
                        end
                        #= none:89 =#
                        iterate_split_explicit!(sefs, grid, Δτ_end, weights, Val(1))
                        #= none:91 =#
                        U_computed = Array(deepcopy(interior(U)))
                        #= none:92 =#
                        η_computed = Array(deepcopy(interior(η)))
                        #= none:93 =#
                        set!(η, η₀)
                        #= none:94 =#
                        set!(U, U₀)
                        #= none:95 =#
                        U_exact = Array(deepcopy(interior(U)))
                        #= none:96 =#
                        η_exact = Array(deepcopy(interior(η)))
                        #= none:98 =#
                        #= none:98 =# @test maximum(abs.(U_computed - U_exact)) < 0.001
                        #= none:99 =#
                        #= none:99 =# @test maximum(abs.(η_computed - η_exact)) < max(100 * eps(FT), 1.0e-6)
                    end
                #= none:102 =#
                sefs = SplitExplicitFreeSurface(substeps = 200, averaging_kernel = constant_averaging_kernel)
                #= none:103 =#
                sefs = materialize_free_surface(sefs, nothing, grid)
                #= none:105 =#
                sefs.η .= 0
                #= none:107 =#
                #= none:107 =# @testset "Averaging / Do Nothing test " begin
                        #= none:108 =#
                        state = sefs.state
                        #= none:109 =#
                        auxiliary = sefs.auxiliary
                        #= none:110 =#
                        (U, V, η̅, U̅, V̅) = (state.U, state.V, state.η̅, state.U̅, state.V̅)
                        #= none:111 =#
                        (Gᵁ, Gⱽ) = (auxiliary.Gᵁ, auxiliary.Gⱽ)
                        #= none:113 =#
                        g = sefs.gravitational_acceleration
                        #= none:114 =#
                        η = sefs.η
                        #= none:116 =#
                        Δτ = ((2π) / maximum([Nx, Ny])) * 0.01
                        #= none:119 =#
                        η_avg = 1
                        #= none:120 =#
                        U_avg = 2
                        #= none:121 =#
                        V_avg = 3
                        #= none:122 =#
                        fill!(η, η_avg)
                        #= none:123 =#
                        fill!(U, U_avg)
                        #= none:124 =#
                        fill!(V, V_avg)
                        #= none:126 =#
                        fill!(η̅, 0)
                        #= none:127 =#
                        fill!(U̅, 0)
                        #= none:128 =#
                        fill!(V̅, 0)
                        #= none:129 =#
                        fill!(Gᵁ, 0)
                        #= none:130 =#
                        fill!(Gⱽ, 0)
                        #= none:132 =#
                        settings = sefs.settings
                        #= none:134 =#
                        Nsubsteps = calculate_substeps(settings.substepping, 1)
                        #= none:135 =#
                        (fractional_Δt, weights) = calculate_adaptive_settings(settings.substepping, Nsubsteps)
                        #= none:137 =#
                        for step = 1:Nsubsteps
                            #= none:138 =#
                            iterate_split_explicit!(sefs, grid, Δτ, weights, Val(1))
                            #= none:139 =#
                        end
                        #= none:141 =#
                        U_computed = Array(deepcopy(interior(U)))
                        #= none:142 =#
                        V_computed = Array(deepcopy(interior(V)))
                        #= none:143 =#
                        η_computed = Array(deepcopy(interior(η)))
                        #= none:145 =#
                        U̅_computed = Array(deepcopy(interior(U̅)))
                        #= none:146 =#
                        V̅_computed = Array(deepcopy(interior(V̅)))
                        #= none:147 =#
                        η̅_computed = Array(deepcopy(interior(η̅)))
                        #= none:149 =#
                        tolerance = 100 * eps(FT)
                        #= none:151 =#
                        #= none:151 =# @test maximum(abs.(U_computed .- U_avg)) < tolerance
                        #= none:152 =#
                        #= none:152 =# @test maximum(abs.(η_computed .- η_avg)) < tolerance
                        #= none:153 =#
                        #= none:153 =# @test maximum(abs.(V_computed .- V_avg)) < tolerance
                        #= none:155 =#
                        #= none:155 =# @test maximum(abs.(U̅_computed .- U_avg)) < tolerance
                        #= none:156 =#
                        #= none:156 =# @test maximum(abs.(η̅_computed .- η_avg)) < tolerance
                        #= none:157 =#
                        #= none:157 =# @test maximum(abs.(V̅_computed .- V_avg)) < tolerance
                    end
                #= none:160 =#
                #= none:160 =# @testset "Complex Multi-Timestep " begin
                        #= none:164 =#
                        kx = 2
                        #= none:165 =#
                        ky = 3
                        #= none:166 =#
                        ω = sqrt(kx ^ 2 + ky ^ 2)
                        #= none:167 =#
                        T = (((2π) / ω) / 3) * 2
                        #= none:168 =#
                        Δτ = ((2π) / maximum([Nx, Ny])) * 0.01
                        #= none:169 =#
                        Nt = floor(Int, T / Δτ)
                        #= none:170 =#
                        Δτ_end = T - Nt * Δτ
                        #= none:172 =#
                        sefs = SplitExplicitFreeSurface(substeps = 200)
                        #= none:173 =#
                        sefs = materialize_free_surface(sefs, nothing, grid)
                        #= none:175 =#
                        state = sefs.state
                        #= none:176 =#
                        auxiliary = sefs.auxiliary
                        #= none:177 =#
                        (U, V, η̅, U̅, V̅) = (state.U, state.V, state.η̅, state.U̅, state.V̅)
                        #= none:178 =#
                        (Gᵁ, Gⱽ) = (auxiliary.Gᵁ, auxiliary.Gⱽ)
                        #= none:179 =#
                        η = sefs.η
                        #= none:180 =#
                        g = sefs.gravitational_acceleration
                        #= none:183 =#
                        gu_c = 1
                        #= none:184 =#
                        gv_c = 2
                        #= none:185 =#
                        η₀(x, y, z) = begin
                                #= none:185 =#
                                sin(kx * x) * sin(ky * y) + 1
                            end
                        #= none:186 =#
                        set!(η, η₀)
                        #= none:188 =#
                        η_mean_before = mean(Array(interior(η)))
                        #= none:190 =#
                        U .= 0
                        #= none:191 =#
                        V .= 0
                        #= none:192 =#
                        η̅ .= 0
                        #= none:193 =#
                        U̅ .= 0
                        #= none:194 =#
                        V̅ .= 0
                        #= none:195 =#
                        Gᵁ .= gu_c
                        #= none:196 =#
                        Gⱽ .= gv_c
                        #= none:198 =#
                        settings = SplitExplicitSettings(grid; substeps = Nt + 1, averaging_kernel = constant_averaging_kernel)
                        #= none:199 =#
                        sefs = sefs(settings)
                        #= none:201 =#
                        weights = settings.substepping.averaging_weights
                        #= none:202 =#
                        for i = 1:Nt
                            #= none:203 =#
                            iterate_split_explicit!(sefs, grid, Δτ, weights, Val(1))
                            #= none:204 =#
                        end
                        #= none:205 =#
                        iterate_split_explicit!(sefs, grid, Δτ_end, weights, Val(1))
                        #= none:207 =#
                        η_mean_after = mean(Array(interior(η)))
                        #= none:209 =#
                        tolerance = 10 * eps(FT)
                        #= none:210 =#
                        #= none:210 =# @test abs(η_mean_after - η_mean_before) < tolerance
                        #= none:212 =#
                        η_computed = Array(deepcopy(interior(η, :, 1, 1)))
                        #= none:213 =#
                        U_computed = Array(deepcopy(interior(U, :, 1, 1)))
                        #= none:214 =#
                        V_computed = Array(deepcopy(interior(V, :, 1, 1)))
                        #= none:216 =#
                        η̅_computed = Array(deepcopy(interior(η̅, :, 1, 1)))
                        #= none:217 =#
                        U̅_computed = Array(deepcopy(interior(U̅, :, 1, 1)))
                        #= none:218 =#
                        V̅_computed = Array(deepcopy(interior(V̅, :, 1, 1)))
                        #= none:220 =#
                        set!(η, η₀)
                        #= none:223 =#
                        η_exact = cos(ω * T) * (Array(interior(η, :, 1, 1)) .- 1) .+ 1
                        #= none:225 =#
                        U₀(x, y, z) = begin
                                #= none:225 =#
                                kx * cos(kx * x) * sin(ky * y)
                            end
                        #= none:226 =#
                        set!(U, U₀)
                        #= none:227 =#
                        U_exact = -((sin(ω * T) * 1) / ω) .* Array(interior(U, :, 1, 1)) .+ gu_c * T
                        #= none:229 =#
                        V₀(x, y, z) = begin
                                #= none:229 =#
                                ky * sin(kx * x) * cos(ky * y)
                            end
                        #= none:230 =#
                        set!(V, V₀)
                        #= none:231 =#
                        V_exact = -((sin(ω * T) * 1) / ω) .* Array(interior(V, :, 1, 1)) .+ gv_c * T
                        #= none:233 =#
                        η̅_exact = ((sin(ω * T) / ω - sin(ω * 0) / ω) / T) * (Array(interior(η, :, 1, 1)) .- 1) .+ 1
                        #= none:234 =#
                        U̅_exact = (((cos(ω * T) * 1) / ω ^ 2 - (cos(ω * 0) * 1) / ω ^ 2) / T) * Array(interior(U, :, 1, 1)) .+ (gu_c * T) / 2
                        #= none:235 =#
                        V̅_exact = (((cos(ω * T) * 1) / ω ^ 2 - (cos(ω * 0) * 1) / ω ^ 2) / T) * Array(interior(V, :, 1, 1)) .+ (gv_c * T) / 2
                        #= none:237 =#
                        tolerance = 0.01
                        #= none:239 =#
                        #= none:239 =# @test maximum(abs.(U_computed - U_exact)) / maximum(abs.(U_exact)) < tolerance
                        #= none:240 =#
                        #= none:240 =# @test maximum(abs.(V_computed - V_exact)) / maximum(abs.(V_exact)) < tolerance
                        #= none:241 =#
                        #= none:241 =# @test maximum(abs.(η_computed - η_exact)) / maximum(abs.(η_exact)) < tolerance
                        #= none:243 =#
                        #= none:243 =# @test maximum(abs.(U̅_computed - U̅_exact)) < tolerance
                        #= none:244 =#
                        #= none:244 =# @test maximum(abs.(V̅_computed - V̅_exact)) < tolerance
                        #= none:245 =#
                        #= none:245 =# @test maximum(abs.(η̅_computed - η̅_exact)) < tolerance
                    end
                #= none:247 =#
            end
            #= none:248 =#
        end
    end