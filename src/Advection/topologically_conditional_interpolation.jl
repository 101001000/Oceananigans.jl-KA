
#= none:13 =#
using Oceananigans.Grids: AbstractUnderlyingGrid, Bounded
#= none:15 =#
const AUG = AbstractUnderlyingGrid
#= none:18 =#
const AUGX = AUG{<:Any, <:Bounded}
#= none:19 =#
const AUGY = AUG{<:Any, <:Any, <:Bounded}
#= none:20 =#
const AUGZ = AUG{<:Any, <:Any, <:Any, <:Bounded}
#= none:21 =#
const AUGXY = AUG{<:Any, <:Bounded, <:Bounded}
#= none:22 =#
const AUGXZ = AUG{<:Any, <:Bounded, <:Any, <:Bounded}
#= none:23 =#
const AUGYZ = AUG{<:Any, <:Any, <:Bounded, <:Bounded}
#= none:24 =#
const AUGXYZ = AUG{<:Any, <:Bounded, <:Bounded, <:Bounded}
#= none:29 =#
for dir = (:x, :y, :z)
    #= none:30 =#
    outside_symmetric_haloᶠ = Symbol(:outside_symmetric_halo_, dir, :ᶠ)
    #= none:31 =#
    outside_symmetric_haloᶜ = Symbol(:outside_symmetric_halo_, dir, :ᶜ)
    #= none:32 =#
    outside_biased_haloᶠ = Symbol(:outside_biased_halo_, dir, :ᶠ)
    #= none:33 =#
    outside_biased_haloᶜ = Symbol(:outside_biased_halo_, dir, :ᶜ)
    #= none:34 =#
    required_halo_size = Symbol(:required_halo_size_, dir)
    #= none:36 =#
    #= none:36 =# @eval begin
            #= none:37 =#
            #= none:37 =# @inline $outside_symmetric_haloᶠ(i, N, adv) = begin
                        #= none:37 =#
                        (i >= $required_halo_size(adv) + 1) & (i <= (N + 1) - $required_halo_size(adv))
                    end
            #= none:38 =#
            #= none:38 =# @inline $outside_symmetric_haloᶜ(i, N, adv) = begin
                        #= none:38 =#
                        (i >= $required_halo_size(adv)) & (i <= (N + 1) - $required_halo_size(adv))
                    end
            #= none:40 =#
            #= none:40 =# @inline $outside_biased_haloᶠ(i, N, adv) = begin
                        #= none:40 =#
                        (((i >= $required_halo_size(adv) + 1) & (i <= (N + 1) - ($required_halo_size(adv) - 1))) & (i >= $required_halo_size(adv))) & (i <= (N + 1) - $required_halo_size(adv))
                    end
            #= none:42 =#
            #= none:42 =# @inline $outside_biased_haloᶜ(i, N, adv) = begin
                        #= none:42 =#
                        (((i >= $required_halo_size(adv)) & (i <= (N + 1) - ($required_halo_size(adv) - 1))) & (i >= $required_halo_size(adv) - 1)) & (i <= (N + 1) - $required_halo_size(adv))
                    end
        end
    #= none:45 =#
end
#= none:47 =#
const HOADV = Union{WENO, Tuple((Centered{N} for N = advection_buffers[2:end]))..., Tuple((UpwindBiased{N} for N = advection_buffers[2:end]))...}
#= none:50 =#
const LOADV = Union{UpwindBiased{1}, Centered{1}}
#= none:52 =#
for bias = (:symmetric, :biased)
    #= none:53 =#
    for (d, ξ) = enumerate((:x, :y, :z))
        #= none:55 =#
        code = [:ᵃ, :ᵃ, :ᵃ]
        #= none:57 =#
        for loc = (:ᶜ, :ᶠ), (alt1, alt2) = zip((:_, :__, :___, :____, :_____), (:_____, :_, :__, :___, :____))
            #= none:58 =#
            code[d] = loc
            #= none:59 =#
            second_order_interp = Symbol(:ℑ, ξ, code...)
            #= none:60 =#
            interp = Symbol(bias, :_interpolate_, ξ, code...)
            #= none:61 =#
            alt1_interp = Symbol(alt1, interp)
            #= none:62 =#
            alt2_interp = Symbol(alt2, interp)
            #= none:65 =#
            #= none:65 =# @eval #= none:65 =# @inline($alt1_interp(i, j, k, grid::AUG, scheme::HOADV, args...) = begin
                            #= none:65 =#
                            $interp(i, j, k, grid, scheme, args...)
                        end)
            #= none:66 =#
            #= none:66 =# @eval #= none:66 =# @inline($alt1_interp(i, j, k, grid::AUG, scheme::LOADV, args...) = begin
                            #= none:66 =#
                            $interp(i, j, k, grid, scheme, args...)
                        end)
            #= none:69 =#
            for GridType = [:AUGX, :AUGY, :AUGZ, :AUGXY, :AUGXZ, :AUGYZ, :AUGXYZ]
                #= none:70 =#
                #= none:70 =# @eval #= none:70 =# @inline($alt1_interp(i, j, k, grid::$GridType, scheme::LOADV, args...) = begin
                                #= none:70 =#
                                $interp(i, j, k, grid, scheme, args...)
                            end)
                #= none:71 =#
            end
            #= none:73 =#
            outside_buffer = Symbol(:outside_, bias, :_halo_, ξ, loc)
            #= none:76 =#
            if ξ == :x
                #= none:77 =#
                #= none:77 =# @eval begin
                        #= none:78 =#
                        #= none:78 =# @inline $alt1_interp(i, j, k, grid::AUGX, scheme::HOADV, args...) = begin
                                    #= none:78 =#
                                    ifelse($outside_buffer(i, grid.Nx, scheme), $interp(i, j, k, grid, scheme, args...), $alt2_interp(i, j, k, grid, scheme.buffer_scheme, args...))
                                end
                    end
            elseif #= none:83 =# ξ == :y
                #= none:84 =#
                #= none:84 =# @eval begin
                        #= none:85 =#
                        #= none:85 =# @inline $alt1_interp(i, j, k, grid::AUGY, scheme::HOADV, args...) = begin
                                    #= none:85 =#
                                    ifelse($outside_buffer(j, grid.Ny, scheme), $interp(i, j, k, grid, scheme, args...), $alt2_interp(i, j, k, grid, scheme.buffer_scheme, args...))
                                end
                    end
            elseif #= none:90 =# ξ == :z
                #= none:91 =#
                #= none:91 =# @eval begin
                        #= none:92 =#
                        #= none:92 =# @inline $alt1_interp(i, j, k, grid::AUGZ, scheme::HOADV, args...) = begin
                                    #= none:92 =#
                                    ifelse($outside_buffer(k, grid.Nz, scheme), $interp(i, j, k, grid, scheme, args...), $alt2_interp(i, j, k, grid, scheme.buffer_scheme, args...))
                                end
                    end
            end
            #= none:98 =#
        end
        #= none:99 =#
    end
    #= none:100 =#
end
#= none:102 =#
#= none:102 =# @inline _multi_dimensional_reconstruction_x(i, j, k, grid::AUGX, scheme, interp, args...) = begin
            #= none:102 =#
            ifelse(outside_symmetric_bufferᶜ(i, grid.Nx, scheme), multi_dimensional_reconstruction_x(i, j, k, grid::AUGX, scheme, interp, args...), interp(i, j, k, grid, scheme, args...))
        end
#= none:107 =#
#= none:107 =# @inline _multi_dimensional_reconstruction_y(i, j, k, grid::AUGY, scheme, interp, args...) = begin
            #= none:107 =#
            ifelse(outside_symmetric_bufferᶜ(j, grid.Ny, scheme), multi_dimensional_reconstruction_y(i, j, k, grid::AUGY, scheme, interp, args...), interp(i, j, k, grid, scheme, args...))
        end