
#= none:1 =#
using Adapt
#= none:2 =#
using Oceananigans.Operators
#= none:3 =#
using Oceananigans.Fields: default_indices
#= none:5 =#
abstract type AbstractGridMetric end
#= none:7 =#
struct XSpacingMetric <: AbstractGridMetric
    #= none:7 =#
end
#= none:8 =#
struct YSpacingMetric <: AbstractGridMetric
    #= none:8 =#
end
#= none:9 =#
struct ZSpacingMetric <: AbstractGridMetric
    #= none:9 =#
end
#= none:11 =#
metric_function_prefix(::XSpacingMetric) = begin
        #= none:11 =#
        :Δx
    end
#= none:12 =#
metric_function_prefix(::YSpacingMetric) = begin
        #= none:12 =#
        :Δy
    end
#= none:13 =#
metric_function_prefix(::ZSpacingMetric) = begin
        #= none:13 =#
        :Δz
    end
#= none:15 =#
struct XAreaMetric <: AbstractGridMetric
    #= none:15 =#
end
#= none:16 =#
struct YAreaMetric <: AbstractGridMetric
    #= none:16 =#
end
#= none:17 =#
struct ZAreaMetric <: AbstractGridMetric
    #= none:17 =#
end
#= none:19 =#
metric_function_prefix(::XAreaMetric) = begin
        #= none:19 =#
        :Ax
    end
#= none:20 =#
metric_function_prefix(::YAreaMetric) = begin
        #= none:20 =#
        :Ay
    end
#= none:21 =#
metric_function_prefix(::ZAreaMetric) = begin
        #= none:21 =#
        :Az
    end
#= none:23 =#
struct VolumeMetric <: AbstractGridMetric
    #= none:23 =#
end
#= none:25 =#
metric_function_prefix(::VolumeMetric) = begin
        #= none:25 =#
        :V
    end
#= none:28 =#
const Δx = XSpacingMetric()
#= none:29 =#
const Δy = YSpacingMetric()
#= none:31 =#
#= none:31 =# Core.@doc "    Δz = ZSpacingMetric()\n\nInstance of `ZSpacingMetric` that generates `BinaryOperation`s\nbetween `AbstractField`s and the vertical grid spacing evaluated\nat the same location as the `AbstractField`. \n\n`Δx` and `Δy` play a similar role for horizontal grid spacings.\n\nExample\n=======\n\n```jldoctest\njulia> using Oceananigans\n\njulia> using Oceananigans.AbstractOperations: Δz\n\njulia> c = CenterField(RectilinearGrid(size=(1, 1, 1), extent=(1, 2, 3)));\n\njulia> c_dz = c * Δz # returns BinaryOperation between Field and GridMetricOperation\nBinaryOperation at (Center, Center, Center)\n├── grid: 1×1×1 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 1×1×1 halo\n└── tree:\n    * at (Center, Center, Center)\n    ├── 1×1×1 Field{Center, Center, Center} on RectilinearGrid on CPU\n    └── Δzᶜᶜᶜ at (Center, Center, Center)\n\njulia> c .= 1;\n\njulia> c_dz[1, 1, 1]\n3.0\n```\n" const Δz = ZSpacingMetric()
#= none:66 =#
const Ax = XAreaMetric()
#= none:67 =#
const Ay = YAreaMetric()
#= none:68 =#
const Az = ZAreaMetric()
#= none:70 =#
#= none:70 =# Core.@doc "    volume = VolumeMetric()\n\nInstance of `VolumeMetric` that generates `BinaryOperation`s\nbetween `AbstractField`s and their cell volumes. Summing\nthis `BinaryOperation` yields an integral of `AbstractField`\nover the domain.\n\nExample\n=======\n\n```jldoctest\njulia> using Oceananigans\n\njulia> using Oceananigans.AbstractOperations: volume\n\njulia> c = CenterField(RectilinearGrid(size=(2, 2, 2), extent=(1, 2, 3)));\n\njulia> c .= 1;\n\njulia> c_dV = c * volume\nBinaryOperation at (Center, Center, Center)\n├── grid: 2×2×2 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 2×2×2 halo\n└── tree:\n    * at (Center, Center, Center)\n    ├── 2×2×2 Field{Center, Center, Center} on RectilinearGrid on CPU\n    └── Vᶜᶜᶜ at (Center, Center, Center)\n\njulia> c_dV[1, 1, 1]\n0.75\n\njulia> sum(c_dV)\n6.0\n```\n" const volume = VolumeMetric()
#= none:107 =#
#= none:107 =# Core.@doc "    metric_function(loc, metric::AbstractGridMetric)\n\nReturn the function associated with `metric::AbstractGridMetric`\nat `loc`ation.\n" function metric_function(loc, metric::AbstractGridMetric)
        #= none:113 =#
        #= none:114 =#
        code = Tuple((interpolation_code(ℓ) for ℓ = loc))
        #= none:115 =#
        prefix = metric_function_prefix(metric)
        #= none:116 =#
        metric_function_symbol = Symbol(prefix, code...)
        #= none:117 =#
        return getglobal(#= none:117 =# @__MODULE__(), metric_function_symbol)
    end
#= none:120 =#
struct GridMetricOperation{LX, LY, LZ, G, T, M} <: AbstractOperation{LX, LY, LZ, G, T}
    #= none:121 =#
    metric::M
    #= none:122 =#
    grid::G
    #= none:123 =#
    function GridMetricOperation{LX, LY, LZ}(metric::M, grid::G) where {LX, LY, LZ, M, G}
        #= none:123 =#
        #= none:124 =#
        T = eltype(grid)
        #= none:125 =#
        return new{LX, LY, LZ, G, T, M}(metric, grid)
    end
end
#= none:129 =#
(Adapt.adapt_structure(to, gm::GridMetricOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:129 =#
        GridMetricOperation{LX, LY, LZ}(Adapt.adapt(to, gm.metric), Adapt.adapt(to, gm.grid))
    end
#= none:133 =#
(on_architecture(to, gm::GridMetricOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:133 =#
        GridMetricOperation{LX, LY, LZ}(on_architecture(to, gm.metric), on_architecture(to, gm.grid))
    end
#= none:138 =#
#= none:138 =# @inline Base.getindex(gm::GridMetricOperation, i, j, k) = begin
            #= none:138 =#
            gm.metric(i, j, k, gm.grid)
        end
#= none:140 =#
indices(::GridMetricOperation) = begin
        #= none:140 =#
        default_indices(3)
    end
#= none:143 =#
GridMetricOperation(L, metric, grid) = begin
        #= none:143 =#
        GridMetricOperation{L[1], L[2], L[3]}(metric_function(L, metric), grid)
    end