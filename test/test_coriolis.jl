
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Coriolis: Ω_Earth, ActiveCellEnstrophyConserving
#= none:4 =#
using Oceananigans.Advection: EnergyConserving, EnstrophyConserving
#= none:6 =#
function instantiate_fplane_1(FT)
    #= none:6 =#
    #= none:7 =#
    coriolis = FPlane(FT, f = π)
    #= none:8 =#
    return coriolis.f ≈ FT(π)
end
#= none:11 =#
function instantiate_fplane_2(FT)
    #= none:11 =#
    #= none:12 =#
    coriolis = FPlane(FT, rotation_rate = 2, latitude = 30)
    #= none:13 =#
    return coriolis.f ≈ FT(2)
end
#= none:16 =#
function instantiate_constant_coriolis_1(FT)
    #= none:16 =#
    #= none:17 =#
    coriolis = ConstantCartesianCoriolis(FT, f = 1, rotation_axis = [0, cosd(45), sind(45)])
    #= none:18 =#
    #= none:18 =# @test coriolis.fy ≈ FT(cosd(45))
    #= none:19 =#
    #= none:19 =# @test coriolis.fz ≈ FT(sind(45))
end
#= none:22 =#
function instantiate_constant_coriolis_2(FT)
    #= none:22 =#
    #= none:23 =#
    coriolis = ConstantCartesianCoriolis(FT, f = 10, rotation_axis = [√(1 / 3), √(1 / 3), √(1 / 3)])
    #= none:24 =#
    #= none:24 =# @test coriolis.fx ≈ FT(10 * √(1 / 3))
    #= none:25 =#
    #= none:25 =# @test coriolis.fy ≈ FT(10 * √(1 / 3))
    #= none:26 =#
    #= none:26 =# @test coriolis.fz ≈ FT(10 * √(1 / 3))
end
#= none:29 =#
function instantiate_betaplane_1(FT)
    #= none:29 =#
    #= none:30 =#
    coriolis = BetaPlane(FT, f₀ = π, β = 2π)
    #= none:31 =#
    #= none:31 =# @test coriolis.f₀ ≈ FT(π)
    #= none:32 =#
    #= none:32 =# @test coriolis.β ≈ FT(2π)
end
#= none:35 =#
function instantiate_betaplane_2(FT)
    #= none:35 =#
    #= none:36 =#
    coriolis = BetaPlane(FT, latitude = 70, radius = 2π, rotation_rate = 3π)
    #= none:37 =#
    #= none:37 =# @test coriolis.f₀ ≈ FT((6π) * sind(70))
    #= none:38 =#
    #= none:38 =# @test coriolis.β ≈ FT(((6π) * cosd(70)) / (2π))
end
#= none:41 =#
function instantiate_ntbetaplane_1(FT)
    #= none:41 =#
    #= none:42 =#
    coriolis = NonTraditionalBetaPlane(FT, fz = π, fy = ℯ, β = 1 // 7, γ = 5)
    #= none:43 =#
    #= none:43 =# @test coriolis.fz ≈ FT(π)
    #= none:44 =#
    #= none:44 =# @test coriolis.fy ≈ FT(ℯ)
    #= none:45 =#
    #= none:45 =# @test coriolis.β ≈ FT(1 // 7)
    #= none:46 =#
    #= none:46 =# @test coriolis.γ ≈ FT(5)
end
#= none:49 =#
function instantiate_ntbetaplane_2(FT)
    #= none:49 =#
    #= none:50 =#
    (Ω, φ, R) = (π, 17, ℯ)
    #= none:51 =#
    coriolis = NonTraditionalBetaPlane(FT, rotation_rate = Ω, latitude = φ, radius = R)
    #= none:52 =#
    #= none:52 =# @test coriolis.fz ≈ FT((+2 * Ω) * sind(φ))
    #= none:53 =#
    #= none:53 =# @test coriolis.fy ≈ FT((+2 * Ω) * cosd(φ))
    #= none:54 =#
    #= none:54 =# @test coriolis.β ≈ FT(((+2 * Ω) * cosd(φ)) / R)
    #= none:55 =#
    #= none:55 =# @test coriolis.γ ≈ FT(((-4 * Ω) * sind(φ)) / R)
end
#= none:58 =#
function instantiate_hydrostatic_spherical_coriolis1(FT)
    #= none:58 =#
    #= none:59 =#
    coriolis = HydrostaticSphericalCoriolis(FT, scheme = EnergyConserving())
    #= none:60 =#
    #= none:60 =# @test coriolis.rotation_rate == FT(Ω_Earth)
    #= none:61 =#
    #= none:61 =# @test coriolis.scheme isa EnergyConserving
    #= none:63 =#
    coriolis = HydrostaticSphericalCoriolis(FT, scheme = EnstrophyConserving())
    #= none:64 =#
    #= none:64 =# @test coriolis.rotation_rate == FT(Ω_Earth)
    #= none:65 =#
    #= none:65 =# @test coriolis.scheme isa EnstrophyConserving
end
#= none:68 =#
function instantiate_hydrostatic_spherical_coriolis2(FT)
    #= none:68 =#
    #= none:69 =#
    coriolis = HydrostaticSphericalCoriolis(FT, rotation_rate = π)
    #= none:70 =#
    #= none:70 =# @test coriolis.rotation_rate == FT(π)
    #= none:71 =#
    #= none:71 =# @test coriolis.scheme isa ActiveCellEnstrophyConserving
end
#= none:74 =#
#= none:74 =# @testset "Coriolis" begin
        #= none:75 =#
        #= none:75 =# @info "Testing Coriolis..."
        #= none:77 =#
        #= none:77 =# @testset "Coriolis" begin
                #= none:78 =#
                for FT = float_types
                    #= none:79 =#
                    #= none:79 =# @test instantiate_fplane_1(FT)
                    #= none:80 =#
                    #= none:80 =# @test instantiate_fplane_2(FT)
                    #= none:82 =#
                    instantiate_constant_coriolis_1(FT)
                    #= none:83 =#
                    instantiate_constant_coriolis_2(FT)
                    #= none:84 =#
                    instantiate_betaplane_1(FT)
                    #= none:85 =#
                    instantiate_betaplane_2(FT)
                    #= none:86 =#
                    instantiate_hydrostatic_spherical_coriolis1(FT)
                    #= none:87 =#
                    instantiate_hydrostatic_spherical_coriolis2(FT)
                    #= none:90 =#
                    #= none:90 =# @test_throws ArgumentError FPlane(FT)
                    #= none:91 =#
                    #= none:91 =# @test_throws ArgumentError FPlane(FT, rotation_rate = 7.0e-5)
                    #= none:92 =#
                    #= none:92 =# @test_throws ArgumentError FPlane(FT, f = 1, latitude = 40)
                    #= none:93 =#
                    #= none:93 =# @test_throws ArgumentError FPlane(FT, f = 1, rotation_rate = 7.0e-5, latitude = 40)
                    #= none:96 =#
                    #= none:96 =# @test_throws ArgumentError ConstantCartesianCoriolis(FT, rotation_axis = [0, 1, 1])
                    #= none:97 =#
                    #= none:97 =# @test_throws ArgumentError ConstantCartesianCoriolis(FT, f = 1, latitude = 45)
                    #= none:98 =#
                    #= none:98 =# @test_throws ArgumentError ConstantCartesianCoriolis(FT, fx = 1, latitude = 45)
                    #= none:99 =#
                    #= none:99 =# @test_throws ArgumentError ConstantCartesianCoriolis(FT, fx = 1, f = 1)
                    #= none:102 =#
                    #= none:102 =# @test_throws ArgumentError BetaPlane(FT)
                    #= none:103 =#
                    #= none:103 =# @test_throws ArgumentError BetaPlane(FT, f₀ = 1)
                    #= none:104 =#
                    #= none:104 =# @test_throws ArgumentError BetaPlane(FT, β = 1)
                    #= none:105 =#
                    #= none:105 =# @test_throws ArgumentError BetaPlane(FT, f₀ = 0.0001, β = 1.0e-11, latitude = 70)
                    #= none:108 =#
                    #= none:108 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT)
                    #= none:109 =#
                    #= none:109 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, rotation_rate = 7.0e-5)
                    #= none:110 =#
                    #= none:110 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, fz = 1, latitude = 40)
                    #= none:111 =#
                    #= none:111 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, fz = 1, rotation_rate = 7.0e-5, latitude = 40)
                    #= none:112 =#
                    #= none:112 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, fy = 1, latitude = 40)
                    #= none:113 =#
                    #= none:113 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, fy = 1, rotation_rate = 7.0e-5, latitude = 40)
                    #= none:114 =#
                    #= none:114 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, fz = 1, fy = 2, latitude = 40)
                    #= none:115 =#
                    #= none:115 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, fz = 1, fy = 2, rotation_rate = 7.0e-5, latitude = 40)
                    #= none:116 =#
                    #= none:116 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, fz = 1, fy = 2, β = 3, latitude = 40)
                    #= none:117 =#
                    #= none:117 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, fz = 1, fy = 2, β = 3, rotation_rate = 7.0e-5, latitude = 40)
                    #= none:118 =#
                    #= none:118 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, fz = 1, fy = 2, β = 3, γ = 4, latitude = 40)
                    #= none:119 =#
                    #= none:119 =# @test_throws ArgumentError NonTraditionalBetaPlane(FT, fz = 1, fy = 2, β = 3, γ = 4, rotation_rate = 7.0e-5, latitude = 40)
                    #= none:122 =#
                    ✈ = FPlane(FT, latitude = 45)
                    #= none:123 =#
                    show(✈)
                    #= none:123 =#
                    println()
                    #= none:124 =#
                    #= none:124 =# @test ✈ isa FPlane{FT}
                    #= none:126 =#
                    ✈ = ConstantCartesianCoriolis(FT, f = 0.0001)
                    #= none:127 =#
                    show(✈)
                    #= none:127 =#
                    println()
                    #= none:128 =#
                    #= none:128 =# @test ✈ isa ConstantCartesianCoriolis{FT}
                    #= none:130 =#
                    ✈ = BetaPlane(FT, latitude = 45)
                    #= none:131 =#
                    show(✈)
                    #= none:131 =#
                    println()
                    #= none:132 =#
                    #= none:132 =# @test ✈ isa BetaPlane{FT}
                    #= none:134 =#
                    ✈ = NonTraditionalBetaPlane(FT, latitude = 45)
                    #= none:135 =#
                    show(✈)
                    #= none:135 =#
                    println()
                    #= none:136 =#
                    #= none:136 =# @test ✈ isa NonTraditionalBetaPlane{FT}
                    #= none:137 =#
                end
            end
    end