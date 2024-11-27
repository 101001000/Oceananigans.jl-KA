
#= none:1 =#
using Oceananigans.BoundaryConditions: NoFluxBoundaryCondition
#= none:2 =#
using Oceananigans.Utils: prettysummary
#= none:4 =#
#= none:4 =# Core.@doc "    SeawaterBuoyancy{FT, EOS, T, S} <: AbstractBuoyancyModel{EOS}\n\nBuoyancyModels model for seawater. `T` and `S` are either `nothing` if both\ntemperature and salinity are active, or of type `FT` if temperature\nor salinity are constant, respectively.\n" struct SeawaterBuoyancy{FT, EOS, T, S} <: AbstractBuoyancyModel{EOS}
        #= none:12 =#
        equation_of_state::EOS
        #= none:13 =#
        gravitational_acceleration::FT
        #= none:14 =#
        constant_temperature::T
        #= none:15 =#
        constant_salinity::S
    end
#= none:18 =#
required_tracers(::SeawaterBuoyancy) = begin
        #= none:18 =#
        (:T, :S)
    end
#= none:19 =#
(required_tracers(::SeawaterBuoyancy{FT, EOS, <:Nothing, <:Number}) where {FT, EOS}) = begin
        #= none:19 =#
        (:T,)
    end
#= none:20 =#
(required_tracers(::SeawaterBuoyancy{FT, EOS, <:Number, <:Nothing}) where {FT, EOS}) = begin
        #= none:20 =#
        (:S,)
    end
#= none:22 =#
Base.nameof(::Type{SeawaterBuoyancy}) = begin
        #= none:22 =#
        "SeawaterBuoyancy"
    end
#= none:23 =#
Base.summary(b::SeawaterBuoyancy) = begin
        #= none:23 =#
        string(nameof(typeof(b)), " with g=", prettysummary(b.gravitational_acceleration), " and ", summary(b.equation_of_state))
    end
#= none:26 =#
function Base.show(io::IO, b::SeawaterBuoyancy{FT}) where FT
    #= none:26 =#
    #= none:28 =#
    print(io, nameof(typeof(b)), "{$(FT)}:", "\n", "├── gravitational_acceleration: ", b.gravitational_acceleration, "\n")
    #= none:31 =#
    if !(isnothing(b.constant_temperature))
        #= none:32 =#
        print(io, "├── constant_temperature: ", b.constant_temperature, "\n")
    end
    #= none:35 =#
    if !(isnothing(b.constant_salinity))
        #= none:36 =#
        print(io, "├── constant_salinity: ", b.constant_salinity, "\n")
    end
    #= none:39 =#
    print(io, "└── equation_of_state: ", summary(b.equation_of_state))
end
#= none:42 =#
#= none:42 =# Core.@doc "    SeawaterBuoyancy([FT = Float64;]\n                     gravitational_acceleration = g_Earth,\n                     equation_of_state = LinearEquationOfState(FT),\n                     constant_temperature = nothing,\n                     constant_salinity = nothing)\n\nReturn parameters for a temperature- and salt-stratified seawater buoyancy model\nwith a `gravitational_acceleration` constant (typically called ``g``), and an\n`equation_of_state` that related temperature and salinity (or conservative temperature\nand absolute salinity) to density anomalies and buoyancy.\n\nSetting `constant_temperature` to something that is not `nothing` indicates that buoyancy depends only on salinity.\nFor a nonlinear equation of state, the value provided `constant_temperature` is used as the temperature of the system.\nVice versa, setting `constant_salinity` indicates that buoyancy depends only on temperature.\n\nFor a linear equation of state, the values of `constant_temperature` or `constant_salinity`\nare irrelevant.\n\nExamples\n========\n\nThe \"TEOS10\" equation of state, see https://www.teos-10.org\n\n```jldoctest seawaterbuoyancy\njulia> using SeawaterPolynomials.TEOS10: TEOS10EquationOfState\n\njulia> teos10 = TEOS10EquationOfState()\nBoussinesqEquationOfState{Float64}:\n    ├── seawater_polynomial: TEOS10SeawaterPolynomial{Float64}\n    └── reference_density: 1020.0\n```\n\nBuoyancy that depends on both temperature and salinity\n\n```jldoctest seawaterbuoyancy\njulia> using Oceananigans\n\njulia> buoyancy = SeawaterBuoyancy(equation_of_state=teos10)\nSeawaterBuoyancy{Float64}:\n├── gravitational_acceleration: 9.80665\n└── equation_of_state: BoussinesqEquationOfState{Float64}\n```\n\nBuoyancy that depends only on salinity with temperature held at 20 degrees Celsius\n\n```jldoctest seawaterbuoyancy\njulia> salinity_dependent_buoyancy = SeawaterBuoyancy(equation_of_state=teos10, constant_temperature=20) \nSeawaterBuoyancy{Float64}:\n├── gravitational_acceleration: 9.80665\n├── constant_temperature: 20\n└── equation_of_state: BoussinesqEquationOfState{Float64}\n```\n\nBuoyancy that depends only on temperature with salinity held at 35 psu\n\n```jldoctest seawaterbuoyancy\njulia> temperature_dependent_buoyancy = SeawaterBuoyancy(equation_of_state=teos10, constant_salinity=35)\nSeawaterBuoyancy{Float64}:\n├── gravitational_acceleration: 9.80665\n├── constant_salinity: 35\n└── equation_of_state: BoussinesqEquationOfState{Float64}\n```\n" function SeawaterBuoyancy(FT = Float64; gravitational_acceleration = g_Earth, equation_of_state = LinearEquationOfState(FT), constant_temperature = nothing, constant_salinity = nothing)
        #= none:106 =#
        #= none:116 =#
        constant_temperature = if constant_temperature === true
                zero(FT)
            else
                constant_temperature
            end
        #= none:117 =#
        constant_salinity = if constant_salinity === true
                zero(FT)
            else
                constant_salinity
            end
        #= none:119 =#
        return SeawaterBuoyancy{FT, typeof(equation_of_state), typeof(constant_temperature), typeof(constant_salinity)}(equation_of_state, gravitational_acceleration, constant_temperature, constant_salinity)
    end
#= none:123 =#
const TemperatureSeawaterBuoyancy = (SeawaterBuoyancy{FT, EOS, <:Nothing, <:Number} where {FT, EOS})
#= none:124 =#
const SalinitySeawaterBuoyancy = (SeawaterBuoyancy{FT, EOS, <:Number, <:Nothing} where {FT, EOS})
#= none:126 =#
Base.nameof(::Type{TemperatureSeawaterBuoyancy}) = begin
        #= none:126 =#
        "TemperatureSeawaterBuoyancy"
    end
#= none:127 =#
Base.nameof(::Type{SalinitySeawaterBuoyancy}) = begin
        #= none:127 =#
        "SalinitySeawaterBuoyancy"
    end
#= none:129 =#
#= none:129 =# @inline get_temperature_and_salinity(::SeawaterBuoyancy, C) = begin
            #= none:129 =#
            (C.T, C.S)
        end
#= none:130 =#
#= none:130 =# @inline get_temperature_and_salinity(b::TemperatureSeawaterBuoyancy, C) = begin
            #= none:130 =#
            (C.T, b.constant_salinity)
        end
#= none:131 =#
#= none:131 =# @inline get_temperature_and_salinity(b::SalinitySeawaterBuoyancy, C) = begin
            #= none:131 =#
            (b.constant_temperature, C.S)
        end
#= none:133 =#
#= none:133 =# @inline function buoyancy_perturbationᶜᶜᶜ(i, j, k, grid, b::SeawaterBuoyancy, C)
        #= none:133 =#
        #= none:134 =#
        (T, S) = get_temperature_and_salinity(b, C)
        #= none:135 =#
        return -((b.gravitational_acceleration * ρ′(i, j, k, grid, b.equation_of_state, T, S)) / b.equation_of_state.reference_density)
    end
#= none:143 =#
#= none:143 =# Core.@doc "    ∂x_b(i, j, k, grid, b::SeawaterBuoyancy, C)\n\nReturns the ``x``-derivative of buoyancy for temperature and salt-stratified water,\n\n```math\n∂_x b = g ( α ∂_x T - β ∂_x S ) ,\n```\n\nwhere ``g`` is gravitational acceleration, ``α`` is the thermal expansion\ncoefficient, ``β`` is the haline contraction coefficient, ``T`` is\nconservative temperature, and ``S`` is absolute salinity.\n\nNote: In Oceananigans, `model.tracers.T` is conservative temperature and\n`model.tracers.S` is absolute salinity.\n\nNote that ``∂_x T`` (`∂x_T`), ``∂_x S`` (`∂x_S`), ``α``, and ``β`` are all evaluated at cell\ninterfaces in `x` and cell centers in `y` and `z`.\n" #= none:162 =# @inline(function ∂x_b(i, j, k, grid, b::SeawaterBuoyancy, C)
            #= none:162 =#
            #= none:163 =#
            (T, S) = get_temperature_and_salinity(b, C)
            #= none:164 =#
            return b.gravitational_acceleration * (thermal_expansionᶠᶜᶜ(i, j, k, grid, b.equation_of_state, T, S) * ∂xᶠᶜᶜ(i, j, k, grid, T) - haline_contractionᶠᶜᶜ(i, j, k, grid, b.equation_of_state, T, S) * ∂xᶠᶜᶜ(i, j, k, grid, S))
        end)
#= none:169 =#
#= none:169 =# Core.@doc "    ∂y_b(i, j, k, grid, b::SeawaterBuoyancy, C)\n\nReturns the ``y``-derivative of buoyancy for temperature and salt-stratified water,\n\n```math\n∂_y b = g ( α ∂_y T - β ∂_y S ) ,\n```\n\nwhere ``g`` is gravitational acceleration, ``α`` is the thermal expansion\ncoefficient, ``β`` is the haline contraction coefficient, ``T`` is\nconservative temperature, and ``S`` is absolute salinity.\n\nNote: In Oceananigans, `model.tracers.T` is conservative temperature and\n`model.tracers.S` is absolute salinity.\n\nNote that ``∂_y T`` (`∂y_T`), ``∂_y S`` (`∂y_S`), ``α``, and ``β`` are all evaluated at cell\ninterfaces in `y` and cell centers in `x` and `z`.\n" #= none:188 =# @inline(function ∂y_b(i, j, k, grid, b::SeawaterBuoyancy, C)
            #= none:188 =#
            #= none:189 =#
            (T, S) = get_temperature_and_salinity(b, C)
            #= none:190 =#
            return b.gravitational_acceleration * (thermal_expansionᶜᶠᶜ(i, j, k, grid, b.equation_of_state, T, S) * ∂yᶜᶠᶜ(i, j, k, grid, T) - haline_contractionᶜᶠᶜ(i, j, k, grid, b.equation_of_state, T, S) * ∂yᶜᶠᶜ(i, j, k, grid, S))
        end)
#= none:195 =#
#= none:195 =# Core.@doc "    ∂z_b(i, j, k, grid, b::SeawaterBuoyancy, C)\n\nReturns the vertical derivative of buoyancy for temperature and salt-stratified water,\n\n```math\n∂_z b = N^2 = g ( α ∂_z T - β ∂_z S ) ,\n```\n\nwhere ``g`` is gravitational acceleration, ``α`` is the thermal expansion\ncoefficient, ``β`` is the haline contraction coefficient, ``T`` is\nconservative temperature, and ``S`` is absolute salinity.\n\nNote: In Oceananigans, `model.tracers.T` is conservative temperature and\n`model.tracers.S` is absolute salinity.\n\nNote that ``∂_z T`` (`∂z_T`), ``∂_z S`` (`∂z_S`), ``α``, and ``β`` are all evaluated at cell\ninterfaces in `z` and cell centers in `x` and `y`.\n" #= none:214 =# @inline(function ∂z_b(i, j, k, grid, b::SeawaterBuoyancy, C)
            #= none:214 =#
            #= none:215 =#
            (T, S) = get_temperature_and_salinity(b, C)
            #= none:216 =#
            return b.gravitational_acceleration * (thermal_expansionᶜᶜᶠ(i, j, k, grid, b.equation_of_state, T, S) * ∂zᶜᶜᶠ(i, j, k, grid, T) - haline_contractionᶜᶜᶠ(i, j, k, grid, b.equation_of_state, T, S) * ∂zᶜᶜᶠ(i, j, k, grid, S))
        end)
#= none:225 =#
#= none:225 =# @inline get_temperature_and_salinity_flux(::SeawaterBuoyancy, bcs) = begin
            #= none:225 =#
            (bcs.T, bcs.S)
        end
#= none:226 =#
#= none:226 =# @inline get_temperature_and_salinity_flux(::TemperatureSeawaterBuoyancy, bcs) = begin
            #= none:226 =#
            (bcs.T, NoFluxBoundaryCondition())
        end
#= none:227 =#
#= none:227 =# @inline get_temperature_and_salinity_flux(::SalinitySeawaterBuoyancy, bcs) = begin
            #= none:227 =#
            (NoFluxBoundaryCondition(), bcs.S)
        end
#= none:229 =#
#= none:229 =# @inline function top_bottom_buoyancy_flux(i, j, k, grid, b::SeawaterBuoyancy, top_bottom_tracer_bcs, clock, fields)
        #= none:229 =#
        #= none:230 =#
        (T, S) = get_temperature_and_salinity(b, fields)
        #= none:231 =#
        (T_flux_bc, S_flux_bc) = get_temperature_and_salinity_flux(b, top_bottom_tracer_bcs)
        #= none:233 =#
        T_flux = getbc(T_flux_bc, i, j, grid, clock, fields)
        #= none:234 =#
        S_flux = getbc(S_flux_bc, i, j, grid, clock, fields)
        #= none:236 =#
        return b.gravitational_acceleration * (thermal_expansionᶜᶜᶠ(i, j, k, grid, b.equation_of_state, T, S) * T_flux - haline_contractionᶜᶜᶠ(i, j, k, grid, b.equation_of_state, T, S) * S_flux)
    end
#= none:241 =#
#= none:241 =# @inline top_buoyancy_flux(i, j, grid, b::SeawaterBuoyancy, args...) = begin
            #= none:241 =#
            top_bottom_buoyancy_flux(i, j, grid.Nz + 1, grid, b, args...)
        end
#= none:242 =#
#= none:242 =# @inline bottom_buoyancy_flux(i, j, grid, b::SeawaterBuoyancy, args...) = begin
            #= none:242 =#
            top_bottom_buoyancy_flux(i, j, 1, grid, b, args...)
        end