
#= none:1 =#
using Oceananigans.Grids: Center, Face
#= none:2 =#
using Oceananigans.Fields: XFaceField, YFaceField, ZFaceField, TracerFields
#= none:4 =#
function HydrostaticFreeSurfaceVelocityFields(::Nothing, grid, clock, bcs = NamedTuple())
    #= none:4 =#
    #= none:5 =#
    u = XFaceField(grid, boundary_conditions = bcs.u)
    #= none:6 =#
    v = YFaceField(grid, boundary_conditions = bcs.v)
    #= none:7 =#
    w = ZFaceField(grid)
    #= none:8 =#
    return (u = u, v = v, w = w)
end
#= none:11 =#
function HydrostaticFreeSurfaceTendencyFields(velocities, free_surface, grid, tracer_names)
    #= none:11 =#
    #= none:12 =#
    u = XFaceField(grid)
    #= none:13 =#
    v = YFaceField(grid)
    #= none:14 =#
    η = free_surface_displacement_field(velocities, free_surface, grid)
    #= none:15 =#
    tracers = TracerFields(tracer_names, grid)
    #= none:16 =#
    return merge((u = u, v = v, η = η), tracers)
end