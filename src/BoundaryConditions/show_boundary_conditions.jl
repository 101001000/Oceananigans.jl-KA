
#= none:1 =#
import Base: show
#= none:2 =#
using Oceananigans.Utils: prettysummary
#= none:4 =#
const DFBC = DefaultBoundaryCondition
#= none:5 =#
const IBC = BoundaryCondition{Open, Nothing}
#= none:7 =#
bc_str(::FBC) = begin
        #= none:7 =#
        "Flux"
    end
#= none:8 =#
bc_str(::PBC) = begin
        #= none:8 =#
        "Periodic"
    end
#= none:9 =#
(bc_str(::OBC{Open{MS}}) where MS) = begin
        #= none:9 =#
        "Open{$(MS)}"
    end
#= none:10 =#
bc_str(::VBC) = begin
        #= none:10 =#
        "Value"
    end
#= none:11 =#
bc_str(::GBC) = begin
        #= none:11 =#
        "Gradient"
    end
#= none:12 =#
bc_str(::ZFBC) = begin
        #= none:12 =#
        "ZeroFlux"
    end
#= none:13 =#
bc_str(::IBC) = begin
        #= none:13 =#
        "Impenetrable"
    end
#= none:14 =#
bc_str(::DFBC) = begin
        #= none:14 =#
        "Default"
    end
#= none:15 =#
bc_str(::MCBC) = begin
        #= none:15 =#
        "MultiRegionCommunication"
    end
#= none:16 =#
bc_str(::DCBC) = begin
        #= none:16 =#
        "DistributedCommunication"
    end
#= none:17 =#
bc_str(::Nothing) = begin
        #= none:17 =#
        "Nothing"
    end
#= none:23 =#
Base.summary(bc::DFBC) = begin
        #= none:23 =#
        string("DefaultBoundaryCondition (", summary(bc.boundary_condition), ")")
    end
#= none:24 =#
(Base.summary(bc::OBC{Open{MS}}) where MS) = begin
        #= none:24 =#
        string("OpenBoundaryCondition{$(MS)}: ", prettysummary(bc.condition))
    end
#= none:25 =#
Base.summary(bc::IBC) = begin
        #= none:25 =#
        string("ImpenetrableBoundaryCondition")
    end
#= none:26 =#
Base.summary(bc::FBC) = begin
        #= none:26 =#
        string("FluxBoundaryCondition: ", prettysummary(bc.condition))
    end
#= none:27 =#
Base.summary(bc::VBC) = begin
        #= none:27 =#
        string("ValueBoundaryCondition: ", prettysummary(bc.condition))
    end
#= none:28 =#
Base.summary(bc::GBC) = begin
        #= none:28 =#
        string("GradientBoundaryCondition: ", prettysummary(bc.condition))
    end
#= none:29 =#
Base.summary(::PBC) = begin
        #= none:29 =#
        string("PeriodicBoundaryCondition")
    end
#= none:30 =#
Base.summary(bc::DCBC) = begin
        #= none:30 =#
        string("DistributedBoundaryCondition: ", prettysummary(bc.condition))
    end
#= none:32 =#
show(io::IO, bc::BoundaryCondition) = begin
        #= none:32 =#
        print(io, summary(bc))
    end
#= none:38 =#
Base.summary(fbcs::FieldBoundaryConditions) = begin
        #= none:38 =#
        "FieldBoundaryConditions"
    end
#= none:40 =#
show_field_boundary_conditions(bcs::FieldBoundaryConditions, padding = "") = begin
        #= none:40 =#
        string("Oceananigans.FieldBoundaryConditions, with boundary conditions", "\n", padding, "├── west: ", summary(bcs.west), "\n", padding, "├── east: ", summary(bcs.east), "\n", padding, "├── south: ", summary(bcs.south), "\n", padding, "├── north: ", summary(bcs.north), "\n", padding, "├── bottom: ", summary(bcs.bottom), "\n", padding, "├── top: ", summary(bcs.top), "\n", padding, "└── immersed: ", summary(bcs.immersed))
    end
#= none:50 =#
Base.show(io::IO, fieldbcs::FieldBoundaryConditions) = begin
        #= none:50 =#
        print(io, show_field_boundary_conditions(fieldbcs))
    end