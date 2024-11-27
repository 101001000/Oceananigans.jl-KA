
#= none:1 =#
using Oceananigans: TurbulenceClosures
#= none:2 =#
using Oceananigans.Grids: prettysummary, architecture
#= none:4 =#
mutable struct TimeStepWizard{FT, C, D}
    #= none:5 =#
    cfl::FT
    #= none:6 =#
    diffusive_cfl::FT
    #= none:7 =#
    max_change::FT
    #= none:8 =#
    min_change::FT
    #= none:9 =#
    max_Δt::FT
    #= none:10 =#
    min_Δt::FT
    #= none:11 =#
    cell_advection_timescale::C
    #= none:12 =#
    cell_diffusion_timescale::D
end
#= none:15 =#
infinite_diffusion_timescale(args...) = begin
        #= none:15 =#
        Inf
    end
#= none:17 =#
Base.summary(wizard::TimeStepWizard) = begin
        #= none:17 =#
        string("TimeStepWizard(", "cfl=", prettysummary(wizard.cfl), ", max_Δt=", prettysummary(wizard.max_Δt), ", min_Δt=", prettysummary(wizard.min_Δt), ")")
    end
#= none:22 =#
#= none:22 =# Core.@doc "    TimeStepWizard([FT=Float64;]\n                   cfl = 0.2,\n                   diffusive_cfl = Inf,\n                   max_change = 1.1,\n                   min_change = 0.5,\n                   max_Δt = Inf,\n                   min_Δt = 0.0,\n                   cell_advection_timescale = cell_advection_timescale,\n                   cell_diffusion_timescale = infinite_diffusion_timescale)\n\nCallback function that adjusts the simulation time step to meet specified target values \nfor advective and diffusive Courant-Friedrichs-Lewy (CFL) numbers (`cfl` and `diffusive_cfl`), \nsubject to the limits\n\n```julia\nmax(min_Δt, min_change * last_Δt) ≤ new_Δt ≤ min(max_Δt, max_change * last_Δt)\n```\n\nwhere `new_Δt` is the new time step calculated by the `TimeStepWizard`.\n\nFor more information on the CFL number, see its [wikipedia entry]\n(https://en.wikipedia.org/wiki/Courant%E2%80%93Friedrichs%E2%80%93Lewy_condition).\n\nExample\n=======\n\nTo use `TimeStepWizard`, insert it into a [`Callback`](@ref) and then add the `Callback` to a `Simulation`:\n\n```julia\njulia> simulation = Simulation(model, Δt=0.9, stop_iteration=100)\n\njulia> wizard = TimeStepWizard(cfl=0.2)\n\njulia> simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(4))\n```\n\nThen when `run!(simulation)` is invoked, the time-step `simulation.Δt` will be updated every\n4 iterations.\n\n(Note that the name `:wizard` is unimportant.)\n" function TimeStepWizard(FT = Float64; cfl = 0.2, diffusive_cfl = Inf, max_change = 1.1, min_change = 0.5, max_Δt = Inf, min_Δt = 0.0, cell_advection_timescale = cell_advection_timescale, cell_diffusion_timescale = infinite_diffusion_timescale)
        #= none:64 =#
        #= none:75 =#
        min_change ≥ 1 && throw(ArgumentError("min_change must be < 1. You provided min_change = $(min_change)."))
        #= none:77 =#
        max_change ≤ 1 && throw(ArgumentError("max_change must be > 1. You provided max_change = $(max_change)."))
        #= none:80 =#
        if isfinite(diffusive_cfl) && cell_diffusion_timescale === infinite_diffusion_timescale
            #= none:81 =#
            cell_diffusion_timescale = TurbulenceClosures.cell_diffusion_timescale
        end
        #= none:84 =#
        C = typeof(cell_advection_timescale)
        #= none:85 =#
        D = typeof(cell_diffusion_timescale)
        #= none:87 =#
        return TimeStepWizard{FT, C, D}(cfl, diffusive_cfl, max_change, min_change, max_Δt, min_Δt, cell_advection_timescale, cell_diffusion_timescale)
    end
#= none:91 =#
using Oceananigans.Grids: topology
#= none:92 =#
using Oceananigans.DistributedComputations: all_reduce
#= none:94 =#
#= none:94 =# Core.@doc "     new_time_step(old_Δt, wizard, model)\n\nReturn a new time_step given `model.velocities` and model diffusivites,\nand the parameters of the `TimeStepWizard` `wizard`.\n" function new_time_step(old_Δt, wizard, model)
        #= none:100 =#
        #= none:102 =#
        advective_Δt = wizard.cfl * wizard.cell_advection_timescale(model)
        #= none:103 =#
        diffusive_Δt = wizard.diffusive_cfl * wizard.cell_diffusion_timescale(model)
        #= none:105 =#
        new_Δt = min(advective_Δt, diffusive_Δt)
        #= none:108 =#
        new_Δt = min(wizard.max_change * old_Δt, new_Δt)
        #= none:109 =#
        new_Δt = max(wizard.min_change * old_Δt, new_Δt)
        #= none:110 =#
        new_Δt = clamp(new_Δt, wizard.min_Δt, wizard.max_Δt)
        #= none:111 =#
        new_Δt = all_reduce(min, new_Δt, architecture(model.grid))
        #= none:113 =#
        return new_Δt
    end
#= none:116 =#
(wizard::TimeStepWizard)(simulation) = begin
        #= none:116 =#
        simulation.Δt = new_time_step(simulation.Δt, wizard, simulation.model)
    end
#= none:119 =#
#= none:119 =# Core.@doc "    conjure_time_step_wizard!(simulation, schedule=IterationInterval(5), wizard_kw...)\n\nAdd a `TimeStepWizard` built with `wizard_kw` as a `Callback` to `simulation`,\ncalled on `schedule` which is `IterationInterval(5)` by default.\n" function conjure_time_step_wizard!(simulation, schedule = IterationInterval(10); wizard_kw...)
        #= none:125 =#
        #= none:126 =#
        wizard = TimeStepWizard(; wizard_kw...)
        #= none:127 =#
        simulation.callbacks[:time_step_wizard] = Callback(wizard, schedule)
        #= none:128 =#
        return nothing
    end