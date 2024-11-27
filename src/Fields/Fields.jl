
#= none:1 =#
module Fields
#= none:1 =#
#= none:3 =#
export Face, Center
#= none:4 =#
export AbstractField, Field, Average, Integral, Reduction, Accumulation, field
#= none:5 =#
export CenterField, XFaceField, YFaceField, ZFaceField
#= none:6 =#
export BackgroundField
#= none:7 =#
export interior, data, xnode, ynode, znode, location
#= none:8 =#
export set!, compute!, @compute, regrid!
#= none:9 =#
export VelocityFields, TracerFields, TendencyFields, tracernames
#= none:10 =#
export interpolate
#= none:12 =#
using Oceananigans.Architectures
#= none:13 =#
using Oceananigans.Grids
#= none:14 =#
using Oceananigans.BoundaryConditions
#= none:15 =#
using Oceananigans.Utils
#= none:17 =#
import Oceananigans.Architectures: on_architecture
#= none:19 =#
include("abstract_field.jl")
#= none:20 =#
include("constant_field.jl")
#= none:21 =#
include("function_field.jl")
#= none:22 =#
include("field_boundary_buffers.jl")
#= none:23 =#
include("field.jl")
#= none:24 =#
include("scans.jl")
#= none:25 =#
include("regridding_fields.jl")
#= none:26 =#
include("field_tuples.jl")
#= none:27 =#
include("background_fields.jl")
#= none:28 =#
include("interpolate.jl")
#= none:29 =#
include("show_fields.jl")
#= none:30 =#
include("broadcasting_abstract_fields.jl")
#= none:32 =#
#= none:32 =# Core.@doc "    field(loc, a, grid)\n\nBuild a field from array `a` at `loc` and on `grid`.\n" #= none:37 =# @inline(function field(loc, a::AbstractArray, grid)
            #= none:37 =#
            #= none:38 =#
            f = Field(loc, grid)
            #= none:39 =#
            a = on_architecture(architecture(grid), a)
            #= none:40 =#
            try
                #= none:41 =#
                copyto!(parent(f), a)
            catch
                #= none:43 =#
                f .= a
            end
            #= none:45 =#
            return f
        end)
#= none:48 =#
#= none:48 =# @inline field(loc, a::Function, grid) = begin
            #= none:48 =#
            FunctionField(loc, a, grid)
        end
#= none:49 =#
#= none:49 =# @inline field(loc, a::Number, grid) = begin
            #= none:49 =#
            ConstantField(a)
        end
#= none:50 =#
#= none:50 =# @inline field(loc, a::ZeroField, grid) = begin
            #= none:50 =#
            a
        end
#= none:51 =#
#= none:51 =# @inline field(loc, a::ConstantField, grid) = begin
            #= none:51 =#
            a
        end
#= none:53 =#
#= none:53 =# @inline function field(loc, f::Field, grid)
        #= none:53 =#
        #= none:54 =#
        loc === location(f) && (grid === f.grid && return f)
        #= none:55 =#
        error("Cannot construct field at $(loc) and on $(grid) from $(f)")
    end
#= none:58 =#
include("set!.jl")
end