
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:2 =#
using OffsetArrays
#= none:4 =#
import Oceananigans.Architectures: on_architecture
#= none:11 =#
DisambiguationTypes = Union{Array, GPUArrays.AbstractGPUArray, BitArray, SubArray{<:Any, <:Any, <:GPUArrays.AbstractGPUArray}, SubArray{<:Any, <:Any, <:Array}, OffsetArray, Tuple, NamedTuple}
#= none:20 =#
on_architecture(arch::Distributed, a::DisambiguationTypes) = begin
        #= none:20 =#
        on_architecture(child_architecture(arch), a)
    end
#= none:22 =#
function on_architecture(new_arch::Distributed, old_grid::LatitudeLongitudeGrid)
    #= none:22 =#
    #= none:23 =#
    child_arch = child_architecture(new_arch)
    #= none:24 =#
    old_properties = (old_grid.Δλᶠᵃᵃ, old_grid.Δλᶜᵃᵃ, old_grid.λᶠᵃᵃ, old_grid.λᶜᵃᵃ, old_grid.Δφᵃᶠᵃ, old_grid.Δφᵃᶜᵃ, old_grid.φᵃᶠᵃ, old_grid.φᵃᶜᵃ, old_grid.Δzᵃᵃᶠ, old_grid.Δzᵃᵃᶜ, old_grid.zᵃᵃᶠ, old_grid.zᵃᵃᶜ, old_grid.Δxᶠᶜᵃ, old_grid.Δxᶜᶠᵃ, old_grid.Δxᶠᶠᵃ, old_grid.Δxᶜᶜᵃ, old_grid.Δyᶠᶜᵃ, old_grid.Δyᶜᶠᵃ, old_grid.Azᶠᶜᵃ, old_grid.Azᶜᶠᵃ, old_grid.Azᶠᶠᵃ, old_grid.Azᶜᶜᵃ)
    #= none:31 =#
    new_properties = Tuple((on_architecture(child_arch, p) for p = old_properties))
    #= none:33 =#
    (TX, TY, TZ) = topology(old_grid)
    #= none:35 =#
    return LatitudeLongitudeGrid{TX, TY, TZ}(new_arch, old_grid.Nx, old_grid.Ny, old_grid.Nz, old_grid.Hx, old_grid.Hy, old_grid.Hz, old_grid.Lx, old_grid.Ly, old_grid.Lz, new_properties..., old_grid.radius)
end
#= none:43 =#
function on_architecture(new_arch::Distributed, old_grid::RectilinearGrid)
    #= none:43 =#
    #= none:44 =#
    child_arch = child_architecture(new_arch)
    #= none:45 =#
    old_properties = (old_grid.Δxᶠᵃᵃ, old_grid.Δxᶜᵃᵃ, old_grid.xᶠᵃᵃ, old_grid.xᶜᵃᵃ, old_grid.Δyᵃᶠᵃ, old_grid.Δyᵃᶜᵃ, old_grid.yᵃᶠᵃ, old_grid.yᵃᶜᵃ, old_grid.Δzᵃᵃᶠ, old_grid.Δzᵃᵃᶜ, old_grid.zᵃᵃᶠ, old_grid.zᵃᵃᶜ)
    #= none:49 =#
    new_properties = Tuple((on_architecture(child_arch, p) for p = old_properties))
    #= none:51 =#
    (TX, TY, TZ) = topology(old_grid)
    #= none:53 =#
    return RectilinearGrid{TX, TY, TZ}(new_arch, old_grid.Nx, old_grid.Ny, old_grid.Nz, old_grid.Hx, old_grid.Hy, old_grid.Hz, old_grid.Lx, old_grid.Ly, old_grid.Lz, new_properties...)
end