
#= none:1 =#
using Oceananigans.Operators: Vᶜᶜᶜ
#= none:2 =#
using Oceananigans.Fields: ZeroField
#= none:4 =#
struct FluxFormAdvection{N, FT, A, B, C} <: AbstractAdvectionScheme{N, FT}
    #= none:5 =#
    x::A
    #= none:6 =#
    y::B
    #= none:7 =#
    z::C
    #= none:9 =#
    (FluxFormAdvection{N, FT}(x::A, y::B, z::C) where {N, FT, A, B, C}) = begin
            #= none:9 =#
            new{N, FT, A, B, C}(x, y, z)
        end
end
#= none:12 =#
#= none:12 =# Core.@doc "    FluxFormAdvection(x_advection, y_advection, z_advection)\n\nReturn a `FluxFormAdvection` type with reconstructions schemes `x_advection`, `y_advection`,\nand `z_advection` to be applied in the ``x``, ``y``, and ``z`` directions, respectively.\n" function FluxFormAdvection(x_advection, y_advection, z_advection)
        #= none:18 =#
        #= none:19 =#
        Hx = required_halo_size_x(x_advection)
        #= none:20 =#
        Hy = required_halo_size_y(y_advection)
        #= none:21 =#
        Hz = required_halo_size_z(z_advection)
        #= none:23 =#
        FT = eltype(x_advection)
        #= none:24 =#
        H = max(Hx, Hy, Hz)
        #= none:26 =#
        return FluxFormAdvection{H, FT}(x_advection, y_advection, z_advection)
    end
#= none:29 =#
Base.show(io::IO, scheme::FluxFormAdvection) = begin
        #= none:29 =#
        print(io, "FluxFormAdvection with reconstructions: ", " \n", "    ├── x: ", summary(scheme.x), "\n", "    ├── y: ", summary(scheme.y), "\n", "    └── z: ", summary(scheme.z))
    end
#= none:35 =#
#= none:35 =# @inline required_halo_size_x(scheme::FluxFormAdvection) = begin
            #= none:35 =#
            required_halo_size_x(scheme.x)
        end
#= none:36 =#
#= none:36 =# @inline required_halo_size_y(scheme::FluxFormAdvection) = begin
            #= none:36 =#
            required_halo_size_y(scheme.y)
        end
#= none:37 =#
#= none:37 =# @inline required_halo_size_z(scheme::FluxFormAdvection) = begin
            #= none:37 =#
            required_halo_size_z(scheme.z)
        end
#= none:39 =#
(Adapt.adapt_structure(to, scheme::FluxFormAdvection{N, FT}) where {N, FT}) = begin
        #= none:39 =#
        FluxFormAdvection{N, FT}(Adapt.adapt(to, scheme.x), Adapt.adapt(to, scheme.y), Adapt.adapt(to, scheme.z))
    end
#= none:44 =#
#= none:44 =# @inline _advective_tracer_flux_x(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:44 =#
            _advective_tracer_flux_x(i, j, k, grid, advection.x, args...)
        end
#= none:45 =#
#= none:45 =# @inline _advective_tracer_flux_y(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:45 =#
            _advective_tracer_flux_y(i, j, k, grid, advection.y, args...)
        end
#= none:46 =#
#= none:46 =# @inline _advective_tracer_flux_z(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:46 =#
            _advective_tracer_flux_z(i, j, k, grid, advection.z, args...)
        end
#= none:48 =#
#= none:48 =# @inline _advective_momentum_flux_Uu(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:48 =#
            _advective_momentum_flux_Uu(i, j, k, grid, advection.x, args...)
        end
#= none:49 =#
#= none:49 =# @inline _advective_momentum_flux_Vu(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:49 =#
            _advective_momentum_flux_Vu(i, j, k, grid, advection.y, args...)
        end
#= none:50 =#
#= none:50 =# @inline _advective_momentum_flux_Wu(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:50 =#
            _advective_momentum_flux_Wu(i, j, k, grid, advection.z, args...)
        end
#= none:52 =#
#= none:52 =# @inline _advective_momentum_flux_Uv(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:52 =#
            _advective_momentum_flux_Uv(i, j, k, grid, advection.x, args...)
        end
#= none:53 =#
#= none:53 =# @inline _advective_momentum_flux_Vv(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:53 =#
            _advective_momentum_flux_Vv(i, j, k, grid, advection.y, args...)
        end
#= none:54 =#
#= none:54 =# @inline _advective_momentum_flux_Wv(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:54 =#
            _advective_momentum_flux_Wv(i, j, k, grid, advection.z, args...)
        end
#= none:56 =#
#= none:56 =# @inline _advective_momentum_flux_Uw(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:56 =#
            _advective_momentum_flux_Uw(i, j, k, grid, advection.x, args...)
        end
#= none:57 =#
#= none:57 =# @inline _advective_momentum_flux_Vw(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:57 =#
            _advective_momentum_flux_Vw(i, j, k, grid, advection.y, args...)
        end
#= none:58 =#
#= none:58 =# @inline _advective_momentum_flux_Ww(i, j, k, grid, advection::FluxFormAdvection, args...) = begin
            #= none:58 =#
            _advective_momentum_flux_Ww(i, j, k, grid, advection.z, args...)
        end