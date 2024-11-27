
#= none:1 =#
module TurbulenceClosures
#= none:1 =#
#= none:3 =#
export AbstractEddyViscosityClosure, VerticalScalarDiffusivity, HorizontalScalarDiffusivity, HorizontalDivergenceScalarDiffusivity, ScalarDiffusivity, VerticalScalarBiharmonicDiffusivity, HorizontalScalarBiharmonicDiffusivity, HorizontalDivergenceScalarBiharmonicDiffusivity, ScalarBiharmonicDiffusivity, TwoDimensionalLeith, SmagorinskyLilly, AnisotropicMinimumDissipation, ConvectiveAdjustmentVerticalDiffusivity, RiBasedVerticalDiffusivity, IsopycnalSkewSymmetricDiffusivity, FluxTapering, ExplicitTimeDiscretization, VerticallyImplicitTimeDiscretization, DiffusivityFields, compute_diffusivities!, viscosity, diffusivity, ∇_dot_qᶜ, ∂ⱼ_τ₁ⱼ, ∂ⱼ_τ₂ⱼ, ∂ⱼ_τ₃ⱼ, cell_diffusion_timescale
#= none:36 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:37 =#
using KernelAbstractions
#= none:38 =#
using Adapt
#= none:40 =#
import Oceananigans.Utils: with_tracers, prettysummary
#= none:42 =#
using Oceananigans
#= none:43 =#
using Oceananigans.Architectures
#= none:44 =#
using Oceananigans.Grids
#= none:45 =#
using Oceananigans.Operators
#= none:46 =#
using Oceananigans.BoundaryConditions
#= none:47 =#
using Oceananigans.Fields
#= none:48 =#
using Oceananigans.BuoyancyModels
#= none:49 =#
using Oceananigans.Utils
#= none:51 =#
using Oceananigans.Architectures: AbstractArchitecture, device
#= none:52 =#
using Oceananigans.Fields: FunctionField
#= none:53 =#
using Oceananigans.ImmersedBoundaries: z_bottom
#= none:55 =#
import Oceananigans.Grids: required_halo_size_x, required_halo_size_y, required_halo_size_z
#= none:56 =#
import Oceananigans.Architectures: on_architecture
#= none:58 =#
const VerticallyBoundedGrid{FT} = AbstractGrid{FT, <:Any, <:Any, <:Bounded}
#= none:64 =#
#= none:64 =# Core.@doc "    AbstractTurbulenceClosure\n\nAbstract supertype for turbulence closures.\n" abstract type AbstractTurbulenceClosure{TimeDiscretization, RequiredHalo} end
#= none:72 =#
validate_closure(closure) = begin
        #= none:72 =#
        closure
    end
#= none:73 =#
closure_summary(closure) = begin
        #= none:73 =#
        summary(closure)
    end
#= none:74 =#
with_tracers(tracers, closure::AbstractTurbulenceClosure) = begin
        #= none:74 =#
        closure
    end
#= none:75 =#
compute_diffusivities!(K, closure::AbstractTurbulenceClosure, args...; kwargs...) = begin
        #= none:75 =#
        nothing
    end
#= none:82 =#
#= none:82 =# @inline (required_halo_size_x(::AbstractTurbulenceClosure{TD, B}) where {TD, B}) = begin
            #= none:82 =#
            B
        end
#= none:83 =#
#= none:83 =# @inline (required_halo_size_y(::AbstractTurbulenceClosure{TD, B}) where {TD, B}) = begin
            #= none:83 =#
            B
        end
#= none:84 =#
#= none:84 =# @inline (required_halo_size_z(::AbstractTurbulenceClosure{TD, B}) where {TD, B}) = begin
            #= none:84 =#
            B
        end
#= none:86 =#
const ClosureKinda = Union{Nothing, AbstractTurbulenceClosure, AbstractArray{<:AbstractTurbulenceClosure}}
#= none:87 =#
add_closure_specific_boundary_conditions(closure::ClosureKinda, bcs, args...) = begin
        #= none:87 =#
        bcs
    end
#= none:90 =#
function shear_production end
#= none:91 =#
function buoyancy_flux end
#= none:92 =#
function dissipation end
#= none:93 =#
function hydrostatic_turbulent_kinetic_energy_tendency end
#= none:99 =#
for dir = (:x, :y, :z)
    #= none:100 =#
    diffusive_flux = Symbol(:diffusive_flux_, dir)
    #= none:101 =#
    viscous_flux_u = Symbol(:viscous_flux_u, dir)
    #= none:102 =#
    viscous_flux_v = Symbol(:viscous_flux_v, dir)
    #= none:103 =#
    viscous_flux_w = Symbol(:viscous_flux_w, dir)
    #= none:104 =#
    #= none:104 =# @eval begin
            #= none:105 =#
            #= none:105 =# @inline $diffusive_flux(i, j, k, grid, clo::AbstractTurbulenceClosure, args...) = begin
                        #= none:105 =#
                        zero(grid)
                    end
            #= none:106 =#
            #= none:106 =# @inline $viscous_flux_u(i, j, k, grid, clo::AbstractTurbulenceClosure, args...) = begin
                        #= none:106 =#
                        zero(grid)
                    end
            #= none:107 =#
            #= none:107 =# @inline $viscous_flux_v(i, j, k, grid, clo::AbstractTurbulenceClosure, args...) = begin
                        #= none:107 =#
                        zero(grid)
                    end
            #= none:108 =#
            #= none:108 =# @inline $viscous_flux_w(i, j, k, grid, clo::AbstractTurbulenceClosure, args...) = begin
                        #= none:108 =#
                        zero(grid)
                    end
        end
    #= none:110 =#
end
#= none:117 =#
#= none:117 =# @inline getclosure(i, j, closure::AbstractMatrix{<:AbstractTurbulenceClosure}) = begin
            #= none:117 =#
            #= none:117 =# @inbounds closure[i, j]
        end
#= none:118 =#
#= none:118 =# @inline getclosure(i, j, closure::AbstractVector{<:AbstractTurbulenceClosure}) = begin
            #= none:118 =#
            #= none:118 =# @inbounds closure[i]
        end
#= none:119 =#
#= none:119 =# @inline getclosure(i, j, closure::AbstractTurbulenceClosure) = begin
            #= none:119 =#
            closure
        end
#= none:121 =#
#= none:121 =# @inline clip(x) = begin
            #= none:121 =#
            max(zero(x), x)
        end
#= none:123 =#
const c = Center()
#= none:124 =#
const f = Face()
#= none:126 =#
#= none:126 =# @inline z_top(i, j, grid) = begin
            #= none:126 =#
            znode(i, j, grid.Nz + 1, grid, c, c, f)
        end
#= none:128 =#
#= none:128 =# @inline depthᶜᶜᶠ(i, j, k, grid) = begin
            #= none:128 =#
            clip(z_top(i, j, grid) - znode(i, j, k, grid, c, c, f))
        end
#= none:129 =#
#= none:129 =# @inline depthᶜᶜᶜ(i, j, k, grid) = begin
            #= none:129 =#
            clip(z_top(i, j, grid) - znode(i, j, k, grid, c, c, c))
        end
#= none:130 =#
#= none:130 =# @inline total_depthᶜᶜᵃ(i, j, grid) = begin
            #= none:130 =#
            clip(z_top(i, j, grid) - z_bottom(i, j, grid))
        end
#= none:132 =#
#= none:132 =# @inline function height_above_bottomᶜᶜᶠ(i, j, k, grid)
        #= none:132 =#
        #= none:133 =#
        h = znode(i, j, k, grid, c, c, f) - z_bottom(i, j, grid)
        #= none:136 =#
        Δz = Δzᶜᶜᶜ(i, j, k - 1, grid)
        #= none:137 =#
        return max(Δz, h)
    end
#= none:140 =#
#= none:140 =# @inline function height_above_bottomᶜᶜᶜ(i, j, k, grid)
        #= none:140 =#
        #= none:141 =#
        Δz = Δzᶜᶜᶜ(i, j, k, grid)
        #= none:142 =#
        h = znode(i, j, k, grid, c, c, c) - z_bottom(i, j, grid)
        #= none:143 =#
        return max(Δz / 2, h)
    end
#= none:146 =#
#= none:146 =# @inline wall_vertical_distanceᶜᶜᶠ(i, j, k, grid) = begin
            #= none:146 =#
            min(depthᶜᶜᶠ(i, j, k, grid), height_above_bottomᶜᶜᶠ(i, j, k, grid))
        end
#= none:147 =#
#= none:147 =# @inline wall_vertical_distanceᶜᶜᶜ(i, j, k, grid) = begin
            #= none:147 =#
            min(depthᶜᶜᶜ(i, j, k, grid), height_above_bottomᶜᶜᶜ(i, j, k, grid))
        end
#= none:149 =#
include("discrete_diffusion_function.jl")
#= none:150 =#
include("implicit_explicit_time_discretization.jl")
#= none:151 =#
include("turbulence_closure_utils.jl")
#= none:152 =#
include("closure_kernel_operators.jl")
#= none:153 =#
include("velocity_tracer_gradients.jl")
#= none:154 =#
include("abstract_scalar_diffusivity_closure.jl")
#= none:155 =#
include("abstract_scalar_biharmonic_diffusivity_closure.jl")
#= none:156 =#
include("closure_tuples.jl")
#= none:157 =#
include("isopycnal_rotation_tensor_components.jl")
#= none:158 =#
include("immersed_diffusive_fluxes.jl")
#= none:161 =#
include("vertically_implicit_diffusion_solver.jl")
#= none:164 =#
include("turbulence_closure_implementations/nothing_closure.jl")
#= none:167 =#
include("turbulence_closure_implementations/scalar_diffusivity.jl")
#= none:168 =#
include("turbulence_closure_implementations/scalar_biharmonic_diffusivity.jl")
#= none:169 =#
include("turbulence_closure_implementations/smagorinsky_lilly.jl")
#= none:170 =#
include("turbulence_closure_implementations/anisotropic_minimum_dissipation.jl")
#= none:171 =#
include("turbulence_closure_implementations/convective_adjustment_vertical_diffusivity.jl")
#= none:172 =#
include("turbulence_closure_implementations/TKEBasedVerticalDiffusivities/TKEBasedVerticalDiffusivities.jl")
#= none:173 =#
include("turbulence_closure_implementations/ri_based_vertical_diffusivity.jl")
#= none:177 =#
include("turbulence_closure_implementations/isopycnal_skew_symmetric_diffusivity.jl")
#= none:178 =#
include("turbulence_closure_implementations/leith_enstrophy_diffusivity.jl")
#= none:180 =#
using .TKEBasedVerticalDiffusivities: CATKEVerticalDiffusivity, TKEDissipationVerticalDiffusivity
#= none:183 =#
include("diffusivity_fields.jl")
#= none:184 =#
include("turbulence_closure_diagnostics.jl")
end