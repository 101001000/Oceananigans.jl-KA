
#= none:1 =#
using Oceananigans
#= none:2 =#
using Oceananigans.Architectures
#= none:3 =#
using Oceananigans.Fields
#= none:4 =#
using Oceananigans.Grids
#= none:5 =#
using Oceananigans.Grids: AbstractGrid
#= none:6 =#
using Oceananigans.AbstractOperations: Δz, GridMetricOperation
#= none:8 =#
using Adapt
#= none:9 =#
using Base
#= none:10 =#
using KernelAbstractions: @index, @kernel
#= none:12 =#
import Oceananigans.TimeSteppers: reset!
#= none:14 =#
#= none:14 =# Core.@doc "    struct SplitExplicitFreeSurface\n\nThe split-explicit free surface solver.\n\n$(FIELDS)\n" struct SplitExplicitFreeSurface{𝒩, 𝒮, ℱ, 𝒫, ℰ} <: AbstractFreeSurface{𝒩, 𝒫}
        #= none:22 =#
        "The instantaneous free surface (`ReducedField`)"
        #= none:23 =#
        η::𝒩
        #= none:24 =#
        "The entire state for the split-explicit solver (`SplitExplicitState`)"
        #= none:25 =#
        state::𝒮
        #= none:26 =#
        "Parameters for timestepping split-explicit solver (`NamedTuple`)"
        #= none:27 =#
        auxiliary::ℱ
        #= none:28 =#
        "Gravitational acceleration"
        #= none:29 =#
        gravitational_acceleration::𝒫
        #= none:30 =#
        "Settings for the split-explicit scheme"
        #= none:31 =#
        settings::ℰ
    end
#= none:34 =#
#= none:34 =# Core.@doc "    SplitExplicitFreeSurface(grid = nothing;\n                             gravitational_acceleration = g_Earth,\n                             substeps = nothing,\n                             cfl = nothing,\n                             fixed_Δt = nothing,\n                             averaging_kernel = averaging_shape_function,\n                             timestepper = ForwardBackwardScheme())\n\nReturn a `SplitExplicitFreeSurface` representing an explicit time discretization\nof a free surface dynamics with `gravitational_acceleration`.\n\nKeyword Arguments\n=================\n\n- `gravitational_acceleration`: the gravitational acceleration (default: `g_Earth`)\n\n- `substeps`: The number of substeps that divide the range `(t, t + 2Δt)`, where `Δt` is the baroclinic\n              timestep. Note that some averaging functions do not require substepping until `2Δt`.\n              The number of substeps is reduced automatically to the last index of `averaging_kernel`\n              for which `averaging_kernel > 0`.\n\n- `cfl`: If set then the number of `substeps` are computed based on the advective timescale imposed from\n         the barotropic gravity-wave speed that corresponds to depth `grid.Lz`. If `fixed_Δt` is provided,\n         then the number of `substeps` adapts to maintain an exact `cfl`. If not, the effective cfl will\n         always be lower than the specified `cfl` provided that the baroclinic time step satisfies\n         `Δt_baroclinic < fixed_Δt`.\n\n!!! info \"Needed keyword arguments\"\n    Either `substeps` _or_ `cfl` need to be prescribed.\n    \n    When `cfl` is prescribed then `grid` is also required as a positional argument.\n\n- `fixed_Δt`: The maximum baroclinic timestep allowed. If `fixed_Δt` is a `nothing` and a cfl is provided,\n              then the number of substeps will be computed on the fly from the baroclinic time step to\n              maintain a constant cfl.\n\n- `averaging_kernel`: A function of `τ` used to average the barotropic transport `U` and the free surface\n                      `η` within the barotropic advancement. `τ` is the fractional substep going from 0 to 2\n                      with the baroclinic time step `t + Δt` located at `τ = 1`. The `averaging_kernel`\n                      function should be centered at `τ = 1`, that is, ``∑ (aₘ m / M) = 1``, where the\n                      the summation occurs for ``m = 1, ..., M_*``. Here, ``m = 0`` and ``m = M`` correspond\n                      to the two consecutive baroclinic timesteps between which the barotropic timestepping\n                      occurs and ``M_*`` corresponds to the last barotropic time step for which the\n                      `averaging_kernel > 0`. By default, the averaging kernel described by [Shchepetkin2005](@citet)\n                      is used.\n\n- `timestepper`: Time stepping scheme used for the barotropic advancement. Choose one of:\n  * `ForwardBackwardScheme()` (default): `η = f(U)`   then `U = f(η)`,\n  * `AdamsBashforth3Scheme()`: `η = f(U, Uᵐ⁻¹, Uᵐ⁻²)` then `U = f(η, ηᵐ, ηᵐ⁻¹, ηᵐ⁻²)`.\n\nReferences\n==========\n\nShchepetkin, A. F., & McWilliams, J. C. (2005). The regional oceanic modeling system (ROMS): a split-explicit, free-surface, topography-following-coordinate oceanic model. Ocean Modelling, 9(4), 347-404.\n" function SplitExplicitFreeSurface(grid = nothing; gravitational_acceleration = g_Earth, substeps = nothing, cfl = nothing, fixed_Δt = nothing, averaging_kernel = averaging_shape_function, timestepper = ForwardBackwardScheme())
        #= none:90 =#
        #= none:98 =#
        settings = SplitExplicitSettings(grid; gravitational_acceleration, substeps, cfl, fixed_Δt, averaging_kernel, timestepper)
        #= none:106 =#
        return SplitExplicitFreeSurface(nothing, nothing, nothing, gravitational_acceleration, settings)
    end
#= none:114 =#
function materialize_free_surface(free_surface::SplitExplicitFreeSurface, velocities, grid)
    #= none:114 =#
    #= none:115 =#
    settings = SplitExplicitSettings(grid; free_surface.settings.settings_kwargs...)
    #= none:117 =#
    η = free_surface_displacement_field(velocities, free_surface, grid)
    #= none:119 =#
    gravitational_acceleration = convert(eltype(grid), free_surface.gravitational_acceleration)
    #= none:121 =#
    return SplitExplicitFreeSurface(η, SplitExplicitState(grid, settings.timestepper), SplitExplicitAuxiliaryFields(grid), gravitational_acceleration, settings)
end
#= none:129 =#
#= none:129 =# Core.@doc "    struct SplitExplicitState\n\nA type containing the state fields for the split-explicit free surface.\n\n$(FIELDS)\n" #= none:136 =# Base.@kwdef(struct SplitExplicitState{CC, ACC, FC, AFC, CF, ACF}
            #= none:137 =#
            "The free surface at time `m`. (`ReducedField` over ``z``)"
            #= none:138 =#
            ηᵐ::ACC
            #= none:139 =#
            "The free surface at time `m-1`. (`ReducedField` over ``z``)"
            #= none:140 =#
            ηᵐ⁻¹::ACC
            #= none:141 =#
            "The free surface at time `m-2`. (`ReducedField` over ``z``)"
            #= none:142 =#
            ηᵐ⁻²::ACC
            #= none:143 =#
            "The barotropic zonal velocity at time `m`. (`ReducedField` over ``z``)"
            #= none:144 =#
            U::FC
            #= none:145 =#
            "The barotropic zonal velocity at time `m-1`. (`ReducedField` over ``z``)"
            #= none:146 =#
            Uᵐ⁻¹::AFC
            #= none:147 =#
            "The barotropic zonal velocity at time `m-2`. (`ReducedField` over ``z``)"
            #= none:148 =#
            Uᵐ⁻²::AFC
            #= none:149 =#
            "The barotropic meridional velocity at time `m`. (`ReducedField` over ``z``)"
            #= none:150 =#
            V::CF
            #= none:151 =#
            "The barotropic meridional velocity at time `m-1`. (`ReducedField` over ``z``)"
            #= none:152 =#
            Vᵐ⁻¹::ACF
            #= none:153 =#
            "The barotropic meridional velocity at time `m-2`. (`ReducedField` over ``z``)"
            #= none:154 =#
            Vᵐ⁻²::ACF
            #= none:155 =#
            "The time-filtered free surface. (`ReducedField` over ``z``)"
            #= none:156 =#
            η̅::CC
            #= none:157 =#
            "The time-filtered barotropic zonal velocity. (`ReducedField` over ``z``)"
            #= none:158 =#
            U̅::FC
            #= none:159 =#
            "The time-filtered barotropic meridional velocity. (`ReducedField` over ``z``)"
            #= none:160 =#
            V̅::CF
        end)
#= none:163 =#
#= none:163 =# Core.@doc "    SplitExplicitState(grid, timestepper)\n\nReturn the split-explicit state for `grid`.\n\nNote that `η̅` is solely used for setting the `η` at the next substep iteration -- it essentially\nacts as a filter for `η`. Values with superscripts `m-1` and `m-2` correspond to previous stored\ntime steps to allow using a higher-order time stepping scheme, e.g., `AdamsBashforth3Scheme`.\n" function SplitExplicitState(grid::AbstractGrid, timestepper)
        #= none:172 =#
        #= none:174 =#
        Nz = size(grid, 3)
        #= none:176 =#
        η̅ = ZFaceField(grid, indices = (:, :, Nz + 1))
        #= none:178 =#
        ηᵐ = auxiliary_free_surface_field(grid, timestepper)
        #= none:179 =#
        ηᵐ⁻¹ = auxiliary_free_surface_field(grid, timestepper)
        #= none:180 =#
        ηᵐ⁻² = auxiliary_free_surface_field(grid, timestepper)
        #= none:182 =#
        U = XFaceField(grid, indices = (:, :, Nz))
        #= none:183 =#
        V = YFaceField(grid, indices = (:, :, Nz))
        #= none:185 =#
        Uᵐ⁻¹ = auxiliary_barotropic_U_field(grid, timestepper)
        #= none:186 =#
        Vᵐ⁻¹ = auxiliary_barotropic_V_field(grid, timestepper)
        #= none:187 =#
        Uᵐ⁻² = auxiliary_barotropic_U_field(grid, timestepper)
        #= none:188 =#
        Vᵐ⁻² = auxiliary_barotropic_V_field(grid, timestepper)
        #= none:190 =#
        U̅ = XFaceField(grid, indices = (:, :, Nz))
        #= none:191 =#
        V̅ = YFaceField(grid, indices = (:, :, Nz))
        #= none:193 =#
        return SplitExplicitState(; ηᵐ, ηᵐ⁻¹, ηᵐ⁻², U, Uᵐ⁻¹, Uᵐ⁻², V, Vᵐ⁻¹, Vᵐ⁻², η̅, U̅, V̅)
    end
#= none:196 =#
#= none:196 =# Core.@doc "    struct SplitExplicitAuxiliaryFields\n\nA type containing auxiliary fields for the split-explicit free surface.\n\nThe barotropic time stepping is launched on a grid `(kernel_size[1], kernel_size[2])`\nlarge (or `:xy` in case of a serial computation), and start computing from \n`(i - kernel_offsets[1], j - kernel_offsets[2])`.\n\n$(FIELDS)\n" #= none:207 =# Base.@kwdef(struct SplitExplicitAuxiliaryFields{𝒞ℱ, ℱ𝒞, 𝒦}
            #= none:208 =#
            "Vertically-integrated slow barotropic forcing function for `U` (`ReducedField` over ``z``)"
            #= none:209 =#
            Gᵁ::ℱ𝒞
            #= none:210 =#
            "Vertically-integrated slow barotropic forcing function for `V` (`ReducedField` over ``z``)"
            #= none:211 =#
            Gⱽ::𝒞ℱ
            #= none:212 =#
            "Depth at `(Face, Center)` (`ReducedField` over ``z``)"
            #= none:213 =#
            Hᶠᶜ::ℱ𝒞
            #= none:214 =#
            "Depth at `(Center, Face)` (`ReducedField` over ``z``)"
            #= none:215 =#
            Hᶜᶠ::𝒞ℱ
            #= none:216 =#
            "kernel size for barotropic time stepping"
            #= none:217 =#
            kernel_parameters::𝒦
        end)
#= none:220 =#
#= none:220 =# Core.@doc "    SplitExplicitAuxiliaryFields(grid)\n\nReturn the `SplitExplicitAuxiliaryFields` for `grid`.\n" function SplitExplicitAuxiliaryFields(grid::AbstractGrid)
        #= none:225 =#
        #= none:227 =#
        Gᵁ = Field((Face, Center, Nothing), grid)
        #= none:228 =#
        Gⱽ = Field((Center, Face, Nothing), grid)
        #= none:230 =#
        Hᶠᶜ = Field((Face, Center, Nothing), grid)
        #= none:231 =#
        Hᶜᶠ = Field((Center, Face, Nothing), grid)
        #= none:233 =#
        dz = GridMetricOperation((Face, Center, Center), Δz, grid)
        #= none:234 =#
        sum!(Hᶠᶜ, dz)
        #= none:236 =#
        dz = GridMetricOperation((Center, Face, Center), Δz, grid)
        #= none:237 =#
        sum!(Hᶜᶠ, dz)
        #= none:239 =#
        fill_halo_regions!((Hᶠᶜ, Hᶜᶠ))
        #= none:241 =#
        kernel_parameters = :xy
        #= none:243 =#
        return SplitExplicitAuxiliaryFields(Gᵁ, Gⱽ, Hᶠᶜ, Hᶜᶠ, kernel_parameters)
    end
#= none:246 =#
#= none:246 =# Core.@doc "    struct SplitExplicitSettings\n\nA type containing settings for the split-explicit free surface.\n\n$(FIELDS)\n" struct SplitExplicitSettings{𝒩, 𝒮}
        #= none:254 =#
        substepping::𝒩
        #= none:255 =#
        timestepper::𝒮
        #= none:256 =#
        settings_kwargs::NamedTuple
    end
#= none:259 =#
struct AdamsBashforth3Scheme
    #= none:259 =#
end
#= none:260 =#
struct ForwardBackwardScheme
    #= none:260 =#
end
#= none:263 =#
auxiliary_free_surface_field(grid, ::AdamsBashforth3Scheme) = begin
        #= none:263 =#
        ZFaceField(grid, indices = (:, :, size(grid, 3) + 1))
    end
#= none:264 =#
auxiliary_free_surface_field(grid, ::ForwardBackwardScheme) = begin
        #= none:264 =#
        nothing
    end
#= none:266 =#
auxiliary_barotropic_U_field(grid, ::AdamsBashforth3Scheme) = begin
        #= none:266 =#
        XFaceField(grid, indices = (:, :, size(grid, 3)))
    end
#= none:267 =#
auxiliary_barotropic_U_field(grid, ::ForwardBackwardScheme) = begin
        #= none:267 =#
        nothing
    end
#= none:268 =#
auxiliary_barotropic_V_field(grid, ::AdamsBashforth3Scheme) = begin
        #= none:268 =#
        YFaceField(grid, indices = (:, :, size(grid, 3)))
    end
#= none:269 =#
auxiliary_barotropic_V_field(grid, ::ForwardBackwardScheme) = begin
        #= none:269 =#
        nothing
    end
#= none:272 =#
#= none:272 =# @inline function averaging_shape_function(τ::FT; p = 2, q = 4, r = FT(0.18927)) where FT
        #= none:272 =#
        #= none:273 =#
        τ₀ = (((p + 2) * (p + q + 2)) / (p + 1)) / (p + q + 1)
        #= none:275 =#
        return (τ / τ₀) ^ p * (1 - (τ / τ₀) ^ q) - r * (τ / τ₀)
    end
#= none:278 =#
#= none:278 =# @inline (cosine_averaging_kernel(τ::FT) where FT) = begin
            #= none:278 =#
            if τ ≥ 0.5 && τ ≤ 1.5
                convert(FT, 1 + cos((2π) * (τ - 1)))
            else
                zero(FT)
            end
        end
#= none:279 =#
#= none:279 =# @inline (constant_averaging_kernel(τ::FT) where FT) = begin
            #= none:279 =#
            convert(FT, 1)
        end
#= none:281 =#
#= none:281 =# Core.@doc " An internal type for the `SplitExplicitFreeSurface` that allows substepping with\na fixed `Δt_barotropic` based on a CFL condition " struct FixedTimeStepSize{B, F}
        #= none:284 =#
        Δt_barotropic::B
        #= none:285 =#
        averaging_kernel::F
    end
#= none:288 =#
#= none:288 =# Core.@doc " An internal type for the `SplitExplicitFreeSurface` that allows substepping with\na fixed number of substeps with time step size of `fractional_step_size * Δt_baroclinic` " struct FixedSubstepNumber{B, F}
        #= none:291 =#
        fractional_step_size::B
        #= none:292 =#
        averaging_weights::F
    end
#= none:295 =#
function FixedTimeStepSize(grid; cfl = 0.7, averaging_kernel = averaging_shape_function, gravitational_acceleration = g_Earth)
    #= none:295 =#
    #= none:300 =#
    FT = eltype(grid)
    #= none:302 =#
    Δx⁻² = if (topology(grid))[1] == Flat
            0
        else
            1 / minimum_xspacing(grid) ^ 2
        end
    #= none:303 =#
    Δy⁻² = if (topology(grid))[2] == Flat
            0
        else
            1 / minimum_yspacing(grid) ^ 2
        end
    #= none:304 =#
    Δs = sqrt(1 / (Δx⁻² + Δy⁻²))
    #= none:306 =#
    wave_speed = sqrt(gravitational_acceleration * grid.Lz)
    #= none:308 =#
    Δt_barotropic = convert(FT, (cfl * Δs) / wave_speed)
    #= none:310 =#
    return FixedTimeStepSize(Δt_barotropic, averaging_kernel)
end
#= none:313 =#
#= none:313 =# @inline function weights_from_substeps(FT, substeps, averaging_kernel)
        #= none:313 =#
        #= none:315 =#
        τᶠ = range(FT(0), FT(2), length = substeps + 1)
        #= none:316 =#
        Δτ = τᶠ[2] - τᶠ[1]
        #= none:318 =#
        averaging_weights = map(averaging_kernel, τᶠ[2:end])
        #= none:319 =#
        idx = searchsortedlast(averaging_weights, 0, rev = true)
        #= none:320 =#
        substeps = idx
        #= none:322 =#
        averaging_weights = averaging_weights[1:idx]
        #= none:323 =#
        averaging_weights ./= sum(averaging_weights)
        #= none:325 =#
        return (Δτ, tuple(averaging_weights...))
    end
#= none:328 =#
function SplitExplicitSettings(grid = nothing; gravitational_acceleration = g_Earth, substeps = nothing, cfl = nothing, fixed_Δt = nothing, averaging_kernel = averaging_shape_function, timestepper = ForwardBackwardScheme())
    #= none:328 =#
    #= none:336 =#
    settings_kwargs = (; gravitational_acceleration, substeps, cfl, fixed_Δt, averaging_kernel, timestepper)
    #= none:343 =#
    if !(isnothing(grid))
        #= none:344 =#
        FT = eltype(grid)
    else
        #= none:350 =#
        FT = Float64
    end
    #= none:353 =#
    if !(isnothing(substeps)) && !(isnothing(cfl)) || isnothing(substeps) && isnothing(cfl)
        #= none:354 =#
        throw(ArgumentError("either specify a cfl or a number of substeps"))
    end
    #= none:357 =#
    if !(isnothing(cfl))
        #= none:358 =#
        if isnothing(grid)
            #= none:359 =#
            throw(ArgumentError(string("Need to provide the grid to calculate the barotropic substeps from the cfl. ", "For example, SplitExplicitFreeSurface(grid, cfl=0.7, ...)")))
        end
        #= none:362 =#
        substepping = FixedTimeStepSize(grid; cfl, gravitational_acceleration, averaging_kernel)
        #= none:363 =#
        if isnothing(fixed_Δt)
            #= none:364 =#
            return SplitExplicitSettings(substepping, timestepper, settings_kwargs)
        else
            #= none:366 =#
            substeps = ceil(Int, (2 * fixed_Δt) / substepping.Δt_barotropic)
        end
    end
    #= none:370 =#
    (fractional_step_size, averaging_weights) = weights_from_substeps(FT, substeps, averaging_kernel)
    #= none:371 =#
    substepping = FixedSubstepNumber(fractional_step_size, averaging_weights)
    #= none:373 =#
    return SplitExplicitSettings(substepping, timestepper, settings_kwargs)
end
#= none:377 =#
free_surface(free_surface::SplitExplicitFreeSurface) = begin
        #= none:377 =#
        free_surface.η
    end
#= none:380 =#
#= none:380 =# @inline explicit_barotropic_pressure_x_gradient(i, j, k, grid, ::SplitExplicitFreeSurface) = begin
            #= none:380 =#
            zero(grid)
        end
#= none:381 =#
#= none:381 =# @inline explicit_barotropic_pressure_y_gradient(i, j, k, grid, ::SplitExplicitFreeSurface) = begin
            #= none:381 =#
            zero(grid)
        end
#= none:384 =#
(sefs::SplitExplicitFreeSurface)(settings::SplitExplicitSettings) = begin
        #= none:384 =#
        SplitExplicitFreeSurface(sefs.η, sefs.state, sefs.auxiliary, sefs.gravitational_acceleration, settings)
    end
#= none:387 =#
Base.summary(s::FixedTimeStepSize) = begin
        #= none:387 =#
        string("Barotropic time step equal to $(prettytime(s.Δt_barotropic))")
    end
#= none:388 =#
Base.summary(s::FixedSubstepNumber) = begin
        #= none:388 =#
        string("Barotropic fractional step equal to $(s.fractional_step_size) times the baroclinic step")
    end
#= none:390 =#
Base.summary(sefs::SplitExplicitFreeSurface) = begin
        #= none:390 =#
        string("SplitExplicitFreeSurface with $(summary(sefs.settings.substepping))")
    end
#= none:392 =#
Base.show(io::IO, sefs::SplitExplicitFreeSurface) = begin
        #= none:392 =#
        print(io, "$(summary(sefs))\n")
    end
#= none:394 =#
function reset!(sefs::SplitExplicitFreeSurface)
    #= none:394 =#
    #= none:395 =#
    for name = propertynames(sefs.state)
        #= none:396 =#
        var = getproperty(sefs.state, name)
        #= none:397 =#
        fill!(var, 0)
        #= none:398 =#
    end
    #= none:400 =#
    fill!(sefs.auxiliary.Gᵁ, 0)
    #= none:401 =#
    fill!(sefs.auxiliary.Gⱽ, 0)
    #= none:403 =#
    return nothing
end
#= none:407 =#
Adapt.adapt_structure(to, free_surface::SplitExplicitFreeSurface) = begin
        #= none:407 =#
        SplitExplicitFreeSurface(Adapt.adapt(to, free_surface.η), nothing, nothing, free_surface.gravitational_acceleration, nothing)
    end
#= none:411 =#
for Type = (:SplitExplicitFreeSurface, :SplitExplicitSettings, :SplitExplicitState, :SplitExplicitAuxiliaryFields, :FixedTimeStepSize, :FixedSubstepNumber)
    #= none:418 =#
    #= none:418 =# @eval begin
            #= none:419 =#
            function on_architecture(to, fs::$Type)
                #= none:419 =#
                #= none:420 =#
                args = Tuple((on_architecture(to, prop) for prop = propertynames(fs)))
                #= none:421 =#
                return $Type(args...)
            end
        end
    #= none:424 =#
end