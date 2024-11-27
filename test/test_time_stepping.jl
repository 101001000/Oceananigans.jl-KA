
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using TimesDates: TimeDate
#= none:4 =#
using Oceananigans.Grids: topological_tuple_length, total_size
#= none:5 =#
using Oceananigans.Fields: BackgroundField
#= none:6 =#
using Oceananigans.TimeSteppers: Clock
#= none:7 =#
using Oceananigans.TurbulenceClosures: CATKEVerticalDiffusivity
#= none:9 =#
function time_stepping_works_with_flat_dimensions(arch, topology)
    #= none:9 =#
    #= none:10 =#
    size = Tuple((1 for i = 1:topological_tuple_length(topology...)))
    #= none:11 =#
    extent = Tuple((1 for i = 1:topological_tuple_length(topology...)))
    #= none:12 =#
    grid = RectilinearGrid(arch; size, extent, topology)
    #= none:13 =#
    model = NonhydrostaticModel(; grid)
    #= none:14 =#
    time_step!(model, 1)
    #= none:15 =#
    return true
end
#= none:18 =#
function euler_time_stepping_doesnt_propagate_NaNs(arch)
    #= none:18 =#
    #= none:19 =#
    model = HydrostaticFreeSurfaceModel(grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 2, 3)), buoyancy = BuoyancyTracer(), tracers = :b)
    #= none:23 =#
    #= none:23 =# CUDA.@allowscalar model.timestepper.G⁻.u[1, 1, 1] = NaN
    #= none:24 =#
    time_step!(model, 1, euler = true)
    #= none:25 =#
    u111 = #= none:25 =# CUDA.@allowscalar(model.velocities.u[1, 1, 1])
    #= none:27 =#
    return !(isnan(u111))
end
#= none:30 =#
function time_stepping_works_with_coriolis(arch, FT, Coriolis)
    #= none:30 =#
    #= none:31 =#
    grid = RectilinearGrid(arch, FT, size = (1, 1, 1), extent = (1, 2, 3))
    #= none:32 =#
    coriolis = Coriolis(FT, latitude = 45)
    #= none:33 =#
    model = NonhydrostaticModel(; grid, coriolis)
    #= none:34 =#
    time_step!(model, 1)
    #= none:35 =#
    return true
end
#= none:38 =#
function time_stepping_works_with_closure(arch, FT, Closure; buoyancy = Buoyancy(model = SeawaterBuoyancy(FT)))
    #= none:38 =#
    #= none:40 =#
    tracers = [:T, :S]
    #= none:41 =#
    Closure === CATKEVerticalDiffusivity && push!(tracers, :e)
    #= none:44 =#
    grid = RectilinearGrid(arch, FT; size = (3, 3, 3), halo = (3, 3, 3), extent = (1, 2, 3))
    #= none:45 =#
    closure = Closure(FT)
    #= none:46 =#
    model = NonhydrostaticModel(; grid, closure, tracers, buoyancy)
    #= none:47 =#
    time_step!(model, 1)
    #= none:49 =#
    return true
end
#= none:52 =#
function time_stepping_works_with_advection_scheme(arch, advection)
    #= none:52 =#
    #= none:54 =#
    grid = RectilinearGrid(arch, size = (3, 3, 3), halo = (3, 3, 3), extent = (1, 2, 3))
    #= none:55 =#
    model = NonhydrostaticModel(; grid, advection)
    #= none:56 =#
    time_step!(model, 1)
    #= none:57 =#
    return true
end
#= none:60 =#
function time_stepping_works_with_stokes_drift(arch, stokes_drift)
    #= none:60 =#
    #= none:62 =#
    grid = RectilinearGrid(arch, size = (3, 3, 3), halo = (3, 3, 3), extent = (1, 2, 3))
    #= none:63 =#
    model = NonhydrostaticModel(; grid, stokes_drift, advection = nothing)
    #= none:64 =#
    time_step!(model, 1)
    #= none:65 =#
    return true
end
#= none:68 =#
function time_stepping_works_with_nothing_closure(arch, FT)
    #= none:68 =#
    #= none:69 =#
    grid = RectilinearGrid(arch, FT; size = (1, 1, 1), extent = (1, 2, 3))
    #= none:70 =#
    model = NonhydrostaticModel(; grid, closure = nothing)
    #= none:71 =#
    time_step!(model, 1)
    #= none:72 =#
    return true
end
#= none:75 =#
function time_stepping_works_with_nonlinear_eos(arch, FT, EOS)
    #= none:75 =#
    #= none:76 =#
    grid = RectilinearGrid(arch, FT; size = (1, 1, 1), extent = (1, 2, 3))
    #= none:78 =#
    eos = EOS()
    #= none:79 =#
    b = SeawaterBuoyancy(equation_of_state = eos)
    #= none:80 =#
    model = NonhydrostaticModel(; grid, buoyancy = b, tracers = (:T, :S))
    #= none:81 =#
    time_step!(model, 1)
    #= none:83 =#
    return true
end
#= none:86 =#
#= none:86 =# @inline add_ones(args...) = begin
            #= none:86 =#
            1
        end
#= none:88 =#
function run_first_AB2_time_step_tests(arch, FT)
    #= none:88 =#
    #= none:91 =#
    grid = RectilinearGrid(arch, FT, size = (13, 17, 19), extent = (1, 2, 3))
    #= none:93 =#
    model = NonhydrostaticModel(; grid, timestepper = :QuasiAdamsBashforth2, forcing = (; T = add_ones), buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:101 =#
    #= none:101 =# @test all(interior(model.timestepper.Gⁿ.u) .≈ 0)
    #= none:102 =#
    #= none:102 =# @test all(interior(model.timestepper.Gⁿ.v) .≈ 0)
    #= none:103 =#
    #= none:103 =# @test all(interior(model.timestepper.Gⁿ.w) .≈ 0)
    #= none:104 =#
    #= none:104 =# @test all(interior(model.timestepper.Gⁿ.T) .≈ 0)
    #= none:105 =#
    #= none:105 =# @test all(interior(model.timestepper.Gⁿ.S) .≈ 0)
    #= none:108 =#
    Δt = 1
    #= none:109 =#
    time_step!(model, Δt, euler = true)
    #= none:110 =#
    #= none:110 =# @test all(interior(model.velocities.u) .≈ 0)
    #= none:111 =#
    #= none:111 =# @test all(interior(model.velocities.v) .≈ 0)
    #= none:112 =#
    #= none:112 =# @test all(interior(model.velocities.w) .≈ 0)
    #= none:113 =#
    #= none:113 =# @test all(interior(model.tracers.T) .≈ 1)
    #= none:114 =#
    #= none:114 =# @test all(interior(model.tracers.S) .≈ 0)
    #= none:116 =#
    return nothing
end
#= none:119 =#
#= none:119 =# Core.@doc "    This tests to make sure that the velocity field remains incompressible (or divergence-free) as the model is time\n    stepped. It just initializes a cube shaped hot bubble perturbation in the center of the 3D domain to induce a\n    velocity field.\n" function incompressible_in_time(grid, Nt, timestepper)
        #= none:124 =#
        #= none:125 =#
        model = NonhydrostaticModel(grid = grid, timestepper = timestepper, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
        #= none:127 =#
        grid = model.grid
        #= none:128 =#
        (u, v, w) = model.velocities
        #= none:130 =#
        div_U = CenterField(grid)
        #= none:133 =#
        #= none:133 =# CUDA.@allowscalar (interior(model.tracers.T))[8:24, 8:24, 8:24] .+= 0.01
        #= none:135 =#
        update_state!(model)
        #= none:136 =#
        for n = 1:Nt
            #= none:137 =#
            time_step!(model, 0.05)
            #= none:138 =#
        end
        #= none:140 =#
        arch = architecture(grid)
        #= none:141 =#
        launch!(arch, grid, :xyz, divergence!, grid, u.data, v.data, w.data, div_U.data)
        #= none:143 =#
        min_div = #= none:143 =# CUDA.@allowscalar(minimum(interior(div_U)))
        #= none:144 =#
        max_div = #= none:144 =# CUDA.@allowscalar(maximum(interior(div_U)))
        #= none:145 =#
        max_abs_div = #= none:145 =# CUDA.@allowscalar(maximum(abs, interior(div_U)))
        #= none:146 =#
        sum_div = #= none:146 =# CUDA.@allowscalar(sum(interior(div_U)))
        #= none:147 =#
        sum_abs_div = #= none:147 =# CUDA.@allowscalar(sum(abs, interior(div_U)))
        #= none:149 =#
        #= none:149 =# @info "Velocity divergence after $(Nt) time steps [$(typeof(arch)), $(typeof(grid)), $(timestepper)]: " * "min=$(min_div), max=$(max_div), max_abs_div=$(max_abs_div), sum=$(sum_div), abs_sum=$(sum_abs_div)"
        #= none:156 =#
        return isapprox(max_abs_div, 0, atol = 5.0e-8)
    end
#= none:159 =#
#= none:159 =# Core.@doc "    tracer_conserved_in_channel(arch, FT, Nt)\n\nCreate a super-coarse eddying channel model with walls in the y and test that\ntemperature is conserved after `Nt` time steps.\n" function tracer_conserved_in_channel(arch, FT, Nt)
        #= none:165 =#
        #= none:166 =#
        (Nx, Ny, Nz) = (16, 32, 16)
        #= none:167 =#
        (Lx, Ly, Lz) = (160000.0, 320000.0, 1024)
        #= none:169 =#
        α = (Lz / Nz) / (Lx / Nx)
        #= none:170 =#
        (νh, κh) = (20.0, 20.0)
        #= none:171 =#
        (νz, κz) = (α * νh, α * κh)
        #= none:173 =#
        topology = (Periodic, Bounded, Bounded)
        #= none:174 =#
        grid = RectilinearGrid(arch, size = (Nx, Ny, Nz), extent = (Lx, Ly, Lz))
        #= none:175 =#
        model = NonhydrostaticModel(grid = grid, closure = (HorizontalScalarDiffusivity(ν = νh, κ = κh), VerticalScalarDiffusivity(ν = νz, κ = κz)), buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
        #= none:180 =#
        Ty = 0.0001
        #= none:181 =#
        Tz = 0.005
        #= none:184 =#
        T₀(x, y, z) = begin
                #= none:184 =#
                10 + Ty * y + Tz * z + 0.0001 * rand()
            end
        #= none:185 =#
        set!(model, T = T₀)
        #= none:187 =#
        Tavg0 = #= none:187 =# CUDA.@allowscalar(mean(interior(model.tracers.T)))
        #= none:189 =#
        update_state!(model)
        #= none:190 =#
        for n = 1:Nt
            #= none:191 =#
            time_step!(model, 600)
            #= none:192 =#
        end
        #= none:194 =#
        Tavg = #= none:194 =# CUDA.@allowscalar(mean(interior(model.tracers.T)))
        #= none:195 =#
        #= none:195 =# @info "Tracer conservation after $(Nt) time steps [$(typeof(arch)), $(FT)]: " * "⟨T⟩-T₀=$(Tavg - Tavg0) °C"
        #= none:198 =#
        return isapprox(Tavg, Tavg0, atol = Nx * Ny * Nz * eps(FT))
    end
#= none:201 =#
function time_stepping_with_background_fields(arch)
    #= none:201 =#
    #= none:203 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
    #= none:205 =#
    background_u(x, y, z, t) = begin
            #= none:205 =#
            π
        end
    #= none:206 =#
    background_v(x, y, z, t) = begin
            #= none:206 =#
            sin(x) * cos(y) * exp(t)
        end
    #= none:208 =#
    background_w_func(x, y, z, t, p) = begin
            #= none:208 =#
            p.α * x + p.β * exp(z / p.λ)
        end
    #= none:209 =#
    background_w = BackgroundField(background_w_func, parameters = (α = 1.2, β = 0.2, λ = 43))
    #= none:211 =#
    background_T(x, y, z, t) = begin
            #= none:211 =#
            background_u(x, y, z, t)
        end
    #= none:213 =#
    background_S_func(x, y, z, t, α) = begin
            #= none:213 =#
            α * y
        end
    #= none:214 =#
    background_S = BackgroundField(background_S_func, parameters = 1.2)
    #= none:216 =#
    background_R = BackgroundField(1)
    #= none:218 =#
    background_fields = (u = background_u, v = background_v, w = background_w, T = background_T, S = background_S, R = background_R)
    #= none:225 =#
    model = NonhydrostaticModel(; grid, background_fields, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S, :R))
    #= none:229 =#
    time_step!(model, 1)
    #= none:231 =#
    return location(model.background_fields.velocities.u) === (Face, Center, Center) && (location(model.background_fields.velocities.v) === (Center, Face, Center) && (location(model.background_fields.velocities.w) === (Center, Center, Face) && (location(model.background_fields.tracers.T) === (Center, Center, Center) && (location(model.background_fields.tracers.S) === (Center, Center, Center) && location(model.background_fields.tracers.R) === (Nothing, Nothing, Nothing)))))
end
#= none:239 =#
Planes = (FPlane, ConstantCartesianCoriolis, BetaPlane, NonTraditionalBetaPlane)
#= none:241 =#
BuoyancyModifiedAnisotropicMinimumDissipation(FT) = begin
        #= none:241 =#
        AnisotropicMinimumDissipation(FT, Cb = 1.0)
    end
#= none:243 =#
Closures = (ScalarDiffusivity, ScalarBiharmonicDiffusivity, TwoDimensionalLeith, IsopycnalSkewSymmetricDiffusivity, SmagorinskyLilly, AnisotropicMinimumDissipation, BuoyancyModifiedAnisotropicMinimumDissipation, CATKEVerticalDiffusivity)
#= none:252 =#
advection_schemes = (nothing, UpwindBiasedFirstOrder(), CenteredSecondOrder(), UpwindBiasedThirdOrder(), CenteredFourthOrder(), UpwindBiasedFifthOrder(), WENO())
#= none:260 =#
#= none:260 =# @inline ∂t_uˢ_uniform(z, t, h) = begin
            #= none:260 =#
            exp(z / h) * cos(t)
        end
#= none:261 =#
#= none:261 =# @inline ∂t_vˢ_uniform(z, t, h) = begin
            #= none:261 =#
            exp(z / h) * cos(t)
        end
#= none:262 =#
#= none:262 =# @inline ∂z_uˢ_uniform(z, t, h) = begin
            #= none:262 =#
            (exp(z / h) / h) * sin(t)
        end
#= none:263 =#
#= none:263 =# @inline ∂z_vˢ_uniform(z, t, h) = begin
            #= none:263 =#
            (exp(z / h) / h) * sin(t)
        end
#= none:265 =#
parameterized_uniform_stokes_drift = UniformStokesDrift(∂t_uˢ = ∂t_uˢ_uniform, ∂t_vˢ = ∂t_vˢ_uniform, ∂z_uˢ = ∂z_uˢ_uniform, ∂z_vˢ = ∂z_vˢ_uniform, parameters = 20)
#= none:271 =#
#= none:271 =# @inline ∂t_uˢ(x, y, z, t, h) = begin
            #= none:271 =#
            exp(z / h) * cos(t)
        end
#= none:272 =#
#= none:272 =# @inline ∂t_vˢ(x, y, z, t, h) = begin
            #= none:272 =#
            exp(z / h) * cos(t)
        end
#= none:273 =#
#= none:273 =# @inline ∂t_wˢ(x, y, z, t, h) = begin
            #= none:273 =#
            0
        end
#= none:274 =#
#= none:274 =# @inline ∂x_vˢ(x, y, z, t, h) = begin
            #= none:274 =#
            0
        end
#= none:275 =#
#= none:275 =# @inline ∂x_wˢ(x, y, z, t, h) = begin
            #= none:275 =#
            0
        end
#= none:276 =#
#= none:276 =# @inline ∂y_uˢ(x, y, z, t, h) = begin
            #= none:276 =#
            0
        end
#= none:277 =#
#= none:277 =# @inline ∂y_wˢ(x, y, z, t, h) = begin
            #= none:277 =#
            0
        end
#= none:278 =#
#= none:278 =# @inline ∂z_uˢ(x, y, z, t, h) = begin
            #= none:278 =#
            (exp(z / h) / h) * sin(t)
        end
#= none:279 =#
#= none:279 =# @inline ∂z_vˢ(x, y, z, t, h) = begin
            #= none:279 =#
            (exp(z / h) / h) * sin(t)
        end
#= none:281 =#
parameterized_stokes_drift = StokesDrift(∂t_uˢ = ∂t_uˢ, ∂t_vˢ = ∂t_vˢ, ∂t_wˢ = ∂t_wˢ, ∂x_vˢ = ∂x_vˢ, ∂x_wˢ = ∂x_wˢ, ∂y_uˢ = ∂y_uˢ, ∂y_wˢ = ∂y_wˢ, ∂z_uˢ = ∂z_uˢ, ∂z_vˢ = ∂z_vˢ, parameters = 20)
#= none:292 =#
stokes_drifts = (UniformStokesDrift(), StokesDrift(), parameterized_uniform_stokes_drift, parameterized_stokes_drift)
#= none:297 =#
timesteppers = (:QuasiAdamsBashforth2, :RungeKutta3)
#= none:299 =#
#= none:299 =# @testset "Time stepping" begin
        #= none:300 =#
        #= none:300 =# @info "Testing time stepping..."
        #= none:302 =#
        for arch = archs, FT = float_types
            #= none:303 =#
            #= none:303 =# @testset "Time stepping with DateTimes [$(typeof(arch)), $(FT)]" begin
                    #= none:304 =#
                    #= none:304 =# @info "  Testing time stepping with datetime clocks [$(typeof(arch)), $(FT)]"
                    #= none:306 =#
                    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
                    #= none:307 =#
                    clock = Clock(time = DateTime(2020))
                    #= none:308 =#
                    model = NonhydrostaticModel(; grid, clock, timestepper = :QuasiAdamsBashforth2)
                    #= none:310 =#
                    time_step!(model, 7.883)
                    #= none:311 =#
                    #= none:311 =# @test model.clock.time == DateTime("2020-01-01T00:00:07.883")
                    #= none:313 =#
                    model = NonhydrostaticModel(grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1)), timestepper = :QuasiAdamsBashforth2, clock = Clock(time = TimeDate(2020)))
                    #= none:317 =#
                    time_step!(model, 1.23e-7)
                    #= none:318 =#
                    #= none:318 =# @test model.clock.time == TimeDate("2020-01-01T00:00:00.000000123")
                end
            #= none:320 =#
        end
        #= none:322 =#
        #= none:322 =# @testset "Flat dimensions" begin
                #= none:323 =#
                for arch = archs
                    #= none:324 =#
                    for topology = ((Flat, Periodic, Periodic), (Periodic, Flat, Periodic), (Periodic, Periodic, Flat), (Flat, Flat, Bounded))
                        #= none:329 =#
                        (TX, TY, TZ) = topology
                        #= none:330 =#
                        #= none:330 =# @info "  Testing that time stepping works with flat dimensions [$(typeof(arch)), $(TX), $(TY), $(TZ)]..."
                        #= none:331 =#
                        #= none:331 =# @test time_stepping_works_with_flat_dimensions(arch, topology)
                        #= none:332 =#
                    end
                    #= none:333 =#
                end
            end
        #= none:336 =#
        #= none:336 =# @testset "Coriolis" begin
                #= none:337 =#
                for arch = archs, FT = [Float64], Coriolis = Planes
                    #= none:338 =#
                    #= none:338 =# @info "  Testing that time stepping works with Coriolis [$(typeof(arch)), $(FT), $(Coriolis)]..."
                    #= none:339 =#
                    #= none:339 =# @test time_stepping_works_with_coriolis(arch, FT, Coriolis)
                    #= none:340 =#
                end
            end
        #= none:343 =#
        #= none:343 =# @testset "Advection schemes" begin
                #= none:344 =#
                for arch = archs, advection_scheme = advection_schemes
                    #= none:345 =#
                    #= none:345 =# @info "  Testing time stepping with advection schemes [$(typeof(arch)), $(typeof(advection_scheme))]"
                    #= none:346 =#
                    #= none:346 =# @test time_stepping_works_with_advection_scheme(arch, advection_scheme)
                    #= none:347 =#
                end
            end
        #= none:350 =#
        #= none:350 =# @testset "Stokes drift" begin
                #= none:351 =#
                for arch = archs, stokes_drift = stokes_drifts
                    #= none:352 =#
                    #= none:352 =# @info "  Testing time stepping with stokes drift schemes [$(typeof(arch)), $(typeof(stokes_drift))]"
                    #= none:353 =#
                    #= none:353 =# @test time_stepping_works_with_stokes_drift(arch, stokes_drift)
                    #= none:354 =#
                end
            end
        #= none:358 =#
        #= none:358 =# @testset "BackgroundFields" begin
                #= none:359 =#
                for arch = archs
                    #= none:360 =#
                    #= none:360 =# @info "  Testing that time stepping works with background fields [$(typeof(arch))]..."
                    #= none:361 =#
                    #= none:361 =# @test time_stepping_with_background_fields(arch)
                    #= none:362 =#
                end
            end
        #= none:365 =#
        #= none:365 =# @testset "Euler time stepping propagate NaNs in previous tendency G⁻" begin
                #= none:366 =#
                for arch = archs
                    #= none:367 =#
                    #= none:367 =# @info "  Testing that Euler time stepping doesn't propagate NaNs found in previous tendency G⁻ [$(typeof(arch))]..."
                    #= none:368 =#
                    #= none:368 =# @test euler_time_stepping_doesnt_propagate_NaNs(arch)
                    #= none:369 =#
                end
            end
        #= none:372 =#
        #= none:372 =# @testset "Turbulence closures" begin
                #= none:373 =#
                for arch = archs, FT = [Float64]
                    #= none:375 =#
                    #= none:375 =# @info "  Testing that time stepping works [$(typeof(arch)), $(FT), nothing]..."
                    #= none:376 =#
                    #= none:376 =# @test time_stepping_works_with_nothing_closure(arch, FT)
                    #= none:378 =#
                    for Closure = Closures
                        #= none:379 =#
                        #= none:379 =# @info "  Testing that time stepping works [$(typeof(arch)), $(FT), $(Closure)]..."
                        #= none:380 =#
                        if Closure === TwoDimensionalLeith
                            #= none:381 =#
                            #= none:381 =# @test time_stepping_works_with_closure(arch, FT, Closure)
                        elseif #= none:382 =# Closure === CATKEVerticalDiffusivity
                            #= none:384 =#
                            #= none:384 =# @test_skip time_stepping_works_with_closure(arch, FT, Closure)
                        else
                            #= none:386 =#
                            #= none:386 =# @test time_stepping_works_with_closure(arch, FT, Closure)
                        end
                        #= none:388 =#
                    end
                    #= none:391 =#
                    #= none:391 =# @test time_stepping_works_with_closure(arch, FT, AnisotropicMinimumDissipation; buoyancy = nothing)
                    #= none:392 =#
                end
            end
        #= none:395 =#
        #= none:395 =# @testset "Idealized nonlinear equation of state" begin
                #= none:396 =#
                for arch = archs, FT = [Float64]
                    #= none:397 =#
                    for eos_type = (SeawaterPolynomials.RoquetEquationOfState, SeawaterPolynomials.TEOS10EquationOfState)
                        #= none:398 =#
                        #= none:398 =# @info "  Testing that time stepping works with " * "RoquetIdealizedNonlinearEquationOfState [$(typeof(arch)), $(FT), $(eos_type)]"
                        #= none:400 =#
                        #= none:400 =# @test time_stepping_works_with_nonlinear_eos(arch, FT, eos_type)
                        #= none:401 =#
                    end
                    #= none:402 =#
                end
            end
        #= none:405 =#
        #= none:405 =# @testset "2nd-order Adams-Bashforth" begin
                #= none:406 =#
                #= none:406 =# @info "  Testing 2nd-order Adams-Bashforth..."
                #= none:407 =#
                for arch = archs, FT = float_types
                    #= none:408 =#
                    run_first_AB2_time_step_tests(arch, FT)
                    #= none:409 =#
                end
            end
        #= none:412 =#
        #= none:412 =# @testset "Incompressibility" begin
                #= none:413 =#
                for FT = float_types, arch = archs
                    #= none:414 =#
                    (Nx, Ny, Nz) = (32, 32, 32)
                    #= none:416 =#
                    regular_grid = RectilinearGrid(arch, FT, size = (Nx, Ny, Nz), x = (0, 1), y = (0, 1), z = (-1, 1))
                    #= none:418 =#
                    S = 1.3
                    #= none:419 =#
                    hyperbolically_spaced_nodes(k) = begin
                            #= none:419 =#
                            tanh(S * ((2 * (k - 1)) / Nz - 1)) / tanh(S)
                        end
                    #= none:420 =#
                    hyperbolic_vs_grid = RectilinearGrid(arch, FT, size = (Nx, Ny, Nz), x = (0, 1), y = (0, 1), z = hyperbolically_spaced_nodes)
                    #= none:426 =#
                    regular_vs_grid = RectilinearGrid(arch, FT, size = (Nx, Ny, Nz), x = (0, 1), y = (0, 1), z = collect(range(0, stop = 1, length = Nz + 1)))
                    #= none:432 =#
                    for grid = (regular_grid, hyperbolic_vs_grid, regular_vs_grid)
                        #= none:433 =#
                        #= none:433 =# @info "  Testing incompressibility [$(FT), $((typeof(grid)).name.wrapper)]..."
                        #= none:435 =#
                        for Nt = [1, 10, 100], timestepper = timesteppers
                            #= none:436 =#
                            #= none:436 =# @test incompressible_in_time(grid, Nt, timestepper)
                            #= none:437 =#
                        end
                        #= none:438 =#
                    end
                    #= none:439 =#
                end
            end
        #= none:442 =#
        #= none:442 =# @testset "Tracer conservation in channel" begin
                #= none:443 =#
                #= none:443 =# @info "  Testing tracer conservation in channel..."
                #= none:444 =#
                for arch = archs, FT = float_types
                    #= none:445 =#
                    #= none:445 =# @test tracer_conserved_in_channel(arch, FT, 10)
                    #= none:446 =#
                end
            end
    end