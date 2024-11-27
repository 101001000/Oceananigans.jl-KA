
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:2 =#
include("data_dependencies.jl")
#= none:4 =#
using Oceananigans.Grids: φnode, λnode, halo_size
#= none:5 =#
using Oceananigans.Utils: Iterate, getregion
#= none:6 =#
using Oceananigans.Fields: replace_horizontal_vector_halos!
#= none:7 =#
using Oceananigans.MultiRegion: number_of_regions, fill_halo_regions!
#= none:9 =#
function get_range_of_indices(operation, index, Nx, Ny)
    #= none:9 =#
    #= none:11 =#
    if operation == :endpoint && index == :first
        #= none:12 =#
        range_x = 1
        #= none:13 =#
        range_y = 1
    elseif #= none:14 =# operation == :endpoint && index == :last
        #= none:15 =#
        range_x = Nx
        #= none:16 =#
        range_y = Ny
    elseif #= none:17 =# operation == :subset && index == :first
        #= none:18 =#
        range_x = 2:Nx
        #= none:19 =#
        range_y = 2:Ny
    elseif #= none:20 =# operation == :subset && index == :last
        #= none:21 =#
        range_x = 1:Nx - 1
        #= none:22 =#
        range_y = 1:Ny - 1
    else
        #= none:24 =#
        range_x = 1:Nx
        #= none:25 =#
        range_y = 1:Ny
    end
    #= none:28 =#
    return (range_x, range_y)
end
#= none:31 =#
function get_halo_data(field, ::West, k_index = 1; operation = nothing, index = :all)
    #= none:31 =#
    #= none:32 =#
    (Nx, Ny, _) = size(field)
    #= none:33 =#
    (Hx, Hy, _) = halo_size(field.grid)
    #= none:35 =#
    (_, range_y) = get_range_of_indices(operation, index, Nx, Ny)
    #= none:37 =#
    return field.data[-Hx + 1:0, range_y, k_index]
end
#= none:40 =#
function get_halo_data(field, ::East, k_index = 1; operation = nothing, index = :all)
    #= none:40 =#
    #= none:41 =#
    (Nx, Ny, _) = size(field)
    #= none:42 =#
    (Hx, Hy, _) = halo_size(field.grid)
    #= none:44 =#
    (_, range_y) = get_range_of_indices(operation, index, Nx, Ny)
    #= none:46 =#
    return field.data[Nx + 1:Nx + Hx, range_y, k_index]
end
#= none:49 =#
function get_halo_data(field, ::North, k_index = 1; operation = nothing, index = :all)
    #= none:49 =#
    #= none:50 =#
    (Nx, Ny, _) = size(field)
    #= none:51 =#
    (Hx, Hy, _) = halo_size(field.grid)
    #= none:53 =#
    (range_x, _) = get_range_of_indices(operation, index, Nx, Ny)
    #= none:55 =#
    return field.data[range_x, Ny + 1:Ny + Hy, k_index]
end
#= none:58 =#
function get_halo_data(field, ::South, k_index = 1; operation = nothing, index = :all)
    #= none:58 =#
    #= none:59 =#
    (Nx, Ny, _) = size(field)
    #= none:60 =#
    (Hx, Hy, _) = halo_size(field.grid)
    #= none:62 =#
    (range_x, _) = get_range_of_indices(operation, index, Nx, Ny)
    #= none:64 =#
    return field.data[range_x, -Hy + 1:0, k_index]
end
#= none:67 =#
function get_boundary_indices(Nx, Ny, Hx, Hy, ::West; operation = nothing, index = :all)
    #= none:67 =#
    #= none:69 =#
    (_, range_y) = get_range_of_indices(operation, index, Nx, Ny)
    #= none:71 =#
    return (1:Hx, range_y)
end
#= none:74 =#
function get_boundary_indices(Nx, Ny, Hx, Hy, ::South; operation = nothing, index = :all)
    #= none:74 =#
    #= none:76 =#
    (range_x, _) = get_range_of_indices(operation, index, Nx, Ny)
    #= none:78 =#
    return (range_x, 1:Hy)
end
#= none:81 =#
function get_boundary_indices(Nx, Ny, Hx, Hy, ::East; operation = nothing, index = :all)
    #= none:81 =#
    #= none:83 =#
    (_, range_y) = get_range_of_indices(operation, index, Nx, Ny)
    #= none:85 =#
    return ((Nx - Hx) + 1:Nx, range_y)
end
#= none:88 =#
function get_boundary_indices(Nx, Ny, Hx, Hy, ::North; operation = nothing, index = :all)
    #= none:88 =#
    #= none:90 =#
    (range_x, _) = get_range_of_indices(operation, index, Nx, Ny)
    #= none:92 =#
    return (range_x, (Ny - Hy) + 1:Ny)
end
#= none:97 =#
R = 1
#= none:98 =#
U = 1
#= none:99 =#
φʳ = 0
#= none:100 =#
α = 90 - φʳ
#= none:101 =#
ψᵣ(λ, φ, z) = begin
        #= none:101 =#
        -U * R * (sind(φ) * cosd(α) - cosd(λ) * cosd(φ) * sind(α))
    end
#= none:104 =#
R = 1
#= none:105 =#
U = 1
#= none:106 =#
φʳ = 0
#= none:107 =#
α = 90 - φʳ
#= none:108 =#
ψᵣ(λ, φ, z) = begin
        #= none:108 =#
        -U * R * (sind(φ) * cosd(α) - cosd(λ) * cosd(φ) * sind(α))
    end
#= none:110 =#
#= none:110 =# Core.@doc "    create_test_data(grid, region)\n\nCreate an array with integer values of the form, e.g., 541 corresponding to region=5, i=4, j=2.\nIf `trailing_zeros > 0` then all values are multiplied with `10^trailing_zeros`, e.g., for\n`trailing_zeros = 2` we have that 54100 corresponds to region=5, i=4, j=2.\n" function create_test_data(grid, region; trailing_zeros = 0)
        #= none:117 =#
        #= none:118 =#
        (Nx, Ny, Nz) = size(grid)
        #= none:119 =#
        (Nx > 9 || Ny > 9) && error("you provided (Nx, Ny) = ($(Nx), $(Ny)); use a grid with Nx, Ny ≤ 9.")
        #= none:120 =#
        !(trailing_zeros isa Integer) && error("trailing_zeros has to be an integer")
        #= none:121 =#
        factor = 10 ^ trailing_zeros
        #= none:123 =#
        return factor .* [100region + 10i + j for i = 1:Nx, j = 1:Ny, k = 1:Nz]
    end
#= none:126 =#
create_c_test_data(grid, region) = begin
        #= none:126 =#
        create_test_data(grid, region; trailing_zeros = 0)
    end
#= none:127 =#
create_ψ_test_data(grid, region) = begin
        #= none:127 =#
        create_test_data(grid, region; trailing_zeros = 1)
    end
#= none:129 =#
create_u_test_data(grid, region) = begin
        #= none:129 =#
        create_test_data(grid, region; trailing_zeros = 2)
    end
#= none:130 =#
create_v_test_data(grid, region) = begin
        #= none:130 =#
        create_test_data(grid, region; trailing_zeros = 3)
    end
#= none:132 =#
#= none:132 =# @testset "Testing conformal cubed sphere partitions..." begin
        #= none:133 =#
        for n = 1:4
            #= none:134 =#
            #= none:134 =# @test length(CubedSpherePartition(; R = n)) == 6 * n ^ 2
            #= none:135 =#
        end
    end
#= none:138 =#
#= none:138 =# Core.@doc "    same_longitude_at_poles!(grid1, grid2)\n\nChange the longitude values in `grid1` that correspond to points situated _exactly_ at\nthe poles so that they match the corresponding longitude values of `grid2`.\n" function same_longitude_at_poles!(grid1::ConformalCubedSphereGrid, grid2::ConformalCubedSphereGrid)
        #= none:144 =#
        #= none:145 =#
        number_of_regions(grid1) == number_of_regions(grid2) || error("grid1 and grid2 must have same number of regions")
        #= none:147 =#
        for region = 1:number_of_regions(grid1)
            #= none:148 =#
            (grid1[region]).λᶠᶠᵃ[(grid2[region]).φᶠᶠᵃ .== 90] = (grid2[region]).λᶠᶠᵃ[(grid2[region]).φᶠᶠᵃ .== 90]
            #= none:149 =#
            (grid1[region]).λᶠᶠᵃ[(grid2[region]).φᶠᶠᵃ .== -90] = (grid2[region]).λᶠᶠᵃ[(grid2[region]).φᶠᶠᵃ .== -90]
            #= none:150 =#
        end
        #= none:152 =#
        return nothing
    end
#= none:155 =#
#= none:155 =# Core.@doc "    zero_out_corner_halos!(array::OffsetArray, N, H)\n\nZero out the values at the corner halo regions of the two-dimensional `array :: OffsetArray`.\nIt is expected that the interior of the offset `array` is `(Nx, Ny) = (N, N)` and the halo\nregion is `H` in both dimensions.\n" function zero_out_corner_halos!(array::OffsetArray, N, H)
        #= none:162 =#
        #= none:163 =#
        size(array) == (N + 2H, N + 2H)
        #= none:165 =#
        Nx = (Ny = N)
        #= none:166 =#
        Hx = (Hy = H)
        #= none:168 =#
        array[-Hx + 1:0, -Hy + 1:0] .= 0
        #= none:169 =#
        array[-Hx + 1:0, Ny + 1:Ny + Hy] .= 0
        #= none:170 =#
        array[Nx + 1:Nx + Hx, -Hy + 1:0] .= 0
        #= none:171 =#
        array[Nx + 1:Nx + Hx, Ny + 1:Ny + Hy] .= 0
        #= none:173 =#
        return nothing
    end
#= none:176 =#
function compare_grid_vars(var1, var2, N, H)
    #= none:176 =#
    #= none:177 =#
    zero_out_corner_halos!(var1, N, H)
    #= none:178 =#
    zero_out_corner_halos!(var2, N, H)
    #= none:179 =#
    return isapprox(var1, var2)
end
#= none:182 =#
#= none:182 =# @testset "Testing conformal cubed sphere grid from file" begin
        #= none:183 =#
        Nz = 1
        #= none:184 =#
        z = (-1, 0)
        #= none:186 =#
        cs32_filepath = datadep"cubed_sphere_32_grid/cubed_sphere_32_grid_with_4_halos.jld2"
        #= none:188 =#
        for panel = 1:6
            #= none:189 =#
            grid = conformal_cubed_sphere_panel(cs32_filepath; panel, Nz, z)
            #= none:190 =#
            #= none:190 =# @test grid isa OrthogonalSphericalShellGrid
            #= none:191 =#
        end
        #= none:193 =#
        for arch = archs
            #= none:194 =#
            #= none:194 =# @info "  Testing conformal cubed sphere grid from file [$(typeof(arch))]..."
            #= none:197 =#
            grid_cs32 = ConformalCubedSphereGrid(cs32_filepath, arch; Nz, z)
            #= none:199 =#
            radius = (first(grid_cs32)).radius
            #= none:200 =#
            (Nx, Ny, Nz) = size(grid_cs32)
            #= none:201 =#
            (Hx, Hy, Hz) = halo_size(grid_cs32)
            #= none:203 =#
            Nx !== Ny && error("Nx must be same as Ny")
            #= none:204 =#
            N = Nx
            #= none:205 =#
            Hx !== Hy && error("Hx must be same as Hy")
            #= none:206 =#
            H = Hy
            #= none:209 =#
            grid = ConformalCubedSphereGrid(arch; z, panel_size = (Nx, Ny, Nz), radius, horizontal_direction_halo = Hx, z_halo = Hz)
            #= none:212 =#
            for panel = 1:6
                #= none:214 =#
                #= none:214 =# CUDA.@allowscalar begin
                        #= none:218 =#
                        #= none:218 =# @test compare_grid_vars((getregion(grid, panel)).φᶜᶜᵃ, (getregion(grid_cs32, panel)).φᶜᶜᵃ, N, H)
                        #= none:219 =#
                        #= none:219 =# @test compare_grid_vars((getregion(grid, panel)).λᶜᶜᵃ, (getregion(grid_cs32, panel)).λᶜᶜᵃ, N, H)
                        #= none:222 =#
                        (getregion(grid, panel)).λᶠᶠᵃ[(getregion(grid, panel)).λᶠᶠᵃ .≈ -180] .= 180
                        #= none:225 =#
                        same_longitude_at_poles!(grid, grid_cs32)
                        #= none:227 =#
                        #= none:227 =# @test compare_grid_vars((getregion(grid, panel)).φᶠᶠᵃ, (getregion(grid_cs32, panel)).φᶠᶠᵃ, N, H)
                        #= none:228 =#
                        #= none:228 =# @test compare_grid_vars((getregion(grid, panel)).λᶠᶠᵃ, (getregion(grid_cs32, panel)).λᶠᶠᵃ, N, H)
                        #= none:230 =#
                        #= none:230 =# @test compare_grid_vars((getregion(grid, panel)).φᶠᶠᵃ, (getregion(grid_cs32, panel)).φᶠᶠᵃ, N, H)
                        #= none:231 =#
                        #= none:231 =# @test compare_grid_vars((getregion(grid, panel)).λᶠᶠᵃ, (getregion(grid_cs32, panel)).λᶠᶠᵃ, N, H)
                    end
                #= none:233 =#
            end
            #= none:234 =#
        end
    end
#= none:238 =#
panel_sizes = ((8, 8, 1), (9, 9, 2))
#= none:240 =#
#= none:240 =# @testset "Testing area metrics" begin
        #= none:241 =#
        for FT = float_types
            #= none:242 =#
            for arch = archs
                #= none:243 =#
                for panel_size = panel_sizes
                    #= none:244 =#
                    (Nx, Ny, Nz) = panel_size
                    #= none:246 =#
                    grid = ConformalCubedSphereGrid(arch, FT; panel_size = (Nx, Ny, Nz), z = (0, 1), radius = 1)
                    #= none:248 =#
                    areaᶜᶜᵃ = (areaᶠᶜᵃ = (areaᶜᶠᵃ = (areaᶠᶠᵃ = 0)))
                    #= none:250 =#
                    for region = 1:number_of_regions(grid)
                        #= none:251 =#
                        #= none:251 =# CUDA.@allowscalar begin
                                #= none:252 =#
                                areaᶜᶜᵃ += sum((getregion(grid, region)).Azᶜᶜᵃ[1:Nx, 1:Ny])
                                #= none:253 =#
                                areaᶠᶜᵃ += sum((getregion(grid, region)).Azᶠᶜᵃ[1:Nx, 1:Ny])
                                #= none:254 =#
                                areaᶜᶠᵃ += sum((getregion(grid, region)).Azᶜᶠᵃ[1:Nx, 1:Ny])
                                #= none:255 =#
                                areaᶠᶠᵃ += sum((getregion(grid, region)).Azᶠᶠᵃ[1:Nx, 1:Ny])
                            end
                        #= none:257 =#
                    end
                    #= none:259 =#
                    #= none:259 =# @test areaᶜᶜᵃ ≈ areaᶠᶜᵃ ≈ areaᶜᶠᵃ ≈ areaᶠᶠᵃ ≈ (4π) * grid.radius ^ 2
                    #= none:260 =#
                end
                #= none:261 =#
            end
            #= none:262 =#
        end
    end
#= none:286 =#
#= none:286 =# @testset "Testing conformal cubed sphere fill halos for tracers" begin
        #= none:287 =#
        for FT = float_types
            #= none:288 =#
            for arch = archs
                #= none:289 =#
                #= none:289 =# @info "  Testing fill halos for tracers [$(FT), $(typeof(arch))]..."
                #= none:291 =#
                (Nx, Ny, Nz) = (9, 9, 1)
                #= none:293 =#
                grid = ConformalCubedSphereGrid(arch, FT; panel_size = (Nx, Ny, Nz), z = (0, 1), radius = 1, horizontal_direction_halo = 3)
                #= none:294 =#
                c = CenterField(grid)
                #= none:296 =#
                region = Iterate(1:6)
                #= none:297 =#
                #= none:297 =# @apply_regionally data = create_c_test_data(grid, region)
                #= none:298 =#
                set!(c, data)
                #= none:299 =#
                fill_halo_regions!(c)
                #= none:301 =#
                (Hx, Hy, Hz) = halo_size(c.grid)
                #= none:303 =#
                west_indices = (1:Hx, 1:Ny)
                #= none:304 =#
                south_indices = (1:Nx, 1:Hy)
                #= none:305 =#
                east_indices = ((Nx - Hx) + 1:Nx, 1:Ny)
                #= none:306 =#
                north_indices = (1:Nx, (Ny - Hy) + 1:Ny)
                #= none:309 =#
                #= none:309 =# CUDA.@allowscalar begin
                        #= none:310 =#
                        switch_device!(grid, 1)
                        #= none:311 =#
                        #= none:311 =# @test get_halo_data(getregion(c, 1), West()) == (reverse((create_c_test_data(grid, 5))[north_indices...], dims = 1))'
                        #= none:312 =#
                        #= none:312 =# @test get_halo_data(getregion(c, 1), East()) == (create_c_test_data(grid, 2))[west_indices...]
                        #= none:313 =#
                        #= none:313 =# @test get_halo_data(getregion(c, 1), South()) == (create_c_test_data(grid, 6))[north_indices...]
                        #= none:314 =#
                        #= none:314 =# @test get_halo_data(getregion(c, 1), North()) == (reverse((create_c_test_data(grid, 3))[west_indices...], dims = 2))'
                        #= none:316 =#
                        switch_device!(grid, 2)
                        #= none:317 =#
                        #= none:317 =# @test get_halo_data(getregion(c, 2), West()) == (create_c_test_data(grid, 1))[east_indices...]
                        #= none:318 =#
                        #= none:318 =# @test get_halo_data(getregion(c, 2), East()) == (reverse((create_c_test_data(grid, 4))[south_indices...], dims = 1))'
                        #= none:319 =#
                        #= none:319 =# @test get_halo_data(getregion(c, 2), South()) == (reverse((create_c_test_data(grid, 6))[east_indices...], dims = 2))'
                        #= none:320 =#
                        #= none:320 =# @test get_halo_data(getregion(c, 2), North()) == (create_c_test_data(grid, 3))[south_indices...]
                        #= none:322 =#
                        switch_device!(grid, 3)
                        #= none:323 =#
                        #= none:323 =# @test get_halo_data(getregion(c, 3), West()) == (reverse((create_c_test_data(grid, 1))[north_indices...], dims = 1))'
                        #= none:324 =#
                        #= none:324 =# @test get_halo_data(getregion(c, 3), East()) == (create_c_test_data(grid, 4))[west_indices...]
                        #= none:325 =#
                        #= none:325 =# @test get_halo_data(getregion(c, 3), South()) == (create_c_test_data(grid, 2))[north_indices...]
                        #= none:326 =#
                        #= none:326 =# @test get_halo_data(getregion(c, 3), North()) == (reverse((create_c_test_data(grid, 5))[west_indices...], dims = 2))'
                        #= none:328 =#
                        switch_device!(grid, 4)
                        #= none:329 =#
                        #= none:329 =# @test get_halo_data(getregion(c, 4), West()) == (create_c_test_data(grid, 3))[east_indices...]
                        #= none:330 =#
                        #= none:330 =# @test get_halo_data(getregion(c, 4), East()) == (reverse((create_c_test_data(grid, 6))[south_indices...], dims = 1))'
                        #= none:331 =#
                        #= none:331 =# @test get_halo_data(getregion(c, 4), South()) == (reverse((create_c_test_data(grid, 2))[east_indices...], dims = 2))'
                        #= none:332 =#
                        #= none:332 =# @test get_halo_data(getregion(c, 4), North()) == (create_c_test_data(grid, 5))[south_indices...]
                        #= none:334 =#
                        switch_device!(grid, 5)
                        #= none:335 =#
                        #= none:335 =# @test get_halo_data(getregion(c, 5), West()) == (reverse((create_c_test_data(grid, 3))[north_indices...], dims = 1))'
                        #= none:336 =#
                        #= none:336 =# @test get_halo_data(getregion(c, 5), East()) == (create_c_test_data(grid, 6))[west_indices...]
                        #= none:337 =#
                        #= none:337 =# @test get_halo_data(getregion(c, 5), South()) == (create_c_test_data(grid, 4))[north_indices...]
                        #= none:338 =#
                        #= none:338 =# @test get_halo_data(getregion(c, 5), North()) == (reverse((create_c_test_data(grid, 1))[west_indices...], dims = 2))'
                        #= none:340 =#
                        switch_device!(grid, 6)
                        #= none:341 =#
                        #= none:341 =# @test get_halo_data(getregion(c, 6), West()) == (create_c_test_data(grid, 5))[east_indices...]
                        #= none:342 =#
                        #= none:342 =# @test get_halo_data(getregion(c, 6), East()) == (reverse((create_c_test_data(grid, 2))[south_indices...], dims = 1))'
                        #= none:343 =#
                        #= none:343 =# @test get_halo_data(getregion(c, 6), South()) == (reverse((create_c_test_data(grid, 4))[east_indices...], dims = 2))'
                        #= none:344 =#
                        #= none:344 =# @test get_halo_data(getregion(c, 6), North()) == (create_c_test_data(grid, 1))[south_indices...]
                    end
                #= none:346 =#
            end
            #= none:347 =#
        end
    end
#= none:350 =#
#= none:350 =# @testset "Testing conformal cubed sphere fill halos for horizontal velocities" begin
        #= none:351 =#
        for FT = float_types
            #= none:352 =#
            for arch = archs
                #= none:354 =#
                #= none:354 =# @info "  Testing fill halos for horizontal velocities [$(FT), $(typeof(arch))]..."
                #= none:356 =#
                (Nx, Ny, Nz) = (3, 3, 1)
                #= none:358 =#
                grid = ConformalCubedSphereGrid(arch, FT; panel_size = (Nx, Ny, Nz), z = (0, 1), radius = 1, horizontal_direction_halo = 3)
                #= none:360 =#
                u = XFaceField(grid)
                #= none:361 =#
                v = YFaceField(grid)
                #= none:363 =#
                region = Iterate(1:6)
                #= none:364 =#
                #= none:364 =# @apply_regionally u_data = create_u_test_data(grid, region)
                #= none:365 =#
                #= none:365 =# @apply_regionally v_data = create_v_test_data(grid, region)
                #= none:366 =#
                set!(u, u_data)
                #= none:367 =#
                set!(v, v_data)
                #= none:369 =#
                fill_halo_regions!((u, v); signed = true)
                #= none:371 =#
                (Hx, Hy, Hz) = halo_size(u.grid)
                #= none:373 =#
                south_indices = get_boundary_indices(Nx, Ny, Hx, Hy, South(); operation = nothing, index = :all)
                #= none:374 =#
                east_indices = get_boundary_indices(Nx, Ny, Hx, Hy, East(); operation = nothing, index = :all)
                #= none:375 =#
                north_indices = get_boundary_indices(Nx, Ny, Hx, Hy, North(); operation = nothing, index = :all)
                #= none:376 =#
                west_indices = get_boundary_indices(Nx, Ny, Hx, Hy, West(); operation = nothing, index = :all)
                #= none:378 =#
                south_indices_first = get_boundary_indices(Nx, Ny, Hx, Hy, South(); operation = :endpoint, index = :first)
                #= none:379 =#
                south_indices_last = get_boundary_indices(Nx, Ny, Hx, Hy, South(); operation = :endpoint, index = :last)
                #= none:380 =#
                east_indices_first = get_boundary_indices(Nx, Ny, Hx, Hy, East(); operation = :endpoint, index = :first)
                #= none:381 =#
                east_indices_last = get_boundary_indices(Nx, Ny, Hx, Hy, East(); operation = :endpoint, index = :last)
                #= none:382 =#
                north_indices_first = get_boundary_indices(Nx, Ny, Hx, Hy, North(); operation = :endpoint, index = :first)
                #= none:383 =#
                north_indices_last = get_boundary_indices(Nx, Ny, Hx, Hy, North(); operation = :endpoint, index = :last)
                #= none:384 =#
                west_indices_first = get_boundary_indices(Nx, Ny, Hx, Hy, West(); operation = :endpoint, index = :first)
                #= none:385 =#
                west_indices_last = get_boundary_indices(Nx, Ny, Hx, Hy, West(); operation = :endpoint, index = :last)
                #= none:387 =#
                south_indices_subset_skip_first_index = get_boundary_indices(Nx, Ny, Hx, Hy, South(); operation = :subset, index = :first)
                #= none:388 =#
                south_indices_subset_skip_last_index = get_boundary_indices(Nx, Ny, Hx, Hy, South(); operation = :subset, index = :last)
                #= none:389 =#
                east_indices_subset_skip_first_index = get_boundary_indices(Nx, Ny, Hx, Hy, East(); operation = :subset, index = :first)
                #= none:390 =#
                east_indices_subset_skip_last_index = get_boundary_indices(Nx, Ny, Hx, Hy, East(); operation = :subset, index = :last)
                #= none:391 =#
                north_indices_subset_skip_first_index = get_boundary_indices(Nx, Ny, Hx, Hy, North(); operation = :subset, index = :first)
                #= none:392 =#
                north_indices_subset_skip_last_index = get_boundary_indices(Nx, Ny, Hx, Hy, North(); operation = :subset, index = :last)
                #= none:393 =#
                west_indices_subset_skip_first_index = get_boundary_indices(Nx, Ny, Hx, Hy, West(); operation = :subset, index = :first)
                #= none:394 =#
                west_indices_subset_skip_last_index = get_boundary_indices(Nx, Ny, Hx, Hy, West(); operation = :subset, index = :last)
                #= none:397 =#
                #= none:397 =# CUDA.@allowscalar begin
                        #= none:399 =#
                        switch_device!(grid, 1)
                        #= none:402 =#
                        #= none:402 =# @test get_halo_data(getregion(u, 1), West()) == (reverse((create_v_test_data(grid, 5))[north_indices...], dims = 1))'
                        #= none:403 =#
                        #= none:403 =# @test get_halo_data(getregion(u, 1), East()) == (create_u_test_data(grid, 2))[west_indices...]
                        #= none:404 =#
                        #= none:404 =# @test get_halo_data(getregion(u, 1), South()) == (create_u_test_data(grid, 6))[north_indices...]
                        #= none:407 =#
                        #= none:407 =# @test get_halo_data(getregion(u, 1), North(); operation = :subset, index = :first) == -((reverse((create_v_test_data(grid, 3))[west_indices_subset_skip_first_index...], dims = 2))')
                        #= none:411 =#
                        #= none:411 =# @test get_halo_data(getregion(u, 1), North(); operation = :endpoint, index = :first) == -(reverse((create_u_test_data(grid, 5))[north_indices_first...]))
                        #= none:416 =#
                        switch_device!(grid, 2)
                        #= none:419 =#
                        #= none:419 =# @test get_halo_data(getregion(u, 2), West()) == (create_u_test_data(grid, 1))[east_indices...]
                        #= none:420 =#
                        #= none:420 =# @test get_halo_data(getregion(u, 2), East()) == (reverse((create_v_test_data(grid, 4))[south_indices...], dims = 1))'
                        #= none:421 =#
                        #= none:421 =# @test get_halo_data(getregion(u, 2), North()) == (create_u_test_data(grid, 3))[south_indices...]
                        #= none:424 =#
                        #= none:424 =# @test get_halo_data(getregion(u, 2), South(); operation = :subset, index = :first) == -((reverse((create_v_test_data(grid, 6))[east_indices_subset_skip_first_index...], dims = 2))')
                        #= none:428 =#
                        #= none:428 =# @test get_halo_data(getregion(u, 2), South(); operation = :endpoint, index = :first) == -((create_v_test_data(grid, 1))[east_indices_first...])
                        #= none:432 =#
                        switch_device!(grid, 3)
                        #= none:435 =#
                        #= none:435 =# @test get_halo_data(getregion(u, 3), West()) == (reverse((create_v_test_data(grid, 1))[north_indices...], dims = 1))'
                        #= none:436 =#
                        #= none:436 =# @test get_halo_data(getregion(u, 3), East()) == (create_u_test_data(grid, 4))[west_indices...]
                        #= none:437 =#
                        #= none:437 =# @test get_halo_data(getregion(u, 3), South()) == (create_u_test_data(grid, 2))[north_indices...]
                        #= none:440 =#
                        #= none:440 =# @test get_halo_data(getregion(u, 3), North(); operation = :subset, index = :first) == -((reverse((create_v_test_data(grid, 5))[west_indices_subset_skip_first_index...], dims = 2))')
                        #= none:444 =#
                        #= none:444 =# @test get_halo_data(getregion(u, 3), North(); operation = :endpoint, index = :first) == -(reverse((create_u_test_data(grid, 1))[north_indices_first...]))
                        #= none:448 =#
                        switch_device!(grid, 4)
                        #= none:451 =#
                        #= none:451 =# @test get_halo_data(getregion(u, 4), West()) == (create_u_test_data(grid, 3))[east_indices...]
                        #= none:452 =#
                        #= none:452 =# @test get_halo_data(getregion(u, 4), East()) == (reverse((create_v_test_data(grid, 6))[south_indices...], dims = 1))'
                        #= none:453 =#
                        #= none:453 =# @test get_halo_data(getregion(u, 4), North()) == (create_u_test_data(grid, 5))[south_indices...]
                        #= none:456 =#
                        #= none:456 =# @test get_halo_data(getregion(u, 4), South(); operation = :subset, index = :first) == -((reverse((create_v_test_data(grid, 2))[east_indices_subset_skip_first_index...], dims = 2))')
                        #= none:460 =#
                        #= none:460 =# @test get_halo_data(getregion(u, 4), South(); operation = :endpoint, index = :first) == -((create_v_test_data(grid, 3))[east_indices_first...])
                        #= none:464 =#
                        switch_device!(grid, 5)
                        #= none:467 =#
                        #= none:467 =# @test get_halo_data(getregion(u, 5), West()) == (reverse((create_v_test_data(grid, 3))[north_indices...], dims = 1))'
                        #= none:468 =#
                        #= none:468 =# @test get_halo_data(getregion(u, 5), East()) == (create_u_test_data(grid, 6))[west_indices...]
                        #= none:469 =#
                        #= none:469 =# @test get_halo_data(getregion(u, 5), South()) == (create_u_test_data(grid, 4))[north_indices...]
                        #= none:472 =#
                        #= none:472 =# @test get_halo_data(getregion(u, 5), North(); operation = :subset, index = :first) == -((reverse((create_v_test_data(grid, 1))[west_indices_subset_skip_first_index...], dims = 2))')
                        #= none:476 =#
                        #= none:476 =# @test get_halo_data(getregion(u, 5), North(); operation = :endpoint, index = :first) == -(reverse((create_u_test_data(grid, 3))[north_indices_first...]))
                        #= none:480 =#
                        switch_device!(grid, 6)
                        #= none:483 =#
                        #= none:483 =# @test get_halo_data(getregion(u, 6), West()) == (create_u_test_data(grid, 5))[east_indices...]
                        #= none:484 =#
                        #= none:484 =# @test get_halo_data(getregion(u, 6), East()) == (reverse((create_v_test_data(grid, 2))[south_indices...], dims = 1))'
                        #= none:485 =#
                        #= none:485 =# @test get_halo_data(getregion(u, 6), North()) == (create_u_test_data(grid, 1))[south_indices...]
                        #= none:488 =#
                        #= none:488 =# @test get_halo_data(getregion(u, 6), South(); operation = :subset, index = :first) == -((reverse((create_v_test_data(grid, 4))[east_indices_subset_skip_first_index...], dims = 2))')
                        #= none:492 =#
                        #= none:492 =# @test get_halo_data(getregion(u, 6), South(); operation = :endpoint, index = :first) == -((create_v_test_data(grid, 5))[east_indices_first...])
                    end
                #= none:498 =#
                #= none:498 =# CUDA.@allowscalar begin
                        #= none:500 =#
                        switch_device!(grid, 1)
                        #= none:503 =#
                        #= none:503 =# @test get_halo_data(getregion(v, 1), East()) == (create_v_test_data(grid, 2))[west_indices...]
                        #= none:504 =#
                        #= none:504 =# @test get_halo_data(getregion(v, 1), South()) == (create_v_test_data(grid, 6))[north_indices...]
                        #= none:505 =#
                        #= none:505 =# @test get_halo_data(getregion(v, 1), North()) == (reverse((create_u_test_data(grid, 3))[west_indices...], dims = 2))'
                        #= none:508 =#
                        #= none:508 =# @test get_halo_data(getregion(v, 1), West(); operation = :subset, index = :first) == -((reverse((create_u_test_data(grid, 5))[north_indices_subset_skip_first_index...], dims = 1))')
                        #= none:512 =#
                        #= none:512 =# @test get_halo_data(getregion(v, 1), West(); operation = :endpoint, index = :first) == -((create_u_test_data(grid, 6))[north_indices_first...])
                        #= none:516 =#
                        switch_device!(grid, 2)
                        #= none:519 =#
                        #= none:519 =# @test get_halo_data(getregion(v, 2), West()) == (create_v_test_data(grid, 1))[east_indices...]
                        #= none:520 =#
                        #= none:520 =# @test get_halo_data(getregion(v, 2), South()) == (reverse((create_u_test_data(grid, 6))[east_indices...], dims = 2))'
                        #= none:521 =#
                        #= none:521 =# @test get_halo_data(getregion(v, 2), North()) == (create_v_test_data(grid, 3))[south_indices...]
                        #= none:524 =#
                        #= none:524 =# @test get_halo_data(getregion(v, 2), East(); operation = :subset, index = :first) == -((reverse((create_u_test_data(grid, 4))[south_indices_subset_skip_first_index...], dims = 1))')
                        #= none:528 =#
                        #= none:528 =# @test get_halo_data(getregion(v, 2), East(); operation = :endpoint, index = :first) == -(reverse((create_v_test_data(grid, 6))[east_indices_first...]))
                        #= none:532 =#
                        switch_device!(grid, 3)
                        #= none:535 =#
                        #= none:535 =# @test get_halo_data(getregion(v, 3), East()) == (create_v_test_data(grid, 4))[west_indices...]
                        #= none:536 =#
                        #= none:536 =# @test get_halo_data(getregion(v, 3), South()) == (create_v_test_data(grid, 2))[north_indices...]
                        #= none:537 =#
                        #= none:537 =# @test get_halo_data(getregion(v, 3), North()) == (reverse((create_u_test_data(grid, 5))[west_indices...], dims = 2))'
                        #= none:540 =#
                        #= none:540 =# @test get_halo_data(getregion(v, 3), West(); operation = :subset, index = :first) == -((reverse((create_u_test_data(grid, 1))[north_indices_subset_skip_first_index...], dims = 1))')
                        #= none:544 =#
                        #= none:544 =# @test get_halo_data(getregion(v, 3), West(); operation = :endpoint, index = :first) == -((create_u_test_data(grid, 2))[north_indices_first...])
                        #= none:548 =#
                        switch_device!(grid, 4)
                        #= none:551 =#
                        #= none:551 =# @test get_halo_data(getregion(v, 4), West()) == (create_v_test_data(grid, 3))[east_indices...]
                        #= none:552 =#
                        #= none:552 =# @test get_halo_data(getregion(v, 4), South()) == (reverse((create_u_test_data(grid, 2))[east_indices...], dims = 2))'
                        #= none:553 =#
                        #= none:553 =# @test get_halo_data(getregion(v, 4), North()) == (create_v_test_data(grid, 5))[south_indices...]
                        #= none:556 =#
                        #= none:556 =# @test get_halo_data(getregion(v, 4), East(); operation = :subset, index = :first) == -((reverse((create_u_test_data(grid, 6))[south_indices_subset_skip_first_index...], dims = 1))')
                        #= none:560 =#
                        #= none:560 =# @test get_halo_data(getregion(v, 4), East(); operation = :endpoint, index = :first) == -(reverse((create_v_test_data(grid, 2))[east_indices_first...]))
                        #= none:564 =#
                        switch_device!(grid, 5)
                        #= none:567 =#
                        #= none:567 =# @test get_halo_data(getregion(v, 5), East()) == (create_v_test_data(grid, 6))[west_indices...]
                        #= none:568 =#
                        #= none:568 =# @test get_halo_data(getregion(v, 5), South()) == (create_v_test_data(grid, 4))[north_indices...]
                        #= none:569 =#
                        #= none:569 =# @test get_halo_data(getregion(v, 5), North()) == (reverse((create_u_test_data(grid, 1))[west_indices...], dims = 2))'
                        #= none:572 =#
                        #= none:572 =# @test get_halo_data(getregion(v, 5), West(); operation = :subset, index = :first) == -((reverse((create_u_test_data(grid, 3))[north_indices_subset_skip_first_index...], dims = 1))')
                        #= none:576 =#
                        #= none:576 =# @test get_halo_data(getregion(v, 5), West(); operation = :endpoint, index = :first) == -((create_u_test_data(grid, 4))[north_indices_first...])
                        #= none:580 =#
                        switch_device!(grid, 6)
                        #= none:583 =#
                        #= none:583 =# @test get_halo_data(getregion(v, 6), West()) == (create_v_test_data(grid, 5))[east_indices...]
                        #= none:584 =#
                        #= none:584 =# @test get_halo_data(getregion(v, 6), South()) == (reverse((create_u_test_data(grid, 4))[east_indices...], dims = 2))'
                        #= none:585 =#
                        #= none:585 =# @test get_halo_data(getregion(v, 6), North()) == (create_v_test_data(grid, 1))[south_indices...]
                        #= none:588 =#
                        #= none:588 =# @test get_halo_data(getregion(v, 6), East(); operation = :subset, index = :first) == -((reverse((create_u_test_data(grid, 2))[south_indices_subset_skip_first_index...], dims = 1))')
                        #= none:592 =#
                        #= none:592 =# @test get_halo_data(getregion(v, 6), East(); operation = :endpoint, index = :first) == -(reverse((create_v_test_data(grid, 4))[east_indices_first...]))
                    end
                #= none:596 =#
            end
            #= none:597 =#
        end
    end
#= none:600 =#
#= none:600 =# @testset "Testing conformal cubed sphere fill halos for Face-Face-Any field" begin
        #= none:601 =#
        for FT = float_types
            #= none:602 =#
            for arch = archs
                #= none:603 =#
                #= none:603 =# @info "  Testing fill halos for streamfunction [$(FT), $(typeof(arch))]..."
                #= none:605 =#
                (Nx, Ny, Nz) = (9, 9, 1)
                #= none:607 =#
                grid = ConformalCubedSphereGrid(arch, FT; panel_size = (Nx, Ny, Nz), z = (0, 1), radius = 1, horizontal_direction_halo = 3)
                #= none:608 =#
                ψ = Field{Face, Face, Center}(grid)
                #= none:610 =#
                region = Iterate(1:6)
                #= none:611 =#
                #= none:611 =# @apply_regionally data = create_ψ_test_data(grid, region)
                #= none:612 =#
                set!(ψ, data)
                #= none:614 =#
                fill_halo_regions!(ψ)
                #= none:616 =#
                (Hx, Hy, Hz) = halo_size(ψ.grid)
                #= none:618 =#
                south_indices = get_boundary_indices(Nx, Ny, Hx, Hy, South(); operation = nothing, index = :all)
                #= none:619 =#
                east_indices = get_boundary_indices(Nx, Ny, Hx, Hy, East(); operation = nothing, index = :all)
                #= none:620 =#
                north_indices = get_boundary_indices(Nx, Ny, Hx, Hy, North(); operation = nothing, index = :all)
                #= none:621 =#
                west_indices = get_boundary_indices(Nx, Ny, Hx, Hy, West(); operation = nothing, index = :all)
                #= none:623 =#
                south_indices_first = get_boundary_indices(Nx, Ny, Hx, Hy, South(); operation = :endpoint, index = :first)
                #= none:624 =#
                south_indices_last = get_boundary_indices(Nx, Ny, Hx, Hy, South(); operation = :endpoint, index = :last)
                #= none:625 =#
                east_indices_first = get_boundary_indices(Nx, Ny, Hx, Hy, East(); operation = :endpoint, index = :first)
                #= none:626 =#
                east_indices_last = get_boundary_indices(Nx, Ny, Hx, Hy, East(); operation = :endpoint, index = :last)
                #= none:627 =#
                north_indices_first = get_boundary_indices(Nx, Ny, Hx, Hy, North(); operation = :endpoint, index = :first)
                #= none:628 =#
                north_indices_last = get_boundary_indices(Nx, Ny, Hx, Hy, North(); operation = :endpoint, index = :last)
                #= none:629 =#
                west_indices_first = get_boundary_indices(Nx, Ny, Hx, Hy, West(); operation = :endpoint, index = :first)
                #= none:630 =#
                west_indices_last = get_boundary_indices(Nx, Ny, Hx, Hy, West(); operation = :endpoint, index = :last)
                #= none:632 =#
                south_indices_subset_skip_first_index = get_boundary_indices(Nx, Ny, Hx, Hy, South(); operation = :subset, index = :first)
                #= none:633 =#
                south_indices_subset_skip_last_index = get_boundary_indices(Nx, Ny, Hx, Hy, South(); operation = :subset, index = :last)
                #= none:634 =#
                east_indices_subset_skip_first_index = get_boundary_indices(Nx, Ny, Hx, Hy, East(); operation = :subset, index = :first)
                #= none:635 =#
                east_indices_subset_skip_last_index = get_boundary_indices(Nx, Ny, Hx, Hy, East(); operation = :subset, index = :last)
                #= none:636 =#
                north_indices_subset_skip_first_index = get_boundary_indices(Nx, Ny, Hx, Hy, North(); operation = :subset, index = :first)
                #= none:637 =#
                north_indices_subset_skip_last_index = get_boundary_indices(Nx, Ny, Hx, Hy, North(); operation = :subset, index = :last)
                #= none:638 =#
                west_indices_subset_skip_first_index = get_boundary_indices(Nx, Ny, Hx, Hy, West(); operation = :subset, index = :first)
                #= none:639 =#
                west_indices_subset_skip_last_index = get_boundary_indices(Nx, Ny, Hx, Hy, West(); operation = :subset, index = :last)
                #= none:642 =#
                #= none:642 =# CUDA.@allowscalar begin
                        #= none:645 =#
                        switch_device!(grid, 1)
                        #= none:648 =#
                        #= none:648 =# @test get_halo_data(getregion(ψ, 1), East()) == (create_ψ_test_data(grid, 2))[west_indices...]
                        #= none:649 =#
                        #= none:649 =# @test get_halo_data(getregion(ψ, 1), South()) == (create_ψ_test_data(grid, 6))[north_indices...]
                        #= none:652 =#
                        #= none:652 =# @test get_halo_data(getregion(ψ, 1), North(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 3))[west_indices_subset_skip_first_index...], dims = 2))'
                        #= none:658 =#
                        #= none:658 =# @test get_halo_data(getregion(ψ, 1), West(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 5))[north_indices_subset_skip_first_index...], dims = 1))'
                        #= none:662 =#
                        #= none:662 =# @test get_halo_data(getregion(ψ, 1), West(); operation = :endpoint, index = :first) == (create_ψ_test_data(grid, 6))[north_indices_first...]
                        #= none:666 =#
                        switch_device!(grid, 2)
                        #= none:667 =#
                        #= none:667 =# @test get_halo_data(getregion(ψ, 2), West()) == (create_ψ_test_data(grid, 1))[east_indices...]
                        #= none:668 =#
                        #= none:668 =# @test get_halo_data(getregion(ψ, 2), North()) == (create_ψ_test_data(grid, 3))[south_indices...]
                        #= none:671 =#
                        #= none:671 =# @test get_halo_data(getregion(ψ, 2), East(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 4))[south_indices_subset_skip_first_index...], dims = 1))'
                        #= none:677 =#
                        #= none:677 =# @test get_halo_data(getregion(ψ, 2), South(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 6))[east_indices_subset_skip_first_index...], dims = 2))'
                        #= none:681 =#
                        #= none:681 =# @test get_halo_data(getregion(ψ, 2), South(); operation = :endpoint, index = :first) == (create_ψ_test_data(grid, 1))[east_indices_first...]
                        #= none:685 =#
                        switch_device!(grid, 3)
                        #= none:686 =#
                        #= none:686 =# @test get_halo_data(getregion(ψ, 3), East()) == (create_ψ_test_data(grid, 4))[west_indices...]
                        #= none:687 =#
                        #= none:687 =# @test get_halo_data(getregion(ψ, 3), South()) == (create_ψ_test_data(grid, 2))[north_indices...]
                        #= none:690 =#
                        #= none:690 =# @test get_halo_data(getregion(ψ, 3), West(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 1))[north_indices_subset_skip_first_index...], dims = 1))'
                        #= none:694 =#
                        #= none:694 =# @test get_halo_data(getregion(ψ, 3), West(); operation = :endpoint, index = :first) == (create_ψ_test_data(grid, 2))[north_indices_first...]
                        #= none:699 =#
                        #= none:699 =# @test get_halo_data(getregion(ψ, 3), North(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 5))[west_indices_subset_skip_first_index...], dims = 2))'
                        #= none:704 =#
                        switch_device!(grid, 4)
                        #= none:705 =#
                        #= none:705 =# @test get_halo_data(getregion(ψ, 4), West()) == (create_ψ_test_data(grid, 3))[east_indices...]
                        #= none:706 =#
                        #= none:706 =# @test get_halo_data(getregion(ψ, 4), North()) == (create_ψ_test_data(grid, 5))[south_indices...]
                        #= none:709 =#
                        #= none:709 =# @test get_halo_data(getregion(ψ, 4), East(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 6))[south_indices_subset_skip_first_index...], dims = 1))'
                        #= none:715 =#
                        #= none:715 =# @test get_halo_data(getregion(ψ, 4), South(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 2))[east_indices_subset_skip_first_index...], dims = 2))'
                        #= none:719 =#
                        #= none:719 =# @test get_halo_data(getregion(ψ, 4), South(); operation = :endpoint, index = :first) == (create_ψ_test_data(grid, 3))[east_indices_first...]
                        #= none:723 =#
                        switch_device!(grid, 5)
                        #= none:724 =#
                        #= none:724 =# @test get_halo_data(getregion(ψ, 5), East()) == (create_ψ_test_data(grid, 6))[west_indices...]
                        #= none:725 =#
                        #= none:725 =# @test get_halo_data(getregion(ψ, 5), South()) == (create_ψ_test_data(grid, 4))[north_indices...]
                        #= none:728 =#
                        #= none:728 =# @test get_halo_data(getregion(ψ, 5), West(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 3))[north_indices_subset_skip_first_index...], dims = 1))'
                        #= none:732 =#
                        #= none:732 =# @test get_halo_data(getregion(ψ, 5), West(); operation = :endpoint, index = :first) == (create_ψ_test_data(grid, 4))[north_indices_first...]
                        #= none:737 =#
                        #= none:737 =# @test get_halo_data(getregion(ψ, 5), North(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 1))[west_indices_subset_skip_first_index...], dims = 2))'
                        #= none:742 =#
                        switch_device!(grid, 6)
                        #= none:743 =#
                        #= none:743 =# @test get_halo_data(getregion(ψ, 6), West()) == (create_ψ_test_data(grid, 5))[east_indices...]
                        #= none:744 =#
                        #= none:744 =# @test get_halo_data(getregion(ψ, 6), North()) == (create_ψ_test_data(grid, 1))[south_indices...]
                        #= none:747 =#
                        #= none:747 =# @test get_halo_data(getregion(ψ, 6), East(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 2))[south_indices_subset_skip_first_index...], dims = 1))'
                        #= none:753 =#
                        #= none:753 =# @test get_halo_data(getregion(ψ, 6), South(); operation = :subset, index = :first) == (reverse((create_ψ_test_data(grid, 4))[east_indices_subset_skip_first_index...], dims = 2))'
                        #= none:758 =#
                        #= none:758 =# @test get_halo_data(getregion(ψ, 6), South(); operation = :endpoint, index = :first) == (create_ψ_test_data(grid, 5))[east_indices_first...]
                    end
                #= none:763 =#
            end
            #= none:764 =#
        end
    end