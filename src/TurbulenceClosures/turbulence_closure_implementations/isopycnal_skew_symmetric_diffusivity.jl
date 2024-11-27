
#= none:1 =#
struct IsopycnalSkewSymmetricDiffusivity{TD, K, S, M, L, N} <: AbstractTurbulenceClosure{TD, N}
    #= none:2 =#
    κ_skew::K
    #= none:3 =#
    κ_symmetric::S
    #= none:4 =#
    isopycnal_tensor::M
    #= none:5 =#
    slope_limiter::L
    #= none:7 =#
    function IsopycnalSkewSymmetricDiffusivity{TD, N}(κ_skew::K, κ_symmetric::S, isopycnal_tensor::I, slope_limiter::L) where {TD, K, S, I, L, N}
        #= none:7 =#
        #= none:12 =#
        return new{TD, K, S, I, L, N}(κ_skew, κ_symmetric, isopycnal_tensor, slope_limiter)
    end
end
#= none:16 =#
const ISSD{TD} = (IsopycnalSkewSymmetricDiffusivity{TD} where TD)
#= none:17 =#
const ISSDVector{TD} = (AbstractVector{<:ISSD{TD}} where TD)
#= none:18 =#
const FlavorOfISSD{TD} = (Union{ISSD{TD}, ISSDVector{TD}} where TD)
#= none:19 =#
const issd_coefficient_loc = (Center(), Center(), Center())
#= none:21 =#
#= none:21 =# Core.@doc "    IsopycnalSkewSymmetricDiffusivity([time_disc=VerticallyImplicitTimeDiscretization(), FT=Float64;]\n                                      κ_skew = 0,\n                                      κ_symmetric = 0,\n                                      isopycnal_tensor = SmallSlopeIsopycnalTensor(),\n                                      slope_limiter = FluxTapering(1e-2))\n\nReturn parameters for an isopycnal skew-symmetric tracer diffusivity with skew diffusivity\n`κ_skew` and symmetric diffusivity `κ_symmetric` that uses an `isopycnal_tensor` model for\nfor calculating the isopycnal slopes, and (optionally) applying a `slope_limiter` to the\ncalculated isopycnal slope values.\n    \nBoth `κ_skew` and `κ_symmetric` may be constants, arrays, fields, or functions of `(x, y, z, t)`.\n" function IsopycnalSkewSymmetricDiffusivity(time_disc::TD = VerticallyImplicitTimeDiscretization(), FT = Float64; κ_skew = 0, κ_symmetric = 0, isopycnal_tensor = SmallSlopeIsopycnalTensor(), slope_limiter = FluxTapering(0.01), required_halo_size::Int = 1) where TD
        #= none:35 =#
        #= none:42 =#
        isopycnal_tensor isa SmallSlopeIsopycnalTensor || error("Only isopycnal_tensor=SmallSlopeIsopycnalTensor() is currently supported.")
        #= none:45 =#
        return IsopycnalSkewSymmetricDiffusivity{TD, required_halo_size}(convert_diffusivity(FT, κ_skew), convert_diffusivity(FT, κ_symmetric), isopycnal_tensor, slope_limiter)
    end
#= none:51 =#
IsopycnalSkewSymmetricDiffusivity(FT::DataType; kw...) = begin
        #= none:51 =#
        IsopycnalSkewSymmetricDiffusivity(VerticallyImplicitTimeDiscretization(), FT; kw...)
    end
#= none:54 =#
function with_tracers(tracers, closure::ISSD{TD, N}) where {TD, N}
    #= none:54 =#
    #= none:55 =#
    κ_skew = if !(closure.κ_skew isa NamedTuple)
            closure.κ_skew
        else
            tracer_diffusivities(tracers, closure.κ_skew)
        end
    #= none:56 =#
    κ_symmetric = if !(closure.κ_symmetric isa NamedTuple)
            closure.κ_symmetric
        else
            tracer_diffusivities(tracers, closure.κ_symmetric)
        end
    #= none:57 =#
    return IsopycnalSkewSymmetricDiffusivity{TD, N}(κ_skew, κ_symmetric, closure.isopycnal_tensor, closure.slope_limiter)
end
#= none:61 =#
function with_tracers(tracers, closure_vector::ISSDVector)
    #= none:61 =#
    #= none:62 =#
    arch = architecture(closure_vector)
    #= none:64 =#
    if arch isa Architectures.GPU
        #= none:65 =#
        closure_vector = Vector(closure_vector)
    end
    #= none:68 =#
    Ex = length(closure_vector)
    #= none:69 =#
    closure_vector = [with_tracers(tracers, closure_vector[i]) for i = 1:Ex]
    #= none:71 =#
    return on_architecture(arch, closure_vector)
end
#= none:75 =#
function DiffusivityFields(grid, tracer_names, bcs, closure::FlavorOfISSD{TD}) where TD
    #= none:75 =#
    #= none:76 =#
    if TD() isa VerticallyImplicitTimeDiscretization
        #= none:78 =#
        return (; ϵ_R₃₃ = Field((Center, Center, Face), grid))
    else
        #= none:80 =#
        return nothing
    end
end
#= none:84 =#
function compute_diffusivities!(diffusivities, closure::FlavorOfISSD, model; parameters = :xyz)
    #= none:84 =#
    #= none:86 =#
    arch = model.architecture
    #= none:87 =#
    grid = model.grid
    #= none:88 =#
    tracers = model.tracers
    #= none:89 =#
    buoyancy = model.buoyancy
    #= none:91 =#
    launch!(arch, grid, parameters, compute_tapered_R₃₃!, diffusivities.ϵ_R₃₃, grid, closure, tracers, buoyancy)
    #= none:94 =#
    return nothing
end
#= none:97 =#
#= none:97 =# @kernel function compute_tapered_R₃₃!(ϵ_R₃₃, grid, closure, tracers, buoyancy)
        #= none:97 =#
        #= none:98 =#
        (i, j, k) = #= none:98 =# @index(Global, NTuple)
        #= none:100 =#
        closure = getclosure(i, j, closure)
        #= none:101 =#
        R₃₃ = isopycnal_rotation_tensor_zz_ccf(i, j, k, grid, buoyancy, tracers, closure.isopycnal_tensor)
        #= none:103 =#
        ϵ = tapering_factorᶜᶜᶠ(i, j, k, grid, closure, tracers, buoyancy)
        #= none:105 =#
        #= none:105 =# @inbounds ϵ_R₃₃[i, j, k] = ϵ * R₃₃
    end
#= none:112 =#
struct FluxTapering{FT}
    #= none:113 =#
    max_slope::FT
end
#= none:116 =#
#= none:116 =# Core.@doc "    taper_factor(i, j, k, grid, closure, tracers, buoyancy) \n\nReturn the tapering factor `min(1, Sₘₐₓ² / slope²)`, where `slope² = slope_x² + slope_y²`\nthat multiplies all components of the isopycnal slope tensor. The tapering factor is calculated on all the\nfaces involved in the isopycnal slope tensor calculation. The minimum value of tapering is selected.\n\nReferences\n==========\nR. Gerdes, C. Koberle, and J. Willebrand. (1991), \"The influence of numerical advection schemes\n    on the results of ocean general circulation models\", Clim. Dynamics, 5 (4), 211–226.\n" #= none:128 =# @inline(function tapering_factor(i, j, k, grid, closure, tracers, buoyancy)
            #= none:128 =#
            #= none:130 =#
            ϵᶠᶜᶜ = tapering_factorᶠᶜᶜ(i, j, k, grid, closure, tracers, buoyancy)
            #= none:131 =#
            ϵᶜᶠᶜ = tapering_factorᶜᶠᶜ(i, j, k, grid, closure, tracers, buoyancy)
            #= none:132 =#
            ϵᶜᶜᶠ = tapering_factorᶜᶜᶠ(i, j, k, grid, closure, tracers, buoyancy)
            #= none:134 =#
            return min(ϵᶠᶜᶜ, ϵᶜᶠᶜ, ϵᶜᶜᶠ)
        end)
#= none:137 =#
#= none:137 =# @inline function tapering_factorᶠᶜᶜ(i, j, k, grid, closure, tracers, buoyancy)
        #= none:137 =#
        #= none:139 =#
        by = ℑxyᶠᶜᵃ(i, j, k, grid, ∂y_b, buoyancy, tracers)
        #= none:140 =#
        bz = ℑxzᶠᵃᶜ(i, j, k, grid, ∂z_b, buoyancy, tracers)
        #= none:141 =#
        bx = ∂x_b(i, j, k, grid, buoyancy, tracers)
        #= none:143 =#
        return calc_tapering(bx, by, bz, grid, closure.isopycnal_tensor, closure.slope_limiter)
    end
#= none:146 =#
#= none:146 =# @inline function tapering_factorᶜᶠᶜ(i, j, k, grid, closure, tracers, buoyancy)
        #= none:146 =#
        #= none:148 =#
        bx = ℑxyᶜᶠᵃ(i, j, k, grid, ∂x_b, buoyancy, tracers)
        #= none:149 =#
        bz = ℑyzᵃᶠᶜ(i, j, k, grid, ∂z_b, buoyancy, tracers)
        #= none:150 =#
        by = ∂y_b(i, j, k, grid, buoyancy, tracers)
        #= none:152 =#
        return calc_tapering(bx, by, bz, grid, closure.isopycnal_tensor, closure.slope_limiter)
    end
#= none:155 =#
#= none:155 =# @inline function tapering_factorᶜᶜᶠ(i, j, k, grid, closure, tracers, buoyancy)
        #= none:155 =#
        #= none:157 =#
        bx = ℑxzᶜᵃᶠ(i, j, k, grid, ∂x_b, buoyancy, tracers)
        #= none:158 =#
        by = ℑyzᵃᶜᶠ(i, j, k, grid, ∂y_b, buoyancy, tracers)
        #= none:159 =#
        bz = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:161 =#
        return calc_tapering(bx, by, bz, grid, closure.isopycnal_tensor, closure.slope_limiter)
    end
#= none:164 =#
#= none:164 =# @inline function calc_tapering(bx, by, bz, grid, slope_model, slope_limiter)
        #= none:164 =#
        #= none:166 =#
        bz = max(bz, slope_model.minimum_bz)
        #= none:168 =#
        slope_x = -bx / bz
        #= none:169 =#
        slope_y = -by / bz
        #= none:172 =#
        slope² = ifelse(bz <= 0, zero(grid), slope_x ^ 2 + slope_y ^ 2)
        #= none:174 =#
        return min(one(grid), slope_limiter.max_slope ^ 2 / slope²)
    end
#= none:179 =#
#= none:179 =# @inline get_tracer_κ(κ::NamedTuple, tracer_index) = begin
            #= none:179 =#
            #= none:179 =# @inbounds κ[tracer_index]
        end
#= none:180 =#
#= none:180 =# @inline get_tracer_κ(κ, tracer_index) = begin
            #= none:180 =#
            κ
        end
#= none:183 =#
#= none:183 =# @inline function diffusive_flux_x(i, j, k, grid, closure::Union{ISSD, ISSDVector}, diffusivity_fields, ::Val{tracer_index}, c, clock, fields, buoyancy) where tracer_index
        #= none:183 =#
        #= none:187 =#
        closure = getclosure(i, j, closure)
        #= none:189 =#
        κ_skew = get_tracer_κ(closure.κ_skew, tracer_index)
        #= none:190 =#
        κ_symmetric = get_tracer_κ(closure.κ_symmetric, tracer_index)
        #= none:192 =#
        κ_skewᶠᶜᶜ = κᶠᶜᶜ(i, j, k, grid, issd_coefficient_loc, κ_skew, clock)
        #= none:193 =#
        κ_symmetricᶠᶜᶜ = κᶠᶜᶜ(i, j, k, grid, issd_coefficient_loc, κ_symmetric, clock)
        #= none:195 =#
        ∂x_c = ∂xᶠᶜᶜ(i, j, k, grid, c)
        #= none:198 =#
        ∂y_c = ℑxyᶠᶜᵃ(i, j, k, grid, ∂yᶜᶠᶜ, c)
        #= none:199 =#
        ∂z_c = ℑxzᶠᵃᶜ(i, j, k, grid, ∂zᶜᶜᶠ, c)
        #= none:201 =#
        R₁₁ = one(grid)
        #= none:202 =#
        R₁₂ = zero(grid)
        #= none:203 =#
        R₁₃ = isopycnal_rotation_tensor_xz_fcc(i, j, k, grid, buoyancy, fields, closure.isopycnal_tensor)
        #= none:205 =#
        ϵ = tapering_factorᶠᶜᶜ(i, j, k, grid, closure, fields, buoyancy)
        #= none:207 =#
        return -ϵ * (κ_symmetricᶠᶜᶜ * R₁₁ * ∂x_c + κ_symmetricᶠᶜᶜ * R₁₂ * ∂y_c + (κ_symmetricᶠᶜᶜ - κ_skewᶠᶜᶜ) * R₁₃ * ∂z_c)
    end
#= none:213 =#
#= none:213 =# @inline function diffusive_flux_y(i, j, k, grid, closure::Union{ISSD, ISSDVector}, diffusivity_fields, ::Val{tracer_index}, c, clock, fields, buoyancy) where tracer_index
        #= none:213 =#
        #= none:217 =#
        closure = getclosure(i, j, closure)
        #= none:219 =#
        κ_skew = get_tracer_κ(closure.κ_skew, tracer_index)
        #= none:220 =#
        κ_symmetric = get_tracer_κ(closure.κ_symmetric, tracer_index)
        #= none:222 =#
        κ_skewᶜᶠᶜ = κᶜᶠᶜ(i, j, k, grid, issd_coefficient_loc, κ_skew, clock)
        #= none:223 =#
        κ_symmetricᶜᶠᶜ = κᶜᶠᶜ(i, j, k, grid, issd_coefficient_loc, κ_symmetric, clock)
        #= none:225 =#
        ∂y_c = ∂yᶜᶠᶜ(i, j, k, grid, c)
        #= none:228 =#
        ∂x_c = ℑxyᶜᶠᵃ(i, j, k, grid, ∂xᶠᶜᶜ, c)
        #= none:229 =#
        ∂z_c = ℑyzᵃᶠᶜ(i, j, k, grid, ∂zᶜᶜᶠ, c)
        #= none:231 =#
        R₂₁ = zero(grid)
        #= none:232 =#
        R₂₂ = one(grid)
        #= none:233 =#
        R₂₃ = isopycnal_rotation_tensor_yz_cfc(i, j, k, grid, buoyancy, fields, closure.isopycnal_tensor)
        #= none:235 =#
        ϵ = tapering_factorᶜᶠᶜ(i, j, k, grid, closure, fields, buoyancy)
        #= none:237 =#
        return -ϵ * (κ_symmetricᶜᶠᶜ * R₂₁ * ∂x_c + κ_symmetricᶜᶠᶜ * R₂₂ * ∂y_c + (κ_symmetricᶜᶠᶜ - κ_skewᶜᶠᶜ) * R₂₃ * ∂z_c)
    end
#= none:243 =#
#= none:243 =# @inline function diffusive_flux_z(i, j, k, grid, closure::FlavorOfISSD{TD}, diffusivity_fields, ::Val{tracer_index}, c, clock, fields, buoyancy) where {tracer_index, TD}
        #= none:243 =#
        #= none:247 =#
        closure = getclosure(i, j, closure)
        #= none:249 =#
        κ_skew = get_tracer_κ(closure.κ_skew, tracer_index)
        #= none:250 =#
        κ_symmetric = get_tracer_κ(closure.κ_symmetric, tracer_index)
        #= none:252 =#
        κ_skewᶜᶜᶠ = κᶜᶜᶠ(i, j, k, grid, issd_coefficient_loc, κ_skew, clock)
        #= none:253 =#
        κ_symmetricᶜᶜᶠ = κᶜᶜᶠ(i, j, k, grid, issd_coefficient_loc, κ_symmetric, clock)
        #= none:256 =#
        ∂x_c = ℑxzᶜᵃᶠ(i, j, k, grid, ∂xᶠᶜᶜ, c)
        #= none:257 =#
        ∂y_c = ℑyzᵃᶜᶠ(i, j, k, grid, ∂yᶜᶠᶜ, c)
        #= none:259 =#
        R₃₁ = isopycnal_rotation_tensor_xz_ccf(i, j, k, grid, buoyancy, fields, closure.isopycnal_tensor)
        #= none:260 =#
        R₃₂ = isopycnal_rotation_tensor_yz_ccf(i, j, k, grid, buoyancy, fields, closure.isopycnal_tensor)
        #= none:262 =#
        κ_symmetric_∂z_c = explicit_κ_∂z_c(i, j, k, grid, TD(), c, κ_symmetricᶜᶜᶠ, closure, buoyancy, fields)
        #= none:264 =#
        ϵ = tapering_factorᶜᶜᶠ(i, j, k, grid, closure, fields, buoyancy)
        #= none:266 =#
        return -ϵ * κ_symmetric_∂z_c - ϵ * ((κ_symmetricᶜᶜᶠ + κ_skewᶜᶜᶠ) * R₃₁ * ∂x_c + (κ_symmetricᶜᶜᶠ + κ_skewᶜᶜᶠ) * R₃₂ * ∂y_c)
    end
#= none:270 =#
#= none:270 =# @inline function explicit_κ_∂z_c(i, j, k, grid, ::ExplicitTimeDiscretization, κ_symmetricᶜᶜᶠ, closure, buoyancy, tracers)
        #= none:270 =#
        #= none:271 =#
        ∂z_c = ∂zᶜᶜᶠ(i, j, k, grid, c)
        #= none:272 =#
        R₃₃ = isopycnal_rotation_tensor_zz_ccf(i, j, k, grid, buoyancy, tracers, closure.isopycnal_tensor)
        #= none:274 =#
        ϵ = tapering_factorᶜᶜᶠ(i, j, k, grid, closure, tracers, buoyancy)
        #= none:276 =#
        return ϵ * κ_symmetricᶜᶜᶠ * R₃₃ * ∂z_c
    end
#= none:279 =#
#= none:279 =# @inline explicit_κ_∂z_c(i, j, k, grid, ::VerticallyImplicitTimeDiscretization, args...) = begin
            #= none:279 =#
            zero(grid)
        end
#= none:281 =#
#= none:281 =# @inline function κzᶜᶜᶠ(i, j, k, grid, closure::FlavorOfISSD, K, ::Val{id}, clock) where id
        #= none:281 =#
        #= none:282 =#
        closure = getclosure(i, j, closure)
        #= none:283 =#
        κ_symmetric = get_tracer_κ(closure.κ_symmetric, id)
        #= none:284 =#
        ϵ_R₃₃ = #= none:284 =# @inbounds(K.ϵ_R₃₃[i, j, k])
        #= none:285 =#
        return ϵ_R₃₃ * κᶜᶜᶠ(i, j, k, grid, issd_coefficient_loc, κ_symmetric, clock)
    end
#= none:288 =#
#= none:288 =# @inline viscous_flux_ux(i, j, k, grid, closure::Union{ISSD, ISSDVector}, args...) = begin
            #= none:288 =#
            zero(grid)
        end
#= none:289 =#
#= none:289 =# @inline viscous_flux_uy(i, j, k, grid, closure::Union{ISSD, ISSDVector}, args...) = begin
            #= none:289 =#
            zero(grid)
        end
#= none:290 =#
#= none:290 =# @inline viscous_flux_uz(i, j, k, grid, closure::Union{ISSD, ISSDVector}, args...) = begin
            #= none:290 =#
            zero(grid)
        end
#= none:292 =#
#= none:292 =# @inline viscous_flux_vx(i, j, k, grid, closure::Union{ISSD, ISSDVector}, args...) = begin
            #= none:292 =#
            zero(grid)
        end
#= none:293 =#
#= none:293 =# @inline viscous_flux_vy(i, j, k, grid, closure::Union{ISSD, ISSDVector}, args...) = begin
            #= none:293 =#
            zero(grid)
        end
#= none:294 =#
#= none:294 =# @inline viscous_flux_vz(i, j, k, grid, closure::Union{ISSD, ISSDVector}, args...) = begin
            #= none:294 =#
            zero(grid)
        end
#= none:296 =#
#= none:296 =# @inline viscous_flux_wx(i, j, k, grid, closure::Union{ISSD, ISSDVector}, args...) = begin
            #= none:296 =#
            zero(grid)
        end
#= none:297 =#
#= none:297 =# @inline viscous_flux_wy(i, j, k, grid, closure::Union{ISSD, ISSDVector}, args...) = begin
            #= none:297 =#
            zero(grid)
        end
#= none:298 =#
#= none:298 =# @inline viscous_flux_wz(i, j, k, grid, closure::Union{ISSD, ISSDVector}, args...) = begin
            #= none:298 =#
            zero(grid)
        end
#= none:304 =#
Base.summary(closure::ISSD) = begin
        #= none:304 =#
        string("IsopycnalSkewSymmetricDiffusivity", "(κ_skew=", prettysummary(closure.κ_skew), ", κ_symmetric=", prettysummary(closure.κ_symmetric), ")")
    end
#= none:309 =#
Base.show(io::IO, closure::ISSD) = begin
        #= none:309 =#
        print(io, "IsopycnalSkewSymmetricDiffusivity: " * "(κ_symmetric=$(closure.κ_symmetric), κ_skew=$(closure.κ_skew), " * "(isopycnal_tensor=$(closure.isopycnal_tensor), slope_limiter=$(closure.slope_limiter))")
    end