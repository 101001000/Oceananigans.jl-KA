
#= none:1 =#
module NonhydrostaticModels
#= none:1 =#
#= none:3 =#
export NonhydrostaticModel
#= none:5 =#
using DocStringExtensions
#= none:7 =#
using KernelAbstractions: @index, @kernel
#= none:9 =#
using Oceananigans.Utils
#= none:10 =#
using Oceananigans.Grids
#= none:11 =#
using Oceananigans.Solvers
#= none:13 =#
using Oceananigans.DistributedComputations
#= none:14 =#
using Oceananigans.DistributedComputations: reconstruct_global_grid, Distributed
#= none:15 =#
using Oceananigans.DistributedComputations: DistributedFFTBasedPoissonSolver, DistributedFourierTridiagonalPoissonSolver
#= none:16 =#
using Oceananigans.Grids: XYRegularRG, XZRegularRG, YZRegularRG, XYZRegularRG
#= none:17 =#
using Oceananigans.ImmersedBoundaries: ImmersedBoundaryGrid
#= none:18 =#
using Oceananigans.Solvers: GridWithFFTSolver, GridWithFourierTridiagonalSolver
#= none:19 =#
using Oceananigans.Utils: SumOfArrays
#= none:21 =#
import Oceananigans: fields, prognostic_fields
#= none:22 =#
import Oceananigans.Advection: cell_advection_timescale
#= none:23 =#
import Oceananigans.TimeSteppers: step_lagrangian_particles!
#= none:25 =#
function nonhydrostatic_pressure_solver(::Distributed, local_grid::XYZRegularRG)
    #= none:25 =#
    #= none:26 =#
    global_grid = reconstruct_global_grid(local_grid)
    #= none:27 =#
    return DistributedFFTBasedPoissonSolver(global_grid, local_grid)
end
#= none:30 =#
function nonhydrostatic_pressure_solver(::Distributed, local_grid::GridWithFourierTridiagonalSolver)
    #= none:30 =#
    #= none:31 =#
    global_grid = reconstruct_global_grid(local_grid)
    #= none:32 =#
    return DistributedFourierTridiagonalPoissonSolver(global_grid, local_grid)
end
#= none:35 =#
nonhydrostatic_pressure_solver(arch, grid::XYZRegularRG) = begin
        #= none:35 =#
        FFTBasedPoissonSolver(grid)
    end
#= none:36 =#
nonhydrostatic_pressure_solver(arch, grid::GridWithFourierTridiagonalSolver) = begin
        #= none:36 =#
        FourierTridiagonalPoissonSolver(grid)
    end
#= none:39 =#
const IBGWithFFTSolver = ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:GridWithFFTSolver}
#= none:41 =#
function nonhydrostatic_pressure_solver(arch, ibg::IBGWithFFTSolver)
    #= none:41 =#
    #= none:42 =#
    msg = "The FFT-based pressure_solver for NonhydrostaticModels on ImmersedBoundaryGrid\nis approximate and will probably produce velocity fields that are divergent\nadjacent to the immersed boundary. An experimental but improved pressure_solver\nis available which may be used by writing\n\n    using Oceananigans.Solvers: ConjugateGradientPoissonSolver\n    pressure_solver = ConjugateGradientPoissonSolver(grid)\n\nPlease report issues to https://github.com/CliMA/Oceananigans.jl/issues.\n"
    #= none:52 =#
    #= none:52 =# @warn msg
    #= none:54 =#
    return nonhydrostatic_pressure_solver(arch, ibg.underlying_grid)
end
#= none:58 =#
nonhydrostatic_pressure_solver(arch, grid) = begin
        #= none:58 =#
        error("None of the implemented pressure solvers for NonhydrostaticModel are supported on $(summary(grid)).")
    end
#= none:62 =#
nonhydrostatic_pressure_solver(grid) = begin
        #= none:62 =#
        nonhydrostatic_pressure_solver(architecture(grid), grid)
    end
#= none:68 =#
include("nonhydrostatic_model.jl")
#= none:69 =#
include("pressure_field.jl")
#= none:70 =#
include("show_nonhydrostatic_model.jl")
#= none:71 =#
include("set_nonhydrostatic_model.jl")
#= none:77 =#
function cell_advection_timescale(model::NonhydrostaticModel)
    #= none:77 =#
    #= none:78 =#
    grid = model.grid
    #= none:79 =#
    velocities = total_velocities(model)
    #= none:80 =#
    return cell_advection_timescale(grid, velocities)
end
#= none:83 =#
#= none:83 =# Core.@doc "    fields(model::NonhydrostaticModel)\n\nReturn a flattened `NamedTuple` of the fields in `model.velocities`, `model.tracers`, and any\nauxiliary fields for a `NonhydrostaticModel` model.\n" fields(model::NonhydrostaticModel) = begin
            #= none:89 =#
            merge(model.velocities, model.tracers, model.auxiliary_fields, biogeochemical_auxiliary_fields(model.biogeochemistry))
        end
#= none:94 =#
#= none:94 =# Core.@doc "    prognostic_fields(model::HydrostaticFreeSurfaceModel)\n\nReturn a flattened `NamedTuple` of the prognostic fields associated with `NonhydrostaticModel`.\n" prognostic_fields(model::NonhydrostaticModel) = begin
            #= none:99 =#
            merge(model.velocities, model.tracers)
        end
#= none:102 =#
step_lagrangian_particles!(model::NonhydrostaticModel, Δt) = begin
        #= none:102 =#
        step_lagrangian_particles!(model.particles, model, Δt)
    end
#= none:104 =#
include("solve_for_pressure.jl")
#= none:105 =#
include("update_hydrostatic_pressure.jl")
#= none:106 =#
include("update_nonhydrostatic_model_state.jl")
#= none:107 =#
include("pressure_correction.jl")
#= none:108 =#
include("nonhydrostatic_tendency_kernel_functions.jl")
#= none:109 =#
include("compute_nonhydrostatic_tendencies.jl")
#= none:110 =#
include("compute_nonhydrostatic_buffer_tendencies.jl")
end