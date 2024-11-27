
#= none:1 =#
using Oceananigans.Architectures: on_architecture
#= none:2 =#
using Oceananigans.Grids: XDirection, YDirection, ZDirection
#= none:4 =#
import Oceananigans.Architectures: architecture
#= none:6 =#
#= none:6 =# Core.@doc "    struct BatchedTridiagonalSolver{A, B, C, T, G, P}\n\nA batched solver for large numbers of triadiagonal systems.\n" struct BatchedTridiagonalSolver{A, B, C, T, G, P, D}
        #= none:12 =#
        a::A
        #= none:13 =#
        b::B
        #= none:14 =#
        c::C
        #= none:15 =#
        t::T
        #= none:16 =#
        grid::G
        #= none:17 =#
        parameters::P
        #= none:18 =#
        tridiagonal_direction::D
    end
#= none:22 =#
const XTridiagonalSolver = (BatchedTridiagonalSolver{A, B, C, T, G, P, <:XDirection} where {A, B, C, T, G, P})
#= none:23 =#
const YTridiagonalSolver = (BatchedTridiagonalSolver{A, B, C, T, G, P, <:YDirection} where {A, B, C, T, G, P})
#= none:24 =#
const ZTridiagonalSolver = (BatchedTridiagonalSolver{A, B, C, T, G, P, <:ZDirection} where {A, B, C, T, G, P})
#= none:26 =#
architecture(solver::BatchedTridiagonalSolver) = begin
        #= none:26 =#
        architecture(solver.grid)
    end
#= none:28 =#
#= none:28 =# Core.@doc "    BatchedTridiagonalSolver(grid;\n                             lower_diagonal,\n                             diagonal,\n                             upper_diagonal,\n                             scratch = on_architecture(architecture(grid), zeros(eltype(grid), size(grid)...)),\n                             tridiagonal_direction = ZDirection()\n                             parameters = nothing)\n\nConstruct a solver for batched tridiagonal systems on `grid` of the form\n\n```\n                    bⁱʲ¹ ϕⁱʲ¹ + cⁱʲ¹ ϕⁱʲ²   = fⁱʲ¹,\n    aⁱʲᵏ⁻¹ ϕⁱʲᵏ⁻¹ + bⁱʲᵏ ϕⁱʲᵏ + cⁱʲᵏ ϕⁱʲᵏ⁺¹ = fⁱʲᵏ,  k = 2, ..., N-1\n    aⁱʲᴺ⁻¹ ϕⁱʲᴺ⁻¹ + bⁱʲᴺ ϕⁱʲᴺ               = fⁱʲᴺ,\n```\nor in matrix form\n```\n    ⎡ bⁱʲ¹   cⁱʲ¹     0       ⋯         0   ⎤ ⎡ ϕⁱʲ¹ ⎤   ⎡ fⁱʲ¹ ⎤\n    ⎢ aⁱʲ¹   bⁱʲ²   cⁱʲ²      0    ⋯    ⋮   ⎥ ⎢ ϕⁱʲ² ⎥   ⎢ fⁱʲ² ⎥\n    ⎢  0      ⋱      ⋱       ⋱              ⎥ ⎢   .  ⎥   ⎢   .  ⎥\n    ⎢  ⋮                                0   ⎥ ⎢ ϕⁱʲᵏ ⎥   ⎢ fⁱʲᵏ ⎥\n    ⎢  ⋮           aⁱʲᴺ⁻²   bⁱʲᴺ⁻¹   cⁱʲᴺ⁻¹ ⎥ ⎢      ⎥   ⎢   .  ⎥\n    ⎣  0      ⋯      0      aⁱʲᴺ⁻¹    bⁱʲᴺ  ⎦ ⎣ ϕⁱʲᴺ ⎦   ⎣ fⁱʲᴺ ⎦\n```\n\nwhere `a` is the `lower_diagonal`, `b` is the `diagonal`, and `c` is the `upper_diagonal`.\n\nNote the convention used here for indexing the upper and lower diagonals; this can be different from \nother implementations where, e.g., `aⁱʲ²` may appear at the second row, instead of `aⁱʲ¹` as above.\n\n`ϕ` is the solution and `f` is the right hand side source term passed to `solve!(ϕ, tridiagonal_solver, f)`.\n\n`a`, `b`, `c`, and `f` can be specified in three ways:\n\n1. A 1D array means, e.g., that `aⁱʲᵏ = a[k]`.\n\n2. A 3D array means, e.g., that `aⁱʲᵏ = a[i, j, k]`.\n\nOther coefficient types can be implemented by extending `get_coefficient`.\n" function BatchedTridiagonalSolver(grid; lower_diagonal, diagonal, upper_diagonal, scratch = on_architecture(architecture(grid), zeros(eltype(grid), grid.Nx, grid.Ny, grid.Nz)), parameters = nothing, tridiagonal_direction = ZDirection())
        #= none:69 =#
        #= none:77 =#
        return BatchedTridiagonalSolver(lower_diagonal, diagonal, upper_diagonal, scratch, grid, parameters, tridiagonal_direction)
    end
#= none:81 =#
#= none:81 =# Core.@doc "    solve!(ϕ, solver::BatchedTridiagonalSolver, rhs, args...)\n\nSolve the batched tridiagonal system of linear equations with right hand side\n`rhs` and lower diagonal, diagonal, and upper diagonal coefficients described by the\n`BatchedTridiagonalSolver` `solver`. `BatchedTridiagonalSolver` uses a modified\nTriDiagonal Matrix Algorithm (TDMA).\n\nThe result is stored in `ϕ` which must have size `(grid.Nx, grid.Ny, grid.Nz)`.\n\nImplementation follows [Press1992](@citet); §2.4. Note that a slightly different notation from\nPress et al. is used for indexing the off-diagonal elements; see [`BatchedTridiagonalSolver`](@ref).\n\nReference\n=========\n\nPress William, H., Teukolsky Saul, A., Vetterling William, T., & Flannery Brian, P. (1992).\n    Numerical recipes: the art of scientific computing. Cambridge University Press\n" function solve!(ϕ, solver::BatchedTridiagonalSolver, rhs, args...)
        #= none:100 =#
        #= none:102 =#
        launch_config = if solver.tridiagonal_direction isa XDirection
                #= none:103 =#
                :yz
            elseif #= none:104 =# solver.tridiagonal_direction isa YDirection
                #= none:105 =#
                :xz
            elseif #= none:106 =# solver.tridiagonal_direction isa ZDirection
                #= none:107 =#
                :xy
            end
        #= none:110 =#
        launch!(architecture(solver), solver.grid, launch_config, solve_batched_tridiagonal_system_kernel!, ϕ, solver.a, solver.b, solver.c, rhs, solver.t, solver.grid, solver.parameters, Tuple(args), solver.tridiagonal_direction)
        #= none:122 =#
        return nothing
    end
#= none:125 =#
#= none:125 =# @inline get_coefficient(i, j, k, grid, a::AbstractArray{<:Any, 1}, p, ::XDirection, args...) = begin
            #= none:125 =#
            #= none:125 =# @inbounds a[i]
        end
#= none:126 =#
#= none:126 =# @inline get_coefficient(i, j, k, grid, a::AbstractArray{<:Any, 1}, p, ::YDirection, args...) = begin
            #= none:126 =#
            #= none:126 =# @inbounds a[j]
        end
#= none:127 =#
#= none:127 =# @inline get_coefficient(i, j, k, grid, a::AbstractArray{<:Any, 1}, p, ::ZDirection, args...) = begin
            #= none:127 =#
            #= none:127 =# @inbounds a[k]
        end
#= none:128 =#
#= none:128 =# @inline get_coefficient(i, j, k, grid, a::AbstractArray{<:Any, 3}, p, tridiagonal_direction, args...) = begin
            #= none:128 =#
            #= none:128 =# @inbounds a[i, j, k]
        end
#= none:130 =#
#= none:130 =# @inline (float_eltype(ϕ::AbstractArray{T}) where T <: AbstractFloat) = begin
            #= none:130 =#
            T
        end
#= none:131 =#
#= none:131 =# @inline (float_eltype(ϕ::AbstractArray{<:Complex{T}}) where T <: AbstractFloat) = begin
            #= none:131 =#
            T
        end
#= none:133 =#
#= none:133 =# @kernel function solve_batched_tridiagonal_system_kernel!(ϕ, a, b, c, f, t, grid, p, args, tridiagonal_direction::XDirection)
        #= none:133 =#
        #= none:134 =#
        Nx = size(grid, 1)
        #= none:135 =#
        (j, k) = #= none:135 =# @index(Global, NTuple)
        #= none:136 =#
        solve_batched_tridiagonal_system_x!(j, k, Nx, ϕ, a, b, c, f, t, grid, p, args, tridiagonal_direction)
    end
#= none:139 =#
#= none:139 =# @inline function solve_batched_tridiagonal_system_x!(j, k, Nx, ϕ, a, b, c, f, t, grid, p, args, tridiagonal_direction)
        #= none:139 =#
        #= none:140 =#
        #= none:140 =# @inbounds begin
                #= none:141 =#
                β = get_coefficient(1, j, k, grid, b, p, tridiagonal_direction, args...)
                #= none:142 =#
                f₁ = get_coefficient(1, j, k, grid, f, p, tridiagonal_direction, args...)
                #= none:143 =#
                ϕ[1, j, k] = f₁ / β
                #= none:145 =#
                for i = 2:Nx
                    #= none:146 =#
                    cᵏ⁻¹ = get_coefficient(i - 1, j, k, grid, c, p, tridiagonal_direction, args...)
                    #= none:147 =#
                    bᵏ = get_coefficient(i, j, k, grid, b, p, tridiagonal_direction, args...)
                    #= none:148 =#
                    aᵏ⁻¹ = get_coefficient(i - 1, j, k, grid, a, p, tridiagonal_direction, args...)
                    #= none:150 =#
                    t[i, j, k] = cᵏ⁻¹ / β
                    #= none:151 =#
                    β = bᵏ - aᵏ⁻¹ * t[i, j, k]
                    #= none:153 =#
                    fᵏ = get_coefficient(i, j, k, grid, f, p, tridiagonal_direction, args...)
                    #= none:157 =#
                    definitely_diagonally_dominant = abs(β) > 10 * eps(float_eltype(ϕ))
                    #= none:158 =#
                    !definitely_diagonally_dominant && break
                    #= none:159 =#
                    ϕ[i, j, k] = (fᵏ - aᵏ⁻¹ * ϕ[i - 1, j, k]) / β
                    #= none:160 =#
                end
                #= none:162 =#
                for i = Nx - 1:-1:1
                    #= none:163 =#
                    ϕ[i, j, k] -= t[i + 1, j, k] * ϕ[i + 1, j, k]
                    #= none:164 =#
                end
            end
    end
#= none:168 =#
#= none:168 =# @kernel function solve_batched_tridiagonal_system_kernel!(ϕ, a, b, c, f, t, grid, p, args, tridiagonal_direction::YDirection)
        #= none:168 =#
        #= none:169 =#
        Ny = size(grid, 2)
        #= none:170 =#
        (i, k) = #= none:170 =# @index(Global, NTuple)
        #= none:171 =#
        solve_batched_tridiagonal_system_y!(i, k, Ny, ϕ, a, b, c, f, t, grid, p, args, tridiagonal_direction)
    end
#= none:174 =#
#= none:174 =# @inline function solve_batched_tridiagonal_system_y!(i, k, Ny, ϕ, a, b, c, f, t, grid, p, args, tridiagonal_direction)
        #= none:174 =#
        #= none:175 =#
        #= none:175 =# @inbounds begin
                #= none:176 =#
                β = get_coefficient(i, 1, k, grid, b, p, tridiagonal_direction, args...)
                #= none:177 =#
                f₁ = get_coefficient(i, 1, k, grid, f, p, tridiagonal_direction, args...)
                #= none:178 =#
                ϕ[i, 1, k] = f₁ / β
                #= none:180 =#
                for j = 2:Ny
                    #= none:181 =#
                    cᵏ⁻¹ = get_coefficient(i, j - 1, k, grid, c, p, tridiagonal_direction, args...)
                    #= none:182 =#
                    bᵏ = get_coefficient(i, j, k, grid, b, p, tridiagonal_direction, args...)
                    #= none:183 =#
                    aᵏ⁻¹ = get_coefficient(i, j - 1, k, grid, a, p, tridiagonal_direction, args...)
                    #= none:185 =#
                    t[i, j, k] = cᵏ⁻¹ / β
                    #= none:186 =#
                    β = bᵏ - aᵏ⁻¹ * t[i, j, k]
                    #= none:188 =#
                    fᵏ = get_coefficient(i, j, k, grid, f, p, tridiagonal_direction, args...)
                    #= none:192 =#
                    definitely_diagonally_dominant = abs(β) > 10 * eps(float_eltype(ϕ))
                    #= none:193 =#
                    !definitely_diagonally_dominant && break
                    #= none:194 =#
                    ϕ[i, j, k] = (fᵏ - aᵏ⁻¹ * ϕ[i, j - 1, k]) / β
                    #= none:195 =#
                end
                #= none:197 =#
                for j = Ny - 1:-1:1
                    #= none:198 =#
                    ϕ[i, j, k] -= t[i, j + 1, k] * ϕ[i, j + 1, k]
                    #= none:199 =#
                end
            end
    end
#= none:203 =#
#= none:203 =# @kernel function solve_batched_tridiagonal_system_kernel!(ϕ, a, b, c, f, t, grid, p, args, tridiagonal_direction::ZDirection)
        #= none:203 =#
        #= none:204 =#
        Nz = size(grid, 3)
        #= none:205 =#
        (i, j) = #= none:205 =# @index(Global, NTuple)
        #= none:206 =#
        solve_batched_tridiagonal_system_z!(i, j, Nz, ϕ, a, b, c, f, t, grid, p, args, tridiagonal_direction)
    end
#= none:209 =#
#= none:209 =# @inline function solve_batched_tridiagonal_system_z!(i, j, Nz, ϕ, a, b, c, f, t, grid, p, args, tridiagonal_direction)
        #= none:209 =#
        #= none:210 =#
        #= none:210 =# @inbounds begin
                #= none:211 =#
                β = get_coefficient(i, j, 1, grid, b, p, tridiagonal_direction, args...)
                #= none:212 =#
                f₁ = get_coefficient(i, j, 1, grid, f, p, tridiagonal_direction, args...)
                #= none:213 =#
                ϕ[i, j, 1] = f₁ / β
                #= none:215 =#
                for k = 2:Nz
                    #= none:216 =#
                    cᵏ⁻¹ = get_coefficient(i, j, k - 1, grid, c, p, tridiagonal_direction, args...)
                    #= none:217 =#
                    bᵏ = get_coefficient(i, j, k, grid, b, p, tridiagonal_direction, args...)
                    #= none:218 =#
                    aᵏ⁻¹ = get_coefficient(i, j, k - 1, grid, a, p, tridiagonal_direction, args...)
                    #= none:220 =#
                    t[i, j, k] = cᵏ⁻¹ / β
                    #= none:221 =#
                    β = bᵏ - aᵏ⁻¹ * t[i, j, k]
                    #= none:222 =#
                    fᵏ = get_coefficient(i, j, k, grid, f, p, tridiagonal_direction, args...)
                    #= none:226 =#
                    definitely_diagonally_dominant = abs(β) > 10 * eps(float_eltype(ϕ))
                    #= none:227 =#
                    !definitely_diagonally_dominant && break
                    #= none:228 =#
                    ϕ[i, j, k] = (fᵏ - aᵏ⁻¹ * ϕ[i, j, k - 1]) / β
                    #= none:229 =#
                end
                #= none:231 =#
                for k = Nz - 1:-1:1
                    #= none:232 =#
                    ϕ[i, j, k] -= t[i, j, k + 1] * ϕ[i, j, k + 1]
                    #= none:233 =#
                end
            end
    end