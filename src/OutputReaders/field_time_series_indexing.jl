
#= none:1 =#
using Oceananigans.Grids: _node
#= none:2 =#
using Oceananigans.Fields: interpolator, _interpolate, fractional_indices, flatten_node
#= none:3 =#
using Oceananigans.Architectures: architecture
#= none:5 =#
import Oceananigans.Fields: interpolate
#= none:12 =#
#= none:12 =# @inline interpolating_time_indices(::Linear, times, t) = begin
            #= none:12 =#
            time_index_binary_search(times, t)
        end
#= none:15 =#
#= none:15 =# @inline function interpolating_time_indices(ti::Cyclical, times, t)
        #= none:15 =#
        #= none:16 =#
        Nt = length(times)
        #= none:17 =#
        t¹ = first(times)
        #= none:18 =#
        tᴺ = last(times)
        #= none:20 =#
        T = ti.period
        #= none:21 =#
        Δt = T - (tᴺ - t¹)
        #= none:24 =#
        τ = t - t¹
        #= none:25 =#
        mod_τ = mod(τ, T)
        #= none:26 =#
        mod_t = mod_τ + t¹
        #= none:28 =#
        (ñ, n₁, n₂) = time_index_binary_search(times, mod_t)
        #= none:30 =#
        cycling = ñ > 1
        #= none:31 =#
        cycled_indices = (ñ - 1, Nt, 1)
        #= none:32 =#
        uncycled_indices = (ñ, n₁, n₂)
        #= none:34 =#
        return ifelse(cycling, cycled_indices, uncycled_indices)
    end
#= none:38 =#
#= none:38 =# @inline function interpolating_time_indices(::Clamp, times, t)
        #= none:38 =#
        #= none:39 =#
        (n, n₁, n₂) = time_index_binary_search(times, t)
        #= none:41 =#
        beyond_indices = (0, n₂, n₂)
        #= none:42 =#
        before_indices = (0, n₁, n₁)
        #= none:43 =#
        unclamped_indices = (n, n₁, n₂)
        #= none:45 =#
        Nt = length(times)
        #= none:47 =#
        indices = ifelse(n + n₁ > Nt, beyond_indices, ifelse(n + n₁ < 1, before_indices, unclamped_indices))
        #= none:50 =#
        return indices
    end
#= none:53 =#
#= none:53 =# @inline function time_index_binary_search(times, t)
        #= none:53 =#
        #= none:54 =#
        Nt = length(times)
        #= none:58 =#
        (n₁, n₂) = index_binary_search(times, t, Nt)
        #= none:60 =#
        #= none:60 =# @inbounds begin
                #= none:61 =#
                t₁ = times[n₁]
                #= none:62 =#
                t₂ = times[n₂]
            end
        #= none:66 =#
        ñ = ((n₂ - n₁) / (t₂ - t₁)) * (t - t₁)
        #= none:68 =#
        ñ = ifelse(n₂ == n₁, zero(ñ), ñ)
        #= none:70 =#
        return (ñ, n₁, n₂)
    end
#= none:77 =#
import Base: getindex
#= none:79 =#
function getindex(fts::OnDiskFTS, n::Int)
    #= none:79 =#
    #= none:81 =#
    arch = architecture(fts)
    #= none:82 =#
    file = jldopen(fts.path; fts.reader_kw...)
    #= none:83 =#
    iter = (keys(file["timeseries/t"]))[n]
    #= none:84 =#
    raw_data = on_architecture(arch, file["timeseries/$(fts.name)/$(iter)"])
    #= none:85 =#
    close(file)
    #= none:88 =#
    loc = location(fts)
    #= none:89 =#
    field_data = offset_data(raw_data, fts.grid, loc, fts.indices)
    #= none:91 =#
    return Field(loc, fts.grid; indices = fts.indices, boundary_conditions = fts.boundary_conditions, data = field_data)
end
#= none:97 =#
#= none:97 =# @propagate_inbounds getindex(f::FlavorOfFTS, i, j, k, n::Int) = begin
            #= none:97 =#
            getindex(f.data, i, j, k, memory_index(f, n))
        end
#= none:98 =#
#= none:98 =# @propagate_inbounds setindex!(f::FlavorOfFTS, v, i, j, k, n::Int) = begin
            #= none:98 =#
            setindex!(f.data, v, i, j, k, memory_index(f, n))
        end
#= none:101 =#
const XYFTS = FlavorOfFTS{<:Any, <:Any, Nothing, <:Any, <:Any}
#= none:102 =#
const XZFTS = FlavorOfFTS{<:Any, Nothing, <:Any, <:Any, <:Any}
#= none:103 =#
const YZFTS = FlavorOfFTS{Nothing, <:Any, <:Any, <:Any, <:Any}
#= none:105 =#
#= none:105 =# @propagate_inbounds getindex(f::XYFTS, i::Int, j::Int, n::Int) = begin
            #= none:105 =#
            getindex(f.data, i, j, 1, memory_index(f, n))
        end
#= none:106 =#
#= none:106 =# @propagate_inbounds getindex(f::XZFTS, i::Int, k::Int, n::Int) = begin
            #= none:106 =#
            getindex(f.data, i, 1, k, memory_index(f, n))
        end
#= none:107 =#
#= none:107 =# @propagate_inbounds getindex(f::YZFTS, j::Int, k::Int, n::Int) = begin
            #= none:107 =#
            getindex(f.data, 1, j, k, memory_index(f, n))
        end
#= none:115 =#
#= none:115 =# @inline getindex(fts::FlavorOfFTS, i::Int, j::Int, k::Int, time_index::Time) = begin
            #= none:115 =#
            interpolating_getindex(fts, i, j, k, time_index)
        end
#= none:118 =#
#= none:118 =# @inline function interpolating_getindex(fts, i, j, k, time_index)
        #= none:118 =#
        #= none:119 =#
        (ñ, n₁, n₂) = interpolating_time_indices(fts.time_indexing, fts.times, time_index.time)
        #= none:121 =#
        #= none:121 =# @inbounds begin
                #= none:122 =#
                ψ₁ = getindex(fts, i, j, k, n₁)
                #= none:123 =#
                ψ₂ = getindex(fts, i, j, k, n₂)
            end
        #= none:126 =#
        ψ̃ = ψ₂ * ñ + ψ₁ * (1 - ñ)
        #= none:129 =#
        return ifelse(n₁ == n₂, ψ₁, ψ̃)
    end
#= none:137 =#
function Base.getindex(fts::FieldTimeSeries, time_index::Time)
    #= none:137 =#
    #= none:139 =#
    (ñ, n₁, n₂) = cpu_interpolating_time_indices(architecture(fts), fts.times, fts.time_indexing, time_index.time)
    #= none:141 =#
    if n₁ == n₂
        #= none:142 =#
        return fts[n₁]
    end
    #= none:146 =#
    ψ₁ = fts[n₁]
    #= none:147 =#
    ψ₂ = fts[n₂]
    #= none:148 =#
    ψ̃ = Field(ψ₂ * ñ + ψ₁ * (1 - ñ))
    #= none:151 =#
    return compute!(ψ̃)
end
#= none:158 =#
#= none:158 =# @inline function interpolate(to_node, to_time_index::Time, from_fts::FlavorOfFTS, from_loc, from_grid)
        #= none:158 =#
        #= none:159 =#
        data = from_fts.data
        #= none:160 =#
        times = from_fts.times
        #= none:161 =#
        backend = from_fts.backend
        #= none:162 =#
        time_indexing = from_fts.time_indexing
        #= none:163 =#
        return interpolate(to_node, to_time_index, data, from_loc, from_grid, times, backend, time_indexing)
    end
#= none:166 =#
#= none:166 =# @inline function interpolate(to_node, to_time_index::Time, data::OffsetArray, from_loc, from_grid, times, backend, time_indexing)
        #= none:166 =#
        #= none:169 =#
        to_time = to_time_index.time
        #= none:172 =#
        to_node = flatten_node(to_node...)
        #= none:173 =#
        (ii, jj, kk) = fractional_indices(to_node, from_grid, from_loc...)
        #= none:175 =#
        ix = interpolator(ii)
        #= none:176 =#
        iy = interpolator(jj)
        #= none:177 =#
        iz = interpolator(kk)
        #= none:179 =#
        (ñ, n₁, n₂) = interpolating_time_indices(time_indexing, times, to_time)
        #= none:181 =#
        Nt = length(times)
        #= none:182 =#
        m₁ = memory_index(backend, time_indexing, Nt, n₁)
        #= none:183 =#
        m₂ = memory_index(backend, time_indexing, Nt, n₂)
        #= none:185 =#
        ψ₁ = _interpolate(data, ix, iy, iz, m₁)
        #= none:186 =#
        ψ₂ = _interpolate(data, ix, iy, iz, m₂)
        #= none:187 =#
        ψ̃ = ψ₂ * ñ + ψ₁ * (1 - ñ)
        #= none:190 =#
        return ifelse(n₁ == n₂, ψ₁, ψ̃)
    end
#= none:193 =#
function interpolate!(target_fts::FieldTimeSeries, source_fts::FieldTimeSeries)
    #= none:193 =#
    #= none:195 =#
    target_grid = target_fts.grid
    #= none:196 =#
    source_grid = source_fts.grid
    #= none:198 =#
    #= none:198 =# @assert architecture(target_grid) == architecture(source_grid)
    #= none:199 =#
    arch = architecture(target_grid)
    #= none:202 =#
    source_location = map(instantiate, location(source_fts))
    #= none:203 =#
    target_location = map(instantiate, location(target_fts))
    #= none:205 =#
    launch!(arch, target_grid, size(target_fts), _interpolate_field_time_series!, target_fts.data, target_grid, target_location, target_fts.times, source_fts, source_grid, source_location)
    #= none:210 =#
    fill_halo_regions!(target_fts)
    #= none:212 =#
    return nothing
end
#= none:215 =#
#= none:215 =# @kernel function _interpolate_field_time_series!(target_fts, target_grid, target_location, target_times, source_fts, source_grid, source_location)
        #= none:215 =#
        #= none:219 =#
        (i, j, k, n) = #= none:219 =# @index(Global, NTuple)
        #= none:221 =#
        target_node = _node(i, j, k, target_grid, target_location...)
        #= none:222 =#
        to_time = #= none:222 =# @inbounds(Time(target_times[n]))
        #= none:224 =#
        #= none:224 =# @inbounds target_fts[i, j, k, n] = interpolate(target_node, to_time, source_fts, source_location, source_grid)
    end
#= none:236 =#
cpu_interpolating_time_indices(::CPU, times, time_indexing, t, arch) = begin
        #= none:236 =#
        interpolating_time_indices(time_indexing, times, t)
    end
#= none:237 =#
cpu_interpolating_time_indices(::CPU, times::AbstractVector, time_indexing, t) = begin
        #= none:237 =#
        interpolating_time_indices(time_indexing, times, t)
    end
#= none:239 =#
function cpu_interpolating_time_indices(::GPU, times::AbstractVector, time_indexing, t)
    #= none:239 =#
    #= none:240 =#
    cpu_times = on_architecture(CPU(), times)
    #= none:241 =#
    return interpolating_time_indices(time_indexing, cpu_times, t)
end
#= none:245 =#
update_field_time_series!(fts, time::Time) = begin
        #= none:245 =#
        nothing
    end
#= none:246 =#
update_field_time_series!(fts, n::Int) = begin
        #= none:246 =#
        nothing
    end
#= none:250 =#
function update_field_time_series!(fts::PartlyInMemoryFTS, time_index::Time)
    #= none:250 =#
    #= none:251 =#
    t = time_index.time
    #= none:252 =#
    (ñ, n₁, n₂) = cpu_interpolating_time_indices(architecture(fts), fts.times, fts.time_indexing, t)
    #= none:253 =#
    return update_field_time_series!(fts, n₁, n₂)
end
#= none:256 =#
function update_field_time_series!(fts::PartlyInMemoryFTS, n₁::Int, n₂ = n₁)
    #= none:256 =#
    #= none:257 =#
    idxs = time_indices(fts)
    #= none:258 =#
    in_range = n₁ ∈ idxs && n₂ ∈ idxs
    #= none:260 =#
    if !in_range
        #= none:262 =#
        Nm = length(fts.backend)
        #= none:263 =#
        start = n₁
        #= none:264 =#
        fts.backend = new_backend(fts.backend, start, Nm)
        #= none:265 =#
        set!(fts)
    end
    #= none:268 =#
    return nothing
end
#= none:273 =#
function getindex(fts::InMemoryFTS, n::Int)
    #= none:273 =#
    #= none:274 =#
    update_field_time_series!(fts, n)
    #= none:276 =#
    m = memory_index(fts, n)
    #= none:277 =#
    underlying_data = view(parent(fts), :, :, :, m)
    #= none:278 =#
    data = offset_data(underlying_data, fts.grid, location(fts), fts.indices)
    #= none:280 =#
    return Field(location(fts), fts.grid; data, fts.boundary_conditions, fts.indices)
end