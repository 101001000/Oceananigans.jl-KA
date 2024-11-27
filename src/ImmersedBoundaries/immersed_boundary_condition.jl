
#= none:1 =#
using Oceananigans.BoundaryConditions: BoundaryCondition, DefaultBoundaryCondition, LeftBoundary, RightBoundary, regularize_boundary_condition, VBC, GBC, FBC, Flux
#= none:8 =#
import Oceananigans.BoundaryConditions: regularize_immersed_boundary_condition, bc_str, update_boundary_condition!
#= none:12 =#
struct ImmersedBoundaryCondition{W, E, S, N, B, T}
    #= none:13 =#
    west::W
    #= none:14 =#
    east::E
    #= none:15 =#
    south::S
    #= none:16 =#
    north::N
    #= none:17 =#
    bottom::B
    #= none:18 =#
    top::T
end
#= none:21 =#
const IBC = ImmersedBoundaryCondition
#= none:23 =#
bc_str(::IBC) = begin
        #= none:23 =#
        "ImmersedBoundaryCondition"
    end
#= none:25 =#
Base.summary(ibc::IBC) = begin
        #= none:25 =#
        string(bc_str(ibc), " with ", "west=", bc_str(ibc.west), ", ", "east=", bc_str(ibc.east), ", ", "south=", bc_str(ibc.south), ", ", "north=", bc_str(ibc.north), ", ", "bottom=", bc_str(ibc.bottom), ", ", "top=", bc_str(ibc.top))
    end
#= none:34 =#
Base.show(io::IO, ibc::IBC) = begin
        #= none:34 =#
        print(io, "ImmersedBoundaryCondition:", "\n", "├── west: ", summary(ibc.west), "\n", "├── east: ", summary(ibc.east), "\n", "├── south: ", summary(ibc.south), "\n", "├── north: ", summary(ibc.north), "\n", "├── bottom: ", summary(ibc.bottom), "\n", "└── top: ", summary(ibc.top))
    end
#= none:43 =#
#= none:43 =# Core.@doc "    ImmersedBoundaryCondition(; interfaces...)\n\nReturn an `ImmersedBoundaryCondition` with conditions on individual cell\n`interfaces ∈ (west, east, south, north, bottom, top)` between the fluid\nand the immersed boundary.\n" function ImmersedBoundaryCondition(; west = nothing, east = nothing, south = nothing, north = nothing, bottom = nothing, top = nothing)
        #= none:50 =#
        #= none:57 =#
        #= none:57 =# @warn "`ImmersedBoundaryCondition` is experimental."
        #= none:58 =#
        return ImmersedBoundaryCondition(west, east, south, north, bottom, top)
    end
#= none:65 =#
const ZFBC = BoundaryCondition{Flux, Nothing}
#= none:66 =#
regularize_immersed_boundary_condition(ibc::ZFBC, ibg::GFIBG, args...) = begin
        #= none:66 =#
        ibc
    end
#= none:68 =#
regularize_immersed_boundary_condition(default::DefaultBoundaryCondition, ibg::GFIBG, loc, field_name, args...) = begin
        #= none:68 =#
        regularize_immersed_boundary_condition(default.boundary_condition, ibg, loc, field_name, args...)
    end
#= none:72 =#
function regularize_immersed_boundary_condition(ibc::Union{VBC, GBC, FBC}, ibg::GFIBG, loc, field_name, args...)
    #= none:72 =#
    #= none:73 =#
    ibc = ImmersedBoundaryCondition(Tuple((ibc for i = 1:6))...)
    #= none:74 =#
    regularize_immersed_boundary_condition(ibc, ibg, loc, field_name, args...)
end
#= none:77 =#
#= none:77 =# Core.@doc "    regularize_immersed_boundary_condition(bc::BoundaryCondition{C, <:ContinuousBoundaryFunction},\n                                           topo, loc, dim, I, prognostic_field_names) where C\n" function regularize_immersed_boundary_condition(bc::IBC, grid, loc, field_name, prognostic_field_names)
        #= none:81 =#
        #= none:83 =#
        west = if loc[1] === Face
                nothing
            else
                regularize_boundary_condition(bc.west, grid, loc, 1, LeftBoundary, prognostic_field_names)
            end
        #= none:84 =#
        east = if loc[1] === Face
                nothing
            else
                regularize_boundary_condition(bc.east, grid, loc, 1, RightBoundary, prognostic_field_names)
            end
        #= none:85 =#
        south = if loc[2] === Face
                nothing
            else
                regularize_boundary_condition(bc.south, grid, loc, 2, LeftBoundary, prognostic_field_names)
            end
        #= none:86 =#
        north = if loc[2] === Face
                nothing
            else
                regularize_boundary_condition(bc.north, grid, loc, 2, RightBoundary, prognostic_field_names)
            end
        #= none:87 =#
        bottom = if loc[3] === Face
                nothing
            else
                regularize_boundary_condition(bc.bottom, grid, loc, 3, LeftBoundary, prognostic_field_names)
            end
        #= none:88 =#
        top = if loc[3] === Face
                nothing
            else
                regularize_boundary_condition(bc.top, grid, loc, 3, RightBoundary, prognostic_field_names)
            end
        #= none:90 =#
        return ImmersedBoundaryCondition(; west, east, south, north, bottom, top)
    end
#= none:93 =#
Adapt.adapt_structure(to, bc::ImmersedBoundaryCondition) = begin
        #= none:93 =#
        ImmersedBoundaryCondition(Adapt.adapt(to, bc.west), Adapt.adapt(to, bc.east), Adapt.adapt(to, bc.south), Adapt.adapt(to, bc.north), Adapt.adapt(to, bc.bottom), Adapt.adapt(to, bc.top))
    end
#= none:100 =#
update_boundary_condition!(bc::ImmersedBoundaryCondition, args...) = begin
        #= none:100 =#
        nothing
    end