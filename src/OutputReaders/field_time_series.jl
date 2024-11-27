
#= none:1 =#
using Base: @propagate_inbounds
#= none:3 =#
using OffsetArrays
#= none:4 =#
using Statistics
#= none:5 =#
using JLD2
#= none:6 =#
using Adapt
#= none:7 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:9 =#
using Dates: AbstractTime
#= none:10 =#
using KernelAbstractions: @kernel, @index
#= none:12 =#
using Oceananigans.Architectures
#= none:13 =#
using Oceananigans.Grids
#= none:14 =#
using Oceananigans.Fields
#= none:16 =#
using Oceananigans.Grids: topology, total_size, interior_parent_indices, parent_index_range
#= none:18 =#
using Oceananigans.Fields: interior_view_indices, index_binary_search, indices_summary, boundary_conditions
#= none:21 =#
using Oceananigans.Units: Time
#= none:22 =#
using Oceananigans.Utils: launch!
#= none:24 =#
import Oceananigans.Architectures: architecture, on_architecture
#= none:25 =#
import Oceananigans.BoundaryConditions: fill_halo_regions!, BoundaryCondition, getbc
#= none:26 =#
import Oceananigans.Fields: Field, set!, interior, indices, interpolate!
#= none:32 =#
abstract type AbstractDataBackend end
#= none:33 =#
abstract type AbstractInMemoryBackend{S} end
#= none:35 =#
struct InMemory{S} <: AbstractInMemoryBackend{S}
    #= none:36 =#
    start::S
    #= none:37 =#
    length::S
end
#= none:40 =#
#= none:40 =# Core.@doc "    InMemory(length=nothing)\n\nReturn a `backend` for `FieldTimeSeries` that stores `size`\nfields in memory. The default `size = nothing` stores all fields in memory.\n" function InMemory(length::Int)
        #= none:46 =#
        #= none:47 =#
        length < 2 && throw(ArgumentError("InMemory `length` must be 2 or greater."))
        #= none:48 =#
        return InMemory(1, length)
    end
#= none:51 =#
InMemory() = begin
        #= none:51 =#
        InMemory(nothing, nothing)
    end
#= none:53 =#
const TotallyInMemory = AbstractInMemoryBackend{Nothing}
#= none:54 =#
const PartlyInMemory = AbstractInMemoryBackend{Int}
#= none:56 =#
Base.summary(backend::PartlyInMemory) = begin
        #= none:56 =#
        string("InMemory(", backend.start, ", ", length(backend), ")")
    end
#= none:57 =#
Base.summary(backend::TotallyInMemory) = begin
        #= none:57 =#
        "InMemory()"
    end
#= none:59 =#
new_backend(::InMemory, start, length) = begin
        #= none:59 =#
        InMemory(start, length)
    end
#= none:61 =#
#= none:61 =# Core.@doc "    OnDisk()\n\nReturn a lazy `backend` for `FieldTimeSeries` that keeps data\non disk, only loading it as requested by indexing into the\n`FieldTimeSeries`.\n" struct OnDisk <: AbstractDataBackend
        #= none:68 =#
    end
#= none:74 =#
#= none:74 =# Core.@doc "    Cyclical(period=nothing)\n\nSpecifies cyclical FieldTimeSeries linear Time extrapolation. If\n`period` is not specified, it is inferred from the `fts::FieldTimeSeries` via\n\n```julia\nt = fts.times\nΔt = t[end] - t[end-1]\nperiod = t[end] - t[1] + Δt\n```\n" struct Cyclical{FT}
        #= none:87 =#
        period::FT
    end
#= none:90 =#
Cyclical() = begin
        #= none:90 =#
        Cyclical(nothing)
    end
#= none:92 =#
#= none:92 =# Core.@doc "    Linear()\n\nSpecifies FieldTimeSeries linear Time extrapolation.\n" struct Linear
        #= none:97 =#
    end
#= none:99 =#
#= none:99 =# Core.@doc "    Clamp()\n\nSpecifies FieldTimeSeries Time extrapolation that returns data from the nearest value.\n" struct Clamp
        #= none:104 =#
    end
#= none:115 =#
#= none:115 =# @inline time_index(backend, ti, Nt, m) = begin
            #= none:115 =#
            m
        end
#= none:116 =#
#= none:116 =# @inline memory_index(backend, ti, Nt, n) = begin
            #= none:116 =#
            n
        end
#= none:117 =#
#= none:117 =# @inline memory_index(backend::TotallyInMemory, ::Cyclical, Nt, n) = begin
            #= none:117 =#
            mod1(n, Nt)
        end
#= none:118 =#
#= none:118 =# @inline memory_index(backend::TotallyInMemory, ::Clamp, Nt, n) = begin
            #= none:118 =#
            clamp(n, 1, Nt)
        end
#= none:121 =#
#= none:121 =# @inline shift_index(n, n₀) = begin
            #= none:121 =#
            n - (n₀ - 1)
        end
#= none:122 =#
#= none:122 =# @inline reverse_index(m, n₀) = begin
            #= none:122 =#
            (m + n₀) - 1
        end
#= none:124 =#
#= none:124 =# @inline memory_index(backend::PartlyInMemory, ::Linear, Nt, n) = begin
            #= none:124 =#
            shift_index(n, backend.start)
        end
#= none:126 =#
#= none:126 =# @inline function memory_index(backend::PartlyInMemory, ::Clamp, Nt, n)
        #= none:126 =#
        #= none:127 =#
        n̂ = clamp(n, 1, Nt)
        #= none:128 =#
        m = shift_index(n̂, backend.start)
        #= none:129 =#
        return m
    end
#= none:132 =#
#= none:132 =# Core.@doc "    time_index(backend::PartlyInMemory, time_indexing, Nt, m)\n\nCompute the time index of a snapshot currently stored at the memory index `m`,\ngiven `backend`, `time_indexing`, and number of times `Nt`.\n" #= none:138 =# @inline(time_index(backend::PartlyInMemory, ::Union{Clamp, Linear}, Nt, m) = begin
                #= none:138 =#
                reverse_index(m, backend.start)
            end)
#= none:141 =#
#= none:141 =# Core.@doc "    memory_index(backend::PartlyInMemory, time_indexing, Nt, n)\n\nCompute the current index of a snapshot in memory that has\nthe time index `n`, given `backend`, `time_indexing`, and number of times `Nt`.\n\nExample\n=======\n\nFor `backend::PartlyInMemory` and `time_indexing::Cyclical`:\n\n# Simple shifting example\n```julia\nNt = 5\nbackend = InMemory(2, 3) # so we have (2, 3, 4)\nn = 4           # so m̃ = 3\nm = 4 - (2 - 1) # = 3\nm̃ = mod1(3, 5)  # = 3 ✓\n```\n\n# Shifting + wrapping example\n```julia\nNt = 5\nbackend = InMemory(4, 3) # so we have (4, 5, 1)\nn = 1 # so, the right answer is m̃ = 3\nm = 1 - (4 - 1) # = -2\nm̃ = mod1(-2, 5)  # = 3 ✓\n```\n\n# Another shifting + wrapping example\n```julia\nNt = 5\nbackend = InMemory(5, 3) # so we have (5, 1, 2)\nn = 11 # so, the right answer is m̃ = 2\nm = 11 - (5 - 1) # = 7\nm̃ = mod1(7, 5)  # = 2 ✓\n```\n" #= none:179 =# @inline(function memory_index(backend::PartlyInMemory, ::Cyclical, Nt, n)
            #= none:179 =#
            #= none:180 =#
            m = shift_index(n, backend.start)
            #= none:181 =#
            m̃ = mod1(m, Nt)
            #= none:182 =#
            return m̃
        end)
#= none:185 =#
#= none:185 =# @inline function time_index(backend::PartlyInMemory, ::Cyclical, Nt, m)
        #= none:185 =#
        #= none:186 =#
        n = reverse_index(m, backend.start)
        #= none:187 =#
        ñ = mod1(n, Nt)
        #= none:188 =#
        return ñ
    end
#= none:191 =#
#= none:191 =# Core.@doc "    time_indices(backend, time_indexing, Nt)\n\nReturn a collection of the time indices that are currently in memory.\nIf `backend::TotallyInMemory` then return `1:length(times)`.\n" function time_indices(backend::PartlyInMemory, time_indexing, Nt)
        #= none:197 =#
        #= none:198 =#
        St = length(backend)
        #= none:199 =#
        n₀ = backend.start
        #= none:201 =#
        time_indices = ntuple(St) do m
                #= none:202 =#
                time_index(backend, time_indexing, Nt, m)
            end
        #= none:205 =#
        return time_indices
    end
#= none:208 =#
time_indices(::TotallyInMemory, time_indexing, Nt) = begin
        #= none:208 =#
        1:Nt
    end
#= none:210 =#
Base.length(backend::PartlyInMemory) = begin
        #= none:210 =#
        backend.length
    end
#= none:216 =#
mutable struct FieldTimeSeries{LX, LY, LZ, TI, K, I, D, G, ET, B, χ, P, N, KW} <: AbstractField{LX, LY, LZ, G, ET, 4}
    #= none:217 =#
    data::D
    #= none:218 =#
    grid::G
    #= none:219 =#
    backend::K
    #= none:220 =#
    boundary_conditions::B
    #= none:221 =#
    indices::I
    #= none:222 =#
    times::χ
    #= none:223 =#
    path::P
    #= none:224 =#
    name::N
    #= none:225 =#
    time_indexing::TI
    #= none:226 =#
    reader_kw::KW
    #= none:228 =#
    function FieldTimeSeries{LX, LY, LZ}(data::D, grid::G, backend::K, bcs::B, indices::I, times, path, name, time_indexing, reader_kw) where {LX, LY, LZ, K, D, G, B, I}
        #= none:228 =#
        #= none:239 =#
        ET = eltype(data)
        #= none:242 =#
        if backend isa PartlyInMemory && backend.length > length(times)
            #= none:243 =#
            throw(ArgumentError("`backend.length` cannot be greater than `length(times)`."))
        end
        #= none:246 =#
        if times isa AbstractArray
            #= none:248 =#
            time_range = range(first(times), last(times), length = length(times))
            #= none:249 =#
            if all(time_range .≈ times)
                #= none:250 =#
                times = time_range
            end
            #= none:253 =#
            times = on_architecture(architecture(grid), times)
        end
        #= none:256 =#
        if time_indexing isa Cyclical{Nothing}
            #= none:257 =#
            Δt = #= none:257 =# @allowscalar(times[end] - times[end - 1])
            #= none:258 =#
            period = #= none:258 =# @allowscalar((times[end] - times[1]) + Δt)
            #= none:259 =#
            time_indexing = Cyclical(period)
        end
        #= none:262 =#
        χ = typeof(times)
        #= none:263 =#
        TI = typeof(time_indexing)
        #= none:264 =#
        P = typeof(path)
        #= none:265 =#
        N = typeof(name)
        #= none:266 =#
        KW = typeof(reader_kw)
        #= none:268 =#
        return new{LX, LY, LZ, TI, K, I, D, G, ET, B, χ, P, N, KW}(data, grid, backend, bcs, indices, times, path, name, time_indexing, reader_kw)
    end
end
#= none:274 =#
(on_architecture(to, fts::FieldTimeSeries{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:274 =#
        FieldTimeSeries{LX, LY, LZ}(on_architecture(to, fts.data), on_architecture(to, fts.grid), on_architecture(to, fts.backend), on_architecture(to, fts.bcs), on_architecture(to, fts.indices), on_architecture(to, fts.times), on_architecture(to, fts.path), on_architecture(to, fts.name), on_architecture(to, fts.time_indexing), on_architecture(to, fts.reader_kw))
    end
#= none:292 =#
struct GPUAdaptedFieldTimeSeries{LX, LY, LZ, TI, K, ET, D, χ} <: AbstractField{LX, LY, LZ, Nothing, ET, 4}
    #= none:293 =#
    data::D
    #= none:294 =#
    times::χ
    #= none:295 =#
    backend::K
    #= none:296 =#
    time_indexing::TI
    #= none:298 =#
    function GPUAdaptedFieldTimeSeries{LX, LY, LZ}(data::D, times::χ, backend::K, time_indexing::TI) where {LX, LY, LZ, TI, K, D, χ}
        #= none:298 =#
        #= none:303 =#
        ET = eltype(data)
        #= none:304 =#
        return new{LX, LY, LZ, TI, K, ET, D, χ}(data, times, backend, time_indexing)
    end
end
#= none:308 =#
function Adapt.adapt_structure(to, fts::FieldTimeSeries)
    #= none:308 =#
    #= none:309 =#
    (LX, LY, LZ) = location(fts)
    #= none:310 =#
    return GPUAdaptedFieldTimeSeries{LX, LY, LZ}(adapt(to, fts.data), adapt(to, fts.times), adapt(to, fts.backend), adapt(to, fts.time_indexing))
end
#= none:316 =#
const FTS{LX, LY, LZ, TI, K} = (FieldTimeSeries{LX, LY, LZ, TI, K} where {LX, LY, LZ, TI, K})
#= none:317 =#
const GPUFTS{LX, LY, LZ, TI, K} = (GPUAdaptedFieldTimeSeries{LX, LY, LZ, TI, K} where {LX, LY, LZ, TI, K})
#= none:319 =#
const FlavorOfFTS{LX, LY, LZ, TI, K} = (Union{GPUFTS{LX, LY, LZ, TI, K}, FTS{LX, LY, LZ, TI, K}} where {LX, LY, LZ, TI, K})
#= none:322 =#
const InMemoryFTS = FlavorOfFTS{<:Any, <:Any, <:Any, <:Any, <:AbstractInMemoryBackend}
#= none:323 =#
const OnDiskFTS = FlavorOfFTS{<:Any, <:Any, <:Any, <:Any, <:OnDisk}
#= none:324 =#
const TotallyInMemoryFTS = FlavorOfFTS{<:Any, <:Any, <:Any, <:Any, <:TotallyInMemory}
#= none:325 =#
const PartlyInMemoryFTS = FlavorOfFTS{<:Any, <:Any, <:Any, <:Any, <:PartlyInMemory}
#= none:327 =#
const CyclicalFTS{K} = (FlavorOfFTS{<:Any, <:Any, <:Any, <:Cyclical, K} where K)
#= none:328 =#
const LinearFTS{K} = (FlavorOfFTS{<:Any, <:Any, <:Any, <:Linear, K} where K)
#= none:329 =#
const ClampFTS{K} = (FlavorOfFTS{<:Any, <:Any, <:Any, <:Clamp, K} where K)
#= none:331 =#
const CyclicalChunkedFTS = CyclicalFTS{<:PartlyInMemory}
#= none:333 =#
architecture(fts::FieldTimeSeries) = begin
        #= none:333 =#
        architecture(fts.grid)
    end
#= none:334 =#
time_indices(fts) = begin
        #= none:334 =#
        time_indices(fts.backend, fts.time_indexing, length(fts.times))
    end
#= none:336 =#
#= none:336 =# @inline function memory_index(fts, n)
        #= none:336 =#
        #= none:337 =#
        backend = fts.backend
        #= none:338 =#
        ti = fts.time_indexing
        #= none:339 =#
        Nt = length(fts.times)
        #= none:340 =#
        return memory_index(backend, ti, Nt, n)
    end
#= none:347 =#
instantiate(T::Type) = begin
        #= none:347 =#
        T()
    end
#= none:349 =#
new_data(FT, grid, loc, indices, ::Nothing) = begin
        #= none:349 =#
        nothing
    end
#= none:354 =#
function new_data(FT, grid, loc, indices, Nt::Union{Int, Int64})
    #= none:354 =#
    #= none:355 =#
    space_size = total_size(grid, loc, indices)
    #= none:356 =#
    underlying_data = zeros(FT, architecture(grid), space_size..., Nt)
    #= none:357 =#
    data = offset_data(underlying_data, grid, loc, indices)
    #= none:358 =#
    return data
end
#= none:361 =#
time_indices_length(backend, times) = begin
        #= none:361 =#
        throw(ArgumentError("$(backend) is not a supported backend!"))
    end
#= none:362 =#
time_indices_length(::TotallyInMemory, times) = begin
        #= none:362 =#
        length(times)
    end
#= none:363 =#
time_indices_length(backend::PartlyInMemory, times) = begin
        #= none:363 =#
        length(backend)
    end
#= none:364 =#
time_indices_length(::OnDisk, times) = begin
        #= none:364 =#
        nothing
    end
#= none:366 =#
function FieldTimeSeries(loc, grid, times = (); indices = (:, :, :), backend = InMemory(), path = nothing, name = nothing, time_indexing = Linear(), boundary_conditions = nothing, reader_kw = Dict{Symbol, Any}())
    #= none:366 =#
    #= none:375 =#
    (LX, LY, LZ) = loc
    #= none:377 =#
    Nt = time_indices_length(backend, times)
    #= none:378 =#
    data = new_data(eltype(grid), grid, loc, indices, Nt)
    #= none:380 =#
    if backend isa OnDisk
        #= none:381 =#
        isnothing(path) && error(ArgumentError("Must provide the keyword argument `path` when `backend=OnDisk()`."))
        #= none:382 =#
        isnothing(name) && error(ArgumentError("Must provide the keyword argument `name` when `backend=OnDisk()`."))
    end
    #= none:385 =#
    return FieldTimeSeries{LX, LY, LZ}(data, grid, backend, boundary_conditions, indices, times, path, name, time_indexing, reader_kw)
end
#= none:389 =#
#= none:389 =# Core.@doc "    FieldTimeSeries{LX, LY, LZ}(grid::AbstractGrid [, times=()]; kwargs...)\n\nConstruct a `FieldTimeSeries` on `grid` and at `times`.\n\nKeyword arguments\n=================\n\n- `indices`: spatial indices\n\n- `backend`: backend, `InMemory(indices=Colon())` or `OnDisk()`\n\n- `path`: path to data for `backend = OnDisk()`\n\n- `name`: name of field for `backend = OnDisk()`\n" function FieldTimeSeries{LX, LY, LZ}(grid::AbstractGrid, times = (); kwargs...) where {LX, LY, LZ}
        #= none:405 =#
        #= none:406 =#
        loc = (LX, LY, LZ)
        #= none:407 =#
        return FieldTimeSeries(loc, grid, times; kwargs...)
    end
#= none:410 =#
struct UnspecifiedBoundaryConditions
    #= none:410 =#
end
#= none:412 =#
#= none:412 =# Core.@doc "    FieldTimeSeries(path, name;\n                    backend = InMemory(),\n                    architecture = nothing,\n                    grid = nothing,\n                    location = nothing,\n                    boundary_conditions = UnspecifiedBoundaryConditions(),\n                    time_indexing = Linear(),\n                    iterations = nothing,\n                    times = nothing,\n                    reader_kw = Dict{Symbol, Any}())\n\nReturn a `FieldTimeSeries` containing a time-series of the field `name`\nload from JLD2 output located at `path`.\n\nKeyword arguments\n=================\n\n- `backend`: `InMemory()` to load data into a 4D array, `OnDisk()` to lazily load data from disk\n             when indexing into `FieldTimeSeries`.\n\n- `grid`: A grid to associate with the data, in the case that the native grid was not serialized\n          properly.\n\n- `iterations`: Iterations to load. Defaults to all iterations found in the file.\n\n- `times`: Save times to load, as determined through an approximate floating point\n           comparison to recorded save times. Defaults to times associated with `iterations`.\n           Takes precedence over `iterations` if `times` is specified.\n\n- `reader_kw`: A dictionary of keyword arguments to pass to the reader (currently only JLD2)\n               to be used when opening files.\n" function FieldTimeSeries(path::String, name::String; backend = InMemory(), architecture = nothing, grid = nothing, location = nothing, boundary_conditions = UnspecifiedBoundaryConditions(), time_indexing = Linear(), iterations = nothing, times = nothing, reader_kw = Dict{Symbol, Any}())
        #= none:445 =#
        #= none:456 =#
        file = jldopen(path; reader_kw...)
        #= none:459 =#
        isnothing(iterations) && (iterations = parse.(Int, keys(file["timeseries/t"])))
        #= none:460 =#
        isnothing(times) && (times = [file["timeseries/t/$(i)"] for i = iterations])
        #= none:461 =#
        isnothing(location) && (Location = file["timeseries/$(name)/serialized/location"])
        #= none:463 =#
        indices = try
                #= none:464 =#
                file["timeseries/$(name)/serialized/indices"]
            catch
                #= none:466 =#
                (:, :, :)
            end
        #= none:469 =#
        isnothing(grid) && (grid = file["serialized/grid"])
        #= none:471 =#
        if isnothing(architecture)
            #= none:472 =#
            if isnothing(grid)
                #= none:473 =#
                architecture = CPU()
            else
                #= none:475 =#
                architecture = Architectures.architecture(grid)
            end
        end
        #= none:479 =#
        if boundary_conditions isa UnspecifiedBoundaryConditions
            #= none:480 =#
            boundary_conditions = file["timeseries/$(name)/serialized/boundary_conditions"]
            #= none:481 =#
            boundary_conditions = on_architecture(architecture, boundary_conditions)
        end
        #= none:486 =#
        grid = try
                #= none:487 =#
                on_architecture(architecture, grid)
            catch err
                #= none:489 =#
                if grid isa RectilinearGrid
                    #= none:490 =#
                    #= none:490 =# @info "Initial attempt to transfer grid to $(architecture) failed."
                    #= none:491 =#
                    #= none:491 =# @info "Attempting to reconstruct RectilinearGrid on $(architecture) manually..."
                    #= none:493 =#
                    Nx = file["grid/Nx"]
                    #= none:494 =#
                    Ny = file["grid/Ny"]
                    #= none:495 =#
                    Nz = file["grid/Nz"]
                    #= none:496 =#
                    Hx = file["grid/Hx"]
                    #= none:497 =#
                    Hy = file["grid/Hy"]
                    #= none:498 =#
                    Hz = file["grid/Hz"]
                    #= none:499 =#
                    xᶠᵃᵃ = file["grid/xᶠᵃᵃ"]
                    #= none:500 =#
                    yᵃᶠᵃ = file["grid/yᵃᶠᵃ"]
                    #= none:501 =#
                    zᵃᵃᶠ = file["grid/zᵃᵃᶠ"]
                    #= none:502 =#
                    x = if file["grid/Δxᶠᵃᵃ"] isa Number
                            (xᶠᵃᵃ[1], xᶠᵃᵃ[Nx + 1])
                        else
                            xᶠᵃᵃ
                        end
                    #= none:503 =#
                    y = if file["grid/Δyᵃᶠᵃ"] isa Number
                            (yᵃᶠᵃ[1], yᵃᶠᵃ[Ny + 1])
                        else
                            yᵃᶠᵃ
                        end
                    #= none:504 =#
                    z = if file["grid/Δzᵃᵃᶠ"] isa Number
                            (zᵃᵃᶠ[1], zᵃᵃᶠ[Nz + 1])
                        else
                            zᵃᵃᶠ
                        end
                    #= none:505 =#
                    topo = topology(grid)
                    #= none:507 =#
                    N = (Nx, Ny, Nz)
                    #= none:510 =#
                    domain = Dict()
                    #= none:511 =#
                    for (i, ξ) = enumerate((x, y, z))
                        #= none:512 =#
                        if topo[i] !== Flat
                            #= none:513 =#
                            if !(ξ isa Tuple)
                                #= none:514 =#
                                chopped_ξ = ξ[1:N[i] + 1]
                            else
                                #= none:516 =#
                                chopped_ξ = ξ
                            end
                            #= none:518 =#
                            sξ = ((:x, :y, :z))[i]
                            #= none:519 =#
                            domain[sξ] = chopped_ξ
                        end
                        #= none:521 =#
                    end
                    #= none:523 =#
                    size = Tuple((N[i] for i = 1:3 if topo[i] !== Flat))
                    #= none:524 =#
                    halo = Tuple((((Hx, Hy, Hz))[i] for i = 1:3 if topo[i] !== Flat))
                    #= none:526 =#
                    RectilinearGrid(architecture; size, halo, topology = topo, domain...)
                else
                    #= none:528 =#
                    throw(err)
                end
            end
        #= none:532 =#
        close(file)
        #= none:534 =#
        (LX, LY, LZ) = Location
        #= none:536 =#
        loc = map(instantiate, Location)
        #= none:537 =#
        Nt = time_indices_length(backend, times)
        #= none:538 =#
        data = new_data(eltype(grid), grid, loc, indices, Nt)
        #= none:540 =#
        time_series = FieldTimeSeries{LX, LY, LZ}(data, grid, backend, boundary_conditions, indices, times, path, name, time_indexing, reader_kw)
        #= none:543 =#
        set!(time_series, path, name)
        #= none:545 =#
        return time_series
    end
#= none:548 =#
#= none:548 =# Core.@doc "    Field(location, path, name, iter;\n          grid = nothing,\n          architecture = nothing,\n          indices = (:, :, :),\n          boundary_conditions = nothing,\n          reader_kw = Dict{Symbol, Any}())\n\nLoad a field called `name` saved in a JLD2 file at `path` at `iter`ation.\nUnless specified, the `grid` is loaded from `path`.\n" function Field(location, path::String, name::String, iter; grid = nothing, architecture = nothing, indices = (:, :, :), boundary_conditions = nothing, reader_kw = Dict{Symbol, Any}())
        #= none:559 =#
        #= none:567 =#
        if isnothing(architecture)
            #= none:568 =#
            if isnothing(grid)
                #= none:569 =#
                architecture = CPU()
            else
                #= none:571 =#
                architecture = Architectures.architecture(grid)
            end
        end
        #= none:576 =#
        file = jldopen(path; reader_kw...)
        #= none:578 =#
        isnothing(grid) && (grid = file["serialized/grid"])
        #= none:579 =#
        raw_data = file["timeseries/$(name)/$(iter)"]
        #= none:581 =#
        close(file)
        #= none:584 =#
        grid = on_architecture(architecture, grid)
        #= none:585 =#
        raw_data = on_architecture(architecture, raw_data)
        #= none:586 =#
        data = offset_data(raw_data, grid, location, indices)
        #= none:588 =#
        return Field(location, grid; boundary_conditions, indices, data)
    end
#= none:595 =#
Base.lastindex(fts::FlavorOfFTS, dim) = begin
        #= none:595 =#
        lastindex(fts.data, dim)
    end
#= none:596 =#
Base.parent(fts::InMemoryFTS) = begin
        #= none:596 =#
        parent(fts.data)
    end
#= none:597 =#
Base.parent(fts::OnDiskFTS) = begin
        #= none:597 =#
        nothing
    end
#= none:598 =#
indices(fts::FieldTimeSeries) = begin
        #= none:598 =#
        fts.indices
    end
#= none:599 =#
interior(fts::FieldTimeSeries, I...) = begin
        #= none:599 =#
        view(interior(fts), I...)
    end
#= none:602 =#
Base.length(fts::FlavorOfFTS) = begin
        #= none:602 =#
        length(fts.times)
    end
#= none:603 =#
Base.lastindex(fts::FlavorOfFTS) = begin
        #= none:603 =#
        length(fts.times)
    end
#= none:604 =#
Base.firstindex(fts::FlavorOfFTS) = begin
        #= none:604 =#
        1
    end
#= none:606 =#
function interior(fts::FieldTimeSeries)
    #= none:606 =#
    #= none:607 =#
    loc = map(instantiate, location(fts))
    #= none:608 =#
    topo = map(instantiate, topology(fts.grid))
    #= none:609 =#
    sz = size(fts.grid)
    #= none:610 =#
    halo_sz = halo_size(fts.grid)
    #= none:612 =#
    i_interior = map(interior_parent_indices, loc, topo, sz, halo_sz)
    #= none:613 =#
    indices = fts.indices
    #= none:614 =#
    i_view = map(interior_view_indices, indices, i_interior)
    #= none:616 =#
    return view(parent(fts), i_view..., :)
end
#= none:620 =#
const CPUFTSBC = BoundaryCondition{<:Any, <:FieldTimeSeries}
#= none:621 =#
const GPUFTSBC = BoundaryCondition{<:Any, <:GPUAdaptedFieldTimeSeries}
#= none:622 =#
const FTSBC = Union{CPUFTSBC, GPUFTSBC}
#= none:624 =#
#= none:624 =# @inline getbc(bc::FTSBC, i::Int, j::Int, grid::AbstractGrid, clock, args...) = begin
            #= none:624 =#
            bc.condition[i, j, Time(clock.time)]
        end
#= none:630 =#
const MAX_FTS_TUPLE_SIZE = 10
#= none:632 =#
fill_halo_regions!(fts::OnDiskFTS) = begin
        #= none:632 =#
        nothing
    end
#= none:634 =#
function fill_halo_regions!(fts::InMemoryFTS)
    #= none:634 =#
    #= none:635 =#
    partitioned_indices = Iterators.partition(time_indices(fts), MAX_FTS_TUPLE_SIZE)
    #= none:636 =#
    partitioned_indices = collect(partitioned_indices)
    #= none:637 =#
    Ni = length(partitioned_indices)
    #= none:639 =#
    asyncmap(1:Ni) do i
        #= none:640 =#
        indices = partitioned_indices[i]
        #= none:641 =#
        fts_tuple = Tuple((fts[n] for n = indices))
        #= none:642 =#
        fill_halo_regions!(fts_tuple)
    end
    #= none:645 =#
    return nothing
end