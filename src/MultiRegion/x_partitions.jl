
#= none:1 =#
using Oceananigans.Grids: cpu_face_constructor_x, cpu_face_constructor_y, cpu_face_constructor_z, default_indices
#= none:2 =#
using Oceananigans.BoundaryConditions: MCBC, PBC
#= none:4 =#
const EqualXPartition = XPartition{<:Number}
#= none:6 =#
Base.length(p::XPartition) = begin
        #= none:6 =#
        length(p.div)
    end
#= none:7 =#
Base.length(p::EqualXPartition) = begin
        #= none:7 =#
        p.div
    end
#= none:9 =#
Base.summary(p::EqualXPartition) = begin
        #= none:9 =#
        "Equal partitioning in X with ($(p.div) regions)"
    end
#= none:10 =#
Base.summary(p::XPartition) = begin
        #= none:10 =#
        "XPartition with [$(["$(p.div[i]) " for i = 1:length(p)]...)]"
    end
#= none:12 =#
function partition_size(p::EqualXPartition, grid)
    #= none:12 =#
    #= none:13 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:14 =#
    #= none:14 =# @assert mod(Nx, p.div) == 0
    #= none:15 =#
    return Tuple(((Nx ÷ p.div, Ny, Nz) for i = 1:length(p)))
end
#= none:18 =#
function partition_size(p::XPartition, grid)
    #= none:18 =#
    #= none:19 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:20 =#
    #= none:20 =# @assert sum(p.div) == Nx
    #= none:21 =#
    return Tuple(((p.div[i], Ny, Nz) for i = 1:length(p)))
end
#= none:24 =#
function partition_extent(p::XPartition, grid)
    #= none:24 =#
    #= none:25 =#
    x = cpu_face_constructor_x(grid)
    #= none:26 =#
    y = cpu_face_constructor_y(grid)
    #= none:27 =#
    z = cpu_face_constructor_z(grid)
    #= none:29 =#
    x = divide_direction(x, p)
    #= none:30 =#
    return Tuple(((x = x[i], y = y, z = z) for i = 1:length(p)))
end
#= none:33 =#
function partition_topology(p::XPartition, grid)
    #= none:33 =#
    #= none:34 =#
    (TX, TY, TZ) = topology(grid)
    #= none:36 =#
    return Tuple(((if TX == Periodic
                    FullyConnected
                else
                    if i == 1
                        RightConnected
                    else
                        if i == length(p)
                            LeftConnected
                        else
                            FullyConnected
                        end
                    end
                end, TY, TZ) for i = 1:length(p)))
end
#= none:42 =#
divide_direction(x::Tuple, p::EqualXPartition) = begin
        #= none:42 =#
        Tuple(((x[1] + ((i - 1) * (x[2] - x[1])) / length(p), x[1] + (i * (x[2] - x[1])) / length(p)) for i = 1:length(p)))
    end
#= none:45 =#
function divide_direction(x::AbstractArray, p::EqualXPartition)
    #= none:45 =#
    #= none:46 =#
    nelem = (length(x) - 1) ÷ length(p)
    #= none:47 =#
    return Tuple((x[1 + (i - 1) * nelem:1 + i * nelem] for i = 1:length(p)))
end
#= none:50 =#
divide_direction(x::Tuple, p::XPartition) = begin
        #= none:50 =#
        Tuple(((x[1] + (sum(p.div[1:i - 1]) * (x[2] - x[1])) / sum(p.div), x[1] + (sum(p.div[1:i]) * (x[2] - x[1])) / sum(p.div)) for i = 1:length(p)))
    end
#= none:54 =#
divide_direction(x::AbstractArray, p::XPartition) = begin
        #= none:54 =#
        Tuple((x[1 + sum(p.div[1:i - 1]):1 + sum(p.div[1:i])] for i = 1:length(p)))
    end
#= none:57 =#
partition(a::Function, args...) = begin
        #= none:57 =#
        a
    end
#= none:58 =#
partition(a::Field, p::EqualXPartition, args...) = begin
        #= none:58 =#
        partition(a.data, p, args...)
    end
#= none:60 =#
function partition(a::AbstractArray, ::EqualXPartition, local_size, region, arch)
    #= none:60 =#
    #= none:61 =#
    idxs = default_indices(length(size(a)))
    #= none:62 =#
    return on_architecture(arch, a[local_size[1] * (region - 1) + 1:local_size[1] * region, idxs[2:end]...])
end
#= none:65 =#
function partition(a::OffsetArray, ::EqualXPartition, local_size, region, arch)
    #= none:65 =#
    #= none:66 =#
    idxs = default_indices(length(size(a)))
    #= none:67 =#
    offsets = (a.offsets[1], Tuple((0 for i = 1:length(idxs) - 1))...)
    #= none:68 =#
    return on_architecture(arch, OffsetArray(a[local_size[1] * (region - 1) + 1 + offsets[1]:local_size[1] * region - offsets[1], idxs[2:end]...], offsets...))
end
#= none:75 =#
function reconstruct_size(mrg, p::XPartition)
    #= none:75 =#
    #= none:76 =#
    Nx = sum([grid.Nx for grid = mrg.region_grids.regional_objects])
    #= none:77 =#
    Ny = (mrg.region_grids[1]).Ny
    #= none:78 =#
    Nz = (mrg.region_grids[1]).Nz
    #= none:79 =#
    return (Nx, Ny, Nz)
end
#= none:82 =#
function reconstruct_extent(mrg, p::XPartition)
    #= none:82 =#
    #= none:83 =#
    switch_device!(mrg.devices[1])
    #= none:84 =#
    y = cpu_face_constructor_y(mrg.region_grids.regional_objects[1])
    #= none:85 =#
    z = cpu_face_constructor_z(mrg.region_grids.regional_objects[1])
    #= none:87 =#
    if cpu_face_constructor_x(mrg.region_grids.regional_objects[1]) isa Tuple
        #= none:88 =#
        x = ((cpu_face_constructor_x(mrg.region_grids.regional_objects[1]))[1], (cpu_face_constructor_x(mrg.region_grids.regional_objects[length(p)]))[end])
    else
        #= none:91 =#
        x = [cpu_face_constructor_x(mrg.region_grids.regional_objects[1])...]
        #= none:92 =#
        for (idx, grid) = enumerate(mrg.region_grids.regional_objects[2:end])
            #= none:93 =#
            switch_device!(mrg.devices[idx])
            #= none:94 =#
            x = [x..., (cpu_face_constructor_x(grid))[2:end]...]
            #= none:95 =#
        end
    end
    #= none:98 =#
    return (; x, y, z)
end
#= none:101 =#
const FunctionMRO = (MultiRegionObject{<:Tuple{Vararg{T}}} where T <: Function)
#= none:102 =#
const ArrayMRO{T, N} = ((MultiRegionObject{<:Tuple{Vararg{A}}} where A <: AbstractArray{T, N}) where {T, N})
#= none:104 =#
reconstruct_global_array(ma::FunctionMRO, args...) = begin
        #= none:104 =#
        ma.regional_objects[1]
    end
#= none:106 =#
function reconstruct_global_array(ma::ArrayMRO{T, N}, p::EqualXPartition, arch) where {T, N}
    #= none:106 =#
    #= none:107 =#
    local_size = size(first(ma.regional_objects))
    #= none:108 =#
    global_Nx = local_size[1] * length(p)
    #= none:109 =#
    idxs = default_indices(length(local_size))
    #= none:110 =#
    arr_out = zeros(eltype(first(ma.regional_objects)), global_Nx, local_size[2:end]...)
    #= none:112 =#
    n = local_size[1]
    #= none:114 =#
    for r = 1:length(p)
        #= none:115 =#
        init = Int(n * (r - 1) + 1)
        #= none:116 =#
        fin = Int(n * r)
        #= none:117 =#
        arr_out[init:fin, idxs[2:end]...] .= (on_architecture(CPU(), ma[r]))[1:(fin - init) + 1, idxs[2:end]...]
        #= none:118 =#
    end
    #= none:120 =#
    return on_architecture(arch, arr_out)
end
#= none:123 =#
function compact_data!(global_field, global_grid, data::MultiRegionObject, p::EqualXPartition)
    #= none:123 =#
    #= none:124 =#
    Nx = (size(global_grid))[1]
    #= none:125 =#
    n = Nx / length(p)
    #= none:127 =#
    for r = 1:length(p)
        #= none:128 =#
        init = Int(n * (r - 1) + 1)
        #= none:129 =#
        fin = Int(n * r)
        #= none:130 =#
        (interior(global_field))[init:fin, :, :] .= (data[r])[1:(fin - init) + 1, :, :]
        #= none:131 =#
    end
    #= none:133 =#
    fill_halo_regions!(global_field)
    #= none:135 =#
    return nothing
end
#= none:142 =#
const XPartitionConnectivity = Union{RegionalConnectivity{East, West}, RegionalConnectivity{West, East}}
#= none:148 =#
#= none:148 =# @inline function displaced_xy_index(i, j, grid, region, p::XPartition)
        #= none:148 =#
        #= none:149 =#
        i′ = i + grid.Nx * (region - 1)
        #= none:150 =#
        t = i′ + (j - 1) * grid.Nx * length(p)
        #= none:151 =#
        return t
    end