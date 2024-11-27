
#= none:1 =#
using Oceananigans.Grids: NegativeZDirection, validate_unit_vector
#= none:3 =#
struct Buoyancy{M, G}
    #= none:4 =#
    model::M
    #= none:5 =#
    gravity_unit_vector::G
end
#= none:8 =#
#= none:8 =# Core.@doc "    Buoyancy(; model, gravity_unit_vector=NegativeZDirection())\n\nConstruct a `buoyancy` given a buoyancy `model`. Optional keyword argument `gravity_unit_vector`\ncan be used to specify the direction of gravity (default `NegativeZDirection()`).\nThe buoyancy acceleration acts in the direction opposite to gravity.\n\nExample\n=======\n\n```jldoctest\nusing Oceananigans\n\ngrid = RectilinearGrid(size=(1, 8, 8), extent=(1, 1, 1))\n\nθ = 45 # degrees\ng̃ = (0, -sind(θ), -cosd(θ))\n\nbuoyancy = Buoyancy(model=BuoyancyTracer(), gravity_unit_vector=g̃)\n\nmodel = NonhydrostaticModel(; grid, buoyancy, tracers=:b)\n\n# output\n\nNonhydrostaticModel{CPU, RectilinearGrid}(time = 0 seconds, iteration = 0)\n├── grid: 1×8×8 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 1×3×3 halo\n├── timestepper: RungeKutta3TimeStepper\n├── advection scheme: Centered reconstruction order 2\n├── tracers: b\n├── closure: Nothing\n├── buoyancy: BuoyancyTracer with ĝ = (0.0, -0.707107, -0.707107)\n└── coriolis: Nothing\n```\n" function Buoyancy(; model, gravity_unit_vector = NegativeZDirection())
        #= none:42 =#
        #= none:43 =#
        gravity_unit_vector = validate_unit_vector(gravity_unit_vector)
        #= none:44 =#
        return Buoyancy(model, gravity_unit_vector)
    end
#= none:48 =#
#= none:48 =# @inline ĝ_x(buoyancy) = begin
            #= none:48 =#
            #= none:48 =# @inbounds -(buoyancy.gravity_unit_vector[1])
        end
#= none:49 =#
#= none:49 =# @inline ĝ_y(buoyancy) = begin
            #= none:49 =#
            #= none:49 =# @inbounds -(buoyancy.gravity_unit_vector[2])
        end
#= none:50 =#
#= none:50 =# @inline ĝ_z(buoyancy) = begin
            #= none:50 =#
            #= none:50 =# @inbounds -(buoyancy.gravity_unit_vector[3])
        end
#= none:52 =#
#= none:52 =# @inline (ĝ_x(::Buoyancy{M, NegativeZDirection}) where M) = begin
            #= none:52 =#
            0
        end
#= none:53 =#
#= none:53 =# @inline (ĝ_y(::Buoyancy{M, NegativeZDirection}) where M) = begin
            #= none:53 =#
            0
        end
#= none:54 =#
#= none:54 =# @inline (ĝ_z(::Buoyancy{M, NegativeZDirection}) where M) = begin
            #= none:54 =#
            1
        end
#= none:60 =#
#= none:60 =# @inline required_tracers(bm::Buoyancy) = begin
            #= none:60 =#
            required_tracers(bm.model)
        end
#= none:62 =#
#= none:62 =# @inline get_temperature_and_salinity(bm::Buoyancy, C) = begin
            #= none:62 =#
            get_temperature_and_salinity(bm.model, C)
        end
#= none:64 =#
#= none:64 =# @inline ∂x_b(i, j, k, grid, b::Buoyancy, C) = begin
            #= none:64 =#
            ∂x_b(i, j, k, grid, b.model, C)
        end
#= none:65 =#
#= none:65 =# @inline ∂y_b(i, j, k, grid, b::Buoyancy, C) = begin
            #= none:65 =#
            ∂y_b(i, j, k, grid, b.model, C)
        end
#= none:66 =#
#= none:66 =# @inline ∂z_b(i, j, k, grid, b::Buoyancy, C) = begin
            #= none:66 =#
            ∂z_b(i, j, k, grid, b.model, C)
        end
#= none:68 =#
#= none:68 =# @inline top_buoyancy_flux(i, j, grid, b::Buoyancy, args...) = begin
            #= none:68 =#
            top_buoyancy_flux(i, j, grid, b.model, args...)
        end
#= none:70 =#
regularize_buoyancy(b) = begin
        #= none:70 =#
        b
    end
#= none:71 =#
regularize_buoyancy(b::AbstractBuoyancyModel) = begin
        #= none:71 =#
        Buoyancy(model = b)
    end
#= none:73 =#
Base.summary(buoyancy::Buoyancy) = begin
        #= none:73 =#
        string(summary(buoyancy.model), " with ĝ = ", summarize_vector(buoyancy.gravity_unit_vector))
    end
#= none:77 =#
summarize_vector(n) = begin
        #= none:77 =#
        string("(", prettysummary(n[1]), ", ", prettysummary(n[2]), ", ", prettysummary(n[3]), ")")
    end
#= none:81 =#
summarize_vector(::NegativeZDirection) = begin
        #= none:81 =#
        "NegativeZDirection()"
    end
#= none:83 =#
function Base.show(io::IO, buoyancy::Buoyancy)
    #= none:83 =#
    #= none:84 =#
    print(io, "Buoyancy:", '\n', "├── model: ", prettysummary(buoyancy.model), '\n', "└── gravity_unit_vector: ", summarize_vector(buoyancy.gravity_unit_vector))
end