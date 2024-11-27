
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:4 =#
Enzyme.API.looseTypeAnalysis!(true)
#= none:5 =#
Enzyme.API.maxtypeoffset!(2032)
#= none:8 =#
Logging.global_logger(TestLogger())
#= none:10 =#
f(grid) = begin
        #= none:10 =#
        CenterField(grid)
    end
#= none:11 =#
const maximum_diffusivity = 100
#= none:13 =#
#= none:13 =# Core.@doc "    set_diffusivity!(model, diffusivity)\n\nChange diffusivity of model to `diffusivity`.\n" function set_diffusivity!(model, diffusivity)
        #= none:18 =#
        #= none:19 =#
        closure = VerticalScalarDiffusivity(; κ = diffusivity)
        #= none:20 =#
        names = tuple(:c)
        #= none:21 =#
        closure = with_tracers(names, closure)
        #= none:22 =#
        model.closure = closure
        #= none:23 =#
        return nothing
    end
#= none:26 =#
function set_initial_condition!(model, amplitude)
    #= none:26 =#
    #= none:27 =#
    amplitude = Ref(amplitude)
    #= none:30 =#
    cᵢ(x, y, z) = begin
            #= none:30 =#
            amplitude[] * exp(-(z ^ 2) / 0.02 - (x ^ 2 + y ^ 2) / 0.05)
        end
    #= none:31 =#
    set!(model, c = cᵢ)
    #= none:33 =#
    return nothing
end
#= none:36 =#
function stable_diffusion!(model, amplitude, diffusivity)
    #= none:36 =#
    #= none:37 =#
    set_diffusivity!(model, diffusivity)
    #= none:38 =#
    set_initial_condition!(model, amplitude)
    #= none:41 =#
    (Nx, Ny, Nz) = size(model.grid)
    #= none:42 =#
    κ_max = maximum_diffusivity
    #= none:43 =#
    Δz = 1 / Nz
    #= none:44 =#
    Δt = (0.1 * Δz ^ 2) / κ_max
    #= none:46 =#
    model.clock.time = 0
    #= none:47 =#
    model.clock.iteration = 0
    #= none:49 =#
    for _ = 1:10
        #= none:50 =#
        time_step!(model, Δt; euler = true)
        #= none:51 =#
    end
    #= none:54 =#
    c = model.tracers.c
    #= none:61 =#
    sum_c² = 0.0
    #= none:62 =#
    for k = 1:Nz, j = 1:Ny, i = 1:Nx
        #= none:63 =#
        sum_c² += c[i, j, k] ^ 2
        #= none:64 =#
    end
    #= none:67 =#
    return sum_c²::Float64
end
#= none:70 =#
#= none:70 =# @testset "Enzyme unit tests" begin
        #= none:71 =#
        arch = CPU()
        #= none:72 =#
        FT = Float64
        #= none:74 =#
        N = 100
        #= none:75 =#
        topo = (Periodic, Flat, Flat)
        #= none:76 =#
        grid = RectilinearGrid(arch, FT, topology = topo, size = N, halo = 2, x = (-1, 1), y = (-1, 1), z = (-1, 1))
        #= none:77 =#
        (fwd, rev) = Enzyme.autodiff_thunk(ReverseSplitWithPrimal, Const{typeof(f)}, Duplicated, typeof(Const(grid)))
        #= none:78 =#
        (tape, primal, shadowp) = fwd(Const(f), Const(grid))
        #= none:80 =#
        #= none:80 =# @show tape primal shadowp
        #= none:82 =#
        shadow = if shadowp isa Base.RefValue
                #= none:83 =#
                shadowp[]
            else
                #= none:85 =#
                shadowp
            end
        #= none:88 =#
        #= none:88 =# @test size(primal) == size(shadow)
    end
#= none:91 =#
function set_initial_condition_via_launch!(model_tracer, amplitude)
    #= none:91 =#
    #= none:93 =#
    amplitude = Ref(amplitude)
    #= none:94 =#
    cᵢ(x, y, z) = begin
            #= none:94 =#
            amplitude[]
        end
    #= none:96 =#
    temp = Base.broadcasted(Base.identity, FunctionField((Center, Center, Center), cᵢ, model_tracer.grid))
    #= none:98 =#
    temp = convert(Base.Broadcast.Broadcasted{Nothing}, temp)
    #= none:99 =#
    grid = model_tracer.grid
    #= none:100 =#
    arch = architecture(model_tracer)
    #= none:102 =#
    param = Oceananigans.Utils.KernelParameters(size(model_tracer), map(Oceananigans.Fields.offset_index, model_tracer.indices))
    #= none:103 =#
    Oceananigans.Utils.launch!(arch, grid, param, Oceananigans.Fields._broadcast_kernel!, model_tracer, temp)
    #= none:105 =#
    return nothing
end
#= none:108 =#
#= none:108 =# @testset "Enzyme + Oceananigans Initialization Broadcast Kernel" begin
        #= none:110 =#
        Nx = (Ny = 64)
        #= none:111 =#
        Nz = 8
        #= none:113 =#
        x = (y = (-π, π))
        #= none:114 =#
        z = (-0.5, 0.5)
        #= none:115 =#
        topology = (Periodic, Periodic, Bounded)
        #= none:117 =#
        grid = RectilinearGrid(size = (Nx, Ny, Nz); x, y, z, topology)
        #= none:118 =#
        model = HydrostaticFreeSurfaceModel(; grid, tracers = :c)
        #= none:119 =#
        model_tracer = model.tracers.c
        #= none:121 =#
        amplitude = 1.0
        #= none:122 =#
        amplitude = Ref(amplitude)
        #= none:123 =#
        cᵢ(x, y, z) = begin
                #= none:123 =#
                amplitude[]
            end
        #= none:124 =#
        temp = Base.broadcasted(Base.identity, FunctionField((Center, Center, Center), cᵢ, model_tracer.grid))
        #= none:126 =#
        temp = convert(Base.Broadcast.Broadcasted{Nothing}, temp)
        #= none:127 =#
        grid = model_tracer.grid
        #= none:128 =#
        arch = architecture(model_tracer)
        #= none:130 =#
        if arch == CPU()
            #= none:131 =#
            param = Oceananigans.Utils.KernelParameters(size(model_tracer), map(Oceananigans.Fields.offset_index, model_tracer.indices))
            #= none:133 =#
            dmodel_tracer = Enzyme.make_zero(model_tracer)
            #= none:136 =#
            autodiff(Enzyme.set_runtime_activity(Enzyme.Reverse), Oceananigans.Utils.launch!, Const(arch), Const(grid), Const(param), Const(Oceananigans.Fields._broadcast_kernel!), Duplicated(model_tracer, dmodel_tracer), Const(temp))
            #= none:146 =#
            autodiff(Enzyme.set_runtime_activity(Enzyme.Reverse), set_initial_condition_via_launch!, Duplicated(model_tracer, dmodel_tracer), Active(1.0))
            #= none:152 =#
            dmodel = Enzyme.make_zero(model)
            #= none:153 =#
            autodiff(Enzyme.set_runtime_activity(Enzyme.Reverse), set_initial_condition!, Duplicated(model, dmodel), Active(1.0))
        end
    end
#= none:161 =#
#= none:161 =# @testset "Enzyme for advection and diffusion with various boundary conditions" begin
        #= none:162 =#
        Nx = (Ny = 64)
        #= none:163 =#
        Nz = 8
        #= none:165 =#
        Lx = (Ly = (L = 2π))
        #= none:166 =#
        Lz = 1
        #= none:168 =#
        x = (y = (-L / 2, L / 2))
        #= none:169 =#
        z = (-Lz / 2, Lz / 2)
        #= none:170 =#
        topology = (Periodic, Periodic, Bounded)
        #= none:172 =#
        grid = RectilinearGrid(size = (Nx, Ny, Nz); x, y, z, topology)
        #= none:173 =#
        diffusion = VerticalScalarDiffusivity(κ = 0.1)
        #= none:175 =#
        u = XFaceField(grid)
        #= none:176 =#
        v = YFaceField(grid)
        #= none:178 =#
        U = 1
        #= none:179 =#
        u₀(x, y, z) = begin
                #= none:179 =#
                -U * cos(x + L / 8) * sin(y) * (z + L / 2)
            end
        #= none:180 =#
        v₀(x, y, z) = begin
                #= none:180 =#
                +U * sin(x + L / 8) * cos(y) * (z + L / 2)
            end
        #= none:182 =#
        set!(u, u₀)
        #= none:183 =#
        set!(v, v₀)
        #= none:184 =#
        fill_halo_regions!(u)
        #= none:185 =#
        fill_halo_regions!(v)
        #= none:187 =#
        #= none:187 =# @inline function tracer_flux(i, j, grid, clock, model_fields, p)
                #= none:187 =#
                #= none:188 =#
                c₀ = p.surface_tracer_concentration
                #= none:189 =#
                u★ = p.piston_velocity
                #= none:190 =#
                return -u★ * (c₀ - model_fields.c[i, j, p.level])
            end
        #= none:193 =#
        parameters = (surface_tracer_concentration = 1, piston_velocity = 0.1, level = Nz)
        #= none:197 =#
        top_c_bc = FluxBoundaryCondition(tracer_flux; discrete_form = true, parameters)
        #= none:198 =#
        c_bcs = FieldBoundaryConditions(top = top_c_bc)
        #= none:205 =#
        model_no_bc = HydrostaticFreeSurfaceModel(; grid, tracer_advection = WENO(), tracers = :c, velocities = PrescribedVelocityFields(; u, v), closure = diffusion)
        #= none:211 =#
        model_bc = HydrostaticFreeSurfaceModel(; grid, tracer_advection = WENO(), tracers = :c, velocities = PrescribedVelocityFields(; u, v), boundary_conditions = (; c = c_bcs), closure = diffusion)
        #= none:218 =#
        models = [model_no_bc, model_bc]
        #= none:220 =#
        #= none:220 =# @show "Advection-diffusion results, first without then with flux BC"
        #= none:222 =#
        for i = 1:2
            #= none:224 =#
            (κ₁, κ₂) = (0.9, 1.1)
            #= none:225 =#
            c²₁ = stable_diffusion!(models[i], 1, κ₁)
            #= none:226 =#
            c²₂ = stable_diffusion!(models[i], 1, κ₂)
            #= none:227 =#
            dc²_dκ_fd = (c²₂ - c²₁) / (κ₂ - κ₁)
            #= none:230 =#
            amplitude = 1.0
            #= none:231 =#
            κ = 1.0
            #= none:232 =#
            dmodel = Enzyme.make_zero(models[i])
            #= none:233 =#
            set_diffusivity!(dmodel, 0)
            #= none:235 =#
            dc²_dκ = autodiff(Enzyme.set_runtime_activity(Enzyme.Reverse), stable_diffusion!, Duplicated(models[i], dmodel), Const(amplitude), Active(κ))
            #= none:241 =#
            #= none:241 =# @info " \n\nAdvection-diffusion:\nEnzyme computed $(dc²_dκ)\nFinite differences computed $(dc²_dκ_fd)\n"
            #= none:247 =#
            tol = 0.01
            #= none:248 =#
            rel_error = abs((dc²_dκ[1])[3] - dc²_dκ_fd) / abs(dc²_dκ_fd)
            #= none:249 =#
            #= none:249 =# @test rel_error < tol
            #= none:250 =#
        end
    end