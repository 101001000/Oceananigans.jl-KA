
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using MPI
#= none:24 =#
MPI.Init()
#= none:28 =#
using Oceananigans.BoundaryConditions: fill_halo_regions!, DCBC
#= none:29 =#
using Oceananigans.DistributedComputations: Distributed, index2rank
#= none:30 =#
using Oceananigans.Fields: AbstractField
#= none:31 =#
using Oceananigans.Grids: halo_size, interior_indices, left_halo_indices, right_halo_indices, underlying_left_halo_indices, underlying_right_halo_indices
#= none:41 =#
instantiate(T::Type) = begin
        #= none:41 =#
        T()
    end
#= none:42 =#
instantiate(t) = begin
        #= none:42 =#
        t
    end
#= none:44 =#
(west_halo(f::AbstractField{LX, LY, LZ}; include_corners = true) where {LX, LY, LZ}) = begin
        #= none:44 =#
        if include_corners
            view(f.data, left_halo_indices(instantiate(LX), instantiate(topology(f, 1)), f.grid.Nx, f.grid.Hx), :, :)
        else
            view(f.data, left_halo_indices(instantiate(LX), instantiate(topology(f, 1)), f.grid.Nx, f.grid.Hx), interior_indices(instantiate(LY), instantiate(topology(f, 2)), f.grid.Ny), interior_indices(instantiate(LZ), instantiate(topology(f, 3)), f.grid.Nz))
        end
    end
#= none:50 =#
(east_halo(f::AbstractField{LX, LY, LZ}; include_corners = true) where {LX, LY, LZ}) = begin
        #= none:50 =#
        if include_corners
            view(f.data, right_halo_indices(instantiate(LX), instantiate(topology(f, 1)), f.grid.Nx, f.grid.Hx), :, :)
        else
            view(f.data, right_halo_indices(instantiate(LX), instantiate(topology(f, 1)), f.grid.Nx, f.grid.Hx), interior_indices(instantiate(LY), instantiate(topology(f, 2)), f.grid.Ny), interior_indices(instantiate(LZ), instantiate(topology(f, 3)), f.grid.Nz))
        end
    end
#= none:56 =#
(south_halo(f::AbstractField{LX, LY, LZ}; include_corners = true) where {LX, LY, LZ}) = begin
        #= none:56 =#
        if include_corners
            view(f.data, :, left_halo_indices(instantiate(LY), instantiate(topology(f, 2)), f.grid.Ny, f.grid.Hy), :)
        else
            view(f.data, interior_indices(instantiate(LX), instantiate(topology(f, 1)), f.grid.Nx), left_halo_indices(instantiate(LY), instantiate(topology(f, 2)), f.grid.Ny, f.grid.Hy), interior_indices(instantiate(LZ), instantiate(topology(f, 3)), f.grid.Nz))
        end
    end
#= none:62 =#
(north_halo(f::AbstractField{LX, LY, LZ}; include_corners = true) where {LX, LY, LZ}) = begin
        #= none:62 =#
        if include_corners
            view(f.data, :, right_halo_indices(instantiate(LY), instantiate(topology(f, 2)), f.grid.Ny, f.grid.Hy), :)
        else
            view(f.data, interior_indices(instantiate(LX), instantiate(topology(f, 1)), f.grid.Nx), right_halo_indices(instantiate(LY), instantiate(topology(f, 2)), f.grid.Ny, f.grid.Hy), interior_indices(instantiate(LZ), instantiate(topology(f, 3)), f.grid.Nz))
        end
    end
#= none:68 =#
(bottom_halo(f::AbstractField{LX, LY, LZ}; include_corners = true) where {LX, LY, LZ}) = begin
        #= none:68 =#
        if include_corners
            view(f.data, :, :, left_halo_indices(instantiate(LZ), instantiate(topology(f, 3)), f.grid.Nz, f.grid.Hz))
        else
            view(f.data, interior_indices(instantiate(LX), instantiate(topology(f, 1)), f.grid.Nx), interior_indices(instantiate(LY), instantiate(topology(f, 2)), f.grid.Ny), left_halo_indices(instantiate(LZ), instantiate(topology(f, 3)), f.grid.Nz, f.grid.Hz))
        end
    end
#= none:74 =#
(top_halo(f::AbstractField{LX, LY, LZ}; include_corners = true) where {LX, LY, LZ}) = begin
        #= none:74 =#
        if include_corners
            view(f.data, :, :, right_halo_indices(instantiate(LZ), instantiate(topology(f, 3)), f.grid.Nz, f.grid.Hz))
        else
            view(f.data, interior_indices(instantiate(LX), instantiate(topology(f, 1)), f.grid.Nx), interior_indices(instantiate(LY), instantiate(topology(f, 2)), f.grid.Ny), right_halo_indices(instantiate(LZ), instantiate(topology(f, 3)), f.grid.Nz, f.grid.Hz))
        end
    end
#= none:81 =#
function southwest_halo(f::AbstractField)
    #= none:81 =#
    #= none:82 =#
    (Nx, Ny, _) = size(f.grid)
    #= none:83 =#
    (Hx, Hy, _) = halo_size(f.grid)
    #= none:84 =#
    return view(parent(f), 1:Hx, 1:Hy, :)
end
#= none:87 =#
function southeast_halo(f::AbstractField)
    #= none:87 =#
    #= none:88 =#
    (Nx, Ny, _) = size(f.grid)
    #= none:89 =#
    (Hx, Hy, _) = halo_size(f.grid)
    #= none:90 =#
    return view(parent(f), Nx + Hx + 1:Nx + 2Hx, 1:Hy, :)
end
#= none:93 =#
function northeast_halo(f::AbstractField)
    #= none:93 =#
    #= none:94 =#
    (Nx, Ny, _) = size(f.grid)
    #= none:95 =#
    (Hx, Hy, _) = halo_size(f.grid)
    #= none:96 =#
    return view(parent(f), Nx + Hx + 1:Nx + 2Hx, Ny + Hy + 1:Ny + 2Hy, :)
end
#= none:99 =#
function northwest_halo(f::AbstractField)
    #= none:99 =#
    #= none:100 =#
    (Nx, Ny, _) = size(f.grid)
    #= none:101 =#
    (Hx, Hy, _) = halo_size(f.grid)
    #= none:102 =#
    return view(parent(f), 1:Hx, Ny + Hy + 1:Ny + 2Hy, :)
end
#= none:106 =#
comm = MPI.COMM_WORLD
#= none:107 =#
mpi_ranks = MPI.Comm_size(comm)
#= none:108 =#
#= none:108 =# @assert mpi_ranks == 4
#= none:114 =#
function test_triply_periodic_rank_connectivity_with_411_ranks()
    #= none:114 =#
    #= none:115 =#
    arch = Distributed(CPU(), partition = Partition(4))
    #= none:117 =#
    local_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    #= none:118 =#
    #= none:118 =# @test local_rank == index2rank(arch.local_index..., arch.ranks...)
    #= none:120 =#
    connectivity = arch.connectivity
    #= none:123 =#
    #= none:123 =# @test isnothing(connectivity.south)
    #= none:124 =#
    #= none:124 =# @test isnothing(connectivity.north)
    #= none:130 =#
    if local_rank == 0
        #= none:131 =#
        #= none:131 =# @test connectivity.east == 1
        #= none:132 =#
        #= none:132 =# @test connectivity.west == 3
    elseif #= none:133 =# local_rank == 1
        #= none:134 =#
        #= none:134 =# @test connectivity.east == 2
        #= none:135 =#
        #= none:135 =# @test connectivity.west == 0
    elseif #= none:136 =# local_rank == 2
        #= none:137 =#
        #= none:137 =# @test connectivity.east == 3
        #= none:138 =#
        #= none:138 =# @test connectivity.west == 1
    elseif #= none:139 =# local_rank == 3
        #= none:140 =#
        #= none:140 =# @test connectivity.east == 0
        #= none:141 =#
        #= none:141 =# @test connectivity.west == 2
    end
    #= none:144 =#
    return nothing
end
#= none:147 =#
function test_triply_periodic_rank_connectivity_with_141_ranks()
    #= none:147 =#
    #= none:148 =#
    arch = Distributed(CPU(), partition = Partition(1, 4))
    #= none:150 =#
    local_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    #= none:151 =#
    #= none:151 =# @test local_rank == index2rank(arch.local_index..., arch.ranks...)
    #= none:153 =#
    connectivity = arch.connectivity
    #= none:156 =#
    #= none:156 =# @test isnothing(connectivity.east)
    #= none:157 =#
    #= none:157 =# @test isnothing(connectivity.west)
    #= none:169 =#
    if local_rank == 0
        #= none:170 =#
        #= none:170 =# @test connectivity.north == 1
        #= none:171 =#
        #= none:171 =# @test connectivity.south == 3
    elseif #= none:172 =# local_rank == 1
        #= none:173 =#
        #= none:173 =# @test connectivity.north == 2
        #= none:174 =#
        #= none:174 =# @test connectivity.south == 0
    elseif #= none:175 =# local_rank == 2
        #= none:176 =#
        #= none:176 =# @test connectivity.north == 3
        #= none:177 =#
        #= none:177 =# @test connectivity.south == 1
    elseif #= none:178 =# local_rank == 3
        #= none:179 =#
        #= none:179 =# @test connectivity.north == 0
        #= none:180 =#
        #= none:180 =# @test connectivity.south == 2
    end
    #= none:183 =#
    return nothing
end
#= none:186 =#
function test_triply_periodic_rank_connectivity_with_221_ranks()
    #= none:186 =#
    #= none:187 =#
    arch = Distributed(CPU(), partition = Partition(2, 2))
    #= none:189 =#
    local_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    #= none:190 =#
    #= none:190 =# @test local_rank == index2rank(arch.local_index..., arch.ranks...)
    #= none:192 =#
    connectivity = arch.connectivity
    #= none:200 =#
    if local_rank == 0
        #= none:201 =#
        #= none:201 =# @test connectivity.east == 2
        #= none:202 =#
        #= none:202 =# @test connectivity.west == 2
        #= none:203 =#
        #= none:203 =# @test connectivity.north == 1
        #= none:204 =#
        #= none:204 =# @test connectivity.south == 1
    elseif #= none:205 =# local_rank == 1
        #= none:206 =#
        #= none:206 =# @test connectivity.east == 3
        #= none:207 =#
        #= none:207 =# @test connectivity.west == 3
        #= none:208 =#
        #= none:208 =# @test connectivity.north == 0
        #= none:209 =#
        #= none:209 =# @test connectivity.south == 0
    elseif #= none:210 =# local_rank == 2
        #= none:211 =#
        #= none:211 =# @test connectivity.east == 0
        #= none:212 =#
        #= none:212 =# @test connectivity.west == 0
        #= none:213 =#
        #= none:213 =# @test connectivity.north == 3
        #= none:214 =#
        #= none:214 =# @test connectivity.south == 3
    elseif #= none:215 =# local_rank == 3
        #= none:216 =#
        #= none:216 =# @test connectivity.east == 1
        #= none:217 =#
        #= none:217 =# @test connectivity.west == 1
        #= none:218 =#
        #= none:218 =# @test connectivity.north == 2
        #= none:219 =#
        #= none:219 =# @test connectivity.south == 2
    end
    #= none:222 =#
    return nothing
end
#= none:229 =#
function test_triply_periodic_local_grid_with_411_ranks()
    #= none:229 =#
    #= none:230 =#
    arch = Distributed(CPU(), partition = Partition(4))
    #= none:231 =#
    local_grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Periodic), size = (8, 8, 8), extent = (1, 2, 3))
    #= none:233 =#
    local_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    #= none:234 =#
    (nx, ny, nz) = size(local_grid)
    #= none:236 =#
    #= none:236 =# @test local_grid.xᶠᵃᵃ[1] == 0.25local_rank
    #= none:237 =#
    #= none:237 =# @test local_grid.xᶠᵃᵃ[nx + 1] == 0.25 * (local_rank + 1)
    #= none:238 =#
    #= none:238 =# @test local_grid.yᵃᶠᵃ[1] == 0
    #= none:239 =#
    #= none:239 =# @test local_grid.yᵃᶠᵃ[ny + 1] == 2
    #= none:240 =#
    #= none:240 =# @test local_grid.zᵃᵃᶠ[1] == -3
    #= none:241 =#
    #= none:241 =# @test local_grid.zᵃᵃᶠ[nz + 1] == 0
    #= none:243 =#
    return nothing
end
#= none:246 =#
function test_triply_periodic_local_grid_with_141_ranks()
    #= none:246 =#
    #= none:247 =#
    arch = Distributed(CPU(), partition = Partition(1, 4))
    #= none:248 =#
    local_grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Periodic), size = (8, 8, 8), extent = (1, 2, 3))
    #= none:250 =#
    local_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    #= none:251 =#
    (nx, ny, nz) = size(local_grid)
    #= none:253 =#
    #= none:253 =# @test local_grid.xᶠᵃᵃ[1] == 0
    #= none:254 =#
    #= none:254 =# @test local_grid.xᶠᵃᵃ[nx + 1] == 1
    #= none:255 =#
    #= none:255 =# @test local_grid.yᵃᶠᵃ[1] == 0.5local_rank
    #= none:256 =#
    #= none:256 =# @test local_grid.yᵃᶠᵃ[ny + 1] == 0.5 * (local_rank + 1)
    #= none:257 =#
    #= none:257 =# @test local_grid.zᵃᵃᶠ[1] == -3
    #= none:258 =#
    #= none:258 =# @test local_grid.zᵃᵃᶠ[nz + 1] == 0
    #= none:260 =#
    return nothing
end
#= none:263 =#
function test_triply_periodic_local_grid_with_221_ranks()
    #= none:263 =#
    #= none:264 =#
    arch = Distributed(CPU(), partition = Partition(2, 2))
    #= none:265 =#
    local_grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Periodic), size = (8, 8, 8), extent = (1, 2, 3))
    #= none:267 =#
    (i, j, k) = arch.local_index
    #= none:268 =#
    (nx, ny, nz) = size(local_grid)
    #= none:270 =#
    #= none:270 =# @test local_grid.xᶠᵃᵃ[1] == 0.5 * (i - 1)
    #= none:271 =#
    #= none:271 =# @test local_grid.xᶠᵃᵃ[nx + 1] == 0.5i
    #= none:272 =#
    #= none:272 =# @test local_grid.yᵃᶠᵃ[1] == j - 1
    #= none:273 =#
    #= none:273 =# @test local_grid.yᵃᶠᵃ[ny + 1] == j
    #= none:274 =#
    #= none:274 =# @test local_grid.zᵃᵃᶠ[1] == -3
    #= none:275 =#
    #= none:275 =# @test local_grid.zᵃᵃᶠ[nz + 1] == 0
    #= none:277 =#
    return nothing
end
#= none:286 =#
function test_triply_periodic_bc_injection_with_411_ranks()
    #= none:286 =#
    #= none:287 =#
    arch = Distributed(partition = Partition(4))
    #= none:288 =#
    grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Periodic), size = (8, 8, 8), extent = (1, 2, 3))
    #= none:289 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:291 =#
    for field = merge(fields(model))
        #= none:292 =#
        fbcs = field.boundary_conditions
        #= none:293 =#
        #= none:293 =# @test fbcs.east isa DCBC
        #= none:294 =#
        #= none:294 =# @test fbcs.west isa DCBC
        #= none:295 =#
        #= none:295 =# @test !(fbcs.north isa DCBC)
        #= none:296 =#
        #= none:296 =# @test !(fbcs.south isa DCBC)
        #= none:297 =#
        #= none:297 =# @test !(fbcs.top isa DCBC)
        #= none:298 =#
        #= none:298 =# @test !(fbcs.bottom isa DCBC)
        #= none:299 =#
    end
end
#= none:302 =#
function test_triply_periodic_bc_injection_with_141_ranks()
    #= none:302 =#
    #= none:303 =#
    arch = Distributed(partition = Partition(1, 4))
    #= none:304 =#
    grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Periodic), size = (8, 8, 8), extent = (1, 2, 3))
    #= none:305 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:307 =#
    for field = merge(fields(model))
        #= none:308 =#
        fbcs = field.boundary_conditions
        #= none:309 =#
        #= none:309 =# @test !(fbcs.east isa DCBC)
        #= none:310 =#
        #= none:310 =# @test !(fbcs.west isa DCBC)
        #= none:311 =#
        #= none:311 =# @test fbcs.north isa DCBC
        #= none:312 =#
        #= none:312 =# @test fbcs.south isa DCBC
        #= none:313 =#
        #= none:313 =# @test !(fbcs.top isa DCBC)
        #= none:314 =#
        #= none:314 =# @test !(fbcs.bottom isa DCBC)
        #= none:315 =#
    end
end
#= none:318 =#
function test_triply_periodic_bc_injection_with_221_ranks()
    #= none:318 =#
    #= none:319 =#
    arch = Distributed(partition = Partition(2, 2))
    #= none:320 =#
    grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Periodic), size = (8, 8, 8), extent = (1, 2, 3))
    #= none:321 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:323 =#
    for field = merge(fields(model))
        #= none:324 =#
        fbcs = field.boundary_conditions
        #= none:325 =#
        #= none:325 =# @test fbcs.east isa DCBC
        #= none:326 =#
        #= none:326 =# @test fbcs.west isa DCBC
        #= none:327 =#
        #= none:327 =# @test fbcs.north isa DCBC
        #= none:328 =#
        #= none:328 =# @test fbcs.south isa DCBC
        #= none:329 =#
        #= none:329 =# @test !(fbcs.top isa DCBC)
        #= none:330 =#
        #= none:330 =# @test !(fbcs.bottom isa DCBC)
        #= none:331 =#
    end
end
#= none:338 =#
function test_triply_periodic_halo_communication_with_411_ranks(halo, child_arch)
    #= none:338 =#
    #= none:339 =#
    arch = Distributed(child_arch; partition = Partition(4))
    #= none:340 =#
    grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Periodic), size = (8, 8, 8), extent = (1, 2, 3), halo = halo)
    #= none:341 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:343 =#
    for field = merge(fields(model))
        #= none:344 =#
        fill!(field, arch.local_rank)
        #= none:345 =#
        fill_halo_regions!(field)
        #= none:347 =#
        #= none:347 =# @test all(east_halo(field, include_corners = false) .== arch.connectivity.east)
        #= none:348 =#
        #= none:348 =# @test all(west_halo(field, include_corners = false) .== arch.connectivity.west)
        #= none:350 =#
        #= none:350 =# @test all(interior(field) .== arch.local_rank)
        #= none:351 =#
        #= none:351 =# @test all(north_halo(field, include_corners = false) .== arch.local_rank)
        #= none:352 =#
        #= none:352 =# @test all(south_halo(field, include_corners = false) .== arch.local_rank)
        #= none:353 =#
        #= none:353 =# @test all(top_halo(field, include_corners = false) .== arch.local_rank)
        #= none:354 =#
        #= none:354 =# @test all(bottom_halo(field, include_corners = false) .== arch.local_rank)
        #= none:355 =#
    end
    #= none:357 =#
    return nothing
end
#= none:360 =#
function test_triply_periodic_halo_communication_with_141_ranks(halo, child_arch)
    #= none:360 =#
    #= none:361 =#
    arch = Distributed(child_arch; partition = Partition(1, 4))
    #= none:362 =#
    grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Periodic), size = (8, 8, 8), extent = (1, 2, 3), halo = halo)
    #= none:363 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:365 =#
    for field = (fields(model)..., model.pressures.pNHS)
        #= none:366 =#
        fill!(field, arch.local_rank)
        #= none:367 =#
        fill_halo_regions!(field)
        #= none:369 =#
        #= none:369 =# @test all(north_halo(field, include_corners = false) .== arch.connectivity.north)
        #= none:370 =#
        #= none:370 =# @test all(south_halo(field, include_corners = false) .== arch.connectivity.south)
        #= none:372 =#
        #= none:372 =# @test all(interior(field) .== arch.local_rank)
        #= none:373 =#
        #= none:373 =# @test all(east_halo(field, include_corners = false) .== arch.local_rank)
        #= none:374 =#
        #= none:374 =# @test all(west_halo(field, include_corners = false) .== arch.local_rank)
        #= none:375 =#
        #= none:375 =# @test all(top_halo(field, include_corners = false) .== arch.local_rank)
        #= none:376 =#
        #= none:376 =# @test all(bottom_halo(field, include_corners = false) .== arch.local_rank)
        #= none:377 =#
    end
    #= none:379 =#
    return nothing
end
#= none:382 =#
function test_triply_periodic_halo_communication_with_221_ranks(halo, child_arch)
    #= none:382 =#
    #= none:383 =#
    arch = Distributed(child_arch; partition = Partition(2, 2))
    #= none:384 =#
    grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Periodic), size = (8, 8, 4), extent = (1, 2, 3), halo = halo)
    #= none:385 =#
    model = NonhydrostaticModel(grid = grid)
    #= none:387 =#
    for field = merge(fields(model))
        #= none:388 =#
        fill!(field, arch.local_rank)
        #= none:389 =#
        fill_halo_regions!(field)
        #= none:391 =#
        #= none:391 =# @test all(interior(field) .== arch.local_rank)
        #= none:393 =#
        #= none:393 =# @test all(east_halo(field, include_corners = false) .== arch.connectivity.east)
        #= none:394 =#
        #= none:394 =# @test all(west_halo(field, include_corners = false) .== arch.connectivity.west)
        #= none:395 =#
        #= none:395 =# @test all(north_halo(field, include_corners = false) .== arch.connectivity.north)
        #= none:396 =#
        #= none:396 =# @test all(south_halo(field, include_corners = false) .== arch.connectivity.south)
        #= none:398 =#
        #= none:398 =# @test all(top_halo(field, include_corners = false) .== arch.local_rank)
        #= none:399 =#
        #= none:399 =# @test all(bottom_halo(field, include_corners = false) .== arch.local_rank)
        #= none:400 =#
        #= none:400 =# @test all(southwest_halo(field) .== arch.connectivity.southwest)
        #= none:401 =#
        #= none:401 =# @test all(southeast_halo(field) .== arch.connectivity.southeast)
        #= none:402 =#
        #= none:402 =# @test all(northwest_halo(field) .== arch.connectivity.northwest)
        #= none:403 =#
        #= none:403 =# @test all(northeast_halo(field) .== arch.connectivity.northeast)
        #= none:404 =#
    end
    #= none:406 =#
    return nothing
end
#= none:413 =#
#= none:413 =# @testset "Distributed MPI Oceananigans" begin
        #= none:415 =#
        #= none:415 =# @info "Testing distributed MPI Oceananigans..."
        #= none:417 =#
        #= none:417 =# @testset "Multi architectures rank connectivity" begin
                #= none:418 =#
                #= none:418 =# @info "  Testing multi architecture rank connectivity..."
                #= none:419 =#
                test_triply_periodic_rank_connectivity_with_411_ranks()
                #= none:420 =#
                test_triply_periodic_rank_connectivity_with_141_ranks()
                #= none:421 =#
                test_triply_periodic_rank_connectivity_with_221_ranks()
            end
        #= none:424 =#
        #= none:424 =# @testset "Local grids for distributed models" begin
                #= none:425 =#
                #= none:425 =# @info "  Testing local grids for distributed models..."
                #= none:426 =#
                test_triply_periodic_local_grid_with_411_ranks()
                #= none:427 =#
                test_triply_periodic_local_grid_with_141_ranks()
                #= none:428 =#
                test_triply_periodic_local_grid_with_221_ranks()
            end
        #= none:431 =#
        #= none:431 =# @testset "Injection of halo communication BCs" begin
                #= none:432 =#
                #= none:432 =# @info "  Testing injection of halo communication BCs..."
                #= none:433 =#
                test_triply_periodic_bc_injection_with_411_ranks()
                #= none:434 =#
                test_triply_periodic_bc_injection_with_141_ranks()
                #= none:435 =#
                test_triply_periodic_bc_injection_with_221_ranks()
            end
        #= none:438 =#
        #= none:438 =# @testset "Halo communication" begin
                #= none:439 =#
                #= none:439 =# @info "  Testing halo communication..."
                #= none:440 =#
                for child_arch = archs
                    #= none:441 =#
                    for H = 1:3
                        #= none:442 =#
                        test_triply_periodic_halo_communication_with_411_ranks((H, H, H), child_arch)
                        #= none:443 =#
                        test_triply_periodic_halo_communication_with_141_ranks((H, H, H), child_arch)
                        #= none:444 =#
                        test_triply_periodic_halo_communication_with_221_ranks((H, H, H), child_arch)
                        #= none:445 =#
                    end
                    #= none:446 =#
                end
            end
        #= none:450 =#
        #= none:450 =# @testset "Time stepping NonhydrostaticModel" begin
                #= none:451 =#
                if CPU() ∈ archs
                    #= none:452 =#
                    for partition = [Partition(1, 4), Partition(2, 2), Partition(4, 1)]
                        #= none:453 =#
                        #= none:453 =# @info "Time-stepping a distributed NonhydrostaticModel with partition $(partition)..."
                        #= none:454 =#
                        arch = Distributed(; partition)
                        #= none:455 =#
                        grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Periodic), size = (8, 8, 8), extent = (1, 2, 3))
                        #= none:456 =#
                        model = NonhydrostaticModel(; grid)
                        #= none:458 =#
                        time_step!(model, 1)
                        #= none:459 =#
                        #= none:459 =# @test model isa NonhydrostaticModel
                        #= none:460 =#
                        #= none:460 =# @test model.clock.time ≈ 1
                        #= none:462 =#
                        simulation = Simulation(model, Δt = 1, stop_iteration = 2)
                        #= none:463 =#
                        run!(simulation)
                        #= none:464 =#
                        #= none:464 =# @test model isa NonhydrostaticModel
                        #= none:465 =#
                        #= none:465 =# @test model.clock.time ≈ 2
                        #= none:466 =#
                    end
                end
            end
        #= none:470 =#
        #= none:470 =# @testset "Time stepping ShallowWaterModel" begin
                #= none:471 =#
                for child_arch = archs
                    #= none:472 =#
                    arch = Distributed(child_arch; partition = Partition(1, 4))
                    #= none:473 =#
                    grid = RectilinearGrid(arch, topology = (Periodic, Periodic, Flat), size = (8, 8), extent = (1, 2), halo = (3, 3))
                    #= none:474 =#
                    model = ShallowWaterModel(; momentum_advection = nothing, mass_advection = nothing, tracer_advection = nothing, grid, gravitational_acceleration = 1)
                    #= none:476 =#
                    set!(model, h = 1)
                    #= none:477 =#
                    time_step!(model, 1)
                    #= none:478 =#
                    #= none:478 =# @test model isa ShallowWaterModel
                    #= none:479 =#
                    #= none:479 =# @test model.clock.time ≈ 1
                    #= none:481 =#
                    simulation = Simulation(model, Δt = 1, stop_iteration = 2)
                    #= none:482 =#
                    run!(simulation)
                    #= none:483 =#
                    #= none:483 =# @test model isa ShallowWaterModel
                    #= none:484 =#
                    #= none:484 =# @test model.clock.time ≈ 2
                    #= none:485 =#
                end
            end
    end