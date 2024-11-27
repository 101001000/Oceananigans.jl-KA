
#= none:3 =#
#= none:3 =# Core.@doc "    @inline symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, ψ, args...)\n\nhigh order centered reconstruction of variable ψ in the x-direction. ψ can be a `Function`\nwith signature `ψ(i, j, k, grid, args...)` or an `AbstractArray`\n" #= none:9 =# @inline(symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, ψ, args...) = begin
                #= none:9 =#
                inner_symmetric_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, ψ, i, Face, args...)
            end)
#= none:11 =#
#= none:11 =# Core.@doc "    @inline symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, ψ, args...)\n\nhigh order centered reconstruction of variable ψ in the y-direction. ψ can be a `Function`\nwith signature `ψ(i, j, k, grid, args...)` or an `AbstractArray`\n" #= none:17 =# @inline(symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, ψ, args...) = begin
                #= none:17 =#
                inner_symmetric_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, ψ, j, Face, args...)
            end)
#= none:19 =#
#= none:19 =# Core.@doc "    @inline symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, ψ, args...)\n\nhigh order centered reconstruction of variable ψ in the z-direction. ψ can be a `Function`\nwith signature `ψ(i, j, k, grid, args...)` or an `AbstractArray`\n" #= none:25 =# @inline(symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, ψ, args...) = begin
                #= none:25 =#
                inner_symmetric_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, ψ, k, Face, args...)
            end)
#= none:27 =#
#= none:27 =# Core.@doc " same as [`symmetric_interpolate_xᶠᵃᵃ`](@ref) but on `Center`s instead of `Face`s " #= none:28 =# @inline(symmetric_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme, ψ, args...) = begin
                #= none:28 =#
                inner_symmetric_interpolate_xᶠᵃᵃ(i + 1, j, k, grid, scheme, ψ, i, Center, args...)
            end)
#= none:29 =#
#= none:29 =# Core.@doc " same as [`symmetric_interpolate_yᵃᶠᵃ`](@ref) but on `Center`s instead of `Face`s " #= none:30 =# @inline(symmetric_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme, ψ, args...) = begin
                #= none:30 =#
                inner_symmetric_interpolate_yᵃᶠᵃ(i, j + 1, k, grid, scheme, ψ, j, Center, args...)
            end)
#= none:31 =#
#= none:31 =# Core.@doc " same as [`symmetric_interpolate_zᵃᵃᶠ`](@ref) but on `Center`s instead of `Face`s " #= none:32 =# @inline(symmetric_interpolate_zᵃᵃᶜ(i, j, k, grid, scheme, ψ, args...) = begin
                #= none:32 =#
                inner_symmetric_interpolate_zᵃᵃᶠ(i, j, k + 1, grid, scheme, ψ, k, Center, args...)
            end)
#= none:34 =#
#= none:34 =# Core.@doc "    @inline biased_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, bias, ψ, args...)\n\nhigh order biased reconstruction of variable ψ in the x-direction. ψ can be a `Function`\nwith signature `ψ(i, j, k, grid, args...)` or an `AbstractArray`. The `bias` argument is\neither `LeftBias` for a left biased reconstruction, or `RightBias` for a right biased reconstruction\n" #= none:41 =# @inline(biased_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, bias, ψ, args...) = begin
                #= none:41 =#
                inner_biased_interpolate_xᶠᵃᵃ(i, j, k, grid, scheme, bias, ψ, i, Face, args...)
            end)
#= none:43 =#
#= none:43 =# Core.@doc "    @inline biased_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, bias, ψ, args...)\n\nhigh order biased reconstruction of variable ψ in the y-direction. ψ can be a `Function`\nwith signature `ψ(i, j, k, grid, args...)` or an `AbstractArray`. The `bias` argument is\neither `LeftBias` for a left biased reconstruction, or `RightBias` for a right biased reconstruction\n" #= none:50 =# @inline(biased_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, bias, ψ, args...) = begin
                #= none:50 =#
                inner_biased_interpolate_yᵃᶠᵃ(i, j, k, grid, scheme, bias, ψ, j, Face, args...)
            end)
#= none:52 =#
#= none:52 =# Core.@doc "    @inline biased_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, bias, ψ, args...)\n\nhigh order biased reconstruction of variable ψ in the z-direction. ψ can be a `Function`\nwith signature `ψ(i, j, k, grid, args...)` or an `AbstractArray`. The `bias` argument is\neither `LeftBias` for a left biased reconstruction, or `RightBias` for a right biased reconstruction\n" #= none:59 =# @inline(biased_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, bias, ψ, args...) = begin
                #= none:59 =#
                inner_biased_interpolate_zᵃᵃᶠ(i, j, k, grid, scheme, bias, ψ, k, Face, args...)
            end)
#= none:61 =#
#= none:61 =# Core.@doc " same as [`biased_interpolate_xᶠᵃᵃ`](@ref) but on `Center`s instead of `Face`s " #= none:62 =# @inline(biased_interpolate_xᶜᵃᵃ(i, j, k, grid, scheme, bias, ψ, args...) = begin
                #= none:62 =#
                inner_biased_interpolate_xᶠᵃᵃ(i + 1, j, k, grid, scheme, bias, ψ, i, Center, args...)
            end)
#= none:63 =#
#= none:63 =# Core.@doc " same as [`biased_interpolate_yᵃᶠᵃ`](@ref) but on `Center`s instead of `Face`s " #= none:64 =# @inline(biased_interpolate_yᵃᶜᵃ(i, j, k, grid, scheme, bias, ψ, args...) = begin
                #= none:64 =#
                inner_biased_interpolate_yᵃᶠᵃ(i, j + 1, k, grid, scheme, bias, ψ, j, Center, args...)
            end)
#= none:65 =#
#= none:65 =# Core.@doc " same as [`biased_interpolate_zᵃᵃᶠ`](@ref) but on `Center`s instead of `Face`s " #= none:66 =# @inline(biased_interpolate_zᵃᵃᶜ(i, j, k, grid, scheme, bias, ψ, args...) = begin
                #= none:66 =#
                inner_biased_interpolate_zᵃᵃᶠ(i, j, k + 1, grid, scheme, bias, ψ, k, Center, args...)
            end)
#= none:68 =#
struct FirstDerivative
    #= none:68 =#
end
#= none:69 =#
struct SecondDerivative
    #= none:69 =#
end
#= none:70 =#
struct Primitive
    #= none:70 =#
end
#= none:72 =#
num_prod(i, m, l, r, xr, xi, shift, op, order, args...) = begin
        #= none:72 =#
        #= none:72 =# @inbounds prod((xr[i + shift] - xi[op(i, (r - q) + 1)] for q = 0:order if q != m && q != l))
    end
#= none:73 =#
num_prod(i, m, l, r, xr, xi, shift, op, order, ::FirstDerivative) = begin
        #= none:73 =#
        #= none:73 =# @inbounds 2 * xr[i + shift] - sum((xi[op(i, (r - q) + 1)] for q = 0:order if q != m && q != l))
    end
#= none:74 =#
num_prod(i, m, l, r, xr, xi, shift, op, order, ::SecondDerivative) = begin
        #= none:74 =#
        2
    end
#= none:76 =#
#= none:76 =# @inline function num_prod(i, m, l, r, xr, xi, shift, op, order, ::Primitive)
        #= none:76 =#
        #= none:77 =#
        s = sum((xi[op(i, (r - q) + 1)] for q = 0:order if q != m && q != l))
        #= none:78 =#
        p = prod((xi[op(i, (r - q) + 1)] for q = 0:order if q != m && q != l))
        #= none:80 =#
        return (xr[i + shift] ^ 3 / 3 - (s * xr[i + shift] ^ 2) / 2) + p * xr[i + shift]
    end
#= none:83 =#
#= none:83 =# Core.@doc "    stencil_coefficients(i, r, xr, xi; shift = 0, op = Base.:(-), order = 3, der = nothing)\n\nReturn coefficients for finite-volume polynomial reconstruction of order `order` at stencil `r`.\n\nPositional Arguments\n====================\n\n- `xi`: the locations of the reconstructing value, i.e. either the center coordinate,\n  for centered quantities or face coordinate for staggered\n- `xr`: the opposite of the reconstruction location desired, i.e., if a recostruction at\n  `Center`s is required xr is the face coordinate\n\nOn a uniform `grid`, the coefficients are independent of the `xr` and `xi` values.\n" #= none:98 =# @inline(function stencil_coefficients(i, r, xr, xi; shift = 0, op = Base.:-, order = 3, der = nothing)
            #= none:98 =#
            #= none:99 =#
            coeffs = zeros(order)
            #= none:100 =#
            #= none:100 =# @inbounds begin
                    #= none:101 =#
                    for j = 0:order - 1
                        #= none:102 =#
                        for m = j + 1:order
                            #= none:103 =#
                            numerator = sum((num_prod(i, m, l, r, xr, xi, shift, op, order, der) for l = 0:order if l != m))
                            #= none:104 =#
                            denominator = prod((xi[op(i, (r - m) + 1)] - xi[op(i, (r - l) + 1)] for l = 0:order if l != m))
                            #= none:105 =#
                            coeffs[j + 1] += (numerator / denominator) * (xi[op(i, r - j)] - xi[op(i, (r - j) + 1)])
                            #= none:106 =#
                        end
                        #= none:107 =#
                    end
                end
            #= none:110 =#
            return tuple(coeffs...)
        end)
#= none:113 =#
#= none:113 =# Core.@doc "    Coefficients for uniform centered and upwind schemes \n\nsymmetric coefficients are for centered reconstruction (dispersive, even order), \nleft and right are for upwind biased (diffusive, odd order)\nexamples:\njulia> using Oceananigans.Advection: coeff2_symmetric, coeff3_left, coeff3_right, coeff4_symmetric, coeff5_left\n\njulia> coeff2_symmetric\n(0.5, 0.5)\n\njulia> coeff3_left, coeff3_right\n((0.33333333333333337, 0.8333333333333334, -0.16666666666666666), (-0.16666666666666669, 0.8333333333333333, 0.3333333333333333))\n\njulia> coeff4_symmetric\n(-0.08333333333333333, 0.5833333333333333, 0.5833333333333333, -0.08333333333333333)\n\njulia> coeff5_left\n(-0.049999999999999926, 0.45000000000000007, 0.7833333333333333, -0.21666666666666667, 0.03333333333333333)\n" const coeff1_left = 1.0
#= none:134 =#
const coeff1_right = 1.0
#= none:137 =#
for buffer = advection_buffers
    #= none:138 =#
    order_bias = 2buffer - 1
    #= none:139 =#
    order_symm = 2buffer
    #= none:141 =#
    coeff_symm = Symbol(:coeff, order_symm, :_symmetric)
    #= none:142 =#
    coeff_left = Symbol(:coeff, order_bias, :_left)
    #= none:143 =#
    coeff_right = Symbol(:coeff, order_bias, :_right)
    #= none:144 =#
    #= none:144 =# @eval begin
            #= none:145 =#
            const $coeff_symm = stencil_coefficients(50, $(buffer - 1), collect(1:100), collect(1:100); order = $order_symm)
            #= none:146 =#
            if $order_bias > 1
                #= none:147 =#
                const $coeff_left = stencil_coefficients(50, $(buffer - 2), collect(1:100), collect(1:100); order = $order_bias)
                #= none:148 =#
                const $coeff_right = stencil_coefficients(50, $(buffer - 1), collect(1:100), collect(1:100); order = $order_bias)
            end
        end
    #= none:151 =#
end
#= none:153 =#
#= none:153 =# Core.@doc " \n    calc_reconstruction_stencil(buffer, shift, dir, func::Bool = false)\n\nStencils for reconstruction calculations (note that WENO has its own reconstruction stencils)\n\nThe first argument is the `buffer`, not the `order`! \n- `order = 2 * buffer` for Centered reconstruction\n- `order = 2 * buffer - 1` for Upwind reconstruction\n   \nExamples\n========\n\n```jldoctest\njulia> using Oceananigans.Advection: calc_reconstruction_stencil\n\njulia> calc_reconstruction_stencil(1, :right, :x)\n:(+(convert(FT, coeff1_right[1]) * ψ[i + 0, j, k]))\n\njulia> calc_reconstruction_stencil(1, :left, :x)\n:(+(convert(FT, coeff1_left[1]) * ψ[i + -1, j, k]))\n\njulia> calc_reconstruction_stencil(1, :symmetric, :x)\n:(convert(FT, coeff2_symmetric[2]) * ψ[i + -1, j, k] + convert(FT, coeff2_symmetric[1]) * ψ[i + 0, j, k])\n\njulia> calc_reconstruction_stencil(2, :symmetric, :x)\n:(convert(FT, coeff4_symmetric[4]) * ψ[i + -2, j, k] + convert(FT, coeff4_symmetric[3]) * ψ[i + -1, j, k] + convert(FT, coeff4_symmetric[2]) * ψ[i + 0, j, k] + convert(FT, coeff4_symmetric[1]) * ψ[i + 1, j, k])\n\njulia> calc_reconstruction_stencil(3, :left, :x)\n:(convert(FT, coeff5_left[5]) * ψ[i + -3, j, k] + convert(FT, coeff5_left[4]) * ψ[i + -2, j, k] + convert(FT, coeff5_left[3]) * ψ[i + -1, j, k] + convert(FT, coeff5_left[2]) * ψ[i + 0, j, k] + convert(FT, coeff5_left[1]) * ψ[i + 1, j, k])\n```\n" #= none:184 =# @inline(function calc_reconstruction_stencil(buffer, shift, dir, func::Bool = false)
            #= none:184 =#
            #= none:185 =#
            N = buffer * 2
            #= none:186 =#
            order = if shift == :symmetric
                    N
                else
                    N - 1
                end
            #= none:187 =#
            if shift != :symmetric
                #= none:188 =#
                N = N .- 1
            end
            #= none:190 =#
            rng = 1:N
            #= none:191 =#
            if shift == :right
                #= none:192 =#
                rng = rng .+ 1
            end
            #= none:194 =#
            stencil_full = Vector(undef, N)
            #= none:195 =#
            coeff = Symbol(:coeff, order, :_, shift)
            #= none:196 =#
            for (idx, n) = enumerate(rng)
                #= none:197 =#
                c = (n - buffer) - 1
                #= none:198 =#
                if func
                    #= none:199 =#
                    stencil_full[idx] = if dir == :x
                            #= line 0 =#
                            :(convert(FT, $coeff[$((order - idx) + 1)]) * ψ(i + $c, j, k, grid, args...))
                        else
                            if dir == :y
                                #= line 0 =#
                                :(convert(FT, $coeff[$((order - idx) + 1)]) * ψ(i, j + $c, k, grid, args...))
                            else
                                #= line 0 =#
                                :(convert(FT, $coeff[$((order - idx) + 1)]) * ψ(i, j, k + $c, grid, args...))
                            end
                        end
                else
                    #= none:205 =#
                    stencil_full[idx] = if dir == :x
                            #= line 0 =#
                            :(convert(FT, $coeff[$((order - idx) + 1)]) * ψ[i + $c, j, k])
                        else
                            if dir == :y
                                #= line 0 =#
                                :(convert(FT, $coeff[$((order - idx) + 1)]) * ψ[i, j + $c, k])
                            else
                                #= line 0 =#
                                :(convert(FT, $coeff[$((order - idx) + 1)]) * ψ[i, j, k + $c])
                            end
                        end
                end
                #= none:211 =#
            end
            #= none:212 =#
            return Expr(:call, :+, stencil_full...)
        end)
#= none:219 =#
#= none:219 =# @inline function reconstruction_stencil(buffer, shift, dir, func::Bool = false)
        #= none:219 =#
        #= none:220 =#
        N = buffer * 2
        #= none:221 =#
        order = if shift == :symmetric
                N
            else
                N - 1
            end
        #= none:222 =#
        if shift != :symmetric
            #= none:223 =#
            N = N .- 1
        end
        #= none:225 =#
        rng = 1:N
        #= none:226 =#
        if shift == :right
            #= none:227 =#
            rng = rng .+ 1
        end
        #= none:229 =#
        stencil_full = Vector(undef, N)
        #= none:230 =#
        coeff = Symbol(:coeff, order, :_, shift)
        #= none:231 =#
        for (idx, n) = enumerate(rng)
            #= none:232 =#
            c = (n - buffer) - 1
            #= none:233 =#
            if func
                #= none:234 =#
                stencil_full[idx] = if dir == :x
                        #= line 0 =#
                        :(ψ(i + $c, j, k, grid, args...))
                    else
                        if dir == :y
                            #= line 0 =#
                            :(ψ(i, j + $c, k, grid, args...))
                        else
                            #= line 0 =#
                            :(ψ(i, j, k + $c, grid, args...))
                        end
                    end
            else
                #= none:240 =#
                stencil_full[idx] = if dir == :x
                        #= line 0 =#
                        :(ψ[i + $c, j, k])
                    else
                        if dir == :y
                            #= line 0 =#
                            :(ψ[i, j + $c, k])
                        else
                            #= line 0 =#
                            :(ψ[i, j, k + $c])
                        end
                    end
            end
            #= none:246 =#
        end
        #= none:247 =#
        return :(($(reverse(stencil_full)...),))
    end
#= none:250 =#
#= none:250 =# @inline function compute_reconstruction_coefficients(grid, FT, scheme; order)
        #= none:250 =#
        #= none:252 =#
        method = if scheme == :Centered
                1
            else
                if scheme == :Upwind
                    2
                else
                    3
                end
            end
        #= none:254 =#
        if grid isa Nothing
            #= none:255 =#
            coeff_xᶠᵃᵃ = nothing
            #= none:256 =#
            coeff_xᶜᵃᵃ = nothing
            #= none:257 =#
            coeff_yᵃᶠᵃ = nothing
            #= none:258 =#
            coeff_yᵃᶜᵃ = nothing
            #= none:259 =#
            coeff_zᵃᵃᶠ = nothing
            #= none:260 =#
            coeff_zᵃᵃᶜ = nothing
        else
            #= none:262 =#
            arch = architecture(grid)
            #= none:263 =#
            (Hx, Hy, Hz) = halo_size(grid)
            #= none:264 =#
            new_grid = with_halo((Hx + 1, Hy + 1, Hz + 1), grid)
            #= none:265 =#
            metrics = coordinates(grid)
            #= none:267 =#
            coeff_xᶠᵃᵃ = reconstruction_coefficients(FT, getproperty(new_grid, metrics[1]), arch, new_grid.Nx, Val(method); order)
            #= none:268 =#
            coeff_xᶜᵃᵃ = reconstruction_coefficients(FT, getproperty(new_grid, metrics[2]), arch, new_grid.Nx, Val(method); order)
            #= none:269 =#
            coeff_yᵃᶠᵃ = reconstruction_coefficients(FT, getproperty(new_grid, metrics[3]), arch, new_grid.Ny, Val(method); order)
            #= none:270 =#
            coeff_yᵃᶜᵃ = reconstruction_coefficients(FT, getproperty(new_grid, metrics[4]), arch, new_grid.Ny, Val(method); order)
            #= none:271 =#
            coeff_zᵃᵃᶠ = reconstruction_coefficients(FT, getproperty(new_grid, metrics[5]), arch, new_grid.Nz, Val(method); order)
            #= none:272 =#
            coeff_zᵃᵃᶜ = reconstruction_coefficients(FT, getproperty(new_grid, metrics[6]), arch, new_grid.Nz, Val(method); order)
        end
        #= none:275 =#
        return (coeff_xᶠᵃᵃ, coeff_xᶜᵃᵃ, coeff_yᵃᶠᵃ, coeff_yᵃᶜᵃ, coeff_zᵃᵃᶠ, coeff_zᵃᵃᶜ)
    end
#= none:279 =#
for val = [1, 2, 3]
    #= none:280 =#
    #= none:280 =# @eval begin
            #= none:281 =#
            #= none:281 =# @inline reconstruction_coefficients(FT, coord::OffsetArray{<:Any, <:Any, <:AbstractRange}, arch, N, ::Val{$val}; order) = begin
                        #= none:281 =#
                        nothing
                    end
            #= none:282 =#
            #= none:282 =# @inline reconstruction_coefficients(FT, coord::AbstractRange, arch, N, ::Val{$val}; order) = begin
                        #= none:282 =#
                        nothing
                    end
            #= none:283 =#
            #= none:283 =# @inline reconstruction_coefficients(FT, coord::Nothing, arch, N, ::Val{$val}; order) = begin
                        #= none:283 =#
                        nothing
                    end
            #= none:284 =#
            #= none:284 =# @inline reconstruction_coefficients(FT, coord::Number, arch, N, ::Val{$val}; order) = begin
                        #= none:284 =#
                        nothing
                    end
        end
    #= none:286 =#
end
#= none:289 =#
#= none:289 =# @inline function reconstruction_coefficients(FT, coord, arch, N, ::Val{1}; order)
        #= none:289 =#
        #= none:290 =#
        cpu_coord = on_architecture(CPU(), coord)
        #= none:291 =#
        r = (order + 1) ÷ 2 - 1
        #= none:292 =#
        s = create_reconstruction_coefficients(FT, r, cpu_coord, arch, N; order)
        #= none:293 =#
        return s
    end
#= none:297 =#
#= none:297 =# @inline function reconstruction_coefficients(FT, coord, arch, N, ::Val{2}; order)
        #= none:297 =#
        #= none:298 =#
        cpu_coord = on_architecture(CPU(), coord)
        #= none:299 =#
        rleft = (order + 1) ÷ 2 - 2
        #= none:300 =#
        rright = (order + 1) ÷ 2 - 1
        #= none:301 =#
        s = []
        #= none:302 =#
        for r = [rleft, rright]
            #= none:303 =#
            push!(s, create_reconstruction_coefficients(FT, r, cpu_coord, arch, N; order))
            #= none:304 =#
        end
        #= none:305 =#
        return tuple(s...)
    end
#= none:309 =#
#= none:309 =# @inline function reconstruction_coefficients(FT, coord, arch, N, ::Val{3}; order)
        #= none:309 =#
        #= none:310 =#
        cpu_coord = on_architecture(CPU(), coord)
        #= none:311 =#
        s = []
        #= none:312 =#
        for r = -1:order - 1
            #= none:313 =#
            push!(s, create_reconstruction_coefficients(FT, r, cpu_coord, arch, N; order))
            #= none:314 =#
        end
        #= none:315 =#
        return tuple(s...)
    end
#= none:319 =#
#= none:319 =# @inline function create_reconstruction_coefficients(FT, r, cpu_coord, arch, N; order)
        #= none:319 =#
        #= none:320 =#
        stencil = NTuple{order, FT}[]
        #= none:321 =#
        #= none:321 =# @inbounds begin
                #= none:322 =#
                for i = 0:N + 1
                    #= none:323 =#
                    push!(stencil, stencil_coefficients(i, r, cpu_coord, cpu_coord; order))
                    #= none:324 =#
                end
            end
        #= none:326 =#
        return OffsetArray(on_architecture(arch, stencil), -1)
    end