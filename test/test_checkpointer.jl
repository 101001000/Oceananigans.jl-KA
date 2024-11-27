
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:2 =#
using Oceananigans: prognostic_fields
#= none:3 =#
using Glob
#= none:9 =#
function test_model_equality(test_model, true_model)
    #= none:9 =#
    #= none:10 =#
    #= none:10 =# CUDA.@allowscalar begin
            #= none:11 =#
            test_model_fields = prognostic_fields(test_model)
            #= none:12 =#
            true_model_fields = prognostic_fields(true_model)
            #= none:13 =#
            field_names = keys(test_model_fields)
            #= none:15 =#
            for name = field_names
                #= none:16 =#
                #= none:16 =# @test all((test_model_fields[name]).data .≈ (true_model_fields[name]).data)
                #= none:17 =#
                #= none:17 =# @test all((test_model.timestepper.Gⁿ[name]).data .≈ (true_model.timestepper.Gⁿ[name]).data)
                #= none:18 =#
                #= none:18 =# @test all((test_model.timestepper.G⁻[name]).data .≈ (true_model.timestepper.G⁻[name]).data)
                #= none:19 =#
            end
        end
    #= none:22 =#
    return nothing
end
#= none:25 =#
#= none:25 =# Core.@doc " Set up a simple simulation to test picking up from a checkpoint. " function initialization_test_simulation(arch, stop_time, Δt = 1, δt = 2)
        #= none:26 =#
        #= none:27 =#
        grid = RectilinearGrid(arch, size = (), topology = (Flat, Flat, Flat))
        #= none:28 =#
        model = NonhydrostaticModel(; grid)
        #= none:29 =#
        simulation = Simulation(model; Δt, stop_time)
        #= none:31 =#
        progress_message(sim) = begin
                #= none:31 =#
                #= none:31 =# @info string("Iter: ", iteration(sim), ", time: ", prettytime(sim))
            end
        #= none:32 =#
        simulation.callbacks[:progress] = Callback(progress_message, TimeInterval(δt))
        #= none:34 =#
        checkpointer = Checkpointer(model, schedule = TimeInterval(stop_time), prefix = "initialization_test", cleanup = false)
        #= none:39 =#
        simulation.output_writers[:checkpointer] = checkpointer
        #= none:41 =#
        return simulation
    end
#= none:44 =#
#= none:44 =# Core.@doc "Run two coarse rising thermal bubble simulations and make sure\n\n1. When restarting from a checkpoint, the restarted model matches the non-restarted\n   model to machine precision.\n\n2. When using set!(test_model) to a checkpoint, the new model matches the non-restarted\n   simulation to machine precision.\n\n3. run!(test_model, pickup) works as expected\n" function test_thermal_bubble_checkpointer_output(arch)
        #= none:55 =#
        #= none:57 =#
        (Nx, Ny, Nz) = (16, 16, 16)
        #= none:58 =#
        (Lx, Ly, Lz) = (100, 100, 100)
        #= none:59 =#
        Δt = 6
        #= none:61 =#
        grid = RectilinearGrid(arch, size = (Nx, Ny, Nz), extent = (Lx, Ly, Lz))
        #= none:62 =#
        closure = ScalarDiffusivity(ν = 0.04, κ = 0.04)
        #= none:63 =#
        true_model = NonhydrostaticModel(; grid, closure, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
        #= none:64 =#
        test_model = deepcopy(true_model)
        #= none:68 =#
        (i1, i2) = (round(Int, Nx / 4), round(Int, (3Nx) / 4))
        #= none:69 =#
        (j1, j2) = (round(Int, Ny / 4), round(Int, (3Ny) / 4))
        #= none:70 =#
        (k1, k2) = (round(Int, Nz / 4), round(Int, (3Nz) / 4))
        #= none:71 =#
        view(true_model.tracers.T, i1:i2, j1:j2, k1:k2) .+= 0.01
        #= none:73 =#
        return run_checkpointer_tests(true_model, test_model, Δt)
    end
#= none:76 =#
function test_hydrostatic_splash_checkpointer(arch, free_surface)
    #= none:76 =#
    #= none:78 =#
    (Nx, Ny, Nz) = (16, 16, 4)
    #= none:79 =#
    (Lx, Ly, Lz) = (1, 1, 1)
    #= none:81 =#
    grid = RectilinearGrid(arch, size = (Nx, Ny, Nz), x = (-10, 10), y = (-10, 10), z = (-1, 0))
    #= none:82 =#
    closure = ScalarDiffusivity(ν = 0.01, κ = 0.01)
    #= none:83 =#
    true_model = HydrostaticFreeSurfaceModel(; grid, free_surface, closure, buoyancy = nothing, tracers = ())
    #= none:84 =#
    test_model = deepcopy(true_model)
    #= none:86 =#
    ηᵢ(x, y, z) = begin
            #= none:86 =#
            0.1 * exp(-(x ^ 2) - y ^ 2)
        end
    #= none:87 =#
    ϵᵢ(x, y, z) = begin
            #= none:87 =#
            1.0e-6 * randn()
        end
    #= none:88 =#
    set!(true_model, η = ηᵢ, u = ϵᵢ, v = ϵᵢ)
    #= none:90 =#
    return run_checkpointer_tests(true_model, test_model, 1.0e-6)
end
#= none:93 =#
function run_checkpointer_tests(true_model, test_model, Δt)
    #= none:93 =#
    #= none:94 =#
    true_simulation = Simulation(true_model, Δt = Δt, stop_iteration = 5)
    #= none:96 =#
    checkpointer = Checkpointer(true_model, schedule = IterationInterval(5), overwrite_existing = true)
    #= none:97 =#
    push!(true_simulation.output_writers, checkpointer)
    #= none:99 =#
    run!(true_simulation)
    #= none:101 =#
    checkpointed_model = deepcopy(true_simulation.model)
    #= none:103 =#
    true_simulation.stop_iteration = 9
    #= none:104 =#
    run!(true_simulation)
    #= none:110 =#
    set!(test_model, "checkpoint_iteration5.jld2")
    #= none:112 =#
    #= none:112 =# @test test_model.clock.iteration == checkpointed_model.clock.iteration
    #= none:113 =#
    #= none:113 =# @test test_model.clock.time == checkpointed_model.clock.time
    #= none:114 =#
    test_model_equality(test_model, checkpointed_model)
    #= none:117 =#
    #= none:117 =# @test test_model.clock.last_Δt == checkpointed_model.clock.last_Δt
    #= none:123 =#
    test_simulation = Simulation(test_model, Δt = Δt, stop_iteration = 9)
    #= none:126 =#
    run!(test_simulation, pickup = "checkpoint_iteration0.jld2")
    #= none:128 =#
    #= none:128 =# @info "Testing model equality when running with pickup=checkpoint_iteration0.jld2."
    #= none:129 =#
    #= none:129 =# @test test_simulation.model.clock.iteration == true_simulation.model.clock.iteration
    #= none:130 =#
    #= none:130 =# @test test_simulation.model.clock.time == true_simulation.model.clock.time
    #= none:131 =#
    test_model_equality(test_model, true_model)
    #= none:133 =#
    run!(test_simulation, pickup = "checkpoint_iteration5.jld2")
    #= none:134 =#
    #= none:134 =# @info "Testing model equality when running with pickup=checkpoint_iteration5.jld2."
    #= none:136 =#
    #= none:136 =# @test test_simulation.model.clock.iteration == true_simulation.model.clock.iteration
    #= none:137 =#
    #= none:137 =# @test test_simulation.model.clock.time == true_simulation.model.clock.time
    #= none:138 =#
    test_model_equality(test_model, true_model)
    #= none:145 =#
    test_simulation.output_writers[:checkpointer] = Checkpointer(test_model, schedule = IterationInterval(5), overwrite_existing = true)
    #= none:148 =#
    run!(test_simulation, pickup = true)
    #= none:149 =#
    #= none:149 =# @info "    Testing model equality when running with pickup=true."
    #= none:151 =#
    #= none:151 =# @test test_simulation.model.clock.iteration == true_simulation.model.clock.iteration
    #= none:152 =#
    #= none:152 =# @test test_simulation.model.clock.time == true_simulation.model.clock.time
    #= none:153 =#
    test_model_equality(test_model, true_model)
    #= none:155 =#
    run!(test_simulation, pickup = 0)
    #= none:156 =#
    #= none:156 =# @info "    Testing model equality when running with pickup=0."
    #= none:158 =#
    #= none:158 =# @test test_simulation.model.clock.iteration == true_simulation.model.clock.iteration
    #= none:159 =#
    #= none:159 =# @test test_simulation.model.clock.time == true_simulation.model.clock.time
    #= none:160 =#
    test_model_equality(test_model, true_model)
    #= none:162 =#
    run!(test_simulation, pickup = 5)
    #= none:163 =#
    #= none:163 =# @info "    Testing model equality when running with pickup=5."
    #= none:165 =#
    #= none:165 =# @test test_simulation.model.clock.iteration == true_simulation.model.clock.iteration
    #= none:166 =#
    #= none:166 =# @test test_simulation.model.clock.time == true_simulation.model.clock.time
    #= none:167 =#
    test_model_equality(test_model, true_model)
    #= none:169 =#
    rm("checkpoint_iteration0.jld2", force = true)
    #= none:170 =#
    rm("checkpoint_iteration5.jld2", force = true)
    #= none:172 =#
    return nothing
end
#= none:175 =#
function run_checkpointer_cleanup_tests(arch)
    #= none:175 =#
    #= none:176 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
    #= none:177 =#
    model = NonhydrostaticModel(; grid, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:178 =#
    simulation = Simulation(model, Δt = 0.2, stop_iteration = 10)
    #= none:180 =#
    simulation.output_writers[:checkpointer] = Checkpointer(model, schedule = IterationInterval(3), cleanup = true)
    #= none:181 =#
    run!(simulation)
    #= none:183 =#
    [#= none:183 =# @test(!(isfile("checkpoint_iteration$(i).jld2"))) for i = 1:10 if i != 9]
    #= none:184 =#
    #= none:184 =# @test isfile("checkpoint_iteration9.jld2")
    #= none:186 =#
    rm("checkpoint_iteration9.jld2", force = true)
    #= none:188 =#
    return nothing
end
#= none:191 =#
for arch = archs
    #= none:192 =#
    #= none:192 =# @testset "Checkpointer [$(typeof(arch))]" begin
            #= none:193 =#
            #= none:193 =# @info "  Testing Checkpointer [$(typeof(arch))]..."
            #= none:194 =#
            test_thermal_bubble_checkpointer_output(arch)
            #= none:196 =#
            for free_surface = [ExplicitFreeSurface(gravitational_acceleration = 1), ImplicitFreeSurface(gravitational_acceleration = 1)]
                #= none:199 =#
                test_hydrostatic_splash_checkpointer(arch, free_surface)
                #= none:200 =#
            end
            #= none:202 =#
            run_checkpointer_cleanup_tests(arch)
            #= none:205 =#
            rm("initialization_test_iteration*.jld2", force = true)
            #= none:206 =#
            simulation = initialization_test_simulation(arch, 4)
            #= none:207 =#
            run!(simulation)
            #= none:210 =#
            N = iteration(simulation)
            #= none:211 =#
            checkpoint = "initialization_test_iteration$(N).jld2"
            #= none:212 =#
            simulation = initialization_test_simulation(arch, 8)
            #= none:213 =#
            run!(simulation, pickup = checkpoint)
            #= none:215 =#
            progress_cb = simulation.callbacks[:progress]
            #= none:216 =#
            progress_cb.schedule.first_actuation_time
            #= none:217 =#
            #= none:217 =# @test progress_cb.schedule.first_actuation_time == 4
        end
    #= none:219 =#
end