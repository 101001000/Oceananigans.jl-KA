
#= none:1 =#
using Oceananigans.TimeSteppers: update_state!
#= none:3 =#
import Oceananigans.Fields: set!
#= none:5 =#
using Oceananigans.Utils: @apply_regionally, apply_regionally!
#= none:7 =#
#= none:7 =# Core.@doc "    set!(model::HydrostaticFreeSurfaceModel; kwargs...)\n\nSet velocity and tracer fields of `model`. The keyword arguments `kwargs...`\ntake the form `name = data`, where `name` refers to one of the fields of either:\n(i) `model.velocities`, (ii) `model.tracers`, or (iii) `model.free_surface.η`,\nand the `data` may be an array, a function with arguments `(x, y, z)`, or any data type\nfor which a `set!(ϕ::AbstractField, data)` function exists.\n\nExample\n=======\n\n```jldoctest\nusing Oceananigans\ngrid = RectilinearGrid(size=(16, 16, 16), extent=(1, 1, 1))\nmodel = HydrostaticFreeSurfaceModel(; grid, tracers=:T)\n\n# Set u to a parabolic function of z, v to random numbers damped\n# at top and bottom, and T to some silly array of half zeros,\n# half random numbers.\n\nu₀(x, y, z) = z / model.grid.Lz * (1 + z / model.grid.Lz)\nv₀(x, y, z) = 1e-3 * rand() * u₀(x, y, z)\n\nT₀ = rand(size(model.grid)...)\nT₀[T₀ .< 0.5] .= 0\n\nset!(model, u=u₀, v=v₀, T=T₀)\n\nmodel.velocities.u\n\n# output\n\n16×16×16 Field{Face, Center, Center} on RectilinearGrid on CPU\n├── grid: 16×16×16 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 3×3×3 halo\n├── boundary conditions: FieldBoundaryConditions\n│   └── west: Periodic, east: Periodic, south: Periodic, north: Periodic, bottom: ZeroFlux, top: ZeroFlux, immersed: ZeroFlux\n└── data: 22×22×22 OffsetArray(::Array{Float64, 3}, -2:19, -2:19, -2:19) with eltype Float64 with indices -2:19×-2:19×-2:19\n    └── max=-0.0302734, min=-0.249023, mean=-0.166992\n```\n" #= none:48 =# @inline(function set!(model::HydrostaticFreeSurfaceModel; kwargs...)
            #= none:48 =#
            #= none:49 =#
            for (fldname, value) = kwargs
                #= none:50 =#
                if fldname ∈ propertynames(model.velocities)
                    #= none:51 =#
                    ϕ = getproperty(model.velocities, fldname)
                elseif #= none:52 =# fldname ∈ propertynames(model.tracers)
                    #= none:53 =#
                    ϕ = getproperty(model.tracers, fldname)
                elseif #= none:54 =# fldname ∈ propertynames(model.free_surface)
                    #= none:55 =#
                    ϕ = getproperty(model.free_surface, fldname)
                else
                    #= none:57 =#
                    throw(ArgumentError("name $(fldname) not found in model.velocities, model.tracers, or model.free_surface"))
                end
                #= none:60 =#
                #= none:60 =# @apply_regionally set!(ϕ, value)
                #= none:61 =#
            end
            #= none:63 =#
            initialize!(model)
            #= none:64 =#
            update_state!(model; compute_tendencies = false)
            #= none:66 =#
            return nothing
        end)