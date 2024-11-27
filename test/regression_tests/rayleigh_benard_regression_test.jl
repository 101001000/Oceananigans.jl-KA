
#= none:1 =#
using Oceananigans.Grids: xnode, znode
#= none:2 =#
using Oceananigans.TimeSteppers: update_state!
#= none:3 =#
using Oceananigans.DistributedComputations: cpu_architecture, partition, reconstruct_global_grid
#= none:5 =#
function run_rayleigh_benard_regression_test(arch, grid_type)
    #= none:5 =#
    #= none:10 =#
    α = 2
    #= none:11 =#
    n = 1
    #= none:12 =#
    Ra = 1.0e6
    #= none:13 =#
    Nx = (Ny = (8n) * α)
    #= none:14 =#
    Lx = (Ly = 1.0α)
    #= none:15 =#
    Nz = 16n
    #= none:16 =#
    Lz = 1.0
    #= none:17 =#
    Pr = 0.7
    #= none:18 =#
    a = 0.1
    #= none:19 =#
    Δb = 1.0
    #= none:22 =#
    ν = sqrt((Δb * Pr * Lz ^ 3) / Ra)
    #= none:23 =#
    κ = ν / Pr
    #= none:29 =#
    if grid_type == :regular
        #= none:30 =#
        grid = RectilinearGrid(arch, size = (Nx, Ny, Nz), extent = (Lx, Ly, Lz), halo = (1, 1, 1))
    elseif #= none:31 =# grid_type == :vertically_unstretched
        #= none:32 =#
        zF = range(-Lz, 0, length = Nz + 1)
        #= none:33 =#
        grid = RectilinearGrid(arch, size = (Nx, Ny, Nz), x = (0, Lx), y = (0, Ly), z = zF, halo = (1, 1, 1))
    end
    #= none:37 =#
    c★(x, z) = begin
            #= none:37 =#
            exp(4z) * sin(((2π) / Lx) * x)
        end
    #= none:39 =#
    function Fc(i, j, k, grid, clock, model_fields)
        #= none:39 =#
        #= none:40 =#
        x = xnode(i, grid, Center())
        #= none:41 =#
        z = znode(k, grid, Center())
        #= none:42 =#
        return (1 / 10) * (c★(x, z) - model_fields.c[i, j, k])
    end
    #= none:45 =#
    cforcing = Forcing(Fc, discrete_form = true)
    #= none:47 =#
    bbcs = FieldBoundaryConditions(top = BoundaryCondition(Value(), 0.0), bottom = BoundaryCondition(Value(), Δb))
    #= none:50 =#
    model = NonhydrostaticModel(; grid, timestepper = :QuasiAdamsBashforth2, closure = ScalarDiffusivity(ν = ν, κ = κ), tracers = (:b, :c), buoyancy = Buoyancy(model = BuoyancyTracer()), boundary_conditions = (; b = bbcs), hydrostatic_pressure_anomaly = CenterField(grid), forcing = (; c = cforcing))
    #= none:60 =#
    Δt = (0.01 * min(model.grid.Δxᶜᵃᵃ, model.grid.Δyᵃᶜᵃ, Lz / Nz) ^ 2) / ν
    #= none:63 =#
    simulation = Simulation(model, Δt = Δt, stop_iteration = 0)
    #= none:66 =#
    ArrayType = typeof(model.velocities.u.data.parent)
    #= none:68 =#
    spinup_steps = 1000
    #= none:69 =#
    test_steps = 100
    #= none:71 =#
    prefix = "rayleigh_benard"
    #= none:73 =#
    checkpointer = Checkpointer(model, schedule = IterationInterval(test_steps), prefix = prefix, dir = joinpath(dirname(#= none:74 =# @__FILE__()), "data"))
    #= none:76 =#
    (u, v, w) = model.velocities
    #= none:77 =#
    (b, c) = model.tracers
    #= none:103 =#
    datadep_path = "regression_test_data/" * prefix * "_iteration$(spinup_steps).jld2"
    #= none:104 =#
    initial_filename = #= none:104 =# @datadep_str(datadep_path)
    #= none:106 =#
    (solution₀, Gⁿ₀, G⁻₀) = get_fields_from_checkpoint(initial_filename)
    #= none:108 =#
    cpu_arch = cpu_architecture(architecture(grid))
    #= none:110 =#
    u₀ = partition(ArrayType(solution₀.u[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(u))
    #= none:111 =#
    v₀ = partition(ArrayType(solution₀.v[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(v))
    #= none:112 =#
    w₀ = partition(ArrayType(solution₀.w[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(w))
    #= none:113 =#
    b₀ = partition(ArrayType(solution₀.b[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(b))
    #= none:114 =#
    c₀ = partition(ArrayType(solution₀.c[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(c))
    #= none:116 =#
    Gⁿu₀ = partition(ArrayType(Gⁿ₀.u[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(u))
    #= none:117 =#
    Gⁿv₀ = partition(ArrayType(Gⁿ₀.v[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(v))
    #= none:118 =#
    Gⁿw₀ = partition(ArrayType(Gⁿ₀.w[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(w))
    #= none:119 =#
    Gⁿb₀ = partition(ArrayType(Gⁿ₀.b[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(b))
    #= none:120 =#
    Gⁿc₀ = partition(ArrayType(Gⁿ₀.c[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(c))
    #= none:122 =#
    G⁻u₀ = partition(ArrayType(G⁻₀.u[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(u))
    #= none:123 =#
    G⁻v₀ = partition(ArrayType(G⁻₀.v[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(v))
    #= none:124 =#
    G⁻w₀ = partition(ArrayType(G⁻₀.w[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(w))
    #= none:125 =#
    G⁻b₀ = partition(ArrayType(G⁻₀.b[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(b))
    #= none:126 =#
    G⁻c₀ = partition(ArrayType(G⁻₀.c[2:end - 1, 2:end - 1, 2:end - 1]), cpu_arch, size(c))
    #= none:128 =#
    set!(model, u = u₀, v = v₀, w = w₀, b = b₀, c = c₀)
    #= none:130 =#
    set!(model.timestepper.Gⁿ.u, Gⁿu₀)
    #= none:131 =#
    set!(model.timestepper.Gⁿ.v, Gⁿv₀)
    #= none:132 =#
    set!(model.timestepper.Gⁿ.w, Gⁿw₀)
    #= none:133 =#
    set!(model.timestepper.Gⁿ.b, Gⁿb₀)
    #= none:134 =#
    set!(model.timestepper.Gⁿ.c, Gⁿc₀)
    #= none:136 =#
    set!(model.timestepper.G⁻.u, G⁻u₀)
    #= none:137 =#
    set!(model.timestepper.G⁻.v, G⁻v₀)
    #= none:138 =#
    set!(model.timestepper.G⁻.w, G⁻w₀)
    #= none:139 =#
    set!(model.timestepper.G⁻.b, G⁻b₀)
    #= none:140 =#
    set!(model.timestepper.G⁻.c, G⁻c₀)
    #= none:142 =#
    model.clock.iteration = spinup_steps
    #= none:143 =#
    model.clock.time = spinup_steps * Δt
    #= none:144 =#
    length(simulation.output_writers) > 0 && pop!(simulation.output_writers)
    #= none:147 =#
    update_state!(model)
    #= none:149 =#
    model.clock.last_Δt = Δt
    #= none:151 =#
    for n = 1:test_steps
        #= none:152 =#
        time_step!(model, Δt, euler = false)
        #= none:153 =#
    end
    #= none:155 =#
    datadep_path = "regression_test_data/" * prefix * "_iteration$(spinup_steps + test_steps).jld2"
    #= none:156 =#
    final_filename = #= none:156 =# @datadep_str(datadep_path)
    #= none:158 =#
    (solution₁, Gⁿ₁, G⁻₁) = get_fields_from_checkpoint(final_filename)
    #= none:160 =#
    test_fields = #= none:160 =# CUDA.@allowscalar((u = Array(interior(model.velocities.u)), v = Array(interior(model.velocities.v)), w = Array((interior(model.velocities.w))[:, :, 1:Nz]), b = Array(interior(model.tracers.b)), c = Array(interior(model.tracers.c))))
    #= none:166 =#
    global_grid = reconstruct_global_grid(model.grid)
    #= none:168 =#
    u₁ = interior(solution₁.u, global_grid)
    #= none:169 =#
    v₁ = interior(solution₁.v, global_grid)
    #= none:170 =#
    w₁ = interior(solution₁.w, global_grid)
    #= none:171 =#
    b₁ = interior(solution₁.b, global_grid)
    #= none:172 =#
    c₁ = interior(solution₁.c, global_grid)
    #= none:174 =#
    reference_fields = (u = partition(Array(u₁), cpu_arch, size(u)), v = partition(Array(v₁), cpu_arch, size(v)), w = partition(Array(w₁), cpu_arch, size(test_fields.w)), b = partition(Array(b₁), cpu_arch, size(b)), c = partition(Array(c₁), cpu_arch, size(c)))
    #= none:180 =#
    summarize_regression_test(test_fields, reference_fields)
    #= none:182 =#
    CUDA.allowscalar(true)
    #= none:183 =#
    #= none:183 =# @test all(test_fields.u .≈ reference_fields.u)
    #= none:184 =#
    #= none:184 =# @test all(test_fields.v .≈ reference_fields.v)
    #= none:185 =#
    #= none:185 =# @test all(test_fields.w .≈ reference_fields.w)
    #= none:186 =#
    #= none:186 =# @test all(test_fields.b .≈ reference_fields.b)
    #= none:187 =#
    #= none:187 =# @test all(test_fields.c .≈ reference_fields.c)
    #= none:188 =#
    CUDA.allowscalar(false)
    #= none:190 =#
    return nothing
end