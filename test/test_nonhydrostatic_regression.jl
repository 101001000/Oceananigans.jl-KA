
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:2 =#
include("data_dependencies.jl")
#= none:4 =#
using Oceananigans.Grids: topology, XRegularLLG, YRegularLLG, ZRegularLLG
#= none:5 =#
using Oceananigans.Fields: CenterField
#= none:7 =#
function get_fields_from_checkpoint(filename)
    #= none:7 =#
    #= none:8 =#
    file = jldopen(filename)
    #= none:10 =#
    tracers = keys(file["tracers"])
    #= none:11 =#
    tracers = Tuple((Symbol(c) for c = tracers))
    #= none:13 =#
    velocity_fields = (u = file["velocities/u/data"], v = file["velocities/v/data"], w = file["velocities/w/data"])
    #= none:17 =#
    tracer_fields = NamedTuple{tracers}(Tuple((file["tracers/$(c)/data"] for c = tracers)))
    #= none:20 =#
    current_tendency_velocity_fields = (u = file["timestepper/Gⁿ/u/data"], v = file["timestepper/Gⁿ/v/data"], w = file["timestepper/Gⁿ/w/data"])
    #= none:24 =#
    current_tendency_tracer_fields = NamedTuple{tracers}(Tuple((file["timestepper/Gⁿ/$(c)/data"] for c = tracers)))
    #= none:27 =#
    previous_tendency_velocity_fields = (u = file["timestepper/G⁻/u/data"], v = file["timestepper/G⁻/v/data"], w = file["timestepper/G⁻/w/data"])
    #= none:31 =#
    previous_tendency_tracer_fields = NamedTuple{tracers}(Tuple((file["timestepper/G⁻/$(c)/data"] for c = tracers)))
    #= none:34 =#
    close(file)
    #= none:36 =#
    solution = merge(velocity_fields, tracer_fields)
    #= none:37 =#
    Gⁿ = merge(current_tendency_velocity_fields, current_tendency_tracer_fields)
    #= none:38 =#
    G⁻ = merge(previous_tendency_velocity_fields, previous_tendency_tracer_fields)
    #= none:40 =#
    return (solution, Gⁿ, G⁻)
end
#= none:43 =#
include("regression_tests/thermal_bubble_regression_test.jl")
#= none:44 =#
include("regression_tests/rayleigh_benard_regression_test.jl")
#= none:45 =#
include("regression_tests/ocean_large_eddy_simulation_regression_test.jl")
#= none:47 =#
#= none:47 =# @testset "Nonhydrostatic Regression" begin
        #= none:48 =#
        #= none:48 =# @info "Running nonhydrostatic regression tests..."
        #= none:50 =#
        archs = nonhydrostatic_regression_test_architectures()
        #= none:52 =#
        for arch = archs
            #= none:53 =#
            A = typeof(arch)
            #= none:55 =#
            for grid_type = [:regular, :vertically_unstretched]
                #= none:56 =#
                #= none:56 =# @testset "Rayleigh–Bénard tracer [$(A), $(grid_type) grid]]" begin
                        #= none:57 =#
                        #= none:57 =# @info "  Testing Rayleigh–Bénard tracer regression [$(A), $(grid_type) grid]"
                        #= none:58 =#
                        run_rayleigh_benard_regression_test(arch, grid_type)
                    end
                #= none:61 =#
                if !(arch isa Distributed)
                    #= none:62 =#
                    #= none:62 =# @testset "Thermal bubble [$(A), $(grid_type) grid]" begin
                            #= none:63 =#
                            #= none:63 =# @info "  Testing thermal bubble regression [$(A), $(grid_type) grid]"
                            #= none:64 =#
                            run_thermal_bubble_regression_test(arch, grid_type)
                        end
                    #= none:67 =#
                    amd_closure = (AnisotropicMinimumDissipation(), ScalarDiffusivity(ν = 1.05e-6, κ = 1.46e-7))
                    #= none:68 =#
                    smag_closure = (SmagorinskyLilly(C = 0.23, Cb = 1, Pr = 1), ScalarDiffusivity(ν = 1.05e-6, κ = 1.46e-7))
                    #= none:70 =#
                    for closure = (amd_closure, smag_closure)
                        #= none:71 =#
                        closurename = string((typeof(first(closure))).name.wrapper)
                        #= none:72 =#
                        #= none:72 =# @testset "Ocean large eddy simulation [$(A), $(closurename), $(grid_type) grid]" begin
                                #= none:73 =#
                                #= none:73 =# @info "  Testing oceanic large eddy simulation regression [$(A), $(closurename), $(grid_type) grid]"
                                #= none:74 =#
                                run_ocean_large_eddy_simulation_regression_test(arch, grid_type, closure)
                            end
                        #= none:76 =#
                    end
                end
                #= none:78 =#
            end
            #= none:79 =#
        end
    end