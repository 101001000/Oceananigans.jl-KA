
#= none:1 =#
using Oceananigans.AbstractOperations: AbstractOperation, KernelFunctionOperation
#= none:2 =#
using Oceananigans.BuoyancyModels: SeawaterBuoyancy, Zᶜᶜᶜ
#= none:3 =#
using Oceananigans.Fields: field
#= none:4 =#
using Oceananigans.Grids: Center
#= none:5 =#
using SeawaterPolynomials: BoussinesqEquationOfState
#= none:6 =#
import SeawaterPolynomials.ρ
#= none:8 =#
#= none:8 =# Core.@doc "Extend `SeawaterPolynomials.ρ` to compute density for a `KernelFunctionOperation` -\n**note** `eos` must be `BoussinesqEquationOfState` because a reference density is needed for the computation." #= none:10 =# @inline(ρ(i, j, k, grid, eos, T, S, Z) = begin
                #= none:10 =#
                #= none:10 =# @inbounds ρ(T[i, j, k], S[i, j, k], Z[i, j, k], eos)
            end)
#= none:12 =#
#= none:12 =# Core.@doc "Return a `KernelFunctionOperation` to compute the in-situ `seawater_density`." seawater_density(grid, eos, temperature, salinity, geopotential_height) = begin
            #= none:13 =#
            KernelFunctionOperation{Center, Center, Center}(ρ, grid, eos, temperature, salinity, geopotential_height)
        end
#= none:16 =#
const ModelsWithBuoyancy = Union{NonhydrostaticModel, HydrostaticFreeSurfaceModel}
#= none:18 =#
validate_model_eos(eos::BoussinesqEquationOfState) = begin
        #= none:18 =#
        nothing
    end
#= none:19 =#
validate_model_eos(eos) = begin
        #= none:19 =#
        throw(ArgumentError("seawater_density is not defined for $(eos)."))
    end
#= none:22 =#
model_temperature(bf, model) = begin
        #= none:22 =#
        model.tracers.T
    end
#= none:23 =#
model_salinity(bf, model) = begin
        #= none:23 =#
        model.tracers.S
    end
#= none:24 =#
model_geopotential_height(model) = begin
        #= none:24 =#
        KernelFunctionOperation{Center, Center, Center}(Zᶜᶜᶜ, model.grid)
    end
#= none:26 =#
const ConstantTemperatureSB = (SeawaterBuoyancy{FT, EOS, <:Number, <:Nothing} where {FT, EOS})
#= none:27 =#
const ConstantSalinitySB = (SeawaterBuoyancy{FT, EOS, <:Nothing, <:Number} where {FT, EOS})
#= none:29 =#
model_temperature(b::ConstantTemperatureSB, model) = begin
        #= none:29 =#
        b.constant_temperature
    end
#= none:30 =#
model_salinity(b::ConstantSalinitySB, model) = begin
        #= none:30 =#
        b.constant_salinity
    end
#= none:32 =#
#= none:32 =# Core.@doc "    seawater_density(model; temperature, salinity, geopotential_height)\n\nReturn a `KernelFunctionOperation` that computes the in-situ density of seawater\nwith (gridded) `temperature`, `salinity`, and at `geopotential_height`. To compute the\nin-situ density, the 55 term polynomial approximation to the equation of state from\n[Roquet et al. (2015)](https://www.sciencedirect.com/science/article/pii/S1463500315000566?ref=pdf_download&fr=RR-2&rr=813416acba58557b) is used.\nBy default the `seawater_density` extracts the geopotential height from the model to compute\nthe in-situ density. To compute a potential density at some user chosen reference geopotential height,\nset `geopotential_height` to a constant for the density computation,\n\n```julia\ngeopotential_height = 0 # sea-surface height\nσ₀ = seawater_density(model; geopotential_height)\n```\n\n**Note:** `seawater_density` must be passed a `BoussinesqEquationOfState` to compute the\ndensity. See the [relevant documentation](https://clima.github.io/OceananigansDocumentation/dev/model_setup/buoyancy_and_equation_of_state/#Idealized-nonlinear-equations-of-state)\nfor how to set `SeawaterBuoyancy` using a `BoussinesqEquationOfState`.\n\nExample\n=======\n\nCompute a density `Field` using the `KernelFunctionOperation` returned from `seawater_density`\n\n```jldoctest density\njulia> using Oceananigans, SeawaterPolynomials.TEOS10\n\njulia> using Oceananigans.Models: seawater_density\n\njulia> grid = RectilinearGrid(size=100, z=(-1000, 0), topology=(Flat, Flat, Bounded))\n1×1×100 RectilinearGrid{Float64, Flat, Flat, Bounded} on CPU with 0×0×3 halo\n├── Flat x\n├── Flat y\n└── Bounded  z ∈ [-1000.0, 0.0] regularly spaced with Δz=10.0\n\njulia> tracers = (:T, :S)\n(:T, :S)\n\njulia> eos = TEOS10EquationOfState()\nBoussinesqEquationOfState{Float64}:\n    ├── seawater_polynomial: TEOS10SeawaterPolynomial{Float64}\n    └── reference_density: 1020.0\n\njulia> buoyancy = SeawaterBuoyancy(equation_of_state=eos)\nSeawaterBuoyancy{Float64}:\n├── gravitational_acceleration: 9.80665\n└── equation_of_state: BoussinesqEquationOfState{Float64}\n\njulia> model = NonhydrostaticModel(; grid, buoyancy, tracers)\nNonhydrostaticModel{CPU, RectilinearGrid}(time = 0 seconds, iteration = 0)\n├── grid: 1×1×100 RectilinearGrid{Float64, Flat, Flat, Bounded} on CPU with 0×0×3 halo\n├── timestepper: RungeKutta3TimeStepper\n├── advection scheme: Centered reconstruction order 2\n├── tracers: (T, S)\n├── closure: Nothing\n├── buoyancy: SeawaterBuoyancy with g=9.80665 and BoussinesqEquationOfState{Float64} with ĝ = NegativeZDirection()\n└── coriolis: Nothing\n\njulia> set!(model, S = 34.7, T = 0.5)\n\njulia> density_operation = seawater_density(model)\nKernelFunctionOperation at (Center, Center, Center)\n├── grid: 1×1×100 RectilinearGrid{Float64, Flat, Flat, Bounded} on CPU with 0×0×3 halo\n├── kernel_function: ρ (generic function with 3 methods)\n└── arguments: (\"BoussinesqEquationOfState{Float64}\", \"1×1×100 Field{Center, Center, Center} on RectilinearGrid on CPU\", \"1×1×100 Field{Center, Center, Center} on RectilinearGrid on CPU\", \"KernelFunctionOperation at (Center, Center, Center)\")\n\njulia> density_field = Field(density_operation)\n1×1×100 Field{Center, Center, Center} on RectilinearGrid on CPU\n├── grid: 1×1×100 RectilinearGrid{Float64, Flat, Flat, Bounded} on CPU with 0×0×3 halo\n├── boundary conditions: FieldBoundaryConditions\n│   └── west: Nothing, east: Nothing, south: Nothing, north: Nothing, bottom: ZeroFlux, top: ZeroFlux, immersed: ZeroFlux\n├── operand: KernelFunctionOperation at (Center, Center, Center)\n├── status: time=0.0\n└── data: 1×1×106 OffsetArray(::Array{Float64, 3}, 1:1, 1:1, -2:103) with eltype Float64 with indices 1:1×1:1×-2:103\n    └── max=0.0, min=0.0, mean=0.0\n\njulia> compute!(density_field)\n1×1×100 Field{Center, Center, Center} on RectilinearGrid on CPU\n├── grid: 1×1×100 RectilinearGrid{Float64, Flat, Flat, Bounded} on CPU with 0×0×3 halo\n├── boundary conditions: FieldBoundaryConditions\n│   └── west: Nothing, east: Nothing, south: Nothing, north: Nothing, bottom: ZeroFlux, top: ZeroFlux, immersed: ZeroFlux\n├── operand: KernelFunctionOperation at (Center, Center, Center)\n├── status: time=0.0\n└── data: 1×1×106 OffsetArray(::Array{Float64, 3}, 1:1, 1:1, -2:103) with eltype Float64 with indices 1:1×1:1×-2:103\n    └── max=1032.38, min=1027.73, mean=1030.06\n```\n\nValues for `temperature`, `salinity` and `geopotential_height` can be passed to\n`seawater_density` to override the defaults that are obtained from the `model`.\n" function seawater_density(model::ModelsWithBuoyancy; temperature = model_temperature(model.buoyancy.model, model), salinity = model_salinity(model.buoyancy.model, model), geopotential_height = model_geopotential_height(model))
        #= none:123 =#
        #= none:128 =#
        eos = model.buoyancy.model.equation_of_state
        #= none:129 =#
        validate_model_eos(eos)
        #= none:131 =#
        grid = model.grid
        #= none:132 =#
        loc = (Center, Center, Center)
        #= none:133 =#
        temperature = field(loc, temperature, grid)
        #= none:134 =#
        salinity = field(loc, salinity, grid)
        #= none:136 =#
        geopotential_height = if geopotential_height isa AbstractOperation
                geopotential_height
            else
                field(loc, geopotential_height, grid)
            end
        #= none:139 =#
        return seawater_density(grid, eos, temperature, salinity, geopotential_height)
    end