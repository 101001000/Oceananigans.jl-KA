
#= none:1 =#
using Oceananigans.Operators: Δzᶜᶜᶜ, Δzᶜᶜᶠ
#= none:2 =#
using Oceananigans.ImmersedBoundaries: PartialCellBottom, ImmersedBoundaryGrid
#= none:3 =#
using Oceananigans.Grids: topology
#= none:4 =#
using Oceananigans.Grids: XFlatGrid, YFlatGrid
#= none:6 =#
#= none:6 =# Core.@doc "Update the hydrostatic pressure perturbation pHY′. This is done by integrating\nthe `buoyancy_perturbationᶜᶜᶜ` downwards:\n\n    `pHY′ = ∫ buoyancy_perturbationᶜᶜᶜ dz` from `z=0` down to `z=-Lz`\n" #= none:12 =# @kernel(function _update_hydrostatic_pressure!(pHY′, grid, buoyancy, C)
            #= none:12 =#
            #= none:13 =#
            (i, j) = #= none:13 =# @index(Global, NTuple)
            #= none:15 =#
            #= none:15 =# @inbounds pHY′[i, j, grid.Nz] = -(z_dot_g_bᶜᶜᶠ(i, j, grid.Nz + 1, grid, buoyancy, C)) * Δzᶜᶜᶠ(i, j, grid.Nz + 1, grid)
            #= none:17 =#
            for k = grid.Nz - 1:-1:1
                #= none:18 =#
                #= none:18 =# @inbounds pHY′[i, j, k] = pHY′[i, j, k + 1] - z_dot_g_bᶜᶜᶠ(i, j, k + 1, grid, buoyancy, C) * Δzᶜᶜᶠ(i, j, k + 1, grid)
                #= none:19 =#
            end
        end)
#= none:22 =#
update_hydrostatic_pressure!(model; kwargs...) = begin
        #= none:22 =#
        update_hydrostatic_pressure!(model.grid, model; kwargs...)
    end
#= none:23 =#
update_hydrostatic_pressure!(::AbstractGrid{<:Any, <:Any, <:Any, <:Flat}, model; kwargs...) = begin
        #= none:23 =#
        nothing
    end
#= none:24 =#
update_hydrostatic_pressure!(grid, model; kwargs...) = begin
        #= none:24 =#
        update_hydrostatic_pressure!(model.pressures.pHY′, model.architecture, model.grid, model.buoyancy, model.tracers; kwargs...)
    end
#= none:28 =#
const PCB = PartialCellBottom
#= none:29 =#
const PCBIBG = ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:PCB}
#= none:31 =#
update_hydrostatic_pressure!(pHY′, arch, ibg::PCBIBG, buoyancy, tracers; parameters = p_kernel_parameters(ibg.underlying_grid)) = begin
        #= none:31 =#
        update_hydrostatic_pressure!(pHY′, arch, ibg.underlying_grid, buoyancy, tracers; parameters)
    end
#= none:34 =#
update_hydrostatic_pressure!(pHY′, arch, grid, buoyancy, tracers; parameters = p_kernel_parameters(grid)) = begin
        #= none:34 =#
        launch!(arch, grid, parameters, _update_hydrostatic_pressure!, pHY′, grid, buoyancy, tracers)
    end
#= none:37 =#
update_hydrostatic_pressure!(::Nothing, arch, grid, args...; kw...) = begin
        #= none:37 =#
        nothing
    end
#= none:38 =#
update_hydrostatic_pressure!(::Nothing, arch, ::PCBIBG, args...; kw...) = begin
        #= none:38 =#
        nothing
    end
#= none:41 =#
#= none:41 =# @inline function p_kernel_parameters(grid)
        #= none:41 =#
        #= none:42 =#
        (Nx, Ny, _) = size(grid)
        #= none:43 =#
        (TX, TY, _) = topology(grid)
        #= none:45 =#
        ii = ifelse(TX == Flat, 1:Nx, 0:Nx + 1)
        #= none:46 =#
        jj = ifelse(TY == Flat, 1:Ny, 0:Ny + 1)
        #= none:48 =#
        return KernelParameters(ii, jj)
    end