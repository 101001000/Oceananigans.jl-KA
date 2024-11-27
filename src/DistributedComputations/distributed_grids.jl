
#= none:1 =#
using MPI
#= none:2 =#
using OffsetArrays
#= none:3 =#
using Oceananigans.Utils: getnamewrapper
#= none:4 =#
using Oceananigans.Grids: AbstractGrid, topology, size, halo_size, architecture, pop_flat_elements
#= none:5 =#
using Oceananigans.Grids: validate_rectilinear_grid_args, validate_lat_lon_grid_args, validate_size
#= none:6 =#
using Oceananigans.Grids: generate_coordinate, with_precomputed_metrics
#= none:7 =#
using Oceananigans.Grids: cpu_face_constructor_x, cpu_face_constructor_y, cpu_face_constructor_z
#= none:8 =#
using Oceananigans.Grids: R_Earth, metrics_precomputed
#= none:10 =#
using Oceananigans.Fields
#= none:12 =#
import Oceananigans.Grids: RectilinearGrid, LatitudeLongitudeGrid, with_halo
#= none:14 =#
const DistributedGrid{FT, TX, TY, TZ} = AbstractGrid{FT, TX, TY, TZ, <:Distributed}
#= none:16 =#
const DistributedRectilinearGrid{FT, TX, TY, TZ, FX, FY, FZ, VX, VY, VZ} = (RectilinearGrid{FT, TX, TY, TZ, FX, FY, FZ, VX, VY, VZ, <:Distributed} where {FT, TX, TY, TZ, FX, FY, FZ, VX, VY, VZ})
#= none:19 =#
const DistributedLatitudeLongitudeGrid{FT, TX, TY, TZ, M, MY, FX, FY, FZ, VX, VY, VZ} = (LatitudeLongitudeGrid{FT, TX, TY, TZ, M, MY, FX, FY, FZ, VX, VY, VZ, <:Distributed} where {FT, TX, TY, TZ, M, MY, FX, FY, FZ, VX, VY, VZ})
#= none:23 =#
local_size(arch::Distributed, global_sz) = begin
        #= none:23 =#
        (local_size(global_sz[1], arch.partition.x, arch.local_index[1]), local_size(global_sz[2], arch.partition.y, arch.local_index[2]), local_size(global_sz[3], arch.partition.z, arch.local_index[3]))
    end
#= none:28 =#
function local_size(N, R, local_index)
    #= none:28 =#
    #= none:29 =#
    N𝓁 = local_sizes(N, R)
    #= none:30 =#
    Nℊ = sum(N𝓁)
    #= none:31 =#
    if local_index == ranks(R)
        #= none:32 =#
        return (N𝓁[local_index] + N) - Nℊ
    else
        #= none:34 =#
        return N𝓁[local_index]
    end
end
#= none:39 =#
#= none:39 =# @inline local_sizes(N, R::Nothing) = begin
            #= none:39 =#
            N
        end
#= none:40 =#
#= none:40 =# @inline local_sizes(N, R::Int) = begin
            #= none:40 =#
            Tuple((N ÷ R for i = 1:R))
        end
#= none:41 =#
#= none:41 =# @inline local_sizes(N, R::Fractional) = begin
            #= none:41 =#
            Tuple((ceil(Int, N * r) for r = R.sizes))
        end
#= none:42 =#
#= none:42 =# @inline function local_sizes(N, R::Sizes)
        #= none:42 =#
        #= none:43 =#
        if N != sum(R.sizes)
            #= none:44 =#
            #= none:44 =# @warn "The Sizes specified in the architecture $(R.sizes) is inconsistent  \n               with the grid size: (N = $(N) != sum(Sizes) = $(sum(R.sizes))). \n               Using $(R.sizes)..."
        end
        #= none:48 =#
        return R.sizes
    end
#= none:52 =#
global_size(arch, local_size) = begin
        #= none:52 =#
        map(sum, concatenate_local_sizes(local_size, arch))
    end
#= none:54 =#
#= none:54 =# Core.@doc "    RectilinearGrid(arch::Distributed, FT=Float64; kw...)\n\nReturn the rank-local portion of `RectilinearGrid` on `arch`itecture.\n" function RectilinearGrid(arch::Distributed, FT::DataType = Float64; size, x = nothing, y = nothing, z = nothing, halo = nothing, extent = nothing, topology = (Periodic, Periodic, Bounded))
        #= none:59 =#
        #= none:69 =#
        (topology, global_sz, halo, x, y, z) = validate_rectilinear_grid_args(topology, size, halo, FT, extent, x, y, z)
        #= none:72 =#
        local_sz = local_size(arch, global_sz)
        #= none:74 =#
        (nx, ny, nz) = local_sz
        #= none:75 =#
        (Hx, Hy, Hz) = halo
        #= none:77 =#
        (ri, rj, rk) = arch.local_index
        #= none:78 =#
        (Rx, Ry, Rz) = arch.ranks
        #= none:80 =#
        TX = insert_connected_topology(topology[1], Rx, ri)
        #= none:81 =#
        TY = insert_connected_topology(topology[2], Ry, rj)
        #= none:82 =#
        TZ = insert_connected_topology(topology[3], Rz, rk)
        #= none:84 =#
        xl = if Rx == 1
                x
            else
                partition_coordinate(x, nx, arch, 1)
            end
        #= none:85 =#
        yl = if Ry == 1
                y
            else
                partition_coordinate(y, ny, arch, 2)
            end
        #= none:86 =#
        zl = if Rz == 1
                z
            else
                partition_coordinate(z, nz, arch, 3)
            end
        #= none:87 =#
        (Lx, xᶠᵃᵃ, xᶜᵃᵃ, Δxᶠᵃᵃ, Δxᶜᵃᵃ) = generate_coordinate(FT, (topology[1])(), nx, Hx, xl, :x, child_architecture(arch))
        #= none:88 =#
        (Ly, yᵃᶠᵃ, yᵃᶜᵃ, Δyᵃᶠᵃ, Δyᵃᶜᵃ) = generate_coordinate(FT, (topology[2])(), ny, Hy, yl, :y, child_architecture(arch))
        #= none:89 =#
        (Lz, zᵃᵃᶠ, zᵃᵃᶜ, Δzᵃᵃᶠ, Δzᵃᵃᶜ) = generate_coordinate(FT, (topology[3])(), nz, Hz, zl, :z, child_architecture(arch))
        #= none:91 =#
        return RectilinearGrid{TX, TY, TZ}(arch, nx, ny, nz, Hx, Hy, Hz, Lx, Ly, Lz, Δxᶠᵃᵃ, Δxᶜᵃᵃ, xᶠᵃᵃ, xᶜᵃᵃ, Δyᵃᶜᵃ, Δyᵃᶠᵃ, yᵃᶠᵃ, yᵃᶜᵃ, Δzᵃᵃᶠ, Δzᵃᵃᶜ, zᵃᵃᶠ, zᵃᵃᶜ)
    end
#= none:100 =#
#= none:100 =# Core.@doc "    LatitudeLongitudeGrid(arch::Distributed, FT=Float64; kw...)\n\nReturn the rank-local portion of `LatitudeLongitudeGrid` on `arch`itecture.\n" function LatitudeLongitudeGrid(arch::Distributed, FT::DataType = Float64; precompute_metrics = true, size, latitude, longitude, z, topology = nothing, radius = R_Earth, halo = (1, 1, 1))
        #= none:105 =#
        #= none:116 =#
        (topology, global_sz, halo, latitude, longitude, z, precompute_metrics) = validate_lat_lon_grid_args(topology, size, halo, FT, latitude, longitude, z, precompute_metrics)
        #= none:119 =#
        local_sz = local_size(arch, global_sz)
        #= none:121 =#
        (nλ, nφ, nz) = local_sz
        #= none:122 =#
        (Hλ, Hφ, Hz) = halo
        #= none:123 =#
        (ri, rj, rk) = arch.local_index
        #= none:124 =#
        (Rx, Ry, Rz) = arch.ranks
        #= none:126 =#
        TX = insert_connected_topology(topology[1], Rx, ri)
        #= none:127 =#
        TY = insert_connected_topology(topology[2], Ry, rj)
        #= none:128 =#
        TZ = insert_connected_topology(topology[3], Rz, rk)
        #= none:130 =#
        λl = if Rx == 1
                longitude
            else
                partition_coordinate(longitude, nλ, arch, 1)
            end
        #= none:131 =#
        φl = if Ry == 1
                latitude
            else
                partition_coordinate(latitude, nφ, arch, 2)
            end
        #= none:132 =#
        zl = if Rz == 1
                z
            else
                partition_coordinate(z, nz, arch, 3)
            end
        #= none:137 =#
        (Lλ, λᶠᵃᵃ, λᶜᵃᵃ, Δλᶠᵃᵃ, Δλᶜᵃᵃ) = generate_coordinate(FT, TX(), nλ, Hλ, λl, :longitude, arch.child_architecture)
        #= none:138 =#
        (Lz, zᵃᵃᶠ, zᵃᵃᶜ, Δzᵃᵃᶠ, Δzᵃᵃᶜ) = generate_coordinate(FT, TZ(), nz, Hz, zl, :z, arch.child_architecture)
        #= none:148 =#
        (Lφ, φᵃᶠᵃ, φᵃᶜᵃ, Δφᵃᶠᵃ, Δφᵃᶜᵃ) = generate_coordinate(FT, Bounded(), nφ, Hφ + 1, φl, :latitude, arch.child_architecture)
        #= none:150 =#
        preliminary_grid = LatitudeLongitudeGrid{TX, TY, TZ}(arch, nλ, nφ, nz, Hλ, Hφ, Hz, Lλ, Lφ, Lz, Δλᶠᵃᵃ, Δλᶜᵃᵃ, λᶠᵃᵃ, λᶜᵃᵃ, Δφᵃᶠᵃ, Δφᵃᶜᵃ, φᵃᶠᵃ, φᵃᶜᵃ, Δzᵃᵃᶠ, Δzᵃᵃᶜ, zᵃᵃᶠ, zᵃᵃᶜ, (nothing for i = 1:10)..., convert(FT, radius))
        #= none:159 =#
        return if !precompute_metrics
                preliminary_grid
            else
                with_precomputed_metrics(preliminary_grid)
            end
    end
#= none:163 =#
reconstruct_global_grid(grid::AbstractGrid) = begin
        #= none:163 =#
        grid
    end
#= none:165 =#
#= none:165 =# Core.@doc "    reconstruct_global_grid(grid::DistributedGrid)\n\nReturn the global grid on `child_architecture(grid)`\n" function reconstruct_global_grid(grid::DistributedRectilinearGrid)
        #= none:170 =#
        #= none:172 =#
        arch = grid.architecture
        #= none:173 =#
        (ri, rj, rk) = arch.local_index
        #= none:175 =#
        (Rx, Ry, Rz) = (R = arch.ranks)
        #= none:177 =#
        (nx, ny, nz) = (n = size(grid))
        #= none:178 =#
        (Hx, Hy, Hz) = (H = halo_size(grid))
        #= none:179 =#
        (Nx, Ny, Nz) = global_size(arch, n)
        #= none:181 =#
        (TX, TY, TZ) = topology(grid)
        #= none:183 =#
        TX = reconstruct_global_topology(TX, Rx, ri, rj, rk, arch.communicator)
        #= none:184 =#
        TY = reconstruct_global_topology(TY, Ry, rj, ri, rk, arch.communicator)
        #= none:185 =#
        TZ = reconstruct_global_topology(TZ, Rz, rk, ri, rj, arch.communicator)
        #= none:187 =#
        x = cpu_face_constructor_x(grid)
        #= none:188 =#
        y = cpu_face_constructor_y(grid)
        #= none:189 =#
        z = cpu_face_constructor_z(grid)
        #= none:192 =#
        xG = if Rx == 1
                x
            else
                assemble_coordinate(x, nx, arch, 1)
            end
        #= none:193 =#
        yG = if Ry == 1
                y
            else
                assemble_coordinate(y, ny, arch, 2)
            end
        #= none:194 =#
        zG = if Rz == 1
                z
            else
                assemble_coordinate(z, nz, arch, 3)
            end
        #= none:196 =#
        child_arch = child_architecture(arch)
        #= none:198 =#
        FT = eltype(grid)
        #= none:200 =#
        (Lx, xᶠᵃᵃ, xᶜᵃᵃ, Δxᶠᵃᵃ, Δxᶜᵃᵃ) = generate_coordinate(FT, TX(), Nx, Hx, xG, :x, child_arch)
        #= none:201 =#
        (Ly, yᵃᶠᵃ, yᵃᶜᵃ, Δyᵃᶠᵃ, Δyᵃᶜᵃ) = generate_coordinate(FT, TY(), Ny, Hy, yG, :y, child_arch)
        #= none:202 =#
        (Lz, zᵃᵃᶠ, zᵃᵃᶜ, Δzᵃᵃᶠ, Δzᵃᵃᶜ) = generate_coordinate(FT, TZ(), Nz, Hz, zG, :z, child_arch)
        #= none:204 =#
        return RectilinearGrid{TX, TY, TZ}(child_arch, Nx, Ny, Nz, Hx, Hy, Hz, Lx, Ly, Lz, Δxᶠᵃᵃ, Δxᶜᵃᵃ, xᶠᵃᵃ, xᶜᵃᵃ, Δyᵃᶠᵃ, Δyᵃᶜᵃ, yᵃᶠᵃ, yᵃᶜᵃ, Δzᵃᵃᶠ, Δzᵃᵃᶜ, zᵃᵃᶠ, zᵃᵃᶜ)
    end
#= none:213 =#
function reconstruct_global_grid(grid::DistributedLatitudeLongitudeGrid)
    #= none:213 =#
    #= none:215 =#
    arch = grid.architecture
    #= none:216 =#
    (ri, rj, rk) = arch.local_index
    #= none:218 =#
    (Rx, Ry, Rz) = (R = arch.ranks)
    #= none:220 =#
    (nλ, nφ, nz) = (n = size(grid))
    #= none:221 =#
    (Hλ, Hφ, Hz) = (H = halo_size(grid))
    #= none:222 =#
    (Nλ, Nφ, Nz) = global_size(arch, n)
    #= none:224 =#
    (TX, TY, TZ) = topology(grid)
    #= none:226 =#
    TX = reconstruct_global_topology(TX, Rx, ri, rj, rk, arch.communicator)
    #= none:227 =#
    TY = reconstruct_global_topology(TY, Ry, rj, ri, rk, arch.communicator)
    #= none:228 =#
    TZ = reconstruct_global_topology(TZ, Rz, rk, ri, rj, arch.communicator)
    #= none:230 =#
    λ = cpu_face_constructor_x(grid)
    #= none:231 =#
    φ = cpu_face_constructor_y(grid)
    #= none:232 =#
    z = cpu_face_constructor_z(grid)
    #= none:235 =#
    λG = if Rx == 1
            λ
        else
            assemble_coordinate(λ, nλ, arch, 1)
        end
    #= none:236 =#
    φG = if Ry == 1
            φ
        else
            assemble_coordinate(φ, nφ, arch, 2)
        end
    #= none:237 =#
    zG = if Rz == 1
            z
        else
            assemble_coordinate(z, nz, arch, 3)
        end
    #= none:239 =#
    child_arch = child_architecture(arch)
    #= none:241 =#
    FT = eltype(grid)
    #= none:246 =#
    (Lλ, λᶠᵃᵃ, λᶜᵃᵃ, Δλᶠᵃᵃ, Δλᶜᵃᵃ) = generate_coordinate(FT, TX(), Nλ, Hλ, λG, :longitude, child_arch)
    #= none:247 =#
    (Lφ, φᵃᶠᵃ, φᵃᶜᵃ, Δφᵃᶠᵃ, Δφᵃᶜᵃ) = generate_coordinate(FT, TY(), Nφ, Hφ, φG, :latitude, child_arch)
    #= none:248 =#
    (Lz, zᵃᵃᶠ, zᵃᵃᶜ, Δzᵃᵃᶠ, Δzᵃᵃᶜ) = generate_coordinate(FT, TZ(), Nz, Hz, zG, :z, child_arch)
    #= none:250 =#
    precompute_metrics = metrics_precomputed(grid)
    #= none:252 =#
    preliminary_grid = LatitudeLongitudeGrid{TX, TY, TZ}(child_arch, Nλ, Nφ, Nz, Hλ, Hφ, Hz, Lλ, Lφ, Lz, Δλᶠᵃᵃ, Δλᶜᵃᵃ, λᶠᵃᵃ, λᶜᵃᵃ, Δφᵃᶠᵃ, Δφᵃᶜᵃ, φᵃᶠᵃ, φᵃᶜᵃ, Δzᵃᵃᶠ, Δzᵃᵃᶜ, zᵃᵃᶠ, zᵃᵃᶜ, (nothing for i = 1:10)..., grid.radius)
    #= none:261 =#
    return if !precompute_metrics
            preliminary_grid
        else
            with_precomputed_metrics(preliminary_grid)
        end
end
#= none:267 =#
function with_halo(new_halo, grid::DistributedRectilinearGrid)
    #= none:267 =#
    #= none:268 =#
    new_grid = with_halo(new_halo, reconstruct_global_grid(grid))
    #= none:269 =#
    return scatter_local_grids(new_grid, architecture(grid), size(grid))
end
#= none:272 =#
function with_halo(new_halo, grid::DistributedLatitudeLongitudeGrid)
    #= none:272 =#
    #= none:273 =#
    new_grid = with_halo(new_halo, reconstruct_global_grid(grid))
    #= none:274 =#
    return scatter_local_grids(new_grid, architecture(grid), size(grid))
end
#= none:278 =#
child_architecture(grid::AbstractGrid) = begin
        #= none:278 =#
        architecture(grid)
    end
#= none:279 =#
child_architecture(grid::DistributedGrid) = begin
        #= none:279 =#
        child_architecture(architecture(grid))
    end
#= none:281 =#
#= none:281 =# Core.@doc " \n    scatter_grid_properties(global_grid)\n\nreturns individual `extent`, `topology`, `size` and `halo` of a `global_grid` \n" function scatter_grid_properties(global_grid)
        #= none:286 =#
        #= none:288 =#
        x = cpu_face_constructor_x(global_grid)
        #= none:289 =#
        y = cpu_face_constructor_y(global_grid)
        #= none:290 =#
        z = cpu_face_constructor_z(global_grid)
        #= none:292 =#
        topo = topology(global_grid)
        #= none:293 =#
        halo = pop_flat_elements(halo_size(global_grid), topo)
        #= none:295 =#
        return (x, y, z, topo, halo)
    end
#= none:298 =#
function scatter_local_grids(global_grid::RectilinearGrid, arch::Distributed, local_size)
    #= none:298 =#
    #= none:299 =#
    (x, y, z, topo, halo) = scatter_grid_properties(global_grid)
    #= none:300 =#
    global_sz = global_size(arch, local_size)
    #= none:301 =#
    return RectilinearGrid(arch, eltype(global_grid); size = global_sz, x = x, y = y, z = z, halo = halo, topology = topo)
end
#= none:304 =#
function scatter_local_grids(global_grid::LatitudeLongitudeGrid, arch::Distributed, local_size)
    #= none:304 =#
    #= none:305 =#
    (x, y, z, topo, halo) = scatter_grid_properties(global_grid)
    #= none:306 =#
    global_sz = global_size(arch, local_size)
    #= none:307 =#
    return LatitudeLongitudeGrid(arch, eltype(global_grid); size = global_sz, longitude = x, latitude = y, z = z, halo = halo, topology = topo, radius = global_grid.radius)
end
#= none:311 =#
#= none:311 =# Core.@doc " \n    insert_connected_topology(T, R, r)\n\nreturns the local topology associated with the global topology `T`, the amount of ranks \nin `T` direction (`R`) and the local rank index `r` \n" insert_connected_topology(T, R, r) = begin
            #= none:317 =#
            T
        end
#= none:319 =#
insert_connected_topology(::Type{Bounded}, R, r) = begin
        #= none:319 =#
        ifelse(R == 1, Bounded, ifelse(r == 1, RightConnected, ifelse(r == R, LeftConnected, FullyConnected)))
    end
#= none:324 =#
insert_connected_topology(::Type{Periodic}, R, r) = begin
        #= none:324 =#
        ifelse(R == 1, Periodic, FullyConnected)
    end
#= none:326 =#
#= none:326 =# Core.@doc " \n    reconstruct_global_topology(T, R, r, comm)\n\nreconstructs the global topology associated with the local topologies `T`, the amount of ranks \nin `T` direction (`R`) and the local rank index `r`. If all ranks hold a `FullyConnected` topology,\nthe global topology is `Periodic`, otherwise it is `Bounded`\n" function reconstruct_global_topology(T, R, r, r1, r2, comm)
        #= none:333 =#
        #= none:334 =#
        if R == 1
            #= none:335 =#
            return T
        end
        #= none:338 =#
        topologies = zeros(Int, R)
        #= none:339 =#
        if T == FullyConnected && (r1 == 1 && r2 == 1)
            #= none:340 =#
            topologies[r] = 1
        end
        #= none:343 =#
        MPI.Allreduce!(topologies, +, comm)
        #= none:345 =#
        if sum(topologies) == R
            #= none:346 =#
            return Periodic
        else
            #= none:348 =#
            return Bounded
        end
    end