
#= none:1 =#
using Printf
#= none:2 =#
using Oceananigans.Grids: size_summary
#= none:3 =#
using Oceananigans.Utils: prettysummary
#= none:4 =#
using Oceananigans.BoundaryConditions: bc_str
#= none:6 =#
import Oceananigans.Grids: grid_name
#= none:8 =#
location_str(::Type{Face}) = begin
        #= none:8 =#
        "Face"
    end
#= none:9 =#
location_str(::Type{Center}) = begin
        #= none:9 =#
        "Center"
    end
#= none:10 =#
location_str(::Type{Nothing}) = begin
        #= none:10 =#
        "⋅"
    end
#= none:11 =#
show_location(LX, LY, LZ) = begin
        #= none:11 =#
        "($(location_str(LX)), $(location_str(LY)), $(location_str(LZ)))"
    end
#= none:12 =#
show_location(field::AbstractField) = begin
        #= none:12 =#
        show_location(location(field)...)
    end
#= none:14 =#
grid_name(field::Field) = begin
        #= none:14 =#
        grid_name(field.grid)
    end
#= none:16 =#
function Base.summary(field::Field)
    #= none:16 =#
    #= none:17 =#
    (LX, LY, LZ) = location(field)
    #= none:18 =#
    prefix = string(size_summary(size(field)), " Field{$(LX), $(LY), $(LZ)}")
    #= none:20 =#
    reduced_dims = reduced_dimensions(field)
    #= none:22 =#
    suffix = if reduced_dims === ()
            string(" on ", grid_name(field), " on ", summary(architecture(field)))
        else
            string(" reduced over dims = ", reduced_dims, " on ", grid_name(field), " on ", summary(architecture(field)))
        end
    #= none:27 =#
    return string(prefix, suffix)
end
#= none:30 =#
data_summary(data) = begin
        #= none:30 =#
        string("max=", prettysummary(maximum(data)), ", ", "min=", prettysummary(minimum(data)), ", ", "mean=", prettysummary(mean(data)))
    end
#= none:34 =#
indices_summary(field) = begin
        #= none:34 =#
        replace(string(field.indices), "Colon()" => ":")
    end
#= none:36 =#
function Base.show(io::IO, field::Field)
    #= none:36 =#
    #= none:38 =#
    bcs = field.boundary_conditions
    #= none:40 =#
    prefix = string("$(summary(field))\n", "├── grid: ", summary(field.grid), "\n")
    #= none:43 =#
    bcs_str = if isnothing(bcs)
            "├── boundary conditions: Nothing \n"
        else
            string("├── boundary conditions: ", summary(bcs), "\n", "│   └── west: ", bc_str(bcs.west), ", east: ", bc_str(bcs.east), ", south: ", bc_str(bcs.south), ", north: ", bc_str(bcs.north), ", bottom: ", bc_str(bcs.bottom), ", top: ", bc_str(bcs.top), ", immersed: ", bc_str(bcs.immersed), "\n")
        end
    #= none:50 =#
    indices_str = if indices_summary(field) == "(:, :, :)"
            ""
        else
            string("├── indices: ", indices_summary(field), "\n")
        end
    #= none:54 =#
    operand_str = if isnothing(field.operand)
            ""
        else
            string("├── operand: ", summary(field.operand), "\n", "├── status: ", summary(field.status), "\n")
        end
    #= none:58 =#
    data_str = string("└── data: ", summary(field.data), "\n", "    └── ", data_summary(field))
    #= none:61 =#
    print(io, prefix, bcs_str, indices_str, operand_str, data_str)
end
#= none:64 =#
Base.summary(status::FieldStatus) = begin
        #= none:64 =#
        "time=$(status.time)"
    end
#= none:66 =#
(Base.summary(::ZeroField{N}) where N) = begin
        #= none:66 =#
        "ZeroField{$(N)}"
    end
#= none:67 =#
(Base.summary(::OneField{N}) where N) = begin
        #= none:67 =#
        "OneField{$(N)}"
    end
#= none:69 =#
Base.show(io::IO, z::Union{ZeroField, OneField}) = begin
        #= none:69 =#
        print(io, summary(z))
    end
#= none:71 =#
#= none:71 =# @inline Base.summary(f::CF) = begin
            #= none:71 =#
            string("ConstantField(", prettysummary(f.constant), ")")
        end
#= none:72 =#
Base.show(io::IO, f::CF) = begin
        #= none:72 =#
        print(io, summary(f))
    end
#= none:74 =#
Base.show(io::IO, ::MIME"text/plain", f::AbstractField) = begin
        #= none:74 =#
        show(io, f)
    end
#= none:76 =#
const FieldTuple = Tuple{Field, Vararg{Field}}
#= none:77 =#
const NamedFieldTuple = (NamedTuple{S, <:FieldTuple} where S)
#= none:79 =#
function Base.show(io::IO, ft::NamedFieldTuple)
    #= none:79 =#
    #= none:80 =#
    names = keys(ft)
    #= none:81 =#
    N = length(ft)
    #= none:83 =#
    grid = (first(ft)).grid
    #= none:84 =#
    all_same_grid = true
    #= none:85 =#
    for field = ft
        #= none:86 =#
        if field.grid !== grid
            #= none:87 =#
            all_same_grid = false
        end
        #= none:89 =#
    end
    #= none:91 =#
    print(io, "NamedTuple with ", N, " Fields ")
    #= none:93 =#
    if all_same_grid
        #= none:94 =#
        print(io, "on ", summary(grid), ":\n")
    else
        #= none:96 =#
        print(io, "on different grids:", "\n")
    end
    #= none:99 =#
    for name = names[1:end - 1]
        #= none:100 =#
        field = ft[name]
        #= none:101 =#
        print(io, "├── $(name): ", summary(field), "\n")
        #= none:103 =#
        if !all_same_grid
            #= none:104 =#
            print(io, "│   └── grid: ", summary(field.grid), "\n")
        end
        #= none:106 =#
    end
    #= none:108 =#
    name = names[end]
    #= none:109 =#
    field = ft[name]
    #= none:110 =#
    print(io, "└── $(name): ", summary(field))
    #= none:112 =#
    if !all_same_grid
        #= none:113 =#
        print(io, "\n")
        #= none:114 =#
        print(io, "    └── grid: ", summary(field.grid))
    end
end