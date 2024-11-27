
#= none:1 =#
using Oceananigans.Utils: prettysummary
#= none:3 =#
struct FunctionField{LX, LY, LZ, C, P, F, G, T} <: AbstractField{LX, LY, LZ, G, T, 3}
    #= none:4 =#
    func::F
    #= none:5 =#
    grid::G
    #= none:6 =#
    clock::C
    #= none:7 =#
    parameters::P
    #= none:9 =#
    #= none:9 =# @doc "    FunctionField{LX, LY, LZ}(func, grid; clock=nothing, parameters=nothing) where {LX, LY, LZ}\n\nReturns a `FunctionField` on `grid` and at location `LX, LY, LZ`.\n\nIf `clock` is not specified, then `func` must be a function with signature\n`func(x, y, z)`. If clock is specified, `func` must be a function with signature\n`func(x, y, z, t)`, where `t` is internally determined from `clock.time`.\n\nA `FunctionField` will return the result of `func(x, y, z [, t])` at `LX, LY, LZ` on\n`grid` when indexed at `i, j, k`.\n" #= none:21 =# @inline(function FunctionField{LX, LY, LZ}(func::F, grid::G; clock::C = nothing, parameters::P = nothing) where {LX, LY, LZ, F, G, C, P}
                #= none:21 =#
                #= none:25 =#
                FT = eltype(grid)
                #= none:26 =#
                return new{LX, LY, LZ, C, P, F, G, FT}(func, grid, clock, parameters)
            end)
    #= none:29 =#
    #= none:29 =# @inline function FunctionField{LX, LY, LZ}(f::FunctionField, grid::G; clock::C = nothing) where {LX, LY, LZ, G, C}
            #= none:29 =#
            #= none:32 =#
            P = typeof(f.parameters)
            #= none:33 =#
            T = eltype(grid)
            #= none:34 =#
            F = typeof(f.func)
            #= none:35 =#
            return new{LX, LY, LZ, C, P, F, G, T}(f.func, grid, clock, f.parameters)
        end
end
#= none:39 =#
#= none:39 =# Core.@doc "Return `a`, or convert `a` to `FunctionField` if `a::Function`" fieldify_function(L, a, grid) = begin
            #= none:40 =#
            a
        end
#= none:41 =#
fieldify_function(L, a::Function, grid) = begin
        #= none:41 =#
        FunctionField(L, a, grid)
    end
#= none:44 =#
#= none:44 =# @inline FunctionField(L::Tuple, func, grid) = begin
            #= none:44 =#
            FunctionField{L[1], L[2], L[3]}(func, grid)
        end
#= none:46 =#
#= none:46 =# @inline indices(::FunctionField) = begin
            #= none:46 =#
            (:, :, :)
        end
#= none:49 =#
#= none:49 =# @inline call_func(clock, parameters, func, x...) = begin
            #= none:49 =#
            func(x..., clock.time, parameters)
        end
#= none:50 =#
#= none:50 =# @inline call_func(clock, ::Nothing, func, x...) = begin
            #= none:50 =#
            func(x..., clock.time)
        end
#= none:51 =#
#= none:51 =# @inline call_func(::Nothing, parameters, func, x...) = begin
            #= none:51 =#
            func(x..., parameters)
        end
#= none:52 =#
#= none:52 =# @inline call_func(::Nothing, ::Nothing, func, x...) = begin
            #= none:52 =#
            func(x...)
        end
#= none:54 =#
#= none:54 =# @inline (Base.getindex(f::FunctionField{LX, LY, LZ}, i, j, k) where {LX, LY, LZ}) = begin
            #= none:54 =#
            call_func(f.clock, f.parameters, f.func, node(i, j, k, f.grid, LX(), LY(), LZ())...)
        end
#= none:57 =#
#= none:57 =# @inline (f::FunctionField)(x...) = begin
            #= none:57 =#
            call_func(f.clock, f.parameters, f.func, x...)
        end
#= none:59 =#
(Adapt.adapt_structure(to, f::FunctionField{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:59 =#
        FunctionField{LX, LY, LZ}(Adapt.adapt(to, f.func), Adapt.adapt(to, f.grid), clock = Adapt.adapt(to, f.clock), parameters = Adapt.adapt(to, f.parameters))
    end
#= none:66 =#
(on_architecture(to, f::FunctionField{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:66 =#
        FunctionField{LX, LY, LZ}(on_architecture(to, f.func), on_architecture(to, f.grid), clock = on_architecture(to, f.clock), parameters = on_architecture(to, f.parameters))
    end
#= none:72 =#
Base.show(io::IO, field::FunctionField) = begin
        #= none:72 =#
        print(io, "FunctionField located at ", show_location(field), "\n", "├── func: $(prettysummary(field.func))", "\n", "├── grid: $(summary(field.grid))\n", "├── clock: $(summary(field.clock))\n", "└── parameters: $(field.parameters)")
    end