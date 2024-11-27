
#= none:1 =#
using Oceananigans.Operators: ℑyᵃᶠᵃ, ℑxᶠᵃᵃ
#= none:21 =#
#= none:21 =# Core.@doc " \n`AbstractSmoothnessStencil`s specifies the polynomials used for diagnosing stencils' smoothness for weno weights \ncalculation in the `VectorInvariant` advection formulation. \n\nSmoothness polynomials different from reconstructing polynomials can be specified _only_ for functional reconstructions:\n```julia\n_biased_interpolate_xᶠᵃᵃ(i, j, k, grid, reconstruced_function::F, bias, smoothness_stencil, args...) where F<:Function\n```\n\nFor scalar reconstructions \n```julia\n_biased_interpolate_xᶠᵃᵃ(i, j, k, grid, bias, reconstruced_field::F) where F<:AbstractField\n```\nthe smoothness is _always_ diagnosed from the reconstructing polynomials of `reconstructed_field`\n\nOptions:\n========\n\n- `DefaultStencil`: uses the same polynomials used for reconstruction\n- `VelocityStencil`: is valid _only_ for vorticity reconstruction and diagnoses the smoothness based on \n                     `(Face, Face, Center)` polynomial interpolations of `u` and `v`\n- `FunctionStencil`: allows using a custom function as smoothness indicator. \nThe custom function should share arguments with the reconstructed function. \n\nExample:\n========\n\n```julia\n@inline   smoothness_function(i, j, k, grid, args...) = custom_smoothness_function(i, j, k, grid, args...)\n@inline reconstruced_function(i, j, k, grid, args...) = custom_reconstruction_function(i, j, k, grid, args...)\n\nsmoothness_stencil = FunctionStencil(smoothness_function)    \n```\n" abstract type AbstractSmoothnessStencil end
#= none:57 =#
#= none:57 =# Core.@doc "`DefaultStencil <: AbstractSmoothnessStencil`, see `AbstractSmoothnessStencil`" struct DefaultStencil <: AbstractSmoothnessStencil
        #= none:58 =#
    end
#= none:60 =#
#= none:60 =# Core.@doc "`VelocityStencil <: AbstractSmoothnessStencil`, see `AbstractSmoothnessStencil`" struct VelocityStencil <: AbstractSmoothnessStencil
        #= none:61 =#
    end
#= none:63 =#
#= none:63 =# Core.@doc "`FunctionStencil <: AbstractSmoothnessStencil`, see `AbstractSmoothnessStencil`" struct FunctionStencil{F} <: AbstractSmoothnessStencil
        #= none:65 =#
        func::F
    end
#= none:68 =#
Base.show(io::IO, a::FunctionStencil) = begin
        #= none:68 =#
        print(io, "FunctionStencil f = $(a.func)")
    end
#= none:70 =#
const ƞ = Int32(2)
#= none:71 =#
const ε = 1.0e-8
#= none:75 =#
#= none:75 =# @inline C★(::WENO{2}, ::Val{0}) = begin
            #= none:75 =#
            2 / 3
        end
#= none:76 =#
#= none:76 =# @inline C★(::WENO{2}, ::Val{1}) = begin
            #= none:76 =#
            1 / 3
        end
#= none:78 =#
#= none:78 =# @inline C★(::WENO{3}, ::Val{0}) = begin
            #= none:78 =#
            3 / 10
        end
#= none:79 =#
#= none:79 =# @inline C★(::WENO{3}, ::Val{1}) = begin
            #= none:79 =#
            3 / 5
        end
#= none:80 =#
#= none:80 =# @inline C★(::WENO{3}, ::Val{2}) = begin
            #= none:80 =#
            1 / 10
        end
#= none:82 =#
#= none:82 =# @inline C★(::WENO{4}, ::Val{0}) = begin
            #= none:82 =#
            4 / 35
        end
#= none:83 =#
#= none:83 =# @inline C★(::WENO{4}, ::Val{1}) = begin
            #= none:83 =#
            18 / 35
        end
#= none:84 =#
#= none:84 =# @inline C★(::WENO{4}, ::Val{2}) = begin
            #= none:84 =#
            12 / 35
        end
#= none:85 =#
#= none:85 =# @inline C★(::WENO{4}, ::Val{3}) = begin
            #= none:85 =#
            1 / 35
        end
#= none:87 =#
#= none:87 =# @inline C★(::WENO{5}, ::Val{0}) = begin
            #= none:87 =#
            5 / 126
        end
#= none:88 =#
#= none:88 =# @inline C★(::WENO{5}, ::Val{1}) = begin
            #= none:88 =#
            20 / 63
        end
#= none:89 =#
#= none:89 =# @inline C★(::WENO{5}, ::Val{2}) = begin
            #= none:89 =#
            10 / 21
        end
#= none:90 =#
#= none:90 =# @inline C★(::WENO{5}, ::Val{3}) = begin
            #= none:90 =#
            10 / 63
        end
#= none:91 =#
#= none:91 =# @inline C★(::WENO{5}, ::Val{4}) = begin
            #= none:91 =#
            1 / 126
        end
#= none:93 =#
#= none:93 =# @inline C★(::WENO{6}, ::Val{0}) = begin
            #= none:93 =#
            1 / 77
        end
#= none:94 =#
#= none:94 =# @inline C★(::WENO{6}, ::Val{1}) = begin
            #= none:94 =#
            25 / 154
        end
#= none:95 =#
#= none:95 =# @inline C★(::WENO{6}, ::Val{2}) = begin
            #= none:95 =#
            100 / 231
        end
#= none:96 =#
#= none:96 =# @inline C★(::WENO{6}, ::Val{3}) = begin
            #= none:96 =#
            25 / 77
        end
#= none:97 =#
#= none:97 =# @inline C★(::WENO{6}, ::Val{4}) = begin
            #= none:97 =#
            5 / 77
        end
#= none:98 =#
#= none:98 =# @inline C★(::WENO{6}, ::Val{5}) = begin
            #= none:98 =#
            1 / 462
        end
#= none:101 =#
for buffer = [2, 3, 4, 5, 6]
    #= none:102 =#
    for stencil = collect(0:1:buffer - 1)
        #= none:105 =#
        #= none:105 =# @eval begin
                #= none:106 =#
                #= none:106 =# Core.@doc "    coeff_p(::WENO{buffer, FT}, bias, ::Val{stencil}, T, args...) \n\nReconstruction coefficients for the stencil number `stencil` of a WENO reconstruction \nof order `buffer * 2 - 1`. Uniform coefficients (i.e. when `T == Nothing`) are independent on the\n`bias` of the reconstruction (either `LeftBias` or `RightBias`), while stretched coeffiecients are\nretrieved from the precomputed coefficients via the `retrieve_coeff` function\n" #= none:114 =# @inline((coeff_p(::WENO{$buffer, FT}, bias, ::Val{$stencil}, ::Type{Nothing}, args...) where FT) = begin
                                #= none:114 =#
                                #= none:115 =# @inbounds map(FT, $(stencil_coefficients(50, stencil, collect(1:100), collect(1:100); order = buffer)))
                            end)
                #= none:118 =#
                #= none:118 =# @inline coeff_p(scheme::WENO{$buffer}, bias, ::Val{$stencil}, T, dir, i, loc) = begin
                            #= none:118 =#
                            ifelse(bias isa LeftBias, retrieve_coeff(scheme, $stencil, dir, i, loc), reverse(retrieve_coeff(scheme, $((buffer - 2) - stencil), dir, i, loc)))
                        end
            end
        #= none:124 =#
        #= none:124 =# @eval begin
                #= none:125 =#
                #= none:125 =# Core.@doc " \n    biased_p(scheme::WENO{buffer}, bias, ::Val{stencil}, ψ, T, dir, i, loc)\n\nBiased reconstruction of `ψ` from the stencil `stencil` of a WENO reconstruction of\norder `buffer * 2 - 1`. The reconstruction is calculated as\n\n```math\nψ★ = ∑ᵣ cᵣ ⋅ ψᵣ\n```\n\nwhere ``cᵣ`` is computed from the function `coeff_p`\n" #= none:137 =# @inline(biased_p(scheme::WENO{$buffer}, bias, ::Val{$stencil}, ψ, T, dir, i, loc) = begin
                                #= none:137 =#
                                #= none:138 =# @inbounds sum(coeff_p(scheme, bias, Val($stencil), T, dir, i, loc) .* ψ)
                            end)
            end
        #= none:140 =#
    end
    #= none:141 =#
end
#= none:145 =#
#= none:145 =# Core.@doc "    smoothness_coefficients(::Val{buffer}, ::Val{stencil})\n\nReturn the coefficients used to calculate the smoothness indicators for the stencil \nnumber `stencil` of a WENO reconstruction of order `buffer * 2 - 1`. The coefficients\nare ordered in such a way to calculate the smoothness in the following fashion:\n\n```julia\nbuffer  = 4\nstencil = 0\n\nψ = # The stencil corresponding to S₀ with buffer 4 (7th order WENO)\n\nC = smoothness_coefficients(Val(buffer), Val(0))\n\n# The smoothness indicator\nβ = ψ[1] * (C[1]  * ψ[1] + C[2] * ψ[2] + C[3] * ψ[3] + C[4] * ψ[4]) + \n    ψ[2] * (C[5]  * ψ[2] + C[6] * ψ[3] + C[7] * ψ[4]) + \n    ψ[3] * (C[8]  * ψ[3] + C[9] * ψ[4])\n    ψ[4] * (C[10] * ψ[4])\n```\n\nThis last operation is metaprogrammed in the function `metaprogrammed_smoothness_operation`\n" #= none:169 =# @inline(smoothness_coefficients(::Val{2}, ::Val{0}) = begin
                #= none:169 =#
                :((1, -2, 1))
            end)
#= none:170 =#
#= none:170 =# @inline smoothness_coefficients(::Val{2}, ::Val{1}) = begin
            #= none:170 =#
            :((1, -2, 1))
        end
#= none:172 =#
#= none:172 =# @inline smoothness_coefficients(::Val{3}, ::Val{0}) = begin
            #= none:172 =#
            :((10, -31, 11, 25, -19, 4))
        end
#= none:173 =#
#= none:173 =# @inline smoothness_coefficients(::Val{3}, ::Val{1}) = begin
            #= none:173 =#
            :((4, -13, 5, 13, -13, 4))
        end
#= none:174 =#
#= none:174 =# @inline smoothness_coefficients(::Val{3}, ::Val{2}) = begin
            #= none:174 =#
            :((4, -19, 11, 25, -31, 10))
        end
#= none:176 =#
#= none:176 =# @inline smoothness_coefficients(::Val{4}, ::Val{0}) = begin
            #= none:176 =#
            :((2.107, -9.402, 7.042, -1.854, 11.003, -17.246, 4.642, 7.043, -3.882, 0.547))
        end
#= none:177 =#
#= none:177 =# @inline smoothness_coefficients(::Val{4}, ::Val{1}) = begin
            #= none:177 =#
            :((0.547, -2.522, 1.922, -0.494, 3.443, -5.966, 1.602, 2.843, -1.642, 0.267))
        end
#= none:178 =#
#= none:178 =# @inline smoothness_coefficients(::Val{4}, ::Val{2}) = begin
            #= none:178 =#
            :((0.267, -1.642, 1.602, -0.494, 2.843, -5.966, 1.922, 3.443, -2.522, 0.547))
        end
#= none:179 =#
#= none:179 =# @inline smoothness_coefficients(::Val{4}, ::Val{3}) = begin
            #= none:179 =#
            :((0.547, -3.882, 4.642, -1.854, 7.043, -17.246, 7.042, 11.003, -9.402, 2.107))
        end
#= none:181 =#
#= none:181 =# @inline smoothness_coefficients(::Val{5}, ::Val{0}) = begin
            #= none:181 =#
            :((1.07918, -6.49501, 7.58823, -4.11487, 0.86329, 10.20563, -24.62076, 13.58458, -2.88007, 15.21393, -17.04396, 3.64863, 4.82963, -2.08501, 0.22658))
        end
#= none:182 =#
#= none:182 =# @inline smoothness_coefficients(::Val{5}, ::Val{1}) = begin
            #= none:182 =#
            :((0.22658, -1.40251, 1.65153, -0.88297, 0.18079, 2.42723, -6.11976, 3.37018, -0.70237, 4.06293, -4.64976, 0.99213, 1.38563, -0.60871, 0.06908))
        end
#= none:183 =#
#= none:183 =# @inline smoothness_coefficients(::Val{5}, ::Val{2}) = begin
            #= none:183 =#
            :((0.06908, -0.51001, 0.67923, -0.38947, 0.08209, 1.04963, -2.99076, 1.79098, -0.38947, 2.31153, -2.99076, 0.67923, 1.04963, -0.51001, 0.06908))
        end
#= none:184 =#
#= none:184 =# @inline smoothness_coefficients(::Val{5}, ::Val{3}) = begin
            #= none:184 =#
            :((0.06908, -0.60871, 0.99213, -0.70237, 0.18079, 1.38563, -4.64976, 3.37018, -0.88297, 4.06293, -6.11976, 1.65153, 2.42723, -1.40251, 0.22658))
        end
#= none:185 =#
#= none:185 =# @inline smoothness_coefficients(::Val{5}, ::Val{4}) = begin
            #= none:185 =#
            :((0.22658, -2.08501, 3.64863, -2.88007, 0.86329, 4.82963, -17.04396, 13.58458, -4.11487, 15.21393, -24.62076, 7.58823, 10.20563, -6.49501, 1.07918))
        end
#= none:187 =#
#= none:187 =# @inline smoothness_coefficients(::Val{6}, ::Val{0}) = begin
            #= none:187 =#
            :((0.6150211, -4.7460464, 7.6206736, -6.3394124, 2.706017, -0.471274, 9.4851237, -31.1771244, 26.2901672, -11.3206788, 1.983435, 26.0445372, -44.4003904, 19.2596472, -3.3918804, 19.0757572, -16.6461044, 2.9442256, 3.6480687, -1.2950184, 0.1152561))
        end
#= none:188 =#
#= none:188 =# @inline smoothness_coefficients(::Val{6}, ::Val{1}) = begin
            #= none:188 =#
            :((0.1152561, -0.9117992, 1.474248, -1.2183636, 0.5134574, -0.0880548, 1.9365967, -6.5224244, 5.5053752, -2.3510468, 0.4067018, 5.6662212, -9.7838784, 4.2405032, -0.7408908, 4.3093692, -3.7913324, 0.6694608, 0.8449957, -0.3015728, 0.0271779))
        end
#= none:189 =#
#= none:189 =# @inline smoothness_coefficients(::Val{6}, ::Val{2}) = begin
            #= none:189 =#
            :((0.0271779, -0.23808, 0.4086352, -0.3462252, 0.1458762, -0.024562, 0.5653317, -2.0427884, 1.7905032, -0.7727988, 0.1325006, 1.9510972, -3.5817664, 1.5929912, -0.279266, 1.7195652, -1.5880404, 0.2863984, 0.3824847, -0.1429976, 0.0139633))
        end
#= none:190 =#
#= none:190 =# @inline smoothness_coefficients(::Val{6}, ::Val{3}) = begin
            #= none:190 =#
            :((0.0139633, -0.1429976, 0.2863984, -0.279266, 0.1325006, -0.024562, 0.3824847, -1.5880404, 1.5929912, -0.7727988, 0.1458762, 1.7195652, -3.5817664, 1.7905032, -0.3462252, 1.9510972, -2.0427884, 0.4086352, 0.5653317, -0.23808, 0.0271779))
        end
#= none:191 =#
#= none:191 =# @inline smoothness_coefficients(::Val{6}, ::Val{4}) = begin
            #= none:191 =#
            :((0.0271779, -0.3015728, 0.6694608, -0.7408908, 0.4067018, -0.0880548, 0.8449957, -3.7913324, 4.2405032, -2.3510468, 0.5134574, 4.3093692, -9.7838784, 5.5053752, -1.2183636, 5.6662212, -6.5224244, 1.474248, 1.9365967, -0.9117992, 0.1152561))
        end
#= none:192 =#
#= none:192 =# @inline smoothness_coefficients(::Val{6}, ::Val{5}) = begin
            #= none:192 =#
            :((0.1152561, -1.2950184, 2.9442256, -3.3918804, 1.983435, -0.471274, 3.6480687, -16.6461044, 19.2596472, -11.3206788, 2.706017, 19.0757572, -44.4003904, 26.2901672, -6.3394124, 26.0445372, -31.1771244, 7.6206736, 9.4851237, -4.7460464, 0.6150211))
        end
#= none:202 =#
#= none:202 =# @inline function metaprogrammed_smoothness_operation(buffer)
        #= none:202 =#
        #= none:203 =#
        elem = Vector(undef, buffer)
        #= none:204 =#
        c_idx = 1
        #= none:205 =#
        for stencil = 1:buffer - 1
            #= none:206 =#
            stencil_sum = Expr(:call, :+, (:(C[$((c_idx + i) - stencil)] * ψ[$i]) for i = stencil:buffer)...)
            #= none:207 =#
            elem[stencil] = :(ψ[$stencil] * $stencil_sum)
            #= none:208 =#
            c_idx += (buffer - stencil) + 1
            #= none:209 =#
        end
        #= none:211 =#
        elem[buffer] = :(ψ[$buffer] * ψ[$buffer] * C[$c_idx])
        #= none:213 =#
        return Expr(:call, :+, elem...)
    end
#= none:216 =#
#= none:216 =# Core.@doc "    smoothness_indicator(ψ, scheme::WENO{buffer, FT}, ::Val{stencil})\n\nReturn the smoothness indicator β for the stencil number `stencil` of a WENO reconstruction of order `buffer * 2 - 1`.\nThe smoothness indicator (β) is calculated as follows\n\n```julia\nC = smoothness_coefficients(Val(buffer), Val(stencil))\n\n# The smoothness indicator\nβ = 0\nc_idx = 1\nfor stencil = 1:buffer - 1\n    partial_sum = [C[c_idx + i - stencil)] * ψ[i]) for i in stencil:buffer]\n    β          += ψ[stencil] * partial_sum\n    c_idx += buffer - stencil + 1\nend\n\nβ += ψ[buffer] * ψ[buffer] * C[c_idx])\n```\n\nThis last operation is metaprogrammed in the function `metaprogrammed_smoothness_operation` (to avoid loops)\nand, for `buffer == 3` unrolls into\n\n```julia\nβ = ψ[1] * (C[1]  * ψ[1] + C[2] * ψ[2] + C[3] * ψ[3]) + \n    ψ[2] * (C[4]  * ψ[2] + C[5] * ψ[3]) + \n    ψ[3] * (C[6])\n```\n\nwhile for `buffer == 4` unrolls into\n\n```julia\nβ = ψ[1] * (C[1]  * ψ[1] + C[2] * ψ[2] + C[3] * ψ[3] + C[4] * ψ[4]) + \n    ψ[2] * (C[5]  * ψ[2] + C[6] * ψ[3] + C[7] * ψ[4]) + \n    ψ[3] * (C[8]  * ψ[3] + C[9] * ψ[4])\n    ψ[4] * (C[10] * ψ[4])\n```\n" #= none:255 =# @inline(smoothness_indicator(ψ, args...) = begin
                #= none:255 =#
                zero(ψ[1])
            end)
#= none:258 =#
for buffer = [2, 3, 4, 5, 6]
    #= none:259 =#
    #= none:259 =# @eval #= none:259 =# @inline(smoothness_operation(scheme::WENO{$buffer}, ψ, C) = begin
                    #= none:259 =#
                    #= none:259 =# @inbounds $(metaprogrammed_smoothness_operation(buffer))
                end)
    #= none:261 =#
    for stencil = 0:buffer - 1
        #= none:262 =#
        #= none:262 =# @eval #= none:262 =# @inline((smoothness_indicator(ψ, scheme::WENO{$buffer, FT}, ::Val{$stencil}) where FT) = begin
                        #= none:262 =#
                        smoothness_operation(scheme, ψ, map(FT, $(smoothness_coefficients(Val(buffer), Val(stencil)))))
                    end)
        #= none:264 =#
    end
    #= none:265 =#
end
#= none:268 =#
#= none:268 =# @inline function metaprogrammed_beta_sum(buffer)
        #= none:268 =#
        #= none:269 =#
        elem = Vector(undef, buffer)
        #= none:270 =#
        for stencil = 1:buffer
            #= none:271 =#
            elem[stencil] = :((β₁[$stencil] + β₂[$stencil]) / 2)
            #= none:272 =#
        end
        #= none:274 =#
        return :(($(elem...),))
    end
#= none:278 =#
#= none:278 =# @inline function metaprogrammed_beta_loop(buffer)
        #= none:278 =#
        #= none:279 =#
        elem = Vector(undef, buffer)
        #= none:280 =#
        for stencil = 1:buffer
            #= none:281 =#
            elem[stencil] = :(smoothness_indicator(ψ[$stencil], scheme, Val($(stencil - 1))))
            #= none:282 =#
        end
        #= none:284 =#
        return :(($(elem...),))
    end
#= none:288 =#
#= none:288 =# @inline function metaprogrammed_zweno_alpha_loop(buffer)
        #= none:288 =#
        #= none:289 =#
        elem = Vector(undef, buffer)
        #= none:290 =#
        for stencil = 1:buffer
            #= none:291 =#
            elem[stencil] = :(convert(FT, C★(scheme, Val($(stencil - 1)))) * (1 + (τ / (β[$stencil] + FT(ε))) ^ ƞ))
            #= none:292 =#
        end
        #= none:294 =#
        return :(($(elem...),))
    end
#= none:297 =#
for buffer = [2, 3, 4, 5, 6]
    #= none:298 =#
    #= none:298 =# @eval begin
            #= none:299 =#
            #= none:299 =# @inline (beta_sum(scheme::WENO{$buffer, FT}, β₁, β₂) where FT) = begin
                        #= none:299 =#
                        #= none:299 =# @inbounds $(metaprogrammed_beta_sum(buffer))
                    end
            #= none:300 =#
            #= none:300 =# @inline (beta_loop(scheme::WENO{$buffer, FT}, ψ) where FT) = begin
                        #= none:300 =#
                        #= none:300 =# @inbounds $(metaprogrammed_beta_loop(buffer))
                    end
            #= none:301 =#
            #= none:301 =# @inline (zweno_alpha_loop(scheme::WENO{$buffer, FT}, β, τ) where FT) = begin
                        #= none:301 =#
                        #= none:301 =# @inbounds $(metaprogrammed_zweno_alpha_loop(buffer))
                    end
        end
    #= none:303 =#
end
#= none:306 =#
#= none:306 =# @inline global_smoothness_indicator(::Val{2}, β) = begin
            #= none:306 =#
            #= none:306 =# @inbounds abs(β[1] - β[2])
        end
#= none:307 =#
#= none:307 =# @inline global_smoothness_indicator(::Val{3}, β) = begin
            #= none:307 =#
            #= none:307 =# @inbounds abs(β[1] - β[3])
        end
#= none:308 =#
#= none:308 =# @inline global_smoothness_indicator(::Val{4}, β) = begin
            #= none:308 =#
            #= none:308 =# @inbounds abs(((β[1] + 3 * β[2]) - 3 * β[3]) - β[4])
        end
#= none:309 =#
#= none:309 =# @inline global_smoothness_indicator(::Val{5}, β) = begin
            #= none:309 =#
            #= none:309 =# @inbounds abs(((β[1] + 2 * β[2]) - 6 * β[3]) + 2 * β[4] + β[5])
        end
#= none:310 =#
#= none:310 =# @inline global_smoothness_indicator(::Val{6}, β) = begin
            #= none:310 =#
            #= none:310 =# @inbounds abs((((β[1] + 36 * β[2] + 135 * β[3]) - 135 * β[4]) - 36 * β[5]) - β[6])
        end
#= none:312 =#
#= none:312 =# Core.@doc "    function biased_weno_weights(ψ, scheme::WENO{N, FT}, args...)\n\nBiased weno weights ω used to weight the WENO reconstruction of the different stencils. \nWe use here a Z-WENO formulation where\n\n```math\n    α = C★ ⋅ (1 + τ² / (β + ϵ)²) \n```\n\nwhere \n- ``C★`` is the optimal weight that leads to an upwind reconstruction of order `N * 2 - 1`,\n- ``β`` is the smoothness indicator calculated by the `smoothness_indicator` function\n- ``τ`` is a global smoothness indicator, function of the ``β`` values, calculated by the `global_smoothness_indicator` function\n- ``ϵ`` is a regularization constant, typically equal to 1e-8\n\nThe ``α`` values are normalized before returning\n" #= none:330 =# @inline(function biased_weno_weights(ψ, scheme::WENO{N, FT}, args...) where {N, FT}
            #= none:330 =#
            #= none:331 =#
            β = beta_loop(scheme, ψ)
            #= none:333 =#
            τ = global_smoothness_indicator(Val(N), β)
            #= none:334 =#
            α = zweno_alpha_loop(scheme, β, τ)
            #= none:336 =#
            return α ./ sum(α)
        end)
#= none:339 =#
#= none:339 =# @inline function biased_weno_weights(ijk, scheme::WENO{N, FT}, bias, dir, ::VelocityStencil, u, v) where {N, FT}
        #= none:339 =#
        #= none:340 =#
        (i, j, k) = ijk
        #= none:342 =#
        uₛ = tangential_stencil_u(i, j, k, scheme, bias, dir, u)
        #= none:343 =#
        vₛ = tangential_stencil_v(i, j, k, scheme, bias, dir, v)
        #= none:344 =#
        βᵤ = beta_loop(scheme, uₛ)
        #= none:345 =#
        βᵥ = beta_loop(scheme, vₛ)
        #= none:346 =#
        β = beta_sum(scheme, βᵤ, βᵥ)
        #= none:348 =#
        τ = global_smoothness_indicator(Val(N), β)
        #= none:349 =#
        α = zweno_alpha_loop(scheme, β, τ)
        #= none:351 =#
        return α ./ sum(α)
    end
#= none:354 =#
#= none:354 =# Core.@doc " \n    load_weno_stencil(buffer, shift, dir, func::Bool = false)\n\nStencils for WENO reconstruction calculations\n\nThe first argument is the `buffer`, not the `order`! \n- `order = 2 * buffer - 1` for WENO reconstruction\n   \nExamples\n========\n\n```jldoctest\njulia> using Oceananigans.Advection: load_weno_stencil\n\njulia> load_weno_stencil(3, :x)\n:((ψ[i + -3, j, k], ψ[i + -2, j, k], ψ[i + -1, j, k], ψ[i + 0, j, k], ψ[i + 1, j, k], ψ[i + 2, j, k]))\n\njulia> load_weno_stencil(2, :x)\n:((ψ[i + -2, j, k], ψ[i + -1, j, k], ψ[i + 0, j, k], ψ[i + 1, j, k]))\n\n" #= none:375 =# @inline(function load_weno_stencil(buffer, dir, func::Bool = false)
            #= none:375 =#
            #= none:376 =#
            N = buffer * 2 - 1
            #= none:377 =#
            stencil = Vector(undef, N + 1)
            #= none:379 =#
            for (idx, c) = enumerate(-buffer:buffer - 1)
                #= none:380 =#
                if func
                    #= none:381 =#
                    stencil[idx] = if dir == :x
                            #= line 0 =#
                            :(ψ(i + $c, j, k, args...))
                        else
                            if dir == :y
                                #= line 0 =#
                                :(ψ(i, j + $c, k, args...))
                            else
                                #= line 0 =#
                                :(ψ(i, j, k + $c, args...))
                            end
                        end
                else
                    #= none:387 =#
                    stencil[idx] = if dir == :x
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
                #= none:393 =#
            end
            #= none:395 =#
            return :(($(stencil...),))
        end)
#= none:400 =#
for dir = (:x, :y, :z), (T, f) = zip((:Any, :Function), (false, true))
    #= none:401 =#
    stencil = Symbol(:weno_stencil_, dir)
    #= none:402 =#
    #= none:402 =# @eval begin
            #= none:403 =#
            #= none:403 =# @inline function $stencil(i, j, k, ::WENO{2}, bias, ψ::$T, args...)
                    #= none:403 =#
                    #= none:404 =#
                    S = #= none:404 =# @inbounds($(load_weno_stencil(2, dir, f)))
                    #= none:405 =#
                    return (S₀₂(S, bias), S₁₂(S, bias))
                end
            #= none:408 =#
            #= none:408 =# @inline function $stencil(i, j, k, ::WENO{3}, bias, ψ::$T, args...)
                    #= none:408 =#
                    #= none:409 =#
                    S = #= none:409 =# @inbounds($(load_weno_stencil(3, dir, f)))
                    #= none:410 =#
                    return (S₀₃(S, bias), S₁₃(S, bias), S₂₃(S, bias))
                end
            #= none:413 =#
            #= none:413 =# @inline function $stencil(i, j, k, ::WENO{4}, bias, ψ::$T, args...)
                    #= none:413 =#
                    #= none:414 =#
                    S = #= none:414 =# @inbounds($(load_weno_stencil(4, dir, f)))
                    #= none:415 =#
                    return (S₀₄(S, bias), S₁₄(S, bias), S₂₄(S, bias), S₃₄(S, bias))
                end
            #= none:418 =#
            #= none:418 =# @inline function $stencil(i, j, k, ::WENO{5}, bias, ψ::$T, args...)
                    #= none:418 =#
                    #= none:419 =#
                    S = #= none:419 =# @inbounds($(load_weno_stencil(5, dir, f)))
                    #= none:420 =#
                    return (S₀₅(S, bias), S₁₅(S, bias), S₂₅(S, bias), S₃₅(S, bias), S₄₅(S, bias))
                end
            #= none:423 =#
            #= none:423 =# @inline function $stencil(i, j, k, ::WENO{6}, bias, ψ::$T, args...)
                    #= none:423 =#
                    #= none:424 =#
                    S = #= none:424 =# @inbounds($(load_weno_stencil(6, dir, f)))
                    #= none:425 =#
                    return (S₀₆(S, bias), S₁₆(S, bias), S₂₆(S, bias), S₃₆(S, bias), S₄₆(S, bias), S₅₆(S, bias))
                end
        end
    #= none:428 =#
end
#= none:431 =#
#= none:431 =# @inline S₀₂(S, bias) = begin
            #= none:431 =#
            #= none:431 =# @inbounds ifelse(bias isa LeftBias, (S[2], S[3]), (S[3], S[2]))
        end
#= none:432 =#
#= none:432 =# @inline S₁₂(S, bias) = begin
            #= none:432 =#
            #= none:432 =# @inbounds ifelse(bias isa LeftBias, (S[1], S[2]), (S[4], S[3]))
        end
#= none:434 =#
#= none:434 =# @inline S₀₃(S, bias) = begin
            #= none:434 =#
            #= none:434 =# @inbounds ifelse(bias isa LeftBias, (S[3], S[4], S[5]), (S[4], S[3], S[2]))
        end
#= none:435 =#
#= none:435 =# @inline S₁₃(S, bias) = begin
            #= none:435 =#
            #= none:435 =# @inbounds ifelse(bias isa LeftBias, (S[2], S[3], S[4]), (S[5], S[4], S[3]))
        end
#= none:436 =#
#= none:436 =# @inline S₂₃(S, bias) = begin
            #= none:436 =#
            #= none:436 =# @inbounds ifelse(bias isa LeftBias, (S[1], S[2], S[3]), (S[6], S[5], S[4]))
        end
#= none:438 =#
#= none:438 =# @inline S₀₄(S, bias) = begin
            #= none:438 =#
            #= none:438 =# @inbounds ifelse(bias isa LeftBias, (S[4], S[5], S[6], S[7]), (S[5], S[4], S[3], S[2]))
        end
#= none:439 =#
#= none:439 =# @inline S₁₄(S, bias) = begin
            #= none:439 =#
            #= none:439 =# @inbounds ifelse(bias isa LeftBias, (S[3], S[4], S[5], S[6]), (S[6], S[5], S[4], S[3]))
        end
#= none:440 =#
#= none:440 =# @inline S₂₄(S, bias) = begin
            #= none:440 =#
            #= none:440 =# @inbounds ifelse(bias isa LeftBias, (S[2], S[3], S[4], S[5]), (S[7], S[6], S[5], S[4]))
        end
#= none:441 =#
#= none:441 =# @inline S₃₄(S, bias) = begin
            #= none:441 =#
            #= none:441 =# @inbounds ifelse(bias isa LeftBias, (S[1], S[2], S[3], S[4]), (S[8], S[7], S[6], S[5]))
        end
#= none:443 =#
#= none:443 =# @inline S₀₅(S, bias) = begin
            #= none:443 =#
            #= none:443 =# @inbounds ifelse(bias isa LeftBias, (S[5], S[6], S[7], S[8], S[9]), (S[6], S[5], S[4], S[3], S[2]))
        end
#= none:444 =#
#= none:444 =# @inline S₁₅(S, bias) = begin
            #= none:444 =#
            #= none:444 =# @inbounds ifelse(bias isa LeftBias, (S[4], S[5], S[6], S[7], S[8]), (S[7], S[6], S[5], S[4], S[3]))
        end
#= none:445 =#
#= none:445 =# @inline S₂₅(S, bias) = begin
            #= none:445 =#
            #= none:445 =# @inbounds ifelse(bias isa LeftBias, (S[3], S[4], S[5], S[6], S[7]), (S[8], S[7], S[6], S[5], S[4]))
        end
#= none:446 =#
#= none:446 =# @inline S₃₅(S, bias) = begin
            #= none:446 =#
            #= none:446 =# @inbounds ifelse(bias isa LeftBias, (S[2], S[3], S[4], S[5], S[6]), (S[9], S[8], S[7], S[6], S[5]))
        end
#= none:447 =#
#= none:447 =# @inline S₄₅(S, bias) = begin
            #= none:447 =#
            #= none:447 =# @inbounds ifelse(bias isa LeftBias, (S[1], S[2], S[3], S[4], S[5]), (S[10], S[9], S[8], S[7], S[6]))
        end
#= none:449 =#
#= none:449 =# @inline S₀₆(S, bias) = begin
            #= none:449 =#
            #= none:449 =# @inbounds ifelse(bias isa LeftBias, (S[6], S[7], S[8], S[9], S[10], S[11]), (S[7], S[6], S[5], S[4], S[3], S[2]))
        end
#= none:450 =#
#= none:450 =# @inline S₁₆(S, bias) = begin
            #= none:450 =#
            #= none:450 =# @inbounds ifelse(bias isa LeftBias, (S[5], S[6], S[7], S[8], S[9], S[10]), (S[8], S[7], S[6], S[5], S[4], S[3]))
        end
#= none:451 =#
#= none:451 =# @inline S₂₆(S, bias) = begin
            #= none:451 =#
            #= none:451 =# @inbounds ifelse(bias isa LeftBias, (S[4], S[5], S[6], S[7], S[8], S[9]), (S[9], S[8], S[7], S[6], S[5], S[4]))
        end
#= none:452 =#
#= none:452 =# @inline S₃₆(S, bias) = begin
            #= none:452 =#
            #= none:452 =# @inbounds ifelse(bias isa LeftBias, (S[3], S[4], S[5], S[6], S[7], S[8]), (S[10], S[9], S[8], S[7], S[6], S[5]))
        end
#= none:453 =#
#= none:453 =# @inline S₄₆(S, bias) = begin
            #= none:453 =#
            #= none:453 =# @inbounds ifelse(bias isa LeftBias, (S[2], S[3], S[4], S[5], S[6], S[7]), (S[11], S[10], S[9], S[8], S[7], S[6]))
        end
#= none:454 =#
#= none:454 =# @inline S₅₆(S, bias) = begin
            #= none:454 =#
            #= none:454 =# @inbounds ifelse(bias isa LeftBias, (S[1], S[2], S[3], S[4], S[5], S[6]), (S[12], S[11], S[10], S[9], S[8], S[7]))
        end
#= none:458 =#
#= none:458 =# @inline tangential_stencil_u(i, j, k, scheme, bias, ::Val{1}, u) = begin
            #= none:458 =#
            #= none:458 =# @inbounds weno_stencil_x(i, j, k, scheme, bias, ℑyᵃᶠᵃ, u)
        end
#= none:459 =#
#= none:459 =# @inline tangential_stencil_u(i, j, k, scheme, bias, ::Val{2}, u) = begin
            #= none:459 =#
            #= none:459 =# @inbounds weno_stencil_y(i, j, k, scheme, bias, ℑyᵃᶠᵃ, u)
        end
#= none:460 =#
#= none:460 =# @inline tangential_stencil_v(i, j, k, scheme, bias, ::Val{1}, v) = begin
            #= none:460 =#
            #= none:460 =# @inbounds weno_stencil_x(i, j, k, scheme, bias, ℑxᶠᵃᵃ, v)
        end
#= none:461 =#
#= none:461 =# @inline tangential_stencil_v(i, j, k, scheme, bias, ::Val{2}, v) = begin
            #= none:461 =#
            #= none:461 =# @inbounds weno_stencil_y(i, j, k, scheme, bias, ℑxᶠᵃᵃ, v)
        end
#= none:464 =#
#= none:464 =# @inline function metaprogrammed_weno_reconstruction(buffer)
        #= none:464 =#
        #= none:465 =#
        elem = Vector(undef, buffer)
        #= none:466 =#
        for stencil = 1:buffer
            #= none:467 =#
            elem[stencil] = :(ω[$stencil] * biased_p(scheme, bias, Val($(stencil - 1)), ψ[$stencil], cT, Val(val), idx, loc))
            #= none:468 =#
        end
        #= none:470 =#
        return Expr(:call, :+, elem...)
    end
#= none:473 =#
#= none:473 =# Core.@doc "    weno_reconstruction(scheme::WENO{buffer}, bias, ψ, ω, cT, val, idx, loc)\n\n`bias`ed reconstruction of stencils `ψ` for a WENO scheme of order `buffer * 2 - 1` weighted by WENO\nweights `ω`. `ψ` is a `Tuple` of `buffer` stencils of size `buffer` and `ω` is a `Tuple` of size `buffer`\ncontaining the computed weights for each of the reconstruction stencils. \n\nThe additional inputs are only used for stretched WENO directions that require the knowledge of the location `loc`\nand the index `idx`.\n\nThe calculation of the reconstruction is metaprogrammed in the `metaprogrammed_weno_reconstruction` function which, for\n`buffer == 4` (seventh order WENO), unrolls to:\n\n```julia\nψ̂ = ω[1] * biased_p(scheme, bias, Val(0), ψ[1], cT, Val(val), idx, loc) + \n    ω[2] * biased_p(scheme, bias, Val(1), ψ[2], cT, Val(val), idx, loc) + \n    ω[3] * biased_p(scheme, bias, Val(2), ψ[3], cT, Val(val), idx, loc) + \n    ω[4] * biased_p(scheme, bias, Val(3), ψ[4], cT, Val(val), idx, loc))\n```\n\nHere, [`biased_p`](@ref) is the function that computes the linear reconstruction of the individual stencils.\n" #= none:495 =# @inline(weno_reconstruction(scheme, bias, ψ, args...) = begin
                #= none:495 =#
                zero((ψ[1])[1])
            end)
#= none:498 =#
for buffer = [2, 3, 4, 5, 6]
    #= none:499 =#
    #= none:499 =# @eval #= none:499 =# @inline(weno_reconstruction(scheme::WENO{$buffer}, bias, ψ, ω, cT, val, idx, loc) = begin
                    #= none:499 =#
                    #= none:499 =# @inbounds $(metaprogrammed_weno_reconstruction(buffer))
                end)
    #= none:500 =#
end
#= none:503 =#
for (interp, dir, val, cT) = zip([:xᶠᵃᵃ, :yᵃᶠᵃ, :zᵃᵃᶠ], [:x, :y, :z], [1, 2, 3], [:XT, :YT, :ZT])
    #= none:504 =#
    interpolate_func = Symbol(:inner_biased_interpolate_, interp)
    #= none:505 =#
    stencil = Symbol(:weno_stencil_, dir)
    #= none:507 =#
    #= none:507 =# @eval begin
            #= none:508 =#
            #= none:508 =# @inline function $interpolate_func(i, j, k, grid, scheme::WENO{N, FT, XT, YT, ZT}, bias, ψ, idx, loc, args...) where {N, FT, XT, YT, ZT}
                    #= none:508 =#
                    #= none:512 =#
                    ψₜ = $stencil(i, j, k, scheme, bias, ψ, grid, args...)
                    #= none:513 =#
                    ω = biased_weno_weights(ψₜ, scheme, bias, Val($val), Nothing, args...)
                    #= none:514 =#
                    return weno_reconstruction(scheme, bias, ψₜ, ω, $cT, $val, idx, loc)
                end
            #= none:517 =#
            #= none:517 =# @inline function $interpolate_func(i, j, k, grid, scheme::WENO{N, FT, XT, YT, ZT}, bias, ψ, idx, loc, VI::AbstractSmoothnessStencil, args...) where {N, FT, XT, YT, ZT}
                    #= none:517 =#
                    #= none:521 =#
                    ψₜ = $stencil(i, j, k, scheme, bias, ψ, grid, args...)
                    #= none:522 =#
                    ω = biased_weno_weights(ψₜ, scheme, bias, Val($val), VI, args...)
                    #= none:523 =#
                    return weno_reconstruction(scheme, bias, ψₜ, ω, $cT, $val, idx, loc)
                end
            #= none:526 =#
            #= none:526 =# @inline function $interpolate_func(i, j, k, grid, scheme::WENO{N, FT, XT, YT, ZT}, bias, ψ, idx, loc, VI::VelocityStencil, u, v, args...) where {N, FT, XT, YT, ZT}
                    #= none:526 =#
                    #= none:530 =#
                    ψₜ = $stencil(i, j, k, scheme, bias, ψ, grid, u, v, args...)
                    #= none:531 =#
                    ω = biased_weno_weights((i, j, k), scheme, bias, Val($val), VI, u, v)
                    #= none:532 =#
                    return weno_reconstruction(scheme, bias, ψₜ, ω, $cT, $val, idx, loc)
                end
            #= none:535 =#
            #= none:535 =# @inline function $interpolate_func(i, j, k, grid, scheme::WENO{N, FT, XT, YT, ZT}, bias, ψ, idx, loc, VI::FunctionStencil, args...) where {N, FT, XT, YT, ZT}
                    #= none:535 =#
                    #= none:539 =#
                    ψₜ = $stencil(i, j, k, scheme, bias, ψ, grid, args...)
                    #= none:540 =#
                    ψₛ = $stencil(i, j, k, scheme, bias, VI.func, grid, args...)
                    #= none:541 =#
                    ω = biased_weno_weights(ψₛ, scheme, bias, Val($val), VI, args...)
                    #= none:542 =#
                    return weno_reconstruction(scheme, bias, ψₜ, ω, $cT, $val, idx, loc)
                end
        end
    #= none:545 =#
end