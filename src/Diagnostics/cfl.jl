
#= none:1 =#
using Oceananigans.Advection: cell_advection_timescale
#= none:2 =#
using Oceananigans.TurbulenceClosures: cell_diffusion_timescale
#= none:4 =#
#= none:4 =# Core.@doc "    struct CFL{D, S}\n\nAn object for computing the Courant-Freidrichs-Lewy (CFL) number.\n" struct CFL{D, S}
        #= none:10 =#
        Δt::D
        #= none:11 =#
        timescale::S
    end
#= none:14 =#
#= none:14 =# Core.@doc "    CFL(Δt [, timescale = Oceananigans.Advection.cell_advection_timescale])\n\nReturn an object for computing the Courant-Freidrichs-Lewy (CFL) number\nassociated with time step `Δt` or `TimeStepWizard` and `timescale`.\n\nSee also [`AdvectiveCFL`](@ref Oceananigans.Diagnostics.AdvectiveCFL)\nand [`DiffusiveCFL`](Oceananigans.Diagnostics.DiffusiveCFL).\n" CFL(Δt) = begin
            #= none:23 =#
            CFL(Δt, cell_advection_timescale)
        end
#= none:25 =#
(c::CFL)(model) = begin
        #= none:25 =#
        c.Δt / c.timescale(model)
    end
#= none:27 =#
#= none:27 =# Core.@doc "    AdvectiveCFL(Δt)\n\nReturn an object for computing the Courant-Freidrichs-Lewy (CFL) number\nassociated with time step `Δt` or `TimeStepWizard` and the time scale\nfor advection across a cell. The advective CFL is, e.g., ``U Δt / Δx``.\n\nExample\n=======\n```jldoctest\njulia> using Oceananigans\n\njulia> model = NonhydrostaticModel(grid = RectilinearGrid(size=(16, 16, 16), extent=(8, 8, 8)));\n\njulia> Δt = 1.0;\n\njulia> cfl = AdvectiveCFL(Δt);\n\njulia> model.velocities.u .= π;\n\njulia> cfl(model)\n6.283185307179586\n```\n" AdvectiveCFL(Δt) = begin
            #= none:51 =#
            CFL(Δt, cell_advection_timescale)
        end
#= none:53 =#
#= none:53 =# Core.@doc "    DiffusiveCFL(Δt)\n\nReturns an object for computing the diffusive Courant-Freidrichs-Lewy (CFL) number\nassociated with time step `Δt` or `TimeStepWizard` and the time scale for diffusion\nacross a cell associated with `model.closure`.  The diffusive CFL, e.g., for viscosity\nis ``ν Δt / Δx²``.\n\nThe maximum diffusive CFL number among viscosity and all tracer diffusivities is\nreturned.\n\nExample\n=======\n```jldoctest\njulia> using Oceananigans\n\njulia> model = NonhydrostaticModel(grid = RectilinearGrid(size=(16, 16, 16), extent=(1, 1, 1)),\n                                   closure = ScalarDiffusivity(; ν = 1e-2));\n\njulia> Δt = 0.1;\n\njulia> dcfl = DiffusiveCFL(Δt);\n\njulia> dcfl(model)\n0.256\n```\n" DiffusiveCFL(Δt) = begin
            #= none:80 =#
            CFL(Δt, cell_diffusion_timescale)
        end