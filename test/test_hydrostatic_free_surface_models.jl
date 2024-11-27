
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: VectorInvariant, PrescribedVelocityFields
#= none:4 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: ExplicitFreeSurface, ImplicitFreeSurface
#= none:5 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: SingleColumnGrid
#= none:6 =#
using Oceananigans.Advection: EnergyConserving, EnstrophyConserving, FluxFormAdvection
#= none:7 =#
using Oceananigans.TurbulenceClosures
#= none:8 =#
using Oceananigans.TurbulenceClosures: CATKEVerticalDiffusivity
#= none:10 =#
function time_step_hydrostatic_model_works(grid; coriolis = nothing, free_surface = ExplicitFreeSurface(), momentum_advection = nothing, tracers = [:b], tracer_advection = nothing, closure = nothing, velocities = nothing)
    #= none:10 =#
    #= none:19 =#
    buoyancy = BuoyancyTracer()
    #= none:20 =#
    closure isa CATKEVerticalDiffusivity && push!(tracers, :e)
    #= none:22 =#
    model = HydrostaticFreeSurfaceModel(; grid, coriolis, tracers, velocities, buoyancy, momentum_advection, tracer_advection, free_surface, closure)
    #= none:25 =#
    simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
    #= none:27 =#
    run!(simulation)
    #= none:29 =#
    return model.clock.iteration == 1
end
#= none:32 =#
function hydrostatic_free_surface_model_tracers_and_forcings_work(arch)
    #= none:32 =#
    #= none:33 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (2π, 2π, 2π))
    #= none:34 =#
    model = HydrostaticFreeSurfaceModel(grid = grid, tracers = (:T, :S, :c, :d))
    #= none:36 =#
    #= none:36 =# @test model.tracers.T isa Field
    #= none:37 =#
    #= none:37 =# @test model.tracers.S isa Field
    #= none:38 =#
    #= none:38 =# @test model.tracers.c isa Field
    #= none:39 =#
    #= none:39 =# @test model.tracers.d isa Field
    #= none:41 =#
    #= none:41 =# @test haskey(model.forcing, :u)
    #= none:42 =#
    #= none:42 =# @test haskey(model.forcing, :v)
    #= none:43 =#
    #= none:43 =# @test haskey(model.forcing, :η)
    #= none:44 =#
    #= none:44 =# @test haskey(model.forcing, :T)
    #= none:45 =#
    #= none:45 =# @test haskey(model.forcing, :S)
    #= none:46 =#
    #= none:46 =# @test haskey(model.forcing, :c)
    #= none:47 =#
    #= none:47 =# @test haskey(model.forcing, :d)
    #= none:49 =#
    simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
    #= none:50 =#
    run!(simulation)
    #= none:52 =#
    #= none:52 =# @test model.clock.iteration == 1
    #= none:54 =#
    return nothing
end
#= none:57 =#
function time_step_hydrostatic_model_with_catke_works(arch, FT)
    #= none:57 =#
    #= none:58 =#
    grid = LatitudeLongitudeGrid(arch, FT, topology = (Bounded, Bounded, Bounded), size = (8, 8, 8), longitude = (0, 1), latitude = (0, 1), z = (-100, 0))
    #= none:68 =#
    model = HydrostaticFreeSurfaceModel(; grid, buoyancy = BuoyancyTracer(), tracers = (:b, :e), closure = CATKEVerticalDiffusivity(FT))
    #= none:75 =#
    simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
    #= none:77 =#
    run!(simulation)
    #= none:79 =#
    return model.clock.iteration == 1
end
#= none:82 =#
topo_1d = (Flat, Flat, Bounded)
#= none:84 =#
topos_2d = ((Periodic, Flat, Bounded), (Flat, Bounded, Bounded), (Bounded, Flat, Bounded))
#= none:88 =#
topos_3d = ((Periodic, Periodic, Bounded), (Periodic, Bounded, Bounded), (Bounded, Bounded, Bounded))
#= none:92 =#
#= none:92 =# @testset "Hydrostatic free surface Models" begin
        #= none:93 =#
        #= none:93 =# @info "Testing hydrostatic free surface models..."
        #= none:95 =#
        #= none:95 =# @testset "$(topo_1d) model construction" begin
                #= none:96 =#
                #= none:96 =# @info "  Testing $(topo_1d) model construction..."
                #= none:97 =#
                for arch = archs, FT = [Float64]
                    #= none:98 =#
                    grid = RectilinearGrid(arch, FT, topology = topo_1d, size = 1, extent = 1)
                    #= none:99 =#
                    model = HydrostaticFreeSurfaceModel(; grid)
                    #= none:100 =#
                    #= none:100 =# @test model isa HydrostaticFreeSurfaceModel
                    #= none:103 =#
                    #= none:103 =# @test grid isa SingleColumnGrid
                    #= none:104 =#
                    #= none:104 =# @test isnothing(model.free_surface)
                    #= none:105 =#
                    #= none:105 =# @test !(:η ∈ keys(fields(model)))
                    #= none:106 =#
                end
            end
        #= none:109 =#
        for topo = topos_2d
            #= none:110 =#
            #= none:110 =# @testset "$(topo) model construction" begin
                    #= none:111 =#
                    #= none:111 =# @info "  Testing $(topo) model construction..."
                    #= none:112 =#
                    for arch = archs, FT = float_types
                        #= none:113 =#
                        grid = RectilinearGrid(arch, FT, topology = topo, size = (1, 1), extent = (1, 2))
                        #= none:114 =#
                        model = HydrostaticFreeSurfaceModel(; grid)
                        #= none:115 =#
                        #= none:115 =# @test model isa HydrostaticFreeSurfaceModel
                        #= none:116 =#
                        #= none:116 =# @test :η ∈ keys(fields(model))
                        #= none:117 =#
                    end
                end
            #= none:119 =#
        end
        #= none:121 =#
        for topo = topos_3d
            #= none:122 =#
            #= none:122 =# @testset "$(topo) model construction" begin
                    #= none:123 =#
                    #= none:123 =# @info "  Testing $(topo) model construction..."
                    #= none:124 =#
                    for arch = archs, FT = float_types
                        #= none:125 =#
                        grid = RectilinearGrid(arch, FT, topology = topo, size = (1, 1, 1), extent = (1, 2, 3))
                        #= none:126 =#
                        model = HydrostaticFreeSurfaceModel(; grid)
                        #= none:127 =#
                        #= none:127 =# @test model isa HydrostaticFreeSurfaceModel
                        #= none:128 =#
                    end
                end
            #= none:130 =#
        end
        #= none:132 =#
        #= none:132 =# @testset "Halo size check in model constructor" begin
                #= none:133 =#
                for topo = topos_3d
                    #= none:134 =#
                    grid = RectilinearGrid(topology = topo, size = (1, 1, 1), extent = (1, 2, 3), halo = (1, 1, 1))
                    #= none:135 =#
                    hcabd_closure = ScalarBiharmonicDiffusivity()
                    #= none:137 =#
                    #= none:137 =# @test_throws ArgumentError HydrostaticFreeSurfaceModel(grid = grid, tracer_advection = CenteredFourthOrder())
                    #= none:138 =#
                    #= none:138 =# @test_throws ArgumentError HydrostaticFreeSurfaceModel(grid = grid, tracer_advection = UpwindBiasedThirdOrder())
                    #= none:139 =#
                    #= none:139 =# @test_throws ArgumentError HydrostaticFreeSurfaceModel(grid = grid, tracer_advection = UpwindBiasedFifthOrder())
                    #= none:140 =#
                    #= none:140 =# @test_throws ArgumentError HydrostaticFreeSurfaceModel(grid = grid, momentum_advection = UpwindBiasedFifthOrder())
                    #= none:141 =#
                    #= none:141 =# @test_throws ArgumentError HydrostaticFreeSurfaceModel(grid = grid, closure = hcabd_closure)
                    #= none:144 =#
                    bigger_grid = RectilinearGrid(topology = topo, size = (3, 3, 1), extent = (1, 2, 3), halo = (3, 3, 3))
                    #= none:146 =#
                    model = HydrostaticFreeSurfaceModel(grid = bigger_grid, closure = hcabd_closure)
                    #= none:147 =#
                    #= none:147 =# @test model isa HydrostaticFreeSurfaceModel
                    #= none:149 =#
                    model = HydrostaticFreeSurfaceModel(grid = bigger_grid, momentum_advection = UpwindBiasedFifthOrder())
                    #= none:150 =#
                    #= none:150 =# @test model isa HydrostaticFreeSurfaceModel
                    #= none:152 =#
                    model = HydrostaticFreeSurfaceModel(grid = bigger_grid, closure = hcabd_closure)
                    #= none:153 =#
                    #= none:153 =# @test model isa HydrostaticFreeSurfaceModel
                    #= none:155 =#
                    model = HydrostaticFreeSurfaceModel(grid = bigger_grid, tracer_advection = UpwindBiasedFifthOrder())
                    #= none:156 =#
                    #= none:156 =# @test model isa HydrostaticFreeSurfaceModel
                    #= none:157 =#
                end
            end
        #= none:160 =#
        #= none:160 =# @testset "Setting HydrostaticFreeSurfaceModel fields" begin
                #= none:161 =#
                #= none:161 =# @info "  Testing setting hydrostatic free surface model fields..."
                #= none:162 =#
                for arch = archs, FT = float_types
                    #= none:163 =#
                    N = (4, 4, 1)
                    #= none:164 =#
                    L = (2π, 3π, 5π)
                    #= none:166 =#
                    grid = RectilinearGrid(arch, FT, size = N, extent = L)
                    #= none:167 =#
                    model = HydrostaticFreeSurfaceModel(grid = grid)
                    #= none:169 =#
                    (x, y, z) = nodes(model.grid, (Face(), Center(), Center()), reshape = true)
                    #= none:171 =#
                    u₀(x, y, z) = begin
                            #= none:171 =#
                            x * y ^ 2
                        end
                    #= none:172 =#
                    u_answer = #= none:172 =# @__dot__(x * y ^ 2)
                    #= none:174 =#
                    η₀ = rand(size(grid)...)
                    #= none:175 =#
                    η_answer = deepcopy(η₀)
                    #= none:177 =#
                    set!(model, u = u₀, η = η₀)
                    #= none:179 =#
                    (u, v, w) = model.velocities
                    #= none:180 =#
                    η = model.free_surface.η
                    #= none:182 =#
                    #= none:182 =# @test all(Array(interior(u)) .≈ u_answer)
                    #= none:183 =#
                    #= none:183 =# @test all(Array(interior(η)) .≈ η_answer)
                    #= none:184 =#
                end
            end
        #= none:187 =#
        for arch = archs
            #= none:189 =#
            for topo = topos_3d
                #= none:190 =#
                grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1), topology = topo)
                #= none:192 =#
                #= none:192 =# @testset "Time-stepping Rectilinear HydrostaticFreeSurfaceModels [$(arch), $(topo)]" begin
                        #= none:193 =#
                        #= none:193 =# @info "  Testing time-stepping Rectilinear HydrostaticFreeSurfaceModels [$(arch), $(topo)]..."
                        #= none:194 =#
                        #= none:194 =# @test time_step_hydrostatic_model_works(grid)
                    end
                #= none:196 =#
            end
            #= none:198 =#
            z_face_generator(; Nz = 1, p = 1, H = 1) = begin
                    #= none:198 =#
                    k->begin
                            #= none:198 =#
                            -H + (k / (Nz + 1)) ^ p
                        end
                end
            #= none:200 =#
            H = 7
            #= none:201 =#
            halo = (7, 7, 7)
            #= none:202 =#
            rectilinear_grid = RectilinearGrid(arch; size = (H, H, 1), extent = (1, 1, 1), halo)
            #= none:203 =#
            vertically_stretched_grid = RectilinearGrid(arch; size = (H, H, 1), x = (0, 1), y = (0, 1), z = z_face_generator(), halo = (H, H, H))
            #= none:205 =#
            precompute_metrics = true
            #= none:206 =#
            lat_lon_sector_grid = LatitudeLongitudeGrid(arch; size = (H, H, H), longitude = (0, 60), latitude = (15, 75), z = (-1, 0), precompute_metrics, halo)
            #= none:207 =#
            lat_lon_strip_grid = LatitudeLongitudeGrid(arch; size = (H, H, H), longitude = (-180, 180), latitude = (15, 75), z = (-1, 0), precompute_metrics, halo)
            #= none:209 =#
            z = z_face_generator()
            #= none:210 =#
            lat_lon_sector_grid_stretched = LatitudeLongitudeGrid(arch; size = (H, H, H), longitude = (0, 60), latitude = (15, 75), z, precompute_metrics, halo)
            #= none:211 =#
            lat_lon_strip_grid_stretched = LatitudeLongitudeGrid(arch; size = (H, H, H), longitude = (-180, 180), latitude = (15, 75), z, precompute_metrics, halo)
            #= none:213 =#
            grids = (rectilinear_grid, vertically_stretched_grid, lat_lon_sector_grid, lat_lon_strip_grid, lat_lon_sector_grid_stretched, lat_lon_strip_grid_stretched)
            #= none:217 =#
            free_surfaces = (ExplicitFreeSurface(), ImplicitFreeSurface(), ImplicitFreeSurface(solver_method = :HeptadiagonalIterativeSolver))
            #= none:219 =#
            for grid = grids
                #= none:220 =#
                for free_surface = free_surfaces
                    #= none:221 =#
                    topo = topology(grid)
                    #= none:222 =#
                    grid_type = (typeof(grid)).name.wrapper
                    #= none:223 =#
                    free_surface_type = (typeof(free_surface)).name.wrapper
                    #= none:224 =#
                    test_label = "[$(arch), $(grid_type), $(topo), $(free_surface_type)]"
                    #= none:225 =#
                    #= none:225 =# @testset "Time-stepping HydrostaticFreeSurfaceModels with various grids $(test_label)" begin
                            #= none:226 =#
                            #= none:226 =# @info "  Testing time-stepping HydrostaticFreeSurfaceModels with various grids $(test_label)..."
                            #= none:227 =#
                            #= none:227 =# @test time_step_hydrostatic_model_works(grid; free_surface)
                        end
                    #= none:229 =#
                end
                #= none:230 =#
            end
            #= none:232 =#
            for coriolis = (nothing, FPlane(f = 1), BetaPlane(f₀ = 1, β = 0.1))
                #= none:233 =#
                #= none:233 =# @testset "Time-stepping HydrostaticFreeSurfaceModels [$(arch), $(typeof(coriolis))]" begin
                        #= none:234 =#
                        #= none:234 =# @info "  Testing time-stepping HydrostaticFreeSurfaceModels [$(arch), $(typeof(coriolis))]..."
                        #= none:235 =#
                        #= none:235 =# @test time_step_hydrostatic_model_works(rectilinear_grid, coriolis = coriolis)
                    end
                #= none:237 =#
            end
            #= none:239 =#
            for coriolis = (nothing, HydrostaticSphericalCoriolis(scheme = EnergyConserving()), HydrostaticSphericalCoriolis(scheme = EnstrophyConserving()))
                #= none:243 =#
                #= none:243 =# @testset "Time-stepping HydrostaticFreeSurfaceModels [$(arch), $(typeof(coriolis))]" begin
                        #= none:244 =#
                        #= none:244 =# @test time_step_hydrostatic_model_works(lat_lon_sector_grid; coriolis)
                        #= none:245 =#
                        #= none:245 =# @test time_step_hydrostatic_model_works(lat_lon_strip_grid; coriolis)
                    end
                #= none:247 =#
            end
            #= none:249 =#
            for momentum_advection = (VectorInvariant(), WENOVectorInvariant(), CenteredSecondOrder(), WENO())
                #= none:250 =#
                #= none:250 =# @testset "Time-stepping HydrostaticFreeSurfaceModels [$(arch), $(typeof(momentum_advection))]" begin
                        #= none:251 =#
                        #= none:251 =# @info "  Testing time-stepping HydrostaticFreeSurfaceModels [$(arch), $(typeof(momentum_advection))]..."
                        #= none:252 =#
                        #= none:252 =# @test time_step_hydrostatic_model_works(rectilinear_grid; momentum_advection)
                    end
                #= none:254 =#
            end
            #= none:256 =#
            for momentum_advection = (VectorInvariant(), WENOVectorInvariant())
                #= none:257 =#
                #= none:257 =# @testset "Time-stepping HydrostaticFreeSurfaceModels [$(arch), $(typeof(momentum_advection))]" begin
                        #= none:258 =#
                        #= none:258 =# @info "  Testing time-stepping HydrostaticFreeSurfaceModels [$(arch), $(typeof(momentum_advection))]..."
                        #= none:259 =#
                        #= none:259 =# @test time_step_hydrostatic_model_works(lat_lon_sector_grid; momentum_advection)
                    end
                #= none:261 =#
            end
            #= none:263 =#
            for tracer_advection = [WENO(), FluxFormAdvection(WENO(), WENO(), Centered()), (b = WENO(), c = nothing)]
                #= none:267 =#
                T = typeof(tracer_advection)
                #= none:268 =#
                #= none:268 =# @testset "Time-stepping HydrostaticFreeSurfaceModels with tracer advection [$(arch), $(T)]" begin
                        #= none:269 =#
                        #= none:269 =# @info "  Testing time-stepping HydrostaticFreeSurfaceModels with tracer advection [$(arch), $(T)]..."
                        #= none:270 =#
                        #= none:270 =# @test time_step_hydrostatic_model_works(rectilinear_grid; tracer_advection, tracers = [:b, :c])
                    end
                #= none:272 =#
            end
            #= none:274 =#
            for closure = (ScalarDiffusivity(), HorizontalScalarDiffusivity(), VerticalScalarDiffusivity(), VerticalScalarDiffusivity(VerticallyImplicitTimeDiscretization()), CATKEVerticalDiffusivity(), CATKEVerticalDiffusivity(ExplicitTimeDiscretization()))
                #= none:281 =#
                #= none:281 =# @testset "Time-stepping Curvilinear HydrostaticFreeSurfaceModels [$(arch), $((typeof(closure)).name.wrapper)]" begin
                        #= none:282 =#
                        #= none:282 =# @info "  Testing time-stepping Curvilinear HydrostaticFreeSurfaceModels [$(arch), $((typeof(closure)).name.wrapper)]..."
                        #= none:283 =#
                        #= none:283 =# @test_skip time_step_hydrostatic_model_works(arch, vertically_stretched_grid, closure = closure)
                        #= none:284 =#
                        #= none:284 =# @test time_step_hydrostatic_model_works(lat_lon_sector_grid; closure)
                        #= none:285 =#
                        #= none:285 =# @test time_step_hydrostatic_model_works(lat_lon_strip_grid; closure)
                    end
                #= none:287 =#
            end
            #= none:289 =#
            closure = ScalarDiffusivity()
            #= none:290 =#
            #= none:290 =# @testset "Time-stepping Rectilinear HydrostaticFreeSurfaceModels [$(arch), $((typeof(closure)).name.wrapper)]" begin
                    #= none:291 =#
                    #= none:291 =# @info "  Testing time-stepping Rectilinear HydrostaticFreeSurfaceModels [$(arch), $((typeof(closure)).name.wrapper)]..."
                    #= none:292 =#
                    #= none:292 =# @test time_step_hydrostatic_model_works(rectilinear_grid, closure = closure)
                end
            #= none:295 =#
            #= none:295 =# @testset "Time-stepping HydrostaticFreeSurfaceModels with PrescribedVelocityFields [$(arch)]" begin
                    #= none:296 =#
                    #= none:296 =# @info "  Testing time-stepping HydrostaticFreeSurfaceModels with PrescribedVelocityFields [$(arch)]..."
                    #= none:299 =#
                    u(x, y, z, t) = begin
                            #= none:299 =#
                            1
                        end
                    #= none:300 =#
                    v(x, y, z, t) = begin
                            #= none:300 =#
                            exp(z)
                        end
                    #= none:301 =#
                    w(x, y, z, t) = begin
                            #= none:301 =#
                            sin(z)
                        end
                    #= none:302 =#
                    velocities = PrescribedVelocityFields(u = u, v = v, w = w)
                    #= none:304 =#
                    #= none:304 =# @test time_step_hydrostatic_model_works(rectilinear_grid, momentum_advection = nothing, velocities = velocities)
                    #= none:305 =#
                    #= none:305 =# @test time_step_hydrostatic_model_works(lat_lon_sector_grid, momentum_advection = nothing, velocities = velocities)
                    #= none:307 =#
                    parameters = (U = 1, m = 0.1, W = 0.001)
                    #= none:308 =#
                    u(x, y, z, t, p) = begin
                            #= none:308 =#
                            p.U
                        end
                    #= none:309 =#
                    v(x, y, z, t, p) = begin
                            #= none:309 =#
                            exp(p.m * z)
                        end
                    #= none:310 =#
                    w(x, y, z, t, p) = begin
                            #= none:310 =#
                            p.W * sin(z)
                        end
                    #= none:312 =#
                    velocities = PrescribedVelocityFields(u = u, v = v, w = w, parameters = parameters)
                    #= none:314 =#
                    #= none:314 =# @test time_step_hydrostatic_model_works(rectilinear_grid, momentum_advection = nothing, velocities = velocities)
                    #= none:315 =#
                    #= none:315 =# @test time_step_hydrostatic_model_works(lat_lon_sector_grid, momentum_advection = nothing, velocities = velocities)
                end
            #= none:318 =#
            #= none:318 =# @testset "HydrostaticFreeSurfaceModel with tracers and forcings [$(arch)]" begin
                    #= none:319 =#
                    #= none:319 =# @info "  Testing HydrostaticFreeSurfaceModel with tracers and forcings [$(arch)]..."
                    #= none:320 =#
                    hydrostatic_free_surface_model_tracers_and_forcings_work(arch)
                end
            #= none:324 =#
            #= none:324 =# @testset "HydrostaticFreeSurfaceModel with Float32 CATKE [$(arch)]" begin
                    #= none:325 =#
                    #= none:325 =# @info "  Testing HydrostaticFreeSurfaceModel with Float32 CATKE [$(arch)]..."
                    #= none:326 =#
                    #= none:326 =# @test time_step_hydrostatic_model_with_catke_works(arch, Float32)
                end
            #= none:328 =#
        end
    end