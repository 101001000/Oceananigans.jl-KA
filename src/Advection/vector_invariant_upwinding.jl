
#= none:1 =#
#= none:1 =# Core.@doc "Upwinding treatment of Kinetic Energy Gradient and Divergence fluxes for the Vector Invariant formulation" abstract type AbstractUpwindingTreatment end
#= none:4 =#
struct OnlySelfUpwinding{A, U, V, U2, V2} <: AbstractUpwindingTreatment
    #= none:5 =#
    cross_scheme::A
    #= none:6 =#
    δU_stencil::U
    #= none:7 =#
    δV_stencil::V
    #= none:8 =#
    δu²_stencil::U2
    #= none:9 =#
    δv²_stencil::V2
end
#= none:12 =#
struct CrossAndSelfUpwinding{A, D, U, V} <: AbstractUpwindingTreatment
    #= none:13 =#
    cross_scheme::A
    #= none:14 =#
    divergence_stencil::D
    #= none:15 =#
    δu²_stencil::U
    #= none:16 =#
    δv²_stencil::V
end
#= none:19 =#
struct VelocityUpwinding{A} <: AbstractUpwindingTreatment
    #= none:20 =#
    cross_scheme::A
end
#= none:26 =#
#= none:26 =# @inline extract_centered_scheme(scheme) = begin
            #= none:26 =#
            scheme
        end
#= none:27 =#
#= none:27 =# @inline extract_centered_scheme(scheme::AUAS) = begin
            #= none:27 =#
            scheme.advecting_velocity_scheme
        end
#= none:29 =#
#= none:29 =# Core.@doc "    OnlySelfUpwinding(; cross_scheme = CenteredSecondOrder(),\n                        δU_stencil   = FunctionStencil(divergence_smoothness),\n                        δV_stencil   = FunctionStencil(divergence_smoothness),\n                        δu²_stencil  = FunctionStencil(u_smoothness),\n                        δv²_stencil  = FunctionStencil(v_smoothness))\n\nUpwinding treatment of Kinetic Energy Gradient and Divergence fluxes in the Vector Invariant formulation, whereas only \nthe terms corresponding to the transporting velocity are upwinded. (i.e., terms in `u` in the zonal momentum equation and \nterms in `v` in the meridional momentum equation). The terms corresponding to the tangential velocities (`v` in zonal \ndirection and `u` in meridional direction) are not upwinded.\nThis is the default upwinding treatment for the Vector Invariant formulation.\n\nKeyword arguments\n=================  \n\n- `cross_scheme`: Advection scheme used for cross-reconstructed terms (tangential velocities) \n                  in the kinetic energy gradient and the divergence flux. Defaults to `CenteredSecondOrder()`.\n- `δU_stencil`: Stencil used for smoothness indicators of `δx_U` in case of a `WENO` upwind reconstruction. \n                Defaults to `FunctionStencil(divergence_smoothness)`\n- `δV_stencil`: Same as `δU_stencil` but for the smoothness of `δy_V`\n- `δu²_stencil`: Stencil used for smoothness indicators of `δx_u²` in case of a `WENO` upwind reconstruction. \n                 Defaults to `FunctionStencil(u_smoothness)` \n- `δv²_stencil`: Same as `δu²_stencil` but for the smoothness of `δy_v²`\n                 Defaults to `FunctionStencil(v_smoothness)`\n" OnlySelfUpwinding(; cross_scheme = CenteredSecondOrder(), δU_stencil = FunctionStencil(divergence_smoothness), δV_stencil = FunctionStencil(divergence_smoothness), δu²_stencil = FunctionStencil(u_smoothness), δv²_stencil = FunctionStencil(v_smoothness)) = begin
            #= none:55 =#
            OnlySelfUpwinding(extract_centered_scheme(cross_scheme), δU_stencil, δV_stencil, δu²_stencil, δv²_stencil)
        end
#= none:62 =#
#= none:62 =# Core.@doc "    CrossAndSelfUpwinding(; cross_scheme       = CenteredSecondOrder(),\n                            divergence_stencil = DefaultStencil(),\n                            δu²_stencil        = FunctionStencil(u_smoothness),\n                            δv²_stencil        = FunctionStencil(v_smoothness)) \n                            \nUpwinding treatment of Divergence fluxes in the Vector Invariant formulation, whereas both terms corresponding to\nthe transporting velocity (`u` in the zonal direction and terms in `v` in the meridional direction) and the \ntangential velocities (`v` in the zonal direction and terms in `u` in the meridional direction) are upwinded. \nContrarily, only the Kinetic Energy gradient term corresponding to the transporting velocity is upwinded.\n\nKeyword arguments\n=================  \n\n- `cross_scheme`: Advection scheme used for cross-reconstructed terms (tangential velocities) \n                  in the kinetic energy gradient. Defaults to `CenteredSecondOrder()`.\n- `divergence_stencil`: Stencil used for smoothness indicators of `δx_U + δy_V` in case of a \n                        `WENO` upwind reconstruction. Defaults to `DefaultStencil()`.\n- `δu²_stencil`: Stencil used for smoothness indicators of `δx_u²` in case of a `WENO` upwind reconstruction. \n                 Defaults to `FunctionStencil(u_smoothness)` \n- `δv²_stencil`: Same as `δu²_stencil` but for the smoothness of `δy_v²`\n                 Defaults to `FunctionStencil(v_smoothness)`\n" CrossAndSelfUpwinding(; cross_scheme = CenteredSecondOrder(), divergence_stencil = DefaultStencil(), δu²_stencil = FunctionStencil(u_smoothness), δv²_stencil = FunctionStencil(v_smoothness)) = begin
            #= none:85 =#
            CrossAndSelfUpwinding(extract_centered_scheme(cross_scheme), divergence_stencil, δu²_stencil, δv²_stencil)
        end
#= none:91 =#
Base.summary(a::OnlySelfUpwinding) = begin
        #= none:91 =#
        "OnlySelfUpwinding"
    end
#= none:92 =#
Base.summary(a::CrossAndSelfUpwinding) = begin
        #= none:92 =#
        "CrossAndSelfUpwinding"
    end
#= none:94 =#
Base.show(io::IO, a::OnlySelfUpwinding) = begin
        #= none:94 =#
        print(io, summary(a), " \n", " KE gradient and Divergence flux cross terms reconstruction: ", "\n", " └── $(summary(a.cross_scheme))", "\n", " Smoothness measures: ", "\n", " ├── smoothness δU: $(a.δU_stencil)", "\n", " ├── smoothness δV: $(a.δV_stencil)", "\n", " ├── smoothness δu²: $(a.δu²_stencil)", "\n", " └── smoothness δv²: $(a.δv²_stencil)")
    end
#= none:104 =#
Adapt.adapt_structure(to, scheme::OnlySelfUpwinding) = begin
        #= none:104 =#
        OnlySelfUpwinding(Adapt.adapt(to, scheme.cross_scheme), Adapt.adapt(to, scheme.δU_stencil), Adapt.adapt(to, scheme.δV_stencil), Adapt.adapt(to, scheme.δu²_stencil), Adapt.adapt(to, scheme.δv²_stencil))
    end
#= none:111 =#
Base.show(io::IO, a::CrossAndSelfUpwinding) = begin
        #= none:111 =#
        print(io, summary(a), " \n", " KE gradient cross terms reconstruction: ", "\n", " └── $(summary(a.cross_scheme))", "\n", " Smoothness measures: ", "\n", " ├── smoothness δ: $(a.divergence_stencil)", "\n", " ├── smoothness δu²: $(a.δu²_stencil)", "\n", " └── smoothness δv²: $(a.δv²_stencil)")
    end
#= none:120 =#
Adapt.adapt_structure(to, scheme::CrossAndSelfUpwinding) = begin
        #= none:120 =#
        CrossAndSelfUpwinding(Adapt.adapt(to, scheme.cross_scheme), Adapt.adapt(to, scheme.divergence_stencil), Adapt.adapt(to, scheme.δu²_stencil), Adapt.adapt(to, scheme.δv²_stencil))
    end