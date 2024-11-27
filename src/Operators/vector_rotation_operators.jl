
#= none:4 =#
#= none:4 =# @inline getvalue(::Nothing, i, j, k, grid, args...) = begin
            #= none:4 =#
            nothing
        end
#= none:5 =#
#= none:5 =# @inline getvalue(a::Number, i, j, k, grid, args...) = begin
            #= none:5 =#
            a
        end
#= none:6 =#
#= none:6 =# @inline getvalue(a::AbstractArray, i, j, k, grid, args...) = begin
            #= none:6 =#
            #= none:6 =# @inbounds a[i, j, k]
        end
#= none:8 =#
#= none:8 =# Core.@doc "    intrinsic_vector(i, j, k, grid::AbstractGrid, uₑ, vₑ, wₑ)\n\nConvert the three-dimensional vector with components `uₑ, vₑ, wₑ` defined in an _extrinsic_ \ncoordinate system associated with the domain, to the coordinate system _intrinsic_ to the grid.\n\n_extrinsic_ coordinate systems are:\n\n- Cartesian for any grid that discretizes a Cartesian domain (e.g. a `RectilinearGrid`)\n- Geographic coordinates for any grid that discretizes a Spherical domain (e.g. an `AbstractCurvilinearGrid`)\n\nTherefore, for the [`RectilinearGrid`](@ref) and the [`LatitudeLongitudeGrid`](@ref), the _extrinsic_ and the \n_intrinsic_ coordinate system are equivalent. However, for other grids (e.g., for the\n [`ConformalCubedSphereGrid`](@ref)) that might not be the case.\n" #= none:23 =# @inline(intrinsic_vector(i, j, k, grid::AbstractGrid, uₑ, vₑ, wₑ) = begin
                #= none:23 =#
                (getvalue(uₑ, i, j, k, grid), getvalue(vₑ, i, j, k, grid), getvalue(wₑ, i, j, k, grid))
            end)
#= none:26 =#
#= none:26 =# Core.@doc "    extrinsic_vector(i, j, k, grid::AbstractGrid, uᵢ, vᵢ, wᵢ)\n\nConvert the three-dimensional vector with components `uᵢ, vᵢ, wᵢ ` defined on the _intrinsic_ coordinate\nsystem of the grid, to the _extrinsic_ coordinate system associated with the domain.\n\n_extrinsic_ coordinate systems are:\n\n- Cartesian for any grid that discretizes a Cartesian domain (e.g. a `RectilinearGrid`)\n- Geographic coordinates for any grid that discretizes a Spherical domain (e.g. an `AbstractCurvilinearGrid`)\n\nTherefore, for the [`RectilinearGrid`](@ref) and the [`LatitudeLongitudeGrid`](@ref), the _extrinsic_ and the \n_intrinsic_ coordinate systems are equivalent. However, for other grids (e.g., for the\n [`ConformalCubedSphereGrid`](@ref)) that might not be the case.\n" #= none:41 =# @inline(extrinsic_vector(i, j, k, grid::AbstractGrid, uᵢ, vᵢ, wᵢ) = begin
                #= none:41 =#
                (getvalue(uᵢ, i, j, k, grid), getvalue(vᵢ, i, j, k, grid), getvalue(wᵢ, i, j, k, grid))
            end)
#= none:45 =#
#= none:45 =# @inline intrinsic_vector(i, j, k, grid::AbstractGrid, uₑ, vₑ) = begin
            #= none:45 =#
            (getvalue(uₑ, i, j, k, grid), getvalue(vₑ, i, j, k, grid))
        end
#= none:48 =#
#= none:48 =# @inline extrinsic_vector(i, j, k, grid::AbstractGrid, uᵢ, vᵢ) = begin
            #= none:48 =#
            (getvalue(uᵢ, i, j, k, grid), getvalue(vᵢ, i, j, k, grid))
        end
#= none:58 =#
#= none:58 =# @inline function intrinsic_vector(i, j, k, grid::OrthogonalSphericalShellGrid, uₑ, vₑ)
        #= none:58 =#
        #= none:60 =#
        φᶜᶠᵃ₊ = φnode(i, j + 1, 1, grid, Center(), Face(), Center())
        #= none:61 =#
        φᶜᶠᵃ₋ = φnode(i, j, 1, grid, Center(), Face(), Center())
        #= none:62 =#
        Δyᶜᶜᵃ = Δyᶜᶜᶜ(i, j, 1, grid)
        #= none:65 =#
        Rcosθᵢ = deg2rad(φᶜᶠᵃ₊ - φᶜᶠᵃ₋) / Δyᶜᶜᵃ
        #= none:67 =#
        φᶠᶜᵃ₊ = φnode(i + 1, j, 1, grid, Face(), Center(), Center())
        #= none:68 =#
        φᶠᶜᵃ₋ = φnode(i, j, 1, grid, Face(), Center(), Center())
        #= none:69 =#
        Δxᶜᶜᵃ = Δxᶜᶜᶜ(i, j, 1, grid)
        #= none:71 =#
        Rsinθᵢ = -(deg2rad(φᶠᶜᵃ₊ - φᶠᶜᵃ₋)) / Δxᶜᶜᵃ
        #= none:74 =#
        Rᵢ = sqrt(Rcosθᵢ ^ 2 + Rsinθᵢ ^ 2)
        #= none:76 =#
        u = getvalue(uₑ, i, j, k, grid)
        #= none:77 =#
        v = getvalue(vₑ, i, j, k, grid)
        #= none:79 =#
        cosθᵢ = Rcosθᵢ / Rᵢ
        #= none:80 =#
        sinθᵢ = Rsinθᵢ / Rᵢ
        #= none:82 =#
        uᵢ = u * cosθᵢ + v * sinθᵢ
        #= none:83 =#
        vᵢ = -u * sinθᵢ + v * cosθᵢ
        #= none:85 =#
        return (uᵢ, vᵢ)
    end
#= none:89 =#
#= none:89 =# @inline function intrinsic_vector(i, j, k, grid::OrthogonalSphericalShellGrid, uₑ, vₑ, wₑ)
        #= none:89 =#
        #= none:91 =#
        (uᵢ, vᵢ) = intrinsic_vector(i, j, k, grid, uₑ, vₑ)
        #= none:92 =#
        wᵢ = getvalue(wₑ, i, j, k, grid)
        #= none:94 =#
        return (uᵢ, vᵢ, wᵢ)
    end
#= none:98 =#
#= none:98 =# @inline function extrinsic_vector(i, j, k, grid::OrthogonalSphericalShellGrid, uᵢ, vᵢ)
        #= none:98 =#
        #= none:100 =#
        φᶜᶠᵃ₊ = φnode(i, j + 1, 1, grid, Center(), Face(), Center())
        #= none:101 =#
        φᶜᶠᵃ₋ = φnode(i, j, 1, grid, Center(), Face(), Center())
        #= none:102 =#
        Δyᶜᶜᵃ = Δyᶜᶜᶜ(i, j, 1, grid)
        #= none:105 =#
        Rcosθₑ = deg2rad(φᶜᶠᵃ₊ - φᶜᶠᵃ₋) / Δyᶜᶜᵃ
        #= none:107 =#
        φᶠᶜᵃ₊ = φnode(i + 1, j, 1, grid, Face(), Center(), Center())
        #= none:108 =#
        φᶠᶜᵃ₋ = φnode(i, j, 1, grid, Face(), Center(), Center())
        #= none:109 =#
        Δxᶜᶜᵃ = Δxᶜᶜᶜ(i, j, 1, grid)
        #= none:111 =#
        Rsinθₑ = -(deg2rad(φᶠᶜᵃ₊ - φᶠᶜᵃ₋)) / Δxᶜᶜᵃ
        #= none:114 =#
        Rₑ = sqrt(Rcosθₑ ^ 2 + Rsinθₑ ^ 2)
        #= none:116 =#
        u = getvalue(uᵢ, i, j, k, grid)
        #= none:117 =#
        v = getvalue(vᵢ, i, j, k, grid)
        #= none:119 =#
        cosθₑ = Rcosθₑ / Rₑ
        #= none:120 =#
        sinθₑ = Rsinθₑ / Rₑ
        #= none:122 =#
        uₑ = u * cosθₑ - v * sinθₑ
        #= none:123 =#
        vₑ = u * sinθₑ + v * cosθₑ
        #= none:125 =#
        return (uₑ, vₑ)
    end
#= none:129 =#
#= none:129 =# @inline function extrinsic_vector(i, j, k, grid::OrthogonalSphericalShellGrid, uᵢ, vᵢ, wᵢ)
        #= none:129 =#
        #= none:131 =#
        (uₑ, vₑ) = intrinsic_vector(i, j, k, grid, uᵢ, vᵢ)
        #= none:132 =#
        wₑ = getvalue(wᵢ, i, j, k, grid)
        #= none:134 =#
        return (uₑ, vₑ, wₑ)
    end