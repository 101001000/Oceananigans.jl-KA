
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using NCDatasets
#= none:4 =#
using StructArrays
#= none:5 =#
using Oceananigans.Architectures: architecture, on_architecture
#= none:7 =#
struct TestParticle{T}
    #= none:8 =#
    x::T
    #= none:9 =#
    y::T
    #= none:10 =#
    z::T
    #= none:11 =#
    u::T
    #= none:12 =#
    v::T
    #= none:13 =#
    w::T
    #= none:14 =#
    s::T
end
#= none:17 =#
function particle_tracking_simulation(; grid, particles, timestepper = :RungeKutta3, velocities = nothing)
    #= none:17 =#
    #= none:18 =#
    if grid isa RectilinearGrid
        #= none:19 =#
        model = NonhydrostaticModel(; grid, timestepper, velocities, particles)
        #= none:20 =#
        set!(model, u = 1, v = 1)
    else
        #= none:22 =#
        set!(velocities.u, 1)
        #= none:23 =#
        set!(velocities.v, 1)
        #= none:24 =#
        model = HydrostaticFreeSurfaceModel(; grid, velocities = PrescribedVelocityFields(; velocities...), particles)
    end
    #= none:26 =#
    sim = Simulation(model, Δt = 0.01, stop_iteration = 1)
    #= none:28 =#
    jld2_filepath = "test_particles.jld2"
    #= none:29 =#
    sim.output_writers[:particles_jld2] = JLD2OutputWriter(model, (; particles = model.particles), filename = "test_particles", schedule = IterationInterval(1))
    #= none:33 =#
    nc_filepath = "test_particles.nc"
    #= none:34 =#
    sim.output_writers[:particles_nc] = NetCDFOutputWriter(model, model.particles, filename = nc_filepath, schedule = IterationInterval(1))
    #= none:37 =#
    sim.output_writers[:checkpointer] = Checkpointer(model, schedule = IterationInterval(1), dir = ".", prefix = "particles_checkpoint")
    #= none:40 =#
    return (sim, jld2_filepath, nc_filepath)
end
#= none:43 =#
function run_simple_particle_tracking_tests(grid, timestepper = :QuasiAdamsBashforth)
    #= none:43 =#
    #= none:45 =#
    arch = architecture(grid)
    #= none:47 =#
    P = 10
    #= none:53 =#
    xs = on_architecture(arch, 0.6 * ones(P))
    #= none:54 =#
    ys = on_architecture(arch, 0.58 * ones(P))
    #= none:55 =#
    zs = on_architecture(arch, 0.8 * ones(P))
    #= none:57 =#
    particles = LagrangianParticles(x = xs, y = ys, z = zs)
    #= none:58 =#
    #= none:58 =# @test particles isa LagrangianParticles
    #= none:60 =#
    if grid isa RectilinearGrid
        #= none:61 =#
        (sim, jld2_filepath, nc_filepath) = particle_tracking_simulation(; grid, particles, timestepper)
        #= none:62 =#
        model = sim.model
        #= none:63 =#
        run!(sim)
        #= none:66 =#
        #= none:66 =# @test length(model.particles) == P
        #= none:67 =#
        #= none:67 =# @test propertynames(model.particles.properties) == (:x, :y, :z)
        #= none:69 =#
        rm(jld2_filepath)
        #= none:70 =#
        rm(nc_filepath)
        #= none:71 =#
        rm("particles_checkpoint_iteration0.jld2")
    end
    #= none:78 =#
    initial_z = #= none:78 =# CUDA.@allowscalar(grid.zᵃᵃᶜ[grid.Nz - 1])
    #= none:79 =#
    top_boundary = #= none:79 =# CUDA.@allowscalar(grid.zᵃᵃᶠ[grid.Nz + 1])
    #= none:81 =#
    (x, y, z) = on_architecture.(Ref(arch), ([0.0], [0.0], [initial_z]))
    #= none:83 =#
    particles = LagrangianParticles(; x, y, z)
    #= none:84 =#
    (u, v, w) = VelocityFields(grid)
    #= none:86 =#
    Δt = 0.01
    #= none:87 =#
    interior(w, :, :, grid.Nz) .= ((0.1 + top_boundary) - initial_z) / Δt
    #= none:88 =#
    interior(w, :, :, grid.Nz - 1) .= ((0.2 + top_boundary) - initial_z) / Δt
    #= none:90 =#
    velocities = PrescribedVelocityFields(; u, v, w)
    #= none:92 =#
    model = HydrostaticFreeSurfaceModel(; grid, particles, velocities, buoyancy = nothing, tracers = ())
    #= none:94 =#
    time_step!(model, Δt)
    #= none:96 =#
    zᶠ = convert(array_type(arch), model.particles.properties.z)
    #= none:97 =#
    #= none:97 =# @test all(zᶠ .≈ top_boundary - 0.15)
    #= none:103 =#
    xs = on_architecture(arch, zeros(P))
    #= none:104 =#
    ys = on_architecture(arch, zeros(P))
    #= none:105 =#
    zs = on_architecture(arch, 0.5 * ones(P))
    #= none:106 =#
    us = on_architecture(arch, zeros(P))
    #= none:107 =#
    vs = on_architecture(arch, zeros(P))
    #= none:108 =#
    ws = on_architecture(arch, zeros(P))
    #= none:109 =#
    ss = on_architecture(arch, zeros(P))
    #= none:112 =#
    particles = StructArray{TestParticle}((xs, ys, zs, us, vs, ws, ss))
    #= none:114 =#
    (u, v, w) = (velocities = VelocityFields(grid))
    #= none:115 =#
    speed = Field(√(u * u + v * v))
    #= none:116 =#
    tracked_fields = merge(velocities, (; s = speed))
    #= none:119 =#
    background_v = (VelocityFields(grid)).v
    #= none:120 =#
    background_v .= 1
    #= none:123 =#
    lagrangian_particles = LagrangianParticles(particles; tracked_fields)
    #= none:124 =#
    #= none:124 =# @test lagrangian_particles isa LagrangianParticles
    #= none:126 =#
    if grid isa RectilinearGrid
        #= none:127 =#
        model = NonhydrostaticModel(; grid, timestepper, velocities, particles = lagrangian_particles, background_fields = (v = background_v,))
        #= none:131 =#
        set!(model, u = 1)
        #= none:133 =#
        sim = Simulation(model, Δt = 0.01, stop_iteration = 1)
        #= none:135 =#
        jld2_filepath = "test_particles.jld2"
        #= none:136 =#
        sim.output_writers[:particles_jld2] = JLD2OutputWriter(model, (; particles = model.particles), filename = jld2_filepath, schedule = IterationInterval(1))
        #= none:140 =#
        nc_filepath = "test_particles.nc"
        #= none:141 =#
        sim.output_writers[:particles_nc] = NetCDFOutputWriter(model, model.particles, filename = nc_filepath, schedule = IterationInterval(1))
        #= none:144 =#
        sim.output_writers[:checkpointer] = Checkpointer(model, schedule = IterationInterval(1), dir = ".", prefix = "particles_checkpoint")
        #= none:147 =#
        rm(jld2_filepath)
        #= none:148 =#
        rm(nc_filepath)
        #= none:149 =#
        rm("particles_checkpoint_iteration1.jld2")
    end
    #= none:152 =#
    (sim, jld2_filepath, nc_filepath) = particle_tracking_simulation(; grid, particles = lagrangian_particles, timestepper, velocities)
    #= none:153 =#
    model = sim.model
    #= none:154 =#
    run!(sim)
    #= none:156 =#
    #= none:156 =# @test length(model.particles) == P
    #= none:157 =#
    #= none:157 =# @test size(model.particles) == tuple(P)
    #= none:158 =#
    #= none:158 =# @test propertynames(model.particles.properties) == (:x, :y, :z, :u, :v, :w, :s)
    #= none:160 =#
    x = convert(array_type(arch), model.particles.properties.x)
    #= none:161 =#
    y = convert(array_type(arch), model.particles.properties.y)
    #= none:162 =#
    z = convert(array_type(arch), model.particles.properties.z)
    #= none:163 =#
    u = convert(array_type(arch), model.particles.properties.u)
    #= none:164 =#
    v = convert(array_type(arch), model.particles.properties.v)
    #= none:165 =#
    w = convert(array_type(arch), model.particles.properties.w)
    #= none:166 =#
    s = convert(array_type(arch), model.particles.properties.s)
    #= none:168 =#
    #= none:168 =# @test size(x) == tuple(P)
    #= none:169 =#
    #= none:169 =# @test size(y) == tuple(P)
    #= none:170 =#
    #= none:170 =# @test size(z) == tuple(P)
    #= none:171 =#
    #= none:171 =# @test size(u) == tuple(P)
    #= none:172 =#
    #= none:172 =# @test size(v) == tuple(P)
    #= none:173 =#
    #= none:173 =# @test size(w) == tuple(P)
    #= none:174 =#
    #= none:174 =# @test size(s) == tuple(P)
    #= none:176 =#
    if grid isa RectilinearGrid
        #= none:177 =#
        #= none:177 =# @test all(x .≈ 0.01)
        #= none:178 =#
        #= none:178 =# @test all(y .≈ 0.01)
    end
    #= none:180 =#
    #= none:180 =# @test all(z .≈ 0.5)
    #= none:181 =#
    #= none:181 =# @test all(u .≈ 1)
    #= none:182 =#
    #= none:182 =# @test all(v .≈ 1)
    #= none:183 =#
    #= none:183 =# @test all(w .≈ 0)
    #= none:184 =#
    #= none:184 =# @test all(s .≈ √2)
    #= none:187 =#
    ds = NCDataset(nc_filepath)
    #= none:188 =#
    (x, y, z) = (ds["x"], ds["y"], ds["z"])
    #= none:189 =#
    (u, v, w, s) = (ds["u"], ds["v"], ds["w"], ds["s"])
    #= none:191 =#
    #= none:191 =# @test size(x) == (P, 2)
    #= none:192 =#
    #= none:192 =# @test size(y) == (P, 2)
    #= none:193 =#
    #= none:193 =# @test size(z) == (P, 2)
    #= none:194 =#
    #= none:194 =# @test size(u) == (P, 2)
    #= none:195 =#
    #= none:195 =# @test size(v) == (P, 2)
    #= none:196 =#
    #= none:196 =# @test size(w) == (P, 2)
    #= none:197 =#
    #= none:197 =# @test size(s) == (P, 2)
    #= none:199 =#
    if grid isa RectilinearGrid
        #= none:200 =#
        #= none:200 =# @test all(x[:, end] .≈ 0.01)
        #= none:201 =#
        #= none:201 =# @test all(y[:, end] .≈ 0.01)
    end
    #= none:203 =#
    #= none:203 =# @test all(z[:, end] .≈ 0.5)
    #= none:204 =#
    #= none:204 =# @test all(u[:, end] .≈ 1)
    #= none:205 =#
    #= none:205 =# @test all(v[:, end] .≈ 1)
    #= none:206 =#
    #= none:206 =# @test all(w[:, end] .≈ 0)
    #= none:207 =#
    #= none:207 =# @test all(s[:, end] .≈ √2)
    #= none:209 =#
    close(ds)
    #= none:210 =#
    rm(nc_filepath)
    #= none:213 =#
    file = jldopen(jld2_filepath)
    #= none:214 =#
    #= none:214 =# @test haskey(file["timeseries"], "particles")
    #= none:215 =#
    #= none:215 =# @test haskey(file["timeseries/particles"], "0")
    #= none:216 =#
    #= none:216 =# @test haskey(file["timeseries/particles"], "0")
    #= none:218 =#
    #= none:218 =# @test size((file["timeseries/particles/1"]).x) == tuple(P)
    #= none:219 =#
    #= none:219 =# @test size((file["timeseries/particles/1"]).y) == tuple(P)
    #= none:220 =#
    #= none:220 =# @test size((file["timeseries/particles/1"]).z) == tuple(P)
    #= none:221 =#
    #= none:221 =# @test size((file["timeseries/particles/1"]).u) == tuple(P)
    #= none:222 =#
    #= none:222 =# @test size((file["timeseries/particles/1"]).v) == tuple(P)
    #= none:223 =#
    #= none:223 =# @test size((file["timeseries/particles/1"]).w) == tuple(P)
    #= none:224 =#
    #= none:224 =# @test size((file["timeseries/particles/1"]).s) == tuple(P)
    #= none:226 =#
    if grid isa RectilinearGrid
        #= none:227 =#
        #= none:227 =# @test all((file["timeseries/particles/1"]).x .≈ 0.01)
        #= none:228 =#
        #= none:228 =# @test all((file["timeseries/particles/1"]).y .≈ 0.01)
    end
    #= none:230 =#
    #= none:230 =# @test all((file["timeseries/particles/1"]).z .≈ 0.5)
    #= none:231 =#
    #= none:231 =# @test all((file["timeseries/particles/1"]).u .≈ 1)
    #= none:232 =#
    #= none:232 =# @test all((file["timeseries/particles/1"]).v .≈ 1)
    #= none:233 =#
    #= none:233 =# @test all((file["timeseries/particles/1"]).w .≈ 0)
    #= none:234 =#
    #= none:234 =# @test all((file["timeseries/particles/1"]).s .≈ √2)
    #= none:236 =#
    close(file)
    #= none:237 =#
    rm(jld2_filepath)
    #= none:240 =#
    model.particles.properties.x .= 0
    #= none:241 =#
    model.particles.properties.y .= 0
    #= none:242 =#
    model.particles.properties.z .= 0
    #= none:243 =#
    model.particles.properties.u .= 0
    #= none:244 =#
    model.particles.properties.v .= 0
    #= none:245 =#
    model.particles.properties.w .= 0
    #= none:246 =#
    model.particles.properties.s .= 0
    #= none:248 =#
    set!(model, "particles_checkpoint_iteration1.jld2")
    #= none:250 =#
    x = convert(array_type(arch), model.particles.properties.x)
    #= none:251 =#
    y = convert(array_type(arch), model.particles.properties.y)
    #= none:252 =#
    z = convert(array_type(arch), model.particles.properties.z)
    #= none:253 =#
    u = convert(array_type(arch), model.particles.properties.u)
    #= none:254 =#
    v = convert(array_type(arch), model.particles.properties.v)
    #= none:255 =#
    w = convert(array_type(arch), model.particles.properties.w)
    #= none:256 =#
    s = convert(array_type(arch), model.particles.properties.s)
    #= none:258 =#
    #= none:258 =# @test model.particles.properties isa StructArray
    #= none:260 =#
    #= none:260 =# @test size(x) == tuple(P)
    #= none:261 =#
    #= none:261 =# @test size(y) == tuple(P)
    #= none:262 =#
    #= none:262 =# @test size(z) == tuple(P)
    #= none:263 =#
    #= none:263 =# @test size(u) == tuple(P)
    #= none:264 =#
    #= none:264 =# @test size(v) == tuple(P)
    #= none:265 =#
    #= none:265 =# @test size(w) == tuple(P)
    #= none:266 =#
    #= none:266 =# @test size(s) == tuple(P)
    #= none:268 =#
    if grid isa RectilinearGrid
        #= none:269 =#
        #= none:269 =# @test all(x .≈ 0.01)
        #= none:270 =#
        #= none:270 =# @test all(y .≈ 0.01)
    end
    #= none:272 =#
    #= none:272 =# @test all(z .≈ 0.5)
    #= none:273 =#
    #= none:273 =# @test all(u .≈ 1)
    #= none:274 =#
    #= none:274 =# @test all(v .≈ 1)
    #= none:275 =#
    #= none:275 =# @test all(w .≈ 0)
    #= none:276 =#
    #= none:276 =# @test all(s .≈ √2)
    #= none:278 =#
    rm("particles_checkpoint_iteration0.jld2")
    #= none:279 =#
    rm("particles_checkpoint_iteration1.jld2")
    #= none:281 =#
    return nothing
end
#= none:284 =#
lagrangian_particle_test_grid(arch, ::Periodic, z) = begin
        #= none:284 =#
        RectilinearGrid(arch; topology = (Periodic, Periodic, Bounded), size = (5, 5, 5), x = (-1, 1), y = (-1, 1), z)
    end
#= none:286 =#
lagrangian_particle_test_grid(arch, ::Flat, z) = begin
        #= none:286 =#
        RectilinearGrid(arch; topology = (Periodic, Flat, Bounded), size = (5, 5), x = (-1, 1), z)
    end
#= none:289 =#
lagrangian_particle_test_grid_expanded(arch, ::Periodic, z) = begin
        #= none:289 =#
        RectilinearGrid(arch; topology = (Periodic, Periodic, Bounded), size = (5, 5, 5), x = (-1, 1), y = (-1, 1), z = 2 .* z)
    end
#= none:291 =#
lagrangian_particle_test_grid_expanded(arch, ::Flat, z) = begin
        #= none:291 =#
        RectilinearGrid(arch; topology = (Periodic, Flat, Bounded), size = (5, 5), x = (-1, 1), z = 2 .* z)
    end
#= none:294 =#
function lagrangian_particle_test_immersed_grid(arch, y_topo, z)
    #= none:294 =#
    #= none:295 =#
    underlying_grid = lagrangian_particle_test_grid_expanded(arch, y_topo, z)
    #= none:296 =#
    z_immersed_boundary(x, z) = begin
            #= none:296 =#
            ifelse(z < -1, true, ifelse(z > 1, true, false))
        end
    #= none:297 =#
    z_immersed_boundary(x, y, z) = begin
            #= none:297 =#
            z_immersed_boundary(x, z)
        end
    #= none:298 =#
    GFB = GridFittedBoundary(z_immersed_boundary)
    #= none:299 =#
    return ImmersedBoundaryGrid(underlying_grid, GFB)
end
#= none:302 =#
lagrangian_particle_test_curvilinear_grid(arch, z) = begin
        #= none:302 =#
        LatitudeLongitudeGrid(arch; size = (5, 5, 5), longitude = (-1, 1), latitude = (-1, 1), z, precompute_metrics = true)
    end
#= none:305 =#
#= none:305 =# @testset "Lagrangian particle tracking" begin
        #= none:306 =#
        timesteppers = (:QuasiAdamsBashforth2, :RungeKutta3)
        #= none:307 =#
        y_topologies = (Periodic(), Flat())
        #= none:308 =#
        vertical_grids = (uniform = (-1, 1), stretched = [-1, -0.5, 0.0, 0.4, 0.7, 1])
        #= none:310 =#
        for arch = archs, timestepper = timesteppers, y_topo = y_topologies, (z_grid_type, z) = pairs(vertical_grids)
            #= none:311 =#
            #= none:311 =# @info "  Testing Lagrangian particle tracking [$(typeof(arch)), $(timestepper)] with y $(typeof(y_topo)) on vertically $(z_grid_type) grid ..."
            #= none:312 =#
            grid = lagrangian_particle_test_grid(arch, y_topo, z)
            #= none:313 =#
            run_simple_particle_tracking_tests(grid, timestepper)
            #= none:315 =#
            if z isa NTuple{2}
                #= none:316 =#
                #= none:316 =# @info "  Testing Lagrangian particle tracking [$(typeof(arch)), $(timestepper)] with y $(typeof(y_topo)) on vertically $(z_grid_type) immersed grid ..."
                #= none:317 =#
                grid = lagrangian_particle_test_immersed_grid(arch, y_topo, z)
                #= none:318 =#
                run_simple_particle_tracking_tests(grid, timestepper)
            end
            #= none:320 =#
        end
        #= none:322 =#
        for arch = archs, (z_grid_type, z) = pairs(vertical_grids)
            #= none:323 =#
            #= none:323 =# @info "  Testing Lagrangian particle tracking [$(typeof(arch))] with a LatitudeLongitudeGrid with vertically $(z_grid_type) z coordinate ..."
            #= none:324 =#
            grid = lagrangian_particle_test_curvilinear_grid(arch, z)
            #= none:325 =#
            run_simple_particle_tracking_tests(grid)
            #= none:326 =#
        end
    end