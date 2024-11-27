
#= none:1 =#
using Random
#= none:2 =#
using Oceananigans.Utils: instantiate
#= none:3 =#
using Oceananigans.Grids: Face, Center
#= none:7 =#
interpolation_code(from, to) = begin
        #= none:7 =#
        interpolation_code(to)
    end
#= none:9 =#
interpolation_code(::Type{Face}) = begin
        #= none:9 =#
        :ᶠ
    end
#= none:10 =#
interpolation_code(::Type{Center}) = begin
        #= none:10 =#
        :ᶜ
    end
#= none:11 =#
interpolation_code(::Type{Nothing}) = begin
        #= none:11 =#
        :ᶜ
    end
#= none:12 =#
interpolation_code(::Face) = begin
        #= none:12 =#
        :ᶠ
    end
#= none:13 =#
interpolation_code(::Center) = begin
        #= none:13 =#
        :ᶜ
    end
#= none:14 =#
interpolation_code(::Nothing) = begin
        #= none:14 =#
        :ᶜ
    end
#= none:17 =#
(interpolation_code(from::L, to::L) where L) = begin
        #= none:17 =#
        :ᵃ
    end
#= none:18 =#
interpolation_code(::Nothing, to) = begin
        #= none:18 =#
        :ᵃ
    end
#= none:19 =#
interpolation_code(from, ::Nothing) = begin
        #= none:19 =#
        :ᵃ
    end
#= none:20 =#
interpolation_code(::Nothing, ::Nothing) = begin
        #= none:20 =#
        :ᵃ
    end
#= none:22 =#
for ξ = ("x", "y", "z")
    #= none:23 =#
    ▶sym = Symbol(:ℑ, ξ, :sym)
    #= none:24 =#
    #= none:24 =# @eval begin
            #= none:25 =#
            $▶sym(s::Symbol) = begin
                    #= none:25 =#
                    $▶sym(Val(s))
                end
            #= none:26 =#
            $▶sym(::Union{Val{:ᶠ}, Val{:ᶜ}}) = begin
                    #= none:26 =#
                    $ξ
                end
            #= none:27 =#
            $▶sym(::Val{:ᵃ}) = begin
                    #= none:27 =#
                    ""
                end
        end
    #= none:29 =#
end
#= none:33 =#
const number_of_identities = 6
#= none:35 =#
for i = 1:number_of_identities
    #= none:36 =#
    identity = Symbol(:identity, i)
    #= none:38 =#
    #= none:38 =# @eval begin
            #= none:39 =#
            #= none:39 =# @inline $identity(i, j, k, grid, c) = begin
                        #= none:39 =#
                        #= none:39 =# @inbounds c[i, j, k]
                    end
            #= none:40 =#
            #= none:40 =# @inline $identity(i, j, k, grid, a::Number) = begin
                        #= none:40 =#
                        a
                    end
            #= none:41 =#
            #= none:41 =# @inline ($identity(i, j, k, grid, F::TF, args...) where TF <: Function) = begin
                        #= none:41 =#
                        F(i, j, k, grid, args...)
                    end
        end
    #= none:43 =#
end
#= none:45 =#
torus(x, lower, upper) = begin
        #= none:45 =#
        lower + rem(x - lower, upper - lower, RoundDown)
    end
#= none:46 =#
identify_an_identity(number) = begin
        #= none:46 =#
        Symbol(:identity, torus(number, 1, number_of_identities))
    end
#= none:47 =#
identity_counter = 0
#= none:49 =#
#= none:49 =# Core.@doc "    interpolation_operator(from, to)\n\nReturns the function to interpolate a field `from = (XA, YZ, ZA)`, `to = (XB, YB, ZB)`,\nwhere the `XA`s and `XB`s are `Face()` or `Center()` instances.\n" function interpolation_operator(from, to)
        #= none:55 =#
        #= none:56 =#
        (from, to) = (instantiate.(from), instantiate.(to))
        #= none:57 =#
        (x, y, z) = (interpolation_code(X, Y) for (X, Y) = zip(from, to))
        #= none:59 =#
        if all((ξ === :ᵃ for ξ = (x, y, z)))
            #= none:62 =#
            global identity_counter += 1
            #= none:63 =#
            identity = identify_an_identity(identity_counter)
            #= none:65 =#
            return getglobal(#= none:65 =# @__MODULE__(), identity)
        else
            #= none:67 =#
            return getglobal(#= none:67 =# @__MODULE__(), Symbol(:ℑ, ℑxsym(x), ℑysym(y), ℑzsym(z), x, y, z))
        end
    end
#= none:71 =#
#= none:71 =# Core.@doc "    interpolation_operator(::Nothing, to)\n\nReturn the `identity` interpolator function. This is needed to obtain the interpolation\noperator for fields that have no intrinsic location, like numbers or functions.\n" function interpolation_operator(::Nothing, to)
        #= none:77 =#
        #= none:78 =#
        global identity_counter += 1
        #= none:79 =#
        identity = identify_an_identity(identity_counter)
        #= none:80 =#
        return getglobal(#= none:80 =# @__MODULE__(), identity)
    end
#= none:83 =#
assumed_field_location(name) = begin
        #= none:83 =#
        if name === :u
            (Face, Center, Center)
        else
            if name === :v
                (Center, Face, Center)
            else
                if name === :w
                    (Center, Center, Face)
                else
                    if name === :uh
                        (Face, Center, Center)
                    else
                        if name === :vh
                            (Center, Face, Center)
                        else
                            (Center, Center, Center)
                        end
                    end
                end
            end
        end
    end
#= none:90 =#
#= none:90 =# Core.@doc "    index_and_interp_dependencies(X, Y, Z, dependencies, model_field_names)\n\nReturns a tuple of indices and interpolation functions to the location `X, Y, Z`\nfor each name in `dependencies`.\n\nThe indices correspond to the position of each dependency within `model_field_names`.\n\nThe interpolation functions interpolate the dependent field to `X, Y, Z`.\n" function index_and_interp_dependencies(X, Y, Z, dependencies, model_field_names)
        #= none:100 =#
        #= none:101 =#
        interps = Tuple((interpolation_operator(assumed_field_location(name), (X, Y, Z)) for name = dependencies))
        #= none:104 =#
        indices = ntuple(length(dependencies)) do i
                #= none:105 =#
                name = dependencies[i]
                #= none:106 =#
                findfirst(isequal(name), model_field_names)
            end
        #= none:109 =#
        !(any(isnothing.(indices))) || error("$(dependencies) are required to be model fields but only $(model_field_names) are present")
        #= none:111 =#
        return (indices, interps)
    end
#= none:115 =#
for LX = (:Center, :Face), LY = (:Center, :Face), LZ = (:Center, :Face)
    #= none:116 =#
    for IX = (:Center, :Face), IY = (:Center, :Face), IZ = (:Center, :Face)
        #= none:117 =#
        from = (eval(LX), eval(LY), eval(LZ))
        #= none:118 =#
        to = (eval(IX), eval(IY), eval(IZ))
        #= none:119 =#
        interp_func = Symbol(interpolation_operator(from, to))
        #= none:120 =#
        #= none:120 =# @eval begin
                #= none:121 =#
                #= none:121 =# @inline (ℑxyz(i, j, k, grid, from::F, to::T, c) where {F <: Tuple{<:$LX, <:$LY, <:$LZ}, T <: Tuple{<:$IX, <:$IY, <:$IZ}}) = begin
                            #= none:121 =#
                            $interp_func(i, j, k, grid, c)
                        end
                #= none:124 =#
                #= none:124 =# @inline (ℑxyz(i, j, k, grid, from::F, to::T, f, args...) where {F <: Tuple{<:$LX, <:$LY, <:$LZ}, T <: Tuple{<:$IX, <:$IY, <:$IZ}}) = begin
                            #= none:124 =#
                            $interp_func(i, j, k, grid, f, args...)
                        end
            end
        #= none:127 =#
    end
    #= none:128 =#
end