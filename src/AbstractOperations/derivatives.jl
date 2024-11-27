
#= none:1 =#
using Oceananigans.Operators: interpolation_code
#= none:3 =#
struct Derivative{LX, LY, LZ, D, A, IN, AD, G, T} <: AbstractOperation{LX, LY, LZ, G, T}
    #= none:4 =#
    ∂::D
    #= none:5 =#
    arg::A
    #= none:6 =#
    ▶::IN
    #= none:7 =#
    abstract_∂::AD
    #= none:8 =#
    grid::G
    #= none:10 =#
    #= none:10 =# @doc "    Derivative{LX, LY, LZ}(∂, arg, ▶, grid)\n\nReturn an abstract representation of the derivative `∂` on `arg`,\nand subsequent interpolation by `▶` on `grid`.\n" function Derivative{LX, LY, LZ}(∂::D, arg::A, ▶::IN, abstract_∂::AD, grid::G) where {LX, LY, LZ, D, A, IN, AD, G}
            #= none:16 =#
            #= none:18 =#
            T = eltype(grid)
            #= none:19 =#
            return new{LX, LY, LZ, D, A, IN, AD, G, T}(∂, arg, ▶, abstract_∂, grid)
        end
end
#= none:23 =#
#= none:23 =# @inline Base.getindex(d::Derivative, i, j, k) = begin
            #= none:23 =#
            d.▶(i, j, k, d.grid, d.∂, d.arg)
        end
#= none:29 =#
#= none:29 =# Core.@doc "Create a derivative operator `∂` acting on `arg` at `L∂`, followed by\ninterpolation to `L` on `grid`." function _derivative(L, ∂, arg, L∂, abstract_∂, grid)
        #= none:31 =#
        #= none:32 =#
        ▶ = interpolation_operator(L∂, L)
        #= none:33 =#
        return Derivative{L[1], L[2], L[3]}(∂, arg, ▶, abstract_∂, grid)
    end
#= none:36 =#
indices(d::Derivative) = begin
        #= none:36 =#
        indices(d.arg)
    end
#= none:39 =#
#= none:39 =# @inline at(loc, d::Derivative) = begin
            #= none:39 =#
            d.abstract_∂(loc, d.arg)
        end
#= none:41 =#
#= none:41 =# Core.@doc "Return `Center` if given `Face` or `Face` if given `Center`." flip(::Type{Face}) = begin
            #= none:42 =#
            Center
        end
#= none:43 =#
flip(::Type{Center}) = begin
        #= none:43 =#
        Face
    end
#= none:45 =#
const LocationType = Union{Type{Face}, Type{Center}, Type{Nothing}}
#= none:47 =#
#= none:47 =# Core.@doc "Return the ``x``-derivative function acting at (`X`, `Y`, `Any`)." ∂x(X::LocationType, Y::LocationType, Z::LocationType) = begin
            #= none:48 =#
            eval(Symbol(:∂x, interpolation_code(flip(X)), interpolation_code(Y), interpolation_code(Z)))
        end
#= none:50 =#
#= none:50 =# Core.@doc "Return the ``y``-derivative function acting at (`X`, `Y`, `Any`)." ∂y(X::LocationType, Y::LocationType, Z::LocationType) = begin
            #= none:51 =#
            eval(Symbol(:∂y, interpolation_code(X), interpolation_code(flip(Y)), interpolation_code(Z)))
        end
#= none:53 =#
#= none:53 =# Core.@doc "Return the ``z``-derivative function acting at (`Any`, `Any`, `Z`)." ∂z(X::LocationType, Y::LocationType, Z::LocationType) = begin
            #= none:54 =#
            eval(Symbol(:∂z, interpolation_code(X), interpolation_code(Y), interpolation_code(flip(Z))))
        end
#= none:56 =#
const derivative_operators = Set([:∂x, :∂y, :∂z])
#= none:57 =#
push!(operators, derivative_operators...)
#= none:59 =#
#= none:59 =# Core.@doc "    ∂x(L::Tuple, arg::AbstractField)\n\nReturn an abstract representation of an ``x``-derivative acting on field `arg` followed\nby interpolation to `L`, where `L` is a 3-tuple of `Face`s and `Center`s.\n" (∂x(L::Tuple, arg::AF{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:65 =#
            _derivative(L, ∂x(LX, LY, LZ), arg, (flip(LX), LY, LZ), ∂x, arg.grid)
        end
#= none:68 =#
#= none:68 =# Core.@doc "    ∂y(L::Tuple, arg::AbstractField)\n\nReturn an abstract representation of a ``y``-derivative acting on field `arg` followed\nby interpolation to `L`, where `L` is a 3-tuple of `Face`s and `Center`s.\n" (∂y(L::Tuple, arg::AF{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:74 =#
            _derivative(L, ∂y(LX, LY, LZ), arg, (LX, flip(LY), LZ), ∂y, arg.grid)
        end
#= none:77 =#
#= none:77 =# Core.@doc "    ∂z(L::Tuple, arg::AbstractField)\n\nReturn an abstract representation of a ``z``-derivative acting on field `arg` followed\nby  interpolation to `L`, where `L` is a 3-tuple of `Face`s and `Center`s.\n" (∂z(L::Tuple, arg::AF{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:83 =#
            _derivative(L, ∂z(LX, LY, LZ), arg, (LX, LY, flip(LZ)), ∂z, arg.grid)
        end
#= none:88 =#
#= none:88 =# Core.@doc "    ∂x(arg::AbstractField)\n\nReturn an abstract representation of a ``x``-derivative acting on field `arg`.\n" (∂x(arg::AF{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:93 =#
            ∂x((flip(LX), LY, LZ), arg)
        end
#= none:95 =#
#= none:95 =# Core.@doc "    ∂y(arg::AbstractField)\n\nReturn an abstract representation of a ``y``-derivative acting on field `arg`.\n" (∂y(arg::AF{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:100 =#
            ∂y((LX, flip(LY), LZ), arg)
        end
#= none:102 =#
#= none:102 =# Core.@doc "    ∂z(arg::AbstractField)\n\nReturn an abstract representation of a ``z``-derivative acting on field `arg`.\n" (∂z(arg::AF{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:107 =#
            ∂z((LX, LY, flip(LZ)), arg)
        end
#= none:113 =#
compute_at!(∂::Derivative, time) = begin
        #= none:113 =#
        compute_at!(∂.arg, time)
    end
#= none:121 =#
#= none:121 =# Core.@doc "Adapt `Derivative` to work on the GPU." (Adapt.adapt_structure(to, deriv::Derivative{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:122 =#
            Derivative{LX, LY, LZ}(Adapt.adapt(to, deriv.∂), Adapt.adapt(to, deriv.arg), Adapt.adapt(to, deriv.▶), nothing, Adapt.adapt(to, deriv.grid))
        end
#= none:129 =#
(on_architecture(to, deriv::Derivative{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:129 =#
        Derivative{LX, LY, LZ}(on_architecture(to, deriv.∂), on_architecture(to, deriv.arg), on_architecture(to, deriv.▶), deriv.abstract_∂, on_architecture(to, deriv.grid))
    end