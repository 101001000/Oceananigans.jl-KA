
#= none:1 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: VerticalVorticityField, VectorInvariant
#= none:3 =#
#= none:3 =# @testset "VerticalVorticityField with HydrostaticFreeSurfaceModel" begin
        #= none:5 =#
        for arch = archs
            #= none:6 =#
            #= none:6 =# @testset "VerticalVorticityField with HydrostaticFreeSurfaceModel [$(arch)]" begin
                    #= none:7 =#
                    #= none:7 =# @info "  Testing VerticalVorticityField with HydrostaticFreeSurfaceModel [$(arch)]..."
                    #= none:9 =#
                    grid = LatitudeLongitudeGrid(arch, size = (3, 3, 3), longitude = (0, 60), latitude = (15, 75), z = (-1, 0))
                    #= none:14 =#
                    model = HydrostaticFreeSurfaceModel(; grid, momentum_advection = VectorInvariant())
                    #= none:16 =#
                    ψᵢ(λ, φ, z) = begin
                            #= none:16 =#
                            rand()
                        end
                    #= none:17 =#
                    set!(model, u = ψᵢ, v = ψᵢ)
                    #= none:19 =#
                    ζ = VerticalVorticityField(model)
                    #= none:21 =#
                    compute!(ζ)
                    #= none:23 =#
                    #= none:23 =# @test all(isfinite.(ζ.data))
                end
            #= none:25 =#
        end
    end