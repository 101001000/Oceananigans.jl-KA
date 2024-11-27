
#= none:1 =#
#= none:1 =# Core.@doc "    LinearEquationOfState{FT} <: AbstractEquationOfState\n\nLinear equation of state for seawater.\n" struct LinearEquationOfState{FT} <: AbstractEquationOfState
        #= none:7 =#
        thermal_expansion::FT
        #= none:8 =#
        haline_contraction::FT
    end
#= none:11 =#
Base.summary(eos::LinearEquationOfState) = begin
        #= none:11 =#
        string("LinearEquationOfState(thermal_expansion=", prettysummary(eos.thermal_expansion), ", haline_contraction=", prettysummary(eos.haline_contraction), ")")
    end
#= none:15 =#
Base.show(io::IO, eos::LinearEquationOfState) = begin
        #= none:15 =#
        print(io, summary(eos))
    end
#= none:17 =#
#= none:17 =# Core.@doc "    LinearEquationOfState([FT=Float64;] thermal_expansion=1.67e-4, haline_contraction=7.80e-4)\n\nReturn `LinearEquationOfState` for `SeawaterBuoyancy` with\n`thermal_expansion` coefficient and `haline_contraction` coefficient.\nThe buoyancy perturbation ``b`` for `LinearEquationOfState` is\n\n```math\n    b = g (α T - β S),\n```\n\nwhere ``g`` is gravitational acceleration, ``α`` is `thermal_expansion`, ``β`` is\n`haline_contraction`, ``T`` is temperature, and ``S`` is practical salinity units.\n\nDefault constants in units inverse Kelvin and practical salinity units\nfor `thermal_expansion` and `haline_contraction`, respectively,\nare taken from Table 1.2 (page 33) of Vallis, \"Atmospheric and Oceanic Fluid\nDynamics: Fundamentals and Large-Scale Circulation\" (2nd ed, 2017).\n" LinearEquationOfState(FT = Float64; thermal_expansion = 0.000167, haline_contraction = 0.00078) = begin
            #= none:36 =#
            LinearEquationOfState{FT}(thermal_expansion, haline_contraction)
        end
#= none:43 =#
#= none:43 =# @inline thermal_expansion(Θ, sᴬ, D, eos::LinearEquationOfState) = begin
            #= none:43 =#
            eos.thermal_expansion
        end
#= none:44 =#
#= none:44 =# @inline haline_contraction(Θ, sᴬ, D, eos::LinearEquationOfState) = begin
            #= none:44 =#
            eos.haline_contraction
        end
#= none:47 =#
#= none:47 =# @inline thermal_expansionᶜᶜᶜ(i, j, k, grid, eos::LinearEquationOfState, C) = begin
            #= none:47 =#
            eos.thermal_expansion
        end
#= none:48 =#
#= none:48 =# @inline thermal_expansionᶠᶜᶜ(i, j, k, grid, eos::LinearEquationOfState, C) = begin
            #= none:48 =#
            eos.thermal_expansion
        end
#= none:49 =#
#= none:49 =# @inline thermal_expansionᶜᶠᶜ(i, j, k, grid, eos::LinearEquationOfState, C) = begin
            #= none:49 =#
            eos.thermal_expansion
        end
#= none:50 =#
#= none:50 =# @inline thermal_expansionᶜᶜᶠ(i, j, k, grid, eos::LinearEquationOfState, C) = begin
            #= none:50 =#
            eos.thermal_expansion
        end
#= none:52 =#
#= none:52 =# @inline haline_contractionᶜᶜᶜ(i, j, k, grid, eos::LinearEquationOfState, C) = begin
            #= none:52 =#
            eos.haline_contraction
        end
#= none:53 =#
#= none:53 =# @inline haline_contractionᶠᶜᶜ(i, j, k, grid, eos::LinearEquationOfState, C) = begin
            #= none:53 =#
            eos.haline_contraction
        end
#= none:54 =#
#= none:54 =# @inline haline_contractionᶜᶠᶜ(i, j, k, grid, eos::LinearEquationOfState, C) = begin
            #= none:54 =#
            eos.haline_contraction
        end
#= none:55 =#
#= none:55 =# @inline haline_contractionᶜᶜᶠ(i, j, k, grid, eos::LinearEquationOfState, C) = begin
            #= none:55 =#
            eos.haline_contraction
        end
#= none:61 =#
const LinearSeawaterBuoyancy = (SeawaterBuoyancy{FT, <:LinearEquationOfState} where FT)
#= none:62 =#
const LinearTemperatureSeawaterBuoyancy = (SeawaterBuoyancy{FT, <:LinearEquationOfState, <:Nothing, <:Number} where FT)
#= none:63 =#
const LinearSalinitySeawaterBuoyancy = (SeawaterBuoyancy{FT, <:LinearEquationOfState, <:Number, <:Nothing} where FT)
#= none:69 =#
#= none:69 =# @inline buoyancy_perturbationᶜᶜᶜ(i, j, k, grid, b::LinearSeawaterBuoyancy, C) = begin
            #= none:69 =#
            #= none:70 =# @inbounds b.gravitational_acceleration * (b.equation_of_state.thermal_expansion * C.T[i, j, k] - b.equation_of_state.haline_contraction * C.S[i, j, k])
        end
#= none:73 =#
#= none:73 =# @inline buoyancy_perturbationᶜᶜᶜ(i, j, k, grid, b::LinearTemperatureSeawaterBuoyancy, C) = begin
            #= none:73 =#
            #= none:74 =# @inbounds b.gravitational_acceleration * b.equation_of_state.thermal_expansion * C.T[i, j, k]
        end
#= none:76 =#
#= none:76 =# @inline buoyancy_perturbationᶜᶜᶜ(i, j, k, grid, b::LinearSalinitySeawaterBuoyancy, C) = begin
            #= none:76 =#
            #= none:77 =# @inbounds -(b.gravitational_acceleration) * b.equation_of_state.haline_contraction * C.S[i, j, k]
        end