
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.TurbulenceClosures: viscosity, ThreeDimensionalFormulation, HorizontalFormulation, VerticalFormulation
#= none:4 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid, GridFittedBoundary, GridFittedBottom, mask_immersed_field!
#= none:5 =#
using Oceananigans.Biogeochemistry: AbstractBiogeochemistry
#= none:6 =#
using Oceananigans.Fields: ZeroField, ConstantField
#= none:8 =#
import Oceananigans.Biogeochemistry: biogeochemical_drift_velocity
#= none:10 =#
function relative_error(u_num, u, time)
    #= none:10 =#
    #= none:11 =#
    u_ans = Field(location(u_num), u_num.grid)
    #= none:12 =#
    u_set(x...) = begin
            #= none:12 =#
            u(x..., time)
        end
    #= none:13 =#
    set!(u_ans, u_set)
    #= none:14 =#
    return mean((interior(u_num) .- interior(u_ans)) .^ 2) / mean(interior(u_ans) .^ 2)
end
#= none:17 =#
function test_diffusion_simple(fieldname, timestepper, time_discretization)
    #= none:17 =#
    #= none:18 =#
    model = NonhydrostaticModel(; timestepper, grid = RectilinearGrid(CPU(), size = (1, 1, 16), extent = (1, 1, 1)), closure = ScalarDiffusivity(time_discretization, ν = 1, κ = 1), tracers = :c)
    #= none:23 =#
    value = π
    #= none:24 =#
    field = (fields(model))[fieldname]
    #= none:25 =#
    interior(field) .= value
    #= none:26 =#
    update_state!(model)
    #= none:28 =#
    [time_step!(model, 1) for n = 1:10]
    #= none:30 =#
    field_data = interior(field)
    #= none:31 =#
    return !(any(#= none:31 =# @__dot__(!(isapprox(value, field_data)))))
end
#= none:34 =#
function test_diffusion_budget(fieldname, field, model, κ, Δ, order = 2)
    #= none:34 =#
    #= none:35 =#
    init_mean = mean(interior(field))
    #= none:36 =#
    update_state!(model)
    #= none:37 =#
    Δt = (0.0001 * Δ ^ order) / κ
    #= none:39 =#
    for _ = 1:10
        #= none:40 =#
        time_step!(model, Δt)
        #= none:41 =#
    end
    #= none:43 =#
    final_mean = mean(interior(field))
    #= none:44 =#
    #= none:44 =# @info #= none:44 =# @sprintf("    Initial <%s>: %.16f, final <%s>: %.16f, final - initial: %.4e", fieldname, init_mean, fieldname, final_mean, final_mean - init_mean)
    #= none:47 =#
    return isapprox(init_mean, final_mean)
end
#= none:50 =#
function test_ScalarDiffusivity_budget(fieldname, model)
    #= none:50 =#
    #= none:51 =#
    set!(model; u = 0, v = 0, w = 0, c = 0)
    #= none:52 =#
    set!(model; Dict(fieldname => ((x, y, z)->begin
                        #= none:52 =#
                        rand()
                    end))...)
    #= none:53 =#
    field = (fields(model))[fieldname]
    #= none:54 =#
    ν = viscosity(model.closure, nothing)
    #= none:55 =#
    return test_diffusion_budget(fieldname, field, model, ν, model.grid.Δzᵃᵃᶜ)
end
#= none:58 =#
function test_ScalarBiharmonicDiffusivity_budget(fieldname, model)
    #= none:58 =#
    #= none:59 =#
    set!(model; u = 0, v = 0, w = 0, c = 0)
    #= none:60 =#
    set!(model; Dict(fieldname => ((x, y, z)->begin
                        #= none:60 =#
                        rand()
                    end))...)
    #= none:61 =#
    field = (fields(model))[fieldname]
    #= none:62 =#
    return test_diffusion_budget(fieldname, field, model, model.closure.ν, model.grid.Δzᵃᵃᶜ, 4)
end
#= none:65 =#
function test_diffusion_cosine(fieldname, grid, closure, ξ, tracers = :c)
    #= none:65 =#
    #= none:66 =#
    model = NonhydrostaticModel(; grid, closure, tracers, buoyancy = nothing)
    #= none:67 =#
    field = (fields(model))[fieldname]
    #= none:69 =#
    m = 2
    #= none:70 =#
    field .= cos.(m * ξ)
    #= none:71 =#
    update_state!(model)
    #= none:73 =#
    κ = 1
    #= none:76 =#
    Δt = (1.0e-6 * grid.Lz ^ 2) / κ
    #= none:77 =#
    for _ = 1:5
        #= none:78 =#
        time_step!(model, Δt)
        #= none:79 =#
    end
    #= none:81 =#
    diffusing_cosine(ξ, t, κ, m) = begin
            #= none:81 =#
            exp(-κ * m ^ 2 * t) * cos(m * ξ)
        end
    #= none:82 =#
    analytical_solution = Field(location(field), grid)
    #= none:83 =#
    analytical_solution .= diffusing_cosine.(ξ, model.clock.time, κ, m)
    #= none:85 =#
    return isapprox(field, analytical_solution, atol = 1.0e-6, rtol = 1.0e-6)
end
#= none:88 =#
function test_immersed_diffusion(Nz, z, time_discretization)
    #= none:88 =#
    #= none:89 =#
    closure = ScalarDiffusivity(time_discretization, κ = 1)
    #= none:90 =#
    underlying_grid = RectilinearGrid(size = Nz, z = z, topology = (Flat, Flat, Bounded))
    #= none:91 =#
    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom((()->begin
                        #= none:91 =#
                        0
                    end)); active_cells_map = true)
    #= none:93 =#
    Δz_min = minimum(underlying_grid.Δzᵃᵃᶜ)
    #= none:94 =#
    model_kwargs = (tracers = :c, buoyancy = nothing, velocities = PrescribedVelocityFields())
    #= none:96 =#
    full_model = HydrostaticFreeSurfaceModel(; grid = underlying_grid, closure, model_kwargs...)
    #= none:97 =#
    immersed_model = HydrostaticFreeSurfaceModel(; grid, closure, model_kwargs...)
    #= none:99 =#
    initial_temperature(z) = begin
            #= none:99 =#
            exp(-(z ^ 2) / 0.02)
        end
    #= none:100 =#
    set!(full_model, c = initial_temperature)
    #= none:101 =#
    set!(immersed_model, c = initial_temperature)
    #= none:103 =#
    Δt = (Δz_min ^ 2 / closure.κ) * 0.1
    #= none:105 =#
    for _ = 1:100
        #= none:106 =#
        time_step!(full_model, Δt)
        #= none:107 =#
        time_step!(immersed_model, Δt)
        #= none:108 =#
    end
    #= none:110 =#
    half = Int(grid.Nz / 2 + 1)
    #= none:111 =#
    c_full = (interior(full_model.tracers.c))[1, 1, half:end]
    #= none:112 =#
    c_immersed = (interior(immersed_model.tracers.c))[1, 1, half:end]
    #= none:114 =#
    return all(c_full .≈ c_immersed)
end
#= none:117 =#
function test_3D_immersed_diffusion(Nz, z, time_discretization)
    #= none:117 =#
    #= none:118 =#
    closure = VerticalScalarDiffusivity(time_discretization, ν = 1, κ = 1)
    #= none:121 =#
    (b, l, m, u, t) = (-0.5, -0.2, 0, 0.2, 0.5)
    #= none:123 =#
    bathymetry = [b b b b b b b b b; b l l l l l l l b; b l m m m m m l b; b l m u u u m l b; b l m u t u m l b; b l m u u u m l b; b l m m m m m l b; b l l l l l l l b; b b b b b b b b b]
    #= none:133 =#
    underlying_grid = RectilinearGrid(size = (9, 9, Nz), x = (0, 1), y = (0, 1), z = z, topology = (Periodic, Periodic, Bounded))
    #= none:134 =#
    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bathymetry); active_cells_map = true)
    #= none:136 =#
    Δz_min = minimum(grid.underlying_grid.Δzᵃᵃᶜ)
    #= none:137 =#
    model_kwargs = (tracers = :c, buoyancy = nothing, velocities = PrescribedVelocityFields())
    #= none:139 =#
    full_model = HydrostaticFreeSurfaceModel(; grid = underlying_grid, closure, model_kwargs...)
    #= none:140 =#
    immersed_model = HydrostaticFreeSurfaceModel(; grid, closure, model_kwargs...)
    #= none:142 =#
    initial_temperature(x, y, z) = begin
            #= none:142 =#
            exp(-(z ^ 2) / 0.02)
        end
    #= none:143 =#
    set!(full_model, c = initial_temperature)
    #= none:144 =#
    set!(immersed_model, c = initial_temperature)
    #= none:146 =#
    Δt = (Δz_min ^ 2 / closure.κ) * 0.1
    #= none:148 =#
    for _ = 1:100
        #= none:149 =#
        time_step!(full_model, Δt)
        #= none:150 =#
        time_step!(immersed_model, Δt)
        #= none:151 =#
    end
    #= none:153 =#
    half = Int(grid.Nz / 2 + 1)
    #= none:155 =#
    assesment = Array{Bool}(undef, 4)
    #= none:157 =#
    c_full = (interior(full_model.tracers.c))[3, 3:7, half:end]
    #= none:158 =#
    c_immersed = (interior(immersed_model.tracers.c))[3, 3:7, half:end]
    #= none:159 =#
    assesment[1] = all(c_full .≈ c_immersed)
    #= none:161 =#
    c_full = (interior(full_model.tracers.c))[3:7, 3, half:end]
    #= none:162 =#
    c_immersed = (interior(immersed_model.tracers.c))[3:7, 3, half:end]
    #= none:163 =#
    assesment[2] = all(c_full .≈ c_immersed)
    #= none:165 =#
    c_full = (interior(full_model.tracers.c))[7, 3:7, half:end]
    #= none:166 =#
    c_immersed = (interior(immersed_model.tracers.c))[7, 3:7, half:end]
    #= none:167 =#
    assesment[3] = all(c_full .≈ c_immersed)
    #= none:169 =#
    c_full = (interior(full_model.tracers.c))[3:7, 7, half:end]
    #= none:170 =#
    c_immersed = (interior(immersed_model.tracers.c))[3:7, 7, half:end]
    #= none:171 =#
    assesment[4] = all(c_full .≈ c_immersed)
    #= none:173 =#
    return all(assesment)
end
#= none:176 =#
function passive_tracer_advection_test(timestepper; N = 128, κ = 1.0e-12, Nt = 100, background_velocity_field = false)
    #= none:176 =#
    #= none:177 =#
    (L, U, V) = (1.0, 0.5, 0.8)
    #= none:178 =#
    (δ, x₀, y₀) = (L / 15, L / 2, L / 2)
    #= none:180 =#
    Δt = ((0.05L) / N) / sqrt(U ^ 2 + V ^ 2)
    #= none:182 =#
    T(x, y, z, t) = begin
            #= none:182 =#
            exp(-((((x - U * t) - x₀) ^ 2 + ((y - V * t) - y₀) ^ 2)) / (2 * δ ^ 2))
        end
    #= none:183 =#
    u₀(x, y, z) = begin
            #= none:183 =#
            U
        end
    #= none:184 =#
    v₀(x, y, z) = begin
            #= none:184 =#
            V
        end
    #= none:185 =#
    T₀(x, y, z) = begin
            #= none:185 =#
            T(x, y, z, 0)
        end
    #= none:186 =#
    background_fields = Dict()
    #= none:188 =#
    if background_velocity_field
        #= none:189 =#
        background_fields[:u] = ((x, y, z, t)->begin
                    #= none:189 =#
                    U
                end)
        #= none:190 =#
        background_fields[:v] = ((x, y, z, t)->begin
                    #= none:190 =#
                    V
                end)
        #= none:191 =#
        u₀ = 0
        #= none:192 =#
        v₀ = 0
    end
    #= none:195 =#
    background_fields = NamedTuple{Tuple(keys(background_fields))}(values(background_fields))
    #= none:197 =#
    grid = RectilinearGrid(size = (N, N, 2), extent = (L, L, L))
    #= none:198 =#
    closure = ScalarDiffusivity(ν = κ, κ = κ)
    #= none:199 =#
    model = NonhydrostaticModel(; grid, closure, timestepper, background_fields, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:202 =#
    set!(model, u = u₀, v = v₀, T = T₀)
    #= none:203 =#
    [time_step!(model, Δt) for n = 1:Nt]
    #= none:206 =#
    return relative_error(model.tracers.T, T, model.clock.time) < 0.0001
end
#= none:209 =#
#= none:209 =# Core.@doc "Taylor-Green vortex test\nSee: https://en.wikipedia.org/wiki/Taylor%E2%80%93Green_vortex#Taylor%E2%80%93Green_vortex_solution\n     and p. 310 of \"Nodal Discontinuous Galerkin Methods: Algorithms, Analysis, and Application\"\n     by Hesthaven & Warburton.\n" function taylor_green_vortex_test(arch, timestepper, time_discretization; FT = Float64, N = 64, Nt = 10)
        #= none:215 =#
        #= none:216 =#
        (Nx, Ny, Nz) = (N, N, 2)
        #= none:217 =#
        (Lx, Ly, Lz) = (1, 1, 1)
        #= none:218 =#
        ν = 1
        #= none:221 =#
        Δx = Lx / Nx
        #= none:222 =#
        Δt = ((1 / (10π)) * Δx ^ 2) / ν
        #= none:225 =#
        #= none:225 =# @inline u(x, y, z, t) = begin
                    #= none:225 =#
                    -(sin((2π) * y)) * exp((-4 * π ^ 2) * ν * t)
                end
        #= none:226 =#
        #= none:226 =# @inline v(x, y, z, t) = begin
                    #= none:226 =#
                    sin((2π) * x) * exp((-4 * π ^ 2) * ν * t)
                end
        #= none:228 =#
        model = NonhydrostaticModel(timestepper = timestepper, grid = RectilinearGrid(arch, FT, size = (Nx, Ny, Nz), extent = (Lx, Ly, Lz)), closure = ScalarDiffusivity(time_discretization, ThreeDimensionalFormulation(), FT, ν = 1), tracers = nothing, buoyancy = nothing)
        #= none:235 =#
        u₀(x, y, z) = begin
                #= none:235 =#
                u(x, y, z, 0)
            end
        #= none:236 =#
        v₀(x, y, z) = begin
                #= none:236 =#
                v(x, y, z, 0)
            end
        #= none:237 =#
        set!(model, u = u₀, v = v₀)
        #= none:239 =#
        for _ = 1:Nt
            #= none:240 =#
            time_step!(model, Δt)
            #= none:241 =#
        end
        #= none:243 =#
        (xF, yC, zC) = nodes(model.velocities.u, reshape = true)
        #= none:244 =#
        (xC, yF, zC) = nodes(model.velocities.v, reshape = true)
        #= none:246 =#
        t = model.clock.time
        #= none:247 =#
        i = model.clock.iteration
        #= none:250 =#
        u_rel_err = abs.((interior(model.velocities.u) .- u.(xF, yC, zC, t)) ./ u.(xF, yC, zC, t))
        #= none:251 =#
        u_rel_err_avg = mean(u_rel_err)
        #= none:252 =#
        u_rel_err_max = maximum(u_rel_err)
        #= none:254 =#
        v_rel_err = abs.((interior(model.velocities.v) .- v.(xC, yF, zC, t)) ./ v.(xC, yF, zC, t))
        #= none:255 =#
        v_rel_err_avg = mean(v_rel_err)
        #= none:256 =#
        v_rel_err_max = maximum(v_rel_err)
        #= none:258 =#
        #= none:258 =# @info "Taylor-Green vortex test [$(arch), $(FT), Nx=Ny=$(N), Nt=$(Nt)]: " * #= none:259 =# @sprintf("Δu: (avg=%6.3g, max=%6.3g), Δv: (avg=%6.3g, max=%6.3g)", u_rel_err_avg, u_rel_err_max, v_rel_err_avg, v_rel_err_max)
        #= none:262 =#
        return u_rel_err_max < 5.0e-6 && v_rel_err_max < 5.0e-6
    end
#= none:265 =#
function stratified_fluid_remains_at_rest_with_tilted_gravity_buoyancy_tracer(arch, FT; N = 32, L = 2000, θ = 60, N² = 1.0e-5)
    #= none:265 =#
    #= none:266 =#
    topo = (Periodic, Bounded, Bounded)
    #= none:267 =#
    grid = RectilinearGrid(arch, FT, topology = topo, size = (1, N, N), extent = (L, L, L))
    #= none:269 =#
    g̃ = [0, sind(θ), cosd(θ)]
    #= none:270 =#
    buoyancy = Buoyancy(model = BuoyancyTracer(), gravity_unit_vector = -g̃)
    #= none:272 =#
    y_bc = GradientBoundaryCondition(N² * g̃[2])
    #= none:273 =#
    z_bc = GradientBoundaryCondition(N² * g̃[3])
    #= none:274 =#
    b_bcs = FieldBoundaryConditions(bottom = z_bc, top = z_bc, south = y_bc, north = y_bc)
    #= none:276 =#
    model = NonhydrostaticModel(; grid, buoyancy, tracers = :b, closure = nothing, boundary_conditions = (; b = b_bcs))
    #= none:281 =#
    b₀(x, y, z) = begin
            #= none:281 =#
            N² * (x * g̃[1] + y * g̃[2] + z * g̃[3])
        end
    #= none:282 =#
    set!(model, b = b₀)
    #= none:284 =#
    simulation = Simulation(model, Δt = 10minutes, stop_time = 1hour)
    #= none:285 =#
    run!(simulation)
    #= none:287 =#
    #= none:287 =# @compute ∂y_b = Field(∂y(model.tracers.b))
    #= none:288 =#
    #= none:288 =# @compute ∂z_b = Field(∂z(model.tracers.b))
    #= none:290 =#
    mean_∂y_b = mean(∂y_b)
    #= none:291 =#
    mean_∂z_b = mean(∂z_b)
    #= none:293 =#
    Δ_y = N² * g̃[2] - mean_∂y_b
    #= none:294 =#
    Δ_z = N² * g̃[3] - mean_∂z_b
    #= none:296 =#
    #= none:296 =# @info "N² * g̃[2] = $(N² * g̃[2]), mean(∂y_b) = $(mean_∂y_b), Δ = $(Δ_y) at t = $(prettytime(model.clock.time)) with θ=$(θ)°"
    #= none:297 =#
    #= none:297 =# @info "N² * g̃[3] = $(N² * g̃[3]), mean(∂z_b) = $(mean_∂z_b), Δ = $(Δ_z) at t = $(prettytime(model.clock.time)) with θ=$(θ)°"
    #= none:299 =#
    #= none:299 =# @test N² * g̃[2] ≈ mean(∂y_b)
    #= none:300 =#
    #= none:300 =# @test N² * g̃[3] ≈ mean(∂z_b)
    #= none:302 =#
    #= none:302 =# CUDA.@allowscalar begin
            #= none:303 =#
            #= none:303 =# @test all(N² * g̃[2] .≈ interior(∂y_b))
            #= none:304 =#
            #= none:304 =# @test all(N² * g̃[3] .≈ interior(∂z_b))
        end
    #= none:307 =#
    return nothing
end
#= none:310 =#
function stratified_fluid_remains_at_rest_with_tilted_gravity_temperature_tracer(arch, FT; N = 32, L = 2000, θ = 60, N² = 1.0e-5)
    #= none:310 =#
    #= none:311 =#
    topo = (Periodic, Bounded, Bounded)
    #= none:312 =#
    grid = RectilinearGrid(arch, FT, topology = topo, size = (1, N, N), extent = (L, L, L))
    #= none:314 =#
    g̃ = (0, sind(θ), cosd(θ))
    #= none:315 =#
    buoyancy = Buoyancy(model = SeawaterBuoyancy(), gravity_unit_vector = g̃)
    #= none:317 =#
    α = buoyancy.model.equation_of_state.thermal_expansion
    #= none:318 =#
    g₀ = buoyancy.model.gravitational_acceleration
    #= none:319 =#
    ∂T∂z = N² / (g₀ * α)
    #= none:321 =#
    y_bc = GradientBoundaryCondition(∂T∂z * g̃[2])
    #= none:322 =#
    z_bc = GradientBoundaryCondition(∂T∂z * g̃[3])
    #= none:323 =#
    T_bcs = FieldBoundaryConditions(bottom = z_bc, top = z_bc, south = y_bc, north = y_bc)
    #= none:325 =#
    model = NonhydrostaticModel(; grid, buoyancy, tracers = (:T, :S), closure = nothing, boundary_conditions = (; T = T_bcs))
    #= none:330 =#
    T₀(x, y, z) = begin
            #= none:330 =#
            ∂T∂z * (x * g̃[1] + y * g̃[2] + z * g̃[3])
        end
    #= none:331 =#
    set!(model, T = T₀)
    #= none:333 =#
    simulation = Simulation(model, Δt = 10minute, stop_time = 1hour)
    #= none:334 =#
    run!(simulation)
    #= none:336 =#
    #= none:336 =# @compute ∂y_T = Field(∂y(model.tracers.T))
    #= none:337 =#
    #= none:337 =# @compute ∂z_T = Field(∂z(model.tracers.T))
    #= none:339 =#
    mean_∂y_T = mean(∂y_T)
    #= none:340 =#
    mean_∂z_T = mean(∂z_T)
    #= none:342 =#
    Δ_y = ∂T∂z * g̃[2] - mean_∂y_T
    #= none:343 =#
    Δ_z = ∂T∂z * g̃[3] - mean_∂z_T
    #= none:345 =#
    #= none:345 =# @info "∂T∂z * g̃[2] = $(∂T∂z * g̃[2]), mean(∂y_T) = $(mean_∂y_T), Δ = $(Δ_y) at t = $(prettytime(model.clock.time)) with θ=$(θ)°"
    #= none:346 =#
    #= none:346 =# @info "∂T∂z * g̃[3] = $(∂T∂z * g̃[3]), mean(∂z_T) = $(mean_∂z_T), Δ = $(Δ_z) at t = $(prettytime(model.clock.time)) with θ=$(θ)°"
    #= none:348 =#
    #= none:348 =# @test ∂T∂z * g̃[2] ≈ mean(∂y_T)
    #= none:349 =#
    #= none:349 =# @test ∂T∂z * g̃[3] ≈ mean(∂z_T)
    #= none:351 =#
    #= none:351 =# CUDA.@allowscalar begin
            #= none:352 =#
            #= none:352 =# @test all(∂T∂z * g̃[2] .≈ interior(∂y_T))
            #= none:353 =#
            #= none:353 =# @test all(∂T∂z * g̃[3] .≈ interior(∂z_T))
        end
    #= none:356 =#
    return nothing
end
#= none:359 =#
function inertial_oscillations_work_with_rotation_in_different_axis(arch, FT)
    #= none:359 =#
    #= none:360 =#
    grid = RectilinearGrid(arch, FT, size = (), topology = (Flat, Flat, Flat))
    #= none:361 =#
    f₀ = 1
    #= none:362 =#
    ū = 1
    #= none:363 =#
    Δt = 0.001
    #= none:364 =#
    T_inertial = (2π) / f₀
    #= none:365 =#
    stop_time = T_inertial / 2
    #= none:366 =#
    zcoriolis = FPlane(f = f₀)
    #= none:367 =#
    xcoriolis = ConstantCartesianCoriolis(f = f₀, rotation_axis = (1, 0, 0))
    #= none:369 =#
    model_x = NonhydrostaticModel(; grid, buoyancy = nothing, tracers = nothing, closure = nothing, timestepper = :RungeKutta3, coriolis = xcoriolis)
    #= none:371 =#
    set!(model_x, v = ū)
    #= none:372 =#
    simulation_x = Simulation(model_x, Δt = Δt, stop_time = stop_time)
    #= none:373 =#
    run!(simulation_x)
    #= none:375 =#
    model_z = NonhydrostaticModel(; grid, buoyancy = nothing, tracers = nothing, closure = nothing, timestepper = :RungeKutta3, coriolis = zcoriolis)
    #= none:377 =#
    set!(model_z, u = ū)
    #= none:378 =#
    simulation_z = Simulation(model_z, Δt = Δt, stop_time = stop_time)
    #= none:379 =#
    run!(simulation_z)
    #= none:381 =#
    u_x = model_x.velocities.u[1, 1, 1]
    #= none:382 =#
    v_x = model_x.velocities.v[1, 1, 1]
    #= none:383 =#
    w_x = model_x.velocities.w[1, 1, 1]
    #= none:385 =#
    u_z = model_z.velocities.u[1, 1, 1]
    #= none:386 =#
    v_z = model_z.velocities.v[1, 1, 1]
    #= none:387 =#
    w_z = model_z.velocities.w[1, 1, 1]
    #= none:389 =#
    #= none:389 =# @test w_z == 0
    #= none:390 =#
    #= none:390 =# @test u_x == 0
    #= none:392 =#
    #= none:392 =# @test √(v_x ^ 2 + w_x ^ 2) ≈ 1
    #= none:393 =#
    #= none:393 =# @test √(u_z ^ 2 + v_z ^ 2) ≈ 1
    #= none:395 =#
    #= none:395 =# @test u_z ≈ v_x
    #= none:396 =#
    #= none:396 =# @test v_z ≈ w_x
    #= none:398 =#
    return nothing
end
#= none:401 =#
timesteppers = (:QuasiAdamsBashforth2, :RungeKutta3)
#= none:403 =#
#= none:403 =# @testset "Dynamics" begin
        #= none:404 =#
        #= none:404 =# @info "Testing dynamics..."
        #= none:406 =#
        #= none:406 =# @testset "Simple diffusion" begin
                #= none:407 =#
                #= none:407 =# @info "  Testing simple diffusion..."
                #= none:408 =#
                for fieldname = (:u, :v, :c), timestepper = timesteppers
                    #= none:409 =#
                    for time_discretization = (ExplicitTimeDiscretization(), VerticallyImplicitTimeDiscretization())
                        #= none:410 =#
                        #= none:410 =# @test test_diffusion_simple(fieldname, timestepper, time_discretization)
                        #= none:411 =#
                    end
                    #= none:412 =#
                end
            end
        #= none:415 =#
        #= none:415 =# @testset "Budgets in isotropic diffusion" begin
                #= none:416 =#
                #= none:416 =# @info "  Testing model budgets with isotropic diffusion..."
                #= none:417 =#
                for timestepper = timesteppers
                    #= none:418 =#
                    for topology = ((Periodic, Periodic, Periodic), (Periodic, Periodic, Bounded), (Periodic, Bounded, Bounded), (Bounded, Bounded, Bounded))
                        #= none:424 =#
                        if topology !== (Periodic, Periodic, Periodic)
                            #= none:425 =#
                            time_discretizations = (ExplicitTimeDiscretization(), VerticallyImplicitTimeDiscretization())
                        else
                            #= none:427 =#
                            time_discretizations = tuple(ExplicitTimeDiscretization())
                        end
                        #= none:430 =#
                        for time_discretization = time_discretizations
                            #= none:431 =#
                            for closurename = [ScalarDiffusivity, VerticalScalarDiffusivity, HorizontalScalarDiffusivity]
                                #= none:434 =#
                                (closurename == HorizontalScalarDiffusivity && time_discretization == VerticallyImplicitTimeDiscretization()) && continue
                                #= none:436 =#
                                closure = closurename(time_discretization, ν = 1, κ = 1)
                                #= none:438 =#
                                fieldnames = [:c]
                                #= none:439 =#
                                topology[1] === Periodic && push!(fieldnames, :u)
                                #= none:440 =#
                                topology[2] === Periodic && push!(fieldnames, :v)
                                #= none:441 =#
                                topology[3] === Periodic && push!(fieldnames, :w)
                                #= none:443 =#
                                grid = RectilinearGrid(size = (4, 4, 4), extent = (1, 1, 1), topology = topology)
                                #= none:445 =#
                                model = NonhydrostaticModel(; timestepper, grid, closure, tracers = :c, coriolis = nothing, buoyancy = nothing)
                                #= none:452 =#
                                td = (typeof(time_discretization)).name.wrapper
                                #= none:454 =#
                                for fieldname = fieldnames
                                    #= none:455 =#
                                    #= none:455 =# @info "    [$(timestepper), $(td), $(closurename)] " * "Testing $(fieldname) budget in a $(topology) domain with scalar diffusion..."
                                    #= none:457 =#
                                    #= none:457 =# @test test_ScalarDiffusivity_budget(fieldname, model)
                                    #= none:458 =#
                                end
                                #= none:459 =#
                            end
                            #= none:460 =#
                        end
                        #= none:461 =#
                    end
                    #= none:462 =#
                end
            end
        #= none:465 =#
        #= none:465 =# @testset "Budgets in biharmonic diffusion" begin
                #= none:466 =#
                #= none:466 =# @info "  Testing model budgets with biharmonic diffusion..."
                #= none:467 =#
                for timestepper = timesteppers
                    #= none:468 =#
                    for topology = ((Periodic, Periodic, Periodic), (Periodic, Periodic, Bounded), (Periodic, Bounded, Bounded), (Bounded, Bounded, Bounded))
                        #= none:473 =#
                        fieldnames = [:c]
                        #= none:475 =#
                        topology[1] === Periodic && push!(fieldnames, :u)
                        #= none:476 =#
                        topology[2] === Periodic && push!(fieldnames, :v)
                        #= none:477 =#
                        topology[3] === Periodic && push!(fieldnames, :w)
                        #= none:479 =#
                        grid = RectilinearGrid(size = (2, 2, 2), extent = (1, 1, 1), topology = topology)
                        #= none:481 =#
                        for formulation = (ThreeDimensionalFormulation(), HorizontalFormulation(), VerticalFormulation())
                            #= none:482 =#
                            model = NonhydrostaticModel(; timestepper, grid, closure = ScalarBiharmonicDiffusivity(formulation, ν = 1, κ = 1), coriolis = nothing, tracers = :c, buoyancy = nothing)
                            #= none:489 =#
                            for fieldname = fieldnames
                                #= none:490 =#
                                #= none:490 =# @info "    [$(timestepper)] Testing $(fieldname) budget in a $(topology) domain " * "with biharmonic diffusion and $(formulation)..."
                                #= none:492 =#
                                #= none:492 =# @test test_ScalarBiharmonicDiffusivity_budget(fieldname, model)
                                #= none:493 =#
                            end
                            #= none:494 =#
                        end
                        #= none:495 =#
                    end
                    #= none:496 =#
                end
            end
        #= none:499 =#
        #= none:499 =# @testset "Diffusion of a cosine" begin
                #= none:500 =#
                for arch = [CPU()]
                    #= none:501 =#
                    (N, L) = (128, π / 2)
                    #= none:502 =#
                    grid = RectilinearGrid(arch, size = N, x = (0, L), topology = (Bounded, Flat, Flat))
                    #= none:505 =#
                    x = reshape(xnodes(grid, Center()), (N, 1, 1))
                    #= none:506 =#
                    y = permutedims(x, (2, 1, 3))
                    #= none:507 =#
                    z = permutedims(x, (2, 3, 1))
                    #= none:510 =#
                    grids = []
                    #= none:511 =#
                    coords = []
                    #= none:512 =#
                    closures = []
                    #= none:513 =#
                    fieldnames = []
                    #= none:515 =#
                    scalar_diffusivity = ScalarDiffusivity(ν = 1, κ = 1)
                    #= none:516 =#
                    implicit_scalar_diffusivity = ScalarDiffusivity(VerticallyImplicitTimeDiscretization(), ν = 1, κ = 1)
                    #= none:517 =#
                    vertical_scalar_diffusivity = VerticalScalarDiffusivity(ν = 1, κ = 1)
                    #= none:518 =#
                    implicit_vertical_scalar_diffusivity = VerticalScalarDiffusivity(VerticallyImplicitTimeDiscretization(), ν = 1, κ = 1)
                    #= none:521 =#
                    append!(coords, [x, y, z])
                    #= none:522 =#
                    append!(fieldnames, [(:v, :w, :c), (:u, :w, :c), (:u, :v, :c)])
                    #= none:523 =#
                    append!(closures, [scalar_diffusivity for i = 1:3])
                    #= none:524 =#
                    append!(grids, [RectilinearGrid(arch, size = (N, 1, 1), x = (0, L), y = (0, 1), z = (0, 1), topology = (Bounded, Periodic, Periodic)), RectilinearGrid(arch, size = (1, N, 1), x = (0, 1), y = (0, L), z = (0, 1), topology = (Periodic, Bounded, Periodic)), RectilinearGrid(arch, size = (1, 1, N), x = (0, 1), y = (0, 1), z = (0, L), topology = (Periodic, Periodic, Bounded))])
                    #= none:529 =#
                    append!(coords, [x, y, z])
                    #= none:530 =#
                    append!(fieldnames, [(:v, :w, :c), (:u, :w, :c), (:u, :v, :c)])
                    #= none:531 =#
                    append!(closures, [HorizontalScalarDiffusivity(ν = 1, κ = 1), HorizontalScalarDiffusivity(ν = 1, κ = 1), VerticalScalarDiffusivity(ν = 1, κ = 1)])
                    #= none:534 =#
                    append!(grids, [RectilinearGrid(arch, size = N, x = (0, L), topology = (Bounded, Flat, Flat)), RectilinearGrid(arch, size = N, y = (0, L), topology = (Flat, Bounded, Flat)), RectilinearGrid(arch, size = N, z = (0, L), topology = (Flat, Flat, Bounded))])
                    #= none:539 =#
                    append!(coords, [z, z])
                    #= none:540 =#
                    append!(fieldnames, [(:u, :v, :c) for i = 1:2])
                    #= none:541 =#
                    append!(closures, [ScalarDiffusivity(VerticallyImplicitTimeDiscretization(), ν = 1, κ = 1), VerticalScalarDiffusivity(VerticallyImplicitTimeDiscretization(), ν = 1, κ = 1)])
                    #= none:543 =#
                    append!(grids, [RectilinearGrid(arch, size = N, z = (0, L), topology = (Flat, Flat, Bounded)), RectilinearGrid(arch, size = N, z = (0, L), topology = (Flat, Flat, Bounded))])
                    #= none:547 =#
                    closure_tuple = (VerticalScalarDiffusivity(VerticallyImplicitTimeDiscretization(), ν = 1 / 2, κ = 1 / 2), VerticalScalarDiffusivity(VerticallyImplicitTimeDiscretization(), ν = 1 / 2, κ = 1 / 2))
                    #= none:549 =#
                    push!(coords, z)
                    #= none:550 =#
                    push!(fieldnames, fieldnames[end])
                    #= none:551 =#
                    push!(closures, closure_tuple)
                    #= none:552 =#
                    push!(grids, grids[end])
                    #= none:555 =#
                    immersed_vertical_grid = ImmersedBoundaryGrid(RectilinearGrid(arch, size = (2, 2, 2N), x = (0, 1), y = (0, 1), z = (0, 2L), topology = (Periodic, Periodic, Bounded)), GridFittedBottom(((x, y)->begin
                                        #= none:561 =#
                                        L
                                    end)))
                    #= none:563 =#
                    z_immersed = reshape(znodes(immersed_vertical_grid, Center()), (1, 1, immersed_vertical_grid.Nz))
                    #= none:565 =#
                    append!(coords, [z_immersed, z_immersed, z_immersed, z_immersed])
                    #= none:566 =#
                    append!(fieldnames, [(:u, :v, :c) for i = 1:4])
                    #= none:567 =#
                    append!(closures, [scalar_diffusivity, implicit_scalar_diffusivity, vertical_scalar_diffusivity, implicit_vertical_scalar_diffusivity])
                    #= none:571 =#
                    append!(grids, [immersed_vertical_grid for i = 1:4])
                    #= none:574 =#
                    stretched_z_grid = RectilinearGrid(arch, size = N, z = center_clustered_coord(N, L, 0), topology = (Flat, Flat, Bounded))
                    #= none:575 =#
                    stretched_immersed_z_grid = ImmersedBoundaryGrid(RectilinearGrid(arch, size = (2, 2, 2N), x = (0, 1), y = (0, 1), z = center_clustered_coord(2N, 2L, 0), topology = (Periodic, Periodic, Bounded)), GridFittedBottom(((x, y)->begin
                                        #= none:582 =#
                                        L
                                    end)))
                    #= none:584 =#
                    stretched_grids = [stretched_z_grid, stretched_z_grid, stretched_immersed_z_grid, stretched_immersed_z_grid]
                    #= none:585 =#
                    append!(coords, [reshape(znodes(grid, Center()), (1, 1, grid.Nz)) for grid = stretched_grids])
                    #= none:586 =#
                    append!(fieldnames, [(:u, :v, :c) for i = 1:4])
                    #= none:587 =#
                    append!(closures, [vertical_scalar_diffusivity, implicit_vertical_scalar_diffusivity, vertical_scalar_diffusivity, implicit_vertical_scalar_diffusivity])
                    #= none:591 =#
                    append!(grids, stretched_grids)
                    #= none:594 =#
                    for case = 1:length(grids)
                        #= none:595 =#
                        closure = closures[case]
                        #= none:596 =#
                        grid = grids[case]
                        #= none:597 =#
                        coord = coords[case]
                        #= none:599 =#
                        for fieldname = fieldnames[case]
                            #= none:600 =#
                            #= none:600 =# @info "  Testing diffusion of a cosine [$(fieldname), $(summary(closure)), $(summary(grid))]..."
                            #= none:601 =#
                            #= none:601 =# @test test_diffusion_cosine(fieldname, grid, closure, coord)
                            #= none:602 =#
                        end
                        #= none:603 =#
                    end
                    #= none:604 =#
                end
            end
    end