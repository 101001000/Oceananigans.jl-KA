
#= none:1 =#
function halo_regions_initalized_correctly(arch, FT, Nx, Ny, Nz)
    #= none:1 =#
    #= none:3 =#
    (Lx, Ly, Lz) = (10, 20, 30)
    #= none:5 =#
    grid = RectilinearGrid(arch, FT, size = (Nx, Ny, Nz), extent = (Lx, Ly, Lz), halo = (1, 1, 1))
    #= none:6 =#
    field = CenterField(grid)
    #= none:9 =#
    set!(field, rand(FT, Nx, Ny, Nz))
    #= none:11 =#
    (Hx, Hy, Hz) = (grid.Hx, grid.Hy, grid.Hz)
    #= none:14 =#
    return #= none:14 =# CUDA.@allowscalar(all(field.data[1 - Hx:0, :, :] .== 0) && (all(field.data[Nx + 1:Nx + Hx, :, :] .== 0) && (all(field.data[:, 1 - Hy:0, :] .== 0) && (all(field.data[:, Ny + 1:Ny + Hy, :] .== 0) && (all(field.data[:, :, 1 - Hz:0] .== 0) && all(field.data[:, :, Nz + 1:Nz + Hz] .== 0))))))
end
#= none:22 =#
function halo_regions_correctly_filled(arch, FT, Nx, Ny, Nz)
    #= none:22 =#
    #= none:24 =#
    (Lx, Ly, Lz) = (100, 200, 300)
    #= none:26 =#
    grid = RectilinearGrid(arch, FT, size = (Nx, Ny, Nz), extent = (Lx, Ly, Lz), halo = (1, 1, 1), topology = (Periodic, Periodic, Bounded))
    #= none:29 =#
    field = CenterField(grid)
    #= none:31 =#
    set!(field, rand(FT, Nx, Ny, Nz))
    #= none:32 =#
    fill_halo_regions!(field)
    #= none:34 =#
    (Hx, Hy, Hz) = (grid.Hx, grid.Hy, grid.Hz)
    #= none:35 =#
    data = field.data
    #= none:37 =#
    return #= none:37 =# CUDA.@allowscalar(all(data[1 - Hx:0, 1:Ny, 1:Nz] .== data[(Nx - Hx) + 1:Nx, 1:Ny, 1:Nz]) && (all(data[1:Nx, 1 - Hy:0, 1:Nz] .== data[1:Nx, (Ny - Hy) + 1:Ny, 1:Nz]) && (all(data[1:Nx, 1:Ny, 0:0] .== data[1:Nx, 1:Ny, 1:1]) && all(data[1:Nx, 1:Ny, Nz + 1:Nz + 1] .== data[1:Nx, 1:Ny, Nz:Nz]))))
end
#= none:43 =#
#= none:43 =# @testset "Halo regions" begin
        #= none:44 =#
        #= none:44 =# @info "Testing halo regions..."
        #= none:46 =#
        Ns = [(8, 8, 8), (8, 8, 4), (10, 7, 5), (1, 8, 8), (1, 9, 5), (8, 1, 8), (5, 1, 9), (8, 8, 1), (5, 9, 1), (1, 1, 8)]
        #= none:52 =#
        #= none:52 =# @testset "Initializing halo regions" begin
                #= none:53 =#
                #= none:53 =# @info "  Testing initializing halo regions..."
                #= none:54 =#
                for arch = archs, FT = float_types, N = Ns
                    #= none:55 =#
                    #= none:55 =# @test halo_regions_initalized_correctly(arch, FT, N...)
                    #= none:56 =#
                end
            end
        #= none:59 =#
        #= none:59 =# @testset "Filling halo regions" begin
                #= none:60 =#
                #= none:60 =# @info "  Testing filling halo regions..."
                #= none:61 =#
                for arch = archs, FT = float_types, N = Ns
                    #= none:62 =#
                    #= none:62 =# @test halo_regions_correctly_filled(arch, FT, N...)
                    #= none:63 =#
                end
            end
    end