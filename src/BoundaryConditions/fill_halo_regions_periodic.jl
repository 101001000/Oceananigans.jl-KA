
#= none:1 =#
using KernelAbstractions.Extras.LoopInfo: @unroll
#= none:7 =#
#= none:7 =# @inline parent_size_and_offset(c, dim1, dim2, size, offset) = begin
            #= none:7 =#
            (parent(c), size, fix_halo_offsets.(offset, c.offsets[[dim1, dim2]]))
        end
#= none:8 =#
#= none:8 =# @inline parent_size_and_offset(c, dim1, dim2, ::Symbol, offset) = begin
            #= none:8 =#
            (parent(c), (size(parent(c)))[[dim1, dim2]], (0, 0))
        end
#= none:10 =#
#= none:10 =# @inline function parent_size_and_offset(c::NTuple, dim1, dim2, ::Symbol, offset)
        #= none:10 =#
        #= none:11 =#
        p = parent.(c)
        #= none:12 =#
        p_size = (minimum([size(t, dim1) for t = p]), minimum([size(t, dim2) for t = p]))
        #= none:13 =#
        return (p, p_size, (0, 0))
    end
#= none:16 =#
#= none:16 =# @inline fix_halo_offsets(o, co) = begin
            #= none:16 =#
            if co > 0
                o - co
            else
                o
            end
        end
#= none:18 =#
function fill_west_and_east_halo!(c, ::PBCT, ::PBCT, size, offset, loc, arch, grid, args...; kw...)
    #= none:18 =#
    #= none:19 =#
    (c_parent, yz_size, offset) = parent_size_and_offset(c, 2, 3, size, offset)
    #= none:20 =#
    launch!(arch, grid, KernelParameters(yz_size, offset), fill_periodic_west_and_east_halo!, c_parent, Val(grid.Hx), grid.Nx; kw...)
    #= none:21 =#
    return nothing
end
#= none:24 =#
function fill_south_and_north_halo!(c, ::PBCT, ::PBCT, size, offset, loc, arch, grid, args...; kw...)
    #= none:24 =#
    #= none:25 =#
    (c_parent, xz_size, offset) = parent_size_and_offset(c, 1, 3, size, offset)
    #= none:26 =#
    launch!(arch, grid, KernelParameters(xz_size, offset), fill_periodic_south_and_north_halo!, c_parent, Val(grid.Hy), grid.Ny; kw...)
    #= none:27 =#
    return nothing
end
#= none:30 =#
function fill_bottom_and_top_halo!(c, ::PBCT, ::PBCT, size, offset, loc, arch, grid, args...; kw...)
    #= none:30 =#
    #= none:31 =#
    (c_parent, xy_size, offset) = parent_size_and_offset(c, 1, 2, size, offset)
    #= none:32 =#
    launch!(arch, grid, KernelParameters(xy_size, offset), fill_periodic_bottom_and_top_halo!, c_parent, Val(grid.Hz), grid.Nz; kw...)
    #= none:33 =#
    return nothing
end
#= none:40 =#
#= none:40 =# @kernel function fill_periodic_west_and_east_halo!(c, ::Val{H}, N) where H
        #= none:40 =#
        #= none:41 =#
        (j, k) = #= none:41 =# @index(Global, NTuple)
        #= none:42 =#
        #= none:42 =# @unroll for i = 1:H
                #= none:43 =#
                #= none:43 =# @inbounds begin
                        #= none:44 =#
                        c[i, j, k] = c[N + i, j, k]
                        #= none:45 =#
                        c[N + H + i, j, k] = c[H + i, j, k]
                    end
                #= none:47 =#
            end
    end
#= none:50 =#
#= none:50 =# @kernel function fill_periodic_south_and_north_halo!(c, ::Val{H}, N) where H
        #= none:50 =#
        #= none:51 =#
        (i, k) = #= none:51 =# @index(Global, NTuple)
        #= none:52 =#
        #= none:52 =# @unroll for j = 1:H
                #= none:53 =#
                #= none:53 =# @inbounds begin
                        #= none:54 =#
                        c[i, j, k] = c[i, N + j, k]
                        #= none:55 =#
                        c[i, N + H + j, k] = c[i, H + j, k]
                    end
                #= none:57 =#
            end
    end
#= none:60 =#
#= none:60 =# @kernel function fill_periodic_bottom_and_top_halo!(c, ::Val{H}, N) where H
        #= none:60 =#
        #= none:61 =#
        (i, j) = #= none:61 =# @index(Global, NTuple)
        #= none:62 =#
        #= none:62 =# @unroll for k = 1:H
                #= none:63 =#
                #= none:63 =# @inbounds begin
                        #= none:64 =#
                        c[i, j, k] = c[i, j, N + k]
                        #= none:65 =#
                        c[i, j, N + H + k] = c[i, j, H + k]
                    end
                #= none:67 =#
            end
    end
#= none:74 =#
#= none:74 =# @kernel function fill_periodic_west_and_east_halo!(c::NTuple{M}, ::Val{H}, N) where {M, H}
        #= none:74 =#
        #= none:75 =#
        (j, k) = #= none:75 =# @index(Global, NTuple)
        #= none:76 =#
        #= none:76 =# @unroll for n = 1:M
                #= none:77 =#
                #= none:77 =# @unroll for i = 1:H
                        #= none:78 =#
                        #= none:78 =# @inbounds begin
                                #= none:79 =#
                                (c[n])[i, j, k] = (c[n])[N + i, j, k]
                                #= none:80 =#
                                (c[n])[N + H + i, j, k] = (c[n])[H + i, j, k]
                            end
                        #= none:82 =#
                    end
                #= none:83 =#
            end
    end
#= none:86 =#
#= none:86 =# @kernel function fill_periodic_south_and_north_halo!(c::NTuple{M}, ::Val{H}, N) where {M, H}
        #= none:86 =#
        #= none:87 =#
        (i, k) = #= none:87 =# @index(Global, NTuple)
        #= none:88 =#
        #= none:88 =# @unroll for n = 1:M
                #= none:89 =#
                #= none:89 =# @unroll for j = 1:H
                        #= none:90 =#
                        #= none:90 =# @inbounds begin
                                #= none:91 =#
                                (c[n])[i, j, k] = (c[n])[i, N + j, k]
                                #= none:92 =#
                                (c[n])[i, N + H + j, k] = (c[n])[i, H + j, k]
                            end
                        #= none:94 =#
                    end
                #= none:95 =#
            end
    end
#= none:98 =#
#= none:98 =# @kernel function fill_periodic_bottom_and_top_halo!(c::NTuple{M}, ::Val{H}, N) where {M, H}
        #= none:98 =#
        #= none:99 =#
        (i, j) = #= none:99 =# @index(Global, NTuple)
        #= none:100 =#
        #= none:100 =# @unroll for n = 1:M
                #= none:101 =#
                #= none:101 =# @unroll for k = 1:H
                        #= none:102 =#
                        #= none:102 =# @inbounds begin
                                #= none:103 =#
                                (c[n])[i, j, k] = (c[n])[i, j, N + k]
                                #= none:104 =#
                                (c[n])[i, j, N + H + k] = (c[n])[i, j, H + k]
                            end
                        #= none:106 =#
                    end
                #= none:107 =#
            end
    end
#= none:114 =#
fill_west_halo!(c, ::PBCT, args...; kwargs...) = begin
        #= none:114 =#
        throw(ArgumentError("Periodic boundary conditions must be applied to both sides"))
    end
#= none:115 =#
fill_east_halo!(c, ::PBCT, args...; kwargs...) = begin
        #= none:115 =#
        throw(ArgumentError("Periodic boundary conditions must be applied to both sides"))
    end
#= none:116 =#
fill_south_halo!(c, ::PBCT, args...; kwargs...) = begin
        #= none:116 =#
        throw(ArgumentError("Periodic boundary conditions must be applied to both sides"))
    end
#= none:117 =#
fill_north_halo!(c, ::PBCT, args...; kwargs...) = begin
        #= none:117 =#
        throw(ArgumentError("Periodic boundary conditions must be applied to both sides"))
    end
#= none:118 =#
fill_bottom_halo!(c, ::PBCT, args...; kwargs...) = begin
        #= none:118 =#
        throw(ArgumentError("Periodic boundary conditions must be applied to both sides"))
    end
#= none:119 =#
fill_top_halo!(c, ::PBCT, args...; kwargs...) = begin
        #= none:119 =#
        throw(ArgumentError("Periodic boundary conditions must be applied to both sides"))
    end