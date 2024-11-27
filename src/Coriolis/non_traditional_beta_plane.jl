
#= none:1 =#
using Oceananigans.Grids: ynode, znode
#= none:3 =#
#= none:3 =# Core.@doc "    struct NonTraditionalBetaPlane{FT} <: AbstractRotation\n\nA Coriolis implementation that accounts for the latitudinal variation of both\nthe locally vertical and the locally horizontal components of the rotation vector.\nThe \"traditional\" approximation in ocean models accounts for only the locally\nvertical component of the rotation vector (see [`BetaPlane`](@ref)).\n\nThis implementation is based off of section 5 of [Dellar2011](@citet) and it conserves\nenergy, angular momentum, and potential vorticity.\n\nReferences\n==========\n\nDellar, P. (2011). Variations on a beta-plane: Derivation of non-traditional\n    beta-plane equations from Hamilton's principle on a sphere. Journal of\n    Fluid Mechanics, 674, 174-195. doi:10.1017/S0022112010006464\n" struct NonTraditionalBetaPlane{FT} <: AbstractRotation
        #= none:22 =#
        fz::FT
        #= none:23 =#
        fy::FT
        #= none:24 =#
        β::FT
        #= none:25 =#
        γ::FT
        #= none:26 =#
        R::FT
    end
#= none:29 =#
#= none:29 =# Core.@doc "    NonTraditionalBetaPlane(FT=Float64;\n                            fz=nothing, fy=nothing, β=nothing, γ=nothing,\n                            rotation_rate=Ω_Earth, latitude=nothing, radius=R_Earth)\n\nThe user may directly specify `fz`, `fy`, `β`, `γ`, and `radius` or the three parameters\n`rotation_rate`, `latitude` (in degrees), and `radius` that specify the rotation rate\nand radius of a planet, and the central latitude (where ``y = 0``) at which the\nnon-traditional `β`-plane approximation is to be made.\n\nIf `fz`, `fy`, `β`, and `γ` are not specified, they are calculated from `rotation_rate`, \n`latitude`, and `radius` according to the relations `fz = 2 * rotation_rate * sind(latitude)`,\n`fy = 2 * rotation_rate * cosd(latitude)`, `β = 2 * rotation_rate * cosd(latitude) / radius`,\nand `γ = - 4 * rotation_rate * sind(latitude) / radius`.\n\nBy default, the `rotation_rate` and planet `radius` is assumed to be Earth's.\n" function NonTraditionalBetaPlane(FT = Float64; fz = nothing, fy = nothing, β = nothing, γ = nothing, rotation_rate = Ω_Earth, latitude = nothing, radius = R_Earth)
        #= none:46 =#
        #= none:50 =#
        (Ω, φ, R) = (rotation_rate, latitude, radius)
        #= none:52 =#
        use_f = !(all(isnothing.((fz, fy, β, γ)))) && isnothing(latitude)
        #= none:53 =#
        use_planet_parameters = !(isnothing(latitude)) && all(isnothing.((fz, fy, β, γ)))
        #= none:55 =#
        if !(xor(use_f, use_planet_parameters))
            #= none:56 =#
            throw(ArgumentError("Either the keywords fz, fy, β, γ, and radius must be specified, " * "*or* all of rotation_rate, latitude, and radius."))
        end
        #= none:60 =#
        if use_planet_parameters
            #= none:61 =#
            fz = (2Ω) * sind(φ)
            #= none:62 =#
            fy = (2Ω) * cosd(φ)
            #= none:63 =#
            β = ((2Ω) * cosd(φ)) / R
            #= none:64 =#
            γ = ((-4Ω) * sind(φ)) / R
        end
        #= none:67 =#
        return NonTraditionalBetaPlane{FT}(fz, fy, β, γ, R)
    end
#= none:70 =#
#= none:70 =# @inline two_Ωʸ(P, y, z) = begin
            #= none:70 =#
            P.fy * (1 - z / P.R) + P.γ * y
        end
#= none:71 =#
#= none:71 =# @inline two_Ωᶻ(P, y, z) = begin
            #= none:71 =#
            P.fz * (1 + (2z) / P.R) + P.β * y
        end
#= none:74 =#
#= none:74 =# @inline two_Ωʸw_minus_two_Ωᶻv(i, j, k, grid, coriolis, U) = begin
            #= none:74 =#
            two_Ωʸ(coriolis, ynode(i, j, k, grid, Center(), Center(), Center()), znode(i, j, k, grid, Center(), Center(), Center())) * ℑzᵃᵃᶜ(i, j, k, grid, U.w) - two_Ωᶻ(coriolis, ynode(i, j, k, grid, Center(), Center(), Center()), znode(i, j, k, grid, Center(), Center(), Center())) * ℑyᵃᶜᵃ(i, j, k, grid, U.v)
        end
#= none:78 =#
#= none:78 =# @inline x_f_cross_U(i, j, k, grid, coriolis::NonTraditionalBetaPlane, U) = begin
            #= none:78 =#
            ℑxᶠᵃᵃ(i, j, k, grid, two_Ωʸw_minus_two_Ωᶻv, coriolis, U)
        end
#= none:81 =#
#= none:81 =# @inline y_f_cross_U(i, j, k, grid, coriolis::NonTraditionalBetaPlane, U) = begin
            #= none:81 =#
            two_Ωᶻ(coriolis, ynode(i, j, k, grid, Center(), Face(), Center()), znode(i, j, k, grid, Center(), Face(), Center())) * ℑxyᶜᶠᵃ(i, j, k, grid, U.u)
        end
#= none:84 =#
#= none:84 =# @inline z_f_cross_U(i, j, k, grid, coriolis::NonTraditionalBetaPlane, U) = begin
            #= none:84 =#
            -(two_Ωʸ(coriolis, ynode(i, j, k, grid, Center(), Center(), Face()), znode(i, j, k, grid, Center(), Center(), Face()))) * ℑxzᶜᵃᶠ(i, j, k, grid, U.u)
        end
#= none:87 =#
(Base.summary(β_plane::NonTraditionalBetaPlane{FT}) where FT) = begin
        #= none:87 =#
        string("NonTraditionalBetaPlane{$(FT)}", #= none:89 =# @sprintf("(fz = %.2e, fy = %.2e, β = %.2e, γ = %.2e, R = %.2e)", β_plane.fz, β_plane.fy, β_plane.β, β_plane.γ, β_plane.R))
    end
#= none:92 =#
Base.show(io::IO, β_plane::NonTraditionalBetaPlane) = begin
        #= none:92 =#
        print(io, summary(β_plane))
    end