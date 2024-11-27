
#= none:1 =#
using Oceananigans: tupleit
#= none:9 =#
#= none:9 =# Core.@doc "adds tup element with `default` value for flat dimensions" inflate_tuple(TX, TY, TZ, tup; default) = begin
            #= none:10 =#
            tup
        end
#= none:12 =#
inflate_tuple(::Type{Flat}, TY, TZ, tup; default) = begin
        #= none:12 =#
        (default, tup[1], tup[2])
    end
#= none:13 =#
inflate_tuple(TY, ::Type{Flat}, TZ, tup; default) = begin
        #= none:13 =#
        (tup[1], default, tup[2])
    end
#= none:14 =#
inflate_tuple(TY, TZ, ::Type{Flat}, tup; default) = begin
        #= none:14 =#
        (tup[1], tup[2], default)
    end
#= none:16 =#
inflate_tuple(TX, ::Type{Flat}, ::Type{Flat}, tup; default) = begin
        #= none:16 =#
        (tup[1], default, default)
    end
#= none:17 =#
inflate_tuple(::Type{Flat}, TY, ::Type{Flat}, tup; default) = begin
        #= none:17 =#
        (default, tup[1], default)
    end
#= none:18 =#
inflate_tuple(::Type{Flat}, ::Type{Flat}, TZ, tup; default) = begin
        #= none:18 =#
        (default, default, tup[1])
    end
#= none:20 =#
inflate_tuple(::Type{Flat}, ::Type{Flat}, ::Type{Flat}, tup; default) = begin
        #= none:20 =#
        (default, default, default)
    end
#= none:22 =#
#= none:22 =# Core.@doc "removes tup elements that correspond to flat dimensions" deflate_tuple(TX, TY, TZ, tup) = begin
            #= none:23 =#
            tup
        end
#= none:25 =#
deflate_tuple(::Type{Flat}, TY, TZ, tup) = begin
        #= none:25 =#
        tuple(tup[2], tup[3])
    end
#= none:26 =#
deflate_tuple(TY, ::Type{Flat}, TZ, tup) = begin
        #= none:26 =#
        tuple(tup[1], tup[3])
    end
#= none:27 =#
deflate_tuple(TY, TZ, ::Type{Flat}, tup) = begin
        #= none:27 =#
        tuple(tup[1], tup[2])
    end
#= none:29 =#
deflate_tuple(TX, ::Type{Flat}, ::Type{Flat}, tup) = begin
        #= none:29 =#
        (tup[1],)
    end
#= none:30 =#
deflate_tuple(::Type{Flat}, TY, ::Type{Flat}, tup) = begin
        #= none:30 =#
        (tup[2],)
    end
#= none:31 =#
deflate_tuple(::Type{Flat}, ::Type{Flat}, TZ, tup) = begin
        #= none:31 =#
        (tup[3],)
    end
#= none:33 =#
deflate_tuple(::Type{Flat}, ::Type{Flat}, ::Type{Flat}, tup) = begin
        #= none:33 =#
        ()
    end
#= none:35 =#
topological_tuple_length(TX, TY, TZ) = begin
        #= none:35 =#
        sum((if T === Flat
                0
            else
                1
            end for T = (TX, TY, TZ)))
    end
#= none:37 =#
#= none:37 =# Core.@doc "Validate that an argument tuple is the right length and has elements of type `argtype`." function validate_tupled_argument(arg, argtype, argname, len = 3; greater_than = 0)
        #= none:38 =#
        #= none:39 =#
        length(arg) == len || throw(ArgumentError("length($(argname)) must be $(len)."))
        #= none:40 =#
        all(isa.(arg, argtype)) || throw(ArgumentError("$(argname)=$(arg) must contain $(argtype)s."))
        #= none:41 =#
        all(arg .> greater_than) || throw(ArgumentError("Elements of $(argname)=$(arg) must be > $(greater_than)!"))
        #= none:42 =#
        return nothing
    end
#= none:49 =#
function validate_topology(topology)
    #= none:49 =#
    #= none:50 =#
    for T = topology
        #= none:51 =#
        if !(T() isa AbstractTopology)
            #= none:52 =#
            e = "$(T) is not a valid topology! " * "Valid topologies are: Periodic, Bounded, Flat."
            #= none:54 =#
            throw(ArgumentError(e))
        end
        #= none:56 =#
    end
    #= none:58 =#
    return topology
end
#= none:61 =#
function validate_size(TX, TY, TZ, sz)
    #= none:61 =#
    #= none:62 =#
    sz = tupleit(sz)
    #= none:63 =#
    validate_tupled_argument(sz, Integer, "size", topological_tuple_length(TX, TY, TZ))
    #= none:64 =#
    return inflate_tuple(TX, TY, TZ, sz, default = 1)
end
#= none:71 =#
function validate_halo(TX, TY, TZ, size, ::Nothing)
    #= none:71 =#
    #= none:72 =#
    maximum_halo = size
    #= none:73 =#
    default_halo = (3, 3, 3)
    #= none:74 =#
    halo = map(min, default_halo, maximum_halo)
    #= none:75 =#
    halo = deflate_tuple(TX, TY, TZ, halo)
    #= none:76 =#
    return validate_halo(TX, TY, TZ, size, halo)
end
#= none:79 =#
coordinate_name(i) = begin
        #= none:79 =#
        if i == 1
            "x"
        else
            if i == 2
                "y"
            else
                "z"
            end
        end
    end
#= none:81 =#
function validate_halo(TX, TY, TZ, size, halo)
    #= none:81 =#
    #= none:82 =#
    halo = tupleit(halo)
    #= none:83 =#
    validate_tupled_argument(halo, Integer, "halo", topological_tuple_length(TX, TY, TZ))
    #= none:84 =#
    halo = inflate_tuple(TX, TY, TZ, halo, default = 0)
    #= none:86 =#
    for i = 1:2
        #= none:87 =#
        !(halo[i] ≤ size[i]) && throw(ArgumentError("halo must be ≤ size for coordinate $(coordinate_name(i))"))
        #= none:88 =#
    end
    #= none:90 =#
    return halo
end
#= none:93 =#
function validate_dimension_specification(T, ξ, dir, N, FT)
    #= none:93 =#
    #= none:95 =#
    isnothing(ξ) && throw(ArgumentError("Must supply extent or $(dir) keyword when $(dir)-direction is $(T)"))
    #= none:96 =#
    length(ξ) == 2 || throw(ArgumentError("$(dir) length($(ξ)) must be 2."))
    #= none:97 =#
    all(isa.(ξ, Number)) || throw(ArgumentError("$(dir)=$(ξ) should contain numbers."))
    #= none:98 =#
    ξ[2] ≥ ξ[1] || throw(ArgumentError("$(dir)=$(ξ) should be an increasing interval."))
    #= none:100 =#
    return FT.(ξ)
end
#= none:103 =#
function validate_rectilinear_domain(TX, TY, TZ, FT, size, extent, x, y, z)
    #= none:103 =#
    #= none:106 =#
    if !(isnothing(extent))
        #= none:108 =#
        (!(isnothing(x)) || (!(isnothing(y)) || !(isnothing(z)))) && throw(ArgumentError("Cannot specify both 'extent' and 'x, y, z' keyword arguments."))
        #= none:111 =#
        extent = tupleit(extent)
        #= none:112 =#
        validate_tupled_argument(extent, Number, "extent", topological_tuple_length(TX, TY, TZ))
        #= none:113 =#
        (Lx, Ly, Lz) = (extent = inflate_tuple(TX, TY, TZ, extent, default = 0))
        #= none:116 =#
        x = if TX() isa Flat
                nothing
            else
                (zero(FT), convert(FT, Lx))
            end
        #= none:117 =#
        y = if TY() isa Flat
                nothing
            else
                (zero(FT), convert(FT, Ly))
            end
        #= none:118 =#
        z = if TZ() isa Flat
                nothing
            else
                (-(convert(FT, Lz)), zero(FT))
            end
    else
        #= none:121 =#
        x = validate_dimension_specification(TX, x, :x, size[1], FT)
        #= none:122 =#
        y = validate_dimension_specification(TY, y, :y, size[2], FT)
        #= none:123 =#
        z = validate_dimension_specification(TZ, z, :z, size[3], FT)
    end
    #= none:126 =#
    return (x, y, z)
end
#= none:129 =#
function validate_dimension_specification(T, ξ::AbstractVector, dir, N, FT)
    #= none:129 =#
    #= none:130 =#
    ξ = FT.(ξ)
    #= none:132 =#
    ξ[end] ≥ ξ[1] || throw(ArgumentError("$(dir)=$(ξ) should have increasing values."))
    #= none:135 =#
    Nξ = length(ξ)
    #= none:136 =#
    N⁺¹ = N + 1
    #= none:137 =#
    if Nξ < N⁺¹
        #= none:138 =#
        throw(ArgumentError("length($(dir)) = $(Nξ) has too few interfaces for the dimension size $(N)!"))
    elseif #= none:139 =# Nξ > N⁺¹
        #= none:140 =#
        msg = "length($(dir)) = $(Nξ) is greater than $(N)+1, where $(N) was passed to `size`.\n" * "$(dir) cell interfaces will be constructed from $(dir)[1:$(N⁺¹)]."
        #= none:142 =#
        #= none:142 =# @warn msg
    end
    #= none:145 =#
    return ξ
end
#= none:148 =#
function validate_dimension_specification(T, ξ::Function, dir, N, FT)
    #= none:148 =#
    #= none:149 =#
    ξ(N) ≥ ξ(1) || throw(ArgumentError("$(dir) should have increasing values."))
    #= none:150 =#
    return ξ
end
#= none:153 =#
validate_dimension_specification(::Type{Flat}, ξ::AbstractVector, dir, N, FT) = begin
        #= none:153 =#
        (FT(ξ[1]), FT(ξ[1]))
    end
#= none:154 =#
validate_dimension_specification(::Type{Flat}, ξ::Function, dir, N, FT) = begin
        #= none:154 =#
        (FT(ξ(1)), FT(ξ(1)))
    end
#= none:155 =#
validate_dimension_specification(::Type{Flat}, ξ::Tuple, dir, N, FT) = begin
        #= none:155 =#
        map(FT, ξ)
    end
#= none:156 =#
validate_dimension_specification(::Type{Flat}, ::Nothing, dir, N, FT) = begin
        #= none:156 =#
        nothing
    end
#= none:157 =#
validate_dimension_specification(::Type{Flat}, ξ::Number, dir, N, FT) = begin
        #= none:157 =#
        convert(FT, ξ)
    end
#= none:159 =#
default_horizontal_extent(T, extent) = begin
        #= none:159 =#
        (0, extent[i])
    end
#= none:160 =#
default_vertical_extent(T, extent) = begin
        #= none:160 =#
        (-(extent[3]), 0)
    end
#= none:162 =#
function validate_vertically_stretched_grid_xy(TX, TY, FT, x, y)
    #= none:162 =#
    #= none:163 =#
    x = validate_dimension_specification(TX, x, :x, FT)
    #= none:164 =#
    y = validate_dimension_specification(TY, y, :y, FT)
    #= none:166 =#
    Lx = x[2] - x[1]
    #= none:167 =#
    Ly = y[2] - y[1]
    #= none:169 =#
    return (FT(Lx), FT(Ly), FT.(x), FT.(y))
end
#= none:172 =#
validate_unit_vector(ê::ZDirection, FT::DataType = Float64) = begin
        #= none:172 =#
        ê
    end
#= none:173 =#
validate_unit_vector(ê::NegativeZDirection, FT::DataType = Float64) = begin
        #= none:173 =#
        ê
    end
#= none:175 =#
function validate_unit_vector(ê, FT::DataType = Float64)
    #= none:175 =#
    #= none:176 =#
    length(ê) == 3 || throw(ArgumentError("unit vector must have length 3"))
    #= none:178 =#
    (ex, ey, ez) = ê
    #= none:180 =#
    ex ^ 2 + ey ^ 2 + ez ^ 2 ≈ 1 || throw(ArgumentError("unit vector `ê` must satisfy ê[1]² + ê[2]² + ê[3]² ≈ 1"))
    #= none:183 =#
    return tuple(FT(ex), FT(ey), FT(ez))
end
#= none:186 =#
function validate_index(idx, loc, topo, N, H)
    #= none:186 =#
    #= none:187 =#
    isinteger(idx) && return validate_index(Int(idx), loc, topo, N, H)
    #= none:188 =#
    return throw(ArgumentError("$(idx) are not supported window indices for Field!"))
end
#= none:191 =#
validate_index(::Colon, loc, topo, N, H) = begin
        #= none:191 =#
        Colon()
    end
#= none:192 =#
validate_index(idx::UnitRange, ::Nothing, topo, N, H) = begin
        #= none:192 =#
        UnitRange(1, 1)
    end
#= none:194 =#
function validate_index(idx::UnitRange, loc, topo, N, H)
    #= none:194 =#
    #= none:195 =#
    all_idx = all_indices(loc, topo, N, H)
    #= none:196 =#
    first(idx) ∈ all_idx && last(idx) ∈ all_idx || throw(ArgumentError("The indices $(idx) must slice $(all_idx)"))
    #= none:197 =#
    return idx
end
#= none:200 =#
validate_index(idx::Int, args...) = begin
        #= none:200 =#
        validate_index(UnitRange(idx, idx), args...)
    end
#= none:202 =#
validate_indices(indices, loc, grid::AbstractGrid) = begin
        #= none:202 =#
        validate_indices(indices, loc, topology(grid), size(grid, loc), halo_size(grid))
    end
#= none:205 =#
validate_indices(indices, loc, topo, sz, halo_sz) = begin
        #= none:205 =#
        map(validate_index, indices, map(instantiate, loc), map(instantiate, topo), sz, halo_sz)
    end