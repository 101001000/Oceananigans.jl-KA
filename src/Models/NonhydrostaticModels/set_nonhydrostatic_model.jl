
#= none:1 =#
using Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:2 =#
using Oceananigans.TimeSteppers: update_state!, calculate_pressure_correction!, pressure_correct_velocities!
#= none:4 =#
import Oceananigans.Fields: set!
#= none:6 =#
#= none:6 =# Core.@doc "    set!(model::NonhydrostaticModel; enforce_incompressibility=true, kwargs...)\n\nSet velocity and tracer fields of `model`. The keyword arguments\n`kwargs...` take the form `name=data`, where `name` refers to one of the\nfields of `model.velocities` or `model.tracers`, and the `data` may be an array,\na function with arguments `(x, y, z)`, or any data type for which a\n`set!(ϕ::AbstractField, data)` function exists.\n\nExample\n=======\n```julia\nmodel = NonhydrostaticModel(grid=RectilinearGrid(size=(32, 32, 32), length=(1, 1, 1))\n\n# Set u to a parabolic function of z, v to random numbers damped\n# at top and bottom, and T to some silly array of half zeros,\n# half random numbers.\n\nu₀(x, y, z) = z / model.grid.Lz * (1 + z / model.grid.Lz)\nv₀(x, y, z) = 1e-3 * rand() * u₀(x, y, z)\n\nT₀ = rand(size(model.grid)...)\nT₀[T₀ .< 0.5] .= 0\n\nset!(model, u=u₀, v=v₀, T=T₀)\n```\n" function set!(model::NonhydrostaticModel; enforce_incompressibility = true, kwargs...)
        #= none:33 =#
        #= none:34 =#
        for (fldname, value) = kwargs
            #= none:35 =#
            if fldname ∈ propertynames(model.velocities)
                #= none:36 =#
                ϕ = getproperty(model.velocities, fldname)
            elseif #= none:37 =# fldname ∈ propertynames(model.tracers)
                #= none:38 =#
                ϕ = getproperty(model.tracers, fldname)
            else
                #= none:40 =#
                throw(ArgumentError("name $(fldname) not found in model.velocities or model.tracers."))
            end
            #= none:42 =#
            set!(ϕ, value)
            #= none:44 =#
            fill_halo_regions!(ϕ, model.clock, fields(model))
            #= none:45 =#
        end
        #= none:48 =#
        foreach(mask_immersed_field!, model.tracers)
        #= none:49 =#
        foreach(mask_immersed_field!, model.velocities)
        #= none:50 =#
        update_state!(model; compute_tendencies = false)
        #= none:52 =#
        if enforce_incompressibility
            #= none:53 =#
            FT = eltype(model.grid)
            #= none:54 =#
            calculate_pressure_correction!(model, one(FT))
            #= none:55 =#
            pressure_correct_velocities!(model, one(FT))
            #= none:56 =#
            update_state!(model; compute_tendencies = false)
        end
        #= none:59 =#
        return nothing
    end