
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:2 =#
include("data_dependencies.jl")
#= none:4 =#
using Oceananigans.Grids: total_extent, xspacings, yspacings, zspacings, xnode, ynode, znode, λnode, φnode, λspacings, φspacings, λspacing, φspacing
#= none:9 =#
using Oceananigans.Operators: Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δxᶜᶜᵃ, Δyᶠᶜᵃ, Δyᶜᶠᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ, Azᶜᶜᵃ
#= none:15 =#
function test_regular_rectilinear_correct_size(FT)
    #= none:15 =#
    #= none:16 =#
    grid = RectilinearGrid(CPU(), FT, size = (4, 6, 8), extent = (2π, 4π, 9π))
    #= none:18 =#
    #= none:18 =# @test grid.Nx == 4
    #= none:19 =#
    #= none:19 =# @test grid.Ny == 6
    #= none:20 =#
    #= none:20 =# @test grid.Nz == 8
    #= none:23 =#
    #= none:23 =# @test grid.Lx ≈ 2π
    #= none:24 =#
    #= none:24 =# @test grid.Ly ≈ 4π
    #= none:25 =#
    #= none:25 =# @test grid.Lz ≈ 9π
    #= none:27 =#
    return nothing
end
#= none:30 =#
function test_regular_rectilinear_correct_extent(FT)
    #= none:30 =#
    #= none:31 =#
    grid = RectilinearGrid(CPU(), FT, size = (4, 6, 8), x = (1, 2), y = (π, 3π), z = (0, 4))
    #= none:33 =#
    #= none:33 =# @test grid.Lx ≈ 1
    #= none:34 =#
    #= none:34 =# @test grid.Ly ≈ 2π
    #= none:35 =#
    #= none:35 =# @test grid.Lz ≈ 4
    #= none:37 =#
    return nothing
end
#= none:40 =#
function test_regular_rectilinear_correct_coordinate_lengths(FT)
    #= none:40 =#
    #= none:41 =#
    grid = RectilinearGrid(CPU(), FT, size = (2, 3, 4), extent = (1, 1, 1), halo = (1, 1, 1), topology = (Periodic, Bounded, Bounded))
    #= none:44 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:45 =#
    (Hx, Hy, Hz) = halo_size(grid)
    #= none:47 =#
    #= none:47 =# @test length(grid.xᶜᵃᵃ) == Nx + 2Hx
    #= none:48 =#
    #= none:48 =# @test length(grid.yᵃᶜᵃ) == Ny + 2Hy
    #= none:49 =#
    #= none:49 =# @test length(grid.zᵃᵃᶜ) == Nz + 2Hz
    #= none:50 =#
    #= none:50 =# @test length(grid.xᶠᵃᵃ) == Nx + 2Hx
    #= none:51 =#
    #= none:51 =# @test length(grid.yᵃᶠᵃ) == Ny + 2Hy + 1
    #= none:52 =#
    #= none:52 =# @test length(grid.zᵃᵃᶠ) == Nz + 2Hz + 1
    #= none:54 =#
    return nothing
end
#= none:57 =#
function test_regular_rectilinear_correct_halo_size(FT)
    #= none:57 =#
    #= none:58 =#
    grid = RectilinearGrid(CPU(), FT, size = (4, 6, 8), extent = (2π, 4π, 9π), halo = (1, 2, 3))
    #= none:60 =#
    #= none:60 =# @test grid.Hx == 1
    #= none:61 =#
    #= none:61 =# @test grid.Hy == 2
    #= none:62 =#
    #= none:62 =# @test grid.Hz == 3
    #= none:64 =#
    return nothing
end
#= none:67 =#
function test_regular_rectilinear_correct_halo_faces(FT)
    #= none:67 =#
    #= none:68 =#
    N = 4
    #= none:69 =#
    H = 1
    #= none:70 =#
    L = 2.0
    #= none:71 =#
    Δ = L / N
    #= none:73 =#
    topo = (Periodic, Bounded, Bounded)
    #= none:74 =#
    grid = RectilinearGrid(CPU(), FT, topology = topo, size = (N, N, N), x = (0, L), y = (0, L), z = (0, L), halo = (H, H, H))
    #= none:76 =#
    #= none:76 =# @test grid.xᶠᵃᵃ[0] == -H * Δ
    #= none:77 =#
    #= none:77 =# @test grid.yᵃᶠᵃ[0] == -H * Δ
    #= none:78 =#
    #= none:78 =# @test grid.zᵃᵃᶠ[0] == -H * Δ
    #= none:80 =#
    #= none:80 =# @test grid.xᶠᵃᵃ[N + 1] == L
    #= none:81 =#
    #= none:81 =# @test grid.yᵃᶠᵃ[N + 2] == L + H * Δ
    #= none:82 =#
    #= none:82 =# @test grid.zᵃᵃᶠ[N + 2] == L + H * Δ
    #= none:84 =#
    return nothing
end
#= none:87 =#
function test_regular_rectilinear_correct_first_cells(FT)
    #= none:87 =#
    #= none:88 =#
    N = 4
    #= none:89 =#
    H = 1
    #= none:90 =#
    L = 4.0
    #= none:91 =#
    Δ = L / N
    #= none:93 =#
    grid = RectilinearGrid(CPU(), FT, size = (N, N, N), x = (0, L), y = (0, L), z = (0, L), halo = (H, H, H))
    #= none:95 =#
    #= none:95 =# @test grid.xᶜᵃᵃ[1] == Δ / 2
    #= none:96 =#
    #= none:96 =# @test grid.yᵃᶜᵃ[1] == Δ / 2
    #= none:97 =#
    #= none:97 =# @test grid.zᵃᵃᶜ[1] == Δ / 2
    #= none:99 =#
    return nothing
end
#= none:102 =#
function test_regular_rectilinear_correct_end_faces(FT)
    #= none:102 =#
    #= none:103 =#
    N = 4
    #= none:104 =#
    L = 2.0
    #= none:105 =#
    Δ = L / N
    #= none:107 =#
    grid = RectilinearGrid(CPU(), FT, size = (N, N, N), x = (0, L), y = (0, L), z = (0, L), halo = (1, 1, 1), topology = (Periodic, Bounded, Bounded))
    #= none:110 =#
    #= none:110 =# @test grid.xᶠᵃᵃ[N + 1] == L
    #= none:111 =#
    #= none:111 =# @test grid.yᵃᶠᵃ[N + 2] == L + Δ
    #= none:112 =#
    #= none:112 =# @test grid.zᵃᵃᶠ[N + 2] == L + Δ
    #= none:114 =#
    return nothing
end
#= none:117 =#
function test_regular_rectilinear_ranges_have_correct_length(FT)
    #= none:117 =#
    #= none:118 =#
    (Nx, Ny, Nz) = (8, 9, 10)
    #= none:119 =#
    (Hx, Hy, Hz) = (1, 2, 1)
    #= none:121 =#
    grid = RectilinearGrid(CPU(), FT, size = (Nx, Ny, Nz), extent = (1, 1, 1), halo = (Hx, Hy, Hz), topology = (Bounded, Bounded, Bounded))
    #= none:124 =#
    #= none:124 =# @test length(grid.xᶜᵃᵃ) == Nx + 2Hx
    #= none:125 =#
    #= none:125 =# @test length(grid.yᵃᶜᵃ) == Ny + 2Hy
    #= none:126 =#
    #= none:126 =# @test length(grid.zᵃᵃᶜ) == Nz + 2Hz
    #= none:127 =#
    #= none:127 =# @test length(grid.xᶠᵃᵃ) == Nx + 1 + 2Hx
    #= none:128 =#
    #= none:128 =# @test length(grid.yᵃᶠᵃ) == Ny + 1 + 2Hy
    #= none:129 =#
    #= none:129 =# @test length(grid.zᵃᵃᶠ) == Nz + 1 + 2Hz
    #= none:131 =#
    return nothing
end
#= none:135 =#
function test_regular_rectilinear_no_roundoff_error_in_ranges(FT)
    #= none:135 =#
    #= none:136 =#
    Nx = (Ny = 1)
    #= none:137 =#
    Nz = 64
    #= none:138 =#
    Hz = 1
    #= none:140 =#
    grid = RectilinearGrid(CPU(), FT, size = (Nx, Ny, Nz), extent = (1, 1, π / 2), halo = (1, 1, Hz))
    #= none:142 =#
    #= none:142 =# @test length(grid.zᵃᵃᶜ) == Nz + 2Hz
    #= none:143 =#
    #= none:143 =# @test length(grid.zᵃᵃᶠ) == Nz + 2Hz + 1
    #= none:145 =#
    return nothing
end
#= none:148 =#
function test_regular_rectilinear_grid_properties_are_same_type(FT)
    #= none:148 =#
    #= none:149 =#
    grid = RectilinearGrid(CPU(), FT, size = (10, 10, 10), extent = (1, 1 // 7, 2π))
    #= none:151 =#
    #= none:151 =# @test grid.Lx isa FT
    #= none:152 =#
    #= none:152 =# @test grid.Ly isa FT
    #= none:153 =#
    #= none:153 =# @test grid.Lz isa FT
    #= none:154 =#
    #= none:154 =# @test grid.Δxᶠᵃᵃ isa FT
    #= none:155 =#
    #= none:155 =# @test grid.Δyᵃᶠᵃ isa FT
    #= none:156 =#
    #= none:156 =# @test grid.Δzᵃᵃᶠ isa FT
    #= none:158 =#
    #= none:158 =# @test eltype(grid.xᶠᵃᵃ) == FT
    #= none:159 =#
    #= none:159 =# @test eltype(grid.yᵃᶠᵃ) == FT
    #= none:160 =#
    #= none:160 =# @test eltype(grid.zᵃᵃᶠ) == FT
    #= none:161 =#
    #= none:161 =# @test eltype(grid.xᶜᵃᵃ) == FT
    #= none:162 =#
    #= none:162 =# @test eltype(grid.yᵃᶜᵃ) == FT
    #= none:163 =#
    #= none:163 =# @test eltype(grid.zᵃᵃᶜ) == FT
    #= none:165 =#
    return nothing
end
#= none:168 =#
function test_regular_rectilinear_xnode_ynode_znode_and_spacings(arch, FT)
    #= none:168 =#
    #= none:170 =#
    #= none:170 =# @info "    Testing with ($(FT)) on ($(arch))..."
    #= none:172 =#
    N = 3
    #= none:174 =#
    size = (N, N, N)
    #= none:175 =#
    topology = (Periodic, Periodic, Bounded)
    #= none:177 =#
    regular_spaced_grid = RectilinearGrid(arch, FT; size, topology, x = (0, π), y = (0, π), z = (0, π))
    #= none:180 =#
    domain = collect(range(0, stop = π, length = N + 1))
    #= none:182 =#
    variably_spaced_grid = RectilinearGrid(arch, FT; size, topology, x = domain, y = domain, z = domain)
    #= none:185 =#
    grids_types = ["regularly spaced", "variably spaced"]
    #= none:186 =#
    grids = [regular_spaced_grid, variably_spaced_grid]
    #= none:188 =#
    for (grid_type, grid) = zip(grids_types, grids)
        #= none:189 =#
        #= none:189 =# @info "        Testing grid utils on $(grid_type) grid...."
        #= none:191 =#
        #= none:191 =# @test xnode(2, grid, Center()) ≈ FT(π / 2)
        #= none:192 =#
        #= none:192 =# @test ynode(2, grid, Center()) ≈ FT(π / 2)
        #= none:193 =#
        #= none:193 =# @test znode(2, grid, Center()) ≈ FT(π / 2)
        #= none:195 =#
        #= none:195 =# @test xnode(2, grid, Face()) ≈ FT(π / 3)
        #= none:196 =#
        #= none:196 =# @test ynode(2, grid, Face()) ≈ FT(π / 3)
        #= none:197 =#
        #= none:197 =# @test znode(2, grid, Face()) ≈ FT(π / 3)
        #= none:199 =#
        #= none:199 =# @test minimum_xspacing(grid) ≈ FT(π / 3)
        #= none:200 =#
        #= none:200 =# @test minimum_yspacing(grid) ≈ FT(π / 3)
        #= none:201 =#
        #= none:201 =# @test minimum_zspacing(grid) ≈ FT(π / 3)
        #= none:203 =#
        #= none:203 =# @test all(xspacings(grid, Center()) .≈ FT(π / N))
        #= none:204 =#
        #= none:204 =# @test all(yspacings(grid, Center()) .≈ FT(π / N))
        #= none:205 =#
        #= none:205 =# @test all(zspacings(grid, Center()) .≈ FT(π / N))
        #= none:207 =#
        #= none:207 =# @test all((x ≈ FT(π / N) for x = xspacings(grid, Face())))
        #= none:208 =#
        #= none:208 =# @test all((y ≈ FT(π / N) for y = yspacings(grid, Face())))
        #= none:209 =#
        #= none:209 =# @test all((z ≈ FT(π / N) for z = zspacings(grid, Face())))
        #= none:211 =#
        #= none:211 =# @test xspacings(grid, Face()) == xspacings(grid, Face(), Center(), Center())
        #= none:212 =#
        #= none:212 =# @test yspacings(grid, Face()) == yspacings(grid, Center(), Face(), Center())
        #= none:213 =#
        #= none:213 =# @test zspacings(grid, Face()) == zspacings(grid, Center(), Center(), Face())
        #= none:215 =#
        #= none:215 =# @test xspacing(1, 1, 1, grid, Face(), Center(), Center()) ≈ FT(π / N)
        #= none:216 =#
        #= none:216 =# @test yspacing(1, 1, 1, grid, Center(), Face(), Center()) ≈ FT(π / N)
        #= none:217 =#
        #= none:217 =# @test zspacing(1, 1, 1, grid, Center(), Center(), Face()) ≈ FT(π / N)
        #= none:218 =#
    end
    #= none:220 =#
    return nothing
end
#= none:223 =#
function test_regular_rectilinear_constructor_errors(FT)
    #= none:223 =#
    #= none:224 =#
    #= none:224 =# @test isbitstype(typeof(RectilinearGrid(CPU(), FT, size = (16, 16, 16), extent = (1, 1, 1))))
    #= none:226 =#
    #= none:226 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (32,), extent = (1, 1, 1))
    #= none:227 =#
    #= none:227 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (32, 64), extent = (1, 1, 1))
    #= none:228 =#
    #= none:228 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (32, 32, 32, 16), extent = (1, 1, 1))
    #= none:230 =#
    #= none:230 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (32, 32, 32.0), extent = (1, 1, 1))
    #= none:231 =#
    #= none:231 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (20.1, 32, 32), extent = (1, 1, 1))
    #= none:232 =#
    #= none:232 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (32, nothing, 32), extent = (1, 1, 1))
    #= none:233 =#
    #= none:233 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (32, "32", 32), extent = (1, 1, 1))
    #= none:234 =#
    #= none:234 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (32, 32, 32), extent = (1, nothing, 1))
    #= none:235 =#
    #= none:235 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (32, 32, 32), extent = (1, "1", 1))
    #= none:236 =#
    #= none:236 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (32, 32, 32), extent = (1, 1, 1), halo = (1, 1))
    #= none:237 =#
    #= none:237 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (32, 32, 32), extent = (1, 1, 1), halo = (1.0, 1, 1))
    #= none:239 =#
    #= none:239 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), y = [1, 2])
    #= none:240 =#
    #= none:240 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), z = (-π, π))
    #= none:241 =#
    #= none:241 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), x = 1, y = 2, z = 3)
    #= none:242 =#
    #= none:242 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), x = (0, 1), y = (0, 2), z = 4)
    #= none:243 =#
    #= none:243 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), x = (-1 // 2, 1), y = (1 // 7, 5 // 7), z = ("0", "1"))
    #= none:244 =#
    #= none:244 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), x = (-1 // 2, 1), y = (1 // 7, 5 // 7), z = (1, 2, 3))
    #= none:245 =#
    #= none:245 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), x = (1, 0), y = (1 // 7, 5 // 7), z = (1, 2))
    #= none:246 =#
    #= none:246 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), x = (0, 1), y = (1, 5), z = (π, -π))
    #= none:247 =#
    #= none:247 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), x = (0, 1), y = (1, 5), z = (π, -π))
    #= none:248 =#
    #= none:248 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), extent = (1, 2, 3), x = (0, 1))
    #= none:249 =#
    #= none:249 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), extent = (1, 2, 3), x = (0, 1), y = (1, 5), z = (-π, π))
    #= none:251 =#
    #= none:251 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, size = (16, 16, 16), extent = (1, 1, 1), topology = (Periodic, Periodic, Flux))
    #= none:253 =#
    #= none:253 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, topology = (Flat, Periodic, Periodic), size = (16, 16, 16), extent = 1)
    #= none:254 =#
    #= none:254 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, topology = (Periodic, Flat, Periodic), size = (16, 16, 16), extent = (1, 1))
    #= none:255 =#
    #= none:255 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, topology = (Periodic, Periodic, Flat), size = (16, 16, 16), extent = (1, 1, 1))
    #= none:256 =#
    #= none:256 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, topology = (Periodic, Periodic, Flat), size = (16, 16), extent = (1, 1, 1))
    #= none:257 =#
    #= none:257 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, topology = (Periodic, Periodic, Flat), size = 16, extent = (1, 1, 1))
    #= none:259 =#
    #= none:259 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, topology = (Periodic, Flat, Flat), size = 16, extent = (1, 1, 1))
    #= none:260 =#
    #= none:260 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, topology = (Flat, Periodic, Flat), size = 16, extent = (1, 1))
    #= none:261 =#
    #= none:261 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, topology = (Flat, Flat, Periodic), size = (16, 16), extent = 1)
    #= none:263 =#
    #= none:263 =# @test_throws ArgumentError RectilinearGrid(CPU(), FT, topology = (Flat, Flat, Flat), size = 16, extent = 1)
    #= none:265 =#
    return nothing
end
#= none:268 =#
function flat_size_regular_rectilinear_grid(FT; topology, size, extent)
    #= none:268 =#
    #= none:269 =#
    grid = RectilinearGrid(CPU(), FT; size, topology, extent)
    #= none:270 =#
    return (grid.Nx, grid.Ny, grid.Nz)
end
#= none:273 =#
function flat_halo_regular_rectilinear_grid(FT; topology, size, halo, extent)
    #= none:273 =#
    #= none:274 =#
    grid = RectilinearGrid(CPU(), FT; size, halo, topology, extent)
    #= none:275 =#
    return (grid.Hx, grid.Hy, grid.Hz)
end
#= none:278 =#
function flat_extent_regular_rectilinear_grid(FT; topology, size, extent)
    #= none:278 =#
    #= none:279 =#
    grid = RectilinearGrid(CPU(), FT; size, topology, extent)
    #= none:280 =#
    return (grid.Lx, grid.Ly, grid.Lz)
end
#= none:283 =#
function test_flat_size_regular_rectilinear_grid(FT)
    #= none:283 =#
    #= none:284 =#
    #= none:284 =# @test flat_size_regular_rectilinear_grid(FT, topology = (Flat, Periodic, Periodic), size = (2, 3), extent = (1, 1)) === (1, 2, 3)
    #= none:285 =#
    #= none:285 =# @test flat_size_regular_rectilinear_grid(FT, topology = (Periodic, Flat, Bounded), size = (2, 3), extent = (1, 1)) === (2, 1, 3)
    #= none:286 =#
    #= none:286 =# @test flat_size_regular_rectilinear_grid(FT, topology = (Periodic, Bounded, Flat), size = (2, 3), extent = (1, 1)) === (2, 3, 1)
    #= none:288 =#
    #= none:288 =# @test flat_size_regular_rectilinear_grid(FT, topology = (Flat, Periodic, Periodic), size = (2, 3), extent = (1, 1)) === (1, 2, 3)
    #= none:289 =#
    #= none:289 =# @test flat_size_regular_rectilinear_grid(FT, topology = (Periodic, Flat, Bounded), size = (2, 3), extent = (1, 1)) === (2, 1, 3)
    #= none:290 =#
    #= none:290 =# @test flat_size_regular_rectilinear_grid(FT, topology = (Periodic, Bounded, Flat), size = (2, 3), extent = (1, 1)) === (2, 3, 1)
    #= none:292 =#
    #= none:292 =# @test flat_size_regular_rectilinear_grid(FT, topology = (Periodic, Flat, Flat), size = 2, extent = 1) === (2, 1, 1)
    #= none:293 =#
    #= none:293 =# @test flat_size_regular_rectilinear_grid(FT, topology = (Flat, Periodic, Flat), size = 2, extent = 1) === (1, 2, 1)
    #= none:294 =#
    #= none:294 =# @test flat_size_regular_rectilinear_grid(FT, topology = (Flat, Flat, Bounded), size = 2, extent = 1) === (1, 1, 2)
    #= none:296 =#
    #= none:296 =# @test flat_size_regular_rectilinear_grid(FT, topology = (Flat, Flat, Flat), size = (), extent = ()) === (1, 1, 1)
    #= none:298 =#
    #= none:298 =# @test flat_halo_regular_rectilinear_grid(FT, topology = (Flat, Periodic, Periodic), size = (3, 3), extent = (1, 1), halo = nothing) === (0, 3, 3)
    #= none:299 =#
    #= none:299 =# @test flat_halo_regular_rectilinear_grid(FT, topology = (Periodic, Flat, Bounded), size = (3, 3), extent = (1, 1), halo = nothing) === (3, 0, 3)
    #= none:300 =#
    #= none:300 =# @test flat_halo_regular_rectilinear_grid(FT, topology = (Periodic, Bounded, Flat), size = (3, 3), extent = (1, 1), halo = nothing) === (3, 3, 0)
    #= none:302 =#
    #= none:302 =# @test flat_halo_regular_rectilinear_grid(FT, topology = (Flat, Periodic, Periodic), size = (3, 3), extent = (1, 1), halo = (2, 3)) === (0, 2, 3)
    #= none:303 =#
    #= none:303 =# @test flat_halo_regular_rectilinear_grid(FT, topology = (Periodic, Flat, Bounded), size = (3, 3), extent = (1, 1), halo = (2, 3)) === (2, 0, 3)
    #= none:304 =#
    #= none:304 =# @test flat_halo_regular_rectilinear_grid(FT, topology = (Periodic, Bounded, Flat), size = (3, 3), extent = (1, 1), halo = (2, 3)) === (2, 3, 0)
    #= none:306 =#
    #= none:306 =# @test flat_halo_regular_rectilinear_grid(FT, topology = (Periodic, Flat, Flat), size = 2, extent = 1, halo = 2) === (2, 0, 0)
    #= none:307 =#
    #= none:307 =# @test flat_halo_regular_rectilinear_grid(FT, topology = (Flat, Periodic, Flat), size = 2, extent = 1, halo = 2) === (0, 2, 0)
    #= none:308 =#
    #= none:308 =# @test flat_halo_regular_rectilinear_grid(FT, topology = (Flat, Flat, Bounded), size = 2, extent = 1, halo = 2) === (0, 0, 2)
    #= none:310 =#
    #= none:310 =# @test flat_halo_regular_rectilinear_grid(FT, topology = (Flat, Flat, Flat), size = (), extent = (), halo = ()) === (0, 0, 0)
    #= none:312 =#
    #= none:312 =# @test flat_extent_regular_rectilinear_grid(FT, topology = (Flat, Periodic, Periodic), size = (2, 3), extent = (1, 1)) == (1, 1, 1)
    #= none:313 =#
    #= none:313 =# @test flat_extent_regular_rectilinear_grid(FT, topology = (Periodic, Flat, Periodic), size = (2, 3), extent = (1, 1)) == (1, 1, 1)
    #= none:314 =#
    #= none:314 =# @test flat_extent_regular_rectilinear_grid(FT, topology = (Periodic, Periodic, Flat), size = (2, 3), extent = (1, 1)) == (1, 1, 1)
    #= none:316 =#
    #= none:316 =# @test flat_extent_regular_rectilinear_grid(FT, topology = (Periodic, Flat, Flat), size = 2, extent = 1) == (1, 1, 1)
    #= none:317 =#
    #= none:317 =# @test flat_extent_regular_rectilinear_grid(FT, topology = (Flat, Periodic, Flat), size = 2, extent = 1) == (1, 1, 1)
    #= none:318 =#
    #= none:318 =# @test flat_extent_regular_rectilinear_grid(FT, topology = (Flat, Flat, Periodic), size = 2, extent = 1) == (1, 1, 1)
    #= none:320 =#
    #= none:320 =# @test flat_extent_regular_rectilinear_grid(FT, topology = (Flat, Flat, Flat), size = (), extent = ()) == (1, 1, 1)
    #= none:322 =#
    return nothing
end
#= none:325 =#
function test_grid_equality(arch)
    #= none:325 =#
    #= none:326 =#
    topo = (Periodic, Periodic, Bounded)
    #= none:327 =#
    (Nx, Ny, Nz) = (4, 7, 9)
    #= none:328 =#
    grid1 = RectilinearGrid(arch, topology = topo, size = (Nx, Ny, Nz), x = (0, 1), y = (-1, 1), z = (0, Nz))
    #= none:329 =#
    grid2 = RectilinearGrid(arch, topology = topo, size = (Nx, Ny, Nz), x = (0, 1), y = (-1, 1), z = 0:Nz)
    #= none:330 =#
    grid3 = RectilinearGrid(arch, topology = topo, size = (Nx, Ny, Nz), x = (0, 1), y = (-1, 1), z = 0:Nz)
    #= none:332 =#
    return grid1 == grid1 && (grid2 == grid3 && grid1 !== grid3)
end
#= none:335 =#
function test_grid_equality_over_architectures()
    #= none:335 =#
    #= none:336 =#
    grid_cpu = RectilinearGrid(CPU(), topology = (Periodic, Periodic, Bounded), size = (3, 7, 9), x = (0, 1), y = (-1, 1), z = 0:9)
    #= none:337 =#
    grid_gpu = RectilinearGrid(GPU(), topology = (Periodic, Periodic, Bounded), size = (3, 7, 9), x = (0, 1), y = (-1, 1), z = 0:9)
    #= none:338 =#
    return grid_cpu == grid_gpu
end
#= none:345 =#
function test_vertically_stretched_grid_properties_are_same_type(FT, arch)
    #= none:345 =#
    #= none:346 =#
    grid = RectilinearGrid(arch, FT, size = (1, 1, 16), x = (0, 1), y = (0, 1), z = collect(0:16))
    #= none:348 =#
    #= none:348 =# @test grid.Lx isa FT
    #= none:349 =#
    #= none:349 =# @test grid.Ly isa FT
    #= none:350 =#
    #= none:350 =# @test grid.Lz isa FT
    #= none:351 =#
    #= none:351 =# @test grid.Δxᶠᵃᵃ isa FT
    #= none:352 =#
    #= none:352 =# @test grid.Δyᵃᶠᵃ isa FT
    #= none:354 =#
    #= none:354 =# @test eltype(grid.xᶠᵃᵃ) == FT
    #= none:355 =#
    #= none:355 =# @test eltype(grid.xᶜᵃᵃ) == FT
    #= none:356 =#
    #= none:356 =# @test eltype(grid.yᵃᶠᵃ) == FT
    #= none:357 =#
    #= none:357 =# @test eltype(grid.yᵃᶜᵃ) == FT
    #= none:358 =#
    #= none:358 =# @test eltype(grid.zᵃᵃᶠ) == FT
    #= none:359 =#
    #= none:359 =# @test eltype(grid.zᵃᵃᶜ) == FT
    #= none:361 =#
    #= none:361 =# @test eltype(grid.Δzᵃᵃᶜ) == FT
    #= none:362 =#
    #= none:362 =# @test eltype(grid.Δzᵃᵃᶠ) == FT
    #= none:364 =#
    return nothing
end
#= none:367 =#
function test_architecturally_correct_stretched_grid(FT, arch, zᵃᵃᶠ)
    #= none:367 =#
    #= none:368 =#
    grid = RectilinearGrid(arch, FT, size = (1, 1, length(zᵃᵃᶠ) - 1), x = (0, 1), y = (0, 1), z = zᵃᵃᶠ)
    #= none:370 =#
    ArrayType = array_type(arch)
    #= none:371 =#
    #= none:371 =# @test grid.zᵃᵃᶠ isa OffsetArray{FT, 1, <:ArrayType}
    #= none:372 =#
    #= none:372 =# @test grid.zᵃᵃᶜ isa OffsetArray{FT, 1, <:ArrayType}
    #= none:373 =#
    #= none:373 =# @test grid.Δzᵃᵃᶠ isa OffsetArray{FT, 1, <:ArrayType}
    #= none:374 =#
    #= none:374 =# @test grid.Δzᵃᵃᶜ isa OffsetArray{FT, 1, <:ArrayType}
    #= none:376 =#
    return nothing
end
#= none:379 =#
function test_rectilinear_grid_correct_spacings(FT, N)
    #= none:379 =#
    #= none:380 =#
    S = 3
    #= none:381 =#
    zᵃᵃᶠ(k) = begin
            #= none:381 =#
            tanh(S * ((2 * (k - 1)) / N - 1)) / tanh(S)
        end
    #= none:384 =#
    grid = RectilinearGrid(CPU(), FT, size = (N, N, N), x = collect(0:N), y = collect(0:N) .^ 2, z = zᵃᵃᶠ)
    #= none:386 =#
    #= none:386 =# @test all(grid.Δxᶜᵃᵃ .== 1)
    #= none:387 =#
    #= none:387 =# @test all(grid.Δxᶠᵃᵃ .== 1)
    #= none:389 =#
    yᵃᶠᵃ(j) = begin
            #= none:389 =#
            (j - 1) ^ 2
        end
    #= none:390 =#
    yᵃᶜᵃ(j) = begin
            #= none:390 =#
            (j ^ 2 + (j - 1) ^ 2) / 2
        end
    #= none:391 =#
    Δyᵃᶠᵃ(j) = begin
            #= none:391 =#
            yᵃᶜᵃ(j) - yᵃᶜᵃ(j - 1)
        end
    #= none:392 =#
    Δyᵃᶜᵃ(j) = begin
            #= none:392 =#
            yᵃᶠᵃ(j + 1) - yᵃᶠᵃ(j)
        end
    #= none:394 =#
    #= none:394 =# @test all(isapprox.(grid.yᵃᶠᵃ[1:N + 1], yᵃᶠᵃ.(1:N + 1)))
    #= none:395 =#
    #= none:395 =# @test all(isapprox.(grid.yᵃᶜᵃ[1:N], yᵃᶜᵃ.(1:N)))
    #= none:396 =#
    #= none:396 =# @test all(isapprox.(grid.Δyᵃᶜᵃ[1:N], Δyᵃᶜᵃ.(1:N)))
    #= none:400 =#
    #= none:400 =# @test all(isapprox.(grid.Δyᵃᶠᵃ[2:N], Δyᵃᶠᵃ.(2:N)))
    #= none:402 =#
    zᵃᵃᶜ(k) = begin
            #= none:402 =#
            (zᵃᵃᶠ(k) + zᵃᵃᶠ(k + 1)) / 2
        end
    #= none:403 =#
    Δzᵃᵃᶜ(k) = begin
            #= none:403 =#
            zᵃᵃᶠ(k + 1) - zᵃᵃᶠ(k)
        end
    #= none:404 =#
    Δzᵃᵃᶠ(k) = begin
            #= none:404 =#
            zᵃᵃᶜ(k) - zᵃᵃᶜ(k - 1)
        end
    #= none:406 =#
    #= none:406 =# @test all(isapprox.(grid.zᵃᵃᶠ[1:N + 1], zᵃᵃᶠ.(1:N + 1)))
    #= none:407 =#
    #= none:407 =# @test all(isapprox.(grid.zᵃᵃᶜ[1:N], zᵃᵃᶜ.(1:N)))
    #= none:408 =#
    #= none:408 =# @test all(isapprox.(grid.Δzᵃᵃᶜ[1:N], Δzᵃᵃᶜ.(1:N)))
    #= none:410 =#
    #= none:410 =# @test all(isapprox.(zspacings(grid, Face(), with_halos = true), grid.Δzᵃᵃᶠ))
    #= none:411 =#
    #= none:411 =# @test all(isapprox.(zspacings(grid, Center(), with_halos = true), grid.Δzᵃᵃᶜ))
    #= none:412 =#
    #= none:412 =# @test zspacing(1, 1, 2, grid, Center(), Center(), Face()) == grid.Δzᵃᵃᶠ[2]
    #= none:414 =#
    #= none:414 =# @test minimum_zspacing(grid, Center(), Center(), Center()) ≈ minimum(grid.Δzᵃᵃᶜ[1:grid.Nz])
    #= none:418 =#
    #= none:418 =# @test all(isapprox.(grid.Δzᵃᵃᶠ[2:N], Δzᵃᵃᶠ.(2:N)))
    #= none:420 =#
    return nothing
end
#= none:427 =#
function test_basic_lat_lon_bounded_domain(FT)
    #= none:427 =#
    #= none:428 =#
    Nλ = (Nφ = 18)
    #= none:429 =#
    Hλ = (Hφ = 1)
    #= none:431 =#
    grid = LatitudeLongitudeGrid(CPU(), FT, size = (Nλ, Nφ, 1), longitude = (-90, 90), latitude = (-45, 45), z = (0, 1), halo = (Hλ, Hφ, 1))
    #= none:433 =#
    #= none:433 =# @test topology(grid) == (Bounded, Bounded, Bounded)
    #= none:435 =#
    #= none:435 =# @test grid.Nx == Nλ
    #= none:436 =#
    #= none:436 =# @test grid.Ny == Nφ
    #= none:437 =#
    #= none:437 =# @test grid.Nz == 1
    #= none:439 =#
    #= none:439 =# @test grid.Lx == 180
    #= none:440 =#
    #= none:440 =# @test grid.Ly == 90
    #= none:441 =#
    #= none:441 =# @test grid.Lz == 1
    #= none:443 =#
    #= none:443 =# @test grid.Δλᶠᵃᵃ == 10
    #= none:444 =#
    #= none:444 =# @test grid.Δφᵃᶠᵃ == 5
    #= none:445 =#
    #= none:445 =# @test grid.Δzᵃᵃᶜ == 1
    #= none:446 =#
    #= none:446 =# @test grid.Δzᵃᵃᶠ == 1
    #= none:448 =#
    #= none:448 =# @test length(grid.λᶠᵃᵃ) == Nλ + 2Hλ + 1
    #= none:449 =#
    #= none:449 =# @test length(grid.λᶜᵃᵃ) == Nλ + 2Hλ
    #= none:451 =#
    #= none:451 =# @test length(grid.φᵃᶠᵃ) == Nφ + 2Hφ + 1
    #= none:452 =#
    #= none:452 =# @test length(grid.φᵃᶜᵃ) == Nφ + 2Hφ
    #= none:454 =#
    #= none:454 =# @test grid.λᶠᵃᵃ[1] == -90
    #= none:455 =#
    #= none:455 =# @test grid.λᶠᵃᵃ[Nλ + 1] == 90
    #= none:457 =#
    #= none:457 =# @test grid.φᵃᶠᵃ[1] == -45
    #= none:458 =#
    #= none:458 =# @test grid.φᵃᶠᵃ[Nφ + 1] == 45
    #= none:460 =#
    #= none:460 =# @test grid.λᶠᵃᵃ[0] == -90 - grid.Δλᶠᵃᵃ
    #= none:461 =#
    #= none:461 =# @test grid.λᶠᵃᵃ[Nλ + 2] == 90 + grid.Δλᶠᵃᵃ
    #= none:463 =#
    #= none:463 =# @test grid.φᵃᶠᵃ[0] == -45 - grid.Δφᵃᶠᵃ
    #= none:464 =#
    #= none:464 =# @test grid.φᵃᶠᵃ[Nφ + 2] == 45 + grid.Δφᵃᶠᵃ
    #= none:466 =#
    #= none:466 =# @test all(diff(grid.λᶠᵃᵃ.parent) .== grid.Δλᶠᵃᵃ)
    #= none:467 =#
    #= none:467 =# @test all(diff(grid.λᶜᵃᵃ.parent) .== grid.Δλᶜᵃᵃ)
    #= none:469 =#
    #= none:469 =# @test all(diff(grid.φᵃᶠᵃ.parent) .== grid.Δφᵃᶠᵃ)
    #= none:470 =#
    #= none:470 =# @test all(diff(grid.φᵃᶜᵃ.parent) .== grid.Δφᵃᶜᵃ)
    #= none:472 =#
    return nothing
end
#= none:475 =#
function test_basic_lat_lon_periodic_domain(FT)
    #= none:475 =#
    #= none:476 =#
    Nλ = 36
    #= none:477 =#
    Nφ = 32
    #= none:478 =#
    Hλ = (Hφ = 1)
    #= none:480 =#
    grid = LatitudeLongitudeGrid(CPU(), FT, size = (Nλ, Nφ, 1), longitude = (-180, 180), latitude = (-80, 80), z = (0, 1), halo = (Hλ, Hφ, 1))
    #= none:482 =#
    #= none:482 =# @test topology(grid) == (Periodic, Bounded, Bounded)
    #= none:484 =#
    #= none:484 =# @test grid.Nx == Nλ
    #= none:485 =#
    #= none:485 =# @test grid.Ny == Nφ
    #= none:486 =#
    #= none:486 =# @test grid.Nz == 1
    #= none:488 =#
    #= none:488 =# @test grid.Lx == 360
    #= none:489 =#
    #= none:489 =# @test grid.Ly == 160
    #= none:490 =#
    #= none:490 =# @test grid.Lz == 1
    #= none:492 =#
    #= none:492 =# @test grid.Δλᶠᵃᵃ == 10
    #= none:493 =#
    #= none:493 =# @test grid.Δφᵃᶠᵃ == 5
    #= none:494 =#
    #= none:494 =# @test grid.Δzᵃᵃᶜ == 1
    #= none:495 =#
    #= none:495 =# @test grid.Δzᵃᵃᶠ == 1
    #= none:497 =#
    #= none:497 =# @test length(grid.λᶠᵃᵃ) == Nλ + 2Hλ
    #= none:498 =#
    #= none:498 =# @test length(grid.λᶜᵃᵃ) == Nλ + 2Hλ
    #= none:500 =#
    #= none:500 =# @test length(grid.φᵃᶠᵃ) == Nφ + 2Hφ + 1
    #= none:501 =#
    #= none:501 =# @test length(grid.φᵃᶜᵃ) == Nφ + 2Hφ
    #= none:503 =#
    #= none:503 =# @test grid.λᶠᵃᵃ[1] == -180
    #= none:504 =#
    #= none:504 =# @test grid.λᶠᵃᵃ[Nλ] == 180 - grid.Δλᶠᵃᵃ
    #= none:506 =#
    #= none:506 =# @test grid.φᵃᶠᵃ[1] == -80
    #= none:507 =#
    #= none:507 =# @test grid.φᵃᶠᵃ[Nφ + 1] == 80
    #= none:509 =#
    #= none:509 =# @test grid.λᶠᵃᵃ[0] == -180 - grid.Δλᶠᵃᵃ
    #= none:510 =#
    #= none:510 =# @test grid.λᶠᵃᵃ[Nλ + 1] == 180
    #= none:512 =#
    #= none:512 =# @test grid.φᵃᶠᵃ[0] == -80 - grid.Δφᵃᶠᵃ
    #= none:513 =#
    #= none:513 =# @test grid.φᵃᶠᵃ[Nφ + 2] == 80 + grid.Δφᵃᶠᵃ
    #= none:515 =#
    #= none:515 =# @test all(diff(grid.λᶠᵃᵃ.parent) .== grid.Δλᶠᵃᵃ)
    #= none:516 =#
    #= none:516 =# @test all(diff(grid.λᶜᵃᵃ.parent) .== grid.Δλᶜᵃᵃ)
    #= none:518 =#
    #= none:518 =# @test all(diff(grid.φᵃᶠᵃ.parent) .== grid.Δφᵃᶠᵃ)
    #= none:519 =#
    #= none:519 =# @test all(diff(grid.φᵃᶜᵃ.parent) .== grid.Δφᵃᶜᵃ)
    #= none:521 =#
    return nothing
end
#= none:524 =#
function test_basic_lat_lon_general_grid(FT)
    #= none:524 =#
    #= none:526 =#
    (Nλ, Nφ, Nz) = (grid_size = (24, 16, 16))
    #= none:527 =#
    (Hλ, Hφ, Hz) = (halo = (1, 1, 1))
    #= none:529 =#
    lat = (-80, 80)
    #= none:530 =#
    lon = (-180, 180)
    #= none:531 =#
    zᵣ = (-100, 0)
    #= none:533 =#
    Λ₁ = (lat[1], lon[1], zᵣ[1])
    #= none:534 =#
    Λₙ = (lat[2], lon[2], zᵣ[2])
    #= none:536 =#
    (Lλ, Lφ, Lz) = (L = #= none:536 =# @__dot__(Λₙ - Λ₁))
    #= none:538 =#
    grid_reg = LatitudeLongitudeGrid(CPU(), FT, size = grid_size, halo = halo, latitude = lat, longitude = lon, z = zᵣ)
    #= none:540 =#
    #= none:540 =# @test typeof(grid_reg.Δzᵃᵃᶜ) == typeof(grid_reg.Δzᵃᵃᶠ) == FT
    #= none:542 =#
    #= none:542 =# @test xspacings(grid_reg, Center(), Center(), with_halos = true) == grid_reg.Δxᶜᶜᵃ
    #= none:543 =#
    #= none:543 =# @test xspacings(grid_reg, Center(), Face(), with_halos = true) == grid_reg.Δxᶜᶠᵃ
    #= none:544 =#
    #= none:544 =# @test xspacings(grid_reg, Face(), Center(), with_halos = true) == grid_reg.Δxᶠᶜᵃ
    #= none:545 =#
    #= none:545 =# @test xspacings(grid_reg, Face(), Face(), with_halos = true) == grid_reg.Δxᶠᶠᵃ
    #= none:546 =#
    #= none:546 =# @test yspacings(grid_reg, Center(), Face(), with_halos = true) == grid_reg.Δyᶜᶠᵃ
    #= none:547 =#
    #= none:547 =# @test yspacings(grid_reg, Face(), Center(), with_halos = true) == grid_reg.Δyᶠᶜᵃ
    #= none:548 =#
    #= none:548 =# @test zspacings(grid_reg, Center(), with_halos = true) == grid_reg.Δzᵃᵃᶜ
    #= none:549 =#
    #= none:549 =# @test zspacings(grid_reg, Face(), with_halos = true) == grid_reg.Δzᵃᵃᶠ
    #= none:551 =#
    #= none:551 =# @test xspacings(grid_reg, Center(), Center(), Center()) == xspacings(grid_reg, Center(), Center())
    #= none:552 =#
    #= none:552 =# @test xspacings(grid_reg, Face(), Face(), Center()) == xspacings(grid_reg, Face(), Face())
    #= none:553 =#
    #= none:553 =# @test yspacings(grid_reg, Center(), Face(), Center()) == yspacings(grid_reg, Center(), Face())
    #= none:554 =#
    #= none:554 =# @test yspacings(grid_reg, Face(), Center(), Center()) == yspacings(grid_reg, Face(), Center())
    #= none:555 =#
    #= none:555 =# @test zspacings(grid_reg, Face(), Face(), Center()) == zspacings(grid_reg, Center())
    #= none:556 =#
    #= none:556 =# @test zspacings(grid_reg, Face(), Center(), Face()) == zspacings(grid_reg, Face())
    #= none:558 =#
    #= none:558 =# @test xspacing(1, 2, 3, grid_reg, Center(), Center(), Center()) == grid_reg.Δxᶜᶜᵃ[2]
    #= none:559 =#
    #= none:559 =# @test xspacing(1, 2, 3, grid_reg, Center(), Face(), Center()) == grid_reg.Δxᶜᶠᵃ[2]
    #= none:560 =#
    #= none:560 =# @test yspacing(1, 2, 3, grid_reg, Center(), Face(), Center()) == grid_reg.Δyᶜᶠᵃ
    #= none:561 =#
    #= none:561 =# @test yspacing(1, 2, 3, grid_reg, Face(), Center(), Center()) == grid_reg.Δyᶠᶜᵃ
    #= none:562 =#
    #= none:562 =# @test zspacing(1, 2, 3, grid_reg, Center(), Center(), Face()) == grid_reg.Δzᵃᵃᶠ
    #= none:563 =#
    #= none:563 =# @test zspacing(1, 2, 3, grid_reg, Center(), Center(), Center()) == grid_reg.Δzᵃᵃᶜ
    #= none:565 =#
    #= none:565 =# @test λspacings(grid_reg, Center(), with_halos = true) == grid_reg.Δλᶜᵃᵃ
    #= none:566 =#
    #= none:566 =# @test λspacings(grid_reg, Face(), with_halos = true) == grid_reg.Δλᶠᵃᵃ
    #= none:567 =#
    #= none:567 =# @test φspacings(grid_reg, Center(), with_halos = true) == grid_reg.Δφᵃᶜᵃ
    #= none:568 =#
    #= none:568 =# @test φspacings(grid_reg, Face(), with_halos = true) == grid_reg.Δφᵃᶠᵃ
    #= none:570 =#
    #= none:570 =# @test λspacing(1, 2, 3, grid_reg, Face(), Center(), Face()) == grid_reg.Δλᶠᵃᵃ
    #= none:571 =#
    #= none:571 =# @test φspacing(1, 2, 3, grid_reg, Center(), Face(), Center()) == grid_reg.Δφᵃᶠᵃ
    #= none:573 =#
    Δλ = grid_reg.Δλᶠᵃᵃ
    #= none:574 =#
    λₛ = -(grid_reg.Lx) / 2:Δλ:grid_reg.Lx / 2
    #= none:576 =#
    Δz = grid_reg.Δzᵃᵃᶜ
    #= none:577 =#
    zₛ = -Lz:Δz:0
    #= none:579 =#
    grid_str = LatitudeLongitudeGrid(CPU(), FT, size = grid_size, halo = halo, latitude = lat, longitude = λₛ, z = zₛ)
    #= none:581 =#
    #= none:581 =# @test length(grid_str.λᶠᵃᵃ) == length(grid_reg.λᶠᵃᵃ) == Nλ + 2Hλ
    #= none:582 =#
    #= none:582 =# @test length(grid_str.λᶜᵃᵃ) == length(grid_reg.λᶜᵃᵃ) == Nλ + 2Hλ
    #= none:584 =#
    #= none:584 =# @test length(grid_str.φᵃᶠᵃ) == length(grid_reg.φᵃᶠᵃ) == Nφ + 2Hφ + 1
    #= none:585 =#
    #= none:585 =# @test length(grid_str.φᵃᶜᵃ) == length(grid_reg.φᵃᶜᵃ) == Nφ + 2Hφ
    #= none:587 =#
    #= none:587 =# @test length(grid_str.zᵃᵃᶠ) == length(grid_reg.zᵃᵃᶠ) == Nz + 2Hz + 1
    #= none:588 =#
    #= none:588 =# @test length(grid_str.zᵃᵃᶜ) == length(grid_reg.zᵃᵃᶜ) == Nz + 2Hz
    #= none:590 =#
    #= none:590 =# @test length(grid_str.Δzᵃᵃᶠ) == Nz + 2Hz + 1
    #= none:591 =#
    #= none:591 =# @test length(grid_str.Δzᵃᵃᶜ) == Nz + 2Hz
    #= none:593 =#
    #= none:593 =# @test all(grid_str.λᶜᵃᵃ == grid_reg.λᶜᵃᵃ)
    #= none:594 =#
    #= none:594 =# @test all(grid_str.λᶠᵃᵃ == grid_reg.λᶠᵃᵃ)
    #= none:595 =#
    #= none:595 =# @test all(grid_str.φᵃᶜᵃ == grid_reg.φᵃᶜᵃ)
    #= none:596 =#
    #= none:596 =# @test all(grid_str.φᵃᶠᵃ == grid_reg.φᵃᶠᵃ)
    #= none:597 =#
    #= none:597 =# @test all(grid_str.zᵃᵃᶜ == grid_reg.zᵃᵃᶜ)
    #= none:598 =#
    #= none:598 =# @test all(grid_str.zᵃᵃᶠ == grid_reg.zᵃᵃᶠ)
    #= none:600 =#
    #= none:600 =# @test sum(grid_str.Δzᵃᵃᶜ) == grid_reg.Δzᵃᵃᶜ * length(grid_str.Δzᵃᵃᶜ)
    #= none:601 =#
    #= none:601 =# @test sum(grid_str.Δzᵃᵃᶠ) == grid_reg.Δzᵃᵃᶠ * length(grid_str.Δzᵃᵃᶠ)
    #= none:603 =#
    #= none:603 =# @test xspacings(grid_str, Center(), Center(), with_halos = true) == grid_str.Δxᶜᶜᵃ
    #= none:604 =#
    #= none:604 =# @test xspacings(grid_str, Center(), Face(), with_halos = true) == grid_str.Δxᶜᶠᵃ
    #= none:605 =#
    #= none:605 =# @test xspacings(grid_str, Face(), Center(), with_halos = true) == grid_str.Δxᶠᶜᵃ
    #= none:606 =#
    #= none:606 =# @test xspacings(grid_str, Face(), Face(), with_halos = true) == grid_str.Δxᶠᶠᵃ
    #= none:607 =#
    #= none:607 =# @test yspacings(grid_str, Center(), Face(), with_halos = true) == grid_str.Δyᶜᶠᵃ
    #= none:608 =#
    #= none:608 =# @test yspacings(grid_str, Face(), Center(), with_halos = true) == grid_str.Δyᶠᶜᵃ
    #= none:609 =#
    #= none:609 =# @test zspacings(grid_str, Center(), with_halos = true) == grid_str.Δzᵃᵃᶜ
    #= none:610 =#
    #= none:610 =# @test zspacings(grid_str, Face(), with_halos = true) == grid_str.Δzᵃᵃᶠ
    #= none:612 =#
    #= none:612 =# @test xspacings(grid_str, Center(), Center()) == grid_str.Δxᶜᶜᵃ[1:grid_str.Nx, 1:grid_str.Ny]
    #= none:613 =#
    #= none:613 =# @test xspacings(grid_str, Center(), Face()) == grid_str.Δxᶜᶠᵃ[1:grid_str.Nx, 1:grid_str.Ny + 1]
    #= none:614 =#
    #= none:614 =# @test zspacings(grid_str, Center()) == grid_str.Δzᵃᵃᶜ[1:grid_str.Nz]
    #= none:615 =#
    #= none:615 =# @test zspacings(grid_str, Face()) == grid_str.Δzᵃᵃᶠ[1:grid_str.Nz + 1]
    #= none:617 =#
    #= none:617 =# @test zspacings(grid_str, Face(), Face(), Center()) == zspacings(grid_str, Center())
    #= none:618 =#
    #= none:618 =# @test zspacings(grid_str, Face(), Center(), Face()) == zspacings(grid_str, Face())
    #= none:620 =#
    return nothing
end
#= none:623 =#
function test_lat_lon_areas(FT)
    #= none:623 =#
    #= none:624 =#
    Nλ = 36
    #= none:625 =#
    Nφ = 32
    #= none:626 =#
    Hλ = (Hφ = 2)
    #= none:628 =#
    grid = LatitudeLongitudeGrid(CPU(), FT, size = (Nλ, Nφ, 1), longitude = (-180, 180), latitude = (-90, 90), z = (0, 1), halo = (Hλ, Hφ, 1))
    #= none:630 =#
    #= none:630 =# @test sum(grid.Azᶜᶜᵃ[1:grid.Ny]) * grid.Nx ≈ (4π) * grid.radius ^ 2
    #= none:632 =#
    return nothing
end
#= none:635 =#
function test_lat_lon_xyzλφ_node_nodes(FT, arch)
    #= none:635 =#
    #= none:637 =#
    #= none:637 =# @info "    Testing with $(FT) on $(typeof(arch))..."
    #= none:639 =#
    (Nλ, Nφ, Nz) = (grid_size = (12, 4, 2))
    #= none:640 =#
    (Hλ, Hφ, Hz) = (halo = (1, 1, 1))
    #= none:642 =#
    lat = (-60, 60)
    #= none:643 =#
    lon = (-180, 180)
    #= none:644 =#
    zᵣ = (-10, 0)
    #= none:646 =#
    grid = LatitudeLongitudeGrid(CPU(), FT, size = grid_size, halo = halo, latitude = lat, longitude = lon, z = zᵣ)
    #= none:648 =#
    #= none:648 =# @info "        Testing grid utils on LatitudeLongitude grid...."
    #= none:650 =#
    #= none:650 =# @test λnode(3, 1, 2, grid, Face(), Face(), Face()) ≈ -120
    #= none:651 =#
    #= none:651 =# @test φnode(3, 2, 2, grid, Face(), Face(), Face()) ≈ -30
    #= none:652 =#
    #= none:652 =# @test xnode(5, 1, 2, grid, Face(), Face(), Face()) / grid.radius ≈ -(FT(π / 6))
    #= none:653 =#
    #= none:653 =# @test ynode(2, 1, 2, grid, Face(), Face(), Face()) / grid.radius ≈ -(FT(π / 3))
    #= none:654 =#
    #= none:654 =# @test znode(2, 1, 2, grid, Face(), Face(), Face()) ≈ -5
    #= none:656 =#
    #= none:656 =# @test minimum_xspacing(grid, Face(), Face(), Face()) / grid.radius ≈ FT(π / 6) * cosd(60)
    #= none:657 =#
    #= none:657 =# @test minimum_xspacing(grid) / grid.radius ≈ FT(π / 6) * cosd(45)
    #= none:658 =#
    #= none:658 =# @test minimum_yspacing(grid) / grid.radius ≈ FT(π / 6)
    #= none:659 =#
    #= none:659 =# @test minimum_zspacing(grid) ≈ 5
    #= none:661 =#
    return nothing
end
#= none:664 =#
function test_lat_lon_precomputed_metrics(FT, arch)
    #= none:664 =#
    #= none:665 =#
    (Nλ, Nφ, Nz) = (N = (4, 2, 3))
    #= none:666 =#
    (Hλ, Hφ, Hz) = (H = (1, 1, 1))
    #= none:668 =#
    latreg = (-80, 80)
    #= none:669 =#
    lonreg = (-180, 180)
    #= none:670 =#
    lonregB = (-160, 160)
    #= none:672 =#
    zreg = (-1, 0)
    #= none:674 =#
    latstr = [-80, 0, 80]
    #= none:675 =#
    lonstr = [-180, -30, 10, 40, 180]
    #= none:676 =#
    lonstrB = [-160, -30, 10, 40, 160]
    #= none:677 =#
    zstr = collect(0:Nz)
    #= none:679 =#
    latitude = (latreg, latstr)
    #= none:680 =#
    longitude = (lonreg, lonstr, lonregB, lonstrB)
    #= none:681 =#
    zcoord = (zreg, zstr)
    #= none:683 =#
    CUDA.allowscalar() do 
        #= none:686 =#
        for lat = latitude
            #= none:687 =#
            for lon = longitude
                #= none:688 =#
                for z = zcoord
                    #= none:689 =#
                    println("$(lat), $(lon), $(z)")
                    #= none:690 =#
                    grid_pre = LatitudeLongitudeGrid(arch, FT, size = N, halo = H, latitude = lat, longitude = lon, z = z, precompute_metrics = true)
                    #= none:691 =#
                    grid_fly = LatitudeLongitudeGrid(arch, FT, size = N, halo = H, latitude = lat, longitude = lon, z = z)
                    #= none:693 =#
                    #= none:693 =# @test all(Array([all(Array([Δxᶠᶜᵃ(i, j, 1, grid_pre) ≈ Δxᶠᶜᵃ(i, j, 1, grid_fly) for i = (1 - Hλ) + 1:(Nλ + Hλ) - 1])) for j = (1 - Hφ) + 1:(Nφ + Hφ) - 1]))
                    #= none:694 =#
                    #= none:694 =# @test all(Array([all(Array([Δxᶜᶠᵃ(i, j, 1, grid_pre) ≈ Δxᶜᶠᵃ(i, j, 1, grid_fly) for i = (1 - Hλ) + 1:(Nλ + Hλ) - 1])) for j = (1 - Hφ) + 1:(Nφ + Hφ) - 1]))
                    #= none:695 =#
                    #= none:695 =# @test all(Array([all(Array([Δxᶠᶠᵃ(i, j, 1, grid_pre) ≈ Δxᶠᶠᵃ(i, j, 1, grid_fly) for i = (1 - Hλ) + 1:(Nλ + Hλ) - 1])) for j = (1 - Hφ) + 1:(Nφ + Hφ) - 1]))
                    #= none:696 =#
                    #= none:696 =# @test all(Array([all(Array([Δxᶜᶜᵃ(i, j, 1, grid_pre) ≈ Δxᶜᶜᵃ(i, j, 1, grid_fly) for i = (1 - Hλ) + 1:(Nλ + Hλ) - 1])) for j = (1 - Hφ) + 1:(Nφ + Hφ) - 1]))
                    #= none:697 =#
                    #= none:697 =# @test all(Array([all(Array([Δyᶜᶠᵃ(i, j, 1, grid_pre) ≈ Δyᶜᶠᵃ(i, j, 1, grid_fly) for i = (1 - Hλ) + 1:(Nλ + Hλ) - 1])) for j = (1 - Hφ) + 1:(Nφ + Hφ) - 1]))
                    #= none:698 =#
                    #= none:698 =# @test all(Array([all(Array([Azᶠᶜᵃ(i, j, 1, grid_pre) ≈ Azᶠᶜᵃ(i, j, 1, grid_fly) for i = (1 - Hλ) + 1:(Nλ + Hλ) - 1])) for j = (1 - Hφ) + 1:(Nφ + Hφ) - 1]))
                    #= none:699 =#
                    #= none:699 =# @test all(Array([all(Array([Azᶜᶠᵃ(i, j, 1, grid_pre) ≈ Azᶜᶠᵃ(i, j, 1, grid_fly) for i = (1 - Hλ) + 1:(Nλ + Hλ) - 1])) for j = (1 - Hφ) + 1:(Nφ + Hφ) - 1]))
                    #= none:700 =#
                    #= none:700 =# @test all(Array([all(Array([Azᶠᶠᵃ(i, j, 1, grid_pre) ≈ Azᶠᶠᵃ(i, j, 1, grid_fly) for i = (1 - Hλ) + 1:(Nλ + Hλ) - 1])) for j = (1 - Hφ) + 1:(Nφ + Hφ) - 1]))
                    #= none:701 =#
                    #= none:701 =# @test all(Array([all(Array([Azᶜᶜᵃ(i, j, 1, grid_pre) ≈ Azᶜᶜᵃ(i, j, 1, grid_fly) for i = (1 - Hλ) + 1:(Nλ + Hλ) - 1])) for j = (1 - Hφ) + 1:(Nφ + Hφ) - 1]))
                    #= none:702 =#
                end
                #= none:703 =#
            end
            #= none:704 =#
        end
    end
end
#= none:714 =#
function test_orthogonal_shell_grid_array_sizes_and_spacings(FT)
    #= none:714 =#
    #= none:716 =#
    grid = conformal_cubed_sphere_panel(CPU(), FT, size = (10, 10, 1), z = (0, 1))
    #= none:718 =#
    (Nx, Ny, Nz) = (grid.Nx, grid.Ny, grid.Nz)
    #= none:719 =#
    (Hx, Hy, Hz) = (grid.Hx, grid.Hy, grid.Hz)
    #= none:721 =#
    #= none:721 =# @test grid.λᶜᶜᵃ isa OffsetArray{FT, 2, <:Array}
    #= none:722 =#
    #= none:722 =# @test grid.λᶠᶜᵃ isa OffsetArray{FT, 2, <:Array}
    #= none:723 =#
    #= none:723 =# @test grid.λᶜᶠᵃ isa OffsetArray{FT, 2, <:Array}
    #= none:724 =#
    #= none:724 =# @test grid.λᶠᶠᵃ isa OffsetArray{FT, 2, <:Array}
    #= none:725 =#
    #= none:725 =# @test grid.φᶜᶜᵃ isa OffsetArray{FT, 2, <:Array}
    #= none:726 =#
    #= none:726 =# @test grid.φᶠᶜᵃ isa OffsetArray{FT, 2, <:Array}
    #= none:727 =#
    #= none:727 =# @test grid.φᶜᶠᵃ isa OffsetArray{FT, 2, <:Array}
    #= none:728 =#
    #= none:728 =# @test grid.φᶠᶠᵃ isa OffsetArray{FT, 2, <:Array}
    #= none:730 =#
    #= none:730 =# @test size(grid.λᶜᶜᵃ) == (Nx + 2Hx, Ny + 2Hy)
    #= none:731 =#
    #= none:731 =# @test size(grid.λᶠᶜᵃ) == (Nx + 2Hx + 1, Ny + 2Hy)
    #= none:732 =#
    #= none:732 =# @test size(grid.λᶜᶠᵃ) == (Nx + 2Hx, Ny + 2Hy + 1)
    #= none:733 =#
    #= none:733 =# @test size(grid.λᶠᶠᵃ) == (Nx + 2Hx + 1, Ny + 2Hy + 1)
    #= none:735 =#
    #= none:735 =# @test size(grid.φᶜᶜᵃ) == (Nx + 2Hx, Ny + 2Hy)
    #= none:736 =#
    #= none:736 =# @test size(grid.φᶠᶜᵃ) == (Nx + 2Hx + 1, Ny + 2Hy)
    #= none:737 =#
    #= none:737 =# @test size(grid.φᶜᶠᵃ) == (Nx + 2Hx, Ny + 2Hy + 1)
    #= none:738 =#
    #= none:738 =# @test size(grid.φᶠᶠᵃ) == (Nx + 2Hx + 1, Ny + 2Hy + 1)
    #= none:740 =#
    #= none:740 =# @test xspacings(grid, Center(), Center(), Face(), with_halos = true) == xspacings(grid, Center(), Center(), with_halos = true) == grid.Δxᶜᶜᵃ
    #= none:741 =#
    #= none:741 =# @test xspacings(grid, Center(), Face(), Face(), with_halos = true) == xspacings(grid, Center(), Face(), with_halos = true) == grid.Δxᶜᶠᵃ
    #= none:742 =#
    #= none:742 =# @test xspacings(grid, Face(), Center(), Face()) == xspacings(grid, Face(), Center()) == grid.Δxᶠᶜᵃ[1:grid.Nx + 1, 1:grid.Ny]
    #= none:743 =#
    #= none:743 =# @test xspacings(grid, Face(), Face(), Face()) == xspacings(grid, Face(), Face()) == grid.Δxᶠᶠᵃ[1:grid.Nx + 1, 1:grid.Ny + 1]
    #= none:745 =#
    #= none:745 =# @test yspacings(grid, Center(), Center(), Face(), with_halos = true) == yspacings(grid, Center(), Center(), with_halos = true) == grid.Δyᶜᶜᵃ
    #= none:746 =#
    #= none:746 =# @test yspacings(grid, Center(), Face(), Face(), with_halos = true) == yspacings(grid, Center(), Face(), with_halos = true) == grid.Δyᶜᶠᵃ
    #= none:747 =#
    #= none:747 =# @test yspacings(grid, Face(), Center(), Face()) == yspacings(grid, Face(), Center()) == grid.Δyᶠᶜᵃ[1:grid.Nx + 1, 1:grid.Ny]
    #= none:748 =#
    #= none:748 =# @test yspacings(grid, Face(), Face(), Face()) == yspacings(grid, Face(), Face()) == grid.Δyᶠᶠᵃ[1:grid.Nx + 1, 1:grid.Ny + 1]
    #= none:750 =#
    #= none:750 =# @test zspacings(grid, Center(), Face(), Face(), with_halos = true) == zspacings(grid, Face(), with_halos = true) == grid.Δzᵃᵃᶠ
    #= none:751 =#
    #= none:751 =# @test zspacings(grid, Center(), Face(), Center()) == zspacings(grid, Center()) == grid.Δzᵃᵃᶜ
    #= none:753 =#
    return nothing
end
#= none:761 =#
#= none:761 =# @testset "Grids" begin
        #= none:762 =#
        #= none:762 =# @info "Testing AbstractGrids..."
        #= none:764 =#
        #= none:764 =# @testset "Grid utils" begin
                #= none:765 =#
                #= none:765 =# @info "  Testing grid utilities..."
                #= none:766 =#
                #= none:766 =# @test total_extent(Periodic(), 1, 0.2, 1.0) == 1.2
                #= none:767 =#
                #= none:767 =# @test total_extent(Bounded(), 1, 0.2, 1.0) == 1.4
            end
        #= none:770 =#
        #= none:770 =# @testset "Regular rectilinear grid" begin
                #= none:771 =#
                #= none:771 =# @info "  Testing regular rectilinear grid..."
                #= none:773 =#
                #= none:773 =# @testset "Grid initialization" begin
                        #= none:774 =#
                        #= none:774 =# @info "    Testing grid initialization..."
                        #= none:776 =#
                        for FT = float_types
                            #= none:777 =#
                            test_regular_rectilinear_correct_size(FT)
                            #= none:778 =#
                            test_regular_rectilinear_correct_extent(FT)
                            #= none:779 =#
                            test_regular_rectilinear_correct_coordinate_lengths(FT)
                            #= none:780 =#
                            test_regular_rectilinear_correct_halo_size(FT)
                            #= none:781 =#
                            test_regular_rectilinear_correct_halo_faces(FT)
                            #= none:782 =#
                            test_regular_rectilinear_correct_first_cells(FT)
                            #= none:783 =#
                            test_regular_rectilinear_correct_end_faces(FT)
                            #= none:784 =#
                            test_regular_rectilinear_ranges_have_correct_length(FT)
                            #= none:785 =#
                            test_regular_rectilinear_no_roundoff_error_in_ranges(FT)
                            #= none:786 =#
                            test_regular_rectilinear_grid_properties_are_same_type(FT)
                            #= none:787 =#
                            for arch = archs
                                #= none:788 =#
                                test_regular_rectilinear_xnode_ynode_znode_and_spacings(arch, FT)
                                #= none:789 =#
                            end
                            #= none:790 =#
                        end
                    end
                #= none:793 =#
                #= none:793 =# @testset "Grid dimensions" begin
                        #= none:794 =#
                        #= none:794 =# @info "    Testing grid constructor errors..."
                        #= none:795 =#
                        for FT = float_types
                            #= none:796 =#
                            test_regular_rectilinear_constructor_errors(FT)
                            #= none:797 =#
                        end
                    end
                #= none:800 =#
                #= none:800 =# @testset "Grids with flat dimensions" begin
                        #= none:801 =#
                        #= none:801 =# @info "    Testing construction of grids with Flat dimensions..."
                        #= none:802 =#
                        for FT = float_types
                            #= none:803 =#
                            test_flat_size_regular_rectilinear_grid(FT)
                            #= none:804 =#
                        end
                    end
                #= none:807 =#
                #= none:807 =# @testset "Grid equality" begin
                        #= none:808 =#
                        #= none:808 =# @info "    Testing grid equality operator (==)..."
                        #= none:810 =#
                        for arch = archs
                            #= none:811 =#
                            test_grid_equality(arch)
                            #= none:812 =#
                        end
                        #= none:814 =#
                        if true
                            #= none:815 =#
                            test_grid_equality_over_architectures()
                        end
                    end
                #= none:820 =#
                topo = (Periodic, Periodic, Periodic)
                #= none:822 =#
                grid = RectilinearGrid(CPU(), topology = topo, size = (3, 7, 9), x = (0, 1), y = (-π, π), z = (0, 2π))
                #= none:824 =#
                #= none:824 =# @test try
                        #= none:825 =#
                        show(grid)
                        #= none:825 =#
                        println()
                        #= none:826 =#
                        true
                    catch err
                        #= none:828 =#
                        println("error in show(::RectilinearGrid)")
                        #= none:829 =#
                        println(sprint(showerror, err))
                        #= none:830 =#
                        false
                    end
                #= none:833 =#
                #= none:833 =# @test grid isa RectilinearGrid
            end
        #= none:836 =#
        #= none:836 =# @testset "Vertically stretched rectilinear grid" begin
                #= none:837 =#
                #= none:837 =# @info "  Testing vertically stretched rectilinear grid..."
                #= none:839 =#
                for arch = archs, FT = float_types
                    #= none:840 =#
                    #= none:840 =# @testset "Vertically stretched rectilinear grid construction [$(typeof(arch)), $(FT)]" begin
                            #= none:841 =#
                            #= none:841 =# @info "    Testing vertically stretched rectilinear grid construction [$(typeof(arch)), $(FT)]..."
                            #= none:843 =#
                            test_vertically_stretched_grid_properties_are_same_type(FT, arch)
                            #= none:845 =#
                            zᵃᵃᶠ1 = collect(0:10) .^ 2
                            #= none:846 =#
                            zᵃᵃᶠ2 = [1, 3, 5, 10, 15, 33, 50]
                            #= none:847 =#
                            for zᵃᵃᶠ = [zᵃᵃᶠ1, zᵃᵃᶠ2]
                                #= none:848 =#
                                test_architecturally_correct_stretched_grid(FT, arch, zᵃᵃᶠ)
                                #= none:849 =#
                            end
                        end
                    #= none:852 =#
                    #= none:852 =# @testset "Vertically stretched rectilinear grid spacings [$(typeof(arch)), $(FT)]" begin
                            #= none:853 =#
                            #= none:853 =# @info "    Testing vertically stretched rectilinear grid spacings [$(typeof(arch)), $(FT)]..."
                            #= none:854 =#
                            for N = [16, 17]
                                #= none:855 =#
                                test_rectilinear_grid_correct_spacings(FT, N)
                                #= none:856 =#
                            end
                        end
                    #= none:860 =#
                    Nz = 20
                    #= none:861 =#
                    grid = RectilinearGrid(arch, size = (1, 1, Nz), x = (0, 1), y = (0, 1), z = collect(0:Nz) .^ 2)
                    #= none:863 =#
                    #= none:863 =# @test try
                            #= none:864 =#
                            show(grid)
                            #= none:864 =#
                            println()
                            #= none:865 =#
                            true
                        catch err
                            #= none:867 =#
                            println("error in show(::RectilinearGrid)")
                            #= none:868 =#
                            println(sprint(showerror, err))
                            #= none:869 =#
                            false
                        end
                    #= none:872 =#
                    #= none:872 =# @test grid isa RectilinearGrid
                    #= none:873 =#
                end
                #= none:875 =#
                for arch = archs
                    #= none:876 =#
                    #= none:876 =# @info "  Testing on_architecture for RectilinearGrid..."
                    #= none:877 =#
                    cpu_grid = RectilinearGrid(CPU(), size = (1, 1, 4), x = (0, 1), y = (0, 1), z = collect(0:4) .^ 2)
                    #= none:878 =#
                    grid = on_architecture(arch, cpu_grid)
                    #= none:879 =#
                    #= none:879 =# @test grid isa RectilinearGrid
                    #= none:880 =#
                    #= none:880 =# @test architecture(grid) == arch
                    #= none:881 =#
                    cpu_grid_again = on_architecture(CPU(), grid)
                    #= none:882 =#
                    #= none:882 =# @test cpu_grid_again == cpu_grid
                    #= none:883 =#
                end
            end
        #= none:886 =#
        #= none:886 =# @testset "Latitude-longitude grid" begin
                #= none:887 =#
                #= none:887 =# @info "  Testing general latitude-longitude grid..."
                #= none:889 =#
                for FT = float_types
                    #= none:890 =#
                    test_basic_lat_lon_bounded_domain(FT)
                    #= none:891 =#
                    test_basic_lat_lon_periodic_domain(FT)
                    #= none:892 =#
                    test_basic_lat_lon_general_grid(FT)
                    #= none:893 =#
                    test_lat_lon_areas(FT)
                    #= none:894 =#
                end
                #= none:896 =#
                #= none:896 =# @info "  Testing precomputed metrics on LatitudeLongitudeGrid..."
                #= none:897 =#
                for arch = archs, FT = float_types
                    #= none:898 =#
                    test_lat_lon_precomputed_metrics(FT, arch)
                    #= none:899 =#
                    test_lat_lon_xyzλφ_node_nodes(FT, arch)
                    #= none:900 =#
                end
                #= none:903 =#
                grid = LatitudeLongitudeGrid(CPU(), size = (36, 32, 1), longitude = (-180, 180), latitude = (-80, 80), z = (0, 1))
                #= none:905 =#
                #= none:905 =# @test try
                        #= none:906 =#
                        show(grid)
                        #= none:906 =#
                        println()
                        #= none:907 =#
                        true
                    catch err
                        #= none:909 =#
                        println("error in show(::LatitudeLongitudeGrid)")
                        #= none:910 =#
                        println(sprint(showerror, err))
                        #= none:911 =#
                        false
                    end
                #= none:914 =#
                #= none:914 =# @test grid isa LatitudeLongitudeGrid
                #= none:916 =#
                for arch = archs
                    #= none:917 =#
                    #= none:917 =# @info "  Testing show for vertically-stretched LatitudeLongitudeGrid..."
                    #= none:918 =#
                    grid = LatitudeLongitudeGrid(arch, size = (36, 32, 10), longitude = (-180, 180), latitude = (-80, 80), z = collect(0:10))
                    #= none:924 =#
                    #= none:924 =# @test try
                            #= none:925 =#
                            show(grid)
                            #= none:925 =#
                            println()
                            #= none:926 =#
                            true
                        catch err
                            #= none:928 =#
                            println("error in show(::LatitudeLongitudeGrid)")
                            #= none:929 =#
                            println(sprint(showerror, err))
                            #= none:930 =#
                            false
                        end
                    #= none:933 =#
                    #= none:933 =# @test grid isa LatitudeLongitudeGrid
                    #= none:934 =#
                end
                #= none:936 =#
                for arch = archs
                    #= none:937 =#
                    #= none:937 =# @info "  Testing on_architecture for LatitudeLongitudeGrid..."
                    #= none:938 =#
                    cpu_grid = LatitudeLongitudeGrid(CPU(), size = (36, 32, 10), longitude = (-180, 180), latitude = (-80, 80), z = collect(0:10))
                    #= none:943 =#
                    grid = on_architecture(arch, cpu_grid)
                    #= none:944 =#
                    #= none:944 =# @test grid isa LatitudeLongitudeGrid
                    #= none:945 =#
                    #= none:945 =# @test architecture(grid) == arch
                    #= none:947 =#
                    cpu_grid_again = on_architecture(CPU(), grid)
                    #= none:948 =#
                    #= none:948 =# @test cpu_grid_again == cpu_grid
                    #= none:949 =#
                end
            end
        #= none:952 =#
        #= none:952 =# @testset "Single column grids" begin
                #= none:953 =#
                #= none:953 =# @info "  Testing single column grid construction..."
                #= none:955 =#
                for arch = archs
                    #= none:956 =#
                    for FT = float_types
                        #= none:957 =#
                        ccc = (Center(), Center(), Center())
                        #= none:958 =#
                        grid = RectilinearGrid(arch, FT, size = 4, z = (-1, 0), topology = (Flat, Flat, Bounded))
                        #= none:959 =#
                        x = xnodes(grid, ccc...)
                        #= none:960 =#
                        y = ynodes(grid, ccc...)
                        #= none:961 =#
                        #= none:961 =# @test isnothing(x)
                        #= none:962 =#
                        #= none:962 =# @test isnothing(y)
                        #= none:964 =#
                        x₀ = 1
                        #= none:965 =#
                        y₀ = π
                        #= none:966 =#
                        grid = RectilinearGrid(arch, FT, size = 4, x = x₀, y = y₀, z = (-1, 0), topology = (Flat, Flat, Bounded))
                        #= none:967 =#
                        x = xnodes(grid, ccc...)
                        #= none:968 =#
                        y = ynodes(grid, ccc...)
                        #= none:969 =#
                        #= none:969 =# @test x[1] isa FT
                        #= none:970 =#
                        #= none:970 =# @test y[1] isa FT
                        #= none:971 =#
                        #= none:971 =# @test x[1] == x₀
                        #= none:972 =#
                        #= none:972 =# @test y[1] == convert(FT, y₀)
                        #= none:974 =#
                        grid = LatitudeLongitudeGrid(arch, FT, size = 4, z = (-1, 0), topology = (Flat, Flat, Bounded))
                        #= none:975 =#
                        λ = λnodes(grid, ccc...)
                        #= none:976 =#
                        φ = φnodes(grid, ccc...)
                        #= none:977 =#
                        #= none:977 =# @test isnothing(λ)
                        #= none:978 =#
                        #= none:978 =# @test isnothing(φ)
                        #= none:980 =#
                        λ₀ = 45
                        #= none:981 =#
                        φ₀ = 10.1
                        #= none:982 =#
                        grid = LatitudeLongitudeGrid(arch, FT, size = 4, latitude = φ₀, longitude = λ₀, z = (-1, 0), topology = (Flat, Flat, Bounded))
                        #= none:984 =#
                        λ = λnodes(grid, ccc...)
                        #= none:985 =#
                        φ = φnodes(grid, ccc...)
                        #= none:986 =#
                        #= none:986 =# @test λ[1] isa FT
                        #= none:987 =#
                        #= none:987 =# @test φ[1] isa FT
                        #= none:988 =#
                        #= none:988 =# @test λ[1] == λ₀
                        #= none:989 =#
                        #= none:989 =# @test φ[1] == convert(FT, φ₀)
                        #= none:990 =#
                    end
                    #= none:991 =#
                end
            end
        #= none:994 =#
        #= none:994 =# @testset "Conformal cubed sphere face grid" begin
                #= none:995 =#
                #= none:995 =# @info "  Testing OrthogonalSphericalShellGrid grid..."
                #= none:997 =#
                for FT = float_types
                    #= none:998 =#
                    test_orthogonal_shell_grid_array_sizes_and_spacings(FT)
                    #= none:999 =#
                end
                #= none:1002 =#
                grid = conformal_cubed_sphere_panel(CPU(), size = (10, 10, 1), z = (0, 1))
                #= none:1004 =#
                #= none:1004 =# @test try
                        #= none:1005 =#
                        show(grid)
                        #= none:1005 =#
                        println()
                        #= none:1006 =#
                        true
                    catch err
                        #= none:1008 =#
                        println("error in show(::OrthogonalSphericalShellGrid)")
                        #= none:1009 =#
                        println(sprint(showerror, err))
                        #= none:1010 =#
                        false
                    end
                #= none:1013 =#
                #= none:1013 =# @test grid isa OrthogonalSphericalShellGrid
                #= none:1015 =#
                for arch = archs
                    #= none:1016 =#
                    for FT = float_types
                        #= none:1017 =#
                        z = (0, 1)
                        #= none:1018 =#
                        radius = 2.345e8
                        #= none:1020 =#
                        (Nx, Ny) = (10, 8)
                        #= none:1021 =#
                        grid = conformal_cubed_sphere_panel(arch, FT, size = (Nx, Ny, 1); z, radius)
                        #= none:1024 =#
                        #= none:1024 =# @test sum(grid.Azᶜᶜᵃ[1:Nx, 1:Ny]) ≈ ((4π) * grid.radius ^ 2) / 6
                        #= none:1030 =#
                        (Nx, Ny) = (11, 9)
                        #= none:1031 =#
                        grid = conformal_cubed_sphere_panel(arch, FT, size = (Nx, Ny, 1); z, radius)
                        #= none:1032 =#
                        #= none:1032 =# @test sum(grid.Δxᶜᶜᵃ[1:Nx, (Ny + 1) ÷ 2]) ≈ ((2π) * grid.radius) / 4
                        #= none:1033 =#
                        #= none:1033 =# @test sum(grid.Δyᶜᶜᵃ[(Nx + 1) ÷ 2, 1:Ny]) ≈ ((2π) * grid.radius) / 4
                        #= none:1035 =#
                        (Nx, Ny) = (10, 9)
                        #= none:1036 =#
                        grid = conformal_cubed_sphere_panel(arch, FT, size = (Nx, Ny, 1); z, radius)
                        #= none:1037 =#
                        #= none:1037 =# @test sum(grid.Δxᶜᶜᵃ[1:Nx, (Ny + 1) ÷ 2]) ≈ ((2π) * grid.radius) / 4
                        #= none:1039 =#
                        (Nx, Ny) = (11, 8)
                        #= none:1040 =#
                        grid = conformal_cubed_sphere_panel(arch, FT, size = (Nx, Ny, 1); z, radius)
                        #= none:1041 =#
                        #= none:1041 =# @test sum(grid.Δyᶜᶜᵃ[(Nx + 1) ÷ 2, 1:Ny]) ≈ ((2π) * grid.radius) / 4
                        #= none:1042 =#
                    end
                    #= none:1043 =#
                end
            end
    end