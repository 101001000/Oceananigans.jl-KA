
#= none:1 =#
using Oceananigans.Fields: AbstractField
#= none:7 =#
struct TwoDimensionalLeith{FT, CR, GM, M} <: AbstractScalarDiffusivity{ExplicitTimeDiscretization, ThreeDimensionalFormulation, 2}
    #= none:8 =#
    C::FT
    #= none:9 =#
    C_Redi::CR
    #= none:10 =#
    C_GM::GM
    #= none:11 =#
    isopycnal_model::M
    #= none:13 =#
    function TwoDimensionalLeith{FT}(C, C_Redi, C_GM, isopycnal_model) where FT
        #= none:13 =#
        #= none:14 =#
        C_Redi = convert_diffusivity(FT, C_Redi)
        #= none:15 =#
        C_GM = convert_diffusivity(FT, C_GM)
        #= none:16 =#
        return new{FT, typeof(C_Redi), typeof(C_GM), typeof(isopycnal_model)}(C, C_Redi, C_GM)
    end
end
#= none:20 =#
#= none:20 =# Core.@doc "    TwoDimensionalLeith(FT=Float64;\n                        C=0.3, C_Redi=1, C_GM=1,\n                        isopycnal_model=SmallSlopeIsopycnalTensor())\n\nReturn a `TwoDimensionalLeith` type associated with the turbulence closure proposed by\n[leith1968diffusion](@citet) and [Fox-Kemper2008](@citet) which has an eddy viscosity of the form\n\n```julia\nνₑ = (C * Δᶠ)³ * √(|∇ₕ ζ|² + |∇ₕ ∂w/∂z|²)\n```\n\nand an eddy diffusivity of the form...\n\nwhere `Δᶠ` is the filter width, `ζ = ∂v/∂x - ∂u/∂y` is the vertical vorticity,\nand `C` is a model constant.\n\nKeyword arguments\n=================\n\n  - `C`: Model constant\n  - `C_Redi`: Coefficient for down-gradient tracer diffusivity for each tracer.\n              Either a constant applied to every tracer, or a `NamedTuple` with fields\n              for each tracer individually.\n  - `C_GM`: Coefficient for down-gradient tracer diffusivity for each tracer.\n            Either a constant applied to every tracer, or a `NamedTuple` with fields\n            for each tracer individually.\n\nReferences\n==========\n\nLeith, C. E. (1968). \"Diffusion Approximation for Two‐Dimensional Turbulence\", The Physics of\n    Fluids 11, 671. doi: 10.1063/1.1691968\n\nFox‐Kemper, B., & D. Menemenlis (2008), \"Can large eddy simulation techniques improve mesoscale rich\n    ocean models?\", in Ocean Modeling in an Eddying Regime, Geophys. Monogr. Ser., 177, pp. 319–337.\n    doi: 10.1029/177GM19\n" TwoDimensionalLeith(FT = Float64; C = 0.3, C_Redi = 1, C_GM = 1, isopycnal_model = SmallSlopeIsopycnalTensor()) = begin
            #= none:58 =#
            TwoDimensionalLeith{FT}(C, C_Redi, C_GM, isopycnal_model)
        end
#= none:61 =#
function with_tracers(tracers, closure::TwoDimensionalLeith{FT}) where FT
    #= none:61 =#
    #= none:62 =#
    C_Redi = tracer_diffusivities(tracers, closure.C_Redi)
    #= none:63 =#
    C_GM = tracer_diffusivities(tracers, closure.C_GM)
    #= none:65 =#
    return TwoDimensionalLeith{FT}(closure.C, C_Redi, C_GM, closure.isopycnal_model)
end
#= none:68 =#
#= none:68 =# @inline function abs²_∇h_ζ(i, j, k, grid, u, v)
        #= none:68 =#
        #= none:69 =#
        ζx = ℑyᵃᶜᵃ(i, j, k, grid, ∂xᶜᶠᶜ, ζ₃ᶠᶠᶜ, u, v)
        #= none:70 =#
        ζy = ℑxᶜᵃᵃ(i, j, k, grid, ∂yᶠᶜᶜ, ζ₃ᶠᶠᶜ, u, v)
        #= none:71 =#
        return ζx ^ 2 + ζy ^ 2
    end
#= none:74 =#
const ArrayOrField = Union{AbstractArray, AbstractField}
#= none:76 =#
#= none:76 =# @inline ψ²(i, j, k, grid, ψ::Function, args...) = begin
            #= none:76 =#
            ψ(i, j, k, grid, args...) ^ 2
        end
#= none:77 =#
#= none:77 =# @inline ψ²(i, j, k, grid, ψ::ArrayOrField, args...) = begin
            #= none:77 =#
            #= none:77 =# @inbounds ψ[i, j, k] ^ 2
        end
#= none:79 =#
#= none:79 =# @inline function abs²_∇h_wz(i, j, k, grid, w)
        #= none:79 =#
        #= none:80 =#
        wxz = ℑxᶜᵃᵃ(i, j, k, grid, ∂xᶠᶜᶜ, ∂zᶜᶜᶜ, w)
        #= none:81 =#
        wyz = ℑyᵃᶜᵃ(i, j, k, grid, ∂yᶜᶠᶜ, ∂zᶜᶜᶜ, w)
        #= none:82 =#
        return wxz ^ 2 + wyz ^ 2
    end
#= none:85 =#
#= none:85 =# @kernel function _compute_leith_viscosity!(νₑ, grid, closure::TwoDimensionalLeith{FT}, buoyancy, velocities, tracers) where FT
        #= none:85 =#
        #= none:86 =#
        (i, j, k) = #= none:86 =# @index(Global, NTuple)
        #= none:87 =#
        (u, v, w) = velocities
        #= none:88 =#
        prefactor = (closure.C * Δᶠ(i, j, k, grid, closure)) ^ 3
        #= none:89 =#
        dynamic_ν = sqrt(abs²_∇h_ζ(i, j, k, grid, u, v) + abs²_∇h_wz(i, j, k, grid, w))
        #= none:91 =#
        #= none:91 =# @inbounds νₑ[i, j, k] = prefactor * dynamic_ν
    end
#= none:94 =#
function compute_diffusivities!(diffusivity_fields, closure::TwoDimensionalLeith, model; parameters = :xyz)
    #= none:94 =#
    #= none:95 =#
    arch = model.architecture
    #= none:96 =#
    grid = model.grid
    #= none:97 =#
    velocities = model.velocities
    #= none:98 =#
    tracers = model.tracers
    #= none:99 =#
    buoyancy = model.buoyancy
    #= none:101 =#
    launch!(arch, grid, parameters, _compute_leith_viscosity!, diffusivity_fields.νₑ, grid, closure, buoyancy, velocities, tracers)
    #= none:104 =#
    return nothing
end
#= none:107 =#
#= none:107 =# Core.@doc "Return the filter width for a Leith Diffusivity on a general grid." #= none:108 =# @inline(Δᶠ(i, j, k, grid, ::TwoDimensionalLeith) = begin
                #= none:108 =#
                sqrt(Δxᶜᶜᶜ(i, j, k, grid) * Δyᶜᶜᶜ(i, j, k, grid))
            end)
#= none:110 =#
function DiffusivityFields(grid, tracer_names, bcs, ::TwoDimensionalLeith)
    #= none:110 =#
    #= none:111 =#
    default_eddy_viscosity_bcs = (; νₑ = FieldBoundaryConditions(grid, (Center, Center, Center)))
    #= none:112 =#
    bcs = merge(default_eddy_viscosity_bcs, bcs)
    #= none:113 =#
    return (; νₑ = CenterField(grid, boundary_conditions = bcs.νₑ))
end
#= none:116 =#
#= none:116 =# @inline viscosity(::TwoDimensionalLeith, K) = begin
            #= none:116 =#
            K.νₑ
        end
#= none:117 =#
#= none:117 =# @inline (diffusivity(::TwoDimensionalLeith, K, ::Val{id}) where id) = begin
            #= none:117 =#
            K.νₑ
        end
#= none:125 =#
#= none:125 =# @inline function diffusive_flux_x(i, j, k, grid, closure::TwoDimensionalLeith, diffusivities, ::Val{tracer_index}, c, clock, fields, buoyancy) where tracer_index
        #= none:125 =#
        #= none:128 =#
        νₑ = diffusivities.νₑ
        #= none:130 =#
        C_Redi = closure.C_Redi[tracer_index]
        #= none:131 =#
        C_GM = closure.C_GM[tracer_index]
        #= none:133 =#
        νₑⁱʲᵏ = ℑxᶠᵃᵃ(i, j, k, grid, νₑ)
        #= none:135 =#
        ∂x_c = ∂xᶠᶜᶜ(i, j, k, grid, c)
        #= none:136 =#
        ∂z_c = ℑxzᶠᵃᶜ(i, j, k, grid, ∂zᶜᶜᶠ, c)
        #= none:138 =#
        R₁₃ = isopycnal_rotation_tensor_xz_fcc(i, j, k, grid, buoyancy, fields, closure.isopycnal_model)
        #= none:140 =#
        return -νₑⁱʲᵏ * (C_Redi * ∂x_c + (C_Redi - C_GM) * R₁₃ * ∂z_c)
    end
#= none:144 =#
#= none:144 =# @inline function diffusive_flux_y(i, j, k, grid, closure::TwoDimensionalLeith, diffusivities, ::Val{tracer_index}, c, clock, fields, buoyancy) where tracer_index
        #= none:144 =#
        #= none:147 =#
        νₑ = diffusivities.νₑ
        #= none:149 =#
        C_Redi = closure.C_Redi[tracer_index]
        #= none:150 =#
        C_GM = closure.C_GM[tracer_index]
        #= none:152 =#
        νₑⁱʲᵏ = ℑyᵃᶠᵃ(i, j, k, grid, νₑ)
        #= none:154 =#
        ∂y_c = ∂yᶜᶠᶜ(i, j, k, grid, c)
        #= none:155 =#
        ∂z_c = ℑyzᵃᶠᶜ(i, j, k, grid, ∂zᶜᶜᶠ, c)
        #= none:157 =#
        R₂₃ = isopycnal_rotation_tensor_yz_cfc(i, j, k, grid, buoyancy, fields, closure.isopycnal_model)
        #= none:158 =#
        return -νₑⁱʲᵏ * (C_Redi * ∂y_c + (C_Redi - C_GM) * R₂₃ * ∂z_c)
    end
#= none:162 =#
#= none:162 =# @inline function diffusive_flux_z(i, j, k, grid, closure::TwoDimensionalLeith, diffusivities, ::Val{tracer_index}, c, clock, fields, buoyancy) where tracer_index
        #= none:162 =#
        #= none:165 =#
        νₑ = diffusivities.νₑ
        #= none:167 =#
        C_Redi = closure.C_Redi[tracer_index]
        #= none:168 =#
        C_GM = closure.C_GM[tracer_index]
        #= none:170 =#
        νₑⁱʲᵏ = ℑzᵃᵃᶠ(i, j, k, grid, νₑ)
        #= none:172 =#
        ∂x_c = ℑxzᶜᵃᶠ(i, j, k, grid, ∂xᶠᶜᶜ, c)
        #= none:173 =#
        ∂y_c = ℑyzᵃᶜᶠ(i, j, k, grid, ∂yᶜᶠᶜ, c)
        #= none:174 =#
        ∂z_c = ∂zᶜᶜᶠ(i, j, k, grid, c)
        #= none:176 =#
        R₃₁ = isopycnal_rotation_tensor_xz_ccf(i, j, k, grid, buoyancy, fields, closure.isopycnal_model)
        #= none:177 =#
        R₃₂ = isopycnal_rotation_tensor_yz_ccf(i, j, k, grid, buoyancy, fields, closure.isopycnal_model)
        #= none:178 =#
        R₃₃ = isopycnal_rotation_tensor_zz_ccf(i, j, k, grid, buoyancy, fields, closure.isopycnal_model)
        #= none:180 =#
        return -νₑⁱʲᵏ * ((C_Redi + C_GM) * R₃₁ * ∂x_c + (C_Redi + C_GM) * R₃₂ * ∂y_c + C_Redi * R₃₃ * ∂z_c)
    end