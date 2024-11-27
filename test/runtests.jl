
#= none:1 =#
using Pkg
#= none:3 =#
include("dependencies_for_runtests.jl")
#= none:5 =#
group = get(ENV, "TEST_GROUP", :all) |> Symbol
#= none:6 =#
test_file = get(ENV, "TEST_FILE", :none) |> Symbol
#= none:10 =#
if test_file != :none
    #= none:11 =#
    group = :none
end
#= none:19 =#
CUDA.allowscalar() do 
    #= none:21 =#
    #= none:21 =# @testset "Oceananigans" begin
            #= none:23 =#
            if test_file != :none
                #= none:24 =#
                #= none:24 =# @testset "Single file test" begin
                        #= none:25 =#
                        include(String(test_file))
                    end
            end
            #= none:30 =#
            if group == :init || group == :all
                #= none:31 =#
                Pkg.instantiate(; verbose = true)
                #= none:32 =#
                Pkg.precompile(; strict = true)
                #= none:33 =#
                Pkg.status()
                #= none:35 =#
                try
                    #= none:36 =#
                    MPI.versioninfo()
                catch
                    #= none:37 =#
                end
                #= none:39 =#
                try
                    #= none:40 =#
                    CUDA.precompile_runtime()
                    #= none:41 =#
                    CUDA.versioninfo()
                catch
                    #= none:42 =#
                end
            end
            #= none:46 =#
            if group == :unit || group == :all
                #= none:47 =#
                #= none:47 =# @testset "Unit tests" begin
                        #= none:48 =#
                        include("test_grids.jl")
                        #= none:49 =#
                        include("test_operators.jl")
                        #= none:50 =#
                        include("test_vector_rotation_operators.jl")
                        #= none:51 =#
                        include("test_boundary_conditions.jl")
                        #= none:52 =#
                        include("test_field.jl")
                        #= none:53 =#
                        include("test_regrid.jl")
                        #= none:54 =#
                        include("test_field_scans.jl")
                        #= none:55 =#
                        include("test_halo_regions.jl")
                        #= none:56 =#
                        include("test_coriolis.jl")
                        #= none:57 =#
                        include("test_buoyancy.jl")
                        #= none:58 =#
                        include("test_stokes_drift.jl")
                        #= none:59 =#
                        include("test_utils.jl")
                        #= none:60 =#
                        include("test_schedules.jl")
                    end
            end
            #= none:64 =#
            if group == :abstract_operations || group == :all
                #= none:65 =#
                #= none:65 =# @testset "AbstractOperations and broadcasting tests" begin
                        #= none:66 =#
                        include("test_abstract_operations.jl")
                        #= none:67 =#
                        include("test_conditional_reductions.jl")
                        #= none:68 =#
                        include("test_computed_field.jl")
                        #= none:69 =#
                        include("test_broadcasting.jl")
                    end
            end
            #= none:73 =#
            if group == :poisson_solvers_1 || group == :all
                #= none:74 =#
                #= none:74 =# @testset "Poisson Solvers 1" begin
                        #= none:75 =#
                        include("test_poisson_solvers.jl")
                    end
            end
            #= none:79 =#
            if group == :poisson_solvers_2 || group == :all
                #= none:80 =#
                #= none:80 =# @testset "Poisson Solvers 2" begin
                        #= none:81 =#
                        include("test_poisson_solvers_stretched_grids.jl")
                    end
            end
            #= none:85 =#
            if group == :matrix_poisson_solvers || group == :all
                #= none:86 =#
                #= none:86 =# @testset "Matrix Poisson Solvers" begin
                        #= none:87 =#
                        include("test_matrix_poisson_solver.jl")
                    end
            end
            #= none:91 =#
            if group == :general_solvers || group == :all
                #= none:92 =#
                #= none:92 =# @testset "General Solvers" begin
                        #= none:93 =#
                        include("test_batched_tridiagonal_solver.jl")
                        #= none:94 =#
                        include("test_preconditioned_conjugate_gradient_solver.jl")
                    end
            end
            #= none:99 =#
            if group == :simulation || group == :all
                #= none:100 =#
                #= none:100 =# @testset "Simulation tests" begin
                        #= none:101 =#
                        include("test_simulations.jl")
                        #= none:102 =#
                        include("test_diagnostics.jl")
                        #= none:103 =#
                        include("test_output_writers.jl")
                        #= none:104 =#
                        include("test_netcdf_output_writer.jl")
                        #= none:105 =#
                        include("test_output_readers.jl")
                    end
            end
            #= none:110 =#
            if group == :lagrangian || group == :all
                #= none:111 =#
                #= none:111 =# @testset "Lagrangian particle tracking tests" begin
                        #= none:112 =#
                        include("test_lagrangian_particle_tracking.jl")
                    end
            end
            #= none:117 =#
            if group == :time_stepping_1 || group == :all
                #= none:118 =#
                #= none:118 =# @testset "Model and time stepping tests (part 1)" begin
                        #= none:119 =#
                        include("test_nonhydrostatic_models.jl")
                        #= none:120 =#
                        include("test_time_stepping.jl")
                    end
            end
            #= none:124 =#
            if group == :time_stepping_2 || group == :all
                #= none:125 =#
                #= none:125 =# @testset "Model and time stepping tests (part 2)" begin
                        #= none:126 =#
                        include("test_boundary_conditions_integration.jl")
                        #= none:127 =#
                        include("test_forcings.jl")
                        #= none:128 =#
                        include("test_immersed_advection.jl")
                    end
            end
            #= none:132 =#
            if group == :time_stepping_3 || group == :all
                #= none:133 =#
                #= none:133 =# @testset "Model and time stepping tests (part 3)" begin
                        #= none:134 =#
                        include("test_dynamics.jl")
                        #= none:135 =#
                        include("test_biogeochemistry.jl")
                        #= none:136 =#
                        include("test_seawater_density.jl")
                    end
            end
            #= none:140 =#
            if group == :turbulence_closures || group == :all
                #= none:141 =#
                #= none:141 =# @testset "Turbulence closures tests" begin
                        #= none:142 =#
                        include("test_turbulence_closures.jl")
                    end
            end
            #= none:146 =#
            if group == :shallow_water || group == :all
                #= none:147 =#
                include("test_shallow_water_models.jl")
            end
            #= none:150 =#
            if group == :hydrostatic_free_surface || group == :all
                #= none:151 =#
                #= none:151 =# @testset "HydrostaticFreeSurfaceModel tests" begin
                        #= none:152 =#
                        include("test_hydrostatic_free_surface_models.jl")
                        #= none:153 =#
                        include("test_ensemble_hydrostatic_free_surface_models.jl")
                        #= none:154 =#
                        include("test_hydrostatic_free_surface_immersed_boundaries.jl")
                        #= none:155 =#
                        include("test_vertical_vorticity_field.jl")
                        #= none:156 =#
                        include("test_implicit_free_surface_solver.jl")
                        #= none:157 =#
                        include("test_split_explicit_free_surface_solver.jl")
                        #= none:158 =#
                        include("test_split_explicit_vertical_integrals.jl")
                        #= none:159 =#
                        include("test_hydrostatic_free_surface_immersed_boundaries_implicit_solve.jl")
                    end
            end
            #= none:164 =#
            if group == :multi_region || group == :all
                #= none:165 =#
                #= none:165 =# @testset "Multi Region tests" begin
                        #= none:166 =#
                        include("test_multi_region_unit.jl")
                        #= none:167 =#
                        include("test_multi_region_advection_diffusion.jl")
                        #= none:168 =#
                        include("test_multi_region_implicit_solver.jl")
                        #= none:169 =#
                        include("test_multi_region_cubed_sphere.jl")
                    end
            end
            #= none:173 =#
            if group == :distributed || group == :all
                #= none:174 =#
                MPI.Initialized() || MPI.Init()
                #= none:175 =#
                archs = test_architectures()
                #= none:176 =#
                include("test_distributed_models.jl")
            end
            #= none:179 =#
            if group == :distributed_solvers || group == :all
                #= none:180 =#
                MPI.Initialized() || MPI.Init()
                #= none:181 =#
                include("test_distributed_transpose.jl")
                #= none:182 =#
                include("test_distributed_poisson_solvers.jl")
            end
            #= none:185 =#
            if group == :distributed_hydrostatic_model || group == :all
                #= none:186 =#
                MPI.Initialized() || MPI.Init()
                #= none:187 =#
                archs = test_architectures()
                #= none:188 =#
                include("test_hydrostatic_regression.jl")
                #= none:189 =#
                include("test_distributed_hydrostatic_model.jl")
            end
            #= none:192 =#
            if group == :distributed_nonhydrostatic_regression || group == :all
                #= none:193 =#
                MPI.Initialized() || MPI.Init()
                #= none:194 =#
                archs = nonhydrostatic_regression_test_architectures()
                #= none:195 =#
                include("test_nonhydrostatic_regression.jl")
            end
            #= none:198 =#
            if group == :nonhydrostatic_regression || group == :all
                #= none:199 =#
                include("test_nonhydrostatic_regression.jl")
            end
            #= none:202 =#
            if group == :hydrostatic_regression || group == :all
                #= none:203 =#
                include("test_hydrostatic_regression.jl")
            end
            #= none:206 =#
            if group == :scripts || group == :all
                #= none:207 =#
                #= none:207 =# @testset "Scripts" begin
                        #= none:208 =#
                        include("test_validation.jl")
                    end
            end
            #= none:213 =#
            if group == :enzyme || group == :all
                #= none:214 =#
                #= none:214 =# @testset "Enzyme extension tests" begin
                        #= none:215 =#
                        include("test_enzyme.jl")
                    end
            end
            #= none:219 =#
            if group == :convergence
                #= none:220 =#
                include("test_convergence.jl")
            end
        end
end