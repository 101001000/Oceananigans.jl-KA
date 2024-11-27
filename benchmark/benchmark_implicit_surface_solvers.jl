
#= none:1 =#
using Oceananigans
#= none:2 =#
using Oceananigans.Units
#= none:3 =#
using Oceananigans.Advection: VelocityStencil
#= none:4 =#
using Oceananigans.Coriolis: HydrostaticSphericalCoriolis, R_Earth
#= none:5 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid, GridFittedBottom
#= none:6 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: FFTImplicitFreeSurfaceSolver
#= none:8 =#
using Printf
#= none:9 =#
using TimerOutputs
#= none:11 =#
"Benchmarks the bumpy baroclinic adjustment problem with various implicit free-surface solvers.\n"
#= none:15 =#
const to = TimerOutput()
#= none:18 =#
using_rectilinear_grid = true
#= none:20 =#
arch = CPU()
#= none:22 =#
for N = 10:10:250
    #= none:23 =#
    #= none:23 =# @info "N=$(N)"
    #= none:24 =#
    println("")
    #= none:26 =#
    if using_rectilinear_grid == true
        #= none:27 =#
        underlying_grid = RectilinearGrid(arch, topology = (Periodic, Bounded, Bounded), size = (N, N, 24), x = (-500kilometers, 500kilometers), y = (-500kilometers, 500kilometers), z = (-1kilometers, 0), halo = (4, 4, 4))
        #= none:35 =#
        Lz_u = underlying_grid.Lz
        #= none:36 =#
        width = 50kilometers
        #= none:37 =#
        bump(x, y) = begin
                #= none:37 =#
                -Lz_u * (1 - 2 * exp(-((x ^ 2 + y ^ 2)) / (2 * width ^ 2)))
            end
    else
        #= none:39 =#
        underlying_grid = LatitudeLongitudeGrid(arch, topology = (Periodic, Bounded, Bounded), size = (N, N, 24), longitude = (-10, 10), latitude = (-55, -35), z = (-1kilometers, 0), halo = (5, 5, 5))
        #= none:47 =#
        Lz_u = underlying_grid.Lz
        #= none:48 =#
        width = 0.5
        #= none:49 =#
        bump(λ, φ) = begin
                #= none:49 =#
                -Lz_u * (1 - 2 * exp(-((λ ^ 2 + φ ^ 2)) / (2 * width ^ 2)))
            end
    end
    #= none:52 =#
    grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bump))
    #= none:55 =#
    (Δx, Δz) = (grid.Lx / grid.Nx, grid.Lz / grid.Nz)
    #= none:56 =#
    𝒜 = Δz / Δx
    #= none:58 =#
    κh = 0.1
    #= none:59 =#
    νh = 0.1
    #= none:60 =#
    κz = 𝒜 * κh
    #= none:61 =#
    νz = 𝒜 * νh
    #= none:63 =#
    horizontal_closure = HorizontalScalarDiffusivity(ν = νh, κ = κh)
    #= none:65 =#
    diffusive_closure = VerticalScalarDiffusivity(VerticallyImplicitTimeDiscretization(); ν = νz, κ = κz)
    #= none:68 =#
    implicit_free_surface_solvers = (:FastFourierTransform, :PreconditionedConjugateGradient, :HeptadiagonalIterativeSolver, :HeptadiagonalIterativeSolver_withMGpreconditioner, :PreconditionedConjugateGradient_withFFTpreconditioner)
    #= none:75 =#
    if using_rectilinear_grid == true
        #= none:76 =#
        coriolis = BetaPlane(latitude = -45)
        #= none:77 =#
        momentum_advection = WENO()
        #= none:78 =#
        tracer_advection = WENO()
    else
        #= none:80 =#
        coriolis = HydrostaticSphericalCoriolis()
        #= none:81 =#
        momentum_advection = WENO(vector_invariant = VelocityStencil())
        #= none:82 =#
        tracer_advection = WENO(vector_invariant = VelocityStencil())
    end
    #= none:85 =#
    for implicit_free_surface_solver = implicit_free_surface_solvers
        #= none:87 =#
        if implicit_free_surface_solver == :PreconditionedConjugateGradient_withFFTpreconditioner
            #= none:88 =#
            fft_preconditioner = FFTImplicitFreeSurfaceSolver(grid)
            #= none:89 =#
            free_surface = ImplicitFreeSurface(solver_method = :PreconditionedConjugateGradient, preconditioner = fft_preconditioner, reltol = sqrt(eps(eltype(grid))), abstol = 0)
        elseif #= none:90 =# implicit_free_surface_solver == :HeptadiagonalIterativeSolver
            #= none:91 =#
            free_surface = ImplicitFreeSurface(solver_method = implicit_free_surface_solver, tolerance = sqrt(eps(eltype(grid))))
        else
            #= none:93 =#
            free_surface = ImplicitFreeSurface(solver_method = implicit_free_surface_solver, reltol = sqrt(eps(eltype(grid))), abstol = 0)
        end
        #= none:96 =#
        model = HydrostaticFreeSurfaceModel(; grid, free_surface, coriolis, buoyancy = BuoyancyTracer(), closure = (horizontal_closure,), tracers = :b, momentum_advection, tracer_advection)
        #= none:105 =#
        ramp(y, δy) = begin
                #= none:105 =#
                min(max(0, y / δy + 1 / 2), 1)
            end
        #= none:108 =#
        N² = 4.0e-6
        #= none:109 =#
        M² = 8.0e-8
        #= none:111 =#
        if using_rectilinear_grid
            #= none:112 =#
            δy = 50kilometers
        else
            #= none:114 =#
            δφ = 0.5
            #= none:115 =#
            δy = R_Earth * deg2rad(δφ)
        end
        #= none:118 =#
        δb = δy * M²
        #= none:119 =#
        ϵb = 0.01δb
        #= none:121 =#
        if using_rectilinear_grid
            #= none:122 =#
            bᵢ_rectilinear(x, y, z) = begin
                    #= none:122 =#
                    N² * z + δb * ramp(y, δy) + ϵb * randn()
                end
            #= none:123 =#
            set!(model, b = bᵢ_rectilinear)
        else
            #= none:125 =#
            bᵢ_latlon(λ, φ, z) = begin
                    #= none:125 =#
                    N² * z + δb * ramp(φ, δφ) + ϵb * randn()
                end
            #= none:126 =#
            set!(model, b = bᵢ_latlon)
        end
        #= none:129 =#
        Δt = 10minutes
        #= none:130 =#
        simulation = Simulation(model; Δt, stop_time = 200days)
        #= none:151 =#
        simulation.stop_iteration = 200
        #= none:153 =#
        run!(simulation)
        #= none:155 =#
        simulation.stop_iteration = 1200
        #= none:157 =#
        string(nameof(typeof(grid)))
        #= none:158 =#
        #= none:158 =# @info "Benchmark with $(implicit_free_surface_solver) free surface implicit solver on $(nameof(typeof(underlying_grid))):"
        #= none:159 =#
        #= none:159 =# @timeit to "$(implicit_free_surface_solver) and N=$(N)" run!(simulation)
        #= none:160 =#
    end
    #= none:161 =#
    show(to)
    #= none:162 =#
end