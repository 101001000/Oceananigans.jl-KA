
#= none:1 =#
import Oceananigans.TimeSteppers: calculate_pressure_correction!, pressure_correct_velocities!
#= none:3 =#
calculate_pressure_correction!(::HydrostaticFreeSurfaceModel, Δt) = begin
        #= none:3 =#
        nothing
    end
#= none:9 =#
const HFSM = HydrostaticFreeSurfaceModel
#= none:10 =#
const ExplicitFreeSurfaceHFSM = HFSM{<:Any, <:Any, <:Any, <:ExplicitFreeSurface}
#= none:11 =#
const ImplicitFreeSurfaceHFSM = HFSM{<:Any, <:Any, <:Any, <:ImplicitFreeSurface}
#= none:12 =#
const SplitExplicitFreeSurfaceHFSM = HFSM{<:Any, <:Any, <:Any, <:SplitExplicitFreeSurface}
#= none:14 =#
pressure_correct_velocities!(model::ExplicitFreeSurfaceHFSM, Δt; kwargs...) = begin
        #= none:14 =#
        nothing
    end
#= none:20 =#
function pressure_correct_velocities!(model::ImplicitFreeSurfaceHFSM, Δt)
    #= none:20 =#
    #= none:22 =#
    launch!(model.architecture, model.grid, :xyz, _barotropic_pressure_correction, model.velocities, model.grid, Δt, model.free_surface.gravitational_acceleration, model.free_surface.η)
    #= none:30 =#
    return nothing
end
#= none:33 =#
calculate_free_surface_tendency!(grid, ::ImplicitFreeSurfaceHFSM, args...) = begin
        #= none:33 =#
        nothing
    end
#= none:34 =#
calculate_free_surface_tendency!(grid, ::SplitExplicitFreeSurfaceHFSM, args...) = begin
        #= none:34 =#
        nothing
    end
#= none:36 =#
function pressure_correct_velocities!(model::SplitExplicitFreeSurfaceHFSM, Δt)
    #= none:36 =#
    #= none:37 =#
    (u, v, _) = model.velocities
    #= none:38 =#
    grid = model.grid
    #= none:39 =#
    barotropic_split_explicit_corrector!(u, v, model.free_surface, grid)
    #= none:41 =#
    return nothing
end
#= none:44 =#
#= none:44 =# @kernel function _barotropic_pressure_correction(U, grid, Δt, g, η)
        #= none:44 =#
        #= none:45 =#
        (i, j, k) = #= none:45 =# @index(Global, NTuple)
        #= none:47 =#
        #= none:47 =# @inbounds begin
                #= none:48 =#
                U.u[i, j, k] -= g * Δt * ∂xᶠᶜᶠ(i, j, grid.Nz + 1, grid, η)
                #= none:49 =#
                U.v[i, j, k] -= g * Δt * ∂yᶜᶠᶠ(i, j, grid.Nz + 1, grid, η)
            end
    end