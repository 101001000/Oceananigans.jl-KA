
#= none:1 =#
#= none:1 =# Core.@doc "    struct BetaPlane{T} <: AbstractRotation\n\nA parameter object for meridionally increasing Coriolis parameter (`f = f₀ + β y`)\nthat accounts for the variation of the locally vertical component of the rotation\nvector with latitude.\n" struct BetaPlane{T} <: AbstractRotation
        #= none:9 =#
        f₀::T
        #= none:10 =#
        β::T
    end
#= none:13 =#
#= none:13 =# Core.@doc "    BetaPlane([T=Float64;] f₀=nothing, β=nothing,\n                           rotation_rate=Ω_Earth, latitude=nothing, radius=R_Earth)\n\nReturn a ``β``-plane Coriolis parameter, ``f = f₀ + β y``. \n\nThe user may specify both `f₀` and `β`, or the three parameters `rotation_rate`, `latitude`\n(in degrees), and `radius` that specify the rotation rate and radius of a planet, and\nthe central latitude (where ``y = 0``) at which the `β`-plane approximation is to be made.\n\nIf `f₀` and `β` are not specified, they are calculated from `rotation_rate`, `latitude`,\nand `radius` according to the relations `f₀ = 2 * rotation_rate * sind(latitude)` and\n`β = 2 * rotation_rate * cosd(latitude) / radius`.\n\nBy default, the `rotation_rate` and planet `radius` are assumed to be Earth's.\n" function BetaPlane(T = Float64; f₀ = nothing, β = nothing, rotation_rate = Ω_Earth, latitude = nothing, radius = R_Earth)
        #= none:29 =#
        #= none:32 =#
        use_f_and_β = !(isnothing(f₀)) && !(isnothing(β))
        #= none:33 =#
        use_planet_parameters = !(isnothing(latitude))
        #= none:35 =#
        if !(xor(use_f_and_β, use_planet_parameters))
            #= none:36 =#
            throw(ArgumentError("Either both keywords f₀ and β must be specified, " * "*or* all of rotation_rate, latitude, and radius."))
        end
        #= none:40 =#
        if use_planet_parameters
            #= none:41 =#
            f₀ = (2rotation_rate) * sind(latitude)
            #= none:42 =#
            β = ((2rotation_rate) * cosd(latitude)) / radius
        end
        #= none:45 =#
        return BetaPlane{T}(f₀, β)
    end
#= none:48 =#
#= none:48 =# @inline fᶠᶠᵃ(i, j, k, grid, coriolis::BetaPlane) = begin
            #= none:48 =#
            coriolis.f₀ + coriolis.β * ynode(i, j, k, grid, Face(), Face(), Center())
        end
#= none:50 =#
#= none:50 =# @inline x_f_cross_U(i, j, k, grid, coriolis::BetaPlane, U) = begin
            #= none:50 =#
            #= none:51 =# @inbounds -((coriolis.f₀ + coriolis.β * ynode(i, j, k, grid, Face(), Center(), Center()))) * ℑxyᶠᶜᵃ(i, j, k, grid, U[2])
        end
#= none:53 =#
#= none:53 =# @inline y_f_cross_U(i, j, k, grid, coriolis::BetaPlane, U) = begin
            #= none:53 =#
            #= none:54 =# @inbounds (coriolis.f₀ + coriolis.β * ynode(i, j, k, grid, Center(), Face(), Center())) * ℑxyᶜᶠᵃ(i, j, k, grid, U[1])
        end
#= none:56 =#
#= none:56 =# @inline z_f_cross_U(i, j, k, grid, coriolis::BetaPlane, U) = begin
            #= none:56 =#
            zero(grid)
        end
#= none:58 =#
function Base.summary(βplane::BetaPlane{FT}) where FT
    #= none:58 =#
    #= none:59 =#
    fstr = prettysummary(βplane.f₀)
    #= none:60 =#
    βstr = prettysummary(βplane.β)
    #= none:61 =#
    return "BetaPlane{$(FT)}(f₀=$(fstr), β=$(βstr))"
end
#= none:64 =#
Base.show(io::IO, βplane::BetaPlane) = begin
        #= none:64 =#
        print(io, summary(βplane))
    end