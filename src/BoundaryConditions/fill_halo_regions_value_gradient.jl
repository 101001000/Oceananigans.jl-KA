
#= none:1 =#
using Oceananigans.Operators: Δx, Δy, Δz
#= none:7 =#
#= none:7 =# @inline linearly_extrapolate(c₀, ∇c, Δ) = begin
            #= none:7 =#
            c₀ + ∇c * Δ
        end
#= none:9 =#
#= none:9 =# @inline left_gradient(bc::GBC, c¹, Δ, i, j, args...) = begin
            #= none:9 =#
            getbc(bc, i, j, args...)
        end
#= none:10 =#
#= none:10 =# @inline right_gradient(bc::GBC, cᴺ, Δ, i, j, args...) = begin
            #= none:10 =#
            getbc(bc, i, j, args...)
        end
#= none:12 =#
#= none:12 =# @inline left_gradient(bc::VBC, c¹, Δ, i, j, args...) = begin
            #= none:12 =#
            (c¹ - getbc(bc, i, j, args...)) / (Δ / 2)
        end
#= none:13 =#
#= none:13 =# @inline right_gradient(bc::VBC, cᴺ, Δ, i, j, args...) = begin
            #= none:13 =#
            (getbc(bc, i, j, args...) - cᴺ) / (Δ / 2)
        end
#= none:15 =#
#= none:15 =# @inline function _fill_west_halo!(j, k, grid, c, bc::Union{VBC, GBC}, loc, args...)
        #= none:15 =#
        #= none:19 =#
        iᴵ = 1
        #= none:20 =#
        iᴮ = 1
        #= none:21 =#
        iᴴ = 0
        #= none:23 =#
        (LX, LY, LZ) = loc
        #= none:24 =#
        Δ = Δx(iᴮ, j, k, grid, flip(LX), LY, LZ)
        #= none:25 =#
        #= none:25 =# @inbounds ∇c = left_gradient(bc, c[iᴵ, j, k], Δ, j, k, grid, args...)
        #= none:26 =#
        #= none:26 =# @inbounds c[iᴴ, j, k] = linearly_extrapolate(c[iᴵ, j, k], ∇c, -Δ)
    end
#= none:29 =#
#= none:29 =# @inline function _fill_east_halo!(j, k, grid, c, bc::Union{VBC, GBC}, loc, args...)
        #= none:29 =#
        #= none:32 =#
        iᴴ = grid.Nx + 1
        #= none:33 =#
        iᴮ = grid.Nx + 1
        #= none:34 =#
        iᴵ = grid.Nx
        #= none:38 =#
        (LX, LY, LZ) = loc
        #= none:39 =#
        Δ = Δx(iᴮ, j, k, grid, flip(LX), LY, LZ)
        #= none:40 =#
        #= none:40 =# @inbounds ∇c = right_gradient(bc, c[iᴵ, j, k], Δ, j, k, grid, args...)
        #= none:41 =#
        #= none:41 =# @inbounds c[iᴴ, j, k] = linearly_extrapolate(c[iᴵ, j, k], ∇c, Δ)
    end
#= none:44 =#
#= none:44 =# @inline function _fill_south_halo!(i, k, grid, c, bc::Union{VBC, GBC}, loc, args...)
        #= none:44 =#
        #= none:48 =#
        jᴵ = 1
        #= none:49 =#
        jᴮ = 1
        #= none:50 =#
        jᴴ = 0
        #= none:52 =#
        (LX, LY, LZ) = loc
        #= none:53 =#
        Δ = Δy(i, jᴮ, k, grid, LX, flip(LY), LZ)
        #= none:54 =#
        #= none:54 =# @inbounds ∇c = left_gradient(bc, c[i, jᴵ, k], Δ, i, k, grid, args...)
        #= none:55 =#
        #= none:55 =# @inbounds c[i, jᴴ, k] = linearly_extrapolate(c[i, jᴵ, k], ∇c, -Δ)
    end
#= none:58 =#
#= none:58 =# @inline function _fill_north_halo!(i, k, grid, c, bc::Union{VBC, GBC}, loc, args...)
        #= none:58 =#
        #= none:61 =#
        jᴴ = grid.Ny + 1
        #= none:62 =#
        jᴮ = grid.Ny + 1
        #= none:63 =#
        jᴵ = grid.Ny
        #= none:67 =#
        (LX, LY, LZ) = loc
        #= none:68 =#
        Δ = Δy(i, jᴮ, k, grid, LX, flip(LY), LZ)
        #= none:69 =#
        #= none:69 =# @inbounds ∇c = right_gradient(bc, c[i, jᴵ, k], Δ, i, k, grid, args...)
        #= none:70 =#
        #= none:70 =# @inbounds c[i, jᴴ, k] = linearly_extrapolate(c[i, jᴵ, k], ∇c, Δ)
    end
#= none:73 =#
#= none:73 =# @inline function _fill_bottom_halo!(i, j, grid, c, bc::Union{VBC, GBC}, loc, args...)
        #= none:73 =#
        #= none:77 =#
        kᴵ = 1
        #= none:78 =#
        kᴮ = 1
        #= none:79 =#
        kᴴ = 0
        #= none:81 =#
        (LX, LY, LZ) = loc
        #= none:82 =#
        Δ = Δz(i, j, kᴮ, grid, LX, LY, flip(LZ))
        #= none:83 =#
        #= none:83 =# @inbounds ∇c = left_gradient(bc, c[i, j, kᴵ], Δ, i, j, grid, args...)
        #= none:84 =#
        #= none:84 =# @inbounds c[i, j, kᴴ] = linearly_extrapolate(c[i, j, kᴵ], ∇c, -Δ)
    end
#= none:87 =#
#= none:87 =# @inline function _fill_top_halo!(i, j, grid, c, bc::Union{VBC, GBC}, loc, args...)
        #= none:87 =#
        #= none:90 =#
        kᴴ = grid.Nz + 1
        #= none:91 =#
        kᴮ = grid.Nz + 1
        #= none:92 =#
        kᴵ = grid.Nz
        #= none:95 =#
        (LX, LY, LZ) = loc
        #= none:96 =#
        Δ = Δz(i, j, kᴮ, grid, LX, LY, flip(LZ))
        #= none:97 =#
        #= none:97 =# @inbounds ∇c = right_gradient(bc, c[i, j, kᴵ], Δ, i, j, grid, args...)
        #= none:98 =#
        #= none:98 =# @inbounds c[i, j, kᴴ] = linearly_extrapolate(c[i, j, kᴵ], ∇c, Δ)
    end