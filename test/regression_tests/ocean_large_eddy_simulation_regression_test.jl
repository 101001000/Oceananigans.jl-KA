
#= none:1 =#
using Oceananigans.TurbulenceClosures: AnisotropicMinimumDissipation
#= none:2 =#
using Oceananigans.TimeSteppers: update_state!
#= none:3 =#
using Oceananigans.DistributedComputations: cpu_architecture, partition
#= none:5 =#
function run_ocean_large_eddy_simulation_regression_test(arch, grid_type, closure)
    #= none:5 =#
    #= none:6 =#
    name = "ocean_large_eddy_simulation_" * string((typeof(first(closure))).name.wrapper)
    #= none:8 =#
    spinup_steps = 10000
    #= none:9 =#
    test_steps = 10
    #= none:10 =#
    Δt = 2.0
    #= none:13 =#
    Qᵀ = 5.0e-5
    #= none:14 =#
    Qᵘ = -2.0e-5
    #= none:15 =#
    ∂T∂z = 0.005
    #= none:18 =#
    N = (L = 16)
    #= none:19 =#
    if grid_type == :regular
        #= none:20 =#
        grid = RectilinearGrid(arch, size = (N, N, N), extent = (L, L, L), halo = (2, 2, 2))
    elseif #= none:21 =# grid_type == :vertically_unstretched
        #= none:22 =#
        zF = range(-L, 0, length = N + 1)
        #= none:23 =#
        grid = RectilinearGrid(arch, size = (N, N, N), x = (0, L), y = (0, L), z = zF, halo = (2, 2, 2))
    end
    #= none:27 =#
    u_bcs = FieldBoundaryConditions(top = BoundaryCondition(Flux(), Qᵘ))
    #= none:28 =#
    T_bcs = FieldBoundaryConditions(top = BoundaryCondition(Flux(), Qᵀ), bottom = BoundaryCondition(Gradient(), ∂T∂z))
    #= none:29 =#
    S_bcs = FieldBoundaryConditions(top = BoundaryCondition(Flux(), 5.0e-8))
    #= none:31 =#
    equation_of_state = LinearEquationOfState(thermal_expansion = 0.0002, haline_contraction = 0.0008)
    #= none:34 =#
    model = NonhydrostaticModel(; grid, closure, timestepper = :QuasiAdamsBashforth2, coriolis = FPlane(f = 0.0001), buoyancy = SeawaterBuoyancy(; equation_of_state), tracers = (:T, :S), hydrostatic_pressure_anomaly = CenterField(grid), boundary_conditions = (u = u_bcs, T = T_bcs, S = S_bcs))
    #= none:43 =#
    ArrayType = typeof(model.velocities.u.data.parent)
    #= none:44 =#
    (nx, ny, nz) = size(model.tracers.T)
    #= none:46 =#
    (u, v, w) = model.velocities
    #= none:47 =#
    (T, S) = model.tracers
    #= none:79 =#
    datadep_path = "regression_test_data/" * name * "_iteration$(spinup_steps).jld2"
    #= none:80 =#
    initial_filename = #= none:80 =# @datadep_str(datadep_path)
    #= none:82 =#
    (solution₀, Gⁿ₀, G⁻₀) = get_fields_from_checkpoint(initial_filename)
    #= none:84 =#
    Nz = grid.Nz
    #= none:86 =#
    cpu_arch = cpu_architecture(architecture(grid))
    #= none:88 =#
    u₀ = partition(ArrayType(solution₀.u[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(u))
    #= none:89 =#
    v₀ = partition(ArrayType(solution₀.v[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(v))
    #= none:90 =#
    w₀ = partition(ArrayType(solution₀.w[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(w))
    #= none:91 =#
    T₀ = partition(ArrayType(solution₀.T[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(T))
    #= none:92 =#
    S₀ = partition(ArrayType(solution₀.S[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(S))
    #= none:94 =#
    Gⁿu₀ = partition((ArrayType(Gⁿ₀.u))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(u))
    #= none:95 =#
    Gⁿv₀ = partition((ArrayType(Gⁿ₀.v))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(v))
    #= none:96 =#
    Gⁿw₀ = partition((ArrayType(Gⁿ₀.w))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(w))
    #= none:97 =#
    GⁿT₀ = partition((ArrayType(Gⁿ₀.T))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(T))
    #= none:98 =#
    GⁿS₀ = partition((ArrayType(Gⁿ₀.S))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(S))
    #= none:100 =#
    G⁻u₀ = partition((ArrayType(G⁻₀.u))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(u))
    #= none:101 =#
    G⁻v₀ = partition((ArrayType(G⁻₀.v))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(v))
    #= none:102 =#
    G⁻w₀ = partition((ArrayType(G⁻₀.w))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(w))
    #= none:103 =#
    G⁻T₀ = partition((ArrayType(G⁻₀.T))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(T))
    #= none:104 =#
    G⁻S₀ = partition((ArrayType(G⁻₀.S))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(S))
    #= none:106 =#
    interior(model.velocities.u) .= u₀
    #= none:107 =#
    interior(model.velocities.v) .= v₀
    #= none:108 =#
    interior(model.velocities.w) .= w₀
    #= none:109 =#
    interior(model.tracers.T) .= T₀
    #= none:110 =#
    interior(model.tracers.S) .= S₀
    #= none:112 =#
    interior(model.timestepper.Gⁿ.u) .= Gⁿu₀
    #= none:113 =#
    interior(model.timestepper.Gⁿ.v) .= Gⁿv₀
    #= none:114 =#
    interior(model.timestepper.Gⁿ.w) .= Gⁿw₀
    #= none:115 =#
    interior(model.timestepper.Gⁿ.T) .= GⁿT₀
    #= none:116 =#
    interior(model.timestepper.Gⁿ.S) .= GⁿS₀
    #= none:118 =#
    interior(model.timestepper.G⁻.u) .= G⁻u₀
    #= none:119 =#
    interior(model.timestepper.G⁻.v) .= G⁻v₀
    #= none:120 =#
    interior(model.timestepper.G⁻.w) .= G⁻w₀
    #= none:121 =#
    interior(model.timestepper.G⁻.T) .= G⁻T₀
    #= none:122 =#
    interior(model.timestepper.G⁻.S) .= G⁻S₀
    #= none:124 =#
    model.clock.time = spinup_steps * Δt
    #= none:125 =#
    model.clock.iteration = spinup_steps
    #= none:127 =#
    update_state!(model; compute_tendencies = true)
    #= none:128 =#
    model.clock.last_Δt = Δt
    #= none:130 =#
    for n = 1:test_steps
        #= none:131 =#
        time_step!(model, Δt, euler = false)
        #= none:132 =#
    end
    #= none:134 =#
    datadep_path = "regression_test_data/" * name * "_iteration$(spinup_steps + test_steps).jld2"
    #= none:135 =#
    final_filename = #= none:135 =# @datadep_str(datadep_path)
    #= none:137 =#
    (solution₁, Gⁿ₁, G⁻₁) = get_fields_from_checkpoint(final_filename)
    #= none:139 =#
    test_fields = #= none:139 =# CUDA.@allowscalar((u = Array(interior(model.velocities.u)), v = Array(interior(model.velocities.v)), w = Array((interior(model.velocities.w))[:, :, 1:nz]), T = Array(interior(model.tracers.T)), S = Array(interior(model.tracers.S))))
    #= none:145 =#
    u₁ = partition((Array(solution₁.u))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(u))
    #= none:146 =#
    v₁ = partition((Array(solution₁.v))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(v))
    #= none:147 =#
    w₁ = partition((Array(solution₁.w))[2:end - 1, 2:end - 1, 2:end - 2], cpu_arch, size(test_fields.w))
    #= none:148 =#
    T₁ = partition((Array(solution₁.T))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(T))
    #= none:149 =#
    S₁ = partition((Array(solution₁.S))[2:end - 1, 2:end - 1, 2:end - 1], cpu_arch, size(S))
    #= none:151 =#
    #= none:151 =# @show (size(test_fields.w), size(w₁))
    #= none:153 =#
    correct_fields = (u = u₁, v = v₁, w = w₁, T = T₁, S = S₁)
    #= none:159 =#
    summarize_regression_test(test_fields, correct_fields)
    #= none:161 =#
    #= none:161 =# @test all(test_fields.u .≈ correct_fields.u)
    #= none:162 =#
    #= none:162 =# @test all(test_fields.v .≈ correct_fields.v)
    #= none:163 =#
    #= none:163 =# @test all(test_fields.w .≈ correct_fields.w)
    #= none:164 =#
    #= none:164 =# @test all(test_fields.T .≈ correct_fields.T)
    #= none:165 =#
    #= none:165 =# @test all(test_fields.S .≈ correct_fields.S)
    #= none:167 =#
    return nothing
end