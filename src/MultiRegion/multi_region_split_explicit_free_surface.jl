
#= none:1 =#
using Oceananigans.Utils
#= none:2 =#
using Oceananigans.AbstractOperations: GridMetricOperation, Δz
#= none:3 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: SplitExplicitFreeSurface, SplitExplicitSettings, SplitExplicitState, FixedSubstepNumber, FixedTimeStepSize, calculate_substeps
#= none:9 =#
import Oceananigans.Models.HydrostaticFreeSurfaceModels: materialize_free_surface, SplitExplicitAuxiliaryFields
#= none:11 =#
function SplitExplicitAuxiliaryFields(grid::MultiRegionGrids)
    #= none:11 =#
    #= none:13 =#
    Gᵁ = Field((Face, Center, Nothing), grid)
    #= none:14 =#
    Gⱽ = Field((Center, Face, Nothing), grid)
    #= none:16 =#
    Hᶠᶜ = Field((Face, Center, Nothing), grid)
    #= none:17 =#
    Hᶜᶠ = Field((Center, Face, Nothing), grid)
    #= none:19 =#
    #= none:19 =# @apply_regionally calculate_column_height!(Hᶠᶜ, (Face, Center, Center))
    #= none:20 =#
    #= none:20 =# @apply_regionally calculate_column_height!(Hᶜᶠ, (Center, Face, Center))
    #= none:22 =#
    fill_halo_regions!((Hᶠᶜ, Hᶜᶠ))
    #= none:25 =#
    #= none:25 =# @apply_regionally kernel_size = augmented_kernel_size(grid, grid.partition)
    #= none:26 =#
    #= none:26 =# @apply_regionally kernel_offsets = augmented_kernel_offsets(grid, grid.partition)
    #= none:28 =#
    #= none:28 =# @apply_regionally kernel_parameters = KernelParameters(kernel_size, kernel_offsets)
    #= none:30 =#
    return SplitExplicitAuxiliaryFields(Gᵁ, Gⱽ, Hᶠᶜ, Hᶜᶠ, kernel_parameters)
end
#= none:33 =#
#= none:33 =# @inline function calculate_column_height!(height, location)
        #= none:33 =#
        #= none:34 =#
        dz = GridMetricOperation(location, Δz, height.grid)
        #= none:35 =#
        sum!(height, dz)
        #= none:36 =#
        return nothing
    end
#= none:39 =#
#= none:39 =# @inline augmented_kernel_size(grid, ::XPartition) = begin
            #= none:39 =#
            ((size(grid, 1) + 2 * (halo_size(grid))[1]) - 2, size(grid, 2))
        end
#= none:40 =#
#= none:40 =# @inline augmented_kernel_size(grid, ::YPartition) = begin
            #= none:40 =#
            (size(grid, 1), (size(grid, 2) + 2 * (halo_size(grid))[2]) - 2)
        end
#= none:41 =#
#= none:41 =# @inline augmented_kernel_size(grid, ::CubedSpherePartition) = begin
            #= none:41 =#
            ((size(grid, 1) + 2 * (halo_size(grid))[1]) - 2, (size(grid, 2) + 2 * (halo_size(grid))[2]) - 2)
        end
#= none:43 =#
#= none:43 =# @inline augmented_kernel_offsets(grid, ::XPartition) = begin
            #= none:43 =#
            (-((halo_size(grid))[1]) + 1, 0)
        end
#= none:44 =#
#= none:44 =# @inline augmented_kernel_offsets(grid, ::YPartition) = begin
            #= none:44 =#
            (0, -((halo_size(grid))[2]) + 1)
        end
#= none:45 =#
#= none:45 =# @inline augmented_kernel_offsets(grid, ::CubedSpherePartition) = begin
            #= none:45 =#
            (-((halo_size(grid))[2]) + 1, -((halo_size(grid))[2]) + 1)
        end
#= none:48 =#
function materialize_free_surface(free_surface::SplitExplicitFreeSurface, velocities, grid::MultiRegionGrids)
    #= none:48 =#
    #= none:49 =#
    settings = SplitExplicitSettings(grid; free_surface.settings.settings_kwargs...)
    #= none:51 =#
    settings.substepping isa FixedTimeStepSize && throw(ArgumentError("SplitExplicitFreeSurface on MultiRegionGrids only suports FixedSubstepNumber; re-initialize SplitExplicitFreeSurface using substeps kwarg"))
    #= none:54 =#
    switch_device!(grid.devices[1])
    #= none:56 =#
    old_halos = halo_size(getregion(grid, 1))
    #= none:57 =#
    Nsubsteps = calculate_substeps(settings.substepping)
    #= none:59 =#
    new_halos = multiregion_split_explicit_halos(old_halos, Nsubsteps + 1, grid.partition)
    #= none:60 =#
    new_grid = with_halo(new_halos, grid)
    #= none:62 =#
    η = ZFaceField(new_grid, indices = (:, :, size(new_grid, 3) + 1))
    #= none:64 =#
    return SplitExplicitFreeSurface(η, SplitExplicitState(new_grid, free_surface.settings.timestepper), SplitExplicitAuxiliaryFields(new_grid), free_surface.gravitational_acceleration, free_surface.settings)
end
#= none:71 =#
#= none:71 =# @inline multiregion_split_explicit_halos(old_halos, step_halo, ::XPartition) = begin
            #= none:71 =#
            (max(step_halo, old_halos[1]), old_halos[2], old_halos[3])
        end
#= none:72 =#
#= none:72 =# @inline multiregion_split_explicit_halos(old_halos, step_halo, ::YPartition) = begin
            #= none:72 =#
            (old_halos[1], max(step_halo, old_halo[2]), old_halos[3])
        end