
#= none:1 =#
#= none:1 =# @inline fill_open_boundary_regions!(field, args...) = begin
            #= none:1 =#
            fill_open_boundary_regions!(field, field.boundary_conditions, field.indices, instantiated_location(field), field.grid)
        end
#= none:4 =#
#= none:4 =# Core.@doc "    fill_open_boundary_regions!(fields, boundary_conditions, indices, loc, grid, args...; kwargs...)\n\nFill open boundary halo regions by filling boundary conditions on field faces with `open_fill`. \n" function fill_open_boundary_regions!(field, boundary_conditions, indices, loc, grid, args...; kwargs...)
        #= none:9 =#
        #= none:10 =#
        arch = architecture(grid)
        #= none:12 =#
        left_bc = left_velocity_open_boundary_condition(boundary_conditions, loc)
        #= none:13 =#
        right_bc = right_velocity_open_boundary_condition(boundary_conditions, loc)
        #= none:17 =#
        (open_fill, regular_fill) = get_open_halo_filling_functions(loc)
        #= none:18 =#
        fill_size = fill_halo_size(field, regular_fill, indices, boundary_conditions, loc, grid)
        #= none:20 =#
        launch!(arch, grid, fill_size, open_fill, field, left_bc, right_bc, loc, grid, args)
        #= none:22 =#
        return nothing
    end
#= none:25 =#
fill_open_boundary_regions!(fields::NTuple, boundary_conditions, indices, loc, grid, args...; kwargs...) = begin
        #= none:25 =#
        [fill_open_boundary_regions!(field, boundary_conditions[n], indices, loc[n], grid, args...; kwargs...) for (n, field) = enumerate(fields)]
    end
#= none:29 =#
#= none:29 =# @inline left_velocity_open_boundary_condition(boundary_condition, loc) = begin
            #= none:29 =#
            nothing
        end
#= none:30 =#
#= none:30 =# @inline left_velocity_open_boundary_condition(boundary_conditions, ::Tuple{Face, Center, Center}) = begin
            #= none:30 =#
            boundary_conditions.west
        end
#= none:31 =#
#= none:31 =# @inline left_velocity_open_boundary_condition(boundary_conditions, ::Tuple{Center, Face, Center}) = begin
            #= none:31 =#
            boundary_conditions.south
        end
#= none:32 =#
#= none:32 =# @inline left_velocity_open_boundary_condition(boundary_conditions, ::Tuple{Center, Center, Face}) = begin
            #= none:32 =#
            boundary_conditions.bottom
        end
#= none:34 =#
#= none:34 =# @inline right_velocity_open_boundary_condition(boundary_conditions, loc) = begin
            #= none:34 =#
            nothing
        end
#= none:35 =#
#= none:35 =# @inline right_velocity_open_boundary_condition(boundary_conditions, ::Tuple{Face, Center, Center}) = begin
            #= none:35 =#
            boundary_conditions.east
        end
#= none:36 =#
#= none:36 =# @inline right_velocity_open_boundary_condition(boundary_conditions, ::Tuple{Center, Face, Center}) = begin
            #= none:36 =#
            boundary_conditions.north
        end
#= none:37 =#
#= none:37 =# @inline right_velocity_open_boundary_condition(boundary_conditions, ::Tuple{Center, Center, Face}) = begin
            #= none:37 =#
            boundary_conditions.top
        end
#= none:40 =#
#= none:40 =# @inline left_velocity_open_boundary_condition(boundary_conditions::Tuple, ::Tuple{Face, Center, Center}) = begin
            #= none:40 =#
            #= none:40 =# @inbounds boundary_conditions[1]
        end
#= none:41 =#
#= none:41 =# @inline left_velocity_open_boundary_condition(boundary_conditions::Tuple, ::Tuple{Center, Face, Center}) = begin
            #= none:41 =#
            #= none:41 =# @inbounds boundary_conditions[1]
        end
#= none:42 =#
#= none:42 =# @inline left_velocity_open_boundary_condition(boundary_conditions::Tuple, ::Tuple{Center, Center, Face}) = begin
            #= none:42 =#
            #= none:42 =# @inbounds boundary_conditions[1]
        end
#= none:44 =#
#= none:44 =# @inline right_velocity_open_boundary_condition(boundary_conditions::Tuple, ::Tuple{Face, Center, Center}) = begin
            #= none:44 =#
            #= none:44 =# @inbounds boundary_conditions[2]
        end
#= none:45 =#
#= none:45 =# @inline right_velocity_open_boundary_condition(boundary_conditions::Tuple, ::Tuple{Center, Face, Center}) = begin
            #= none:45 =#
            #= none:45 =# @inbounds boundary_conditions[2]
        end
#= none:46 =#
#= none:46 =# @inline right_velocity_open_boundary_condition(boundary_conditions::Tuple, ::Tuple{Center, Center, Face}) = begin
            #= none:46 =#
            #= none:46 =# @inbounds boundary_conditions[2]
        end
#= none:48 =#
#= none:48 =# @inline get_open_halo_filling_functions(loc) = begin
            #= none:48 =#
            (_no_fill!, _no_fill!)
        end
#= none:49 =#
#= none:49 =# @inline get_open_halo_filling_functions(::Tuple{Face, Center, Center}) = begin
            #= none:49 =#
            (_fill_west_and_east_open_halo!, fill_west_and_east_halo!)
        end
#= none:50 =#
#= none:50 =# @inline get_open_halo_filling_functions(::Tuple{Center, Face, Center}) = begin
            #= none:50 =#
            (_fill_south_and_north_open_halo!, fill_south_and_north_halo!)
        end
#= none:51 =#
#= none:51 =# @inline get_open_halo_filling_functions(::Tuple{Center, Center, Face}) = begin
            #= none:51 =#
            (_fill_bottom_and_top_open_halo!, fill_bottom_and_top_halo!)
        end
#= none:53 =#
#= none:53 =# @kernel _no_fill!(args...) = begin
            #= none:53 =#
            nothing
        end
#= none:55 =#
#= none:55 =# @inline fill_halo_size(field, ::typeof(_no_fill!), args...) = begin
            #= none:55 =#
            (0, 0)
        end
#= none:57 =#
#= none:57 =# @kernel function _fill_west_and_east_open_halo!(c, west_bc, east_bc, loc, grid, args)
        #= none:57 =#
        #= none:58 =#
        (j, k) = #= none:58 =# @index(Global, NTuple)
        #= none:59 =#
        _fill_west_open_halo!(j, k, grid, c, west_bc, loc, args...)
        #= none:60 =#
        _fill_east_open_halo!(j, k, grid, c, east_bc, loc, args...)
    end
#= none:63 =#
#= none:63 =# @kernel function _fill_south_and_north_open_halo!(c, south_bc, north_bc, loc, grid, args)
        #= none:63 =#
        #= none:64 =#
        (i, k) = #= none:64 =# @index(Global, NTuple)
        #= none:65 =#
        _fill_south_open_halo!(i, k, grid, c, south_bc, loc, args...)
        #= none:66 =#
        _fill_north_open_halo!(i, k, grid, c, north_bc, loc, args...)
    end
#= none:69 =#
#= none:69 =# @kernel function _fill_bottom_and_top_open_halo!(c, bottom_bc, top_bc, loc, grid, args)
        #= none:69 =#
        #= none:70 =#
        (i, j) = #= none:70 =# @index(Global, NTuple)
        #= none:71 =#
        _fill_bottom_open_halo!(i, j, grid, c, bottom_bc, loc, args...)
        #= none:72 =#
        _fill_top_open_halo!(i, j, grid, c, top_bc, loc, args...)
    end
#= none:77 =#
#= none:77 =# @inline _fill_west_open_halo!(j, k, grid, c, bc, loc, args...) = begin
            #= none:77 =#
            nothing
        end
#= none:78 =#
#= none:78 =# @inline _fill_east_open_halo!(j, k, grid, c, bc, loc, args...) = begin
            #= none:78 =#
            nothing
        end
#= none:79 =#
#= none:79 =# @inline _fill_south_open_halo!(i, k, grid, c, bc, loc, args...) = begin
            #= none:79 =#
            nothing
        end
#= none:80 =#
#= none:80 =# @inline _fill_north_open_halo!(i, k, grid, c, bc, loc, args...) = begin
            #= none:80 =#
            nothing
        end
#= none:81 =#
#= none:81 =# @inline _fill_bottom_open_halo!(i, j, grid, c, bc, loc, args...) = begin
            #= none:81 =#
            nothing
        end
#= none:82 =#
#= none:82 =# @inline _fill_top_open_halo!(i, j, grid, c, bc, loc, args...) = begin
            #= none:82 =#
            nothing
        end
#= none:86 =#
#= none:86 =# @inline _fill_west_open_halo!(j, k, grid, c, bc::OBC, loc, args...) = begin
            #= none:86 =#
            #= none:86 =# @inbounds c[1, j, k] = getbc(bc, j, k, grid, args...)
        end
#= none:87 =#
#= none:87 =# @inline _fill_east_open_halo!(j, k, grid, c, bc::OBC, loc, args...) = begin
            #= none:87 =#
            #= none:87 =# @inbounds c[grid.Nx + 1, j, k] = getbc(bc, j, k, grid, args...)
        end
#= none:88 =#
#= none:88 =# @inline _fill_south_open_halo!(i, k, grid, c, bc::OBC, loc, args...) = begin
            #= none:88 =#
            #= none:88 =# @inbounds c[i, 1, k] = getbc(bc, i, k, grid, args...)
        end
#= none:89 =#
#= none:89 =# @inline _fill_north_open_halo!(i, k, grid, c, bc::OBC, loc, args...) = begin
            #= none:89 =#
            #= none:89 =# @inbounds c[i, grid.Ny + 1, k] = getbc(bc, i, k, grid, args...)
        end
#= none:90 =#
#= none:90 =# @inline _fill_bottom_open_halo!(i, j, grid, c, bc::OBC, loc, args...) = begin
            #= none:90 =#
            #= none:90 =# @inbounds c[i, j, 1] = getbc(bc, i, j, grid, args...)
        end
#= none:91 =#
#= none:91 =# @inline _fill_top_open_halo!(i, j, grid, c, bc::OBC, loc, args...) = begin
            #= none:91 =#
            #= none:91 =# @inbounds c[i, j, grid.Nz + 1] = getbc(bc, i, j, grid, args...)
        end
#= none:95 =#
#= none:95 =# @inline _fill_west_halo!(j, k, grid, c, bc::OBC, loc, args...) = begin
            #= none:95 =#
            _fill_west_open_halo!(j, k, grid, c, bc, loc, args...)
        end
#= none:96 =#
#= none:96 =# @inline _fill_east_halo!(j, k, grid, c, bc::OBC, loc, args...) = begin
            #= none:96 =#
            _fill_east_open_halo!(j, k, grid, c, bc, loc, args...)
        end
#= none:97 =#
#= none:97 =# @inline _fill_south_halo!(i, k, grid, c, bc::OBC, loc, args...) = begin
            #= none:97 =#
            _fill_south_open_halo!(i, k, grid, c, bc, loc, args...)
        end
#= none:98 =#
#= none:98 =# @inline _fill_north_halo!(i, k, grid, c, bc::OBC, loc, args...) = begin
            #= none:98 =#
            _fill_north_open_halo!(i, k, grid, c, bc, loc, args...)
        end
#= none:99 =#
#= none:99 =# @inline _fill_bottom_halo!(i, j, grid, c, bc::OBC, loc, args...) = begin
            #= none:99 =#
            _fill_bottom_open_halo!(i, j, grid, c, bc, loc, args...)
        end
#= none:100 =#
#= none:100 =# @inline _fill_top_halo!(i, j, grid, c, bc::OBC, loc, args...) = begin
            #= none:100 =#
            _fill_top_open_halo!(i, j, grid, c, bc, loc, args...)
        end
#= none:104 =#
#= none:104 =# @inline _fill_west_halo!(j, k, grid, c, bc::OBC, ::Tuple{Face, <:Any, <:Any}, args...) = begin
            #= none:104 =#
            nothing
        end
#= none:105 =#
#= none:105 =# @inline _fill_east_halo!(j, k, grid, c, bc::OBC, ::Tuple{Face, <:Any, <:Any}, args...) = begin
            #= none:105 =#
            nothing
        end
#= none:106 =#
#= none:106 =# @inline _fill_south_halo!(i, k, grid, c, bc::OBC, ::Tuple{<:Any, Face, <:Any}, args...) = begin
            #= none:106 =#
            nothing
        end
#= none:107 =#
#= none:107 =# @inline _fill_north_halo!(i, k, grid, c, bc::OBC, ::Tuple{<:Any, Face, <:Any}, args...) = begin
            #= none:107 =#
            nothing
        end
#= none:108 =#
#= none:108 =# @inline _fill_bottom_halo!(i, j, grid, c, bc::OBC, ::Tuple{<:Any, <:Any, Face}, args...) = begin
            #= none:108 =#
            nothing
        end
#= none:109 =#
#= none:109 =# @inline _fill_top_halo!(i, j, grid, c, bc::OBC, ::Tuple{<:Any, <:Any, Face}, args...) = begin
            #= none:109 =#
            nothing
        end