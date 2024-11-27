
#= none:5 =#
#= none:5 =# Core.@doc "    struct UpwindBiasedFifthOrder <: AbstractUpwindBiasedAdvectionScheme{3}\n\nUpwind-biased fifth-order advection scheme.\n" struct UpwindBiased{N, FT, XT, YT, ZT, CA, SI} <: AbstractUpwindBiasedAdvectionScheme{N, FT}
        #= none:11 =#
        "Coefficient for Upwind reconstruction on stretched ``x``-faces"
        #= none:12 =#
        coeff_xᶠᵃᵃ::XT
        #= none:13 =#
        "Coefficient for Upwind reconstruction on stretched ``x``-centers"
        #= none:14 =#
        coeff_xᶜᵃᵃ::XT
        #= none:15 =#
        "Coefficient for Upwind reconstruction on stretched ``y``-faces"
        #= none:16 =#
        coeff_yᵃᶠᵃ::YT
        #= none:17 =#
        "Coefficient for Upwind reconstruction on stretched ``y``-centers"
        #= none:18 =#
        coeff_yᵃᶜᵃ::YT
        #= none:19 =#
        "Coefficient for Upwind reconstruction on stretched ``z``-faces"
        #= none:20 =#
        coeff_zᵃᵃᶠ::ZT
        #= none:21 =#
        "Coefficient for Upwind reconstruction on stretched ``z``-centers"
        #= none:22 =#
        coeff_zᵃᵃᶜ::ZT
        #= none:24 =#
        "Reconstruction scheme used near boundaries"
        #= none:25 =#
        buffer_scheme::CA
        #= none:26 =#
        "Reconstruction scheme used for symmetric interpolation"
        #= none:27 =#
        advecting_velocity_scheme::SI
        #= none:29 =#
        function UpwindBiased{N, FT}(coeff_xᶠᵃᵃ::XT, coeff_xᶜᵃᵃ::XT, coeff_yᵃᶠᵃ::YT, coeff_yᵃᶜᵃ::YT, coeff_zᵃᵃᶠ::ZT, coeff_zᵃᵃᶜ::ZT, buffer_scheme::CA, advecting_velocity_scheme::SI) where {N, FT, XT, YT, ZT, CA, SI}
            #= none:29 =#
            #= none:34 =#
            return new{N, FT, XT, YT, ZT, CA, SI}(coeff_xᶠᵃᵃ, coeff_xᶜᵃᵃ, coeff_yᵃᶠᵃ, coeff_yᵃᶜᵃ, coeff_zᵃᵃᶠ, coeff_zᵃᵃᶜ, buffer_scheme, advecting_velocity_scheme)
        end
    end
#= none:41 =#
function UpwindBiased(FT::DataType = Float64; grid = nothing, order = 3)
    #= none:41 =#
    #= none:43 =#
    if !(grid isa Nothing)
        #= none:44 =#
        FT = eltype(grid)
    end
    #= none:47 =#
    mod(order, 2) == 0 && throw(ArgumentError("UpwindBiased reconstruction scheme is defined only for odd orders"))
    #= none:49 =#
    N = Int((order + 1) ÷ 2)
    #= none:51 =#
    if N > 1
        #= none:52 =#
        coefficients = Tuple((nothing for i = 1:6))
        #= none:57 =#
        advecting_velocity_scheme = Centered(FT; grid, order = order - 1)
        #= none:58 =#
        buffer_scheme = UpwindBiased(FT; grid, order = order - 2)
    else
        #= none:60 =#
        coefficients = Tuple((nothing for i = 1:6))
        #= none:61 =#
        advecting_velocity_scheme = Centered(FT; grid, order = 2)
        #= none:62 =#
        buffer_scheme = nothing
    end
    #= none:65 =#
    return UpwindBiased{N, FT}(coefficients..., buffer_scheme, advecting_velocity_scheme)
end
#= none:68 =#
(Base.summary(a::UpwindBiased{N}) where N) = begin
        #= none:68 =#
        string("Upwind Biased reconstruction order ", N * 2 - 1)
    end
#= none:70 =#
(Base.show(io::IO, a::UpwindBiased{N, FT, XT, YT, ZT}) where {N, FT, XT, YT, ZT}) = begin
        #= none:70 =#
        print(io, summary(a), " \n", " Boundary scheme: ", "\n", "    └── ", summary(a.buffer_scheme), "\n", " Symmetric scheme: ", "\n", "    └── ", summary(a.advecting_velocity_scheme), "\n", " Directions:", "\n", "    ├── X $(if XT == Nothing
    "regular"
else
    "stretched"
end) \n", "    ├── Y $(if YT == Nothing
    "regular"
else
    "stretched"
end) \n", "    └── Z $(if ZT == Nothing
    "regular"
else
    "stretched"
end)")
    end
#= none:81 =#
(Adapt.adapt_structure(to, scheme::UpwindBiased{N, FT}) where {N, FT}) = begin
        #= none:81 =#
        UpwindBiased{N, FT}(Adapt.adapt(to, scheme.coeff_xᶠᵃᵃ), Adapt.adapt(to, scheme.coeff_xᶜᵃᵃ), Adapt.adapt(to, scheme.coeff_yᵃᶠᵃ), Adapt.adapt(to, scheme.coeff_yᵃᶜᵃ), Adapt.adapt(to, scheme.coeff_zᵃᵃᶠ), Adapt.adapt(to, scheme.coeff_zᵃᵃᶜ), Adapt.adapt(to, scheme.buffer_scheme), Adapt.adapt(to, scheme.advecting_velocity_scheme))
    end
#= none:88 =#
(on_architecture(to, scheme::UpwindBiased{N, FT}) where {N, FT}) = begin
        #= none:88 =#
        UpwindBiased{N, FT}(on_architecture(to, scheme.coeff_xᶠᵃᵃ), on_architecture(to, scheme.coeff_xᶜᵃᵃ), on_architecture(to, scheme.coeff_yᵃᶠᵃ), on_architecture(to, scheme.coeff_yᵃᶜᵃ), on_architecture(to, scheme.coeff_zᵃᵃᶠ), on_architecture(to, scheme.coeff_zᵃᵃᶜ), on_architecture(to, scheme.buffer_scheme), on_architecture(to, scheme.advecting_velocity_scheme))
    end
#= none:96 =#
UpwindBiased(grid, FT::DataType = Float64; kwargs...) = begin
        #= none:96 =#
        UpwindBiased(FT; grid, kwargs...)
    end
#= none:98 =#
UpwindBiasedFirstOrder(grid = nothing, FT::DataType = Float64) = begin
        #= none:98 =#
        UpwindBiased(grid, FT; order = 1)
    end
#= none:99 =#
UpwindBiasedThirdOrder(grid = nothing, FT::DataType = Float64) = begin
        #= none:99 =#
        UpwindBiased(grid, FT; order = 3)
    end
#= none:100 =#
UpwindBiasedFifthOrder(grid = nothing, FT::DataType = Float64) = begin
        #= none:100 =#
        UpwindBiased(grid, FT; order = 5)
    end
#= none:102 =#
const AUAS = AbstractUpwindBiasedAdvectionScheme
#= none:105 =#
#= none:105 =# @inline symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme::AUAS, c, args...) = begin
            #= none:105 =#
            #= none:105 =# @inbounds symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme.advecting_velocity_scheme, c, args...)
        end
#= none:106 =#
#= none:106 =# @inline symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme::AUAS, c, args...) = begin
            #= none:106 =#
            #= none:106 =# @inbounds symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme.advecting_velocity_scheme, c, args...)
        end
#= none:107 =#
#= none:107 =# @inline symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme::AUAS, c, args...) = begin
            #= none:107 =#
            #= none:107 =# @inbounds symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme.advecting_velocity_scheme, c, args...)
        end
#= none:109 =#
#= none:109 =# @inline symmetric_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme::AUAS, u, args...) = begin
            #= none:109 =#
            #= none:109 =# @inbounds symmetric_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme.advecting_velocity_scheme, u, args...)
        end
#= none:110 =#
#= none:110 =# @inline symmetric_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme::AUAS, v, args...) = begin
            #= none:110 =#
            #= none:110 =# @inbounds symmetric_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme.advecting_velocity_scheme, v, args...)
        end
#= none:111 =#
#= none:111 =# @inline symmetric_interpolate_zᵃᵃᶜ(i, j, k, grid, scheme::AUAS, w, args...) = begin
            #= none:111 =#
            #= none:111 =# @inbounds symmetric_interpolate_zᵃᵃᶜ(i, j, k, grid, scheme.advecting_velocity_scheme, w, args...)
        end
#= none:113 =#
const UX{N, FT} = (UpwindBiased{N, FT, <:Nothing} where {N, FT})
#= none:114 =#
const UY{N, FT} = (UpwindBiased{N, FT, <:Any, <:Nothing} where {N, FT})
#= none:115 =#
const UZ{N, FT} = (UpwindBiased{N, FT, <:Any, <:Any, <:Nothing} where {N, FT})
#= none:118 =#
for buffer = advection_buffers
    #= none:119 =#
    #= none:119 =# @eval begin
            #= none:120 =#
            #= none:120 =# @inline (inner_biased_interpolate_xᶠᵃᵃ(i, j, k, grid, ::UX{$buffer, FT}, bias, ψ, idx, loc, args...) where FT) = begin
                        #= none:120 =#
                        #= none:121 =# @inbounds ifelse(bias isa LeftBias, $(calc_reconstruction_stencil(buffer, :left, :x, false)), $(calc_reconstruction_stencil(buffer, :right, :x, false)))
                    end
            #= none:124 =#
            #= none:124 =# @inline (inner_biased_interpolate_xᶠᵃᵃ(i, j, k, grid, ::UX{$buffer, FT}, bias, ψ::Function, idx, loc, args...) where FT) = begin
                        #= none:124 =#
                        #= none:125 =# @inbounds ifelse(bias isa LeftBias, $(calc_reconstruction_stencil(buffer, :left, :x, true)), $(calc_reconstruction_stencil(buffer, :right, :x, true)))
                    end
            #= none:128 =#
            #= none:128 =# @inline (inner_biased_interpolate_yᵃᶠᵃ(i, j, k, grid, ::UY{$buffer, FT}, bias, ψ, idx, loc, args...) where FT) = begin
                        #= none:128 =#
                        #= none:129 =# @inbounds ifelse(bias isa LeftBias, $(calc_reconstruction_stencil(buffer, :left, :y, false)), $(calc_reconstruction_stencil(buffer, :right, :y, false)))
                    end
            #= none:132 =#
            #= none:132 =# @inline (inner_biased_interpolate_yᵃᶠᵃ(i, j, k, grid, ::UY{$buffer, FT}, bias, ψ::Function, idx, loc, args...) where FT) = begin
                        #= none:132 =#
                        #= none:133 =# @inbounds ifelse(bias isa LeftBias, $(calc_reconstruction_stencil(buffer, :left, :y, true)), $(calc_reconstruction_stencil(buffer, :right, :y, true)))
                    end
            #= none:136 =#
            #= none:136 =# @inline (inner_biased_interpolate_zᵃᵃᶠ(i, j, k, grid, ::UZ{$buffer, FT}, bias, ψ, idx, loc, args...) where FT) = begin
                        #= none:136 =#
                        #= none:137 =# @inbounds ifelse(bias isa LeftBias, $(calc_reconstruction_stencil(buffer, :left, :z, false)), $(calc_reconstruction_stencil(buffer, :right, :z, false)))
                    end
            #= none:140 =#
            #= none:140 =# @inline (inner_biased_interpolate_zᵃᵃᶠ(i, j, k, grid, ::UZ{$buffer, FT}, bias, ψ::Function, idx, loc, args...) where FT) = begin
                        #= none:140 =#
                        #= none:141 =# @inbounds ifelse(bias isa LeftBias, $(calc_reconstruction_stencil(buffer, :left, :z, true)), $(calc_reconstruction_stencil(buffer, :right, :z, true)))
                    end
        end
    #= none:144 =#
end
#= none:147 =#
for (dir, ξ, val) = zip((:xᶠᵃᵃ, :yᵃᶠᵃ, :zᵃᵃᶠ), (:x, :y, :z), (1, 2, 3))
    #= none:148 =#
    stencil = Symbol(:inner_biased_interpolate_, dir)
    #= none:150 =#
    for buffer = advection_buffers
        #= none:151 =#
        #= none:151 =# @eval begin
                #= none:152 =#
                #= none:152 =# @inline ($stencil(i, j, k, grid, scheme::UpwindBiased{$buffer, FT}, bias, ψ, idx, loc, args...) where FT) = begin
                            #= none:152 =#
                            #= none:153 =# @inbounds ifelse(bias isa LeftBias, sum($(reconstruction_stencil(buffer, :left, ξ, false)) .* retrieve_coeff(scheme, Val(1), Val($val), idx, loc)), sum($(reconstruction_stencil(buffer, :right, ξ, false)) .* retrieve_coeff(scheme, Val(2), Val($val), idx, loc)))
                        end
                #= none:156 =#
                #= none:156 =# @inline ($stencil(i, j, k, grid, scheme::UpwindBiased{$buffer, FT}, bias, ψ::Function, idx, loc, args...) where FT) = begin
                            #= none:156 =#
                            #= none:157 =# @inbounds ifelse(bias isa LeftBias, sum($(reconstruction_stencil(buffer, :left, ξ, true)) .* retrieve_coeff(scheme, Val(1), Val($val), idx, loc)), sum($(reconstruction_stencil(buffer, :right, ξ, true)) .* retrieve_coeff(scheme, Val(2), Val($val), idx, loc)))
                        end
            end
        #= none:160 =#
    end
    #= none:161 =#
end
#= none:164 =#
#= none:164 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{1}, ::Val{1}, i, ::Type{Face}) = begin
            #= none:164 =#
            #= none:164 =# @inbounds (scheme.coeff_xᶠᵃᵃ[1])[i]
        end
#= none:165 =#
#= none:165 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{1}, ::Val{1}, i, ::Type{Center}) = begin
            #= none:165 =#
            #= none:165 =# @inbounds (scheme.coeff_xᶜᵃᵃ[1])[i]
        end
#= none:166 =#
#= none:166 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{1}, ::Val{2}, i, ::Type{Face}) = begin
            #= none:166 =#
            #= none:166 =# @inbounds (scheme.coeff_yᵃᶠᵃ[1])[i]
        end
#= none:167 =#
#= none:167 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{1}, ::Val{2}, i, ::Type{Center}) = begin
            #= none:167 =#
            #= none:167 =# @inbounds (scheme.coeff_yᵃᶜᵃ[1])[i]
        end
#= none:168 =#
#= none:168 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{1}, ::Val{3}, i, ::Type{Face}) = begin
            #= none:168 =#
            #= none:168 =# @inbounds (scheme.coeff_zᵃᵃᶠ[1])[i]
        end
#= none:169 =#
#= none:169 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{1}, ::Val{3}, i, ::Type{Center}) = begin
            #= none:169 =#
            #= none:169 =# @inbounds (scheme.coeff_zᵃᵃᶜ[1])[i]
        end
#= none:171 =#
#= none:171 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{2}, ::Val{1}, i, ::Type{Face}) = begin
            #= none:171 =#
            #= none:171 =# @inbounds (scheme.coeff_xᶠᵃᵃ[2])[i]
        end
#= none:172 =#
#= none:172 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{2}, ::Val{1}, i, ::Type{Center}) = begin
            #= none:172 =#
            #= none:172 =# @inbounds (scheme.coeff_xᶜᵃᵃ[2])[i]
        end
#= none:173 =#
#= none:173 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{2}, ::Val{2}, i, ::Type{Face}) = begin
            #= none:173 =#
            #= none:173 =# @inbounds (scheme.coeff_yᵃᶠᵃ[2])[i]
        end
#= none:174 =#
#= none:174 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{2}, ::Val{2}, i, ::Type{Center}) = begin
            #= none:174 =#
            #= none:174 =# @inbounds (scheme.coeff_yᵃᶜᵃ[2])[i]
        end
#= none:175 =#
#= none:175 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{2}, ::Val{3}, i, ::Type{Face}) = begin
            #= none:175 =#
            #= none:175 =# @inbounds (scheme.coeff_zᵃᵃᶠ[2])[i]
        end
#= none:176 =#
#= none:176 =# @inline retrieve_coeff(scheme::UpwindBiased, ::Val{2}, ::Val{3}, i, ::Type{Center}) = begin
            #= none:176 =#
            #= none:176 =# @inbounds (scheme.coeff_zᵃᵃᶜ[2])[i]
        end