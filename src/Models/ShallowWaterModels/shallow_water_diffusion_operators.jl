
#= none:1 =#
using Oceananigans.Operators
#= none:2 =#
using Oceananigans.Architectures: device
#= none:3 =#
using Oceananigans.TurbulenceClosures: ExplicitTimeDiscretization, ThreeDimensionalFormulation
#= none:5 =#
using Oceananigans.TurbulenceClosures: AbstractScalarDiffusivity, convert_diffusivity, viscosity_location, viscosity, ν_σᶜᶜᶜ, ∂ⱼ_τ₁ⱼ, ∂ⱼ_τ₂ⱼ
#= none:14 =#
import Oceananigans.TurbulenceClosures: DiffusivityFields, compute_diffusivities!, viscosity, with_tracers, νᶜᶜᶜ
#= none:21 =#
struct ShallowWaterScalarDiffusivity{V, X, N} <: AbstractScalarDiffusivity{ExplicitTimeDiscretization, ThreeDimensionalFormulation, N}
    #= none:22 =#
    ν::V
    #= none:23 =#
    ξ::X
    #= none:24 =#
    (ShallowWaterScalarDiffusivity{N}(ν::V, ξ::X) where {N, V, X}) = begin
            #= none:24 =#
            new{V, X, N}(ν, ξ)
        end
end
#= none:27 =#
#= none:27 =# Core.@doc "    ShallowWaterScalarDiffusivity([FT::DataType=Float64;]\n                                  ν=0, ξ=0, discrete_form=false)\n\nReturn a scalar diffusivity for the shallow water model.\n\nThe diffusivity for the shallow water model is calculated as `h * ν` so that we get a\nviscous term in the form ``h^{-1} 𝛁 ⋅ (h ν t)``, where ``t`` is the 2D stress tensor plus\na trace, i.e., ``t = 𝛁𝐮 + (𝛁𝐮)^T - ξ I ⋅ (𝛁 ⋅ 𝐮)``.\n\nWith the `VectorInvariantFormulation()` (that evolves ``u`` and ``v``) we compute\n``h^{-1} 𝛁(ν h 𝛁 t)``, while with the `ConservativeFormulation()` (that evolves\n``u h`` and ``v h``) we compute ``𝛁 (ν h 𝛁 t)``.\n" function ShallowWaterScalarDiffusivity(FT::DataType = Float64; ν = 0, ξ = 0, discrete_form = false, required_halo_size = 1)
        #= none:41 =#
        #= none:42 =#
        ν = convert_diffusivity(FT, ν; discrete_form)
        #= none:43 =#
        ξ = convert_diffusivity(FT, ξ; discrete_form)
        #= none:44 =#
        return ShallowWaterScalarDiffusivity{required_halo_size}(ν, ξ)
    end
#= none:48 =#
with_tracers(tracers, closure::ShallowWaterScalarDiffusivity) = begin
        #= none:48 =#
        closure
    end
#= none:49 =#
viscosity(closure::ShallowWaterScalarDiffusivity, K) = begin
        #= none:49 =#
        closure.ν
    end
#= none:51 =#
(Adapt.adapt_structure(to, closure::ShallowWaterScalarDiffusivity{B}) where B) = begin
        #= none:51 =#
        ShallowWaterScalarDiffusivity{B}(Adapt.adapt(to, closure.ν), Adapt.adapt(to, closure.ξ))
    end
#= none:54 =#
(on_architecture(to, closure::ShallowWaterScalarDiffusivity{B}) where B) = begin
        #= none:54 =#
        ShallowWaterScalarDiffusivity{B}(on_architecture(to, closure.ν), on_architecture(to, closure.ξ))
    end
#= none:61 =#
#= none:61 =# @kernel function _calculate_shallow_water_viscosity!(νₑ, grid, closure, clock, fields)
        #= none:61 =#
        #= none:62 =#
        (i, j, k) = #= none:62 =# @index(Global, NTuple)
        #= none:63 =#
        νₑ[i, j, k] = fields.h[i, j, k] * νᶜᶜᶜ(i, j, k, grid, viscosity_location(closure), closure.ν, clock, fields)
    end
#= none:66 =#
function compute_diffusivities!(diffusivity_fields, closure::ShallowWaterScalarDiffusivity, model)
    #= none:66 =#
    #= none:68 =#
    arch = model.architecture
    #= none:69 =#
    grid = model.grid
    #= none:70 =#
    clock = model.clock
    #= none:72 =#
    model_fields = shallow_water_fields(model.velocities, model.tracers, model.solution, formulation(model))
    #= none:74 =#
    launch!(arch, grid, :xyz, _calculate_shallow_water_viscosity!, diffusivity_fields.νₑ, grid, closure, clock, model_fields)
    #= none:78 =#
    return nothing
end
#= none:81 =#
DiffusivityFields(grid, tracer_names, bcs, ::ShallowWaterScalarDiffusivity) = begin
        #= none:81 =#
        (; νₑ = CenterField(grid, boundary_conditions = bcs.h))
    end
#= none:87 =#
#= none:87 =# @inline sw_∂ⱼ_τ₁ⱼ(i, j, k, grid, closure, K, clock, fields, ::ConservativeFormulation) = begin
            #= none:87 =#
            ∂ⱼ_τ₁ⱼ(i, j, k, grid, closure, K, clock, fields, nothing) + trace_term_x(i, j, k, grid, closure, K, clock, fields)
        end
#= none:90 =#
#= none:90 =# @inline sw_∂ⱼ_τ₂ⱼ(i, j, k, grid, closure, K, clock, fields, ::ConservativeFormulation) = begin
            #= none:90 =#
            ∂ⱼ_τ₂ⱼ(i, j, k, grid, closure, K, clock, fields, nothing) + trace_term_y(i, j, k, grid, closure, K, clock, fields)
        end
#= none:93 =#
#= none:93 =# @inline sw_∂ⱼ_τ₁ⱼ(i, j, k, grid, closure, K, clock, fields, ::VectorInvariantFormulation) = begin
            #= none:93 =#
            (∂ⱼ_τ₁ⱼ(i, j, k, grid, closure, K, clock, fields, nothing) + trace_term_x(i, j, k, grid, closure, K, clock, fields)) / ℑxᶠᵃᵃ(i, j, k, grid, fields.h)
        end
#= none:96 =#
#= none:96 =# @inline sw_∂ⱼ_τ₂ⱼ(i, j, k, grid, closure, K, clock, fields, ::VectorInvariantFormulation) = begin
            #= none:96 =#
            (∂ⱼ_τ₂ⱼ(i, j, k, grid, closure, K, clock, fields, nothing) + trace_term_y(i, j, k, grid, closure, K, clock, fields)) / ℑyᵃᶠᵃ(i, j, k, grid, fields.h)
        end
#= none:99 =#
#= none:99 =# @inline trace_term_x(i, j, k, grid, clo, K, clk, fields) = begin
            #= none:99 =#
            (-(δxᶠᵃᵃ(i, j, k, grid, ν_σᶜᶜᶜ, clo, K, clk, fields, div_xyᶜᶜᶜ, fields.u, fields.v)) * clo.ξ) / Azᶠᶜᶜ(i, j, k, grid)
        end
#= none:100 =#
#= none:100 =# @inline trace_term_y(i, j, k, grid, clo, K, clk, fields) = begin
            #= none:100 =#
            (-(δyᵃᶠᵃ(i, j, k, grid, ν_σᶜᶜᶜ, clo, K, clk, fields, div_xyᶜᶜᶜ, fields.u, fields.v)) * clo.ξ) / Azᶠᶜᶜ(i, j, k, grid)
        end
#= none:102 =#
#= none:102 =# @inline trace_term_x(i, j, k, grid, ::Nothing, args...) = begin
            #= none:102 =#
            zero(grid)
        end
#= none:103 =#
#= none:103 =# @inline trace_term_y(i, j, k, grid, ::Nothing, args...) = begin
            #= none:103 =#
            zero(grid)
        end