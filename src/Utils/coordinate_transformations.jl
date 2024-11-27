
#= none:1 =#
using Oceananigans.Grids: xnode, ynode, total_length
#= none:3 =#
#= none:3 =# Core.@doc "    lat_lon_to_cartesian(longitude, latitude)\n\nConvert `(longitude, latitude)` coordinates (in degrees) to\ncartesian coordinates `(x, y, z)` on the unit sphere.\n" lat_lon_to_cartesian(longitude, latitude) = begin
            #= none:9 =#
            (lat_lon_to_x(longitude, latitude), lat_lon_to_y(longitude, latitude), lat_lon_to_z(longitude, latitude))
        end
#= none:13 =#
#= none:13 =# Core.@doc "    lat_lon_to_x(longitude, latitude)\n\nConvert `(longitude, latitude)` coordinates (in degrees) to cartesian `x` on the unit sphere.\n" lat_lon_to_x(longitude, latitude) = begin
            #= none:18 =#
            cosd(longitude) * cosd(latitude)
        end
#= none:20 =#
#= none:20 =# Core.@doc "    lat_lon_to_y(longitude, latitude)\n\nConvert `(longitude, latitude)` coordinates (in degrees) to cartesian `y` on the unit sphere.\n" lat_lon_to_y(longitude, latitude) = begin
            #= none:25 =#
            sind(longitude) * cosd(latitude)
        end
#= none:27 =#
#= none:27 =# Core.@doc "    lat_lon_to_z(longitude, latitude)\n\nConvert `(longitude, latitude)` coordinates (in degrees) to cartesian `z` on the unit sphere.\n" lat_lon_to_z(longitude, latitude) = begin
            #= none:32 =#
            sind(latitude)
        end
#= none:34 =#
longitude_in_same_window(λ₁, λ₂) = begin
        #= none:34 =#
        (mod((λ₁ - λ₂) + 180, 360) + λ₂) - 180
    end
#= none:36 =#
flip_location(::Center) = begin
        #= none:36 =#
        Face()
    end
#= none:37 =#
flip_location(::Face) = begin
        #= none:37 =#
        Center()
    end
#= none:39 =#
#= none:39 =# Core.@doc "    get_longitude_vertices(i, j, k, grid::Union{LatitudeLongitudeGrid, OrthogonalSphericalShellGrid}, ℓx, ℓy, ℓz)\n\nReturn the longitudes that correspond to the four vertices of cell `i, j, k` at\nlocatiopn `(ℓx, ℓy, ℓz)`. The first vertice is the cell's Southern-Western one\nand the rest follow in counter-clockwise order.\n" function get_longitude_vertices(i, j, k, grid::Union{LatitudeLongitudeGrid, OrthogonalSphericalShellGrid}, ℓx, ℓy, ℓz)
        #= none:46 =#
        #= none:48 =#
        if ℓx == Center()
            #= none:49 =#
            i₀ = i
        elseif #= none:50 =# ℓx == Face()
            #= none:51 =#
            i₀ = i - 1
        end
        #= none:54 =#
        if ℓy == Center()
            #= none:55 =#
            j₀ = j
        elseif #= none:56 =# ℓy == Face()
            #= none:57 =#
            j₀ = j - 1
        end
        #= none:60 =#
        λ₁ = λnode(i₀, j₀, k, grid, flip_location(ℓx), flip_location(ℓy), ℓz)
        #= none:61 =#
        λ₂ = λnode(i₀ + 1, j₀, k, grid, flip_location(ℓx), flip_location(ℓy), ℓz)
        #= none:62 =#
        λ₃ = λnode(i₀ + 1, j₀ + 1, k, grid, flip_location(ℓx), flip_location(ℓy), ℓz)
        #= none:63 =#
        λ₄ = λnode(i₀, j₀ + 1, k, grid, flip_location(ℓx), flip_location(ℓy), ℓz)
        #= none:65 =#
        return [λ₁; λ₂; λ₃; λ₄]
    end
#= none:68 =#
#= none:68 =# Core.@doc "    get_latitude_vertices(i, j, k, grid::Union{LatitudeLongitudeGrid, OrthogonalSphericalShellGrid}, ℓx, ℓy, ℓz)\n\nReturn the latitudes that correspond to the four vertices of cell `i, j, k` at\nlocatiopn `(ℓx, ℓy, ℓz)`. The first vertice is the cell's Southern-Western one\nand the rest follow in counter-clockwise order.\n" function get_latitude_vertices(i, j, k, grid::Union{LatitudeLongitudeGrid, OrthogonalSphericalShellGrid}, ℓx, ℓy, ℓz)
        #= none:75 =#
        #= none:77 =#
        if ℓx == Center()
            #= none:78 =#
            i₀ = i
        elseif #= none:79 =# ℓx == Face()
            #= none:80 =#
            i₀ = i - 1
        end
        #= none:83 =#
        if ℓy == Center()
            #= none:84 =#
            j₀ = j
        elseif #= none:85 =# ℓy == Face()
            #= none:86 =#
            j₀ = j - 1
        end
        #= none:89 =#
        φ₁ = φnode(i₀, j₀, k, grid, flip_location(ℓx), flip_location(ℓy), ℓz)
        #= none:90 =#
        φ₂ = φnode(i₀ + 1, j₀, k, grid, flip_location(ℓx), flip_location(ℓy), ℓz)
        #= none:91 =#
        φ₃ = φnode(i₀ + 1, j₀ + 1, k, grid, flip_location(ℓx), flip_location(ℓy), ℓz)
        #= none:92 =#
        φ₄ = φnode(i₀, j₀ + 1, k, grid, flip_location(ℓx), flip_location(ℓy), ℓz)
        #= none:94 =#
        return [φ₁; φ₂; φ₃; φ₄]
    end
#= none:97 =#
#= none:97 =# Core.@doc "    get_lat_lon_nodes_and_vertices(grid, ℓx, ℓy, ℓz)\n\nReturn the latitude-longitude coordinates of the horizontal nodes of the\n`grid` at locations `ℓx`, `ℓy`, and `ℓz` and also the coordinates of the four\nvertices that determine the cell surrounding each node.\n\nSee [`get_longitude_vertices`](@ref) and [`get_latitude_vertices`](@ref).\n" function get_lat_lon_nodes_and_vertices(grid, ℓx, ℓy, ℓz)
        #= none:106 =#
        #= none:108 =#
        (TX, TY, _) = topology(grid)
        #= none:110 =#
        λ = zeros(eltype(grid), total_length(ℓx, TX(), grid.Nx, 0), total_length(ℓy, TY(), grid.Ny, 0))
        #= none:111 =#
        φ = zeros(eltype(grid), total_length(ℓx, TX(), grid.Nx, 0), total_length(ℓy, TY(), grid.Ny, 0))
        #= none:113 =#
        for j = axes(λ, 2), i = axes(λ, 1)
            #= none:114 =#
            λ[i, j] = λnode(i, j, 1, grid, ℓx, ℓy, ℓz)
            #= none:115 =#
            φ[i, j] = φnode(i, j, 1, grid, ℓx, ℓy, ℓz)
            #= none:116 =#
        end
        #= none:118 =#
        λvertices = zeros(4, size(λ)...)
        #= none:119 =#
        φvertices = zeros(4, size(φ)...)
        #= none:121 =#
        for j = axes(λ, 2), i = axes(λ, 1)
            #= none:122 =#
            λvertices[:, i, j] = get_longitude_vertices(i, j, 1, grid, ℓx, ℓy, ℓz)
            #= none:123 =#
            φvertices[:, i, j] = get_latitude_vertices(i, j, 1, grid, ℓx, ℓy, ℓz)
            #= none:124 =#
        end
        #= none:126 =#
        λ = mod.(λ .+ 180, 360) .- 180
        #= none:127 =#
        λvertices = longitude_in_same_window.(λvertices, reshape(λ, (1, size(λ)...)))
        #= none:129 =#
        return ((λ, φ), (λvertices, φvertices))
    end
#= none:132 =#
#= none:132 =# Core.@doc "    get_cartesian_nodes_and_vertices(grid::Union{LatitudeLongitudeGrid, OrthogonalSphericalShellGrid}, ℓx, ℓy, ℓz)\n\nReturn the cartesian coordinates of the horizontal nodes of the `grid`\nat locations `ℓx`, `ℓy`, and `ℓz` on the unit sphere and also the corresponding\ncoordinates of the four vertices that determine the cell surrounding each node.\n\nSee [`get_lat_lon_nodes_and_vertices`](@ref).\n" function get_cartesian_nodes_and_vertices(grid::Union{LatitudeLongitudeGrid, OrthogonalSphericalShellGrid}, ℓx, ℓy, ℓz)
        #= none:141 =#
        #= none:143 =#
        ((λ, φ), (λvertices, φvertices)) = get_lat_lon_nodes_and_vertices(grid, ℓx, ℓy, ℓz)
        #= none:145 =#
        x = similar(λ)
        #= none:146 =#
        y = similar(λ)
        #= none:147 =#
        z = similar(λ)
        #= none:149 =#
        xvertices = similar(λvertices)
        #= none:150 =#
        yvertices = similar(λvertices)
        #= none:151 =#
        zvertices = similar(λvertices)
        #= none:153 =#
        for j = axes(λ, 2), i = axes(λ, 1)
            #= none:154 =#
            x[i, j] = lat_lon_to_x(λ[i, j], φ[i, j])
            #= none:155 =#
            y[i, j] = lat_lon_to_y(λ[i, j], φ[i, j])
            #= none:156 =#
            z[i, j] = lat_lon_to_z(λ[i, j], φ[i, j])
            #= none:158 =#
            for vertex = 1:4
                #= none:159 =#
                xvertices[vertex, i, j] = lat_lon_to_x(λvertices[vertex, i, j], φvertices[vertex, i, j])
                #= none:160 =#
                yvertices[vertex, i, j] = lat_lon_to_y(λvertices[vertex, i, j], φvertices[vertex, i, j])
                #= none:161 =#
                zvertices[vertex, i, j] = lat_lon_to_z(λvertices[vertex, i, j], φvertices[vertex, i, j])
                #= none:162 =#
            end
            #= none:163 =#
        end
        #= none:165 =#
        return ((x, y, z), (xvertices, yvertices, zvertices))
    end