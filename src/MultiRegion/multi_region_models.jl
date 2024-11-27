
#= none:1 =#
using Oceananigans.Models: AbstractModel
#= none:2 =#
using Oceananigans.Advection: WENO, VectorInvariant
#= none:3 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: AbstractFreeSurface
#= none:4 =#
using Oceananigans.TimeSteppers: AbstractTimeStepper, QuasiAdamsBashforth2TimeStepper
#= none:5 =#
using Oceananigans.Models: PrescribedVelocityFields
#= none:6 =#
using Oceananigans.TurbulenceClosures: VerticallyImplicitTimeDiscretization
#= none:7 =#
using Oceananigans.Advection: AbstractAdvectionScheme
#= none:8 =#
using Oceananigans.Advection: OnlySelfUpwinding, CrossAndSelfUpwinding
#= none:9 =#
using Oceananigans.ImmersedBoundaries: GridFittedBottom, PartialCellBottom, GridFittedBoundary
#= none:10 =#
using Oceananigans.Solvers: ConjugateGradientSolver
#= none:12 =#
import Oceananigans.Advection: WENO, cell_advection_timescale, adapt_advection_order
#= none:13 =#
import Oceananigans.Models.HydrostaticFreeSurfaceModels: build_implicit_step_solver, validate_tracer_advection
#= none:14 =#
import Oceananigans.TurbulenceClosures: implicit_diffusion_solver
#= none:16 =#
const MultiRegionModel = HydrostaticFreeSurfaceModel{<:Any, <:Any, <:AbstractArchitecture, <:Any, <:MultiRegionGrids}
#= none:18 =#
function adapt_advection_order(advection::MultiRegionObject, grid::MultiRegionGrids)
    #= none:18 =#
    #= none:19 =#
    #= none:19 =# @apply_regionally new_advection = adapt_advection_order(advection, grid)
    #= none:20 =#
    return new_advection
end
#= none:24 =#
function getregionalproperties(T, inner = true)
    #= none:24 =#
    #= none:25 =#
    type = getglobal(#= none:25 =# @__MODULE__(), T)
    #= none:26 =#
    names = fieldnames(type)
    #= none:27 =#
    args = Vector(undef, length(names))
    #= none:28 =#
    for (n, name) = enumerate(names)
        #= none:29 =#
        args[n] = if inner
                #= line 0 =#
                :(_getregion(t.$(name), r))
            else
                #= line 0 =#
                :(getregion(t.$(name), r))
            end
        #= none:30 =#
    end
    #= none:31 =#
    return args
end
#= none:34 =#
Types = (:HydrostaticFreeSurfaceModel, :ImplicitFreeSurface, :ExplicitFreeSurface, :QuasiAdamsBashforth2TimeStepper, :SplitExplicitAuxiliaryFields, :SplitExplicitState, :SplitExplicitFreeSurface, :PrescribedVelocityFields, :ConjugateGradientSolver, :CrossAndSelfUpwinding, :OnlySelfUpwinding, :GridFittedBoundary, :GridFittedBottom, :PartialCellBottom)
#= none:49 =#
for T = Types
    #= none:50 =#
    #= none:50 =# @eval begin
            #= none:53 =#
            #= none:53 =# @inline getregion(t::$T, r) = begin
                        #= none:53 =#
                        $T($(getregionalproperties(T, true)...))
                    end
            #= none:54 =#
            #= none:54 =# @inline _getregion(t::$T, r) = begin
                        #= none:54 =#
                        $T($(getregionalproperties(T, false)...))
                    end
        end
    #= none:56 =#
end
#= none:58 =#
#= none:58 =# @inline isregional(pv::PrescribedVelocityFields) = begin
            #= none:58 =#
            (isregional(pv.u) | isregional(pv.v)) | isregional(pv.w)
        end
#= none:59 =#
#= none:59 =# @inline devices(pv::PrescribedVelocityFields) = begin
            #= none:59 =#
            devices(pv[findfirst(isregional, (pv.u, pv.v, pv.w))])
        end
#= none:61 =#
validate_tracer_advection(tracer_advection::MultiRegionObject, grid::MultiRegionGrids) = begin
        #= none:61 =#
        (tracer_advection, NamedTuple())
    end
#= none:63 =#
#= none:63 =# @inline isregional(mrm::MultiRegionModel) = begin
            #= none:63 =#
            true
        end
#= none:64 =#
#= none:64 =# @inline devices(mrm::MultiRegionModel) = begin
            #= none:64 =#
            devices(mrm.grid)
        end
#= none:65 =#
#= none:65 =# @inline getdevice(mrm::MultiRegionModel, d) = begin
            #= none:65 =#
            getdevice(mrm.grid, d)
        end
#= none:67 =#
implicit_diffusion_solver(time_discretization::VerticallyImplicitTimeDiscretization, mrg::MultiRegionGrid) = begin
        #= none:67 =#
        construct_regionally(implicit_diffusion_solver, time_discretization, mrg)
    end
#= none:70 =#
WENO(mrg::MultiRegionGrid, args...; kwargs...) = begin
        #= none:70 =#
        construct_regionally(WENO, mrg, args...; kwargs...)
    end
#= none:72 =#
#= none:72 =# @inline (getregion(t::VectorInvariant{N, FT, Z, ZS, V, K, D, U, M}, r) where {N, FT, Z, ZS, V, K, D, U, M}) = begin
            #= none:72 =#
            VectorInvariant{N, FT, M}(_getregion(t.vorticity_scheme, r), _getregion(t.vorticity_stencil, r), _getregion(t.vertical_scheme, r), _getregion(t.kinetic_energy_gradient_scheme, r), _getregion(t.divergence_scheme, r), _getregion(t.upwinding, r))
        end
#= none:80 =#
#= none:80 =# @inline (_getregion(t::VectorInvariant{N, FT, Z, ZS, V, K, D, U, M}, r) where {N, FT, Z, ZS, V, K, D, U, M}) = begin
            #= none:80 =#
            VectorInvariant{N, FT, M}(getregion(t.vorticity_scheme, r), getregion(t.vorticity_stencil, r), getregion(t.vertical_scheme, r), getregion(t.kinetic_energy_gradient_scheme, r), getregion(t.divergence_scheme, r), getregion(t.upwinding, r))
        end
#= none:88 =#
function cell_advection_timescale(grid::MultiRegionGrids, velocities)
    #= none:88 =#
    #= none:89 =#
    Δt = construct_regionally(cell_advection_timescale, grid, velocities)
    #= none:90 =#
    return minimum(Δt.regional_objects)
end