
#= none:1 =#
module Operators
#= none:1 =#
#= none:4 =#
export Δxᶠᶠᶠ, Δxᶠᶠᶜ, Δxᶠᶜᶠ, Δxᶠᶜᶜ, Δxᶜᶠᶠ, Δxᶜᶠᶜ, Δxᶜᶜᶠ, Δxᶜᶜᶜ
#= none:5 =#
export Δyᶠᶠᶠ, Δyᶠᶠᶜ, Δyᶠᶜᶠ, Δyᶠᶜᶜ, Δyᶜᶠᶠ, Δyᶜᶠᶜ, Δyᶜᶜᶠ, Δyᶜᶜᶜ
#= none:6 =#
export Δzᶠᶠᶠ, Δzᶠᶠᶜ, Δzᶠᶜᶠ, Δzᶠᶜᶜ, Δzᶜᶠᶠ, Δzᶜᶠᶜ, Δzᶜᶜᶠ, Δzᶜᶜᶜ
#= none:9 =#
export Axᶠᶠᶠ, Axᶠᶠᶜ, Axᶠᶜᶠ, Axᶠᶜᶜ, Axᶜᶠᶠ, Axᶜᶠᶜ, Axᶜᶜᶠ, Axᶜᶜᶜ
#= none:10 =#
export Ayᶠᶠᶠ, Ayᶠᶠᶜ, Ayᶠᶜᶠ, Ayᶠᶜᶜ, Ayᶜᶠᶠ, Ayᶜᶠᶜ, Ayᶜᶜᶠ, Ayᶜᶜᶜ
#= none:11 =#
export Azᶠᶠᶠ, Azᶠᶠᶜ, Azᶠᶜᶠ, Azᶠᶜᶜ, Azᶜᶠᶠ, Azᶜᶠᶜ, Azᶜᶜᶠ, Azᶜᶜᶜ
#= none:14 =#
export Vᶠᶠᶠ, Vᶠᶠᶜ, Vᶠᶜᶠ, Vᶠᶜᶜ, Vᶜᶠᶠ, Vᶜᶠᶜ, Vᶜᶜᶠ, Vᶜᶜᶜ
#= none:17 =#
export Δx_qᶠᶠᶠ, Δx_qᶠᶠᶜ, Δx_qᶠᶜᶠ, Δx_qᶠᶜᶜ, Δx_qᶜᶠᶠ, Δx_qᶜᶠᶜ, Δx_qᶜᶜᶠ, Δx_qᶜᶜᶜ
#= none:18 =#
export Δy_qᶠᶠᶠ, Δy_qᶠᶠᶜ, Δy_qᶠᶜᶠ, Δy_qᶠᶜᶜ, Δy_qᶜᶠᶠ, Δy_qᶜᶠᶜ, Δy_qᶜᶜᶠ, Δy_qᶜᶜᶜ
#= none:19 =#
export Δz_qᶠᶠᶠ, Δz_qᶠᶠᶜ, Δz_qᶠᶜᶠ, Δz_qᶠᶜᶜ, Δz_qᶜᶠᶠ, Δz_qᶜᶠᶜ, Δz_qᶜᶜᶠ, Δz_qᶜᶜᶜ
#= none:22 =#
export Ax_qᶠᶠᶠ, Ax_qᶠᶠᶜ, Ax_qᶠᶜᶠ, Ax_qᶠᶜᶜ, Ax_qᶜᶠᶠ, Ax_qᶜᶠᶜ, Ax_qᶜᶜᶠ, Ax_qᶜᶜᶜ
#= none:23 =#
export Ay_qᶠᶠᶠ, Ay_qᶠᶠᶜ, Ay_qᶠᶜᶠ, Ay_qᶠᶜᶜ, Ay_qᶜᶠᶠ, Ay_qᶜᶠᶜ, Ay_qᶜᶜᶠ, Ay_qᶜᶜᶜ
#= none:24 =#
export Az_qᶠᶠᶠ, Az_qᶠᶠᶜ, Az_qᶠᶜᶠ, Az_qᶠᶜᶜ, Az_qᶜᶠᶠ, Az_qᶜᶠᶜ, Az_qᶜᶜᶠ, Az_qᶜᶜᶜ
#= none:27 =#
export δxᶜᵃᵃ, δxᶠᵃᵃ, δyᵃᶜᵃ, δyᵃᶠᵃ, δzᵃᵃᶜ, δzᵃᵃᶠ
#= none:28 =#
export δxᶠᶠᶠ, δxᶠᶠᶜ, δxᶠᶜᶠ, δxᶠᶜᶜ, δxᶜᶠᶠ, δxᶜᶠᶜ, δxᶜᶜᶠ, δxᶜᶜᶜ
#= none:29 =#
export δyᶠᶠᶠ, δyᶠᶠᶜ, δyᶠᶜᶠ, δyᶠᶜᶜ, δyᶜᶠᶠ, δyᶜᶠᶜ, δyᶜᶜᶠ, δyᶜᶜᶜ
#= none:30 =#
export δzᶠᶠᶠ, δzᶠᶠᶜ, δzᶠᶜᶠ, δzᶠᶜᶜ, δzᶜᶠᶠ, δzᶜᶠᶜ, δzᶜᶜᶠ, δzᶜᶜᶜ
#= none:33 =#
export ∂xᶠᶠᶠ, ∂xᶠᶠᶜ, ∂xᶠᶜᶠ, ∂xᶠᶜᶜ, ∂xᶜᶠᶠ, ∂xᶜᶠᶜ, ∂xᶜᶜᶠ, ∂xᶜᶜᶜ
#= none:34 =#
export ∂yᶠᶠᶠ, ∂yᶠᶠᶜ, ∂yᶠᶜᶠ, ∂yᶠᶜᶜ, ∂yᶜᶠᶠ, ∂yᶜᶠᶜ, ∂yᶜᶜᶠ, ∂yᶜᶜᶜ
#= none:35 =#
export ∂zᶠᶠᶠ, ∂zᶠᶠᶜ, ∂zᶠᶜᶠ, ∂zᶠᶜᶜ, ∂zᶜᶠᶠ, ∂zᶜᶠᶜ, ∂zᶜᶜᶠ, ∂zᶜᶜᶜ
#= none:37 =#
export ∂²xᶠᶠᶠ, ∂²xᶠᶠᶜ, ∂²xᶠᶜᶠ, ∂²xᶠᶜᶜ, ∂²xᶜᶠᶠ, ∂²xᶜᶠᶜ, ∂²xᶜᶜᶠ, ∂²xᶜᶜᶜ
#= none:38 =#
export ∂²yᶠᶠᶠ, ∂²yᶠᶠᶜ, ∂²yᶠᶜᶠ, ∂²yᶠᶜᶜ, ∂²yᶜᶠᶠ, ∂²yᶜᶠᶜ, ∂²yᶜᶜᶠ, ∂²yᶜᶜᶜ
#= none:39 =#
export ∂²zᶠᶠᶠ, ∂²zᶠᶠᶜ, ∂²zᶠᶜᶠ, ∂²zᶠᶜᶜ, ∂²zᶜᶠᶠ, ∂²zᶜᶠᶜ, ∂²zᶜᶜᶠ, ∂²zᶜᶜᶜ
#= none:41 =#
export ∂³xᶠᶠᶠ, ∂³xᶠᶠᶜ, ∂³xᶠᶜᶠ, ∂³xᶠᶜᶜ, ∂³xᶜᶠᶠ, ∂³xᶜᶠᶜ, ∂³xᶜᶜᶠ, ∂³xᶜᶜᶜ
#= none:42 =#
export ∂³yᶠᶠᶠ, ∂³yᶠᶠᶜ, ∂³yᶠᶜᶠ, ∂³yᶠᶜᶜ, ∂³yᶜᶠᶠ, ∂³yᶜᶠᶜ, ∂³yᶜᶜᶠ, ∂³yᶜᶜᶜ
#= none:43 =#
export ∂³zᶠᶠᶠ, ∂³zᶠᶠᶜ, ∂³zᶠᶜᶠ, ∂³zᶠᶜᶜ, ∂³zᶜᶠᶠ, ∂³zᶜᶠᶜ, ∂³zᶜᶜᶠ, ∂³zᶜᶜᶜ
#= none:45 =#
export ∂⁴xᶠᶠᶠ, ∂⁴xᶠᶠᶜ, ∂⁴xᶠᶜᶠ, ∂⁴xᶠᶜᶜ, ∂⁴xᶜᶠᶠ, ∂⁴xᶜᶠᶜ, ∂⁴xᶜᶜᶠ, ∂⁴xᶜᶜᶜ
#= none:46 =#
export ∂⁴yᶠᶠᶠ, ∂⁴yᶠᶠᶜ, ∂⁴yᶠᶜᶠ, ∂⁴yᶠᶜᶜ, ∂⁴yᶜᶠᶠ, ∂⁴yᶜᶠᶜ, ∂⁴yᶜᶜᶠ, ∂⁴yᶜᶜᶜ
#= none:47 =#
export ∂⁴zᶠᶠᶠ, ∂⁴zᶠᶠᶜ, ∂⁴zᶠᶜᶠ, ∂⁴zᶠᶜᶜ, ∂⁴zᶜᶠᶠ, ∂⁴zᶜᶠᶜ, ∂⁴zᶜᶜᶠ, ∂⁴zᶜᶜᶜ
#= none:50 =#
export Ax_∂xᶠᶠᶠ, Ax_∂xᶠᶠᶜ, Ax_∂xᶠᶜᶠ, Ax_∂xᶠᶜᶜ, Ax_∂xᶜᶠᶠ, Ax_∂xᶜᶠᶜ, Ax_∂xᶜᶜᶠ, Ax_∂xᶜᶜᶜ
#= none:51 =#
export Ay_∂yᶠᶠᶠ, Ay_∂yᶠᶠᶜ, Ay_∂yᶠᶜᶠ, Ay_∂yᶠᶜᶜ, Ay_∂yᶜᶠᶠ, Ay_∂yᶜᶠᶜ, Ay_∂yᶜᶜᶠ, Ay_∂yᶜᶜᶜ
#= none:52 =#
export Az_∂zᶠᶠᶠ, Az_∂zᶠᶠᶜ, Az_∂zᶠᶜᶠ, Az_∂zᶠᶜᶜ, Az_∂zᶜᶠᶠ, Az_∂zᶜᶠᶜ, Az_∂zᶜᶜᶠ, Az_∂zᶜᶜᶜ
#= none:55 =#
export divᶜᶜᶜ, div_xyᶜᶜᶜ, div_xyᶜᶜᶠ, ζ₃ᶠᶠᶜ
#= none:56 =#
export ∇²ᶜᶜᶜ, ∇²ᶠᶜᶜ, ∇²ᶜᶠᶜ, ∇²ᶜᶜᶠ, ∇²hᶜᶜᶜ, ∇²hᶠᶜᶜ, ∇²hᶜᶠᶜ
#= none:59 =#
export ℑxᶜᵃᵃ, ℑxᶠᵃᵃ, ℑyᵃᶜᵃ, ℑyᵃᶠᵃ, ℑzᵃᵃᶜ, ℑzᵃᵃᶠ
#= none:60 =#
export ℑxyᶜᶜᵃ, ℑxyᶠᶜᵃ, ℑxyᶠᶠᵃ, ℑxyᶜᶠᵃ, ℑxzᶜᵃᶜ, ℑxzᶠᵃᶜ, ℑxzᶠᵃᶠ, ℑxzᶜᵃᶠ, ℑyzᵃᶜᶜ, ℑyzᵃᶠᶜ, ℑyzᵃᶠᶠ, ℑyzᵃᶜᶠ
#= none:61 =#
export ℑxyzᶜᶜᶠ, ℑxyzᶜᶠᶜ, ℑxyzᶠᶜᶜ, ℑxyzᶜᶠᶠ, ℑxyzᶠᶜᶠ, ℑxyzᶠᶠᶜ, ℑxyzᶜᶜᶜ, ℑxyzᶠᶠᶠ
#= none:64 =#
export δxTᶠᵃᵃ, δyTᵃᶠᵃ, δxTᶜᵃᵃ, δyTᵃᶜᵃ
#= none:65 =#
export ∂xTᶠᶜᶠ, ∂yTᶜᶠᶠ
#= none:68 =#
export intrinsic_vector, extrinsic_vector
#= none:70 =#
using Oceananigans.Grids
#= none:72 =#
import Oceananigans.Grids: xspacing, yspacing, zspacing
#= none:78 =#
const AG = AbstractGrid
#= none:80 =#
const Δx = xspacing
#= none:81 =#
const Δy = yspacing
#= none:82 =#
const Δz = zspacing
#= none:84 =#
include("difference_operators.jl")
#= none:85 =#
include("interpolation_operators.jl")
#= none:86 =#
include("interpolation_utils.jl")
#= none:88 =#
include("spacings_and_areas_and_volumes.jl")
#= none:89 =#
include("products_between_fields_and_grid_metrics.jl")
#= none:91 =#
include("derivative_operators.jl")
#= none:92 =#
include("divergence_operators.jl")
#= none:93 =#
include("topology_aware_operators.jl")
#= none:94 =#
include("vorticity_operators.jl")
#= none:95 =#
include("laplacian_operators.jl")
#= none:97 =#
include("vector_rotation_operators.jl")
end