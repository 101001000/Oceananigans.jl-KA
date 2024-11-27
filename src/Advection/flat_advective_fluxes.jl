
#= none:6 =#
using Oceananigans.Grids: XFlatGrid, YFlatGrid, ZFlatGrid
#= none:8 =#
for SchemeType = [:CenteredScheme, :UpwindScheme]
    #= none:9 =#
    #= none:9 =# @eval begin
            #= none:10 =#
            #= none:10 =# @inline advective_momentum_flux_Uu(i, j, k, grid::XFlatGrid, ::$SchemeType, U, u) = begin
                        #= none:10 =#
                        zero(grid)
                    end
            #= none:11 =#
            #= none:11 =# @inline advective_momentum_flux_Uv(i, j, k, grid::XFlatGrid, ::$SchemeType, U, v) = begin
                        #= none:11 =#
                        zero(grid)
                    end
            #= none:12 =#
            #= none:12 =# @inline advective_momentum_flux_Uw(i, j, k, grid::XFlatGrid, ::$SchemeType, U, w) = begin
                        #= none:12 =#
                        zero(grid)
                    end
            #= none:14 =#
            #= none:14 =# @inline advective_momentum_flux_Vv(i, j, k, grid::YFlatGrid, ::$SchemeType, V, v) = begin
                        #= none:14 =#
                        zero(grid)
                    end
            #= none:15 =#
            #= none:15 =# @inline advective_momentum_flux_Vu(i, j, k, grid::YFlatGrid, ::$SchemeType, V, u) = begin
                        #= none:15 =#
                        zero(grid)
                    end
            #= none:16 =#
            #= none:16 =# @inline advective_momentum_flux_Vw(i, j, k, grid::YFlatGrid, ::$SchemeType, V, w) = begin
                        #= none:16 =#
                        zero(grid)
                    end
            #= none:18 =#
            #= none:18 =# @inline advective_momentum_flux_Wu(i, j, k, grid::ZFlatGrid, ::$SchemeType, W, u) = begin
                        #= none:18 =#
                        zero(grid)
                    end
            #= none:19 =#
            #= none:19 =# @inline advective_momentum_flux_Wv(i, j, k, grid::ZFlatGrid, ::$SchemeType, W, v) = begin
                        #= none:19 =#
                        zero(grid)
                    end
            #= none:20 =#
            #= none:20 =# @inline advective_momentum_flux_Ww(i, j, k, grid::ZFlatGrid, ::$SchemeType, W, w) = begin
                        #= none:20 =#
                        zero(grid)
                    end
        end
    #= none:22 =#
end
#= none:24 =#
Grids = [:XFlatGrid, :YFlatGrid, :ZFlatGrid, :XFlatGrid, :YFlatGrid, :ZFlatGrid]
#= none:26 =#
for side = (:left_biased, :right_biased, :symmetric)
    #= none:27 =#
    for (dir, Grid) = zip([:xᶠᵃᵃ, :yᵃᶠᵃ, :zᵃᵃᶠ, :xᶜᵃᵃ, :yᵃᶜᵃ, :zᵃᵃᶜ], Grids)
        #= none:28 =#
        interp_function = Symbol(side, :_interpolate_, dir)
        #= none:29 =#
        #= none:29 =# @eval begin
                #= none:30 =#
                #= none:30 =# @inline $interp_function(i, j, k, grid::$Grid, scheme, ψ, args...) = begin
                            #= none:30 =#
                            #= none:30 =# @inbounds ψ[i, j, k]
                        end
                #= none:31 =#
                #= none:31 =# @inline $interp_function(i, j, k, grid::$Grid, scheme, ψ::Function, args...) = begin
                            #= none:31 =#
                            #= none:31 =# @inbounds ψ(i, j, k, grid, args...)
                        end
                #= none:33 =#
                #= none:33 =# @inline $interp_function(i, j, k, grid::$Grid, scheme::AbstractUpwindBiasedAdvectionScheme, ψ, args...) = begin
                            #= none:33 =#
                            #= none:33 =# @inbounds ψ[i, j, k]
                        end
                #= none:34 =#
                #= none:34 =# @inline $interp_function(i, j, k, grid::$Grid, scheme::AbstractUpwindBiasedAdvectionScheme, ψ::Function, args...) = begin
                            #= none:34 =#
                            #= none:34 =# @inbounds ψ(i, j, k, grid, args...)
                        end
                #= none:35 =#
                #= none:35 =# @inline $interp_function(i, j, k, grid::$Grid, scheme::AbstractUpwindBiasedAdvectionScheme, ψ::Function, S::AbstractSmoothnessStencil, args...) = begin
                            #= none:35 =#
                            #= none:35 =# @inbounds ψ(i, j, k, grid, args...)
                        end
            end
        #= none:37 =#
    end
    #= none:38 =#
end