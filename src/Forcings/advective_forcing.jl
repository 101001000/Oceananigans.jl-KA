
#= none:1 =#
using Oceananigans.Advection: UpwindBiasedFifthOrder, div_Uc, div_𝐯u, div_𝐯v, div_𝐯w
#= none:2 =#
using Oceananigans.Fields: ZeroField, ConstantField
#= none:3 =#
using Oceananigans.Utils: SumOfArrays
#= none:4 =#
using Adapt
#= none:6 =#
maybe_constant_field(u) = begin
        #= none:6 =#
        u
    end
#= none:7 =#
maybe_constant_field(u::Number) = begin
        #= none:7 =#
        ConstantField(u)
    end
#= none:9 =#
struct AdvectiveForcing{U, V, W}
    #= none:10 =#
    u::U
    #= none:11 =#
    v::V
    #= none:12 =#
    w::W
end
#= none:15 =#
#= none:15 =# Core.@doc "    AdvectiveForcing(u=ZeroField(), v=ZeroField(), w=ZeroField())\n\nBuild a forcing term representing advection by the velocity field `u, v, w` with an advection `scheme`.\n\nExample\n=======\n\n# Using a tracer field to model sinking particles\n\n```jldoctest\nusing Oceananigans\n\n# Physical parameters\ngravitational_acceleration          = 9.81     # m s⁻²\nocean_density                       = 1026     # kg m⁻³\nmean_particle_density               = 2000     # kg m⁻³\nmean_particle_radius                = 1e-3     # m\nocean_molecular_kinematic_viscosity = 1.05e-6  # m² s⁻¹\n\n# Terminal velocity of a sphere in viscous flow\nΔb = gravitational_acceleration * (mean_particle_density - ocean_density) / ocean_density\nν = ocean_molecular_kinematic_viscosity\nR = mean_particle_radius\n\nw_Stokes = - 2/9 * Δb / ν * R^2 # m s⁻¹\n\nsettling = AdvectiveForcing(w=w_Stokes)\n\n# output\nAdvectiveForcing:\n├── u: ZeroField{Int64}\n├── v: ZeroField{Int64}\n└── w: ConstantField(-1.97096)\n```\n" function AdvectiveForcing(; u = ZeroField(), v = ZeroField(), w = ZeroField())
        #= none:51 =#
        #= none:52 =#
        (u, v, w) = maybe_constant_field.((u, v, w))
        #= none:53 =#
        return AdvectiveForcing(u, v, w)
    end
#= none:56 =#
#= none:56 =# @inline (af::AdvectiveForcing)(i, j, k, grid, clock, model_fields) = begin
            #= none:56 =#
            0
        end
#= none:58 =#
Base.summary(::AdvectiveForcing) = begin
        #= none:58 =#
        string("AdvectiveForcing")
    end
#= none:60 =#
function Base.show(io::IO, af::AdvectiveForcing)
    #= none:60 =#
    #= none:62 =#
    print(io, summary(af), ":", "\n")
    #= none:64 =#
    print(io, "├── u: ", prettysummary(af.u), "\n", "├── v: ", prettysummary(af.v), "\n", "└── w: ", prettysummary(af.w))
end
#= none:69 =#
Adapt.adapt_structure(to, af::AdvectiveForcing) = begin
        #= none:69 =#
        AdvectiveForcing(adapt(to, af.u), adapt(to, af.v), adapt(to, af.w))
    end
#= none:72 =#
on_architecture(to, af::AdvectiveForcing) = begin
        #= none:72 =#
        AdvectiveForcing(on_architecture(to, af.u), on_architecture(to, af.v), on_architecture(to, af.w))
    end
#= none:77 =#
#= none:77 =# @inline with_advective_forcing(forcing, total_velocities) = begin
            #= none:77 =#
            total_velocities
        end
#= none:79 =#
#= none:79 =# @inline with_advective_forcing(forcing::AdvectiveForcing, total_velocities) = begin
            #= none:79 =#
            (u = SumOfArrays{2}(forcing.u, total_velocities.u), v = SumOfArrays{2}(forcing.v, total_velocities.v), w = SumOfArrays{2}(forcing.w, total_velocities.w))
        end
#= none:85 =#
#= none:85 =# @inline with_advective_forcing(mf::MultipleForcings, total_velocities) = begin
            #= none:85 =#
            with_advective_forcing(mf.forcings, total_velocities)
        end
#= none:89 =#
#= none:89 =# @inline with_advective_forcing(forcing::Tuple, total_velocities) = begin
            #= none:89 =#
            #= none:90 =# @inbounds with_advective_forcing(forcing[2:end], with_advective_forcing(forcing[1], total_velocities))
        end
#= none:93 =#
#= none:93 =# @inline with_advective_forcing(forcing::NTuple{1}, total_velocities) = begin
            #= none:93 =#
            #= none:94 =# @inbounds with_advective_forcing(forcing[1], total_velocities)
        end