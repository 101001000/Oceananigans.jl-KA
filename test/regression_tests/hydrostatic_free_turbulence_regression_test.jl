
#= none:1 =#
using Oceananigans.Fields: FunctionField
#= none:2 =#
using Oceananigans.Grids: architecture
#= none:3 =#
using Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:4 =#
using Oceananigans.Coriolis: EnergyConserving
#= none:5 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: HydrostaticFreeSurfaceModel, VectorInvariant
#= none:6 =#
using Oceananigans.TurbulenceClosures: HorizontalScalarDiffusivity
#= none:8 =#
using Oceananigans.DistributedComputations: Distributed, DistributedGrid, DistributedComputations, all_reduce
#= none:9 =#
using Oceananigans.DistributedComputations: reconstruct_global_topology, partition, cpu_architecture
#= none:11 =#
using JLD2
#= none:13 =#
ordered_indices(r, i) = begin
        #= none:13 =#
        if i == 1
            r
        else
            if i == 2
                (r[2], r[1], r[3])
            else
                (r[3], r[2], r[1])
            end
        end
    end
#= none:15 =#
global_topology(grid, i) = begin
        #= none:15 =#
        string(topology(grid, i))
    end
#= none:17 =#
function global_topology(grid::DistributedGrid, i)
    #= none:17 =#
    #= none:18 =#
    arch = architecture(grid)
    #= none:19 =#
    R = arch.ranks[i]
    #= none:20 =#
    r = ordered_indices(arch.local_index, i)
    #= none:21 =#
    T = reconstruct_global_topology(topology(grid, i), R, r..., arch.communicator)
    #= none:22 =#
    return string(T)
end
#= none:25 =#
function run_hydrostatic_free_turbulence_regression_test(grid, free_surface; regenerate_data = false)
    #= none:25 =#
    #= none:32 =#
    coriolis = HydrostaticSphericalCoriolis(scheme = EnergyConserving())
    #= none:34 =#
    model = HydrostaticFreeSurfaceModel(; grid, coriolis, momentum_advection = VectorInvariant(), free_surface = free_surface, closure = HorizontalScalarDiffusivity(ν = 100000.0, κ = 10000.0))
    #= none:46 =#
    step_function(x, d, c) = begin
            #= none:46 =#
            (1 / 2) * (1 + tanh((x - c) / d))
        end
    #= none:47 =#
    polar_mask(y) = begin
            #= none:47 =#
            step_function(y, -5, 40) * step_function(y, 5, -40)
        end
    #= none:48 =#
    shear_func(x, y, z, p) = begin
            #= none:48 =#
            p.U * (0.5 + z / p.Lz) * polar_mask(y)
        end
    #= none:50 =#
    set!(model, u = ((λ, φ, z)->begin
                    #= none:50 =#
                    polar_mask(φ) * exp(-(φ ^ 2) / 200)
                end), v = ((λ, φ, z)->begin
                    #= none:51 =#
                    polar_mask(φ) * sind(2λ)
                end))
    #= none:53 =#
    (u, v, w) = model.velocities
    #= none:54 =#
    U = 0.1 * maximum(abs, u)
    #= none:55 =#
    U = all_reduce(max, U, architecture(grid))
    #= none:56 =#
    shear = FunctionField{Face, Center, Center}(shear_func, grid, parameters = (U = U, Lz = grid.Lz))
    #= none:57 =#
    u .= u + shear
    #= none:61 =#
    gravity = model.free_surface.gravitational_acceleration
    #= none:62 =#
    wave_speed = sqrt(gravity * grid.Lz)
    #= none:64 =#
    CUDA.allowscalar(true)
    #= none:65 =#
    minimum_Δx = grid.radius * cosd(maximum(abs, view(grid.φᵃᶜᵃ, 1:grid.Ny))) * deg2rad(minimum(grid.Δλᶜᵃᵃ))
    #= none:66 =#
    minimum_Δy = grid.radius * deg2rad(minimum(grid.Δφᵃᶜᵃ))
    #= none:67 =#
    CUDA.allowscalar(false)
    #= none:69 =#
    wave_time_scale = min(minimum_Δx, minimum_Δy) / wave_speed
    #= none:71 =#
    Δt = 0.2wave_time_scale
    #= none:72 =#
    Δt = all_reduce(min, Δt, architecture(grid))
    #= none:78 =#
    stop_iteration = 20
    #= none:80 =#
    simulation = Simulation(model, Δt = Δt, stop_iteration = stop_iteration)
    #= none:84 =#
    η = model.free_surface.η
    #= none:86 =#
    free_surface_str = string((typeof(model.free_surface)).name.wrapper)
    #= none:87 =#
    x_topology_str = global_topology(grid, 1)
    #= none:88 =#
    output_filename = "hydrostatic_free_turbulence_regression_$(x_topology_str)_$(free_surface_str).jld2"
    #= none:90 =#
    if regenerate_data && !(grid isa DistributedGrid)
        #= none:91 =#
        #= none:91 =# @warn "Generating new data for the Hydrostatic regression test."
        #= none:93 =#
        directory = joinpath(dirname(#= none:93 =# @__FILE__()), "data")
        #= none:94 =#
        outputs = (; u, v, w, η)
        #= none:95 =#
        simulation.output_writers[:fields] = JLD2OutputWriter(model, outputs, dir = directory, schedule = IterationInterval(stop_iteration), filename = output_filename, with_halos = true, overwrite_existing = true)
    end
    #= none:104 =#
    run!(simulation)
    #= none:107 =#
    test_fields = (u = Array(interior(u)), v = Array(interior(v)), w = Array(interior(w)), η = Array(interior(η)))
    #= none:114 =#
    if !regenerate_data
        #= none:115 =#
        datadep_path = "regression_test_data/" * output_filename
        #= none:116 =#
        regression_data_path = #= none:116 =# @datadep_str(datadep_path)
        #= none:117 =#
        file = jldopen(regression_data_path)
        #= none:119 =#
        cpu_arch = cpu_architecture(architecture(grid))
        #= none:122 =#
        H = 2
        #= none:123 =#
        truth_fields = (u = partition((file["timeseries/u/$(stop_iteration)"])[H + 1:end - H, H + 1:end - H, H + 1:end - H], cpu_arch, size(u)), v = partition((file["timeseries/v/$(stop_iteration)"])[H + 1:end - H, H + 1:end - H, H + 1:end - H], cpu_arch, size(v)), w = partition((file["timeseries/w/$(stop_iteration)"])[H + 1:end - H, H + 1:end - H, H + 1:end - H], cpu_arch, size(w)), η = partition((file["timeseries/η/$(stop_iteration)"])[H + 1:end - H, H + 1:end - H, :], cpu_arch, size(η)))
        #= none:130 =#
        close(file)
        #= none:132 =#
        summarize_regression_test(test_fields, truth_fields)
        #= none:134 =#
        test_fields_equality(cpu_arch, test_fields, truth_fields)
    end
    #= none:137 =#
    return nothing
end
#= none:140 =#
function test_fields_equality(arch, test_fields, truth_fields)
    #= none:140 =#
    #= none:141 =#
    #= none:141 =# @test all(test_fields.u .≈ truth_fields.u)
    #= none:142 =#
    #= none:142 =# @test all(test_fields.v .≈ truth_fields.v)
    #= none:143 =#
    #= none:143 =# @test all(test_fields.w .≈ truth_fields.w)
    #= none:144 =#
    #= none:144 =# @test all(test_fields.η .≈ truth_fields.η)
    #= none:146 =#
    return nothing
end