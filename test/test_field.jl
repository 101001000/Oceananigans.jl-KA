
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Statistics
#= none:5 =#
using Oceananigans.Grids: total_length
#= none:6 =#
using Oceananigans.Fields: ReducedField, has_velocities
#= none:7 =#
using Oceananigans.Fields: VelocityFields, TracerFields, interpolate, interpolate!
#= none:8 =#
using Oceananigans.Fields: reduced_location
#= none:10 =#
#= none:10 =# Core.@doc "    correct_field_size(grid, FieldType, Tx, Ty, Tz)\n\nTest that the field initialized by the FieldType constructor on `grid`\nhas size `(Tx, Ty, Tz)`.\n" correct_field_size(grid, loc, Tx, Ty, Tz) = begin
            #= none:16 =#
            size(parent(Field(loc, grid))) == (Tx, Ty, Tz)
        end
#= none:18 =#
function run_similar_field_tests(f)
    #= none:18 =#
    #= none:19 =#
    g = similar(f)
    #= none:20 =#
    #= none:20 =# @test typeof(f) == typeof(g)
    #= none:21 =#
    #= none:21 =# @test f.grid == g.grid
    #= none:22 =#
    #= none:22 =# @test location(f) === location(g)
    #= none:23 =#
    #= none:23 =# @test !(f.data === g.data)
    #= none:24 =#
    return nothing
end
#= none:27 =#
#= none:27 =# Core.@doc "     correct_field_value_was_set(N, L, ftf, val)\n\nTest that the field initialized by the field type function `ftf` on the grid g\ncan be correctly filled with the value `val` using the `set!(f::AbstractField, v)`\nfunction.\n" function correct_field_value_was_set(grid, FieldType, val::Number)
        #= none:34 =#
        #= none:35 =#
        arch = architecture(grid)
        #= none:36 =#
        f = FieldType(grid)
        #= none:37 =#
        set!(f, val)
        #= none:38 =#
        return all(interior(f) .≈ val * on_architecture(arch, ones(size(f))))
    end
#= none:41 =#
function run_field_reduction_tests(FT, arch)
    #= none:41 =#
    #= none:42 =#
    N = 8
    #= none:43 =#
    topo = (Bounded, Bounded, Bounded)
    #= none:44 =#
    grid = RectilinearGrid(arch, FT, topology = topo, size = (N, N, N), x = (-1, 1), y = (0, 2π), z = (-1, 1))
    #= none:46 =#
    u = XFaceField(grid)
    #= none:47 =#
    v = YFaceField(grid)
    #= none:48 =#
    w = ZFaceField(grid)
    #= none:49 =#
    c = CenterField(grid)
    #= none:51 =#
    f(x, y, z) = begin
            #= none:51 =#
            1 + exp(x) * sin(y) * tanh(z)
        end
    #= none:53 =#
    ϕs = (u, v, w, c)
    #= none:54 =#
    [set!(ϕ, f) for ϕ = ϕs]
    #= none:56 =#
    u_vals = f.(nodes(u, reshape = true)...)
    #= none:57 =#
    v_vals = f.(nodes(v, reshape = true)...)
    #= none:58 =#
    w_vals = f.(nodes(w, reshape = true)...)
    #= none:59 =#
    c_vals = f.(nodes(c, reshape = true)...)
    #= none:62 =#
    u_vals = on_architecture(arch, u_vals)
    #= none:63 =#
    v_vals = on_architecture(arch, v_vals)
    #= none:64 =#
    w_vals = on_architecture(arch, w_vals)
    #= none:65 =#
    c_vals = on_architecture(arch, c_vals)
    #= none:67 =#
    ϕs_vals = (u_vals, v_vals, w_vals, c_vals)
    #= none:69 =#
    dims_to_test = (1, 2, 3, (1, 2), (1, 3), (2, 3), (1, 2, 3))
    #= none:71 =#
    for (ϕ, ϕ_vals) = zip(ϕs, ϕs_vals)
        #= none:73 =#
        ε = eps(eltype(ϕ_vals)) * 10 * maximum(maximum.(ϕs_vals))
        #= none:74 =#
        #= none:74 =# @info "    Testing field reductions with tolerance $(ε)..."
        #= none:76 =#
        #= none:76 =# @test #= none:76 =# CUDA.@allowscalar(all(isapprox.(ϕ, ϕ_vals, atol = ε)))
        #= none:79 =#
        CUDA.allowscalar(false)
        #= none:81 =#
        #= none:81 =# @test minimum(ϕ) ≈ minimum(ϕ_vals) atol = ε
        #= none:82 =#
        #= none:82 =# @test maximum(ϕ) ≈ maximum(ϕ_vals) atol = ε
        #= none:83 =#
        #= none:83 =# @test mean(ϕ) ≈ mean(ϕ_vals) atol = 2ε
        #= none:84 =#
        #= none:84 =# @test minimum(∛, ϕ) ≈ minimum(∛, ϕ_vals) atol = ε
        #= none:85 =#
        #= none:85 =# @test maximum(abs, ϕ) ≈ maximum(abs, ϕ_vals) atol = ε
        #= none:86 =#
        #= none:86 =# @test mean(abs2, ϕ) ≈ mean(abs2, ϕ) atol = ε
        #= none:88 =#
        for dims = dims_to_test
            #= none:89 =#
            #= none:89 =# @test all(isapprox(minimum(ϕ, dims = dims), minimum(ϕ_vals, dims = dims), atol = 4ε))
            #= none:90 =#
            #= none:90 =# @test all(isapprox(maximum(ϕ, dims = dims), maximum(ϕ_vals, dims = dims), atol = 4ε))
            #= none:91 =#
            #= none:91 =# @test all(isapprox(mean(ϕ, dims = dims), mean(ϕ_vals, dims = dims), atol = 4ε))
            #= none:93 =#
            #= none:93 =# @test all(isapprox(minimum(sin, ϕ, dims = dims), minimum(sin, ϕ_vals, dims = dims), atol = 4ε))
            #= none:94 =#
            #= none:94 =# @test all(isapprox(maximum(cos, ϕ, dims = dims), maximum(cos, ϕ_vals, dims = dims), atol = 4ε))
            #= none:95 =#
            #= none:95 =# @test all(isapprox(mean(cosh, ϕ, dims = dims), mean(cosh, ϕ_vals, dims = dims), atol = 5ε))
            #= none:96 =#
        end
        #= none:97 =#
    end
    #= none:99 =#
    return nothing
end
#= none:102 =#
#= none:102 =# @inline interpolate_xyz(x, y, z, from_field, from_loc, from_grid) = begin
            #= none:102 =#
            interpolate((x, y, z), from_field, from_loc, from_grid)
        end
#= none:107 =#
#= none:107 =# @inline func(x, y, z) = begin
            #= none:107 =#
            convert(typeof(x), (((((exp(-1) + 3x) - y / 7) + z + (2x) * y) - (3x) * z) + (4y) * z) - (5x) * y * z)
        end
#= none:109 =#
function run_field_interpolation_tests(grid)
    #= none:109 =#
    #= none:110 =#
    arch = architecture(grid)
    #= none:111 =#
    velocities = VelocityFields(grid)
    #= none:112 =#
    tracers = TracerFields((:c,), grid)
    #= none:114 =#
    ((u, v, w), c) = (velocities, tracers.c)
    #= none:120 =#
    (xf, yf, zf) = nodes(grid, (Face(), Face(), Face()), reshape = true)
    #= none:121 =#
    f_max = #= none:121 =# CUDA.@allowscalar(maximum(func.(xf, yf, zf)))
    #= none:122 =#
    ε_max = eps(f_max)
    #= none:123 =#
    tolerance = 10ε_max
    #= none:125 =#
    set!(u, func)
    #= none:126 =#
    set!(v, func)
    #= none:127 =#
    set!(w, func)
    #= none:128 =#
    set!(c, func)
    #= none:133 =#
    for f = (u, v, w, c)
        #= none:134 =#
        (x, y, z) = nodes(f, reshape = true)
        #= none:135 =#
        loc = Tuple((L() for L = location(f)))
        #= none:137 =#
        #= none:137 =# CUDA.@allowscalar begin
                #= none:138 =#
                ℑf = interpolate_xyz.(x, y, z, Ref(f.data), Ref(loc), Ref(f.grid))
            end
        #= none:141 =#
        ℑf_cpu = Array(ℑf)
        #= none:142 =#
        f_interior_cpu = Array(interior(f))
        #= none:143 =#
        #= none:143 =# @test all(isapprox.(ℑf_cpu, f_interior_cpu, atol = tolerance))
        #= none:144 =#
    end
    #= none:148 =#
    xs = Array(reshape([0.3, 0.55, 0.73], (3, 1, 1)))
    #= none:149 =#
    ys = Array(reshape([-π / 6, 0, 1 + 1.0e-7], (1, 3, 1)))
    #= none:150 =#
    zs = Array(reshape([-1.3, 1.23, 2.1], (1, 1, 3)))
    #= none:152 =#
    X = [(xs[i], ys[j], zs[k]) for i = 1:3, j = 1:3, k = 1:3]
    #= none:153 =#
    X = on_architecture(arch, X)
    #= none:155 =#
    xs = on_architecture(arch, xs)
    #= none:156 =#
    ys = on_architecture(arch, ys)
    #= none:157 =#
    zs = on_architecture(arch, zs)
    #= none:159 =#
    #= none:159 =# CUDA.@allowscalar begin
            #= none:160 =#
            for f = (u, v, w, c)
                #= none:161 =#
                loc = Tuple((L() for L = location(f)))
                #= none:162 =#
                ℑf = interpolate_xyz.(xs, ys, zs, Ref(f.data), Ref(loc), Ref(f.grid))
                #= none:163 =#
                F = func.(xs, ys, zs)
                #= none:164 =#
                F = Array(F)
                #= none:165 =#
                ℑf = Array(ℑf)
                #= none:166 =#
                #= none:166 =# @test all(isapprox.(ℑf, F, atol = tolerance))
                #= none:172 =#
                fill_halo_regions!(f)
                #= none:174 =#
                f_copy = deepcopy(f)
                #= none:175 =#
                fill!(f_copy, 0)
                #= none:176 =#
                interpolate!(f_copy, f)
                #= none:178 =#
                #= none:178 =# @test all(interior(f_copy) .≈ interior(f))
                #= none:179 =#
            end
        end
    #= none:182 =#
    return nothing
end
#= none:189 =#
#= none:189 =# @testset "Fields" begin
        #= none:190 =#
        #= none:190 =# @info "Testing Fields..."
        #= none:192 =#
        #= none:192 =# @testset "Field initialization" begin
                #= none:193 =#
                #= none:193 =# @info "  Testing Field initialization..."
                #= none:195 =#
                N = (4, 6, 8)
                #= none:196 =#
                L = (2π, 3π, 5π)
                #= none:197 =#
                H = (1, 1, 1)
                #= none:199 =#
                for arch = archs, FT = float_types
                    #= none:200 =#
                    grid = RectilinearGrid(arch, FT, size = N, extent = L, halo = H, topology = (Periodic, Periodic, Periodic))
                    #= none:201 =#
                    #= none:201 =# @test correct_field_size(grid, (Center, Center, Center), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:202 =#
                    #= none:202 =# @test correct_field_size(grid, (Face, Center, Center), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:203 =#
                    #= none:203 =# @test correct_field_size(grid, (Center, Face, Center), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:204 =#
                    #= none:204 =# @test correct_field_size(grid, (Center, Center, Face), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:206 =#
                    grid = RectilinearGrid(arch, FT, size = N, extent = L, halo = H, topology = (Periodic, Periodic, Bounded))
                    #= none:207 =#
                    #= none:207 =# @test correct_field_size(grid, (Center, Center, Center), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:208 =#
                    #= none:208 =# @test correct_field_size(grid, (Face, Center, Center), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:209 =#
                    #= none:209 =# @test correct_field_size(grid, (Center, Face, Center), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:210 =#
                    #= none:210 =# @test correct_field_size(grid, (Center, Center, Face), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3] + 1)
                    #= none:212 =#
                    grid = RectilinearGrid(arch, FT, size = N, extent = L, halo = H, topology = (Periodic, Bounded, Bounded))
                    #= none:213 =#
                    #= none:213 =# @test correct_field_size(grid, (Center, Center, Center), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:214 =#
                    #= none:214 =# @test correct_field_size(grid, (Face, Center, Center), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:215 =#
                    #= none:215 =# @test correct_field_size(grid, (Center, Face, Center), N[1] + 2 * H[1], N[2] + 1 + 2 * H[2], N[3] + 2 * H[3])
                    #= none:216 =#
                    #= none:216 =# @test correct_field_size(grid, (Center, Center, Face), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 1 + 2 * H[3])
                    #= none:218 =#
                    grid = RectilinearGrid(arch, FT, size = N, extent = L, halo = H, topology = (Bounded, Bounded, Bounded))
                    #= none:219 =#
                    #= none:219 =# @test correct_field_size(grid, (Center, Center, Center), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:220 =#
                    #= none:220 =# @test correct_field_size(grid, (Face, Center, Center), N[1] + 1 + 2 * H[1], N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:221 =#
                    #= none:221 =# @test correct_field_size(grid, (Center, Face, Center), N[1] + 2 * H[1], N[2] + 1 + 2 * H[2], N[3] + 2 * H[3])
                    #= none:222 =#
                    #= none:222 =# @test correct_field_size(grid, (Center, Center, Face), N[1] + 2 * H[1], N[2] + 2 * H[2], N[3] + 1 + 2 * H[3])
                    #= none:225 =#
                    #= none:225 =# @test correct_field_size(grid, (Nothing, Center, Center), 1, N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:226 =#
                    #= none:226 =# @test correct_field_size(grid, (Nothing, Center, Center), 1, N[2] + 2 * H[2], N[3] + 2 * H[3])
                    #= none:227 =#
                    #= none:227 =# @test correct_field_size(grid, (Nothing, Face, Center), 1, N[2] + 2 * H[2] + 1, N[3] + 2 * H[3])
                    #= none:228 =#
                    #= none:228 =# @test correct_field_size(grid, (Nothing, Face, Face), 1, N[2] + 2 * H[2] + 1, N[3] + 2 * H[3] + 1)
                    #= none:229 =#
                    #= none:229 =# @test correct_field_size(grid, (Center, Nothing, Center), N[1] + 2 * H[1], 1, N[3] + 2 * H[3])
                    #= none:230 =#
                    #= none:230 =# @test correct_field_size(grid, (Center, Nothing, Center), N[1] + 2 * H[1], 1, N[3] + 2 * H[3])
                    #= none:231 =#
                    #= none:231 =# @test correct_field_size(grid, (Center, Center, Nothing), N[1] + 2 * H[1], N[2] + 2 * H[2], 1)
                    #= none:232 =#
                    #= none:232 =# @test correct_field_size(grid, (Nothing, Nothing, Center), 1, 1, N[3] + 2 * H[3])
                    #= none:233 =#
                    #= none:233 =# @test correct_field_size(grid, (Center, Nothing, Nothing), N[1] + 2 * H[1], 1, 1)
                    #= none:234 =#
                    #= none:234 =# @test correct_field_size(grid, (Nothing, Nothing, Nothing), 1, 1, 1)
                    #= none:237 =#
                    for f = [CenterField(grid), XFaceField(grid), YFaceField(grid), ZFaceField(grid)]
                        #= none:239 =#
                        test_indices = [(:, :, :), (1:2, 3:4, 5:6), (1, 1:6, :)]
                        #= none:240 =#
                        test_field_sizes = [size(f), (2, 2, 2), (1, 6, size(f, 3))]
                        #= none:241 =#
                        test_parent_sizes = [size(parent(f)), (2, 2, 2), (1, 6, size(parent(f), 3))]
                        #= none:243 =#
                        for (t, indices) = enumerate(test_indices)
                            #= none:244 =#
                            field_sz = test_field_sizes[t]
                            #= none:245 =#
                            parent_sz = test_parent_sizes[t]
                            #= none:246 =#
                            f_view = view(f, indices...)
                            #= none:247 =#
                            f_sliced = Field(f; indices)
                            #= none:248 =#
                            #= none:248 =# @test size(f_view) == field_sz
                            #= none:249 =#
                            #= none:249 =# @test size(parent(f_view)) == parent_sz
                            #= none:250 =#
                        end
                        #= none:251 =#
                    end
                    #= none:253 =#
                    grid = RectilinearGrid(arch, FT, size = N, extent = L, halo = H, topology = (Periodic, Periodic, Periodic))
                    #= none:254 =#
                    for side = (:east, :west, :north, :south, :top, :bottom)
                        #= none:255 =#
                        for wrong_bc = (ValueBoundaryCondition(0), FluxBoundaryCondition(0), GradientBoundaryCondition(0))
                            #= none:259 =#
                            wrong_kw = Dict(side => wrong_bc)
                            #= none:260 =#
                            wrong_bcs = FieldBoundaryConditions(grid, (Center, Center, Center); wrong_kw...)
                            #= none:261 =#
                            #= none:261 =# @test_throws ArgumentError CenterField(grid, boundary_conditions = wrong_bcs)
                            #= none:262 =#
                        end
                        #= none:263 =#
                    end
                    #= none:265 =#
                    grid = RectilinearGrid(arch, FT, size = N[2:3], extent = L[2:3], halo = H[2:3], topology = (Flat, Periodic, Periodic))
                    #= none:266 =#
                    for side = (:east, :west)
                        #= none:267 =#
                        for wrong_bc = (ValueBoundaryCondition(0), FluxBoundaryCondition(0), GradientBoundaryCondition(0))
                            #= none:271 =#
                            wrong_kw = Dict(side => wrong_bc)
                            #= none:272 =#
                            wrong_bcs = FieldBoundaryConditions(grid, (Center, Center, Center); wrong_kw...)
                            #= none:273 =#
                            #= none:273 =# @test_throws ArgumentError CenterField(grid, boundary_conditions = wrong_bcs)
                            #= none:274 =#
                        end
                        #= none:275 =#
                    end
                    #= none:277 =#
                    grid = RectilinearGrid(arch, FT, size = N, extent = L, halo = H, topology = (Periodic, Bounded, Bounded))
                    #= none:278 =#
                    for side = (:east, :west, :north, :south)
                        #= none:279 =#
                        for wrong_bc = (ValueBoundaryCondition(0), FluxBoundaryCondition(0), GradientBoundaryCondition(0))
                            #= none:283 =#
                            wrong_kw = Dict(side => wrong_bc)
                            #= none:284 =#
                            wrong_bcs = FieldBoundaryConditions(grid, (Center, Face, Face); wrong_kw...)
                            #= none:286 =#
                            #= none:286 =# @test_throws ArgumentError Field{Center, Face, Face}(grid, boundary_conditions = wrong_bcs)
                            #= none:287 =#
                        end
                        #= none:288 =#
                    end
                    #= none:290 =#
                    if arch isa GPU
                        #= none:291 =#
                        wrong_bcs = FieldBoundaryConditions(grid, (Center, Center, Center), top = FluxBoundaryCondition(zeros(FT, N[1], N[2])))
                        #= none:293 =#
                        #= none:293 =# @test_throws ArgumentError CenterField(grid, boundary_conditions = wrong_bcs)
                    end
                    #= none:295 =#
                end
            end
        #= none:298 =#
        #= none:298 =# @testset "Setting fields" begin
                #= none:299 =#
                #= none:299 =# @info "  Testing field setting..."
                #= none:301 =#
                FieldTypes = (CenterField, XFaceField, YFaceField, ZFaceField)
                #= none:303 =#
                N = (4, 6, 8)
                #= none:304 =#
                L = (2π, 3π, 5π)
                #= none:305 =#
                H = (1, 1, 1)
                #= none:307 =#
                int_vals = Any[0, Int8(-1), Int16(2), Int32(-3), Int64(4)]
                #= none:308 =#
                uint_vals = Any[6, UInt8(7), UInt16(8), UInt32(9), UInt64(10)]
                #= none:309 =#
                float_vals = Any[0.0, -0.0, 6.0e-34, 1.0f10]
                #= none:310 =#
                rational_vals = Any[1 // 11, -23 // 7]
                #= none:311 =#
                other_vals = Any[π]
                #= none:312 =#
                vals = vcat(int_vals, uint_vals, float_vals, rational_vals, other_vals)
                #= none:314 =#
                for arch = archs, FT = float_types
                    #= none:315 =#
                    ArrayType = array_type(arch)
                    #= none:316 =#
                    grid = RectilinearGrid(arch, FT, size = N, extent = L, topology = (Periodic, Periodic, Bounded))
                    #= none:318 =#
                    for FieldType = FieldTypes, val = vals
                        #= none:319 =#
                        #= none:319 =# @test correct_field_value_was_set(grid, FieldType, val)
                        #= none:320 =#
                    end
                    #= none:322 =#
                    for loc = ((Center, Center, Center), (Face, Center, Center), (Center, Face, Center), (Center, Center, Face), (Nothing, Center, Center), (Center, Nothing, Center), (Center, Center, Nothing), (Nothing, Nothing, Center), (Nothing, Nothing, Nothing))
                        #= none:332 =#
                        field = Field(loc, grid)
                        #= none:333 =#
                        sz = size(field)
                        #= none:334 =#
                        A = rand(FT, sz...)
                        #= none:335 =#
                        set!(field, A)
                        #= none:336 =#
                        #= none:336 =# @test #= none:336 =# CUDA.@allowscalar(field.data[1, 1, 1] == A[1, 1, 1])
                        #= none:337 =#
                    end
                    #= none:339 =#
                    Nx = 8
                    #= none:340 =#
                    topo = (Bounded, Bounded, Bounded)
                    #= none:341 =#
                    grid = RectilinearGrid(arch, FT, topology = topo, size = (Nx, Nx, Nx), x = (-1, 1), y = (0, 2π), z = (-1, 1))
                    #= none:343 =#
                    u = XFaceField(grid)
                    #= none:344 =#
                    v = YFaceField(grid)
                    #= none:345 =#
                    w = ZFaceField(grid)
                    #= none:346 =#
                    c = CenterField(grid)
                    #= none:348 =#
                    f(x, y, z) = begin
                            #= none:348 =#
                            exp(x) * sin(y) * tanh(z)
                        end
                    #= none:350 =#
                    ϕs = (u, v, w, c)
                    #= none:351 =#
                    [set!(ϕ, f) for ϕ = ϕs]
                    #= none:353 =#
                    (xu, yu, zu) = nodes(u)
                    #= none:354 =#
                    (xv, yv, zv) = nodes(v)
                    #= none:355 =#
                    (xw, yw, zw) = nodes(w)
                    #= none:356 =#
                    (xc, yc, zc) = nodes(c)
                    #= none:358 =#
                    #= none:358 =# @test #= none:358 =# CUDA.@allowscalar(u[1, 2, 3] ≈ f(xu[1], yu[2], zu[3]))
                    #= none:359 =#
                    #= none:359 =# @test #= none:359 =# CUDA.@allowscalar(v[1, 2, 3] ≈ f(xv[1], yv[2], zv[3]))
                    #= none:360 =#
                    #= none:360 =# @test #= none:360 =# CUDA.@allowscalar(w[1, 2, 3] ≈ f(xw[1], yw[2], zw[3]))
                    #= none:361 =#
                    #= none:361 =# @test #= none:361 =# CUDA.@allowscalar(c[1, 2, 3] ≈ f(xc[1], yc[2], zc[3]))
                    #= none:367 =#
                    big_halo = (3, 3, 3)
                    #= none:368 =#
                    small_halo = (1, 1, 1)
                    #= none:369 =#
                    domain = (; x = (0, 1), y = (0, 1), z = (0, 1))
                    #= none:370 =#
                    sz = (3, 3, 3)
                    #= none:372 =#
                    grid = RectilinearGrid(arch, FT; halo = big_halo, size = sz, domain...)
                    #= none:373 =#
                    a = CenterField(grid)
                    #= none:374 =#
                    b = CenterField(grid)
                    #= none:375 =#
                    parent(a) .= 1
                    #= none:376 =#
                    set!(b, a)
                    #= none:377 =#
                    #= none:377 =# @test parent(b) == parent(a)
                    #= none:379 =#
                    grid_with_smaller_halo = RectilinearGrid(arch, FT; halo = small_halo, size = sz, domain...)
                    #= none:380 =#
                    c = CenterField(grid_with_smaller_halo)
                    #= none:381 =#
                    set!(c, a)
                    #= none:382 =#
                    #= none:382 =# @test interior(c) == interior(a)
                    #= none:385 =#
                    if arch isa GPU
                        #= none:386 =#
                        cpu_grid = RectilinearGrid(CPU(), FT; halo = big_halo, size = sz, domain...)
                        #= none:387 =#
                        d = CenterField(cpu_grid)
                        #= none:388 =#
                        set!(d, a)
                        #= none:389 =#
                        #= none:389 =# @test parent(d) == Array(parent(a))
                        #= none:391 =#
                        cpu_grid_with_smaller_halo = RectilinearGrid(CPU(), FT; halo = small_halo, size = sz, domain...)
                        #= none:392 =#
                        e = CenterField(cpu_grid_with_smaller_halo)
                        #= none:393 =#
                        set!(e, a)
                        #= none:394 =#
                        #= none:394 =# @test Array(interior(e)) == Array(interior(a))
                    end
                    #= none:396 =#
                end
            end
        #= none:399 =#
        #= none:399 =# @testset "Field reductions" begin
                #= none:400 =#
                #= none:400 =# @info "  Testing field reductions..."
                #= none:402 =#
                for arch = archs, FT = float_types
                    #= none:403 =#
                    run_field_reduction_tests(FT, arch)
                    #= none:404 =#
                end
            end
        #= none:407 =#
        #= none:407 =# @testset "Field interpolation" begin
                #= none:408 =#
                #= none:408 =# @info "  Testing field interpolation..."
                #= none:410 =#
                for arch = archs, FT = float_types
                    #= none:411 =#
                    reg_grid = RectilinearGrid(arch, FT, size = (4, 5, 7), x = (0, 1), y = (-π, π), z = (-5.3, 2.7), halo = (1, 1, 1))
                    #= none:414 =#
                    stretched_grid = RectilinearGrid(arch, size = (4, 5, 7), halo = (1, 1, 1), x = [0.0, 0.26, 0.49, 0.78, 1.0], y = [-3.1, -1.9, -0.6, 0.6, 1.9, 3.1], z = [-5.3, -4.2, -3.0, -1.9, -0.7, 0.4, 1.6, 2.7])
                    #= none:421 =#
                    grids = [reg_grid, stretched_grid]
                    #= none:423 =#
                    for grid = grids
                        #= none:424 =#
                        run_field_interpolation_tests(grid)
                        #= none:425 =#
                    end
                    #= none:426 =#
                end
            end
        #= none:429 =#
        #= none:429 =# @testset "Field utils" begin
                #= none:430 =#
                #= none:430 =# @info "  Testing field utils..."
                #= none:432 =#
                #= none:432 =# @test has_velocities(()) == false
                #= none:433 =#
                #= none:433 =# @test has_velocities((:u,)) == false
                #= none:434 =#
                #= none:434 =# @test has_velocities((:u, :v)) == false
                #= none:435 =#
                #= none:435 =# @test has_velocities((:u, :v, :w)) == true
                #= none:437 =#
                #= none:437 =# @info "    Testing similar(f) for f::Union(Field, ReducedField)..."
                #= none:439 =#
                grid = RectilinearGrid(CPU(), size = (1, 1, 1), extent = (1, 1, 1))
                #= none:441 =#
                for X = (Center, Face), Y = (Center, Face), Z = (Center, Face)
                    #= none:442 =#
                    for arch = archs
                        #= none:443 =#
                        f = Field{X, Y, Z}(grid)
                        #= none:444 =#
                        run_similar_field_tests(f)
                        #= none:446 =#
                        for dims = (3, (1, 2), (1, 2, 3))
                            #= none:447 =#
                            loc = reduced_location((X, Y, Z); dims)
                            #= none:448 =#
                            f = Field(loc, grid)
                            #= none:449 =#
                            run_similar_field_tests(f)
                            #= none:450 =#
                        end
                        #= none:451 =#
                    end
                    #= none:452 =#
                end
            end
        #= none:455 =#
        #= none:455 =# @testset "Views of field views" begin
                #= none:456 =#
                #= none:456 =# @info "  Testing views of field views..."
                #= none:458 =#
                (Nx, Ny, Nz) = (1, 1, 7)
                #= none:460 =#
                FieldTypes = (CenterField, XFaceField, YFaceField, ZFaceField)
                #= none:461 =#
                ZTopologies = (Periodic, Bounded)
                #= none:463 =#
                for arch = archs, FT = float_types, FieldType = FieldTypes, ZTopology = ZTopologies
                    #= none:464 =#
                    grid = RectilinearGrid(arch, FT, size = (Nx, Ny, Nz), x = (0, 1), y = (0, 1), z = (0, 1), topology = (Periodic, Periodic, ZTopology))
                    #= none:465 =#
                    (Hx, Hy, Hz) = halo_size(grid)
                    #= none:467 =#
                    c = FieldType(grid)
                    #= none:468 =#
                    set!(c, ((x, y, z)->begin
                                #= none:468 =#
                                rand()
                            end))
                    #= none:470 =#
                    k_top = total_length((location(c, 3))(), (topology(c, 3))(), size(grid, 3))
                    #= none:473 =#
                    cv = view(c, :, :, 1 + 1:k_top - 1)
                    #= none:474 =#
                    #= none:474 =# @test size(cv) == (Nx, Ny, k_top - 2)
                    #= none:475 =#
                    #= none:475 =# @test size(parent(cv)) == (Nx + 2Hx, Ny + 2Hy, k_top - 2)
                    #= none:476 =#
                    #= none:476 =# CUDA.@allowscalar #= none:476 =# @test(all((cv[i, j, k] == c[i, j, k] for k = 1 + 1:k_top - 1, j = 1:Ny, i = 1:Nx)))
                    #= none:479 =#
                    cvv = view(cv, :, :, 1 + 2:k_top - 2)
                    #= none:480 =#
                    #= none:480 =# @test size(cvv) == (Nx, Ny, k_top - 4)
                    #= none:481 =#
                    #= none:481 =# @test size(parent(cvv)) == (Nx + 2Hx, Ny + 2Hy, k_top - 4)
                    #= none:482 =#
                    #= none:482 =# CUDA.@allowscalar #= none:482 =# @test(all((cvv[i, j, k] == cv[i, j, k] for k = 1 + 2:k_top - 2, j = 1:Ny, i = 1:Nx)))
                    #= none:484 =#
                    cvvv = view(cvv, :, :, 1 + 3:k_top - 3)
                    #= none:485 =#
                    #= none:485 =# @test size(cvvv) == (1, 1, k_top - 6)
                    #= none:486 =#
                    #= none:486 =# @test size(parent(cvvv)) == (Nx + 2Hx, Ny + 2Hy, k_top - 6)
                    #= none:487 =#
                    #= none:487 =# CUDA.@allowscalar #= none:487 =# @test(all((cvvv[i, j, k] == cvv[i, j, k] for k = 1 + 3:k_top - 3, j = 1:Ny, i = 1:Nx)))
                    #= none:489 =#
                    #= none:489 =# @test_throws ArgumentError view(cv, :, :, 1)
                    #= none:490 =#
                    #= none:490 =# @test_throws ArgumentError view(cv, :, :, k_top)
                    #= none:491 =#
                    #= none:491 =# @test_throws ArgumentError view(cvv, :, :, 1:1 + 1)
                    #= none:492 =#
                    #= none:492 =# @test_throws ArgumentError view(cvv, :, :, k_top - 1:k_top)
                    #= none:493 =#
                    #= none:493 =# @test_throws ArgumentError view(cvvv, :, :, 1:1 + 2)
                    #= none:494 =#
                    #= none:494 =# @test_throws ArgumentError view(cvvv, :, :, k_top - 2:k_top)
                    #= none:496 =#
                    #= none:496 =# @test_throws BoundsError cv[:, :, 1]
                    #= none:497 =#
                    #= none:497 =# @test_throws BoundsError cv[:, :, k_top]
                    #= none:498 =#
                    #= none:498 =# @test_throws BoundsError cvv[:, :, 1:1 + 1]
                    #= none:499 =#
                    #= none:499 =# @test_throws BoundsError cvv[:, :, k_top - 1:k_top]
                    #= none:500 =#
                    #= none:500 =# @test_throws BoundsError cvvv[:, :, 1:1 + 2]
                    #= none:501 =#
                    #= none:501 =# @test_throws BoundsError cvvv[:, :, k_top - 2:k_top]
                    #= none:502 =#
                end
            end
    end