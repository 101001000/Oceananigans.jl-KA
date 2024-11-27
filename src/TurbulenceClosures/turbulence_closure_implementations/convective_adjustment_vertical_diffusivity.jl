
#= none:1 =#
using Oceananigans.Architectures: architecture
#= none:2 =#
using Oceananigans.AbstractOperations: KernelFunctionOperation
#= none:3 =#
using Oceananigans.BuoyancyModels: ∂z_b
#= none:4 =#
using Oceananigans.Operators: ℑzᵃᵃᶜ
#= none:6 =#
struct ConvectiveAdjustmentVerticalDiffusivity{TD, CK, CN, BK, BN} <: AbstractScalarDiffusivity{TD, VerticalFormulation, 1}
    #= none:7 =#
    convective_κz::CK
    #= none:8 =#
    convective_νz::CN
    #= none:9 =#
    background_κz::BK
    #= none:10 =#
    background_νz::BN
    #= none:12 =#
    function ConvectiveAdjustmentVerticalDiffusivity{TD}(convective_κz::CK, convective_νz::CN, background_κz::BK, background_νz::BN) where {TD, CK, CN, BK, BN}
        #= none:12 =#
        #= none:17 =#
        return new{TD, CK, CN, BK, BN}(convective_κz, convective_νz, background_κz, background_νz)
    end
end
#= none:21 =#
#= none:21 =# Core.@doc "    ConvectiveAdjustmentVerticalDiffusivity([time_discretization = VerticallyImplicitTimeDiscretization(), FT=Float64;]\n                                            convective_κz = 0,\n                                            convective_νz = 0,\n                                            background_κz = 0,\n                                            background_νz = 0)\n\nReturn a convective adjustment vertical diffusivity closure that applies different values of diffusivity and/or viscosity depending\nwhether the region is statically stable (positive or zero buoyancy gradient) or statically unstable (negative buoyancy gradient).\n\nArguments\n=========\n\n* `time_discretization`: Either `ExplicitTimeDiscretization()` or `VerticallyImplicitTimeDiscretization()`;\n                         default `VerticallyImplicitTimeDiscretization()`.\n\n* `FT`: Float type; default `Float64`.\n\nKeyword arguments\n=================\n\n* `convective_κz`: Vertical tracer diffusivity in regions with negative (unstable) buoyancy gradients. Either\n                   a single number, function, array, field, or tuple of diffusivities for each tracer.\n\n* `background_κz`: Vertical tracer diffusivity in regions with zero or positive (stable) buoyancy gradients.\n\n* `convective_νz`: Vertical viscosity in regions with negative (unstable) buoyancy gradients. Either\n                  a number, function, array, or field.\n\n* `background_κz`: Vertical viscosity in regions with zero or positive (stable) buoyancy gradients.\n\nExample\n=======\n\n```jldoctest\njulia> using Oceananigans\n\njulia> cavd = ConvectiveAdjustmentVerticalDiffusivity(convective_κz = 1)\nConvectiveAdjustmentVerticalDiffusivity{VerticallyImplicitTimeDiscretization}(background_κz=0.0 convective_κz=1 background_νz=0.0 convective_νz=0.0)\n```\n" function ConvectiveAdjustmentVerticalDiffusivity(time_discretization = VerticallyImplicitTimeDiscretization(), FT = Float64; convective_κz = zero(FT), convective_νz = zero(FT), background_κz = zero(FT), background_νz = zero(FT))
        #= none:62 =#
        #= none:68 =#
        return ConvectiveAdjustmentVerticalDiffusivity{typeof(time_discretization)}(convective_κz, convective_νz, background_κz, background_νz)
    end
#= none:72 =#
ConvectiveAdjustmentVerticalDiffusivity(FT::DataType; kwargs...) = begin
        #= none:72 =#
        ConvectiveAdjustmentVerticalDiffusivity(VerticallyImplicitTimeDiscretization(), FT; kwargs...)
    end
#= none:74 =#
const CAVD = ConvectiveAdjustmentVerticalDiffusivity
#= none:81 =#
const CAVDArray = AbstractArray{<:CAVD}
#= none:82 =#
const FlavorOfCAVD = Union{CAVD, CAVDArray}
#= none:84 =#
with_tracers(tracers, closure::FlavorOfCAVD) = begin
        #= none:84 =#
        closure
    end
#= none:85 =#
DiffusivityFields(grid, tracer_names, bcs, closure::FlavorOfCAVD) = begin
        #= none:85 =#
        (; κᶜ = ZFaceField(grid), κᵘ = ZFaceField(grid))
    end
#= none:86 =#
#= none:86 =# @inline viscosity_location(::FlavorOfCAVD) = begin
            #= none:86 =#
            (Center(), Center(), Face())
        end
#= none:87 =#
#= none:87 =# @inline diffusivity_location(::FlavorOfCAVD) = begin
            #= none:87 =#
            (Center(), Center(), Face())
        end
#= none:88 =#
#= none:88 =# @inline viscosity(::FlavorOfCAVD, diffusivities) = begin
            #= none:88 =#
            diffusivities.κᵘ
        end
#= none:89 =#
#= none:89 =# @inline diffusivity(::FlavorOfCAVD, diffusivities, id) = begin
            #= none:89 =#
            diffusivities.κᶜ
        end
#= none:91 =#
function compute_diffusivities!(diffusivities, closure::FlavorOfCAVD, model; parameters = :xyz)
    #= none:91 =#
    #= none:93 =#
    arch = model.architecture
    #= none:94 =#
    grid = model.grid
    #= none:95 =#
    tracers = model.tracers
    #= none:96 =#
    buoyancy = model.buoyancy
    #= none:98 =#
    launch!(arch, grid, parameters, compute_convective_adjustment_diffusivities!, diffusivities, grid, closure, tracers, buoyancy)
    #= none:103 =#
    return nothing
end
#= none:106 =#
#= none:106 =# @inline is_stableᶜᶜᶠ(i, j, k, grid, tracers, buoyancy) = begin
            #= none:106 =#
            ∂z_b(i, j, k, grid, buoyancy, tracers) >= 0
        end
#= none:108 =#
#= none:108 =# @kernel function compute_convective_adjustment_diffusivities!(diffusivities, grid, closure, tracers, buoyancy)
        #= none:108 =#
        #= none:109 =#
        (i, j, k) = #= none:109 =# @index(Global, NTuple)
        #= none:112 =#
        closure_ij = getclosure(i, j, closure)
        #= none:114 =#
        stable_cell = is_stableᶜᶜᶠ(i, j, k, grid, tracers, buoyancy)
        #= none:116 =#
        #= none:116 =# @inbounds diffusivities.κᶜ[i, j, k] = ifelse(stable_cell, closure_ij.background_κz, closure_ij.convective_κz)
        #= none:120 =#
        #= none:120 =# @inbounds diffusivities.κᵘ[i, j, k] = ifelse(stable_cell, closure_ij.background_νz, closure_ij.convective_νz)
    end
#= none:129 =#
function Base.summary(closure::ConvectiveAdjustmentVerticalDiffusivity{TD}) where TD
    #= none:129 =#
    #= none:130 =#
    return string("ConvectiveAdjustmentVerticalDiffusivity{$(TD)}" * "(background_κz=", prettysummary(closure.background_κz), " convective_κz=", prettysummary(closure.convective_κz), " background_νz=", prettysummary(closure.background_νz), " convective_νz=", prettysummary(closure.convective_νz), ")")
end
#= none:135 =#
Base.show(io::IO, closure::ConvectiveAdjustmentVerticalDiffusivity) = begin
        #= none:135 =#
        print(io, summary(closure))
    end