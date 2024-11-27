
#= none:2 =#
const c = Center()
#= none:3 =#
const f = Face()
#= none:5 =#
function build_condition(Topo, side, dim)
    #= none:5 =#
    #= none:6 =#
    if Topo == :Bounded
        #= none:7 =#
        return :(($side < 1) | ($side > grid.$(dim)))
    elseif #= none:8 =# Topo == :LeftConnected
        #= none:9 =#
        return :($side > grid.$(dim))
    else
        #= none:11 =#
        return :($side < 1)
    end
end
#= none:19 =#
#= none:19 =# Core.@doc "    inactive_cell(i, j, k, grid)\n\nReturn `true` when the tracer cell at `i, j, k` is \"external\" to the domain boundary.\n\n`inactive_cell`s include halo cells in `Bounded` directions, right halo cells in\n`LeftConnected` directions, left halo cells in `RightConnected` directions, and cells\nwithin an immersed boundary. Cells that are staggered with respect to tracer cells and\nwhich lie _on_ the boundary are considered active.\n" #= none:29 =# @inline(inactive_cell(i, j, k, grid) = begin
                #= none:29 =#
                false
            end)
#= none:30 =#
#= none:30 =# @inline active_cell(i, j, k, grid) = begin
            #= none:30 =#
            !(inactive_cell(i, j, k, grid))
        end
#= none:38 =#
Topos = (:Bounded, :LeftConnected, :RightConnected)
#= none:40 =#
for PrimaryTopo = Topos
    #= none:42 =#
    xcondition = build_condition(PrimaryTopo, :i, :Nx)
    #= none:43 =#
    ycondition = build_condition(PrimaryTopo, :j, :Ny)
    #= none:44 =#
    zcondition = build_condition(PrimaryTopo, :k, :Nz)
    #= none:46 =#
    #= none:46 =# @eval begin
            #= none:47 =#
            XBoundedGrid = AbstractGrid{<:Any, <:$PrimaryTopo}
            #= none:48 =#
            YBoundedGrid = AbstractGrid{<:Any, <:Any, <:$PrimaryTopo}
            #= none:49 =#
            ZBoundedGrid = AbstractGrid{<:Any, <:Any, <:Any, <:$PrimaryTopo}
            #= none:51 =#
            #= none:51 =# @inline inactive_cell(i, j, k, grid::XBoundedGrid) = begin
                        #= none:51 =#
                        $xcondition
                    end
            #= none:52 =#
            #= none:52 =# @inline inactive_cell(i, j, k, grid::YBoundedGrid) = begin
                        #= none:52 =#
                        $ycondition
                    end
            #= none:53 =#
            #= none:53 =# @inline inactive_cell(i, j, k, grid::ZBoundedGrid) = begin
                        #= none:53 =#
                        $zcondition
                    end
        end
    #= none:56 =#
    for SecondaryTopo = Topos
        #= none:58 =#
        xycondition = :($xcondition | $(build_condition(SecondaryTopo, :j, :Ny)))
        #= none:59 =#
        xzcondition = :($xcondition | $(build_condition(SecondaryTopo, :k, :Nz)))
        #= none:60 =#
        yzcondition = :($ycondition | $(build_condition(SecondaryTopo, :k, :Nz)))
        #= none:62 =#
        #= none:62 =# @eval begin
                #= none:63 =#
                XYBoundedGrid = AbstractGrid{<:Any, <:$PrimaryTopo, <:$SecondaryTopo}
                #= none:64 =#
                XZBoundedGrid = AbstractGrid{<:Any, <:$PrimaryTopo, <:Any, <:$SecondaryTopo}
                #= none:65 =#
                YZBoundedGrid = AbstractGrid{<:Any, <:Any, <:$PrimaryTopo, <:$SecondaryTopo}
                #= none:67 =#
                #= none:67 =# @inline inactive_cell(i, j, k, grid::XYBoundedGrid) = begin
                            #= none:67 =#
                            $xycondition
                        end
                #= none:68 =#
                #= none:68 =# @inline inactive_cell(i, j, k, grid::XZBoundedGrid) = begin
                            #= none:68 =#
                            $xzcondition
                        end
                #= none:69 =#
                #= none:69 =# @inline inactive_cell(i, j, k, grid::YZBoundedGrid) = begin
                            #= none:69 =#
                            $yzcondition
                        end
            end
        #= none:72 =#
        for TertiaryTopo = Topos
            #= none:73 =#
            xyzcondition = :($xycondition | $(build_condition(TertiaryTopo, :k, :Nz)))
            #= none:75 =#
            #= none:75 =# @eval begin
                    #= none:76 =#
                    XYZBoundedGrid = AbstractGrid{<:Any, <:$PrimaryTopo, <:$SecondaryTopo, <:$TertiaryTopo}
                    #= none:78 =#
                    #= none:78 =# @inline inactive_cell(i, j, k, grid::XYZBoundedGrid) = begin
                                #= none:78 =#
                                $xyzcondition
                            end
                end
            #= none:80 =#
        end
        #= none:81 =#
    end
    #= none:82 =#
end
#= none:84 =#
#= none:84 =# Core.@doc "    inactive_node(i, j, k, grid, LX, LY, LZ)\n\nReturn `true` when the location `(LX, LY, LZ)` is \"inactive\" and thus not directly\nassociated with an \"active\" cell.\n\nFor `Face` locations, this means the node is surrounded by `inactive_cell`s:\nthe interfaces of \"active\" cells are _not_ `inactive_node`.\n\nFor `Center` locations, this means the direction is `Bounded` and that the\ncell or interface centered on the location is completely outside the active\nregion of the grid.\n" #= none:97 =# @inline(inactive_node(i, j, k, grid, LX, LY, LZ) = begin
                #= none:97 =#
                inactive_cell(i, j, k, grid)
            end)
#= none:99 =#
#= none:99 =# @inline inactive_node(i, j, k, grid, ::Face, LY, LZ) = begin
            #= none:99 =#
            inactive_cell(i, j, k, grid) & inactive_cell(i - 1, j, k, grid)
        end
#= none:100 =#
#= none:100 =# @inline inactive_node(i, j, k, grid, LX, ::Face, LZ) = begin
            #= none:100 =#
            inactive_cell(i, j, k, grid) & inactive_cell(i, j - 1, k, grid)
        end
#= none:101 =#
#= none:101 =# @inline inactive_node(i, j, k, grid, LX, LY, ::Face) = begin
            #= none:101 =#
            inactive_cell(i, j, k, grid) & inactive_cell(i, j, k - 1, grid)
        end
#= none:103 =#
#= none:103 =# @inline inactive_node(i, j, k, grid, ::Face, ::Face, LZ) = begin
            #= none:103 =#
            inactive_node(i, j, k, grid, c, f, c) & inactive_node(i - 1, j, k, grid, c, f, c)
        end
#= none:104 =#
#= none:104 =# @inline inactive_node(i, j, k, grid, ::Face, LY, ::Face) = begin
            #= none:104 =#
            inactive_node(i, j, k, grid, c, c, f) & inactive_node(i - 1, j, k, grid, c, c, f)
        end
#= none:105 =#
#= none:105 =# @inline inactive_node(i, j, k, grid, LX, ::Face, ::Face) = begin
            #= none:105 =#
            inactive_node(i, j, k, grid, c, f, c) & inactive_node(i, j, k - 1, grid, c, f, c)
        end
#= none:107 =#
#= none:107 =# @inline inactive_node(i, j, k, grid, ::Face, ::Face, ::Face) = begin
            #= none:107 =#
            inactive_node(i, j, k, grid, c, f, f) & inactive_node(i - 1, j, k, grid, c, f, f)
        end
#= none:109 =#
#= none:109 =# Core.@doc "    peripheral_node(i, j, k, grid, LX, LY, LZ)\n\nReturn `true` when the location `(LX, LY, LZ)`, is _either_ inactive or\nlies on the boundary between inactive and active cells in a `Bounded` direction.\n" #= none:115 =# @inline(peripheral_node(i, j, k, grid, LX, LY, LZ) = begin
                #= none:115 =#
                inactive_cell(i, j, k, grid)
            end)
#= none:117 =#
#= none:117 =# @inline peripheral_node(i, j, k, grid, ::Face, LY, LZ) = begin
            #= none:117 =#
            inactive_cell(i, j, k, grid) | inactive_cell(i - 1, j, k, grid)
        end
#= none:118 =#
#= none:118 =# @inline peripheral_node(i, j, k, grid, LX, ::Face, LZ) = begin
            #= none:118 =#
            inactive_cell(i, j, k, grid) | inactive_cell(i, j - 1, k, grid)
        end
#= none:119 =#
#= none:119 =# @inline peripheral_node(i, j, k, grid, LX, LY, ::Face) = begin
            #= none:119 =#
            inactive_cell(i, j, k, grid) | inactive_cell(i, j, k - 1, grid)
        end
#= none:121 =#
#= none:121 =# @inline peripheral_node(i, j, k, grid, ::Face, ::Face, LZ) = begin
            #= none:121 =#
            peripheral_node(i, j, k, grid, c, f, c) | peripheral_node(i - 1, j, k, grid, c, f, c)
        end
#= none:122 =#
#= none:122 =# @inline peripheral_node(i, j, k, grid, ::Face, LY, ::Face) = begin
            #= none:122 =#
            peripheral_node(i, j, k, grid, c, c, f) | peripheral_node(i - 1, j, k, grid, c, c, f)
        end
#= none:123 =#
#= none:123 =# @inline peripheral_node(i, j, k, grid, LX, ::Face, ::Face) = begin
            #= none:123 =#
            peripheral_node(i, j, k, grid, c, f, c) | peripheral_node(i, j, k - 1, grid, c, f, c)
        end
#= none:125 =#
#= none:125 =# @inline peripheral_node(i, j, k, grid, ::Face, ::Face, ::Face) = begin
            #= none:125 =#
            peripheral_node(i, j, k, grid, c, f, f) | peripheral_node(i - 1, j, k, grid, c, f, f)
        end
#= none:127 =#
#= none:127 =# Core.@doc "    boundary_node(i, j, k, grid, LX, LY, LZ)\n\nReturn `true` when the location `(LX, LY, LZ)` lies on a boundary.\n" #= none:132 =# @inline(boundary_node(i, j, k, grid, LX, LY, LZ) = begin
                #= none:132 =#
                peripheral_node(i, j, k, grid, LX, LY, LZ) & !(inactive_node(i, j, k, grid, LX, LY, LZ))
            end)