
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
function compute_derivative(model, ∂)
    #= none:3 =#
    #= none:4 =#
    (T, S) = model.tracers
    #= none:5 =#
    parent(S) .= π
    #= none:6 =#
    #= none:6 =# @compute ∂S = Field(∂(S))
    #= none:7 =#
    result = Array(interior(∂S))
    #= none:8 =#
    return all(result .≈ zero(model.grid))
end
#= none:11 =#
function compute_unary(unary, model)
    #= none:11 =#
    #= none:12 =#
    set!(model; S = π)
    #= none:13 =#
    (T, S) = model.tracers
    #= none:14 =#
    #= none:14 =# @compute uS = Field(unary(S), data = model.pressures.pNHS.data)
    #= none:15 =#
    result = Array(interior(uS))
    #= none:16 =#
    return all(result .≈ unary((eltype(model.grid))(π)))
end
#= none:19 =#
function compute_plus(model)
    #= none:19 =#
    #= none:20 =#
    set!(model; S = π, T = 42)
    #= none:21 =#
    (T, S) = model.tracers
    #= none:22 =#
    #= none:22 =# @compute ST = Field(S + T, data = model.pressures.pNHS.data)
    #= none:23 =#
    result = Array(interior(ST))
    #= none:24 =#
    return all(result .≈ (eltype(model.grid))(π + 42))
end
#= none:27 =#
function compute_many_plus(model)
    #= none:27 =#
    #= none:28 =#
    set!(model; u = 2, S = π, T = 42)
    #= none:29 =#
    (T, S) = model.tracers
    #= none:30 =#
    (u, v, w) = model.velocities
    #= none:31 =#
    #= none:31 =# @compute uTS = Field(#= none:31 =# @at((Center, Center, Center), u + T + S))
    #= none:32 =#
    result = Array(interior(uTS))
    #= none:33 =#
    return all(result .≈ (eltype(model.grid))(2 + π + 42))
end
#= none:36 =#
function compute_minus(model)
    #= none:36 =#
    #= none:37 =#
    set!(model; S = π, T = 42)
    #= none:38 =#
    (T, S) = model.tracers
    #= none:39 =#
    #= none:39 =# @compute ST = Field(S - T, data = model.pressures.pNHS.data)
    #= none:40 =#
    result = Array(interior(ST))
    #= none:41 =#
    return all(result .≈ (eltype(model.grid))(π - 42))
end
#= none:44 =#
function compute_times(model)
    #= none:44 =#
    #= none:45 =#
    set!(model; S = π, T = 42)
    #= none:46 =#
    (T, S) = model.tracers
    #= none:47 =#
    #= none:47 =# @compute ST = Field(S * T, data = model.pressures.pNHS.data)
    #= none:48 =#
    result = Array(interior(ST))
    #= none:49 =#
    return all(result .≈ (eltype(model.grid))(π * 42))
end
#= none:52 =#
function compute_kinetic_energy(model)
    #= none:52 =#
    #= none:53 =#
    (u, v, w) = model.velocities
    #= none:54 =#
    set!(u, 1)
    #= none:55 =#
    set!(v, 2)
    #= none:56 =#
    set!(w, 3)
    #= none:58 =#
    kinetic_energy_operation = #= none:58 =# @at((Center, Center, Center), (u ^ 2 + v ^ 2 + w ^ 2) / 2)
    #= none:59 =#
    #= none:59 =# @compute kinetic_energy = Field(kinetic_energy_operation, data = model.pressures.pNHS.data)
    #= none:61 =#
    return all(interior(kinetic_energy, 2:3, 2:3, 2:3) .≈ 7)
end
#= none:64 =#
function horizontal_average_of_plus(model)
    #= none:64 =#
    #= none:65 =#
    (Ny, Nz) = (model.grid.Ny, model.grid.Nz)
    #= none:67 =#
    S₀(x, y, z) = begin
            #= none:67 =#
            sin(π * z)
        end
    #= none:68 =#
    T₀(x, y, z) = begin
            #= none:68 =#
            42z
        end
    #= none:69 =#
    set!(model; S = S₀, T = T₀)
    #= none:70 =#
    (T, S) = model.tracers
    #= none:72 =#
    #= none:72 =# @compute ST = Field(Average(S + T, dims = (1, 2)))
    #= none:74 =#
    #= none:74 =# @test ST.operand isa Reduction
    #= none:76 =#
    zC = znodes(model.grid, Center())
    #= none:77 =#
    correct_profile = #= none:77 =# @__dot__(sin(π * zC) + 42zC)
    #= none:78 =#
    computed_profile = Array(interior(ST, 1, 1, :))
    #= none:80 =#
    return all(computed_profile .≈ correct_profile)
end
#= none:83 =#
function zonal_average_of_plus(model)
    #= none:83 =#
    #= none:84 =#
    (Ny, Nz) = (model.grid.Ny, model.grid.Nz)
    #= none:86 =#
    S₀(x, y, z) = begin
            #= none:86 =#
            sin(π * z) * sin(π * y)
        end
    #= none:87 =#
    T₀(x, y, z) = begin
            #= none:87 =#
            42z + y ^ 2
        end
    #= none:88 =#
    set!(model; S = S₀, T = T₀)
    #= none:89 =#
    (T, S) = model.tracers
    #= none:91 =#
    #= none:91 =# @compute ST = Field(Average(S + T, dims = 1))
    #= none:93 =#
    (_, yC, zC) = nodes(model.grid, Center(), Center(), Center(); reshape = true)
    #= none:95 =#
    correct_slice = #= none:95 =# @__dot__(sin(π * zC) * sin(π * yC) + 42zC + yC ^ 2)
    #= none:96 =#
    computed_slice = Array(interior(ST, 1, :, :))
    #= none:98 =#
    return all(computed_slice .≈ view(correct_slice, 1, :, :))
end
#= none:101 =#
function volume_average_of_times(model)
    #= none:101 =#
    #= none:102 =#
    (Ny, Nz) = (model.grid.Ny, model.grid.Nz)
    #= none:104 =#
    S₀(x, y, z) = begin
            #= none:104 =#
            1 + sin((2π) * x)
        end
    #= none:105 =#
    T₀(x, y, z) = begin
            #= none:105 =#
            y
        end
    #= none:106 =#
    set!(model; S = S₀, T = T₀)
    #= none:107 =#
    (T, S) = model.tracers
    #= none:109 =#
    #= none:109 =# @compute ST = Field(Average(S * T, dims = (1, 2, 3)))
    #= none:110 =#
    result = #= none:110 =# CUDA.@allowscalar(ST[1, 1, 1])
    #= none:112 =#
    return result ≈ 0.5
end
#= none:115 =#
function horizontal_average_of_minus(model)
    #= none:115 =#
    #= none:116 =#
    (Ny, Nz) = (model.grid.Ny, model.grid.Nz)
    #= none:118 =#
    S₀(x, y, z) = begin
            #= none:118 =#
            sin(π * z)
        end
    #= none:119 =#
    T₀(x, y, z) = begin
            #= none:119 =#
            42z
        end
    #= none:120 =#
    set!(model; S = S₀, T = T₀)
    #= none:121 =#
    (T, S) = model.tracers
    #= none:123 =#
    #= none:123 =# @compute ST = Field(Average(S - T, dims = (1, 2)))
    #= none:125 =#
    zC = znodes(model.grid, Center())
    #= none:126 =#
    correct_profile = #= none:126 =# @__dot__(sin(π * zC) - 42zC)
    #= none:127 =#
    computed_profile = Array(interior(ST, 1, 1, 1:Nz))
    #= none:129 =#
    return all(computed_profile .≈ correct_profile)
end
#= none:132 =#
function horizontal_average_of_times(model)
    #= none:132 =#
    #= none:133 =#
    (Ny, Nz) = (model.grid.Ny, model.grid.Nz)
    #= none:135 =#
    S₀(x, y, z) = begin
            #= none:135 =#
            sin(π * z)
        end
    #= none:136 =#
    T₀(x, y, z) = begin
            #= none:136 =#
            42z
        end
    #= none:137 =#
    set!(model; S = S₀, T = T₀)
    #= none:138 =#
    (T, S) = model.tracers
    #= none:140 =#
    #= none:140 =# @compute ST = Field(Average(S * T, dims = (1, 2)))
    #= none:142 =#
    zC = znodes(model.grid, Center())
    #= none:143 =#
    correct_profile = #= none:143 =# @__dot__(sin(π * zC) * 42 * zC)
    #= none:144 =#
    computed_profile = Array(interior(ST, 1, 1, 1:Nz))
    #= none:146 =#
    return all(computed_profile .≈ correct_profile)
end
#= none:149 =#
function multiplication_and_derivative_ccf(model)
    #= none:149 =#
    #= none:150 =#
    (Ny, Nz) = (model.grid.Ny, model.grid.Nz)
    #= none:152 =#
    w₀(x, y, z) = begin
            #= none:152 =#
            sin(π * z)
        end
    #= none:153 =#
    T₀(x, y, z) = begin
            #= none:153 =#
            42z
        end
    #= none:154 =#
    set!(model; enforce_incompressibility = false, w = w₀, T = T₀)
    #= none:156 =#
    w = model.velocities.w
    #= none:157 =#
    T = model.tracers.T
    #= none:159 =#
    #= none:159 =# @compute wT = Field(Average(w * ∂z(T), dims = (1, 2)))
    #= none:161 =#
    zF = znodes(model.grid, Face())
    #= none:162 =#
    correct_profile = #= none:162 =# @__dot__(42 * sin(π * zF))
    #= none:163 =#
    computed_profile = Array(interior(wT, 1, 1, 1:Nz))
    #= none:166 =#
    return all(computed_profile[2:Nz] .≈ correct_profile[2:Nz])
end
#= none:169 =#
const C = Center
#= none:170 =#
const F = Face
#= none:172 =#
function multiplication_and_derivative_ccc(model)
    #= none:172 =#
    #= none:173 =#
    (Ny, Nz) = (model.grid.Ny, model.grid.Nz)
    #= none:175 =#
    w₀(x, y, z) = begin
            #= none:175 =#
            sin(π * z)
        end
    #= none:176 =#
    T₀(x, y, z) = begin
            #= none:176 =#
            42z
        end
    #= none:177 =#
    set!(model; enforce_incompressibility = false, w = w₀, T = T₀)
    #= none:179 =#
    w = model.velocities.w
    #= none:180 =#
    T = model.tracers.T
    #= none:182 =#
    wT_ccc = #= none:182 =# @at((C, C, C), w * ∂z(T))
    #= none:183 =#
    #= none:183 =# @compute wT_ccc_avg = Field(Average(wT_ccc, dims = (1, 2)))
    #= none:185 =#
    zF = znodes(model.grid, Face())
    #= none:186 =#
    sinusoid = sin.(π * zF)
    #= none:187 =#
    interped_sin = [(sinusoid[k] + sinusoid[k + 1]) / 2 for k = 1:model.grid.Nz]
    #= none:188 =#
    correct_profile = interped_sin .* 42
    #= none:190 =#
    result = Array(interior(wT_ccc_avg))
    #= none:193 =#
    return all(result[1, 1, 2:Nz - 1] .≈ correct_profile[2:Nz - 1])
end
#= none:196 =#
function computation_including_boundaries(arch)
    #= none:196 =#
    #= none:197 =#
    topo = (Periodic, Bounded, Bounded)
    #= none:198 =#
    grid = RectilinearGrid(arch, topology = topo, size = (13, 17, 19), extent = (1, 1, 1))
    #= none:199 =#
    model = NonhydrostaticModel(; grid)
    #= none:201 =#
    (u, v, w) = model.velocities
    #= none:202 =#
    parent(u) .= 1 + rand()
    #= none:203 =#
    parent(v) .= 2 + rand()
    #= none:204 =#
    parent(w) .= 3 + rand()
    #= none:206 =#
    op = #= none:206 =# @at((Center, Face, Face), u * v * w)
    #= none:207 =#
    #= none:207 =# @compute uvw = Field(op)
    #= none:209 =#
    return all(interior(uvw) .!= 0)
end
#= none:212 =#
function operations_with_computed_field(model)
    #= none:212 =#
    #= none:213 =#
    (u, v, w) = model.velocities
    #= none:214 =#
    uv = Field(u * v)
    #= none:215 =#
    #= none:215 =# @compute uvw = Field(uv * w)
    #= none:216 =#
    return true
end
#= none:219 =#
function operations_with_averaged_field(model)
    #= none:219 =#
    #= none:220 =#
    (u, v, w) = model.velocities
    #= none:221 =#
    UV = Field(Average(u * v, dims = (1, 2)))
    #= none:222 =#
    wUV = Field(w * UV)
    #= none:223 =#
    compute!(wUV)
    #= none:224 =#
    return true
end
#= none:227 =#
function computations_with_buoyancy_field(arch, buoyancy)
    #= none:227 =#
    #= none:228 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
    #= none:229 =#
    tracers = if buoyancy isa BuoyancyTracer
            :b
        else
            (:T, :S)
        end
    #= none:230 =#
    model = NonhydrostaticModel(grid = grid, tracers = tracers, buoyancy = buoyancy)
    #= none:233 =#
    b = BuoyancyField(model)
    #= none:234 =#
    (u, v, w) = model.velocities
    #= none:236 =#
    compute!(b)
    #= none:238 =#
    ub = Field(b * u)
    #= none:239 =#
    vb = Field(b * v)
    #= none:240 =#
    wb = Field(b * w)
    #= none:242 =#
    compute!(ub)
    #= none:243 =#
    compute!(vb)
    #= none:244 =#
    compute!(wb)
    #= none:246 =#
    return true
end
#= none:249 =#
function computations_with_averaged_fields(model)
    #= none:249 =#
    #= none:250 =#
    (u, v, w, T, S) = fields(model)
    #= none:252 =#
    set!(model, enforce_incompressibility = false, u = ((x, y, z)->begin
                    #= none:252 =#
                    z
                end), v = 2, w = 3)
    #= none:255 =#
    U = Field(Average(u, dims = (1, 2)))
    #= none:256 =#
    V = Field(Average(v, dims = (1, 2)))
    #= none:258 =#
    tke_op = #= none:258 =# @at((Center, Center, Center), ((u - U) ^ 2 + (v - V) ^ 2 + w ^ 2) / 2)
    #= none:259 =#
    tke = Field(tke_op)
    #= none:260 =#
    compute!(tke)
    #= none:262 =#
    return all(interior(tke, 2:3, 2:3, 2:3) .== 9 / 2)
end
#= none:265 =#
function computations_with_averaged_field_derivative(model)
    #= none:265 =#
    #= none:267 =#
    set!(model, enforce_incompressibility = false, u = ((x, y, z)->begin
                    #= none:267 =#
                    z
                end), v = 2, w = 3)
    #= none:269 =#
    (u, v, w, T, S) = fields(model)
    #= none:272 =#
    U = Field(Average(u, dims = (1, 2)))
    #= none:273 =#
    V = Field(Average(v, dims = (1, 2)))
    #= none:276 =#
    shear_production_op = #= none:276 =# @at((Center, Center, Center), u * w * ∂z(U))
    #= none:277 =#
    shear = Field(shear_production_op)
    #= none:278 =#
    compute!(shear)
    #= none:280 =#
    set!(model, T = ((x, y, z)->begin
                    #= none:280 =#
                    3z
                end))
    #= none:282 =#
    return all(interior(shear, 2:3, 2:3, 2:3) .== interior(T, 2:3, 2:3, 2:3))
end
#= none:285 =#
function computations_with_computed_fields(model)
    #= none:285 =#
    #= none:286 =#
    (u, v, w, T, S) = fields(model)
    #= none:288 =#
    set!(model, enforce_incompressibility = false, u = ((x, y, z)->begin
                    #= none:288 =#
                    z
                end), v = 2, w = 3)
    #= none:291 =#
    U = Field(Average(u, dims = (1, 2)))
    #= none:292 =#
    V = Field(Average(v, dims = (1, 2)))
    #= none:294 =#
    u′ = Field(u - U)
    #= none:295 =#
    v′ = Field(v - V)
    #= none:297 =#
    tke_op = #= none:297 =# @at((Center, Center, Center), (u′ ^ 2 + v′ ^ 2 + w ^ 2) / 2)
    #= none:298 =#
    tke = Field(tke_op)
    #= none:299 =#
    compute!(tke)
    #= none:301 =#
    return all(interior(tke, 2:3, 2:3, 2:3) .== 9 / 2)
end
#= none:304 =#
function compute_tuples_and_namedtuples(model)
    #= none:304 =#
    #= none:305 =#
    c = CenterField(model.grid)
    #= none:306 =#
    set!(c, 1)
    #= none:308 =#
    one_c = Field(1c)
    #= none:309 =#
    two_c = tuple(Field(2c))
    #= none:310 =#
    six_c = (; field = Field(6c))
    #= none:311 =#
    ten_c = (; field = Field(10c))
    #= none:313 =#
    compute!(one_c)
    #= none:314 =#
    compute!(two_c)
    #= none:315 =#
    compute!(six_c)
    #= none:317 =#
    at_ijk(i, j, k, grid, nt::NamedTuple) = begin
            #= none:317 =#
            nt.field[i, j, k]
        end
    #= none:318 =#
    ten_c_op = KernelFunctionOperation{Center, Center, Center}(at_ijk, model.grid, ten_c)
    #= none:319 =#
    ten_c_field = Field(ten_c_op)
    #= none:320 =#
    compute!(ten_c_field)
    #= none:322 =#
    return ((all(interior(one_c) .== 1) & all(interior(two_c[1]) .== 2)) & all(interior(six_c.field) .== 6)) & all(interior(ten_c.field) .== 10)
end
#= none:325 =#
for arch = archs
    #= none:326 =#
    A = typeof(arch)
    #= none:327 =#
    #= none:327 =# @testset "Computed Fields [$(A)]" begin
            #= none:328 =#
            #= none:328 =# @info "  Testing computed Fields [$(A)]..."
            #= none:330 =#
            gravitational_acceleration = 1
            #= none:331 =#
            equation_of_state = LinearEquationOfState(thermal_expansion = 1, haline_contraction = 1)
            #= none:332 =#
            buoyancy = SeawaterBuoyancy(; gravitational_acceleration, equation_of_state)
            #= none:334 =#
            underlying_grid = RectilinearGrid(arch, size = (4, 4, 4), extent = (1, 1, 1), topology = (Periodic, Periodic, Bounded))
            #= none:335 =#
            bottom(x, y) = begin
                    #= none:335 =#
                    -2
                end
            #= none:336 =#
            immersed_grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bottom))
            #= none:337 =#
            immersed_active_grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bottom); active_cells_map = true)
            #= none:339 =#
            for grid = (underlying_grid, immersed_grid, immersed_active_grid)
                #= none:340 =#
                G = (typeof(grid)).name.wrapper
                #= none:341 =#
                model = NonhydrostaticModel(; grid, buoyancy, tracers = (:T, :S))
                #= none:343 =#
                #= none:343 =# @testset "Instantiating and computing computed fields [$(A), $(G)]" begin
                        #= none:344 =#
                        #= none:344 =# @info "  Testing computed Field instantiation and computation [$(A), $(G)]..."
                        #= none:345 =#
                        c = CenterField(grid)
                        #= none:346 =#
                        c² = compute!(Field(c ^ 2))
                        #= none:347 =#
                        #= none:347 =# @test c² isa Field
                        #= none:350 =#
                        indices = [(:, :, :), (1, :, :), (:, :, grid.Nz), (2:4, 3, 5)]
                        #= none:351 =#
                        sizes = [(4, 4, 4), (1, 4, 4), (4, 4, 1), (3, 1, 1)]
                        #= none:352 =#
                        for (ii, sz) = zip(indices, sizes)
                            #= none:353 =#
                            c² = compute!(Field(c ^ 2; indices = ii))
                            #= none:354 =#
                            #= none:354 =# @test size(interior(c²)) === sz
                            #= none:355 =#
                        end
                    end
                #= none:358 =#
                #= none:358 =# @testset "Derivative computations [$(A), $(G)]" begin
                        #= none:359 =#
                        #= none:359 =# @info "      Testing correctness of compute! derivatives..."
                        #= none:360 =#
                        #= none:360 =# @test compute_derivative(model, ∂x)
                        #= none:361 =#
                        #= none:361 =# @test compute_derivative(model, ∂y)
                        #= none:362 =#
                        #= none:362 =# @test compute_derivative(model, ∂z)
                    end
                #= none:365 =#
                #= none:365 =# @testset "Unary computations [$(A), $(G)]" begin
                        #= none:366 =#
                        #= none:366 =# @info "      Testing correctness of compute! unary operations..."
                        #= none:367 =#
                        for unary = (sqrt, sin, cos, exp, tanh)
                            #= none:368 =#
                            #= none:368 =# @test compute_unary(unary, model)
                            #= none:369 =#
                        end
                    end
                #= none:372 =#
                #= none:372 =# @testset "Binary computations [$(A), $(G)]" begin
                        #= none:373 =#
                        #= none:373 =# @info "      Testing correctness of compute! binary operations..."
                        #= none:374 =#
                        #= none:374 =# @test compute_plus(model)
                        #= none:375 =#
                        #= none:375 =# @test compute_minus(model)
                        #= none:376 =#
                        #= none:376 =# @test compute_times(model)
                        #= none:379 =#
                        (u, v, w) = model.velocities
                        #= none:380 =#
                        #= none:380 =# @test try
                                #= none:380 =#
                                compute!(Field((u + v) - w))
                                #= none:380 =#
                                true
                            catch
                                #= none:380 =#
                                false
                            end
                    end
                #= none:383 =#
                #= none:383 =# @testset "Multiary computations [$(A), $(G)]" begin
                        #= none:384 =#
                        #= none:384 =# @info "      Testing correctness of compute! multiary operations..."
                        #= none:385 =#
                        #= none:385 =# @test compute_many_plus(model)
                        #= none:387 =#
                        #= none:387 =# @info "      Testing correctness of compute! kinetic energy..."
                        #= none:388 =#
                        #= none:388 =# @test compute_kinetic_energy(model)
                    end
                #= none:391 =#
                #= none:391 =# @testset "Computations with KernelFunctionOperation [$(A), $(G)]" begin
                        #= none:392 =#
                        #= none:392 =# @test begin
                                #= none:393 =#
                                #= none:393 =# @inline trivial_kernel_function(i, j, k, grid) = begin
                                            #= none:393 =#
                                            1
                                        end
                                #= none:394 =#
                                op = KernelFunctionOperation{Center, Center, Center}(trivial_kernel_function, grid)
                                #= none:395 =#
                                f = Field(op)
                                #= none:396 =#
                                compute!(f)
                                #= none:397 =#
                                f isa Field && f.operand === op
                            end
                        #= none:400 =#
                        #= none:400 =# @test begin
                                #= none:401 =#
                                #= none:401 =# @inline trivial_parameterized_kernel_function(i, j, k, grid, μ) = begin
                                            #= none:401 =#
                                            μ
                                        end
                                #= none:402 =#
                                op = KernelFunctionOperation{Center, Center, Center}(trivial_parameterized_kernel_function, grid, 0.1)
                                #= none:403 =#
                                f = Field(op)
                                #= none:404 =#
                                compute!(f)
                                #= none:405 =#
                                f isa Field && f.operand === op
                            end
                        #= none:408 =#
                        #= none:408 =# @test begin
                                #= none:409 =#
                                #= none:409 =# @inline auxiliary_fields_kernel_function(i, j, k, grid, auxiliary_fields) = begin
                                            #= none:409 =#
                                            1.0
                                        end
                                #= none:410 =#
                                op = KernelFunctionOperation{Center, Center, Center}(auxiliary_fields_kernel_function, grid, model.auxiliary_fields)
                                #= none:412 =#
                                f = Field(op)
                                #= none:413 =#
                                compute!(f)
                                #= none:414 =#
                                f isa Field && f.operand === op
                            end
                        #= none:417 =#
                        ϵ(x, y, z) = begin
                                #= none:417 =#
                                2 * rand() - 1
                            end
                        #= none:418 =#
                        set!(model, u = ϵ, v = ϵ)
                        #= none:419 =#
                        (u, v, w) = model.velocities
                        #= none:420 =#
                        ζ_op = KernelFunctionOperation{Face, Face, Center}(ζ₃ᶠᶠᶜ, grid, u, v)
                        #= none:422 =#
                        ζ = Field(ζ_op)
                        #= none:423 =#
                        compute!(ζ)
                        #= none:424 =#
                        #= none:424 =# @test ζ isa Field && ζ.operand.kernel_function === ζ₃ᶠᶠᶜ
                        #= none:426 =#
                        ζxy = Field(ζ_op, indices = (:, :, 1))
                        #= none:427 =#
                        compute!(ζxy)
                        #= none:428 =#
                        #= none:428 =# @test all(interior(ζxy, :, :, 1) .== interior(ζ, :, :, 1))
                        #= none:430 =#
                        ζxz = Field(ζ_op, indices = (:, 1, :))
                        #= none:431 =#
                        compute!(ζxz)
                        #= none:432 =#
                        #= none:432 =# @test all(interior(ζxz, :, 1, :) .== interior(ζ, :, 1, :))
                        #= none:434 =#
                        ζyz = Field(ζ_op, indices = (1, :, :))
                        #= none:435 =#
                        compute!(ζyz)
                        #= none:436 =#
                        #= none:436 =# @test all(interior(ζyz, 1, :, :) .== interior(ζ, 1, :, :))
                    end
                #= none:439 =#
                #= none:439 =# @testset "Operations with computed Fields [$(A), $(G)]" begin
                        #= none:440 =#
                        #= none:440 =# @info "      Testing operations with computed Fields..."
                        #= none:441 =#
                        #= none:441 =# @test operations_with_computed_field(model)
                    end
                #= none:444 =#
                #= none:444 =# @testset "Horizontal averages of operations [$(A), $(G)]" begin
                        #= none:445 =#
                        #= none:445 =# @info "      Testing horizontal averages..."
                        #= none:446 =#
                        #= none:446 =# @test horizontal_average_of_plus(model)
                        #= none:447 =#
                        #= none:447 =# @test horizontal_average_of_minus(model)
                        #= none:448 =#
                        #= none:448 =# @test horizontal_average_of_times(model)
                        #= none:450 =#
                        #= none:450 =# @test multiplication_and_derivative_ccf(model)
                        #= none:451 =#
                        #= none:451 =# @test multiplication_and_derivative_ccc(model)
                    end
                #= none:454 =#
                #= none:454 =# @testset "Zonal averages of operations [$(A), $(G)]" begin
                        #= none:455 =#
                        #= none:455 =# @info "      Testing zonal averages..."
                        #= none:456 =#
                        #= none:456 =# @test zonal_average_of_plus(model)
                    end
                #= none:459 =#
                #= none:459 =# @testset "Volume averages of operations [$(A), $(G)]" begin
                        #= none:460 =#
                        #= none:460 =# @info "      Testing volume averages..."
                        #= none:461 =#
                        #= none:461 =# @test volume_average_of_times(model)
                    end
                #= none:464 =#
                #= none:464 =# @testset "Field boundary conditions [$(A), $(G)]" begin
                        #= none:465 =#
                        #= none:465 =# @info "      Testing boundary conditions for Field..."
                        #= none:467 =#
                        set!(model; S = π, T = 42)
                        #= none:468 =#
                        (T, S) = model.tracers
                        #= none:470 =#
                        #= none:470 =# @compute ST = Field(S + T, data = model.pressures.pNHS.data)
                        #= none:472 =#
                        (Nx, Ny, Nz) = size(model.grid)
                        #= none:473 =#
                        (Hx, Hy, Hz) = halo_size(model.grid)
                        #= none:476 =#
                        ii = 1 + Hx:Nx + Hx
                        #= none:477 =#
                        jj = 1 + Hy:Ny + Hy
                        #= none:478 =#
                        kk = 1 + Hz:Nz + Hz
                        #= none:479 =#
                        #= none:479 =# @test all(view(parent(ST), Hx, jj, kk) .== view(parent(ST), Nx + 1 + Hx, jj, kk))
                        #= none:480 =#
                        #= none:480 =# @test all(view(parent(ST), ii, Hy, kk) .== view(parent(ST), ii, Ny + 1 + Hy, kk))
                        #= none:483 =#
                        #= none:483 =# @test all(view(parent(ST), ii, jj, Hz) .== view(parent(ST), ii, jj, 1 + Hz))
                        #= none:484 =#
                        #= none:484 =# @test all(view(parent(ST), ii, jj, Nz + Hz) .== view(parent(ST), ii, jj, Nz + 1 + Hz))
                        #= none:486 =#
                        #= none:486 =# @compute ST_face = Field(#= none:486 =# @at((Center, Center, Face), S * T))
                        #= none:489 =#
                        #= none:489 =# @test all(view(parent(ST_face), ii, jj, Hz) .== 0)
                        #= none:490 =#
                        #= none:490 =# @test all(view(parent(ST_face), ii, jj, Nz + 2 + Hz) .== 0)
                    end
                #= none:493 =#
                #= none:493 =# @testset "Operations with Averaged Field [$(A), $(G)]" begin
                        #= none:494 =#
                        #= none:494 =# @info "      Testing operations with Averaged Field..."
                        #= none:496 =#
                        (T, S) = model.tracers
                        #= none:497 =#
                        TS = Field(Average(T * S, dims = (1, 2)))
                        #= none:498 =#
                        #= none:498 =# @test operations_with_averaged_field(model)
                    end
                #= none:501 =#
                #= none:501 =# @testset "Compute! on faces along bounded dimensions" begin
                        #= none:502 =#
                        #= none:502 =# @info "      Testing compute! on faces along bounded dimensions..."
                        #= none:503 =#
                        #= none:503 =# @test computation_including_boundaries(arch)
                    end
                #= none:506 =#
                EquationsOfState = (LinearEquationOfState, SeawaterPolynomials.RoquetEquationOfState, SeawaterPolynomials.TEOS10EquationOfState)
                #= none:509 =#
                buoyancies = (BuoyancyTracer(), SeawaterBuoyancy(), (SeawaterBuoyancy(equation_of_state = eos()) for eos = EquationsOfState)...)
                #= none:512 =#
                for buoyancy = buoyancies
                    #= none:513 =#
                    #= none:513 =# @testset "Computations with BuoyancyFields [$(A), $(G), $((typeof(buoyancy)).name.wrapper)]" begin
                            #= none:514 =#
                            #= none:514 =# @info "      Testing computations with BuoyancyField " * "[$(A), $(G), $((typeof(buoyancy)).name.wrapper)]..."
                            #= none:517 =#
                            #= none:517 =# @test computations_with_buoyancy_field(arch, buoyancy)
                        end
                    #= none:519 =#
                end
                #= none:521 =#
                #= none:521 =# @testset "Computations with Averaged Fields [$(A), $(G)]" begin
                        #= none:522 =#
                        #= none:522 =# @info "      Testing computations with Averaged Field [$(A), $(G)]..."
                        #= none:524 =#
                        #= none:524 =# @test computations_with_averaged_field_derivative(model)
                        #= none:526 =#
                        (u, v, w) = model.velocities
                        #= none:528 =#
                        set!(model, enforce_incompressibility = false, u = ((x, y, z)->begin
                                        #= none:528 =#
                                        z
                                    end), v = 2, w = 3)
                        #= none:531 =#
                        U = Field(Average(u, dims = (1, 2)))
                        #= none:532 =#
                        V = Field(Average(v, dims = (1, 2)))
                        #= none:535 =#
                        u_prime = u - U
                        #= none:536 =#
                        u_prime_ccc = #= none:536 =# @at((Center, Center, Center), u - U)
                        #= none:537 =#
                        u_prime_squared = (u - U) ^ 2
                        #= none:538 =#
                        u_prime_squared_ccc = #= none:538 =# @at((Center, Center, Center), (u - U) ^ 2)
                        #= none:539 =#
                        horizontal_twice_tke = (u - U) ^ 2 + (v - V) ^ 2
                        #= none:540 =#
                        horizontal_tke = ((u - U) ^ 2 + (v - V) ^ 2) / 2
                        #= none:541 =#
                        horizontal_tke_ccc = #= none:541 =# @at((Center, Center, Center), ((u - U) ^ 2 + (v - V) ^ 2) / 2)
                        #= none:542 =#
                        twice_tke = (u - U) ^ 2 + (v - V) ^ 2 + w ^ 2
                        #= none:543 =#
                        tke = ((u - U) ^ 2 + (v - V) ^ 2 + w ^ 2) / 2
                        #= none:544 =#
                        tke_ccc = #= none:544 =# @at((Center, Center, Center), ((u - U) ^ 2 + (v - V) ^ 2 + w ^ 2) / 2)
                        #= none:546 =#
                        compute!(Field(u_prime))
                        #= none:547 =#
                        compute!(Field(u_prime_ccc))
                        #= none:548 =#
                        compute!(Field(u_prime_squared))
                        #= none:549 =#
                        compute!(Field(u_prime_squared_ccc))
                        #= none:550 =#
                        compute!(Field(horizontal_twice_tke))
                        #= none:551 =#
                        compute!(Field(horizontal_tke))
                        #= none:552 =#
                        compute!(Field(twice_tke))
                        #= none:553 =#
                        compute!(Field(horizontal_tke_ccc))
                        #= none:555 =#
                        computed_tke = Field(tke_ccc)
                        #= none:557 =#
                        tke_window = Field(tke_ccc, indices = (2:3, 2:3, 2:3))
                        #= none:558 =#
                        if (grid isa ImmersedBoundaryGrid) & (arch == GPU())
                            #= none:559 =#
                            #= none:559 =# @test_broken try
                                    #= none:559 =#
                                    compute!(computed_tke)
                                    #= none:559 =#
                                    true
                                catch
                                    #= none:559 =#
                                    false
                                end
                            #= none:560 =#
                            #= none:560 =# @test_broken try
                                    #= none:560 =#
                                    compute!(Field(tke))
                                    #= none:560 =#
                                    true
                                catch
                                    #= none:560 =#
                                    false
                                end
                            #= none:561 =#
                            #= none:561 =# @test_broken try
                                    #= none:561 =#
                                    compute!(tke_window)
                                    #= none:561 =#
                                    true
                                catch
                                    #= none:561 =#
                                    false
                                end
                            #= none:562 =#
                            #= none:562 =# @test_broken all(interior(computed_tke, 2:3, 2:3, 2:3) .== 9 / 2)
                            #= none:563 =#
                            #= none:563 =# @test_broken all(interior(tke_window) .== 9 / 2)
                        else
                            #= none:565 =#
                            #= none:565 =# @test try
                                    #= none:565 =#
                                    compute!(computed_tke)
                                    #= none:565 =#
                                    true
                                catch
                                    #= none:565 =#
                                    false
                                end
                            #= none:566 =#
                            #= none:566 =# @test try
                                    #= none:566 =#
                                    compute!(Field(tke))
                                    #= none:566 =#
                                    true
                                catch
                                    #= none:566 =#
                                    false
                                end
                            #= none:567 =#
                            #= none:567 =# @test try
                                    #= none:567 =#
                                    compute!(tke_window)
                                    #= none:567 =#
                                    true
                                catch
                                    #= none:567 =#
                                    false
                                end
                            #= none:568 =#
                            #= none:568 =# @test all(interior(computed_tke, 2:3, 2:3, 2:3) .== 9 / 2)
                            #= none:569 =#
                            #= none:569 =# @test all(interior(tke_window) .== 9 / 2)
                        end
                        #= none:573 =#
                        tke_xy = Field(tke_ccc, indices = (:, :, 2))
                        #= none:574 =#
                        tke_xz = Field(tke_ccc, indices = (2:3, 2, 2:3))
                        #= none:575 =#
                        tke_yz = Field(tke_ccc, indices = (2, 2:3, 2:3))
                        #= none:576 =#
                        tke_x = Field(tke_ccc, indices = (2:3, 2, 2))
                        #= none:578 =#
                        if (grid isa ImmersedBoundaryGrid) & (arch == GPU())
                            #= none:579 =#
                            #= none:579 =# @test_broken try
                                    #= none:579 =#
                                    compute!(tke_xy)
                                    #= none:579 =#
                                    true
                                catch
                                    #= none:579 =#
                                    false
                                end
                            #= none:580 =#
                            #= none:580 =# @test_broken all(interior(tke_xy, 2:3, 2:3, 1) .== 9 / 2)
                            #= none:582 =#
                            #= none:582 =# @test_broken try
                                    #= none:582 =#
                                    compute!(tke_xz)
                                    #= none:582 =#
                                    true
                                catch
                                    #= none:582 =#
                                    false
                                end
                            #= none:583 =#
                            #= none:583 =# @test_broken all(interior(tke_xz) .== 9 / 2)
                            #= none:585 =#
                            #= none:585 =# @test_broken try
                                    #= none:585 =#
                                    compute!(tke_yz)
                                    #= none:585 =#
                                    true
                                catch
                                    #= none:585 =#
                                    false
                                end
                            #= none:586 =#
                            #= none:586 =# @test_broken all(interior(tke_yz) .== 9 / 2)
                            #= none:588 =#
                            #= none:588 =# @test_broken try
                                    #= none:588 =#
                                    compute!(tke_x)
                                    #= none:588 =#
                                    true
                                catch
                                    #= none:588 =#
                                    false
                                end
                            #= none:589 =#
                            #= none:589 =# @test_broken all(interior(tke_x) .== 9 / 2)
                        else
                            #= none:591 =#
                            #= none:591 =# @test try
                                    #= none:591 =#
                                    compute!(tke_xy)
                                    #= none:591 =#
                                    true
                                catch
                                    #= none:591 =#
                                    false
                                end
                            #= none:592 =#
                            #= none:592 =# @test all(interior(tke_xy, 2:3, 2:3, 1) .== 9 / 2)
                            #= none:594 =#
                            #= none:594 =# @test try
                                    #= none:594 =#
                                    compute!(tke_xz)
                                    #= none:594 =#
                                    true
                                catch
                                    #= none:594 =#
                                    false
                                end
                            #= none:595 =#
                            #= none:595 =# @test all(interior(tke_xz) .== 9 / 2)
                            #= none:597 =#
                            #= none:597 =# @test try
                                    #= none:597 =#
                                    compute!(tke_yz)
                                    #= none:597 =#
                                    true
                                catch
                                    #= none:597 =#
                                    false
                                end
                            #= none:598 =#
                            #= none:598 =# @test all(interior(tke_yz) .== 9 / 2)
                            #= none:600 =#
                            #= none:600 =# @test try
                                    #= none:600 =#
                                    compute!(tke_x)
                                    #= none:600 =#
                                    true
                                catch
                                    #= none:600 =#
                                    false
                                end
                            #= none:601 =#
                            #= none:601 =# @test all(interior(tke_x) .== 9 / 2)
                        end
                    end
                #= none:605 =#
                #= none:605 =# @testset "Computations with Fields [$(A), $(G)]" begin
                        #= none:606 =#
                        #= none:606 =# @info "      Testing computations with Field [$(A), $(G)]..."
                        #= none:607 =#
                        #= none:607 =# @test computations_with_computed_fields(model)
                        #= none:609 =#
                        #= none:609 =# @info "      Testing computations of Tuples and NamedTuples"
                        #= none:610 =#
                        #= none:610 =# @test compute_tuples_and_namedtuples(model)
                    end
                #= none:613 =#
                #= none:613 =# @testset "Conditional computation of Field and BuoyancyField [$(A), $(G)]" begin
                        #= none:614 =#
                        #= none:614 =# @info "      Testing conditional computation of Field and BuoyancyField " * "[$(A), $(G)]..."
                        #= none:617 =#
                        set!(model, u = 2, v = 0, w = 0, T = 3, S = 0)
                        #= none:618 =#
                        (u, v, w, T, S) = fields(model)
                        #= none:620 =#
                        uT = Field(u * T)
                        #= none:622 =#
                        α = model.buoyancy.model.equation_of_state.thermal_expansion
                        #= none:623 =#
                        g = model.buoyancy.model.gravitational_acceleration
                        #= none:624 =#
                        b = BuoyancyField(model)
                        #= none:626 =#
                        compute_at!(uT, 1.0)
                        #= none:627 =#
                        compute_at!(b, 1.0)
                        #= none:628 =#
                        #= none:628 =# @test all(interior(uT) .== 6)
                        #= none:629 =#
                        #= none:629 =# @test all(interior(b) .== g * α * 3)
                        #= none:631 =#
                        set!(model, u = 2, T = 4)
                        #= none:632 =#
                        compute_at!(uT, 1.0)
                        #= none:633 =#
                        compute_at!(b, 1.0)
                        #= none:634 =#
                        #= none:634 =# @test all(interior(uT) .== 6)
                        #= none:635 =#
                        #= none:635 =# @test all(interior(b) .== g * α * 3)
                        #= none:637 =#
                        compute_at!(uT, 2.0)
                        #= none:638 =#
                        compute_at!(b, 2.0)
                        #= none:639 =#
                        #= none:639 =# @test all(interior(uT) .== 8)
                        #= none:640 =#
                        #= none:640 =# @test all(interior(b) .== g * α * 4)
                    end
                #= none:642 =#
            end
        end
    #= none:644 =#
end