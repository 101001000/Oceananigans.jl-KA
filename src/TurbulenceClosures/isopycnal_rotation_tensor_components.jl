
#= none:3 =#
#= none:3 =# Core.@doc "    AbstractIsopycnalTensor\n\nAbstract supertype for an isopycnal rotation model.\n" abstract type AbstractIsopycnalTensor end
#= none:10 =#
#= none:10 =# Core.@doc "    struct IsopycnalTensor{FT} <: AbstractIsopycnalTensor\n\nA tensor that rotates a vector into the isopycnal plane using the local slopes\nof the buoyancy field.\n\nSlopes are computed via `slope_x = - ∂b/∂x / ∂b/∂z` and `slope_y = - ∂b/∂y / ∂b/∂z`,\nwith the negative sign to account for the stable stratification (`∂b/∂z < 0`).\nThen, the components of the isopycnal rotation tensor are:\n\n```\n               ⎡     1 + slope_y²         - slope_x slope_y      slope_x ⎤ \n(1 + slope²)⁻¹ | - slope_x slope_y          1 + slope_x²         slope_y |\n               ⎣       slope_x                 slope_y            slope² ⎦\n```\n\nwhere `slope² = slope_x² + slope_y²`.\n" struct IsopycnalTensor{FT} <: AbstractIsopycnalTensor
        #= none:29 =#
        minimum_bz::FT
    end
#= none:32 =#
#= none:32 =# Core.@doc "    struct SmallSlopeIsopycnalTensor{FT} <: AbstractIsopycnalTensor\n\nA tensor that rotates a vector into the isopycnal plane using the local slopes\nof the buoyancy field and employing the small-slope approximation, i.e., that\nthe horizontal isopycnal slopes, `slope_x` and `slope_y` are ``≪ 1``. Slopes are\ncomputed via `slope_x = - ∂b/∂x / ∂b/∂z` and `slope_y = - ∂b/∂y / ∂b/∂z`, with\nthe negative sign to account for the stable stratification (`∂b/∂z < 0`). Then,\nby utilizing the small-slope appoximation, the components of the isopycnal\nrotation tensor are:\n\n```\n⎡   1            0         slope_x ⎤ \n|   0            1         slope_y |\n⎣ slope_x      slope_y      slope² ⎦\n```\n\nwhere `slope² = slope_x² + slope_y²`.\n\nThe slopes are tapered using the `slope_limiter.max_slope`, i.e., the tapering factor is\n`min(1, slope_limiter.max_slope² / slope²)`, where `slope² = slope_x² + slope_y²`\nthat multiplies all components of the isopycnal slope tensor.\n\nReferences\n==========\nR. Gerdes, C. Koberle, and J. Willebrand. (1991), \"The influence of numerical advection schemes\n    on the results of ocean general circulation models\", Clim. Dynamics, 5 (4), 211–226.\n" struct SmallSlopeIsopycnalTensor{FT} <: AbstractIsopycnalTensor
        #= none:61 =#
        minimum_bz::FT
    end
#= none:64 =#
SmallSlopeIsopycnalTensor(FT::DataType = Float64; minimum_bz = FT(0)) = begin
        #= none:64 =#
        SmallSlopeIsopycnalTensor(minimum_bz)
    end
#= none:66 =#
#= none:66 =# @inline function isopycnal_rotation_tensor_xz_fcc(i, j, k, grid::AbstractGrid, buoyancy, tracers, slope_model::SmallSlopeIsopycnalTensor)
        #= none:66 =#
        #= none:68 =#
        bx = ∂x_b(i, j, k, grid, buoyancy, tracers)
        #= none:69 =#
        by = ℑxyᶠᶜᵃ(i, j, k, grid, ∂y_b, buoyancy, tracers)
        #= none:70 =#
        bz = ℑxzᶠᵃᶜ(i, j, k, grid, ∂z_b, buoyancy, tracers)
        #= none:71 =#
        bz = max(bz, slope_model.minimum_bz)
        #= none:73 =#
        slope_x = -bx / bz
        #= none:75 =#
        return ifelse(bz == 0, zero(grid), slope_x)
    end
#= none:78 =#
#= none:78 =# @inline function isopycnal_rotation_tensor_xz_ccf(i, j, k, grid::AbstractGrid, buoyancy, tracers, slope_model::SmallSlopeIsopycnalTensor)
        #= none:78 =#
        #= none:81 =#
        bx = ℑxzᶜᵃᶠ(i, j, k, grid, ∂x_b, buoyancy, tracers)
        #= none:82 =#
        bz = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:83 =#
        bz = max(bz, slope_model.minimum_bz)
        #= none:85 =#
        slope_x = -bx / bz
        #= none:87 =#
        return ifelse(bz == 0, zero(grid), slope_x)
    end
#= none:90 =#
#= none:90 =# @inline function isopycnal_rotation_tensor_yz_cfc(i, j, k, grid::AbstractGrid, buoyancy, tracers, slope_model::SmallSlopeIsopycnalTensor)
        #= none:90 =#
        #= none:93 =#
        by = ∂y_b(i, j, k, grid, buoyancy, tracers)
        #= none:94 =#
        bz = ℑyzᵃᶠᶜ(i, j, k, grid, ∂z_b, buoyancy, tracers)
        #= none:95 =#
        bz = max(bz, slope_model.minimum_bz)
        #= none:97 =#
        slope_y = -by / bz
        #= none:99 =#
        return ifelse(bz == 0, zero(grid), slope_y)
    end
#= none:102 =#
#= none:102 =# @inline function isopycnal_rotation_tensor_yz_ccf(i, j, k, grid::AbstractGrid, buoyancy, tracers, slope_model::SmallSlopeIsopycnalTensor)
        #= none:102 =#
        #= none:105 =#
        by = ℑyzᵃᶜᶠ(i, j, k, grid, ∂y_b, buoyancy, tracers)
        #= none:106 =#
        bz = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:107 =#
        bz = max(bz, slope_model.minimum_bz)
        #= none:109 =#
        slope_y = -by / bz
        #= none:111 =#
        return ifelse(bz == 0, zero(grid), slope_y)
    end
#= none:114 =#
#= none:114 =# @inline function isopycnal_rotation_tensor_zz_ccf(i, j, k, grid::AbstractGrid, buoyancy, tracers, slope_model::SmallSlopeIsopycnalTensor)
        #= none:114 =#
        #= none:117 =#
        bx = ℑxzᶜᵃᶠ(i, j, k, grid, ∂x_b, buoyancy, tracers)
        #= none:118 =#
        by = ℑyzᵃᶜᶠ(i, j, k, grid, ∂y_b, buoyancy, tracers)
        #= none:119 =#
        bz = ∂z_b(i, j, k, grid, buoyancy, tracers)
        #= none:120 =#
        bz = max(bz, slope_model.minimum_bz)
        #= none:122 =#
        slope_x = -bx / bz
        #= none:123 =#
        slope_y = -by / bz
        #= none:124 =#
        slope² = slope_x ^ 2 + slope_y ^ 2
        #= none:126 =#
        return ifelse(bz == 0, zero(grid), slope²)
    end