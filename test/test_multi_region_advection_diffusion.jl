
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
Gaussian(x, y, L) = begin
        #= none:3 =#
        exp(-((x ^ 2 + y ^ 2)) / (2 * L ^ 2))
    end
#= none:4 =#
prescribed_velocities() = begin
        #= none:4 =#
        PrescribedVelocityFields(u = ((λ, ϕ, z, t = 0)->begin
                        #= none:4 =#
                        0.1 * hack_cosd(ϕ)
                    end))
    end
#= none:6 =#
function Δ_min(grid)
    #= none:6 =#
    #= none:7 =#
    Δx_min = minimum_xspacing(grid, Center(), Center(), Center())
    #= none:8 =#
    Δy_min = minimum_yspacing(grid, Center(), Center(), Center())
    #= none:9 =#
    return min(Δx_min, Δy_min)
end
#= none:12 =#
function solid_body_tracer_advection_test(grid; P = XPartition, regions = 1)
    #= none:12 =#
    #= none:14 =#
    if architecture(grid) isa GPU
        #= none:15 =#
        devices = (0, 0)
    else
        #= none:17 =#
        devices = nothing
    end
    #= none:20 =#
    if grid isa RectilinearGrid
        #= none:21 =#
        L = 0.1
    else
        #= none:23 =#
        L = 24
    end
    #= none:27 =#
    cᵢ(x, y, z) = begin
            #= none:27 =#
            Gaussian(x, 0, L)
        end
    #= none:28 =#
    eᵢ(x, y, z) = begin
            #= none:28 =#
            Gaussian(x, y, L)
        end
    #= none:30 =#
    mrg = MultiRegionGrid(grid, partition = P(regions), devices = devices)
    #= none:32 =#
    model = HydrostaticFreeSurfaceModel(grid = mrg, tracers = (:c, :e), velocities = prescribed_velocities(), free_surface = ExplicitFreeSurface(), momentum_advection = nothing, tracer_advection = WENO(), coriolis = nothing, buoyancy = nothing, closure = nothing)
    #= none:42 =#
    set!(model, c = cᵢ, e = eᵢ)
    #= none:45 =#
    advection_time_scale = Δ_min(grid) / 0.1
    #= none:47 =#
    Δt = 0.1advection_time_scale
    #= none:49 =#
    for _ = 1:10
        #= none:50 =#
        time_step!(model, Δt)
        #= none:51 =#
    end
    #= none:53 =#
    return model.tracers
end
#= none:56 =#
function solid_body_rotation_test(grid; P = XPartition, regions = 1)
    #= none:56 =#
    #= none:58 =#
    if architecture(grid) isa GPU
        #= none:59 =#
        devices = (0, 0)
    else
        #= none:61 =#
        devices = nothing
    end
    #= none:64 =#
    mrg = MultiRegionGrid(grid, partition = P(regions))
    #= none:66 =#
    free_surface = ExplicitFreeSurface(gravitational_acceleration = 1)
    #= none:67 =#
    coriolis = HydrostaticSphericalCoriolis(rotation_rate = 1)
    #= none:69 =#
    model = HydrostaticFreeSurfaceModel(grid = mrg, momentum_advection = VectorInvariant(), free_surface = free_surface, coriolis = coriolis, tracers = :c, tracer_advection = WENO(), buoyancy = nothing, closure = nothing)
    #= none:78 =#
    g = model.free_surface.gravitational_acceleration
    #= none:79 =#
    R = grid.radius
    #= none:80 =#
    Ω = model.coriolis.rotation_rate
    #= none:82 =#
    uᵢ(λ, φ, z) = begin
            #= none:82 =#
            0.1 * cosd(φ) * sind(λ)
        end
    #= none:83 =#
    ηᵢ(λ, φ, z) = begin
            #= none:83 =#
            (((R * Ω * 0.1 + 0.1 ^ 2 / 2) * sind(φ) ^ 2) / g) * sind(λ)
        end
    #= none:84 =#
    cᵢ(λ, φ, z) = begin
            #= none:84 =#
            Gaussian(λ, φ - 5, 10)
        end
    #= none:86 =#
    set!(model, u = uᵢ, η = ηᵢ, c = cᵢ)
    #= none:88 =#
    Δt = (0.1 * Δ_min(grid)) / sqrt(g * grid.Lz)
    #= none:90 =#
    for _ = 1:10
        #= none:91 =#
        time_step!(model, Δt)
        #= none:92 =#
    end
    #= none:94 =#
    return merge(model.velocities, model.tracers, (; η = model.free_surface.η))
end
#= none:97 =#
function diffusion_cosine_test(grid; P = XPartition, regions = 1, closure, field_name = :c)
    #= none:97 =#
    #= none:98 =#
    if architecture(grid) isa GPU
        #= none:99 =#
        devices = (0, 0)
    else
        #= none:101 =#
        devices = nothing
    end
    #= none:104 =#
    mrg = MultiRegionGrid(grid, partition = P(regions), devices = devices)
    #= none:110 =#
    free_surface = SplitExplicitFreeSurface(substeps = 8)
    #= none:112 =#
    model = HydrostaticFreeSurfaceModel(; grid = mrg, free_surface, closure, tracers = :c, coriolis = nothing, buoyancy = nothing)
    #= none:119 =#
    initial_condition(x, y, z) = begin
            #= none:119 =#
            cos(2x)
        end
    #= none:121 =#
    expr = quote
            #= none:125 =#
            set!($model, $field_name = $initial_condition)
        end
    #= none:127 =#
    eval(expr)
    #= none:130 =#
    Δt = 1.0e-6 * cell_diffusion_timescale(model)
    #= none:132 =#
    for _ = 1:10
        #= none:133 =#
        time_step!(model, Δt)
        #= none:134 =#
    end
    #= none:136 =#
    return (fields(model))[field_name]
end
#= none:139 =#
Nx = (Ny = 32)
#= none:141 =#
partitioning = [XPartition]
#= none:143 =#
for arch = archs
    #= none:144 =#
    grid_rect = RectilinearGrid(arch, size = (Nx, Ny, 1), halo = (3, 3, 3), topology = (Periodic, Bounded, Bounded), x = (0, 1), y = (0, 1), z = (0, 1))
    #= none:152 =#
    grid_lat = LatitudeLongitudeGrid(arch, size = (Nx, Ny, 1), halo = (3, 3, 3), latitude = (-80, 80), longitude = (-180, 180), z = (-1, 0), radius = 1)
    #= none:160 =#
    #= none:160 =# @testset "Testing multi region tracer advection" begin
            #= none:161 =#
            for grid = (grid_rect, grid_lat)
                #= none:164 =#
                (cs, es) = solid_body_tracer_advection_test(grid, regions = 1)
                #= none:166 =#
                cs = Array(interior(cs))
                #= none:167 =#
                es = Array(interior(es))
                #= none:169 =#
                for regions = (2,), P = partitioning
                    #= none:170 =#
                    #= none:170 =# @info "  Testing $(regions) $(P)s on $((typeof(grid)).name.wrapper) on the $(arch)"
                    #= none:171 =#
                    (c, e) = solid_body_tracer_advection_test(grid; P = P, regions = regions)
                    #= none:173 =#
                    c = interior(reconstruct_global_field(c))
                    #= none:174 =#
                    e = interior(reconstruct_global_field(e))
                    #= none:176 =#
                    #= none:176 =# @test all(isapprox(c, cs, atol = 1.0e-20, rtol = 1.0e-15))
                    #= none:177 =#
                    #= none:177 =# @test all(isapprox(e, es, atol = 1.0e-20, rtol = 1.0e-15))
                    #= none:178 =#
                end
                #= none:179 =#
            end
        end
    #= none:182 =#
    #= none:182 =# @testset "Testing multi region solid body rotation" begin
            #= none:183 =#
            grid = LatitudeLongitudeGrid(arch, size = (Nx, Ny, 1), halo = (3, 3, 3), latitude = (-80, 80), longitude = (-160, 160), z = (-1, 0), radius = 1, topology = (Bounded, Bounded, Bounded))
            #= none:193 =#
            (us, vs, ws, cs, ηs) = solid_body_rotation_test(grid, regions = 1)
            #= none:195 =#
            us = Array(interior(us))
            #= none:196 =#
            vs = Array(interior(vs))
            #= none:197 =#
            ws = Array(interior(ws))
            #= none:198 =#
            cs = Array(interior(cs))
            #= none:199 =#
            ηs = Array(interior(ηs))
            #= none:201 =#
            for regions = (2,), P = partitioning
                #= none:202 =#
                #= none:202 =# @info "  Testing $(regions) $(P)s on $((typeof(grid)).name.wrapper) on the $(arch)"
                #= none:203 =#
                (u, v, w, c, η) = solid_body_rotation_test(grid; P = P, regions = regions)
                #= none:205 =#
                u = interior(reconstruct_global_field(u))
                #= none:206 =#
                v = interior(reconstruct_global_field(v))
                #= none:207 =#
                w = interior(reconstruct_global_field(w))
                #= none:208 =#
                c = interior(reconstruct_global_field(c))
                #= none:209 =#
                η = interior(reconstruct_global_field(η))
                #= none:211 =#
                #= none:211 =# @test all(isapprox(u, us, atol = 1.0e-20, rtol = 1.0e-15))
                #= none:212 =#
                #= none:212 =# @test all(isapprox(v, vs, atol = 1.0e-20, rtol = 1.0e-15))
                #= none:213 =#
                #= none:213 =# @test all(isapprox(w, ws, atol = 1.0e-20, rtol = 1.0e-15))
                #= none:214 =#
                #= none:214 =# @test all(isapprox(c, cs, atol = 1.0e-20, rtol = 1.0e-15))
                #= none:215 =#
                #= none:215 =# @test all(isapprox(η, ηs, atol = 1.0e-20, rtol = 1.0e-15))
                #= none:216 =#
            end
        end
    #= none:219 =#
    #= none:219 =# @testset "Testing multi region gaussian diffusion" begin
            #= none:220 =#
            grid = RectilinearGrid(arch, size = (Nx, Ny, 1), halo = (3, 3, 3), topology = (Bounded, Bounded, Bounded), x = (0, 1), y = (0, 1), z = (0, 1))
            #= none:228 =#
            diff₂ = ScalarDiffusivity(ν = 1, κ = 1)
            #= none:229 =#
            diff₄ = ScalarBiharmonicDiffusivity(ν = 1.0e-5, κ = 1.0e-5)
            #= none:231 =#
            for field_name = (:u, :v, :c)
                #= none:232 =#
                for closure = (diff₂, diff₄)
                    #= none:235 =#
                    fs = diffusion_cosine_test(grid; closure, field_name, regions = 1)
                    #= none:236 =#
                    fs = Array(interior(fs))
                    #= none:238 =#
                    for regions = (2,), P = partitioning
                        #= none:239 =#
                        #= none:239 =# @info "  Testing diffusion of $(field_name) on $(regions) $(P)s with $((typeof(closure)).name.wrapper) on $(arch)"
                        #= none:241 =#
                        f = diffusion_cosine_test(grid; closure, P, field_name, regions)
                        #= none:242 =#
                        f = interior(reconstruct_global_field(f))
                        #= none:244 =#
                        #= none:244 =# @test all(isapprox(f, fs, atol = 1.0e-20, rtol = 1.0e-15))
                        #= none:245 =#
                    end
                    #= none:246 =#
                end
                #= none:247 =#
            end
        end
    #= none:249 =#
end