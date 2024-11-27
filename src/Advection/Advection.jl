
#= none:1 =#
module Advection
#= none:1 =#
#= none:3 =#
export div_𝐯u, div_𝐯v, div_𝐯w, div_Uc, momentum_flux_uu, momentum_flux_uv, momentum_flux_uw, momentum_flux_vu, momentum_flux_vv, momentum_flux_vw, momentum_flux_wu, momentum_flux_wv, momentum_flux_ww, advective_tracer_flux_x, advective_tracer_flux_y, advective_tracer_flux_z, AdvectionScheme, Centered, CenteredSecondOrder, CenteredFourthOrder, UpwindBiased, UpwindBiasedFirstOrder, UpwindBiasedThirdOrder, UpwindBiasedFifthOrder, WENO, WENOThirdOrder, WENOFifthOrder, VectorInvariant, WENOVectorInvariant, FluxFormAdvection, EnergyConserving, EnstrophyConserving
#= none:28 =#
using DocStringExtensions
#= none:30 =#
using Base: @propagate_inbounds
#= none:31 =#
using Adapt
#= none:32 =#
using OffsetArrays
#= none:34 =#
using Oceananigans.Grids
#= none:35 =#
using Oceananigans.Grids: with_halo, coordinates
#= none:36 =#
using Oceananigans.Architectures: architecture, CPU
#= none:38 =#
using Oceananigans.Operators
#= none:40 =#
import Base: show, summary
#= none:41 =#
import Oceananigans.Grids: required_halo_size_x, required_halo_size_y, required_halo_size_z
#= none:42 =#
import Oceananigans.Architectures: on_architecture
#= none:44 =#
abstract type AbstractAdvectionScheme{B, FT} end
#= none:45 =#
abstract type AbstractCenteredAdvectionScheme{B, FT} <: AbstractAdvectionScheme{B, FT} end
#= none:46 =#
abstract type AbstractUpwindBiasedAdvectionScheme{B, FT} <: AbstractAdvectionScheme{B, FT} end
#= none:56 =#
const advection_buffers = [1, 2, 3, 4, 5, 6]
#= none:58 =#
#= none:58 =# @inline (Base.eltype(::AbstractAdvectionScheme{<:Any, FT}) where FT) = begin
            #= none:58 =#
            FT
        end
#= none:60 =#
#= none:60 =# @inline (required_halo_size_x(::AbstractAdvectionScheme{B}) where B) = begin
            #= none:60 =#
            B
        end
#= none:61 =#
#= none:61 =# @inline (required_halo_size_y(::AbstractAdvectionScheme{B}) where B) = begin
            #= none:61 =#
            B
        end
#= none:62 =#
#= none:62 =# @inline (required_halo_size_z(::AbstractAdvectionScheme{B}) where B) = begin
            #= none:62 =#
            B
        end
#= none:64 =#
include("centered_advective_fluxes.jl")
#= none:65 =#
include("upwind_biased_advective_fluxes.jl")
#= none:67 =#
include("reconstruction_coefficients.jl")
#= none:68 =#
include("centered_reconstruction.jl")
#= none:69 =#
include("upwind_biased_reconstruction.jl")
#= none:70 =#
include("weno_reconstruction.jl")
#= none:71 =#
include("weno_interpolants.jl")
#= none:72 =#
include("stretched_weno_smoothness.jl")
#= none:73 =#
include("multi_dimensional_reconstruction.jl")
#= none:74 =#
include("vector_invariant_upwinding.jl")
#= none:75 =#
include("vector_invariant_advection.jl")
#= none:76 =#
include("vector_invariant_self_upwinding.jl")
#= none:77 =#
include("vector_invariant_cross_upwinding.jl")
#= none:78 =#
include("flux_form_advection.jl")
#= none:80 =#
include("flat_advective_fluxes.jl")
#= none:81 =#
include("topologically_conditional_interpolation.jl")
#= none:82 =#
include("immersed_advective_fluxes.jl")
#= none:83 =#
include("momentum_advection_operators.jl")
#= none:84 =#
include("tracer_advection_operators.jl")
#= none:85 =#
include("positivity_preserving_tracer_advection_operators.jl")
#= none:86 =#
include("cell_advection_timescale.jl")
#= none:87 =#
include("adapt_advection_order.jl")
end