
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
devices(::CPU, num) = begin
        #= none:3 =#
        nothing
    end
#= none:4 =#
devices(::GPU, num) = begin
        #= none:4 =#
        Tuple((0 for i = 1:num))
    end
#= none:6 =#
#= none:6 =# @testset "Testing multi region grids" begin
        #= none:7 =#
        for arch = archs
            #= none:9 =#
            regions = [2, 4, 5]
            #= none:10 =#
            partition_types = [XPartition]
            #= none:12 =#
            lat_lon_grid = LatitudeLongitudeGrid(arch, size = (20, 20, 1), latitude = (-80, 80), longitude = collect(range(-180, 180, length = 21)), z = (0, 1))
            #= none:18 =#
            rectilinear_grid = RectilinearGrid(arch, size = (20, 20, 1), x = (0, 1), y = collect(range(0, 1, length = 21)), z = (0, 1))
            #= none:24 =#
            grids = [lat_lon_grid, rectilinear_grid]
            #= none:26 =#
            immersed_boundaries = [GridFittedBottom(((x, y)->begin
                                #= none:26 =#
                                0.5
                            end)), GridFittedBoundary(((x, y, z)->begin
                                #= none:27 =#
                                z > 0.5
                            end))]
            #= none:29 =#
            for grid = grids, Partition = partition_types, region = regions
                #= none:30 =#
                #= none:30 =# @info "Testing multi region $(getnamewrapper(grid)) on $(regions) $(Partition)s"
                #= none:31 =#
                mrg = MultiRegionGrid(grid, partition = Partition(region), devices = devices(arch, region))
                #= none:33 =#
                #= none:33 =# @test reconstruct_global_grid(mrg) == grid
                #= none:35 =#
                for FieldType = [CenterField, XFaceField, YFaceField]
                    #= none:36 =#
                    #= none:36 =# @info "Testing multi region $(FieldType) on $(getnamewrapper(grid)) on $(regions) $(Partition)s"
                    #= none:38 =#
                    multi_region_field = FieldType(mrg)
                    #= none:39 =#
                    single_region_field = FieldType(grid)
                    #= none:41 =#
                    set!(single_region_field, ((x, y, z)->begin
                                #= none:41 =#
                                x
                            end))
                    #= none:42 =#
                    set!(multi_region_field, ((x, y, z)->begin
                                #= none:42 =#
                                x
                            end))
                    #= none:44 =#
                    fill_halo_regions!(single_region_field)
                    #= none:45 =#
                    fill_halo_regions!(multi_region_field)
                    #= none:48 =#
                    reconstructed_field = reconstruct_global_field(multi_region_field)
                    #= none:50 =#
                    #= none:50 =# @test parent(reconstructed_field) ≈ Array(parent(single_region_field))
                    #= none:51 =#
                end
                #= none:53 =#
                for immersed_boundary = immersed_boundaries
                    #= none:54 =#
                    #= none:54 =# @info "Testing multi region immersed boundaries on $(getnamewrapper(grid)) on $(regions) $(Partition)s"
                    #= none:55 =#
                    ibg = ImmersedBoundaryGrid(grid, immersed_boundary)
                    #= none:56 =#
                    mrg = MultiRegionGrid(grid, partition = Partition(region), devices = devices(arch, region))
                    #= none:57 =#
                    mribg = ImmersedBoundaryGrid(mrg, immersed_boundary)
                    #= none:59 =#
                    #= none:59 =# @test reconstruct_global_grid(mribg) == ibg
                    #= none:60 =#
                end
                #= none:61 =#
            end
            #= none:62 =#
        end
    end