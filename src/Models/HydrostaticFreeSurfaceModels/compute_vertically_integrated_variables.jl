
#= none:1 =#
using Oceananigans.Grids: halo_size
#= none:2 =#
using Oceananigans.AbstractOperations: Ax, Ay, GridMetricOperation
#= none:5 =#
function compute_vertically_integrated_lateral_areas!(∫ᶻ_A)
    #= none:5 =#
    #= none:11 =#
    field_grid = ∫ᶻ_A.xᶠᶜᶜ.grid
    #= none:13 =#
    Axᶠᶜᶜ = GridMetricOperation((Face, Center, Center), Ax, field_grid)
    #= none:14 =#
    Ayᶜᶠᶜ = GridMetricOperation((Center, Face, Center), Ay, field_grid)
    #= none:16 =#
    sum!(∫ᶻ_A.xᶠᶜᶜ, Axᶠᶜᶜ)
    #= none:17 =#
    sum!(∫ᶻ_A.yᶜᶠᶜ, Ayᶜᶠᶜ)
    #= none:19 =#
    return nothing
end
#= none:22 =#
"Compute the vertical integrated volume flux from the bottom to ``z = 0`` (i.e., linear free-surface).\n\n```\nU★ = ∫ᶻ Ax * u★ dz\nV★ = ∫ᶻ Ay * v★ dz\n```\n"
#= none:32 =#
function compute_vertically_integrated_volume_flux!(∫ᶻ_U, velocities)
    #= none:32 =#
    #= none:35 =#
    sum!(∫ᶻ_U.u, Ax * velocities.u)
    #= none:36 =#
    sum!(∫ᶻ_U.v, Ay * velocities.v)
    #= none:38 =#
    return nothing
end