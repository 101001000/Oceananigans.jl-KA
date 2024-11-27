
#= none:1 =#
using Oceananigans.BoundaryConditions: DiscreteBoundaryFunction, BoundaryCondition, Flux
#= none:3 =#
struct TKETopBoundaryConditionParameters{C, U}
    #= none:4 =#
    top_tracer_boundary_conditions::C
    #= none:5 =#
    top_velocity_boundary_conditions::U
end
#= none:8 =#
const TKEBoundaryFunction = DiscreteBoundaryFunction{<:TKETopBoundaryConditionParameters}
#= none:9 =#
const TKEBoundaryCondition = BoundaryCondition{<:Flux, <:TKEBoundaryFunction}
#= none:11 =#
#= none:11 =# @inline Adapt.adapt_structure(to, p::TKETopBoundaryConditionParameters) = begin
            #= none:11 =#
            TKETopBoundaryConditionParameters(adapt(to, p.top_tracer_boundary_conditions), adapt(to, p.top_velocity_boundary_conditions))
        end
#= none:15 =#
#= none:15 =# @inline on_architecture(to, p::TKETopBoundaryConditionParameters) = begin
            #= none:15 =#
            TKETopBoundaryConditionParameters(on_architecture(to, p.top_tracer_boundary_conditions), on_architecture(to, p.top_velocity_boundary_conditions))
        end
#= none:19 =#
#= none:19 =# @inline getbc(bc::TKEBoundaryCondition, i::Integer, j::Integer, grid::AbstractGrid, clock, fields, clo, buoyancy) = begin
            #= none:19 =#
            bc.condition.func(i, j, grid, clock, fields, bc.condition.parameters, clo, buoyancy)
        end
#= none:22 =#
#= none:22 =# @inline getbc(bc::TKEBoundaryCondition, i::Integer, j::Integer, k::Integer, grid::AbstractGrid, clock, fields, clo, buoyancy) = begin
            #= none:22 =#
            bc.condition.func(i, j, k, grid, clock, fields, bc.condition.parameters, clo, buoyancy)
        end
#= none:25 =#
#= none:25 =# Core.@doc "    top_tke_flux(i, j, grid, clock, fields, parameters, closure, buoyancy)\n\nCompute the flux of TKE through the surface / top boundary.\nDesigned to be used with TKETopBoundaryConditionParameters in a FluxBoundaryCondition, eg:\n\n```\ntop_tracer_bcs = top_tracer_boundary_conditions(grid, tracer_names, user_bcs)\ntop_velocity_bcs = top_velocity_boundary_conditions(grid, user_bcs)\nparameters = TKETopBoundaryConditionParameters(top_tracer_bcs, top_velocity_bcs)\ntop_tke_bc = FluxBoundaryCondition(top_tke_flux, discrete_form=true, parameters=parameters)\n```\n\nSee the implementation in catke_equation.jl.\n" #= none:40 =# @inline(top_tke_flux(i, j, grid, clock, fields, parameters, closure, buoyancy) = begin
                #= none:40 =#
                zero(grid)
            end)
#= none:46 =#
#= none:46 =# Core.@doc " Infer tracer boundary conditions from user_bcs and tracer_names. " function top_tracer_boundary_conditions(grid, tracer_names, user_bcs)
        #= none:47 =#
        #= none:48 =#
        default_tracer_bcs = NamedTuple((c => FieldBoundaryConditions(grid, (Center, Center, Center)) for c = tracer_names))
        #= none:49 =#
        bcs = merge(default_tracer_bcs, user_bcs)
        #= none:50 =#
        return NamedTuple((c => (bcs[c]).top for c = tracer_names))
    end
#= none:53 =#
#= none:53 =# Core.@doc " Infer velocity boundary conditions from `user_bcs` and `tracer_names`. " function top_velocity_boundary_conditions(grid, user_bcs)
        #= none:54 =#
        #= none:55 =#
        default_top_bc = default_prognostic_bc((topology(grid, 3))(), Center(), DefaultBoundaryCondition())
        #= none:57 =#
        user_bc_names = keys(user_bcs)
        #= none:58 =#
        u_top_bc = if :u ∈ user_bc_names
                user_bcs.u.top
            else
                default_top_bc
            end
        #= none:59 =#
        v_top_bc = if :v ∈ user_bc_names
                user_bcs.v.top
            else
                default_top_bc
            end
        #= none:61 =#
        return (u = u_top_bc, v = v_top_bc)
    end
#= none:64 =#
#= none:64 =# Core.@doc " Computes the friction velocity u★ based on fluxes of u and v. " #= none:65 =# @inline(function friction_velocity(i, j, grid, clock, fields, velocity_bcs)
            #= none:65 =#
            #= none:66 =#
            FT = eltype(grid)
            #= none:67 =#
            τx = getbc(velocity_bcs.u, i, j, grid, clock, fields)
            #= none:68 =#
            τy = getbc(velocity_bcs.v, i, j, grid, clock, fields)
            #= none:69 =#
            return sqrt(sqrt(τx ^ 2 + τy ^ 2))
        end)
#= none:72 =#
#= none:72 =# Core.@doc " Computes the convective velocity w★. " #= none:73 =# @inline(function top_convective_turbulent_velocity_cubed(i, j, grid, clock, fields, buoyancy, tracer_bcs)
            #= none:73 =#
            #= none:74 =#
            Jᵇ = top_buoyancy_flux(i, j, grid, buoyancy, tracer_bcs, clock, fields)
            #= none:75 =#
            Δz = Δzᶜᶜᶜ(i, j, grid.Nz, grid)
            #= none:76 =#
            return clip(Jᵇ) * Δz
        end)
#= none:79 =#
#= none:79 =# @inline top_tke_flux(i, j, grid, clock, fields, parameters, closure_tuple::Tuple{<:Any}, buoyancy) = begin
            #= none:79 =#
            top_tke_flux(i, j, grid, clock, fields, parameters, closure_tuple[1], buoyancy)
        end
#= none:82 =#
#= none:82 =# @inline top_tke_flux(i, j, grid, clock, fields, parameters, closure_tuple::Tuple{<:Any, <:Any}, buoyancy) = begin
            #= none:82 =#
            top_tke_flux(i, j, grid, clock, fields, parameters, closure_tuple[1], buoyancy) + top_tke_flux(i, j, grid, clock, fields, parameters, closure_tuple[2], buoyancy)
        end
#= none:86 =#
#= none:86 =# @inline top_tke_flux(i, j, grid, clock, fields, parameters, closure_tuple::Tuple{<:Any, <:Any, <:Any}, buoyancy) = begin
            #= none:86 =#
            top_tke_flux(i, j, grid, clock, fields, parameters, closure_tuple[1], buoyancy) + top_tke_flux(i, j, grid, clock, fields, parameters, closure_tuple[2], buoyancy) + top_tke_flux(i, j, grid, clock, fields, parameters, closure_tuple[3], buoyancy)
        end