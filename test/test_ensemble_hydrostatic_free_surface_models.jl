
#= none:1 =#
using Test
#= none:2 =#
using Oceananigans
#= none:3 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: ColumnEnsembleSize, SliceEnsembleSize
#= none:4 =#
using Oceananigans.TurbulenceClosures: ConvectiveAdjustmentVerticalDiffusivity
#= none:5 =#
const CAVD = ConvectiveAdjustmentVerticalDiffusivity
#= none:7 =#
#= none:7 =# @testset "`HydrostaticFreeSurfaceModel` using a `SingleColumnGrid`" begin
        #= none:9 =#
        Nz = 3
        #= none:10 =#
        Hz = 1
        #= none:11 =#
        single_column_topology = (Flat, Flat, Bounded)
        #= none:12 =#
        periodic_topology = (Periodic, Periodic, Bounded)
        #= none:14 =#
        single_column_grid = RectilinearGrid(; size = Nz, z = (-1, 0), topology = single_column_topology, halo = Hz)
        #= none:15 =#
        periodic_grid = RectilinearGrid(; size = (1, 1, Nz), x = (0, 1), y = (0, 1), z = (-1, 0), topology = periodic_topology, halo = (1, 1, Hz))
        #= none:16 =#
        coriolis = FPlane(f = 0.2)
        #= none:17 =#
        closure = CAVD(background_κz = 1.0)
        #= none:19 =#
        Δt = 0.01
        #= none:21 =#
        model_kwargs = (; tracers = :c, buoyancy = nothing, closure, coriolis)
        #= none:22 =#
        simulation_kwargs = (; Δt, stop_iteration = 100)
        #= none:24 =#
        sic_model = HydrostaticFreeSurfaceModel(; grid = single_column_grid, model_kwargs...)
        #= none:25 =#
        per_model = HydrostaticFreeSurfaceModel(; grid = periodic_grid, model_kwargs...)
        #= none:27 =#
        set!(sic_model, c = (z->begin
                        #= none:27 =#
                        exp(-(z ^ 2))
                    end), u = 1, v = 1)
        #= none:28 =#
        set!(per_model, c = ((x, y, z)->begin
                        #= none:28 =#
                        exp(-(z ^ 2))
                    end), u = 1, v = 1)
        #= none:30 =#
        sic_simulation = Simulation(sic_model; simulation_kwargs...)
        #= none:31 =#
        per_simulation = Simulation(per_model; simulation_kwargs...)
        #= none:32 =#
        run!(sic_simulation)
        #= none:33 =#
        run!(per_simulation)
        #= none:35 =#
        #= none:35 =# @info "Testing Single column grid results..."
        #= none:37 =#
        #= none:37 =# @test all(sic_model.velocities.u.data[1, 1, :] .≈ per_model.velocities.u.data[1, 1, :])
        #= none:38 =#
        #= none:38 =# @test all(sic_model.velocities.v.data[1, 1, :] .≈ per_model.velocities.v.data[1, 1, :])
        #= none:39 =#
        #= none:39 =# @test all(sic_model.tracers.c.data[1, 1, :] .≈ per_model.tracers.c.data[1, 1, :])
    end
#= none:42 =#
#= none:42 =# @testset "Ensembles of `HydrostaticFreeSurfaceModel` with different closures" begin
        #= none:44 =#
        Nz = 16
        #= none:45 =#
        Hz = 1
        #= none:46 =#
        topology = (Flat, Flat, Bounded)
        #= none:47 =#
        grid = RectilinearGrid(; size = Nz, z = (-10, 10), topology, halo = Hz)
        #= none:49 =#
        closures = [CAVD(background_κz = 1.0) CAVD(background_κz = 1.1); CAVD(background_κz = 1.2) CAVD(background_κz = 1.3); CAVD(background_κz = 1.4) CAVD(background_κz = 1.5)]
        #= none:53 =#
        ensemble_size = size(closures)
        #= none:55 =#
        #= none:55 =# @test size(closures) == (3, 2)
        #= none:56 =#
        #= none:56 =# @test (closures[2, 1]).background_κz == 1.2
        #= none:58 =#
        Δt = 0.01 * grid.Δzᵃᵃᶜ ^ 2
        #= none:60 =#
        model_kwargs = (; tracers = :c, buoyancy = nothing, coriolis = nothing)
        #= none:61 =#
        simulation_kwargs = (; Δt, stop_iteration = 100)
        #= none:63 =#
        models = [HydrostaticFreeSurfaceModel(; grid, closure = closures[i, j], model_kwargs...) for i = 1:ensemble_size[1], j = 1:ensemble_size[2]]
        #= none:66 =#
        set_ic!(model) = begin
                #= none:66 =#
                set!(model, c = (z->begin
                                #= none:66 =#
                                exp(-(z ^ 2))
                            end))
            end
        #= none:68 =#
        for model = models
            #= none:69 =#
            set_ic!(model)
            #= none:70 =#
            simulation = Simulation(model; simulation_kwargs...)
            #= none:71 =#
            run!(simulation)
            #= none:72 =#
        end
        #= none:74 =#
        ensemble_grid = RectilinearGrid(; size = ColumnEnsembleSize(; Nz, ensemble = ensemble_size, Hz), z = (-10, 10), topology, halo = Hz)
        #= none:77 =#
        #= none:77 =# @test size(ensemble_grid) == (ensemble_size[1], ensemble_size[2], Nz)
        #= none:79 =#
        ensemble_model = HydrostaticFreeSurfaceModel(; grid = ensemble_grid, closure = closures, model_kwargs...)
        #= none:80 =#
        set_ic!(ensemble_model)
        #= none:82 =#
        #= none:82 =# @test size(parent(ensemble_model.tracers.c)) == (ensemble_size[1], ensemble_size[2], Nz + 2)
        #= none:84 =#
        ensemble_simulation = Simulation(ensemble_model; simulation_kwargs...)
        #= none:85 =#
        run!(ensemble_simulation)
        #= none:87 =#
        for i = 1:ensemble_size[1], j = 1:ensemble_size[2]
            #= none:88 =#
            #= none:88 =# @info "Testing ConvectiveAdjustmentVerticalDiffusivity ensemble member ($(i), $(j))..."
            #= none:89 =#
            #= none:89 =# @test (parent(ensemble_model.tracers.c))[i, j, :] == (parent((models[i, j]).tracers.c))[1, 1, :]
            #= none:90 =#
        end
    end
#= none:94 =#
#= none:94 =# @testset "Ensembles of column `HydrostaticFreeSurfaceModel`s with different Coriolis parameters" begin
        #= none:96 =#
        Nz = 3
        #= none:97 =#
        Hz = 1
        #= none:98 =#
        topology = (Flat, Flat, Bounded)
        #= none:100 =#
        grid = RectilinearGrid(; size = Nz, z = (-1, 0), topology, halo = Hz)
        #= none:102 =#
        coriolises = [FPlane(f = 0.2) FPlane(f = -0.4) FPlane(f = -1.1); FPlane(f = 1.1) FPlane(f = 1.2) FPlane(f = 1.3)]
        #= none:105 =#
        ensemble_size = size(coriolises)
        #= none:107 =#
        Δt = 0.01
        #= none:109 =#
        #= none:109 =# @test size(coriolises) == (2, 3)
        #= none:110 =#
        #= none:110 =# @test (coriolises[2, 2]).f == 1.2
        #= none:112 =#
        model_kwargs = (; tracers = nothing, buoyancy = nothing, closure = nothing)
        #= none:113 =#
        simulation_kwargs = (; Δt, stop_iteration = 100)
        #= none:115 =#
        models = [HydrostaticFreeSurfaceModel(; grid, coriolis = coriolises[i, j], model_kwargs...) for i = 1:ensemble_size[1], j = 1:ensemble_size[2]]
        #= none:118 =#
        set_ic!(model) = begin
                #= none:118 =#
                set!(model, u = 1, v = 1)
            end
        #= none:120 =#
        for model = models
            #= none:121 =#
            set_ic!(model)
            #= none:122 =#
            simulation = Simulation(model; simulation_kwargs...)
            #= none:123 =#
            run!(simulation)
            #= none:124 =#
        end
        #= none:126 =#
        ensemble_grid = RectilinearGrid(size = ColumnEnsembleSize(Nz = Nz, ensemble = ensemble_size, Hz = Hz); z = (-1, 0), topology, halo = Hz)
        #= none:128 =#
        ensemble_model = HydrostaticFreeSurfaceModel(; grid = ensemble_grid, coriolis = coriolises, model_kwargs...)
        #= none:129 =#
        set_ic!(ensemble_model)
        #= none:130 =#
        ensemble_simulation = Simulation(ensemble_model; simulation_kwargs...)
        #= none:131 =#
        run!(ensemble_simulation)
        #= none:133 =#
        for i = 1:ensemble_size[1], j = 1:ensemble_size[2]
            #= none:134 =#
            #= none:134 =# @info "Testing Coriolis ensemble member ($(i), $(j)) with $(coriolises[i, j])..."
            #= none:135 =#
            #= none:135 =# @test ensemble_model.coriolis[i, j] == coriolises[i, j]
            #= none:137 =#
            #= none:137 =# @show parent(ensemble_model.velocities.u.data[i, j, :])
            #= none:139 =#
            #= none:139 =# @test all(ensemble_model.velocities.u.data[i, j, :] .≈ (models[i, j]).velocities.u.data[1, 1, :])
            #= none:141 =#
            #= none:141 =# @show parent(ensemble_model.velocities.v.data[i, j, :])
            #= none:143 =#
            #= none:143 =# @test all(ensemble_model.velocities.v.data[i, j, :] .≈ (models[i, j]).velocities.v.data[1, 1, :])
            #= none:144 =#
        end
    end
#= none:148 =#
#= none:148 =# @testset "Ensembles of slice `HydrostaticFreeSurfaceModel`s with different Coriolis parameters" begin
        #= none:150 =#
        (Ny, Nz) = (4, 2)
        #= none:151 =#
        (Hy, Hz) = (1, 1)
        #= none:152 =#
        topology = (Flat, Periodic, Bounded)
        #= none:154 =#
        grid = RectilinearGrid(; size = (Ny, Nz), y = (-10, 10), z = (-1, 0), topology, halo = (Hy, Hz))
        #= none:156 =#
        coriolises = [FPlane(f = 1.0), FPlane(f = 1.1), FPlane(f = 1.2)]
        #= none:158 =#
        ensemble_size = size(coriolises)
        #= none:160 =#
        Δt = 0.01
        #= none:162 =#
        #= none:162 =# @test length(coriolises) == 3
        #= none:163 =#
        #= none:163 =# @test (coriolises[2]).f == 1.1
        #= none:165 =#
        model_kwargs = (; tracers = nothing, buoyancy = nothing, closure = nothing)
        #= none:166 =#
        simulation_kwargs = (; Δt, stop_iteration = 100)
        #= none:168 =#
        models = [HydrostaticFreeSurfaceModel(; grid, coriolis = coriolises[i], model_kwargs...) for i = 1:ensemble_size[1]]
        #= none:170 =#
        set_ic!(model) = begin
                #= none:170 =#
                set!(model, u = sqrt(2), v = sqrt(2))
            end
        #= none:172 =#
        for model = models
            #= none:173 =#
            set_ic!(model)
            #= none:174 =#
            simulation = Simulation(model; simulation_kwargs...)
            #= none:175 =#
            run!(simulation)
            #= none:176 =#
        end
        #= none:178 =#
        ensemble_grid = RectilinearGrid(; size = SliceEnsembleSize(size = (Ny, Nz), ensemble = ensemble_size[1]), y = (-10, 10), z = (-1, 0), topology, halo = (Hy, Hz))
        #= none:180 =#
        ensemble_model = HydrostaticFreeSurfaceModel(; grid = ensemble_grid, coriolis = coriolises, model_kwargs...)
        #= none:181 =#
        set_ic!(ensemble_model)
        #= none:182 =#
        ensemble_simulation = Simulation(ensemble_model; simulation_kwargs...)
        #= none:183 =#
        run!(ensemble_simulation)
        #= none:185 =#
        for i = 1:ensemble_size[1]
            #= none:186 =#
            #= none:186 =# @info "Testing Coriolis ensemble member ($(i),) with $(coriolises[i])..."
            #= none:187 =#
            #= none:187 =# @test ensemble_model.coriolis[i] == coriolises[i]
            #= none:189 =#
            #= none:189 =# @show (parent(ensemble_model.velocities.u))[i, :, :]
            #= none:191 =#
            #= none:191 =# @test (parent(ensemble_model.velocities.u))[i, :, :] == (parent((models[i]).velocities.u))[1, :, :]
            #= none:193 =#
            #= none:193 =# @show (parent(ensemble_model.velocities.v))[i, :, :]
            #= none:195 =#
            #= none:195 =# @test (parent(ensemble_model.velocities.v))[i, :, :] == (parent((models[i]).velocities.v))[1, :, :]
            #= none:196 =#
        end
    end