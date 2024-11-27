
#= none:1 =#
validate_buoyancy(::Nothing, tracers) = begin
        #= none:1 =#
        nothing
    end
#= none:3 =#
required_tracers(::Nothing) = begin
        #= none:3 =#
        ()
    end
#= none:5 =#
#= none:5 =# @inline buoyancy_perturbationᶜᶜᶜ(i, j, k, grid, ::Nothing, C) = begin
            #= none:5 =#
            zero(grid)
        end
#= none:7 =#
#= none:7 =# @inline ∂x_b(i, j, k, grid, ::Nothing, C) = begin
            #= none:7 =#
            zero(grid)
        end
#= none:8 =#
#= none:8 =# @inline ∂y_b(i, j, k, grid, ::Nothing, C) = begin
            #= none:8 =#
            zero(grid)
        end
#= none:9 =#
#= none:9 =# @inline ∂z_b(i, j, k, grid, ::Nothing, C) = begin
            #= none:9 =#
            zero(grid)
        end
#= none:11 =#
#= none:11 =# @inline x_dot_g_bᶠᶜᶜ(i, j, k, grid, ::Nothing, C) = begin
            #= none:11 =#
            zero(grid)
        end
#= none:12 =#
#= none:12 =# @inline y_dot_g_bᶜᶠᶜ(i, j, k, grid, ::Nothing, C) = begin
            #= none:12 =#
            zero(grid)
        end
#= none:13 =#
#= none:13 =# @inline z_dot_g_bᶜᶜᶠ(i, j, k, grid, ::Nothing, C) = begin
            #= none:13 =#
            zero(grid)
        end