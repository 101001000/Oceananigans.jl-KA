
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Grids: required_halo_size_x, required_halo_size_y, required_halo_size_z
#= none:5 =#
#= none:5 =# @testset "Models" begin
        #= none:6 =#
        #= none:6 =# @info "Testing models..."
        #= none:8 =#
        #= none:8 =# @testset "Model constructor errors" begin
                #= none:9 =#
                grid = RectilinearGrid(CPU(), size = (1, 1, 1), extent = (1, 1, 1))
                #= none:10 =#
                #= none:10 =# @test_throws TypeError NonhydrostaticModel(; grid, boundary_conditions = 1)
                #= none:11 =#
                #= none:11 =# @test_throws TypeError NonhydrostaticModel(; grid, forcing = 2)
                #= none:12 =#
                #= none:12 =# @test_throws TypeError NonhydrostaticModel(; grid, background_fields = 3)
            end
        #= none:15 =#
        topos = ((Periodic, Periodic, Periodic), (Periodic, Periodic, Bounded), (Periodic, Bounded, Bounded), (Bounded, Bounded, Bounded))
        #= none:20 =#
        for topo = topos
            #= none:21 =#
            #= none:21 =# @testset "$(topo) model construction" begin
                    #= none:22 =#
                    #= none:22 =# @info "  Testing $(topo) model construction..."
                    #= none:23 =#
                    for arch = archs, FT = float_types
                        #= none:24 =#
                        arch isa GPU && (topo == (Bounded, Bounded, Bounded) && continue)
                        #= none:26 =#
                        grid = RectilinearGrid(arch, FT, topology = topo, size = (16, 16, 2), extent = (1, 2, 3))
                        #= none:27 =#
                        model = NonhydrostaticModel(; grid)
                        #= none:29 =#
                        #= none:29 =# @test model isa NonhydrostaticModel
                        #= none:30 =#
                    end
                end
            #= none:32 =#
        end
        #= none:34 =#
        #= none:34 =# @testset "Adjustment of halos in NonhydrostaticModel constructor" begin
                #= none:35 =#
                #= none:35 =# @info "  Testing adjustment of halos in NonhydrostaticModel constructor..."
                #= none:37 =#
                minimal_grid = RectilinearGrid(size = (4, 4, 4), extent = (1, 2, 3), halo = (1, 1, 1))
                #= none:38 =#
                funny_grid = RectilinearGrid(size = (4, 4, 4), extent = (1, 2, 3), halo = (1, 3, 4))
                #= none:41 =#
                model = NonhydrostaticModel(grid = minimal_grid)
                #= none:42 =#
                #= none:42 =# @test model.grid.Hx == 1 && (model.grid.Hy == 1 && model.grid.Hz == 1)
                #= none:44 =#
                model = NonhydrostaticModel(grid = funny_grid)
                #= none:45 =#
                #= none:45 =# @test model.grid.Hx == 1 && (model.grid.Hy == 3 && model.grid.Hz == 4)
                #= none:48 =#
                for scheme = (CenteredFourthOrder(), UpwindBiasedThirdOrder())
                    #= none:49 =#
                    model = NonhydrostaticModel(advection = scheme, grid = minimal_grid)
                    #= none:50 =#
                    #= none:50 =# @test model.grid.Hx == 2 && (model.grid.Hy == 2 && model.grid.Hz == 2)
                    #= none:52 =#
                    model = NonhydrostaticModel(advection = scheme, grid = funny_grid)
                    #= none:53 =#
                    #= none:53 =# @test model.grid.Hx == 2 && (model.grid.Hy == 3 && model.grid.Hz == 4)
                    #= none:54 =#
                end
                #= none:57 =#
                for scheme = (WENO(), UpwindBiasedFifthOrder())
                    #= none:58 =#
                    model = NonhydrostaticModel(advection = scheme, grid = minimal_grid)
                    #= none:59 =#
                    #= none:59 =# @test model.grid.Hx == 3 && (model.grid.Hy == 3 && model.grid.Hz == 3)
                    #= none:61 =#
                    model = NonhydrostaticModel(advection = scheme, grid = funny_grid)
                    #= none:62 =#
                    #= none:62 =# @test model.grid.Hx == 3 && (model.grid.Hy == 3 && model.grid.Hz == 4)
                    #= none:63 =#
                end
                #= none:66 =#
                model = NonhydrostaticModel(closure = ScalarBiharmonicDiffusivity(), grid = minimal_grid)
                #= none:67 =#
                #= none:67 =# @test model.grid.Hx == 2 && (model.grid.Hy == 2 && model.grid.Hz == 2)
                #= none:69 =#
                model = NonhydrostaticModel(closure = ScalarBiharmonicDiffusivity(), grid = funny_grid)
                #= none:70 =#
                #= none:70 =# @test model.grid.Hx == 2 && (model.grid.Hy == 3 && model.grid.Hz == 4)
                #= none:72 =#
                #= none:72 =# @info "  Testing adjustment of advection schemes in NonhydrostaticModel constructor..."
                #= none:73 =#
                small_grid = RectilinearGrid(size = (4, 2, 4), extent = (1, 2, 3), halo = (1, 1, 1))
                #= none:76 =#
                model = NonhydrostaticModel(grid = small_grid, advection = WENO())
                #= none:77 =#
                #= none:77 =# @test model.advection isa FluxFormAdvection
                #= none:78 =#
                #= none:78 =# @test required_halo_size_x(model.advection) == 3
                #= none:79 =#
                #= none:79 =# @test required_halo_size_y(model.advection) == 2
                #= none:80 =#
                #= none:80 =# @test required_halo_size_z(model.advection) == 3
                #= none:82 =#
                model = NonhydrostaticModel(grid = small_grid, advection = UpwindBiased(; order = 9))
                #= none:83 =#
                #= none:83 =# @test model.advection isa FluxFormAdvection
                #= none:84 =#
                #= none:84 =# @test required_halo_size_x(model.advection) == 4
                #= none:85 =#
                #= none:85 =# @test required_halo_size_y(model.advection) == 2
                #= none:86 =#
                #= none:86 =# @test required_halo_size_z(model.advection) == 4
                #= none:88 =#
                model = NonhydrostaticModel(grid = small_grid, advection = Centered(; order = 10))
                #= none:89 =#
                #= none:89 =# @test model.advection isa FluxFormAdvection
                #= none:90 =#
                #= none:90 =# @test required_halo_size_x(model.advection) == 4
                #= none:91 =#
                #= none:91 =# @test required_halo_size_y(model.advection) == 2
                #= none:92 =#
                #= none:92 =# @test required_halo_size_z(model.advection) == 4
            end
        #= none:95 =#
        #= none:95 =# @testset "Model construction with single tracer and nothing tracer" begin
                #= none:96 =#
                #= none:96 =# @info "  Testing model construction with single tracer and nothing tracer..."
                #= none:97 =#
                for arch = archs
                    #= none:98 =#
                    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 2, 3))
                    #= none:100 =#
                    model = NonhydrostaticModel(; grid, tracers = :c, buoyancy = nothing)
                    #= none:101 =#
                    #= none:101 =# @test model isa NonhydrostaticModel
                    #= none:103 =#
                    model = NonhydrostaticModel(; grid, tracers = nothing, buoyancy = nothing)
                    #= none:104 =#
                    #= none:104 =# @test model isa NonhydrostaticModel
                    #= none:105 =#
                end
            end
        #= none:108 =#
        #= none:108 =# @testset "Setting model fields" begin
                #= none:109 =#
                #= none:109 =# @info "  Testing setting model fields..."
                #= none:110 =#
                for arch = archs, FT = float_types
                    #= none:111 =#
                    N = (4, 4, 4)
                    #= none:112 =#
                    L = (2π, 3π, 5π)
                    #= none:114 =#
                    grid = RectilinearGrid(arch, FT, size = N, extent = L)
                    #= none:115 =#
                    model = NonhydrostaticModel(; grid, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S))
                    #= none:117 =#
                    (u, v, w) = model.velocities
                    #= none:118 =#
                    (T, S) = model.tracers
                    #= none:121 =#
                    T₀_array = rand(FT, size(grid)...)
                    #= none:122 =#
                    T_answer = deepcopy(T₀_array)
                    #= none:124 =#
                    set!(model; enforce_incompressibility = false, T = T₀_array)
                    #= none:126 =#
                    #= none:126 =# @test Array(interior(T)) ≈ T_answer
                    #= none:129 =#
                    u₀(x, y, z) = begin
                            #= none:129 =#
                            1 + x + y + z
                        end
                    #= none:130 =#
                    v₀(x, y, z) = begin
                            #= none:130 =#
                            2 + sin(x * y * z)
                        end
                    #= none:131 =#
                    w₀(x, y, z) = begin
                            #= none:131 =#
                            3 + y * z
                        end
                    #= none:132 =#
                    T₀(x, y, z) = begin
                            #= none:132 =#
                            4 + tanh((x + y) - z)
                        end
                    #= none:133 =#
                    S₀(x, y, z) = begin
                            #= none:133 =#
                            5
                        end
                    #= none:135 =#
                    set!(model, enforce_incompressibility = false, u = u₀, v = v₀, w = w₀, T = T₀, S = S₀)
                    #= none:137 =#
                    (xC, yC, zC) = nodes(model.grid, (Center(), Center(), Center()), reshape = true)
                    #= none:138 =#
                    (xF, yF, zF) = nodes(model.grid, (Face(), Face(), Face()), reshape = true)
                    #= none:141 =#
                    u_answer = u₀.(xF, yC, zC) |> Array
                    #= none:142 =#
                    v_answer = v₀.(xC, yF, zC) |> Array
                    #= none:143 =#
                    w_answer = w₀.(xC, yC, zF) |> Array
                    #= none:144 =#
                    T_answer = T₀.(xC, yC, zC) |> Array
                    #= none:145 =#
                    S_answer = S₀.(xC, yC, zC) |> Array
                    #= none:147 =#
                    (Nx, Ny, Nz) = size(model.grid)
                    #= none:149 =#
                    cpu_grid = on_architecture(CPU(), grid)
                    #= none:151 =#
                    u_cpu = XFaceField(cpu_grid)
                    #= none:152 =#
                    v_cpu = YFaceField(cpu_grid)
                    #= none:153 =#
                    w_cpu = ZFaceField(cpu_grid)
                    #= none:154 =#
                    T_cpu = CenterField(cpu_grid)
                    #= none:155 =#
                    S_cpu = CenterField(cpu_grid)
                    #= none:157 =#
                    set!(u_cpu, u)
                    #= none:158 =#
                    set!(v_cpu, v)
                    #= none:159 =#
                    set!(w_cpu, w)
                    #= none:160 =#
                    set!(T_cpu, T)
                    #= none:161 =#
                    set!(S_cpu, S)
                    #= none:163 =#
                    values_match = [all(u_answer .≈ interior(u_cpu)), all(v_answer .≈ interior(v_cpu)), all(w_answer[:, :, 2:Nz] .≈ (interior(w_cpu))[:, :, 2:Nz]), all(T_answer .≈ interior(T_cpu)), all(S_answer .≈ interior(S_cpu))]
                    #= none:171 =#
                    #= none:171 =# @test all(values_match)
                    #= none:175 =#
                    #= none:175 =# @test u_cpu[1, 1, 1] == u_cpu[Nx + 1, 1, 1]
                    #= none:176 =#
                    #= none:176 =# @test u_cpu[1, 1, 1] == u_cpu[1, Ny + 1, 1]
                    #= none:177 =#
                    #= none:177 =# @test all(u_cpu[1:Nx, 1:Ny, 1] .== u_cpu[1:Nx, 1:Ny, 0])
                    #= none:178 =#
                    #= none:178 =# @test all(u_cpu[1:Nx, 1:Ny, Nz] .== u_cpu[1:Nx, 1:Ny, Nz + 1])
                    #= none:181 =#
                    set!(model, u = 0, v = 0, w = 1, T = 0, S = 0)
                    #= none:182 =#
                    ϵ = 10 * eps(FT)
                    #= none:183 =#
                    set!(w_cpu, w)
                    #= none:184 =#
                    #= none:184 =# @test all(abs.(interior(w_cpu)) .< ϵ)
                    #= none:187 =#
                    U_field = XFaceField(grid)
                    #= none:188 =#
                    U_field .= 1
                    #= none:189 =#
                    model = NonhydrostaticModel(; grid, background_fields = (u = U_field,))
                    #= none:190 =#
                    #= none:190 =# @test model.background_fields.velocities.u isa Field
                    #= none:192 =#
                    U_field = CenterField(grid)
                    #= none:193 =#
                    #= none:193 =# @test_throws ArgumentError NonhydrostaticModel(; grid, background_fields = (u = U_field,))
                    #= none:194 =#
                end
            end
    end