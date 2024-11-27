
#= none:1 =#
#= none:1 =# @inline x_dot_g_bᶠᶜᶜ(i, j, k, grid, buoyancy, C) = begin
            #= none:1 =#
            ĝ_x(buoyancy) * ℑxᶠᵃᵃ(i, j, k, grid, buoyancy_perturbationᶜᶜᶜ, buoyancy.model, C)
        end
#= none:2 =#
#= none:2 =# @inline y_dot_g_bᶜᶠᶜ(i, j, k, grid, buoyancy, C) = begin
            #= none:2 =#
            ĝ_y(buoyancy) * ℑyᵃᶠᵃ(i, j, k, grid, buoyancy_perturbationᶜᶜᶜ, buoyancy.model, C)
        end
#= none:3 =#
#= none:3 =# @inline z_dot_g_bᶜᶜᶠ(i, j, k, grid, buoyancy, C) = begin
            #= none:3 =#
            ĝ_z(buoyancy) * ℑzᵃᵃᶠ(i, j, k, grid, buoyancy_perturbationᶜᶜᶜ, buoyancy.model, C)
        end
#= none:5 =#
#= none:5 =# @inline (x_dot_g_bᶠᶜᶜ(i, j, k, grid, ::Buoyancy{M, NegativeZDirection}, C) where M) = begin
            #= none:5 =#
            0
        end
#= none:6 =#
#= none:6 =# @inline (y_dot_g_bᶜᶠᶜ(i, j, k, grid, ::Buoyancy{M, NegativeZDirection}, C) where M) = begin
            #= none:6 =#
            0
        end
#= none:7 =#
#= none:7 =# @inline (z_dot_g_bᶜᶜᶠ(i, j, k, grid, b::Buoyancy{M, NegativeZDirection}, C) where M) = begin
            #= none:7 =#
            ℑzᵃᵃᶠ(i, j, k, grid, buoyancy_perturbationᶜᶜᶜ, b.model, C)
        end