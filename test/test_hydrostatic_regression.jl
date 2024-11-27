
#= none:2 =#
include("data_dependencies.jl")
#= none:4 =#
using Oceananigans.Grids: topology, XRegularLLG, YRegularLLG, ZRegularLLG
#= none:6 =#
function show_hydrostatic_test(grid, free_surface, precompute_metrics)
    #= none:6 =#
    #= none:8 =#
    if typeof(grid) <: XRegularLLG
        gx = :regular
    else
        gx = :stretched
    end
    #= none:9 =#
    if typeof(grid) <: YRegularLLG
        gy = :regular
    else
        gy = :stretched
    end
    #= none:10 =#
    if typeof(grid) <: ZRegularLLG
        gz = :regular
    else
        gz = :stretched
    end
    #= none:12 =#
    arch = grid.architecture
    #= none:13 =#
    free_surface_str = string((typeof(free_surface)).name.wrapper)
    #= none:15 =#
    strc = "$(if precompute_metrics
    ", metrics are precomputed"
else
    ""
end)"
    #= none:17 =#
    testset_str = "Hydrostatic free turbulence regression [$(arch), $(topology(grid, 1)) longitude,  ($(gx), $(gy), $(gz)) grid, $(free_surface_str)]" * strc
    #= none:18 =#
    info_str = "  Testing Hydrostatic free turbulence [$(arch), $(topology(grid, 1)) longitude,  ($(gx), $(gy), $(gz)) grid, $(free_surface_str)]" * strc
    #= none:20 =#
    return (testset_str, info_str)
end
#= none:23 =#
function get_fields_from_checkpoint(filename)
    #= none:23 =#
    #= none:24 =#
    file = jldopen(filename)
    #= none:26 =#
    tracers = keys(file["tracers"])
    #= none:27 =#
    tracers = Tuple((Symbol(c) for c = tracers))
    #= none:29 =#
    velocity_fields = (u = file["velocities/u/data"], v = file["velocities/v/data"], w = file["velocities/w/data"])
    #= none:33 =#
    tracer_fields = NamedTuple{tracers}(Tuple((file["tracers/$(c)/data"] for c = tracers)))
    #= none:36 =#
    current_tendency_velocity_fields = (u = file["timestepper/Gⁿ/u/data"], v = file["timestepper/Gⁿ/v/data"], w = file["timestepper/Gⁿ/w/data"])
    #= none:40 =#
    current_tendency_tracer_fields = NamedTuple{tracers}(Tuple((file["timestepper/Gⁿ/$(c)/data"] for c = tracers)))
    #= none:43 =#
    previous_tendency_velocity_fields = (u = file["timestepper/G⁻/u/data"], v = file["timestepper/G⁻/v/data"], w = file["timestepper/G⁻/w/data"])
    #= none:47 =#
    previous_tendency_tracer_fields = NamedTuple{tracers}(Tuple((file["timestepper/G⁻/$(c)/data"] for c = tracers)))
    #= none:50 =#
    close(file)
    #= none:52 =#
    solution = merge(velocity_fields, tracer_fields)
    #= none:53 =#
    Gⁿ = merge(current_tendency_velocity_fields, current_tendency_tracer_fields)
    #= none:54 =#
    G⁻ = merge(previous_tendency_velocity_fields, previous_tendency_tracer_fields)
    #= none:56 =#
    return (solution, Gⁿ, G⁻)
end
#= none:59 =#
include("regression_tests/hydrostatic_free_turbulence_regression_test.jl")
#= none:61 =#
#= none:61 =# @testset "Hydrostatic Regression" begin
        #= none:62 =#
        #= none:62 =# @info "Running hydrostatic regression tests..."
        #= none:64 =#
        for arch = archs
            #= none:65 =#
            longitudes = [(-180, 180), (-160, 160)]
            #= none:66 =#
            latitudes = [(-60, 60)]
            #= none:67 =#
            zs = [(-90, 0)]
            #= none:69 =#
            explicit_free_surface = ExplicitFreeSurface(gravitational_acceleration = 1.0)
            #= none:70 =#
            implicit_free_surface = ImplicitFreeSurface(gravitational_acceleration = 1.0, solver_method = :PreconditionedConjugateGradient, reltol = 0, abstol = 1.0e-15)
            #= none:74 =#
            for longitude = longitudes, latitude = latitudes, z = zs, precompute_metrics = (true, false)
                #= none:75 =#
                if longitude[1] == -180
                    size = (180, 60, 3)
                else
                    size = (160, 60, 3)
                end
                #= none:76 =#
                grid = LatitudeLongitudeGrid(arch; size, longitude, latitude, z, precompute_metrics, halo = (2, 2, 2))
                #= none:78 =#
                split_explicit_free_surface = SplitExplicitFreeSurface(grid, gravitational_acceleration = 1.0, substeps = 5)
                #= none:82 =#
                for free_surface = [explicit_free_surface, implicit_free_surface, split_explicit_free_surface]
                    #= none:86 =#
                    if !(precompute_metrics && (free_surface isa ImplicitFreeSurface && arch isa GPU)) && !(free_surface isa ImplicitFreeSurface && arch isa Distributed)
                        #= none:89 =#
                        (testset_str, info_str) = show_hydrostatic_test(grid, free_surface, precompute_metrics)
                        #= none:91 =#
                        #= none:91 =# @testset "$(testset_str)" begin
                                #= none:92 =#
                                #= none:92 =# @info "$(info_str)"
                                #= none:93 =#
                                run_hydrostatic_free_turbulence_regression_test(grid, free_surface)
                            end
                    end
                    #= none:96 =#
                end
                #= none:97 =#
            end
            #= none:98 =#
        end
    end