
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using TimesDates: TimeDate
#= none:4 =#
using Dates: DateTime, Nanosecond, Millisecond
#= none:5 =#
using TimesDates: TimeDate
#= none:6 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:7 =#
using NCDatasets
#= none:8 =#
using Oceananigans: Clock
#= none:14 =#
function test_DateTime_netcdf_output(arch)
    #= none:14 =#
    #= none:15 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
    #= none:16 =#
    clock = Clock(time = DateTime(2021, 1, 1))
    #= none:17 =#
    model = NonhydrostaticModel(; grid, clock, timestepper = :QuasiAdamsBashforth2, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:20 =#
    Δt = 5days + 3hours + 44.123seconds
    #= none:21 =#
    simulation = Simulation(model; Δt, stop_time = DateTime(2021, 2, 1))
    #= none:23 =#
    filepath = "test_DateTime.nc"
    #= none:24 =#
    isfile(filepath) && rm(filepath)
    #= none:25 =#
    simulation.output_writers[:cal] = NetCDFOutputWriter(model, fields(model); filename = filepath, schedule = IterationInterval(1))
    #= none:29 =#
    run!(simulation)
    #= none:31 =#
    ds = NCDataset(filepath)
    #= none:32 =#
    #= none:32 =# @test (ds["time"]).attrib["units"] == "seconds since 2000-01-01 00:00:00"
    #= none:34 =#
    Nt = length(ds["time"])
    #= none:35 =#
    #= none:35 =# @test Nt == 8
    #= none:37 =#
    for n = 1:Nt - 1
        #= none:38 =#
        #= none:38 =# @test (ds["time"])[n] == DateTime(2021, 1, 1) + (n - 1) * Millisecond(1000Δt)
        #= none:39 =#
    end
    #= none:41 =#
    #= none:41 =# @test (ds["time"])[Nt] == DateTime(2021, 2, 1)
    #= none:43 =#
    close(ds)
    #= none:44 =#
    rm(filepath)
    #= none:46 =#
    return nothing
end
#= none:49 =#
function test_netcdf_size_file_splitting(arch)
    #= none:49 =#
    #= none:50 =#
    grid = RectilinearGrid(arch, size = (16, 16, 16), extent = (1, 1, 1), halo = (1, 1, 1))
    #= none:51 =#
    model = NonhydrostaticModel(; grid, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:52 =#
    simulation = Simulation(model, Δt = 1, stop_iteration = 10)
    #= none:54 =#
    fake_attributes = Dict("fake_attribute" => "fake_attribute")
    #= none:56 =#
    ow = NetCDFOutputWriter(model, (; u = model.velocities.u); dir = ".", filename = "test.nc", schedule = IterationInterval(1), array_type = Array{Float64}, with_halos = true, global_attributes = fake_attributes, file_splitting = FileSizeLimit(200KiB), overwrite_existing = true)
    #= none:66 =#
    push!(simulation.output_writers, ow)
    #= none:69 =#
    run!(simulation)
    #= none:72 =#
    #= none:72 =# @test filesize("test_part1.nc") > 200KiB
    #= none:73 =#
    #= none:73 =# @test filesize("test_part2.nc") > 200KiB
    #= none:74 =#
    #= none:74 =# @test filesize("test_part3.nc") < 200KiB
    #= none:75 =#
    #= none:75 =# @test !(isfile("test_part4.nc"))
    #= none:77 =#
    for n = string.(1:3)
        #= none:78 =#
        filename = "test_part$(n).nc"
        #= none:79 =#
        ds = NCDataset(filename, "r")
        #= none:80 =#
        dimlength = length(keys(ds.dim))
        #= none:82 =#
        #= none:82 =# @test dimlength == 7
        #= none:84 =#
        #= none:84 =# @test ds.attrib["fake_attribute"] == "fake_attribute"
        #= none:87 =#
        close(ds)
        #= none:88 =#
        rm(filename)
        #= none:89 =#
    end
    #= none:91 =#
    return nothing
end
#= none:94 =#
function test_netcdf_time_file_splitting(arch)
    #= none:94 =#
    #= none:95 =#
    grid = RectilinearGrid(arch, size = (16, 16, 16), extent = (1, 1, 1), halo = (1, 1, 1))
    #= none:96 =#
    model = NonhydrostaticModel(; grid, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:97 =#
    simulation = Simulation(model, Δt = 1, stop_iteration = 12seconds)
    #= none:99 =#
    fake_attributes = Dict("fake_attribute" => "fake_attribute")
    #= none:101 =#
    ow = NetCDFOutputWriter(model, (; u = model.velocities.u); dir = ".", filename = "test.nc", schedule = IterationInterval(2), array_type = Array{Float64}, with_halos = true, global_attributes = fake_attributes, file_splitting = TimeInterval(4seconds), overwrite_existing = true)
    #= none:111 =#
    push!(simulation.output_writers, ow)
    #= none:113 =#
    run!(simulation)
    #= none:115 =#
    for n = string.(1:3)
        #= none:116 =#
        filename = "test_part$(n).nc"
        #= none:117 =#
        ds = NCDataset(filename, "r")
        #= none:118 =#
        dimlength = length(ds["time"])
        #= none:120 =#
        #= none:120 =# @test dimlength == 2
        #= none:122 =#
        #= none:122 =# @test ds.attrib["fake_attribute"] == "fake_attribute"
        #= none:125 =#
        close(ds)
        #= none:126 =#
        rm(filename)
        #= none:127 =#
    end
    #= none:128 =#
    rm("test_part4.nc")
    #= none:130 =#
    return nothing
end
#= none:133 =#
function test_TimeDate_netcdf_output(arch)
    #= none:133 =#
    #= none:134 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
    #= none:135 =#
    clock = Clock(time = TimeDate(2021, 1, 1))
    #= none:136 =#
    model = NonhydrostaticModel(; grid, clock, timestepper = :QuasiAdamsBashforth2, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:139 =#
    Δt = 5days + 3hours + 44.123seconds
    #= none:140 =#
    simulation = Simulation(model, Δt = Δt, stop_time = TimeDate(2021, 2, 1))
    #= none:142 =#
    filepath = "test_TimeDate.nc"
    #= none:143 =#
    isfile(filepath) && rm(filepath)
    #= none:144 =#
    simulation.output_writers[:cal] = NetCDFOutputWriter(model, fields(model); filename = filepath, schedule = IterationInterval(1))
    #= none:148 =#
    run!(simulation)
    #= none:150 =#
    ds = NCDataset(filepath)
    #= none:151 =#
    #= none:151 =# @test (ds["time"]).attrib["units"] == "seconds since 2000-01-01 00:00:00"
    #= none:153 =#
    Nt = length(ds["time"])
    #= none:154 =#
    #= none:154 =# @test Nt == 8
    #= none:156 =#
    for n = 1:Nt - 1
        #= none:157 =#
        #= none:157 =# @test (ds["time"])[n] == DateTime(2021, 1, 1) + (n - 1) * Millisecond(1000Δt)
        #= none:158 =#
    end
    #= none:160 =#
    #= none:160 =# @test (ds["time"])[Nt] == DateTime(2021, 2, 1)
    #= none:162 =#
    close(ds)
    #= none:163 =#
    rm(filepath)
    #= none:165 =#
    return nothing
end
#= none:168 =#
function test_thermal_bubble_netcdf_output(arch)
    #= none:168 =#
    #= none:169 =#
    (Nx, Ny, Nz) = (16, 16, 16)
    #= none:170 =#
    (Lx, Ly, Lz) = (100, 100, 100)
    #= none:172 =#
    topo = (Periodic, Periodic, Bounded)
    #= none:173 =#
    grid = RectilinearGrid(arch, topology = topo, size = (Nx, Ny, Nz), extent = (Lx, Ly, Lz))
    #= none:174 =#
    closure = ScalarDiffusivity(ν = 0.04, κ = 0.04)
    #= none:175 =#
    model = NonhydrostaticModel(; grid, closure, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:176 =#
    simulation = Simulation(model, Δt = 6, stop_iteration = 10)
    #= none:180 =#
    (i1, i2) = (round(Int, Nx / 4), round(Int, (3Nx) / 4))
    #= none:181 =#
    (j1, j2) = (round(Int, Ny / 4), round(Int, (3Ny) / 4))
    #= none:182 =#
    (k1, k2) = (round(Int, Nz / 4), round(Int, (3Nz) / 4))
    #= none:183 =#
    view(model.tracers.T, i1:i2, j1:j2, k1:k2) .+= 0.01
    #= none:185 =#
    outputs = Dict("v" => model.velocities.v, "u" => model.velocities.u, "w" => model.velocities.w, "T" => model.tracers.T, "S" => model.tracers.S)
    #= none:191 =#
    nc_filepath = "test_dump_$(typeof(arch)).nc"
    #= none:192 =#
    isfile(nc_filepath) && rm(nc_filepath)
    #= none:193 =#
    nc_writer = NetCDFOutputWriter(model, outputs, filename = nc_filepath, schedule = IterationInterval(10), verbose = true)
    #= none:194 =#
    push!(simulation.output_writers, nc_writer)
    #= none:196 =#
    i_slice = 1:10
    #= none:197 =#
    j_slice = 13
    #= none:198 =#
    k_slice = 9:11
    #= none:199 =#
    indices = (i_slice, j_slice, k_slice)
    #= none:200 =#
    j_slice = j_slice:j_slice
    #= none:202 =#
    nc_sliced_filepath = "test_dump_sliced_$(typeof(arch)).nc"
    #= none:203 =#
    isfile(nc_sliced_filepath) && rm(nc_sliced_filepath)
    #= none:204 =#
    nc_sliced_writer = NetCDFOutputWriter(model, outputs, filename = nc_sliced_filepath, schedule = IterationInterval(10), array_type = Array{Float32}, indices = indices, verbose = true)
    #= none:211 =#
    push!(simulation.output_writers, nc_sliced_writer)
    #= none:213 =#
    run!(simulation)
    #= none:215 =#
    ds3 = Dataset(nc_filepath)
    #= none:217 =#
    #= none:217 =# @test haskey(ds3.attrib, "date") && !(isnothing(ds3.attrib["date"]))
    #= none:218 =#
    #= none:218 =# @test haskey(ds3.attrib, "Julia") && !(isnothing(ds3.attrib["Julia"]))
    #= none:219 =#
    #= none:219 =# @test haskey(ds3.attrib, "Oceananigans") && !(isnothing(ds3.attrib["Oceananigans"]))
    #= none:220 =#
    #= none:220 =# @test haskey(ds3.attrib, "schedule") && ds3.attrib["schedule"] == "IterationInterval"
    #= none:221 =#
    #= none:221 =# @test haskey(ds3.attrib, "interval") && ds3.attrib["interval"] == 10
    #= none:222 =#
    #= none:222 =# @test haskey(ds3.attrib, "output iteration interval") && !(isnothing(ds3.attrib["output iteration interval"]))
    #= none:224 =#
    #= none:224 =# @test eltype(ds3["time"]) == eltype(model.clock.time)
    #= none:226 =#
    #= none:226 =# @test eltype(ds3["xC"]) == Float64
    #= none:227 =#
    #= none:227 =# @test eltype(ds3["xF"]) == Float64
    #= none:228 =#
    #= none:228 =# @test eltype(ds3["yC"]) == Float64
    #= none:229 =#
    #= none:229 =# @test eltype(ds3["yF"]) == Float64
    #= none:230 =#
    #= none:230 =# @test eltype(ds3["zC"]) == Float64
    #= none:231 =#
    #= none:231 =# @test eltype(ds3["zF"]) == Float64
    #= none:233 =#
    #= none:233 =# @test length(ds3["xC"]) == Nx
    #= none:234 =#
    #= none:234 =# @test length(ds3["yC"]) == Ny
    #= none:235 =#
    #= none:235 =# @test length(ds3["zC"]) == Nz
    #= none:236 =#
    #= none:236 =# @test length(ds3["xF"]) == Nx
    #= none:237 =#
    #= none:237 =# @test length(ds3["yF"]) == Ny
    #= none:238 =#
    #= none:238 =# @test length(ds3["zF"]) == Nz + 1
    #= none:240 =#
    #= none:240 =# @test (ds3["xC"])[1] == grid.xᶜᵃᵃ[1]
    #= none:241 =#
    #= none:241 =# @test (ds3["xF"])[1] == grid.xᶠᵃᵃ[1]
    #= none:242 =#
    #= none:242 =# @test (ds3["yC"])[1] == grid.yᵃᶜᵃ[1]
    #= none:243 =#
    #= none:243 =# @test (ds3["yF"])[1] == grid.yᵃᶠᵃ[1]
    #= none:244 =#
    #= none:244 =# @test (ds3["zC"])[1] == grid.zᵃᵃᶜ[1]
    #= none:245 =#
    #= none:245 =# @test (ds3["zF"])[1] == grid.zᵃᵃᶠ[1]
    #= none:247 =#
    #= none:247 =# @test (ds3["xC"])[end] == grid.xᶜᵃᵃ[Nx]
    #= none:248 =#
    #= none:248 =# @test (ds3["xF"])[end] == grid.xᶠᵃᵃ[Nx]
    #= none:249 =#
    #= none:249 =# @test (ds3["yC"])[end] == grid.yᵃᶜᵃ[Ny]
    #= none:250 =#
    #= none:250 =# @test (ds3["yF"])[end] == grid.yᵃᶠᵃ[Ny]
    #= none:251 =#
    #= none:251 =# @test (ds3["zC"])[end] == grid.zᵃᵃᶜ[Nz]
    #= none:252 =#
    #= none:252 =# @test (ds3["zF"])[end] == grid.zᵃᵃᶠ[Nz + 1]
    #= none:254 =#
    #= none:254 =# @test eltype(ds3["u"]) == Float64
    #= none:255 =#
    #= none:255 =# @test eltype(ds3["v"]) == Float64
    #= none:256 =#
    #= none:256 =# @test eltype(ds3["w"]) == Float64
    #= none:257 =#
    #= none:257 =# @test eltype(ds3["T"]) == Float64
    #= none:258 =#
    #= none:258 =# @test eltype(ds3["S"]) == Float64
    #= none:260 =#
    u = (ds3["u"])[:, :, :, end]
    #= none:261 =#
    v = (ds3["v"])[:, :, :, end]
    #= none:262 =#
    w = (ds3["w"])[:, :, :, end]
    #= none:263 =#
    T = (ds3["T"])[:, :, :, end]
    #= none:264 =#
    S = (ds3["S"])[:, :, :, end]
    #= none:266 =#
    close(ds3)
    #= none:268 =#
    #= none:268 =# @test all(u .≈ Array(interior(model.velocities.u)))
    #= none:269 =#
    #= none:269 =# @test all(v .≈ Array(interior(model.velocities.v)))
    #= none:270 =#
    #= none:270 =# @test all(w .≈ Array(interior(model.velocities.w)))
    #= none:271 =#
    #= none:271 =# @test all(T .≈ Array(interior(model.tracers.T)))
    #= none:272 =#
    #= none:272 =# @test all(S .≈ Array(interior(model.tracers.S)))
    #= none:274 =#
    ds2 = Dataset(nc_sliced_filepath)
    #= none:276 =#
    #= none:276 =# @test haskey(ds2.attrib, "date") && !(isnothing(ds2.attrib["date"]))
    #= none:277 =#
    #= none:277 =# @test haskey(ds2.attrib, "Julia") && !(isnothing(ds2.attrib["Julia"]))
    #= none:278 =#
    #= none:278 =# @test haskey(ds2.attrib, "Oceananigans") && !(isnothing(ds2.attrib["Oceananigans"]))
    #= none:279 =#
    #= none:279 =# @test haskey(ds2.attrib, "schedule") && ds2.attrib["schedule"] == "IterationInterval"
    #= none:280 =#
    #= none:280 =# @test haskey(ds2.attrib, "interval") && ds2.attrib["interval"] == 10
    #= none:281 =#
    #= none:281 =# @test haskey(ds2.attrib, "output iteration interval") && !(isnothing(ds2.attrib["output iteration interval"]))
    #= none:283 =#
    #= none:283 =# @test eltype(ds2["time"]) == eltype(model.clock.time)
    #= none:285 =#
    #= none:285 =# @test eltype(ds2["xC"]) == Float32
    #= none:286 =#
    #= none:286 =# @test eltype(ds2["xF"]) == Float32
    #= none:287 =#
    #= none:287 =# @test eltype(ds2["yC"]) == Float32
    #= none:288 =#
    #= none:288 =# @test eltype(ds2["yF"]) == Float32
    #= none:289 =#
    #= none:289 =# @test eltype(ds2["zC"]) == Float32
    #= none:290 =#
    #= none:290 =# @test eltype(ds2["zF"]) == Float32
    #= none:292 =#
    #= none:292 =# @test length(ds2["xC"]) == length(i_slice)
    #= none:293 =#
    #= none:293 =# @test length(ds2["xF"]) == length(i_slice)
    #= none:294 =#
    #= none:294 =# @test length(ds2["yC"]) == length(j_slice)
    #= none:295 =#
    #= none:295 =# @test length(ds2["yF"]) == length(j_slice)
    #= none:296 =#
    #= none:296 =# @test length(ds2["zC"]) == length(k_slice)
    #= none:297 =#
    #= none:297 =# @test length(ds2["zF"]) == length(k_slice)
    #= none:299 =#
    #= none:299 =# @test (ds2["xC"])[1] == grid.xᶜᵃᵃ[i_slice[1]]
    #= none:300 =#
    #= none:300 =# @test (ds2["xF"])[1] == grid.xᶠᵃᵃ[i_slice[1]]
    #= none:301 =#
    #= none:301 =# @test (ds2["yC"])[1] == grid.yᵃᶜᵃ[j_slice[1]]
    #= none:302 =#
    #= none:302 =# @test (ds2["yF"])[1] == grid.yᵃᶠᵃ[j_slice[1]]
    #= none:303 =#
    #= none:303 =# @test (ds2["zC"])[1] == grid.zᵃᵃᶜ[k_slice[1]]
    #= none:304 =#
    #= none:304 =# @test (ds2["zF"])[1] == grid.zᵃᵃᶠ[k_slice[1]]
    #= none:306 =#
    #= none:306 =# @test (ds2["xC"])[end] == grid.xᶜᵃᵃ[i_slice[end]]
    #= none:307 =#
    #= none:307 =# @test (ds2["xF"])[end] == grid.xᶠᵃᵃ[i_slice[end]]
    #= none:308 =#
    #= none:308 =# @test (ds2["yC"])[end] == grid.yᵃᶜᵃ[j_slice[end]]
    #= none:309 =#
    #= none:309 =# @test (ds2["yF"])[end] == grid.yᵃᶠᵃ[j_slice[end]]
    #= none:310 =#
    #= none:310 =# @test (ds2["zC"])[end] == grid.zᵃᵃᶜ[k_slice[end]]
    #= none:311 =#
    #= none:311 =# @test (ds2["zF"])[end] == grid.zᵃᵃᶠ[k_slice[end]]
    #= none:313 =#
    #= none:313 =# @test eltype(ds2["u"]) == Float32
    #= none:314 =#
    #= none:314 =# @test eltype(ds2["v"]) == Float32
    #= none:315 =#
    #= none:315 =# @test eltype(ds2["w"]) == Float32
    #= none:316 =#
    #= none:316 =# @test eltype(ds2["T"]) == Float32
    #= none:317 =#
    #= none:317 =# @test eltype(ds2["S"]) == Float32
    #= none:319 =#
    u_sliced = (ds2["u"])[:, :, :, end]
    #= none:320 =#
    v_sliced = (ds2["v"])[:, :, :, end]
    #= none:321 =#
    w_sliced = (ds2["w"])[:, :, :, end]
    #= none:322 =#
    T_sliced = (ds2["T"])[:, :, :, end]
    #= none:323 =#
    S_sliced = (ds2["S"])[:, :, :, end]
    #= none:325 =#
    close(ds2)
    #= none:327 =#
    #= none:327 =# @test all(u_sliced .≈ (Array(interior(model.velocities.u)))[i_slice, j_slice, k_slice])
    #= none:328 =#
    #= none:328 =# @test all(v_sliced .≈ (Array(interior(model.velocities.v)))[i_slice, j_slice, k_slice])
    #= none:329 =#
    #= none:329 =# @test all(w_sliced .≈ (Array(interior(model.velocities.w)))[i_slice, j_slice, k_slice])
    #= none:330 =#
    #= none:330 =# @test all(T_sliced .≈ (Array(interior(model.tracers.T)))[i_slice, j_slice, k_slice])
    #= none:331 =#
    #= none:331 =# @test all(S_sliced .≈ (Array(interior(model.tracers.S)))[i_slice, j_slice, k_slice])
    #= none:333 =#
    rm(nc_filepath)
    #= none:334 =#
    rm(nc_sliced_filepath)
    #= none:336 =#
    return nothing
end
#= none:339 =#
function test_thermal_bubble_netcdf_output_with_halos(arch)
    #= none:339 =#
    #= none:340 =#
    (Nx, Ny, Nz) = (16, 16, 16)
    #= none:341 =#
    (Lx, Ly, Lz) = (100, 100, 100)
    #= none:343 =#
    topo = (Periodic, Periodic, Bounded)
    #= none:344 =#
    grid = RectilinearGrid(arch, topology = topo, size = (Nx, Ny, Nz), extent = (Lx, Ly, Lz))
    #= none:345 =#
    closure = ScalarDiffusivity(ν = 0.04, κ = 0.04)
    #= none:346 =#
    model = NonhydrostaticModel(; grid, closure, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:347 =#
    simulation = Simulation(model, Δt = 6, stop_iteration = 10)
    #= none:351 =#
    (i1, i2) = (round(Int, Nx / 4), round(Int, (3Nx) / 4))
    #= none:352 =#
    (j1, j2) = (round(Int, Ny / 4), round(Int, (3Ny) / 4))
    #= none:353 =#
    (k1, k2) = (round(Int, Nz / 4), round(Int, (3Nz) / 4))
    #= none:354 =#
    view(model.tracers.T, i1:i2, j1:j2, k1:k2) .+= 0.01
    #= none:356 =#
    nc_filepath = "test_dump_with_halos_$(typeof(arch)).nc"
    #= none:358 =#
    nc_writer = NetCDFOutputWriter(model, merge(model.velocities, model.tracers), filename = nc_filepath, schedule = IterationInterval(10), with_halos = true)
    #= none:363 =#
    push!(simulation.output_writers, nc_writer)
    #= none:365 =#
    run!(simulation)
    #= none:367 =#
    ds = Dataset(nc_filepath)
    #= none:369 =#
    #= none:369 =# @test haskey(ds.attrib, "date") && !(isnothing(ds.attrib["date"]))
    #= none:370 =#
    #= none:370 =# @test haskey(ds.attrib, "Julia") && !(isnothing(ds.attrib["Julia"]))
    #= none:371 =#
    #= none:371 =# @test haskey(ds.attrib, "Oceananigans") && !(isnothing(ds.attrib["Oceananigans"]))
    #= none:372 =#
    #= none:372 =# @test haskey(ds.attrib, "schedule") && ds.attrib["schedule"] == "IterationInterval"
    #= none:373 =#
    #= none:373 =# @test haskey(ds.attrib, "interval") && ds.attrib["interval"] == 10
    #= none:374 =#
    #= none:374 =# @test haskey(ds.attrib, "output iteration interval") && !(isnothing(ds.attrib["output iteration interval"]))
    #= none:376 =#
    #= none:376 =# @test eltype(ds["time"]) == eltype(model.clock.time)
    #= none:379 =#
    #= none:379 =# @test eltype(ds["xC"]) == Float64
    #= none:380 =#
    #= none:380 =# @test eltype(ds["xF"]) == Float64
    #= none:381 =#
    #= none:381 =# @test eltype(ds["yC"]) == Float64
    #= none:382 =#
    #= none:382 =# @test eltype(ds["yF"]) == Float64
    #= none:383 =#
    #= none:383 =# @test eltype(ds["zC"]) == Float64
    #= none:384 =#
    #= none:384 =# @test eltype(ds["zF"]) == Float64
    #= none:386 =#
    (Hx, Hy, Hz) = (grid.Hx, grid.Hy, grid.Hz)
    #= none:387 =#
    #= none:387 =# @test length(ds["xC"]) == Nx + 2Hx
    #= none:388 =#
    #= none:388 =# @test length(ds["yC"]) == Ny + 2Hy
    #= none:389 =#
    #= none:389 =# @test length(ds["zC"]) == Nz + 2Hz
    #= none:390 =#
    #= none:390 =# @test length(ds["xF"]) == Nx + 2Hx
    #= none:391 =#
    #= none:391 =# @test length(ds["yF"]) == Ny + 2Hy
    #= none:392 =#
    #= none:392 =# @test length(ds["zF"]) == Nz + 2Hz + 1
    #= none:394 =#
    #= none:394 =# @test (ds["xC"])[1] == grid.xᶜᵃᵃ[1 - Hx]
    #= none:395 =#
    #= none:395 =# @test (ds["xF"])[1] == grid.xᶠᵃᵃ[1 - Hx]
    #= none:396 =#
    #= none:396 =# @test (ds["yC"])[1] == grid.yᵃᶜᵃ[1 - Hy]
    #= none:397 =#
    #= none:397 =# @test (ds["yF"])[1] == grid.yᵃᶠᵃ[1 - Hy]
    #= none:398 =#
    #= none:398 =# @test (ds["zC"])[1] == grid.zᵃᵃᶜ[1 - Hz]
    #= none:399 =#
    #= none:399 =# @test (ds["zF"])[1] == grid.zᵃᵃᶠ[1 - Hz]
    #= none:401 =#
    #= none:401 =# @test (ds["xC"])[end] == grid.xᶜᵃᵃ[Nx + Hx]
    #= none:402 =#
    #= none:402 =# @test (ds["xF"])[end] == grid.xᶠᵃᵃ[Nx + Hx]
    #= none:403 =#
    #= none:403 =# @test (ds["yC"])[end] == grid.yᵃᶜᵃ[Ny + Hy]
    #= none:404 =#
    #= none:404 =# @test (ds["yF"])[end] == grid.yᵃᶠᵃ[Ny + Hy]
    #= none:405 =#
    #= none:405 =# @test (ds["zC"])[end] == grid.zᵃᵃᶜ[Nz + Hz]
    #= none:406 =#
    #= none:406 =# @test (ds["zF"])[end] == grid.zᵃᵃᶠ[Nz + Hz + 1]
    #= none:408 =#
    #= none:408 =# @test eltype(ds["u"]) == Float64
    #= none:409 =#
    #= none:409 =# @test eltype(ds["v"]) == Float64
    #= none:410 =#
    #= none:410 =# @test eltype(ds["w"]) == Float64
    #= none:411 =#
    #= none:411 =# @test eltype(ds["T"]) == Float64
    #= none:412 =#
    #= none:412 =# @test eltype(ds["S"]) == Float64
    #= none:414 =#
    u = (ds["u"])[:, :, :, end]
    #= none:415 =#
    v = (ds["v"])[:, :, :, end]
    #= none:416 =#
    w = (ds["w"])[:, :, :, end]
    #= none:417 =#
    T = (ds["T"])[:, :, :, end]
    #= none:418 =#
    S = (ds["S"])[:, :, :, end]
    #= none:420 =#
    close(ds)
    #= none:422 =#
    #= none:422 =# @test all(u .≈ Array(model.velocities.u.data.parent))
    #= none:423 =#
    #= none:423 =# @test all(v .≈ Array(model.velocities.v.data.parent))
    #= none:424 =#
    #= none:424 =# @test all(w .≈ Array(model.velocities.w.data.parent))
    #= none:425 =#
    #= none:425 =# @test all(T .≈ Array(model.tracers.T.data.parent))
    #= none:426 =#
    #= none:426 =# @test all(S .≈ Array(model.tracers.S.data.parent))
    #= none:428 =#
    rm(nc_filepath)
    #= none:430 =#
    return nothing
end
#= none:433 =#
function test_netcdf_function_output(arch)
    #= none:433 =#
    #= none:434 =#
    Nx = (Ny = (Nz = (N = 16)))
    #= none:435 =#
    L = 1
    #= none:436 =#
    Δt = 1.25
    #= none:437 =#
    iters = 3
    #= none:439 =#
    grid = RectilinearGrid(arch, size = (Nx, Ny, Nz), extent = (L, 2L, 3L))
    #= none:440 =#
    model = NonhydrostaticModel(; grid, timestepper = :QuasiAdamsBashforth2, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:443 =#
    simulation = Simulation(model, Δt = Δt, stop_iteration = iters)
    #= none:444 =#
    grid = model.grid
    #= none:447 =#
    f(model) = begin
            #= none:447 =#
            model.clock.time ^ 2
        end
    #= none:449 =#
    g(model) = begin
            #= none:449 =#
            model.clock.time .* exp.(znodes(grid, Center()))
        end
    #= none:451 =#
    (xC, yF) = (xnodes(grid, Center()), ynodes(grid, Face()))
    #= none:453 =#
    XC = [xC[i] for i = 1:Nx, j = 1:Ny]
    #= none:454 =#
    YF = [yF[j] for i = 1:Nx, j = 1:Ny]
    #= none:456 =#
    h(model) = begin
            #= none:456 =#
            #= none:456 =# @__dot__ model.clock.time * sin(XC) * cos(YF)
        end
    #= none:458 =#
    outputs = (scalar = f, profile = g, slice = h)
    #= none:459 =#
    dims = (scalar = (), profile = ("zC",), slice = ("xC", "yC"))
    #= none:461 =#
    output_attributes = (scalar = (long_name = "Some scalar", units = "bananas"), profile = (long_name = "Some vertical profile", units = "watermelons"), slice = (long_name = "Some slice", units = "mushrooms"))
    #= none:467 =#
    global_attributes = (location = "Bay of Fundy", onions = 7)
    #= none:469 =#
    nc_filepath = "test_function_outputs_$(typeof(arch)).nc"
    #= none:471 =#
    simulation.output_writers[:food] = NetCDFOutputWriter(model, outputs; global_attributes, output_attributes, filename = nc_filepath, schedule = TimeInterval(Δt), dimensions = dims, array_type = Array{Float64}, verbose = true)
    #= none:479 =#
    run!(simulation)
    #= none:481 =#
    ds = Dataset(nc_filepath, "r")
    #= none:483 =#
    #= none:483 =# @test haskey(ds.attrib, "date") && !(isnothing(ds.attrib["date"]))
    #= none:484 =#
    #= none:484 =# @test haskey(ds.attrib, "Julia") && !(isnothing(ds.attrib["Julia"]))
    #= none:485 =#
    #= none:485 =# @test haskey(ds.attrib, "Oceananigans") && !(isnothing(ds.attrib["Oceananigans"]))
    #= none:486 =#
    #= none:486 =# @test haskey(ds.attrib, "schedule") && !(isnothing(ds.attrib["schedule"]))
    #= none:487 =#
    #= none:487 =# @test haskey(ds.attrib, "interval") && !(isnothing(ds.attrib["interval"]))
    #= none:488 =#
    #= none:488 =# @test haskey(ds.attrib, "output time interval") && !(isnothing(ds.attrib["output time interval"]))
    #= none:490 =#
    #= none:490 =# @test eltype(ds["time"]) == eltype(model.clock.time)
    #= none:492 =#
    #= none:492 =# @test eltype(ds["xC"]) == Float64
    #= none:493 =#
    #= none:493 =# @test eltype(ds["xF"]) == Float64
    #= none:494 =#
    #= none:494 =# @test eltype(ds["yC"]) == Float64
    #= none:495 =#
    #= none:495 =# @test eltype(ds["yF"]) == Float64
    #= none:496 =#
    #= none:496 =# @test eltype(ds["zC"]) == Float64
    #= none:497 =#
    #= none:497 =# @test eltype(ds["zF"]) == Float64
    #= none:499 =#
    #= none:499 =# @test length(ds["xC"]) == N
    #= none:500 =#
    #= none:500 =# @test length(ds["yC"]) == N
    #= none:501 =#
    #= none:501 =# @test length(ds["zC"]) == N
    #= none:502 =#
    #= none:502 =# @test length(ds["xF"]) == N
    #= none:503 =#
    #= none:503 =# @test length(ds["yF"]) == N
    #= none:504 =#
    #= none:504 =# @test length(ds["zF"]) == N + 1
    #= none:506 =#
    #= none:506 =# @test (ds["xC"])[1] == grid.xᶜᵃᵃ[1]
    #= none:507 =#
    #= none:507 =# @test (ds["xF"])[1] == grid.xᶠᵃᵃ[1]
    #= none:508 =#
    #= none:508 =# @test (ds["yC"])[1] == grid.yᵃᶜᵃ[1]
    #= none:509 =#
    #= none:509 =# @test (ds["yF"])[1] == grid.yᵃᶠᵃ[1]
    #= none:510 =#
    #= none:510 =# @test (ds["zC"])[1] == grid.zᵃᵃᶜ[1]
    #= none:511 =#
    #= none:511 =# @test (ds["zF"])[1] == grid.zᵃᵃᶠ[1]
    #= none:513 =#
    #= none:513 =# @test (ds["xC"])[end] == grid.xᶜᵃᵃ[N]
    #= none:514 =#
    #= none:514 =# @test (ds["yC"])[end] == grid.yᵃᶜᵃ[N]
    #= none:515 =#
    #= none:515 =# @test (ds["zC"])[end] == grid.zᵃᵃᶜ[N]
    #= none:516 =#
    #= none:516 =# @test (ds["xF"])[end] == grid.xᶠᵃᵃ[N]
    #= none:517 =#
    #= none:517 =# @test (ds["yF"])[end] == grid.yᵃᶠᵃ[N]
    #= none:518 =#
    #= none:518 =# @test (ds["zF"])[end] == grid.zᵃᵃᶠ[N + 1]
    #= none:520 =#
    #= none:520 =# @test ds.attrib["location"] == "Bay of Fundy"
    #= none:521 =#
    #= none:521 =# @test ds.attrib["onions"] == 7
    #= none:523 =#
    #= none:523 =# @test eltype(ds["scalar"]) == Float64
    #= none:524 =#
    #= none:524 =# @test eltype(ds["profile"]) == Float64
    #= none:525 =#
    #= none:525 =# @test eltype(ds["slice"]) == Float64
    #= none:527 =#
    #= none:527 =# @test length(ds["time"]) == iters + 1
    #= none:528 =#
    #= none:528 =# @test (ds["time"])[:] == [n * Δt for n = 0:iters]
    #= none:530 =#
    #= none:530 =# @test length(ds["scalar"]) == iters + 1
    #= none:531 =#
    #= none:531 =# @test (ds["scalar"]).attrib["long_name"] == "Some scalar"
    #= none:532 =#
    #= none:532 =# @test (ds["scalar"]).attrib["units"] == "bananas"
    #= none:533 =#
    #= none:533 =# @test (ds["scalar"])[:] == [(n * Δt) ^ 2 for n = 0:iters]
    #= none:534 =#
    #= none:534 =# @test dimnames(ds["scalar"]) == ("time",)
    #= none:536 =#
    #= none:536 =# @test (ds["profile"]).attrib["long_name"] == "Some vertical profile"
    #= none:537 =#
    #= none:537 =# @test (ds["profile"]).attrib["units"] == "watermelons"
    #= none:538 =#
    #= none:538 =# @test size(ds["profile"]) == (N, iters + 1)
    #= none:539 =#
    #= none:539 =# @test dimnames(ds["profile"]) == ("zC", "time")
    #= none:541 =#
    for n = 0:iters
        #= none:542 =#
        #= none:542 =# @test (ds["profile"])[:, n + 1] == (n * Δt) .* exp.(znodes(grid, Center()))
        #= none:543 =#
    end
    #= none:545 =#
    #= none:545 =# @test (ds["slice"]).attrib["long_name"] == "Some slice"
    #= none:546 =#
    #= none:546 =# @test (ds["slice"]).attrib["units"] == "mushrooms"
    #= none:547 =#
    #= none:547 =# @test size(ds["slice"]) == (N, N, iters + 1)
    #= none:548 =#
    #= none:548 =# @test dimnames(ds["slice"]) == ("xC", "yC", "time")
    #= none:550 =#
    for n = 0:iters
        #= none:551 =#
        #= none:551 =# @test (ds["slice"])[:, :, n + 1] == ((n * Δt) .* sin.(XC)) .* cos.(YF)
        #= none:552 =#
    end
    #= none:554 =#
    close(ds)
    #= none:560 =#
    iters += 1
    #= none:561 =#
    simulation = Simulation(model, Δt = Δt, stop_iteration = iters)
    #= none:563 =#
    simulation.output_writers[:food] = NetCDFOutputWriter(model, outputs; global_attributes, output_attributes, filename = nc_filepath, overwrite_existing = false, schedule = IterationInterval(1), array_type = Array{Float64}, dimensions = dims, verbose = true)
    #= none:572 =#
    run!(simulation)
    #= none:574 =#
    ds = Dataset(nc_filepath, "r")
    #= none:576 =#
    #= none:576 =# @test length(ds["time"]) == iters + 1
    #= none:577 =#
    #= none:577 =# @test length(ds["scalar"]) == iters + 1
    #= none:578 =#
    #= none:578 =# @test size(ds["profile"]) == (N, iters + 1)
    #= none:579 =#
    #= none:579 =# @test size(ds["slice"]) == (N, N, iters + 1)
    #= none:581 =#
    #= none:581 =# @test (ds["time"])[:] == [n * Δt for n = 0:iters]
    #= none:582 =#
    #= none:582 =# @test (ds["scalar"])[:] == [(n * Δt) ^ 2 for n = 0:iters]
    #= none:584 =#
    for n = 0:iters
        #= none:585 =#
        #= none:585 =# @test (ds["profile"])[:, n + 1] ≈ (n * Δt) .* exp.(znodes(grid, Center()))
        #= none:586 =#
        #= none:586 =# @test (ds["slice"])[:, :, n + 1] ≈ (n * Δt) .* (sin.(XC) .* cos.(YF))
        #= none:587 =#
    end
    #= none:589 =#
    close(ds)
    #= none:591 =#
    rm(nc_filepath)
    #= none:593 =#
    return nothing
end
#= none:596 =#
function test_netcdf_spatial_average(arch)
    #= none:596 =#
    #= none:597 =#
    topo = (Periodic, Periodic, Periodic)
    #= none:598 =#
    domain = (x = (0, 1), y = (0, 1), z = (0, 1))
    #= none:599 =#
    grid = RectilinearGrid(arch, topology = topo, size = (4, 4, 4); domain...)
    #= none:601 =#
    model = NonhydrostaticModel(grid = grid, timestepper = :RungeKutta3, tracers = (:c,), coriolis = nothing, buoyancy = nothing, closure = nothing)
    #= none:607 =#
    set!(model, c = 1)
    #= none:609 =#
    Δt = 1 / 64
    #= none:610 =#
    simulation = Simulation(model, Δt = Δt, stop_iteration = 10)
    #= none:612 =#
    ∫c_dx = Field(Average(model.tracers.c, dims = 1))
    #= none:613 =#
    ∫∫c_dxdy = Field(Average(model.tracers.c, dims = (1, 2)))
    #= none:614 =#
    ∫∫∫c_dxdydz = Field(Average(model.tracers.c, dims = (1, 2, 3)))
    #= none:616 =#
    volume_avg_nc_filepath = "volume_averaged_field_test.nc"
    #= none:618 =#
    simulation.output_writers[:averages] = NetCDFOutputWriter(model, (; ∫c_dx, ∫∫c_dxdy, ∫∫∫c_dxdydz), array_type = Array{Float64}, verbose = true, filename = volume_avg_nc_filepath, schedule = IterationInterval(2))
    #= none:623 =#
    run!(simulation)
    #= none:625 =#
    ds = NCDataset(volume_avg_nc_filepath)
    #= none:627 =#
    for (n, t) = enumerate(ds["time"])
        #= none:628 =#
        #= none:628 =# @test all((ds["∫c_dx"])[:, :, n] .≈ 1)
        #= none:629 =#
        #= none:629 =# @test all((ds["∫∫c_dxdy"])[:, n] .≈ 1)
        #= none:630 =#
        #= none:630 =# @test all((ds["∫∫∫c_dxdydz"])[n] .≈ 1)
        #= none:631 =#
    end
    #= none:633 =#
    close(ds)
    #= none:635 =#
    return nothing
end
#= none:639 =#
function test_netcdf_time_averaging(arch)
    #= none:639 =#
    #= none:640 =#
    topo = (Periodic, Periodic, Periodic)
    #= none:641 =#
    domain = (x = (0, 1), y = (0, 1), z = (0, 1))
    #= none:642 =#
    grid = RectilinearGrid(arch, topology = topo, size = (4, 4, 4); domain...)
    #= none:644 =#
    λ1(x, y, z) = begin
            #= none:644 =#
            x + (1 - y) ^ 2 + tanh(z)
        end
    #= none:645 =#
    λ2(x, y, z) = begin
            #= none:645 =#
            x + (1 - y) ^ 2 + tanh(4z)
        end
    #= none:647 =#
    Fc1(x, y, z, t, c1) = begin
            #= none:647 =#
            -(λ1(x, y, z)) * c1
        end
    #= none:648 =#
    Fc2(x, y, z, t, c2) = begin
            #= none:648 =#
            -(λ2(x, y, z)) * c2
        end
    #= none:650 =#
    c1_forcing = Forcing(Fc1, field_dependencies = :c1)
    #= none:651 =#
    c2_forcing = Forcing(Fc2, field_dependencies = :c2)
    #= none:653 =#
    model = NonhydrostaticModel(; grid, timestepper = :RungeKutta3, tracers = (:c1, :c2), forcing = (c1 = c1_forcing, c2 = c2_forcing))
    #= none:658 =#
    set!(model, c1 = 1, c2 = 1)
    #= none:660 =#
    Δt = 1 / 64
    #= none:661 =#
    simulation = Simulation(model, Δt = Δt, stop_time = 50Δt)
    #= none:663 =#
    ∫c1_dxdy = Field(Average(model.tracers.c1, dims = (1, 2)))
    #= none:664 =#
    ∫c2_dxdy = Field(Average(model.tracers.c2, dims = (1, 2)))
    #= none:666 =#
    nc_outputs = Dict("c1" => ∫c1_dxdy, "c2" => ∫c2_dxdy)
    #= none:667 =#
    nc_dimensions = Dict("c1" => ("zC",), "c2" => ("zC",))
    #= none:669 =#
    horizontal_average_nc_filepath = "decay_averaged_field_test.nc"
    #= none:671 =#
    simulation.output_writers[:horizontal_average] = NetCDFOutputWriter(model, nc_outputs, array_type = Array{Float64}, verbose = true, filename = horizontal_average_nc_filepath, schedule = TimeInterval(10Δt), dimensions = nc_dimensions)
    #= none:679 =#
    multiple_time_average_nc_filepath = "decay_windowed_time_average_test.nc"
    #= none:680 =#
    single_time_average_nc_filepath = "single_decay_windowed_time_average_test.nc"
    #= none:681 =#
    window = 6Δt
    #= none:682 =#
    stride = 2
    #= none:684 =#
    single_nc_output = Dict("c1" => ∫c1_dxdy)
    #= none:685 =#
    single_nc_dimension = Dict("c1" => ("zC",))
    #= none:687 =#
    simulation.output_writers[:single_output_time_average] = NetCDFOutputWriter(model, single_nc_output, array_type = Array{Float64}, verbose = true, filename = single_time_average_nc_filepath, schedule = AveragedTimeInterval(10Δt, window = window, stride = stride), dimensions = single_nc_dimension)
    #= none:695 =#
    simulation.output_writers[:multiple_output_time_average] = NetCDFOutputWriter(model, nc_outputs, array_type = Array{Float64}, verbose = true, filename = multiple_time_average_nc_filepath, schedule = AveragedTimeInterval(10Δt, window = window, stride = stride), dimensions = nc_dimensions)
    #= none:703 =#
    run!(simulation)
    #= none:712 =#
    ds = NCDataset(horizontal_average_nc_filepath)
    #= none:714 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:715 =#
    (xs, ys, zs) = nodes(model.tracers.c1)
    #= none:717 =#
    c̄1(z, t) = begin
            #= none:717 =#
            (1 / (Nx * Ny)) * sum((exp(-(λ1(x, y, z)) * t) for x = xs for y = ys))
        end
    #= none:718 =#
    c̄2(z, t) = begin
            #= none:718 =#
            (1 / (Nx * Ny)) * sum((exp(-(λ2(x, y, z)) * t) for x = xs for y = ys))
        end
    #= none:720 =#
    rtol = 1.0e-5
    #= none:722 =#
    for (n, t) = enumerate(ds["time"])
        #= none:723 =#
        #= none:723 =# @test all(isapprox.((ds["c1"])[:, n], c̄1.(zs, t), rtol = rtol))
        #= none:724 =#
        #= none:724 =# @test all(isapprox.((ds["c2"])[:, n], c̄2.(zs, t), rtol = rtol))
        #= none:725 =#
    end
    #= none:727 =#
    close(ds)
    #= none:730 =#
    c̄1(ts) = begin
            #= none:730 =#
            (1 / length(ts)) * sum((c̄1.(zs, t) for t = ts))
        end
    #= none:731 =#
    c̄2(ts) = begin
            #= none:731 =#
            (1 / length(ts)) * sum((c̄2.(zs, t) for t = ts))
        end
    #= none:738 =#
    single_ds = NCDataset(single_time_average_nc_filepath)
    #= none:740 =#
    attribute_names = ("schedule", "interval", "output time interval", "time_averaging_window", "time averaging window", "time_averaging_stride", "time averaging stride")
    #= none:744 =#
    for name = attribute_names
        #= none:745 =#
        #= none:745 =# @test haskey(single_ds.attrib, name) && !(isnothing(single_ds.attrib[name]))
        #= none:746 =#
    end
    #= none:748 =#
    window_size = Int(window / Δt)
    #= none:750 =#
    #= none:750 =# @info "    Testing time-averaging of a single NetCDF output [$(typeof(arch))]..."
    #= none:752 =#
    for (n, t) = enumerate((single_ds["time"])[2:end])
        #= none:753 =#
        averaging_times = [t - n * Δt for n = 0:stride:window_size - 1 if t - n * Δt >= 0]
        #= none:754 =#
        #= none:754 =# @test all(isapprox.((single_ds["c1"])[:, n + 1], c̄1(averaging_times), rtol = rtol, atol = rtol))
        #= none:755 =#
    end
    #= none:757 =#
    close(single_ds)
    #= none:764 =#
    ds = NCDataset(multiple_time_average_nc_filepath)
    #= none:766 =#
    #= none:766 =# @info "    Testing time-averaging of multiple NetCDF outputs [$(typeof(arch))]..."
    #= none:768 =#
    for (n, t) = enumerate((ds["time"])[2:end])
        #= none:769 =#
        averaging_times = [t - n * Δt for n = 0:stride:window_size - 1 if t - n * Δt >= 0]
        #= none:770 =#
        #= none:770 =# @test all(isapprox.((ds["c2"])[:, n + 1], c̄2(averaging_times), rtol = rtol))
        #= none:771 =#
    end
    #= none:773 =#
    close(ds)
    #= none:775 =#
    rm(horizontal_average_nc_filepath)
    #= none:776 =#
    rm(multiple_time_average_nc_filepath)
    #= none:778 =#
    return nothing
end
#= none:781 =#
function test_netcdf_output_alignment(arch)
    #= none:781 =#
    #= none:782 =#
    grid = RectilinearGrid(size = (1, 1, 1), extent = (1, 1, 1))
    #= none:783 =#
    model = NonhydrostaticModel(; grid, timestepper = :QuasiAdamsBashforth2, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:785 =#
    simulation = Simulation(model, Δt = 0.2, stop_time = 40)
    #= none:787 =#
    test_filename1 = "test_output_alignment1.nc"
    #= none:788 =#
    simulation.output_writers[:stuff] = NetCDFOutputWriter(model, model.velocities, filename = test_filename1, schedule = TimeInterval(7.3))
    #= none:792 =#
    test_filename2 = "test_output_alignment2.nc"
    #= none:793 =#
    simulation.output_writers[:something] = NetCDFOutputWriter(model, model.tracers, filename = test_filename2, schedule = TimeInterval(3.0))
    #= none:797 =#
    run!(simulation)
    #= none:799 =#
    Dataset(test_filename1, "r") do ds
        #= none:800 =#
        #= none:800 =# @test all(ds["time"] .== 0:7.3:40)
    end
    #= none:803 =#
    Dataset(test_filename2, "r") do ds
        #= none:804 =#
        #= none:804 =# @test all(ds["time"] .== 0:3.0:40)
    end
    #= none:807 =#
    rm(test_filename1)
    #= none:808 =#
    rm(test_filename2)
    #= none:810 =#
    return nothing
end
#= none:813 =#
function test_netcdf_vertically_stretched_grid_output(arch)
    #= none:813 =#
    #= none:814 =#
    Nx = (Ny = 8)
    #= none:815 =#
    Nz = 16
    #= none:816 =#
    zF = [k ^ 2 for k = 0:Nz]
    #= none:817 =#
    grid = RectilinearGrid(arch; size = (Nx, Ny, Nz), x = (0, 1), y = (-π, π), z = zF)
    #= none:819 =#
    model = NonhydrostaticModel(; grid, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
    #= none:822 =#
    Δt = 1.25
    #= none:823 =#
    iters = 3
    #= none:824 =#
    simulation = Simulation(model, Δt = Δt, stop_iteration = iters)
    #= none:826 =#
    nc_filepath = "test_netcdf_vertically_stretched_grid_output_$(typeof(arch)).nc"
    #= none:828 =#
    simulation.output_writers[:fields] = NetCDFOutputWriter(model, merge(model.velocities, model.tracers), filename = nc_filepath, schedule = IterationInterval(1), array_type = Array{Float64}, verbose = true)
    #= none:835 =#
    run!(simulation)
    #= none:837 =#
    grid = model.grid
    #= none:838 =#
    ds = NCDataset(nc_filepath)
    #= none:840 =#
    #= none:840 =# @test length(ds["xC"]) == Nx
    #= none:841 =#
    #= none:841 =# @test length(ds["yC"]) == Ny
    #= none:842 =#
    #= none:842 =# @test length(ds["zC"]) == Nz
    #= none:843 =#
    #= none:843 =# @test length(ds["xF"]) == Nx
    #= none:844 =#
    #= none:844 =# @test length(ds["yF"]) == Ny
    #= none:845 =#
    #= none:845 =# @test length(ds["zF"]) == Nz + 1
    #= none:847 =#
    #= none:847 =# @test (ds["xC"])[1] == grid.xᶜᵃᵃ[1]
    #= none:848 =#
    #= none:848 =# @test (ds["xF"])[1] == grid.xᶠᵃᵃ[1]
    #= none:849 =#
    #= none:849 =# @test (ds["yC"])[1] == grid.yᵃᶜᵃ[1]
    #= none:850 =#
    #= none:850 =# @test (ds["yF"])[1] == grid.yᵃᶠᵃ[1]
    #= none:852 =#
    #= none:852 =# @test #= none:852 =# CUDA.@allowscalar((ds["zC"])[1] == grid.zᵃᵃᶜ[1])
    #= none:853 =#
    #= none:853 =# @test #= none:853 =# CUDA.@allowscalar((ds["zF"])[1] == grid.zᵃᵃᶠ[1])
    #= none:855 =#
    #= none:855 =# @test (ds["xC"])[end] == grid.xᶜᵃᵃ[Nx]
    #= none:856 =#
    #= none:856 =# @test (ds["xF"])[end] == grid.xᶠᵃᵃ[Nx]
    #= none:857 =#
    #= none:857 =# @test (ds["yC"])[end] == grid.yᵃᶜᵃ[Ny]
    #= none:858 =#
    #= none:858 =# @test (ds["yF"])[end] == grid.yᵃᶠᵃ[Ny]
    #= none:860 =#
    #= none:860 =# @test #= none:860 =# CUDA.@allowscalar((ds["zC"])[end] == grid.zᵃᵃᶜ[Nz])
    #= none:861 =#
    #= none:861 =# @test #= none:861 =# CUDA.@allowscalar((ds["zF"])[end] == grid.zᵃᵃᶠ[Nz + 1])
    #= none:863 =#
    close(ds)
    #= none:864 =#
    rm(nc_filepath)
    #= none:866 =#
    return nothing
end
#= none:869 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: VectorInvariant
#= none:871 =#
function test_netcdf_regular_lat_lon_grid_output(arch; immersed = false)
    #= none:871 =#
    #= none:872 =#
    Nx = (Ny = (Nz = 16))
    #= none:873 =#
    grid = LatitudeLongitudeGrid(arch; size = (Nx, Ny, Nz), longitude = (-180, 180), latitude = (-80, 80), z = (-100, 0))
    #= none:875 =#
    if immersed
        #= none:876 =#
        grid = ImmersedBoundaryGrid(grid, GridFittedBottom(((x, y)->begin
                            #= none:876 =#
                            -50
                        end)))
    end
    #= none:879 =#
    model = HydrostaticFreeSurfaceModel(momentum_advection = VectorInvariant(), grid = grid)
    #= none:881 =#
    Δt = 1.25
    #= none:882 =#
    iters = 3
    #= none:883 =#
    simulation = Simulation(model, Δt = Δt, stop_iteration = iters)
    #= none:885 =#
    nc_filepath = "test_netcdf_regular_lat_lon_grid_output_$(typeof(arch)).nc"
    #= none:887 =#
    simulation.output_writers[:fields] = NetCDFOutputWriter(model, merge(model.velocities, model.tracers), filename = nc_filepath, schedule = IterationInterval(1), array_type = Array{Float64}, verbose = true)
    #= none:894 =#
    run!(simulation)
    #= none:896 =#
    grid = model.grid
    #= none:897 =#
    ds = NCDataset(nc_filepath)
    #= none:899 =#
    #= none:899 =# @test length(ds["xC"]) == Nx
    #= none:900 =#
    #= none:900 =# @test length(ds["yC"]) == Ny
    #= none:901 =#
    #= none:901 =# @test length(ds["zC"]) == Nz
    #= none:902 =#
    #= none:902 =# @test length(ds["xF"]) == Nx
    #= none:903 =#
    #= none:903 =# @test length(ds["yF"]) == Ny + 1
    #= none:904 =#
    #= none:904 =# @test length(ds["zF"]) == Nz + 1
    #= none:906 =#
    #= none:906 =# @test (ds["xC"])[1] == grid.λᶜᵃᵃ[1]
    #= none:907 =#
    #= none:907 =# @test (ds["xF"])[1] == grid.λᶠᵃᵃ[1]
    #= none:908 =#
    #= none:908 =# @test (ds["yC"])[1] == grid.φᵃᶜᵃ[1]
    #= none:909 =#
    #= none:909 =# @test (ds["yF"])[1] == grid.φᵃᶠᵃ[1]
    #= none:910 =#
    #= none:910 =# @test (ds["zC"])[1] == grid.zᵃᵃᶜ[1]
    #= none:911 =#
    #= none:911 =# @test (ds["zF"])[1] == grid.zᵃᵃᶠ[1]
    #= none:913 =#
    #= none:913 =# @test (ds["xC"])[end] == grid.λᶜᵃᵃ[Nx]
    #= none:914 =#
    #= none:914 =# @test (ds["xF"])[end] == grid.λᶠᵃᵃ[Nx]
    #= none:915 =#
    #= none:915 =# @test (ds["yC"])[end] == grid.φᵃᶜᵃ[Ny]
    #= none:916 =#
    #= none:916 =# @test (ds["yF"])[end] == grid.φᵃᶠᵃ[Ny + 1]
    #= none:917 =#
    #= none:917 =# @test (ds["zC"])[end] == grid.zᵃᵃᶜ[Nz]
    #= none:918 =#
    #= none:918 =# @test (ds["zF"])[end] == grid.zᵃᵃᶠ[Nz + 1]
    #= none:920 =#
    close(ds)
    #= none:921 =#
    rm(nc_filepath)
    #= none:923 =#
    return nothing
end
#= none:926 =#
for arch = archs
    #= none:927 =#
    #= none:927 =# @testset "NetCDF output writer [$(typeof(arch))]" begin
            #= none:928 =#
            #= none:928 =# @info "  Testing NetCDF output writer [$(typeof(arch))]..."
            #= none:929 =#
            test_DateTime_netcdf_output(arch)
            #= none:930 =#
            test_netcdf_size_file_splitting(arch)
            #= none:931 =#
            test_netcdf_time_file_splitting(arch)
            #= none:932 =#
            test_TimeDate_netcdf_output(arch)
            #= none:933 =#
            test_thermal_bubble_netcdf_output(arch)
            #= none:934 =#
            test_thermal_bubble_netcdf_output_with_halos(arch)
            #= none:935 =#
            test_netcdf_function_output(arch)
            #= none:936 =#
            test_netcdf_output_alignment(arch)
            #= none:937 =#
            test_netcdf_spatial_average(arch)
            #= none:938 =#
            test_netcdf_time_averaging(arch)
            #= none:939 =#
            test_netcdf_vertically_stretched_grid_output(arch)
            #= none:940 =#
            test_netcdf_regular_lat_lon_grid_output(arch; immersed = false)
            #= none:941 =#
            test_netcdf_regular_lat_lon_grid_output(arch; immersed = true)
        end
    #= none:943 =#
end