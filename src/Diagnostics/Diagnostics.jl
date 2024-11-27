
#= none:1 =#
module Diagnostics
#= none:1 =#
#= none:3 =#
export StateChecker, CFL, AdvectiveCFL, DiffusiveCFL
#= none:5 =#
using CUDA, Juliana, GPUArrays
import KernelAbstractions
#= none:6 =#
using Oceananigans
#= none:7 =#
using Oceananigans.Operators
#= none:9 =#
using Oceananigans: AbstractDiagnostic
#= none:10 =#
using Oceananigans.Utils: TimeInterval, IterationInterval, WallTimeInterval
#= none:12 =#
import Base: show
#= none:13 =#
import Oceananigans: run_diagnostic!
#= none:15 =#
include("state_checker.jl")
#= none:16 =#
include("cfl.jl")
end