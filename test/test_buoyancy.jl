
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Fields: TracerFields
#= none:5 =#
using Oceananigans.BuoyancyModels: required_tracers, ρ′, ∂x_b, ∂y_b, thermal_expansionᶜᶜᶜ, thermal_expansionᶠᶜᶜ, thermal_expansionᶜᶠᶜ, thermal_expansionᶜᶜᶠ, haline_contractionᶜᶜᶜ, haline_contractionᶠᶜᶜ, haline_contractionᶜᶠᶜ, haline_contractionᶜᶜᶠ
#= none:10 =#
function instantiate_linear_equation_of_state(FT, α, β)
    #= none:10 =#
    #= none:11 =#
    eos = LinearEquationOfState(FT, thermal_expansion = α, haline_contraction = β)
    #= none:12 =#
    return eos.thermal_expansion == FT(α) && eos.haline_contraction == FT(β)
end
#= none:15 =#
function instantiate_seawater_buoyancy(FT, EquationOfState; kwargs...)
    #= none:15 =#
    #= none:16 =#
    buoyancy = SeawaterBuoyancy(FT, equation_of_state = EquationOfState(FT); kwargs...)
    #= none:17 =#
    return typeof(buoyancy.gravitational_acceleration) == FT
end
#= none:20 =#
function density_perturbation_works(arch, FT, eos)
    #= none:20 =#
    #= none:21 =#
    grid = RectilinearGrid(arch, FT, size = (3, 3, 3), extent = (1, 1, 1))
    #= none:22 =#
    C = TracerFields((:T, :S), grid)
    #= none:23 =#
    density_anomaly = #= none:23 =# CUDA.@allowscalar(ρ′(2, 2, 2, grid, eos, C.T, C.S))
    #= none:24 =#
    return true
end
#= none:27 =#
function ∂x_b_works(arch, FT, buoyancy)
    #= none:27 =#
    #= none:28 =#
    grid = RectilinearGrid(arch, FT, size = (3, 3, 3), extent = (1, 1, 1))
    #= none:29 =#
    C = TracerFields(required_tracers(buoyancy), grid)
    #= none:30 =#
    dbdx = #= none:30 =# CUDA.@allowscalar(∂x_b(2, 2, 2, grid, buoyancy, C))
    #= none:31 =#
    return true
end
#= none:34 =#
function ∂y_b_works(arch, FT, buoyancy)
    #= none:34 =#
    #= none:35 =#
    grid = RectilinearGrid(arch, FT, size = (3, 3, 3), extent = (1, 1, 1))
    #= none:36 =#
    C = TracerFields(required_tracers(buoyancy), grid)
    #= none:37 =#
    dbdy = #= none:37 =# CUDA.@allowscalar(∂y_b(2, 2, 2, grid, buoyancy, C))
    #= none:38 =#
    return true
end
#= none:41 =#
function ∂z_b_works(arch, FT, buoyancy)
    #= none:41 =#
    #= none:42 =#
    grid = RectilinearGrid(arch, FT, size = (3, 3, 3), extent = (1, 1, 1))
    #= none:43 =#
    C = TracerFields(required_tracers(buoyancy), grid)
    #= none:44 =#
    dbdz = #= none:44 =# CUDA.@allowscalar(∂z_b(2, 2, 2, grid, buoyancy, C))
    #= none:45 =#
    return true
end
#= none:48 =#
function thermal_expansion_works(arch, FT, eos)
    #= none:48 =#
    #= none:49 =#
    grid = RectilinearGrid(arch, FT, size = (3, 3, 3), extent = (1, 1, 1))
    #= none:50 =#
    C = TracerFields((:T, :S), grid)
    #= none:51 =#
    α = #= none:51 =# CUDA.@allowscalar(thermal_expansionᶜᶜᶜ(2, 2, 2, grid, eos, C.T, C.S))
    #= none:52 =#
    α = #= none:52 =# CUDA.@allowscalar(thermal_expansionᶠᶜᶜ(2, 2, 2, grid, eos, C.T, C.S))
    #= none:53 =#
    α = #= none:53 =# CUDA.@allowscalar(thermal_expansionᶜᶠᶜ(2, 2, 2, grid, eos, C.T, C.S))
    #= none:54 =#
    α = #= none:54 =# CUDA.@allowscalar(thermal_expansionᶜᶜᶠ(2, 2, 2, grid, eos, C.T, C.S))
    #= none:55 =#
    return true
end
#= none:58 =#
function haline_contraction_works(arch, FT, eos)
    #= none:58 =#
    #= none:59 =#
    grid = RectilinearGrid(arch, FT, size = (3, 3, 3), extent = (1, 1, 1))
    #= none:60 =#
    C = TracerFields((:T, :S), grid)
    #= none:61 =#
    β = #= none:61 =# CUDA.@allowscalar(haline_contractionᶜᶜᶜ(2, 2, 2, grid, eos, C.T, C.S))
    #= none:62 =#
    β = #= none:62 =# CUDA.@allowscalar(haline_contractionᶠᶜᶜ(2, 2, 2, grid, eos, C.T, C.S))
    #= none:63 =#
    β = #= none:63 =# CUDA.@allowscalar(haline_contractionᶜᶠᶜ(2, 2, 2, grid, eos, C.T, C.S))
    #= none:64 =#
    β = #= none:64 =# CUDA.@allowscalar(haline_contractionᶜᶜᶠ(2, 2, 2, grid, eos, C.T, C.S))
    #= none:65 =#
    return true
end
#= none:68 =#
EquationsOfState = (LinearEquationOfState, SeawaterPolynomials.RoquetEquationOfState, SeawaterPolynomials.TEOS10EquationOfState)
#= none:69 =#
buoyancy_kwargs = (Dict(), Dict(:constant_salinity => 35.0), Dict(:constant_temperature => 20.0))
#= none:71 =#
#= none:71 =# @testset "BuoyancyModels" begin
        #= none:72 =#
        #= none:72 =# @info "Testing buoyancy..."
        #= none:74 =#
        #= none:74 =# @testset "Equations of State" begin
                #= none:75 =#
                #= none:75 =# @info "  Testing equations of state..."
                #= none:76 =#
                for FT = float_types
                    #= none:77 =#
                    #= none:77 =# @test instantiate_linear_equation_of_state(FT, 0.1, 0.3)
                    #= none:79 =#
                    for EOS = EquationsOfState
                        #= none:80 =#
                        for kwargs = buoyancy_kwargs
                            #= none:81 =#
                            #= none:81 =# @test instantiate_seawater_buoyancy(FT, EOS; kwargs...)
                            #= none:82 =#
                        end
                        #= none:83 =#
                    end
                    #= none:85 =#
                    for arch = archs
                        #= none:86 =#
                        #= none:86 =# @test density_perturbation_works(arch, FT, SeawaterPolynomials.RoquetEquationOfState())
                        #= none:87 =#
                    end
                    #= none:89 =#
                    buoyancies = (nothing, Buoyancy(model = BuoyancyTracer()), Buoyancy(model = SeawaterBuoyancy(FT)), (Buoyancy(model = SeawaterBuoyancy(FT, equation_of_state = eos(FT))) for eos = EquationsOfState)...)
                    #= none:92 =#
                    for arch = archs
                        #= none:93 =#
                        for buoyancy = buoyancies
                            #= none:94 =#
                            #= none:94 =# @test ∂x_b_works(arch, FT, buoyancy)
                            #= none:95 =#
                            #= none:95 =# @test ∂y_b_works(arch, FT, buoyancy)
                            #= none:96 =#
                            #= none:96 =# @test ∂z_b_works(arch, FT, buoyancy)
                            #= none:97 =#
                        end
                        #= none:98 =#
                    end
                    #= none:100 =#
                    for arch = archs
                        #= none:101 =#
                        for EOS = EquationsOfState
                            #= none:102 =#
                            #= none:102 =# @test thermal_expansion_works(arch, FT, EOS())
                            #= none:103 =#
                            #= none:103 =# @test haline_contraction_works(arch, FT, EOS())
                            #= none:104 =#
                        end
                        #= none:105 =#
                    end
                    #= none:106 =#
                end
            end
    end