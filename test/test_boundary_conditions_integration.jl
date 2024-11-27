
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.BoundaryConditions: ContinuousBoundaryFunction
#= none:4 =#
using Oceananigans: prognostic_fields
#= none:6 =#
function test_boundary_condition(arch, FT, topo, side, field_name, boundary_condition)
    #= none:6 =#
    #= none:7 =#
    grid = RectilinearGrid(arch, FT, size = (1, 1, 1), extent = (1, π, 42), topology = topo)
    #= none:9 =#
    boundary_condition_kwarg = (; side => boundary_condition)
    #= none:10 =#
    field_boundary_conditions = FieldBoundaryConditions(; boundary_condition_kwarg...)
    #= none:11 =#
    bcs = (; field_name => field_boundary_conditions)
    #= none:12 =#
    model = NonhydrostaticModel(; grid, boundary_conditions = bcs, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:15 =#
    success = try
            #= none:16 =#
            time_step!(model, 1.0e-16)
            #= none:17 =#
            true
        catch err
            #= none:19 =#
            #= none:19 =# @warn "test_boundary_condition errored with " * sprint(showerror, err)
            #= none:20 =#
            false
        end
    #= none:23 =#
    return success
end
#= none:26 =#
function test_nonhydrostatic_flux_budget(grid, name, side, L)
    #= none:26 =#
    #= none:27 =#
    FT = eltype(grid)
    #= none:28 =#
    flux = FT(π)
    #= none:29 =#
    direction = if side ∈ (:west, :south, :bottom, :immersed)
            1
        else
            -1
        end
    #= none:30 =#
    bc_kwarg = Dict(side => BoundaryCondition(Flux(), flux * direction))
    #= none:31 =#
    field_bcs = FieldBoundaryConditions(; bc_kwarg...)
    #= none:32 =#
    boundary_conditions = (; name => field_bcs)
    #= none:34 =#
    model = NonhydrostaticModel(; grid, boundary_conditions, tracers = :c)
    #= none:36 =#
    is_velocity_field = name ∈ (:u, :v, :w)
    #= none:37 =#
    field = if is_velocity_field
            getproperty(model.velocities, name)
        else
            getproperty(model.tracers, name)
        end
    #= none:38 =#
    set!(field, 0)
    #= none:40 =#
    simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
    #= none:41 =#
    run!(simulation)
    #= none:43 =#
    mean_ϕ = mean(field)
    #= none:49 =#
    return mean_ϕ ≈ (flux * model.clock.time) / L
end
#= none:52 =#
function fluxes_with_diffusivity_boundary_conditions_are_correct(arch, FT)
    #= none:52 =#
    #= none:53 =#
    Lz = 1
    #= none:54 =#
    κ₀ = FT(exp(-3))
    #= none:55 =#
    bz = FT(π)
    #= none:56 =#
    flux = -κ₀ * bz
    #= none:58 =#
    grid = RectilinearGrid(arch, FT, size = (16, 16, 16), extent = (1, 1, Lz))
    #= none:60 =#
    buoyancy_bcs = FieldBoundaryConditions(bottom = GradientBoundaryCondition(bz))
    #= none:61 =#
    κₑ_bcs = FieldBoundaryConditions(grid, (Center, Center, Center), bottom = ValueBoundaryCondition(κ₀))
    #= none:62 =#
    model_bcs = (b = buoyancy_bcs, κₑ = (b = κₑ_bcs,))
    #= none:64 =#
    model = NonhydrostaticModel(; grid, timestepper = :QuasiAdamsBashforth2, tracers = :b, buoyancy = BuoyancyTracer(), closure = AnisotropicMinimumDissipation(), boundary_conditions = model_bcs)
    #= none:71 =#
    b₀(x, y, z) = begin
            #= none:71 =#
            z * bz
        end
    #= none:72 =#
    set!(model, b = b₀)
    #= none:74 =#
    b = model.tracers.b
    #= none:75 =#
    mean_b₀ = mean(b)
    #= none:77 =#
    τκ = Lz ^ 2 / κ₀
    #= none:78 =#
    Δt = 1.0e-6τκ
    #= none:79 =#
    Nt = 10
    #= none:81 =#
    for n = 1:Nt
        #= none:82 =#
        time_step!(model, Δt, euler = n == 1)
        #= none:83 =#
    end
    #= none:103 =#
    return isapprox(mean(b) - mean_b₀, (flux * model.clock.time) / Lz, atol = 1.0e-6)
end
#= none:106 =#
test_boundary_conditions(C, FT, ArrayType) = begin
        #= none:106 =#
        (integer_bc(C, FT, ArrayType), float_bc(C, FT, ArrayType), irrational_bc(C, FT, ArrayType), array_bc(C, FT, ArrayType), simple_function_bc(C, FT, ArrayType), parameterized_function_bc(C, FT, ArrayType), field_dependent_function_bc(C, FT, ArrayType), parameterized_field_dependent_function_bc(C, FT, ArrayType), discrete_function_bc(C, FT, ArrayType), parameterized_discrete_function_bc(C, FT, ArrayType))
    end
#= none:117 =#
#= none:117 =# @testset "Boundary condition integration tests" begin
        #= none:118 =#
        #= none:118 =# @info "Testing boundary condition integration into NonhydrostaticModel..."
        #= none:120 =#
        #= none:120 =# @testset "Boundary condition regularization" begin
                #= none:121 =#
                #= none:121 =# @info "  Testing boundary condition regularization in NonhydrostaticModel constructor..."
                #= none:123 =#
                FT = Float64
                #= none:124 =#
                arch = first(archs)
                #= none:126 =#
                grid = RectilinearGrid(arch, FT, size = (1, 1, 1), extent = (1, π, 42), topology = (Bounded, Bounded, Bounded))
                #= none:128 =#
                u_boundary_conditions = FieldBoundaryConditions(bottom = simple_function_bc(Value), top = simple_function_bc(Value), north = simple_function_bc(Value), south = simple_function_bc(Value), east = simple_function_bc(Open), west = simple_function_bc(Open))
                #= none:135 =#
                v_boundary_conditions = FieldBoundaryConditions(bottom = simple_function_bc(Value), top = simple_function_bc(Value), north = simple_function_bc(Open), south = simple_function_bc(Open), east = simple_function_bc(Value), west = simple_function_bc(Value))
                #= none:143 =#
                w_boundary_conditions = FieldBoundaryConditions(bottom = simple_function_bc(Open), top = simple_function_bc(Open), north = simple_function_bc(Value), south = simple_function_bc(Value), east = simple_function_bc(Value), west = simple_function_bc(Value))
                #= none:150 =#
                T_boundary_conditions = FieldBoundaryConditions(bottom = simple_function_bc(Value), top = simple_function_bc(Value), north = simple_function_bc(Value), south = simple_function_bc(Value), east = simple_function_bc(Value), west = simple_function_bc(Value))
                #= none:157 =#
                boundary_conditions = (u = u_boundary_conditions, v = v_boundary_conditions, w = w_boundary_conditions, T = T_boundary_conditions)
                #= none:162 =#
                model = NonhydrostaticModel(grid = grid, boundary_conditions = boundary_conditions, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
                #= none:167 =#
                #= none:167 =# @test location(model.velocities.u.boundary_conditions.bottom.condition) == (Face, Center, Nothing)
                #= none:168 =#
                #= none:168 =# @test location(model.velocities.u.boundary_conditions.top.condition) == (Face, Center, Nothing)
                #= none:169 =#
                #= none:169 =# @test location(model.velocities.u.boundary_conditions.north.condition) == (Face, Nothing, Center)
                #= none:170 =#
                #= none:170 =# @test location(model.velocities.u.boundary_conditions.south.condition) == (Face, Nothing, Center)
                #= none:171 =#
                #= none:171 =# @test location(model.velocities.u.boundary_conditions.east.condition) == (Nothing, Center, Center)
                #= none:172 =#
                #= none:172 =# @test location(model.velocities.u.boundary_conditions.west.condition) == (Nothing, Center, Center)
                #= none:174 =#
                #= none:174 =# @test location(model.velocities.v.boundary_conditions.bottom.condition) == (Center, Face, Nothing)
                #= none:175 =#
                #= none:175 =# @test location(model.velocities.v.boundary_conditions.top.condition) == (Center, Face, Nothing)
                #= none:176 =#
                #= none:176 =# @test location(model.velocities.v.boundary_conditions.north.condition) == (Center, Nothing, Center)
                #= none:177 =#
                #= none:177 =# @test location(model.velocities.v.boundary_conditions.south.condition) == (Center, Nothing, Center)
                #= none:178 =#
                #= none:178 =# @test location(model.velocities.v.boundary_conditions.east.condition) == (Nothing, Face, Center)
                #= none:179 =#
                #= none:179 =# @test location(model.velocities.v.boundary_conditions.west.condition) == (Nothing, Face, Center)
                #= none:181 =#
                #= none:181 =# @test location(model.velocities.w.boundary_conditions.bottom.condition) == (Center, Center, Nothing)
                #= none:182 =#
                #= none:182 =# @test location(model.velocities.w.boundary_conditions.top.condition) == (Center, Center, Nothing)
                #= none:183 =#
                #= none:183 =# @test location(model.velocities.w.boundary_conditions.north.condition) == (Center, Nothing, Face)
                #= none:184 =#
                #= none:184 =# @test location(model.velocities.w.boundary_conditions.south.condition) == (Center, Nothing, Face)
                #= none:185 =#
                #= none:185 =# @test location(model.velocities.w.boundary_conditions.east.condition) == (Nothing, Center, Face)
                #= none:186 =#
                #= none:186 =# @test location(model.velocities.w.boundary_conditions.west.condition) == (Nothing, Center, Face)
                #= none:188 =#
                #= none:188 =# @test location(model.tracers.T.boundary_conditions.bottom.condition) == (Center, Center, Nothing)
                #= none:189 =#
                #= none:189 =# @test location(model.tracers.T.boundary_conditions.top.condition) == (Center, Center, Nothing)
                #= none:190 =#
                #= none:190 =# @test location(model.tracers.T.boundary_conditions.north.condition) == (Center, Nothing, Center)
                #= none:191 =#
                #= none:191 =# @test location(model.tracers.T.boundary_conditions.south.condition) == (Center, Nothing, Center)
                #= none:192 =#
                #= none:192 =# @test location(model.tracers.T.boundary_conditions.east.condition) == (Nothing, Center, Center)
                #= none:193 =#
                #= none:193 =# @test location(model.tracers.T.boundary_conditions.west.condition) == (Nothing, Center, Center)
            end
        #= none:196 =#
        #= none:196 =# @testset "Boundary condition time-stepping works" begin
                #= none:197 =#
                for arch = archs, FT = (Float64,)
                    #= none:198 =#
                    #= none:198 =# @info "  Testing that time-stepping with boundary conditions works [$(typeof(arch)), $(FT)]..."
                    #= none:200 =#
                    topo = (Bounded, Bounded, Bounded)
                    #= none:202 =#
                    for C = (Gradient, Flux, Value), boundary_condition = test_boundary_conditions(C, FT, array_type(arch))
                        #= none:203 =#
                        #= none:203 =# @test test_boundary_condition(arch, FT, topo, :east, :T, boundary_condition)
                        #= none:204 =#
                        #= none:204 =# @test test_boundary_condition(arch, FT, topo, :south, :T, boundary_condition)
                        #= none:205 =#
                        #= none:205 =# @test test_boundary_condition(arch, FT, topo, :top, :T, boundary_condition)
                        #= none:206 =#
                    end
                    #= none:208 =#
                    for boundary_condition = test_boundary_conditions(Open, FT, array_type(arch))
                        #= none:209 =#
                        #= none:209 =# @test test_boundary_condition(arch, FT, topo, :east, :u, boundary_condition)
                        #= none:210 =#
                        #= none:210 =# @test test_boundary_condition(arch, FT, topo, :south, :v, boundary_condition)
                        #= none:211 =#
                        #= none:211 =# @test test_boundary_condition(arch, FT, topo, :top, :w, boundary_condition)
                        #= none:212 =#
                    end
                    #= none:213 =#
                end
            end
        #= none:216 =#
        #= none:216 =# @testset "Budgets with Flux boundary conditions" begin
                #= none:217 =#
                for arch = archs
                    #= none:218 =#
                    A = typeof(arch)
                    #= none:219 =#
                    #= none:219 =# @info "  Testing budgets with Flux boundary conditions [$(A)]..."
                    #= none:221 =#
                    Lx = 0.3
                    #= none:222 =#
                    Ly = 0.4
                    #= none:223 =#
                    Lz = 0.5
                    #= none:225 =#
                    bottom(x, y) = begin
                            #= none:225 =#
                            0
                        end
                    #= none:226 =#
                    ib = GridFittedBottom(bottom)
                    #= none:227 =#
                    grid_kw = (size = (2, 2, 2), x = (0, Lx), y = (0, Ly))
                    #= none:229 =#
                    rectilinear_grid(topology) = begin
                            #= none:229 =#
                            RectilinearGrid(arch; topology, z = (0, Lz), grid_kw...)
                        end
                    #= none:230 =#
                    immersed_rectilinear_grid(topology) = begin
                            #= none:230 =#
                            ImmersedBoundaryGrid(RectilinearGrid(arch; topology, z = (-Lz, Lz), grid_kw...), ib)
                        end
                    #= none:231 =#
                    immersed_active_rectilinear_grid(topology) = begin
                            #= none:231 =#
                            ImmersedBoundaryGrid(RectilinearGrid(arch; topology, z = (-Lz, Lz), grid_kw...), ib; active_cells_map = true)
                        end
                    #= none:232 =#
                    grids_to_test(topo) = begin
                            #= none:232 =#
                            [rectilinear_grid(topo), immersed_rectilinear_grid(topo), immersed_active_rectilinear_grid(topo)]
                        end
                    #= none:234 =#
                    for grid = grids_to_test((Periodic, Bounded, Bounded))
                        #= none:235 =#
                        for name = (:u, :c)
                            #= none:236 =#
                            for (side, L) = zip((:north, :south, :top, :bottom), (Ly, Ly, Lz, Lz))
                                #= none:237 =#
                                if grid isa ImmersedBoundaryGrid && side == :bottom
                                    #= none:238 =#
                                    side = :immersed
                                end
                                #= none:240 =#
                                #= none:240 =# @info "    Testing budgets with Flux boundary conditions [$(summary(grid)), $(name), $(side)]..."
                                #= none:241 =#
                                #= none:241 =# @test test_nonhydrostatic_flux_budget(grid, name, side, L)
                                #= none:242 =#
                            end
                            #= none:243 =#
                        end
                        #= none:244 =#
                    end
                    #= none:246 =#
                    for grid = grids_to_test((Bounded, Periodic, Bounded))
                        #= none:247 =#
                        for name = (:v, :c)
                            #= none:248 =#
                            for (side, L) = zip((:east, :west, :top, :bottom), (Lx, Lx, Lz, Lz))
                                #= none:249 =#
                                if grid isa ImmersedBoundaryGrid && side == :bottom
                                    #= none:250 =#
                                    side = :immersed
                                end
                                #= none:252 =#
                                #= none:252 =# @info "    Testing budgets with Flux boundary conditions [$(summary(grid)), $(name), $(side)]..."
                                #= none:253 =#
                                #= none:253 =# @test test_nonhydrostatic_flux_budget(grid, name, side, L)
                                #= none:254 =#
                            end
                            #= none:255 =#
                        end
                        #= none:256 =#
                    end
                    #= none:259 =#
                    grid = rectilinear_grid((Bounded, Bounded, Periodic))
                    #= none:260 =#
                    for name = (:w, :c)
                        #= none:261 =#
                        for (side, L) = zip((:east, :west, :north, :south), (Lx, Lx, Ly, Ly))
                            #= none:262 =#
                            #= none:262 =# @info "    Testing budgets with Flux boundary conditions [$(summary(grid)), $(name), $(side)]..."
                            #= none:263 =#
                            #= none:263 =# @test test_nonhydrostatic_flux_budget(grid, name, side, L)
                            #= none:264 =#
                        end
                        #= none:265 =#
                    end
                    #= none:266 =#
                end
            end
        #= none:269 =#
        #= none:269 =# @testset "Custom diffusivity boundary conditions" begin
                #= none:270 =#
                for arch = archs, FT = (Float64,)
                    #= none:271 =#
                    A = typeof(arch)
                    #= none:272 =#
                    #= none:272 =# @info "  Testing flux budgets with diffusivity boundary conditions [$(A), $(FT)]..."
                    #= none:273 =#
                    #= none:273 =# @test fluxes_with_diffusivity_boundary_conditions_are_correct(arch, FT)
                    #= none:274 =#
                end
            end
    end