
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Models.ShallowWaterModels
#= none:4 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid, GridFittedBoundary
#= none:6 =#
function time_stepping_shallow_water_model_works(arch, topo, coriolis, advection; timestepper = :RungeKutta3)
    #= none:6 =#
    #= none:7 =#
    grid = RectilinearGrid(arch, size = (3, 3), extent = (2π, 2π), topology = topo)
    #= none:8 =#
    model = ShallowWaterModel(grid = grid, gravitational_acceleration = 1, coriolis = coriolis, momentum_advection = advection, timestepper = :RungeKutta3)
    #= none:10 =#
    set!(model, h = 1)
    #= none:12 =#
    simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
    #= none:13 =#
    run!(simulation)
    #= none:15 =#
    return model.clock.iteration == 1
end
#= none:18 =#
function time_step_wizard_shallow_water_model_works(arch, topo, coriolis)
    #= none:18 =#
    #= none:19 =#
    grid = RectilinearGrid(arch, size = (3, 3), extent = (2π, 2π), topology = topo)
    #= none:20 =#
    model = ShallowWaterModel(grid = grid, gravitational_acceleration = 1, coriolis = coriolis)
    #= none:21 =#
    set!(model, h = 1)
    #= none:23 =#
    simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
    #= none:24 =#
    wizard = TimeStepWizard(cfl = 1.0, max_change = 1.1, max_Δt = 10)
    #= none:25 =#
    simulation.callbacks[:wizard] = Callback(wizard)
    #= none:26 =#
    run!(simulation)
    #= none:28 =#
    return model.clock.iteration == 1
end
#= none:31 =#
function shallow_water_model_tracers_and_forcings_work(arch)
    #= none:31 =#
    #= none:32 =#
    grid = RectilinearGrid(arch, size = (3, 3), extent = (2π, 2π), topology = (Periodic, Periodic, Flat))
    #= none:33 =#
    model = ShallowWaterModel(grid = grid, gravitational_acceleration = 1, tracers = (:c, :d))
    #= none:34 =#
    set!(model, h = 1)
    #= none:36 =#
    #= none:36 =# @test model.tracers.c isa Field
    #= none:37 =#
    #= none:37 =# @test model.tracers.d isa Field
    #= none:39 =#
    #= none:39 =# @test haskey(model.forcing, :uh)
    #= none:40 =#
    #= none:40 =# @test haskey(model.forcing, :vh)
    #= none:41 =#
    #= none:41 =# @test haskey(model.forcing, :h)
    #= none:42 =#
    #= none:42 =# @test haskey(model.forcing, :c)
    #= none:43 =#
    #= none:43 =# @test haskey(model.forcing, :d)
    #= none:45 =#
    simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
    #= none:46 =#
    run!(simulation)
    #= none:48 =#
    #= none:48 =# @test model.clock.iteration == 1
    #= none:50 =#
    return nothing
end
#= none:53 =#
function test_shallow_water_diffusion_cosine(grid, formulation, fieldname, ξ)
    #= none:53 =#
    #= none:54 =#
    (ν, m) = (1, 2)
    #= none:56 =#
    closure = ShallowWaterScalarDiffusivity(; ν)
    #= none:57 =#
    momentum_advection = nothing
    #= none:58 =#
    tracer_advection = nothing
    #= none:59 =#
    mass_advection = nothing
    #= none:61 =#
    model = ShallowWaterModel(; grid, closure, gravitational_acceleration = 1.0, momentum_advection, tracer_advection, mass_advection, formulation)
    #= none:66 =#
    field = model.velocities[fieldname]
    #= none:68 =#
    interior(field) .= on_architecture(architecture(grid), cos.(m * ξ))
    #= none:69 =#
    update_state!(model)
    #= none:72 =#
    Δt = (1.0e-6 * grid.Lx ^ 2) / closure.ν
    #= none:73 =#
    for _ = 1:5
        #= none:74 =#
        time_step!(model, Δt)
        #= none:75 =#
    end
    #= none:77 =#
    diffusing_cosine(ξ, t, κ, m) = begin
            #= none:77 =#
            exp(-κ * m ^ 2 * t) * cos(m * ξ)
        end
    #= none:78 =#
    analytical_solution = Field(location(field), grid)
    #= none:79 =#
    analytical_solution .= diffusing_cosine.(ξ, model.clock.time, ν, m)
    #= none:81 =#
    return isapprox(field, analytical_solution, atol = 1.0e-6, rtol = 1.0e-6)
end
#= none:84 =#
#= none:84 =# @testset "Shallow Water Models" begin
        #= none:85 =#
        #= none:85 =# @info "Testing shallow water models..."
        #= none:87 =#
        #= none:87 =# @testset "Must be Flat in the vertical" begin
                #= none:88 =#
                grid = RectilinearGrid(size = (1, 1, 1), extent = (1, 1, 1), topology = (Periodic, Periodic, Bounded))
                #= none:89 =#
                #= none:89 =# @test_throws ArgumentError ShallowWaterModel(grid = grid, gravitational_acceleration = 1)
                #= none:91 =#
                grid = RectilinearGrid(size = (1, 1, 1), extent = (1, 1, 1), topology = (Periodic, Periodic, Periodic))
                #= none:92 =#
                #= none:92 =# @test_throws ArgumentError ShallowWaterModel(grid = grid, gravitational_acceleration = 1)
            end
        #= none:95 =#
        #= none:95 =# @testset "Model constructor errors" begin
                #= none:96 =#
                grid = RectilinearGrid(size = (1, 1), extent = (1, 1), topology = (Periodic, Periodic, Flat))
                #= none:97 =#
                #= none:97 =# @test_throws MethodError ShallowWaterModel(architecture = CPU, grid = grid, gravitational_acceleration = 1)
                #= none:98 =#
                #= none:98 =# @test_throws MethodError ShallowWaterModel(architecture = GPU, grid = grid, gravitational_acceleration = 1)
            end
        #= none:101 =#
        topo = (Flat, Flat, Flat)
        #= none:103 =#
        #= none:103 =# @testset "$(topo) model construction" begin
                #= none:104 =#
                #= none:104 =# @info "  Testing $(topo) model construction..."
                #= none:105 =#
                for arch = archs, FT = float_types
                    #= none:106 =#
                    grid = RectilinearGrid(arch, FT, topology = topo, size = (), extent = ())
                    #= none:107 =#
                    model = ShallowWaterModel(grid = grid, gravitational_acceleration = 1)
                    #= none:109 =#
                    #= none:109 =# @test model isa ShallowWaterModel
                    #= none:110 =#
                end
            end
        #= none:113 =#
        topos = ((Bounded, Flat, Flat), (Flat, Bounded, Flat))
        #= none:118 =#
        for topo = topos
            #= none:119 =#
            #= none:119 =# @testset "$(topo) model construction" begin
                    #= none:120 =#
                    #= none:120 =# @info "  Testing $(topo) model construction..."
                    #= none:121 =#
                    for arch = archs, FT = float_types
                        #= none:124 =#
                        grid = RectilinearGrid(arch, FT, topology = topo, size = 3, extent = 1, halo = 3)
                        #= none:125 =#
                        model = ShallowWaterModel(grid = grid, gravitational_acceleration = 1)
                        #= none:127 =#
                        #= none:127 =# @test model isa ShallowWaterModel
                        #= none:128 =#
                    end
                end
            #= none:130 =#
        end
        #= none:132 =#
        topos = ((Periodic, Periodic, Flat), (Periodic, Bounded, Flat), (Bounded, Bounded, Flat))
        #= none:138 =#
        for topo = topos
            #= none:139 =#
            #= none:139 =# @testset "$(topo) model construction" begin
                    #= none:140 =#
                    #= none:140 =# @info "  Testing $(topo) model construction..."
                    #= none:141 =#
                    for arch = archs, FT = float_types
                        #= none:144 =#
                        grid = RectilinearGrid(arch, FT, topology = topo, size = (3, 3), extent = (1, 2), halo = (3, 3))
                        #= none:145 =#
                        model = ShallowWaterModel(grid = grid, gravitational_acceleration = 1)
                        #= none:147 =#
                        #= none:147 =# @test model isa ShallowWaterModel
                        #= none:148 =#
                    end
                end
            #= none:150 =#
        end
        #= none:152 =#
        #= none:152 =# @testset "Setting ShallowWaterModel fields" begin
                #= none:153 =#
                #= none:153 =# @info "  Testing setting shallow water model fields..."
                #= none:155 =#
                for arch = archs, FT = float_types
                    #= none:156 =#
                    N = (4, 4)
                    #= none:157 =#
                    L = (2π, 3π)
                    #= none:159 =#
                    grid = RectilinearGrid(arch, FT, size = N, extent = L, topology = (Periodic, Periodic, Flat), halo = (3, 3))
                    #= none:160 =#
                    model = ShallowWaterModel(grid = grid, gravitational_acceleration = 1)
                    #= none:162 =#
                    (x, y, z) = nodes(model.grid, (Face(), Center(), Center()), reshape = true)
                    #= none:164 =#
                    uh₀(x, y) = begin
                            #= none:164 =#
                            x * y ^ 2
                        end
                    #= none:165 =#
                    uh_answer = #= none:165 =# @__dot__(x * y ^ 2)
                    #= none:167 =#
                    h₀ = rand(size(grid)...)
                    #= none:168 =#
                    h_answer = deepcopy(h₀)
                    #= none:170 =#
                    set!(model, uh = uh₀, h = h₀)
                    #= none:172 =#
                    (uh, vh, h) = model.solution
                    #= none:174 =#
                    #= none:174 =# @test all(Array(interior(uh)) .≈ uh_answer)
                    #= none:175 =#
                    #= none:175 =# @test all(Array(interior(h)) .≈ h_answer)
                    #= none:176 =#
                end
            end
        #= none:179 =#
        for arch = archs
            #= none:180 =#
            for topo = topos
                #= none:181 =#
                #= none:181 =# @testset "Time-stepping ShallowWaterModels [$(arch), $(topo)]" begin
                        #= none:182 =#
                        #= none:182 =# @info "  Testing time-stepping ShallowWaterModels [$(arch), $(topo)]..."
                        #= none:183 =#
                        #= none:183 =# @test time_stepping_shallow_water_model_works(arch, topo, nothing, nothing)
                    end
                #= none:185 =#
            end
            #= none:187 =#
            for coriolis = (nothing, FPlane(f = 1), BetaPlane(f₀ = 1, β = 0.1))
                #= none:188 =#
                #= none:188 =# @testset "Time-stepping ShallowWaterModels [$(arch), $(typeof(coriolis))]" begin
                        #= none:189 =#
                        #= none:189 =# @info "  Testing time-stepping ShallowWaterModels [$(arch), $(typeof(coriolis))]..."
                        #= none:190 =#
                        #= none:190 =# @test time_stepping_shallow_water_model_works(arch, topos[1], coriolis, nothing)
                    end
                #= none:192 =#
            end
            #= none:194 =#
            #= none:194 =# @testset "Time-step Wizard ShallowWaterModels [$(arch), $(topos)[1]]" begin
                    #= none:195 =#
                    #= none:195 =# @info "  Testing time-step wizard ShallowWaterModels [$(arch), $(topos)[1]]..."
                    #= none:196 =#
                    #= none:196 =# @test time_step_wizard_shallow_water_model_works(archs[1], topos[1], nothing)
                end
            #= none:200 =#
            for advection = (nothing, CenteredSecondOrder(), WENO())
                #= none:201 =#
                #= none:201 =# @testset "Time-stepping ShallowWaterModels [$(arch), $(typeof(advection))]" begin
                        #= none:202 =#
                        #= none:202 =# @info "  Testing time-stepping ShallowWaterModels [$(arch), $(typeof(advection))]..."
                        #= none:203 =#
                        #= none:203 =# @test time_stepping_shallow_water_model_works(arch, topos[1], nothing, advection)
                    end
                #= none:205 =#
            end
            #= none:207 =#
            for timestepper = (:RungeKutta3, :QuasiAdamsBashforth2)
                #= none:208 =#
                #= none:208 =# @testset "Time-stepping ShallowWaterModels [$(arch), $(timestepper)]" begin
                        #= none:209 =#
                        #= none:209 =# @info "  Testing time-stepping ShallowWaterModels [$(arch), $(timestepper)]..."
                        #= none:210 =#
                        #= none:210 =# @test time_stepping_shallow_water_model_works(arch, topos[1], nothing, nothing, timestepper = timestepper)
                    end
                #= none:212 =#
            end
            #= none:214 =#
            #= none:214 =# @testset "ShallowWaterModel with tracers and forcings [$(arch)]" begin
                    #= none:215 =#
                    #= none:215 =# @info "  Testing ShallowWaterModel with tracers and forcings [$(arch)]..."
                    #= none:216 =#
                    shallow_water_model_tracers_and_forcings_work(arch)
                end
            #= none:219 =#
            #= none:219 =# @testset "ShallowWaterModel viscous diffusion [$(arch)]" begin
                    #= none:220 =#
                    (Nx, Ny) = (10, 12)
                    #= none:221 =#
                    grid_x = RectilinearGrid(arch, size = Nx, x = (0, 1), topology = (Bounded, Flat, Flat))
                    #= none:222 =#
                    grid_y = RectilinearGrid(arch, size = Ny, y = (0, 1), topology = (Flat, Bounded, Flat))
                    #= none:223 =#
                    coords = (reshape(xnodes(grid_x, Face()), (Nx + 1, 1)), reshape(ynodes(grid_y, Face()), (1, Ny + 1)))
                    #= none:225 =#
                    for (fieldname, grid, coord) = zip([:u, :v], [grid_x, grid_y], coords)
                        #= none:226 =#
                        for formulation = (ConservativeFormulation(), VectorInvariantFormulation())
                            #= none:227 =#
                            #= none:227 =# @info "  Testing ShallowWaterModel cosine viscous diffusion [$(fieldname), $(formulation)]"
                            #= none:228 =#
                            test_shallow_water_diffusion_cosine(grid, formulation, fieldname, coord)
                            #= none:229 =#
                        end
                        #= none:230 =#
                    end
                end
            #= none:232 =#
        end
        #= none:234 =#
        #= none:234 =# @testset "ShallowWaterModels with ImmersedBoundaryGrid" begin
                #= none:235 =#
                for arch = archs
                    #= none:236 =#
                    #= none:236 =# @testset "ShallowWaterModels with ImmersedBoundaryGrid [$(arch)]" begin
                            #= none:237 =#
                            #= none:237 =# @info "Testing ShallowWaterModels with ImmersedBoundaryGrid [$(arch)]"
                            #= none:240 =#
                            bump(x, y) = begin
                                    #= none:240 =#
                                    y < exp(-(x ^ 2))
                                end
                            #= none:241 =#
                            grid = RectilinearGrid(arch, size = (8, 8), x = (-10, 10), y = (0, 5), topology = (Periodic, Bounded, Flat))
                            #= none:242 =#
                            grid_with_bump = ImmersedBoundaryGrid(grid, GridFittedBoundary(bump))
                            #= none:244 =#
                            #= none:244 =# @test_throws ArgumentError model = ShallowWaterModel(grid = grid_with_bump, gravitational_acceleration = 1)
                            #= none:246 =#
                            grid = RectilinearGrid(arch, size = (8, 8), x = (-10, 10), y = (0, 5), topology = (Periodic, Bounded, Flat), halo = (4, 4))
                            #= none:247 =#
                            grid_with_bump = ImmersedBoundaryGrid(grid, GridFittedBoundary(bump))
                            #= none:249 =#
                            model = ShallowWaterModel(grid = grid_with_bump, gravitational_acceleration = 1)
                            #= none:251 =#
                            set!(model, h = 1)
                            #= none:252 =#
                            simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
                            #= none:253 =#
                            run!(simulation)
                            #= none:255 =#
                            #= none:255 =# @test model.clock.iteration == 1
                        end
                    #= none:257 =#
                end
            end
    end