
#= none:5 =#
#= none:5 =# @inline fᶠᶠᵃ(i, j, k, grid, ::Nothing) = begin
            #= none:5 =#
            zero(grid)
        end
#= none:7 =#
#= none:7 =# @inline (x_f_cross_U(i, j, k, grid::AbstractGrid{FT}, ::Nothing, U) where FT) = begin
            #= none:7 =#
            zero(FT)
        end
#= none:8 =#
#= none:8 =# @inline (y_f_cross_U(i, j, k, grid::AbstractGrid{FT}, ::Nothing, U) where FT) = begin
            #= none:8 =#
            zero(FT)
        end
#= none:9 =#
#= none:9 =# @inline (z_f_cross_U(i, j, k, grid::AbstractGrid{FT}, ::Nothing, U) where FT) = begin
            #= none:9 =#
            zero(FT)
        end