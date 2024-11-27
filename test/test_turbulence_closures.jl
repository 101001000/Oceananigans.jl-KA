
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.TurbulenceClosures: CATKEVerticalDiffusivity, RiBasedVerticalDiffusivity, DiscreteDiffusionFunction
#= none:5 =#
using Oceananigans.TurbulenceClosures: viscosity_location, diffusivity_location, required_halo_size_x, required_halo_size_y, required_halo_size_z
#= none:8 =#
using Oceananigans.TurbulenceClosures: diffusive_flux_x, diffusive_flux_y, diffusive_flux_z, viscous_flux_ux, viscous_flux_uy, viscous_flux_uz, viscous_flux_vx, viscous_flux_vy, viscous_flux_vz, viscous_flux_wx, viscous_flux_wy, viscous_flux_wz
#= none:13 =#
for closure = closures
    #= none:14 =#
    #= none:14 =# @eval begin
            #= none:15 =#
            using Oceananigans.TurbulenceClosures: $closure
        end
    #= none:17 =#
end
#= none:19 =#
function tracer_specific_horizontal_diffusivity(T = Float64; νh = T(0.3), κh = T(0.7))
    #= none:19 =#
    #= none:20 =#
    closure = HorizontalScalarDiffusivity(κ = (T = κh, S = κh), ν = νh)
    #= none:21 =#
    return closure.ν == νh && (closure.κ.T == κh && closure.κ.T == κh)
end
#= none:24 =#
function run_constant_isotropic_diffusivity_fluxdiv_tests(FT = Float64; ν = FT(0.3), κ = FT(0.7))
    #= none:24 =#
    #= none:25 =#
    arch = CPU()
    #= none:26 =#
    closure = ScalarDiffusivity(FT, κ = (T = κ, S = κ), ν = ν)
    #= none:27 =#
    grid = RectilinearGrid(FT, size = (3, 1, 4), extent = (3, 1, 4))
    #= none:28 =#
    velocities = VelocityFields(grid)
    #= none:29 =#
    tracers = TracerFields((:T, :S), grid)
    #= none:30 =#
    clock = Clock(time = 0.0)
    #= none:32 =#
    (u, v, w) = velocities
    #= none:33 =#
    (T, S) = tracers
    #= none:35 =#
    for k = 1:4
        #= none:36 =#
        (interior(u))[:, 1, k] .= [0, -1 / 2, 0]
        #= none:37 =#
        (interior(v))[:, 1, k] .= [0, -2, 0]
        #= none:38 =#
        (interior(w))[:, 1, k] .= [0, -3, 0]
        #= none:39 =#
        (interior(T))[:, 1, k] .= [0, -1, 0]
        #= none:40 =#
    end
    #= none:42 =#
    model_fields = merge(datatuple(velocities), datatuple(tracers))
    #= none:43 =#
    fill_halo_regions!(merge(velocities, tracers), nothing, model_fields)
    #= none:45 =#
    (K, b) = (nothing, nothing)
    #= none:46 =#
    closure_args = (clock, model_fields, b)
    #= none:48 =#
    #= none:48 =# @test ∇_dot_qᶜ(2, 1, 3, grid, closure, K, Val(1), tracers[1], closure_args...) == -2 * κ
    #= none:49 =#
    #= none:49 =# @test ∂ⱼ_τ₁ⱼ(2, 1, 3, grid, closure, K, closure_args...) == -2 * ν
    #= none:50 =#
    #= none:50 =# @test ∂ⱼ_τ₂ⱼ(2, 1, 3, grid, closure, K, closure_args...) == -4 * ν
    #= none:51 =#
    #= none:51 =# @test ∂ⱼ_τ₃ⱼ(2, 1, 3, grid, closure, K, closure_args...) == -6 * ν
    #= none:53 =#
    return nothing
end
#= none:56 =#
function horizontal_diffusivity_fluxdiv(FT = Float64; νh = FT(0.3), κh = FT(0.7), νz = FT(0.1), κz = FT(0.5))
    #= none:56 =#
    #= none:57 =#
    arch = CPU()
    #= none:58 =#
    closureh = HorizontalScalarDiffusivity(FT, ν = νh, κ = (T = κh, S = κh))
    #= none:59 =#
    closurez = VerticalScalarDiffusivity(FT, ν = νz, κ = (T = κz, S = κz))
    #= none:60 =#
    grid = RectilinearGrid(arch, FT, size = (3, 1, 4), extent = (3, 1, 4))
    #= none:61 =#
    eos = LinearEquationOfState(FT)
    #= none:62 =#
    buoyancy = SeawaterBuoyancy(FT, gravitational_acceleration = 1, equation_of_state = eos)
    #= none:63 =#
    velocities = VelocityFields(grid)
    #= none:64 =#
    tracers = TracerFields((:T, :S), grid)
    #= none:65 =#
    clock = Clock(time = 0.0)
    #= none:67 =#
    (u, v, w, T, S) = merge(velocities, tracers)
    #= none:69 =#
    (interior(u))[:, 1, 2] .= [0, 1, 0]
    #= none:70 =#
    (interior(u))[:, 1, 3] .= [0, -1, 0]
    #= none:71 =#
    (interior(u))[:, 1, 4] .= [0, 1, 0]
    #= none:73 =#
    (interior(v))[:, 1, 2] .= [0, 1, 0]
    #= none:74 =#
    (interior(v))[:, 1, 3] .= [0, -2, 0]
    #= none:75 =#
    (interior(v))[:, 1, 4] .= [0, 1, 0]
    #= none:77 =#
    (interior(w))[:, 1, 2] .= [0, 1, 0]
    #= none:78 =#
    (interior(w))[:, 1, 3] .= [0, -3, 0]
    #= none:79 =#
    (interior(w))[:, 1, 4] .= [0, 1, 0]
    #= none:81 =#
    (interior(T))[:, 1, 2] .= [0, 1, 0]
    #= none:82 =#
    (interior(T))[:, 1, 3] .= [0, -4, 0]
    #= none:83 =#
    (interior(T))[:, 1, 4] .= [0, 1, 0]
    #= none:85 =#
    model_fields = merge(datatuple(velocities), datatuple(tracers))
    #= none:86 =#
    fill_halo_regions!(merge(velocities, tracers), nothing, model_fields)
    #= none:88 =#
    (K, b) = (nothing, nothing)
    #= none:89 =#
    closure_args = (clock, model_fields, b)
    #= none:91 =#
    return ∇_dot_qᶜ(2, 1, 3, grid, closureh, K, Val(1), T, closure_args...) == -8 * κh && (∇_dot_qᶜ(2, 1, 3, grid, closurez, K, Val(1), T, closure_args...) == -10 * κz && (∂ⱼ_τ₁ⱼ(2, 1, 3, grid, closureh, K, closure_args...) == -(2νh) && (∂ⱼ_τ₁ⱼ(2, 1, 3, grid, closurez, K, closure_args...) == -(4νz) && (∂ⱼ_τ₂ⱼ(2, 1, 3, grid, closureh, K, closure_args...) == -(4νh) && (∂ⱼ_τ₂ⱼ(2, 1, 3, grid, closurez, K, closure_args...) == -(6νz) && (∂ⱼ_τ₃ⱼ(2, 1, 3, grid, closureh, K, closure_args...) == -(6νh) && ∂ⱼ_τ₃ⱼ(2, 1, 3, grid, closurez, K, closure_args...) == -(8νz)))))))
end
#= none:101 =#
function time_step_with_variable_isotropic_diffusivity(arch)
    #= none:101 =#
    #= none:102 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 2, 3))
    #= none:103 =#
    closure = ScalarDiffusivity(ν = ((x, y, z, t)->begin
                        #= none:103 =#
                        exp(z) * cos(x) * cos(y) * cos(t)
                    end), κ = ((x, y, z, t)->begin
                        #= none:104 =#
                        exp(z) * cos(x) * cos(y) * cos(t)
                    end))
    #= none:106 =#
    model = NonhydrostaticModel(; grid, closure)
    #= none:108 =#
    time_step!(model, 1)
    #= none:109 =#
    return true
end
#= none:112 =#
function time_step_with_field_isotropic_diffusivity(arch)
    #= none:112 =#
    #= none:113 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 2, 3))
    #= none:114 =#
    ν = CenterField(grid)
    #= none:115 =#
    κ = CenterField(grid)
    #= none:116 =#
    closure = ScalarDiffusivity(; ν, κ)
    #= none:117 =#
    model = NonhydrostaticModel(; grid, closure)
    #= none:118 =#
    time_step!(model, 1)
    #= none:119 =#
    return true
end
#= none:122 =#
function time_step_with_variable_anisotropic_diffusivity(arch)
    #= none:122 =#
    #= none:123 =#
    clov = VerticalScalarDiffusivity(ν = ((x, y, z, t)->begin
                        #= none:123 =#
                        exp(z) * cos(x) * cos(y) * cos(t)
                    end), κ = ((x, y, z, t)->begin
                        #= none:124 =#
                        exp(z) * cos(x) * cos(y) * cos(t)
                    end))
    #= none:126 =#
    cloh = HorizontalScalarDiffusivity(ν = ((x, y, z, t)->begin
                        #= none:126 =#
                        exp(z) * cos(x) * cos(y) * cos(t)
                    end), κ = ((x, y, z, t)->begin
                        #= none:127 =#
                        exp(z) * cos(x) * cos(y) * cos(t)
                    end))
    #= none:128 =#
    for clo = (clov, cloh)
        #= none:129 =#
        model = NonhydrostaticModel(grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 2, 3)), closure = clo)
        #= none:130 =#
        time_step!(model, 1)
        #= none:131 =#
    end
    #= none:133 =#
    return true
end
#= none:136 =#
function time_step_with_variable_discrete_diffusivity(arch)
    #= none:136 =#
    #= none:137 =#
    #= none:137 =# @inline νd(i, j, k, grid, clock, fields) = begin
                #= none:137 =#
                1 + fields.u[i, j, k] * 5
            end
    #= none:138 =#
    #= none:138 =# @inline κd(i, j, k, grid, clock, fields) = begin
                #= none:138 =#
                1 + fields.v[i, j, k] * 5
            end
    #= none:140 =#
    closure_ν = ScalarDiffusivity(ν = νd, discrete_form = true, loc = (Face, Center, Center))
    #= none:141 =#
    closure_κ = ScalarDiffusivity(κ = κd, discrete_form = true, loc = (Center, Face, Center))
    #= none:143 =#
    model = NonhydrostaticModel(grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 2, 3)), tracers = (:T, :S), closure = (closure_ν, closure_κ))
    #= none:147 =#
    time_step!(model, 1)
    #= none:148 =#
    return true
end
#= none:151 =#
function time_step_with_tupled_closure(FT, arch)
    #= none:151 =#
    #= none:152 =#
    closure_tuple = (AnisotropicMinimumDissipation(FT), ScalarDiffusivity(FT))
    #= none:154 =#
    model = NonhydrostaticModel(closure = closure_tuple, grid = RectilinearGrid(arch, FT, size = (2, 2, 2), extent = (1, 2, 3)))
    #= none:157 =#
    time_step!(model, 1)
    #= none:158 =#
    return true
end
#= none:161 =#
function run_time_step_with_catke_tests(arch, closure)
    #= none:161 =#
    #= none:162 =#
    grid = RectilinearGrid(arch, size = (2, 2, 2), extent = (1, 2, 3))
    #= none:163 =#
    buoyancy = BuoyancyTracer()
    #= none:166 =#
    #= none:166 =# @test_throws ArgumentError HydrostaticFreeSurfaceModel(; grid, closure, buoyancy, tracers = :b)
    #= none:167 =#
    #= none:167 =# @test_throws ArgumentError HydrostaticFreeSurfaceModel(; grid, closure, buoyancy, tracers = (:b, :E))
    #= none:170 =#
    #= none:170 =# @test_throws ErrorException NonhydrostaticModel(; grid, closure, buoyancy, tracers = (:b, :c, :e))
    #= none:172 =#
    model = HydrostaticFreeSurfaceModel(; grid, closure, buoyancy, tracers = (:b, :c, :e))
    #= none:175 =#
    #= none:175 =# @test !(model.tracers.e.boundary_conditions.top.condition isa BoundaryCondition{Flux, Nothing})
    #= none:178 =#
    time_step!(model, 1)
    #= none:179 =#
    #= none:179 =# @test true
    #= none:182 =#
    time_step!(model, 1)
    #= none:183 =#
    #= none:183 =# @test true
    #= none:186 =#
    return model
end
#= none:189 =#
function compute_closure_specific_diffusive_cfl(closure)
    #= none:189 =#
    #= none:190 =#
    grid = RectilinearGrid(CPU(), size = (2, 2, 2), extent = (1, 2, 3))
    #= none:192 =#
    model = NonhydrostaticModel(; grid, closure, buoyancy = BuoyancyTracer(), tracers = :b)
    #= none:193 =#
    dcfl = DiffusiveCFL(0.1)
    #= none:194 =#
    #= none:194 =# @test dcfl(model) isa Number
    #= none:195 =#
    #= none:195 =# @test diffusive_flux_x(1, 1, 1, grid, model.closure, model.diffusivity_fields, Val(1), model.tracers.b, model.clock, fields(model), model.buoyancy) == 0
    #= none:196 =#
    #= none:196 =# @test diffusive_flux_y(1, 1, 1, grid, model.closure, model.diffusivity_fields, Val(1), model.tracers.b, model.clock, fields(model), model.buoyancy) == 0
    #= none:197 =#
    #= none:197 =# @test diffusive_flux_z(1, 1, 1, grid, model.closure, model.diffusivity_fields, Val(1), model.tracers.b, model.clock, fields(model), model.buoyancy) == 0
    #= none:199 =#
    tracerless_model = NonhydrostaticModel(; grid, closure, buoyancy = nothing, tracers = nothing)
    #= none:200 =#
    dcfl = DiffusiveCFL(0.2)
    #= none:201 =#
    #= none:201 =# @test dcfl(tracerless_model) isa Number
    #= none:202 =#
    #= none:202 =# @test viscous_flux_ux(1, 1, 1, grid, model.closure, model.diffusivity_fields, model.clock, fields(model), model.buoyancy) == 0
    #= none:203 =#
    #= none:203 =# @test viscous_flux_uy(1, 1, 1, grid, model.closure, model.diffusivity_fields, model.clock, fields(model), model.buoyancy) == 0
    #= none:204 =#
    #= none:204 =# @test viscous_flux_uz(1, 1, 1, grid, model.closure, model.diffusivity_fields, model.clock, fields(model), model.buoyancy) == 0
    #= none:206 =#
    return nothing
end
#= none:209 =#
#= none:209 =# @testset "Turbulence closures" begin
        #= none:210 =#
        #= none:210 =# @info "Testing turbulence closures..."
        #= none:212 =#
        #= none:212 =# @testset "Closure instantiation" begin
                #= none:213 =#
                #= none:213 =# @info "  Testing closure instantiation..."
                #= none:214 =#
                for closurename = closures
                    #= none:215 =#
                    closure = (getproperty(TurbulenceClosures, closurename))()
                    #= none:216 =#
                    #= none:216 =# @test closure isa TurbulenceClosures.AbstractTurbulenceClosure
                    #= none:218 =#
                    grid = RectilinearGrid(CPU(), size = (2, 2, 2), extent = (1, 2, 3))
                    #= none:219 =#
                    model = NonhydrostaticModel(grid = grid, closure = closure, tracers = :c)
                    #= none:220 =#
                    c = model.tracers.c
                    #= none:221 =#
                    u = model.velocities.u
                    #= none:222 =#
                    κ = diffusivity(model.closure, model.diffusivity_fields, Val(:c))
                    #= none:223 =#
                    κ_dx_c = κ * ∂x(c)
                    #= none:224 =#
                    ν = viscosity(model.closure, model.diffusivity_fields)
                    #= none:225 =#
                    ν_dx_u = ν * ∂x(u)
                    #= none:226 =#
                    #= none:226 =# @test ν_dx_u[1, 1, 1] == 0.0
                    #= none:227 =#
                    #= none:227 =# @test κ_dx_c[1, 1, 1] == 0.0
                    #= none:228 =#
                end
                #= none:230 =#
                c = Center()
                #= none:231 =#
                f = Face()
                #= none:232 =#
                ri_based = RiBasedVerticalDiffusivity()
                #= none:233 =#
                #= none:233 =# @test viscosity_location(ri_based) == (c, c, f)
                #= none:234 =#
                #= none:234 =# @test diffusivity_location(ri_based) == (c, c, f)
                #= none:236 =#
                catke = CATKEVerticalDiffusivity()
                #= none:237 =#
                #= none:237 =# @test viscosity_location(catke) == (c, c, f)
                #= none:238 =#
                #= none:238 =# @test diffusivity_location(catke) == (c, c, f)
            end
        #= none:241 =#
        #= none:241 =# @testset "ScalarDiffusivity" begin
                #= none:242 =#
                #= none:242 =# @info "  Testing ScalarDiffusivity..."
                #= none:243 =#
                for T = float_types
                    #= none:244 =#
                    (ν, κ) = (0.3, 0.7)
                    #= none:245 =#
                    closure = ScalarDiffusivity(T; κ = (T = κ, S = κ), ν = ν)
                    #= none:246 =#
                    #= none:246 =# @test closure.ν == T(ν)
                    #= none:247 =#
                    #= none:247 =# @test closure.κ.T == T(κ)
                    #= none:248 =#
                    run_constant_isotropic_diffusivity_fluxdiv_tests(T)
                    #= none:249 =#
                end
                #= none:251 =#
                #= none:251 =# @info "  Testing ScalarDiffusivity with different halo requirements..."
                #= none:252 =#
                closure = ScalarDiffusivity(ν = 0.3)
                #= none:253 =#
                #= none:253 =# @test required_halo_size_x(closure) == 1
                #= none:254 =#
                #= none:254 =# @test required_halo_size_y(closure) == 1
                #= none:255 =#
                #= none:255 =# @test required_halo_size_z(closure) == 1
                #= none:257 =#
                closure = ScalarBiharmonicDiffusivity(ν = 0.3)
                #= none:258 =#
                #= none:258 =# @test required_halo_size_x(closure) == 2
                #= none:259 =#
                #= none:259 =# @test required_halo_size_y(closure) == 2
                #= none:260 =#
                #= none:260 =# @test required_halo_size_z(closure) == 2
                #= none:262 =#
                #= none:262 =# @inline ν(i, j, k, grid, ℓx, ℓy, ℓz, clock, fields) = begin
                            #= none:262 =#
                            ℑxᶠᵃᵃ(i, j, k, grid, ℑxᶜᵃᵃ, fields.u)
                        end
                #= none:263 =#
                closure = ScalarDiffusivity(; ν, discrete_form = true, required_halo_size = 2)
                #= none:265 =#
                #= none:265 =# @test closure.ν isa DiscreteDiffusionFunction
                #= none:266 =#
                #= none:266 =# @test required_halo_size_x(closure) == 2
                #= none:267 =#
                #= none:267 =# @test required_halo_size_y(closure) == 2
                #= none:268 =#
                #= none:268 =# @test required_halo_size_z(closure) == 2
            end
        #= none:272 =#
        #= none:272 =# @testset "HorizontalScalarDiffusivity" begin
                #= none:273 =#
                #= none:273 =# @info "  Testing HorizontalScalarDiffusivity..."
                #= none:274 =#
                for T = float_types
                    #= none:275 =#
                    #= none:275 =# @test tracer_specific_horizontal_diffusivity(T)
                    #= none:276 =#
                    #= none:276 =# @test horizontal_diffusivity_fluxdiv(T, νz = zero(T), νh = zero(T))
                    #= none:277 =#
                    #= none:277 =# @test horizontal_diffusivity_fluxdiv(T)
                    #= none:278 =#
                end
            end
        #= none:281 =#
        #= none:281 =# @testset "Time-stepping with variable diffusivities" begin
                #= none:282 =#
                #= none:282 =# @info "  Testing time-stepping with presribed variable diffusivities..."
                #= none:283 =#
                for arch = archs
                    #= none:284 =#
                    #= none:284 =# @test time_step_with_variable_isotropic_diffusivity(arch)
                    #= none:285 =#
                    #= none:285 =# @test time_step_with_field_isotropic_diffusivity(arch)
                    #= none:286 =#
                    #= none:286 =# @test time_step_with_variable_anisotropic_diffusivity(arch)
                    #= none:287 =#
                    #= none:287 =# @test time_step_with_variable_discrete_diffusivity(arch)
                    #= none:288 =#
                end
            end
        #= none:291 =#
        #= none:291 =# @testset "Time-stepping with CATKE closure" begin
                #= none:292 =#
                #= none:292 =# @info "  Testing time-stepping with CATKE closure and closure tuples with CATKE..."
                #= none:293 =#
                for arch = archs
                    #= none:294 =#
                    #= none:294 =# @info "    Testing time-stepping CATKE by itself..."
                    #= none:295 =#
                    closure = CATKEVerticalDiffusivity()
                    #= none:296 =#
                    run_time_step_with_catke_tests(arch, closure)
                    #= none:298 =#
                    #= none:298 =# @info "    Testing time-stepping CATKE in a 2-tuple with HorizontalScalarDiffusivity..."
                    #= none:299 =#
                    closure = (CATKEVerticalDiffusivity(), HorizontalScalarDiffusivity())
                    #= none:300 =#
                    model = run_time_step_with_catke_tests(arch, closure)
                    #= none:301 =#
                    #= none:301 =# @test first(model.closure) === closure[1]
                    #= none:304 =#
                    #= none:304 =# @info "    Testing time-stepping CATKE in a 2-tuple with HorizontalScalarDiffusivity..."
                    #= none:305 =#
                    closure = (HorizontalScalarDiffusivity(), CATKEVerticalDiffusivity())
                    #= none:306 =#
                    model = run_time_step_with_catke_tests(arch, closure)
                    #= none:307 =#
                    #= none:307 =# @test first(model.closure) === closure[2]
                    #= none:310 =#
                    #= none:310 =# @info "    Testing time-stepping CATKE in a 3-tuple..."
                    #= none:311 =#
                    closure = (HorizontalScalarDiffusivity(), CATKEVerticalDiffusivity(), VerticalScalarDiffusivity())
                    #= none:312 =#
                    model = run_time_step_with_catke_tests(arch, closure)
                    #= none:313 =#
                    #= none:313 =# @test first(model.closure) === closure[2]
                    #= none:314 =#
                end
            end
        #= none:317 =#
        #= none:317 =# @testset "Closure tuples" begin
                #= none:318 =#
                #= none:318 =# @info "  Testing time-stepping with a tuple of closures..."
                #= none:319 =#
                for arch = archs
                    #= none:320 =#
                    for FT = float_types
                        #= none:321 =#
                        #= none:321 =# @test time_step_with_tupled_closure(FT, arch)
                        #= none:322 =#
                    end
                    #= none:323 =#
                end
            end
        #= none:326 =#
        #= none:326 =# @testset "Diagnostics" begin
                #= none:327 =#
                #= none:327 =# @info "  Testing turbulence closure diagnostics..."
                #= none:328 =#
                for closurename = closures
                    #= none:329 =#
                    closure = (getproperty(TurbulenceClosures, closurename))()
                    #= none:330 =#
                    compute_closure_specific_diffusive_cfl(closure)
                    #= none:331 =#
                end
                #= none:334 =#
                compute_closure_specific_diffusive_cfl((ScalarDiffusivity(), ScalarBiharmonicDiffusivity(), SmagorinskyLilly(), AnisotropicMinimumDissipation()))
            end
    end