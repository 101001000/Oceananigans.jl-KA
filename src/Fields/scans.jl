
#= none:1 =#
using KernelAbstractions: @kernel, @index
#= none:7 =#
#= none:7 =# Core.@doc "    Scan{T, R, O, D}\n\nAn operand for `Field` that is computed by traversing a dimension.\nThis includes `Reducing` `Scan`s like `sum!` and `maximum!`, as well as\n`Accumulating` `Scan`s like `cumsum!`.\n" struct Scan{T, R, O, D}
        #= none:15 =#
        type::T
        #= none:16 =#
        scan!::R
        #= none:17 =#
        operand::O
        #= none:18 =#
        dims::D
    end
#= none:21 =#
abstract type AbstractReducing end
#= none:22 =#
abstract type AbstractAccumulating end
#= none:24 =#
struct Reducing <: AbstractReducing
    #= none:24 =#
end
#= none:25 =#
struct Accumulating <: AbstractAccumulating
    #= none:25 =#
end
#= none:27 =#
Base.summary(::Reducing) = begin
        #= none:27 =#
        "Reducing"
    end
#= none:28 =#
Base.summary(::Accumulating) = begin
        #= none:28 =#
        "Accumulating"
    end
#= none:30 =#
const Reduction = Scan{<:AbstractReducing}
#= none:31 =#
const Accumulation = Scan{<:AbstractAccumulating}
#= none:33 =#
scan_indices(::AbstractReducing, indices; dims) = begin
        #= none:33 =#
        Tuple((if i ∈ dims
                Colon()
            else
                indices[i]
            end for i = 1:3))
    end
#= none:34 =#
scan_indices(::AbstractAccumulating, indices; dims) = begin
        #= none:34 =#
        indices
    end
#= none:36 =#
Base.summary(s::Scan) = begin
        #= none:36 =#
        string(summary(s.type), " ", s.scan!, " over dims ", s.dims, " of ", summary(s.operand))
    end
#= none:41 =#
function Field(scan::Scan; data = nothing, indices = indices(scan.operand), recompute_safely = true)
    #= none:41 =#
    #= none:46 =#
    operand = scan.operand
    #= none:47 =#
    grid = operand.grid
    #= none:48 =#
    (LX, LY, LZ) = (loc = location(scan))
    #= none:49 =#
    indices = scan_indices(scan.type, indices; dims = scan.dims)
    #= none:51 =#
    if isnothing(data)
        #= none:52 =#
        data = new_data(grid, loc, indices)
        #= none:53 =#
        recompute_safely = false
    end
    #= none:56 =#
    boundary_conditions = FieldBoundaryConditions(grid, loc, indices)
    #= none:57 =#
    status = if recompute_safely
            nothing
        else
            FieldStatus()
        end
    #= none:59 =#
    return Field(loc, grid, data, boundary_conditions, indices, scan, status)
end
#= none:62 =#
const ScannedComputedField = Field{<:Any, <:Any, <:Any, <:Scan}
#= none:64 =#
function compute!(field::ScannedComputedField, time = nothing)
    #= none:64 =#
    #= none:65 =#
    s = field.operand
    #= none:66 =#
    compute_at!(s.operand, time)
    #= none:68 =#
    if s.type isa AbstractReducing
        #= none:69 =#
        s.scan!(field, s.operand)
    elseif #= none:70 =# s.type isa AbstractAccumulating
        #= none:71 =#
        s.scan!(field, s.operand; dims = s.dims)
    end
    #= none:74 =#
    return field
end
#= none:81 =#
function Base.show(io::IO, field::ScannedComputedField)
    #= none:81 =#
    #= none:82 =#
    print(io, summary(field), '\n', "├── data: ", typeof(field.data), ", size: ", size(field), '\n', "├── grid: ", summary(field.grid), '\n', "├── operand: ", summary(field.operand), '\n', "├── status: ", summary(field.status), '\n')
    #= none:88 =#
    data_str = string("└── data: ", summary(field.data), '\n', "    └── ", data_summary(field))
    #= none:91 =#
    print(io, data_str)
end
#= none:94 =#
Base.show(io::IO, s::Scan) = begin
        #= none:94 =#
        print(io, "$(summary(s))\n", "└── operand: $(summary(s.operand))\n", "    └── grid: $(summary(s.operand.grid))")
    end
#= none:103 =#
#= none:103 =# Core.@doc "    Reduction(reduce!, operand; dims)\n\nReturn a `Reduction` of `operand` with `reduce!`, where `reduce!` can be called with\n\n```\nreduce!(field, operand)\n```\n\nto reduce `operand` along `dims` and store in `field`.\n\nExample\n=======\n\n```jldoctest\nusing Oceananigans\n\nNx, Ny, Nz = 3, 3, 3\n\ngrid = RectilinearGrid(size=(Nx, Ny, Nz), x=(0, 1), y=(0, 1), z=(0, 1),\n                       topology=(Periodic, Periodic, Periodic))\n\nc = CenterField(grid)\n\nset!(c, (x, y, z) -> x + y + z)\n\nmax_c² = Field(Reduction(maximum!, c^2, dims=3))\n\ncompute!(max_c²)\n\nmax_c²[1:Nx, 1:Ny]\n\n# output\n3×3 Matrix{Float64}:\n 1.36111  2.25     3.36111\n 2.25     3.36111  4.69444\n 3.36111  4.69444  6.25\n```\n" Reduction(reduce!, operand; dims) = begin
            #= none:142 =#
            Scan(Reducing(), reduce!, operand, dims)
        end
#= none:143 =#
location(r::Reduction) = begin
        #= none:143 =#
        reduced_location(location(r.operand); dims = r.dims)
    end
#= none:149 =#
#= none:149 =# Core.@doc "    Accumulation(accumulate!, operand; dims)\n\nReturn a `Accumulation` of `operand` with `accumulate!`, where `accumulate!` can be called with\n\n```\naccumulate!(field, operand; dims)\n```\n\nto accumulate `operand` along `dims` and store in `field`.\n\nExample\n=======\n\n```jldoctest\nusing Oceananigans\n\nNx, Ny, Nz = 3, 3, 3\n\ngrid = RectilinearGrid(size=(Nx, Ny, Nz), x=(0, 1), y=(0, 1), z=(0, 1),\n                       topology=(Periodic, Periodic, Periodic))\n\nc = CenterField(grid)\n\nset!(c, (x, y, z) -> x + y + z)\n\ncumsum_c² = Field(Accumulation(cumsum!, c^2, dims=3))\n\ncompute!(cumsum_c²)\n\ncumsum_c²[1:Nx, 1:Ny, 1:Nz]\n\n# output\n3×3×3 Array{Float64, 3}:\n[:, :, 1] =\n 0.25      0.694444  1.36111\n 0.694444  1.36111   2.25\n 1.36111   2.25      3.36111\n\n[:, :, 2] =\n 0.944444  2.05556  3.61111\n 2.05556   3.61111  5.61111\n 3.61111   5.61111  8.05556\n\n[:, :, 3] =\n 2.30556   4.30556   6.97222\n 4.30556   6.97222  10.3056\n 6.97222  10.3056   14.3056\n```\n" Accumulation(accumulate!, operand; dims) = begin
            #= none:199 =#
            Scan(Accumulating(), accumulate!, operand, dims)
        end
#= none:200 =#
location(a::Accumulation) = begin
        #= none:200 =#
        location(a.operand)
    end
#= none:207 =#
struct Forward
    #= none:207 =#
end
#= none:208 =#
struct Reverse
    #= none:208 =#
end
#= none:210 =#
#= none:210 =# @inline increment(::Forward, idx) = begin
            #= none:210 =#
            idx + 1
        end
#= none:211 =#
#= none:211 =# @inline decrement(::Forward, idx) = begin
            #= none:211 =#
            idx - 1
        end
#= none:213 =#
#= none:213 =# @inline increment(::Reverse, idx) = begin
            #= none:213 =#
            idx - 1
        end
#= none:214 =#
#= none:214 =# @inline decrement(::Reverse, idx) = begin
            #= none:214 =#
            idx + 1
        end
#= none:219 =#
Base.accumulate!(op, B::Field, A::AbstractField; dims::Integer) = begin
        #= none:219 =#
        directional_accumulate!(op, B, A, dims, Forward())
    end
#= none:222 =#
reverse_accumulate!(op, B::Field, A::AbstractField; dims::Integer) = begin
        #= none:222 =#
        directional_accumulate!(op, B, A, dims, Reverse())
    end
#= none:225 =#
function Base.cumsum!(B::Field, A::AbstractField; dims, condition = nothing, mask = get_neutral_mask(Base.sum!))
    #= none:225 =#
    #= none:226 =#
    Ac = condition_operand(A, condition, mask)
    #= none:227 =#
    return directional_accumulate!(Base.add_sum, B, Ac, dims, Forward())
end
#= none:230 =#
function reverse_cumsum!(B::Field, A::AbstractField; dims, condition = nothing, mask = get_neutral_mask(Base.sum!))
    #= none:230 =#
    #= none:231 =#
    Ac = condition_operand(A, condition, mask)
    #= none:232 =#
    return directional_accumulate!(Base.add_sum, B, Ac, dims, Reverse())
end
#= none:235 =#
function directional_accumulate!(op, B, A, dim, direction)
    #= none:235 =#
    #= none:237 =#
    grid = B.grid
    #= none:238 =#
    arch = architecture(B)
    #= none:242 =#
    if dim == 1
        #= none:243 =#
        config = :yz
        #= none:244 =#
        kernel = accumulate_x
    elseif #= none:245 =# dim == 2
        #= none:246 =#
        config = :xz
        #= none:247 =#
        kernel = accumulate_y
    elseif #= none:248 =# dim == 3
        #= none:249 =#
        config = :xy
        #= none:250 =#
        kernel = accumulate_z
    end
    #= none:253 =#
    if direction isa Forward
        #= none:254 =#
        start = 1
        #= none:255 =#
        finish = size(B, dim)
    elseif #= none:256 =# direction isa Reverse
        #= none:257 =#
        start = size(B, dim)
        #= none:258 =#
        finish = 1
    end
    #= none:261 =#
    launch!(arch, grid, config, kernel, op, B, A, start, finish, direction)
    #= none:263 =#
    return B
end
#= none:266 =#
#= none:266 =# @inline function accumulation_range(dir, start, finish)
        #= none:266 =#
        #= none:267 =#
        by = increment(dir, 0)
        #= none:268 =#
        from = increment(dir, start)
        #= none:269 =#
        return StepRange(from, by, finish)
    end
#= none:272 =#
#= none:272 =# @kernel function accumulate_x(op, B, A, start, finish, dir)
        #= none:272 =#
        #= none:273 =#
        (j, k) = #= none:273 =# @index(Global, NTuple)
        #= none:276 =#
        #= none:276 =# @inbounds B[start, j, k] = Base.reduce_first(op, A[start, j, k])
        #= none:278 =#
        for i = accumulation_range(dir, start, finish)
            #= none:279 =#
            pr = decrement(dir, i)
            #= none:280 =#
            #= none:280 =# @inbounds B[i, j, k] = op(B[pr, j, k], A[i, j, k])
            #= none:281 =#
        end
    end
#= none:284 =#
#= none:284 =# @kernel function accumulate_y(op, B, A, start, finish, dir)
        #= none:284 =#
        #= none:285 =#
        (i, k) = #= none:285 =# @index(Global, NTuple)
        #= none:288 =#
        #= none:288 =# @inbounds B[i, start, k] = Base.reduce_first(op, A[i, start, k])
        #= none:290 =#
        for j = accumulation_range(dir, start, finish)
            #= none:291 =#
            pr = decrement(dir, j)
            #= none:292 =#
            #= none:292 =# @inbounds B[i, j, k] = op(B[i, pr, k], A[i, j, k])
            #= none:293 =#
        end
    end
#= none:296 =#
#= none:296 =# @kernel function accumulate_z(op, B, A, start, finish, dir)
        #= none:296 =#
        #= none:297 =#
        (i, j) = #= none:297 =# @index(Global, NTuple)
        #= none:300 =#
        #= none:300 =# @inbounds B[i, j, start] = Base.reduce_first(op, A[i, j, start])
        #= none:302 =#
        for k = accumulation_range(dir, start, finish)
            #= none:303 =#
            pr = decrement(dir, k)
            #= none:304 =#
            #= none:304 =# @inbounds B[i, j, k] = op(B[i, j, pr], A[i, j, k])
            #= none:305 =#
        end
    end