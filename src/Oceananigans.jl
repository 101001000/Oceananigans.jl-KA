
#= none:1 =#
#= none:1 =# Core.@doc "Main module for `Oceananigans.jl` -- a Julia software for fast, friendly, flexible,\ndata-driven, ocean-flavored fluid dynamics on CPUs and GPUs.\n" module Oceananigans
    #= none:5 =#
    #= none:7 =#
    export CPU, GPU, OceananigansLogger, Center, Face, Periodic, Bounded, Flat, FullyConnected, LeftConnected, RightConnected, RectilinearGrid, LatitudeLongitudeGrid, OrthogonalSphericalShellGrid, xnodes, ynodes, znodes, nodes, λnodes, φnodes, xspacings, yspacings, zspacings, minimum_xspacing, minimum_yspacing, minimum_zspacing, ImmersedBoundaryGrid, GridFittedBoundary, GridFittedBottom, ImmersedBoundaryCondition, Distributed, Partition, Centered, CenteredSecondOrder, CenteredFourthOrder, UpwindBiased, UpwindBiasedFirstOrder, UpwindBiasedThirdOrder, UpwindBiasedFifthOrder, WENO, WENOThirdOrder, WENOFifthOrder, VectorInvariant, WENOVectorInvariant, EnergyConserving, EnstrophyConserving, FluxFormAdvection, BoundaryCondition, FluxBoundaryCondition, ValueBoundaryCondition, GradientBoundaryCondition, OpenBoundaryCondition, FieldBoundaryConditions, Field, CenterField, XFaceField, YFaceField, ZFaceField, Average, Integral, CumulativeIntegral, Reduction, Accumulation, BackgroundField, interior, set!, compute!, regrid!, location, Forcing, Relaxation, LinearTarget, GaussianMask, AdvectiveForcing, FPlane, ConstantCartesianCoriolis, BetaPlane, NonTraditionalBetaPlane, Buoyancy, BuoyancyTracer, SeawaterBuoyancy, LinearEquationOfState, TEOS10, BuoyancyField, UniformStokesDrift, StokesDrift, VerticalScalarDiffusivity, HorizontalScalarDiffusivity, ScalarDiffusivity, VerticalScalarBiharmonicDiffusivity, HorizontalScalarBiharmonicDiffusivity, ScalarBiharmonicDiffusivity, SmagorinskyLilly, AnisotropicMinimumDissipation, ConvectiveAdjustmentVerticalDiffusivity, RiBasedVerticalDiffusivity, IsopycnalSkewSymmetricDiffusivity, FluxTapering, VerticallyImplicitTimeDiscretization, viscosity, diffusivity, LagrangianParticles, NonhydrostaticModel, HydrostaticFreeSurfaceModel, ShallowWaterModel, ConservativeFormulation, VectorInvariantFormulation, PressureField, fields, VectorInvariant, ExplicitFreeSurface, ImplicitFreeSurface, SplitExplicitFreeSurface, HydrostaticSphericalCoriolis, PrescribedVelocityFields, Clock, TimeStepWizard, conjure_time_step_wizard!, time_step!, Simulation, run!, Callback, add_callback!, iteration, stopwatch, iteration_limit_exceeded, stop_time_exceeded, wall_time_limit_exceeded, TimeStepCallsite, TendencyCallsite, UpdateStateCallsite, StateChecker, CFL, AdvectiveCFL, DiffusiveCFL, NetCDFOutputWriter, JLD2OutputWriter, Checkpointer, TimeInterval, IterationInterval, AveragedTimeInterval, SpecifiedTimes, FileSizeLimit, AndSchedule, OrSchedule, written_names, FieldTimeSeries, FieldDataset, InMemory, OnDisk, ∂x, ∂y, ∂z, @at, KernelFunctionOperation, MultiRegionGrid, MultiRegionField, XPartition, YPartition, CubedSpherePartition, ConformalCubedSphereGrid, CubedSphereField, prettytime, apply_regionally!, construct_regionally, @apply_regionally, MultiRegionObject, Time
    #= none:127 =#
    using Printf
    #= none:128 =#
    using Logging
    #= none:129 =#
    using Statistics
    #= none:130 =#
    using LinearAlgebra
    #= none:131 =#
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
    #= none:132 =#
    using Adapt
    #= none:133 =#
    using DocStringExtensions
    #= none:134 =#
    using OffsetArrays
    #= none:135 =#
    using FFTW
    #= none:136 =#
    using JLD2
    #= none:138 =#
    using Base: @propagate_inbounds
    #= none:139 =#
    using Statistics: mean
    #= none:141 =#
    import Base: +, -, *, /, size, length, eltype, iterate, similar, show, getindex, lastindex, setindex!, push!
    #= none:152 =#
    #= none:152 =# Core.@doc "    AbstractModel\n\nAbstract supertype for models.\n" abstract type AbstractModel{TS} end
    #= none:159 =#
    #= none:159 =# Core.@doc "    AbstractDiagnostic\n\nAbstract supertype for diagnostics that compute information from the current\nmodel state.\n" abstract type AbstractDiagnostic end
    #= none:167 =#
    #= none:167 =# Core.@doc "    AbstractOutputWriter\n\nAbstract supertype for output writers that write data to disk.\n" abstract type AbstractOutputWriter end
    #= none:175 =#
    struct TimeStepCallsite
        #= none:175 =#
    end
    #= none:176 =#
    struct TendencyCallsite
        #= none:176 =#
    end
    #= none:177 =#
    struct UpdateStateCallsite
        #= none:177 =#
    end
    #= none:183 =#
    function run_diagnostic! end
    #= none:184 =#
    function write_output! end
    #= none:185 =#
    function initialize! end
    #= none:186 =#
    function location end
    #= none:187 =#
    function instantiated_location end
    #= none:188 =#
    function tupleit end
    #= none:189 =#
    function fields end
    #= none:190 =#
    function prognostic_fields end
    #= none:191 =#
    function tracer_tendency_kernel_function end
    #= none:192 =#
    function boundary_conditions end
    #= none:199 =#
    include("Architectures.jl")
    #= none:200 =#
    include("Units.jl")
    #= none:201 =#
    include("Grids/Grids.jl")
    #= none:202 =#
    include("Utils/Utils.jl")
    #= none:203 =#
    include("Logger.jl")
    #= none:204 =#
    include("Operators/Operators.jl")
    #= none:205 =#
    include("BoundaryConditions/BoundaryConditions.jl")
    #= none:206 =#
    include("Fields/Fields.jl")
    #= none:207 =#
    include("AbstractOperations/AbstractOperations.jl")
    #= none:208 =#
    include("TimeSteppers/TimeSteppers.jl")
    #= none:209 =#
    include("ImmersedBoundaries/ImmersedBoundaries.jl")
    #= none:210 =#
    include("Advection/Advection.jl")
    #= none:211 =#
    include("Solvers/Solvers.jl")
    #= none:212 =#
    include("OutputReaders/OutputReaders.jl")
    #= none:213 =#
    include("DistributedComputations/DistributedComputations.jl")
    #= none:219 =#
    include("Coriolis/Coriolis.jl")
    #= none:220 =#
    include("BuoyancyModels/BuoyancyModels.jl")
    #= none:221 =#
    include("StokesDrifts.jl")
    #= none:222 =#
    include("TurbulenceClosures/TurbulenceClosures.jl")
    #= none:223 =#
    include("Forcings/Forcings.jl")
    #= none:224 =#
    include("Biogeochemistry.jl")
    #= none:227 =#
    include("Models/Models.jl")
    #= none:230 =#
    include("Diagnostics/Diagnostics.jl")
    #= none:231 =#
    include("OutputWriters/OutputWriters.jl")
    #= none:232 =#
    include("Simulations/Simulations.jl")
    #= none:235 =#
    include("MultiRegion/MultiRegion.jl")
    #= none:241 =#
    using .Logger
    #= none:242 =#
    using .Architectures
    #= none:243 =#
    using .Utils
    #= none:244 =#
    using .Advection
    #= none:245 =#
    using .Grids
    #= none:246 =#
    using .BoundaryConditions
    #= none:247 =#
    using .Fields
    #= none:248 =#
    using .Coriolis
    #= none:249 =#
    using .BuoyancyModels
    #= none:250 =#
    using .StokesDrifts
    #= none:251 =#
    using .TurbulenceClosures
    #= none:252 =#
    using .Solvers
    #= none:253 =#
    using .OutputReaders
    #= none:254 =#
    using .Forcings
    #= none:255 =#
    using .ImmersedBoundaries
    #= none:256 =#
    using .DistributedComputations
    #= none:257 =#
    using .Models
    #= none:258 =#
    using .TimeSteppers
    #= none:259 =#
    using .Diagnostics
    #= none:260 =#
    using .OutputWriters
    #= none:261 =#
    using .Simulations
    #= none:262 =#
    using .AbstractOperations
    #= none:263 =#
    using .MultiRegion
    #= none:265 =#
    function __init__()
        #= none:265 =#
        #= none:266 =#
        threads = Threads.nthreads()
        #= none:267 =#
        if threads > 1
            #= none:268 =#
            #= none:268 =# @info "Oceananigans will use $(threads) threads"
            #= none:271 =#
            FFTW.set_num_threads(4threads)
        end
        #= none:274 =#
        if true
            #= none:275 =#
            #= none:275 =# @debug "CUDA-enabled GPU(s) detected:"
            #= none:276 =#
            for (gpu, dev) = enumerate(KAUtils.devices())
                #= none:277 =#
                #= none:277 =# @debug "$(dev): $(KAUtils.name(dev))"
                #= none:278 =#
            end
            #= none:280 =#
            CUDA.allowscalar(false)
        end
    end
    end