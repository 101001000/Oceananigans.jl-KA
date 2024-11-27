
#= none:5 =#
function min_Δxyz(grid, ::ThreeDimensionalFormulation)
    #= none:5 =#
    #= none:6 =#
    Δx = minimum_xspacing(grid, Center(), Center(), Center())
    #= none:7 =#
    Δy = minimum_yspacing(grid, Center(), Center(), Center())
    #= none:8 =#
    Δz = minimum_zspacing(grid, Center(), Center(), Center())
    #= none:9 =#
    return min(Δx, Δy, Δz)
end
#= none:12 =#
function min_Δxyz(grid, ::HorizontalFormulation)
    #= none:12 =#
    #= none:13 =#
    Δx = minimum_xspacing(grid, Center(), Center(), Center())
    #= none:14 =#
    Δy = minimum_yspacing(grid, Center(), Center(), Center())
    #= none:15 =#
    return min(Δx, Δy)
end
#= none:18 =#
min_Δxyz(grid, ::VerticalFormulation) = begin
        #= none:18 =#
        minimum_zspacing(grid, Center(), Center(), Center())
    end
#= none:21 =#
cell_diffusion_timescale(model) = begin
        #= none:21 =#
        cell_diffusion_timescale(model.closure, model.diffusivity_fields, model.grid)
    end
#= none:22 =#
cell_diffusion_timescale(::Nothing, diffusivities, grid) = begin
        #= none:22 =#
        Inf
    end
#= none:24 =#
maximum_numeric_diffusivity(κ::Number) = begin
        #= none:24 =#
        κ
    end
#= none:25 =#
maximum_numeric_diffusivity(κ::FunctionField) = begin
        #= none:25 =#
        maximum(κ)
    end
#= none:26 =#
maximum_numeric_diffusivity(κ_tuple::NamedTuple) = begin
        #= none:26 =#
        maximum((maximum_numeric_diffusivity(κ) for κ = κ_tuple))
    end
#= none:27 =#
maximum_numeric_diffusivity(κ::NamedTuple{()}) = begin
        #= none:27 =#
        0
    end
#= none:28 =#
maximum_numeric_diffusivity(::Nothing) = begin
        #= none:28 =#
        0
    end
#= none:31 =#
maximum_numeric_diffusivity(κ::Function) = begin
        #= none:31 =#
        0
    end
#= none:33 =#
function cell_diffusion_timescale(closure::ScalarDiffusivity{TD, Dir}, diffusivities, grid) where {TD, Dir}
    #= none:33 =#
    #= none:34 =#
    Δ = min_Δxyz(grid, formulation(closure))
    #= none:35 =#
    max_κ = maximum_numeric_diffusivity(closure.κ)
    #= none:36 =#
    max_ν = maximum_numeric_diffusivity(closure.ν)
    #= none:37 =#
    return min(Δ ^ 2 / max_ν, Δ ^ 2 / max_κ)
end
#= none:40 =#
function cell_diffusion_timescale(closure::ScalarBiharmonicDiffusivity{Dir}, diffusivities, grid) where Dir
    #= none:40 =#
    #= none:41 =#
    Δ = min_Δxyz(grid, formulation(closure))
    #= none:42 =#
    max_κ = maximum_numeric_diffusivity(closure.κ)
    #= none:43 =#
    max_ν = maximum_numeric_diffusivity(closure.ν)
    #= none:44 =#
    return min(Δ ^ 4 / max_ν, Δ ^ 4 / max_κ)
end
#= none:47 =#
function cell_diffusion_timescale(closure::SmagorinskyLilly, diffusivities, grid)
    #= none:47 =#
    #= none:48 =#
    Δ = min_Δxyz(grid, formulation(closure))
    #= none:49 =#
    min_Pr = if closure.Pr isa NamedTuple{()}
            1
        else
            minimum(closure.Pr)
        end
    #= none:50 =#
    max_νκ = maximum(diffusivities.νₑ.data.parent) * max(1, 1 / min_Pr)
    #= none:51 =#
    return Δ ^ 2 / max_νκ
end
#= none:54 =#
function cell_diffusion_timescale(closure::AnisotropicMinimumDissipation, diffusivities, grid)
    #= none:54 =#
    #= none:55 =#
    Δ = min_Δxyz(grid, formulation(closure))
    #= none:56 =#
    max_ν = maximum(diffusivities.νₑ.data.parent)
    #= none:57 =#
    max_κ = if diffusivities.κₑ isa NamedTuple{()}
            Inf
        else
            max(Tuple((maximum(κₑ.data.parent) for κₑ = diffusivities.κₑ))...)
        end
    #= none:58 =#
    return min(Δ ^ 2 / max_ν, Δ ^ 2 / max_κ)
end
#= none:61 =#
function cell_diffusion_timescale(closure::TwoDimensionalLeith, diffusivities, grid)
    #= none:61 =#
    #= none:62 =#
    Δ = min_Δxyz(grid, ThreeDimensionalFormulation())
    #= none:63 =#
    max_ν = maximum(diffusivities.νₑ.data.parent)
    #= none:64 =#
    return Δ ^ 2 / max_ν
end
#= none:68 =#
cell_diffusion_timescale(::ConvectiveAdjustmentVerticalDiffusivity{<:VerticallyImplicitTimeDiscretization}, diffusivities, grid) = begin
        #= none:68 =#
        Inf
    end
#= none:71 =#
cell_diffusion_timescale(closure::Tuple, diffusivity_fields, grid) = begin
        #= none:71 =#
        minimum((cell_diffusion_timescale(c, diffusivities, grid) for (c, diffusivities) = zip(closure, diffusivity_fields)))
    end