
#= none:1 =#
using Oceananigans.Utils: prettysummary
#= none:3 =#
#= none:3 =# Core.@doc "    struct FPlane{FT} <: AbstractRotation\n\nA parameter object for constant rotation around a vertical axis.\n" struct FPlane{FT} <: AbstractRotation
        #= none:9 =#
        f::FT
    end
#= none:12 =#
#= none:12 =# Core.@doc "    FPlane([FT=Float64;] f=nothing, rotation_rate=Ω_Earth, latitude=nothing)\n\nReturn a parameter object for constant rotation at the angular frequency\n`f/2`, and therefore with background vorticity `f`, around a vertical axis.\nIf `f` is not specified, it is calculated from `rotation_rate` and\n`latitude` (in degrees) according to the relation `f = 2 * rotation_rate * sind(latitude)`.\n\nBy default, `rotation_rate` is assumed to be Earth's.\n\nAlso called `FPlane`, after the \"f-plane\" approximation for the local effect of\na planet's rotation in a planar coordinate system tangent to the planet's surface.\n" function FPlane(FT::DataType = Float64; f = nothing, rotation_rate = Ω_Earth, latitude = nothing)
        #= none:25 =#
        #= none:27 =#
        use_f = !(isnothing(f))
        #= none:28 =#
        use_planet_parameters = !(isnothing(latitude))
        #= none:30 =#
        if !(xor(use_f, use_planet_parameters))
            #= none:31 =#
            throw(ArgumentError("Either both keywords rotation_rate and latitude must be " * "specified, *or* only f must be specified."))
        end
        #= none:35 =#
        if use_f
            #= none:36 =#
            return FPlane{FT}(f)
        elseif #= none:37 =# use_planet_parameters
            #= none:38 =#
            return FPlane{FT}((2rotation_rate) * sind(latitude))
        end
    end
#= none:42 =#
#= none:42 =# @inline fᶠᶠᵃ(i, j, k, grid, coriolis::FPlane) = begin
            #= none:42 =#
            coriolis.f
        end
#= none:44 =#
#= none:44 =# @inline x_f_cross_U(i, j, k, grid, coriolis::FPlane, U) = begin
            #= none:44 =#
            -(coriolis.f) * ℑxyᶠᶜᵃ(i, j, k, grid, U[2])
        end
#= none:45 =#
#= none:45 =# @inline y_f_cross_U(i, j, k, grid, coriolis::FPlane, U) = begin
            #= none:45 =#
            coriolis.f * ℑxyᶜᶠᵃ(i, j, k, grid, U[1])
        end
#= none:46 =#
#= none:46 =# @inline z_f_cross_U(i, j, k, grid, coriolis::FPlane, U) = begin
            #= none:46 =#
            zero(grid)
        end
#= none:48 =#
function Base.summary(fplane::FPlane{FT}) where FT
    #= none:48 =#
    #= none:49 =#
    fstr = prettysummary(fplane.f)
    #= none:50 =#
    return "FPlane{$(FT)}(f=$(fstr))"
end
#= none:53 =#
Base.show(io::IO, fplane::FPlane) = begin
        #= none:53 =#
        print(io, summary(fplane))
    end