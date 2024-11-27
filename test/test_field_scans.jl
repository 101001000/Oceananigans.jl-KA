
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Statistics
#= none:4 =#
using Oceananigans.Architectures: on_architecture
#= none:5 =#
using Oceananigans.AbstractOperations: BinaryOperation
#= none:6 =#
using Oceananigans.Fields: ReducedField, CenterField, ZFaceField, compute_at!, @compute, reverse_cumsum!
#= none:7 =#
using Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:8 =#
using Oceananigans.Grids: halo_size
#= none:10 =#
trilinear(x, y, z) = begin
        #= none:10 =#
        x + y + z
    end
#= none:11 =#
interior_array(a, i, j, k) = begin
        #= none:11 =#
        Array(interior(a, i, j, k))
    end
#= none:13 =#
#= none:13 =# @testset "Fields computed by Reduction" begin
        #= none:14 =#
        #= none:14 =# @info "Testing Fields computed by reductions..."
        #= none:16 =#
        for arch = archs
            #= none:17 =#
            arch_str = string(typeof(arch))
            #= none:19 =#
            regular_grid = RectilinearGrid(arch, size = (2, 2, 2), x = (0, 2), y = (0, 2), z = (0, 2), topology = (Periodic, Periodic, Bounded))
            #= none:23 =#
            xy_regular_grid = RectilinearGrid(arch, size = (2, 2, 2), x = (0, 2), y = (0, 2), z = [0, 1, 2], topology = (Periodic, Periodic, Bounded))
            #= none:27 =#
            #= none:27 =# @testset "Averaged and integrated fields [$(arch_str)]" begin
                    #= none:28 =#
                    #= none:28 =# @info "  Testing averaged and integrated Fields [$(arch_str)]"
                    #= none:30 =#
                    for grid = (regular_grid, xy_regular_grid)
                        #= none:32 =#
                        (Nx, Ny, Nz) = size(grid)
                        #= none:34 =#
                        w = ZFaceField(grid)
                        #= none:35 =#
                        T = CenterField(grid)
                        #= none:36 =#
                        ζ = Field{Face, Face, Face}(grid)
                        #= none:38 =#
                        set!(T, trilinear)
                        #= none:39 =#
                        set!(w, trilinear)
                        #= none:40 =#
                        set!(ζ, trilinear)
                        #= none:42 =#
                        #= none:42 =# @compute Txyz = Field(Average(T, dims = (1, 2, 3)))
                        #= none:46 =#
                        fill_halo_regions!(T)
                        #= none:47 =#
                        #= none:47 =# @compute Txy = Field(Average(T, dims = (1, 2)))
                        #= none:49 =#
                        fill_halo_regions!(T)
                        #= none:50 =#
                        #= none:50 =# @compute Tx = Field(Average(T, dims = 1))
                        #= none:52 =#
                        #= none:52 =# @compute wxyz = Field(Average(w, dims = (1, 2, 3)))
                        #= none:53 =#
                        #= none:53 =# @compute wxy = Field(Average(w, dims = (1, 2)))
                        #= none:54 =#
                        #= none:54 =# @compute wx = Field(Average(w, dims = 1))
                        #= none:56 =#
                        #= none:56 =# @compute ζxyz = Field(Average(ζ, dims = (1, 2, 3)))
                        #= none:57 =#
                        #= none:57 =# @compute ζxy = Field(Average(ζ, dims = (1, 2)))
                        #= none:58 =#
                        #= none:58 =# @compute ζx = Field(Average(ζ, dims = 1))
                        #= none:60 =#
                        #= none:60 =# @compute Θxyz = Field(Integral(T, dims = (1, 2, 3)))
                        #= none:61 =#
                        #= none:61 =# @compute Θxy = Field(Integral(T, dims = (1, 2)))
                        #= none:62 =#
                        #= none:62 =# @compute Θx = Field(Integral(T, dims = 1))
                        #= none:64 =#
                        #= none:64 =# @compute Wxyz = Field(Integral(w, dims = (1, 2, 3)))
                        #= none:65 =#
                        #= none:65 =# @compute Wxy = Field(Integral(w, dims = (1, 2)))
                        #= none:66 =#
                        #= none:66 =# @compute Wx = Field(Integral(w, dims = 1))
                        #= none:68 =#
                        #= none:68 =# @compute Zxyz = Field(Integral(ζ, dims = (1, 2, 3)))
                        #= none:69 =#
                        #= none:69 =# @compute Zxy = Field(Integral(ζ, dims = (1, 2)))
                        #= none:70 =#
                        #= none:70 =# @compute Zx = Field(Integral(ζ, dims = 1))
                        #= none:72 =#
                        #= none:72 =# @compute Tcx = Field(CumulativeIntegral(T, dims = 1))
                        #= none:73 =#
                        #= none:73 =# @compute Tcy = Field(CumulativeIntegral(T, dims = 2))
                        #= none:74 =#
                        #= none:74 =# @compute Tcz = Field(CumulativeIntegral(T, dims = 3))
                        #= none:75 =#
                        #= none:75 =# @compute wcx = Field(CumulativeIntegral(w, dims = 1))
                        #= none:76 =#
                        #= none:76 =# @compute wcy = Field(CumulativeIntegral(w, dims = 2))
                        #= none:77 =#
                        #= none:77 =# @compute wcz = Field(CumulativeIntegral(w, dims = 3))
                        #= none:78 =#
                        #= none:78 =# @compute ζcx = Field(CumulativeIntegral(ζ, dims = 1))
                        #= none:79 =#
                        #= none:79 =# @compute ζcy = Field(CumulativeIntegral(ζ, dims = 2))
                        #= none:80 =#
                        #= none:80 =# @compute ζcz = Field(CumulativeIntegral(ζ, dims = 3))
                        #= none:82 =#
                        #= none:82 =# @compute Trx = Field(CumulativeIntegral(T, dims = 1, reverse = true))
                        #= none:83 =#
                        #= none:83 =# @compute Try = Field(CumulativeIntegral(T, dims = 2, reverse = true))
                        #= none:84 =#
                        #= none:84 =# @compute Trz = Field(CumulativeIntegral(T, dims = 3, reverse = true))
                        #= none:85 =#
                        #= none:85 =# @compute wrx = Field(CumulativeIntegral(w, dims = 1, reverse = true))
                        #= none:86 =#
                        #= none:86 =# @compute wry = Field(CumulativeIntegral(w, dims = 2, reverse = true))
                        #= none:87 =#
                        #= none:87 =# @compute wrz = Field(CumulativeIntegral(w, dims = 3, reverse = true))
                        #= none:88 =#
                        #= none:88 =# @compute ζrx = Field(CumulativeIntegral(ζ, dims = 1, reverse = true))
                        #= none:89 =#
                        #= none:89 =# @compute ζry = Field(CumulativeIntegral(ζ, dims = 2, reverse = true))
                        #= none:90 =#
                        #= none:90 =# @compute ζrz = Field(CumulativeIntegral(ζ, dims = 3, reverse = true))
                        #= none:92 =#
                        for T′ = (Tx, Txy)
                            #= none:93 =#
                            #= none:93 =# @test T′.operand.operand === T
                            #= none:94 =#
                        end
                        #= none:96 =#
                        for w′ = (wx, wxy)
                            #= none:97 =#
                            #= none:97 =# @test w′.operand.operand === w
                            #= none:98 =#
                        end
                        #= none:100 =#
                        for ζ′ = (ζx, ζxy)
                            #= none:101 =#
                            #= none:101 =# @test ζ′.operand.operand === ζ
                            #= none:102 =#
                        end
                        #= none:104 =#
                        for f = (wx, wxy, Tx, Txy, ζx, ζxy, Wx, Wxy, Θx, Θxy, Zx, Zxy)
                            #= none:105 =#
                            #= none:105 =# @test f.operand isa Reduction
                            #= none:106 =#
                        end
                        #= none:108 =#
                        for f = (Tcx, Tcy, Tcz, Trx, Try, Trz, wcx, wcy, wcz, wrx, wry, wrz, ζcx, ζcy, ζcz, ζrx, ζry, ζrz)
                            #= none:111 =#
                            #= none:111 =# @test f.operand isa Accumulation
                            #= none:112 =#
                        end
                        #= none:114 =#
                        for f = (wx, wxy, Tx, Txy, ζx, ζxy)
                            #= none:115 =#
                            #= none:115 =# @test f.operand.scan! === mean!
                            #= none:116 =#
                        end
                        #= none:118 =#
                        for f = (wx, wxy, Tx, Txy, ζx, ζxy)
                            #= none:119 =#
                            #= none:119 =# @test f.operand.scan! === mean!
                            #= none:120 =#
                        end
                        #= none:122 =#
                        for f = (Tcx, Tcy, Tcz, wcx, wcy, wcz, ζcx, ζcy, ζcz)
                            #= none:123 =#
                            #= none:123 =# @test f.operand.scan! === cumsum!
                            #= none:124 =#
                        end
                        #= none:126 =#
                        for f = (Trx, Try, Trz, wrx, wry, wrz, ζrx, ζry, ζrz)
                            #= none:127 =#
                            #= none:127 =# @test f.operand.scan! === reverse_cumsum!
                            #= none:128 =#
                        end
                        #= none:130 =#
                        #= none:130 =# @test Txyz.operand isa Reduction
                        #= none:131 =#
                        #= none:131 =# @test wxyz.operand isa Reduction
                        #= none:132 =#
                        #= none:132 =# @test ζxyz.operand isa Reduction
                        #= none:135 =#
                        if grid === regular_grid
                            #= none:136 =#
                            #= none:136 =# @test Txyz.operand.scan! === mean!
                            #= none:137 =#
                            #= none:137 =# @test wxyz.operand.scan! === mean!
                            #= none:138 =#
                            #= none:138 =# @test Txyz.operand.operand === T
                            #= none:139 =#
                            #= none:139 =# @test wxyz.operand.operand === w
                        else
                            #= none:141 =#
                            #= none:141 =# @test Txyz.operand.scan! === sum!
                            #= none:142 =#
                            #= none:142 =# @test wxyz.operand.scan! === sum!
                            #= none:143 =#
                            #= none:143 =# @test Txyz.operand.operand isa BinaryOperation
                            #= none:144 =#
                            #= none:144 =# @test wxyz.operand.operand isa BinaryOperation
                        end
                        #= none:147 =#
                        #= none:147 =# @test Tx.operand.dims === tuple(1)
                        #= none:148 =#
                        #= none:148 =# @test wx.operand.dims === tuple(1)
                        #= none:149 =#
                        #= none:149 =# @test Txy.operand.dims === (1, 2)
                        #= none:150 =#
                        #= none:150 =# @test wxy.operand.dims === (1, 2)
                        #= none:151 =#
                        #= none:151 =# @test Txyz.operand.dims === (1, 2, 3)
                        #= none:152 =#
                        #= none:152 =# @test wxyz.operand.dims === (1, 2, 3)
                        #= none:154 =#
                        #= none:154 =# @test #= none:154 =# CUDA.@allowscalar(Txyz[1, 1, 1] ≈ 3)
                        #= none:155 =#
                        #= none:155 =# @test interior_array(Txy, 1, 1, :) ≈ [2.5, 3.5]
                        #= none:156 =#
                        #= none:156 =# @test interior_array(Tx, 1, :, :) ≈ [[2, 3] [3, 4]]
                        #= none:158 =#
                        #= none:158 =# @test #= none:158 =# CUDA.@allowscalar(wxyz[1, 1, 1] ≈ 3)
                        #= none:159 =#
                        #= none:159 =# @test interior_array(wxy, 1, 1, :) ≈ [2, 3, 4]
                        #= none:160 =#
                        #= none:160 =# @test interior_array(wx, 1, :, :) ≈ [[1.5, 2.5] [2.5, 3.5] [3.5, 4.5]]
                        #= none:162 =#
                        averages_1d = (Tx, wx, ζx)
                        #= none:163 =#
                        integrals_1d = (Θx, Wx, Zx)
                        #= none:165 =#
                        for (a, i) = zip(averages_1d, integrals_1d)
                            #= none:166 =#
                            #= none:166 =# @test interior(i) == 2 .* interior(a)
                            #= none:167 =#
                        end
                        #= none:169 =#
                        averages_2d = (Txy, wxy, ζxy)
                        #= none:170 =#
                        integrals_2d = (Θxy, Wxy, Zxy)
                        #= none:172 =#
                        for (a, i) = zip(averages_2d, integrals_2d)
                            #= none:173 =#
                            #= none:173 =# @test interior(i) == 4 .* interior(a)
                            #= none:174 =#
                        end
                        #= none:178 =#
                        #= none:178 =# @test interior_array(Tcx, :, 1, 1) ≈ [1.5, 4]
                        #= none:179 =#
                        #= none:179 =# @test interior_array(Tcy, 1, :, 1) ≈ [1.5, 4]
                        #= none:180 =#
                        #= none:180 =# @test interior_array(Tcz, 1, 1, :) ≈ [1.5, 4]
                        #= none:182 =#
                        #= none:182 =# @test interior_array(Trx, :, 1, 1) ≈ [4, 2.5]
                        #= none:183 =#
                        #= none:183 =# @test interior_array(Try, 1, :, 1) ≈ [4, 2.5]
                        #= none:184 =#
                        #= none:184 =# @test interior_array(Trz, 1, 1, :) ≈ [4, 2.5]
                        #= none:189 =#
                        #= none:189 =# @test interior_array(wcx, :, 1, 1) ≈ [1, 3]
                        #= none:190 =#
                        #= none:190 =# @test interior_array(wcy, 1, :, 1) ≈ [1, 3]
                        #= none:191 =#
                        #= none:191 =# @test interior_array(wcz, 1, 1, :) ≈ [1, 3, 6]
                        #= none:193 =#
                        #= none:193 =# @test interior_array(wrx, :, 1, 1) ≈ [3, 2]
                        #= none:194 =#
                        #= none:194 =# @test interior_array(wry, 1, :, 1) ≈ [3, 2]
                        #= none:195 =#
                        #= none:195 =# @test interior_array(wrz, 1, 1, :) ≈ [6, 5, 3]
                        #= none:197 =#
                        #= none:197 =# @compute Txyz = #= none:197 =# CUDA.@allowscalar(Field(Average(T, condition = T .> 3)))
                        #= none:198 =#
                        #= none:198 =# @compute Txy = #= none:198 =# CUDA.@allowscalar(Field(Average(T, dims = (1, 2), condition = T .> 3)))
                        #= none:199 =#
                        #= none:199 =# @compute Tx = #= none:199 =# CUDA.@allowscalar(Field(Average(T, dims = 1, condition = T .> 2)))
                        #= none:201 =#
                        #= none:201 =# @test #= none:201 =# CUDA.@allowscalar(Txyz[1, 1, 1] ≈ 3.75)
                        #= none:202 =#
                        #= none:202 =# @test interior_array(Txy, 1, 1, :) ≈ [3.5, 11.5 / 3]
                        #= none:203 =#
                        #= none:203 =# @test interior_array(Tx, 1, :, :) ≈ [[2.5, 3] [3, 4]]
                        #= none:205 =#
                        #= none:205 =# @compute wxyz = #= none:205 =# CUDA.@allowscalar(Field(Average(w, condition = w .> 3)))
                        #= none:206 =#
                        #= none:206 =# @compute wxy = #= none:206 =# CUDA.@allowscalar(Field(Average(w, dims = (1, 2), condition = w .> 2)))
                        #= none:207 =#
                        #= none:207 =# @compute wx = #= none:207 =# CUDA.@allowscalar(Field(Average(w, dims = 1, condition = w .> 1)))
                        #= none:209 =#
                        #= none:209 =# @test #= none:209 =# CUDA.@allowscalar(wxyz[1, 1, 1] ≈ 4.25)
                        #= none:210 =#
                        #= none:210 =# @test interior_array(wxy, 1, 1, :) ≈ [3, 10 / 3, 4]
                        #= none:211 =#
                        #= none:211 =# @test interior_array(wx, 1, :, :) ≈ [[2, 2.5] [2.5, 3.5] [3.5, 4.5]]
                        #= none:214 =#
                        #= none:214 =# @compute T2cx = Field(CumulativeIntegral(2T, dims = 1))
                        #= none:215 =#
                        #= none:215 =# @compute T2cy = Field(CumulativeIntegral(2T, dims = 2))
                        #= none:216 =#
                        #= none:216 =# @compute T2cz = Field(CumulativeIntegral(2T, dims = 3))
                        #= none:218 =#
                        #= none:218 =# @compute T2rx = Field(CumulativeIntegral(2T, dims = 1, reverse = true))
                        #= none:219 =#
                        #= none:219 =# @compute T2ry = Field(CumulativeIntegral(2T, dims = 2, reverse = true))
                        #= none:220 =#
                        #= none:220 =# @compute T2rz = Field(CumulativeIntegral(2T, dims = 3, reverse = true))
                        #= none:224 =#
                        #= none:224 =# @test interior_array(T2cx, :, 1, 1) ≈ [3, 8]
                        #= none:225 =#
                        #= none:225 =# @test interior_array(T2cy, 1, :, 1) ≈ [3, 8]
                        #= none:226 =#
                        #= none:226 =# @test interior_array(T2cz, 1, 1, :) ≈ [3, 8]
                        #= none:228 =#
                        #= none:228 =# @test interior_array(T2rx, :, 1, 1) ≈ [8, 5]
                        #= none:229 =#
                        #= none:229 =# @test interior_array(T2ry, 1, :, 1) ≈ [8, 5]
                        #= none:230 =#
                        #= none:230 =# @test interior_array(T2rz, 1, 1, :) ≈ [8, 5]
                        #= none:231 =#
                    end
                    #= none:234 =#
                    big_grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Bounded), size = (256, 256, 128), x = (0, 2), y = (0, 2), z = (0, 2))
                    #= none:241 =#
                    c = CenterField(big_grid)
                    #= none:242 =#
                    c .= 1
                    #= none:244 =#
                    C = Field(Average(c, dims = (1, 2)))
                    #= none:248 =#
                    for i = 1:10
                        #= none:249 =#
                        sum!(C, C.operand.operand)
                        #= none:250 =#
                    end
                    #= none:252 =#
                    results = []
                    #= none:253 =#
                    for i = 1:10
                        #= none:254 =#
                        mean!(C, C.operand.operand)
                        #= none:255 =#
                        push!(results, all(interior(C) .== 1))
                        #= none:256 =#
                    end
                    #= none:258 =#
                    #= none:258 =# @test mean(results) == 1.0
                end
            #= none:261 =#
            #= none:261 =# @testset "Allocating reductions [$(arch_str)]" begin
                    #= none:262 =#
                    #= none:262 =# @info "  Testing allocating reductions"
                    #= none:264 =#
                    grid = RectilinearGrid(arch, size = (2, 2, 2), x = (0, 2), y = (0, 2), z = (0, 2), topology = (Periodic, Periodic, Bounded))
                    #= none:268 =#
                    w = ZFaceField(grid)
                    #= none:269 =#
                    T = CenterField(grid)
                    #= none:270 =#
                    set!(T, trilinear)
                    #= none:271 =#
                    set!(w, trilinear)
                    #= none:272 =#
                    fill_halo_regions!(T)
                    #= none:273 =#
                    fill_halo_regions!(w)
                    #= none:275 =#
                    #= none:275 =# @compute Txyz = Field(Average(T, dims = (1, 2, 3)))
                    #= none:276 =#
                    #= none:276 =# @compute Txy = Field(Average(T, dims = (1, 2)))
                    #= none:277 =#
                    #= none:277 =# @compute Tx = Field(Average(T, dims = 1))
                    #= none:279 =#
                    #= none:279 =# @compute wxyz = Field(Average(w, dims = (1, 2, 3)))
                    #= none:280 =#
                    #= none:280 =# @compute wxy = Field(Average(w, dims = (1, 2)))
                    #= none:281 =#
                    #= none:281 =# @compute wx = Field(Average(w, dims = 1))
                    #= none:284 =#
                    #= none:284 =# @test #= none:284 =# CUDA.@allowscalar(Txyz[1, 1, 1] == mean(T))
                    #= none:285 =#
                    #= none:285 =# @test interior(Txy) == interior(mean(T, dims = (1, 2)))
                    #= none:286 =#
                    #= none:286 =# @test interior(Tx) == interior(mean(T, dims = 1))
                    #= none:288 =#
                    #= none:288 =# @test #= none:288 =# CUDA.@allowscalar(wxyz[1, 1, 1] == mean(w))
                    #= none:289 =#
                    #= none:289 =# @test interior(wxy) == interior(mean(w, dims = (1, 2)))
                    #= none:290 =#
                    #= none:290 =# @test interior(wx) == interior(mean(w, dims = 1))
                    #= none:293 =#
                    #= none:293 =# @test maximum(T) == maximum(interior(T))
                    #= none:294 =#
                    #= none:294 =# @test minimum(T) == minimum(interior(T))
                    #= none:296 =#
                    for dims = (1, (1, 2))
                        #= none:297 =#
                        #= none:297 =# @test interior(minimum(T; dims)) == minimum(interior(T); dims)
                        #= none:298 =#
                        #= none:298 =# @test interior(minimum(T; dims)) == minimum(interior(T); dims)
                        #= none:299 =#
                    end
                end
            #= none:302 =#
            #= none:302 =# @testset "Conditional computation of averaged Fields [$(typeof(arch))]" begin
                    #= none:303 =#
                    #= none:303 =# @info "  Testing conditional computation of averaged Fields [$(typeof(arch))]"
                    #= none:304 =#
                    for FT = float_types
                        #= none:305 =#
                        grid = RectilinearGrid(arch, FT, size = (2, 2, 2), extent = (1, 1, 1))
                        #= none:306 =#
                        c = CenterField(grid)
                        #= none:308 =#
                        for dims = (1, 2, 3, (1, 2), (2, 3), (1, 3), (1, 2, 3))
                            #= none:309 =#
                            C = Field(Average(c, dims = dims))
                            #= none:311 =#
                            #= none:311 =# @test !(isnothing(C.status))
                            #= none:314 =#
                            set!(c, 1)
                            #= none:315 =#
                            compute_at!(C, FT(1))
                            #= none:316 =#
                            #= none:316 =# @test all(interior(C) .== 1)
                            #= none:317 =#
                            #= none:317 =# @test C.status.time == FT(1)
                            #= none:319 =#
                            set!(c, 2)
                            #= none:320 =#
                            compute_at!(C, FT(1))
                            #= none:321 =#
                            #= none:321 =# @test C.status.time == FT(1)
                            #= none:322 =#
                            #= none:322 =# @test all(interior(C) .== 1)
                            #= none:324 =#
                            compute_at!(C, FT(2))
                            #= none:325 =#
                            #= none:325 =# @test C.status.time == FT(2)
                            #= none:326 =#
                            #= none:326 =# @test all(interior(C) .== 2)
                            #= none:327 =#
                        end
                        #= none:328 =#
                    end
                end
            #= none:331 =#
            #= none:331 =# @testset "Immersed Fields reduction [$(typeof(arch))]" begin
                    #= none:332 =#
                    #= none:332 =# @info "  Testing reductions of immersed Fields [$(typeof(arch))]"
                    #= none:333 =#
                    underlying_grid = RectilinearGrid(arch, size = (3, 3, 3), extent = (1, 1, 1))
                    #= none:335 =#
                    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(((x, y)->begin
                                        #= none:335 =#
                                        if y < 0.5
                                            -0.6
                                        else
                                            0
                                        end
                                    end)))
                    #= none:336 =#
                    c = Field((Center, Center, Nothing), grid)
                    #= none:338 =#
                    set!(c, ((x, y)->begin
                                #= none:338 =#
                                y
                            end))
                    #= none:339 =#
                    #= none:339 =# @test maximum(c) == grid.yᵃᶜᵃ[1]
                    #= none:341 =#
                    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(((x, y)->begin
                                        #= none:341 =#
                                        if y < 0.5
                                            -0.6
                                        else
                                            -0.4
                                        end
                                    end)))
                    #= none:342 =#
                    c = Field((Center, Center, Nothing), grid)
                    #= none:344 =#
                    set!(c, ((x, y)->begin
                                #= none:344 =#
                                y
                            end))
                    #= none:345 =#
                    #= none:345 =# @test maximum(c) == grid.yᵃᶜᵃ[3]
                    #= none:347 =#
                    underlying_grid = RectilinearGrid(arch, size = (1, 1, 8), extent = (1, 1, 1))
                    #= none:349 =#
                    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(((x, y)->begin
                                        #= none:349 =#
                                        -3 / 4
                                    end)))
                    #= none:350 =#
                    c = Field((Center, Center, Center), grid)
                    #= none:352 =#
                    set!(c, ((x, y, z)->begin
                                #= none:352 =#
                                -z
                            end))
                    #= none:353 =#
                    #= none:353 =# @test maximum(c) == (Array(interior(c)))[1, 1, 3]
                    #= none:354 =#
                    c_condition = interior(c) .< 0.5
                    #= none:355 =#
                    avg_c_smaller_than_½ = Array(interior(compute!(Field(Average(c, condition = c_condition)))))
                    #= none:356 =#
                    #= none:356 =# @test avg_c_smaller_than_½[1, 1, 1] == 0.25
                    #= none:358 =#
                    zᶜᶜᶜ = KernelFunctionOperation{Center, Center, Center}(znode, grid, Center(), Center(), Center())
                    #= none:359 =#
                    ci = Array(interior(c))
                    #= none:360 =#
                    bottom_half_average_manual = (ci[1, 1, 3] + ci[1, 1, 4]) / 2
                    #= none:361 =#
                    bottom_half_average = Average(c; condition = zᶜᶜᶜ .< -1 / 2)
                    #= none:362 =#
                    bottom_half_average_field = Field(bottom_half_average)
                    #= none:363 =#
                    compute!(bottom_half_average_field)
                    #= none:364 =#
                    bottom_half_average_array = Array(interior(bottom_half_average_field))
                    #= none:365 =#
                    #= none:365 =# @test bottom_half_average_array[1, 1, 1] == bottom_half_average_manual
                end
            #= none:367 =#
        end
    end