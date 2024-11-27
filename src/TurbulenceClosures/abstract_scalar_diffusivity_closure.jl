
#= none:1 =#
using Oceananigans.Operators: ℑxyᶠᶠᵃ, ℑxzᶠᵃᶠ, ℑyzᵃᶠᶠ
#= none:3 =#
#= none:3 =# Core.@doc "    abstract type AbstractScalarDiffusivity <: AbstractTurbulenceClosure end\n\nAbstract type for closures with scalar diffusivities.\n" abstract type AbstractScalarDiffusivity{TD, F, N} <: AbstractTurbulenceClosure{TD, N} end
#= none:14 =#
abstract type AbstractDiffusivityFormulation end
#= none:16 =#
#= none:16 =# Core.@doc "    struct ThreeDimensionalFormulation end\n\nSpecifies a three-dimensionally-isotropic `ScalarDiffusivity`.\n" struct ThreeDimensionalFormulation <: AbstractDiffusivityFormulation
        #= none:21 =#
    end
#= none:23 =#
#= none:23 =# Core.@doc "    struct HorizontalFormulation end\n\nSpecifies a horizontally-isotropic, `VectorInvariant`, `ScalarDiffusivity`.\n" struct HorizontalFormulation <: AbstractDiffusivityFormulation
        #= none:28 =#
    end
#= none:30 =#
#= none:30 =# Core.@doc "    struct HorizontalDivergenceFormulation end\n\nSpecifies viscosity for \"divergence damping\". Has no effect on tracers.\n" struct HorizontalDivergenceFormulation <: AbstractDiffusivityFormulation
        #= none:35 =#
    end
#= none:37 =#
#= none:37 =# Core.@doc "    struct VerticalFormulation end\n\nSpecifies a `ScalarDiffusivity` acting only in the vertical direction.\n" struct VerticalFormulation <: AbstractDiffusivityFormulation
        #= none:42 =#
    end
#= none:44 =#
#= none:44 =# Core.@doc "    viscosity(closure, diffusivities)\n\nReturns the scalar viscosity associated with `closure`.\n" function viscosity end
#= none:51 =#
#= none:51 =# Core.@doc "    diffusivity(closure, tracer_index, diffusivity_fields)\n\nReturns the scalar diffusivity associated with `closure` and `tracer_index`.\n" function diffusivity end
#= none:58 =#
const c = Center()
#= none:61 =#
#= none:61 =# @inline viscosity_location(::AbstractScalarDiffusivity) = begin
            #= none:61 =#
            (c, c, c)
        end
#= none:62 =#
#= none:62 =# @inline diffusivity_location(::AbstractScalarDiffusivity) = begin
            #= none:62 =#
            (c, c, c)
        end
#= none:65 =#
viscosity(closure::Tuple, K) = begin
        #= none:65 =#
        Tuple((viscosity(closure[n], K[n]) for n = 1:length(closure)))
    end
#= none:66 =#
diffusivity(closure::Tuple, K, id) = begin
        #= none:66 =#
        Tuple((diffusivity(closure[n], K[n], id) for n = 1:length(closure)))
    end
#= none:68 =#
#= none:68 =# @inline (formulation(::AbstractScalarDiffusivity{TD, F}) where {TD, F}) = begin
            #= none:68 =#
            F()
        end
#= none:70 =#
Base.summary(::VerticalFormulation) = begin
        #= none:70 =#
        "VerticalFormulation"
    end
#= none:71 =#
Base.summary(::HorizontalFormulation) = begin
        #= none:71 =#
        "HorizontalFormulation"
    end
#= none:72 =#
Base.summary(::ThreeDimensionalFormulation) = begin
        #= none:72 =#
        "ThreeDimensionalFormulation"
    end
#= none:78 =#
const ASD = AbstractScalarDiffusivity
#= none:79 =#
const AID = AbstractScalarDiffusivity{<:Any, <:ThreeDimensionalFormulation}
#= none:80 =#
const AHD = AbstractScalarDiffusivity{<:Any, <:HorizontalFormulation}
#= none:81 =#
const ADD = AbstractScalarDiffusivity{<:Any, <:HorizontalDivergenceFormulation}
#= none:82 =#
const AVD = AbstractScalarDiffusivity{<:Any, <:VerticalFormulation}
#= none:84 =#
#= none:84 =# @inline νᶜᶜᶜ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:84 =#
            νᶜᶜᶜ(i, j, k, grid, viscosity_location(closure), viscosity(closure, K), args...)
        end
#= none:85 =#
#= none:85 =# @inline νᶠᶠᶜ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:85 =#
            νᶠᶠᶜ(i, j, k, grid, viscosity_location(closure), viscosity(closure, K), args...)
        end
#= none:86 =#
#= none:86 =# @inline νᶠᶜᶠ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:86 =#
            νᶠᶜᶠ(i, j, k, grid, viscosity_location(closure), viscosity(closure, K), args...)
        end
#= none:87 =#
#= none:87 =# @inline νᶜᶠᶠ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:87 =#
            νᶜᶠᶠ(i, j, k, grid, viscosity_location(closure), viscosity(closure, K), args...)
        end
#= none:89 =#
#= none:89 =# @inline κᶠᶜᶜ(i, j, k, grid, closure::ASD, K, id, args...) = begin
            #= none:89 =#
            κᶠᶜᶜ(i, j, k, grid, diffusivity_location(closure), diffusivity(closure, K, id), args...)
        end
#= none:90 =#
#= none:90 =# @inline κᶜᶠᶜ(i, j, k, grid, closure::ASD, K, id, args...) = begin
            #= none:90 =#
            κᶜᶠᶜ(i, j, k, grid, diffusivity_location(closure), diffusivity(closure, K, id), args...)
        end
#= none:91 =#
#= none:91 =# @inline κᶜᶜᶠ(i, j, k, grid, closure::ASD, K, id, args...) = begin
            #= none:91 =#
            κᶜᶜᶠ(i, j, k, grid, diffusivity_location(closure), diffusivity(closure, K, id), args...)
        end
#= none:94 =#
#= none:94 =# @inline νzᶜᶜᶜ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:94 =#
            νᶜᶜᶜ(i, j, k, grid, closure, K, args...)
        end
#= none:95 =#
#= none:95 =# @inline νzᶠᶠᶜ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:95 =#
            νᶠᶠᶜ(i, j, k, grid, closure, K, args...)
        end
#= none:96 =#
#= none:96 =# @inline νzᶠᶜᶠ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:96 =#
            νᶠᶜᶠ(i, j, k, grid, closure, K, args...)
        end
#= none:97 =#
#= none:97 =# @inline νzᶜᶠᶠ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:97 =#
            νᶜᶠᶠ(i, j, k, grid, closure, K, args...)
        end
#= none:98 =#
#= none:98 =# @inline νzᶠᶜᶠ(i, j, k, grid, closure::ASD, K, ::Nothing, args...) = begin
            #= none:98 =#
            νzᶠᶜᶠ(i, j, k, grid, closure, K, args...)
        end
#= none:99 =#
#= none:99 =# @inline νzᶜᶠᶠ(i, j, k, grid, closure::ASD, K, ::Nothing, args...) = begin
            #= none:99 =#
            νzᶜᶠᶠ(i, j, k, grid, closure, K, args...)
        end
#= none:101 =#
#= none:101 =# @inline κzᶠᶜᶜ(i, j, k, grid, closure::ASD, K, id, args...) = begin
            #= none:101 =#
            κᶠᶜᶜ(i, j, k, grid, closure, K, id, args...)
        end
#= none:102 =#
#= none:102 =# @inline κzᶜᶠᶜ(i, j, k, grid, closure::ASD, K, id, args...) = begin
            #= none:102 =#
            κᶜᶠᶜ(i, j, k, grid, closure, K, id, args...)
        end
#= none:103 =#
#= none:103 =# @inline κzᶜᶜᶠ(i, j, k, grid, closure::ASD, K, id, args...) = begin
            #= none:103 =#
            κᶜᶜᶠ(i, j, k, grid, closure, K, id, args...)
        end
#= none:105 =#
#= none:105 =# @inline νhᶜᶜᶜ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:105 =#
            νᶜᶜᶜ(i, j, k, grid, closure, K, args...)
        end
#= none:106 =#
#= none:106 =# @inline νhᶠᶠᶜ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:106 =#
            νᶠᶠᶜ(i, j, k, grid, closure, K, args...)
        end
#= none:107 =#
#= none:107 =# @inline νhᶠᶜᶠ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:107 =#
            νᶠᶜᶠ(i, j, k, grid, closure, K, args...)
        end
#= none:108 =#
#= none:108 =# @inline νhᶜᶠᶠ(i, j, k, grid, closure::ASD, K, args...) = begin
            #= none:108 =#
            νᶜᶠᶠ(i, j, k, grid, closure, K, args...)
        end
#= none:110 =#
#= none:110 =# @inline κhᶠᶜᶜ(i, j, k, grid, closure::ASD, K, id, args...) = begin
            #= none:110 =#
            κᶠᶜᶜ(i, j, k, grid, closure, K, id, args...)
        end
#= none:111 =#
#= none:111 =# @inline κhᶜᶠᶜ(i, j, k, grid, closure::ASD, K, id, args...) = begin
            #= none:111 =#
            κᶜᶠᶜ(i, j, k, grid, closure, K, id, args...)
        end
#= none:112 =#
#= none:112 =# @inline κhᶜᶜᶠ(i, j, k, grid, closure::ASD, K, id, args...) = begin
            #= none:112 =#
            κᶜᶜᶠ(i, j, k, grid, closure, K, id, args...)
        end
#= none:114 =#
for (dir, Clo) = zip((:h, :z), (:AVD, :AHD))
    #= none:115 =#
    for code = (:ᶜᶜᶜ, :ᶠᶠᶜ, :ᶠᶜᶠ, :ᶜᶠᶠ)
        #= none:116 =#
        ν = Symbol(:ν, dir, code)
        #= none:117 =#
        #= none:117 =# @eval begin
                #= none:118 =#
                #= none:118 =# @inline $ν(i, j, k, grid, closure::$Clo, K, clock, args...) = begin
                            #= none:118 =#
                            zero(grid)
                        end
            end
        #= none:120 =#
    end
    #= none:122 =#
    for code = (:ᶠᶜᶜ, :ᶜᶠᶜ, :ᶜᶜᶠ)
        #= none:123 =#
        κ = Symbol(:κ, dir, code)
        #= none:124 =#
        #= none:124 =# @eval begin
                #= none:125 =#
                #= none:125 =# @inline $κ(i, j, k, grid, closure::$Clo, K, id, clock, args...) = begin
                            #= none:125 =#
                            zero(grid)
                        end
            end
        #= none:127 =#
    end
    #= none:128 =#
end
#= none:130 =#
const F = Face
#= none:131 =#
const C = Center
#= none:133 =#
#= none:133 =# @inline z_diffusivity(i, j, k, grid, ::F, ::C, ::C, closure::ASD, K, id, args...) = begin
            #= none:133 =#
            κzᶠᶜᶜ(i, j, k, grid, closure, K, id, args...)
        end
#= none:134 =#
#= none:134 =# @inline z_diffusivity(i, j, k, grid, ::C, ::F, ::C, closure::ASD, K, id, args...) = begin
            #= none:134 =#
            κzᶜᶠᶜ(i, j, k, grid, closure, K, id, args...)
        end
#= none:135 =#
#= none:135 =# @inline z_diffusivity(i, j, k, grid, ::C, ::C, ::F, closure::ASD, K, id, args...) = begin
            #= none:135 =#
            κzᶜᶜᶠ(i, j, k, grid, closure, K, id, args...)
        end
#= none:137 =#
#= none:137 =# @inline h_diffusivity(i, j, k, grid, ::F, ::C, ::C, closure::ASD, K, id, args...) = begin
            #= none:137 =#
            κhᶠᶜᶜ(i, j, k, grid, closure, K, id, args...)
        end
#= none:138 =#
#= none:138 =# @inline h_diffusivity(i, j, k, grid, ::C, ::F, ::C, closure::ASD, K, id, args...) = begin
            #= none:138 =#
            κhᶜᶠᶜ(i, j, k, grid, closure, K, id, args...)
        end
#= none:139 =#
#= none:139 =# @inline h_diffusivity(i, j, k, grid, ::C, ::C, ::F, closure::ASD, K, id, args...) = begin
            #= none:139 =#
            κhᶜᶜᶠ(i, j, k, grid, closure, K, id, args...)
        end
#= none:142 =#
#= none:142 =# @inline z_diffusivity(i, j, k, grid, ::C, ::C, ::C, closure::ASD, K, ::Nothing, args...) = begin
            #= none:142 =#
            νzᶜᶜᶜ(i, j, k, grid, closure, K, args...)
        end
#= none:143 =#
#= none:143 =# @inline z_diffusivity(i, j, k, grid, ::F, ::F, ::C, closure::ASD, K, ::Nothing, args...) = begin
            #= none:143 =#
            νzᶠᶠᶜ(i, j, k, grid, closure, K, args...)
        end
#= none:144 =#
#= none:144 =# @inline z_diffusivity(i, j, k, grid, ::F, ::C, ::F, closure::ASD, K, ::Nothing, args...) = begin
            #= none:144 =#
            νzᶠᶜᶠ(i, j, k, grid, closure, K, args...)
        end
#= none:145 =#
#= none:145 =# @inline z_diffusivity(i, j, k, grid, ::C, ::F, ::F, closure::ASD, K, ::Nothing, args...) = begin
            #= none:145 =#
            νzᶜᶠᶠ(i, j, k, grid, closure, K, args...)
        end
#= none:147 =#
#= none:147 =# @inline h_diffusivity(i, j, k, grid, ::C, ::C, ::C, closure::ASD, K, ::Nothing, args...) = begin
            #= none:147 =#
            νhᶜᶜᶜ(i, j, k, grid, closure, K, args...)
        end
#= none:148 =#
#= none:148 =# @inline h_diffusivity(i, j, k, grid, ::F, ::F, ::C, closure::ASD, K, ::Nothing, args...) = begin
            #= none:148 =#
            νhᶠᶠᶜ(i, j, k, grid, closure, K, args...)
        end
#= none:149 =#
#= none:149 =# @inline h_diffusivity(i, j, k, grid, ::F, ::C, ::F, closure::ASD, K, ::Nothing, args...) = begin
            #= none:149 =#
            νhᶠᶜᶠ(i, j, k, grid, closure, K, args...)
        end
#= none:150 =#
#= none:150 =# @inline h_diffusivity(i, j, k, grid, ::C, ::F, ::F, closure::ASD, K, ::Nothing, args...) = begin
            #= none:150 =#
            νhᶜᶠᶠ(i, j, k, grid, closure, K, args...)
        end
#= none:154 =#
#= none:154 =# @inline ν_σᶜᶜᶜ(i, j, k, grid, closure, K, clock, fields, σᶜᶜᶜ, args...) = begin
            #= none:154 =#
            νᶜᶜᶜ(i, j, k, grid, closure, K, clock, fields) * σᶜᶜᶜ(i, j, k, grid, args...)
        end
#= none:155 =#
#= none:155 =# @inline ν_σᶠᶠᶜ(i, j, k, grid, closure, K, clock, fields, σᶠᶠᶜ, args...) = begin
            #= none:155 =#
            νᶠᶠᶜ(i, j, k, grid, closure, K, clock, fields) * σᶠᶠᶜ(i, j, k, grid, args...)
        end
#= none:156 =#
#= none:156 =# @inline ν_σᶠᶜᶠ(i, j, k, grid, closure, K, clock, fields, σᶠᶜᶠ, args...) = begin
            #= none:156 =#
            νᶠᶜᶠ(i, j, k, grid, closure, K, clock, fields) * σᶠᶜᶠ(i, j, k, grid, args...)
        end
#= none:157 =#
#= none:157 =# @inline ν_σᶜᶠᶠ(i, j, k, grid, closure, K, clock, fields, σᶜᶠᶠ, args...) = begin
            #= none:157 =#
            νᶜᶠᶠ(i, j, k, grid, closure, K, clock, fields) * σᶜᶠᶠ(i, j, k, grid, args...)
        end
#= none:159 =#
#= none:159 =# @inline viscous_flux_ux(i, j, k, grid, clo::AID, K, clk, fields, b) = begin
            #= none:159 =#
            -2 * ν_σᶜᶜᶜ(i, j, k, grid, clo, K, clk, fields, Σ₁₁, fields.u, fields.v, fields.w)
        end
#= none:160 =#
#= none:160 =# @inline viscous_flux_vx(i, j, k, grid, clo::AID, K, clk, fields, b) = begin
            #= none:160 =#
            -2 * ν_σᶠᶠᶜ(i, j, k, grid, clo, K, clk, fields, Σ₂₁, fields.u, fields.v, fields.w)
        end
#= none:161 =#
#= none:161 =# @inline viscous_flux_wx(i, j, k, grid, clo::AID, K, clk, fields, b) = begin
            #= none:161 =#
            -2 * ν_σᶠᶜᶠ(i, j, k, grid, clo, K, clk, fields, Σ₃₁, fields.u, fields.v, fields.w)
        end
#= none:162 =#
#= none:162 =# @inline viscous_flux_uy(i, j, k, grid, clo::AID, K, clk, fields, b) = begin
            #= none:162 =#
            -2 * ν_σᶠᶠᶜ(i, j, k, grid, clo, K, clk, fields, Σ₁₂, fields.u, fields.v, fields.w)
        end
#= none:163 =#
#= none:163 =# @inline viscous_flux_vy(i, j, k, grid, clo::AID, K, clk, fields, b) = begin
            #= none:163 =#
            -2 * ν_σᶜᶜᶜ(i, j, k, grid, clo, K, clk, fields, Σ₂₂, fields.u, fields.v, fields.w)
        end
#= none:164 =#
#= none:164 =# @inline viscous_flux_wy(i, j, k, grid, clo::AID, K, clk, fields, b) = begin
            #= none:164 =#
            -2 * ν_σᶜᶠᶠ(i, j, k, grid, clo, K, clk, fields, Σ₃₂, fields.u, fields.v, fields.w)
        end
#= none:167 =#
#= none:167 =# @inline viscous_flux_uz(i, j, k, grid, clo::AID, K, clk, fields, b) = begin
            #= none:167 =#
            -2 * ν_σᶠᶜᶠ(i, j, k, grid, clo, K, clk, fields, Σ₁₃, fields.u, fields.v, fields.w)
        end
#= none:168 =#
#= none:168 =# @inline viscous_flux_vz(i, j, k, grid, clo::AID, K, clk, fields, b) = begin
            #= none:168 =#
            -2 * ν_σᶜᶠᶠ(i, j, k, grid, clo, K, clk, fields, Σ₂₃, fields.u, fields.v, fields.w)
        end
#= none:169 =#
#= none:169 =# @inline viscous_flux_wz(i, j, k, grid, clo::AID, K, clk, fields, b) = begin
            #= none:169 =#
            -2 * ν_σᶜᶜᶜ(i, j, k, grid, clo, K, clk, fields, Σ₃₃, fields.u, fields.v, fields.w)
        end
#= none:172 =#
#= none:172 =# @inline νh_δᶜᶜᶜ(i, j, k, grid, closure, K, clock, fields, u, v) = begin
            #= none:172 =#
            νhᶜᶜᶜ(i, j, k, grid, closure, K, clock, fields) * div_xyᶜᶜᶜ(i, j, k, grid, u, v)
        end
#= none:173 =#
#= none:173 =# @inline νh_ζᶠᶠᶜ(i, j, k, grid, closure, K, clock, fields, u, v) = begin
            #= none:173 =#
            νhᶠᶠᶜ(i, j, k, grid, closure, K, clock, fields) * ζ₃ᶠᶠᶜ(i, j, k, grid, u, v)
        end
#= none:174 =#
#= none:174 =# @inline νh_σᶠᶜᶠ(i, j, k, grid, closure, K, clock, fields, σᶠᶜᶠ, args...) = begin
            #= none:174 =#
            νhᶠᶜᶠ(i, j, k, grid, closure, K, clock, fields) * σᶠᶜᶠ(i, j, k, grid, args...)
        end
#= none:175 =#
#= none:175 =# @inline νh_σᶜᶠᶠ(i, j, k, grid, closure, K, clock, fields, σᶜᶠᶠ, args...) = begin
            #= none:175 =#
            νhᶜᶠᶠ(i, j, k, grid, closure, K, clock, fields) * σᶜᶠᶠ(i, j, k, grid, args...)
        end
#= none:177 =#
#= none:177 =# @inline viscous_flux_ux(i, j, k, grid, clo::AHD, K, clk, fields, b) = begin
            #= none:177 =#
            -(νh_δᶜᶜᶜ(i, j, k, grid, clo, K, clk, fields, fields.u, fields.v))
        end
#= none:178 =#
#= none:178 =# @inline viscous_flux_vx(i, j, k, grid, clo::AHD, K, clk, fields, b) = begin
            #= none:178 =#
            -(νh_ζᶠᶠᶜ(i, j, k, grid, clo, K, clk, fields, fields.u, fields.v))
        end
#= none:179 =#
#= none:179 =# @inline viscous_flux_uy(i, j, k, grid, clo::AHD, K, clk, fields, b) = begin
            #= none:179 =#
            +(νh_ζᶠᶠᶜ(i, j, k, grid, clo, K, clk, fields, fields.u, fields.v))
        end
#= none:180 =#
#= none:180 =# @inline viscous_flux_vy(i, j, k, grid, clo::AHD, K, clk, fields, b) = begin
            #= none:180 =#
            -(νh_δᶜᶜᶜ(i, j, k, grid, clo, K, clk, fields, fields.u, fields.v))
        end
#= none:181 =#
#= none:181 =# @inline viscous_flux_wx(i, j, k, grid, clo::AHD, K, clk, fields, b) = begin
            #= none:181 =#
            -(νh_σᶠᶜᶠ(i, j, k, grid, clo, K, clk, fields, ∂xᶠᶜᶠ, fields.w))
        end
#= none:182 =#
#= none:182 =# @inline viscous_flux_wy(i, j, k, grid, clo::AHD, K, clk, fields, b) = begin
            #= none:182 =#
            -(νh_σᶜᶠᶠ(i, j, k, grid, clo, K, clk, fields, ∂yᶜᶠᶠ, fields.w))
        end
#= none:185 =#
#= none:185 =# @inline viscous_flux_ux(i, j, k, grid, clo::ADD, K, clk, fields, b) = begin
            #= none:185 =#
            -(νh_δᶜᶜᶜ(i, j, k, grid, clo, K, clk, fields, fields.u, fields.v))
        end
#= none:186 =#
#= none:186 =# @inline viscous_flux_vy(i, j, k, grid, clo::ADD, K, clk, fields, b) = begin
            #= none:186 =#
            -(νh_δᶜᶜᶜ(i, j, k, grid, clo, K, clk, fields, fields.u, fields.v))
        end
#= none:189 =#
#= none:189 =# @inline νz_σᶜᶜᶜ(i, j, k, grid, closure, K, clock, fields, σᶜᶜᶜ, args...) = begin
            #= none:189 =#
            νzᶜᶜᶜ(i, j, k, grid, closure, K, clock, fields) * σᶜᶜᶜ(i, j, k, grid, args...)
        end
#= none:190 =#
#= none:190 =# @inline νz_σᶠᶠᶜ(i, j, k, grid, closure, K, clock, fields, σᶠᶠᶜ, args...) = begin
            #= none:190 =#
            νzᶠᶠᶜ(i, j, k, grid, closure, K, clock, fields) * σᶠᶠᶜ(i, j, k, grid, args...)
        end
#= none:191 =#
#= none:191 =# @inline νz_σᶠᶜᶠ(i, j, k, grid, closure, K, clock, fields, σᶠᶜᶠ, args...) = begin
            #= none:191 =#
            νzᶠᶜᶠ(i, j, k, grid, closure, K, clock, fields) * σᶠᶜᶠ(i, j, k, grid, args...)
        end
#= none:192 =#
#= none:192 =# @inline νz_σᶜᶠᶠ(i, j, k, grid, closure, K, clock, fields, σᶜᶠᶠ, args...) = begin
            #= none:192 =#
            νzᶜᶠᶠ(i, j, k, grid, closure, K, clock, fields) * σᶜᶠᶠ(i, j, k, grid, args...)
        end
#= none:194 =#
#= none:194 =# @inline viscous_flux_uz(i, j, k, grid, clo::AVD, K, clk, fields, b) = begin
            #= none:194 =#
            -(νz_σᶠᶜᶠ(i, j, k, grid, clo, K, clk, fields, ∂zᶠᶜᶠ, fields.u))
        end
#= none:195 =#
#= none:195 =# @inline viscous_flux_vz(i, j, k, grid, clo::AVD, K, clk, fields, b) = begin
            #= none:195 =#
            -(νz_σᶜᶠᶠ(i, j, k, grid, clo, K, clk, fields, ∂zᶜᶠᶠ, fields.v))
        end
#= none:196 =#
#= none:196 =# @inline viscous_flux_wz(i, j, k, grid, clo::AVD, K, clk, fields, b) = begin
            #= none:196 =#
            -(νz_σᶜᶜᶜ(i, j, k, grid, clo, K, clk, fields, ∂zᶜᶜᶜ, fields.w))
        end
#= none:202 =#
const AIDorAHD = Union{AID, AHD}
#= none:203 =#
const AIDorAVD = Union{AID, AVD}
#= none:205 =#
#= none:205 =# @inline (diffusive_flux_x(i, j, k, grid, cl::AIDorAHD, K, ::Val{id}, c, clk, fields, b) where id) = begin
            #= none:205 =#
            -(κhᶠᶜᶜ(i, j, k, grid, cl, K, Val(id), clk, fields)) * ∂xᶠᶜᶜ(i, j, k, grid, c)
        end
#= none:206 =#
#= none:206 =# @inline (diffusive_flux_y(i, j, k, grid, cl::AIDorAHD, K, ::Val{id}, c, clk, fields, b) where id) = begin
            #= none:206 =#
            -(κhᶜᶠᶜ(i, j, k, grid, cl, K, Val(id), clk, fields)) * ∂yᶜᶠᶜ(i, j, k, grid, c)
        end
#= none:207 =#
#= none:207 =# @inline (diffusive_flux_z(i, j, k, grid, cl::AIDorAVD, K, ::Val{id}, c, clk, fields, b) where id) = begin
            #= none:207 =#
            -(κzᶜᶜᶠ(i, j, k, grid, cl, K, Val(id), clk, fields)) * ∂zᶜᶜᶠ(i, j, k, grid, c)
        end
#= none:213 =#
const VITD = VerticallyImplicitTimeDiscretization
#= none:215 =#
#= none:215 =# @inline ivd_viscous_flux_uz(i, j, k, grid, closure::AID, K, clock, fields, b) = begin
            #= none:215 =#
            -(ν_σᶠᶜᶠ(i, j, k, grid, closure, K, clock, fields, ∂xᶠᶜᶠ, fields.w))
        end
#= none:216 =#
#= none:216 =# @inline ivd_viscous_flux_vz(i, j, k, grid, closure::AID, K, clock, fields, b) = begin
            #= none:216 =#
            -(ν_σᶜᶠᶠ(i, j, k, grid, closure, K, clock, fields, ∂yᶜᶠᶠ, fields.w))
        end
#= none:217 =#
#= none:217 =# @inline ivd_viscous_flux_uz(i, j, k, grid, closure::AVD, K, clock, fields, b) = begin
            #= none:217 =#
            zero(grid)
        end
#= none:218 =#
#= none:218 =# @inline ivd_viscous_flux_vz(i, j, k, grid, closure::AVD, K, clock, fields, b) = begin
            #= none:218 =#
            zero(grid)
        end
#= none:221 =#
#= none:221 =# @inline viscous_flux_uz(i, j, k, grid, ::VITD, closure::AIDorAVD, args...) = begin
            #= none:221 =#
            ivd_viscous_flux_uz(i, j, k, grid, closure, args...)
        end
#= none:222 =#
#= none:222 =# @inline viscous_flux_vz(i, j, k, grid, ::VITD, closure::AIDorAVD, args...) = begin
            #= none:222 =#
            ivd_viscous_flux_vz(i, j, k, grid, closure, args...)
        end
#= none:223 =#
#= none:223 =# @inline viscous_flux_wz(i, j, k, grid, ::VITD, closure::AIDorAVD, args...) = begin
            #= none:223 =#
            zero(grid)
        end
#= none:224 =#
#= none:224 =# @inline diffusive_flux_z(i, j, k, grid, ::VITD, closure::AIDorAVD, args...) = begin
            #= none:224 =#
            zero(grid)
        end
#= none:234 =#
#= none:234 =# @inline function viscous_flux_uz(i, j, k, grid::VerticallyBoundedGrid, ::VITD, closure::AIDorAVD, args...)
        #= none:234 =#
        #= none:235 =#
        return ifelse((k == 1) | (k == grid.Nz + 1), viscous_flux_uz(i, j, k, grid, ExplicitTimeDiscretization(), closure, args...), ivd_viscous_flux_uz(i, j, k, grid, closure, args...))
    end
#= none:240 =#
#= none:240 =# @inline function viscous_flux_vz(i, j, k, grid::VerticallyBoundedGrid, ::VITD, closure::AIDorAVD, args...)
        #= none:240 =#
        #= none:241 =#
        return ifelse((k == 1) | (k == grid.Nz + 1), viscous_flux_vz(i, j, k, grid, ExplicitTimeDiscretization(), closure, args...), ivd_viscous_flux_vz(i, j, k, grid, closure, args...))
    end
#= none:246 =#
#= none:246 =# @inline function viscous_flux_wz(i, j, k, grid::VerticallyBoundedGrid, ::VITD, closure::AIDorAVD, args...)
        #= none:246 =#
        #= none:247 =#
        return ifelse((k == 1) | (k == grid.Nz + 1), viscous_flux_wz(i, j, k, grid, ExplicitTimeDiscretization(), closure, args...), zero(grid))
    end
#= none:252 =#
#= none:252 =# @inline function diffusive_flux_z(i, j, k, grid::VerticallyBoundedGrid, ::VITD, closure::AIDorAVD, args...)
        #= none:252 =#
        #= none:253 =#
        return ifelse((k == 1) | (k == grid.Nz + 1), diffusive_flux_z(i, j, k, grid, ExplicitTimeDiscretization(), closure, args...), zero(grid))
    end
#= none:263 =#
#= none:263 =# @inline κ_σᶠᶜᶜ(i, j, k, grid, closure, K, id, clock, fields, σᶠᶜᶜ, args...) = begin
            #= none:263 =#
            κᶠᶜᶜ(i, j, k, grid, closure, K, id, clock, fields) * σᶠᶜᶜ(i, j, k, grid, args...)
        end
#= none:264 =#
#= none:264 =# @inline κ_σᶜᶠᶜ(i, j, k, grid, closure, K, id, clock, fields, σᶜᶠᶜ, args...) = begin
            #= none:264 =#
            κᶜᶠᶜ(i, j, k, grid, closure, K, id, clock, fields) * σᶜᶠᶜ(i, j, k, grid, args...)
        end
#= none:265 =#
#= none:265 =# @inline κ_σᶜᶜᶠ(i, j, k, grid, closure, K, id, clock, fields, σᶜᶜᶠ, args...) = begin
            #= none:265 =#
            κᶜᶜᶠ(i, j, k, grid, closure, K, id, clock, fields) * σᶜᶜᶠ(i, j, k, grid, args...)
        end
#= none:273 =#
#= none:273 =# @inline νᶜᶜᶜ(i, j, k, grid, loc, ν::Number, args...) = begin
            #= none:273 =#
            ν
        end
#= none:274 =#
#= none:274 =# @inline νᶠᶜᶠ(i, j, k, grid, loc, ν::Number, args...) = begin
            #= none:274 =#
            ν
        end
#= none:275 =#
#= none:275 =# @inline νᶜᶠᶠ(i, j, k, grid, loc, ν::Number, args...) = begin
            #= none:275 =#
            ν
        end
#= none:276 =#
#= none:276 =# @inline νᶠᶠᶜ(i, j, k, grid, loc, ν::Number, args...) = begin
            #= none:276 =#
            ν
        end
#= none:278 =#
#= none:278 =# @inline κᶠᶜᶜ(i, j, k, grid, loc, κ::Number, args...) = begin
            #= none:278 =#
            κ
        end
#= none:279 =#
#= none:279 =# @inline κᶜᶠᶜ(i, j, k, grid, loc, κ::Number, args...) = begin
            #= none:279 =#
            κ
        end
#= none:280 =#
#= none:280 =# @inline κᶜᶜᶠ(i, j, k, grid, loc, κ::Number, args...) = begin
            #= none:280 =#
            κ
        end
#= none:283 =#
const Lᶜᶜᶜ = Tuple{Center, Center, Center}
#= none:284 =#
#= none:284 =# @inline νᶜᶜᶜ(i, j, k, grid, ::Lᶜᶜᶜ, ν::AbstractArray, args...) = begin
            #= none:284 =#
            #= none:284 =# @inbounds ν[i, j, k]
        end
#= none:285 =#
#= none:285 =# @inline νᶠᶜᶠ(i, j, k, grid, ::Lᶜᶜᶜ, ν::AbstractArray, args...) = begin
            #= none:285 =#
            ℑxzᶠᵃᶠ(i, j, k, grid, ν)
        end
#= none:286 =#
#= none:286 =# @inline νᶜᶠᶠ(i, j, k, grid, ::Lᶜᶜᶜ, ν::AbstractArray, args...) = begin
            #= none:286 =#
            ℑyzᵃᶠᶠ(i, j, k, grid, ν)
        end
#= none:287 =#
#= none:287 =# @inline νᶠᶠᶜ(i, j, k, grid, ::Lᶜᶜᶜ, ν::AbstractArray, args...) = begin
            #= none:287 =#
            ℑxyᶠᶠᵃ(i, j, k, grid, ν)
        end
#= none:289 =#
#= none:289 =# @inline κᶠᶜᶜ(i, j, k, grid, ::Lᶜᶜᶜ, κ::AbstractArray, args...) = begin
            #= none:289 =#
            ℑxᶠᵃᵃ(i, j, k, grid, κ)
        end
#= none:290 =#
#= none:290 =# @inline κᶜᶠᶜ(i, j, k, grid, ::Lᶜᶜᶜ, κ::AbstractArray, args...) = begin
            #= none:290 =#
            ℑyᵃᶠᵃ(i, j, k, grid, κ)
        end
#= none:291 =#
#= none:291 =# @inline κᶜᶜᶠ(i, j, k, grid, ::Lᶜᶜᶜ, κ::AbstractArray, args...) = begin
            #= none:291 =#
            ℑzᵃᵃᶠ(i, j, k, grid, κ)
        end
#= none:294 =#
const Lᶜᶜᶠ = Tuple{Center, Center, Face}
#= none:295 =#
#= none:295 =# @inline νᶜᶜᶜ(i, j, k, grid, ::Lᶜᶜᶠ, ν::AbstractArray, args...) = begin
            #= none:295 =#
            ℑzᵃᵃᶜ(i, j, k, grid, ν)
        end
#= none:296 =#
#= none:296 =# @inline νᶠᶜᶠ(i, j, k, grid, ::Lᶜᶜᶠ, ν::AbstractArray, args...) = begin
            #= none:296 =#
            ℑxᶠᵃᵃ(i, j, k, grid, ν)
        end
#= none:297 =#
#= none:297 =# @inline νᶜᶠᶠ(i, j, k, grid, ::Lᶜᶜᶠ, ν::AbstractArray, args...) = begin
            #= none:297 =#
            ℑyᵃᶠᵃ(i, j, k, grid, ν)
        end
#= none:298 =#
#= none:298 =# @inline νᶠᶠᶜ(i, j, k, grid, ::Lᶜᶜᶠ, ν::AbstractArray, args...) = begin
            #= none:298 =#
            ℑxyzᶠᶠᶜ(i, j, k, grid, ν)
        end
#= none:300 =#
#= none:300 =# @inline κᶠᶜᶜ(i, j, k, grid, ::Lᶜᶜᶠ, κ::AbstractArray, args...) = begin
            #= none:300 =#
            ℑxzᶠᵃᶠ(i, j, k, grid, κ)
        end
#= none:301 =#
#= none:301 =# @inline κᶜᶠᶜ(i, j, k, grid, ::Lᶜᶜᶠ, κ::AbstractArray, args...) = begin
            #= none:301 =#
            ℑyzᵃᶠᶠ(i, j, k, grid, κ)
        end
#= none:302 =#
#= none:302 =# @inline κᶜᶜᶠ(i, j, k, grid, ::Lᶜᶜᶠ, κ::AbstractArray, args...) = begin
            #= none:302 =#
            #= none:302 =# @inbounds κ[i, j, k]
        end
#= none:306 =#
const c = Center()
#= none:307 =#
const f = Face()
#= none:309 =#
#= none:309 =# @inline (νᶜᶜᶜ(i, j, k, grid, loc, ν::F, clock, args...) where F <: Function) = begin
            #= none:309 =#
            ν(node(i, j, k, grid, c, c, c)..., clock.time)
        end
#= none:310 =#
#= none:310 =# @inline (νᶠᶜᶠ(i, j, k, grid, loc, ν::F, clock, args...) where F <: Function) = begin
            #= none:310 =#
            ν(node(i, j, k, grid, f, c, f)..., clock.time)
        end
#= none:311 =#
#= none:311 =# @inline (νᶜᶠᶠ(i, j, k, grid, loc, ν::F, clock, args...) where F <: Function) = begin
            #= none:311 =#
            ν(node(i, j, k, grid, c, f, f)..., clock.time)
        end
#= none:312 =#
#= none:312 =# @inline (νᶠᶠᶜ(i, j, k, grid, loc, ν::F, clock, args...) where F <: Function) = begin
            #= none:312 =#
            ν(node(i, j, k, grid, f, f, c)..., clock.time)
        end
#= none:314 =#
#= none:314 =# @inline (κᶠᶜᶜ(i, j, k, grid, loc, κ::F, clock, args...) where F <: Function) = begin
            #= none:314 =#
            κ(node(i, j, k, grid, f, c, c)..., clock.time)
        end
#= none:315 =#
#= none:315 =# @inline (κᶜᶠᶜ(i, j, k, grid, loc, κ::F, clock, args...) where F <: Function) = begin
            #= none:315 =#
            κ(node(i, j, k, grid, c, f, c)..., clock.time)
        end
#= none:316 =#
#= none:316 =# @inline (κᶜᶜᶠ(i, j, k, grid, loc, κ::F, clock, args...) where F <: Function) = begin
            #= none:316 =#
            κ(node(i, j, k, grid, c, c, f)..., clock.time)
        end
#= none:319 =#
#= none:319 =# @inline νᶜᶜᶜ(i, j, k, grid, loc, ν::DiscreteDiffusionFunction, clock, fields) = begin
            #= none:319 =#
            getdiffusivity(ν, i, j, k, grid, (c, c, c), clock, fields)
        end
#= none:320 =#
#= none:320 =# @inline νᶠᶜᶠ(i, j, k, grid, loc, ν::DiscreteDiffusionFunction, clock, fields) = begin
            #= none:320 =#
            getdiffusivity(ν, i, j, k, grid, (f, c, f), clock, fields)
        end
#= none:321 =#
#= none:321 =# @inline νᶜᶠᶠ(i, j, k, grid, loc, ν::DiscreteDiffusionFunction, clock, fields) = begin
            #= none:321 =#
            getdiffusivity(ν, i, j, k, grid, (c, f, f), clock, fields)
        end
#= none:322 =#
#= none:322 =# @inline νᶠᶠᶜ(i, j, k, grid, loc, ν::DiscreteDiffusionFunction, clock, fields) = begin
            #= none:322 =#
            getdiffusivity(ν, i, j, k, grid, (f, f, c), clock, fields)
        end
#= none:324 =#
#= none:324 =# @inline κᶠᶜᶜ(i, j, k, grid, loc, κ::DiscreteDiffusionFunction, clock, fields) = begin
            #= none:324 =#
            getdiffusivity(κ, i, j, k, grid, (f, c, c), clock, fields)
        end
#= none:325 =#
#= none:325 =# @inline κᶜᶠᶜ(i, j, k, grid, loc, κ::DiscreteDiffusionFunction, clock, fields) = begin
            #= none:325 =#
            getdiffusivity(κ, i, j, k, grid, (c, f, c), clock, fields)
        end
#= none:326 =#
#= none:326 =# @inline κᶜᶜᶠ(i, j, k, grid, loc, κ::DiscreteDiffusionFunction, clock, fields) = begin
            #= none:326 =#
            getdiffusivity(κ, i, j, k, grid, (c, c, f), clock, fields)
        end