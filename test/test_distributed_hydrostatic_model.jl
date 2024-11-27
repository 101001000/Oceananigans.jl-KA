
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using MPI
#= none:24 =#
MPI.Initialized() || MPI.Init()
#= none:28 =#
using Oceananigans.Operators: hack_cosd
#= none:29 =#
using Oceananigans.DistributedComputations: partition, all_reduce, cpu_architecture, reconstruct_global_grid
#= none:31 =#
function Δ_min(grid)
    #= none:31 =#
    #= none:32 =#
    Δx_min = minimum_xspacing(grid, Center(), Center(), Center())
    #= none:33 =#
    Δy_min = minimum_yspacing(grid, Center(), Center(), Center())
    #= none:34 =#
    return min(Δx_min, Δy_min)
end
#= none:37 =#
#= none:37 =# @inline Gaussian(x, y, L) = begin
            #= none:37 =#
            exp(-((x ^ 2 + y ^ 2)) / L ^ 2)
        end
#= none:39 =#
function solid_body_rotation_test(grid)
    #= none:39 =#
    #= none:41 =#
    free_surface = SplitExplicitFreeSurface(grid; substeps = 5, gravitational_acceleration = 1)
    #= none:42 =#
    coriolis = HydrostaticSphericalCoriolis(rotation_rate = 1)
    #= none:44 =#
    model = HydrostaticFreeSurfaceModel(; grid, momentum_advection = VectorInvariant(), free_surface = free_surface, coriolis = coriolis, tracers = :c, tracer_advection = WENO(), buoyancy = nothing, closure = nothing)
    #= none:53 =#
    g = model.free_surface.gravitational_acceleration
    #= none:54 =#
    R = grid.radius
    #= none:55 =#
    Ω = model.coriolis.rotation_rate
    #= none:57 =#
    uᵢ(λ, φ, z) = begin
            #= none:57 =#
            0.1 * cosd(φ) * sind(λ)
        end
    #= none:58 =#
    ηᵢ(λ, φ, z) = begin
            #= none:58 =#
            (((R * Ω * 0.1 + 0.1 ^ 2 / 2) * sind(φ) ^ 2) / g) * sind(λ)
        end
    #= none:62 =#
    cᵢ(λ, φ, z) = begin
            #= none:62 =#
            max(Gaussian(λ, φ - 5, 10), 0.1)
        end
    #= none:63 =#
    vᵢ(λ, φ, z) = begin
            #= none:63 =#
            0.1
        end
    #= none:65 =#
    set!(model, u = uᵢ, η = ηᵢ, c = cᵢ)
    #= none:67 =#
    #= none:67 =# @show Δt_local = (0.1 * Δ_min(grid)) / sqrt(g * grid.Lz)
    #= none:68 =#
    #= none:68 =# @show Δt = all_reduce(min, Δt_local, architecture(grid))
    #= none:70 =#
    simulation = Simulation(model; Δt, stop_iteration = 10)
    #= none:71 =#
    run!(simulation)
    #= none:73 =#
    return merge(model.velocities, model.tracers, (; η = model.free_surface.η))
end
#= none:76 =#
Nx = 32
#= none:77 =#
Ny = 32
#= none:79 =#
for arch = archs
    #= none:80 =#
    #= none:80 =# @testset "Testing distributed solid body rotation" begin
            #= none:81 =#
            underlying_grid = LatitudeLongitudeGrid(arch, size = (Nx, Ny, 1), halo = (4, 4, 4), latitude = (-80, 80), longitude = (-160, 160), z = (-1, 0), radius = 1, topology = (Bounded, Bounded, Bounded))
            #= none:89 =#
            bottom(λ, φ) = begin
                    #= none:89 =#
                    if -30 < λ < 30 && -40 < φ < 20
                        0
                    else
                        -1
                    end
                end
            #= none:91 =#
            immersed_grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bottom))
            #= none:92 =#
            immersed_active_grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bottom); active_cells_map = true)
            #= none:94 =#
            global_underlying_grid = reconstruct_global_grid(underlying_grid)
            #= none:95 =#
            global_immersed_grid = ImmersedBoundaryGrid(global_underlying_grid, GridFittedBottom(bottom))
            #= none:97 =#
            for (grid, global_grid) = zip((underlying_grid, immersed_grid, immersed_active_grid), (global_underlying_grid, global_immersed_grid, global_immersed_grid))
                #= none:100 =#
                (us, vs, ws, cs, ηs) = solid_body_rotation_test(global_grid)
                #= none:102 =#
                us = interior(on_architecture(CPU(), us))
                #= none:103 =#
                vs = interior(on_architecture(CPU(), vs))
                #= none:104 =#
                ws = interior(on_architecture(CPU(), ws))
                #= none:105 =#
                cs = interior(on_architecture(CPU(), cs))
                #= none:106 =#
                ηs = interior(on_architecture(CPU(), ηs))
                #= none:108 =#
                #= none:108 =# @info "  Testing distributed solid body rotation with architecture $(arch) on $((typeof(grid)).name.wrapper)"
                #= none:109 =#
                (u, v, w, c, η) = solid_body_rotation_test(grid)
                #= none:111 =#
                cpu_arch = cpu_architecture(arch)
                #= none:113 =#
                u = interior(on_architecture(cpu_arch, u))
                #= none:114 =#
                v = interior(on_architecture(cpu_arch, v))
                #= none:115 =#
                w = interior(on_architecture(cpu_arch, w))
                #= none:116 =#
                c = interior(on_architecture(cpu_arch, c))
                #= none:117 =#
                η = interior(on_architecture(cpu_arch, η))
                #= none:119 =#
                us = partition(us, cpu_arch, size(u))
                #= none:120 =#
                vs = partition(vs, cpu_arch, size(v))
                #= none:121 =#
                ws = partition(ws, cpu_arch, size(w))
                #= none:122 =#
                cs = partition(cs, cpu_arch, size(c))
                #= none:123 =#
                ηs = partition(ηs, cpu_arch, size(η))
                #= none:125 =#
                atol = eps(eltype(grid))
                #= none:126 =#
                rtol = sqrt(eps(eltype(grid)))
                #= none:128 =#
                #= none:128 =# @test all(isapprox(u, us; atol, rtol))
                #= none:129 =#
                #= none:129 =# @test all(isapprox(v, vs; atol, rtol))
                #= none:130 =#
                #= none:130 =# @test all(isapprox(w, ws; atol, rtol))
                #= none:131 =#
                #= none:131 =# @test all(isapprox(c, cs; atol, rtol))
                #= none:132 =#
                #= none:132 =# @test all(isapprox(η, ηs; atol, rtol))
                #= none:133 =#
            end
        end
    #= none:135 =#
end