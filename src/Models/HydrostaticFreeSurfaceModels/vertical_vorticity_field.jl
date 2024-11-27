
#= none:1 =#
using Oceananigans.Grids: Face, Face, Center
#= none:2 =#
using Oceananigans.Operators: ζ₃ᶠᶠᶜ
#= none:3 =#
using Oceananigans.AbstractOperations: KernelFunctionOperation
#= none:5 =#
#= none:5 =# Core.@doc "    VerticalVorticityField(model; kw...)\n\nReturns a `Field` that `compute!`s vertical vorticity in a manner consistent\nwith the `VectorInvariant` momentum advection scheme for curvilinear grids.\n\nIn particular, `VerticalVorticityField` uses `ζ₃ᶠᶠᶜ`, which in turn computes the\nvertical vorticity by first integrating the velocity field around the borders\nof the vorticity cell to find the vertical circulation, and then dividing by the\narea of the vorticity cell to compute vertical vorticity.\n" VerticalVorticityField(model; kw...) = begin
            #= none:16 =#
            VerticalVorticityField(model.grid, model.velocities; kw...)
        end
#= none:18 =#
function VerticalVorticityField(grid, velocities; kw...)
    #= none:18 =#
    #= none:19 =#
    (u, v, w) = velocities
    #= none:20 =#
    vorticity_operation = KernelFunctionOperation{Face, Face, Center}(ζ₃ᶠᶠᶜ, grid, u, v)
    #= none:21 =#
    return Field(vorticity_operation; kw...)
end