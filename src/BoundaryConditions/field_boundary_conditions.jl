
#= none:1 =#
using Oceananigans.Operators: assumed_field_location
#= none:7 =#
struct DefaultBoundaryCondition{BC}
    #= none:8 =#
    boundary_condition::BC
end
#= none:11 =#
DefaultBoundaryCondition() = begin
        #= none:11 =#
        DefaultBoundaryCondition(NoFluxBoundaryCondition())
    end
#= none:13 =#
default_prognostic_bc(::Grids.Periodic, loc, default) = begin
        #= none:13 =#
        PeriodicBoundaryCondition()
    end
#= none:14 =#
default_prognostic_bc(::FullyConnected, loc, default) = begin
        #= none:14 =#
        MultiRegionCommunicationBoundaryCondition()
    end
#= none:15 =#
default_prognostic_bc(::Flat, loc, default) = begin
        #= none:15 =#
        nothing
    end
#= none:16 =#
default_prognostic_bc(::Bounded, ::Center, default) = begin
        #= none:16 =#
        default.boundary_condition
    end
#= none:17 =#
default_prognostic_bc(::LeftConnected, ::Center, default) = begin
        #= none:17 =#
        default.boundary_condition
    end
#= none:18 =#
default_prognostic_bc(::RightConnected, ::Center, default) = begin
        #= none:18 =#
        default.boundary_condition
    end
#= none:21 =#
default_prognostic_bc(::Bounded, ::Face, default) = begin
        #= none:21 =#
        ImpenetrableBoundaryCondition()
    end
#= none:22 =#
default_prognostic_bc(::LeftConnected, ::Face, default) = begin
        #= none:22 =#
        ImpenetrableBoundaryCondition()
    end
#= none:23 =#
default_prognostic_bc(::RightConnected, ::Face, default) = begin
        #= none:23 =#
        ImpenetrableBoundaryCondition()
    end
#= none:25 =#
default_prognostic_bc(::Bounded, ::Nothing, default) = begin
        #= none:25 =#
        nothing
    end
#= none:26 =#
default_prognostic_bc(::Flat, ::Nothing, default) = begin
        #= none:26 =#
        nothing
    end
#= none:27 =#
default_prognostic_bc(::Grids.Periodic, ::Nothing, default) = begin
        #= none:27 =#
        nothing
    end
#= none:28 =#
default_prognostic_bc(::FullyConnected, ::Nothing, default) = begin
        #= none:28 =#
        nothing
    end
#= none:29 =#
default_prognostic_bc(::LeftConnected, ::Nothing, default) = begin
        #= none:29 =#
        nothing
    end
#= none:30 =#
default_prognostic_bc(::RightConnected, ::Nothing, default) = begin
        #= none:30 =#
        nothing
    end
#= none:32 =#
default_auxiliary_bc(topo, loc) = begin
        #= none:32 =#
        default_prognostic_bc(topo, loc, DefaultBoundaryCondition())
    end
#= none:33 =#
default_auxiliary_bc(::Bounded, ::Face) = begin
        #= none:33 =#
        nothing
    end
#= none:34 =#
default_auxiliary_bc(::RightConnected, ::Face) = begin
        #= none:34 =#
        nothing
    end
#= none:35 =#
default_auxiliary_bc(::LeftConnected, ::Face) = begin
        #= none:35 =#
        nothing
    end
#= none:41 =#
mutable struct FieldBoundaryConditions{W, E, S, N, B, T, I}
    #= none:42 =#
    west::W
    #= none:43 =#
    east::E
    #= none:44 =#
    south::S
    #= none:45 =#
    north::N
    #= none:46 =#
    bottom::B
    #= none:47 =#
    top::T
    #= none:48 =#
    immersed::I
end
#= none:51 =#
function FieldBoundaryConditions(indices::Tuple, west, east, south, north, bottom, top, immersed)
    #= none:51 =#
    #= none:53 =#
    (west, east) = window_boundary_conditions(indices[1], west, east)
    #= none:54 =#
    (south, north) = window_boundary_conditions(indices[2], south, north)
    #= none:55 =#
    (bottom, top) = window_boundary_conditions(indices[3], bottom, top)
    #= none:56 =#
    return FieldBoundaryConditions(west, east, south, north, bottom, top, immersed)
end
#= none:59 =#
FieldBoundaryConditions(indices::Tuple, bcs::FieldBoundaryConditions) = begin
        #= none:59 =#
        FieldBoundaryConditions(indices, (getproperty(bcs, side) for side = propertynames(bcs))...)
    end
#= none:63 =#
FieldBoundaryConditions(indices::Tuple, ::Nothing) = begin
        #= none:63 =#
        nothing
    end
#= none:65 =#
window_boundary_conditions(::Colon, left, right) = begin
        #= none:65 =#
        (left, right)
    end
#= none:66 =#
window_boundary_conditions(::UnitRange, left, right) = begin
        #= none:66 =#
        (nothing, nothing)
    end
#= none:68 =#
on_architecture(arch, fbcs::FieldBoundaryConditions) = begin
        #= none:68 =#
        FieldBoundaryConditions(on_architecture(arch, fbcs.west), on_architecture(arch, fbcs.east), on_architecture(arch, fbcs.south), on_architecture(arch, fbcs.north), on_architecture(arch, fbcs.bottom), on_architecture(arch, fbcs.top), on_architecture(arch, fbcs.immersed))
    end
#= none:77 =#
#= none:77 =# Core.@doc "    FieldBoundaryConditions(; kwargs...)\n\nReturn a template for boundary conditions on prognostic fields.\n\nKeyword arguments\n=================\n\nKeyword arguments specify boundary conditions on the 7 possible boundaries:\n\n- `west`: left end point in the `x`-direction where `i = 1`\n- `east`: right end point in the `x`-direction where `i = grid.Nx`\n- `south`: left end point in the `y`-direction where `j = 1`\n- `north`: right end point in the `y`-direction where `j = grid.Ny`\n- `bottom`: right end point in the `z`-direction where `k = 1`\n- `top`: right end point in the `z`-direction where `k = grid.Nz`\n- `immersed`: boundary between solid and fluid for immersed boundaries\n\nIf a boundary condition is unspecified, the default for prognostic fields\nand the topology in the boundary-normal direction is used:\n\n - `PeriodicBoundaryCondition` for `Periodic` directions\n - `NoFluxBoundaryCondition` for `Bounded` directions and `Centered`-located fields\n - `ImpenetrableBoundaryCondition` for `Bounded` directions and `Face`-located fields\n - `nothing` for `Flat` directions and/or `Nothing`-located fields\n" FieldBoundaryConditions(default_bounded_bc::BoundaryCondition = NoFluxBoundaryCondition(); west = DefaultBoundaryCondition(default_bounded_bc), east = DefaultBoundaryCondition(default_bounded_bc), south = DefaultBoundaryCondition(default_bounded_bc), north = DefaultBoundaryCondition(default_bounded_bc), bottom = DefaultBoundaryCondition(default_bounded_bc), top = DefaultBoundaryCondition(default_bounded_bc), immersed = DefaultBoundaryCondition(default_bounded_bc)) = begin
            #= none:103 =#
            FieldBoundaryConditions(west, east, south, north, bottom, top, immersed)
        end
#= none:113 =#
#= none:113 =# Core.@doc "    FieldBoundaryConditions(grid, location, indices=(:, :, :);\n                            west     = default_auxiliary_bc(topology(grid, 1)(), location[1]()),\n                            east     = default_auxiliary_bc(topology(grid, 1)(), location[1]()),\n                            south    = default_auxiliary_bc(topology(grid, 2)(), location[2]()),\n                            north    = default_auxiliary_bc(topology(grid, 2)(), location[2]()),\n                            bottom   = default_auxiliary_bc(topology(grid, 3)(), location[3]()),\n                            top      = default_auxiliary_bc(topology(grid, 3)(), location[3]()),\n                            immersed = NoFluxBoundaryCondition())\n\nReturn boundary conditions for auxiliary fields (fields whose values are\nderived from a model's prognostic fields) on `grid` and at `location`.\n\nKeyword arguments\n=================\n\nKeyword arguments specify boundary conditions on the 6 possible boundaries:\n\n- `west`, left end point in the `x`-direction where `i = 1`\n- `east`, right end point in the `x`-direction where `i = grid.Nx`\n- `south`, left end point in the `y`-direction where `j = 1`\n- `north`, right end point in the `y`-direction where `j = grid.Ny`\n- `bottom`, right end point in the `z`-direction where `k = 1`\n- `top`, right end point in the `z`-direction where `k = grid.Nz`\n- `immersed`: boundary between solid and fluid for immersed boundaries\n\nIf a boundary condition is unspecified, the default for auxiliary fields\nand the topology in the boundary-normal direction is used:\n\n- `PeriodicBoundaryCondition` for `Periodic` directions\n- `GradientBoundaryCondition(0)` for `Bounded` directions and `Centered`-located fields\n- `nothing` for `Bounded` directions and `Face`-located fields\n- `nothing` for `Flat` directions and/or `Nothing`-located fields\n" function FieldBoundaryConditions(grid::AbstractGrid, location, indices = (:, :, :); west = default_auxiliary_bc((topology(grid, 1))(), (location[1])()), east = default_auxiliary_bc((topology(grid, 1))(), (location[1])()), south = default_auxiliary_bc((topology(grid, 2))(), (location[2])()), north = default_auxiliary_bc((topology(grid, 2))(), (location[2])()), bottom = default_auxiliary_bc((topology(grid, 3))(), (location[3])()), top = default_auxiliary_bc((topology(grid, 3))(), (location[3])()), immersed = NoFluxBoundaryCondition())
        #= none:147 =#
        #= none:156 =#
        return FieldBoundaryConditions(indices, west, east, south, north, bottom, top, immersed)
    end
#= none:166 =#
function regularize_immersed_boundary_condition(ibc, grid, loc, field_name, args...)
    #= none:166 =#
    #= none:167 =#
    if !(ibc isa DefaultBoundaryCondition)
        #= none:168 =#
        msg = "$(field_name) was assigned an immersed boundary condition\n$(ibc) ,\nbut this is not supported on\n$(summary(grid)) .\nThe immersed boundary condition on $(field_name) will have no effect.\n"
        #= none:175 =#
        #= none:175 =# @warn msg
    end
    #= none:178 =#
    return NoFluxBoundaryCondition()
end
#= none:182 =#
function regularize_boundary_condition(default::DefaultBoundaryCondition, grid, loc, dim, args...)
    #= none:182 =#
    #= none:183 =#
    default_bc = default_prognostic_bc((topology(grid, dim))(), (loc[dim])(), default)
    #= none:184 =#
    return regularize_boundary_condition(default_bc, grid, loc, dim, args...)
end
#= none:187 =#
regularize_boundary_condition(bc, args...) = begin
        #= none:187 =#
        bc
    end
#= none:190 =#
(regularize_boundary_condition(bc::BoundaryCondition{C, <:Number}, grid, args...) where C) = begin
        #= none:190 =#
        BoundaryCondition(bc.classification, convert(eltype(grid), bc.condition))
    end
#= none:193 =#
#= none:193 =# Core.@doc " \n    regularize_field_boundary_conditions(bcs::FieldBoundaryConditions,\n                                         grid::AbstractGrid,\n                                         field_name::Symbol,\n                                         prognostic_names=nothing)\n\nCompute default boundary conditions and attach field locations to ContinuousBoundaryFunction\nboundary conditions for prognostic model field boundary conditions.\n\n!!! warn \"No support for `ContinuousBoundaryFunction` for immersed boundary conditions\"\n    Do not regularize immersed boundary conditions.\n\n    Currently, there is no support `ContinuousBoundaryFunction` for immersed boundary\n    conditions.\n" function regularize_field_boundary_conditions(bcs::FieldBoundaryConditions, grid::AbstractGrid, field_name::Symbol, prognostic_names = nothing)
        #= none:208 =#
        #= none:213 =#
        loc = assumed_field_location(field_name)
        #= none:215 =#
        west = regularize_boundary_condition(bcs.west, grid, loc, 1, LeftBoundary, prognostic_names)
        #= none:216 =#
        east = regularize_boundary_condition(bcs.east, grid, loc, 1, RightBoundary, prognostic_names)
        #= none:217 =#
        south = regularize_boundary_condition(bcs.south, grid, loc, 2, LeftBoundary, prognostic_names)
        #= none:218 =#
        north = regularize_boundary_condition(bcs.north, grid, loc, 2, RightBoundary, prognostic_names)
        #= none:219 =#
        bottom = regularize_boundary_condition(bcs.bottom, grid, loc, 3, LeftBoundary, prognostic_names)
        #= none:220 =#
        top = regularize_boundary_condition(bcs.top, grid, loc, 3, RightBoundary, prognostic_names)
        #= none:222 =#
        immersed = regularize_immersed_boundary_condition(bcs.immersed, grid, loc, field_name, prognostic_names)
        #= none:224 =#
        return FieldBoundaryConditions(west, east, south, north, bottom, top, immersed)
    end
#= none:228 =#
function regularize_field_boundary_conditions(boundary_conditions::NamedTuple, grid::AbstractGrid, group_name::Symbol, prognostic_names = nothing)
    #= none:228 =#
    #= none:233 =#
    return NamedTuple((field_name => regularize_field_boundary_conditions(field_bcs, grid, field_name, prognostic_names) for (field_name, field_bcs) = pairs(boundary_conditions)))
end
#= none:237 =#
regularize_field_boundary_conditions(::Missing, grid::AbstractGrid, field_name::Symbol, prognostic_names = nothing) = begin
        #= none:237 =#
        missing
    end
#= none:246 =#
regularize_field_boundary_conditions(boundary_conditions::NamedTuple, grid::AbstractGrid, prognostic_names::Tuple) = begin
        #= none:246 =#
        NamedTuple((field_name => regularize_field_boundary_conditions(field_bcs, grid, field_name, prognostic_names) for (field_name, field_bcs) = pairs(boundary_conditions)))
    end