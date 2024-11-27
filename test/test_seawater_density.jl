
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Models
#= none:5 =#
using Oceananigans.AbstractOperations: AbstractOperation
#= none:6 =#
using Oceananigans.BuoyancyModels: Zᶜᶜᶜ
#= none:7 =#
using Oceananigans.Models: model_temperature, model_salinity, model_geopotential_height, ConstantTemperatureSB, ConstantSalinitySB
#= none:10 =#
using SeawaterPolynomials: ρ, BoussinesqEquationOfState, SecondOrderSeawaterPolynomial, RoquetEquationOfState, TEOS10EquationOfState, TEOS10SeawaterPolynomial
#= none:13 =#
tracers = (:S, :T)
#= none:14 =#
ST_testvals = (S = 34.7, T = 0.5)
#= none:15 =#
Roquet_eos = (RoquetEquationOfState(:Linear), RoquetEquationOfState(:Cabbeling), RoquetEquationOfState(:CabbelingThermobaricity), RoquetEquationOfState(:Freezing), RoquetEquationOfState(:SecondOrder), RoquetEquationOfState(:SimplestRealistic))
#= none:22 =#
TEOS10_eos = TEOS10EquationOfState()
#= none:24 =#
#= none:24 =# Core.@doc "Return an `Array` on `arch` that is `size(grid)` flled with `value`." function grid_size_value(arch, grid, value)
        #= none:25 =#
        #= none:27 =#
        value_array = fill(value, size(grid))
        #= none:29 =#
        return on_architecture(arch, value_array)
    end
#= none:33 =#
#= none:33 =# Core.@doc "Check the error thrown for non-`BoussinesqEquationOfState`." function error_non_Boussinesq(arch, FT)
        #= none:34 =#
        #= none:36 =#
        grid = RectilinearGrid(arch, FT, size = (3, 3, 3), extent = (1, 1, 1))
        #= none:37 =#
        buoyancy = SeawaterBuoyancy()
        #= none:38 =#
        model = NonhydrostaticModel(; grid, buoyancy, tracers)
        #= none:39 =#
        seawater_density(model)
        #= none:41 =#
        return nothing
    end
#= none:44 =#
#= none:44 =# Core.@doc "    eos_works(arch, FT, eos::BoussinesqEquationOfState;\n              constant_temperature = nothing, constant_salinity = nothing)\n\nCheck if using a `BoussinesqEquationOfState` returns a `KernelFunctionOperation`.\n" function eos_works(arch, FT, eos::BoussinesqEquationOfState; constant_temperature = nothing, constant_salinity = nothing)
        #= none:50 =#
        #= none:53 =#
        grid = RectilinearGrid(arch, FT, size = (3, 3, 3), extent = (1, 1, 1))
        #= none:54 =#
        buoyancy = SeawaterBuoyancy(equation_of_state = eos; constant_temperature, constant_salinity)
        #= none:55 =#
        model = NonhydrostaticModel(; grid, buoyancy, tracers)
        #= none:57 =#
        return seawater_density(model) isa AbstractOperation
    end
#= none:60 =#
#= none:60 =# Core.@doc "    insitu_density(arch, FT, eos::BoussinesqEquationOfState;\n                   constant_temperature = nothing, constant_salinity = nothing)\n\nUse the `KernelFunctionOperation` returned from `seawater_density` to compute\na density `Field` and compare the computed values to density values explicitly\ncalculate using `SeawaterPolynomials.ρ`. Similar function is used to test the\npotential density computation.\n" function insitu_density(arch, FT, eos::BoussinesqEquationOfState; constant_temperature = nothing, constant_salinity = nothing)
        #= none:69 =#
        #= none:72 =#
        grid = RectilinearGrid(arch, FT, size = (3, 3, 3), extent = (1, 1, 1))
        #= none:73 =#
        buoyancy = SeawaterBuoyancy(equation_of_state = eos; constant_temperature, constant_salinity)
        #= none:74 =#
        model = NonhydrostaticModel(; grid, buoyancy, tracers)
        #= none:76 =#
        if !(isnothing(constant_temperature))
            #= none:77 =#
            set!(model, S = ST_testvals.S)
        elseif #= none:78 =# !(isnothing(constant_salinity))
            #= none:79 =#
            set!(model, T = ST_testvals.T)
        else
            #= none:81 =#
            set!(model, S = ST_testvals.S, T = ST_testvals.T)
        end
        #= none:84 =#
        d_field = compute!(Field(seawater_density(model)))
        #= none:87 =#
        geopotential_height = model_geopotential_height(model)
        #= none:88 =#
        T_vec = grid_size_value(arch, grid, ST_testvals.T)
        #= none:89 =#
        S_vec = grid_size_value(arch, grid, ST_testvals.S)
        #= none:90 =#
        eos_vec = grid_size_value(arch, grid, model.buoyancy.model.equation_of_state)
        #= none:91 =#
        SWP_ρ = similar(interior(d_field))
        #= none:92 =#
        #= none:92 =# @__dot__ SWP_ρ = SeawaterPolynomials.ρ(T_vec, S_vec, geopotential_height, eos_vec)
        #= none:94 =#
        return all(interior(d_field) .≈ SWP_ρ)
    end
#= none:97 =#
function potential_density(arch, FT, eos::BoussinesqEquationOfState; constant_temperature = nothing, constant_salinity = nothing)
    #= none:97 =#
    #= none:100 =#
    grid = RectilinearGrid(arch, FT, size = (3, 3, 3), extent = (1, 1, 1))
    #= none:101 =#
    buoyancy = SeawaterBuoyancy(equation_of_state = eos; constant_temperature, constant_salinity)
    #= none:102 =#
    model = NonhydrostaticModel(; grid, buoyancy, tracers)
    #= none:104 =#
    if !(isnothing(constant_temperature))
        #= none:105 =#
        set!(model, S = ST_testvals.S)
    elseif #= none:106 =# !(isnothing(constant_salinity))
        #= none:107 =#
        set!(model, T = ST_testvals.T)
    else
        #= none:109 =#
        set!(model, S = ST_testvals.S, T = ST_testvals.T)
    end
    #= none:112 =#
    d_field = compute!(Field(seawater_density(model, geopotential_height = 0)))
    #= none:115 =#
    geopotential_height = grid_size_value(arch, grid, 0)
    #= none:116 =#
    T_vec = grid_size_value(arch, grid, ST_testvals.T)
    #= none:117 =#
    S_vec = grid_size_value(arch, grid, ST_testvals.S)
    #= none:118 =#
    eos_vec = grid_size_value(arch, grid, model.buoyancy.model.equation_of_state)
    #= none:119 =#
    SWP_ρ = similar(interior(d_field))
    #= none:120 =#
    #= none:120 =# @__dot__ SWP_ρ = SeawaterPolynomials.ρ(T_vec, S_vec, geopotential_height, eos_vec)
    #= none:122 =#
    return all(interior(d_field) .≈ SWP_ρ)
end
#= none:125 =#
#= none:125 =# @testset "Density models" begin
        #= none:126 =#
        #= none:126 =# @info "Testing `seawater_density`..."
        #= none:128 =#
        #= none:128 =# @testset "Error for non-`BoussinesqEquationOfState`" begin
                #= none:129 =#
                #= none:129 =# @info "Testing error is thrown... "
                #= none:130 =#
                for FT = float_types
                    #= none:131 =#
                    for arch = archs
                        #= none:132 =#
                        #= none:132 =# @test_throws ArgumentError error_non_Boussinesq(arch, FT)
                        #= none:133 =#
                    end
                    #= none:134 =#
                end
            end
        #= none:137 =#
        #= none:137 =# @testset "seawater_density `KernelFunctionOperation` instantiation" begin
                #= none:138 =#
                #= none:138 =# @info "Testing `AbstractOperation` is returned..."
                #= none:140 =#
                for FT = float_types
                    #= none:141 =#
                    for arch = archs
                        #= none:142 =#
                        for eos = Roquet_eos
                            #= none:143 =#
                            #= none:143 =# @test eos_works(arch, FT, eos)
                            #= none:144 =#
                            #= none:144 =# @test eos_works(arch, FT, eos, constant_temperature = ST_testvals.T)
                            #= none:145 =#
                            #= none:145 =# @test eos_works(arch, FT, eos, constant_salinity = ST_testvals.S)
                            #= none:146 =#
                        end
                        #= none:147 =#
                        #= none:147 =# @test eos_works(arch, FT, TEOS10_eos)
                        #= none:148 =#
                        #= none:148 =# @test eos_works(arch, FT, TEOS10_eos, constant_temperature = ST_testvals.T)
                        #= none:149 =#
                        #= none:149 =# @test eos_works(arch, FT, TEOS10_eos, constant_salinity = ST_testvals.S)
                        #= none:150 =#
                    end
                    #= none:151 =#
                end
            end
        #= none:154 =#
        #= none:154 =# @testset "In-situ density computation tests" begin
                #= none:155 =#
                #= none:155 =# @info "Testing in-situ density computation..."
                #= none:157 =#
                for FT = float_types
                    #= none:158 =#
                    for arch = archs
                        #= none:159 =#
                        for eos = Roquet_eos
                            #= none:160 =#
                            #= none:160 =# @test insitu_density(arch, FT, eos)
                            #= none:161 =#
                            #= none:161 =# @test insitu_density(arch, FT, eos, constant_temperature = ST_testvals.T)
                            #= none:162 =#
                            #= none:162 =# @test insitu_density(arch, FT, eos, constant_salinity = ST_testvals.S)
                            #= none:163 =#
                        end
                        #= none:164 =#
                        #= none:164 =# @test insitu_density(arch, FT, TEOS10_eos)
                        #= none:165 =#
                        #= none:165 =# @test insitu_density(arch, FT, TEOS10_eos, constant_temperature = ST_testvals.T)
                        #= none:166 =#
                        #= none:166 =# @test insitu_density(arch, FT, TEOS10_eos, constant_salinity = ST_testvals.S)
                        #= none:167 =#
                    end
                    #= none:168 =#
                end
            end
        #= none:171 =#
        #= none:171 =# @testset "Potential density computation tests" begin
                #= none:172 =#
                #= none:172 =# @info "Testing a potential density comnputation..."
                #= none:174 =#
                for FT = float_types
                    #= none:175 =#
                    for arch = archs
                        #= none:176 =#
                        for eos = Roquet_eos
                            #= none:177 =#
                            #= none:177 =# @test potential_density(arch, FT, eos)
                            #= none:178 =#
                            #= none:178 =# @test potential_density(arch, FT, eos, constant_temperature = ST_testvals.T)
                            #= none:179 =#
                            #= none:179 =# @test potential_density(arch, FT, eos, constant_salinity = ST_testvals.S)
                            #= none:180 =#
                        end
                        #= none:181 =#
                        #= none:181 =# @test potential_density(arch, FT, TEOS10_eos)
                        #= none:182 =#
                        #= none:182 =# @test potential_density(arch, FT, TEOS10_eos, constant_temperature = ST_testvals.T)
                        #= none:183 =#
                        #= none:183 =# @test potential_density(arch, FT, TEOS10_eos, constant_salinity = ST_testvals.S)
                        #= none:184 =#
                    end
                    #= none:185 =#
                end
            end
    end