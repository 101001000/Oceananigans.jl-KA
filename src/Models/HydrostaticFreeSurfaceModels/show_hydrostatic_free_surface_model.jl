
#= none:1 =#
using Oceananigans.Utils: prettytime, ordered_dict_show, prettykeys
#= none:2 =#
using Oceananigans.TurbulenceClosures: closure_summary
#= none:4 =#
function Base.summary(model::HydrostaticFreeSurfaceModel)
    #= none:4 =#
    #= none:5 =#
    A = nameof(typeof(architecture(model.grid)))
    #= none:6 =#
    G = nameof(typeof(model.grid))
    #= none:7 =#
    return string("HydrostaticFreeSurfaceModel{$(A), $(G)}", "(time = ", prettytime(model.clock.time), ", iteration = ", model.clock.iteration, ")")
end
#= none:11 =#
function Base.show(io::IO, model::HydrostaticFreeSurfaceModel)
    #= none:11 =#
    #= none:12 =#
    TS = nameof(typeof(model.timestepper))
    #= none:13 =#
    tracernames = prettykeys(model.tracers)
    #= none:15 =#
    print(io, summary(model), "\n", "├── grid: ", summary(model.grid), "\n", "├── timestepper: ", TS, "\n", "├── tracers: ", tracernames, "\n", "├── closure: ", closure_summary(model.closure), "\n", "├── buoyancy: ", summary(model.buoyancy), "\n")
    #= none:22 =#
    if model.free_surface !== nothing
        #= none:23 =#
        print(io, "├── free surface: ", (typeof(model.free_surface)).name.wrapper, " with gravitational acceleration $(model.free_surface.gravitational_acceleration) m s⁻²", "\n")
        #= none:25 =#
        if (typeof(model.free_surface)).name.wrapper == ImplicitFreeSurface
            #= none:26 =#
            print(io, "│   └── solver: ", string(model.free_surface.solver_method), "\n")
        end
        #= none:29 =#
        if (typeof(model.free_surface)).name.wrapper == SplitExplicitFreeSurface
            #= none:30 =#
            print(io, "│   └── substepping: $(summary(model.free_surface.settings.substepping))", "\n")
        end
    end
    #= none:34 =#
    if model.advection !== nothing
        #= none:35 =#
        print(io, "├── advection scheme: ", "\n")
        #= none:36 =#
        names = keys(model.advection)
        #= none:37 =#
        for name = names[1:end - 1]
            #= none:38 =#
            print(io, "│   ├── " * string(name) * ": " * summary(model.advection[name]), "\n")
            #= none:39 =#
        end
        #= none:40 =#
        name = names[end]
        #= none:41 =#
        print(io, "│   └── " * string(name) * ": " * summary(model.advection[name]), "\n")
    end
    #= none:44 =#
    if isnothing(model.particles)
        #= none:45 =#
        print(io, "└── coriolis: $(typeof(model.coriolis))")
    else
        #= none:47 =#
        particles = model.particles.properties
        #= none:48 =#
        properties = propertynames(particles)
        #= none:49 =#
        print(io, "├── coriolis: $(typeof(model.coriolis))\n")
        #= none:50 =#
        print(io, "└── particles: $(length(particles)) Lagrangian particles with $(length(properties)) properties: $(properties)")
    end
end