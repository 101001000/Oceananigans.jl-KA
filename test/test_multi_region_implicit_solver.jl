
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
function geostrophic_adjustment_test(free_surface, grid; regions = 1)
    #= none:3 =#
    #= none:5 =#
    if architecture(grid) isa GPU
        #= none:6 =#
        devices = (0, 0)
    else
        #= none:8 =#
        devices = nothing
    end
    #= none:11 =#
    mrg = MultiRegionGrid(grid, partition = XPartition(regions), devices = devices)
    #= none:13 =#
    coriolis = FPlane(f = 0.0001)
    #= none:15 =#
    model = HydrostaticFreeSurfaceModel(grid = mrg, coriolis = coriolis, free_surface = free_surface)
    #= none:19 =#
    gaussian(x, L) = begin
            #= none:19 =#
            exp(-(x ^ 2) / (2 * L ^ 2))
        end
    #= none:21 =#
    U = 0.1
    #= none:22 =#
    L = grid.Lx / 40
    #= none:23 =#
    x₀ = grid.Lx / 4
    #= none:25 =#
    vᵍ(x, y, z) = begin
            #= none:25 =#
            ((-U * (x - x₀)) / L) * gaussian(x - x₀, L)
        end
    #= none:27 =#
    g = model.free_surface.gravitational_acceleration
    #= none:28 =#
    η = model.free_surface.η
    #= none:30 =#
    η₀ = (coriolis.f * U * L) / g
    #= none:32 =#
    ηᵍ(x) = begin
            #= none:32 =#
            η₀ * gaussian(x - x₀, L)
        end
    #= none:34 =#
    ηⁱ(x, y, z) = begin
            #= none:34 =#
            2 * ηᵍ(x)
        end
    #= none:36 =#
    set!(model, v = vᵍ)
    #= none:37 =#
    #= none:37 =# @apply_regionally set!(η, ηⁱ)
    #= none:39 =#
    gravity_wave_speed = sqrt(g * grid.Lz)
    #= none:40 =#
    Δt = (2 * model.grid.Δxᶜᵃᵃ) / gravity_wave_speed
    #= none:42 =#
    simulation = Simulation(model; Δt, stop_iteration = 10)
    #= none:43 =#
    run!(simulation)
    #= none:45 =#
    return η
end
#= none:48 =#
for arch = archs
    #= none:50 =#
    free_surface = ImplicitFreeSurface(solver_method = :HeptadiagonalIterativeSolver, maximum_iterations = 64 * 3)
    #= none:51 =#
    topology_types = ((Bounded, Periodic, Bounded), (Periodic, Periodic, Bounded))
    #= none:53 =#
    #= none:53 =# @testset "Testing multi region implicit free surface" begin
            #= none:54 =#
            for topology_type = topology_types
                #= none:55 =#
                grid = RectilinearGrid(arch, size = (64, 3, 1), x = (0, 100kilometers), y = (0, 100kilometers), z = (-400meters, 0), topology = topology_type)
                #= none:60 =#
                ηs = geostrophic_adjustment_test(free_surface, grid)
                #= none:61 =#
                ηs = Array(interior(ηs))
                #= none:63 =#
                for regions = [2, 4]
                    #= none:64 =#
                    #= none:64 =# @info "  Testing $(regions) partitions on $(topology_type) on the $(arch)"
                    #= none:65 =#
                    η = geostrophic_adjustment_test(free_surface, grid, regions = regions)
                    #= none:66 =#
                    η = Array(interior(reconstruct_global_field(η)))
                    #= none:68 =#
                    #= none:68 =# @test all(η .≈ ηs)
                    #= none:69 =#
                end
                #= none:70 =#
            end
        end
    #= none:72 =#
end