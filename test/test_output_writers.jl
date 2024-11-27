
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Statistics
#= none:4 =#
using NCDatasets
#= none:6 =#
using Dates: Millisecond
#= none:7 =#
using Oceananigans: write_output!
#= none:8 =#
using Oceananigans.BoundaryConditions: PBC, FBC, ZFBC, ContinuousBoundaryFunction
#= none:9 =#
using Oceananigans.TimeSteppers: update_state!
#= none:15 =#
function run_instantiate_windowed_time_average_tests(model)
    #= none:15 =#
    #= none:17 =#
    set!(model, u = ((x, y, z)->begin
                    #= none:17 =#
                    rand()
                end))
    #= none:18 =#
    (u, v, w) = model.velocities
    #= none:19 =#
    (Nx, Ny, Nz) = size(u)
    #= none:21 =#
    for test_u = (u, view(u, 1:Nx, 1:Ny, 1:Nz))
        #= none:22 =#
        u₀ = deepcopy(parent(test_u))
        #= none:23 =#
        wta = WindowedTimeAverage(test_u, schedule = AveragedTimeInterval(10, window = 1))
        #= none:24 =#
        #= none:24 =# @test all(wta(model) .== u₀)
        #= none:25 =#
    end
    #= none:27 =#
    return nothing
end
#= none:30 =#
function time_step_with_windowed_time_average(model)
    #= none:30 =#
    #= none:32 =#
    model.clock.iteration = 0
    #= none:33 =#
    model.clock.time = 0.0
    #= none:35 =#
    set!(model, u = 0, v = 0, w = 0, T = 0, S = 0)
    #= none:37 =#
    wta = WindowedTimeAverage(model.velocities.u, schedule = AveragedTimeInterval(4, window = 2))
    #= none:39 =#
    simulation = Simulation(model, Δt = 1.0, stop_time = 4.0)
    #= none:40 =#
    simulation.diagnostics[:u_avg] = wta
    #= none:41 =#
    run!(simulation)
    #= none:43 =#
    return all(wta(model) .== parent(model.velocities.u))
end
#= none:50 =#
function dependencies_added_correctly!(model, windowed_time_average, output_writer)
    #= none:50 =#
    #= none:52 =#
    model.clock.iteration = 0
    #= none:53 =#
    model.clock.time = 0.0
    #= none:55 =#
    simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
    #= none:56 =#
    push!(simulation.output_writers, output_writer)
    #= none:57 =#
    run!(simulation)
    #= none:59 =#
    return windowed_time_average ∈ values(simulation.diagnostics)
end
#= none:62 =#
function test_dependency_adding(model)
    #= none:62 =#
    #= none:64 =#
    windowed_time_average = WindowedTimeAverage(model.velocities.u, schedule = AveragedTimeInterval(4, window = 2))
    #= none:66 =#
    output = Dict("time_average" => windowed_time_average)
    #= none:67 =#
    attributes = Dict("time_average" => Dict("longname" => "A time average", "units" => "arbitrary"))
    #= none:68 =#
    dimensions = Dict("time_average" => ("xF", "yC", "zC"))
    #= none:71 =#
    jld2_output_writer = JLD2OutputWriter(model, output, schedule = TimeInterval(4), dir = ".", filename = "test.jld2", overwrite_existing = true)
    #= none:77 =#
    windowed_time_average = jld2_output_writer.outputs.time_average
    #= none:78 =#
    #= none:78 =# @test dependencies_added_correctly!(model, windowed_time_average, jld2_output_writer)
    #= none:80 =#
    rm("test.jld2")
    #= none:83 =#
    netcdf_output_writer = NetCDFOutputWriter(model, output, schedule = TimeInterval(4), filename = "test.nc", output_attributes = attributes, dimensions = dimensions)
    #= none:89 =#
    windowed_time_average = netcdf_output_writer.outputs["time_average"]
    #= none:90 =#
    #= none:90 =# @test dependencies_added_correctly!(model, windowed_time_average, netcdf_output_writer)
    #= none:92 =#
    rm("test.nc")
    #= none:94 =#
    return nothing
end
#= none:97 =#
function test_creating_and_appending(model, output_writer)
    #= none:97 =#
    #= none:99 =#
    simulation = Simulation(model, Δt = 1, stop_iteration = 5)
    #= none:100 =#
    output = fields(model)
    #= none:101 =#
    filename = "test_creating_and_appending"
    #= none:104 =#
    simulation.output_writers[:writer] = (writer = output_writer(model, output, filename = filename, schedule = IterationInterval(1), overwrite_existing = true, verbose = true))
    #= none:108 =#
    run!(simulation)
    #= none:111 =#
    filepath = writer.filepath
    #= none:112 =#
    #= none:112 =# @test isfile(filepath)
    #= none:115 =#
    simulation.stop_iteration = 10
    #= none:116 =#
    (simulation.output_writers[:writer]).overwrite_existing = false
    #= none:117 =#
    run!(simulation)
    #= none:120 =#
    if output_writer === NetCDFOutputWriter
        #= none:121 =#
        ds = NCDataset(filepath)
        #= none:122 =#
        time_length = length(ds["time"])
    elseif #= none:123 =# output_writer === JLD2OutputWriter
        #= none:124 =#
        ds = jldopen(filepath)
        #= none:125 =#
        time_length = length(keys(ds["timeseries/t"]))
    end
    #= none:127 =#
    close(ds)
    #= none:128 =#
    #= none:128 =# @test time_length == 11
    #= none:130 =#
    rm(filepath)
    #= none:132 =#
    return nothing
end
#= none:139 =#
function test_windowed_time_averaging_simulation(model)
    #= none:139 =#
    #= none:141 =#
    jld_filename1 = "test_windowed_time_averaging1.jld2"
    #= none:142 =#
    jld_filename2 = "test_windowed_time_averaging2.jld2"
    #= none:144 =#
    model.clock.iteration = (model.clock.time = 0)
    #= none:145 =#
    simulation = Simulation(model, Δt = 1.0, stop_iteration = 0)
    #= none:147 =#
    jld2_output_writer = JLD2OutputWriter(model, model.velocities, schedule = AveragedTimeInterval(π, window = 1), filename = jld_filename1, overwrite_existing = true)
    #= none:153 =#
    nc_filepath1 = "windowed_time_average_test1.nc"
    #= none:154 =#
    nc_outputs = Dict((string(KAUtils.name) => field for (name, field) = pairs(model.velocities)))
    #= none:155 =#
    nc_output_writer = NetCDFOutputWriter(model, nc_outputs, filename = nc_filepath1, schedule = AveragedTimeInterval(π, window = 1))
    #= none:159 =#
    jld2_outputs_are_time_averaged = Tuple((typeof(out) <: WindowedTimeAverage for out = jld2_output_writer.outputs))
    #= none:160 =#
    nc_outputs_are_time_averaged = Tuple((typeof(out) <: WindowedTimeAverage for out = values(nc_output_writer.outputs)))
    #= none:162 =#
    #= none:162 =# @test all(jld2_outputs_are_time_averaged)
    #= none:163 =#
    #= none:163 =# @test all(nc_outputs_are_time_averaged)
    #= none:167 =#
    simulation.output_writers[:jld2] = jld2_output_writer
    #= none:168 =#
    simulation.output_writers[:nc] = nc_output_writer
    #= none:170 =#
    run!(simulation)
    #= none:172 =#
    jld2_u_windowed_time_average = (simulation.output_writers[:jld2]).outputs.u
    #= none:173 =#
    nc_w_windowed_time_average = (simulation.output_writers[:nc]).outputs["w"]
    #= none:175 =#
    #= none:175 =# @test !(jld2_u_windowed_time_average.schedule.collecting)
    #= none:176 =#
    #= none:176 =# @test !(nc_w_windowed_time_average.schedule.collecting)
    #= none:181 =#
    simulation.Δt = 1.5
    #= none:182 =#
    simulation.stop_iteration = 2
    #= none:183 =#
    run!(simulation)
    #= none:185 =#
    #= none:185 =# @test jld2_u_windowed_time_average.schedule.collecting
    #= none:186 =#
    #= none:186 =# @test nc_w_windowed_time_average.schedule.collecting
    #= none:189 =#
    simulation.Δt = (π - 3) + 0.01
    #= none:190 =#
    simulation.stop_iteration = 3
    #= none:191 =#
    run!(simulation)
    #= none:193 =#
    #= none:193 =# @test jld2_u_windowed_time_average.schedule.previous_interval_stop_time == model.clock.time - rem(model.clock.time, jld2_u_windowed_time_average.schedule.interval)
    #= none:196 =#
    #= none:196 =# @test nc_w_windowed_time_average.schedule.previous_interval_stop_time == model.clock.time - rem(model.clock.time, nc_w_windowed_time_average.schedule.interval)
    #= none:201 =#
    model.clock.iteration = (model.clock.time = 0)
    #= none:203 =#
    simulation.output_writers[:jld2] = JLD2OutputWriter(model, model.velocities, schedule = AveragedTimeInterval(π, window = π), filename = jld_filename2, overwrite_existing = true)
    #= none:208 =#
    nc_filepath2 = "windowed_time_average_test2.nc"
    #= none:209 =#
    nc_outputs = Dict((string(name) => field for (name, field) = pairs(model.velocities)))
    #= none:210 =#
    simulation.output_writers[:nc] = NetCDFOutputWriter(model, nc_outputs, filename = nc_filepath2, schedule = AveragedTimeInterval(π, window = π))
    #= none:214 =#
    run!(simulation)
    #= none:216 =#
    #= none:216 =# @test (simulation.output_writers[:jld2]).outputs.u.schedule.collecting
    #= none:217 =#
    #= none:217 =# @test ((simulation.output_writers[:nc]).outputs["w"]).schedule.collecting
    #= none:219 =#
    rm(nc_filepath1)
    #= none:220 =#
    rm(nc_filepath2)
    #= none:221 =#
    rm(jld_filename1)
    #= none:222 =#
    rm(jld_filename2)
    #= none:224 =#
    return nothing
end
#= none:231 =#
#= none:231 =# @testset "Output writers" begin
        #= none:232 =#
        #= none:232 =# @info "Testing output writers..."
        #= none:234 =#
        topo = (Periodic, Periodic, Bounded)
        #= none:235 =#
        for arch = archs
            #= none:237 =#
            #= none:237 =# @info "Testing that writers create file and append to it properly"
            #= none:238 =#
            for output_writer = (NetCDFOutputWriter, JLD2OutputWriter)
                #= none:239 =#
                grid = RectilinearGrid(arch, topology = topo, size = (1, 1, 1), extent = (1, 1, 1))
                #= none:240 =#
                model = NonhydrostaticModel(; grid)
                #= none:241 =#
                test_creating_and_appending(model, output_writer)
                #= none:242 =#
            end
            #= none:245 =#
            grid = RectilinearGrid(arch, topology = topo, size = (4, 4, 4), extent = (1, 1, 1))
            #= none:246 =#
            model = NonhydrostaticModel(; grid, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
            #= none:248 =#
            #= none:248 =# @testset "WindowedTimeAverage [$(typeof(arch))]" begin
                    #= none:249 =#
                    #= none:249 =# @info "  Testing WindowedTimeAverage [$(typeof(arch))]..."
                    #= none:250 =#
                    run_instantiate_windowed_time_average_tests(model)
                    #= none:251 =#
                    #= none:251 =# @test time_step_with_windowed_time_average(model)
                    #= none:252 =#
                    #= none:252 =# @test_throws ArgumentError AveragedTimeInterval(1.0, window = 1.1)
                end
            #= none:254 =#
        end
        #= none:256 =#
        include("test_netcdf_output_writer.jl")
        #= none:257 =#
        include("test_jld2_output_writer.jl")
        #= none:258 =#
        include("test_checkpointer.jl")
        #= none:260 =#
        for arch = archs
            #= none:261 =#
            topo = (Periodic, Periodic, Bounded)
            #= none:262 =#
            grid = RectilinearGrid(arch, topology = topo, size = (4, 4, 4), extent = (1, 1, 1))
            #= none:263 =#
            model = NonhydrostaticModel(; grid, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
            #= none:265 =#
            #= none:265 =# @testset "Dependency adding [$(typeof(arch))]" begin
                    #= none:266 =#
                    #= none:266 =# @info "    Testing dependency adding [$(typeof(arch))]..."
                    #= none:267 =#
                    test_dependency_adding(model)
                end
            #= none:270 =#
            #= none:270 =# @testset "Time averaging of output [$(typeof(arch))]" begin
                    #= none:271 =#
                    #= none:271 =# @info "    Testing time averaging of output [$(typeof(arch))]..."
                    #= none:272 =#
                    test_windowed_time_averaging_simulation(model)
                end
            #= none:274 =#
        end
    end