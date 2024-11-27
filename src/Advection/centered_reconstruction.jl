
#= none:5 =#
#= none:5 =# Core.@doc "    struct Centered{N, FT, XT, YT, ZT, CA} <: AbstractCenteredAdvectionScheme{N, FT}\n\nCentered reconstruction scheme.\n" struct Centered{N, FT, XT, YT, ZT, CA} <: AbstractCenteredAdvectionScheme{N, FT}
        #= none:11 =#
        "coefficient for Centered reconstruction on stretched ``x``-faces"
        #= none:12 =#
        coeff_xᶠᵃᵃ::XT
        #= none:13 =#
        "coefficient for Centered reconstruction on stretched ``x``-centers"
        #= none:14 =#
        coeff_xᶜᵃᵃ::XT
        #= none:15 =#
        "coefficient for Centered reconstruction on stretched ``y``-faces"
        #= none:16 =#
        coeff_yᵃᶠᵃ::YT
        #= none:17 =#
        "coefficient for Centered reconstruction on stretched ``y``-centers"
        #= none:18 =#
        coeff_yᵃᶜᵃ::YT
        #= none:19 =#
        "coefficient for Centered reconstruction on stretched ``z``-faces"
        #= none:20 =#
        coeff_zᵃᵃᶠ::ZT
        #= none:21 =#
        "coefficient for Centered reconstruction on stretched ``z``-centers"
        #= none:22 =#
        coeff_zᵃᵃᶜ::ZT
        #= none:24 =#
        "advection scheme used near boundaries"
        #= none:25 =#
        buffer_scheme::CA
        #= none:27 =#
        function Centered{N, FT}(coeff_xᶠᵃᵃ::XT, coeff_xᶜᵃᵃ::XT, coeff_yᵃᶠᵃ::YT, coeff_yᵃᶜᵃ::YT, coeff_zᵃᵃᶠ::ZT, coeff_zᵃᵃᶜ::ZT, buffer_scheme::CA) where {N, FT, XT, YT, ZT, CA}
            #= none:27 =#
            #= none:32 =#
            return new{N, FT, XT, YT, ZT, CA}(coeff_xᶠᵃᵃ, coeff_xᶜᵃᵃ, coeff_yᵃᶠᵃ, coeff_yᵃᶜᵃ, coeff_zᵃᵃᶠ, coeff_zᵃᵃᶜ, buffer_scheme)
        end
    end
#= none:39 =#
function Centered(FT::DataType = Float64; grid = nothing, order = 2)
    #= none:39 =#
    #= none:41 =#
    if !(grid isa Nothing)
        #= none:42 =#
        FT = eltype(grid)
    end
    #= none:45 =#
    mod(order, 2) != 0 && throw(ArgumentError("Centered reconstruction scheme is defined only for even orders"))
    #= none:47 =#
    N = Int(order ÷ 2)
    #= none:48 =#
    if N > 1
        #= none:49 =#
        coefficients = Tuple((nothing for i = 1:6))
        #= none:53 =#
        buffer_scheme = Centered(FT; grid, order = order - 2)
    else
        #= none:55 =#
        coefficients = Tuple((nothing for i = 1:6))
        #= none:56 =#
        buffer_scheme = nothing
    end
    #= none:58 =#
    return Centered{N, FT}(coefficients..., buffer_scheme)
end
#= none:61 =#
(Base.summary(a::Centered{N}) where N) = begin
        #= none:61 =#
        string("Centered reconstruction order ", N * 2)
    end
#= none:63 =#
(Base.show(io::IO, a::Centered{N, FT, XT, YT, ZT}) where {N, FT, XT, YT, ZT}) = begin
        #= none:63 =#
        print(io, summary(a), " \n", " Boundary scheme: ", "\n", "    └── ", summary(a.buffer_scheme), "\n", " Directions:", "\n", "    ├── X $(if XT == Nothing
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
#= none:73 =#
(Adapt.adapt_structure(to, scheme::Centered{N, FT}) where {N, FT}) = begin
        #= none:73 =#
        Centered{N, FT}(Adapt.adapt(to, scheme.coeff_xᶠᵃᵃ), Adapt.adapt(to, scheme.coeff_xᶜᵃᵃ), Adapt.adapt(to, scheme.coeff_yᵃᶠᵃ), Adapt.adapt(to, scheme.coeff_yᵃᶜᵃ), Adapt.adapt(to, scheme.coeff_zᵃᵃᶠ), Adapt.adapt(to, scheme.coeff_zᵃᵃᶜ), Adapt.adapt(to, scheme.buffer_scheme))
    end
#= none:79 =#
(on_architecture(to, scheme::Centered{N, FT}) where {N, FT}) = begin
        #= none:79 =#
        Centered{N, FT}(on_architecture(to, scheme.coeff_xᶠᵃᵃ), on_architecture(to, scheme.coeff_xᶜᵃᵃ), on_architecture(to, scheme.coeff_yᵃᶠᵃ), on_architecture(to, scheme.coeff_yᵃᶜᵃ), on_architecture(to, scheme.coeff_zᵃᵃᶠ), on_architecture(to, scheme.coeff_zᵃᵃᶜ), on_architecture(to, scheme.buffer_scheme))
    end
#= none:86 =#
Centered(grid, FT::DataType = Float64; kwargs...) = begin
        #= none:86 =#
        Centered(FT; grid, kwargs...)
    end
#= none:88 =#
CenteredSecondOrder(grid = nothing, FT::DataType = Float64) = begin
        #= none:88 =#
        Centered(grid, FT; order = 2)
    end
#= none:89 =#
CenteredFourthOrder(grid = nothing, FT::DataType = Float64) = begin
        #= none:89 =#
        Centered(grid, FT; order = 4)
    end
#= none:91 =#
const ACAS = AbstractCenteredAdvectionScheme
#= none:94 =#
#= none:94 =# @inline biased_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme::ACAS, bias, c, args...) = begin
            #= none:94 =#
            symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, c, args...)
        end
#= none:95 =#
#= none:95 =# @inline biased_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme::ACAS, bias, c, args...) = begin
            #= none:95 =#
            symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, c, args...)
        end
#= none:96 =#
#= none:96 =# @inline biased_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme::ACAS, bias, c, args...) = begin
            #= none:96 =#
            symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, c, args...)
        end
#= none:99 =#
#= none:99 =# @inline biased_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme::ACAS, bias, c, args...) = begin
            #= none:99 =#
            symmetric_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme, c, args...)
        end
#= none:100 =#
#= none:100 =# @inline biased_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme::ACAS, bias, c, args...) = begin
            #= none:100 =#
            symmetric_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme, c, args...)
        end
#= none:101 =#
#= none:101 =# @inline biased_interpolate_zᵃᵃᶜ(i, j, k, grid, scheme::ACAS, bias, c, args...) = begin
            #= none:101 =#
            symmetric_interpolate_zᵃᵃᶜ(i, j, k, grid, scheme, c, args...)
        end
#= none:104 =#
for buffer = advection_buffers
    #= none:105 =#
    #= none:105 =# @eval begin
            #= none:106 =#
            #= none:106 =# @inline (inner_symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme::Centered{$buffer, FT, <:Nothing}, ψ, idx, loc, args...) where FT) = begin
                        #= none:106 =#
                        #= none:106 =# @inbounds $(calc_reconstruction_stencil(buffer, :symmetric, :x, false))
                    end
            #= none:107 =#
            #= none:107 =# @inline (inner_symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme::Centered{$buffer, FT, <:Nothing}, ψ::Function, idx, loc, args...) where FT) = begin
                        #= none:107 =#
                        #= none:107 =# @inbounds $(calc_reconstruction_stencil(buffer, :symmetric, :x, true))
                    end
            #= none:109 =#
            #= none:109 =# @inline (inner_symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme::Centered{$buffer, FT, XT, <:Nothing}, ψ, idx, loc, args...) where {FT, XT}) = begin
                        #= none:109 =#
                        #= none:109 =# @inbounds $(calc_reconstruction_stencil(buffer, :symmetric, :y, false))
                    end
            #= none:110 =#
            #= none:110 =# @inline (inner_symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme::Centered{$buffer, FT, XT, <:Nothing}, ψ::Function, idx, loc, args...) where {FT, XT}) = begin
                        #= none:110 =#
                        #= none:110 =# @inbounds $(calc_reconstruction_stencil(buffer, :symmetric, :y, true))
                    end
            #= none:112 =#
            #= none:112 =# @inline (inner_symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme::Centered{$buffer, FT, XT, YT, <:Nothing}, ψ, idx, loc, args...) where {FT, XT, YT}) = begin
                        #= none:112 =#
                        #= none:112 =# @inbounds $(calc_reconstruction_stencil(buffer, :symmetric, :z, false))
                    end
            #= none:113 =#
            #= none:113 =# @inline (inner_symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme::Centered{$buffer, FT, XT, YT, <:Nothing}, ψ::Function, idx, loc, args...) where {FT, XT, YT}) = begin
                        #= none:113 =#
                        #= none:113 =# @inbounds $(calc_reconstruction_stencil(buffer, :symmetric, :z, true))
                    end
        end
    #= none:115 =#
end
#= none:118 =#
for (dir, ξ, val) = zip((:xᶠᵃᵃ, :yᵃᶠᵃ, :zᵃᵃᶠ), (:x, :y, :z), (1, 2, 3))
    #= none:119 =#
    stencil = Symbol(:inner_symmetric_interpolate_, dir)
    #= none:121 =#
    for buffer = advection_buffers
        #= none:122 =#
        #= none:122 =# @eval begin
                #= none:123 =#
                #= none:123 =# @inline ($stencil(i, j, k, grid, scheme::Centered{$buffer, FT}, ψ, idx, loc, args...) where FT) = begin
                            #= none:123 =#
                            #= none:123 =# @inbounds sum($(reconstruction_stencil(buffer, :symmetric, ξ, false)) .* retrieve_coeff(scheme, Val($val), idx, loc))
                        end
                #= none:124 =#
                #= none:124 =# @inline ($stencil(i, j, k, grid, scheme::Centered{$buffer, FT}, ψ::Function, idx, loc, args...) where FT) = begin
                            #= none:124 =#
                            #= none:124 =# @inbounds sum($(reconstruction_stencil(buffer, :symmetric, ξ, true)) .* retrieve_coeff(scheme, Val($val), idx, loc))
                        end
            end
        #= none:126 =#
    end
    #= none:127 =#
end
#= none:130 =#
#= none:130 =# @inline retrieve_coeff(scheme::Centered, ::Val{1}, i, ::Type{Face}) = begin
            #= none:130 =#
            #= none:130 =# @inbounds scheme.coeff_xᶠᵃᵃ[i]
        end
#= none:131 =#
#= none:131 =# @inline retrieve_coeff(scheme::Centered, ::Val{1}, i, ::Type{Center}) = begin
            #= none:131 =#
            #= none:131 =# @inbounds scheme.coeff_xᶜᵃᵃ[i]
        end
#= none:132 =#
#= none:132 =# @inline retrieve_coeff(scheme::Centered, ::Val{2}, i, ::Type{Face}) = begin
            #= none:132 =#
            #= none:132 =# @inbounds scheme.coeff_yᵃᶠᵃ[i]
        end
#= none:133 =#
#= none:133 =# @inline retrieve_coeff(scheme::Centered, ::Val{2}, i, ::Type{Center}) = begin
            #= none:133 =#
            #= none:133 =# @inbounds scheme.coeff_yᵃᶜᵃ[i]
        end
#= none:134 =#
#= none:134 =# @inline retrieve_coeff(scheme::Centered, ::Val{3}, i, ::Type{Face}) = begin
            #= none:134 =#
            #= none:134 =# @inbounds scheme.coeff_zᵃᵃᶠ[i]
        end
#= none:135 =#
#= none:135 =# @inline retrieve_coeff(scheme::Centered, ::Val{3}, i, ::Type{Center}) = begin
            #= none:135 =#
            #= none:135 =# @inbounds scheme.coeff_zᵃᵃᶜ[i]
        end