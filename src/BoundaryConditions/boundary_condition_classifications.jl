
#= none:1 =#
#= none:1 =# Core.@doc "    AbstractBoundaryConditionClassification\n\nAbstract supertype for boundary condition types.\n" abstract type AbstractBoundaryConditionClassification end
#= none:8 =#
#= none:8 =# Core.@doc "    struct Periodic <: AbstractBoundaryConditionClassification\n\nA classification specifying a periodic boundary condition.\n\nA condition may not be specified with a `Periodic` boundary condition.\n" struct Periodic <: AbstractBoundaryConditionClassification
        #= none:15 =#
    end
#= none:17 =#
#= none:17 =# Core.@doc "    struct Flux <: AbstractBoundaryConditionClassification\n\nA classification specifying a boundary condition on the flux of a field.\n\nThe sign convention is such that a positive flux represents the flux of a quantity in the\npositive direction. For example, a positive vertical flux implies a quantity is fluxed\nupwards, in the ``+z`` direction.\n\nDue to this convention, a positive flux applied to the top boundary specifies that a quantity\nis fluxed upwards across the top boundary and thus out of the domain. As a result, a positive\nflux applied to a top boundary leads to a reduction of that quantity in the interior of the\ndomain; for example, a positive, upwards flux of heat at the top of the domain acts to cool\nthe interior of the domain. Conversely, a positive flux applied to the bottom boundary leads\nto an increase of the quantity in the interior of the domain. The same logic holds for east,\nwest, north, and south boundaries.\n" struct Flux <: AbstractBoundaryConditionClassification
        #= none:34 =#
    end
#= none:36 =#
#= none:36 =# Core.@doc "    struct Gradient <: AbstractBoundaryConditionClassification\n\nA classification specifying a boundary condition on the derivative or gradient of a field. Also\ncalled a Neumann boundary condition.\n" struct Gradient <: AbstractBoundaryConditionClassification
        #= none:42 =#
    end
#= none:44 =#
#= none:44 =# Core.@doc "    struct Value <: AbstractBoundaryConditionClassification\n\nA classification specifying a boundary condition on the value of a field. Also called a Dirchlet\nboundary condition.\n" struct Value <: AbstractBoundaryConditionClassification
        #= none:50 =#
    end
#= none:52 =#
#= none:52 =# Core.@doc "    struct Open <: AbstractBoundaryConditionClassification\n\nA classification that specifies the halo regions of a field directly.\n\nFor fields located at `Faces`, `Open` also specifies field value _on_ the boundary.\n\nOpen boundary conditions are used to specify the component of a velocity field normal to a boundary\nand can also be used to describe nested or linked simulation domains.\n" struct Open{MS} <: AbstractBoundaryConditionClassification
        #= none:63 =#
        matching_scheme::MS
    end
#= none:66 =#
Open() = begin
        #= none:66 =#
        Open(nothing)
    end
#= none:68 =#
(open::Open)() = begin
        #= none:68 =#
        open
    end
#= none:70 =#
Adapt.adapt_structure(to, open::Open) = begin
        #= none:70 =#
        Open(adapt(to, open.matching_scheme))
    end
#= none:72 =#
#= none:72 =# Core.@doc "    struct MultiRegionCommunication <: AbstractBoundaryConditionClassification\n\nA classification specifying a shared memory communicating boundary condition\n" struct MultiRegionCommunication <: AbstractBoundaryConditionClassification
        #= none:77 =#
    end
#= none:79 =#
#= none:79 =# Core.@doc "    struct DistributedCommunication <: AbstractBoundaryConditionClassification\n\nA classification specifying a distributed memory communicating boundary condition \n" struct DistributedCommunication <: AbstractBoundaryConditionClassification
        #= none:84 =#
    end