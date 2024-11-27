
#= none:1 =#
using Oceananigans.Utils: prettytime
#= none:3 =#
#= none:3 =# Core.@doc "Show the innards of a `Model` in the REPL." function Base.show(io::IO, model::ShallowWaterModel{G, A, T}) where {G, A, T}
        #= none:4 =#
        #= none:5 =#
        TS = nameof(typeof(model.timestepper))
        #= none:7 =#
        print(io, "ShallowWaterModel{$(Base.typename(A)), $(T)}", "(time = $(prettytime(model.clock.time)), iteration = $(model.clock.iteration)) \n", "├── grid: $(summary(model.grid))\n", "├── timestepper: ", TS, "\n")
        #= none:12 =#
        if model.advection !== nothing
            #= none:13 =#
            print(io, "├── advection scheme: ", "\n")
            #= none:14 =#
            names = keys(model.advection)
            #= none:15 =#
            for name = names[1:end - 1]
                #= none:16 =#
                print(io, "│   ├── " * string(name) * ": " * summary(model.advection[name]), "\n")
                #= none:17 =#
            end
            #= none:18 =#
            name = names[end]
            #= none:19 =#
            print(io, "│   └── " * string(name) * ": " * summary(model.advection[name]), "\n")
        end
        #= none:22 =#
        print(io, "├── tracers: $(tracernames(model.tracers))\n", "└── coriolis: $(typeof(model.coriolis))")
    end