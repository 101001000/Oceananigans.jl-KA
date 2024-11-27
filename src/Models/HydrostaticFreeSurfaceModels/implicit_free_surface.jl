
#= none:1 =#
using Oceananigans.Grids: AbstractGrid
#= none:2 =#
using Oceananigans.Architectures: device
#= none:3 =#
using Oceananigans.Operators: ∂xᶠᶜᶜ, ∂yᶜᶠᶜ, Δzᶜᶜᶠ, Δzᶜᶜᶜ
#= none:4 =#
using Oceananigans.BoundaryConditions: regularize_field_boundary_conditions
#= none:5 =#
using Oceananigans.Solvers: solve!
#= none:6 =#
using Oceananigans.Utils: prettysummary
#= none:7 =#
using Oceananigans.Fields
#= none:8 =#
using Oceananigans.Utils: prettytime
#= none:10 =#
using Adapt
#= none:12 =#
struct ImplicitFreeSurface{E, G, B, I, M, S} <: AbstractFreeSurface{E, G}
    #= none:13 =#
    η::E
    #= none:14 =#
    gravitational_acceleration::G
    #= none:15 =#
    barotropic_volume_flux::B
    #= none:16 =#
    implicit_step_solver::I
    #= none:17 =#
    solver_method::M
    #= none:18 =#
    solver_settings::S
end
#= none:21 =#
Base.show(io::IO, fs::ImplicitFreeSurface) = begin
        #= none:21 =#
        if isnothing(fs.η)
            print(io, "ImplicitFreeSurface with ", fs.solver_method, "\n", "├─ gravitational_acceleration: ", prettysummary(fs.gravitational_acceleration), "\n", "├─ solver_method: ", fs.solver_method, "\n", "└─ settings: ", if isempty(fs.solver_settings)
                    "Default"
                else
                    fs.solver_settings
                end)
        else
            print(io, "ImplicitFreeSurface with ", fs.solver_method, "\n", "├─ grid: ", summary(fs.η.grid), "\n", "├─ η: ", summary(fs.η), "\n", "├─ gravitational_acceleration: ", prettysummary(fs.gravitational_acceleration), "\n", "├─ implicit_step_solver: ", nameof(typeof(fs.implicit_step_solver)), "\n", "└─ settings: ", fs.solver_settings)
        end
    end
#= none:34 =#
#= none:34 =# Core.@doc "    ImplicitFreeSurface(; solver_method=:Default, gravitational_acceleration=g_Earth, solver_settings...)\n\nReturn an implicit free-surface solver. The implicit free-surface equation is\n\n```math\n\\left [ 𝛁_h ⋅ (H 𝛁_h) - \\frac{1}{g Δt^2} \\right ] η^{n+1} = \\frac{𝛁_h ⋅ 𝐐_⋆}{g Δt} - \\frac{η^{n}}{g Δt^2} ,\n```\n\nwhere ``η^n`` is the free-surface elevation at the ``n``-th time step, ``H`` is depth, ``g`` is\nthe gravitational acceleration, ``Δt`` is the time step, ``𝛁_h`` is the horizontal gradient operator,\nand ``𝐐_⋆`` is the barotropic volume flux associated with the predictor velocity field ``𝐮_⋆``, i.e., \n\n```math\n𝐐_⋆ = \\int_{-H}^0 𝐮_⋆ \\, 𝖽 z ,\n```\n\nwhere \n\n```math\n𝐮_⋆ = 𝐮^n + \\int_{t_n}^{t_{n+1}} 𝐆ᵤ \\, 𝖽t .\n```\n\nThis equation can be solved, in general, using the [`ConjugateGradientSolver`](@ref) but \nother solvers can be invoked in special cases.\n\nIf ``H`` is constant, we divide through out to obtain\n\n```math\n\\left ( ∇^2_h - \\frac{1}{g H Δt^2} \\right ) η^{n+1}  = \\frac{1}{g H Δt} \\left ( 𝛁_h ⋅ 𝐐_⋆ - \\frac{η^{n}}{Δt} \\right ) .\n```\n\nThus, for constant ``H`` and on grids with regular spacing in ``x`` and ``y`` directions, the free\nsurface can be obtained using the [`FFTBasedPoissonSolver`](@ref).\n\n`solver_method` can be either of:\n* `:FastFourierTransform` for [`FFTBasedPoissonSolver`](@ref)\n* `:HeptadiagonalIterativeSolver`  for [`HeptadiagonalIterativeSolver`](@ref)\n* `:PreconditionedConjugateGradient` for [`ConjugateGradientSolver`](@ref)\n\nBy default, if the grid has regular spacing in the horizontal directions then the `:FastFourierTransform` is chosen,\notherwise the `:HeptadiagonalIterativeSolver`.\n" ImplicitFreeSurface(; solver_method = :Default, gravitational_acceleration = g_Earth, solver_settings...) = begin
            #= none:77 =#
            ImplicitFreeSurface(nothing, gravitational_acceleration, nothing, nothing, solver_method, solver_settings)
        end
#= none:80 =#
Adapt.adapt_structure(to, free_surface::ImplicitFreeSurface) = begin
        #= none:80 =#
        ImplicitFreeSurface(Adapt.adapt(to, free_surface.η), free_surface.gravitational_acceleration, nothing, nothing, nothing, nothing)
    end
#= none:84 =#
on_architecture(to, free_surface::ImplicitFreeSurface) = begin
        #= none:84 =#
        ImplicitFreeSurface(on_architecture(to, free_surface.η), on_architecture(to, free_surface.gravitational_acceleration), on_architecture(to, free_surface.barotropic_volume_flux), on_architecture(to, free_surface.implicit_step_solver), on_architecture(to, free_surface.solver_methods), on_architecture(to, free_surface.solver_settings))
    end
#= none:93 =#
function materialize_free_surface(free_surface::ImplicitFreeSurface{Nothing}, velocities, grid)
    #= none:93 =#
    #= none:94 =#
    η = free_surface_displacement_field(velocities, free_surface, grid)
    #= none:95 =#
    gravitational_acceleration = convert(eltype(grid), free_surface.gravitational_acceleration)
    #= none:98 =#
    barotropic_x_volume_flux = Field((Face, Center, Nothing), grid)
    #= none:99 =#
    barotropic_y_volume_flux = Field((Center, Face, Nothing), grid)
    #= none:100 =#
    barotropic_volume_flux = (u = barotropic_x_volume_flux, v = barotropic_y_volume_flux)
    #= none:102 =#
    user_solver_method = free_surface.solver_method
    #= none:103 =#
    solver = build_implicit_step_solver(Val(user_solver_method), grid, free_surface.solver_settings, gravitational_acceleration)
    #= none:104 =#
    solver_method = nameof(typeof(solver))
    #= none:106 =#
    return ImplicitFreeSurface(η, gravitational_acceleration, barotropic_volume_flux, solver, solver_method, free_surface.solver_settings)
end
#= none:114 =#
build_implicit_step_solver(::Val{:Default}, grid::XYRegularRG, settings, gravitational_acceleration) = begin
        #= none:114 =#
        build_implicit_step_solver(Val(:FastFourierTransform), grid, settings, gravitational_acceleration)
    end
#= none:117 =#
build_implicit_step_solver(::Val{:Default}, grid, settings, gravitational_acceleration) = begin
        #= none:117 =#
        build_implicit_step_solver(Val(:HeptadiagonalIterativeSolver), grid, settings, gravitational_acceleration)
    end
#= none:120 =#
#= none:120 =# @inline explicit_barotropic_pressure_x_gradient(i, j, k, grid, ::ImplicitFreeSurface) = begin
            #= none:120 =#
            0
        end
#= none:121 =#
#= none:121 =# @inline explicit_barotropic_pressure_y_gradient(i, j, k, grid, ::ImplicitFreeSurface) = begin
            #= none:121 =#
            0
        end
#= none:123 =#
#= none:123 =# Core.@doc "Implicitly step forward η.\n" ab2_step_free_surface!(free_surface::ImplicitFreeSurface, model, Δt, χ) = begin
            #= none:126 =#
            implicit_free_surface_step!(free_surface::ImplicitFreeSurface, model, Δt, χ)
        end
#= none:129 =#
function implicit_free_surface_step!(free_surface::ImplicitFreeSurface, model, Δt, χ)
    #= none:129 =#
    #= none:130 =#
    η = free_surface.η
    #= none:131 =#
    g = free_surface.gravitational_acceleration
    #= none:132 =#
    rhs = free_surface.implicit_step_solver.right_hand_side
    #= none:133 =#
    ∫ᶻQ = free_surface.barotropic_volume_flux
    #= none:134 =#
    solver = free_surface.implicit_step_solver
    #= none:135 =#
    arch = model.architecture
    #= none:137 =#
    fill_halo_regions!(model.velocities, model.clock, fields(model))
    #= none:140 =#
    #= none:140 =# @apply_regionally local_compute_integrated_volume_flux!(∫ᶻQ, model.velocities, arch)
    #= none:141 =#
    fill_halo_regions!(∫ᶻQ)
    #= none:143 =#
    compute_implicit_free_surface_right_hand_side!(rhs, solver, g, Δt, ∫ᶻQ, η)
    #= none:146 =#
    start_time = time_ns()
    #= none:148 =#
    solve!(η, solver, rhs, g, Δt)
    #= none:150 =#
    #= none:150 =# @debug "Implicit step solve took $(prettytime((time_ns() - start_time) * 1.0e-9))."
    #= none:152 =#
    fill_halo_regions!(η)
    #= none:154 =#
    return nothing
end
#= none:157 =#
function local_compute_integrated_volume_flux!(∫ᶻQ, velocities, arch)
    #= none:157 =#
    #= none:159 =#
    foreach(mask_immersed_field!, velocities)
    #= none:162 =#
    compute_vertically_integrated_volume_flux!(∫ᶻQ, velocities)
    #= none:164 =#
    return nothing
end