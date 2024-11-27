
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.BoundaryConditions: ImpenetrableBoundaryCondition
#= none:4 =#
using Oceananigans.Fields: Field
#= none:5 =#
using Oceananigans.Forcings: MultipleForcings
#= none:7 =#
#= none:7 =# Core.@doc " Take one time step with three forcing arrays on u, v, w. " function time_step_with_forcing_array(arch)
        #= none:8 =#
        #= none:9 =#
        grid = RectilinearGrid(arch, size = (2, 2, 2), extent = (1, 1, 1))
        #= none:11 =#
        Fu = XFaceField(grid)
        #= none:12 =#
        Fv = YFaceField(grid)
        #= none:13 =#
        Fw = ZFaceField(grid)
        #= none:15 =#
        set!(Fu, ((x, y, z)->begin
                    #= none:15 =#
                    1
                end))
        #= none:16 =#
        set!(Fv, ((x, y, z)->begin
                    #= none:16 =#
                    1
                end))
        #= none:17 =#
        set!(Fw, ((x, y, z)->begin
                    #= none:17 =#
                    1
                end))
        #= none:19 =#
        model = NonhydrostaticModel(; grid, forcing = (u = Fu, v = Fv, w = Fw))
        #= none:20 =#
        time_step!(model, 1)
        #= none:22 =#
        return true
    end
#= none:25 =#
#= none:25 =# Core.@doc " Take one time step with three forcing functions on u, v, w. " function time_step_with_forcing_functions(arch)
        #= none:26 =#
        #= none:27 =#
        #= none:27 =# @inline Fu(x, y, z, t) = begin
                    #= none:27 =#
                    exp(π * z)
                end
        #= none:28 =#
        #= none:28 =# @inline Fv(x, y, z, t) = begin
                    #= none:28 =#
                    cos(42x)
                end
        #= none:29 =#
        #= none:29 =# @inline Fw(x, y, z, t) = begin
                    #= none:29 =#
                    1.0
                end
        #= none:31 =#
        grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
        #= none:32 =#
        model = NonhydrostaticModel(; grid, forcing = (u = Fu, v = Fv, w = Fw))
        #= none:33 =#
        time_step!(model, 1)
        #= none:35 =#
        return true
    end
#= none:38 =#
#= none:38 =# @inline Fu_discrete_func(i, j, k, grid, clock, model_fields) = begin
            #= none:38 =#
            #= none:38 =# @inbounds -(model_fields.u[i, j, k])
        end
#= none:39 =#
#= none:39 =# @inline Fv_discrete_func(i, j, k, grid, clock, model_fields, params) = begin
            #= none:39 =#
            #= none:39 =# @inbounds -(model_fields.v[i, j, k]) / params.τ
        end
#= none:40 =#
#= none:40 =# @inline Fw_discrete_func(i, j, k, grid, clock, model_fields, params) = begin
            #= none:40 =#
            #= none:40 =# @inbounds -(model_fields.w[i, j, k] ^ 2) / params.τ
        end
#= none:42 =#
#= none:42 =# Core.@doc " Take one time step with a DiscreteForcing function. " function time_step_with_discrete_forcing(arch)
        #= none:43 =#
        #= none:44 =#
        Fu = Forcing(Fu_discrete_func, discrete_form = true)
        #= none:45 =#
        grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
        #= none:46 =#
        model = NonhydrostaticModel(; grid, forcing = (; u = Fu))
        #= none:47 =#
        time_step!(model, 1)
        #= none:49 =#
        return true
    end
#= none:52 =#
#= none:52 =# Core.@doc " Take one time step with ParameterizedForcing forcing functions. " function time_step_with_parameterized_discrete_forcing(arch)
        #= none:53 =#
        #= none:55 =#
        Fv = Forcing(Fv_discrete_func, parameters = (; τ = 60), discrete_form = true)
        #= none:56 =#
        Fw = Forcing(Fw_discrete_func, parameters = (; τ = 60), discrete_form = true)
        #= none:58 =#
        grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
        #= none:59 =#
        model = NonhydrostaticModel(; grid, forcing = (v = Fv, w = Fw))
        #= none:60 =#
        time_step!(model, 1)
        #= none:62 =#
        return true
    end
#= none:65 =#
#= none:65 =# Core.@doc " Take one time step with a Forcing forcing function with parameters. " function time_step_with_parameterized_continuous_forcing(arch)
        #= none:66 =#
        #= none:67 =#
        Fu = Forcing(((x, y, z, t, ω)->begin
                        #= none:67 =#
                        sin(ω * x)
                    end), parameters = π)
        #= none:68 =#
        grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
        #= none:69 =#
        model = NonhydrostaticModel(; grid, forcing = (; u = Fu))
        #= none:70 =#
        time_step!(model, 1)
        #= none:71 =#
        return true
    end
#= none:74 =#
#= none:74 =# Core.@doc " Take one time step with a Forcing forcing function with parameters. " function time_step_with_single_field_dependent_forcing(arch, fld)
        #= none:75 =#
        #= none:77 =#
        forcing = NamedTuple{(fld,)}((Forcing(((x, y, z, t, fld)->begin
                                #= none:77 =#
                                -fld
                            end), field_dependencies = fld),))
        #= none:79 =#
        grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
        #= none:80 =#
        A = Field{Center, Center, Center}(grid)
        #= none:81 =#
        model = NonhydrostaticModel(; grid, forcing, buoyancy = SeawaterBuoyancy(), tracers = (:T, :S), auxiliary_fields = (; A))
        #= none:85 =#
        time_step!(model, 1)
        #= none:87 =#
        return true
    end
#= none:90 =#
#= none:90 =# Core.@doc " Take one time step with a Forcing forcing function with parameters. " function time_step_with_multiple_field_dependent_forcing(arch)
        #= none:91 =#
        #= none:93 =#
        Fu = Forcing(((x, y, z, t, v, w, T, A)->begin
                        #= none:93 =#
                        sin(v) * exp(w) * T * A
                    end), field_dependencies = (:v, :w, :T, :A))
        #= none:95 =#
        grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
        #= none:96 =#
        A = Field{Center, Center, Center}(grid)
        #= none:97 =#
        model = NonhydrostaticModel(; grid, forcing = (; u = Fu), buoyancy = SeawaterBuoyancy(), tracers = (:T, :S), auxiliary_fields = (; A))
        #= none:102 =#
        time_step!(model, 1)
        #= none:104 =#
        return true
    end
#= none:108 =#
#= none:108 =# Core.@doc " Take one time step with a Forcing forcing function with parameters. " function time_step_with_parameterized_field_dependent_forcing(arch)
        #= none:109 =#
        #= none:110 =#
        Fu = Forcing(((x, y, z, t, u, p)->begin
                        #= none:110 =#
                        sin(p.ω * x) * u
                    end), parameters = (ω = π,), field_dependencies = :u)
        #= none:111 =#
        grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
        #= none:112 =#
        model = NonhydrostaticModel(; grid, forcing = (; u = Fu))
        #= none:113 =#
        time_step!(model, 1)
        #= none:114 =#
        return true
    end
#= none:117 =#
#= none:117 =# Core.@doc " Take one time step with a FieldTimeSeries forcing function. " function time_step_with_field_time_series_forcing(arch)
        #= none:118 =#
        #= none:120 =#
        grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
        #= none:122 =#
        u_forcing = FieldTimeSeries{Face, Center, Center}(grid, 0:1:3)
        #= none:124 =#
        for (t, time) = enumerate(u_forcing.times)
            #= none:125 =#
            set!(u_forcing[t], ((x, y, z)->begin
                        #= none:125 =#
                        sin(π * x) * time
                    end))
            #= none:126 =#
        end
        #= none:128 =#
        model = NonhydrostaticModel(; grid, forcing = (; u = u_forcing))
        #= none:129 =#
        time_step!(model, 1)
        #= none:132 =#
        u_forcing = FieldTimeSeries{Face, Center, Center}(grid, 0:1:4; backend = InMemory(2))
        #= none:134 =#
        model = NonhydrostaticModel(; grid, forcing = (; u = u_forcing))
        #= none:135 =#
        time_step!(model, 2)
        #= none:136 =#
        time_step!(model, 2)
        #= none:138 =#
        #= none:138 =# @test u_forcing.backend.start == 4
        #= none:140 =#
        return true
    end
#= none:143 =#
function relaxed_time_stepping(arch)
    #= none:143 =#
    #= none:144 =#
    x_relax = Relaxation(rate = 1 / 60, mask = GaussianMask{:x}(center = 0.5, width = 0.1), target = LinearTarget{:x}(intercept = π, gradient = ℯ))
    #= none:147 =#
    y_relax = Relaxation(rate = 1 / 60, mask = GaussianMask{:y}(center = 0.5, width = 0.1), target = LinearTarget{:y}(intercept = π, gradient = ℯ))
    #= none:150 =#
    z_relax = Relaxation(rate = 1 / 60, mask = GaussianMask{:z}(center = 0.5, width = 0.1), target = π)
    #= none:153 =#
    grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (1, 1, 1))
    #= none:154 =#
    model = NonhydrostaticModel(; grid, forcing = (u = x_relax, v = y_relax, w = z_relax))
    #= none:155 =#
    time_step!(model, 1)
    #= none:157 =#
    return true
end
#= none:160 =#
function advective_and_multiple_forcing(arch)
    #= none:160 =#
    #= none:161 =#
    grid = RectilinearGrid(arch, size = (4, 5, 6), extent = (1, 1, 1), halo = (4, 4, 4))
    #= none:163 =#
    constant_slip = AdvectiveForcing(w = 1)
    #= none:164 =#
    zero_slip = AdvectiveForcing(w = 0)
    #= none:165 =#
    no_penetration = ImpenetrableBoundaryCondition()
    #= none:166 =#
    slip_bcs = FieldBoundaryConditions(grid, (Center, Center, Face), top = no_penetration, bottom = no_penetration)
    #= none:167 =#
    slip_velocity = ZFaceField(grid, boundary_conditions = slip_bcs)
    #= none:168 =#
    set!(slip_velocity, 1)
    #= none:169 =#
    velocity_field_slip = AdvectiveForcing(w = slip_velocity)
    #= none:170 =#
    zero_forcing(x, y, z, t) = begin
            #= none:170 =#
            0
        end
    #= none:171 =#
    one_forcing(x, y, z, t) = begin
            #= none:171 =#
            1
        end
    #= none:173 =#
    model = NonhydrostaticModel(; grid, timestepper = :QuasiAdamsBashforth2, tracers = (:a, :b, :c), forcing = (a = constant_slip, b = (zero_forcing, velocity_field_slip), c = (one_forcing, zero_slip)))
    #= none:180 =#
    a₀ = rand(size(grid)...)
    #= none:181 =#
    b₀ = rand(size(grid)...)
    #= none:182 =#
    set!(model, a = a₀, b = b₀, c = 0)
    #= none:185 =#
    time_step!(model, 1, euler = true)
    #= none:187 =#
    a₁ = Array(interior(model.tracers.a))
    #= none:188 =#
    b₁ = Array(interior(model.tracers.b))
    #= none:189 =#
    c₁ = Array(interior(model.tracers.c))
    #= none:191 =#
    a_changed = a₁ ≠ a₀
    #= none:192 =#
    b_changed = b₁ ≠ b₀
    #= none:193 =#
    c_correct = all(c₁ .== model.clock.time)
    #= none:195 =#
    return (a_changed & b_changed) & c_correct
end
#= none:198 =#
function two_forcings(arch)
    #= none:198 =#
    #= none:199 =#
    grid = RectilinearGrid(arch, size = (4, 5, 6), extent = (1, 1, 1), halo = (4, 4, 4))
    #= none:201 =#
    forcing1 = Relaxation(rate = 1)
    #= none:202 =#
    forcing2 = Relaxation(rate = 2)
    #= none:204 =#
    forcing = (u = (forcing1, forcing2), v = MultipleForcings(forcing1, forcing2), w = MultipleForcings((forcing1, forcing2)))
    #= none:208 =#
    model = NonhydrostaticModel(; grid, forcing)
    #= none:209 =#
    time_step!(model, 1)
    #= none:211 =#
    return true
end
#= none:214 =#
function seven_forcings(arch)
    #= none:214 =#
    #= none:215 =#
    grid = RectilinearGrid(arch, size = (4, 5, 6), extent = (1, 1, 1), halo = (4, 4, 4))
    #= none:217 =#
    weird_forcing(x, y, z, t) = begin
            #= none:217 =#
            x * y + z
        end
    #= none:218 =#
    wonky_forcing(x, y, z, t) = begin
            #= none:218 =#
            z / (x - y)
        end
    #= none:219 =#
    strange_forcing(x, y, z, t) = begin
            #= none:219 =#
            z - t
        end
    #= none:220 =#
    bizarre_forcing(x, y, z, t) = begin
            #= none:220 =#
            y + x
        end
    #= none:221 =#
    peculiar_forcing(x, y, z, t) = begin
            #= none:221 =#
            (2t) / z
        end
    #= none:222 =#
    eccentric_forcing(x, y, z, t) = begin
            #= none:222 =#
            x + y + z + t
        end
    #= none:223 =#
    unconventional_forcing(x, y, z, t) = begin
            #= none:223 =#
            (10x) * y
        end
    #= none:225 =#
    F1 = Forcing(weird_forcing)
    #= none:226 =#
    F2 = Forcing(wonky_forcing)
    #= none:227 =#
    F3 = Forcing(strange_forcing)
    #= none:228 =#
    F4 = Forcing(bizarre_forcing)
    #= none:229 =#
    F5 = Forcing(peculiar_forcing)
    #= none:230 =#
    F6 = Forcing(eccentric_forcing)
    #= none:231 =#
    F7 = Forcing(unconventional_forcing)
    #= none:233 =#
    Ft = (F1, F2, F3, F4, F5, F6, F7)
    #= none:234 =#
    forcing = (u = Ft, v = MultipleForcings(Ft...), w = MultipleForcings(Ft))
    #= none:235 =#
    model = NonhydrostaticModel(; grid, forcing)
    #= none:237 =#
    time_step!(model, 1)
    #= none:239 =#
    return true
end
#= none:242 =#
#= none:242 =# @testset "Forcings" begin
        #= none:243 =#
        #= none:243 =# @info "Testing forcings..."
        #= none:245 =#
        for arch = archs
            #= none:246 =#
            A = typeof(arch)
            #= none:247 =#
            #= none:247 =# @testset "Forcing function time stepping [$(A)]" begin
                    #= none:248 =#
                    #= none:248 =# @info "  Testing forcing function time stepping [$(A)]..."
                    #= none:250 =#
                    #= none:250 =# @testset "Non-parameterized forcing functions [$(A)]" begin
                            #= none:251 =#
                            #= none:251 =# @info "      Testing non-parameterized forcing functions [$(A)]..."
                            #= none:252 =#
                            #= none:252 =# @test time_step_with_forcing_functions(arch)
                            #= none:253 =#
                            #= none:253 =# @test time_step_with_forcing_array(arch)
                            #= none:254 =#
                            #= none:254 =# @test time_step_with_discrete_forcing(arch)
                        end
                    #= none:257 =#
                    #= none:257 =# @testset "Parameterized forcing functions [$(A)]" begin
                            #= none:258 =#
                            #= none:258 =# @info "      Testing parameterized forcing functions [$(A)]..."
                            #= none:259 =#
                            #= none:259 =# @test time_step_with_parameterized_continuous_forcing(arch)
                            #= none:260 =#
                            #= none:260 =# @test time_step_with_parameterized_discrete_forcing(arch)
                        end
                    #= none:263 =#
                    #= none:263 =# @testset "Field-dependent forcing functions [$(A)]" begin
                            #= none:264 =#
                            #= none:264 =# @info "      Testing field-dependent forcing functions [$(A)]..."
                            #= none:266 =#
                            for fld = (:u, :v, :w, :T, :A)
                                #= none:267 =#
                                #= none:267 =# @test time_step_with_single_field_dependent_forcing(arch, fld)
                                #= none:268 =#
                            end
                            #= none:270 =#
                            #= none:270 =# @test time_step_with_multiple_field_dependent_forcing(arch)
                            #= none:271 =#
                            #= none:271 =# @test time_step_with_parameterized_field_dependent_forcing(arch)
                        end
                    #= none:274 =#
                    #= none:274 =# @testset "Relaxation forcing functions [$(A)]" begin
                            #= none:275 =#
                            #= none:275 =# @info "      Testing relaxation forcing functions [$(A)]..."
                            #= none:276 =#
                            #= none:276 =# @test relaxed_time_stepping(arch)
                        end
                    #= none:279 =#
                    #= none:279 =# @testset "Advective and multiple forcing [$(A)]" begin
                            #= none:280 =#
                            #= none:280 =# @info "      Testing advective and multiple forcing [$(A)]..."
                            #= none:281 =#
                            #= none:281 =# @test advective_and_multiple_forcing(arch)
                            #= none:282 =#
                            #= none:282 =# @test two_forcings(arch)
                            #= none:283 =#
                            #= none:283 =# @test seven_forcings(arch)
                        end
                    #= none:286 =#
                    #= none:286 =# @testset "FieldTimeSeries forcing on [$(A)]" begin
                            #= none:287 =#
                            #= none:287 =# @info "      Testing FieldTimeSeries forcing [$(A)]..."
                            #= none:288 =#
                            #= none:288 =# @test time_step_with_field_time_series_forcing(arch)
                        end
                end
            #= none:291 =#
        end
    end