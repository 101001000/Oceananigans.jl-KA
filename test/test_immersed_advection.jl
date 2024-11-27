
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid, GridFittedBoundary, mask_immersed_field!
#= none:4 =#
using Oceananigans.Advection: _symmetric_interpolate_xᶠᵃᵃ, _symmetric_interpolate_xᶜᵃᵃ, _symmetric_interpolate_yᵃᶠᵃ, _symmetric_interpolate_yᵃᶜᵃ, _biased_interpolate_xᶜᵃᵃ, _biased_interpolate_xᶠᵃᵃ, _biased_interpolate_yᵃᶜᵃ, _biased_interpolate_yᵃᶠᵃ, FluxFormAdvection
#= none:15 =#
advection_schemes = [Centered, UpwindBiased, WENO]
#= none:17 =#
#= none:17 =# @inline advective_order(buffer, ::Type{Centered}) = begin
            #= none:17 =#
            buffer * 2
        end
#= none:18 =#
#= none:18 =# @inline advective_order(buffer, AdvectionType) = begin
            #= none:18 =#
            buffer * 2 - 1
        end
#= none:20 =#
function run_tracer_interpolation_test(c, ibg, scheme)
    #= none:20 =#
    #= none:22 =#
    for i = 6:19, j = 6:19
        #= none:23 =#
        if typeof(scheme) <: Centered
            #= none:24 =#
            #= none:24 =# @test #= none:24 =# CUDA.@allowscalar(_symmetric_interpolate_xᶠᵃᵃ(i + 1, j, 1, ibg, scheme, c) ≈ 1.0)
        else
            #= none:26 =#
            #= none:26 =# @test #= none:26 =# CUDA.@allowscalar(_biased_interpolate_xᶠᵃᵃ(i + 1, j, 1, ibg, scheme, true, c) ≈ 1.0)
            #= none:27 =#
            #= none:27 =# @test #= none:27 =# CUDA.@allowscalar(_biased_interpolate_xᶠᵃᵃ(i + 1, j, 1, ibg, scheme, false, c) ≈ 1.0)
            #= none:28 =#
            #= none:28 =# @test #= none:28 =# CUDA.@allowscalar(_biased_interpolate_yᵃᶠᵃ(i, j + 1, 1, ibg, scheme, true, c) ≈ 1.0)
            #= none:29 =#
            #= none:29 =# @test #= none:29 =# CUDA.@allowscalar(_biased_interpolate_yᵃᶠᵃ(i, j + 1, 1, ibg, scheme, false, c) ≈ 1.0)
        end
        #= none:31 =#
    end
end
#= none:34 =#
function run_tracer_conservation_test(grid, scheme)
    #= none:34 =#
    #= none:36 =#
    model = HydrostaticFreeSurfaceModel(grid = grid, tracers = :c, free_surface = ExplicitFreeSurface(), tracer_advection = scheme, buoyancy = nothing, coriolis = nothing)
    #= none:42 =#
    c = model.tracers.c
    #= none:43 =#
    set!(model, c = 1)
    #= none:44 =#
    fill_halo_regions!(c)
    #= none:46 =#
    η = model.free_surface.η
    #= none:48 =#
    indices = if model.grid isa ImmersedBoundaryGrid
            (5:7, 3:6, 1)
        else
            (2:5, 3:6, 1)
        end
    #= none:50 =#
    interior(η, indices...) .= -0.05
    #= none:51 =#
    fill_halo_regions!(η)
    #= none:53 =#
    wave_speed = sqrt(model.free_surface.gravitational_acceleration)
    #= none:54 =#
    dt = 0.1 / wave_speed
    #= none:55 =#
    for _ = 1:10
        #= none:56 =#
        time_step!(model, dt)
        #= none:57 =#
    end
    #= none:59 =#
    #= none:59 =# @test maximum(c) ≈ 1.0
    #= none:60 =#
    #= none:60 =# @test minimum(c) ≈ 1.0
    #= none:61 =#
    #= none:61 =# @test mean(c) ≈ 1.0
    #= none:63 =#
    return nothing
end
#= none:66 =#
function run_momentum_interpolation_test(u, v, ibg, scheme)
    #= none:66 =#
    #= none:69 =#
    interior(u, 6, :, 1) .= 1.0
    #= none:70 =#
    interior(v, :, 6, 1) .= 1.0
    #= none:72 =#
    for i = 7:19, j = 7:19
        #= none:73 =#
        if typeof(scheme) <: Centered
            #= none:74 =#
            #= none:74 =# @test #= none:74 =# CUDA.@allowscalar(_symmetric_interpolate_xᶜᵃᵃ(i + 1, j, 1, ibg, scheme, u) ≈ 1.0)
            #= none:75 =#
            #= none:75 =# @test #= none:75 =# CUDA.@allowscalar(_symmetric_interpolate_xᶜᵃᵃ(i + 1, j, 1, ibg, scheme, v) ≈ 1.0)
            #= none:76 =#
            #= none:76 =# @test #= none:76 =# CUDA.@allowscalar(_symmetric_interpolate_yᵃᶜᵃ(i, j + 1, 1, ibg, scheme, u) ≈ 1.0)
            #= none:77 =#
            #= none:77 =# @test #= none:77 =# CUDA.@allowscalar(_symmetric_interpolate_yᵃᶜᵃ(i, j + 1, 1, ibg, scheme, v) ≈ 1.0)
        else
            #= none:79 =#
            #= none:79 =# @test #= none:79 =# CUDA.@allowscalar(_biased_interpolate_xᶜᵃᵃ(i + 1, j, 1, ibg, scheme, true, u) ≈ 1.0)
            #= none:80 =#
            #= none:80 =# @test #= none:80 =# CUDA.@allowscalar(_biased_interpolate_xᶜᵃᵃ(i + 1, j, 1, ibg, scheme, false, u) ≈ 1.0)
            #= none:81 =#
            #= none:81 =# @test #= none:81 =# CUDA.@allowscalar(_biased_interpolate_yᵃᶜᵃ(i, j + 1, 1, ibg, scheme, true, u) ≈ 1.0)
            #= none:82 =#
            #= none:82 =# @test #= none:82 =# CUDA.@allowscalar(_biased_interpolate_yᵃᶜᵃ(i, j + 1, 1, ibg, scheme, false, u) ≈ 1.0)
            #= none:84 =#
            #= none:84 =# @test #= none:84 =# CUDA.@allowscalar(_biased_interpolate_xᶜᵃᵃ(i + 1, j, 1, ibg, scheme, true, v) ≈ 1.0)
            #= none:85 =#
            #= none:85 =# @test #= none:85 =# CUDA.@allowscalar(_biased_interpolate_xᶜᵃᵃ(i + 1, j, 1, ibg, scheme, false, v) ≈ 1.0)
            #= none:86 =#
            #= none:86 =# @test #= none:86 =# CUDA.@allowscalar(_biased_interpolate_yᵃᶜᵃ(i, j + 1, 1, ibg, scheme, true, v) ≈ 1.0)
            #= none:87 =#
            #= none:87 =# @test #= none:87 =# CUDA.@allowscalar(_biased_interpolate_yᵃᶜᵃ(i, j + 1, 1, ibg, scheme, false, v) ≈ 1.0)
        end
        #= none:89 =#
    end
    #= none:91 =#
    return nothing
end
#= none:94 =#
for arch = archs
    #= none:95 =#
    #= none:95 =# @testset "Immersed tracer reconstruction" begin
            #= none:96 =#
            #= none:96 =# @info "Running immersed tracer reconstruction tests..."
            #= none:98 =#
            grid = RectilinearGrid(arch, size = (20, 20), extent = (20, 20), halo = (6, 6), topology = (Bounded, Bounded, Flat))
            #= none:99 =#
            ibg = ImmersedBoundaryGrid(grid, GridFittedBoundary(((x, y)->begin
                                #= none:99 =#
                                x < 5 || y < 5
                            end)))
            #= none:101 =#
            c = CenterField(ibg)
            #= none:102 =#
            set!(c, 1)
            #= none:103 =#
            mask_immersed_field!(c)
            #= none:104 =#
            fill_halo_regions!(c)
            #= none:106 =#
            for adv = advection_schemes, buffer = [1, 2, 3, 4, 5]
                #= none:107 =#
                scheme = adv(order = advective_order(buffer, adv))
                #= none:109 =#
                #= none:109 =# @info "  Testing immersed tracer reconstruction [$(typeof(arch)), $(summary(scheme))]"
                #= none:110 =#
                run_tracer_interpolation_test(c, ibg, scheme)
                #= none:111 =#
            end
        end
    #= none:114 =#
    #= none:114 =# @testset "Immersed tracer conservation" begin
            #= none:115 =#
            #= none:115 =# @info "Running immersed tracer conservation tests..."
            #= none:117 =#
            grid = RectilinearGrid(arch, size = (10, 8, 1), extent = (10, 8, 1), halo = (6, 6, 6), topology = (Bounded, Periodic, Bounded))
            #= none:118 =#
            ibg = ImmersedBoundaryGrid(grid, GridFittedBoundary(((x, y, z)->begin
                                #= none:118 =#
                                x < 2
                            end)))
            #= none:120 =#
            for adv = advection_schemes, buffer = [1, 2, 3, 4, 5]
                #= none:121 =#
                scheme = adv(order = advective_order(buffer, adv))
                #= none:123 =#
                for g = [grid, ibg]
                    #= none:124 =#
                    #= none:124 =# @info "  Testing immersed tracer conservation [$(typeof(arch)), $(summary(scheme)), $((typeof(g)).name.wrapper)]"
                    #= none:125 =#
                    run_tracer_conservation_test(g, scheme)
                    #= none:126 =#
                end
                #= none:127 =#
            end
            #= none:129 =#
            for adv = advection_schemes, buffer = [1, 2, 3, 4, 5]
                #= none:130 =#
                directional_scheme = adv(order = advective_order(buffer, adv))
                #= none:131 =#
                scheme = FluxFormAdvection(directional_scheme, directional_scheme, directional_scheme)
                #= none:132 =#
                for g = [grid, ibg]
                    #= none:133 =#
                    #= none:133 =# @info "  Testing immersed tracer conservation [$(typeof(arch)), $(summary(scheme)), $((typeof(g)).name.wrapper)]"
                    #= none:134 =#
                    run_tracer_conservation_test(g, scheme)
                    #= none:135 =#
                end
                #= none:136 =#
            end
        end
    #= none:139 =#
    #= none:139 =# @testset "Immersed momentum reconstruction" begin
            #= none:140 =#
            #= none:140 =# @info "Running immersed momentum recontruction tests..."
            #= none:142 =#
            grid = RectilinearGrid(arch, size = (20, 20), extent = (20, 20), halo = (6, 6), topology = (Bounded, Bounded, Flat))
            #= none:143 =#
            ibg = ImmersedBoundaryGrid(grid, GridFittedBoundary(((x, y)->begin
                                #= none:143 =#
                                x < 5 || y < 5
                            end)))
            #= none:145 =#
            u = XFaceField(ibg)
            #= none:146 =#
            v = YFaceField(ibg)
            #= none:147 =#
            set!(u, 1)
            #= none:148 =#
            set!(v, 1)
            #= none:150 =#
            mask_immersed_field!(u)
            #= none:151 =#
            mask_immersed_field!(v)
            #= none:153 =#
            fill_halo_regions!(u)
            #= none:154 =#
            fill_halo_regions!(v)
            #= none:156 =#
            for adv = advection_schemes, buffer = [1, 2, 3, 4, 5]
                #= none:157 =#
                scheme = adv(order = advective_order(buffer, adv))
                #= none:159 =#
                #= none:159 =# @info "  Testing immersed momentum reconstruction [$(typeof(arch)), $(summary(scheme))]"
                #= none:160 =#
                run_momentum_interpolation_test(u, v, ibg, scheme)
                #= none:161 =#
            end
        end
    #= none:163 =#
end