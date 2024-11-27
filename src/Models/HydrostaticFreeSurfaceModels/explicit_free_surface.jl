
#= none:1 =#
using Oceananigans.Grids: AbstractGrid
#= none:2 =#
using Oceananigans.Operators: ∂xᶠᶜᶜ, ∂yᶜᶠᶜ
#= none:3 =#
using Oceananigans.BoundaryConditions: regularize_field_boundary_conditions
#= none:5 =#
using Adapt
#= none:7 =#
#= none:7 =# Core.@doc "    struct ExplicitFreeSurface{E, T}\n\nThe explicit free surface solver.\n\n$(TYPEDFIELDS)\n" struct ExplicitFreeSurface{E, G} <: AbstractFreeSurface{E, G}
        #= none:15 =#
        "free surface elevation"
        #= none:16 =#
        η::E
        #= none:17 =#
        "gravitational accelerations"
        #= none:18 =#
        gravitational_acceleration::G
    end
#= none:21 =#
ExplicitFreeSurface(; gravitational_acceleration = g_Earth) = begin
        #= none:21 =#
        ExplicitFreeSurface(nothing, gravitational_acceleration)
    end
#= none:24 =#
Adapt.adapt_structure(to, free_surface::ExplicitFreeSurface) = begin
        #= none:24 =#
        ExplicitFreeSurface(Adapt.adapt(to, free_surface.η), free_surface.gravitational_acceleration)
    end
#= none:27 =#
on_architecture(to, free_surface::ExplicitFreeSurface) = begin
        #= none:27 =#
        ExplicitFreeSurface(on_architecture(to, free_surface.η), on_architecture(to, free_surface.gravitational_acceleration))
    end
#= none:32 =#
function materialize_free_surface(free_surface::ExplicitFreeSurface{Nothing}, velocities, grid)
    #= none:32 =#
    #= none:33 =#
    η = free_surface_displacement_field(velocities, free_surface, grid)
    #= none:34 =#
    g = convert(eltype(grid), free_surface.gravitational_acceleration)
    #= none:36 =#
    return ExplicitFreeSurface(η, g)
end
#= none:43 =#
#= none:43 =# @inline explicit_barotropic_pressure_x_gradient(i, j, k, grid, free_surface::ExplicitFreeSurface) = begin
            #= none:43 =#
            free_surface.gravitational_acceleration * ∂xᶠᶜᶜ(i, j, grid.Nz + 1, grid, free_surface.η)
        end
#= none:46 =#
#= none:46 =# @inline explicit_barotropic_pressure_y_gradient(i, j, k, grid, free_surface::ExplicitFreeSurface) = begin
            #= none:46 =#
            free_surface.gravitational_acceleration * ∂yᶜᶠᶜ(i, j, grid.Nz + 1, grid, free_surface.η)
        end
#= none:53 =#
ab2_step_free_surface!(free_surface::ExplicitFreeSurface, model, Δt, χ) = begin
        #= none:53 =#
        #= none:54 =# @apply_regionally explicit_ab2_step_free_surface!(free_surface, model, Δt, χ)
    end
#= none:56 =#
explicit_ab2_step_free_surface!(free_surface, model, Δt, χ) = begin
        #= none:56 =#
        launch!(model.architecture, model.grid, :xy, _explicit_ab2_step_free_surface!, free_surface.η, Δt, χ, model.timestepper.Gⁿ.η, model.timestepper.G⁻.η, size(model.grid, 3))
    end
#= none:65 =#
#= none:65 =# @kernel function _explicit_ab2_step_free_surface!(η, Δt, χ::FT, Gηⁿ, Gη⁻, Nz) where FT
        #= none:65 =#
        #= none:66 =#
        (i, j) = #= none:66 =# @index(Global, NTuple)
        #= none:68 =#
        #= none:68 =# @inbounds begin
                #= none:69 =#
                η[i, j, Nz + 1] += Δt * ((FT(1.5) + χ) * Gηⁿ[i, j, Nz + 1] - (FT(0.5) + χ) * Gη⁻[i, j, Nz + 1])
            end
    end