
#= none:5 =#
using Oceananigans.Architectures
#= none:6 =#
using Oceananigans.Grids
#= none:7 =#
using Oceananigans.Grids: AbstractGrid
#= none:8 =#
using Base: @pure
#= none:10 =#
import Oceananigans
#= none:11 =#
import KernelAbstractions: get, expand
#= none:13 =#
struct KernelParameters{S, O}
    #= none:13 =#
end
#= none:15 =#
#= none:15 =# Core.@doc "    KernelParameters(size, offsets)\n\nReturn parameters for kernel launching and execution that define (i) a tuple that\ndefines the `size` of the kernel being launched and (ii) a tuple of `offsets` that\noffset loop indices. For example, `offsets = (0, 0, 0)` with `size = (N, N, N)` means\nall indices loop from `1:N`. If `offsets = (1, 1, 1)`, then all indices loop from \n`2:N+1`. And so on.\n\nExample\n=======\n\n```julia\nsize = (8, 6, 4)\noffsets = (0, 1, 2)\nkp = KernelParameters(size, offsets)\n\n# Launch a kernel with indices that range from i=1:8, j=2:7, k=3:6,\n# where i, j, k are the first, second, and third index, respectively:\n\nlaunch!(arch, grid, kp, kernel!, kernel_args...)\n```\n\nSee [`launch!`](@ref).\n" KernelParameters(size, offsets) = begin
            #= none:40 =#
            KernelParameters{size, offsets}()
        end
#= none:42 =#
#= none:42 =# Core.@doc "    KernelParameters(range1, [range2, range3])\n\nReturn parameters for launching a kernel of up to three dimensions, where the\nindices spanned by the kernel in each dimension are given by (range1, range2, range3).\n\nExample\n=======\n\n```julia\nkp = KernelParameters(1:4, 0:10)\n\n# Launch a kernel with indices that range from i=1:4, j=0:10,\n# where i, j are the first and second index, respectively.\nlaunch!(arch, grid, kp, kernel!, kernel_args...)\n```\n\nSee the documentation for [`launch!`](@ref).\n" function KernelParameters(r::UnitRange)
        #= none:61 =#
        #= none:62 =#
        size = length(r)
        #= none:63 =#
        offset = first(r) - 1
        #= none:64 =#
        return KernelParameters(tuple(size), tuple(offset))
    end
#= none:67 =#
function KernelParameters(r1::UnitRange, r2::UnitRange)
    #= none:67 =#
    #= none:68 =#
    size = (length(r1), length(r2))
    #= none:69 =#
    offsets = (first(r1) - 1, first(r2) - 1)
    #= none:70 =#
    return KernelParameters(size, offsets)
end
#= none:73 =#
function KernelParameters(r1::UnitRange, r2::UnitRange, r3::UnitRange)
    #= none:73 =#
    #= none:74 =#
    size = (length(r1), length(r2), length(r3))
    #= none:75 =#
    offsets = (first(r1) - 1, first(r2) - 1, first(r3) - 1)
    #= none:76 =#
    return KernelParameters(size, offsets)
end
#= none:79 =#
(contiguousrange(range::NTuple{N, Int}, offset::NTuple{N, Int}) where N) = begin
        #= none:79 =#
        Tuple((1 + o:r + o for (r, o) = zip(range, offset)))
    end
#= none:80 =#
flatten_reduced_dimensions(worksize, dims) = begin
        #= none:80 =#
        Tuple((if d ∈ dims
                1
            else
                worksize[d]
            end for d = 1:3))
    end
#= none:83 =#
function heuristic_workgroup(Wx, Wy, Wz = nothing, Wt = nothing)
    #= none:83 =#
    #= none:85 =#
    workgroup = if Wx == 1 && Wy == 1
            (1, 1)
        else
            if Wx == 1
                (1, min(256, Wy))
            else
                if Wy == 1
                    (min(256, Wx), 1)
                else
                    (16, 16)
                end
            end
        end
    #= none:103 =#
    return workgroup
end
#= none:106 =#
periphery_offset(loc, topo, N) = begin
        #= none:106 =#
        0
    end
#= none:107 =#
periphery_offset(::Face, ::Bounded, N) = begin
        #= none:107 =#
        ifelse(N > 1, 1, 0)
    end
#= none:109 =#
drop_omitted_dims(::Val{:xyz}, xyz) = begin
        #= none:109 =#
        xyz
    end
#= none:110 =#
drop_omitted_dims(::Val{:xy}, (x, y, z)) = begin
        #= none:110 =#
        (x, y)
    end
#= none:111 =#
drop_omitted_dims(::Val{:xz}, (x, y, z)) = begin
        #= none:111 =#
        (x, z)
    end
#= none:112 =#
drop_omitted_dims(::Val{:yz}, (x, y, z)) = begin
        #= none:112 =#
        (y, z)
    end
#= none:113 =#
drop_omitted_dims(workdims, xyz) = begin
        #= none:113 =#
        throw(ArgumentError("Unsupported launch configuration: $(workdims)"))
    end
#= none:115 =#
#= none:115 =# Core.@doc "    interior_work_layout(grid, dims, location)\n\nReturns the `workgroup` and `worksize` for launching a kernel over `dims`\non `grid` that excludes peripheral nodes.\nThe `workgroup` is a tuple specifying the threads per block in each\ndimension. The `worksize` specifies the range of the loop in each dimension.\n\nSpecifying `include_right_boundaries=true` will ensure the work layout includes the\nright face end points along bounded dimensions. This requires the field `location`\nto be specified.\n\nFor more information, see: https://github.com/CliMA/Oceananigans.jl/pull/308\n" #= none:129 =# @inline(function interior_work_layout(grid, workdims::Symbol, location)
            #= none:129 =#
            #= none:130 =#
            valdims = Val(workdims)
            #= none:131 =#
            (Nx, Ny, Nz) = size(grid)
            #= none:134 =#
            (ℓx, ℓy, ℓz) = map(instantiate, location)
            #= none:135 =#
            (tx, ty, tz) = map(instantiate, topology(grid))
            #= none:138 =#
            ox = periphery_offset(ℓx, tx, Nx)
            #= none:139 =#
            oy = periphery_offset(ℓy, ty, Ny)
            #= none:140 =#
            oz = periphery_offset(ℓz, tz, Nz)
            #= none:143 =#
            (Wx, Wy, Wz) = (Nx - ox, Ny - oy, Nz - oz)
            #= none:144 =#
            workgroup = heuristic_workgroup(Wx, Wy, Wz)
            #= none:145 =#
            workgroup = StaticSize(workgroup)
            #= none:148 =#
            worksize = drop_omitted_dims(valdims, (Wx, Wy, Wz))
            #= none:149 =#
            offsets = drop_omitted_dims(valdims, (ox, oy, oz))
            #= none:150 =#
            range = contiguousrange(worksize, offsets)
            #= none:151 =#
            worksize = OffsetStaticSize(range)
            #= none:153 =#
            return (workgroup, worksize)
        end)
#= none:156 =#
#= none:156 =# Core.@doc "    work_layout(grid, dims, location)\n\nReturns the `workgroup` and `worksize` for launching a kernel over `dims`\non `grid`. The `workgroup` is a tuple specifying the threads per block in each\ndimension. The `worksize` specifies the range of the loop in each dimension.\n\nSpecifying `include_right_boundaries=true` will ensure the work layout includes the\nright face end points along bounded dimensions. This requires the field `location`\nto be specified.\n\nFor more information, see: https://github.com/CliMA/Oceananigans.jl/pull/308\n" #= none:169 =# @inline(function work_layout(grid, workdims::Symbol, reduced_dimensions)
            #= none:169 =#
            #= none:170 =#
            valdims = Val(workdims)
            #= none:171 =#
            (Nx, Ny, Nz) = size(grid)
            #= none:172 =#
            (Wx, Wy, Wz) = flatten_reduced_dimensions((Nx, Ny, Nz), reduced_dimensions)
            #= none:173 =#
            workgroup = heuristic_workgroup(Wx, Wy, Wz)
            #= none:174 =#
            worksize = drop_omitted_dims(valdims, (Wx, Wy, Wz))
            #= none:175 =#
            return (workgroup, worksize)
        end)
#= none:178 =#
function work_layout(grid, worksize::NTuple{N, Int}, reduced_dimensions) where N
    #= none:178 =#
    #= none:179 =#
    workgroup = heuristic_workgroup(worksize...)
    #= none:180 =#
    return (workgroup, worksize)
end
#= none:183 =#
function work_layout(grid, ::KernelParameters{spec, offsets}, reduced_dimensions) where {spec, offsets}
    #= none:183 =#
    #= none:184 =#
    (workgroup, worksize) = work_layout(grid, spec, reduced_dimensions)
    #= none:185 =#
    static_workgroup = StaticSize(workgroup)
    #= none:186 =#
    range = contiguousrange(worksize, offsets)
    #= none:187 =#
    offset_worksize = OffsetStaticSize(range)
    #= none:188 =#
    return (static_workgroup, offset_worksize)
end
#= none:191 =#
#= none:191 =# Core.@doc "    configure_kernel(arch, grid, workspec, kernel!;\n                     exclude_periphery = false,\n                     reduced_dimensions = (),\n                     location = nothing,\n                     active_cells_map = nothing,\n                     only_local_halos = false,\n                     async = false)\n\nConfigure `kernel!` to launch over the `dims` of `grid` on\nthe architecture `arch`.\n\n# Arguments\n============\n\n- `arch`: The architecture on which the kernel will be launched.\n- `grid`: The grid on which the kernel will be executed.\n- `workspec`: The workspec that defines the work distribution.\n- `kernel!`: The kernel function to be executed.\n\n# Keyword Arguments\n====================\n\n- `include_right_boundaries`: A boolean indicating whether to include right boundaries `(N + 1)`. Default is `false`.\n- `reduced_dimensions`: A tuple specifying the dimensions to be reduced in the work distribution. Default is an empty tuple.\n- `location`: The location of the kernel execution, needed for `include_right_boundaries`. Default is `nothing`.\n- `active_cells_map`: A map indicating the active cells in the grid. If the map is not a nothing, the workspec will be disregarded and \n                      the kernel is configured as a linear kernel with a worksize equal to the length of the active cell map. Default is `nothing`.\n" #= none:220 =# @inline(function configure_kernel(arch, grid, workspec, kernel!; exclude_periphery = false, reduced_dimensions = (), location = nothing, active_cells_map = nothing)
            #= none:220 =#
            #= none:226 =#
            if !(isnothing(active_cells_map))
                #= none:227 =#
                workgroup = min(length(active_cells_map), 256)
                #= none:228 =#
                worksize = length(active_cells_map)
            elseif #= none:229 =# exclude_periphery && !(workspec isa KernelParameters)
                #= none:230 =#
                (workgroup, worksize) = interior_work_layout(grid, workspec, location)
            else
                #= none:232 =#
                (workgroup, worksize) = work_layout(grid, workspec, reduced_dimensions)
            end
            #= none:235 =#
            dev = Architectures.device(arch)
            #= none:236 =#
            loop = kernel!(dev, workgroup, worksize)
            #= none:237 =#
            return (loop, worksize)
        end)
#= none:241 =#
#= none:241 =# Core.@doc "    launch!(arch, grid, workspec, kernel!, kernel_args...; kw...)\n\nLaunches `kernel!` with arguments `kernel_args`\nover the `dims` of `grid` on the architecture `arch`.\nKernels run on the default stream.\n\nSee [configure_kernel](@ref) for more information and also a list of the\nkeyword arguments `kw`.\n" #= none:251 =# @inline(launch!(args...; kwargs...) = begin
                #= none:251 =#
                _launch!(args...; kwargs...)
            end)
#= none:253 =#
#= none:253 =# @inline (launch!(arch, grid, workspec::NTuple{N, Int}, args...; kwargs...) where N) = begin
            #= none:253 =#
            _launch!(arch, grid, workspec, args...; kwargs...)
        end
#= none:256 =#
#= none:256 =# @inline function launch!(arch, grid, workspec_tuple::Tuple, args...; kwargs...)
        #= none:256 =#
        #= none:257 =#
        for workspec = workspec_tuple
            #= none:258 =#
            _launch!(arch, grid, workspec, args...; kwargs...)
            #= none:259 =#
        end
        #= none:260 =#
        return nothing
    end
#= none:264 =#
#= none:264 =# @inline (launch!(arch, grid, ::Val{workspec}, args...; kw...) where workspec) = begin
            #= none:264 =#
            _launch!(arch, grid, workspec, args...; kw...)
        end
#= none:268 =#
#= none:268 =# @inline function _launch!(arch, grid, workspec, kernel!, first_kernel_arg, other_kernel_args...; exclude_periphery = false, reduced_dimensions = (), active_cells_map = nothing, only_local_halos = false, async = false)
        #= none:268 =#
        #= none:276 =#
        location = Oceananigans.Grids.location(first_kernel_arg)
        #= none:278 =#
        (loop!, worksize) = configure_kernel(arch, grid, workspec, kernel!; location, exclude_periphery, reduced_dimensions, active_cells_map)
        #= none:285 =#
        if worksize != 0
            #= none:286 =#
            loop!(first_kernel_arg, other_kernel_args...)
        end
        #= none:289 =#
        return nothing
    end
#= none:307 =#
using KernelAbstractions: Kernel
#= none:308 =#
using KernelAbstractions.NDIteration: _Size, StaticSize
#= none:309 =#
using KernelAbstractions.NDIteration: NDRange
#= none:311 =#
struct OffsetStaticSize{S} <: _Size
    #= none:312 =#
    function OffsetStaticSize{S}() where S
        #= none:312 =#
        #= none:313 =#
        new{S::Tuple{Vararg}}()
    end
end
#= none:317 =#
#= none:317 =# @pure OffsetStaticSize(s::Tuple{Vararg{Int}}) = begin
            #= none:317 =#
            OffsetStaticSize{s}()
        end
#= none:318 =#
#= none:318 =# @pure OffsetStaticSize(s::Int...) = begin
            #= none:318 =#
            OffsetStaticSize{s}()
        end
#= none:319 =#
#= none:319 =# @pure OffsetStaticSize(s::Type{<:Tuple}) = begin
            #= none:319 =#
            OffsetStaticSize{tuple(s.parameters...)}()
        end
#= none:320 =#
#= none:320 =# @pure OffsetStaticSize(s::Tuple{Vararg{UnitRange{Int}}}) = begin
            #= none:320 =#
            OffsetStaticSize{s}()
        end
#= none:323 =#
#= none:323 =# @pure (get(::Type{OffsetStaticSize{S}}) where S) = begin
            #= none:323 =#
            S
        end
#= none:324 =#
#= none:324 =# @pure (get(::OffsetStaticSize{S}) where S) = begin
            #= none:324 =#
            S
        end
#= none:325 =#
#= none:325 =# @pure (Base.getindex(::OffsetStaticSize{S}, i::Int) where S) = begin
            #= none:325 =#
            if i <= length(S)
                S[i]
            else
                1
            end
        end
#= none:326 =#
#= none:326 =# @pure (Base.ndims(::OffsetStaticSize{S}) where S) = begin
            #= none:326 =#
            length(S)
        end
#= none:327 =#
#= none:327 =# @pure (Base.length(::OffsetStaticSize{S}) where S) = begin
            #= none:327 =#
            prod(worksize.(S))
        end
#= none:329 =#
#= none:329 =# @inline (getrange(::OffsetStaticSize{S}) where S) = begin
            #= none:329 =#
            (worksize(S), offsets(S))
        end
#= none:330 =#
#= none:330 =# @inline (getrange(::Type{OffsetStaticSize{S}}) where S) = begin
            #= none:330 =#
            (worksize(S), offsets(S))
        end
#= none:332 =#
#= none:332 =# @inline offsets(ranges::Tuple{Vararg{UnitRange}}) = begin
            #= none:332 =#
            Tuple((r.start - 1 for r = ranges))
        end
#= none:334 =#
#= none:334 =# @inline worksize(i::Tuple) = begin
            #= none:334 =#
            worksize.(i)
        end
#= none:335 =#
#= none:335 =# @inline worksize(i::Int) = begin
            #= none:335 =#
            i
        end
#= none:336 =#
#= none:336 =# @inline worksize(i::UnitRange) = begin
            #= none:336 =#
            length(i)
        end
#= none:338 =#
#= none:338 =# Core.@doc "a type used to store offsets in `NDRange` types" struct KernelOffsets{O}
        #= none:340 =#
        offsets::O
    end
#= none:343 =#
Base.getindex(o::KernelOffsets, args...) = begin
        #= none:343 =#
        getindex(o.offsets, args...)
    end
#= none:345 =#
const OffsetNDRange{N} = (NDRange{N, <:StaticSize, <:StaticSize, <:Any, <:KernelOffsets} where N)
#= none:349 =#
#= none:349 =# @inline function expand(ndrange::OffsetNDRange{N}, groupidx::CartesianIndex{N}, idx::CartesianIndex{N}) where N
        #= none:349 =#
        #= none:350 =#
        nI = ntuple(Val(N)) do I
                #= none:351 =#
                #= none:351 =# Base.@_inline_meta
                #= none:352 =#
                offsets = workitems(ndrange)
                #= none:353 =#
                stride = size(offsets, I)
                #= none:354 =#
                gidx = groupidx.I[I]
                #= none:355 =#
                (gidx - 1) * stride + idx.I[I] + ndrange.workitems[I]
            end
        #= none:357 =#
        return CartesianIndex(nI)
    end
#= none:360 =#
using KernelAbstractions.NDIteration
#= none:361 =#
using KernelAbstractions: ndrange, workgroupsize
#= none:362 =#
import KernelAbstractions: partition
#= none:364 =#
using KernelAbstractions: CompilerMetadata
#= none:365 =#
import KernelAbstractions: __ndrange, __groupsize
#= none:367 =#
#= none:367 =# @inline (__ndrange(::CompilerMetadata{NDRange}) where NDRange <: OffsetStaticSize) = begin
            #= none:367 =#
            CartesianIndices(get(NDRange))
        end
#= none:368 =#
#= none:368 =# @inline (__groupsize(cm::CompilerMetadata{NDRange}) where NDRange <: OffsetStaticSize) = begin
            #= none:368 =#
            size(__ndrange(cm))
        end
#= none:371 =#
const OffsetKernel = Kernel{<:Any, <:StaticSize, <:OffsetStaticSize}
#= none:375 =#
function partition(kernel::OffsetKernel, inrange, ingroupsize)
    #= none:375 =#
    #= none:376 =#
    static_ndrange = ndrange(kernel)
    #= none:377 =#
    static_workgroupsize = workgroupsize(kernel)
    #= none:379 =#
    if inrange !== nothing && inrange != get(static_ndrange)
        #= none:380 =#
        error("Static NDRange ($(static_ndrange)) and launch NDRange ($(inrange)) differ")
    end
    #= none:383 =#
    (range, offsets) = getrange(static_ndrange)
    #= none:385 =#
    if static_workgroupsize <: StaticSize
        #= none:386 =#
        if ingroupsize !== nothing && ingroupsize != get(static_workgroupsize)
            #= none:387 =#
            error("Static WorkgroupSize ($(static_workgroupsize)) and launch WorkgroupSize $(ingroupsize) differ")
        end
        #= none:389 =#
        groupsize = get(static_workgroupsize)
    end
    #= none:392 =#
    #= none:392 =# @assert groupsize !== nothing
    #= none:393 =#
    #= none:393 =# @assert range !== nothing
    #= none:394 =#
    (blocks, groupsize, dynamic) = NDIteration.partition(range, groupsize)
    #= none:396 =#
    static_blocks = StaticSize{blocks}
    #= none:397 =#
    static_workgroupsize = StaticSize{groupsize}
    #= none:399 =#
    iterspace = NDRange{length(range), static_blocks, static_workgroupsize}(blocks, KernelOffsets(offsets))
    #= none:401 =#
    return (iterspace, dynamic)
end