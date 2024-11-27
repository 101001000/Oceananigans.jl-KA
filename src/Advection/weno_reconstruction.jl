
#= none:5 =#
struct WENO{N, FT, XT, YT, ZT, PP, CA, SI} <: AbstractUpwindBiasedAdvectionScheme{N, FT}
    #= none:7 =#
    "Coefficient for ENO reconstruction on x-faces"
    #= none:8 =#
    coeff_xᶠᵃᵃ::XT
    #= none:9 =#
    "Coefficient for ENO reconstruction on x-centers"
    #= none:10 =#
    coeff_xᶜᵃᵃ::XT
    #= none:11 =#
    "Coefficient for ENO reconstruction on y-faces"
    #= none:12 =#
    coeff_yᵃᶠᵃ::YT
    #= none:13 =#
    "Coefficient for ENO reconstruction on y-centers"
    #= none:14 =#
    coeff_yᵃᶜᵃ::YT
    #= none:15 =#
    "Coefficient for ENO reconstruction on z-faces"
    #= none:16 =#
    coeff_zᵃᵃᶠ::ZT
    #= none:17 =#
    "Coefficient for ENO reconstruction on z-centers"
    #= none:18 =#
    coeff_zᵃᵃᶜ::ZT
    #= none:20 =#
    "Bounds for maximum-principle-satisfying WENO scheme"
    #= none:21 =#
    bounds::PP
    #= none:23 =#
    "Advection scheme used near boundaries"
    #= none:24 =#
    buffer_scheme::CA
    #= none:25 =#
    "Reconstruction scheme used for symmetric interpolation"
    #= none:26 =#
    advecting_velocity_scheme::SI
    #= none:28 =#
    function WENO{N, FT}(coeff_xᶠᵃᵃ::XT, coeff_xᶜᵃᵃ::XT, coeff_yᵃᶠᵃ::YT, coeff_yᵃᶜᵃ::YT, coeff_zᵃᵃᶠ::ZT, coeff_zᵃᵃᶜ::ZT, bounds::PP, buffer_scheme::CA, advecting_velocity_scheme::SI) where {N, FT, XT, YT, ZT, PP, CA, SI}
        #= none:28 =#
        #= none:34 =#
        return new{N, FT, XT, YT, ZT, PP, CA, SI}(coeff_xᶠᵃᵃ, coeff_xᶜᵃᵃ, coeff_yᵃᶠᵃ, coeff_yᵃᶜᵃ, coeff_zᵃᵃᶠ, coeff_zᵃᵃᶜ, bounds, buffer_scheme, advecting_velocity_scheme)
    end
end
#= none:41 =#
#= none:41 =# Core.@doc "    WENO([FT=Float64;] \n         order = 5,\n         grid = nothing, \n         bounds = nothing)\n               \nConstruct a weighted essentially non-oscillatory advection scheme of order `order`.\n\nKeyword arguments\n=================\n\n- `order`: The order of the WENO advection scheme. Default: 5\n- `grid`: (defaults to `nothing`)\n\nExamples\n========\n```jldoctest\njulia> using Oceananigans\n\njulia> WENO()\nWENO reconstruction order 5\n Boundary scheme: \n    └── WENO reconstruction order 3\n Symmetric scheme: \n    └── Centered reconstruction order 4\n Directions:\n    ├── X regular \n    ├── Y regular \n    └── Z regular\n```\n\n```jldoctest\njulia> using Oceananigans\n\njulia> Nx, Nz = 16, 10;\n\njulia> Lx, Lz = 1e4, 1e3;\n\njulia> chebychev_spaced_z_faces(k) = - Lz/2 - Lz/2 * cos(π * (k - 1) / Nz);\n\njulia> grid = RectilinearGrid(size = (Nx, Nz), halo = (4, 4), topology=(Periodic, Flat, Bounded),\n                              x = (0, Lx), z = chebychev_spaced_z_faces);\n\njulia> WENO(grid; order=7)\nWENO reconstruction order 7\n Boundary scheme: \n    └── WENO reconstruction order 5\n Symmetric scheme: \n    └── Centered reconstruction order 6\n Directions:\n    ├── X regular \n    ├── Y regular \n    └── Z stretched\n```\n" function WENO(FT::DataType = Float64; order = 5, grid = nothing, bounds = nothing)
        #= none:96 =#
        #= none:101 =#
        if !(grid isa Nothing)
            #= none:102 =#
            FT = eltype(grid)
        end
        #= none:105 =#
        mod(order, 2) == 0 && throw(ArgumentError("WENO reconstruction scheme is defined only for odd orders"))
        #= none:107 =#
        if order < 3
            #= none:109 =#
            return UpwindBiased(FT; order = 1)
        else
            #= none:111 =#
            N = Int((order + 1) ÷ 2)
            #= none:113 =#
            weno_coefficients = compute_reconstruction_coefficients(grid, FT, :WENO; order = N)
            #= none:114 =#
            advecting_velocity_scheme = Centered(FT; grid, order = order - 1)
            #= none:115 =#
            buffer_scheme = WENO(FT; grid, order = order - 2, bounds)
        end
        #= none:118 =#
        return WENO{N, FT}(weno_coefficients..., bounds, buffer_scheme, advecting_velocity_scheme)
    end
#= none:121 =#
WENO(grid, FT::DataType = Float64; kwargs...) = begin
        #= none:121 =#
        WENO(FT; grid, kwargs...)
    end
#= none:124 =#
WENOThirdOrder(grid = nothing, FT::DataType = Float64; kwargs...) = begin
        #= none:124 =#
        WENO(grid, FT; order = 3, kwargs...)
    end
#= none:125 =#
WENOFifthOrder(grid = nothing, FT::DataType = Float64; kwargs...) = begin
        #= none:125 =#
        WENO(grid, FT; order = 5, kwargs...)
    end
#= none:128 =#
const PositiveWENO = WENO{<:Any, <:Any, <:Any, <:Any, <:Any, <:Tuple}
#= none:130 =#
(Base.summary(a::WENO{N}) where N) = begin
        #= none:130 =#
        string("WENO reconstruction order ", N * 2 - 1)
    end
#= none:132 =#
(Base.show(io::IO, a::WENO{N, FT, RX, RY, RZ, PP}) where {N, FT, RX, RY, RZ, PP}) = begin
        #= none:132 =#
        print(io, summary(a), " \n", if a.bounds isa Nothing
                ""
            else
                " Bounds : \n    └── $(a.bounds) \n"
            end, " Boundary scheme: ", "\n", "    └── ", summary(a.buffer_scheme), "\n", " Symmetric scheme: ", "\n", "    └── ", summary(a.advecting_velocity_scheme), "\n", " Directions:", "\n", "    ├── X $(if RX == Nothing
    "regular"
else
    "stretched"
end) \n", "    ├── Y $(if RY == Nothing
    "regular"
else
    "stretched"
end) \n", "    └── Z $(if RZ == Nothing
    "regular"
else
    "stretched"
end)")
    end
#= none:144 =#
(Adapt.adapt_structure(to, scheme::WENO{N, FT, XT, YT, ZT, PP}) where {N, FT, XT, YT, ZT, PP}) = begin
        #= none:144 =#
        WENO{N, FT}(Adapt.adapt(to, scheme.coeff_xᶠᵃᵃ), Adapt.adapt(to, scheme.coeff_xᶜᵃᵃ), Adapt.adapt(to, scheme.coeff_yᵃᶠᵃ), Adapt.adapt(to, scheme.coeff_yᵃᶜᵃ), Adapt.adapt(to, scheme.coeff_zᵃᵃᶠ), Adapt.adapt(to, scheme.coeff_zᵃᵃᶜ), Adapt.adapt(to, scheme.bounds), Adapt.adapt(to, scheme.buffer_scheme), Adapt.adapt(to, scheme.advecting_velocity_scheme))
    end
#= none:152 =#
(on_architecture(to, scheme::WENO{N, FT, XT, YT, ZT, PP}) where {N, FT, XT, YT, ZT, PP}) = begin
        #= none:152 =#
        WENO{N, FT}(on_architecture(to, scheme.coeff_xᶠᵃᵃ), on_architecture(to, scheme.coeff_xᶜᵃᵃ), on_architecture(to, scheme.coeff_yᵃᶠᵃ), on_architecture(to, scheme.coeff_yᵃᶜᵃ), on_architecture(to, scheme.coeff_zᵃᵃᶠ), on_architecture(to, scheme.coeff_zᵃᵃᶜ), on_architecture(to, scheme.bounds), on_architecture(to, scheme.buffer_scheme), on_architecture(to, scheme.advecting_velocity_scheme))
    end
#= none:161 =#
#= none:161 =# @inline retrieve_coeff(scheme::WENO, r, ::Val{1}, i, ::Type{Face}) = begin
            #= none:161 =#
            #= none:161 =# @inbounds (scheme.coeff_xᶠᵃᵃ[r + 2])[i]
        end
#= none:162 =#
#= none:162 =# @inline retrieve_coeff(scheme::WENO, r, ::Val{1}, i, ::Type{Center}) = begin
            #= none:162 =#
            #= none:162 =# @inbounds (scheme.coeff_xᶜᵃᵃ[r + 2])[i]
        end
#= none:163 =#
#= none:163 =# @inline retrieve_coeff(scheme::WENO, r, ::Val{2}, i, ::Type{Face}) = begin
            #= none:163 =#
            #= none:163 =# @inbounds (scheme.coeff_yᵃᶠᵃ[r + 2])[i]
        end
#= none:164 =#
#= none:164 =# @inline retrieve_coeff(scheme::WENO, r, ::Val{2}, i, ::Type{Center}) = begin
            #= none:164 =#
            #= none:164 =# @inbounds (scheme.coeff_yᵃᶜᵃ[r + 2])[i]
        end
#= none:165 =#
#= none:165 =# @inline retrieve_coeff(scheme::WENO, r, ::Val{3}, i, ::Type{Face}) = begin
            #= none:165 =#
            #= none:165 =# @inbounds (scheme.coeff_zᵃᵃᶠ[r + 2])[i]
        end
#= none:166 =#
#= none:166 =# @inline retrieve_coeff(scheme::WENO, r, ::Val{3}, i, ::Type{Center}) = begin
            #= none:166 =#
            #= none:166 =# @inbounds (scheme.coeff_zᵃᵃᶜ[r + 2])[i]
        end