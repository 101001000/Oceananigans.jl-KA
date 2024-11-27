
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using TimesDates: TimeDate
#= none:5 =#
using Oceananigans.Models: erroring_NaNChecker!
#= none:7 =#
using Oceananigans.Simulations: stop_iteration_exceeded, stop_time_exceeded, wall_time_limit_exceeded, TimeStepWizard, new_time_step, reset!
#= none:11 =#
using Dates: DateTime
#= none:13 =#
function wall_time_step_wizard_tests(arch)
    #= none:13 =#
    #= none:14 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
    #= none:15 =#
    Δx = grid.Δxᶜᵃᵃ
    #= none:17 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:19 =#
    CFL = 0.45
    #= none:20 =#
    u₀ = 7
    #= none:21 =#
    Δt = 2.5
    #= none:22 =#
    model.velocities.u[1, 1, 1] = u₀
    #= none:24 =#
    wizard = TimeStepWizard(cfl = CFL, max_change = Inf, min_change = 0)
    #= none:25 =#
    Δt = new_time_step(Δt, wizard, model)
    #= none:26 =#
    #= none:26 =# @test Δt ≈ (CFL * Δx) / u₀
    #= none:28 =#
    wizard = TimeStepWizard(cfl = CFL, max_change = Inf, min_change = 0.75)
    #= none:29 =#
    Δt = new_time_step(1.0, wizard, model)
    #= none:30 =#
    #= none:30 =# @test Δt ≈ 0.75
    #= none:32 =#
    wizard = TimeStepWizard(cfl = CFL, max_change = Inf, min_change = 0, min_Δt = 1.99)
    #= none:33 =#
    Δt = new_time_step(Δt, wizard, model)
    #= none:34 =#
    #= none:34 =# @test Δt ≈ 1.99
    #= none:36 =#
    model.velocities.u[1, 1, 1] = u₀ / 100
    #= none:38 =#
    wizard = TimeStepWizard(cfl = CFL, max_change = 1.1, min_change = 0)
    #= none:39 =#
    Δt = new_time_step(1.0, wizard, model)
    #= none:40 =#
    #= none:40 =# @test Δt ≈ 1.1
    #= none:42 =#
    wizard = TimeStepWizard(cfl = CFL, max_change = Inf, min_change = 0, max_Δt = 3.99)
    #= none:43 =#
    Δt = new_time_step(Δt, wizard, model)
    #= none:44 =#
    #= none:44 =# @test Δt ≈ 3.99
    #= none:47 =#
    model = NonhydrostaticModel(grid = grid, closure = ScalarDiffusivity(ν = 1))
    #= none:48 =#
    diff_CFL = 0.45
    #= none:50 =#
    wizard = TimeStepWizard(cfl = Inf, diffusive_cfl = diff_CFL, max_change = Inf, min_change = 0)
    #= none:51 =#
    Δt = new_time_step(Δt, wizard, model)
    #= none:52 =#
    #= none:52 =# @test Δt ≈ (diff_CFL * Δx ^ 2) / model.closure.ν
    #= none:54 =#
    grid_stretched = RectilinearGrid(arch, size = (1, 1, 1), x = (0, 1), y = (0, 1), z = (z->begin
                        #= none:58 =#
                        z
                    end), halo = (1, 1, 1))
    #= none:61 =#
    model = NonhydrostaticModel(grid = grid_stretched)
    #= none:63 =#
    Δx = grid_stretched.Δxᶜᵃᵃ
    #= none:64 =#
    CFL = 0.45
    #= none:65 =#
    u₀ = 7
    #= none:66 =#
    Δt = 2.5
    #= none:67 =#
    model.velocities.u .= u₀
    #= none:69 =#
    wizard = TimeStepWizard(cfl = CFL, max_change = Inf, min_change = 0)
    #= none:70 =#
    Δt = new_time_step(Δt, wizard, model)
    #= none:71 =#
    #= none:71 =# @test Δt ≈ (CFL * Δx) / u₀
    #= none:73 =#
    return nothing
end
#= none:76 =#
function run_basic_simulation_tests(arch)
    #= none:76 =#
    #= none:77 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
    #= none:78 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:79 =#
    simulation = Simulation(model, Δt = 3, stop_iteration = 1)
    #= none:82 =#
    #= none:82 =# @test simulation isa Simulation
    #= none:84 =#
    simulation.running = true
    #= none:85 =#
    stop_iteration_exceeded(simulation)
    #= none:86 =#
    #= none:86 =# @test simulation.running
    #= none:88 =#
    run!(simulation)
    #= none:91 =#
    #= none:91 =# @test simulation isa Simulation
    #= none:94 =#
    simulation.running = true
    #= none:95 =#
    stop_iteration_exceeded(simulation)
    #= none:96 =#
    #= none:96 =# @test !(simulation.running)
    #= none:98 =#
    #= none:98 =# @test model.clock.time ≈ simulation.Δt
    #= none:99 =#
    #= none:99 =# @test model.clock.iteration == 1
    #= none:100 =#
    #= none:100 =# @test simulation.run_wall_time > 0
    #= none:102 =#
    simulation.running = true
    #= none:103 =#
    stop_time_exceeded(simulation)
    #= none:104 =#
    #= none:104 =# @test simulation.running
    #= none:106 =#
    simulation.running = true
    #= none:107 =#
    simulation.stop_time = 1.0e-12
    #= none:108 =#
    stop_time_exceeded(simulation)
    #= none:109 =#
    #= none:109 =# @test !(simulation.running)
    #= none:111 =#
    simulation.running = true
    #= none:112 =#
    wall_time_limit_exceeded(simulation)
    #= none:113 =#
    #= none:113 =# @test simulation.running
    #= none:115 =#
    simulation.running = true
    #= none:116 =#
    simulation.wall_time_limit = 1.0e-12
    #= none:117 =#
    wall_time_limit_exceeded(simulation)
    #= none:118 =#
    #= none:118 =# @test !(simulation.running)
    #= none:121 =#
    reset!(simulation)
    #= none:122 =#
    simulation.stop_iteration = 3
    #= none:123 =#
    run!(simulation)
    #= none:125 =#
    #= none:125 =# @test simulation.model.clock.iteration == 3
    #= none:128 =#
    reset!(simulation)
    #= none:129 =#
    simulation.stop_time = 20.2
    #= none:130 =#
    run!(simulation)
    #= none:132 =#
    #= none:132 =# @test simulation.model.clock.time ≈ 20.2
    #= none:135 =#
    reset!(simulation)
    #= none:136 =#
    simulation.stop_iteration = 2
    #= none:138 =#
    wizard = TimeStepWizard(cfl = 0.1)
    #= none:139 =#
    simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(1))
    #= none:141 =#
    run!(simulation)
    #= none:143 =#
    #= none:143 =# @test (simulation.callbacks[:wizard]).func isa TimeStepWizard
    #= none:146 =#
    reset!(simulation)
    #= none:147 =#
    simulation.stop_time = 2.0
    #= none:148 =#
    simulation.Δt = 1.0
    #= none:150 =#
    called_at = Float64[]
    #= none:151 =#
    schedule = TimeInterval(0.31)
    #= none:152 =#
    capture_call_time(sim, data) = begin
            #= none:152 =#
            push!(data, sim.model.clock.time)
        end
    #= none:153 =#
    simulation.callbacks[:tester] = Callback(capture_call_time, schedule, parameters = called_at)
    #= none:154 =#
    run!(simulation)
    #= none:156 =#
    #= none:156 =# @show called_at
    #= none:157 =#
    #= none:157 =# @test all(called_at .≈ 0.0:schedule.interval:simulation.stop_time)
    #= none:159 =#
    return nothing
end
#= none:162 =#
function run_simulation_date_tests(arch, start_time, stop_time, Δt)
    #= none:162 =#
    #= none:163 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
    #= none:165 =#
    clock = Clock(time = start_time)
    #= none:166 =#
    model = NonhydrostaticModel(; grid, clock, timestepper = :QuasiAdamsBashforth2)
    #= none:167 =#
    simulation = Simulation(model; Δt, stop_time)
    #= none:169 =#
    #= none:169 =# @test model.clock.time == start_time
    #= none:170 =#
    #= none:170 =# @test simulation.stop_time == stop_time
    #= none:172 =#
    run!(simulation)
    #= none:174 =#
    #= none:174 =# @test model.clock.time == stop_time
    #= none:175 =#
    #= none:175 =# @test simulation.stop_time == stop_time
    #= none:177 =#
    return nothing
end
#= none:180 =#
function run_nan_checker_test(arch; erroring)
    #= none:180 =#
    #= none:181 =#
    grid = RectilinearGrid(arch, size = (4, 2, 1), extent = (1, 1, 1))
    #= none:182 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:183 =#
    simulation = Simulation(model, Δt = 1, stop_iteration = 1)
    #= none:184 =#
    model.velocities.u[1, 1, 1] = NaN
    #= none:185 =#
    erroring && erroring_NaNChecker!(simulation)
    #= none:187 =#
    if erroring
        #= none:188 =#
        #= none:188 =# @test_throws ErrorException run!(simulation)
    else
        #= none:190 =#
        run!(simulation)
        #= none:191 =#
        #= none:191 =# @test model.clock.iteration == 0
    end
    #= none:194 =#
    return nothing
end
#= none:197 =#
#= none:197 =# @testset "Time step wizard" begin
        #= none:198 =#
        for arch = archs
            #= none:199 =#
            #= none:199 =# @info "Testing time step wizard [$(typeof(arch))]..."
            #= none:200 =#
            wall_time_step_wizard_tests(arch)
            #= none:201 =#
        end
    end
#= none:204 =#
#= none:204 =# @testset "Simulations" begin
        #= none:205 =#
        for arch = archs
            #= none:206 =#
            #= none:206 =# @info "Testing simulations [$(typeof(arch))]..."
            #= none:207 =#
            run_basic_simulation_tests(arch)
            #= none:210 =#
            grid = RectilinearGrid(arch, size = (), topology = (Flat, Flat, Flat))
            #= none:211 =#
            model = NonhydrostaticModel(; grid)
            #= none:212 =#
            simulation = Simulation(model; Δt = 1, stop_time = 6)
            #= none:214 =#
            progress_message(sim) = begin
                    #= none:214 =#
                    #= none:214 =# @info string("Iter: ", iteration(sim), ", time: ", prettytime(sim))
                end
            #= none:215 =#
            progress_cb = Callback(progress_message, TimeInterval(2))
            #= none:216 =#
            simulation.callbacks[:progress] = progress_cb
            #= none:218 =#
            model.clock.iteration = 1
            #= none:219 =#
            run!(simulation)
            #= none:220 =#
            #= none:220 =# @test progress_cb.schedule.actuations == 3
            #= none:222 =#
            #= none:222 =# @testset "NaN Checker [$(typeof(arch))]" begin
                    #= none:223 =#
                    #= none:223 =# @info "  Testing NaN Checker [$(typeof(arch))]..."
                    #= none:224 =#
                    run_nan_checker_test(arch, erroring = true)
                    #= none:225 =#
                    run_nan_checker_test(arch, erroring = false)
                end
            #= none:228 =#
            #= none:228 =# @info "Testing simulations with DateTime [$(typeof(arch))]..."
            #= none:229 =#
            run_simulation_date_tests(arch, 0.0, 1.0, 0.3)
            #= none:230 =#
            run_simulation_date_tests(arch, DateTime(2020), DateTime(2021), 100days)
            #= none:231 =#
            run_simulation_date_tests(arch, TimeDate(2020), TimeDate(2021), 100days)
            #= none:232 =#
        end
    end