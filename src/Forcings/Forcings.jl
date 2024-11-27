
#= none:1 =#
module Forcings
#= none:1 =#
#= none:3 =#
export Forcing, ContinuousForcing, DiscreteForcing, Relaxation, GaussianMask, LinearTarget, AdvectiveForcing
#= none:5 =#
using Oceananigans.Fields
#= none:6 =#
using Oceananigans.OutputReaders: FlavorOfFTS
#= none:7 =#
using Oceananigans.Units: Time
#= none:8 =#
import Oceananigans.Architectures: on_architecture
#= none:10 =#
include("multiple_forcings.jl")
#= none:11 =#
include("continuous_forcing.jl")
#= none:12 =#
include("discrete_forcing.jl")
#= none:13 =#
include("relaxation.jl")
#= none:14 =#
include("advective_forcing.jl")
#= none:15 =#
include("forcing.jl")
#= none:16 =#
include("model_forcing.jl")
end