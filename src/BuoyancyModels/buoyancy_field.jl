
#= none:1 =#
using Oceananigans.AbstractOperations: KernelFunctionOperation
#= none:2 =#
using Oceananigans.Fields: Field, ZeroField
#= none:4 =#
buoyancy(::Nothing, args...) = begin
        #= none:4 =#
        ZeroField()
    end
#= none:5 =#
buoyancy(::BuoyancyTracer, grid, tracers) = begin
        #= none:5 =#
        tracers.b
    end
#= none:8 =#
buoyancy(model) = begin
        #= none:8 =#
        buoyancy(model.buoyancy, model.grid, model.tracers)
    end
#= none:9 =#
buoyancy(b, grid, tracers) = begin
        #= none:9 =#
        KernelFunctionOperation{Center, Center, Center}(buoyancy_perturbationᶜᶜᶜ, grid, b.model, tracers)
    end
#= none:10 =#
BuoyancyField(model) = begin
        #= none:10 =#
        Field(buoyancy(model))
    end
#= none:12 =#
buoyancy_frequency(b::Buoyancy, grid, tracers) = begin
        #= none:12 =#
        KernelFunctionOperation{Center, Center, Face}(∂z_b, grid, b.model, tracers)
    end
#= none:13 =#
buoyancy_frequency(b, grid, tracers) = begin
        #= none:13 =#
        KernelFunctionOperation{Center, Center, Face}(∂z_b, grid, b, tracers)
    end
#= none:14 =#
buoyancy_frequency(model) = begin
        #= none:14 =#
        buoyancy_frequency(model.buoyancy, model.grid, model.tracers)
    end