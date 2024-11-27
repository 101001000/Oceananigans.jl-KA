
#= none:8 =#
#= none:8 =# @inline getnode(ξ, i) = begin
            #= none:8 =#
            #= none:8 =# @inbounds ξ[i]
        end
#= none:9 =#
#= none:9 =# @inline getnode(::Nothing, i) = begin
            #= none:9 =#
            nothing
        end
#= none:10 =#
#= none:10 =# @inline getnode(ξ::Number, i) = begin
            #= none:10 =#
            ξ
        end
#= none:12 =#
node_names(grid, ℓx, ℓy, ℓz) = begin
        #= none:12 =#
        _node_names(grid, ℓx, ℓy, ℓz)
    end
#= none:14 =#
node_names(grid::XFlatGrid, ℓx, ℓy, ℓz) = begin
        #= none:14 =#
        _node_names(grid, nothing, ℓy, ℓz)
    end
#= none:15 =#
node_names(grid::YFlatGrid, ℓx, ℓy, ℓz) = begin
        #= none:15 =#
        _node_names(grid, ℓx, nothing, ℓz)
    end
#= none:16 =#
node_names(grid::ZFlatGrid, ℓx, ℓy, ℓz) = begin
        #= none:16 =#
        _node_names(grid, ℓx, ℓy, nothing)
    end
#= none:17 =#
node_names(grid::XYFlatGrid, ℓx, ℓy, ℓz) = begin
        #= none:17 =#
        _node_names(grid, nothing, nothing, ℓz)
    end
#= none:18 =#
node_names(grid::XZFlatGrid, ℓx, ℓy, ℓz) = begin
        #= none:18 =#
        _node_names(grid, nothing, ℓy, nothing)
    end
#= none:19 =#
node_names(grid::YZFlatGrid, ℓx, ℓy, ℓz) = begin
        #= none:19 =#
        _node_names(grid, ℓx, nothing, nothing)
    end
#= none:20 =#
node_names(grid::XYZFlatGrid, ℓx, ℓy, ℓz) = begin
        #= none:20 =#
        _node_names(grid, nothing, nothing, nothing)
    end
#= none:22 =#
_node_names(grid, ℓx, ℓy, ℓz) = begin
        #= none:22 =#
        (ξname(grid), ηname(grid), rname(grid))
    end
#= none:24 =#
_node_names(grid, ::Nothing, ℓy, ℓz) = begin
        #= none:24 =#
        (ηname(grid), rname(grid))
    end
#= none:25 =#
_node_names(grid, ℓx, ::Nothing, ℓz) = begin
        #= none:25 =#
        (ξname(grid), rname(grid))
    end
#= none:26 =#
_node_names(grid, ℓx, ℓy, ::Nothing) = begin
        #= none:26 =#
        (ξname(grid), ηname(grid))
    end
#= none:28 =#
_node_names(grid, ℓx, ::Nothing, ::Nothing) = begin
        #= none:28 =#
        tuple(ξname(grid))
    end
#= none:29 =#
_node_names(grid, ::Nothing, ℓy, ::Nothing) = begin
        #= none:29 =#
        tuple(ηname(grid))
    end
#= none:30 =#
_node_names(grid, ::Nothing, ::Nothing, ℓz) = begin
        #= none:30 =#
        tuple(rname(grid))
    end
#= none:32 =#
_node_names(grid, ::Nothing, ::Nothing, ::Nothing) = begin
        #= none:32 =#
        tuple()
    end
#= none:35 =#
#= none:35 =# @inline _node(i, j, k, grid, ℓx, ℓy, ℓz) = begin
            #= none:35 =#
            (ξnode(i, j, k, grid, ℓx, ℓy, ℓz), ηnode(i, j, k, grid, ℓx, ℓy, ℓz), rnode(i, j, k, grid, ℓx, ℓy, ℓz))
        end
#= none:40 =#
#= none:40 =# @inline _node(i, j, k, grid, ℓx::Nothing, ℓy, ℓz) = begin
            #= none:40 =#
            (ηnode(i, j, k, grid, ℓx, ℓy, ℓz), rnode(i, j, k, grid, ℓx, ℓy, ℓz))
        end
#= none:41 =#
#= none:41 =# @inline _node(i, j, k, grid, ℓx, ℓy::Nothing, ℓz) = begin
            #= none:41 =#
            (ξnode(i, j, k, grid, ℓx, ℓy, ℓz), rnode(i, j, k, grid, ℓx, ℓy, ℓz))
        end
#= none:42 =#
#= none:42 =# @inline _node(i, j, k, grid, ℓx, ℓy, ℓz::Nothing) = begin
            #= none:42 =#
            (ξnode(i, j, k, grid, ℓx, ℓy, ℓz), ηnode(i, j, k, grid, ℓx, ℓy, ℓz))
        end
#= none:44 =#
#= none:44 =# @inline _node(i, j, k, grid, ℓx, ℓy::Nothing, ℓz::Nothing) = begin
            #= none:44 =#
            tuple(ξnode(i, j, k, grid, ℓx, ℓy, ℓz))
        end
#= none:45 =#
#= none:45 =# @inline _node(i, j, k, grid, ℓx::Nothing, ℓy, ℓz::Nothing) = begin
            #= none:45 =#
            tuple(ηnode(i, j, k, grid, ℓx, ℓy, ℓz))
        end
#= none:46 =#
#= none:46 =# @inline _node(i, j, k, grid, ℓx::Nothing, ℓy::Nothing, ℓz) = begin
            #= none:46 =#
            tuple(rnode(i, j, k, grid, ℓx, ℓy, ℓz))
        end
#= none:48 =#
#= none:48 =# @inline _node(i, j, k, grid, ::Nothing, ::Nothing, ::Nothing) = begin
            #= none:48 =#
            tuple()
        end
#= none:51 =#
#= none:51 =# @inline node(i, j, k, grid, ℓx, ℓy, ℓz) = begin
            #= none:51 =#
            _node(i, j, k, grid, ℓx, ℓy, ℓz)
        end
#= none:53 =#
#= none:53 =# @inline node(i, j, k, grid::XFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:53 =#
            _node(i, j, k, grid, nothing, ℓy, ℓz)
        end
#= none:54 =#
#= none:54 =# @inline node(i, j, k, grid::YFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:54 =#
            _node(i, j, k, grid, ℓx, nothing, ℓz)
        end
#= none:55 =#
#= none:55 =# @inline node(i, j, k, grid::ZFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:55 =#
            _node(i, j, k, grid, ℓx, ℓy, nothing)
        end
#= none:57 =#
#= none:57 =# @inline node(i, j, k, grid::XYFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:57 =#
            _node(i, j, k, grid, nothing, nothing, ℓz)
        end
#= none:58 =#
#= none:58 =# @inline node(i, j, k, grid::XZFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:58 =#
            _node(i, j, k, grid, nothing, ℓy, nothing)
        end
#= none:59 =#
#= none:59 =# @inline node(i, j, k, grid::YZFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:59 =#
            _node(i, j, k, grid, ℓx, nothing, nothing)
        end
#= none:61 =#
#= none:61 =# @inline node(i, j, k, grid::XYZFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:61 =#
            tuple()
        end
#= none:67 =#
xnodes(grid, ::Nothing; kwargs...) = begin
        #= none:67 =#
        1:1
    end
#= none:68 =#
ynodes(grid, ::Nothing; kwargs...) = begin
        #= none:68 =#
        1:1
    end
#= none:69 =#
znodes(grid, ::Nothing; kwargs...) = begin
        #= none:69 =#
        1:1
    end
#= none:71 =#
#= none:71 =# Core.@doc "    xnodes(grid, ℓx, ℓy, ℓz, with_halos=false)\n\nReturn the positions over the interior nodes on `grid` in the ``x``-direction for the location `ℓx`,\n`ℓy`, `ℓz`. For `Bounded` directions, `Face` nodes include the boundary points.\n\nSee [`znodes`](@ref) for examples.\n" #= none:79 =# @inline(xnodes(grid, ℓx, ℓy, ℓz; kwargs...) = begin
                #= none:79 =#
                xnodes(grid, ℓx; kwargs...)
            end)
#= none:81 =#
#= none:81 =# Core.@doc "    ynodes(grid, ℓx, ℓy, ℓz, with_halos=false)\n\nReturn the positions over the interior nodes on `grid` in the ``y``-direction for the location `ℓx`,\n`ℓy`, `ℓz`. For `Bounded` directions, `Face` nodes include the boundary points.\n\nSee [`znodes`](@ref) for examples.\n" #= none:89 =# @inline(ynodes(grid, ℓx, ℓy, ℓz; kwargs...) = begin
                #= none:89 =#
                ynodes(grid, ℓy; kwargs...)
            end)
#= none:91 =#
#= none:91 =# Core.@doc "    znodes(grid, ℓx, ℓy, ℓz; with_halos=false)\n\nReturn the positions over the interior nodes on `grid` in the ``z``-direction for the location `ℓx`,\n`ℓy`, `ℓz`. For `Bounded` directions, `Face` nodes include the boundary points.\n\n```jldoctest znodes\njulia> using Oceananigans\n\njulia> horz_periodic_grid = RectilinearGrid(size=(3, 3, 3), extent=(2π, 2π, 1), halo=(1, 1, 1),\n                                            topology=(Periodic, Periodic, Bounded));\n\njulia> zC = znodes(horz_periodic_grid, Center())\n3-element view(OffsetArray(::StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}, Int64}, 0:4), 1:3) with eltype Float64:\n -0.8333333333333334\n -0.5\n -0.16666666666666666\n\njulia> zC = znodes(horz_periodic_grid, Center(), Center(), Center())\n3-element view(OffsetArray(::StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}, Int64}, 0:4), 1:3) with eltype Float64:\n -0.8333333333333334\n -0.5\n -0.16666666666666666\n\njulia> zC = znodes(horz_periodic_grid, Center(), Center(), Center(), with_halos=true)\n-1.1666666666666667:0.3333333333333333:0.16666666666666666 with indices 0:4\n```\n" #= none:119 =# @inline(znodes(grid, ℓx, ℓy, ℓz; kwargs...) = begin
                #= none:119 =#
                znodes(grid, ℓz; kwargs...)
            end)
#= none:121 =#
#= none:121 =# Core.@doc "    λnodes(grid::AbstractCurvilinearGrid, ℓx, ℓy, ℓz, with_halos=false)\n\nReturn the positions over the interior nodes on a curvilinear `grid` in the ``λ``-direction\nfor the location `ℓλ`, `ℓφ`, `ℓz`. For `Bounded` directions, `Face` nodes include the boundary points.\n\nSee [`znodes`](@ref) for examples.\n" #= none:129 =# @inline(λnodes(grid::AbstractCurvilinearGrid, ℓλ, ℓφ, ℓz; kwargs...) = begin
                #= none:129 =#
                λnodes(grid, ℓλ; kwargs...)
            end)
#= none:131 =#
#= none:131 =# Core.@doc "    φnodes(grid::AbstractCurvilinearGrid, ℓx, ℓy, ℓz, with_halos=false)\n\nReturn the positions over the interior nodes on a curvilinear `grid` in the ``φ``-direction\nfor the location `ℓλ`, `ℓφ`, `ℓz`. For `Bounded` directions, `Face` nodes include the boundary points.\n\nSee [`znodes`](@ref) for examples.\n" #= none:139 =# @inline(φnodes(grid::AbstractCurvilinearGrid, ℓλ, ℓφ, ℓz; kwargs...) = begin
                #= none:139 =#
                φnodes(grid, ℓφ; kwargs...)
            end)
#= none:141 =#
#= none:141 =# Core.@doc "    nodes(grid, (ℓx, ℓy, ℓz); reshape=false, with_halos=false)\n    nodes(grid, ℓx, ℓy, ℓz; reshape=false, with_halos=false)\n\nReturn a 3-tuple of views over the interior nodes of the `grid`'s\nnative coordinates at the locations in `loc=(ℓx, ℓy, ℓz)` in `x, y, z`.\n\nIf `reshape=true`, the views are reshaped to 3D arrays with non-singleton\ndimensions 1, 2, 3 for `x, y, z`, respectively. These reshaped arrays can then\nbe used in broadcast operations with 3D fields or arrays.\n\nFor `RectilinearGrid`s the native coordinates are `x, y, z`; for curvilinear grids,\nlike `LatitudeLongitudeGrid` or `OrthogonalSphericalShellGrid` the native coordinates\nare `λ, φ, z`.\n\nSee [`xnodes`](@ref), [`ynodes`](@ref), [`znodes`](@ref), [`λnodes`](@ref), and [`φnodes`](@ref).\n" nodes(grid::AbstractGrid, (ℓx, ℓy, ℓz); reshape = false, with_halos = false) = begin
            #= none:158 =#
            nodes(grid, ℓx, ℓy, ℓz; reshape, with_halos)
        end
#= none:165 =#
function xspacing end
#= none:166 =#
function yspacing end
#= none:167 =#
function zspacing end
#= none:169 =#
#= none:169 =# Core.@doc "    xspacings(grid, ℓx, ℓy, ℓz; with_halos=true)\n\nReturn the spacings over the interior nodes on `grid` in the ``x``-direction for the location `ℓx`,\n`ℓy`, `ℓz`. For `Bounded` directions, `Face` nodes include the boundary points.\n\n```jldoctest xspacings\njulia> using Oceananigans\n\njulia> grid = LatitudeLongitudeGrid(size=(8, 15, 10), longitude=(-20, 60), latitude=(-10, 50), z=(-100, 0));\n\njulia> xspacings(grid, Center(), Face(), Center())\n16-element view(OffsetArray(::Vector{Float64}, -2:18), 1:16) with eltype Float64:\n      1.0950562585518518e6\n      1.1058578920188267e6\n      1.1112718969963323e6\n      1.1112718969963323e6\n      1.1058578920188267e6\n      1.0950562585518518e6\n      1.0789196210678827e6\n      1.0575265956426917e6\n      1.0309814069457315e6\n 999413.38046802\n 962976.3124613502\n 921847.720658409\n 876227.979424229\n 826339.3435524226\n 772424.8654621692\n 714747.2110712599\n```\n" #= none:200 =# @inline(xspacings(grid, ℓx, ℓy, ℓz; with_halos = true) = begin
                #= none:200 =#
                xspacings(grid, ℓx; with_halos)
            end)
#= none:202 =#
#= none:202 =# Core.@doc "    yspacings(grid, ℓx, ℓy, ℓz; with_halos=true)\n\nReturn the spacings over the interior nodes on `grid` in the ``y``-direction for the location `ℓx`,\n`ℓy`, `ℓz`. For `Bounded` directions, `Face` nodes include the boundary points.\n\n```jldoctest yspacings\njulia> using Oceananigans\n\njulia> grid = LatitudeLongitudeGrid(size=(20, 15, 10), longitude=(0, 20), latitude=(-15, 15), z=(-100, 0));\n\njulia> yspacings(grid, Center(), Center(), Center())\n222389.85328911748\n```\n" #= none:217 =# @inline(yspacings(grid, ℓx, ℓy, ℓz; with_halos = true) = begin
                #= none:217 =#
                yspacings(grid, ℓy; with_halos)
            end)
#= none:219 =#
#= none:219 =# Core.@doc "    zspacings(grid, ℓx, ℓy, ℓz; with_halos=true)\n\nReturn the spacings over the interior nodes on `grid` in the ``z``-direction for the location `ℓx`,\n`ℓy`, `ℓz`. For `Bounded` directions, `Face` nodes include the boundary points.\n\n```jldoctest zspacings\njulia> using Oceananigans\n\njulia> grid = LatitudeLongitudeGrid(size=(20, 15, 10), longitude=(0, 20), latitude=(-15, 15), z=(-100, 0));\n\njulia> zspacings(grid, Center(), Center(), Center())\n10.0\n```\n" #= none:234 =# @inline(zspacings(grid, ℓx, ℓy, ℓz; with_halos = true) = begin
                #= none:234 =#
                zspacings(grid, ℓz; with_halos)
            end)
#= none:236 =#
destantiate(::Face) = begin
        #= none:236 =#
        Face
    end
#= none:237 =#
destantiate(::Center) = begin
        #= none:237 =#
        Center
    end
#= none:239 =#
spacing_function(::Val{:x}) = begin
        #= none:239 =#
        xspacing
    end
#= none:240 =#
spacing_function(::Val{:y}) = begin
        #= none:240 =#
        yspacing
    end
#= none:241 =#
spacing_function(::Val{:z}) = begin
        #= none:241 =#
        zspacing
    end
#= none:243 =#
function minimum_spacing(s, grid, ℓx, ℓy, ℓz)
    #= none:243 =#
    #= none:244 =#
    spacing = spacing_function(s)
    #= none:245 =#
    (LX, LY, LZ) = map(destantiate, (ℓx, ℓy, ℓz))
    #= none:246 =#
    Δ = KernelFunctionOperation{LX, LY, LZ}(spacing, grid, ℓx, ℓy, ℓz)
    #= none:248 =#
    return minimum(Δ)
end
#= none:251 =#
#= none:251 =# Core.@doc "    minimum_xspacing(grid, ℓx, ℓy, ℓz)\n    minimum_xspacing(grid) = minimum_xspacing(grid, Center(), Center(), Center())\n\nReturn the minimum spacing for `grid` in ``x`` direction at location `ℓx, ℓy, ℓz`.\n\nExamples\n========\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=(2, 4, 8), extent=(1, 1, 1));\n\njulia> minimum_xspacing(grid, Center(), Center(), Center())\n0.5\n```\n" minimum_xspacing(grid, ℓx, ℓy, ℓz) = begin
            #= none:268 =#
            minimum_spacing(Val(:x), grid, ℓx, ℓy, ℓz)
        end
#= none:269 =#
minimum_xspacing(grid) = begin
        #= none:269 =#
        minimum_spacing(Val(:x), grid, Center(), Center(), Center())
    end
#= none:270 =#
#= none:270 =# Core.@doc "    minimum_yspacing(grid, ℓx, ℓy, ℓz)\n    minimum_yspacing(grid) = minimum_yspacing(grid, Center(), Center(), Center())\n\nReturn the minimum spacing for `grid` in ``y`` direction at location `ℓx, ℓy, ℓz`.\n\nExamples\n========\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=(2, 4, 8), extent=(1, 1, 1));\n\njulia> minimum_yspacing(grid, Center(), Center(), Center())\n0.25\n```\n" minimum_yspacing(grid, ℓx, ℓy, ℓz) = begin
            #= none:287 =#
            minimum_spacing(Val(:y), grid, ℓx, ℓy, ℓz)
        end
#= none:288 =#
minimum_yspacing(grid) = begin
        #= none:288 =#
        minimum_spacing(Val(:y), grid, Center(), Center(), Center())
    end
#= none:290 =#
#= none:290 =# Core.@doc "    minimum_zspacing(grid, ℓx, ℓy, ℓz)\n    minimum_zspacing(grid) = minimum_zspacing(grid, Center(), Center(), Center())\n\nReturn the minimum spacing for `grid` in ``z`` direction at location `ℓx, ℓy, ℓz`.\n\nExamples\n========\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=(2, 4, 8), extent=(1, 1, 1));\n\njulia> minimum_zspacing(grid, Center(), Center(), Center())\n0.125\n```\n" minimum_zspacing(grid, ℓx, ℓy, ℓz) = begin
            #= none:307 =#
            minimum_spacing(Val(:z), grid, ℓx, ℓy, ℓz)
        end
#= none:308 =#
minimum_zspacing(grid) = begin
        #= none:308 =#
        minimum_spacing(Val(:z), grid, Center(), Center(), Center())
    end