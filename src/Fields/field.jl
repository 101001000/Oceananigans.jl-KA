
#= none:1 =#
using Oceananigans.BoundaryConditions: OBC, MCBC, BoundaryCondition
#= none:2 =#
using Oceananigans.Grids: parent_index_range, index_range_offset, default_indices, all_indices, validate_indices
#= none:3 =#
using Oceananigans.Grids: index_range_contains
#= none:5 =#
using Adapt
#= none:6 =#
using KernelAbstractions: @kernel, @index
#= none:7 =#
using Base: @propagate_inbounds
#= none:9 =#
import Oceananigans: boundary_conditions
#= none:10 =#
import Oceananigans.Architectures: on_architecture
#= none:11 =#
import Oceananigans.BoundaryConditions: fill_halo_regions!, getbc
#= none:12 =#
import Statistics: norm, mean, mean!
#= none:13 =#
import Base: ==
#= none:19 =#
struct Field{LX, LY, LZ, O, G, I, D, T, B, S, F} <: AbstractField{LX, LY, LZ, G, T, 3}
    #= none:20 =#
    grid::G
    #= none:21 =#
    data::D
    #= none:22 =#
    boundary_conditions::B
    #= none:23 =#
    indices::I
    #= none:24 =#
    operand::O
    #= none:25 =#
    status::S
    #= none:26 =#
    boundary_buffers::F
    #= none:29 =#
    function Field{LX, LY, LZ}(grid::G, data::D, bcs::B, indices::I, op::O, status::S, buffers::F) where {LX, LY, LZ, G, D, B, O, S, I, F}
        #= none:29 =#
        #= none:30 =#
        T = eltype(data)
        #= none:31 =#
        return new{LX, LY, LZ, O, G, I, D, T, B, S, F}(grid, data, bcs, indices, op, status, buffers)
    end
end
#= none:39 =#
function validate_field_data(loc, data, grid, indices)
    #= none:39 =#
    #= none:40 =#
    (Fx, Fy, Fz) = total_size(grid, loc, indices)
    #= none:42 =#
    if size(data) != (Fx, Fy, Fz)
        #= none:43 =#
        (LX, LY, LZ) = loc
        #= none:44 =#
        e = "Cannot construct field at ($(LX), $(LY), $(LZ)) with size(data)=$(size(data)). " * "`data` must have size ($(Fx), $(Fy), $(Fz))."
        #= none:46 =#
        throw(ArgumentError(e))
    end
    #= none:49 =#
    return nothing
end
#= none:52 =#
validate_boundary_condition_location(bc, ::Center, side) = begin
        #= none:52 =#
        nothing
    end
#= none:53 =#
validate_boundary_condition_location(::Union{OBC, Nothing, MCBC}, ::Face, side) = begin
        #= none:53 =#
        nothing
    end
#= none:54 =#
validate_boundary_condition_location(::Nothing, ::Nothing, side) = begin
        #= none:54 =#
        nothing
    end
#= none:55 =#
validate_boundary_condition_location(bc, loc, side) = begin
        #= none:55 =#
        throw(ArgumentError("Cannot specify $(side) boundary condition $(bc) on a field at $(loc)!"))
    end
#= none:58 =#
validate_boundary_conditions(loc, grid, ::Missing) = begin
        #= none:58 =#
        nothing
    end
#= none:59 =#
validate_boundary_conditions(loc, grid, ::Nothing) = begin
        #= none:59 =#
        nothing
    end
#= none:61 =#
function validate_boundary_conditions(loc, grid, bcs)
    #= none:61 =#
    #= none:62 =#
    sides = (:east, :west, :north, :south, :bottom, :top)
    #= none:63 =#
    directions = (1, 1, 2, 2, 3, 3)
    #= none:65 =#
    for (side, dir) = zip(sides, directions)
        #= none:66 =#
        topo = (topology(grid, dir))()
        #= none:67 =#
        ℓ = (loc[dir])()
        #= none:68 =#
        bc = getproperty(bcs, side)
        #= none:71 =#
        validate_boundary_condition_topology(bc, topo, side)
        #= none:74 =#
        topo isa Bounded && validate_boundary_condition_location(bc, ℓ, side)
        #= none:77 =#
        validate_boundary_condition_architecture(bc, architecture(grid), side)
        #= none:78 =#
    end
    #= none:80 =#
    return nothing
end
#= none:88 =#
function Field(loc::Tuple, grid::AbstractGrid, data, bcs, indices, op = nothing, status = nothing)
    #= none:88 =#
    #= none:89 =#
    #= none:89 =# @apply_regionally indices = validate_indices(indices, loc, grid)
    #= none:90 =#
    #= none:90 =# @apply_regionally validate_field_data(loc, data, grid, indices)
    #= none:91 =#
    #= none:91 =# @apply_regionally validate_boundary_conditions(loc, grid, bcs)
    #= none:92 =#
    buffers = FieldBoundaryBuffers(grid, data, bcs)
    #= none:93 =#
    (LX, LY, LZ) = loc
    #= none:94 =#
    return Field{LX, LY, LZ}(grid, data, bcs, indices, op, status, buffers)
end
#= none:97 =#
#= none:97 =# Core.@doc "    Field{LX, LY, LZ}(grid::AbstractGrid,\n                      T::DataType=eltype(grid); kw...) where {LX, LY, LZ}\n\nConstruct a `Field` on `grid` with data type `T` at the location `(LX, LY, LZ)`.\nEach of `(LX, LY, LZ)` is either `Center` or `Face` and determines the field's\nlocation in `(x, y, z)` respectively.\n\nKeyword arguments\n=================\n\n- `data :: OffsetArray`: An offset array with the fields data. If nothing is provided the\n  field is filled with zeros.\n- `boundary_conditions`: If nothing is provided, then field is created using the default\n  boundary conditions via [`FieldBoundaryConditions`](@ref).\n- `indices`: Used to prescribe where a reduced field lives on. For example, at which `k` index\n  does a two-dimensional ``x``-``y`` field lives on. Default: `(:, :, :)`.\n\nExample\n=======\n\nA field at location `(Face, Face, Center)`.\n\n```jldoctest fields\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=(2, 3, 4), extent=(1, 1, 1));\n\njulia> ω = Field{Face, Face, Center}(grid)\n2×3×4 Field{Face, Face, Center} on RectilinearGrid on CPU\n├── grid: 2×3×4 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 2×3×3 halo\n├── boundary conditions: FieldBoundaryConditions\n│   └── west: Periodic, east: Periodic, south: Periodic, north: Periodic, bottom: ZeroFlux, top: ZeroFlux, immersed: ZeroFlux\n└── data: 6×9×10 OffsetArray(::Array{Float64, 3}, -1:4, -2:6, -2:7) with eltype Float64 with indices -1:4×-2:6×-2:7\n    └── max=0.0, min=0.0, mean=0.0\n```\n\nNow, using `indices` we can create a two dimensional ``x``-``y`` field at location\n`(Face, Face, Center)` to compute, e.g., the vertical vorticity ``∂v/∂x - ∂u/∂y``\nat the fluid's surface ``z = 0``, which for `Center` corresponds to `k = Nz`.\n\n```jldoctest fields\njulia> u = XFaceField(grid); v = YFaceField(grid);\n\njulia> ωₛ = Field(∂x(v) - ∂y(u), indices=(:, :, grid.Nz))\n2×3×1 Field{Face, Face, Center} on RectilinearGrid on CPU\n├── grid: 2×3×4 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 2×3×3 halo\n├── boundary conditions: FieldBoundaryConditions\n│   └── west: Periodic, east: Periodic, south: Periodic, north: Periodic, bottom: Nothing, top: Nothing, immersed: ZeroFlux\n├── indices: (:, :, 4:4)\n├── operand: BinaryOperation at (Face, Face, Center)\n├── status: time=0.0\n└── data: 6×9×1 OffsetArray(::Array{Float64, 3}, -1:4, -2:6, 4:4) with eltype Float64 with indices -1:4×-2:6×4:4\n    └── max=0.0, min=0.0, mean=0.0\n\njulia> compute!(ωₛ)\n2×3×1 Field{Face, Face, Center} on RectilinearGrid on CPU\n├── grid: 2×3×4 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 2×3×3 halo\n├── boundary conditions: FieldBoundaryConditions\n│   └── west: Periodic, east: Periodic, south: Periodic, north: Periodic, bottom: Nothing, top: Nothing, immersed: ZeroFlux\n├── indices: (:, :, 4:4)\n├── operand: BinaryOperation at (Face, Face, Center)\n├── status: time=0.0\n└── data: 6×9×1 OffsetArray(::Array{Float64, 3}, -1:4, -2:6, 4:4) with eltype Float64 with indices -1:4×-2:6×4:4\n    └── max=0.0, min=0.0, mean=0.0\n```\n" function Field{LX, LY, LZ}(grid::AbstractGrid, T::DataType = eltype(grid); kw...) where {LX, LY, LZ}
        #= none:164 =#
        #= none:168 =#
        return Field((LX, LY, LZ), grid, T; kw...)
    end
#= none:171 =#
function Field(loc::Tuple, grid::AbstractGrid, T::DataType = eltype(grid); indices = default_indices(3), data = new_data(T, grid, loc, validate_indices(indices, loc, grid)), boundary_conditions = FieldBoundaryConditions(grid, loc, validate_indices(indices, loc, grid)), operand = nothing, status = nothing)
    #= none:171 =#
    #= none:180 =#
    return Field(loc, grid, data, boundary_conditions, indices, operand, status)
end
#= none:183 =#
Field(z::ZeroField; kw...) = begin
        #= none:183 =#
        z
    end
#= none:184 =#
Field(f::Field; indices = f.indices) = begin
        #= none:184 =#
        view(f, indices...)
    end
#= none:186 =#
#= none:186 =# Core.@doc "    CenterField(grid, T=eltype(grid); kw...)\n\nReturn a `Field{Center, Center, Center}` on `grid`.\nAdditional keyword arguments are passed to the `Field` constructor.\n" CenterField(grid::AbstractGrid, T::DataType = eltype(grid); kw...) = begin
            #= none:192 =#
            Field((Center, Center, Center), grid, T; kw...)
        end
#= none:194 =#
#= none:194 =# Core.@doc "    XFaceField(grid, T=eltype(grid); kw...)\n\nReturn a `Field{Face, Center, Center}` on `grid`.\nAdditional keyword arguments are passed to the `Field` constructor.\n" XFaceField(grid::AbstractGrid, T::DataType = eltype(grid); kw...) = begin
            #= none:200 =#
            Field((Face, Center, Center), grid, T; kw...)
        end
#= none:202 =#
#= none:202 =# Core.@doc "    YFaceField(grid, T=eltype(grid); kw...)\n\nReturn a `Field{Center, Face, Center}` on `grid`.\nAdditional keyword arguments are passed to the `Field` constructor.\n" YFaceField(grid::AbstractGrid, T::DataType = eltype(grid); kw...) = begin
            #= none:208 =#
            Field((Center, Face, Center), grid, T; kw...)
        end
#= none:210 =#
#= none:210 =# Core.@doc "    ZFaceField(grid, T=eltype(grid); kw...)\n\nReturn a `Field{Center, Center, Face}` on `grid`.\nAdditional keyword arguments are passed to the `Field` constructor.\n" ZFaceField(grid::AbstractGrid, T::DataType = eltype(grid); kw...) = begin
            #= none:216 =#
            Field((Center, Center, Face), grid, T; kw...)
        end
#= none:223 =#
function Base.similar(f::Field, grid = f.grid)
    #= none:223 =#
    #= none:224 =#
    loc = location(f)
    #= none:225 =#
    return Field(loc, grid, new_data(eltype(grid), grid, loc, f.indices), FieldBoundaryConditions(grid, loc, f.indices), f.indices, f.operand, deepcopy(f.status))
end
#= none:234 =#
#= none:234 =# Core.@doc "    offset_windowed_data(data, data_indices, loc, grid, view_indices)\n\nReturn an `OffsetArray` of `parent(data)`.\n\nIf `indices` is not (:, :, :), a `view` of `parent(data)` with `indices`.\n\nIf `indices === (:, :, :)`, return an `OffsetArray` of `parent(data)`.\n" function offset_windowed_data(data, data_indices, Loc, grid, view_indices)
        #= none:243 =#
        #= none:244 =#
        halo = halo_size(grid)
        #= none:245 =#
        topo = map(instantiate, topology(grid))
        #= none:246 =#
        loc = map(instantiate, Loc)
        #= none:248 =#
        parent_indices = map(parent_index_range, data_indices, view_indices, loc, topo, halo)
        #= none:249 =#
        windowed_parent = view(parent(data), parent_indices...)
        #= none:251 =#
        sz = size(grid)
        #= none:252 =#
        return offset_data(windowed_parent, loc, topo, sz, halo, view_indices)
    end
#= none:255 =#
convert_colon_indices(view_indices, field_indices) = begin
        #= none:255 =#
        view_indices
    end
#= none:256 =#
convert_colon_indices(::Colon, field_indices) = begin
        #= none:256 =#
        field_indices
    end
#= none:258 =#
#= none:258 =# Core.@doc "    view(f::Field, indices...)\n\nReturns a `Field` with `indices`, whose `data` is\na view into `f`, offset to preserve index meaning.\n\nExample\n=======\n\n```@meta\nDocTestSetup = quote\n   using Random\n   Random.seed!(1234)\nend\n```\n\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=(2, 3, 4), x=(0, 1), y=(0, 1), z=(0, 1));\n\njulia> c = CenterField(grid)\n2×3×4 Field{Center, Center, Center} on RectilinearGrid on CPU\n├── grid: 2×3×4 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 2×3×3 halo\n├── boundary conditions: FieldBoundaryConditions\n│   └── west: Periodic, east: Periodic, south: Periodic, north: Periodic, bottom: ZeroFlux, top: ZeroFlux, immersed: ZeroFlux\n└── data: 6×9×10 OffsetArray(::Array{Float64, 3}, -1:4, -2:6, -2:7) with eltype Float64 with indices -1:4×-2:6×-2:7\n    └── max=0.0, min=0.0, mean=0.0\n\njulia> c .= rand(size(c)...);\n\njulia> v = view(c, :, 2:3, 1:2)\n2×2×2 Field{Center, Center, Center} on RectilinearGrid on CPU\n├── grid: 2×3×4 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 2×3×3 halo\n├── boundary conditions: FieldBoundaryConditions\n│   └── west: Periodic, east: Periodic, south: Nothing, north: Nothing, bottom: Nothing, top: Nothing, immersed: ZeroFlux\n├── indices: (:, 2:3, 1:2)\n└── data: 6×2×2 OffsetArray(view(::Array{Float64, 3}, :, 5:6, 4:5), -1:4, 2:3, 1:2) with eltype Float64 with indices -1:4×2:3×1:2\n    └── max=0.972136, min=0.0149088, mean=0.59198\n\njulia> size(v)\n(2, 2, 2)\n\njulia> v[2, 2, 2] == c[2, 2, 2]\ntrue\n```\n" function Base.view(f::Field, i, j, k)
        #= none:305 =#
        #= none:306 =#
        grid = f.grid
        #= none:307 =#
        loc = location(f)
        #= none:310 =#
        view_indices = ((i, j, k) = validate_indices((i, j, k), loc, f.grid))
        #= none:312 =#
        if view_indices == f.indices
            #= none:313 =#
            return f
        end
        #= none:317 =#
        valid_view_indices = map(index_range_contains, f.indices, view_indices)
        #= none:319 =#
        all(valid_view_indices) || throw(ArgumentError("view indices $((i, j, k)) do not intersect field indices $(f.indices)"))
        #= none:322 =#
        view_indices = map(convert_colon_indices, view_indices, f.indices)
        #= none:330 =#
        windowed_data = offset_windowed_data(f.data, f.indices, loc, grid, view_indices)
        #= none:332 =#
        boundary_conditions = FieldBoundaryConditions(view_indices, f.boundary_conditions)
        #= none:337 =#
        status = nothing
        #= none:339 =#
        return Field(loc, grid, windowed_data, boundary_conditions, view_indices, f.operand, status)
    end
#= none:348 =#
const WindowedData = OffsetArray{<:Any, <:Any, <:SubArray}
#= none:349 =#
const WindowedField = Field{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:WindowedData}
#= none:352 =#
Base.view(f::Field, I::Vararg{Colon}) = begin
        #= none:352 =#
        f
    end
#= none:353 =#
Base.view(f::Field, i) = begin
        #= none:353 =#
        view(f, i, :, :)
    end
#= none:354 =#
Base.view(f::Field, i, j) = begin
        #= none:354 =#
        view(f, i, j, :)
    end
#= none:356 =#
boundary_conditions(not_field) = begin
        #= none:356 =#
        nothing
    end
#= none:358 =#
#= none:358 =# @inline boundary_conditions(f::Field) = begin
            #= none:358 =#
            f.boundary_conditions
        end
#= none:359 =#
#= none:359 =# @inline boundary_conditions(w::WindowedField) = begin
            #= none:359 =#
            FieldBoundaryConditions(w.indices, w.boundary_conditions)
        end
#= none:361 =#
immersed_boundary_condition(f::Field) = begin
        #= none:361 =#
        f.boundary_conditions.immersed
    end
#= none:362 =#
data(field::Field) = begin
        #= none:362 =#
        field.data
    end
#= none:363 =#
indices(obj, i = default_indices(3)) = begin
        #= none:363 =#
        i
    end
#= none:364 =#
indices(f::Field, i = default_indices(3)) = begin
        #= none:364 =#
        f.indices
    end
#= none:365 =#
indices(a::SubArray, i = default_indices(ndims(a))) = begin
        #= none:365 =#
        a.indices
    end
#= none:366 =#
indices(a::OffsetArray, i = default_indices(ndims(a))) = begin
        #= none:366 =#
        indices(parent(a), i)
    end
#= none:368 =#
#= none:368 =# Core.@doc "Return indices that create a `view` over the interior of a Field." interior_view_indices(field_indices, interior_indices) = begin
            #= none:369 =#
            Colon()
        end
#= none:370 =#
interior_view_indices(::Colon, interior_indices) = begin
        #= none:370 =#
        interior_indices
    end
#= none:372 =#
instantiate(T::Type) = begin
        #= none:372 =#
        T()
    end
#= none:373 =#
instantiate(t) = begin
        #= none:373 =#
        t
    end
#= none:375 =#
function interior(a::OffsetArray, Loc::Tuple, Topo::Tuple, sz::NTuple{N, Int}, halo_sz::NTuple{N, Int}, ind::Tuple = default_indices(3)) where N
    #= none:375 =#
    #= none:382 =#
    loc = map(instantiate, Loc)
    #= none:383 =#
    topo = map(instantiate, Topo)
    #= none:384 =#
    i_interior = map(interior_parent_indices, loc, topo, sz, halo_sz)
    #= none:385 =#
    i_view = map(interior_view_indices, ind, i_interior)
    #= none:386 =#
    return view(parent(a), i_view...)
end
#= none:389 =#
#= none:389 =# Core.@doc "    interior(f::Field)\n\nReturn a view of `f` that excludes halo points.\n" interior(f::Field) = begin
            #= none:394 =#
            interior(f.data, location(f), f.grid, f.indices)
        end
#= none:395 =#
interior(a::OffsetArray, loc, grid, indices) = begin
        #= none:395 =#
        interior(a, loc, topology(grid), size(grid), halo_size(grid), indices)
    end
#= none:396 =#
interior(f::Field, I...) = begin
        #= none:396 =#
        view(interior(f), I...)
    end
#= none:399 =#
Base.checkbounds(f::Field, I...) = begin
        #= none:399 =#
        Base.checkbounds(f.data, I...)
    end
#= none:401 =#
#= none:401 =# @propagate_inbounds Base.getindex(f::Field, inds...) = begin
            #= none:401 =#
            getindex(f.data, inds...)
        end
#= none:402 =#
#= none:402 =# @propagate_inbounds Base.getindex(f::Field, i::Int) = begin
            #= none:402 =#
            (parent(f))[i]
        end
#= none:403 =#
#= none:403 =# @propagate_inbounds Base.setindex!(f::Field, val, i, j, k) = begin
            #= none:403 =#
            setindex!(f.data, val, i, j, k)
        end
#= none:404 =#
#= none:404 =# @propagate_inbounds Base.lastindex(f::Field) = begin
            #= none:404 =#
            lastindex(f.data)
        end
#= none:405 =#
#= none:405 =# @propagate_inbounds Base.lastindex(f::Field, dim) = begin
            #= none:405 =#
            lastindex(f.data, dim)
        end
#= none:407 =#
Base.fill!(f::Field, val) = begin
        #= none:407 =#
        fill!(parent(f), val)
    end
#= none:408 =#
Base.parent(f::Field) = begin
        #= none:408 =#
        parent(f.data)
    end
#= none:409 =#
Adapt.adapt_structure(to, f::Field) = begin
        #= none:409 =#
        Adapt.adapt(to, f.data)
    end
#= none:411 =#
total_size(f::Field) = begin
        #= none:411 =#
        total_size(f.grid, location(f), f.indices)
    end
#= none:412 =#
#= none:412 =# @inline Base.size(f::Field) = begin
            #= none:412 =#
            size(f.grid, location(f), f.indices)
        end
#= none:414 =#
f::Field == a = begin
        #= none:414 =#
        interior(f) == a
    end
#= none:415 =#
a == f::Field = begin
        #= none:415 =#
        a == interior(f)
    end
#= none:416 =#
a::Field == b::Field = begin
        #= none:416 =#
        interior(a) == interior(b)
    end
#= none:422 =#
(on_architecture(arch, field::AbstractField{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:422 =#
        Field{LX, LY, LZ}(on_architecture(arch, field.grid), on_architecture(arch, field.data), on_architecture(arch, field.boundary_conditions), on_architecture(arch, field.indices), on_architecture(arch, field.operand), on_architecture(arch, field.status), on_architecture(arch, field.boundary_buffers))
    end
#= none:435 =#
#= none:435 =# Core.@doc "    compute!(field)\n\nComputes `field.data` from `field.operand`.\n" compute!(field, time = nothing) = begin
            #= none:440 =#
            field
        end
#= none:442 =#
compute!(collection::Union{Tuple, NamedTuple}) = begin
        #= none:442 =#
        map(compute!, collection)
    end
#= none:444 =#
#= none:444 =# Core.@doc "    @compute(exprs...)\n\nCall `compute!` on fields after defining them.\n" macro compute(def)
        #= none:449 =#
        #= none:450 =#
        expr = Expr(:block)
        #= none:451 =#
        field = def.args[1]
        #= none:452 =#
        push!(expr.args, :($(esc(def))))
        #= none:453 =#
        push!(expr.args, :(compute!($(esc(field)))))
        #= none:454 =#
        return expr
    end
#= none:458 =#
mutable struct FieldStatus{T}
    #= none:459 =#
    time::T
end
#= none:462 =#
FieldStatus() = begin
        #= none:462 =#
        FieldStatus(0.0)
    end
#= none:463 =#
Adapt.adapt_structure(to, status::FieldStatus) = begin
        #= none:463 =#
        (; time = status.time)
    end
#= none:465 =#
#= none:465 =# Core.@doc "    compute_at!(field, time)\n\nComputes `field.data` at `time`. Falls back to compute!(field).\n" compute_at!(field, time) = begin
            #= none:470 =#
            compute!(field)
        end
#= none:472 =#
#= none:472 =# Core.@doc "    compute_at!(field, time)\n\nComputes `field.data` if `time != field.status.time`.\n" function compute_at!(field::Field, time)
        #= none:477 =#
        #= none:478 =#
        if isnothing(field.status)
            #= none:479 =#
            compute!(field, time)
        elseif #= none:482 =# time == zero(time) || time != field.status.time
            #= none:483 =#
            compute!(field, time)
            #= none:484 =#
            field.status.time = time
        end
        #= none:487 =#
        return field
    end
#= none:492 =#
compute_at!(field::Field, ::Nothing) = begin
        #= none:492 =#
        compute!(field, nothing)
    end
#= none:498 =#
const XReducedField = Field{Nothing}
#= none:499 =#
const YReducedField = Field{<:Any, Nothing}
#= none:500 =#
const ZReducedField = Field{<:Any, <:Any, Nothing}
#= none:502 =#
const YZReducedField = Field{<:Any, Nothing, Nothing}
#= none:503 =#
const XZReducedField = Field{Nothing, <:Any, Nothing}
#= none:504 =#
const XYReducedField = Field{Nothing, Nothing, <:Any}
#= none:506 =#
const XYZReducedField = Field{Nothing, Nothing, Nothing}
#= none:508 =#
const ReducedField = Union{XReducedField, YReducedField, ZReducedField, YZReducedField, XZReducedField, XYReducedField, XYZReducedField}
#= none:516 =#
reduced_dimensions(field::Field) = begin
        #= none:516 =#
        ()
    end
#= none:517 =#
reduced_dimensions(field::XReducedField) = begin
        #= none:517 =#
        tuple(1)
    end
#= none:518 =#
reduced_dimensions(field::YReducedField) = begin
        #= none:518 =#
        tuple(2)
    end
#= none:519 =#
reduced_dimensions(field::ZReducedField) = begin
        #= none:519 =#
        tuple(3)
    end
#= none:520 =#
reduced_dimensions(field::YZReducedField) = begin
        #= none:520 =#
        (2, 3)
    end
#= none:521 =#
reduced_dimensions(field::XZReducedField) = begin
        #= none:521 =#
        (1, 3)
    end
#= none:522 =#
reduced_dimensions(field::XYReducedField) = begin
        #= none:522 =#
        (1, 2)
    end
#= none:523 =#
reduced_dimensions(field::XYZReducedField) = begin
        #= none:523 =#
        (1, 2, 3)
    end
#= none:525 =#
#= none:525 =# @propagate_inbounds Base.getindex(r::XReducedField, i, j, k) = begin
            #= none:525 =#
            getindex(r.data, 1, j, k)
        end
#= none:526 =#
#= none:526 =# @propagate_inbounds Base.getindex(r::YReducedField, i, j, k) = begin
            #= none:526 =#
            getindex(r.data, i, 1, k)
        end
#= none:527 =#
#= none:527 =# @propagate_inbounds Base.getindex(r::ZReducedField, i, j, k) = begin
            #= none:527 =#
            getindex(r.data, i, j, 1)
        end
#= none:529 =#
#= none:529 =# @propagate_inbounds Base.setindex!(r::XReducedField, v, i, j, k) = begin
            #= none:529 =#
            setindex!(r.data, v, 1, j, k)
        end
#= none:530 =#
#= none:530 =# @propagate_inbounds Base.setindex!(r::YReducedField, v, i, j, k) = begin
            #= none:530 =#
            setindex!(r.data, v, i, 1, k)
        end
#= none:531 =#
#= none:531 =# @propagate_inbounds Base.setindex!(r::ZReducedField, v, i, j, k) = begin
            #= none:531 =#
            setindex!(r.data, v, i, j, 1)
        end
#= none:533 =#
#= none:533 =# @propagate_inbounds Base.getindex(r::YZReducedField, i, j, k) = begin
            #= none:533 =#
            getindex(r.data, i, 1, 1)
        end
#= none:534 =#
#= none:534 =# @propagate_inbounds Base.getindex(r::XZReducedField, i, j, k) = begin
            #= none:534 =#
            getindex(r.data, 1, j, 1)
        end
#= none:535 =#
#= none:535 =# @propagate_inbounds Base.getindex(r::XYReducedField, i, j, k) = begin
            #= none:535 =#
            getindex(r.data, 1, 1, k)
        end
#= none:537 =#
#= none:537 =# @propagate_inbounds Base.setindex!(r::YZReducedField, v, i, j, k) = begin
            #= none:537 =#
            setindex!(r.data, v, i, 1, 1)
        end
#= none:538 =#
#= none:538 =# @propagate_inbounds Base.setindex!(r::XZReducedField, v, i, j, k) = begin
            #= none:538 =#
            setindex!(r.data, v, 1, j, 1)
        end
#= none:539 =#
#= none:539 =# @propagate_inbounds Base.setindex!(r::XYReducedField, v, i, j, k) = begin
            #= none:539 =#
            setindex!(r.data, v, 1, 1, k)
        end
#= none:541 =#
#= none:541 =# @propagate_inbounds Base.getindex(r::XYZReducedField, i, j, k) = begin
            #= none:541 =#
            getindex(r.data, 1, 1, 1)
        end
#= none:542 =#
#= none:542 =# @propagate_inbounds Base.setindex!(r::XYZReducedField, v, i, j, k) = begin
            #= none:542 =#
            setindex!(r.data, v, 1, 1, 1)
        end
#= none:544 =#
const XFieldBC = BoundaryCondition{<:Any, XReducedField}
#= none:545 =#
const YFieldBC = BoundaryCondition{<:Any, YReducedField}
#= none:546 =#
const ZFieldBC = BoundaryCondition{<:Any, ZReducedField}
#= none:549 =#
#= none:549 =# @inline getbc(bc::XFieldBC, j::Integer, k::Integer, grid::AbstractGrid, args...) = begin
            #= none:549 =#
            #= none:549 =# @inbounds bc.condition[1, j, k]
        end
#= none:550 =#
#= none:550 =# @inline getbc(bc::YFieldBC, i::Integer, k::Integer, grid::AbstractGrid, args...) = begin
            #= none:550 =#
            #= none:550 =# @inbounds bc.condition[i, 1, k]
        end
#= none:551 =#
#= none:551 =# @inline getbc(bc::ZFieldBC, i::Integer, j::Integer, grid::AbstractGrid, args...) = begin
            #= none:551 =#
            #= none:551 =# @inbounds bc.condition[i, j, 1]
        end
#= none:556 =#
const XYZFieldBC = BoundaryCondition{<:Any, XYZReducedField}
#= none:557 =#
#= none:557 =# @inline getbc(bc::XYZFieldBC, ::Integer, ::Integer, ::AbstractGrid, args...) = begin
            #= none:557 =#
            #= none:557 =# @inbounds bc.condition[1, 1, 1]
        end
#= none:560 =#
function Adapt.adapt_structure(to, reduced_field::ReducedField)
    #= none:560 =#
    #= none:561 =#
    (LX, LY, LZ) = location(reduced_field)
    #= none:562 =#
    return Field{LX, LY, LZ}(nothing, adapt(to, reduced_field.data), nothing, nothing, nothing, nothing, nothing)
end
#= none:575 =#
const XReducedAbstractField = AbstractField{Nothing}
#= none:576 =#
const YReducedAbstractField = AbstractField{<:Any, Nothing}
#= none:577 =#
const ZReducedAbstractField = AbstractField{<:Any, <:Any, Nothing}
#= none:579 =#
const YZReducedAbstractField = AbstractField{<:Any, Nothing, Nothing}
#= none:580 =#
const XZReducedAbstractField = AbstractField{Nothing, <:Any, Nothing}
#= none:581 =#
const XYReducedAbstractField = AbstractField{Nothing, Nothing, <:Any}
#= none:583 =#
const XYZReducedAbstractField = AbstractField{Nothing, Nothing, Nothing}
#= none:585 =#
const ReducedAbstractField = Union{XReducedAbstractField, YReducedAbstractField, ZReducedAbstractField, YZReducedAbstractField, XZReducedAbstractField, XYReducedAbstractField, XYZReducedAbstractField}
#= none:594 =#
Statistics.dot(a::Field, b::Field) = begin
        #= none:594 =#
        mapreduce(((x, y)->begin
                    #= none:594 =#
                    x * y
                end), +, interior(a), interior(b))
    end
#= none:597 =#
const SumReduction = typeof(Base.sum!)
#= none:598 =#
const MeanReduction = typeof(Statistics.mean!)
#= none:599 =#
const ProdReduction = typeof(Base.prod!)
#= none:600 =#
const MaximumReduction = typeof(Base.maximum!)
#= none:601 =#
const MinimumReduction = typeof(Base.minimum!)
#= none:602 =#
const AllReduction = typeof(Base.all!)
#= none:603 =#
const AnyReduction = typeof(Base.any!)
#= none:605 =#
initialize_reduced_field!(::SumReduction, f, r::ReducedAbstractField, c) = begin
        #= none:605 =#
        Base.initarray!(interior(r), f, Base.add_sum, true, interior(c))
    end
#= none:606 =#
initialize_reduced_field!(::ProdReduction, f, r::ReducedAbstractField, c) = begin
        #= none:606 =#
        Base.initarray!(interior(r), f, Base.mul_prod, true, interior(c))
    end
#= none:607 =#
initialize_reduced_field!(::AllReduction, f, r::ReducedAbstractField, c) = begin
        #= none:607 =#
        Base.initarray!(interior(r), f, &, true, interior(c))
    end
#= none:608 =#
initialize_reduced_field!(::AnyReduction, f, r::ReducedAbstractField, c) = begin
        #= none:608 =#
        Base.initarray!(interior(r), f, |, true, interior(c))
    end
#= none:609 =#
initialize_reduced_field!(::MaximumReduction, f, r::ReducedAbstractField, c) = begin
        #= none:609 =#
        Base.mapfirst!(f, interior(r), interior(c))
    end
#= none:610 =#
initialize_reduced_field!(::MinimumReduction, f, r::ReducedAbstractField, c) = begin
        #= none:610 =#
        Base.mapfirst!(f, interior(r), interior(c))
    end
#= none:612 =#
filltype(f, c) = begin
        #= none:612 =#
        eltype(c)
    end
#= none:613 =#
filltype(::Union{AllReduction, AnyReduction}, grid) = begin
        #= none:613 =#
        Bool
    end
#= none:615 =#
function reduced_location(loc; dims)
    #= none:615 =#
    #= none:616 =#
    if dims isa Colon
        #= none:617 =#
        return (Nothing, Nothing, Nothing)
    else
        #= none:619 =#
        return Tuple((if i ∈ dims
                    Nothing
                else
                    loc[i]
                end for i = 1:3))
    end
end
#= none:623 =#
function reduced_dimension(loc)
    #= none:623 =#
    #= none:624 =#
    dims = ()
    #= none:625 =#
    for i = 1:3
        #= none:626 =#
        if loc[i] == Nothing
            dims = (dims..., i)
        else
            dims
        end
        #= none:627 =#
    end
    #= none:628 =#
    return dims
end
#= none:633 =#
get_neutral_mask(::Union{AllReduction, AnyReduction}) = begin
        #= none:633 =#
        true
    end
#= none:634 =#
get_neutral_mask(::Union{SumReduction, MeanReduction}) = begin
        #= none:634 =#
        0
    end
#= none:635 =#
get_neutral_mask(::MinimumReduction) = begin
        #= none:635 =#
        Inf
    end
#= none:636 =#
get_neutral_mask(::MaximumReduction) = begin
        #= none:636 =#
        -Inf
    end
#= none:637 =#
get_neutral_mask(::ProdReduction) = begin
        #= none:637 =#
        1
    end
#= none:640 =#
#= none:640 =# Core.@doc "    condition_operand(f::Function, op::AbstractField, condition, mask)\n\nWrap `f(op)` in `ConditionedOperand` with `condition` and `mask`. `f` defaults to `identity`.\n\nIf `f isa identity` and `isnothing(condition)` then `op` is returned without wrapping.\n\nOtherwise return `ConditionedOperand`, even when `isnothing(condition)` but `!(f isa identity)`.\n" #= none:649 =# @inline(condition_operand(op::AbstractField, condition, mask) = begin
                #= none:649 =#
                condition_operand(identity, op, condition, mask)
            end)
#= none:650 =#
#= none:650 =# @inline condition_operand(::typeof(identity), operand::AbstractField, ::Nothing, mask) = begin
            #= none:650 =#
            operand
        end
#= none:652 =#
#= none:652 =# @inline conditional_length(c::AbstractField) = begin
            #= none:652 =#
            length(c)
        end
#= none:653 =#
#= none:653 =# @inline conditional_length(c::AbstractField, dims) = begin
            #= none:653 =#
            mapreduce((i->begin
                        #= none:653 =#
                        size(c, i)
                    end), *, unique(dims); init = 1)
        end
#= none:656 =#
for reduction = (:sum, :maximum, :minimum, :all, :any, :prod)
    #= none:658 =#
    reduction! = Symbol(reduction, '!')
    #= none:660 =#
    #= none:660 =# @eval begin
            #= none:663 =#
            function Base.$(reduction!)(f::Function, r::ReducedAbstractField, a::AbstractField; condition = nothing, mask = get_neutral_mask(Base.$(reduction!)), kwargs...)
                #= none:663 =#
                #= none:670 =#
                return Base.$(reduction!)(identity, interior(r), condition_operand(f, a, condition, mask); kwargs...)
            end
            #= none:676 =#
            function Base.$(reduction!)(r::ReducedAbstractField, a::AbstractField; condition = nothing, mask = get_neutral_mask(Base.$(reduction!)), kwargs...)
                #= none:676 =#
                #= none:682 =#
                return Base.$(reduction!)(identity, interior(r), condition_operand(a, condition, mask); kwargs...)
            end
            #= none:689 =#
            function Base.$(reduction)(f::Function, c::AbstractField; condition = nothing, mask = get_neutral_mask(Base.$(reduction!)), dims = (:))
                #= none:689 =#
                #= none:695 =#
                T = filltype(Base.$(reduction!), c)
                #= none:696 =#
                loc = reduced_location(location(c); dims)
                #= none:697 =#
                r = Field(loc, c.grid, T; indices = indices(c))
                #= none:698 =#
                conditioned_c = condition_operand(f, c, condition, mask)
                #= none:699 =#
                initialize_reduced_field!(Base.$(reduction!), identity, r, conditioned_c)
                #= none:700 =#
                Base.$(reduction!)(identity, r, conditioned_c, init = false)
                #= none:702 =#
                if dims isa Colon
                    #= none:703 =#
                    return #= none:703 =# CUDA.@allowscalar(first(r))
                else
                    #= none:705 =#
                    return r
                end
            end
            #= none:709 =#
            Base.$(reduction)(c::AbstractField; kwargs...) = begin
                    #= none:709 =#
                    Base.$(reduction)(identity, c; kwargs...)
                end
        end
    #= none:711 =#
end
#= none:713 =#
function Statistics._mean(f, c::AbstractField, ::Colon; condition = nothing, mask = 0)
    #= none:713 =#
    #= none:714 =#
    operator = condition_operand(f, c, condition, mask)
    #= none:715 =#
    return sum(operator) / conditional_length(operator)
end
#= none:718 =#
function Statistics._mean(f, c::AbstractField, dims; condition = nothing, mask = 0)
    #= none:718 =#
    #= none:719 =#
    operand = condition_operand(f, c, condition, mask)
    #= none:720 =#
    r = sum(operand; dims)
    #= none:721 =#
    n = conditional_length(operand, dims)
    #= none:722 =#
    r ./= n
    #= none:723 =#
    return r
end
#= none:726 =#
Statistics.mean(f::Function, c::AbstractField; condition = nothing, dims = (:)) = begin
        #= none:726 =#
        Statistics._mean(f, c, dims; condition)
    end
#= none:727 =#
Statistics.mean(c::AbstractField; condition = nothing, dims = (:)) = begin
        #= none:727 =#
        Statistics._mean(identity, c, dims; condition)
    end
#= none:729 =#
function Statistics.mean!(f::Function, r::ReducedAbstractField, a::AbstractField; condition = nothing, mask = 0)
    #= none:729 =#
    #= none:730 =#
    sum!(f, r, a; condition, mask, init = true)
    #= none:731 =#
    dims = reduced_dimension(location(r))
    #= none:732 =#
    n = conditional_length(condition_operand(f, a, condition, mask), dims)
    #= none:733 =#
    r ./= n
    #= none:734 =#
    return r
end
#= none:737 =#
Statistics.mean!(r::ReducedAbstractField, a::AbstractArray; kwargs...) = begin
        #= none:737 =#
        Statistics.mean!(identity, r, a; kwargs...)
    end
#= none:739 =#
function Statistics.norm(a::AbstractField; condition = nothing)
    #= none:739 =#
    #= none:740 =#
    r = zeros(a.grid, 1)
    #= none:741 =#
    Base.mapreducedim!((x->begin
                #= none:741 =#
                x * x
            end), +, r, condition_operand(a, condition, 0))
    #= none:742 =#
    return #= none:742 =# CUDA.@allowscalar(sqrt(r[1]))
end
#= none:745 =#
function Base.isapprox(a::AbstractField, b::AbstractField; kw...)
    #= none:745 =#
    #= none:746 =#
    conditioned_a = condition_operand(a, nothing, one(eltype(a)))
    #= none:747 =#
    conditioned_b = condition_operand(b, nothing, one(eltype(b)))
    #= none:749 =#
    return all(isapprox.(conditioned_a, conditioned_b; kw...))
end
#= none:756 =#
function fill_halo_regions!(field::Field, args...; kwargs...)
    #= none:756 =#
    #= none:757 =#
    reduced_dims = reduced_dimensions(field)
    #= none:759 =#
    fill_halo_regions!(field.data, field.boundary_conditions, field.indices, instantiated_location(field), field.grid, args...; reduced_dimensions = reduced_dims, kwargs...)
    #= none:768 =#
    return nothing
end