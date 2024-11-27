
#= none:1 =#
#= none:1 =# @inline (∇_dot_qᶜ(i, j, k, grid::AbstractGrid{FT}, ::Nothing, args...) where FT) = begin
            #= none:1 =#
            zero(FT)
        end
#= none:2 =#
#= none:2 =# @inline (∂ⱼ_τ₁ⱼ(i, j, k, grid::AbstractGrid{FT}, ::Nothing, args...) where FT) = begin
            #= none:2 =#
            zero(FT)
        end
#= none:3 =#
#= none:3 =# @inline (∂ⱼ_τ₂ⱼ(i, j, k, grid::AbstractGrid{FT}, ::Nothing, args...) where FT) = begin
            #= none:3 =#
            zero(FT)
        end
#= none:4 =#
#= none:4 =# @inline (∂ⱼ_τ₃ⱼ(i, j, k, grid::AbstractGrid{FT}, ::Nothing, args...) where FT) = begin
            #= none:4 =#
            zero(FT)
        end
#= none:6 =#
compute_diffusivities!(diffusivities, ::Nothing, args...; kwargs...) = begin
        #= none:6 =#
        nothing
    end
#= none:7 =#
compute_diffusivities!(::Nothing, ::Nothing, args...; kwargs...) = begin
        #= none:7 =#
        nothing
    end
#= none:9 =#
#= none:9 =# @inline viscosity(::Nothing, ::Nothing) = begin
            #= none:9 =#
            0
        end
#= none:10 =#
#= none:10 =# @inline (diffusivity(::Nothing, ::Nothing, ::Val{id}) where id) = begin
            #= none:10 =#
            0
        end