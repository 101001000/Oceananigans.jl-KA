
#= none:1 =#
using Pkg
#= none:2 =#
using SafeTestsets
#= none:4 =#
const CONVERGENCE_DIR = joinpath(#= none:4 =# @__DIR__(), "..", "validation", "convergence_tests")
#= none:6 =#
Pkg.activate(CONVERGENCE_DIR)
#= none:7 =#
Pkg.instantiate()
#= none:8 =#
Pkg.develop(PackageSpec(path = joinpath(#= none:8 =# @__DIR__(), "..")))
#= none:10 =#
vt = get(ENV, "VALIDATION_TEST", :all) |> Symbol
#= none:12 =#
#= none:12 =# @testset "Convergence" begin
        #= none:13 =#
        if vt == :point_exponential_decay || vt == :all
            #= none:14 =#
            #= none:14 =# @safetestset "0D point exponential decay" begin
                    #= none:15 =#
                    include(joinpath(#= none:15 =# @__DIR__(), "..", "validation", "convergence_tests", "point_exponential_decay.jl"))
                end
        end
        #= none:19 =#
        if vt == :cosine_advection_diffusion || vt == :all
            #= none:20 =#
            #= none:20 =# @safetestset "1D cosine advection-diffusion" begin
                    #= none:21 =#
                    include(joinpath(#= none:21 =# @__DIR__(), "..", "validation", "convergence_tests", "one_dimensional_cosine_advection_diffusion.jl"))
                end
        end
        #= none:25 =#
        if vt == :gaussian_advection_diffusion || vt == :all
            #= none:26 =#
            #= none:26 =# @safetestset "1D Gaussian advection-diffusion" begin
                    #= none:27 =#
                    include(joinpath(#= none:27 =# @__DIR__(), "..", "validation", "convergence_tests", "one_dimensional_gaussian_advection_diffusion.jl"))
                end
        end
        #= none:31 =#
        if vt == :advection_schemes || vt == :all
            #= none:32 =#
            #= none:32 =# @safetestset "1D advection schemes" begin
                    #= none:33 =#
                    include(joinpath(#= none:33 =# @__DIR__(), "..", "validation", "convergence_tests", "one_dimensional_advection_schemes.jl"))
                end
        end
        #= none:37 =#
        if vt == :diffusion || vt == :all
            #= none:38 =#
            #= none:38 =# @safetestset "2D diffusion" begin
                    #= none:39 =#
                    include(joinpath(#= none:39 =# @__DIR__(), "..", "validation", "convergence_tests", "two_dimensional_diffusion.jl"))
                end
        end
        #= none:43 =#
        if vt == :taylor_green || vt == :all
            #= none:44 =#
            #= none:44 =# @safetestset "2D Taylor-Green" begin
                    #= none:45 =#
                    include(joinpath(#= none:45 =# @__DIR__(), "..", "validation", "convergence_tests", "run_taylor_green.jl"))
                    #= none:46 =#
                    include(joinpath(#= none:46 =# @__DIR__(), "..", "validation", "convergence_tests", "analyze_taylor_green.jl"))
                end
        end
        #= none:50 =#
        if vt == :forced_free_slip || vt == :all
            #= none:51 =#
            #= none:51 =# @safetestset "2D forced free-slip" begin
                    #= none:52 =#
                    include(joinpath(#= none:52 =# @__DIR__(), "..", "validation", "convergence_tests", "run_forced_free_slip.jl"))
                    #= none:53 =#
                    include(joinpath(#= none:53 =# @__DIR__(), "..", "validation", "convergence_tests", "analyze_forced_free_slip.jl"))
                end
        end
        #= none:57 =#
        if vt == :forced_fixed_slip || vt == :all
            #= none:58 =#
            #= none:58 =# @safetestset "2D forced fixed-slip" begin
                    #= none:59 =#
                    include(joinpath(#= none:59 =# @__DIR__(), "..", "validation", "convergence_tests", "run_forced_fixed_slip.jl"))
                    #= none:60 =#
                    include(joinpath(#= none:60 =# @__DIR__(), "..", "validation", "convergence_tests", "analyze_forced_fixed_slip.jl"))
                end
        end
    end