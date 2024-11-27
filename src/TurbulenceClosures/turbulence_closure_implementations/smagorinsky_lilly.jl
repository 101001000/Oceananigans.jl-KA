
#= none:6 =#
struct SmagorinskyLilly{TD, FT, P} <: AbstractScalarDiffusivity{TD, ThreeDimensionalFormulation, 2}
    #= none:7 =#
    C::FT
    #= none:8 =#
    Cb::FT
    #= none:9 =#
    Pr::P
    #= none:11 =#
    function SmagorinskyLilly{TD, FT}(C, Cb, Pr) where {TD, FT}
        #= none:11 =#
        #= none:12 =#
        Pr = convert_diffusivity(FT, Pr; discrete_form = false)
        #= none:13 =#
        P = typeof(Pr)
        #= none:14 =#
        return new{TD, FT, P}(C, Cb, Pr)
    end
end
#= none:18 =#
#= none:18 =# @inline viscosity(::SmagorinskyLilly, K) = begin
            #= none:18 =#
            K.νₑ
        end
#= none:19 =#
#= none:19 =# @inline (diffusivity(closure::SmagorinskyLilly, K, ::Val{id}) where id) = begin
            #= none:19 =#
            K.νₑ / closure.Pr[id]
        end
#= none:21 =#
#= none:21 =# Core.@doc "    SmagorinskyLilly([time_discretization::TD = ExplicitTimeDiscretization(), FT=Float64;] C=0.16, Cb=1.0, Pr=1.0)\n\nReturn a `SmagorinskyLilly` type associated with the turbulence closure proposed by\n[Lilly62](@citet), [Smagorinsky1958](@citet), [Smagorinsky1963](@citet), and [Lilly66](@citet),\nwhich has an eddy viscosity of the form\n\n```\nνₑ = (C * Δᶠ)² * √(2Σ²) * √(1 - Cb * N² / Σ²)\n```\n\nand an eddy diffusivity of the form\n\n```\nκₑ = νₑ / Pr\n```\n\nwhere `Δᶠ` is the filter width, `Σ² = ΣᵢⱼΣᵢⱼ` is the double dot product of\nthe strain tensor `Σᵢⱼ`, `Pr` is the turbulent Prandtl number, `N²` is the\ntotal buoyancy gradient, and `Cb` is a constant the multiplies the Richardson\nnumber modification to the eddy viscosity.\n\nArguments\n=========\n\n* `time_discretization`: Either `ExplicitTimeDiscretization()` or `VerticallyImplicitTimeDiscretization()`, \n                         which integrates the terms involving only ``z``-derivatives in the\n                         viscous and diffusive fluxes with an implicit time discretization.\n                         Default `ExplicitTimeDiscretization()`.\n\n* `FT`: Float type; default `Float64`.\n\nKeyword arguments\n=================\n\n* `C`: Smagorinsky constant. Default value is 0.16 as obtained by Lilly (1966).\n\n* `Cb`: Buoyancy term multipler based on Lilly (1962) (`Cb = 0` turns it off, `Cb ≠ 0` turns it on.\n        Typically, and according to the original work by Lilly (1962), `Cb = 1 / Pr`.)\n\n* `Pr`: Turbulent Prandtl numbers for each tracer. Either a constant applied to every\n        tracer, or a `NamedTuple` with fields for each tracer individually.\n\nReferences\n==========\n\nSmagorinsky, J. \"On the numerical integration of the primitive equations of motion for\n    baroclinic flow in a closed region.\" Monthly Weather Review (1958)\n\nLilly, D. K. \"On the numerical simulation of buoyant convection.\" Tellus (1962)\n\nSmagorinsky, J. \"General circulation experiments with the primitive equations: I.\n    The basic experiment.\" Monthly Weather Review (1963)\n\nLilly, D. K. \"The representation of small-scale turbulence in numerical simulation experiments.\" \n    NCAR Manuscript No. 281, 0, (1966)\n" (SmagorinskyLilly(time_discretization::TD = ExplicitTimeDiscretization(), FT = Float64; C = 0.16, Cb = 1.0, Pr = 1.0) where TD) = begin
            #= none:78 =#
            SmagorinskyLilly{TD, FT}(C, Cb, Pr)
        end
#= none:81 =#
SmagorinskyLilly(FT::DataType; kwargs...) = begin
        #= none:81 =#
        SmagorinskyLilly(ExplicitTimeDiscretization(), FT; kwargs...)
    end
#= none:83 =#
function with_tracers(tracers, closure::SmagorinskyLilly{TD, FT}) where {TD, FT}
    #= none:83 =#
    #= none:84 =#
    Pr = tracer_diffusivities(tracers, closure.Pr)
    #= none:85 =#
    return SmagorinskyLilly{TD, FT}(closure.C, closure.Cb, Pr)
end
#= none:88 =#
#= none:88 =# Core.@doc "    stability(N², Σ², Cb)\n\nReturn the stability function\n\n```math\n    \\sqrt(1 - Cb N^2 / Σ^2 )\n```\n\nwhen ``N^2 > 0``, and 1 otherwise.\n" #= none:99 =# @inline(function stability(N²::FT, Σ²::FT, Cb::FT) where FT
            #= none:99 =#
            #= none:100 =#
            N²⁺ = max(zero(FT), N²)
            #= none:101 =#
            ς² = one(FT) - min(one(FT), (Cb * N²⁺) / Σ²)
            #= none:102 =#
            return ifelse(Σ² == 0, zero(FT), sqrt(ς²))
        end)
#= none:105 =#
#= none:105 =# @kernel function _compute_smagorinsky_viscosity!(νₑ, grid, closure, buoyancy, velocities, tracers)
        #= none:105 =#
        #= none:106 =#
        (i, j, k) = #= none:106 =# @index(Global, NTuple)
        #= none:109 =#
        Σ² = ΣᵢⱼΣᵢⱼᶜᶜᶜ(i, j, k, grid, velocities.u, velocities.v, velocities.w)
        #= none:112 =#
        N² = ℑzᵃᵃᶜ(i, j, k, grid, ∂z_b, buoyancy, tracers)
        #= none:113 =#
        ς = stability(N², Σ², closure.Cb)
        #= none:116 =#
        Δ³ = Δxᶜᶜᶜ(i, j, k, grid) * Δyᶜᶜᶜ(i, j, k, grid) * Δzᶜᶜᶜ(i, j, k, grid)
        #= none:117 =#
        Δᶠ = cbrt(Δ³)
        #= none:118 =#
        C = closure.C
        #= none:120 =#
        #= none:120 =# @inbounds νₑ[i, j, k] = ς * (C * Δᶠ) ^ 2 * sqrt(2Σ²)
    end
#= none:123 =#
function compute_diffusivities!(diffusivity_fields, closure::SmagorinskyLilly, model; parameters = :xyz)
    #= none:123 =#
    #= none:124 =#
    arch = model.architecture
    #= none:125 =#
    grid = model.grid
    #= none:126 =#
    buoyancy = model.buoyancy
    #= none:127 =#
    velocities = model.velocities
    #= none:128 =#
    tracers = model.tracers
    #= none:130 =#
    launch!(arch, grid, parameters, _compute_smagorinsky_viscosity!, diffusivity_fields.νₑ, grid, closure, buoyancy, velocities, tracers)
    #= none:133 =#
    return nothing
end
#= none:136 =#
#= none:136 =# @inline (κᶠᶜᶜ(i, j, k, grid, closure::SmagorinskyLilly, K, ::Val{id}, args...) where id) = begin
            #= none:136 =#
            ℑxᶠᵃᵃ(i, j, k, grid, K.νₑ) / closure.Pr[id]
        end
#= none:137 =#
#= none:137 =# @inline (κᶜᶠᶜ(i, j, k, grid, closure::SmagorinskyLilly, K, ::Val{id}, args...) where id) = begin
            #= none:137 =#
            ℑyᵃᶠᵃ(i, j, k, grid, K.νₑ) / closure.Pr[id]
        end
#= none:138 =#
#= none:138 =# @inline (κᶜᶜᶠ(i, j, k, grid, closure::SmagorinskyLilly, K, ::Val{id}, args...) where id) = begin
            #= none:138 =#
            ℑzᵃᵃᶠ(i, j, k, grid, K.νₑ) / closure.Pr[id]
        end
#= none:149 =#
#= none:149 =# Core.@doc "Return the double dot product of strain at `ccc`." #= none:150 =# @inline(function ΣᵢⱼΣᵢⱼᶜᶜᶜ(i, j, k, grid, u, v, w)
            #= none:150 =#
            #= none:151 =#
            return tr_Σ²(i, j, k, grid, u, v, w) + 2 * ℑxyᶜᶜᵃ(i, j, k, grid, Σ₁₂², u, v, w) + 2 * ℑxzᶜᵃᶜ(i, j, k, grid, Σ₁₃², u, v, w) + 2 * ℑyzᵃᶜᶜ(i, j, k, grid, Σ₂₃², u, v, w)
        end)
#= none:159 =#
#= none:159 =# Core.@doc "Return the double dot product of strain at `ffc`." #= none:160 =# @inline(function ΣᵢⱼΣᵢⱼᶠᶠᶜ(i, j, k, grid, u, v, w)
            #= none:160 =#
            #= none:161 =#
            return ℑxyᶠᶠᵃ(i, j, k, grid, tr_Σ², u, v, w) + 2 * Σ₁₂²(i, j, k, grid, u, v, w) + 2 * ℑyzᵃᶠᶜ(i, j, k, grid, Σ₁₃², u, v, w) + 2 * ℑxzᶠᵃᶜ(i, j, k, grid, Σ₂₃², u, v, w)
        end)
#= none:169 =#
#= none:169 =# Core.@doc "Return the double dot product of strain at `fcf`." #= none:170 =# @inline(function ΣᵢⱼΣᵢⱼᶠᶜᶠ(i, j, k, grid, u, v, w)
            #= none:170 =#
            #= none:171 =#
            return ℑxzᶠᵃᶠ(i, j, k, grid, tr_Σ², u, v, w) + 2 * ℑyzᵃᶜᶠ(i, j, k, grid, Σ₁₂², u, v, w) + 2 * Σ₁₃²(i, j, k, grid, u, v, w) + 2 * ℑxyᶠᶜᵃ(i, j, k, grid, Σ₂₃², u, v, w)
        end)
#= none:179 =#
#= none:179 =# Core.@doc "Return the double dot product of strain at `cff`." #= none:180 =# @inline(function ΣᵢⱼΣᵢⱼᶜᶠᶠ(i, j, k, grid, u, v, w)
            #= none:180 =#
            #= none:181 =#
            return ℑyzᵃᶠᶠ(i, j, k, grid, tr_Σ², u, v, w) + 2 * ℑxzᶜᵃᶠ(i, j, k, grid, Σ₁₂², u, v, w) + 2 * ℑxyᶜᶠᵃ(i, j, k, grid, Σ₁₃², u, v, w) + 2 * Σ₂₃²(i, j, k, grid, u, v, w)
        end)
#= none:189 =#
#= none:189 =# Core.@doc "Return the double dot product of strain at `ccf`." #= none:190 =# @inline(function ΣᵢⱼΣᵢⱼᶜᶜᶠ(i, j, k, grid, u, v, w)
            #= none:190 =#
            #= none:191 =#
            return ℑzᵃᵃᶠ(i, j, k, grid, tr_Σ², u, v, w) + 2 * ℑxyzᶜᶜᶠ(i, j, k, grid, Σ₁₂², u, v, w) + 2 * ℑxᶜᵃᵃ(i, j, k, grid, Σ₁₃², u, v, w) + 2 * ℑyᵃᶜᵃ(i, j, k, grid, Σ₂₃², u, v, w)
        end)
#= none:199 =#
Base.summary(closure::SmagorinskyLilly) = begin
        #= none:199 =#
        string("SmagorinskyLilly: C=$(closure.C), Cb=$(closure.Cb), Pr=$(closure.Pr)")
    end
#= none:200 =#
Base.show(io::IO, closure::SmagorinskyLilly) = begin
        #= none:200 =#
        print(io, summary(closure))
    end
#= none:206 =#
function DiffusivityFields(grid, tracer_names, bcs, closure::SmagorinskyLilly)
    #= none:206 =#
    #= none:208 =#
    default_eddy_viscosity_bcs = (; νₑ = FieldBoundaryConditions(grid, (Center, Center, Center)))
    #= none:209 =#
    bcs = merge(default_eddy_viscosity_bcs, bcs)
    #= none:210 =#
    νₑ = CenterField(grid, boundary_conditions = bcs.νₑ)
    #= none:212 =#
    return (; νₑ)
end