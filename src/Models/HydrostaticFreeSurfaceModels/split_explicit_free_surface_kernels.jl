
#= none:1 =#
using Oceananigans.Grids: topology
#= none:2 =#
using Oceananigans.Utils
#= none:3 =#
using Oceananigans.AbstractOperations: Δz
#= none:4 =#
using Oceananigans.BoundaryConditions
#= none:5 =#
using Oceananigans.Operators
#= none:6 =#
using Oceananigans.Architectures: convert_args
#= none:7 =#
using Oceananigans.ImmersedBoundaries: peripheral_node, immersed_inactive_node, GFBIBG
#= none:8 =#
using Oceananigans.ImmersedBoundaries: inactive_node, IBG, c, f
#= none:9 =#
using Oceananigans.ImmersedBoundaries: mask_immersed_field!, retrieve_surface_active_cells_map, retrieve_interior_active_cells_map
#= none:10 =#
using Oceananigans.ImmersedBoundaries: active_linear_index_to_tuple, ActiveCellsIBG, ActiveZColumnsIBG
#= none:11 =#
using Oceananigans.DistributedComputations: child_architecture
#= none:12 =#
using Oceananigans.DistributedComputations: Distributed
#= none:14 =#
using Printf
#= none:15 =#
using KernelAbstractions: @index, @kernel
#= none:16 =#
using KernelAbstractions.Extras.LoopInfo: @unroll
#= none:19 =#
const β = 0.281105
#= none:20 =#
const α = 1.5 + β
#= none:21 =#
const θ = -0.5 - 2β
#= none:22 =#
const γ = 0.088
#= none:23 =#
const δ = 0.614
#= none:24 =#
const ϵ = 0.013
#= none:25 =#
const μ = ((1 - δ) - γ) - ϵ
#= none:36 =#
#= none:36 =# @inline div_Txᶜᶜᶠ(i, j, k, grid, U★::Function, args...) = begin
            #= none:36 =#
            (1 / Azᶜᶜᶠ(i, j, k, grid)) * δxTᶜᵃᵃ(i, j, k, grid, Δy_qᶠᶜᶠ, U★, args...)
        end
#= none:37 =#
#= none:37 =# @inline div_Tyᶜᶜᶠ(i, j, k, grid, V★::Function, args...) = begin
            #= none:37 =#
            (1 / Azᶜᶜᶠ(i, j, k, grid)) * δyTᵃᶜᵃ(i, j, k, grid, Δx_qᶜᶠᶠ, V★, args...)
        end
#= none:44 =#
#= none:44 =# @inline function U★(i, j, k, grid, ::AdamsBashforth3Scheme, Uᵐ, Uᵐ⁻¹, Uᵐ⁻²)
        #= none:44 =#
        #= none:45 =#
        FT = eltype(grid)
        #= none:46 =#
        return #= none:46 =# @inbounds(FT(α) * Uᵐ[i, j, k] + FT(θ) * Uᵐ⁻¹[i, j, k] + FT(β) * Uᵐ⁻²[i, j, k])
    end
#= none:49 =#
#= none:49 =# @inline function η★(i, j, k, grid, ::AdamsBashforth3Scheme, ηᵐ⁺¹, ηᵐ, ηᵐ⁻¹, ηᵐ⁻²)
        #= none:49 =#
        #= none:50 =#
        FT = eltype(grid)
        #= none:51 =#
        return #= none:51 =# @inbounds(FT(δ) * ηᵐ⁺¹[i, j, k] + FT(μ) * ηᵐ[i, j, k] + FT(γ) * ηᵐ⁻¹[i, j, k] + FT(ϵ) * ηᵐ⁻²[i, j, k])
    end
#= none:55 =#
#= none:55 =# @inline U★(i, j, k, grid, ::ForwardBackwardScheme, U, args...) = begin
            #= none:55 =#
            #= none:55 =# @inbounds U[i, j, k]
        end
#= none:56 =#
#= none:56 =# @inline η★(i, j, k, grid, ::ForwardBackwardScheme, η, args...) = begin
            #= none:56 =#
            #= none:56 =# @inbounds η[i, j, k]
        end
#= none:58 =#
#= none:58 =# @inline advance_previous_velocity!(i, j, k, ::ForwardBackwardScheme, U, Uᵐ⁻¹, Uᵐ⁻²) = begin
            #= none:58 =#
            nothing
        end
#= none:60 =#
#= none:60 =# @inline function advance_previous_velocity!(i, j, k, ::AdamsBashforth3Scheme, U, Uᵐ⁻¹, Uᵐ⁻²)
        #= none:60 =#
        #= none:61 =#
        #= none:61 =# @inbounds Uᵐ⁻²[i, j, k] = Uᵐ⁻¹[i, j, k]
        #= none:62 =#
        #= none:62 =# @inbounds Uᵐ⁻¹[i, j, k] = U[i, j, k]
        #= none:64 =#
        return nothing
    end
#= none:67 =#
#= none:67 =# @inline advance_previous_free_surface!(i, j, k, ::ForwardBackwardScheme, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻²) = begin
            #= none:67 =#
            nothing
        end
#= none:69 =#
#= none:69 =# @inline function advance_previous_free_surface!(i, j, k, ::AdamsBashforth3Scheme, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻²)
        #= none:69 =#
        #= none:70 =#
        #= none:70 =# @inbounds ηᵐ⁻²[i, j, k] = ηᵐ⁻¹[i, j, k]
        #= none:71 =#
        #= none:71 =# @inbounds ηᵐ⁻¹[i, j, k] = ηᵐ[i, j, k]
        #= none:72 =#
        #= none:72 =# @inbounds ηᵐ[i, j, k] = η[i, j, k]
        #= none:74 =#
        return nothing
    end
#= none:77 =#
#= none:77 =# @kernel function _split_explicit_free_surface!(grid, Δτ, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻², U, V, Uᵐ⁻¹, Uᵐ⁻², Vᵐ⁻¹, Vᵐ⁻², timestepper)
        #= none:77 =#
        #= none:78 =#
        (i, j) = #= none:78 =# @index(Global, NTuple)
        #= none:79 =#
        free_surface_evolution!(i, j, grid, Δτ, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻², U, V, Uᵐ⁻¹, Uᵐ⁻², Vᵐ⁻¹, Vᵐ⁻², timestepper)
    end
#= none:83 =#
#= none:83 =# @inline function free_surface_evolution!(i, j, grid, Δτ, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻², U, V, Uᵐ⁻¹, Uᵐ⁻², Vᵐ⁻¹, Vᵐ⁻², timestepper)
        #= none:83 =#
        #= none:84 =#
        k_top = grid.Nz + 1
        #= none:85 =#
        (TX, TY, _) = topology(grid)
        #= none:87 =#
        #= none:87 =# @inbounds begin
                #= none:88 =#
                advance_previous_free_surface!(i, j, k_top, timestepper, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻²)
                #= none:90 =#
                η[i, j, k_top] -= Δτ * (div_Txᶜᶜᶠ(i, j, k_top - 1, grid, U★, timestepper, U, Uᵐ⁻¹, Uᵐ⁻²) + div_Tyᶜᶜᶠ(i, j, k_top - 1, grid, U★, timestepper, V, Vᵐ⁻¹, Vᵐ⁻²))
            end
        #= none:94 =#
        return nothing
    end
#= none:97 =#
#= none:97 =# @kernel function _split_explicit_barotropic_velocity!(averaging_weight, grid, Δτ, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻², U, Uᵐ⁻¹, Uᵐ⁻², V, Vᵐ⁻¹, Vᵐ⁻², η̅, U̅, V̅, Gᵁ, Gⱽ, Hᶠᶜ, Hᶜᶠ, g, timestepper)
        #= none:97 =#
        #= none:101 =#
        (i, j) = #= none:101 =# @index(Global, NTuple)
        #= none:102 =#
        velocity_evolution!(i, j, grid, Δτ, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻², U, Uᵐ⁻¹, Uᵐ⁻², V, Vᵐ⁻¹, Vᵐ⁻², η̅, U̅, V̅, averaging_weight, Gᵁ, Gⱽ, Hᶠᶜ, Hᶜᶠ, g, timestepper)
    end
#= none:109 =#
#= none:109 =# @inline function velocity_evolution!(i, j, grid, Δτ, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻², U, Uᵐ⁻¹, Uᵐ⁻², V, Vᵐ⁻¹, Vᵐ⁻², η̅, U̅, V̅, averaging_weight, Gᵁ, Gⱽ, Hᶠᶜ, Hᶜᶠ, g, timestepper)
        #= none:109 =#
        #= none:114 =#
        k_top = grid.Nz + 1
        #= none:116 =#
        #= none:116 =# @inbounds begin
                #= none:117 =#
                advance_previous_velocity!(i, j, k_top - 1, timestepper, U, Uᵐ⁻¹, Uᵐ⁻²)
                #= none:118 =#
                advance_previous_velocity!(i, j, k_top - 1, timestepper, V, Vᵐ⁻¹, Vᵐ⁻²)
                #= none:121 =#
                U[i, j, k_top - 1] += Δτ * (-g * Hᶠᶜ[i, j] * ∂xTᶠᶜᶠ(i, j, k_top, grid, η★, timestepper, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻²) + Gᵁ[i, j, 1])
                #= none:122 =#
                V[i, j, k_top - 1] += Δτ * (-g * Hᶜᶠ[i, j] * ∂yTᶜᶠᶠ(i, j, k_top, grid, η★, timestepper, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻²) + Gⱽ[i, j, 1])
                #= none:125 =#
                η̅[i, j, k_top] += averaging_weight * η[i, j, k_top]
                #= none:126 =#
                U̅[i, j, k_top - 1] += averaging_weight * U[i, j, k_top - 1]
                #= none:127 =#
                V̅[i, j, k_top - 1] += averaging_weight * V[i, j, k_top - 1]
            end
    end
#= none:133 =#
#= none:133 =# @kernel function _barotropic_mode_kernel!(U, V, grid, ::Nothing, u, v)
        #= none:133 =#
        #= none:134 =#
        (i, j) = #= none:134 =# @index(Global, NTuple)
        #= none:135 =#
        k_top = grid.Nz + 1
        #= none:137 =#
        #= none:137 =# @inbounds U[i, j, k_top - 1] = Δzᶠᶜᶜ(i, j, 1, grid) * u[i, j, 1]
        #= none:138 =#
        #= none:138 =# @inbounds V[i, j, k_top - 1] = Δzᶜᶠᶜ(i, j, 1, grid) * v[i, j, 1]
        #= none:140 =#
        for k = 2:grid.Nz
            #= none:141 =#
            #= none:141 =# @inbounds U[i, j, k_top - 1] += Δzᶠᶜᶜ(i, j, k, grid) * u[i, j, k]
            #= none:142 =#
            #= none:142 =# @inbounds V[i, j, k_top - 1] += Δzᶜᶠᶜ(i, j, k, grid) * v[i, j, k]
            #= none:143 =#
        end
    end
#= none:148 =#
#= none:148 =# @kernel function _barotropic_mode_kernel!(U, V, grid, active_cells_map, u, v)
        #= none:148 =#
        #= none:149 =#
        idx = #= none:149 =# @index(Global, Linear)
        #= none:150 =#
        (i, j) = active_linear_index_to_tuple(idx, active_cells_map)
        #= none:151 =#
        k_top = grid.Nz + 1
        #= none:153 =#
        #= none:153 =# @inbounds U[i, j, k_top - 1] = Δzᶠᶜᶜ(i, j, 1, grid) * u[i, j, 1]
        #= none:154 =#
        #= none:154 =# @inbounds V[i, j, k_top - 1] = Δzᶜᶠᶜ(i, j, 1, grid) * v[i, j, 1]
        #= none:156 =#
        for k = 2:grid.Nz
            #= none:157 =#
            #= none:157 =# @inbounds U[i, j, k_top - 1] += Δzᶠᶜᶜ(i, j, k, grid) * u[i, j, k]
            #= none:158 =#
            #= none:158 =# @inbounds V[i, j, k_top - 1] += Δzᶜᶠᶜ(i, j, k, grid) * v[i, j, k]
            #= none:159 =#
        end
    end
#= none:162 =#
#= none:162 =# @inline function compute_barotropic_mode!(U, V, grid, u, v)
        #= none:162 =#
        #= none:163 =#
        active_cells_map = retrieve_surface_active_cells_map(grid)
        #= none:165 =#
        launch!(architecture(grid), grid, :xy, _barotropic_mode_kernel!, U, V, grid, active_cells_map, u, v; active_cells_map)
        #= none:167 =#
        return nothing
    end
#= none:170 =#
function initialize_free_surface_state!(state, η, timestepper)
    #= none:170 =#
    #= none:172 =#
    parent(state.U) .= parent(state.U̅)
    #= none:173 =#
    parent(state.V) .= parent(state.V̅)
    #= none:175 =#
    initialize_auxiliary_state!(state, η, timestepper)
    #= none:177 =#
    fill!(state.η̅, 0)
    #= none:178 =#
    fill!(state.U̅, 0)
    #= none:179 =#
    fill!(state.V̅, 0)
    #= none:181 =#
    return nothing
end
#= none:184 =#
initialize_auxiliary_state!(state, η, ::ForwardBackwardScheme) = begin
        #= none:184 =#
        nothing
    end
#= none:186 =#
function initialize_auxiliary_state!(state, η, timestepper)
    #= none:186 =#
    #= none:187 =#
    parent(state.Uᵐ⁻¹) .= parent(state.U̅)
    #= none:188 =#
    parent(state.Vᵐ⁻¹) .= parent(state.V̅)
    #= none:190 =#
    parent(state.Uᵐ⁻²) .= parent(state.U̅)
    #= none:191 =#
    parent(state.Vᵐ⁻²) .= parent(state.V̅)
    #= none:193 =#
    parent(state.ηᵐ) .= parent(η)
    #= none:194 =#
    parent(state.ηᵐ⁻¹) .= parent(η)
    #= none:195 =#
    parent(state.ηᵐ⁻²) .= parent(η)
    #= none:197 =#
    return nothing
end
#= none:200 =#
#= none:200 =# @kernel function _barotropic_split_explicit_corrector!(u, v, U̅, V̅, U, V, Hᶠᶜ, Hᶜᶠ, grid)
        #= none:200 =#
        #= none:201 =#
        (i, j, k) = #= none:201 =# @index(Global, NTuple)
        #= none:202 =#
        k_top = grid.Nz + 1
        #= none:204 =#
        #= none:204 =# @inbounds begin
                #= none:205 =#
                u[i, j, k] = u[i, j, k] + (U̅[i, j, k_top - 1] - U[i, j, k_top - 1]) / Hᶠᶜ[i, j, 1]
                #= none:206 =#
                v[i, j, k] = v[i, j, k] + (V̅[i, j, k_top - 1] - V[i, j, k_top - 1]) / Hᶜᶠ[i, j, 1]
            end
    end
#= none:210 =#
function barotropic_split_explicit_corrector!(u, v, free_surface, grid)
    #= none:210 =#
    #= none:211 =#
    sefs = free_surface.state
    #= none:212 =#
    (U, V, U̅, V̅) = (sefs.U, sefs.V, sefs.U̅, sefs.V̅)
    #= none:213 =#
    (Hᶠᶜ, Hᶜᶠ) = (free_surface.auxiliary.Hᶠᶜ, free_surface.auxiliary.Hᶜᶠ)
    #= none:214 =#
    arch = architecture(grid)
    #= none:219 =#
    compute_barotropic_mode!(U, V, grid, u, v)
    #= none:221 =#
    launch!(arch, grid, :xyz, _barotropic_split_explicit_corrector!, u, v, U̅, V̅, U, V, Hᶠᶜ, Hᶜᶠ, grid)
    #= none:224 =#
    return nothing
end
#= none:227 =#
#= none:227 =# Core.@doc "Explicitly step forward η in substeps.\n" ab2_step_free_surface!(free_surface::SplitExplicitFreeSurface, model, Δt, χ) = begin
            #= none:230 =#
            split_explicit_free_surface_step!(free_surface, model, Δt, χ)
        end
#= none:233 =#
function initialize_free_surface!(sefs::SplitExplicitFreeSurface, grid, velocities)
    #= none:233 =#
    #= none:234 =#
    #= none:234 =# @apply_regionally compute_barotropic_mode!(sefs.state.U̅, sefs.state.V̅, grid, velocities.u, velocities.v)
    #= none:235 =#
    fill_halo_regions!((sefs.state.U̅, sefs.state.V̅, sefs.η))
end
#= none:238 =#
function split_explicit_free_surface_step!(free_surface::SplitExplicitFreeSurface, model, Δt, χ)
    #= none:238 =#
    #= none:242 =#
    free_surface_grid = free_surface.η.grid
    #= none:245 =#
    wait_free_surface_communication!(free_surface, architecture(free_surface_grid))
    #= none:248 =#
    settings = free_surface.settings
    #= none:249 =#
    Nsubsteps = calculate_substeps(settings.substepping, Δt)
    #= none:252 =#
    (fractional_Δt, weights) = calculate_adaptive_settings(settings.substepping, Nsubsteps)
    #= none:253 =#
    Nsubsteps = length(weights)
    #= none:256 =#
    Δτᴮ = fractional_Δt * Δt
    #= none:259 =#
    #= none:259 =# @apply_regionally begin
            #= none:260 =#
            initialize_free_surface_state!(free_surface.state, free_surface.η, settings.timestepper)
            #= none:263 =#
            iterate_split_explicit!(free_surface, free_surface_grid, Δτᴮ, weights, Val(Nsubsteps))
            #= none:266 =#
            set!(free_surface.η, free_surface.state.η̅)
        end
    #= none:269 =#
    fields_to_fill = (free_surface.state.U̅, free_surface.state.V̅)
    #= none:270 =#
    fill_halo_regions!(fields_to_fill; async = true)
    #= none:273 =#
    #= none:273 =# @apply_regionally begin
            #= none:274 =#
            mask_immersed_field!(model.velocities.u)
            #= none:275 =#
            mask_immersed_field!(model.velocities.v)
        end
    #= none:278 =#
    return nothing
end
#= none:282 =#
const FNS = FixedSubstepNumber
#= none:283 =#
const FTS = FixedTimeStepSize
#= none:287 =#
const MINIMUM_SUBSTEPS = 5
#= none:289 =#
#= none:289 =# @inline calculate_substeps(substepping::FNS, Δt = nothing) = begin
            #= none:289 =#
            length(substepping.averaging_weights)
        end
#= none:290 =#
#= none:290 =# @inline calculate_substeps(substepping::FTS, Δt) = begin
            #= none:290 =#
            max(MINIMUM_SUBSTEPS, ceil(Int, (2Δt) / substepping.Δt_barotropic))
        end
#= none:292 =#
#= none:292 =# @inline calculate_adaptive_settings(substepping::FNS, substeps) = begin
            #= none:292 =#
            (substepping.fractional_step_size, substepping.averaging_weights)
        end
#= none:293 =#
#= none:293 =# @inline calculate_adaptive_settings(substepping::FTS, substeps) = begin
            #= none:293 =#
            weights_from_substeps(eltype(substepping.Δt_barotropic), substeps, substepping.averaging_kernel)
        end
#= none:296 =#
const FixedSubstepsSetting{N} = (SplitExplicitSettings{<:FixedSubstepNumber{<:Any, <:NTuple{N, <:Any}}} where N)
#= none:297 =#
const FixedSubstepsSplitExplicit{F} = (SplitExplicitFreeSurface{<:Any, <:Any, <:Any, <:Any, <:FixedSubstepsSetting{N}} where N)
#= none:299 =#
function iterate_split_explicit!(free_surface, grid, Δτᴮ, weights, ::Val{Nsubsteps}) where Nsubsteps
    #= none:299 =#
    #= none:300 =#
    arch = architecture(grid)
    #= none:302 =#
    η = free_surface.η
    #= none:303 =#
    state = free_surface.state
    #= none:304 =#
    auxiliary = free_surface.auxiliary
    #= none:305 =#
    settings = free_surface.settings
    #= none:306 =#
    g = free_surface.gravitational_acceleration
    #= none:309 =#
    (U, V) = (state.U, state.V)
    #= none:310 =#
    (Uᵐ⁻¹, Uᵐ⁻²) = (state.Uᵐ⁻¹, state.Uᵐ⁻²)
    #= none:311 =#
    (Vᵐ⁻¹, Vᵐ⁻²) = (state.Vᵐ⁻¹, state.Vᵐ⁻²)
    #= none:312 =#
    (ηᵐ, ηᵐ⁻¹, ηᵐ⁻²) = (state.ηᵐ, state.ηᵐ⁻¹, state.ηᵐ⁻²)
    #= none:313 =#
    (η̅, U̅, V̅) = (state.η̅, state.U̅, state.V̅)
    #= none:314 =#
    (Gᵁ, Gⱽ, Hᶠᶜ, Hᶜᶠ) = (auxiliary.Gᵁ, auxiliary.Gⱽ, auxiliary.Hᶠᶜ, auxiliary.Hᶜᶠ)
    #= none:316 =#
    timestepper = settings.timestepper
    #= none:318 =#
    parameters = auxiliary.kernel_parameters
    #= none:320 =#
    (free_surface_kernel!, _) = configure_kernel(arch, grid, parameters, _split_explicit_free_surface!)
    #= none:321 =#
    (barotropic_velocity_kernel!, _) = configure_kernel(arch, grid, parameters, _split_explicit_barotropic_velocity!)
    #= none:323 =#
    η_args = (grid, Δτᴮ, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻², U, V, Uᵐ⁻¹, Uᵐ⁻², Vᵐ⁻¹, Vᵐ⁻², timestepper)
    #= none:327 =#
    U_args = (grid, Δτᴮ, η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻², U, Uᵐ⁻¹, Uᵐ⁻², V, Vᵐ⁻¹, Vᵐ⁻², η̅, U̅, V̅, Gᵁ, Gⱽ, Hᶠᶜ, Hᶜᶠ, g, timestepper)
    #= none:332 =#
    #= none:332 =# GC.@preserve η_args U_args begin
            #= none:338 =#
            converted_η_args = convert_args(arch, η_args)
            #= none:339 =#
            converted_U_args = convert_args(arch, U_args)
            #= none:341 =#
            #= none:341 =# @unroll for substep = 1:Nsubsteps
                    #= none:342 =#
                    #= none:342 =# Base.@_inline_meta
                    #= none:343 =#
                    averaging_weight = weights[substep]
                    #= none:344 =#
                    free_surface_kernel!(converted_η_args...)
                    #= none:345 =#
                    barotropic_velocity_kernel!(averaging_weight, converted_U_args...)
                    #= none:346 =#
                end
        end
    #= none:349 =#
    return nothing
end
#= none:353 =#
#= none:353 =# @kernel function _compute_integrated_ab2_tendencies!(Gᵁ, Gⱽ, grid, ::Nothing, Gu⁻, Gv⁻, Guⁿ, Gvⁿ, χ)
        #= none:353 =#
        #= none:354 =#
        (i, j) = #= none:354 =# @index(Global, NTuple)
        #= none:355 =#
        k_top = grid.Nz + 1
        #= none:357 =#
        #= none:357 =# @inbounds Gᵁ[i, j, k_top - 1] = Δzᶠᶜᶜ(i, j, 1, grid) * ab2_step_Gu(i, j, 1, grid, Gu⁻, Guⁿ, χ)
        #= none:358 =#
        #= none:358 =# @inbounds Gⱽ[i, j, k_top - 1] = Δzᶜᶠᶜ(i, j, 1, grid) * ab2_step_Gv(i, j, 1, grid, Gv⁻, Gvⁿ, χ)
        #= none:360 =#
        for k = 2:grid.Nz
            #= none:361 =#
            #= none:361 =# @inbounds Gᵁ[i, j, k_top - 1] += Δzᶠᶜᶜ(i, j, k, grid) * ab2_step_Gu(i, j, k, grid, Gu⁻, Guⁿ, χ)
            #= none:362 =#
            #= none:362 =# @inbounds Gⱽ[i, j, k_top - 1] += Δzᶜᶠᶜ(i, j, k, grid) * ab2_step_Gv(i, j, k, grid, Gv⁻, Gvⁿ, χ)
            #= none:363 =#
        end
    end
#= none:367 =#
#= none:367 =# @kernel function _compute_integrated_ab2_tendencies!(Gᵁ, Gⱽ, grid, active_cells_map, Gu⁻, Gv⁻, Guⁿ, Gvⁿ, χ)
        #= none:367 =#
        #= none:368 =#
        idx = #= none:368 =# @index(Global, Linear)
        #= none:369 =#
        (i, j) = active_linear_index_to_tuple(idx, active_cells_map)
        #= none:370 =#
        k_top = grid.Nz + 1
        #= none:372 =#
        #= none:372 =# @inbounds Gᵁ[i, j, k_top - 1] = Δzᶠᶜᶜ(i, j, 1, grid) * ab2_step_Gu(i, j, 1, grid, Gu⁻, Guⁿ, χ)
        #= none:373 =#
        #= none:373 =# @inbounds Gⱽ[i, j, k_top - 1] = Δzᶜᶠᶜ(i, j, 1, grid) * ab2_step_Gv(i, j, 1, grid, Gv⁻, Gvⁿ, χ)
        #= none:375 =#
        for k = 2:grid.Nz
            #= none:376 =#
            #= none:376 =# @inbounds Gᵁ[i, j, k_top - 1] += Δzᶠᶜᶜ(i, j, k, grid) * ab2_step_Gu(i, j, k, grid, Gu⁻, Guⁿ, χ)
            #= none:377 =#
            #= none:377 =# @inbounds Gⱽ[i, j, k_top - 1] += Δzᶜᶠᶜ(i, j, k, grid) * ab2_step_Gv(i, j, k, grid, Gv⁻, Gvⁿ, χ)
            #= none:378 =#
        end
    end
#= none:381 =#
#= none:381 =# @inline (ab2_step_Gu(i, j, k, grid, G⁻, Gⁿ, χ::FT) where FT) = begin
            #= none:381 =#
            #= none:382 =# @inbounds ifelse(peripheral_node(i, j, k, grid, f, c, c), zero(grid), (convert(FT, 1.5) + χ) * Gⁿ[i, j, k] - G⁻[i, j, k] * (convert(FT, 0.5) + χ))
        end
#= none:384 =#
#= none:384 =# @inline (ab2_step_Gv(i, j, k, grid, G⁻, Gⁿ, χ::FT) where FT) = begin
            #= none:384 =#
            #= none:385 =# @inbounds ifelse(peripheral_node(i, j, k, grid, c, f, c), zero(grid), (convert(FT, 1.5) + χ) * Gⁿ[i, j, k] - G⁻[i, j, k] * (convert(FT, 0.5) + χ))
        end
#= none:389 =#
function setup_free_surface!(model, free_surface::SplitExplicitFreeSurface, χ)
    #= none:389 =#
    #= none:392 =#
    Gu⁻ = model.timestepper.G⁻.u
    #= none:393 =#
    Gv⁻ = model.timestepper.G⁻.v
    #= none:394 =#
    Guⁿ = model.timestepper.Gⁿ.u
    #= none:395 =#
    Gvⁿ = model.timestepper.Gⁿ.v
    #= none:397 =#
    auxiliary = free_surface.auxiliary
    #= none:399 =#
    #= none:399 =# @apply_regionally setup_split_explicit_tendency!(auxiliary, model.grid, Gu⁻, Gv⁻, Guⁿ, Gvⁿ, χ)
    #= none:401 =#
    fields_to_fill = (auxiliary.Gᵁ, auxiliary.Gⱽ)
    #= none:402 =#
    fill_halo_regions!(fields_to_fill; async = true)
    #= none:404 =#
    return nothing
end
#= none:407 =#
#= none:407 =# @inline function setup_split_explicit_tendency!(auxiliary, grid, Gu⁻, Gv⁻, Guⁿ, Gvⁿ, χ)
        #= none:407 =#
        #= none:408 =#
        active_cells_map = retrieve_surface_active_cells_map(grid)
        #= none:410 =#
        launch!(architecture(grid), grid, :xy, _compute_integrated_ab2_tendencies!, auxiliary.Gᵁ, auxiliary.Gⱽ, grid, active_cells_map, Gu⁻, Gv⁻, Guⁿ, Gvⁿ, χ; active_cells_map)
        #= none:413 =#
        return nothing
    end
#= none:416 =#
wait_free_surface_communication!(free_surface, arch) = begin
        #= none:416 =#
        nothing
    end