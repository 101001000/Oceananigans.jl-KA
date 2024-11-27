
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Operators: Δxᶠᵃᵃ, Δxᶜᵃᵃ, Δxᶠᶠᵃ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶜᶜᵃ
#= none:4 =#
using Oceananigans.Operators: Δyᵃᶠᵃ, Δyᵃᶜᵃ, Δyᶠᶠᵃ, Δyᶠᶜᵃ, Δyᶜᶠᵃ, Δyᶜᶜᵃ
#= none:6 =#
using Oceananigans.Operators: Δzᵃᵃᶜ, Δzᵃᵃᶠ
#= none:8 =#
function test_three_dimensional_differences(T = Float64)
    #= none:8 =#
    #= none:9 =#
    grid = RectilinearGrid(CPU(), T; size = (3, 3, 3), extent = (3, 3, 3))
    #= none:10 =#
    ϕ = rand(T, 3, 3, 3)
    #= none:12 =#
    grid = ImmersedBoundaryGrid(grid, GridFittedBoundary(((x, y, z)->begin
                        #= none:12 =#
                        x < 1
                    end)))
    #= none:14 =#
    ϕ² = ϕ .^ 2
    #= none:16 =#
    δx_ϕ_f = T(0)
    #= none:17 =#
    δx_ϕ_c = ϕ²[3, 2, 2] - ϕ²[2, 2, 2]
    #= none:19 =#
    δy_ϕ_f = ϕ²[2, 2, 2] - ϕ²[2, 1, 2]
    #= none:20 =#
    δy_ϕ_c = ϕ²[2, 3, 2] - ϕ²[2, 2, 2]
    #= none:22 =#
    δz_ϕ_f = ϕ²[2, 2, 2] - ϕ²[2, 2, 1]
    #= none:23 =#
    δz_ϕ_c = ϕ²[2, 2, 3] - ϕ²[2, 2, 2]
    #= none:25 =#
    f(i, j, k, grid, ϕ) = begin
            #= none:25 =#
            ϕ[i, j, k] ^ 2
        end
    #= none:27 =#
    for δx = (δxᶜᶜᶜ, δxᶜᶜᶠ, δxᶜᶠᶜ, δxᶜᶠᶠ)
        #= none:28 =#
        #= none:28 =# @test δx(2, 2, 2, grid, f, ϕ) == δx_ϕ_c
        #= none:29 =#
    end
    #= none:30 =#
    for δx = (∂xᶠᶜᶜ, δxᶠᶜᶠ, δxᶠᶠᶜ, δxᶠᶠᶠ)
        #= none:31 =#
        #= none:31 =# @test δx(2, 2, 2, grid, f, ϕ) == δx_ϕ_f
        #= none:32 =#
    end
    #= none:34 =#
    for δy = (∂yᶜᶜᶜ, δyᶜᶜᶠ, δyᶠᶜᶜ, δyᶠᶜᶠ)
        #= none:35 =#
        #= none:35 =# @test δy(2, 2, 2, grid, f, ϕ) == δy_ϕ_c
        #= none:36 =#
    end
    #= none:37 =#
    for δy = (δyᶜᶠᶜ, δyᶠᶠᶜ, δyᶜᶠᶠ, δyᶠᶠᶠ)
        #= none:38 =#
        #= none:38 =# @test δy(2, 2, 2, grid, f, ϕ) == δy_ϕ_f
        #= none:39 =#
    end
    #= none:41 =#
    for δz = (δzᶜᶜᶜ, δzᶜᶠᶜ, δzᶠᶜᶜ, δzᶠᶠᶜ)
        #= none:42 =#
        #= none:42 =# @test δz(2, 2, 2, grid, f, ϕ) == δz_ϕ_c
        #= none:43 =#
    end
    #= none:44 =#
    for δz = (δzᶜᶜᶠ, δzᶜᶠᶠ, δzᶠᶜᶠ, δzᶠᶠᶠ)
        #= none:45 =#
        #= none:45 =# @test δz(2, 2, 2, grid, f, ϕ) == δz_ϕ_f
        #= none:46 =#
    end
    #= none:48 =#
    return nothing
end
#= none:51 =#
function test_function_differentiation(T = Float64)
    #= none:51 =#
    #= none:52 =#
    grid = RectilinearGrid(CPU(), T; size = (3, 3, 3), extent = (3, 3, 3))
    #= none:53 =#
    ϕ = rand(T, 3, 3, 3)
    #= none:54 =#
    ϕ² = ϕ .^ 2
    #= none:56 =#
    ∂x_ϕ_f = ϕ²[2, 2, 2] - ϕ²[1, 2, 2]
    #= none:57 =#
    ∂x_ϕ_c = ϕ²[3, 2, 2] - ϕ²[2, 2, 2]
    #= none:59 =#
    ∂y_ϕ_f = ϕ²[2, 2, 2] - ϕ²[2, 1, 2]
    #= none:60 =#
    ∂y_ϕ_c = ϕ²[2, 3, 2] - ϕ²[2, 2, 2]
    #= none:62 =#
    ∂z_ϕ_f = ϕ²[2, 2, 2] - ϕ²[2, 2, 1]
    #= none:63 =#
    ∂z_ϕ_c = ϕ²[2, 2, 3] - ϕ²[2, 2, 2]
    #= none:65 =#
    f(i, j, k, grid, ϕ) = begin
            #= none:65 =#
            ϕ[i, j, k] ^ 2
        end
    #= none:67 =#
    for ∂x = (∂xᶜᶜᶜ, ∂xᶜᶜᶠ, ∂xᶜᶠᶜ, ∂xᶜᶠᶠ)
        #= none:68 =#
        #= none:68 =# @test ∂x(2, 2, 2, grid, f, ϕ) == ∂x_ϕ_c
        #= none:69 =#
    end
    #= none:70 =#
    for ∂x = (∂xᶠᶜᶜ, ∂xᶠᶜᶠ, ∂xᶠᶠᶜ, ∂xᶠᶠᶠ)
        #= none:71 =#
        #= none:71 =# @test ∂x(2, 2, 2, grid, f, ϕ) == ∂x_ϕ_f
        #= none:72 =#
    end
    #= none:74 =#
    for ∂y = (∂yᶜᶜᶜ, ∂yᶜᶜᶠ, ∂yᶠᶜᶜ, ∂yᶠᶜᶠ)
        #= none:75 =#
        #= none:75 =# @test ∂y(2, 2, 2, grid, f, ϕ) == ∂y_ϕ_c
        #= none:76 =#
    end
    #= none:77 =#
    for ∂y = (∂yᶜᶠᶜ, ∂yᶠᶠᶜ, ∂yᶜᶠᶠ, ∂yᶠᶠᶠ)
        #= none:78 =#
        #= none:78 =# @test ∂y(2, 2, 2, grid, f, ϕ) == ∂y_ϕ_f
        #= none:79 =#
    end
    #= none:81 =#
    for ∂z = (∂zᶜᶜᶜ, ∂zᶜᶠᶜ, ∂zᶠᶜᶜ, ∂zᶠᶠᶜ)
        #= none:82 =#
        #= none:82 =# @test ∂z(2, 2, 2, grid, f, ϕ) == ∂z_ϕ_c
        #= none:83 =#
    end
    #= none:84 =#
    for ∂z = (∂zᶜᶜᶠ, ∂zᶜᶠᶠ, ∂zᶠᶜᶠ, ∂zᶠᶠᶠ)
        #= none:85 =#
        #= none:85 =# @test ∂z(2, 2, 2, grid, f, ϕ) == ∂z_ϕ_f
        #= none:86 =#
    end
    #= none:88 =#
    stretched_f = [0, 1, 3, 6]
    #= none:89 =#
    stretched_c = OffsetArray([-0.5, 0.5, 2, 4.5, 7.5], -1)
    #= none:91 =#
    dc(i) = begin
            #= none:91 =#
            stretched_f[i + 1] - stretched_f[i]
        end
    #= none:92 =#
    df(i) = begin
            #= none:92 =#
            stretched_c[i] - stretched_c[i - 1]
        end
    #= none:94 =#
    grid = RectilinearGrid(CPU(), T; size = (3, 3, 3), x = stretched_f, y = stretched_f, z = stretched_f, topology = (Bounded, Bounded, Bounded))
    #= none:96 =#
    ∂x_f(i, j, k) = begin
            #= none:96 =#
            (ϕ²[i, j, k] - ϕ²[i - 1, j, k]) / df(i)
        end
    #= none:97 =#
    ∂x_c(i, j, k) = begin
            #= none:97 =#
            (ϕ²[i + 1, j, k] - ϕ²[i, j, k]) / dc(i)
        end
    #= none:98 =#
    ∂y_f(i, j, k) = begin
            #= none:98 =#
            (ϕ²[i, j, k] - ϕ²[i, j - 1, k]) / df(j)
        end
    #= none:99 =#
    ∂y_c(i, j, k) = begin
            #= none:99 =#
            (ϕ²[i, j + 1, k] - ϕ²[i, j, k]) / dc(j)
        end
    #= none:100 =#
    ∂z_f(i, j, k) = begin
            #= none:100 =#
            (ϕ²[i, j, k] - ϕ²[i, j, k - 1]) / df(k)
        end
    #= none:101 =#
    ∂z_c(i, j, k) = begin
            #= none:101 =#
            (ϕ²[i, j, k + 1] - ϕ²[i, j, k]) / dc(k)
        end
    #= none:103 =#
    for ∂x = (∂xᶜᶜᶜ, ∂xᶜᶜᶠ, ∂xᶜᶠᶜ, ∂xᶜᶠᶠ)
        #= none:104 =#
        #= none:104 =# @test ∂x(2, 2, 2, grid, f, ϕ) == ∂x_c(2, 2, 2)
        #= none:105 =#
    end
    #= none:106 =#
    for ∂x = (∂xᶠᶜᶜ, ∂xᶠᶜᶠ, ∂xᶠᶠᶜ, ∂xᶠᶠᶠ)
        #= none:107 =#
        #= none:107 =# @test ∂x(2, 2, 2, grid, f, ϕ) == ∂x_f(2, 2, 2)
        #= none:108 =#
    end
    #= none:110 =#
    for ∂y = (∂yᶜᶜᶜ, ∂yᶜᶜᶠ, ∂yᶠᶜᶜ, ∂yᶠᶜᶠ)
        #= none:111 =#
        #= none:111 =# @test ∂y(2, 2, 2, grid, f, ϕ) == ∂y_c(2, 2, 2)
        #= none:112 =#
    end
    #= none:113 =#
    for ∂y = (∂yᶜᶠᶜ, ∂yᶠᶠᶜ, ∂yᶜᶠᶠ, ∂yᶠᶠᶠ)
        #= none:114 =#
        #= none:114 =# @test ∂y(2, 2, 2, grid, f, ϕ) == ∂y_f(2, 2, 2)
        #= none:115 =#
    end
    #= none:117 =#
    for ∂z = (∂zᶜᶜᶜ, ∂zᶜᶠᶜ, ∂zᶠᶜᶜ, ∂zᶠᶠᶜ)
        #= none:118 =#
        #= none:118 =# @test ∂z(2, 2, 2, grid, f, ϕ) == ∂z_c(2, 2, 2)
        #= none:119 =#
    end
    #= none:120 =#
    for ∂z = (∂zᶜᶜᶠ, ∂zᶜᶠᶠ, ∂zᶠᶜᶠ, ∂zᶠᶠᶠ)
        #= none:121 =#
        #= none:121 =# @test ∂z(2, 2, 2, grid, f, ϕ) == ∂z_f(2, 2, 2)
        #= none:122 =#
    end
    #= none:124 =#
    return nothing
end
#= none:127 =#
function test_function_interpolation(T = Float64)
    #= none:127 =#
    #= none:128 =#
    grid = RectilinearGrid(CPU(), T; size = (3, 3, 3), extent = (3, 3, 3))
    #= none:129 =#
    ϕ = rand(T, 3, 3, 3)
    #= none:130 =#
    ϕ² = ϕ .^ 2
    #= none:132 =#
    ℑx_ϕ_f = (ϕ²[2, 2, 2] + ϕ²[1, 2, 2]) / 2
    #= none:133 =#
    ℑx_ϕ_c = (ϕ²[3, 2, 2] + ϕ²[2, 2, 2]) / 2
    #= none:135 =#
    ℑy_ϕ_f = (ϕ²[2, 2, 2] + ϕ²[2, 1, 2]) / 2
    #= none:136 =#
    ℑy_ϕ_c = (ϕ²[2, 3, 2] + ϕ²[2, 2, 2]) / 2
    #= none:138 =#
    ℑz_ϕ_f = (ϕ²[2, 2, 2] + ϕ²[2, 2, 1]) / 2
    #= none:139 =#
    ℑz_ϕ_c = (ϕ²[2, 2, 3] + ϕ²[2, 2, 2]) / 2
    #= none:141 =#
    f(i, j, k, grid, ϕ) = begin
            #= none:141 =#
            ϕ[i, j, k] ^ 2
        end
    #= none:143 =#
    #= none:143 =# @test ℑxᶜᵃᵃ(2, 2, 2, grid, f, ϕ) == ℑx_ϕ_c
    #= none:144 =#
    #= none:144 =# @test ℑxᶠᵃᵃ(2, 2, 2, grid, f, ϕ) == ℑx_ϕ_f
    #= none:146 =#
    #= none:146 =# @test ℑyᵃᶜᵃ(2, 2, 2, grid, f, ϕ) == ℑy_ϕ_c
    #= none:147 =#
    #= none:147 =# @test ℑyᵃᶠᵃ(2, 2, 2, grid, f, ϕ) == ℑy_ϕ_f
    #= none:149 =#
    #= none:149 =# @test ℑzᵃᵃᶜ(2, 2, 2, grid, f, ϕ) == ℑz_ϕ_c
    #= none:150 =#
    #= none:150 =# @test ℑzᵃᵃᶠ(2, 2, 2, grid, f, ϕ) == ℑz_ϕ_f
    #= none:152 =#
    return nothing
end
#= none:155 =#
#= none:155 =# @testset "Operators" begin
        #= none:156 =#
        #= none:156 =# @info "Testing operators..."
        #= none:158 =#
        #= none:158 =# @testset "Grid lengths, areas, and volume operators" begin
                #= none:159 =#
                #= none:159 =# @info "  Testing grid lengths, areas, and volume operators..."
                #= none:161 =#
                x_spacings = ([eval(Symbol(:Δx, LX, :ᵃ, :ᵃ)) for LX = (:ᶜ, :ᶠ)]..., [eval(Symbol(:Δx, LX, LY, :ᵃ)) for LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ)]..., [eval(Symbol(:Δx, LX, LY, LZ)) for LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ), LZ = (:ᶜ, :ᶠ)]...)
                #= none:165 =#
                y_spacings = ([eval(Symbol(:Δy, :ᵃ, LY, :ᵃ)) for LY = (:ᶜ, :ᶠ)]..., [eval(Symbol(:Δy, LX, LY, :ᵃ)) for LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ)]..., [eval(Symbol(:Δy, LX, LY, LZ)) for LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ), LZ = (:ᶜ, :ᶠ)]...)
                #= none:169 =#
                z_spacings = ([eval(Symbol(:Δz, :ᵃ, :ᵃ, LZ)) for LZ = (:ᶜ, :ᶠ)]..., [eval(Symbol(:Δz, LX, LY, LZ)) for LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ), LZ = (:ᶜ, :ᶠ)]...)
                #= none:172 =#
                FT = Float64
                #= none:173 =#
                grid = RectilinearGrid(CPU(), FT, size = (1, 1, 1), extent = (π, 2π, 3π))
                #= none:175 =#
                #= none:175 =# @testset "Easterly lengths" begin
                        #= none:176 =#
                        #= none:176 =# @info "    Testing easterly lengths..."
                        #= none:177 =#
                        for δ = x_spacings
                            #= none:178 =#
                            #= none:178 =# @test δ(1, 1, 1, grid) == FT(π)
                            #= none:179 =#
                        end
                    end
                #= none:182 =#
                #= none:182 =# @testset "Westerly lengths" begin
                        #= none:183 =#
                        #= none:183 =# @info "    Testing westerly lengths..."
                        #= none:184 =#
                        for δ = y_spacings
                            #= none:185 =#
                            #= none:185 =# @test δ(1, 1, 1, grid) == FT(2π)
                            #= none:186 =#
                        end
                    end
                #= none:189 =#
                #= none:189 =# @testset "Vertical lengths" begin
                        #= none:190 =#
                        #= none:190 =# @info "    Testing vertical lengths..."
                        #= none:191 =#
                        for δ = z_spacings
                            #= none:192 =#
                            #= none:192 =# @test δ(1, 1, 1, grid) == FT(3π)
                            #= none:193 =#
                        end
                    end
                #= none:196 =#
                #= none:196 =# @testset "East-normal areas in the yz-plane" begin
                        #= none:197 =#
                        #= none:197 =# @info "    Testing areas with easterly normal in the yz-plane..."
                        #= none:198 =#
                        for A = (Axᶜᶜᶜ, Axᶠᶜᶜ, Axᶜᶠᶜ, Axᶜᶜᶠ, Axᶠᶠᶠ, Axᶠᶠᶜ, Axᶠᶜᶠ, Axᶜᶠᶠ)
                            #= none:199 =#
                            #= none:199 =# @test A(1, 1, 1, grid) == FT(6 * π ^ 2)
                            #= none:200 =#
                        end
                    end
                #= none:203 =#
                #= none:203 =# @testset "West-normal areas in the xz-plane" begin
                        #= none:204 =#
                        #= none:204 =# @info "    Testing areas with westerly normal in the xz-plane..."
                        #= none:205 =#
                        for A = (Ayᶜᶜᶜ, Ayᶠᶜᶜ, Ayᶜᶠᶜ, Ayᶜᶜᶠ, Ayᶠᶠᶠ, Ayᶠᶠᶜ, Ayᶠᶜᶠ, Ayᶜᶠᶠ)
                            #= none:206 =#
                            #= none:206 =# @test A(1, 1, 1, grid) == FT(3 * π ^ 2)
                            #= none:207 =#
                        end
                    end
                #= none:210 =#
                #= none:210 =# @testset "Horizontal areas in the xy-plane" begin
                        #= none:211 =#
                        #= none:211 =# @info "    Testing horizontal areas in the xy-plane..."
                        #= none:212 =#
                        for A = (Azᶜᶜᶜ, Azᶠᶜᶜ, Azᶜᶠᶜ, Azᶜᶜᶠ, Azᶠᶠᶠ, Azᶠᶠᶜ, Azᶠᶜᶠ, Azᶜᶠᶠ)
                            #= none:213 =#
                            #= none:213 =# @test A(1, 1, 1, grid) == FT(2 * π ^ 2)
                            #= none:214 =#
                        end
                    end
                #= none:217 =#
                #= none:217 =# @testset "Volumes" begin
                        #= none:218 =#
                        #= none:218 =# @info "    Testing volumes..."
                        #= none:219 =#
                        for V = (Vᶜᶜᶜ, Vᶠᶜᶜ, Vᶜᶠᶜ, Vᶜᶜᶠ, Vᶠᶠᶠ, Vᶠᶠᶜ, Vᶠᶜᶠ, Vᶜᶠᶠ)
                            #= none:220 =#
                            #= none:220 =# @test V(1, 1, 1, grid) == FT(6 * π ^ 3)
                            #= none:221 =#
                        end
                    end
            end
        #= none:226 =#
        #= none:226 =# @testset "Function differences" begin
                #= none:227 =#
                #= none:227 =# @info "  Testing function differences..."
                #= none:228 =#
                test_three_dimensional_differences()
            end
        #= none:231 =#
        #= none:231 =# @testset "Function differentiation" begin
                #= none:232 =#
                #= none:232 =# @info "  Testing function differentiation..."
                #= none:233 =#
                test_function_differentiation()
            end
        #= none:236 =#
        #= none:236 =# @testset "Function interpolation" begin
                #= none:237 =#
                #= none:237 =# @info "  Testing function interpolation..."
                #= none:238 =#
                test_function_interpolation()
            end
        #= none:241 =#
        #= none:241 =# @testset "2D operators" begin
                #= none:242 =#
                #= none:242 =# @info "  Testing 2D operators..."
                #= none:244 =#
                (Nx, Ny, Nz) = (32, 16, 8)
                #= none:245 =#
                (Lx, Ly, Lz) = (100, 100, 100)
                #= none:247 =#
                arch = CPU()
                #= none:248 =#
                grid = RectilinearGrid(CPU(), size = (Nx, Ny, Nz), extent = (Lx, Ly, Lz))
                #= none:249 =#
                bcs = FieldBoundaryConditions(grid, (Center, Center, Center))
                #= none:251 =#
                (Hx, Hy, Hz) = (grid.Hx, grid.Hy, grid.Hz)
                #= none:252 =#
                (Tx, Ty, Tz) = (Nx + 2Hx, Ny + 2Hy, Nz + 2Hz)
                #= none:254 =#
                A3 = OffsetArray(zeros(Tx, Ty, Tz), 1 - Hx:Nx + Hx, 1 - Hy:Ny + Hy, 1 - Hz:Nz + Hz)
                #= none:255 =#
                #= none:255 =# @__dot__ #= none:255 =# @views(A3[1:Nx, 1:Ny, 1:Nz] = rand())
                #= none:256 =#
                fill_halo_regions!(A3, bcs, (:, :, :), (Center, Center, Center), grid)
                #= none:259 =#
                A2yz = OffsetArray(zeros(1 + 2Hx, Ty, Tz), 1 - Hx:1 + Hx, 1 - Hy:Ny + Hy, 1 - Hz:Nz + Hz)
                #= none:260 =#
                grid_yz = RectilinearGrid(CPU(), size = (1, Ny, Nz), extent = (Lx, Ly, Lz))
                #= none:263 =#
                A2yz[0:2, 0:Ny + 1, 1:Nz] .= A3[1:1, 0:Ny + 1, 1:Nz]
                #= none:264 =#
                A2yz[:, :, 0] .= A2yz[:, :, 1]
                #= none:265 =#
                A2yz[:, :, Nz + 1] .= A2yz[:, :, Nz]
                #= none:268 =#
                A2xz = OffsetArray(zeros(Tx, 1 + 2Hy, Tz), 1 - Hx:Nx + Hx, 1 - Hy:1 + Hy, 1 - Hz:Nz + Hz)
                #= none:269 =#
                grid_xz = RectilinearGrid(CPU(), size = (Nx, 1, Nz), extent = (Lx, Ly, Lz))
                #= none:272 =#
                A2xz[0:Nx + 1, 0:2, 1:Nz] .= A3[0:Nx + 1, 1:1, 1:Nz]
                #= none:273 =#
                A2xz[:, :, 0] .= A2xz[:, :, 1]
                #= none:274 =#
                A2xz[:, :, Nz + 1] .= A2xz[:, :, Nz]
                #= none:276 =#
                test_indices_3d = [(4, 5, 5), (21, 11, 4), (16, 8, 4), (30, 12, 3), (11, 3, 6), (2, 10, 4), (31, 5, 6), (10, 2, 4), (17, 15, 5), (17, 10, 2), (23, 5, 7), (1, 5, 5), (32, 10, 3), (16, 1, 4), (16, 16, 4), (16, 8, 1), (16, 8, 8), (1, 1, 1), (32, 16, 8)]
                #= none:281 =#
                test_indices_2d_yz = [(1, 1, 1), (1, 1, 2), (1, 2, 1), (1, 2, 2), (1, 1, 5), (1, 5, 1), (1, 5, 5), (1, 11, 4), (1, 15, 7), (1, 15, 8), (1, 16, 7), (1, 16, 8)]
                #= none:285 =#
                test_indices_2d_xz = [(1, 1, 1), (1, 1, 2), (2, 1, 1), (2, 1, 2), (1, 1, 5), (5, 1, 1), (5, 1, 5), (17, 1, 4), (31, 1, 7), (31, 1, 8), (32, 1, 7), (32, 1, 8)]
                #= none:289 =#
                for idx = test_indices_2d_yz
                    #= none:290 =#
                    #= none:290 =# @test δxᶜᵃᵃ(idx..., grid_yz, A2yz) ≈ 0
                    #= none:291 =#
                    #= none:291 =# @test δxᶠᵃᵃ(idx..., grid_yz, A2yz) ≈ 0
                    #= none:292 =#
                    #= none:292 =# @test δyᵃᶜᵃ(idx..., grid_yz, A2yz) ≈ δyᵃᶜᵃ(idx..., grid_yz, A3)
                    #= none:293 =#
                    #= none:293 =# @test δyᵃᶠᵃ(idx..., grid_yz, A2yz) ≈ δyᵃᶠᵃ(idx..., grid_yz, A3)
                    #= none:294 =#
                    #= none:294 =# @test δzᵃᵃᶜ(idx..., grid_yz, A2yz) ≈ δzᵃᵃᶜ(idx..., grid_yz, A3)
                    #= none:295 =#
                    #= none:295 =# @test δzᵃᵃᶠ(idx..., grid_yz, A2yz) ≈ δzᵃᵃᶠ(idx..., grid_yz, A3)
                    #= none:296 =#
                end
                #= none:298 =#
                for idx = test_indices_2d_xz
                    #= none:299 =#
                    #= none:299 =# @test δxᶜᵃᵃ(idx..., grid_xz, A2xz) ≈ δxᶜᵃᵃ(idx..., grid_xz, A3)
                    #= none:300 =#
                    #= none:300 =# @test δxᶠᵃᵃ(idx..., grid_xz, A2xz) ≈ δxᶠᵃᵃ(idx..., grid_xz, A3)
                    #= none:301 =#
                    #= none:301 =# @test δyᵃᶜᵃ(idx..., grid_xz, A2xz) ≈ 0
                    #= none:302 =#
                    #= none:302 =# @test δyᵃᶠᵃ(idx..., grid_xz, A2xz) ≈ 0
                    #= none:303 =#
                    #= none:303 =# @test δzᵃᵃᶜ(idx..., grid_xz, A2xz) ≈ δzᵃᵃᶜ(idx..., grid_xz, A3)
                    #= none:304 =#
                    #= none:304 =# @test δzᵃᵃᶠ(idx..., grid_xz, A2xz) ≈ δzᵃᵃᶠ(idx..., grid_xz, A3)
                    #= none:305 =#
                end
            end
    end