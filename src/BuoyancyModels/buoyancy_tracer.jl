
#= none:1 =#
#= none:1 =# Core.@doc "    BuoyancyTracer <: AbstractBuoyancyModel{Nothing}\n\nType indicating that the tracer `b` represents buoyancy.\n" struct BuoyancyTracer <: AbstractBuoyancyModel{Nothing}
        #= none:6 =#
    end
#= none:8 =#
const BuoyancyTracerModel = Buoyancy{<:BuoyancyTracer}
#= none:10 =#
required_tracers(::BuoyancyTracer) = begin
        #= none:10 =#
        (:b,)
    end
#= none:12 =#
#= none:12 =# @inline buoyancy_perturbationᶜᶜᶜ(i, j, k, grid, ::BuoyancyTracer, C) = begin
            #= none:12 =#
            #= none:12 =# @inbounds C.b[i, j, k]
        end
#= none:14 =#
#= none:14 =# @inline ∂x_b(i, j, k, grid, ::BuoyancyTracer, C) = begin
            #= none:14 =#
            ∂xᶠᶜᶜ(i, j, k, grid, C.b)
        end
#= none:15 =#
#= none:15 =# @inline ∂y_b(i, j, k, grid, ::BuoyancyTracer, C) = begin
            #= none:15 =#
            ∂yᶜᶠᶜ(i, j, k, grid, C.b)
        end
#= none:16 =#
#= none:16 =# @inline ∂z_b(i, j, k, grid, ::BuoyancyTracer, C) = begin
            #= none:16 =#
            ∂zᶜᶜᶠ(i, j, k, grid, C.b)
        end
#= none:18 =#
#= none:18 =# @inline top_buoyancy_flux(i, j, grid, ::BuoyancyTracer, top_tracer_bcs, clock, fields) = begin
            #= none:18 =#
            getbc(top_tracer_bcs.b, i, j, grid, clock, fields)
        end
#= none:19 =#
#= none:19 =# @inline bottom_buoyancy_flux(i, j, grid, ::BuoyancyTracer, bottom_tracer_bcs, clock, fields) = begin
            #= none:19 =#
            getbc(bottom_tracer_bcs.b, i, j, grid, clock, fields)
        end