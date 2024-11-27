
#= none:1 =#
using DataDeps
#= none:3 =#
ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"
#= none:5 =#
dd = DataDep("cubed_sphere_32_grid", "Conformal cubed sphere grid with 32×32 grid points on each face", "https://github.com/glwagner/OceananigansArtifacts.jl/raw/main/cubed_sphere_grids/cs32_with_4_halos/cubed_sphere_32_grid_with_4_halos.jld2")
#= none:9 =#
DataDeps.register(dd)
#= none:13 =#
datadep"cubed_sphere_32_grid"
#= none:17 =#
path = "https://github.com/glwagner/OceananigansArtifacts.jl/raw/main/data_for_regression_tests/"
#= none:19 =#
dh = DataDep("regression_test_data", "Data for Regression tests", [path * "hydrostatic_free_turbulence_regression_Periodic_ImplicitFreeSurface.jld2", path * "hydrostatic_free_turbulence_regression_Periodic_ExplicitFreeSurface.jld2", path * "hydrostatic_free_turbulence_regression_Periodic_SplitExplicitFreeSurface.jld2", path * "hydrostatic_free_turbulence_regression_Bounded_ImplicitFreeSurface.jld2", path * "hydrostatic_free_turbulence_regression_Bounded_ExplicitFreeSurface.jld2", path * "hydrostatic_free_turbulence_regression_Bounded_SplitExplicitFreeSurface.jld2", path * "ocean_large_eddy_simulation_AnisotropicMinimumDissipation_iteration10000.jld2", path * "ocean_large_eddy_simulation_AnisotropicMinimumDissipation_iteration10010.jld2", path * "ocean_large_eddy_simulation_SmagorinskyLilly_iteration10000.jld2", path * "ocean_large_eddy_simulation_SmagorinskyLilly_iteration10010.jld2", path * "rayleigh_benard_iteration1000.jld2", path * "rayleigh_benard_iteration1100.jld2", path * "thermal_bubble_regression.nc"])
#= none:36 =#
DataDeps.register(dh)
#= none:38 =#
datadep"regression_test_data"