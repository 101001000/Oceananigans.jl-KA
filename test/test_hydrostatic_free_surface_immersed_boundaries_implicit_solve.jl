
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid, GridFittedBottom
#= none:4 =#
using Oceananigans.Architectures: on_architecture
#= none:5 =#
using Oceananigans.TurbulenceClosures
#= none:6 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: compute_vertically_integrated_volume_flux!, compute_implicit_free_surface_right_hand_side!, implicit_free_surface_step!, pressure_correct_velocities!
#= none:11 =#
#= none:11 =# @testset "Immersed boundaries test divergent flow solve with hydrostatic free surface models" begin
        #= none:12 =#
        for arch = archs
            #= none:13 =#
            A = typeof(arch)
            #= none:14 =#
            #= none:14 =# @info "Testing immersed boundaries divergent flow solve [$(A)]"
            #= none:16 =#
            Nx = 11
            #= none:17 =#
            Ny = 11
            #= none:18 =#
            Nz = 1
            #= none:20 =#
            underlying_grid = RectilinearGrid(arch, size = (Nx, Ny, Nz), extent = (Nx, Ny, 1), halo = (3, 3, 3), topology = (Periodic, Periodic, Bounded))
            #= none:26 =#
            imm1 = floor(Int, (Nx + 1) / 2)
            #= none:27 =#
            imp1 = floor(Int, (Nx + 1) / 2) + 1
            #= none:28 =#
            jmm1 = floor(Int, (Ny + 1) / 2)
            #= none:29 =#
            jmp1 = floor(Int, (Ny + 1) / 2) + 1
            #= none:31 =#
            bottom = [-1.0 for j = 1:Ny, i = 1:Nx]
            #= none:32 =#
            bottom[imm1 - 1:imp1 + 1, jmm1 - 1:jmp1 + 1] .= 0
            #= none:34 =#
            B = on_architecture(arch, bottom)
            #= none:35 =#
            grid = ImmersedBoundaryGrid(underlying_grid, GridFittedBottom(B))
            #= none:37 =#
            free_surfaces = [ImplicitFreeSurface(solver_method = :HeptadiagonalIterativeSolver, gravitational_acceleration = 1.0), ImplicitFreeSurface(solver_method = :PreconditionedConjugateGradient, gravitational_acceleration = 1.0), ImplicitFreeSurface(gravitational_acceleration = 1.0)]
            #= none:41 =#
            sol = ()
            #= none:42 =#
            f = ()
            #= none:44 =#
            for free_surface = free_surfaces
                #= none:46 =#
                model = HydrostaticFreeSurfaceModel(; grid, free_surface, buoyancy = nothing, tracers = nothing, closure = nothing)
                #= none:52 =#
                (u, v, w) = model.velocities
                #= none:53 =#
                u[imm1, jmm1, 1:Nz] .= 1
                #= none:54 =#
                u[imp1, jmm1, 1:Nz] .= -1
                #= none:55 =#
                v[imm1, jmm1, 1:Nz] .= 1
                #= none:56 =#
                v[imm1, jmp1, 1:Nz] .= -1
                #= none:58 =#
                implicit_free_surface_step!(model.free_surface, model, 1.0, 1.5)
                #= none:60 =#
                sol = (sol..., model.free_surface.η)
                #= none:61 =#
                f = (f..., model.free_surface)
                #= none:62 =#
            end
            #= none:64 =#
            #= none:64 =# @test all(interior(sol[1]) .≈ interior(sol[2]) .≈ interior(sol[3]))
            #= none:65 =#
        end
    end