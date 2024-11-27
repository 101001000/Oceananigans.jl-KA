
#= none:1 =#
using KernelAbstractions.Extras.LoopInfo: @unroll
#= none:10 =#
#= none:10 =# @inline function biased_left_β(ψ, scheme, r, dir, i, location)
        #= none:10 =#
        #= none:11 =#
        #= none:11 =# @inbounds begin
                #= none:12 =#
                stencil = retrieve_left_smooth(scheme, r, dir, i, location)
                #= none:13 =#
                wᵢᵢ = stencil[1]
                #= none:14 =#
                wᵢⱼ = stencil[2]
                #= none:15 =#
                result = 0
                #= none:16 =#
                #= none:16 =# @unroll for j = 1:3
                        #= none:17 =#
                        result += ψ[j] * (wᵢᵢ[j] * ψ[j] + wᵢⱼ[j] * (dagger(ψ))[j])
                        #= none:18 =#
                    end
            end
        #= none:20 =#
        return result
    end
#= none:23 =#
#= none:23 =# @inline function biased_right_β(ψ, scheme, r, dir, i, location)
        #= none:23 =#
        #= none:24 =#
        #= none:24 =# @inbounds begin
                #= none:25 =#
                stencil = retrieve_right_smooth(scheme, r, dir, i, location)
                #= none:26 =#
                wᵢᵢ = stencil[1]
                #= none:27 =#
                wᵢⱼ = stencil[2]
                #= none:28 =#
                result = 0
                #= none:29 =#
                #= none:29 =# @unroll for j = 1:3
                        #= none:30 =#
                        result += ψ[j] * (wᵢᵢ[j] * ψ[j] + wᵢⱼ[j] * (dagger(ψ))[j])
                        #= none:31 =#
                    end
            end
        #= none:33 =#
        return result
    end
#= none:36 =#
#= none:36 =# @inline left_biased_β₀(FT, ψ, T, scheme, args...) = begin
            #= none:36 =#
            biased_left_β(ψ, scheme, 0, args...)
        end
#= none:37 =#
#= none:37 =# @inline left_biased_β₁(FT, ψ, T, scheme, args...) = begin
            #= none:37 =#
            biased_left_β(ψ, scheme, 1, args...)
        end
#= none:38 =#
#= none:38 =# @inline left_biased_β₂(FT, ψ, T, scheme, args...) = begin
            #= none:38 =#
            biased_left_β(ψ, scheme, 2, args...)
        end
#= none:40 =#
#= none:40 =# @inline right_biased_β₀(FT, ψ, T, scheme, args...) = begin
            #= none:40 =#
            biased_right_β(ψ, scheme, 2, args...)
        end
#= none:41 =#
#= none:41 =# @inline right_biased_β₁(FT, ψ, T, scheme, args...) = begin
            #= none:41 =#
            biased_right_β(ψ, scheme, 1, args...)
        end
#= none:42 =#
#= none:42 =# @inline right_biased_β₂(FT, ψ, T, scheme, args...) = begin
            #= none:42 =#
            biased_right_β(ψ, scheme, 0, args...)
        end
#= none:44 =#
#= none:44 =# @inline retrieve_left_smooth(scheme, r, ::Val{1}, i, ::Type{Face}) = begin
            #= none:44 =#
            #= none:44 =# @inbounds (scheme.smooth_xᶠᵃᵃ[r + 1])[i]
        end
#= none:45 =#
#= none:45 =# @inline retrieve_left_smooth(scheme, r, ::Val{1}, i, ::Type{Center}) = begin
            #= none:45 =#
            #= none:45 =# @inbounds (scheme.smooth_xᶜᵃᵃ[r + 1])[i]
        end
#= none:46 =#
#= none:46 =# @inline retrieve_left_smooth(scheme, r, ::Val{2}, i, ::Type{Face}) = begin
            #= none:46 =#
            #= none:46 =# @inbounds (scheme.smooth_yᵃᶠᵃ[r + 1])[i]
        end
#= none:47 =#
#= none:47 =# @inline retrieve_left_smooth(scheme, r, ::Val{2}, i, ::Type{Center}) = begin
            #= none:47 =#
            #= none:47 =# @inbounds (scheme.smooth_yᵃᶜᵃ[r + 1])[i]
        end
#= none:48 =#
#= none:48 =# @inline retrieve_left_smooth(scheme, r, ::Val{3}, i, ::Type{Face}) = begin
            #= none:48 =#
            #= none:48 =# @inbounds (scheme.smooth_zᵃᵃᶠ[r + 1])[i]
        end
#= none:49 =#
#= none:49 =# @inline retrieve_left_smooth(scheme, r, ::Val{3}, i, ::Type{Center}) = begin
            #= none:49 =#
            #= none:49 =# @inbounds (scheme.smooth_zᵃᵃᶜ[r + 1])[i]
        end
#= none:51 =#
#= none:51 =# @inline retrieve_right_smooth(scheme, r, ::Val{1}, i, ::Type{Face}) = begin
            #= none:51 =#
            #= none:51 =# @inbounds (scheme.smooth_xᶠᵃᵃ[r + 4])[i]
        end
#= none:52 =#
#= none:52 =# @inline retrieve_right_smooth(scheme, r, ::Val{1}, i, ::Type{Center}) = begin
            #= none:52 =#
            #= none:52 =# @inbounds (scheme.smooth_xᶜᵃᵃ[r + 4])[i]
        end
#= none:53 =#
#= none:53 =# @inline retrieve_right_smooth(scheme, r, ::Val{2}, i, ::Type{Face}) = begin
            #= none:53 =#
            #= none:53 =# @inbounds (scheme.smooth_yᵃᶠᵃ[r + 4])[i]
        end
#= none:54 =#
#= none:54 =# @inline retrieve_right_smooth(scheme, r, ::Val{2}, i, ::Type{Center}) = begin
            #= none:54 =#
            #= none:54 =# @inbounds (scheme.smooth_yᵃᶜᵃ[r + 4])[i]
        end
#= none:55 =#
#= none:55 =# @inline retrieve_right_smooth(scheme, r, ::Val{3}, i, ::Type{Face}) = begin
            #= none:55 =#
            #= none:55 =# @inbounds (scheme.smooth_zᵃᵃᶠ[r + 4])[i]
        end
#= none:56 =#
#= none:56 =# @inline retrieve_right_smooth(scheme, r, ::Val{3}, i, ::Type{Center}) = begin
            #= none:56 =#
            #= none:56 =# @inbounds (scheme.smooth_zᵃᵃᶜ[r + 4])[i]
        end
#= none:58 =#
#= none:58 =# @inline calc_smoothness_coefficients(FT, ::Val{false}, args...; kwargs...) = begin
            #= none:58 =#
            nothing
        end
#= none:59 =#
#= none:59 =# @inline calc_smoothness_coefficients(FT, ::Val{true}, coord::OffsetArray{<:Any, <:Any, <:AbstractRange}, arch, N; order) = begin
            #= none:59 =#
            nothing
        end
#= none:60 =#
#= none:60 =# @inline calc_smoothness_coefficients(FT, ::Val{true}, coord::AbstractRange, arch, N; order) = begin
            #= none:60 =#
            nothing
        end
#= none:62 =#
function calc_smoothness_coefficients(FT, beta, coord, arch, N; order)
    #= none:62 =#
    #= none:64 =#
    cpu_coord = on_architecture(CPU(), coord)
    #= none:66 =#
    order == 3 || throw(ArgumentError("The stretched smoothness coefficients are only implemented for order == 3"))
    #= none:68 =#
    s1 = create_smoothness_coefficients(FT, 0, -, cpu_coord, arch, N; order)
    #= none:69 =#
    s2 = create_smoothness_coefficients(FT, 1, -, cpu_coord, arch, N; order)
    #= none:70 =#
    s3 = create_smoothness_coefficients(FT, 2, -, cpu_coord, arch, N; order)
    #= none:71 =#
    s4 = create_smoothness_coefficients(FT, 0, +, cpu_coord, arch, N; order)
    #= none:72 =#
    s5 = create_smoothness_coefficients(FT, 1, +, cpu_coord, arch, N; order)
    #= none:73 =#
    s6 = create_smoothness_coefficients(FT, 2, +, cpu_coord, arch, N; order)
    #= none:75 =#
    return (s1, s2, s3, s4, s5, s6)
end
#= none:78 =#
function create_smoothness_coefficients(FT, r, op, cpu_coord, arch, N; order)
    #= none:78 =#
    #= none:81 =#
    stencil = NTuple{2, NTuple{order, FT}}[]
    #= none:82 =#
    #= none:82 =# @inbounds begin
            #= none:83 =#
            for i = 0:N + 1
                #= none:85 =#
                bias1 = Int(op == (+))
                #= none:86 =#
                bias2 = bias1 - 1
                #= none:88 =#
                Δcᵢ = cpu_coord[i + bias1] - cpu_coord[i + bias2]
                #= none:90 =#
                Bᵢ = stencil_coefficients(i, r, cpu_coord, cpu_coord; order, op, shift = bias1, der = Primitive())
                #= none:91 =#
                bᵢ = stencil_coefficients(i, r, cpu_coord, cpu_coord; order, op, shift = bias1)
                #= none:92 =#
                bₓᵢ = stencil_coefficients(i, r, cpu_coord, cpu_coord; order, op, shift = bias1, der = FirstDerivative())
                #= none:93 =#
                Aᵢ = stencil_coefficients(i, r, cpu_coord, cpu_coord; order, op, shift = bias2, der = Primitive())
                #= none:94 =#
                aᵢ = stencil_coefficients(i, r, cpu_coord, cpu_coord; order, op, shift = bias2)
                #= none:95 =#
                aₓᵢ = stencil_coefficients(i, r, cpu_coord, cpu_coord; order, op, shift = bias2, der = FirstDerivative())
                #= none:96 =#
                pₓₓ = stencil_coefficients(i, r, cpu_coord, cpu_coord; order, op, shift = bias1, der = SecondDerivative())
                #= none:98 =#
                Pᵢ = Bᵢ .- Aᵢ
                #= none:100 =#
                wᵢᵢ = Δcᵢ .* ((bᵢ .* bₓᵢ .- aᵢ .* aₓᵢ) .- pₓₓ .* Pᵢ) .+ Δcᵢ ^ 4 .* (pₓₓ .* pₓₓ)
                #= none:101 =#
                wᵢⱼ = Δcᵢ .* ((star(bᵢ, bₓᵢ) .- star(aᵢ, aₓᵢ)) .- star(pₓₓ, Pᵢ)) .+ Δcᵢ ^ 4 .* star(pₓₓ, pₓₓ)
                #= none:103 =#
                push!(stencil, (wᵢᵢ, wᵢⱼ))
                #= none:104 =#
            end
        end
    #= none:107 =#
    return OffsetArray(on_architecture(arch, stencil), -1)
end
#= none:110 =#
#= none:110 =# @inline dagger(ψ) = begin
            #= none:110 =#
            (ψ[2], ψ[3], ψ[1])
        end
#= none:111 =#
#= none:111 =# @inline star(ψ₁, ψ₂) = begin
            #= none:111 =#
            ψ₁ .* dagger(ψ₂) .+ dagger(ψ₁) .* ψ₂
        end