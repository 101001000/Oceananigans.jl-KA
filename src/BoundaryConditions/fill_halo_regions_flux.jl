
#= none:14 =#
#= none:14 =# @inline _fill_flux_west_halo!(i, j, k, grid, c) = begin
            #= none:14 =#
            #= none:14 =# @inbounds c[1 - i, j, k] = c[i, j, k]
        end
#= none:15 =#
#= none:15 =# @inline _fill_flux_east_halo!(i, j, k, grid, c) = begin
            #= none:15 =#
            #= none:15 =# @inbounds c[grid.Nx + i, j, k] = c[(grid.Nx + 1) - i, j, k]
        end
#= none:17 =#
#= none:17 =# @inline _fill_flux_south_halo!(i, j, k, grid, c) = begin
            #= none:17 =#
            #= none:17 =# @inbounds c[i, 1 - j, k] = c[i, j, k]
        end
#= none:18 =#
#= none:18 =# @inline _fill_flux_north_halo!(i, j, k, grid, c) = begin
            #= none:18 =#
            #= none:18 =# @inbounds c[i, grid.Ny + j, k] = c[i, (grid.Ny + 1) - j, k]
        end
#= none:20 =#
#= none:20 =# @inline _fill_flux_bottom_halo!(i, j, k, grid, c) = begin
            #= none:20 =#
            #= none:20 =# @inbounds c[i, j, 1 - k] = c[i, j, k]
        end
#= none:21 =#
#= none:21 =# @inline _fill_flux_top_halo!(i, j, k, grid, c) = begin
            #= none:21 =#
            #= none:21 =# @inbounds c[i, j, grid.Nz + k] = c[i, j, (grid.Nz + 1) - k]
        end
#= none:28 =#
#= none:28 =# @inline _fill_west_halo!(j, k, grid, c, ::FBC, args...) = begin
            #= none:28 =#
            _fill_flux_west_halo!(1, j, k, grid, c)
        end
#= none:29 =#
#= none:29 =# @inline _fill_east_halo!(j, k, grid, c, ::FBC, args...) = begin
            #= none:29 =#
            _fill_flux_east_halo!(1, j, k, grid, c)
        end
#= none:30 =#
#= none:30 =# @inline _fill_south_halo!(i, k, grid, c, ::FBC, args...) = begin
            #= none:30 =#
            _fill_flux_south_halo!(i, 1, k, grid, c)
        end
#= none:31 =#
#= none:31 =# @inline _fill_north_halo!(i, k, grid, c, ::FBC, args...) = begin
            #= none:31 =#
            _fill_flux_north_halo!(i, 1, k, grid, c)
        end
#= none:32 =#
#= none:32 =# @inline _fill_bottom_halo!(i, j, grid, c, ::FBC, args...) = begin
            #= none:32 =#
            _fill_flux_bottom_halo!(i, j, 1, grid, c)
        end
#= none:33 =#
#= none:33 =# @inline _fill_top_halo!(i, j, grid, c, ::FBC, args...) = begin
            #= none:33 =#
            _fill_flux_top_halo!(i, j, 1, grid, c)
        end