
#= none:1 =#
using Oceananigans.Grids: ZDirection, validate_unit_vector
#= none:3 =#
#= none:3 =# Core.@doc "    struct ConstantCartesianCoriolis{FT} <: AbstractRotation\n\nA Coriolis implementation that accounts for the locally vertical and possibly both local horizontal\ncomponents of a constant rotation vector. This is a more general implementation of [`FPlane`](@ref),\nwhich only accounts for the locally vertical component.\n" struct ConstantCartesianCoriolis{FT} <: AbstractRotation
        #= none:11 =#
        fx::FT
        #= none:12 =#
        fy::FT
        #= none:13 =#
        fz::FT
    end
#= none:16 =#
#= none:16 =# Core.@doc "    ConstantCartesianCoriolis([FT=Float64;] fx=nothing, fy=nothing, fz=nothing,\n                                            f=nothing, rotation_axis=ZDirection(), \n                                            rotation_rate=Ω_Earth, latitude=nothing)\n\nReturn a parameter object for a constant rotation decomposed into the `x`, `y`, and `z` directions.\nIn oceanography the components `x`, `y`, `z` correspond to the directions east, north, and up. This\nconstant rotation can be specified in three different ways:\n\n- Specifying all components `fx`, `fy` and `fz` directly.\n- Specifying the Coriolis parameter `f` and (optionally) a `rotation_axis` (which defaults to the\n  `z` direction if not specified).\n- Specifying `latitude` (in degrees) and (optionally) a `rotation_rate` in radians per second\n  (which defaults to Earth's rotation rate).\n" function ConstantCartesianCoriolis(FT = Float64; fx = nothing, fy = nothing, fz = nothing, f = nothing, rotation_axis = ZDirection(), rotation_rate = Ω_Earth, latitude = nothing)
        #= none:31 =#
        #= none:34 =#
        if !(isnothing(latitude))
            #= none:35 =#
            all(isnothing.((fx, fy, fz, f))) || throw(ArgumentError("Only `rotation_rate` can be specified when using `latitude`."))
            #= none:37 =#
            fx = 0
            #= none:38 =#
            fy = (2rotation_rate) * cosd(latitude)
            #= none:39 =#
            fz = (2rotation_rate) * sind(latitude)
        elseif #= none:41 =# !(isnothing(f))
            #= none:42 =#
            all(isnothing.((fx, fy, fz, latitude))) || throw(ArgumentError("Only `rotation_axis` can be specified when using `f`."))
            #= none:44 =#
            rotation_axis = validate_unit_vector(rotation_axis, FT)
            #= none:45 =#
            if rotation_axis isa ZDirection
                #= none:46 =#
                fx = (fy = 0)
                #= none:47 =#
                fz = f
            else
                #= none:49 =#
                fx = f * rotation_axis[1]
                #= none:50 =#
                fy = f * rotation_axis[2]
                #= none:51 =#
                fz = f * rotation_axis[3]
            end
        elseif #= none:54 =# all((!isnothing).((fx, fy, fz)))
            #= none:55 =#
            all(isnothing.((latitude, f))) || throw(ArgumentError("Only `fx`, `fy` and `fz` can be specified when setting each component directly."))
        else
            #= none:58 =#
            throw(ArgumentError("Either (i) `latitude`, or (ii) `f`, or (iii) `fx`, `fy` and `fz` must be specified."))
        end
        #= none:62 =#
        return ConstantCartesianCoriolis{FT}(fx, fy, fz)
    end
#= none:68 =#
#= none:68 =# @inline fʸw_minus_fᶻv(i, j, k, grid, coriolis, U) = begin
            #= none:68 =#
            coriolis.fy * ℑzᵃᵃᶜ(i, j, k, grid, U.w) - coriolis.fz * ℑyᵃᶜᵃ(i, j, k, grid, U.v)
        end
#= none:71 =#
#= none:71 =# @inline fᶻu_minus_fˣw(i, j, k, grid, coriolis, U) = begin
            #= none:71 =#
            coriolis.fz * ℑxᶜᵃᵃ(i, j, k, grid, U.u) - coriolis.fx * ℑzᵃᵃᶜ(i, j, k, grid, U.w)
        end
#= none:74 =#
#= none:74 =# @inline fˣv_minus_fʸu(i, j, k, grid, coriolis, U) = begin
            #= none:74 =#
            coriolis.fx * ℑyᵃᶜᵃ(i, j, k, grid, U.v) - coriolis.fy * ℑxᶜᵃᵃ(i, j, k, grid, U.u)
        end
#= none:77 =#
#= none:77 =# @inline x_f_cross_U(i, j, k, grid, coriolis::ConstantCartesianCoriolis, U) = begin
            #= none:77 =#
            ℑxᶠᵃᵃ(i, j, k, grid, fʸw_minus_fᶻv, coriolis, U)
        end
#= none:78 =#
#= none:78 =# @inline y_f_cross_U(i, j, k, grid, coriolis::ConstantCartesianCoriolis, U) = begin
            #= none:78 =#
            ℑyᵃᶠᵃ(i, j, k, grid, fᶻu_minus_fˣw, coriolis, U)
        end
#= none:79 =#
#= none:79 =# @inline z_f_cross_U(i, j, k, grid, coriolis::ConstantCartesianCoriolis, U) = begin
            #= none:79 =#
            ℑzᵃᵃᶠ(i, j, k, grid, fˣv_minus_fʸu, coriolis, U)
        end
#= none:81 =#
(Base.show(io::IO, f_plane::ConstantCartesianCoriolis{FT}) where FT) = begin
        #= none:81 =#
        print(io, "ConstantCartesianCoriolis{$(FT)}: ", #= none:82 =# @sprintf("fx = %.2e, fy = %.2e, fz = %.2e", f_plane.fx, f_plane.fy, f_plane.fz))
    end