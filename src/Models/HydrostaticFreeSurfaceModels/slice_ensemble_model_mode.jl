
#= none:1 =#
using Oceananigans.Grids: Flat, Bounded, y_domain
#= none:2 =#
using Oceananigans.TurbulenceClosures: AbstractTurbulenceClosure
#= none:3 =#
using Oceananigans.TurbulenceClosures.TKEBasedVerticalDiffusivities: _top_tke_flux, CATKEVDArray
#= none:5 =#
import Oceananigans.Grids: validate_size, validate_halo, XYRegularRG
#= none:6 =#
import Oceananigans.TurbulenceClosures: time_discretization, compute_diffusivities!, with_tracers
#= none:7 =#
import Oceananigans.TurbulenceClosures: ∂ⱼ_τ₁ⱼ, ∂ⱼ_τ₂ⱼ, ∂ⱼ_τ₃ⱼ, ∇_dot_qᶜ
#= none:8 =#
import Oceananigans.TurbulenceClosures.TKEBasedVerticalDiffusivities: top_tke_flux
#= none:9 =#
import Oceananigans.Coriolis: x_f_cross_U, y_f_cross_U, z_f_cross_U
#= none:15 =#
const YZSliceGrid = Union{AbstractGrid{<:AbstractFloat, <:Flat, <:Bounded, <:Bounded}, AbstractGrid{<:AbstractFloat, <:Flat, <:Periodic, <:Bounded}}
#= none:18 =#
#= none:18 =# @inline function ∂ⱼ_τ₁ⱼ(i, j, k, grid::YZSliceGrid, closure_array::ClosureArray, args...)
        #= none:18 =#
        #= none:19 =#
        #= none:19 =# @inbounds closure = closure_array[i]
        #= none:20 =#
        return ∂ⱼ_τ₁ⱼ(i, j, k, grid, closure, args...)
    end
#= none:23 =#
#= none:23 =# @inline function ∂ⱼ_τ₂ⱼ(i, j, k, grid::YZSliceGrid, closure_array::ClosureArray, args...)
        #= none:23 =#
        #= none:24 =#
        #= none:24 =# @inbounds closure = closure_array[i]
        #= none:25 =#
        return ∂ⱼ_τ₂ⱼ(i, j, k, grid, closure, args...)
    end
#= none:28 =#
#= none:28 =# @inline function ∇_dot_qᶜ(i, j, k, grid::YZSliceGrid, closure_array::ClosureArray, c, tracer_index, args...)
        #= none:28 =#
        #= none:29 =#
        #= none:29 =# @inbounds closure = closure_array[i]
        #= none:30 =#
        return ∇_dot_qᶜ(i, j, k, grid, closure, c, tracer_index, args...)
    end
#= none:33 =#
struct SliceEnsembleSize
    #= none:34 =#
    ensemble::Int
    #= none:35 =#
    Ny::Int
    #= none:36 =#
    Nz::Int
    #= none:37 =#
    Hy::Int
    #= none:38 =#
    Hz::Int
end
#= none:41 =#
SliceEnsembleSize(; size, ensemble = 0, halo = (1, 1)) = begin
        #= none:41 =#
        SliceEnsembleSize(ensemble, size[1], size[2], halo[1], halo[2])
    end
#= none:43 =#
validate_size(TX, TY, TZ, e::SliceEnsembleSize) = begin
        #= none:43 =#
        tuple(e.ensemble, e.Ny, e.Nz)
    end
#= none:44 =#
validate_halo(TX, TY, TZ, size, e::SliceEnsembleSize) = begin
        #= none:44 =#
        tuple(0, e.Hy, e.Hz)
    end
#= none:50 =#
#= none:50 =# Core.@doc " Compute the flux of TKE through the surface / top boundary. " #= none:51 =# @inline(function top_tke_flux(i, j, grid::YZSliceGrid, clock, fields, parameters, closure_array::CATKEVDArray, buoyancy)
            #= none:51 =#
            #= none:52 =#
            top_tracer_bcs = parameters.top_tracer_boundary_conditions
            #= none:53 =#
            top_velocity_bcs = parameters.top_velocity_boundary_conditions
            #= none:54 =#
            #= none:54 =# @inbounds closure = closure_array[i]
            #= none:56 =#
            return _top_tke_flux(i, j, grid, closure.surface_TKE_flux, closure, buoyancy, fields, top_tracer_bcs, top_velocity_bcs, clock)
        end)
#= none:60 =#
#= none:60 =# @inline function hydrostatic_turbulent_kinetic_energy_tendency(i, j, k, grid::YZSliceGrid, val_tracer_index::Val{tracer_index}, advection, closure_array::CATKEVDArray, args...) where tracer_index
        #= none:60 =#
        #= none:65 =#
        #= none:65 =# @inbounds closure = closure_array[i]
        #= none:66 =#
        return hydrostatic_turbulent_kinetic_energy_tendency(i, j, k, grid, val_tracer_index, advection, closure, args...)
    end
#= none:73 =#
const CoriolisVector = AbstractVector{<:AbstractRotation}
#= none:75 =#
#= none:75 =# @inline x_f_cross_U(i, j, k, grid::YZSliceGrid, coriolis::CoriolisVector, U) = begin
            #= none:75 =#
            #= none:75 =# @inbounds x_f_cross_U(i, j, k, grid, coriolis[i], U)
        end
#= none:76 =#
#= none:76 =# @inline y_f_cross_U(i, j, k, grid::YZSliceGrid, coriolis::CoriolisVector, U) = begin
            #= none:76 =#
            #= none:76 =# @inbounds y_f_cross_U(i, j, k, grid, coriolis[i], U)
        end
#= none:77 =#
#= none:77 =# @inline z_f_cross_U(i, j, k, grid::YZSliceGrid, coriolis::CoriolisVector, U) = begin
            #= none:77 =#
            #= none:77 =# @inbounds z_f_cross_U(i, j, k, grid, coriolis[i], U)
        end
#= none:79 =#
function FFTImplicitFreeSurfaceSolver(grid::YZSliceGrid, settings = nothing, gravitational_acceleration = nothing)
    #= none:79 =#
    #= none:80 =#
    grid isa XYRegularRG || throw(ArgumentError("FFTImplicitFreeSurfaceSolver requires horizontally-regular rectilinear grids."))
    #= none:84 =#
    TY = topology(grid, 2)
    #= none:86 =#
    sz = SliceEnsembleSize(size = (grid.Ny, 1), ensemble = grid.Nx, halo = (grid.Hy, 0))
    #= none:88 =#
    horizontal_grid = RectilinearGrid(architecture(grid); topology = (Flat, TY, Flat), size = sz, halo = grid.Hy, y = y_domain(grid))
    #= none:94 =#
    solver = FFTBasedPoissonSolver(horizontal_grid)
    #= none:95 =#
    right_hand_side = solver.storage
    #= none:97 =#
    return FFTImplicitFreeSurfaceSolver(solver, grid, horizontal_grid, right_hand_side)
end