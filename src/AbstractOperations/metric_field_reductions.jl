
#= none:1 =#
using Statistics: mean!, sum!
#= none:3 =#
using Oceananigans.Utils: tupleit
#= none:4 =#
using Oceananigans.Grids: regular_dimensions
#= none:5 =#
using Oceananigans.Fields: Scan, condition_operand, reverse_cumsum!, AbstractReducing, AbstractAccumulating
#= none:11 =#
reduction_grid_metric(dims::Number) = begin
        #= none:11 =#
        reduction_grid_metric(tuple(dims))
    end
#= none:13 =#
reduction_grid_metric(dims) = begin
        #= none:13 =#
        if dims === tuple(1)
            Δx
        else
            if dims === tuple(2)
                Δy
            else
                if dims === tuple(3)
                    Δz
                else
                    if dims === (1, 2)
                        Az
                    else
                        if dims === (1, 3)
                            Ay
                        else
                            if dims === (2, 3)
                                Ax
                            else
                                if dims === (1, 2, 3)
                                    volume
                                else
                                    throw(ArgumentError("Cannot determine grid metric for reducing over dims = $(dims)"))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
#= none:26 =#
struct Averaging <: AbstractReducing
    #= none:26 =#
end
#= none:27 =#
const Average = Scan{<:Averaging}
#= none:28 =#
Base.summary(r::Average) = begin
        #= none:28 =#
        string("Average of ", summary(r.operand), " over dims ", r.dims)
    end
#= none:30 =#
#= none:30 =# Core.@doc "    Average(field::AbstractField; dims=:, condition=nothing, mask=0)\n\nReturn `Reduction` representing a spatial average of `field` over `dims`.\n\nOver regularly-spaced dimensions this is equivalent to a numerical `mean!`.\n\nOver dimensions of variable spacing, `field` is multiplied by the\nappropriate grid length, area or volume, and divided by the total\nspatial extent of the interval.\n" function Average(field::AbstractField; dims = (:), condition = nothing, mask = 0)
        #= none:41 =#
        #= none:42 =#
        dims = if dims isa Colon
                (1, 2, 3)
            else
                tupleit(dims)
            end
        #= none:43 =#
        dx = reduction_grid_metric(dims)
        #= none:45 =#
        if all((d in regular_dimensions(field.grid) for d = dims))
            #= none:47 =#
            operand = condition_operand(field, condition, mask)
            #= none:48 =#
            return Scan(Averaging(), mean!, operand, dims)
        else
            #= none:51 =#
            metric = GridMetricOperation(location(field), dx, field.grid)
            #= none:52 =#
            L = sum(metric; condition, mask, dims)
            #= none:55 =#
            L⁻¹_field_dx = (field * dx) / L
            #= none:57 =#
            operand = condition_operand(L⁻¹_field_dx, condition, mask)
            #= none:59 =#
            return Scan(Averaging(), sum!, operand, dims)
        end
    end
#= none:63 =#
struct Integrating <: AbstractReducing
    #= none:63 =#
end
#= none:64 =#
const Integral = Scan{<:Integrating}
#= none:65 =#
Base.summary(r::Integral) = begin
        #= none:65 =#
        string("Integral of ", summary(r.operand), " over dims ", r.dims)
    end
#= none:67 =#
#= none:67 =# Core.@doc "    Integral(field::AbstractField; dims=:, condition=nothing, mask=0)\n\n\nReturn a `Reduction` representing a spatial integral of `field` over `dims`.\n\nExample\n=======\n\nCompute the integral of ``f(x, y, z) = x y z`` over the domain\n``(x, y, z) ∈ [0, 1] × [0, 1] × [0, 1]``. The analytical answer\nis ``∭ x y z \\, dx \\, dy \\, dz = 1/8``.\n\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=(8, 8, 8), x=(0, 1), y=(0, 1), z=(0, 1));\n\njulia> f = CenterField(grid);\n\njulia> set!(f, (x, y, z) -> x * y * z)\n8×8×8 Field{Center, Center, Center} on RectilinearGrid on CPU\n├── grid: 8×8×8 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 3×3×3 halo\n├── boundary conditions: FieldBoundaryConditions\n│   └── west: Periodic, east: Periodic, south: Periodic, north: Periodic, bottom: ZeroFlux, top: ZeroFlux, immersed: ZeroFlux\n└── data: 14×14×14 OffsetArray(::Array{Float64, 3}, -2:11, -2:11, -2:11) with eltype Float64 with indices -2:11×-2:11×-2:11\n    └── max=0.823975, min=0.000244141, mean=0.125\n\njulia> ∫f = Integral(f)\nIntegral of BinaryOperation at (Center, Center, Center) over dims (1, 2, 3)\n└── operand: BinaryOperation at (Center, Center, Center)\n    └── grid: 8×8×8 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 3×3×3 halo\n\njulia> ∫f = Field(Integral(f));\n\njulia> compute!(∫f);\n\njulia> ∫f[1, 1, 1]\n0.125\n```\n" function Integral(field::AbstractField; dims = (:), condition = nothing, mask = 0)
        #= none:108 =#
        #= none:109 =#
        dims = if dims isa Colon
                (1, 2, 3)
            else
                tupleit(dims)
            end
        #= none:110 =#
        dx = reduction_grid_metric(dims)
        #= none:111 =#
        operand = condition_operand(field * dx, condition, mask)
        #= none:112 =#
        return Scan(Integrating(), sum!, operand, dims)
    end
#= none:119 =#
struct CumulativelyIntegrating <: AbstractAccumulating
    #= none:119 =#
end
#= none:120 =#
const CumulativeIntegral = Scan{<:CumulativelyIntegrating}
#= none:121 =#
Base.summary(c::CumulativeIntegral) = begin
        #= none:121 =#
        string("CumulativeIntegral of ", summary(c.operand), " over dims ", c.dims)
    end
#= none:123 =#
#= none:123 =# Core.@doc "    CumulativeIntegral(field::AbstractField; dims, reverse=false, condition=nothing, mask=0)\n\nReturn an `Accumulation` representing the cumulative spatial integral of `field` over `dims`.\n\nExample\n=======\n\nCompute the cumulative integral of ``f(z) = z`` over z ∈ [0, 1].\n\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=8, z=(0, 1), topology=(Flat, Flat, Bounded));\n\njulia> c = CenterField(grid);\n\njulia> set!(c, z -> z)\n1×1×8 Field{Center, Center, Center} on RectilinearGrid on CPU\n├── grid: 1×1×8 RectilinearGrid{Float64, Flat, Flat, Bounded} on CPU with 0×0×3 halo\n├── boundary conditions: FieldBoundaryConditions\n│   └── west: Nothing, east: Nothing, south: Nothing, north: Nothing, bottom: ZeroFlux, top: ZeroFlux, immersed: ZeroFlux\n└── data: 1×1×14 OffsetArray(::Array{Float64, 3}, 1:1, 1:1, -2:11) with eltype Float64 with indices 1:1×1:1×-2:11\n    └── max=0.9375, min=0.0625, mean=0.5\n\njulia> C_op = CumulativeIntegral(c, dims=3)\nCumulativeIntegral of BinaryOperation at (Center, Center, Center) over dims 3\n└── operand: BinaryOperation at (Center, Center, Center)\n    └── grid: 1×1×8 RectilinearGrid{Float64, Flat, Flat, Bounded} on CPU with 0×0×3 halo\n\njulia> C = compute!(Field(C_op))\n1×1×8 Field{Center, Center, Center} on RectilinearGrid on CPU\n├── data: OffsetArrays.OffsetArray{Float64, 3, Array{Float64, 3}}, size: (1, 1, 8)\n├── grid: 1×1×8 RectilinearGrid{Float64, Flat, Flat, Bounded} on CPU with 0×0×3 halo\n├── operand: CumulativeIntegral of BinaryOperation at (Center, Center, Center) over dims 3\n├── status: time=0.0\n└── data: 1×1×14 OffsetArray(::Array{Float64, 3}, 1:1, 1:1, -2:11) with eltype Float64 with indices 1:1×1:1×-2:11\n    └── max=0.5, min=0.0078125, mean=0.199219\n\njulia> C[1, 1, 8]\n0.5\n```\n" function CumulativeIntegral(field::AbstractField; dims, reverse = false, condition = nothing, mask = 0)
        #= none:166 =#
        #= none:167 =#
        dims ∈ (1, 2, 3) || throw(ArgumentError("CumulativeIntegral only supports dims=1, 2, or 3."))
        #= none:168 =#
        maybe_reverse_cumsum = if reverse
                reverse_cumsum!
            else
                cumsum!
            end
        #= none:169 =#
        dx = reduction_grid_metric(dims)
        #= none:170 =#
        operand = condition_operand(field * dx, condition, mask)
        #= none:171 =#
        return Scan(CumulativelyIntegrating(), maybe_reverse_cumsum, operand, dims)
    end