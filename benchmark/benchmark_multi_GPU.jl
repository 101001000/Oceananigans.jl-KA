
#= none:1 =#
using Oceananigans
#= none:2 =#
using Oceananigans.Grids
#= none:4 =#
using Oceananigans.Coriolis: HydrostaticSphericalCoriolis, VectorInvariantEnergyConserving, VectorInvariantEnstrophyConserving
#= none:9 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: HydrostaticFreeSurfaceModel, VectorInvariant, ExplicitFreeSurface
#= none:14 =#
using Oceananigans.Utils: prettytime, hours
#= none:16 =#
using Oceananigans.MultiRegion
#= none:17 =#
using Oceananigans.TurbulenceClosures: VerticallyImplicitTimeDiscretization
#= none:19 =#
using Statistics
#= none:20 =#
using JLD2
#= none:21 =#
using Printf
#= none:22 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:24 =#
const U = 0.1
#= none:25 =#
const Nx = 128
#= none:26 =#
const Ny = 128
#= none:27 =#
const Nz = 1
#= none:28 =#
const mult1 = 1
#= none:29 =#
const mult2 = 1
#= none:32 =#
solid_body_rotation(φ) = begin
        #= none:32 =#
        U * cosd(φ)
    end
#= none:33 =#
solid_body_geostrophic_height(φ, R, Ω, g) = begin
        #= none:33 =#
        ((R * Ω * U + U ^ 2 / 2) * sind(φ) ^ 2) / g
    end
#= none:38 =#
function run_solid_body_rotation(; architecture = CPU(), Nx = 90, Ny = 30, dev = nothing, coriolis_scheme = VectorInvariantEnstrophyConserving())
    #= none:38 =#
    #= none:45 =#
    grid = LatitudeLongitudeGrid(architecture, size = (Nx, Ny, Nz), radius = 1, halo = (3, 3, 3), latitude = (-80, 80), longitude = (-180, 180), z = (-1, 0))
    #= none:52 =#
    if dev isa Nothing
        #= none:53 =#
        mrg = grid
    else
        #= none:55 =#
        mrg = MultiRegionGrid(grid, partition = XPartition(length(dev)), devices = dev)
    end
    #= none:58 =#
    #= none:58 =# @show mrg
    #= none:60 =#
    free_surface = ExplicitFreeSurface(gravitational_acceleration = 1)
    #= none:62 =#
    coriolis = HydrostaticSphericalCoriolis(rotation_rate = 1, scheme = coriolis_scheme)
    #= none:65 =#
    closure = (HorizontalScalarDiffusivity(ν = 1, κ = 1), VerticalScalarDiffusivity(VerticallyImplicitTimeDiscretization(), κ = 1, ν = 1))
    #= none:67 =#
    model = HydrostaticFreeSurfaceModel(grid = mrg, momentum_advection = VectorInvariant(), free_surface = free_surface, coriolis = coriolis, tracers = (:T, :b), tracer_advection = WENO(), buoyancy = BuoyancyTracer(), closure = closure)
    #= none:76 =#
    g = model.free_surface.gravitational_acceleration
    #= none:77 =#
    R = grid.radius
    #= none:78 =#
    Ω = model.coriolis.rotation_rate
    #= none:80 =#
    uᵢ(λ, φ, z) = begin
            #= none:80 =#
            solid_body_rotation(φ)
        end
    #= none:81 =#
    ηᵢ(λ, φ) = begin
            #= none:81 =#
            solid_body_geostrophic_height(φ, R, Ω, g)
        end
    #= none:84 =#
    Gaussian(λ, φ, L) = begin
            #= none:84 =#
            exp(-((λ ^ 2 + φ ^ 2)) / (2 * L ^ 2))
        end
    #= none:87 =#
    L = 10
    #= none:88 =#
    φ₀ = 5
    #= none:90 =#
    cᵢ(λ, φ, z) = begin
            #= none:90 =#
            Gaussian(λ, φ - φ₀, L)
        end
    #= none:92 =#
    set!(model, u = uᵢ, η = ηᵢ)
    #= none:94 =#
    gravity_wave_speed = sqrt(g * grid.Lz)
    #= none:97 =#
    wave_propagation_time_scale = min(grid.radius * cosd(maximum(abs, grid.φᵃᶜᵃ)) * deg2rad(grid.Δλᶜᵃᵃ), grid.radius * deg2rad(grid.Δφᵃᶜᵃ)) / gravity_wave_speed
    #= none:100 =#
    Δt = 0.1wave_propagation_time_scale
    #= none:102 =#
    simulation = Simulation(model, Δt = Δt, stop_iteration = 500)
    #= none:106 =#
    progress(sim) = begin
            #= none:106 =#
            #= none:106 =# @info #= none:106 =# @sprintf("Iter: %d, time: %.1f, Δt: %.3f", sim.model.clock.iteration, sim.model.clock.time, sim.Δt)
        end
    #= none:110 =#
    simulation.callbacks[:progress] = Callback(progress, IterationInterval(500))
    #= none:112 =#
    run!(simulation)
    #= none:114 =#
    #= none:114 =# @show simulation.run_wall_time
    #= none:115 =#
    return simulation
end
#= none:118 =#
simulation_serial = run_solid_body_rotation(Nx = Nx, Ny = Ny, architecture = GPU())
#= none:119 =#
simulation_paral1 = run_solid_body_rotation(Nx = mult1 * Nx, Ny = Ny, dev = (0, 1), architecture = GPU())
#= none:120 =#
simulation_paral2 = run_solid_body_rotation(Nx = mult2 * Nx, Ny = Ny, dev = (0, 1, 2), architecture = GPU())
#= none:122 =#
using BenchmarkTools
#= none:124 =#
nothing
#= none:127 =#
time_step!(simulation_serial.model, 1)
#= none:128 =#
trial_serial = #= none:128 =# @benchmark(begin
            #= none:1 =#
            time_step!(simulation_serial.model, 1)
            #= none:1 =#
            KernelAbstractions.synchronize(KAUtils.get_backend())
        end, samples = 10)
#= none:132 =#
time_step!(simulation_paral1.model, 1)
#= none:133 =#
trial_paral1 = #= none:133 =# @benchmark(begin
            #= none:1 =#
            time_step!(simulation_paral1.model, 1)
            #= none:1 =#
            KernelAbstractions.synchronize(KAUtils.get_backend())
        end, samples = 10)
#= none:137 =#
time_step!(simulation_paral2.model, 1)
#= none:138 =#
trial_paral2 = #= none:138 =# @benchmark(begin
            #= none:1 =#
            time_step!(simulation_paral2.model, 1)
            #= none:1 =#
            KernelAbstractions.synchronize(KAUtils.get_backend())
        end, samples = 10)