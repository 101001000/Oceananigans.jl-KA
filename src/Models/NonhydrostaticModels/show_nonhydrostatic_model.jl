
#= none:1 =#
using Oceananigans.Utils: prettytime, ordered_dict_show, prettykeys
#= none:2 =#
using Oceananigans.TurbulenceClosures: closure_summary
#= none:4 =#
function Base.summary(model::NonhydrostaticModel)
    #= none:4 =#
    #= none:5 =#
    A = nameof(typeof(architecture(model.grid)))
    #= none:6 =#
    G = nameof(typeof(model.grid))
    #= none:7 =#
    return string("NonhydrostaticModel{$(A), $(G)}", "(time = ", prettytime(model.clock.time), ", iteration = ", model.clock.iteration, ")")
end
#= none:11 =#
function Base.show(io::IO, model::NonhydrostaticModel)
    #= none:11 =#
    #= none:12 =#
    TS = nameof(typeof(model.timestepper))
    #= none:13 =#
    tracernames = prettykeys(model.tracers)
    #= none:15 =#
    print(io, summary(model), "\n", "├── grid: ", summary(model.grid), "\n", "├── timestepper: ", TS, "\n", "├── advection scheme: ", summary(model.advection), "\n", "├── tracers: ", tracernames, "\n", "├── closure: ", closure_summary(model.closure), "\n", "├── buoyancy: ", summary(model.buoyancy), "\n")
    #= none:23 =#
    if isnothing(model.particles)
        #= none:24 =#
        print(io, "└── coriolis: ", summary(model.coriolis))
    else
        #= none:26 =#
        particles = model.particles.properties
        #= none:27 =#
        properties = propertynames(particles)
        #= none:28 =#
        print(io, "├── coriolis: ", summary(model.coriolis), "\n")
        #= none:29 =#
        print(io, "└── particles: ", summary(model.particles))
    end
end