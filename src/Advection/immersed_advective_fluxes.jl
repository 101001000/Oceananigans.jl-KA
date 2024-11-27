
#= none:1 =#
using Oceananigans.ImmersedBoundaries
#= none:2 =#
using Oceananigans.ImmersedBoundaries: immersed_peripheral_node, inactive_node
#= none:3 =#
using Oceananigans.Fields: ZeroField
#= none:5 =#
const IBG = ImmersedBoundaryGrid
#= none:7 =#
const c = Center()
#= none:8 =#
const f = Face()
#= none:10 =#
#= none:10 =# Core.@doc "    conditional_flux(i, j, k, ibg::IBG, ℓx, ℓy, ℓz, qᴮ, qᴵ, nc)\n\nReturn either\n\n    i) The boundary flux `qᴮ` if the node condition `nc` is true (default: `nc = immersed_peripheral_node`), or\n    ii) The interior flux `qᴵ` otherwise.\n\nThis can be used either to condition intrinsic flux functions, or immersed boundary flux functions.\n" #= none:20 =# @inline(function conditional_flux(i, j, k, ibg, ℓx, ℓy, ℓz, q_boundary, q_interior)
            #= none:20 =#
            #= none:21 =#
            on_immersed_periphery = immersed_peripheral_node(i, j, k, ibg, ℓx, ℓy, ℓz)
            #= none:22 =#
            return ifelse(on_immersed_periphery, q_boundary, q_interior)
        end)
#= none:26 =#
#= none:26 =# @inline conditional_flux_ccc(i, j, k, ibg::IBG, qᴮ, qᴵ) = begin
            #= none:26 =#
            conditional_flux(i, j, k, ibg, c, c, c, qᴮ, qᴵ)
        end
#= none:27 =#
#= none:27 =# @inline conditional_flux_ffc(i, j, k, ibg::IBG, qᴮ, qᴵ) = begin
            #= none:27 =#
            conditional_flux(i, j, k, ibg, f, f, c, qᴮ, qᴵ)
        end
#= none:28 =#
#= none:28 =# @inline conditional_flux_fcf(i, j, k, ibg::IBG, qᴮ, qᴵ) = begin
            #= none:28 =#
            conditional_flux(i, j, k, ibg, f, c, f, qᴮ, qᴵ)
        end
#= none:29 =#
#= none:29 =# @inline conditional_flux_cff(i, j, k, ibg::IBG, qᴮ, qᴵ) = begin
            #= none:29 =#
            conditional_flux(i, j, k, ibg, c, f, f, qᴮ, qᴵ)
        end
#= none:31 =#
#= none:31 =# @inline conditional_flux_fcc(i, j, k, ibg::IBG, qᴮ, qᴵ) = begin
            #= none:31 =#
            conditional_flux(i, j, k, ibg, f, c, c, qᴮ, qᴵ)
        end
#= none:32 =#
#= none:32 =# @inline conditional_flux_cfc(i, j, k, ibg::IBG, qᴮ, qᴵ) = begin
            #= none:32 =#
            conditional_flux(i, j, k, ibg, c, f, c, qᴮ, qᴵ)
        end
#= none:33 =#
#= none:33 =# @inline conditional_flux_ccf(i, j, k, ibg::IBG, qᴮ, qᴵ) = begin
            #= none:33 =#
            conditional_flux(i, j, k, ibg, c, c, f, qᴮ, qᴵ)
        end
#= none:41 =#
#= none:41 =# @inline _advective_momentum_flux_Uu(i, j, k, ibg::IBG, args...) = begin
            #= none:41 =#
            conditional_flux_ccc(i, j, k, ibg, zero(ibg), advective_momentum_flux_Uu(i, j, k, ibg, args...))
        end
#= none:42 =#
#= none:42 =# @inline _advective_momentum_flux_Vu(i, j, k, ibg::IBG, args...) = begin
            #= none:42 =#
            conditional_flux_ffc(i, j, k, ibg, zero(ibg), advective_momentum_flux_Vu(i, j, k, ibg, args...))
        end
#= none:43 =#
#= none:43 =# @inline _advective_momentum_flux_Wu(i, j, k, ibg::IBG, args...) = begin
            #= none:43 =#
            conditional_flux_fcf(i, j, k, ibg, zero(ibg), advective_momentum_flux_Wu(i, j, k, ibg, args...))
        end
#= none:47 =#
#= none:47 =# @inline _advective_momentum_flux_Uv(i, j, k, ibg::IBG, args...) = begin
            #= none:47 =#
            conditional_flux_ffc(i, j, k, ibg, zero(ibg), advective_momentum_flux_Uv(i, j, k, ibg, args...))
        end
#= none:48 =#
#= none:48 =# @inline _advective_momentum_flux_Vv(i, j, k, ibg::IBG, args...) = begin
            #= none:48 =#
            conditional_flux_ccc(i, j, k, ibg, zero(ibg), advective_momentum_flux_Vv(i, j, k, ibg, args...))
        end
#= none:49 =#
#= none:49 =# @inline _advective_momentum_flux_Wv(i, j, k, ibg::IBG, args...) = begin
            #= none:49 =#
            conditional_flux_cff(i, j, k, ibg, zero(ibg), advective_momentum_flux_Wv(i, j, k, ibg, args...))
        end
#= none:53 =#
#= none:53 =# @inline _advective_momentum_flux_Uw(i, j, k, ibg::IBG, args...) = begin
            #= none:53 =#
            conditional_flux_fcf(i, j, k, ibg, zero(ibg), advective_momentum_flux_Uw(i, j, k, ibg, args...))
        end
#= none:54 =#
#= none:54 =# @inline _advective_momentum_flux_Vw(i, j, k, ibg::IBG, args...) = begin
            #= none:54 =#
            conditional_flux_cff(i, j, k, ibg, zero(ibg), advective_momentum_flux_Vw(i, j, k, ibg, args...))
        end
#= none:55 =#
#= none:55 =# @inline _advective_momentum_flux_Ww(i, j, k, ibg::IBG, args...) = begin
            #= none:55 =#
            conditional_flux_ccc(i, j, k, ibg, zero(ibg), advective_momentum_flux_Ww(i, j, k, ibg, args...))
        end
#= none:57 =#
#= none:57 =# @inline _advective_tracer_flux_x(i, j, k, ibg::IBG, args...) = begin
            #= none:57 =#
            conditional_flux_fcc(i, j, k, ibg, zero(ibg), advective_tracer_flux_x(i, j, k, ibg, args...))
        end
#= none:58 =#
#= none:58 =# @inline _advective_tracer_flux_y(i, j, k, ibg::IBG, args...) = begin
            #= none:58 =#
            conditional_flux_cfc(i, j, k, ibg, zero(ibg), advective_tracer_flux_y(i, j, k, ibg, args...))
        end
#= none:59 =#
#= none:59 =# @inline _advective_tracer_flux_z(i, j, k, ibg::IBG, args...) = begin
            #= none:59 =#
            conditional_flux_ccf(i, j, k, ibg, zero(ibg), advective_tracer_flux_z(i, j, k, ibg, args...))
        end
#= none:62 =#
#= none:62 =# @inline _advective_tracer_flux_x(i, j, k, ibg::IBG, ::Nothing, args...) = begin
            #= none:62 =#
            zero(ibg)
        end
#= none:63 =#
#= none:63 =# @inline _advective_tracer_flux_y(i, j, k, ibg::IBG, ::Nothing, args...) = begin
            #= none:63 =#
            zero(ibg)
        end
#= none:64 =#
#= none:64 =# @inline _advective_tracer_flux_z(i, j, k, ibg::IBG, ::Nothing, args...) = begin
            #= none:64 =#
            zero(ibg)
        end
#= none:67 =#
#= none:67 =# @inline _advective_momentum_flux_Uu(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:67 =#
            _advective_momentum_flux_Uu(i, j, k, ibg, advection.x, args...)
        end
#= none:68 =#
#= none:68 =# @inline _advective_momentum_flux_Vu(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:68 =#
            _advective_momentum_flux_Vu(i, j, k, ibg, advection.y, args...)
        end
#= none:69 =#
#= none:69 =# @inline _advective_momentum_flux_Wu(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:69 =#
            _advective_momentum_flux_Wu(i, j, k, ibg, advection.z, args...)
        end
#= none:71 =#
#= none:71 =# @inline _advective_momentum_flux_Uv(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:71 =#
            _advective_momentum_flux_Uv(i, j, k, ibg, advection.x, args...)
        end
#= none:72 =#
#= none:72 =# @inline _advective_momentum_flux_Vv(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:72 =#
            _advective_momentum_flux_Vv(i, j, k, ibg, advection.y, args...)
        end
#= none:73 =#
#= none:73 =# @inline _advective_momentum_flux_Wv(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:73 =#
            _advective_momentum_flux_Wv(i, j, k, ibg, advection.z, args...)
        end
#= none:75 =#
#= none:75 =# @inline _advective_momentum_flux_Uw(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:75 =#
            _advective_momentum_flux_Uw(i, j, k, ibg, advection.x, args...)
        end
#= none:76 =#
#= none:76 =# @inline _advective_momentum_flux_Vw(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:76 =#
            _advective_momentum_flux_Vw(i, j, k, ibg, advection.y, args...)
        end
#= none:77 =#
#= none:77 =# @inline _advective_momentum_flux_Ww(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:77 =#
            _advective_momentum_flux_Ww(i, j, k, ibg, advection.z, args...)
        end
#= none:80 =#
#= none:80 =# @inline _advective_tracer_flux_x(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:80 =#
            _advective_tracer_flux_x(i, j, k, ibg, advection.x, args...)
        end
#= none:83 =#
#= none:83 =# @inline _advective_tracer_flux_y(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:83 =#
            _advective_tracer_flux_y(i, j, k, ibg, advection.y, args...)
        end
#= none:86 =#
#= none:86 =# @inline _advective_tracer_flux_z(i, j, k, ibg::IBG, advection::FluxFormAdvection, args...) = begin
            #= none:86 =#
            _advective_tracer_flux_z(i, j, k, ibg, advection.z, args...)
        end
#= none:95 =#
#= none:95 =# Core.@doc "    inside_immersed_boundary(buffer, shift, dir, side;\n                             xside = :ᶠ, yside = :ᶠ, zside = :ᶠ) \n\nCheck if the stencil required for reconstruction contains immersed nodes \n\nExample\n=======\n\n```\njulia> inside_immersed_boundary(2, :none, :z, :ᶜ)\n4-element Vector{Any}:\n :(inactive_node(i, j, k + -1, ibg, c, c, f))\n :(inactive_node(i, j, k + 0,  ibg, c, c, f))\n :(inactive_node(i, j, k + 1,  ibg, c, c, f))\n :(inactive_node(i, j, k + 2,  ibg, c, c, f))\n\njulia> inside_immersed_boundary(3, :left, :x, :ᶠ)\n5-element Vector{Any}:\n :(inactive_node(i + -3, j, k, ibg, c, c, c))\n :(inactive_node(i + -2, j, k, ibg, c, c, c))\n :(inactive_node(i + -1, j, k, ibg, c, c, c))\n :(inactive_node(i + 0,  j, k, ibg, c, c, c))\n :(inactive_node(i + 1,  j, k, ibg, c, c, c))\n```\n" #= none:121 =# @inline(function inside_immersed_boundary(buffer, shift, dir, side; xside = :ᶠ, yside = :ᶠ, zside = :ᶠ)
            #= none:121 =#
            #= none:124 =#
            N = buffer * 2
            #= none:125 =#
            if shift != :none
                #= none:126 =#
                N -= 1
            end
            #= none:129 =#
            if shift == :interior
                #= none:130 =#
                rng = 1:N + 1
            elseif #= none:131 =# shift == :right
                #= none:132 =#
                rng = 2:N + 1
            else
                #= none:134 =#
                rng = 1:N
            end
            #= none:137 =#
            inactive_cells = Vector(undef, length(rng))
            #= none:139 =#
            for (idx, n) = enumerate(rng)
                #= none:140 =#
                c = if side == :ᶠ
                        (n - buffer) - 1
                    else
                        n - buffer
                    end
                #= none:141 =#
                xflipside = if xside == :ᶠ
                        :c
                    else
                        :f
                    end
                #= none:142 =#
                yflipside = if yside == :ᶠ
                        :c
                    else
                        :f
                    end
                #= none:143 =#
                zflipside = if zside == :ᶠ
                        :c
                    else
                        :f
                    end
                #= none:144 =#
                inactive_cells[idx] = if dir == :x
                        #= line 0 =#
                        :(inactive_node(i + $c, j, k, ibg, $xflipside, $yflipside, $zflipside))
                    else
                        if dir == :y
                            #= line 0 =#
                            :(inactive_node(i, j + $c, k, ibg, $xflipside, $yflipside, $zflipside))
                        else
                            #= line 0 =#
                            :(inactive_node(i, j, k + $c, ibg, $xflipside, $yflipside, $zflipside))
                        end
                    end
                #= none:149 =#
            end
            #= none:151 =#
            return inactive_cells
        end)
#= none:154 =#
for side = (:ᶜ, :ᶠ)
    #= none:155 =#
    near_x_boundary_symm = Symbol(:near_x_immersed_boundary_symmetric, side)
    #= none:156 =#
    near_y_boundary_symm = Symbol(:near_y_immersed_boundary_symmetric, side)
    #= none:157 =#
    near_z_boundary_symm = Symbol(:near_z_immersed_boundary_symmetric, side)
    #= none:159 =#
    near_x_boundary_bias = Symbol(:near_x_immersed_boundary_biased, side)
    #= none:160 =#
    near_y_boundary_bias = Symbol(:near_y_immersed_boundary_biased, side)
    #= none:161 =#
    near_z_boundary_bias = Symbol(:near_z_immersed_boundary_biased, side)
    #= none:163 =#
    #= none:163 =# @eval begin
            #= none:164 =#
            #= none:164 =# @inline $near_x_boundary_symm(i, j, k, ibg, ::AbstractAdvectionScheme{0}, args...) = begin
                        #= none:164 =#
                        false
                    end
            #= none:165 =#
            #= none:165 =# @inline $near_y_boundary_symm(i, j, k, ibg, ::AbstractAdvectionScheme{0}, args...) = begin
                        #= none:165 =#
                        false
                    end
            #= none:166 =#
            #= none:166 =# @inline $near_z_boundary_symm(i, j, k, ibg, ::AbstractAdvectionScheme{0}, args...) = begin
                        #= none:166 =#
                        false
                    end
            #= none:168 =#
            #= none:168 =# @inline $near_x_boundary_bias(i, j, k, ibg, ::AbstractAdvectionScheme{0}, args...) = begin
                        #= none:168 =#
                        false
                    end
            #= none:169 =#
            #= none:169 =# @inline $near_y_boundary_bias(i, j, k, ibg, ::AbstractAdvectionScheme{0}, args...) = begin
                        #= none:169 =#
                        false
                    end
            #= none:170 =#
            #= none:170 =# @inline $near_z_boundary_bias(i, j, k, ibg, ::AbstractAdvectionScheme{0}, args...) = begin
                        #= none:170 =#
                        false
                    end
        end
    #= none:173 =#
    for buffer = advection_buffers
        #= none:174 =#
        #= none:174 =# @eval begin
                #= none:175 =#
                #= none:175 =# @inline $near_x_boundary_symm(i, j, k, ibg, ::AbstractAdvectionScheme{$buffer}) = begin
                            #= none:175 =#
                            (|)($(inside_immersed_boundary(buffer, :none, :x, side; xside = side)...))
                        end
                #= none:176 =#
                #= none:176 =# @inline $near_y_boundary_symm(i, j, k, ibg, ::AbstractAdvectionScheme{$buffer}) = begin
                            #= none:176 =#
                            (|)($(inside_immersed_boundary(buffer, :none, :y, side; yside = side)...))
                        end
                #= none:177 =#
                #= none:177 =# @inline $near_z_boundary_symm(i, j, k, ibg, ::AbstractAdvectionScheme{$buffer}) = begin
                            #= none:177 =#
                            (|)($(inside_immersed_boundary(buffer, :none, :z, side; zside = side)...))
                        end
                #= none:179 =#
                #= none:179 =# @inline $near_x_boundary_bias(i, j, k, ibg, ::AbstractAdvectionScheme{$buffer}) = begin
                            #= none:179 =#
                            (|)($(inside_immersed_boundary(buffer, :interior, :x, side; xside = side)...))
                        end
                #= none:180 =#
                #= none:180 =# @inline $near_y_boundary_bias(i, j, k, ibg, ::AbstractAdvectionScheme{$buffer}) = begin
                            #= none:180 =#
                            (|)($(inside_immersed_boundary(buffer, :interior, :y, side; yside = side)...))
                        end
                #= none:181 =#
                #= none:181 =# @inline $near_z_boundary_bias(i, j, k, ibg, ::AbstractAdvectionScheme{$buffer}) = begin
                            #= none:181 =#
                            (|)($(inside_immersed_boundary(buffer, :interior, :z, side; zside = side)...))
                        end
            end
        #= none:183 =#
    end
    #= none:184 =#
end
#= none:186 =#
for bias = (:symmetric, :biased)
    #= none:187 =#
    for (d, ξ) = enumerate((:x, :y, :z))
        #= none:188 =#
        code = [:ᵃ, :ᵃ, :ᵃ]
        #= none:190 =#
        for loc = (:ᶜ, :ᶠ), alt = (:_, :__, :___, :____, :_____)
            #= none:191 =#
            code[d] = loc
            #= none:192 =#
            interp = Symbol(bias, :_interpolate_, ξ, code...)
            #= none:193 =#
            alt_interp = Symbol(alt, interp)
            #= none:194 =#
            #= none:194 =# @eval begin
                    #= none:195 =#
                    import Oceananigans.Advection: $alt_interp
                    #= none:196 =#
                    using Oceananigans.Advection: $interp
                end
            #= none:198 =#
        end
        #= none:200 =#
        for loc = (:ᶜ, :ᶠ), (alt1, alt2) = zip((:_, :__, :___, :____, :_____), (:_____, :_, :__, :___, :____))
            #= none:201 =#
            code[d] = loc
            #= none:202 =#
            interp = Symbol(bias, :_interpolate_, ξ, code...)
            #= none:203 =#
            alt1_interp = Symbol(alt1, interp)
            #= none:204 =#
            alt2_interp = Symbol(alt2, interp)
            #= none:206 =#
            near_boundary = Symbol(:near_, ξ, :_immersed_boundary_, bias, loc)
            #= none:208 =#
            #= none:208 =# @eval begin
                    #= none:210 =#
                    #= none:210 =# @inline $alt1_interp(i, j, k, ibg::ImmersedBoundaryGrid, scheme::LOADV, args...) = begin
                                #= none:210 =#
                                $interp(i, j, k, ibg, scheme, args...)
                            end
                    #= none:213 =#
                    #= none:213 =# @inline $alt1_interp(i, j, k, ibg::ImmersedBoundaryGrid, scheme::HOADV, args...) = begin
                                #= none:213 =#
                                ifelse($near_boundary(i, j, k, ibg, scheme), $alt2_interp(i, j, k, ibg, scheme.buffer_scheme, args...), $interp(i, j, k, ibg, scheme, args...))
                            end
                end
            #= none:218 =#
        end
        #= none:219 =#
    end
    #= none:220 =#
end