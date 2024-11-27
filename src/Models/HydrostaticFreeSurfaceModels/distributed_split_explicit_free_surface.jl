
#= none:1 =#
using Oceananigans.AbstractOperations: GridMetricOperation, Δz
#= none:2 =#
using Oceananigans.DistributedComputations: DistributedGrid, DistributedField
#= none:3 =#
using Oceananigans.DistributedComputations: SynchronizedDistributed, synchronize_communication!
#= none:4 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: SplitExplicitState, SplitExplicitFreeSurface
#= none:6 =#
import Oceananigans.Models.HydrostaticFreeSurfaceModels: materialize_free_surface, SplitExplicitAuxiliaryFields
#= none:8 =#
function SplitExplicitAuxiliaryFields(grid::DistributedGrid)
    #= none:8 =#
    #= none:10 =#
    Gᵁ = Field((Face, Center, Nothing), grid)
    #= none:11 =#
    Gⱽ = Field((Center, Face, Nothing), grid)
    #= none:13 =#
    Hᶠᶜ = Field((Face, Center, Nothing), grid)
    #= none:14 =#
    Hᶜᶠ = Field((Center, Face, Nothing), grid)
    #= none:16 =#
    calculate_column_height!(Hᶠᶜ, (Face, Center, Center))
    #= none:17 =#
    calculate_column_height!(Hᶜᶠ, (Center, Face, Center))
    #= none:19 =#
    fill_halo_regions!((Hᶠᶜ, Hᶜᶠ))
    #= none:22 =#
    kernel_size = augmented_kernel_size(grid)
    #= none:23 =#
    kernel_offsets = augmented_kernel_offsets(grid)
    #= none:25 =#
    kernel_parameters = KernelParameters(kernel_size, kernel_offsets)
    #= none:27 =#
    return SplitExplicitAuxiliaryFields(Gᵁ, Gⱽ, Hᶠᶜ, Hᶜᶠ, kernel_parameters)
end
#= none:30 =#
#= none:30 =# Core.@doc "Integrate z at locations `location` and set! `height`` with the result" #= none:31 =# @inline(function calculate_column_height!(height, location)
            #= none:31 =#
            #= none:32 =#
            dz = GridMetricOperation(location, Δz, height.grid)
            #= none:33 =#
            return sum!(height, dz)
        end)
#= none:36 =#
#= none:36 =# @inline function augmented_kernel_size(grid::DistributedGrid)
        #= none:36 =#
        #= none:37 =#
        (Nx, Ny, _) = size(grid)
        #= none:38 =#
        (Hx, Hy, _) = halo_size(grid)
        #= none:40 =#
        (Tx, Ty, _) = topology(grid)
        #= none:42 =#
        (Rx, Ry, _) = (architecture(grid)).ranks
        #= none:44 =#
        Ax = if Rx == 1
                Nx
            else
                if Tx == RightConnected || Tx == LeftConnected
                    (Nx + Hx) - 1
                else
                    (Nx + 2Hx) - 2
                end
            end
        #= none:45 =#
        Ay = if Ry == 1
                Ny
            else
                if Ty == RightConnected || Ty == LeftConnected
                    (Ny + Hy) - 1
                else
                    (Ny + 2Hy) - 2
                end
            end
        #= none:47 =#
        return (Ax, Ay)
    end
#= none:50 =#
#= none:50 =# @inline function augmented_kernel_offsets(grid::DistributedGrid)
        #= none:50 =#
        #= none:51 =#
        (Hx, Hy, _) = halo_size(grid)
        #= none:52 =#
        (Tx, Ty, _) = topology(grid)
        #= none:54 =#
        (Rx, Ry, _) = (architecture(grid)).ranks
        #= none:56 =#
        Ax = if Rx == 1 || Tx == RightConnected
                0
            else
                -Hx + 1
            end
        #= none:57 =#
        Ay = if Ry == 1 || Ty == RightConnected
                0
            else
                -Hy + 1
            end
        #= none:59 =#
        return (Ax, Ay)
    end
#= none:63 =#
function materialize_free_surface(free_surface::SplitExplicitFreeSurface, velocities, grid::DistributedGrid)
    #= none:63 =#
    #= none:65 =#
    settings = free_surface.settings
    #= none:67 =#
    old_halos = halo_size(grid)
    #= none:68 =#
    Nsubsteps = length(settings.substepping.averaging_weights)
    #= none:70 =#
    extended_halos = distributed_split_explicit_halos(old_halos, Nsubsteps + 1, grid)
    #= none:71 =#
    extended_grid = with_halo(extended_halos, grid)
    #= none:73 =#
    Nze = size(extended_grid, 3)
    #= none:74 =#
    η = ZFaceField(extended_grid, indices = (:, :, Nze + 1))
    #= none:76 =#
    return SplitExplicitFreeSurface(η, SplitExplicitState(extended_grid, settings.timestepper), SplitExplicitAuxiliaryFields(extended_grid), free_surface.gravitational_acceleration, free_surface.settings)
end
#= none:83 =#
#= none:83 =# @inline function distributed_split_explicit_halos(old_halos, step_halo, grid::DistributedGrid)
        #= none:83 =#
        #= none:85 =#
        (Rx, Ry, _) = (architecture(grid)).ranks
        #= none:87 =#
        Ax = if Rx == 1
                old_halos[1]
            else
                max(step_halo, old_halos[1])
            end
        #= none:88 =#
        Ay = if Ry == 1
                old_halos[2]
            else
                max(step_halo, old_halos[2])
            end
        #= none:90 =#
        return (Ax, Ay, old_halos[3])
    end
#= none:93 =#
const DistributedSplitExplicit = SplitExplicitFreeSurface{<:DistributedField}
#= none:95 =#
wait_free_surface_communication!(::DistributedSplitExplicit, ::SynchronizedDistributed) = begin
        #= none:95 =#
        nothing
    end
#= none:97 =#
function wait_free_surface_communication!(free_surface::DistributedSplitExplicit, arch)
    #= none:97 =#
    #= none:99 =#
    state = free_surface.state
    #= none:101 =#
    for field = (state.U̅, state.V̅)
        #= none:102 =#
        synchronize_communication!(field)
        #= none:103 =#
    end
    #= none:105 =#
    auxiliary = free_surface.auxiliary
    #= none:107 =#
    for field = (auxiliary.Gᵁ, auxiliary.Gⱽ)
        #= none:108 =#
        synchronize_communication!(field)
        #= none:109 =#
    end
    #= none:111 =#
    return nothing
end