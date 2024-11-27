
#= none:1 =#
using Oceananigans.Grids: Flat
#= none:7 =#
#= none:7 =# @inline δxᶜᵃᵃ(i, j, k, grid, u) = begin
            #= none:7 =#
            #= none:7 =# @inbounds u[i + 1, j, k] - u[i, j, k]
        end
#= none:8 =#
#= none:8 =# @inline δxᶠᵃᵃ(i, j, k, grid, c) = begin
            #= none:8 =#
            #= none:8 =# @inbounds c[i, j, k] - c[i - 1, j, k]
        end
#= none:10 =#
#= none:10 =# @inline δyᵃᶜᵃ(i, j, k, grid, v) = begin
            #= none:10 =#
            #= none:10 =# @inbounds v[i, j + 1, k] - v[i, j, k]
        end
#= none:11 =#
#= none:11 =# @inline δyᵃᶠᵃ(i, j, k, grid, c) = begin
            #= none:11 =#
            #= none:11 =# @inbounds c[i, j, k] - c[i, j - 1, k]
        end
#= none:13 =#
#= none:13 =# @inline δzᵃᵃᶜ(i, j, k, grid, w) = begin
            #= none:13 =#
            #= none:13 =# @inbounds w[i, j, k + 1] - w[i, j, k]
        end
#= none:14 =#
#= none:14 =# @inline δzᵃᵃᶠ(i, j, k, grid, c) = begin
            #= none:14 =#
            #= none:14 =# @inbounds c[i, j, k] - c[i, j, k - 1]
        end
#= none:20 =#
#= none:20 =# @inline (δxᶜᵃᵃ(i, j, k, grid, f::F, args...) where F <: Function) = begin
            #= none:20 =#
            f(i + 1, j, k, grid, args...) - f(i, j, k, grid, args...)
        end
#= none:21 =#
#= none:21 =# @inline (δxᶠᵃᵃ(i, j, k, grid, f::F, args...) where F <: Function) = begin
            #= none:21 =#
            f(i, j, k, grid, args...) - f(i - 1, j, k, grid, args...)
        end
#= none:23 =#
#= none:23 =# @inline (δyᵃᶜᵃ(i, j, k, grid, f::F, args...) where F <: Function) = begin
            #= none:23 =#
            f(i, j + 1, k, grid, args...) - f(i, j, k, grid, args...)
        end
#= none:24 =#
#= none:24 =# @inline (δyᵃᶠᵃ(i, j, k, grid, f::F, args...) where F <: Function) = begin
            #= none:24 =#
            f(i, j, k, grid, args...) - f(i, j - 1, k, grid, args...)
        end
#= none:26 =#
#= none:26 =# @inline (δzᵃᵃᶜ(i, j, k, grid, f::F, args...) where F <: Function) = begin
            #= none:26 =#
            f(i, j, k + 1, grid, args...) - f(i, j, k, grid, args...)
        end
#= none:27 =#
#= none:27 =# @inline (δzᵃᵃᶠ(i, j, k, grid, f::F, args...) where F <: Function) = begin
            #= none:27 =#
            f(i, j, k, grid, args...) - f(i, j, k - 1, grid, args...)
        end
#= none:33 =#
#= none:33 =# @inline (δxᶜᵃᵃ(i, j, k, grid::AG{FT, Flat, TY, TZ}, u) where {FT, TY, TZ}) = begin
            #= none:33 =#
            zero(FT)
        end
#= none:34 =#
#= none:34 =# @inline (δxᶠᵃᵃ(i, j, k, grid::AG{FT, Flat, TY, TZ}, c) where {FT, TY, TZ}) = begin
            #= none:34 =#
            zero(FT)
        end
#= none:36 =#
#= none:36 =# @inline (δyᵃᶜᵃ(i, j, k, grid::AG{FT, TX, Flat, TZ}, v) where {FT, TX, TZ}) = begin
            #= none:36 =#
            zero(FT)
        end
#= none:37 =#
#= none:37 =# @inline (δyᵃᶠᵃ(i, j, k, grid::AG{FT, TX, Flat, TZ}, c) where {FT, TX, TZ}) = begin
            #= none:37 =#
            zero(FT)
        end
#= none:39 =#
#= none:39 =# @inline (δzᵃᵃᶜ(i, j, k, grid::AG{FT, TX, TY, Flat}, w) where {FT, TX, TY}) = begin
            #= none:39 =#
            zero(FT)
        end
#= none:40 =#
#= none:40 =# @inline (δzᵃᵃᶠ(i, j, k, grid::AG{FT, TX, TY, Flat}, c) where {FT, TX, TY}) = begin
            #= none:40 =#
            zero(FT)
        end
#= none:42 =#
#= none:42 =# @inline (δxᶜᵃᵃ(i, j, k, grid::AG{FT, Flat, TY, TZ}, f::F, args...) where {FT, TY, TZ, F <: Function}) = begin
            #= none:42 =#
            zero(FT)
        end
#= none:43 =#
#= none:43 =# @inline (δxᶠᵃᵃ(i, j, k, grid::AG{FT, Flat, TY, TZ}, f::F, args...) where {FT, TY, TZ, F <: Function}) = begin
            #= none:43 =#
            zero(FT)
        end
#= none:45 =#
#= none:45 =# @inline (δyᵃᶜᵃ(i, j, k, grid::AG{FT, TX, Flat, TZ}, f::F, args...) where {FT, TX, TZ, F <: Function}) = begin
            #= none:45 =#
            zero(FT)
        end
#= none:46 =#
#= none:46 =# @inline (δyᵃᶠᵃ(i, j, k, grid::AG{FT, TX, Flat, TZ}, f::F, args...) where {FT, TX, TZ, F <: Function}) = begin
            #= none:46 =#
            zero(FT)
        end
#= none:48 =#
#= none:48 =# @inline (δzᵃᵃᶜ(i, j, k, grid::AG{FT, TX, TY, Flat}, f::F, args...) where {FT, TX, TY, F <: Function}) = begin
            #= none:48 =#
            zero(FT)
        end
#= none:49 =#
#= none:49 =# @inline (δzᵃᵃᶠ(i, j, k, grid::AG{FT, TX, TY, Flat}, f::F, args...) where {FT, TX, TY, F <: Function}) = begin
            #= none:49 =#
            zero(FT)
        end
#= none:55 =#
for ℓx = (:ᶜ, :ᶠ), ℓy = (:ᶜ, :ᶠ), ℓz = (:ᶜ, :ᶠ)
    #= none:56 =#
    δx = Symbol(:δx, ℓx, ℓy, ℓz)
    #= none:57 =#
    δy = Symbol(:δy, ℓx, ℓy, ℓz)
    #= none:58 =#
    δz = Symbol(:δz, ℓx, ℓy, ℓz)
    #= none:60 =#
    δxᵃ = Symbol(:δx, ℓx, :ᵃ, :ᵃ)
    #= none:61 =#
    δyᵃ = Symbol(:δy, :ᵃ, ℓy, :ᵃ)
    #= none:62 =#
    δzᵃ = Symbol(:δz, :ᵃ, :ᵃ, ℓz)
    #= none:64 =#
    #= none:64 =# @eval begin
            #= none:65 =#
            #= none:65 =# @inline $δx(i, j, k, grid, f::Function, args...) = begin
                        #= none:65 =#
                        $δxᵃ(i, j, k, grid, f, args...)
                    end
            #= none:66 =#
            #= none:66 =# @inline $δy(i, j, k, grid, f::Function, args...) = begin
                        #= none:66 =#
                        $δyᵃ(i, j, k, grid, f, args...)
                    end
            #= none:67 =#
            #= none:67 =# @inline $δz(i, j, k, grid, f::Function, args...) = begin
                        #= none:67 =#
                        $δzᵃ(i, j, k, grid, f, args...)
                    end
            #= none:69 =#
            #= none:69 =# @inline $δx(i, j, k, grid, c) = begin
                        #= none:69 =#
                        $δxᵃ(i, j, k, grid, c)
                    end
            #= none:70 =#
            #= none:70 =# @inline $δy(i, j, k, grid, c) = begin
                        #= none:70 =#
                        $δyᵃ(i, j, k, grid, c)
                    end
            #= none:71 =#
            #= none:71 =# @inline $δz(i, j, k, grid, c) = begin
                        #= none:71 =#
                        $δzᵃ(i, j, k, grid, c)
                    end
        end
    #= none:73 =#
end