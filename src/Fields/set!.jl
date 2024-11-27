
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:2 =#
using KernelAbstractions: @kernel, @index
#= none:3 =#
using Adapt: adapt_structure
#= none:5 =#
using Oceananigans.Grids: on_architecture, node_names
#= none:6 =#
using Oceananigans.Architectures: child_architecture, device, GPU, CPU
#= none:7 =#
using Oceananigans.Utils: work_layout
#= none:13 =#
function tuple_string(tup::Tuple)
    #= none:13 =#
    #= none:14 =#
    str = prod((string(t, ", ") for t = tup))
    #= none:15 =#
    return str[1:end - 2]
end
#= none:18 =#
tuple_string(tup::Tuple{}) = begin
        #= none:18 =#
        ""
    end
#= none:24 =#
function set!(Φ::NamedTuple; kwargs...)
    #= none:24 =#
    #= none:25 =#
    for (fldname, value) = kwargs
        #= none:26 =#
        ϕ = getproperty(Φ, fldname)
        #= none:27 =#
        set!(ϕ, value)
        #= none:28 =#
    end
    #= none:29 =#
    return nothing
end
#= none:33 =#
set!(u::Field, f::Function) = begin
        #= none:33 =#
        set_to_function!(u, f)
    end
#= none:34 =#
set!(u::Field, a::Union{Array, GPUArrays.AbstractGPUArray, OffsetArray}) = begin
        #= none:34 =#
        set_to_array!(u, a)
    end
#= none:35 =#
set!(u::Field, v::Field) = begin
        #= none:35 =#
        set_to_field!(u, v)
    end
#= none:37 =#
function set!(u::Field, v)
    #= none:37 =#
    #= none:38 =#
    u .= v
    #= none:39 =#
    return u
end
#= none:46 =#
function set_to_function!(u, f)
    #= none:46 =#
    #= none:48 =#
    arch = child_architecture(u)
    #= none:51 =#
    if arch isa GPU
        #= none:52 =#
        cpu_grid = on_architecture(CPU(), u.grid)
        #= none:53 =#
        cpu_u = Field(location(u), cpu_grid; indices = indices(u))
    elseif #= none:54 =# arch isa CPU
        #= none:55 =#
        cpu_grid = u.grid
        #= none:56 =#
        cpu_u = u
    end
    #= none:60 =#
    f_field = field(location(u), f, cpu_grid)
    #= none:63 =#
    try
        #= none:64 =#
        set!(cpu_u, f_field)
    catch err
        #= none:66 =#
        u_loc = Tuple((L() for L = location(u)))
        #= none:68 =#
        arg_str = tuple_string(node_names(u.grid, u_loc...))
        #= none:69 =#
        loc_str = tuple_string(location(u))
        #= none:70 =#
        topo_str = tuple_string(topology(u.grid))
        #= none:72 =#
        msg = string("An error was encountered within set! while setting the field", '\n', '\n', "    ", prettysummary(u), '\n', '\n', "Note that to use set!(field, func::Function) on a field at location ", "(", loc_str, ")", '\n', "and on a grid with topology (", topo_str, "), func must be ", "callable via", '\n', '\n', "     func(", arg_str, ")", '\n')
        #= none:79 =#
        #= none:79 =# @warn msg
        #= none:80 =#
        throw(err)
    end
    #= none:84 =#
    if child_architecture(u) isa GPU
        #= none:85 =#
        set!(u, cpu_u)
    end
    #= none:88 =#
    return u
end
#= none:91 =#
function set_to_array!(u, f)
    #= none:91 =#
    #= none:92 =#
    f = on_architecture(architecture(u), f)
    #= none:94 =#
    try
        #= none:95 =#
        u .= f
    catch err
        #= none:97 =#
        if err isa DimensionMismatch
            #= none:98 =#
            (Nx, Ny, Nz) = size(u)
            #= none:99 =#
            u .= reshape(f, Nx, Ny, Nz)
            #= none:101 =#
            msg = string("Reshaped ", summary(f), " to set! its data to ", '\n', summary(u))
            #= none:104 =#
            #= none:104 =# @warn msg
        else
            #= none:106 =#
            throw(err)
        end
    end
    #= none:110 =#
    return u
end
#= none:113 =#
function set_to_field!(u, v)
    #= none:113 =#
    #= none:117 =#
    if child_architecture(u) === child_architecture(v)
        #= none:122 =#
        try
            #= none:123 =#
            parent(u) .= parent(v)
        catch
            #= none:126 =#
            interior(u) .= interior(v)
        end
    else
        #= none:129 =#
        v_data = on_architecture(child_architecture(u), v.data)
        #= none:132 =#
        try
            #= none:133 =#
            parent(u) .= parent(v_data)
        catch
            #= none:135 =#
            interior(u) .= interior(v_data, location(v), v.grid, v.indices)
        end
    end
    #= none:139 =#
    return u
end