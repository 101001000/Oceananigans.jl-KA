
#= none:1 =#
using Oceananigans.Grids: cpu_face_constructor_x, cpu_face_constructor_y, cpu_face_constructor_z, default_indices
#= none:2 =#
using Oceananigans.BoundaryConditions: MCBC, PBC
#= none:4 =#
const EqualYPartition = YPartition{<:Number}
#= none:6 =#
Base.length(p::YPartition) = begin
        #= none:6 =#
        length(p.div)
    end
#= none:7 =#
Base.length(p::EqualYPartition) = begin
        #= none:7 =#
        p.div
    end
#= none:9 =#
Base.summary(p::EqualYPartition) = begin
        #= none:9 =#
        "Equal partitioning in Y with ($(p.div) regions)"
    end
#= none:10 =#
Base.summary(p::YPartition) = begin
        #= none:10 =#
        "YPartition with [$(["$(p.div[i]) " for i = 1:length(p)]...)]"
    end
#= none:12 =#
function partition_size(p::EqualYPartition, grid)
    #= none:12 =#
    #= none:13 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:14 =#
    #= none:14 =# @assert mod(Ny, p.div) == 0
    #= none:15 =#
    return Tuple(((Nx, Ny ÷ p.div, Nz) for i = 1:length(p)))
end
#= none:18 =#
function partition_size(p::YPartition, grid)
    #= none:18 =#
    #= none:19 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:20 =#
    #= none:20 =# @assert sum(p.div) == Ny
    #= none:21 =#
    return Tuple(((Nx, p.div[i], Nz) for i = 1:length(p)))
end
#= none:24 =#
function partition_extent(p::YPartition, grid)
    #= none:24 =#
    #= none:25 =#
    x = cpu_face_constructor_x(grid)
    #= none:26 =#
    y = cpu_face_constructor_y(grid)
    #= none:27 =#
    z = cpu_face_constructor_z(grid)
    #= none:29 =#
    y = divide_direction(y, p)
    #= none:30 =#
    return Tuple(((x, y = y[i], z = z) for i = 1:length(p)))
end
#= none:33 =#
function partition_topology(p::YPartition, grid)
    #= none:33 =#
    #= none:34 =#
    (TX, TY, TZ) = topology(grid)
    #= none:36 =#
    return Tuple(((TX, if TY == Periodic
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
                end, TZ) for i = 1:length(p)))
end
#= none:45 =#
divide_direction(x::Tuple, p::EqualYPartition) = begin
        #= none:45 =#
        Tuple(((x[1] + ((i - 1) * (x[2] - x[1])) / length(p), x[1] + (i * (x[2] - x[1])) / length(p)) for i = 1:length(p)))
    end
#= none:48 =#
function divide_direction(x::AbstractArray, p::EqualYPartition)
    #= none:48 =#
    #= none:49 =#
    nelem = (length(x) - 1) ÷ length(p)
    #= none:50 =#
    return Tuple((x[1 + (i - 1) * nelem:1 + i * nelem] for i = 1:length(p)))
end
#= none:53 =#
partition(a::Field, p::EqualYPartition, args...) = begin
        #= none:53 =#
        partition(a.data, p, args...)
    end
#= none:55 =#
function partition(a::AbstractArray, ::EqualYPartition, local_size, region, arch)
    #= none:55 =#
    #= none:56 =#
    idxs = default_indices(length(size(a)))
    #= none:57 =#
    offsets = (a.offsets[1], Tuple((0 for i = 1:length(idxs) - 1))...)
    #= none:58 =#
    return on_architecture(arch, OffsetArray(a[local_size[1] * (region - 1) + 1 + offsets[1]:local_size[1] * region - offsets[1], idxs[2:end]...], offsets...))
end
#= none:61 =#
function partition(a::OffsetArray, ::EqualYPartition, local_size, region, arch)
    #= none:61 =#
    #= none:62 =#
    idxs = default_indices(length(size(a)))
    #= none:63 =#
    offsets = (0, a.offsets[2], Tuple((0 for i = 1:length(idxs) - 2))...)
    #= none:64 =#
    return on_architecture(arch, OffsetArray(a[idxs[1], local_size[2] * (region - 1) + 1 + offsets[2]:local_size[2] * region - offsets[2], idxs[3:end]...], offsets...))
end
#= none:71 =#
function reconstruct_size(mrg, p::YPartition)
    #= none:71 =#
    #= none:72 =#
    Nx = (mrg.region_grids[1]).Nx
    #= none:73 =#
    Ny = sum([grid.Ny for grid = mrg.region_grids.regional_objects])
    #= none:74 =#
    Nz = (mrg.region_grids[1]).Nz
    #= none:75 =#
    return (Nx, Ny, Nz)
end
#= none:78 =#
function reconstruct_extent(mrg, p::YPartition)
    #= none:78 =#
    #= none:79 =#
    switch_device!(mrg.devices[1])
    #= none:80 =#
    x = cpu_face_constructor_x(mrg.region_grids.regional_objects[1])
    #= none:81 =#
    z = cpu_face_constructor_z(mrg.region_grids.regional_objects[1])
    #= none:83 =#
    if cpu_face_constructor_y(mrg.region_grids.regional_objects[1]) isa Tuple
        #= none:84 =#
        y = ((cpu_face_constructor_y(mrg.region_grids.regional_objects[1]))[1], (cpu_face_constructor_y(mrg.region_grids.regional_objects[length(p)]))[end])
    else
        #= none:87 =#
        y = [cpu_face_constructor_y(mrg.region_grids.regional_objects[1])...]
        #= none:88 =#
        for (idx, grid) = enumerate(mrg.region_grids.regional_objects[2:end])
            #= none:89 =#
            switch_device!(mrg.devices[idx])
            #= none:90 =#
            y = [y..., (cpu_face_constructor_y(grid))[2:end]...]
            #= none:91 =#
        end
    end
    #= none:93 =#
    return (; x, y, z)
end
#= none:96 =#
function reconstruct_global_array(ma::ArrayMRO{T, N}, p::EqualYPartition, arch) where {T, N}
    #= none:96 =#
    #= none:97 =#
    local_size = size(first(ma.regional_objects))
    #= none:98 =#
    global_Ny = local_size[2] * length(p)
    #= none:99 =#
    idxs = default_indices(length(local_size))
    #= none:100 =#
    arr_out = zeros(eltype(first(ma.regional_objects)), local_size[1], global_Ny, local_size[3:end]...)
    #= none:102 =#
    n = local_size[2]
    #= none:104 =#
    for r = 1:length(p)
        #= none:105 =#
        init = Int(n * (r - 1) + 1)
        #= none:106 =#
        fin = Int(n * r)
        #= none:107 =#
        arr_out[idxs[1], init:fin, idxs[3:end]...] .= (on_architecture(CPU(), ma[r]))[idxs[1], 1:(fin - init) + 1, idxs[3:end]...]
        #= none:108 =#
    end
    #= none:110 =#
    return on_architecture(arch, arr_out)
end
#= none:113 =#
function compact_data!(global_field, global_grid, data::MultiRegionObject, p::EqualYPartition)
    #= none:113 =#
    #= none:114 =#
    Ny = (size(global_grid))[2]
    #= none:115 =#
    n = Ny / length(p)
    #= none:117 =#
    for r = 1:length(p)
        #= none:118 =#
        init = Int(n * (r - 1) + 1)
        #= none:119 =#
        fin = Int(n * r)
        #= none:120 =#
        (interior(global_field))[:, init:fin, :] .= (data[r])[:, 1:(fin - init) + 1, :]
        #= none:121 =#
    end
    #= none:123 =#
    fill_halo_regions!(global_field)
    #= none:125 =#
    return nothing
end
#= none:132 =#
const YPartitionConnectivity = Union{RegionalConnectivity{North, South}, RegionalConnectivity{South, North}}
#= none:138 =#
#= none:138 =# @inline function displaced_xy_index(i, j, grid, region, p::YPartition)
        #= none:138 =#
        #= none:139 =#
        j′ = j + grid.Ny * (region - 1)
        #= none:140 =#
        t = i + (j′ - 1) * grid.Nx
        #= none:141 =#
        return t
    end