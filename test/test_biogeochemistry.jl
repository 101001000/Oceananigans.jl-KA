
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using KernelAbstractions
#= none:4 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:6 =#
using Oceananigans.Fields: ConstantField, ZeroField
#= none:7 =#
using Oceananigans.Biogeochemistry: AbstractBiogeochemistry, AbstractContinuousFormBiogeochemistry
#= none:9 =#
import Oceananigans.Biogeochemistry: required_biogeochemical_tracers, required_biogeochemical_auxiliary_fields, biogeochemical_drift_velocity, biogeochemical_auxiliary_fields, update_biogeochemical_state!
#= none:16 =#
import Adapt: adapt_structure
#= none:23 =#
struct MinimalDiscreteBiogeochemistry{FT, I, S} <: AbstractBiogeochemistry
    #= none:24 =#
    growth_rate::FT
    #= none:25 =#
    mortality_rate::FT
    #= none:26 =#
    photosynthetic_active_radiation::I
    #= none:27 =#
    sinking_velocity::S
end
#= none:30 =#
#= none:30 =# @inline function (bgc::MinimalDiscreteBiogeochemistry)(i, j, k, grid, ::Val{:P}, clock, fields)
        #= none:30 =#
        #= none:31 =#
        μ₀ = bgc.growth_rate
        #= none:32 =#
        m = bgc.mortality_rate
        #= none:33 =#
        P = #= none:33 =# @inbounds(fields.P[i, j, k])
        #= none:34 =#
        Iᴾᴬᴿ = #= none:34 =# @inbounds(fields.Iᴾᴬᴿ[i, j, k])
        #= none:35 =#
        return P * (μ₀ * (1 - Iᴾᴬᴿ) - m)
    end
#= none:38 =#
#= none:38 =# @inline function adapt_structure(to, mdb::MinimalDiscreteBiogeochemistry)
        #= none:38 =#
        #= none:39 =#
        return MinimalDiscreteBiogeochemistry(mdb.growth_rate, mdb.mortality_rate, adapt_structure(to, mdb.photosynthetic_active_radiation), mdb.sinking_velocity)
    end
#= none:46 =#
struct MinimalContinuousBiogeochemistry{FT, I, S} <: AbstractContinuousFormBiogeochemistry
    #= none:47 =#
    growth_rate::FT
    #= none:48 =#
    mortality_rate::FT
    #= none:49 =#
    photosynthetic_active_radiation::I
    #= none:50 =#
    sinking_velocity::S
end
#= none:53 =#
#= none:53 =# @inline function (bgc::MinimalContinuousBiogeochemistry)(::Val{:P}, x, y, z, t, P, Iᴾᴬᴿ)
        #= none:53 =#
        #= none:54 =#
        μ₀ = bgc.growth_rate
        #= none:55 =#
        m = bgc.mortality_rate
        #= none:56 =#
        return (μ₀ * (1 - Iᴾᴬᴿ) - m) * P
    end
#= none:59 =#
#= none:59 =# @inline function adapt_structure(to, mcb::MinimalContinuousBiogeochemistry)
        #= none:59 =#
        #= none:60 =#
        return MinimalContinuousBiogeochemistry(mcb.growth_rate, mcb.mortality_rate, adapt_structure(to, mcb.photosynthetic_active_radiation), mcb.sinking_velocity)
    end
#= none:68 =#
const MB = Union{MinimalDiscreteBiogeochemistry, MinimalContinuousBiogeochemistry}
#= none:70 =#
#= none:70 =# @inline required_biogeochemical_tracers(::MB) = begin
            #= none:70 =#
            tuple(:P)
        end
#= none:71 =#
#= none:71 =# @inline required_biogeochemical_auxiliary_fields(::MB) = begin
            #= none:71 =#
            tuple(:Iᴾᴬᴿ)
        end
#= none:72 =#
#= none:72 =# @inline biogeochemical_auxiliary_fields(bgc::MB) = begin
            #= none:72 =#
            (; Iᴾᴬᴿ = bgc.photosynthetic_active_radiation)
        end
#= none:73 =#
#= none:73 =# @inline biogeochemical_drift_velocity(bgc::MB, ::Val{:P}) = begin
            #= none:73 =#
            bgc.sinking_velocity
        end
#= none:77 =#
#= none:77 =# @kernel function integrate_photosynthetic_active_radiation!(Iᴾᴬᴿ, grid)
        #= none:77 =#
        #= none:78 =#
        (i, j, k) = #= none:78 =# @index(Global, NTuple)
        #= none:79 =#
        z = znode(i, j, k, grid, Center(), Center(), Center())
        #= none:80 =#
        #= none:80 =# @inbounds Iᴾᴬᴿ[i, j, k] = exp(z / 5)
    end
#= none:83 =#
#= none:83 =# @inline function update_biogeochemical_state!(bgc::MB, model)
        #= none:83 =#
        #= none:84 =#
        launch!(architecture(model), model.grid, :xyz, integrate_photosynthetic_active_radiation!, bgc.photosynthetic_active_radiation, model.grid)
        #= none:86 =#
        return nothing
    end
#= none:93 =#
function test_biogeochemistry(grid, MinimalBiogeochemistryType, ModelType)
    #= none:93 =#
    #= none:94 =#
    Iᴾᴬᴿ = CenterField(grid)
    #= none:96 =#
    u = ZeroField()
    #= none:97 =#
    v = ZeroField()
    #= none:98 =#
    w = ConstantField(-200 / day)
    #= none:99 =#
    drift_velocities = (; u, v, w)
    #= none:101 =#
    growth_rate = 1 / day
    #= none:102 =#
    mortality_rate = 0.3 / day
    #= none:104 =#
    biogeochemistry = MinimalBiogeochemistryType(growth_rate, mortality_rate, Iᴾᴬᴿ, drift_velocities)
    #= none:109 =#
    if ModelType == HydrostaticFreeSurfaceModel && grid isa OrthogonalSphericalShellGrid
        #= none:110 =#
        model = ModelType(; grid, biogeochemistry, momentum_advection = VectorInvariant())
    else
        #= none:112 =#
        model = ModelType(; grid, biogeochemistry)
    end
    #= none:114 =#
    set!(model, P = 1)
    #= none:116 =#
    #= none:116 =# @test :P in keys(model.tracers)
    #= none:118 =#
    time_step!(model, 1)
    #= none:120 =#
    #= none:120 =# @test #= none:120 =# CUDA.@allowscalar(any(biogeochemistry.photosynthetic_active_radiation .!= 0))
    #= none:121 =#
    #= none:121 =# @test #= none:121 =# CUDA.@allowscalar(any(model.tracers.P .!= 1))
    #= none:123 =#
    return nothing
end
#= none:130 =#
#= none:130 =# @testset "Biogeochemistry" begin
        #= none:131 =#
        #= none:131 =# @info "Testing biogeochemistry setup..."
        #= none:132 =#
        for bgc = (MinimalDiscreteBiogeochemistry, MinimalContinuousBiogeochemistry), model = (NonhydrostaticModel, HydrostaticFreeSurfaceModel), arch = archs, grid = (RectilinearGrid(arch; size = (2, 2, 2), extent = (2, 2, 2)), LatitudeLongitudeGrid(arch; size = (5, 5, 5), longitude = (-180, 180), latitude = (-85, 85), z = (-2, 0)), conformal_cubed_sphere_panel(arch; size = (3, 3, 3), z = (-2, 0)))
            #= none:139 =#
            if !(model == NonhydrostaticModel && (grid isa LatitudeLongitudeGrid) | (grid isa OrthogonalSphericalShellGrid))
                #= none:140 =#
                #= none:140 =# @info "Testing $(bgc) in $(model) on $(grid)..."
                #= none:141 =#
                test_biogeochemistry(grid, bgc, model)
            end
            #= none:143 =#
        end
    end