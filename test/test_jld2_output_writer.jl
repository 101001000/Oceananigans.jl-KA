
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Fields: FunctionField
#= none:9 =#
function jld2_sliced_field_output(model, outputs = model.velocities)
    #= none:9 =#
    #= none:11 =#
    model.clock.iteration = 0
    #= none:12 =#
    model.clock.time = 0.0
    #= none:14 =#
    set!(model, u = ((x, y, z)->begin
                    #= none:14 =#
                    rand()
                end), v = ((x, y, z)->begin
                    #= none:15 =#
                    rand()
                end), w = ((x, y, z)->begin
                    #= none:16 =#
                    rand()
                end))
    #= none:18 =#
    simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
    #= none:20 =#
    simulation.output_writers[:velocities] = JLD2OutputWriter(model, outputs, schedule = TimeInterval(1), indices = (1:2, 1:4, :), with_halos = false, dir = ".", filename = "test.jld2", overwrite_existing = true)
    #= none:29 =#
    run!(simulation)
    #= none:31 =#
    file = jldopen("test.jld2")
    #= none:33 =#
    u₁ = file["timeseries/u/0"]
    #= none:34 =#
    v₁ = file["timeseries/v/0"]
    #= none:35 =#
    w₁ = file["timeseries/w/0"]
    #= none:37 =#
    close(file)
    #= none:39 =#
    rm("test.jld2")
    #= none:41 =#
    return size(u₁) == (2, 2, 4) && (size(v₁) == (2, 2, 4) && size(w₁) == (2, 2, 5))
end
#= none:44 =#
function test_jld2_size_file_splitting(arch)
    #= none:44 =#
    #= none:45 =#
    grid = RectilinearGrid(arch, size = (16, 16, 16), extent = (1, 1, 1), halo = (1, 1, 1))
    #= none:46 =#
    model = NonhydrostaticModel(; grid, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:47 =#
    simulation = Simulation(model, Δt = 1, stop_iteration = 10)
    #= none:49 =#
    function fake_bc_init(file, model)
        #= none:49 =#
        #= none:50 =#
        file["boundary_conditions/fake"] = π
    end
    #= none:53 =#
    ow = JLD2OutputWriter(model, (; u = model.velocities.u); dir = ".", filename = "test.jld2", schedule = IterationInterval(1), init = fake_bc_init, including = [:grid], array_type = Array{Float64}, with_halos = true, file_splitting = FileSizeLimit(200KiB), overwrite_existing = true)
    #= none:64 =#
    push!(simulation.output_writers, ow)
    #= none:67 =#
    run!(simulation)
    #= none:70 =#
    #= none:70 =# @test filesize("test_part1.jld2") > 200KiB
    #= none:71 =#
    #= none:71 =# @test filesize("test_part2.jld2") > 200KiB
    #= none:72 =#
    #= none:72 =# @test filesize("test_part3.jld2") < 200KiB
    #= none:73 =#
    #= none:73 =# @test !(isfile("test_part4.jld2"))
    #= none:75 =#
    for n = string.(1:3)
        #= none:76 =#
        filename = "test_part$(n).jld2"
        #= none:77 =#
        jldopen(filename, "r") do file
            #= none:79 =#
            #= none:79 =# @test file["grid/Nx"] == 16
            #= none:82 =#
            #= none:82 =# @test file["boundary_conditions/fake"] == π
        end
        #= none:86 =#
        rm(filename)
        #= none:87 =#
    end
    #= none:89 =#
    return nothing
end
#= none:92 =#
function test_jld2_time_file_splitting(arch)
    #= none:92 =#
    #= none:93 =#
    grid = RectilinearGrid(arch, size = (16, 16, 16), extent = (1, 1, 1), halo = (1, 1, 1))
    #= none:94 =#
    model = NonhydrostaticModel(; grid, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:95 =#
    simulation = Simulation(model, Δt = 1, stop_iteration = 10)
    #= none:97 =#
    function fake_bc_init(file, model)
        #= none:97 =#
        #= none:98 =#
        file["boundary_conditions/fake"] = π
    end
    #= none:100 =#
    ow = JLD2OutputWriter(model, (; u = model.velocities.u); dir = ".", filename = "test", schedule = IterationInterval(1), init = fake_bc_init, including = [:grid], array_type = Array{Float64}, with_halos = true, file_splitting = TimeInterval(3seconds), overwrite_existing = true)
    #= none:111 =#
    push!(simulation.output_writers, ow)
    #= none:113 =#
    run!(simulation)
    #= none:115 =#
    for n = string.(1:3)
        #= none:116 =#
        filename = "test_part$(n).jld2"
        #= none:117 =#
        jldopen(filename, "r") do file
            #= none:119 =#
            #= none:119 =# @test file["grid/Nx"] == 16
            #= none:122 =#
            dimlength = length(file["timeseries/t"])
            #= none:123 =#
            #= none:123 =# @test dimlength == 3
            #= none:126 =#
            #= none:126 =# @test file["boundary_conditions/fake"] == π
        end
        #= none:130 =#
        rm(filename)
        #= none:131 =#
    end
    #= none:132 =#
    rm("test_part4.jld2")
    #= none:134 =#
    return nothing
end
#= none:137 =#
function test_jld2_time_averaging_of_horizontal_averages(model)
    #= none:137 =#
    #= none:139 =#
    model.clock.iteration = 0
    #= none:140 =#
    model.clock.time = 0.0
    #= none:142 =#
    (u, v, w) = model.velocities
    #= none:143 =#
    T = model.tracers.T
    #= none:145 =#
    u .= 1
    #= none:146 =#
    v .= 2
    #= none:147 =#
    w .= 0
    #= none:148 =#
    T .= 4
    #= none:150 =#
    Δt = 0.1
    #= none:151 =#
    simulation = Simulation(model, Δt = Δt, stop_iteration = 5)
    #= none:153 =#
    average_fluxes = (wu = Field(Average(w * u, dims = (1, 2))), uv = Field(Average(u * v, dims = (1, 2))), wT = Field(Average(w * T, dims = (1, 2))))
    #= none:157 =#
    simulation.output_writers[:fluxes] = JLD2OutputWriter(model, average_fluxes, schedule = AveragedTimeInterval(4Δt, window = 2Δt), dir = ".", with_halos = false, filename = "jld2_time_averaging_test.jld2", overwrite_existing = true)
    #= none:164 =#
    run!(simulation)
    #= none:166 =#
    test_file_name = "jld2_time_averaging_test.jld2"
    #= none:167 =#
    file = jldopen(test_file_name)
    #= none:170 =#
    wu = (file["timeseries/wu/4"])[1, 1, 3]
    #= none:171 =#
    uv = (file["timeseries/uv/4"])[1, 1, 3]
    #= none:172 =#
    wT = (file["timeseries/wT/4"])[1, 1, 3]
    #= none:174 =#
    close(file)
    #= none:176 =#
    rm(test_file_name)
    #= none:178 =#
    FT = eltype(model.grid)
    #= none:182 =#
    #= none:182 =# @test abs(wu) < eps(FT)
    #= none:183 =#
    #= none:183 =# @test abs(wT) < eps(FT)
    #= none:184 =#
    #= none:184 =# @test uv == FT(2)
    #= none:186 =#
    return nothing
end
#= none:189 =#
for arch = archs
    #= none:191 =#
    topo = (Periodic, Periodic, Bounded)
    #= none:192 =#
    grid = RectilinearGrid(arch, topology = topo, size = (4, 4, 4), extent = (1, 1, 1))
    #= none:193 =#
    background_u = BackgroundField(((x, y, z, t)->begin
                    #= none:193 =#
                    0
                end))
    #= none:194 =#
    model = NonhydrostaticModel(grid = grid, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S), background_fields = (u = background_u,))
    #= none:196 =#
    #= none:196 =# @testset "JLD2 output writer [$(typeof(arch))]" begin
            #= none:197 =#
            #= none:197 =# @info "  Testing JLD2 output writer [$(typeof(arch))]..."
            #= none:199 =#
            set!(model, u = ((x, y, z)->begin
                            #= none:199 =#
                            rand()
                        end), v = ((x, y, z)->begin
                            #= none:200 =#
                            rand()
                        end), w = ((x, y, z)->begin
                            #= none:201 =#
                            rand()
                        end))
            #= none:203 =#
            simulation = Simulation(model, Δt = 1.0, stop_iteration = 1)
            #= none:206 =#
            clock = model.clock
            #= none:207 =#
            α = 0.12
            #= none:208 =#
            test_function_field = FunctionField{Center, Center, Center}(((x, y, z, t, α)->begin
                            #= none:208 =#
                            α * t
                        end), grid; clock, parameters = α)
            #= none:209 =#
            function_and_background_fields = (; αt = test_function_field, background_u = model.background_fields.velocities.u)
            #= none:211 =#
            (u, v, w) = model.velocities
            #= none:212 =#
            operation_outputs = (u_op = 1u, v_op = 1v, w_op = 1w)
            #= none:214 =#
            vanilla_outputs = merge(model.velocities, function_and_background_fields, operation_outputs)
            #= none:216 =#
            simulation.output_writers[:velocities] = JLD2OutputWriter(model, vanilla_outputs, schedule = IterationInterval(1), dir = ".", filename = "vanilla_jld2_test", indices = (:, :, :), with_halos = false, overwrite_existing = true)
            #= none:224 =#
            simulation.output_writers[:sliced] = JLD2OutputWriter(model, model.velocities, schedule = TimeInterval(1), indices = (1:2, 1:4, :), with_halos = false, dir = ".", filename = "sliced_jld2_test", overwrite_existing = true)
            #= none:232 =#
            func_outputs = (u = (model->begin
                                #= none:232 =#
                                u
                            end), v = (model->begin
                                #= none:232 =#
                                v
                            end), w = (model->begin
                                #= none:232 =#
                                w
                            end))
            #= none:234 =#
            simulation.output_writers[:sliced_funcs] = JLD2OutputWriter(model, func_outputs, schedule = TimeInterval(1), indices = (1:2, 1:4, :), with_halos = false, dir = ".", filename = "sliced_funcs_jld2_test", overwrite_existing = true)
            #= none:243 =#
            simulation.output_writers[:sliced_func_fields] = JLD2OutputWriter(model, function_and_background_fields, schedule = TimeInterval(1), indices = (1:2, 1:4, :), with_halos = false, dir = ".", filename = "sliced_func_fields_jld2_test", overwrite_existing = true)
            #= none:253 =#
            u₀ = #= none:253 =# CUDA.@allowscalar(model.velocities.u[3, 3, 3])
            #= none:254 =#
            v₀ = #= none:254 =# CUDA.@allowscalar(model.velocities.v[3, 3, 3])
            #= none:255 =#
            w₀ = #= none:255 =# CUDA.@allowscalar(model.velocities.w[3, 3, 3])
            #= none:257 =#
            run!(simulation)
            #= none:263 =#
            file = jldopen("vanilla_jld2_test.jld2")
            #= none:266 =#
            u₁ = (file["timeseries/u/0"])[3, 3, 3]
            #= none:267 =#
            v₁ = (file["timeseries/v/0"])[3, 3, 3]
            #= none:268 =#
            w₁ = (file["timeseries/w/0"])[3, 3, 3]
            #= none:271 =#
            u₁_op = (file["timeseries/u_op/0"])[3, 3, 3]
            #= none:272 =#
            v₁_op = (file["timeseries/v_op/0"])[3, 3, 3]
            #= none:273 =#
            w₁_op = (file["timeseries/w_op/0"])[3, 3, 3]
            #= none:276 =#
            αt₀ = (file["timeseries/αt/0"])[3, 3, 3]
            #= none:277 =#
            αt₁ = (file["timeseries/αt/1"])[3, 3, 3]
            #= none:278 =#
            t₀ = file["timeseries/t/0"]
            #= none:279 =#
            t₁ = file["timeseries/t/1"]
            #= none:281 =#
            close(file)
            #= none:283 =#
            rm("vanilla_jld2_test.jld2")
            #= none:285 =#
            FT = typeof(u₁)
            #= none:287 =#
            #= none:287 =# @test FT(u₀) == u₁
            #= none:288 =#
            #= none:288 =# @test FT(v₀) == v₁
            #= none:289 =#
            #= none:289 =# @test FT(w₀) == w₁
            #= none:291 =#
            #= none:291 =# @test FT(u₀) == u₁_op
            #= none:292 =#
            #= none:292 =# @test FT(v₀) == v₁_op
            #= none:293 =#
            #= none:293 =# @test FT(w₀) == w₁_op
            #= none:295 =#
            #= none:295 =# @test FT(αt₀) == α * t₀
            #= none:296 =#
            #= none:296 =# @test FT(αt₁) == α * t₁
            #= none:302 =#
            function test_field_slicing(test_file_name, variables, sizes...)
                #= none:302 =#
                #= none:303 =#
                file = jldopen(test_file_name)
                #= none:305 =#
                for (i, variable) = enumerate(variables)
                    #= none:306 =#
                    var₁ = file["timeseries/$(variable)/0"]
                    #= none:307 =#
                    #= none:307 =# @test size(var₁) == sizes[i]
                    #= none:308 =#
                end
                #= none:310 =#
                close(file)
                #= none:311 =#
                rm(test_file_name)
            end
            #= none:314 =#
            test_field_slicing("sliced_jld2_test.jld2", ("u", "v", "w"), (2, 4, 4), (2, 4, 4), (2, 4, 5))
            #= none:315 =#
            test_field_slicing("sliced_funcs_jld2_test.jld2", ("u", "v", "w"), (4, 4, 4), (4, 4, 4), (4, 4, 5))
            #= none:316 =#
            test_field_slicing("sliced_func_fields_jld2_test.jld2", ("αt", "background_u"), (2, 4, 4), (2, 4, 4))
            #= none:322 =#
            test_jld2_size_file_splitting(arch)
            #= none:323 =#
            test_jld2_time_file_splitting(arch)
            #= none:329 =#
            test_jld2_time_averaging_of_horizontal_averages(model)
        end
    #= none:331 =#
end