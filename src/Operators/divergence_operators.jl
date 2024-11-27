
#= none:5 =#
#= none:5 =# Core.@doc "    divᶜᶜᶜ(i, j, k, grid, u, v, w)\n\nCalculate the divergence ``𝛁·𝐕`` of a vector field ``𝐕 = (u, v, w)``,\n\n```julia\n1/V * [δxᶜᵃᵃ(Ax * u) + δxᵃᶜᵃ(Ay * v) + δzᵃᵃᶜ(Az * w)]\n```\n\nwhich ends up at the cell centers `ccc`.\n" #= none:16 =# @inline(divᶜᶜᶜ(i, j, k, grid, u, v, w) = begin
                #= none:16 =#
                (1 / Vᶜᶜᶜ(i, j, k, grid)) * (δxᶜᶜᶜ(i, j, k, grid, Ax_qᶠᶜᶜ, u) + δyᶜᶜᶜ(i, j, k, grid, Ay_qᶜᶠᶜ, v) + δzᶜᶜᶜ(i, j, k, grid, Az_qᶜᶜᶠ, w))
            end)
#= none:21 =#
#= none:21 =# Core.@doc "    div_xyᶜᶜᵃ(i, j, k, grid, u, v)\n\nReturn the discrete `div_xy = ∂x u + ∂y v` of velocity field `u, v` defined as\n\n```julia\n1 / Azᶜᶜᵃ * [δxᶜᵃᵃ(Δyᵃᶜᵃ * u) + δyᵃᶜᵃ(Δxᶜᵃᵃ * v)]\n```\n\nat `i, j, k`, where `Azᶜᶜᵃ` is the area of the cell centered on (Center, Center, Any) --- a tracer cell,\n`Δy` is the length of the cell centered on (Face, Center, Any) in `y` (a `u` cell),\nand `Δx` is the length of the cell centered on (Center, Face, Any) in `x` (a `v` cell).\n`div_xyᶜᶜᵃ` ends up at the location `cca`.\n" #= none:35 =# @inline(flux_div_xyᶜᶜᶜ(i, j, k, grid, u, v) = begin
                #= none:35 =#
                δxᶜᶜᶜ(i, j, k, grid, Ax_qᶠᶜᶜ, u) + δyᶜᶜᶜ(i, j, k, grid, Ay_qᶜᶠᶜ, v)
            end)
#= none:38 =#
#= none:38 =# @inline div_xyᶜᶜᶜ(i, j, k, grid, u, v) = begin
            #= none:38 =#
            (1 / Vᶜᶜᶜ(i, j, k, grid)) * flux_div_xyᶜᶜᶜ(i, j, k, grid, u, v)
        end
#= none:41 =#
#= none:41 =# @inline div_xyᶜᶜᶠ(i, j, k, grid, Qu, Qv) = begin
            #= none:41 =#
            (1 / Vᶜᶜᶠ(i, j, k, grid)) * (δxᶜᶜᶠ(i, j, k, grid, Ay_qᶠᶜᶠ, Qu) + δyᶜᶜᶠ(i, j, k, grid, Ax_qᶜᶠᶠ, Qv))
        end
#= none:46 =#
index_left(i, ::Center) = begin
        #= none:46 =#
        i
    end
#= none:47 =#
index_left(i, ::Face) = begin
        #= none:47 =#
        i - 1
    end
#= none:48 =#
index_right(i, ::Center) = begin
        #= none:48 =#
        i + 1
    end
#= none:49 =#
index_right(i, ::Face) = begin
        #= none:49 =#
        i
    end
#= none:51 =#
#= none:51 =# @inline Base.div(i, j, k, grid::AbstractGrid, loc, q_west, q_east, q_south, q_north, q_bottom, q_top) = begin
            #= none:51 =#
            (1 / volume(i, j, k, grid, loc...)) * (δx_Ax_q(i, j, k, grid, loc, q_west, q_east) + δy_Ay_q(i, j, k, grid, loc, q_south, q_north) + δz_Az_q(i, j, k, grid, loc, q_bottom, q_top))
        end
#= none:56 =#
#= none:56 =# @inline function δx_Ax_q(i, j, k, grid, (LX, LY, LZ), qᵂ, qᴱ)
        #= none:56 =#
        #= none:57 =#
        iᵂ = index_left(i, LX)
        #= none:58 =#
        Axᵂ = Ax(iᵂ, j, k, grid, LX, LY, LZ)
        #= none:60 =#
        iᴱ = index_right(i, LX)
        #= none:61 =#
        Axᴱ = Ax(iᴱ, j, k, grid, LX, LY, LZ)
        #= none:63 =#
        return Axᴱ * qᴱ - Axᵂ * qᵂ
    end
#= none:66 =#
#= none:66 =# @inline function δy_Ay_q(i, j, k, grid, (LX, LY, LZ), qˢ, qᴺ)
        #= none:66 =#
        #= none:67 =#
        jˢ = index_left(j, LY)
        #= none:68 =#
        Ayˢ = Ay(i, jˢ, k, grid, LX, LY, LZ)
        #= none:70 =#
        jᴺ = index_right(j, LY)
        #= none:71 =#
        Ayᴺ = Ay(i, jᴺ, k, grid, LX, LY, LZ)
        #= none:73 =#
        return Ayᴺ * qᴺ - Ayˢ * qˢ
    end
#= none:76 =#
#= none:76 =# @inline function δz_Az_q(i, j, k, grid, (LX, LY, LZ), qᴮ, qᵀ)
        #= none:76 =#
        #= none:77 =#
        kᴮ = index_left(k, LZ)
        #= none:78 =#
        Azᴮ = Az(i, j, kᴮ, grid, LX, LY, LZ)
        #= none:80 =#
        kᵀ = index_right(k, LZ)
        #= none:81 =#
        Azᵀ = Az(i, j, kᵀ, grid, LX, LY, LZ)
        #= none:83 =#
        return Azᵀ * qᵀ - Azᴮ * qᴮ
    end
#= none:88 =#
#= none:88 =# @inline δx_Ax_q(i, j, k, grid::XFlatGrid, args...) = begin
            #= none:88 =#
            zero(grid)
        end
#= none:89 =#
#= none:89 =# @inline δy_Ay_q(i, j, k, grid::YFlatGrid, args...) = begin
            #= none:89 =#
            zero(grid)
        end
#= none:90 =#
#= none:90 =# @inline δz_Az_q(i, j, k, grid::ZFlatGrid, args...) = begin
            #= none:90 =#
            zero(grid)
        end