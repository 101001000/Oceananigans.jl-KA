
#= none:1 =#
using Oceananigans.Grids: Flat
#= none:7 =#
#= none:7 =# @inline ℑxᶜᵃᵃ(i, j, k, u) = begin
            #= none:7 =#
            #= none:7 =# @inbounds (u[i, j, k] + u[i + 1, j, k]) / 2
        end
#= none:8 =#
#= none:8 =# @inline ℑxᶠᵃᵃ(i, j, k, c) = begin
            #= none:8 =#
            #= none:8 =# @inbounds (c[i - 1, j, k] + c[i, j, k]) / 2
        end
#= none:10 =#
#= none:10 =# @inline ℑyᵃᶜᵃ(i, j, k, v) = begin
            #= none:10 =#
            #= none:10 =# @inbounds (v[i, j, k] + v[i, j + 1, k]) / 2
        end
#= none:11 =#
#= none:11 =# @inline ℑyᵃᶠᵃ(i, j, k, c) = begin
            #= none:11 =#
            #= none:11 =# @inbounds (c[i, j - 1, k] + c[i, j, k]) / 2
        end
#= none:13 =#
#= none:13 =# @inline ℑzᵃᵃᶜ(i, j, k, w) = begin
            #= none:13 =#
            #= none:13 =# @inbounds (w[i, j, k] + w[i, j, k + 1]) / 2
        end
#= none:14 =#
#= none:14 =# @inline ℑzᵃᵃᶠ(i, j, k, c) = begin
            #= none:14 =#
            #= none:14 =# @inbounds (c[i, j, k - 1] + c[i, j, k]) / 2
        end
#= none:20 =#
#= none:20 =# @inline (ℑxᶜᵃᵃ(i, j, k, grid::AG{FT}, u) where FT) = begin
            #= none:20 =#
            #= none:20 =# @inbounds FT(0.5) * (u[i, j, k] + u[i + 1, j, k])
        end
#= none:21 =#
#= none:21 =# @inline (ℑxᶠᵃᵃ(i, j, k, grid::AG{FT}, c) where FT) = begin
            #= none:21 =#
            #= none:21 =# @inbounds FT(0.5) * (c[i - 1, j, k] + c[i, j, k])
        end
#= none:23 =#
#= none:23 =# @inline (ℑyᵃᶜᵃ(i, j, k, grid::AG{FT}, v) where FT) = begin
            #= none:23 =#
            #= none:23 =# @inbounds FT(0.5) * (v[i, j, k] + v[i, j + 1, k])
        end
#= none:24 =#
#= none:24 =# @inline (ℑyᵃᶠᵃ(i, j, k, grid::AG{FT}, c) where FT) = begin
            #= none:24 =#
            #= none:24 =# @inbounds FT(0.5) * (c[i, j - 1, k] + c[i, j, k])
        end
#= none:26 =#
#= none:26 =# @inline (ℑzᵃᵃᶜ(i, j, k, grid::AG{FT}, w) where FT) = begin
            #= none:26 =#
            #= none:26 =# @inbounds FT(0.5) * (w[i, j, k] + w[i, j, k + 1])
        end
#= none:27 =#
#= none:27 =# @inline (ℑzᵃᵃᶠ(i, j, k, grid::AG{FT}, c) where FT) = begin
            #= none:27 =#
            #= none:27 =# @inbounds FT(0.5) * (c[i, j, k - 1] + c[i, j, k])
        end
#= none:33 =#
#= none:33 =# @inline (ℑxᶜᵃᵃ(i, j, k, grid::AG{FT}, f::F, args...) where {FT, F <: Function}) = begin
            #= none:33 =#
            FT(0.5) * (f(i, j, k, grid, args...) + f(i + 1, j, k, grid, args...))
        end
#= none:34 =#
#= none:34 =# @inline (ℑxᶠᵃᵃ(i, j, k, grid::AG{FT}, f::F, args...) where {FT, F <: Function}) = begin
            #= none:34 =#
            FT(0.5) * (f(i - 1, j, k, grid, args...) + f(i, j, k, grid, args...))
        end
#= none:36 =#
#= none:36 =# @inline (ℑyᵃᶜᵃ(i, j, k, grid::AG{FT}, f::F, args...) where {FT, F <: Function}) = begin
            #= none:36 =#
            FT(0.5) * (f(i, j, k, grid, args...) + f(i, j + 1, k, grid, args...))
        end
#= none:37 =#
#= none:37 =# @inline (ℑyᵃᶠᵃ(i, j, k, grid::AG{FT}, f::F, args...) where {FT, F <: Function}) = begin
            #= none:37 =#
            FT(0.5) * (f(i, j - 1, k, grid, args...) + f(i, j, k, grid, args...))
        end
#= none:39 =#
#= none:39 =# @inline (ℑzᵃᵃᶜ(i, j, k, grid::AG{FT}, f::F, args...) where {FT, F <: Function}) = begin
            #= none:39 =#
            FT(0.5) * (f(i, j, k, grid, args...) + f(i, j, k + 1, grid, args...))
        end
#= none:40 =#
#= none:40 =# @inline (ℑzᵃᵃᶠ(i, j, k, grid::AG{FT}, f::F, args...) where {FT, F <: Function}) = begin
            #= none:40 =#
            FT(0.5) * (f(i, j, k - 1, grid, args...) + f(i, j, k, grid, args...))
        end
#= none:46 =#
#= none:46 =# @inline ℑxᶠᵃᵃ(i, j, k, grid::AG, f::Number, args...) = begin
            #= none:46 =#
            f
        end
#= none:47 =#
#= none:47 =# @inline ℑxᶜᵃᵃ(i, j, k, grid::AG, f::Number, args...) = begin
            #= none:47 =#
            f
        end
#= none:48 =#
#= none:48 =# @inline ℑyᵃᶠᵃ(i, j, k, grid::AG, f::Number, args...) = begin
            #= none:48 =#
            f
        end
#= none:49 =#
#= none:49 =# @inline ℑyᵃᶜᵃ(i, j, k, grid::AG, f::Number, args...) = begin
            #= none:49 =#
            f
        end
#= none:50 =#
#= none:50 =# @inline ℑzᵃᵃᶠ(i, j, k, grid::AG, f::Number, args...) = begin
            #= none:50 =#
            f
        end
#= none:51 =#
#= none:51 =# @inline ℑzᵃᵃᶜ(i, j, k, grid::AG, f::Number, args...) = begin
            #= none:51 =#
            f
        end
#= none:57 =#
#= none:57 =# @inline ℑxyᶜᶜᵃ(i, j, k, grid, f, args...) = begin
            #= none:57 =#
            ℑyᵃᶜᵃ(i, j, k, grid, ℑxᶜᵃᵃ, f, args...)
        end
#= none:58 =#
#= none:58 =# @inline ℑxyᶠᶜᵃ(i, j, k, grid, f, args...) = begin
            #= none:58 =#
            ℑyᵃᶜᵃ(i, j, k, grid, ℑxᶠᵃᵃ, f, args...)
        end
#= none:59 =#
#= none:59 =# @inline ℑxyᶠᶠᵃ(i, j, k, grid, f, args...) = begin
            #= none:59 =#
            ℑyᵃᶠᵃ(i, j, k, grid, ℑxᶠᵃᵃ, f, args...)
        end
#= none:60 =#
#= none:60 =# @inline ℑxyᶜᶠᵃ(i, j, k, grid, f, args...) = begin
            #= none:60 =#
            ℑyᵃᶠᵃ(i, j, k, grid, ℑxᶜᵃᵃ, f, args...)
        end
#= none:61 =#
#= none:61 =# @inline ℑxzᶜᵃᶜ(i, j, k, grid, f, args...) = begin
            #= none:61 =#
            ℑzᵃᵃᶜ(i, j, k, grid, ℑxᶜᵃᵃ, f, args...)
        end
#= none:62 =#
#= none:62 =# @inline ℑxzᶠᵃᶜ(i, j, k, grid, f, args...) = begin
            #= none:62 =#
            ℑzᵃᵃᶜ(i, j, k, grid, ℑxᶠᵃᵃ, f, args...)
        end
#= none:63 =#
#= none:63 =# @inline ℑxzᶠᵃᶠ(i, j, k, grid, f, args...) = begin
            #= none:63 =#
            ℑzᵃᵃᶠ(i, j, k, grid, ℑxᶠᵃᵃ, f, args...)
        end
#= none:64 =#
#= none:64 =# @inline ℑxzᶜᵃᶠ(i, j, k, grid, f, args...) = begin
            #= none:64 =#
            ℑzᵃᵃᶠ(i, j, k, grid, ℑxᶜᵃᵃ, f, args...)
        end
#= none:65 =#
#= none:65 =# @inline ℑyzᵃᶜᶜ(i, j, k, grid, f, args...) = begin
            #= none:65 =#
            ℑzᵃᵃᶜ(i, j, k, grid, ℑyᵃᶜᵃ, f, args...)
        end
#= none:66 =#
#= none:66 =# @inline ℑyzᵃᶠᶜ(i, j, k, grid, f, args...) = begin
            #= none:66 =#
            ℑzᵃᵃᶜ(i, j, k, grid, ℑyᵃᶠᵃ, f, args...)
        end
#= none:67 =#
#= none:67 =# @inline ℑyzᵃᶠᶠ(i, j, k, grid, f, args...) = begin
            #= none:67 =#
            ℑzᵃᵃᶠ(i, j, k, grid, ℑyᵃᶠᵃ, f, args...)
        end
#= none:68 =#
#= none:68 =# @inline ℑyzᵃᶜᶠ(i, j, k, grid, f, args...) = begin
            #= none:68 =#
            ℑzᵃᵃᶠ(i, j, k, grid, ℑyᵃᶜᵃ, f, args...)
        end
#= none:74 =#
#= none:74 =# @inline ℑxyzᶜᶜᶜ(i, j, k, grid, f, args...) = begin
            #= none:74 =#
            ℑxᶜᵃᵃ(i, j, k, grid, ℑyᵃᶜᵃ, ℑzᵃᵃᶜ, f, args...)
        end
#= none:75 =#
#= none:75 =# @inline ℑxyzᶠᶠᶠ(i, j, k, grid, f, args...) = begin
            #= none:75 =#
            ℑxᶠᵃᵃ(i, j, k, grid, ℑyᵃᶠᵃ, ℑzᵃᵃᶠ, f, args...)
        end
#= none:77 =#
#= none:77 =# @inline ℑxyzᶜᶜᶠ(i, j, k, grid, f, args...) = begin
            #= none:77 =#
            ℑxᶜᵃᵃ(i, j, k, grid, ℑyᵃᶜᵃ, ℑzᵃᵃᶠ, f, args...)
        end
#= none:78 =#
#= none:78 =# @inline ℑxyzᶜᶠᶜ(i, j, k, grid, f, args...) = begin
            #= none:78 =#
            ℑxᶜᵃᵃ(i, j, k, grid, ℑyᵃᶠᵃ, ℑzᵃᵃᶜ, f, args...)
        end
#= none:79 =#
#= none:79 =# @inline ℑxyzᶠᶜᶜ(i, j, k, grid, f, args...) = begin
            #= none:79 =#
            ℑxᶠᵃᵃ(i, j, k, grid, ℑyᵃᶜᵃ, ℑzᵃᵃᶜ, f, args...)
        end
#= none:81 =#
#= none:81 =# @inline ℑxyzᶜᶠᶠ(i, j, k, grid, f, args...) = begin
            #= none:81 =#
            ℑxᶜᵃᵃ(i, j, k, grid, ℑyᵃᶠᵃ, ℑzᵃᵃᶠ, f, args...)
        end
#= none:82 =#
#= none:82 =# @inline ℑxyzᶠᶜᶠ(i, j, k, grid, f, args...) = begin
            #= none:82 =#
            ℑxᶠᵃᵃ(i, j, k, grid, ℑyᵃᶜᵃ, ℑzᵃᵃᶠ, f, args...)
        end
#= none:83 =#
#= none:83 =# @inline ℑxyzᶠᶠᶜ(i, j, k, grid, f, args...) = begin
            #= none:83 =#
            ℑxᶠᵃᵃ(i, j, k, grid, ℑyᵃᶠᵃ, ℑzᵃᵃᶜ, f, args...)
        end
#= none:89 =#
#= none:89 =# @inline (ℑxᶠᵃᵃ(i, j, k, grid::AG{FT}, c, args...) where FT) = begin
            #= none:89 =#
            #= none:89 =# @inbounds FT(0.5) * (c[i - 1, j, k] + c[i, j, k])
        end
#= none:90 =#
#= none:90 =# @inline (ℑyᵃᶠᵃ(i, j, k, grid::AG{FT}, c, args...) where FT) = begin
            #= none:90 =#
            #= none:90 =# @inbounds FT(0.5) * (c[i, j - 1, k] + c[i, j, k])
        end
#= none:91 =#
#= none:91 =# @inline (ℑzᵃᵃᶠ(i, j, k, grid::AG{FT}, c, args...) where FT) = begin
            #= none:91 =#
            #= none:91 =# @inbounds FT(0.5) * (c[i, j, k - 1] + c[i, j, k])
        end
#= none:97 =#
using Oceananigans.Grids: XFlatGrid, YFlatGrid, ZFlatGrid
#= none:99 =#
#= none:99 =# @inline ℑxᶜᵃᵃ(i, j, k, grid::XFlatGrid, u) = begin
            #= none:99 =#
            #= none:99 =# @inbounds u[i, j, k]
        end
#= none:100 =#
#= none:100 =# @inline ℑxᶠᵃᵃ(i, j, k, grid::XFlatGrid, c) = begin
            #= none:100 =#
            #= none:100 =# @inbounds c[i, j, k]
        end
#= none:102 =#
#= none:102 =# @inline ℑyᵃᶜᵃ(i, j, k, grid::YFlatGrid, w) = begin
            #= none:102 =#
            #= none:102 =# @inbounds w[i, j, k]
        end
#= none:103 =#
#= none:103 =# @inline ℑyᵃᶠᵃ(i, j, k, grid::YFlatGrid, c) = begin
            #= none:103 =#
            #= none:103 =# @inbounds c[i, j, k]
        end
#= none:105 =#
#= none:105 =# @inline ℑzᵃᵃᶜ(i, j, k, grid::ZFlatGrid, w) = begin
            #= none:105 =#
            #= none:105 =# @inbounds w[i, j, k]
        end
#= none:106 =#
#= none:106 =# @inline ℑzᵃᵃᶠ(i, j, k, grid::ZFlatGrid, c) = begin
            #= none:106 =#
            #= none:106 =# @inbounds c[i, j, k]
        end
#= none:108 =#
#= none:108 =# @inline (ℑxᶜᵃᵃ(i, j, k, grid::XFlatGrid, f::F, args...) where F <: Function) = begin
            #= none:108 =#
            f(i, j, k, grid, args...)
        end
#= none:109 =#
#= none:109 =# @inline (ℑxᶠᵃᵃ(i, j, k, grid::XFlatGrid, f::F, args...) where F <: Function) = begin
            #= none:109 =#
            f(i, j, k, grid, args...)
        end
#= none:111 =#
#= none:111 =# @inline (ℑyᵃᶜᵃ(i, j, k, grid::YFlatGrid, f::F, args...) where F <: Function) = begin
            #= none:111 =#
            f(i, j, k, grid, args...)
        end
#= none:112 =#
#= none:112 =# @inline (ℑyᵃᶠᵃ(i, j, k, grid::YFlatGrid, f::F, args...) where F <: Function) = begin
            #= none:112 =#
            f(i, j, k, grid, args...)
        end
#= none:114 =#
#= none:114 =# @inline (ℑzᵃᵃᶜ(i, j, k, grid::ZFlatGrid, f::F, args...) where F <: Function) = begin
            #= none:114 =#
            f(i, j, k, grid, args...)
        end
#= none:115 =#
#= none:115 =# @inline (ℑzᵃᵃᶠ(i, j, k, grid::ZFlatGrid, f::F, args...) where F <: Function) = begin
            #= none:115 =#
            f(i, j, k, grid, args...)
        end