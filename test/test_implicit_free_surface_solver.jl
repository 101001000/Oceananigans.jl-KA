
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Statistics
#= none:4 =#
using Oceananigans.BuoyancyModels: g_Earth
#= none:5 =#
using Oceananigans.Operators
#= none:6 =#
using Oceananigans.Grids: inactive_cell
#= none:7 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: ImplicitFreeSurface, FFTImplicitFreeSurfaceSolver, PCGImplicitFreeSurfaceSolver, MatrixImplicitFreeSurfaceSolver, compute_vertically_integrated_lateral_areas!, implicit_free_surface_step!, implicit_free_surface_linear_operation!
#= none:16 =#
using Oceananigans.Grids: with_halo
#= none:18 =#
function set_simple_divergent_velocity!(model)
    #= none:18 =#
    #= none:20 =#
    grid = model.grid
    #= none:22 =#
    (u, v, w) = model.velocities
    #= none:23 =#
    η = model.free_surface.η
    #= none:25 =#
    u .= 0
    #= none:26 =#
    v .= 0
    #= none:27 =#
    η .= 0
    #= none:30 =#
    (i, j, k) = (Int(floor(grid.Nx / 2)) + 1, Int(floor(grid.Ny / 2)) + 1, grid.Nz)
    #= none:31 =#
    inactive_cell(i, j, k, grid) && error("The nudged cell at ($(i), $(j), $(k)) is inactive.")
    #= none:33 =#
    Δy = #= none:33 =# CUDA.@allowscalar(Δyᶜᶠᶜ(i, j, k, grid))
    #= none:34 =#
    Δz = #= none:34 =# CUDA.@allowscalar(Δzᶜᶠᶜ(i, j, k, grid))
    #= none:38 =#
    transport = 100000.0
    #= none:39 =#
    #= none:39 =# CUDA.@allowscalar u[i, j, k] = transport / (Δy * Δz)
    #= none:41 =#
    update_state!(model)
    #= none:43 =#
    return nothing
end
#= none:46 =#
function run_implicit_free_surface_solver_tests(arch, grid, free_surface)
    #= none:46 =#
    #= none:47 =#
    Δt = 900
    #= none:50 =#
    model = HydrostaticFreeSurfaceModel(; grid, momentum_advection = nothing, free_surface)
    #= none:54 =#
    set_simple_divergent_velocity!(model)
    #= none:55 =#
    implicit_free_surface_step!(model.free_surface, model, Δt, 1.5)
    #= none:57 =#
    acronym = if free_surface.solver_method == :HeptadiagonalIterativeSolver
            "Matrix"
        else
            "PCG"
        end
    #= none:59 =#
    η = model.free_surface.η
    #= none:60 =#
    #= none:60 =# @info "    " * acronym * " implicit free surface solver test, norm(η_" * lowercase(acronym) * "): $(norm(η)), maximum(abs, η_" * lowercase(acronym) * "): $(maximum(abs, η))"
    #= none:63 =#
    right_hand_side = model.free_surface.implicit_step_solver.right_hand_side
    #= none:64 =#
    if !(right_hand_side isa Field)
        #= none:65 =#
        rhs = Field{Center, Center, Nothing}(grid)
        #= none:66 =#
        set!(rhs, reshape(right_hand_side, model.free_surface.implicit_step_solver.matrix_iterative_solver.problem_size...))
        #= none:67 =#
        right_hand_side = rhs
    end
    #= none:71 =#
    g = g_Earth
    #= none:72 =#
    η = model.free_surface.η
    #= none:74 =#
    ∫ᶻ_Axᶠᶜᶜ = Field((Face, Center, Nothing), grid)
    #= none:75 =#
    ∫ᶻ_Ayᶜᶠᶜ = Field((Center, Face, Nothing), grid)
    #= none:77 =#
    vertically_integrated_lateral_areas = (xᶠᶜᶜ = ∫ᶻ_Axᶠᶜᶜ, yᶜᶠᶜ = ∫ᶻ_Ayᶜᶠᶜ)
    #= none:79 =#
    compute_vertically_integrated_lateral_areas!(vertically_integrated_lateral_areas)
    #= none:80 =#
    fill_halo_regions!(vertically_integrated_lateral_areas)
    #= none:82 =#
    left_hand_side = ZFaceField(grid, indices = (:, :, grid.Nz + 1))
    #= none:83 =#
    implicit_free_surface_linear_operation!(left_hand_side, η, ∫ᶻ_Axᶠᶜᶜ, ∫ᶻ_Ayᶜᶠᶜ, g, Δt)
    #= none:86 =#
    extrema_tolerance = 1.0e-9
    #= none:87 =#
    std_tolerance = 1.0e-9
    #= none:89 =#
    #= none:89 =# @show norm(left_hand_side)
    #= none:90 =#
    #= none:90 =# @show norm(right_hand_side)
    #= none:92 =#
    #= none:92 =# CUDA.@allowscalar begin
            #= none:93 =#
            #= none:93 =# @test maximum(abs, interior(left_hand_side) .- interior(right_hand_side)) < extrema_tolerance
            #= none:94 =#
            #= none:94 =# @test std(interior(left_hand_side) .- interior(right_hand_side)) < std_tolerance
        end
    #= none:97 =#
    return model.free_surface.implicit_step_solver
end
#= none:100 =#
#= none:100 =# @testset "Implicit free surface solver tests" begin
        #= none:101 =#
        for arch = archs
            #= none:102 =#
            A = typeof(arch)
            #= none:104 =#
            rectilinear_grid = RectilinearGrid(arch, size = (128, 2, 5), x = (-5000kilometers, 5000kilometers), y = (0, 100kilometers), z = (-500, 0), halo = (3, 2, 3), topology = (Bounded, Periodic, Bounded))
            #= none:111 =#
            Lz = rectilinear_grid.Lz
            #= none:112 =#
            width = rectilinear_grid.Lx / 20
            #= none:114 =#
            bump(x, y) = begin
                    #= none:114 =#
                    -Lz * (1 - 0.2 * exp(-(x ^ 2) / (2 * width ^ 2)))
                end
            #= none:116 =#
            underlying_grid = RectilinearGrid(arch, size = (128, 2, 5), x = (-5000kilometers, 5000kilometers), y = (0, 100kilometers), z = [-500, -300, -220, -170, -60, 0], halo = (3, 2, 3), topology = (Bounded, Periodic, Bounded))
            #= none:123 =#
            bumpy_vertically_stretched_rectilinear_grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(bump))
            #= none:125 =#
            lat_lon_grid = LatitudeLongitudeGrid(arch, size = (50, 50, 5), longitude = (-20, 30), latitude = (-10, 40), z = (-4000, 0))
            #= none:130 =#
            for grid = (rectilinear_grid, bumpy_vertically_stretched_rectilinear_grid, lat_lon_grid)
                #= none:131 =#
                G = string(nameof(typeof(grid)))
                #= none:133 =#
                #= none:133 =# @info "Testing PreconditionedConjugateGradient implicit free surface solver [$(A), $(G)]..."
                #= none:134 =#
                free_surface = ImplicitFreeSurface(solver_method = :PreconditionedConjugateGradient, abstol = 1.0e-15, reltol = 0)
                #= none:136 =#
                run_implicit_free_surface_solver_tests(arch, grid, free_surface)
                #= none:137 =#
            end
            #= none:139 =#
            #= none:139 =# @info "Testing implicit free surface solvers compared to FFT [$(A)]..."
            #= none:141 =#
            mat_free_surface = ImplicitFreeSurface(solver_method = :HeptadiagonalIterativeSolver, tolerance = 1.0e-15, maximum_iterations = 128 ^ 2)
            #= none:144 =#
            pcg_free_surface = ImplicitFreeSurface(solver_method = :PreconditionedConjugateGradient, abstol = 1.0e-15, reltol = 0, maxiter = 128 ^ 2)
            #= none:147 =#
            fft_free_surface = ImplicitFreeSurface(solver_method = :FastFourierTransform)
            #= none:149 =#
            mat_model = HydrostaticFreeSurfaceModel(grid = rectilinear_grid, momentum_advection = nothing, free_surface = mat_free_surface)
            #= none:153 =#
            pcg_model = HydrostaticFreeSurfaceModel(grid = rectilinear_grid, momentum_advection = nothing, free_surface = pcg_free_surface)
            #= none:157 =#
            fft_model = HydrostaticFreeSurfaceModel(grid = rectilinear_grid, momentum_advection = nothing, free_surface = fft_free_surface)
            #= none:161 =#
            #= none:161 =# @test fft_model.free_surface.implicit_step_solver isa FFTImplicitFreeSurfaceSolver
            #= none:162 =#
            #= none:162 =# @test pcg_model.free_surface.implicit_step_solver isa PCGImplicitFreeSurfaceSolver
            #= none:163 =#
            #= none:163 =# @test mat_model.free_surface.implicit_step_solver isa MatrixImplicitFreeSurfaceSolver
            #= none:165 =#
            Δt₁ = 900
            #= none:166 =#
            Δt₂ = 920.0
            #= none:168 =#
            for m = (mat_model, pcg_model, fft_model)
                #= none:169 =#
                set_simple_divergent_velocity!(m)
                #= none:170 =#
                implicit_free_surface_step!(m.free_surface, m, Δt₁, 1.5)
                #= none:171 =#
                implicit_free_surface_step!(m.free_surface, m, Δt₁, 1.5)
                #= none:172 =#
                implicit_free_surface_step!(m.free_surface, m, Δt₂, 1.5)
                #= none:173 =#
            end
            #= none:175 =#
            mat_η = mat_model.free_surface.η
            #= none:176 =#
            pcg_η = pcg_model.free_surface.η
            #= none:177 =#
            fft_η = fft_model.free_surface.η
            #= none:179 =#
            mat_η_cpu = Array(interior(mat_η))
            #= none:180 =#
            pcg_η_cpu = Array(interior(pcg_η))
            #= none:181 =#
            fft_η_cpu = Array(interior(fft_η))
            #= none:183 =#
            Δη_mat = mat_η_cpu .- fft_η_cpu
            #= none:184 =#
            Δη_pcg = pcg_η_cpu .- fft_η_cpu
            #= none:186 =#
            #= none:186 =# @info "FFT/PCG/MAT implicit free surface solver comparison:"
            #= none:187 =#
            #= none:187 =# @info "    maximum(abs, η_mat - η_fft): $(maximum(abs, Δη_mat))"
            #= none:188 =#
            #= none:188 =# @info "    maximum(abs, η_pcg - η_fft): $(maximum(abs, Δη_pcg))"
            #= none:189 =#
            #= none:189 =# @info "    maximum(abs, η_mat): $(maximum(abs, mat_η_cpu))"
            #= none:190 =#
            #= none:190 =# @info "    maximum(abs, η_pcg): $(maximum(abs, pcg_η_cpu))"
            #= none:191 =#
            #= none:191 =# @info "    maximum(abs, η_fft): $(maximum(abs, fft_η_cpu))"
            #= none:193 =#
            #= none:193 =# @test all(isapprox.(Δη_mat, 0, atol = 1.0e-15))
            #= none:194 =#
            #= none:194 =# @test all(isapprox.(Δη_pcg, 0, atol = 1.0e-15))
            #= none:195 =#
        end
    end