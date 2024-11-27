
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Diagnostics
#= none:4 =#
using Oceananigans.Diagnostics: AbstractDiagnostic
#= none:6 =#
struct TestDiagnostic <: AbstractDiagnostic
    #= none:6 =#
end
#= none:8 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: VectorInvariant
#= none:10 =#
TestModel_VerticallyStrectedRectGrid(arch, FT, ν = 1.0, Δx = 0.5) = begin
        #= none:10 =#
        NonhydrostaticModel(grid = RectilinearGrid(arch, FT, size = (3, 3, 3), x = (0, 3Δx), y = (0, 3Δx), z = 0:Δx:3Δx), closure = ScalarDiffusivity(FT, ν = ν, κ = ν))
    end
#= none:17 =#
TestModel_RegularRectGrid(arch, FT, ν = 1.0, Δx = 0.5) = begin
        #= none:17 =#
        NonhydrostaticModel(grid = RectilinearGrid(arch, FT, topology = (Periodic, Periodic, Periodic), size = (3, 3, 3), extent = (3Δx, 3Δx, 3Δx)), closure = ScalarDiffusivity(FT, ν = ν, κ = ν))
    end
#= none:23 =#
function diffusive_cfl_diagnostic_is_correct(arch, FT)
    #= none:23 =#
    #= none:24 =#
    Δt = FT(1.3e-6)
    #= none:25 =#
    Δx = FT(0.5)
    #= none:26 =#
    ν = FT(1.2)
    #= none:27 =#
    CFL_by_hand = (Δt * ν) / Δx ^ 2
    #= none:29 =#
    model = TestModel_RegularRectGrid(arch, FT, ν, Δx)
    #= none:30 =#
    cfl = DiffusiveCFL(FT(Δt))
    #= none:32 =#
    return cfl(model) ≈ CFL_by_hand
end
#= none:35 =#
function advective_cfl_diagnostic_is_correct_on_regular_grid(arch, FT)
    #= none:35 =#
    #= none:36 =#
    model = TestModel_RegularRectGrid(arch, FT)
    #= none:38 =#
    Δt = FT(1.3e-6)
    #= none:39 =#
    Δx = minimum_xspacing(model.grid)
    #= none:40 =#
    u₀ = FT(1.2)
    #= none:41 =#
    CFL_by_hand = (Δt * u₀) / Δx
    #= none:43 =#
    set!(model, u = u₀)
    #= none:44 =#
    cfl = AdvectiveCFL(FT(Δt))
    #= none:46 =#
    return cfl(model) ≈ CFL_by_hand
end
#= none:49 =#
function advective_cfl_diagnostic_is_correct_on_vertically_stretched_grid(arch, FT)
    #= none:49 =#
    #= none:50 =#
    model = TestModel_VerticallyStrectedRectGrid(arch, FT)
    #= none:52 =#
    Δt = FT(1.3e-6)
    #= none:53 =#
    Δx = FT(model.grid.Δxᶜᵃᵃ)
    #= none:54 =#
    u₀ = FT(1.2)
    #= none:55 =#
    CFL_by_hand = (Δt * u₀) / Δx
    #= none:57 =#
    set!(model, u = u₀)
    #= none:58 =#
    cfl = AdvectiveCFL(FT(Δt))
    #= none:60 =#
    return cfl(model) ≈ CFL_by_hand
end
#= none:63 =#
function advective_timescale_cfl_on_regular_grid(arch, FT)
    #= none:63 =#
    #= none:64 =#
    model = TestModel_RegularRectGrid(arch, FT)
    #= none:66 =#
    Δt = FT(1.7)
    #= none:68 =#
    Δx = model.grid.Δxᶜᵃᵃ
    #= none:69 =#
    Δy = model.grid.Δyᵃᶜᵃ
    #= none:70 =#
    Δz = model.grid.Δzᵃᵃᶜ
    #= none:72 =#
    u₀ = FT(1.2)
    #= none:73 =#
    v₀ = FT(-2.5)
    #= none:74 =#
    w₀ = FT(3.9)
    #= none:76 =#
    set!(model, u = u₀, v = v₀, w = w₀)
    #= none:78 =#
    CFL_by_hand = Δt * (abs(u₀) / Δx + abs(v₀) / Δy + abs(w₀) / Δz)
    #= none:80 =#
    cfl = CFL(FT(Δt), Oceananigans.Advection.cell_advection_timescale)
    #= none:82 =#
    return cfl(model) ≈ CFL_by_hand
end
#= none:85 =#
function advective_timescale_cfl_on_stretched_grid(arch, FT)
    #= none:85 =#
    #= none:86 =#
    grid = RectilinearGrid(arch, size = (4, 4, 8), x = (0, 100), y = (0, 100), z = [k ^ 2 for k = 0:8])
    #= none:87 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:89 =#
    Δt = FT(15.5)
    #= none:91 =#
    Δx = model.grid.Δxᶜᵃᵃ
    #= none:92 =#
    Δy = model.grid.Δyᵃᶜᵃ
    #= none:95 =#
    Δz_min = #= none:95 =# CUDA.@allowscalar(Oceananigans.Operators.Δzᵃᵃᶠ(1, 1, 2, grid))
    #= none:97 =#
    u₀ = FT(1.2)
    #= none:98 =#
    v₀ = FT(-2.5)
    #= none:99 =#
    w₀ = FT(3.9)
    #= none:101 =#
    set!(model, u = u₀, v = v₀, w = w₀, enforce_incompressibility = false)
    #= none:103 =#
    CFL_by_hand = Δt * (abs(u₀) / Δx + abs(v₀) / Δy + abs(w₀) / Δz_min)
    #= none:105 =#
    cfl = CFL(FT(Δt), Oceananigans.Advection.cell_advection_timescale)
    #= none:107 =#
    return cfl(model) ≈ CFL_by_hand
end
#= none:110 =#
function advective_timescale_cfl_on_lat_lon_grid(arch, FT)
    #= none:110 =#
    #= none:111 =#
    grid = LatitudeLongitudeGrid(arch, size = (8, 8, 8), longitude = (-10, 10), latitude = (0, 45), z = (-1000, 0))
    #= none:112 =#
    model = HydrostaticFreeSurfaceModel(grid = grid, momentum_advection = VectorInvariant())
    #= none:114 =#
    Δt = FT(1000)
    #= none:116 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:119 =#
    Δx_min = #= none:119 =# CUDA.@allowscalar(Oceananigans.Operators.Δxᶠᶜᵃ(1, Ny, 1, grid))
    #= none:122 =#
    Δy_min = #= none:122 =# CUDA.@allowscalar(Oceananigans.Operators.Δyᶜᶠᵃ(1, 1, 1, grid))
    #= none:124 =#
    Δz = model.grid.Δzᵃᵃᶠ
    #= none:126 =#
    u₀ = FT(1.2)
    #= none:127 =#
    v₀ = FT(-2.5)
    #= none:128 =#
    w₀ = FT(-0.1)
    #= none:131 =#
    set!(model.velocities.u, u₀)
    #= none:132 =#
    set!(model.velocities.v, v₀)
    #= none:133 =#
    set!(model.velocities.w, w₀)
    #= none:135 =#
    CFL_by_hand = Δt * (abs(u₀) / Δx_min + abs(v₀) / Δy_min + abs(w₀) / Δz)
    #= none:137 =#
    cfl = CFL(FT(Δt), Oceananigans.Advection.cell_advection_timescale)
    #= none:139 =#
    return cfl(model) ≈ CFL_by_hand
end
#= none:142 =#
function advective_timescale_cfl_on_flat_2d_grid(arch, FT)
    #= none:142 =#
    #= none:143 =#
    Δx = 0.5
    #= none:144 =#
    topo = (Periodic, Flat, Bounded)
    #= none:145 =#
    grid = RectilinearGrid(arch, FT, topology = topo, size = (3, 3), x = (0, 3Δx), z = (0, 3Δx))
    #= none:147 =#
    model = NonhydrostaticModel(; grid)
    #= none:148 =#
    set!(model, v = 1)
    #= none:150 =#
    Δt = FT(1.7)
    #= none:151 =#
    cfl = CFL(FT(Δt), Oceananigans.Advection.cell_advection_timescale)
    #= none:153 =#
    return cfl(model) == 0
end
#= none:156 =#
get_iteration(model) = begin
        #= none:156 =#
        model.clock.iteration
    end
#= none:157 =#
get_time(model) = begin
        #= none:157 =#
        model.clock.time
    end
#= none:159 =#
function diagnostics_getindex(arch, FT)
    #= none:159 =#
    #= none:160 =#
    model = TestModel_RegularRectGrid(arch, FT)
    #= none:161 =#
    simulation = Simulation(model, Δt = 0, stop_iteration = 0)
    #= none:162 =#
    td = TestDiagnostic()
    #= none:163 =#
    simulation.diagnostics[:td] = td
    #= none:164 =#
    return simulation.diagnostics[1] == td
end
#= none:167 =#
function diagnostics_setindex(arch, FT)
    #= none:167 =#
    #= none:168 =#
    model = TestModel_RegularRectGrid(arch, FT)
    #= none:169 =#
    simulation = Simulation(model, Δt = 0, stop_iteration = 0)
    #= none:171 =#
    td1 = TestDiagnostic()
    #= none:172 =#
    td2 = TestDiagnostic()
    #= none:173 =#
    td3 = TestDiagnostic()
    #= none:175 =#
    push!(simulation.diagnostics, td1, td2)
    #= none:176 =#
    simulation.diagnostics[2] = td3
    #= none:178 =#
    return simulation.diagnostics[:diag2] == td3
end
#= none:181 =#
#= none:181 =# @testset "Diagnostics" begin
        #= none:182 =#
        #= none:182 =# @info "Testing diagnostics..."
        #= none:184 =#
        for arch = archs
            #= none:185 =#
            #= none:185 =# @testset "CFL [$(typeof(arch))]" begin
                    #= none:186 =#
                    #= none:186 =# @info "  Testing CFL diagnostics [$(typeof(arch))]..."
                    #= none:187 =#
                    for FT = float_types
                        #= none:188 =#
                        #= none:188 =# @test diffusive_cfl_diagnostic_is_correct(arch, FT)
                        #= none:189 =#
                        #= none:189 =# @test advective_cfl_diagnostic_is_correct_on_regular_grid(arch, FT)
                        #= none:190 =#
                        #= none:190 =# @test advective_cfl_diagnostic_is_correct_on_vertically_stretched_grid(arch, FT)
                        #= none:191 =#
                        #= none:191 =# @test advective_timescale_cfl_on_regular_grid(arch, FT)
                        #= none:192 =#
                        #= none:192 =# @test advective_timescale_cfl_on_stretched_grid(arch, FT)
                        #= none:193 =#
                        #= none:193 =# @test advective_timescale_cfl_on_lat_lon_grid(arch, FT)
                        #= none:194 =#
                        #= none:194 =# @test advective_timescale_cfl_on_flat_2d_grid(arch, FT)
                        #= none:195 =#
                    end
                end
            #= none:197 =#
        end
        #= none:199 =#
        for arch = archs
            #= none:200 =#
            #= none:200 =# @testset "Miscellaneous timeseries diagnostics [$(typeof(arch))]" begin
                    #= none:201 =#
                    #= none:201 =# @info "  Testing miscellaneous timeseries diagnostics [$(typeof(arch))]..."
                    #= none:202 =#
                    for FT = float_types
                        #= none:203 =#
                        #= none:203 =# @test diagnostics_getindex(arch, FT)
                        #= none:204 =#
                        #= none:204 =# @test diagnostics_setindex(arch, FT)
                        #= none:205 =#
                    end
                end
            #= none:207 =#
        end
    end