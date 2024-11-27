
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid, GridFittedBoundary, GridFittedBottom
#= none:4 =#
using Oceananigans.TurbulenceClosures
#= none:6 =#
#= none:6 =# @inline surface_wind_stress(λ, φ, t, p) = begin
            #= none:6 =#
            p.τ₀ * cos(((2π) * (φ - p.φ₀)) / p.Lφ)
        end
#= none:7 =#
#= none:7 =# @inline u_bottom_drag(i, j, grid, clock, fields, μ) = begin
            #= none:7 =#
            #= none:7 =# @inbounds -μ * fields.u[i, j, 1]
        end
#= none:8 =#
#= none:8 =# @inline v_bottom_drag(i, j, grid, clock, fields, μ) = begin
            #= none:8 =#
            #= none:8 =# @inbounds -μ * fields.v[i, j, 1]
        end
#= none:10 =#
#= none:10 =# @testset "Immersed boundaries with hydrostatic free surface models" begin
        #= none:11 =#
        #= none:11 =# @info "Testing immersed boundaries with hydrostatic free surface models..."
        #= none:13 =#
        for arch = archs
            #= none:15 =#
            arch_str = string(typeof(arch))
            #= none:17 =#
            #= none:17 =# @testset "GridFittedBoundary [$(arch_str)]" begin
                    #= none:18 =#
                    #= none:18 =# @info "Testing GridFittedBoundary with HydrostaticFreeSurfaceModel [$(arch_str)]..."
                    #= none:20 =#
                    underlying_grid = RectilinearGrid(arch, size = (8, 8, 8), x = (-5, 5), y = (-5, 5), z = (0, 2))
                    #= none:22 =#
                    bump(x, y, z) = begin
                            #= none:22 =#
                            z < exp(-(x ^ 2) - y ^ 2)
                        end
                    #= none:23 =#
                    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBoundary(bump))
                    #= none:25 =#
                    for closure = (ScalarDiffusivity(ν = 1, κ = 0.5), ScalarDiffusivity(VerticallyImplicitTimeDiscretization(), ν = 1, κ = 0.5))
                        #= none:28 =#
                        model = HydrostaticFreeSurfaceModel(; grid, tracers = :b, buoyancy = BuoyancyTracer(), closure = closure)
                        #= none:33 =#
                        u = model.velocities.u
                        #= none:34 =#
                        b = model.tracers.b
                        #= none:37 =#
                        set!(model, u = 1, b = ((x, y, z)->begin
                                        #= none:37 =#
                                        4z
                                    end))
                        #= none:40 =#
                        #= none:40 =# @test b[4, 4, 2] == 0
                        #= none:41 =#
                        #= none:41 =# @test u[4, 4, 2] == 0
                        #= none:43 =#
                        simulation = Simulation(model, Δt = 0.001, stop_iteration = 2)
                        #= none:45 =#
                        run!(simulation)
                        #= none:48 =#
                        #= none:48 =# @test b[4, 4, 2] == 0
                        #= none:49 =#
                        #= none:49 =# @test u[4, 4, 2] == 0
                        #= none:50 =#
                    end
                end
            #= none:53 =#
            #= none:53 =# @testset "Surface boundary conditions with immersed boundaries [$(arch_str)]" begin
                    #= none:54 =#
                    #= none:54 =# @info "  Testing surface boundary conditions with ImmersedBoundaries in HydrostaticFreeSurfaceModel [$(arch_str)]..."
                    #= none:56 =#
                    Nx = 60
                    #= none:57 =#
                    Ny = 60
                    #= none:60 =#
                    underlying_grid = LatitudeLongitudeGrid(arch, size = (Nx, Ny, 2), longitude = (-30, 30), latitude = (15, 75), z = (-4000, 0))
                    #= none:66 =#
                    bathymetry = zeros(Nx, Ny) .- 4000
                    #= none:67 =#
                    view(bathymetry, 31:34, 43:47) .= 0
                    #= none:68 =#
                    bathymetry = on_architecture(arch, bathymetry)
                    #= none:70 =#
                    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bathymetry))
                    #= none:72 =#
                    free_surface = ImplicitFreeSurface(gravitational_acceleration = 0.1)
                    #= none:73 =#
                    coriolis = HydrostaticSphericalCoriolis(scheme = EnstrophyConserving())
                    #= none:75 =#
                    surface_wind_stress_parameters = (τ₀ = 0.0001, Lφ = grid.Ly, φ₀ = 15)
                    #= none:79 =#
                    surface_wind_stress_bc = FluxBoundaryCondition(surface_wind_stress, parameters = surface_wind_stress_parameters)
                    #= none:82 =#
                    μ = 1 / (60days)
                    #= none:84 =#
                    u_bottom_drag_bc = FluxBoundaryCondition(u_bottom_drag, discrete_form = true, parameters = μ)
                    #= none:88 =#
                    v_bottom_drag_bc = FluxBoundaryCondition(v_bottom_drag, discrete_form = true, parameters = μ)
                    #= none:92 =#
                    u_bcs = FieldBoundaryConditions(top = surface_wind_stress_bc, bottom = u_bottom_drag_bc)
                    #= none:93 =#
                    v_bcs = FieldBoundaryConditions(bottom = v_bottom_drag_bc)
                    #= none:95 =#
                    νh₀ = 5000.0 * (60 / grid.Nx) ^ 2
                    #= none:96 =#
                    constant_horizontal_diffusivity = HorizontalScalarDiffusivity(ν = νh₀)
                    #= none:98 =#
                    model = HydrostaticFreeSurfaceModel(; grid, momentum_advection = VectorInvariant(), free_surface = free_surface, coriolis = coriolis, boundary_conditions = (u = u_bcs, v = v_bcs), closure = constant_horizontal_diffusivity, tracers = nothing, buoyancy = nothing)
                    #= none:107 =#
                    simulation = Simulation(model, Δt = 3600, stop_iteration = 1)
                    #= none:109 =#
                    run!(simulation)
                    #= none:112 =#
                    #= none:112 =# @test true
                end
            #= none:115 =#
            #= none:115 =# @testset "Correct vertically-integrated lateral face areas with immersed boundaries [$(arch_str)]" begin
                    #= none:116 =#
                    #= none:116 =# @info "  Testing correct vertically-integrated lateral face areas with immersed boundaries [$(arch_str)]..."
                    #= none:118 =#
                    Nx = 5
                    #= none:119 =#
                    Ny = 5
                    #= none:121 =#
                    underlying_grid = RectilinearGrid(arch, size = (Nx, Ny, 3), extent = (Nx, Ny, 3), topology = (Periodic, Periodic, Bounded))
                    #= none:126 =#
                    bathymetry = [-3.0 for j = 1:Ny, i = 1:Nx]
                    #= none:127 =#
                    bathymetry[2:Nx - 1, 2:Ny - 1] .= [-2 for j = 2:Ny - 1, i = 2:Nx - 1]
                    #= none:128 =#
                    bathymetry[3:Nx - 2, 3:Ny - 2] .= [-1 for j = 3:Ny - 2, i = 3:Nx - 2]
                    #= none:129 =#
                    bathymetry = on_architecture(arch, bathymetry)
                    #= none:131 =#
                    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bathymetry))
                    #= none:133 =#
                    model = HydrostaticFreeSurfaceModel(; grid, free_surface = ImplicitFreeSurface(solver_method = :PreconditionedConjugateGradient), buoyancy = nothing, tracers = nothing, closure = nothing)
                    #= none:139 =#
                    x_ref = ([3.0 3.0 3.0 3.0 3.0; 3.0 2.0 2.0 2.0 2.0; 3.0 2.0 1.0 1.0 2.0; 3.0 2.0 2.0 2.0 2.0; 3.0 3.0 3.0 3.0 3.0])'
                    #= none:145 =#
                    y_ref = ([3.0 3.0 3.0 3.0 3.0; 3.0 2.0 2.0 2.0 3.0; 3.0 2.0 1.0 2.0 3.0; 3.0 2.0 1.0 2.0 3.0; 3.0 2.0 2.0 2.0 3.0])'
                    #= none:151 =#
                    fs = model.free_surface
                    #= none:152 =#
                    vertically_integrated_lateral_areas = fs.implicit_step_solver.vertically_integrated_lateral_areas
                    #= none:154 =#
                    ∫Axᶠᶜᶜ = vertically_integrated_lateral_areas.xᶠᶜᶜ
                    #= none:155 =#
                    ∫Ayᶜᶠᶜ = vertically_integrated_lateral_areas.yᶜᶠᶜ
                    #= none:157 =#
                    ∫Axᶠᶜᶜ = Array(interior(∫Axᶠᶜᶜ))
                    #= none:158 =#
                    ∫Ayᶜᶠᶜ = Array(interior(∫Ayᶜᶠᶜ))
                    #= none:160 =#
                    Ax_ok = ∫Axᶠᶜᶜ[:, :, 1] ≈ x_ref
                    #= none:161 =#
                    Ay_ok = ∫Ayᶜᶠᶜ[:, :, 1] ≈ y_ref
                    #= none:163 =#
                    #= none:163 =# @test Ax_ok & Ay_ok
                end
            #= none:165 =#
        end
    end