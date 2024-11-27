
#= none:1 =#
using KernelAbstractions: @kernel, @index
#= none:3 =#
using Oceananigans.Architectures: on_architecture, architecture
#= none:4 =#
using Oceananigans.Operators: Δzᶜᶜᶜ, Δyᶜᶜᶜ, Δxᶜᶜᶜ, Azᶜᶜᶜ
#= none:5 =#
using Oceananigans.Grids: hack_sind, ξnode, ηnode, rnode
#= none:7 =#
using Base: ForwardOrdering
#= none:9 =#
const f = Face()
#= none:10 =#
const c = Center()
#= none:12 =#
#= none:12 =# Core.@doc "    regrid!(a, b)\n\nRegrid field `b` onto the grid of field `a`. \n\nExample\n=======\n\nGenerate a tracer field on a vertically stretched grid and regrid it on a regular grid.\n\n```jldoctest\nusing Oceananigans\n\nNz, Lz = 2, 1.0\ntopology = (Flat, Flat, Bounded)\n\ninput_grid = RectilinearGrid(size=Nz, z = [0, Lz/3, Lz], topology=topology, halo=1)\ninput_field = CenterField(input_grid)\ninput_field[1, 1, 1:Nz] = [2, 3]\n\noutput_grid = RectilinearGrid(size=Nz, z=(0, Lz), topology=topology, halo=1)\noutput_field = CenterField(output_grid)\n\nregrid!(output_field, input_field)\n\noutput_field[1, 1, :]\n\n# output\n4-element OffsetArray(::Vector{Float64}, 0:3) with eltype Float64 with indices 0:3:\n 0.0\n 2.333333333333333\n 3.0\n 0.0\n```\n" regrid!(a, b) = begin
            #= none:47 =#
            regrid!(a, a.grid, b.grid, b)
        end
#= none:49 =#
function we_can_regrid_in_z(a, target_grid, source_grid, b)
    #= none:49 =#
    #= none:53 =#
    (typeof(source_grid)).name.wrapper === (typeof(target_grid)).name.wrapper && ((size(a))[1:2] === (size(b))[1:2] && return true)
    #= none:56 =#
    return false
end
#= none:59 =#
function we_can_regrid_in_y(a, target_grid, source_grid, b)
    #= none:59 =#
    #= none:63 =#
    (typeof(source_grid)).name.wrapper === (typeof(target_grid)).name.wrapper && ((size(a))[[1, 3]] === (size(b))[[1, 3]] && return true)
    #= none:66 =#
    return false
end
#= none:69 =#
function we_can_regrid_in_x(a, target_grid, source_grid, b)
    #= none:69 =#
    #= none:73 =#
    (typeof(source_grid)).name.wrapper === (typeof(target_grid)).name.wrapper && ((size(a))[[2, 3]] === (size(b))[[2, 3]] && return true)
    #= none:76 =#
    return false
end
#= none:79 =#
function regrid_in_z!(a, target_grid, source_grid, b)
    #= none:79 =#
    #= none:80 =#
    location(a, 3) == Center || throw(ArgumentError("Can only regrid fields in z with Center z-locations."))
    #= none:81 =#
    arch = architecture(a)
    #= none:82 =#
    source_z_faces = znodes(source_grid, f)
    #= none:83 =#
    launch!(arch, target_grid, :xy, _regrid_in_z!, a, b, target_grid, source_grid, source_z_faces)
    #= none:85 =#
    return a
end
#= none:88 =#
function regrid_in_y!(a, target_grid, source_grid, b)
    #= none:88 =#
    #= none:89 =#
    location(a, 2) == Center || throw(ArgumentError("Can only regrid fields in y with Center y-locations."))
    #= none:90 =#
    arch = architecture(a)
    #= none:91 =#
    source_y_faces = (nodes(source_grid, c, f, c))[2]
    #= none:92 =#
    Nx_source_faces = size(source_grid, (Face, Center, Center), 1)
    #= none:93 =#
    launch!(arch, target_grid, :xz, _regrid_in_y!, a, b, target_grid, source_grid, source_y_faces, Nx_source_faces)
    #= none:94 =#
    return a
end
#= none:97 =#
function regrid_in_x!(a, target_grid, source_grid, b)
    #= none:97 =#
    #= none:98 =#
    location(a, 1) == Center || throw(ArgumentError("Can only regrid fields in x with Center x-locations."))
    #= none:99 =#
    arch = architecture(a)
    #= none:100 =#
    source_x_faces = (nodes(source_grid, f, c, c))[1]
    #= none:101 =#
    Ny_source_faces = size(source_grid, (Center, Face, Center), 2)
    #= none:102 =#
    launch!(arch, target_grid, :yz, _regrid_in_x!, a, b, target_grid, source_grid, source_x_faces, Ny_source_faces)
    #= none:103 =#
    return a
end
#= none:106 =#
regrid_in_x!(a, b) = begin
        #= none:106 =#
        regrid_in_x!(a, a.grid, b.grid, b)
    end
#= none:107 =#
regrid_in_y!(a, b) = begin
        #= none:107 =#
        regrid_in_y!(a, a.grid, b.grid, b)
    end
#= none:108 =#
regrid_in_z!(a, b) = begin
        #= none:108 =#
        regrid_in_z!(a, a.grid, b.grid, b)
    end
#= none:110 =#
function regrid!(a, target_grid, source_grid, b)
    #= none:110 =#
    #= none:111 =#
    arch = architecture(a)
    #= none:113 =#
    if we_can_regrid_in_z(a, target_grid, source_grid, b)
        #= none:114 =#
        return regrid_in_z!(a, target_grid, source_grid, b)
    elseif #= none:115 =# we_can_regrid_in_y(a, target_grid, source_grid, b)
        #= none:116 =#
        return regrid_in_y!(a, target_grid, source_grid, b)
    elseif #= none:117 =# we_can_regrid_in_x(a, target_grid, source_grid, b)
        #= none:118 =#
        return regrid_in_x!(a, target_grid, source_grid, b)
    else
        #= none:120 =#
        msg = "Regridding\n$(summary(b)) on $(summary(source_grid))\nto $(summary(a)) on $(summary(target_grid))\nis not supported."
        #= none:125 =#
        return throw(ArgumentError(msg))
    end
end
#= none:133 =#
#= none:133 =# @kernel function _regrid_in_z!(target_field, source_field, target_grid, source_grid, source_z_faces)
        #= none:133 =#
        #= none:134 =#
        (i, j) = #= none:134 =# @index(Global, NTuple)
        #= none:136 =#
        (Nx_target, Ny_target, Nz_target) = size(target_grid)
        #= none:137 =#
        (Nx_source, Ny_source, Nz_source) = size(source_grid)
        #= none:138 =#
        i_src = ifelse(Nx_target == Nx_source, i, 1)
        #= none:139 =#
        j_src = ifelse(Ny_target == Ny_source, j, 1)
        #= none:141 =#
        fo = ForwardOrdering()
        #= none:143 =#
        #= none:143 =# @inbounds for k = 1:target_grid.Nz
                #= none:144 =#
                target_field[i, j, k] = 0
                #= none:146 =#
                z₋ = znode(i, j, k, target_grid, c, c, f)
                #= none:147 =#
                z₊ = znode(i, j, k + 1, target_grid, c, c, f)
                #= none:150 =#
                k₋_src = searchsortedfirst(source_z_faces, z₋, 1, Nz_source + 1, fo)
                #= none:151 =#
                k₊_src = searchsortedfirst(source_z_faces, z₊, 1, Nz_source + 1, fo) - 1
                #= none:153 =#
                if k₊_src < k₋_src
                    #= none:159 =#
                    target_field[i, j, k] = source_field[i_src, j_src, k₊_src]
                else
                    #= none:162 =#
                    for k_src = k₋_src:k₊_src - 1
                        #= none:163 =#
                        target_field[i, j, k] += source_field[i_src, j_src, k_src] * Δzᶜᶜᶜ(i_src, j_src, k_src, source_grid)
                        #= none:164 =#
                    end
                    #= none:166 =#
                    zk₋_src = znode(i_src, j_src, k₋_src, source_grid, c, c, f)
                    #= none:167 =#
                    zk₊_src = znode(i_src, j_src, k₊_src, source_grid, c, c, f)
                    #= none:171 =#
                    if k₋_src > 1
                        #= none:172 =#
                        target_field[i, j, k] += source_field[i_src, j_src, k₋_src - 1] * (zk₋_src - z₋)
                    end
                    #= none:177 =#
                    if k₊_src < source_grid.Nz + 1
                        #= none:178 =#
                        target_field[i, j, k] += source_field[i_src, j_src, k₊_src] * (z₊ - zk₊_src)
                    end
                    #= none:181 =#
                    target_field[i, j, k] /= Δzᶜᶜᶜ(i, j, k, target_grid)
                end
                #= none:183 =#
            end
    end
#= none:186 =#
#= none:186 =# @kernel function _regrid_in_y!(target_field, source_field, target_grid, source_grid, source_y_faces, Nx_source_faces)
        #= none:186 =#
        #= none:187 =#
        (i, k) = #= none:187 =# @index(Global, NTuple)
        #= none:189 =#
        (Nx_target, Ny_target, Nz_target) = size(target_grid)
        #= none:190 =#
        (Nx_source, Ny_source, Nz_source) = size(source_grid)
        #= none:191 =#
        i_src = ifelse(Nx_target == Nx_source, i, 1)
        #= none:192 =#
        k_src = ifelse(Nz_target == Nz_source, k, 1)
        #= none:194 =#
        i⁺_src = min(Nx_source_faces, i_src + 1)
        #= none:196 =#
        fo = ForwardOrdering()
        #= none:198 =#
        #= none:198 =# @inbounds for j = 1:target_grid.Ny
                #= none:199 =#
                target_field[i, j, k] = 0
                #= none:201 =#
                y₋ = ηnode(i, j, k, target_grid, c, f, c)
                #= none:202 =#
                y₊ = ηnode(i, j + 1, k, target_grid, c, f, c)
                #= none:205 =#
                j₋_src = searchsortedfirst(source_y_faces, y₋, 1, Ny_source + 1, fo)
                #= none:206 =#
                j₊_src = searchsortedfirst(source_y_faces, y₊, 1, Ny_source + 1, fo) - 1
                #= none:208 =#
                if j₊_src < j₋_src
                    #= none:214 =#
                    target_field[i, j, k] = source_field[i_src, j₊_src, k_src]
                else
                    #= none:217 =#
                    for j_src = j₋_src:j₊_src - 1
                        #= none:218 =#
                        target_field[i, j, k] += source_field[i_src, j_src, k_src] * Azᶜᶜᶜ(i_src, j_src, k_src, source_grid)
                        #= none:219 =#
                    end
                    #= none:221 =#
                    yj₋_src = ηnode(i_src, j₋_src, k_src, source_grid, c, f, c)
                    #= none:222 =#
                    yj₊_src = ηnode(i_src, j₊_src, k_src, source_grid, c, f, c)
                    #= none:227 =#
                    if j₋_src > 1
                        #= none:228 =#
                        j_left = j₋_src - 1
                        #= none:230 =#
                        ξ₁ = ξnode(i_src, j_left, k_src, source_grid, f, c, c)
                        #= none:231 =#
                        ξ₂ = ξnode(i⁺_src, j_left, k_src, source_grid, f, c, c)
                        #= none:232 =#
                        Az_left = fractional_horizontal_area(source_grid, ξ₁, ξ₂, y₋, yj₋_src)
                        #= none:234 =#
                        target_field[i, j, k] += source_field[i_src, j_left, k_src] * Az_left
                    end
                    #= none:238 =#
                    if j₊_src < source_grid.Ny + 1
                        #= none:239 =#
                        j_right = j₊_src
                        #= none:241 =#
                        ξ₁ = ξnode(i_src, j_right, k_src, source_grid, f, c, c)
                        #= none:242 =#
                        ξ₂ = ξnode(i⁺_src, j_right, k_src, source_grid, f, c, c)
                        #= none:243 =#
                        Az_right = fractional_horizontal_area(source_grid, ξ₁, ξ₂, yj₊_src, y₊)
                        #= none:245 =#
                        target_field[i, j, k] += source_field[i_src, j_right, k_src] * Az_right
                    end
                    #= none:248 =#
                    target_field[i, j, k] /= Azᶜᶜᶜ(i, j, k, target_grid)
                end
                #= none:250 =#
            end
    end
#= none:253 =#
#= none:253 =# @kernel function _regrid_in_x!(target_field, source_field, target_grid, source_grid, source_x_faces, Ny_source_faces)
        #= none:253 =#
        #= none:254 =#
        (j, k) = #= none:254 =# @index(Global, NTuple)
        #= none:256 =#
        (Nx_target, Ny_target, Nz_target) = size(target_grid)
        #= none:257 =#
        (Nx_source, Ny_source, Nz_source) = size(source_grid)
        #= none:258 =#
        j_src = ifelse(Ny_target == Ny_source, j, 1)
        #= none:259 =#
        k_src = ifelse(Nz_target == Nz_source, k, 1)
        #= none:261 =#
        j⁺_src = min(Ny_source_faces, j_src + 1)
        #= none:263 =#
        fo = ForwardOrdering()
        #= none:265 =#
        #= none:265 =# @inbounds for i = 1:target_grid.Nx
                #= none:266 =#
                target_field[i, j, k] = 0
                #= none:269 =#
                ξ₋ = ξnode(i, j, k, target_grid, f, c, c)
                #= none:270 =#
                ξ₊ = ξnode(i + 1, j, k, target_grid, f, c, c)
                #= none:273 =#
                i₋_src = searchsortedfirst(source_x_faces, ξ₋, 1, Nx_source + 1, fo)
                #= none:276 =#
                i₊_src = searchsortedfirst(source_x_faces, ξ₊, 1, Nx_source + 1, fo) - 1
                #= none:278 =#
                if i₊_src < i₋_src
                    #= none:284 =#
                    target_field[i, j, k] = source_field[i₊_src, j_src, k_src]
                else
                    #= none:290 =#
                    for i_src = i₋_src:i₊_src - 1
                        #= none:291 =#
                        target_field[i, j, k] += source_field[i_src, j_src, k_src] * Azᶜᶜᶜ(i_src, j_src, k_src, source_grid)
                        #= none:292 =#
                    end
                    #= none:296 =#
                    ξi₋_src = ξnode(i₋_src, j_src, k_src, source_grid, f, c, c)
                    #= none:297 =#
                    ξi₊_src = ξnode(i₊_src, j_src, k_src, source_grid, f, c, c)
                    #= none:302 =#
                    if i₋_src > 1
                        #= none:303 =#
                        i_left = i₋_src - 1
                        #= none:305 =#
                        η₁ = ηnode(i_left, j_src, k_src, source_grid, c, f, c)
                        #= none:306 =#
                        η₂ = ηnode(i_left, j⁺_src, k_src, source_grid, c, f, c)
                        #= none:307 =#
                        Az_left = fractional_horizontal_area(source_grid, ξ₋, ξi₋_src, η₁, η₂)
                        #= none:309 =#
                        target_field[i, j, k] += source_field[i_left, j_src, k_src] * Az_left
                    end
                    #= none:314 =#
                    if i₊_src < source_grid.Nx + 1
                        #= none:315 =#
                        i_right = i₊_src
                        #= none:317 =#
                        η₁ = ηnode(i_right, j_src, k_src, source_grid, c, f, c)
                        #= none:318 =#
                        η₂ = ηnode(i_right, j⁺_src, k_src, source_grid, c, f, c)
                        #= none:319 =#
                        Az_right = fractional_horizontal_area(source_grid, ξi₊_src, ξ₊, η₁, η₂)
                        #= none:321 =#
                        target_field[i, j, k] += source_field[i_right, j_src, k_src] * Az_right
                    end
                    #= none:324 =#
                    target_field[i, j, k] /= Azᶜᶜᶜ(i, j, k, target_grid)
                end
                #= none:326 =#
            end
    end
#= none:329 =#
#= none:329 =# @inline fractional_horizontal_area(grid::RectilinearGrid, x₁, x₂, y₁, y₂) = begin
            #= none:329 =#
            (x₂ - x₁) * (y₂ - y₁)
        end
#= none:330 =#
#= none:330 =# @inline fractional_horizontal_area(grid::RectilinearGrid{<:Any, <:Flat}, x₁, x₂, y₁, y₂) = begin
            #= none:330 =#
            y₂ - y₁
        end
#= none:331 =#
#= none:331 =# @inline fractional_horizontal_area(grid::RectilinearGrid{<:Any, <:Any, <:Flat}, x₁, x₂, y₁, y₂) = begin
            #= none:331 =#
            x₂ - x₁
        end
#= none:333 =#
#= none:333 =# @inline function fractional_horizontal_area(grid::LatitudeLongitudeGrid, λ₁, λ₂, φ₁, φ₂)
        #= none:333 =#
        #= none:334 =#
        Δλ = λ₂ - λ₁
        #= none:335 =#
        return grid.radius ^ 2 * deg2rad(Δλ) * (hack_sind(φ₂) - hack_sind(φ₁))
    end
#= none:338 =#
#= none:338 =# @inline fractional_horizontal_area(grid::LatitudeLongitudeGrid{<:Any, <:Flat}, λ₁, λ₂, φ₁, φ₂) = begin
            #= none:338 =#
            grid.radius ^ 2 * (hack_sind(φ₂) - hack_sind(φ₁))
        end
#= none:339 =#
#= none:339 =# @inline fractional_horizontal_area(grid::LatitudeLongitudeGrid{<:Any, <:Any, <:Flat}, λ₁, λ₂, φ₁, φ₂) = begin
            #= none:339 =#
            grid.radius ^ 2 * deg2rad(λ₂ - λ₁)
        end