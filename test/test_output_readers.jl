
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Utils: Time
#= none:4 =#
using Oceananigans.Fields: indices, interpolate!
#= none:5 =#
using Oceananigans.OutputReaders: Cyclical, Clamp
#= none:7 =#
function generate_some_interesting_simulation_data(Nx, Ny, Nz; architecture = CPU())
    #= none:7 =#
    #= none:8 =#
    grid = RectilinearGrid(architecture, size = (Nx, Ny, Nz), extent = (64, 64, 32))
    #= none:10 =#
    T_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(5.0e-5), bottom = GradientBoundaryCondition(0.01))
    #= none:11 =#
    u_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(-0.0003))
    #= none:13 =#
    #= none:13 =# @inline Qˢ(x, y, t, S, evaporation_rate) = begin
                #= none:13 =#
                -evaporation_rate * S
            end
    #= none:14 =#
    evaporation_bc = FluxBoundaryCondition(Qˢ, field_dependencies = :S, parameters = 3.0e-7)
    #= none:15 =#
    S_bcs = FieldBoundaryConditions(top = evaporation_bc)
    #= none:17 =#
    model = NonhydrostaticModel(; grid, tracers = (:T, :S), buoyancy = SeawaterBuoyancy(), boundary_conditions = (u = u_bcs, T = T_bcs, S = S_bcs))
    #= none:20 =#
    dTdz = 0.01
    #= none:21 =#
    Tᵢ(x, y, z) = begin
            #= none:21 =#
            20 + dTdz * z + 1.0e-6 * randn()
        end
    #= none:22 =#
    uᵢ(x, y, z) = begin
            #= none:22 =#
            0.001 * randn()
        end
    #= none:23 =#
    set!(model, u = uᵢ, w = uᵢ, T = Tᵢ, S = 35)
    #= none:25 =#
    simulation = Simulation(model, Δt = 10.0, stop_time = 2minutes)
    #= none:26 =#
    wizard = TimeStepWizard(cfl = 1.0, max_change = 1.1, max_Δt = 1minute)
    #= none:27 =#
    simulation.callbacks[:wizard] = Callback(wizard)
    #= none:29 =#
    (u, v, w) = model.velocities
    #= none:31 =#
    computed_fields = (b = BuoyancyField(model), ζ = Field(∂x(v) - ∂y(u)), ke = Field(√(u ^ 2 + v ^ 2)))
    #= none:37 =#
    fields_to_output = merge(model.velocities, model.tracers, computed_fields)
    #= none:39 =#
    filepath3d = "test_3d_output_with_halos.jld2"
    #= none:40 =#
    filepath2d = "test_2d_output_with_halos.jld2"
    #= none:41 =#
    filepath1d = "test_1d_output_with_halos.jld2"
    #= none:43 =#
    simulation.output_writers[:jld2_3d_with_halos] = JLD2OutputWriter(model, fields_to_output, filename = filepath3d, with_halos = true, schedule = TimeInterval(30seconds), overwrite_existing = true)
    #= none:50 =#
    simulation.output_writers[:jld2_2d_with_halos] = JLD2OutputWriter(model, fields_to_output, filename = filepath2d, indices = (:, :, grid.Nz), with_halos = true, schedule = TimeInterval(30seconds), overwrite_existing = true)
    #= none:58 =#
    profiles = NamedTuple{keys(fields_to_output)}((Field(Average(f, dims = (1, 2))) for f = fields_to_output))
    #= none:60 =#
    simulation.output_writers[:jld2_1d_with_halos] = JLD2OutputWriter(model, profiles, filename = filepath1d, with_halos = true, schedule = TimeInterval(30seconds), overwrite_existing = true)
    #= none:67 =#
    run!(simulation)
    #= none:69 =#
    return (filepath1d, filepath2d, filepath3d)
end
#= none:72 =#
#= none:72 =# @testset "OutputReaders" begin
        #= none:73 =#
        #= none:73 =# @info "Testing output readers..."
        #= none:75 =#
        Nt = 5
        #= none:76 =#
        (Nx, Ny, Nz) = (16, 10, 5)
        #= none:77 =#
        (filepath1d, filepath2d, filepath3d) = generate_some_interesting_simulation_data(Nx, Ny, Nz)
        #= none:79 =#
        for arch = archs
            #= none:80 =#
            #= none:80 =# @testset "FieldTimeSeries{InMemory} [$(typeof(arch))]" begin
                    #= none:81 =#
                    #= none:81 =# @info "  Testing FieldTimeSeries{InMemory} [$(typeof(arch))]..."
                    #= none:84 =#
                    u3 = FieldTimeSeries(filepath3d, "u", architecture = arch)
                    #= none:85 =#
                    v3 = FieldTimeSeries(filepath3d, "v", architecture = arch)
                    #= none:86 =#
                    w3 = FieldTimeSeries(filepath3d, "w", architecture = arch)
                    #= none:87 =#
                    T3 = FieldTimeSeries(filepath3d, "T", architecture = arch)
                    #= none:88 =#
                    b3 = FieldTimeSeries(filepath3d, "b", architecture = arch)
                    #= none:89 =#
                    ζ3 = FieldTimeSeries(filepath3d, "ζ", architecture = arch)
                    #= none:93 =#
                    #= none:93 =# @test size(parent(u3[1])) == (size(parent(u3)))[1:3]
                    #= none:94 =#
                    #= none:94 =# @test size(parent(v3[1])) == (size(parent(v3)))[1:3]
                    #= none:95 =#
                    #= none:95 =# @test size(parent(w3[1])) == (size(parent(w3)))[1:3]
                    #= none:96 =#
                    #= none:96 =# @test size(parent(T3[1])) == (size(parent(T3)))[1:3]
                    #= none:97 =#
                    #= none:97 =# @test size(parent(b3[1])) == (size(parent(b3)))[1:3]
                    #= none:98 =#
                    #= none:98 =# @test size(parent(ζ3[1])) == (size(parent(ζ3)))[1:3]
                    #= none:100 =#
                    #= none:100 =# @test location(u3) == (Face, Center, Center)
                    #= none:101 =#
                    #= none:101 =# @test location(v3) == (Center, Face, Center)
                    #= none:102 =#
                    #= none:102 =# @test location(w3) == (Center, Center, Face)
                    #= none:103 =#
                    #= none:103 =# @test location(T3) == (Center, Center, Center)
                    #= none:104 =#
                    #= none:104 =# @test location(b3) == (Center, Center, Center)
                    #= none:105 =#
                    #= none:105 =# @test location(ζ3) == (Face, Face, Center)
                    #= none:107 =#
                    #= none:107 =# @test size(u3) == (Nx, Ny, Nz, Nt)
                    #= none:108 =#
                    #= none:108 =# @test size(v3) == (Nx, Ny, Nz, Nt)
                    #= none:109 =#
                    #= none:109 =# @test size(w3) == (Nx, Ny, Nz + 1, Nt)
                    #= none:110 =#
                    #= none:110 =# @test size(T3) == (Nx, Ny, Nz, Nt)
                    #= none:111 =#
                    #= none:111 =# @test size(b3) == (Nx, Ny, Nz, Nt)
                    #= none:112 =#
                    #= none:112 =# @test size(ζ3) == (Nx, Ny, Nz, Nt)
                    #= none:114 =#
                    ArrayType = array_type(arch)
                    #= none:115 =#
                    for fts = (u3, v3, w3, T3, b3, ζ3)
                        #= none:116 =#
                        #= none:116 =# @test parent(fts) isa ArrayType
                        #= none:117 =#
                        #= none:117 =# @test (fts.times isa StepRangeLen) | (fts.times isa ArrayType)
                        #= none:118 =#
                    end
                    #= none:120 =#
                    if arch isa CPU
                        #= none:121 =#
                        #= none:121 =# @test u3[1, 2, 3, 4] isa Number
                        #= none:122 =#
                        #= none:122 =# @test u3[1] isa Field
                        #= none:123 =#
                        #= none:123 =# @test v3[2] isa Field
                    end
                    #= none:127 =#
                    u3i = FieldTimeSeries{Face, Center, Center}(u3.grid, u3.times)
                    #= none:128 =#
                    interpolate!(u3i, u3)
                    #= none:129 =#
                    #= none:129 =# @test all(interior(u3i) .≈ interior(u3))
                    #= none:132 =#
                    grid3 = RectilinearGrid(arch, size = (3, 3, 3), x = (0.5, 3.5), y = (0.5, 3.5), z = (0.5, 3.5), topology = (Periodic, Periodic, Bounded))
                    #= none:135 =#
                    grid1 = RectilinearGrid(arch, size = 3, x = 1.3, y = 2.7, z = (0.5, 3.5), topology = (Flat, Flat, Bounded))
                    #= none:138 =#
                    times = [1, 2]
                    #= none:139 =#
                    c3 = FieldTimeSeries{Center, Center, Center}(grid3, times)
                    #= none:140 =#
                    c1 = FieldTimeSeries{Center, Center, Center}(grid1, times)
                    #= none:142 =#
                    for n = 1:length(times)
                        #= none:143 =#
                        tn = times[n]
                        #= none:144 =#
                        c₀(x, y, z) = begin
                                #= none:144 =#
                                (x + y + z) * tn
                            end
                        #= none:145 =#
                        set!(c3[n], c₀)
                        #= none:146 =#
                    end
                    #= none:148 =#
                    interpolate!(c1, c3)
                    #= none:151 =#
                    c11 = interior(c1[1], 1, 1, :) |> Array
                    #= none:152 =#
                    c12 = interior(c1[2], 1, 1, :) |> Array
                    #= none:154 =#
                    #= none:154 =# @test c11 ≈ [5.0, 6.0, 7.0]
                    #= none:155 =#
                    #= none:155 =# @test c12 ≈ [10.0, 12.0, 14.0]
                    #= none:159 =#
                    u2 = FieldTimeSeries(filepath2d, "u", architecture = arch)
                    #= none:160 =#
                    v2 = FieldTimeSeries(filepath2d, "v", architecture = arch)
                    #= none:161 =#
                    w2 = FieldTimeSeries(filepath2d, "w", architecture = arch)
                    #= none:162 =#
                    T2 = FieldTimeSeries(filepath2d, "T", architecture = arch)
                    #= none:163 =#
                    b2 = FieldTimeSeries(filepath2d, "b", architecture = arch)
                    #= none:164 =#
                    ζ2 = FieldTimeSeries(filepath2d, "ζ", architecture = arch)
                    #= none:166 =#
                    #= none:166 =# @test location(u2) == (Face, Center, Center)
                    #= none:167 =#
                    #= none:167 =# @test location(v2) == (Center, Face, Center)
                    #= none:168 =#
                    #= none:168 =# @test location(w2) == (Center, Center, Face)
                    #= none:169 =#
                    #= none:169 =# @test location(T2) == (Center, Center, Center)
                    #= none:170 =#
                    #= none:170 =# @test location(b2) == (Center, Center, Center)
                    #= none:171 =#
                    #= none:171 =# @test location(ζ2) == (Face, Face, Center)
                    #= none:173 =#
                    #= none:173 =# @test size(u2) == (Nx, Ny, 1, Nt)
                    #= none:174 =#
                    #= none:174 =# @test size(v2) == (Nx, Ny, 1, Nt)
                    #= none:175 =#
                    #= none:175 =# @test size(w2) == (Nx, Ny, 1, Nt)
                    #= none:176 =#
                    #= none:176 =# @test size(T2) == (Nx, Ny, 1, Nt)
                    #= none:177 =#
                    #= none:177 =# @test size(b2) == (Nx, Ny, 1, Nt)
                    #= none:178 =#
                    #= none:178 =# @test size(ζ2) == (Nx, Ny, 1, Nt)
                    #= none:180 =#
                    ArrayType = array_type(arch)
                    #= none:181 =#
                    for fts = (u3, v3, w3, T3, b3, ζ3)
                        #= none:182 =#
                        #= none:182 =# @test parent(fts) isa ArrayType
                        #= none:183 =#
                    end
                    #= none:185 =#
                    if arch isa CPU
                        #= none:186 =#
                        #= none:186 =# @test u2[1, 2, 5, 4] isa Number
                        #= none:187 =#
                        #= none:187 =# @test u2[1] isa Field
                        #= none:188 =#
                        #= none:188 =# @test v2[2] isa Field
                    end
                    #= none:193 =#
                    u1 = FieldTimeSeries(filepath1d, "u", architecture = arch)
                    #= none:194 =#
                    v1 = FieldTimeSeries(filepath1d, "v", architecture = arch)
                    #= none:195 =#
                    w1 = FieldTimeSeries(filepath1d, "w", architecture = arch)
                    #= none:196 =#
                    T1 = FieldTimeSeries(filepath1d, "T", architecture = arch)
                    #= none:197 =#
                    b1 = FieldTimeSeries(filepath1d, "b", architecture = arch)
                    #= none:198 =#
                    ζ1 = FieldTimeSeries(filepath1d, "ζ", architecture = arch)
                    #= none:200 =#
                    #= none:200 =# @test location(u1) == (Nothing, Nothing, Center)
                    #= none:201 =#
                    #= none:201 =# @test location(v1) == (Nothing, Nothing, Center)
                    #= none:202 =#
                    #= none:202 =# @test location(w1) == (Nothing, Nothing, Face)
                    #= none:203 =#
                    #= none:203 =# @test location(T1) == (Nothing, Nothing, Center)
                    #= none:204 =#
                    #= none:204 =# @test location(b1) == (Nothing, Nothing, Center)
                    #= none:205 =#
                    #= none:205 =# @test location(ζ1) == (Nothing, Nothing, Center)
                    #= none:207 =#
                    #= none:207 =# @test size(u1) == (1, 1, Nz, Nt)
                    #= none:208 =#
                    #= none:208 =# @test size(v1) == (1, 1, Nz, Nt)
                    #= none:209 =#
                    #= none:209 =# @test size(w1) == (1, 1, Nz + 1, Nt)
                    #= none:210 =#
                    #= none:210 =# @test size(T1) == (1, 1, Nz, Nt)
                    #= none:211 =#
                    #= none:211 =# @test size(b1) == (1, 1, Nz, Nt)
                    #= none:212 =#
                    #= none:212 =# @test size(ζ1) == (1, 1, Nz, Nt)
                    #= none:214 =#
                    for fts = (u1, v1, w1, T1, b1, ζ1)
                        #= none:215 =#
                        #= none:215 =# @test parent(fts) isa ArrayType
                        #= none:216 =#
                    end
                    #= none:218 =#
                    if arch isa CPU
                        #= none:219 =#
                        #= none:219 =# @test u1[1, 1, 3, 4] isa Number
                        #= none:220 =#
                        #= none:220 =# @test u1[1] isa Field
                        #= none:221 =#
                        #= none:221 =# @test v1[2] isa Field
                    end
                end
            #= none:225 =#
            if arch isa GPU
                #= none:226 =#
                #= none:226 =# @testset "FieldTimeSeries with CuArray boundary conditions [$(typeof(arch))]" begin
                        #= none:227 =#
                        #= none:227 =# @info "  Testing FieldTimeSeries with CuArray boundary conditions..."
                        #= none:229 =#
                        x = (y = (z = (0, 1)))
                        #= none:230 =#
                        grid = RectilinearGrid(GPU(); size = (1, 1, 1), x, y, z)
                        #= none:232 =#
                        τx = KAUtils.ArrayConstructor(KAUtils.get_backend(), zeros(size(grid)...))
                        #= none:233 =#
                        τy = Field{Center, Face, Nothing}(grid)
                        #= none:234 =#
                        u_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(τx))
                        #= none:235 =#
                        v_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(τy))
                        #= none:236 =#
                        model = NonhydrostaticModel(; grid, boundary_conditions = (; u = u_bcs, v = v_bcs))
                        #= none:237 =#
                        simulation = Simulation(model; Δt = 1, stop_iteration = 1)
                        #= none:239 =#
                        simulation.output_writers[:jld2] = JLD2OutputWriter(model, model.velocities, filename = "test_cuarray_bc.jld2", schedule = IterationInterval(1), overwrite_existing = true)
                        #= none:244 =#
                        run!(simulation)
                        #= none:246 =#
                        ut = FieldTimeSeries("test_cuarray_bc.jld2", "u")
                        #= none:247 =#
                        vt = FieldTimeSeries("test_cuarray_bc.jld2", "v")
                        #= none:248 =#
                        #= none:248 =# @test ut.boundary_conditions.top.classification isa Flux
                        #= none:249 =#
                        #= none:249 =# @test ut.boundary_conditions.top.condition isa Array
                        #= none:251 =#
                        τy_ow = vt.boundary_conditions.top.condition
                        #= none:252 =#
                        #= none:252 =# @test τy_ow isa Field{Center, Face, Nothing}
                        #= none:253 =#
                        #= none:253 =# @test architecture(τy_ow) isa CPU
                        #= none:254 =#
                        #= none:254 =# @test parent(τy_ow) isa Array
                        #= none:255 =#
                        rm("test_cuarray_bc.jld2")
                    end
            end
            #= none:258 =#
        end
        #= none:260 =#
        for arch = archs
            #= none:261 =#
            #= none:261 =# @testset "FieldTimeSeries{OnDisk} [$(typeof(arch))]" begin
                    #= none:262 =#
                    #= none:262 =# @info "  Testing FieldTimeSeries{OnDisk} [$(typeof(arch))]..."
                    #= none:264 =#
                    ArrayType = array_type(arch)
                    #= none:266 =#
                    ζ = FieldTimeSeries(filepath3d, "ζ", backend = OnDisk(), architecture = arch)
                    #= none:267 =#
                    #= none:267 =# @test location(ζ) == (Face, Face, Center)
                    #= none:268 =#
                    #= none:268 =# @test size(ζ) == (Nx, Ny, Nz, Nt)
                    #= none:269 =#
                    #= none:269 =# @test ζ[1] isa Field
                    #= none:270 =#
                    #= none:270 =# @test ζ[2] isa Field
                    #= none:271 =#
                    #= none:271 =# @test (ζ[1]).data.parent isa ArrayType
                    #= none:273 =#
                    b = FieldTimeSeries(filepath1d, "b", backend = OnDisk(), architecture = arch)
                    #= none:274 =#
                    #= none:274 =# @test location(b) == (Nothing, Nothing, Center)
                    #= none:275 =#
                    #= none:275 =# @test size(b) == (1, 1, Nz, Nt)
                    #= none:276 =#
                    #= none:276 =# @test b[1] isa Field
                    #= none:277 =#
                    #= none:277 =# @test b[2] isa Field
                end
            #= none:279 =#
        end
        #= none:281 =#
        for arch = archs
            #= none:282 =#
            #= none:282 =# @testset "FieldTimeSeries{InMemory} reductions" begin
                    #= none:283 =#
                    #= none:283 =# @info "  Testing FieldTimeSeries{InMemory} reductions..."
                    #= none:285 =#
                    for name = ("u", "v", "w", "T", "b", "ζ"), fun = (sum, mean, maximum, minimum)
                        #= none:286 =#
                        f = FieldTimeSeries(filepath3d, name, architecture = CPU())
                        #= none:288 =#
                        ε = eps(maximum(abs, f.data.parent))
                        #= none:290 =#
                        val1 = fun(f)
                        #= none:291 =#
                        val2 = fun([fun(f[n]) for n = 1:Nt])
                        #= none:293 =#
                        #= none:293 =# @test val1 ≈ val2 atol = 4ε
                        #= none:294 =#
                    end
                end
            #= none:296 =#
        end
        #= none:298 =#
        #= none:298 =# @testset "Outputwriting with set!(FieldTimeSeries{OnDisk})" begin
                #= none:299 =#
                #= none:299 =# @info "  Testing set!(FieldTimeSeries{OnDisk})..."
                #= none:301 =#
                grid = RectilinearGrid(size = (1, 1, 1), extent = (1, 1, 1))
                #= none:302 =#
                c = CenterField(grid)
                #= none:304 =#
                filepath = "testfile.jld2"
                #= none:305 =#
                f = FieldTimeSeries(location(c), grid, 1:10; backend = OnDisk(), path = filepath, name = "c")
                #= none:307 =#
                for i = 1:10
                    #= none:308 =#
                    set!(c, i)
                    #= none:309 =#
                    set!(f, c, i)
                    #= none:310 =#
                end
                #= none:312 =#
                g = FieldTimeSeries(filepath, "c")
                #= none:314 =#
                #= none:314 =# @test location(g) == (Center, Center, Center)
                #= none:315 =#
                #= none:315 =# @test indices(g) == (:, :, :)
                #= none:316 =#
                #= none:316 =# @test g.grid == grid
                #= none:318 =#
                #= none:318 =# @test g[1, 1, 1, 1] == 1
                #= none:319 =#
                #= none:319 =# @test g[1, 1, 1, 10] == 10
                #= none:320 =#
                #= none:320 =# @test g[1, 1, 1, Time(1.6)] == 1.6
                #= none:322 =#
                t = g[Time(3.8)]
                #= none:324 =#
                #= none:324 =# @test t[1, 1, 1] == 3.8
            end
        #= none:327 =#
        #= none:327 =# @testset "Test chunked abstraction" begin
                #= none:328 =#
                #= none:328 =# @info "  Testing Chunked abstraction..."
                #= none:329 =#
                filepath = "testfile.jld2"
                #= none:330 =#
                fts = FieldTimeSeries(filepath, "c")
                #= none:331 =#
                fts_chunked = FieldTimeSeries(filepath, "c"; backend = InMemory(2), time_indexing = Cyclical())
                #= none:333 =#
                for t = eachindex(fts.times)
                    #= none:334 =#
                    fts_chunked[t] == fts[t]
                    #= none:335 =#
                end
                #= none:337 =#
                (min_fts, max_fts) = extrema(fts)
                #= none:340 =#
                times = map(Time, 0:0.1:300)
                #= none:341 =#
                for time = times
                    #= none:342 =#
                    #= none:342 =# @test minimum(fts_chunked[time]) ≥ min_fts
                    #= none:343 =#
                    #= none:343 =# @test maximum(fts_chunked[time]) ≤ max_fts
                    #= none:344 =#
                end
            end
        #= none:347 =#
        #= none:347 =# @testset "Time Interpolation" begin
                #= none:348 =#
                times = rand(100) * 100
                #= none:349 =#
                times = sort(times)
                #= none:351 =#
                (min_t, max_t) = extrema(times)
                #= none:353 =#
                grid = RectilinearGrid(size = (1, 1, 1), extent = (1, 1, 1))
                #= none:355 =#
                fts_cyclic = FieldTimeSeries{Nothing, Nothing, Nothing}(grid, times; time_indexing = Cyclical())
                #= none:356 =#
                fts_clamp = FieldTimeSeries{Nothing, Nothing, Nothing}(grid, times; time_indexing = Clamp())
                #= none:358 =#
                for t = eachindex(times)
                    #= none:359 =#
                    fill!(fts_cyclic[t], t / 2)
                    #= none:360 =#
                    fill!(fts_clamp[t], t / 2)
                    #= none:361 =#
                end
                #= none:364 =#
                for time = Time.(collect(0:0.1:100))
                    #= none:365 =#
                    #= none:365 =# @test fts_cyclic[1, 1, 1, time] ≤ 50
                    #= none:366 =#
                    #= none:366 =# @test fts_cyclic[1, 1, 1, time] ≥ 0.5
                    #= none:368 =#
                    if time.time > max_t
                        #= none:369 =#
                        #= none:369 =# @test fts_clamp[1, 1, 1, time] == 50
                    elseif #= none:370 =# time.time < min_t
                        #= none:371 =#
                        #= none:371 =# @test fts_clamp[1, 1, 1, time] == 0.5
                    else
                        #= none:373 =#
                        #= none:373 =# @test fts_clamp[1, 1, 1, time] ≈ fts_cyclic[1, 1, 1, time]
                    end
                    #= none:375 =#
                end
            end
        #= none:378 =#
        for Backend = [InMemory, OnDisk]
            #= none:379 =#
            #= none:379 =# @testset "FieldDataset{$(Backend)} indexing" begin
                    #= none:380 =#
                    #= none:380 =# @info "  Testing FieldDataset{$(Backend)} indexing..."
                    #= none:382 =#
                    ds = FieldDataset(filepath3d, backend = Backend())
                    #= none:384 =#
                    #= none:384 =# @test ds isa FieldDataset
                    #= none:385 =#
                    #= none:385 =# @test length(keys(ds.fields)) == 8
                    #= none:387 =#
                    for var_str = ("u", "v", "w", "T", "S", "b", "ζ", "ke")
                        #= none:388 =#
                        #= none:388 =# @test ds[var_str] isa FieldTimeSeries
                        #= none:389 =#
                        #= none:389 =# @test (ds[var_str])[1] isa Field
                        #= none:390 =#
                    end
                    #= none:392 =#
                    for var_sym = (:u, :v, :w, :T, :S, :b, :ζ, :ke)
                        #= none:393 =#
                        #= none:393 =# @test ds[var_sym] isa FieldTimeSeries
                        #= none:394 =#
                        #= none:394 =# @test (ds[var_sym])[2] isa Field
                        #= none:395 =#
                    end
                    #= none:397 =#
                    #= none:397 =# @test ds.u isa FieldTimeSeries
                    #= none:398 =#
                    #= none:398 =# @test ds.v isa FieldTimeSeries
                    #= none:399 =#
                    #= none:399 =# @test ds.w isa FieldTimeSeries
                    #= none:400 =#
                    #= none:400 =# @test ds.T isa FieldTimeSeries
                    #= none:401 =#
                    #= none:401 =# @test ds.S isa FieldTimeSeries
                    #= none:402 =#
                    #= none:402 =# @test ds.b isa FieldTimeSeries
                    #= none:403 =#
                    #= none:403 =# @test ds.ζ isa FieldTimeSeries
                    #= none:404 =#
                    #= none:404 =# @test ds.ke isa FieldTimeSeries
                end
            #= none:406 =#
        end
        #= none:408 =#
        for Backend = [InMemory, OnDisk]
            #= none:409 =#
            #= none:409 =# @testset "FieldTimeSeries{$(Backend)} parallel reading" begin
                    #= none:410 =#
                    #= none:410 =# @info "  Testing FieldTimeSeries{$(Backend)} parallel reading..."
                    #= none:412 =#
                    reader_kw = Dict(:parallel_read => true)
                    #= none:413 =#
                    u3 = FieldTimeSeries(filepath3d, "u"; backend = Backend(), reader_kw)
                    #= none:414 =#
                    b3 = FieldTimeSeries(filepath3d, "b"; backend = Backend(), reader_kw)
                    #= none:416 =#
                    #= none:416 =# @test u3 isa FieldTimeSeries
                    #= none:417 =#
                    #= none:417 =# @test b3 isa FieldTimeSeries
                    #= none:418 =#
                    #= none:418 =# @test u3[1] isa Field
                    #= none:419 =#
                    #= none:419 =# @test b3[1] isa Field
                end
            #= none:421 =#
        end
        #= none:423 =#
        for Backend = [InMemory, OnDisk]
            #= none:424 =#
            #= none:424 =# @testset "FieldDataset{$(Backend)} parallel reading" begin
                    #= none:425 =#
                    #= none:425 =# @info "  Testing FieldDataset{$(Backend)} parallel reading..."
                    #= none:427 =#
                    reader_kw = Dict(:parallel_read => true)
                    #= none:428 =#
                    ds = FieldDataset(filepath3d; backend = Backend(), reader_kw)
                    #= none:430 =#
                    #= none:430 =# @test ds isa FieldDataset
                    #= none:431 =#
                    #= none:431 =# @test ds.u isa FieldTimeSeries
                    #= none:432 =#
                    #= none:432 =# @test ds.b isa FieldTimeSeries
                    #= none:433 =#
                    #= none:433 =# @test ds.u[1] isa Field
                    #= none:434 =#
                    #= none:434 =# @test ds.b[1] isa Field
                end
            #= none:436 =#
        end
        #= none:438 =#
        rm(filepath1d)
        #= none:439 =#
        rm(filepath2d)
        #= none:440 =#
        rm(filepath3d)
    end