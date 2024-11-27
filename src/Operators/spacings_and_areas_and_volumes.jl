
#= none:1 =#
using Oceananigans.Grids: Center, Face
#= none:3 =#
const RG = RectilinearGrid
#= none:4 =#
const RGX = XRegularRG
#= none:5 =#
const RGY = YRegularRG
#= none:6 =#
const RGZ = ZRegularRG
#= none:8 =#
const OSSG = OrthogonalSphericalShellGrid
#= none:9 =#
const OSSGZ = ZRegOrthogonalSphericalShellGrid
#= none:11 =#
const LLG = LatitudeLongitudeGrid
#= none:12 =#
const LLGX = XRegularLLG
#= none:13 =#
const LLGY = YRegularLLG
#= none:14 =#
const LLGZ = ZRegularLLG
#= none:17 =#
const LLGF = LatitudeLongitudeGrid{<:Any, <:Any, <:Any, <:Any, <:Nothing}
#= none:18 =#
const LLGFX = LatitudeLongitudeGrid{<:Any, <:Any, <:Any, <:Any, <:Nothing, <:Any, <:Number}
#= none:19 =#
const LLGFY = LatitudeLongitudeGrid{<:Any, <:Any, <:Any, <:Any, <:Nothing, <:Any, <:Any, <:Number}
#= none:21 =#
#= none:21 =# @inline hack_cosd(φ) = begin
            #= none:21 =#
            cos((π * φ) / 180)
        end
#= none:22 =#
#= none:22 =# @inline hack_sind(φ) = begin
            #= none:22 =#
            sin((π * φ) / 180)
        end
#= none:24 =#
"Notes:\nThis file defines grid lengths, areas, and volumes for staggered structured grids.\nEach \"reference cell\" is associated with an index i, j, k.\nThe \"location\" of each reference cell is roughly the geometric centroid of the reference cell.\nOn the staggered grid, there are 7 cells additional to the \"reference cell\"\nthat are staggered with respect to the reference cell in x, y, and/or z.\n\nThe staggering is denoted by the locations \"Center\" and \"Face\":\n  - \"Center\" is shared with the reference cell;\n  - \"Face\" lies between reference cell centers, roughly at the interface between\n    reference cells.\n\nThe three-dimensional location of an object is defined by a 3-tuple of locations, and\ndenoted by a triplet of superscripts. For example, an object `φ` whose cell is located at\n(Center, Center, Face) is denoted `φᶜᶜᶠ`. `ᶜᶜᶠ` is Centered in `x`, `Centered` in `y`, and on\nreference cell interfaces in `z` (this is where the vertical velocity is located, for example).\n\nThe operators in this file fall into three categories:\n\n1. Operators needed for an algorithm valid on rectilinear grids with\n   at most a stretched vertical dimension and regular horizontal dimensions.\n2. Operators needed for an algorithm on a grid that is curvilinear in the horizontal\n   at rectilinear (possibly stretched) in the vertical.\n"
#= none:56 =#
#= none:56 =# @inline Δxᶠᵃᵃ(i, j, k, grid) = begin
            #= none:56 =#
            nothing
        end
#= none:57 =#
#= none:57 =# @inline Δxᶜᵃᵃ(i, j, k, grid) = begin
            #= none:57 =#
            nothing
        end
#= none:58 =#
#= none:58 =# @inline Δyᵃᶠᵃ(i, j, k, grid) = begin
            #= none:58 =#
            nothing
        end
#= none:59 =#
#= none:59 =# @inline Δyᵃᶜᵃ(i, j, k, grid) = begin
            #= none:59 =#
            nothing
        end
#= none:61 =#
const ZRG = Union{LLGZ, RGZ}
#= none:63 =#
#= none:63 =# @inline Δzᵃᵃᶠ(i, j, k, grid) = begin
            #= none:63 =#
            #= none:63 =# @inbounds grid.Δzᵃᵃᶠ[k]
        end
#= none:64 =#
#= none:64 =# @inline Δzᵃᵃᶜ(i, j, k, grid) = begin
            #= none:64 =#
            #= none:64 =# @inbounds grid.Δzᵃᵃᶜ[k]
        end
#= none:66 =#
#= none:66 =# @inline Δzᵃᵃᶠ(i, j, k, grid::ZRG) = begin
            #= none:66 =#
            grid.Δzᵃᵃᶠ
        end
#= none:67 =#
#= none:67 =# @inline Δzᵃᵃᶜ(i, j, k, grid::ZRG) = begin
            #= none:67 =#
            grid.Δzᵃᵃᶜ
        end
#= none:69 =#
#= none:69 =# @inline Δzᵃᵃᶜ(i, j, k, grid::OSSG) = begin
            #= none:69 =#
            #= none:69 =# @inbounds grid.Δzᵃᵃᶜ[k]
        end
#= none:70 =#
#= none:70 =# @inline Δzᵃᵃᶠ(i, j, k, grid::OSSG) = begin
            #= none:70 =#
            #= none:70 =# @inbounds grid.Δzᵃᵃᶠ[k]
        end
#= none:72 =#
#= none:72 =# @inline Δzᵃᵃᶜ(i, j, k, grid::OSSGZ) = begin
            #= none:72 =#
            grid.Δzᵃᵃᶜ
        end
#= none:73 =#
#= none:73 =# @inline Δzᵃᵃᶠ(i, j, k, grid::OSSGZ) = begin
            #= none:73 =#
            grid.Δzᵃᵃᶠ
        end
#= none:76 =#
for LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ)
    #= none:78 =#
    x_spacing_1D = Symbol(:Δx, LX, :ᵃ, :ᵃ)
    #= none:79 =#
    x_spacing_2D = Symbol(:Δx, LX, LY, :ᵃ)
    #= none:81 =#
    y_spacing_1D = Symbol(:Δy, :ᵃ, LY, :ᵃ)
    #= none:82 =#
    y_spacing_2D = Symbol(:Δy, LX, LY, :ᵃ)
    #= none:84 =#
    #= none:84 =# @eval begin
            #= none:85 =#
            #= none:85 =# @inline $x_spacing_2D(i, j, k, grid) = begin
                        #= none:85 =#
                        $x_spacing_1D(i, j, k, grid)
                    end
            #= none:86 =#
            #= none:86 =# @inline $y_spacing_2D(i, j, k, grid) = begin
                        #= none:86 =#
                        $y_spacing_1D(i, j, k, grid)
                    end
        end
    #= none:89 =#
    for LZ = (:ᶜ, :ᶠ)
        #= none:90 =#
        x_spacing_3D = Symbol(:Δx, LX, LY, LZ)
        #= none:91 =#
        y_spacing_3D = Symbol(:Δy, LX, LY, LZ)
        #= none:93 =#
        z_spacing_1D = Symbol(:Δz, :ᵃ, :ᵃ, LZ)
        #= none:94 =#
        z_spacing_3D = Symbol(:Δz, LX, LY, LZ)
        #= none:96 =#
        #= none:96 =# @eval begin
                #= none:97 =#
                #= none:97 =# @inline $x_spacing_3D(i, j, k, grid) = begin
                            #= none:97 =#
                            $x_spacing_2D(i, j, k, grid)
                        end
                #= none:98 =#
                #= none:98 =# @inline $y_spacing_3D(i, j, k, grid) = begin
                            #= none:98 =#
                            $y_spacing_2D(i, j, k, grid)
                        end
                #= none:99 =#
                #= none:99 =# @inline $z_spacing_3D(i, j, k, grid) = begin
                            #= none:99 =#
                            $z_spacing_1D(i, j, k, grid)
                        end
            end
        #= none:101 =#
    end
    #= none:102 =#
end
#= none:108 =#
#= none:108 =# @inline Δxᶠᵃᵃ(i, j, k, grid::RG) = begin
            #= none:108 =#
            #= none:108 =# @inbounds grid.Δxᶠᵃᵃ[i]
        end
#= none:109 =#
#= none:109 =# @inline Δxᶜᵃᵃ(i, j, k, grid::RG) = begin
            #= none:109 =#
            #= none:109 =# @inbounds grid.Δxᶜᵃᵃ[i]
        end
#= none:110 =#
#= none:110 =# @inline Δyᵃᶠᵃ(i, j, k, grid::RG) = begin
            #= none:110 =#
            #= none:110 =# @inbounds grid.Δyᵃᶠᵃ[j]
        end
#= none:111 =#
#= none:111 =# @inline Δyᵃᶜᵃ(i, j, k, grid::RG) = begin
            #= none:111 =#
            #= none:111 =# @inbounds grid.Δyᵃᶜᵃ[j]
        end
#= none:113 =#
#= none:113 =# @inline Δxᶠᵃᵃ(i, j, k, grid::RGX) = begin
            #= none:113 =#
            grid.Δxᶠᵃᵃ
        end
#= none:114 =#
#= none:114 =# @inline Δxᶜᵃᵃ(i, j, k, grid::RGX) = begin
            #= none:114 =#
            grid.Δxᶜᵃᵃ
        end
#= none:115 =#
#= none:115 =# @inline Δyᵃᶠᵃ(i, j, k, grid::RGY) = begin
            #= none:115 =#
            grid.Δyᵃᶠᵃ
        end
#= none:116 =#
#= none:116 =# @inline Δyᵃᶜᵃ(i, j, k, grid::RGY) = begin
            #= none:116 =#
            grid.Δyᵃᶜᵃ
        end
#= none:124 =#
#= none:124 =# @inline Δxᶜᶠᵃ(i, j, k, grid::LLG) = begin
            #= none:124 =#
            #= none:124 =# @inbounds grid.Δxᶜᶠᵃ[i, j]
        end
#= none:125 =#
#= none:125 =# @inline Δxᶠᶜᵃ(i, j, k, grid::LLG) = begin
            #= none:125 =#
            #= none:125 =# @inbounds grid.Δxᶠᶜᵃ[i, j]
        end
#= none:126 =#
#= none:126 =# @inline Δxᶠᶠᵃ(i, j, k, grid::LLG) = begin
            #= none:126 =#
            #= none:126 =# @inbounds grid.Δxᶠᶠᵃ[i, j]
        end
#= none:127 =#
#= none:127 =# @inline Δxᶜᶜᵃ(i, j, k, grid::LLG) = begin
            #= none:127 =#
            #= none:127 =# @inbounds grid.Δxᶜᶜᵃ[i, j]
        end
#= none:128 =#
#= none:128 =# @inline Δxᶠᶜᵃ(i, j, k, grid::LLGX) = begin
            #= none:128 =#
            #= none:128 =# @inbounds grid.Δxᶠᶜᵃ[j]
        end
#= none:129 =#
#= none:129 =# @inline Δxᶜᶠᵃ(i, j, k, grid::LLGX) = begin
            #= none:129 =#
            #= none:129 =# @inbounds grid.Δxᶜᶠᵃ[j]
        end
#= none:130 =#
#= none:130 =# @inline Δxᶠᶠᵃ(i, j, k, grid::LLGX) = begin
            #= none:130 =#
            #= none:130 =# @inbounds grid.Δxᶠᶠᵃ[j]
        end
#= none:131 =#
#= none:131 =# @inline Δxᶜᶜᵃ(i, j, k, grid::LLGX) = begin
            #= none:131 =#
            #= none:131 =# @inbounds grid.Δxᶜᶜᵃ[j]
        end
#= none:133 =#
#= none:133 =# @inline Δyᶜᶠᵃ(i, j, k, grid::LLG) = begin
            #= none:133 =#
            #= none:133 =# @inbounds grid.Δyᶜᶠᵃ[j]
        end
#= none:134 =#
#= none:134 =# @inline Δyᶠᶜᵃ(i, j, k, grid::LLG) = begin
            #= none:134 =#
            #= none:134 =# @inbounds grid.Δyᶠᶜᵃ[j]
        end
#= none:135 =#
#= none:135 =# @inline Δyᶜᶠᵃ(i, j, k, grid::LLGY) = begin
            #= none:135 =#
            grid.Δyᶜᶠᵃ
        end
#= none:136 =#
#= none:136 =# @inline Δyᶠᶜᵃ(i, j, k, grid::LLGY) = begin
            #= none:136 =#
            grid.Δyᶠᶜᵃ
        end
#= none:137 =#
#= none:137 =# @inline Δyᶜᶜᵃ(i, j, k, grid::LLG) = begin
            #= none:137 =#
            Δyᶠᶜᵃ(i, j, k, grid)
        end
#= none:138 =#
#= none:138 =# @inline Δyᶠᶠᵃ(i, j, k, grid::LLG) = begin
            #= none:138 =#
            Δyᶜᶠᵃ(i, j, k, grid)
        end
#= none:142 =#
#= none:142 =# @inline Δxᶠᶜᵃ(i, j, k, grid::LLGF) = begin
            #= none:142 =#
            #= none:142 =# @inbounds grid.radius * deg2rad(grid.Δλᶠᵃᵃ[i]) * hack_cosd(grid.φᵃᶜᵃ[j])
        end
#= none:143 =#
#= none:143 =# @inline Δxᶜᶠᵃ(i, j, k, grid::LLGF) = begin
            #= none:143 =#
            #= none:143 =# @inbounds grid.radius * deg2rad(grid.Δλᶜᵃᵃ[i]) * hack_cosd(grid.φᵃᶠᵃ[j])
        end
#= none:144 =#
#= none:144 =# @inline Δxᶠᶠᵃ(i, j, k, grid::LLGF) = begin
            #= none:144 =#
            #= none:144 =# @inbounds grid.radius * deg2rad(grid.Δλᶠᵃᵃ[i]) * hack_cosd(grid.φᵃᶠᵃ[j])
        end
#= none:145 =#
#= none:145 =# @inline Δxᶜᶜᵃ(i, j, k, grid::LLGF) = begin
            #= none:145 =#
            #= none:145 =# @inbounds grid.radius * deg2rad(grid.Δλᶜᵃᵃ[i]) * hack_cosd(grid.φᵃᶜᵃ[j])
        end
#= none:146 =#
#= none:146 =# @inline Δxᶠᶜᵃ(i, j, k, grid::LLGFX) = begin
            #= none:146 =#
            #= none:146 =# @inbounds grid.radius * deg2rad(grid.Δλᶠᵃᵃ) * hack_cosd(grid.φᵃᶜᵃ[j])
        end
#= none:147 =#
#= none:147 =# @inline Δxᶜᶠᵃ(i, j, k, grid::LLGFX) = begin
            #= none:147 =#
            #= none:147 =# @inbounds grid.radius * deg2rad(grid.Δλᶜᵃᵃ) * hack_cosd(grid.φᵃᶠᵃ[j])
        end
#= none:148 =#
#= none:148 =# @inline Δxᶠᶠᵃ(i, j, k, grid::LLGFX) = begin
            #= none:148 =#
            #= none:148 =# @inbounds grid.radius * deg2rad(grid.Δλᶠᵃᵃ) * hack_cosd(grid.φᵃᶠᵃ[j])
        end
#= none:149 =#
#= none:149 =# @inline Δxᶜᶜᵃ(i, j, k, grid::LLGFX) = begin
            #= none:149 =#
            #= none:149 =# @inbounds grid.radius * deg2rad(grid.Δλᶜᵃᵃ) * hack_cosd(grid.φᵃᶜᵃ[j])
        end
#= none:151 =#
#= none:151 =# @inline Δyᶜᶠᵃ(i, j, k, grid::LLGF) = begin
            #= none:151 =#
            #= none:151 =# @inbounds grid.radius * deg2rad(grid.Δφᵃᶠᵃ[j])
        end
#= none:152 =#
#= none:152 =# @inline Δyᶠᶜᵃ(i, j, k, grid::LLGF) = begin
            #= none:152 =#
            #= none:152 =# @inbounds grid.radius * deg2rad(grid.Δφᵃᶜᵃ[j])
        end
#= none:153 =#
#= none:153 =# @inline Δyᶜᶠᵃ(i, j, k, grid::LLGFY) = begin
            #= none:153 =#
            grid.radius * deg2rad(grid.Δφᵃᶠᵃ)
        end
#= none:154 =#
#= none:154 =# @inline Δyᶠᶜᵃ(i, j, k, grid::LLGFY) = begin
            #= none:154 =#
            grid.radius * deg2rad(grid.Δφᵃᶜᵃ)
        end
#= none:160 =#
#= none:160 =# @inline Δxᶜᶜᵃ(i, j, k, grid::OSSG) = begin
            #= none:160 =#
            #= none:160 =# @inbounds grid.Δxᶜᶜᵃ[i, j]
        end
#= none:161 =#
#= none:161 =# @inline Δxᶠᶜᵃ(i, j, k, grid::OSSG) = begin
            #= none:161 =#
            #= none:161 =# @inbounds grid.Δxᶠᶜᵃ[i, j]
        end
#= none:162 =#
#= none:162 =# @inline Δxᶜᶠᵃ(i, j, k, grid::OSSG) = begin
            #= none:162 =#
            #= none:162 =# @inbounds grid.Δxᶜᶠᵃ[i, j]
        end
#= none:163 =#
#= none:163 =# @inline Δxᶠᶠᵃ(i, j, k, grid::OSSG) = begin
            #= none:163 =#
            #= none:163 =# @inbounds grid.Δxᶠᶠᵃ[i, j]
        end
#= none:165 =#
#= none:165 =# @inline Δyᶜᶜᵃ(i, j, k, grid::OSSG) = begin
            #= none:165 =#
            #= none:165 =# @inbounds grid.Δyᶜᶜᵃ[i, j]
        end
#= none:166 =#
#= none:166 =# @inline Δyᶠᶜᵃ(i, j, k, grid::OSSG) = begin
            #= none:166 =#
            #= none:166 =# @inbounds grid.Δyᶠᶜᵃ[i, j]
        end
#= none:167 =#
#= none:167 =# @inline Δyᶜᶠᵃ(i, j, k, grid::OSSG) = begin
            #= none:167 =#
            #= none:167 =# @inbounds grid.Δyᶜᶠᵃ[i, j]
        end
#= none:168 =#
#= none:168 =# @inline Δyᶠᶠᵃ(i, j, k, grid::OSSG) = begin
            #= none:168 =#
            #= none:168 =# @inbounds grid.Δyᶠᶠᵃ[i, j]
        end
#= none:176 =#
for LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ)
    #= none:178 =#
    x_spacing_2D = Symbol(:Δx, LX, LY, :ᵃ)
    #= none:179 =#
    y_spacing_2D = Symbol(:Δy, LX, LY, :ᵃ)
    #= none:180 =#
    z_area_2D = Symbol(:Az, LX, LY, :ᵃ)
    #= none:182 =#
    #= none:182 =# @eval $z_area_2D(i, j, k, grid) = begin
                #= none:182 =#
                $x_spacing_2D(i, j, k, grid) * $y_spacing_2D(i, j, k, grid)
            end
    #= none:184 =#
    for LZ = (:ᶜ, :ᶠ)
        #= none:185 =#
        x_spacing_3D = Symbol(:Δx, LX, LY, LZ)
        #= none:186 =#
        y_spacing_3D = Symbol(:Δy, LX, LY, LZ)
        #= none:187 =#
        z_spacing_3D = Symbol(:Δz, LX, LY, LZ)
        #= none:189 =#
        x_area_3D = Symbol(:Ax, LX, LY, LZ)
        #= none:190 =#
        y_area_3D = Symbol(:Ay, LX, LY, LZ)
        #= none:191 =#
        z_area_3D = Symbol(:Az, LX, LY, LZ)
        #= none:193 =#
        #= none:193 =# @eval begin
                #= none:194 =#
                #= none:194 =# @inline $x_area_3D(i, j, k, grid) = begin
                            #= none:194 =#
                            $y_spacing_3D(i, j, k, grid) * $z_spacing_3D(i, j, k, grid)
                        end
                #= none:195 =#
                #= none:195 =# @inline $y_area_3D(i, j, k, grid) = begin
                            #= none:195 =#
                            $x_spacing_3D(i, j, k, grid) * $z_spacing_3D(i, j, k, grid)
                        end
                #= none:196 =#
                #= none:196 =# @inline $z_area_3D(i, j, k, grid) = begin
                            #= none:196 =#
                            $z_area_2D(i, j, k, grid)
                        end
            end
        #= none:198 =#
    end
    #= none:199 =#
end
#= none:206 =#
#= none:206 =# @inline Azᶠᶜᵃ(i, j, k, grid::LLGF) = begin
            #= none:206 =#
            #= none:206 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶠᵃᵃ[i]) * (hack_sind(grid.φᵃᶠᵃ[j + 1]) - hack_sind(grid.φᵃᶠᵃ[j]))
        end
#= none:207 =#
#= none:207 =# @inline Azᶜᶠᵃ(i, j, k, grid::LLGF) = begin
            #= none:207 =#
            #= none:207 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶜᵃᵃ[i]) * (hack_sind(grid.φᵃᶜᵃ[j]) - hack_sind(grid.φᵃᶜᵃ[j - 1]))
        end
#= none:208 =#
#= none:208 =# @inline Azᶠᶠᵃ(i, j, k, grid::LLGF) = begin
            #= none:208 =#
            #= none:208 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶠᵃᵃ[i]) * (hack_sind(grid.φᵃᶜᵃ[j]) - hack_sind(grid.φᵃᶜᵃ[j - 1]))
        end
#= none:209 =#
#= none:209 =# @inline Azᶜᶜᵃ(i, j, k, grid::LLGF) = begin
            #= none:209 =#
            #= none:209 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶜᵃᵃ[i]) * (hack_sind(grid.φᵃᶠᵃ[j + 1]) - hack_sind(grid.φᵃᶠᵃ[j]))
        end
#= none:210 =#
#= none:210 =# @inline Azᶠᶜᵃ(i, j, k, grid::LLGFX) = begin
            #= none:210 =#
            #= none:210 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶠᵃᵃ) * (hack_sind(grid.φᵃᶠᵃ[j + 1]) - hack_sind(grid.φᵃᶠᵃ[j]))
        end
#= none:211 =#
#= none:211 =# @inline Azᶜᶠᵃ(i, j, k, grid::LLGFX) = begin
            #= none:211 =#
            #= none:211 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶜᵃᵃ) * (hack_sind(grid.φᵃᶜᵃ[j]) - hack_sind(grid.φᵃᶜᵃ[j - 1]))
        end
#= none:212 =#
#= none:212 =# @inline Azᶠᶠᵃ(i, j, k, grid::LLGFX) = begin
            #= none:212 =#
            #= none:212 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶠᵃᵃ) * (hack_sind(grid.φᵃᶜᵃ[j]) - hack_sind(grid.φᵃᶜᵃ[j - 1]))
        end
#= none:213 =#
#= none:213 =# @inline Azᶜᶜᵃ(i, j, k, grid::LLGFX) = begin
            #= none:213 =#
            #= none:213 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶜᵃᵃ) * (hack_sind(grid.φᵃᶠᵃ[j + 1]) - hack_sind(grid.φᵃᶠᵃ[j]))
        end
#= none:215 =#
for LX = (:ᶠ, :ᶜ), LY = (:ᶠ, :ᶜ)
    #= none:217 =#
    z_area_2D = Symbol(:Az, LX, LY, :ᵃ)
    #= none:219 =#
    #= none:219 =# @eval begin
            #= none:220 =#
            #= none:220 =# @inline $z_area_2D(i, j, k, grid::OSSG) = begin
                        #= none:220 =#
                        #= none:220 =# @inbounds grid.$(z_area_2D)[i, j]
                    end
            #= none:221 =#
            #= none:221 =# @inline $z_area_2D(i, j, k, grid::LLG) = begin
                        #= none:221 =#
                        #= none:221 =# @inbounds grid.$(z_area_2D)[i, j]
                    end
            #= none:222 =#
            #= none:222 =# @inline $z_area_2D(i, j, k, grid::LLGX) = begin
                        #= none:222 =#
                        #= none:222 =# @inbounds grid.$(z_area_2D)[j]
                    end
        end
    #= none:224 =#
end
#= none:232 =#
#= none:232 =# @inline Vᶜᶜᶜ(i, j, k, grid) = begin
            #= none:232 =#
            Azᶜᶜᶜ(i, j, k, grid) * Δzᶜᶜᶜ(i, j, k, grid)
        end
#= none:233 =#
#= none:233 =# @inline Vᶠᶜᶜ(i, j, k, grid) = begin
            #= none:233 =#
            Azᶠᶜᶜ(i, j, k, grid) * Δzᶠᶜᶜ(i, j, k, grid)
        end
#= none:234 =#
#= none:234 =# @inline Vᶜᶠᶜ(i, j, k, grid) = begin
            #= none:234 =#
            Azᶜᶠᶜ(i, j, k, grid) * Δzᶜᶠᶜ(i, j, k, grid)
        end
#= none:235 =#
#= none:235 =# @inline Vᶜᶜᶠ(i, j, k, grid) = begin
            #= none:235 =#
            Azᶜᶜᶠ(i, j, k, grid) * Δzᶜᶜᶠ(i, j, k, grid)
        end
#= none:236 =#
#= none:236 =# @inline Vᶠᶠᶜ(i, j, k, grid) = begin
            #= none:236 =#
            Azᶠᶠᶜ(i, j, k, grid) * Δzᶠᶠᶜ(i, j, k, grid)
        end
#= none:237 =#
#= none:237 =# @inline Vᶠᶜᶠ(i, j, k, grid) = begin
            #= none:237 =#
            Azᶠᶜᶠ(i, j, k, grid) * Δzᶠᶜᶠ(i, j, k, grid)
        end
#= none:238 =#
#= none:238 =# @inline Vᶜᶠᶠ(i, j, k, grid) = begin
            #= none:238 =#
            Azᶜᶠᶠ(i, j, k, grid) * Δzᶜᶠᶠ(i, j, k, grid)
        end
#= none:239 =#
#= none:239 =# @inline Vᶠᶠᶠ(i, j, k, grid) = begin
            #= none:239 =#
            Azᶠᶠᶠ(i, j, k, grid) * Δzᶠᶠᶠ(i, j, k, grid)
        end
#= none:249 =#
location_code(LX, LY, LZ) = begin
        #= none:249 =#
        Symbol(interpolation_code(LX), interpolation_code(LY), interpolation_code(LZ))
    end
#= none:251 =#
for LX = (:Center, :Face)
    #= none:252 =#
    for LY = (:Center, :Face)
        #= none:253 =#
        for LZ = (:Center, :Face)
            #= none:254 =#
            LXe = #= none:254 =# @eval($LX)
            #= none:255 =#
            LYe = #= none:255 =# @eval($LY)
            #= none:256 =#
            LZe = #= none:256 =# @eval($LZ)
            #= none:258 =#
            volume_function = Symbol(:V, location_code(LXe, LYe, LZe))
            #= none:259 =#
            #= none:259 =# @eval begin
                    #= none:260 =#
                    #= none:260 =# @inline volume(i, j, k, grid, ::$LX, ::$LY, ::$LZ) = begin
                                #= none:260 =#
                                $volume_function(i, j, k, grid)
                            end
                end
            #= none:263 =#
            for op = (:Δ, :A), dir = (:x, :y, :z)
                #= none:264 =#
                func = Symbol(op, dir)
                #= none:265 =#
                metric = Symbol(op, dir, location_code(LXe, LYe, LZe))
                #= none:267 =#
                #= none:267 =# @eval begin
                        #= none:268 =#
                        #= none:268 =# @inline $func(i, j, k, grid, ::$LX, ::$LY, ::$LZ) = begin
                                    #= none:268 =#
                                    $metric(i, j, k, grid)
                                end
                    end
                #= none:270 =#
            end
            #= none:271 =#
        end
        #= none:272 =#
    end
    #= none:273 =#
end