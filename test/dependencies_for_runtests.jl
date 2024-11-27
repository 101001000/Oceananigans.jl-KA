
#= none:1 =#
using Oceananigans
#= none:2 =#
using Test
#= none:3 =#
using Printf
#= none:4 =#
using Random
#= none:5 =#
using Statistics
#= none:6 =#
using LinearAlgebra
#= none:7 =#
using Logging
#= none:8 =#
using Enzyme
#= none:9 =#
using SparseArrays
#= none:10 =#
using JLD2
#= none:11 =#
using FFTW
#= none:12 =#
using OffsetArrays
#= none:13 =#
using SeawaterPolynomials
#= none:14 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:15 =#
using MPI
#= none:17 =#
using Dates: DateTime, Nanosecond
#= none:18 =#
using Statistics: mean, mean!, norm
#= none:19 =#
using LinearAlgebra: norm
#= none:20 =#
using NCDatasets: Dataset
#= none:21 =#
using KernelAbstractions: @kernel, @index
#= none:23 =#
MPI.versioninfo()
#= none:24 =#
MPI.Initialized() || MPI.Init()
#= none:26 =#
using Oceananigans.Architectures
#= none:27 =#
using Oceananigans.Grids
#= none:28 =#
using Oceananigans.Operators
#= none:29 =#
using Oceananigans.Advection
#= none:30 =#
using Oceananigans.BoundaryConditions
#= none:31 =#
using Oceananigans.Fields
#= none:32 =#
using Oceananigans.AbstractOperations
#= none:33 =#
using Oceananigans.Coriolis
#= none:34 =#
using Oceananigans.BuoyancyModels
#= none:35 =#
using Oceananigans.Forcings
#= none:36 =#
using Oceananigans.Solvers
#= none:37 =#
using Oceananigans.Models
#= none:38 =#
using Oceananigans.MultiRegion
#= none:39 =#
using Oceananigans.Simulations
#= none:40 =#
using Oceananigans.Diagnostics
#= none:41 =#
using Oceananigans.OutputWriters
#= none:42 =#
using Oceananigans.TurbulenceClosures
#= none:43 =#
using Oceananigans.DistributedComputations
#= none:44 =#
using Oceananigans.Logger
#= none:45 =#
using Oceananigans.Units
#= none:46 =#
using Oceananigans.Utils
#= none:48 =#
using Oceananigans: Clock
#= none:49 =#
using Oceananigans.Architectures: device, array_type
#= none:50 =#
using Oceananigans.Architectures: on_architecture
#= none:51 =#
using Oceananigans.AbstractOperations: UnaryOperation, Derivative, BinaryOperation, MultiaryOperation
#= none:52 =#
using Oceananigans.AbstractOperations: KernelFunctionOperation
#= none:53 =#
using Oceananigans.BuoyancyModels: BuoyancyField
#= none:54 =#
using Oceananigans.Grids: architecture
#= none:55 =#
using Oceananigans.Fields: ZeroField, ConstantField, FunctionField, compute_at!, indices
#= none:56 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: tracernames
#= none:57 =#
using Oceananigans.ImmersedBoundaries: conditional_length
#= none:58 =#
using Oceananigans.Operators: ℑxyᶜᶠᵃ, ℑxyᶠᶜᵃ, hack_cosd
#= none:59 =#
using Oceananigans.Solvers: constructors, unpack_constructors
#= none:60 =#
using Oceananigans.TurbulenceClosures: with_tracers
#= none:61 =#
using Oceananigans.MultiRegion: reconstruct_global_grid, reconstruct_global_field, getnamewrapper
#= none:63 =#
import Oceananigans.Utils: launch!, datatuple
#= none:64 =#
Logging.global_logger(OceananigansLogger())
#= none:70 =#
closures = (:ScalarDiffusivity, :ScalarBiharmonicDiffusivity, :TwoDimensionalLeith, :SmagorinskyLilly, :AnisotropicMinimumDissipation, :ConvectiveAdjustmentVerticalDiffusivity)
#= none:79 =#
if !(#= none:79 =# @isdefined(already_included))
    #= none:80 =#
    already_included = Ref(false)
    #= none:81 =#
    macro include_once(expr)
        #= none:81 =#
        #= none:82 =#
        return if !(already_included[])
                #= line 0 =#
                :($(esc(expr)))
            else
                :nothing
            end
    end
end
#= none:86 =#
#= none:86 =# @include_once include("utils_for_runtests.jl")
#= none:87 =#
already_included[] = true
#= none:89 =#
float_types = (Float32, Float64)
#= none:90 =#
archs = test_architectures()