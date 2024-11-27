
#= none:1 =#
using Oceananigans.DistributedComputations: cpu_architecture, partition
#= none:3 =#
function run_thermal_bubble_regression_test(arch, grid_type)
    #= none:3 =#
    #= none:4 =#
    (Nx, Ny, Nz) = (16, 16, 16)
    #= none:5 =#
    (Lx, Ly, Lz) = (100, 100, 100)
    #= none:6 =#
    Δt = 6
    #= none:8 =#
    if grid_type == :regular
        #= none:9 =#
        grid = RectilinearGrid(arch, size = (Nx, Ny, Nz), extent = (Lx, Ly, Lz), halo = (1, 1, 1))
    elseif #= none:10 =# grid_type == :vertically_unstretched
        #= none:11 =#
        zF = range(-Lz, 0, length = Nz + 1)
        #= none:12 =#
        grid = RectilinearGrid(arch, size = (Nx, Ny, Nz), x = (0, Lx), y = (0, Ly), z = zF, halo = (1, 1, 1))
    end
    #= none:15 =#
    closure = ScalarDiffusivity(ν = 0.04, κ = 0.04)
    #= none:17 =#
    model = NonhydrostaticModel(; grid, closure, timestepper = :QuasiAdamsBashforth2, coriolis = FPlane(f = 0.0001), buoyancy = SeawaterBuoyancy(), hydrostatic_pressure_anomaly = CenterField(grid), tracers = (:T, :S))
    #= none:24 =#
    simulation = Simulation(model, Δt = 6, stop_iteration = 10)
    #= none:26 =#
    model.tracers.T.data.parent .= 9.85
    #= none:27 =#
    model.tracers.S.data.parent .= 35.0
    #= none:31 =#
    (i1, i2) = (round(Int, Nx / 4), round(Int, (3Nx) / 4))
    #= none:32 =#
    (j1, j2) = (round(Int, Ny / 4), round(Int, (3Ny) / 4))
    #= none:33 =#
    (k1, k2) = (round(Int, Nz / 4), round(Int, (3Nz) / 4))
    #= none:34 =#
    view(model.tracers.T, i1:i2, j1:j2, k1:k2) .+= 0.01
    #= none:36 =#
    datadep_path = "regression_test_data/thermal_bubble_regression.nc"
    #= none:37 =#
    regression_data_filepath = #= none:37 =# @datadep_str(datadep_path)
    #= none:60 =#
    run!(simulation)
    #= none:62 =#
    ds = Dataset(regression_data_filepath, "r")
    #= none:64 =#
    test_fields = (u = zeros(size(model.velocities.u)), v = zeros(size(model.velocities.v)), w = zeros(size(model.velocities.w)), T = zeros(size(model.tracers.T)), S = zeros(size(model.tracers.S)))
    #= none:70 =#
    copyto!(test_fields.u, interior(model.velocities.u))
    #= none:71 =#
    copyto!(test_fields.v, interior(model.velocities.v))
    #= none:72 =#
    copyto!(test_fields.w, interior(model.velocities.w))
    #= none:73 =#
    copyto!(test_fields.T, interior(model.tracers.T))
    #= none:74 =#
    copyto!(test_fields.S, interior(model.tracers.S))
    #= none:76 =#
    reference_fields = (u = (ds["u"])[:, :, :, end], v = (ds["v"])[:, :, :, end], w = (ds["w"])[:, :, :, end], T = (ds["T"])[:, :, :, end], S = (ds["S"])[:, :, :, end])
    #= none:82 =#
    cpu_arch = cpu_architecture(architecture(grid))
    #= none:84 =#
    reference_fields = (u = partition(reference_fields.u, cpu_arch, size(reference_fields.u)), v = partition(reference_fields.v, cpu_arch, size(reference_fields.v)), w = partition(reference_fields.w, cpu_arch, size(reference_fields.w)), T = partition(reference_fields.T, cpu_arch, size(reference_fields.T)), S = partition(reference_fields.S, cpu_arch, size(reference_fields.S)))
    #= none:90 =#
    summarize_regression_test(test_fields, reference_fields)
    #= none:92 =#
    #= none:92 =# @test all(test_fields.u .≈ reference_fields.u)
    #= none:93 =#
    #= none:93 =# @test all(test_fields.v .≈ reference_fields.v)
    #= none:94 =#
    #= none:94 =# @test all(test_fields.w .≈ reference_fields.w)
    #= none:95 =#
    #= none:95 =# @test all(test_fields.T .≈ reference_fields.T)
    #= none:96 =#
    #= none:96 =# @test all(test_fields.S .≈ reference_fields.S)
    #= none:98 =#
    return nothing
end