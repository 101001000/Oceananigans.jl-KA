
#= none:1 =#
using Oceananigans.Utils: prettysummary
#= none:5 =#
function BackgroundVelocityFields(bg, grid, clock)
    #= none:5 =#
    #= none:6 =#
    u = if :u ∈ keys(bg)
            regularize_background_field(Face, Center, Center, bg[:u], grid, clock)
        else
            ZeroField()
        end
    #= none:7 =#
    v = if :v ∈ keys(bg)
            regularize_background_field(Center, Face, Center, bg[:v], grid, clock)
        else
            ZeroField()
        end
    #= none:8 =#
    w = if :w ∈ keys(bg)
            regularize_background_field(Center, Center, Face, bg[:w], grid, clock)
        else
            ZeroField()
        end
    #= none:10 =#
    return (u = u, v = v, w = w)
end
#= none:13 =#
function BackgroundTracerFields(bg, tracer_names, grid, clock)
    #= none:13 =#
    #= none:14 =#
    tracer_fields = Tuple((if c ∈ keys(bg)
                regularize_background_field(Center, Center, Center, getindex(bg, c), grid, clock)
            else
                ZeroField()
            end for c = tracer_names))
    #= none:20 =#
    return NamedTuple{tracer_names}(tracer_fields)
end
#= none:27 =#
function BackgroundFields(background_fields, tracer_names, grid, clock)
    #= none:27 =#
    #= none:28 =#
    velocities = BackgroundVelocityFields(background_fields, grid, clock)
    #= none:29 =#
    tracers = BackgroundTracerFields(background_fields, tracer_names, grid, clock)
    #= none:30 =#
    return (velocities = velocities, tracers = tracers)
end
#= none:33 =#
#= none:33 =# Core.@doc "    BackgroundField{F, P}\n\nTemporary container for storing information about `BackgroundFields`.\n" struct BackgroundField{F, P}
        #= none:39 =#
        func::F
        #= none:40 =#
        parameters::P
    end
#= none:43 =#
#= none:43 =# Core.@doc "    BackgroundField(func; parameters=nothing)\n\nReturns a `BackgroundField` to be passed to `NonhydrostaticModel` for use\nas a background velocity or tracer field.\n\nIf `parameters` is not provided, `func` must be callable with the signature\n\n```julia\nfunc(x, y, z, t)\n```\n\nIf `parameters` is provided, `func` must be callable with the signature\n\n```julia\nfunc(x, y, z, t, parameters)\n```\n" BackgroundField(func; parameters = nothing) = begin
            #= none:61 =#
            BackgroundField(func, parameters)
        end
#= none:63 =#
regularize_background_field(LX, LY, LZ, bf::BackgroundField{<:Number}, grid, clock) = begin
        #= none:63 =#
        ConstantField(bf.func)
    end
#= none:65 =#
regularize_background_field(LX, LY, LZ, f::BackgroundField{<:Function}, grid, clock) = begin
        #= none:65 =#
        FunctionField{LX, LY, LZ}(f.func, grid; clock = clock, parameters = f.parameters)
    end
#= none:68 =#
regularize_background_field(LX, LY, LZ, func::Function, grid, clock) = begin
        #= none:68 =#
        FunctionField{LX, LY, LZ}(func, grid; clock = clock)
    end
#= none:71 =#
function regularize_background_field(LX, LY, LZ, field::AbstractField, grid, clock)
    #= none:71 =#
    #= none:72 =#
    if location(field) != (LX, LY, LZ)
        #= none:73 =#
        throw(ArgumentError("Cannot use field at $(location(field)) as a background field at $((LX, LY, LZ))"))
    end
    #= none:76 =#
    return field
end
#= none:79 =#
(Base.show(io::IO, field::BackgroundField{F, P}) where {F, P}) = begin
        #= none:79 =#
        print(io, "BackgroundField{$(F), $(P)}", "\n", "├── func: $(prettysummary(field.func))", "\n", "└── parameters: $(field.parameters)")
    end