
#= none:1 =#
using Oceananigans.Architectures
#= none:2 =#
using Oceananigans.Architectures: architecture, on_architecture, unsafe_free!
#= none:3 =#
using Oceananigans.Grids: interior_parent_indices, topology
#= none:4 =#
using Oceananigans.Utils: heuristic_workgroup
#= none:5 =#
using KernelAbstractions: @kernel, @index
#= none:6 =#
using IterativeSolvers, SparseArrays, LinearAlgebra
#= none:7 =#
begin
    using CUDA, CUDA.CUSPARSE, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:8 =#
using IterativeSolvers: CGStateVariables
#= none:10 =#
import Oceananigans.Grids: architecture
#= none:12 =#
mutable struct HeptadiagonalIterativeSolver{G, R, L, D, M, P, PM, PS, I, ST, T, F}
    #= none:13 =#
    grid::G
    #= none:14 =#
    problem_size::R
    #= none:15 =#
    matrix_constructors::L
    #= none:16 =#
    diagonal::D
    #= none:17 =#
    matrix::M
    #= none:18 =#
    preconditioner::P
    #= none:19 =#
    preconditioner_method::PM
    #= none:20 =#
    preconditioner_settings::PS
    #= none:21 =#
    iterative_solver::I
    #= none:22 =#
    state_vars::ST
    #= none:23 =#
    tolerance::T
    #= none:24 =#
    last_Δt::F
    #= none:25 =#
    maximum_iterations::Int
    #= none:26 =#
    verbose::Bool
end
#= none:29 =#
#= none:29 =# Core.@doc "    HeptadiagonalIterativeSolver(coeffs;\n                                 grid,\n                                 iterative_solver = cg!,\n                                 maximum_iterations = prod(size(grid)),\n                                 tolerance = 1e-13,\n                                 reduced_dim = (false, false, false), \n                                 placeholder_timestep = -1.0, \n                                 preconditioner_method = :Default, \n                                 preconditioner_settings = nothing,\n                                 template = on_architecture(architecture(grid), zeros(prod(size(grid)))),\n                                 verbose = false)\n\nReturn a `HeptadiagonalIterativeSolver` to solve the problem `A * x = b`, provided\nthat `A` is a symmetric matrix.\n\nThe solver relies on a sparse version of the matrix `A` that is stored in `matrix_constructors`.\n\nIn particular, given coefficients `Ax`, `Ay`, `Az`, `C`, `D`, the solved problem is\n\n```julia\n    Axᵢ₊₁ ηᵢ₊₁ + Axᵢ ηᵢ₋₁ + Ayⱼ₊₁ ηⱼ₊₁ + Ayⱼ ηⱼ₋₁ + Azₖ₊₁ ηₖ₊₁ + Azₖ ηₖ₋₁ \n    - 2 ( Axᵢ₊₁ + Axᵢ + Ayⱼ₊₁ + Ayⱼ + Azₖ₊₁ + Azₖ ) ηᵢⱼₖ \n    +   ( Cᵢⱼₖ + Dᵢⱼₖ/Δt^2 ) ηᵢⱼₖ  = b\n```\n\nTo have the equation solved at location `{Center, Center, Center}`, the coefficients must be\nspecified at:\n- `Ax` -> `{Face,   Center, Center}`\n- `Ay` -> `{Center, Face,   Center}`\n- `Az` -> `{Center, Center, Face}`\n- `C`  -> `{Center, Center, Center}`\n- `D`  -> `{Center, Center, Center}`\n\n`solver.matrix` is precomputed with a placeholder timestep value of `placeholder_timestep = -1.0`.\n\nThe sparse matrix `A` can be constructed with:\n- `SparseMatrixCSC(constructors...)` for CPU\n- `CuSparseMatrixCSC(constructors...)` for GPU\n\nThe matrix constructors are calculated based on the pentadiagonal coeffients passed as an input\nto `matrix_from_coefficients` function.\n\nTo allow for variable time step, the diagonal term `- Az / (g * Δt²)` is only added later on\nand it is updated only when the previous time step changes (`last_Δt != Δt`).\n\nPreconditioning is done through the various methods implemented in `Solvers/sparse_preconditioners.jl`.\n    \nThe `iterative_solver` used can is to be chosen from the IterativeSolvers.jl package. \nThe default solver is a Conjugate Gradient (`cg`):\n\n```julia\nsolver = HeptadiagonalIterativeSolver((Ax, Ay, Az, C, D); grid)\n```\n" function HeptadiagonalIterativeSolver(coeffs; grid, iterative_solver = cg!, maximum_iterations = prod(size(grid)), tolerance = 1.0e-13, reduced_dim = (false, false, false), placeholder_timestep = -1.0, preconditioner_method = :Default, preconditioner_settings = nothing, template = on_architecture(architecture(grid), zeros(prod(size(grid)))), verbose = false)
        #= none:84 =#
        #= none:96 =#
        arch = architecture(grid)
        #= none:98 =#
        (matrix_constructors, diagonal, problem_size) = matrix_from_coefficients(arch, grid, coeffs, reduced_dim)
        #= none:103 =#
        placeholder_constructors = deepcopy(matrix_constructors)
        #= none:104 =#
        M = prod(problem_size)
        #= none:105 =#
        update_diag!(placeholder_constructors, arch, M, M, diagonal, 1.0, 0)
        #= none:107 =#
        placeholder_matrix = arch_sparse_matrix(arch, placeholder_constructors)
        #= none:109 =#
        settings = validate_settings(Val(preconditioner_method), arch, preconditioner_settings)
        #= none:110 =#
        reduced_matrix = arch_sparse_matrix(arch, speye(eltype(grid), 2))
        #= none:111 =#
        preconditioner = build_preconditioner(Val(preconditioner_method), reduced_matrix, settings)
        #= none:113 =#
        state_vars = CGStateVariables(zero(template), deepcopy(template), deepcopy(template))
        #= none:115 =#
        return HeptadiagonalIterativeSolver(grid, problem_size, matrix_constructors, diagonal, placeholder_matrix, preconditioner, preconditioner_method, settings, iterative_solver, state_vars, tolerance, placeholder_timestep, maximum_iterations, verbose)
    end
#= none:131 =#
architecture(solver::HeptadiagonalIterativeSolver) = begin
        #= none:131 =#
        architecture(solver.grid)
    end
#= none:133 =#
#= none:133 =# Core.@doc "    matrix_from_coefficients(arch, grid, coeffs, reduced_dim)\n\nReturn the sparse matrix constructors based on the pentadiagonal coeffients (`coeffs`).\n" function matrix_from_coefficients(arch, grid, coeffs, reduced_dim)
        #= none:138 =#
        #= none:139 =#
        (Ax, Ay, Az, C, D) = coeffs
        #= none:141 =#
        Ax = on_architecture(CPU(), Ax)
        #= none:142 =#
        Ay = on_architecture(CPU(), Ay)
        #= none:143 =#
        Az = on_architecture(CPU(), Az)
        #= none:144 =#
        C = on_architecture(CPU(), C)
        #= none:145 =#
        D = on_architecture(arch, D)
        #= none:147 =#
        N = size(grid)
        #= none:149 =#
        topo = topology(grid)
        #= none:151 =#
        dims = validate_laplacian_direction.(N, topo, reduced_dim)
        #= none:152 =#
        (Nx, Ny, Nz) = (N = validate_laplacian_size.(N, dims))
        #= none:153 =#
        M = prod(N)
        #= none:154 =#
        diag = on_architecture(arch, zeros(eltype(grid), M))
        #= none:164 =#
        posx = (1, Nx - 1)
        #= none:165 =#
        posy = (1, Ny - 1) .* Nx
        #= none:166 =#
        posz = ((1, Nz - 1) .* Nx) .* Ny
        #= none:168 =#
        coeff_d = zeros(eltype(grid), M)
        #= none:169 =#
        coeff_x = zeros(eltype(grid), M - posx[1])
        #= none:170 =#
        coeff_y = zeros(eltype(grid), M - posy[1])
        #= none:171 =#
        coeff_z = zeros(eltype(grid), M - posz[1])
        #= none:172 =#
        coeff_bound_x = zeros(eltype(grid), M - posx[2])
        #= none:173 =#
        coeff_bound_y = zeros(eltype(grid), M - posy[2])
        #= none:174 =#
        coeff_bound_z = zeros(eltype(grid), M - posz[2])
        #= none:177 =#
        loop! = _initialize_variable_diagonal!(Architectures.device(arch), heuristic_workgroup(N...), N)
        #= none:178 =#
        loop!(diag, D, N)
        #= none:181 =#
        fill_core_matrix!(coeff_d, coeff_x, coeff_y, coeff_z, Ax, Ay, Az, C, N, dims)
        #= none:184 =#
        dims[1] && fill_boundaries_x!(coeff_d, coeff_bound_x, Ax, N, topo[1])
        #= none:185 =#
        dims[2] && fill_boundaries_y!(coeff_d, coeff_bound_y, Ay, N, topo[2])
        #= none:186 =#
        dims[3] && fill_boundaries_z!(coeff_d, coeff_bound_z, Az, N, topo[3])
        #= none:188 =#
        sparse_matrix = spdiagm(0 => coeff_d, posx[1] => coeff_x, -(posx[1]) => coeff_x, posx[2] => coeff_bound_x, -(posx[2]) => coeff_bound_x, posy[1] => coeff_y, -(posy[1]) => coeff_y, posy[2] => coeff_bound_y, -(posy[2]) => coeff_bound_y, posz[1] => coeff_z, -(posz[1]) => coeff_z, posz[2] => coeff_bound_z, -(posz[2]) => coeff_bound_z)
        #= none:196 =#
        ensure_diagonal_elements_are_present!(sparse_matrix)
        #= none:198 =#
        matrix_constructors = constructors(arch, sparse_matrix)
        #= none:200 =#
        return (matrix_constructors, diag, N)
    end
#= none:203 =#
#= none:203 =# @kernel function _initialize_variable_diagonal!(diag, D, N)
        #= none:203 =#
        #= none:204 =#
        (i, j, k) = #= none:204 =# @index(Global, NTuple)
        #= none:206 =#
        t = i + N[1] * ((j - 1) + N[2] * (k - 1))
        #= none:207 =#
        #= none:207 =# @inbounds diag[t] = D[i, j, k]
    end
#= none:210 =#
function fill_core_matrix!(coeff_d, coeff_x, coeff_y, coeff_z, Ax, Ay, Az, C, N, dims)
    #= none:210 =#
    #= none:211 =#
    (Nx, Ny, Nz) = N
    #= none:212 =#
    for k = 1:Nz, j = 1:Ny, i = 1:Nx
        #= none:213 =#
        t = i + Nx * ((j - 1) + Ny * (k - 1))
        #= none:214 =#
        coeff_d[t] = C[i, j, k]
        #= none:215 =#
    end
    #= none:216 =#
    if dims[1]
        #= none:217 =#
        for k = 1:Nz, j = 1:Ny, i = 1:Nx - 1
            #= none:218 =#
            t = i + Nx * ((j - 1) + Ny * (k - 1))
            #= none:219 =#
            coeff_x[t] = Ax[i + 1, j, k]
            #= none:220 =#
            coeff_d[t] -= coeff_x[t]
            #= none:221 =#
            coeff_d[t + 1] -= coeff_x[t]
            #= none:222 =#
        end
    end
    #= none:224 =#
    if dims[2]
        #= none:225 =#
        for k = 1:Nz, j = 1:Ny - 1, i = 1:Nx
            #= none:226 =#
            t = i + Nx * ((j - 1) + Ny * (k - 1))
            #= none:227 =#
            coeff_y[t] = Ay[i, j + 1, k]
            #= none:228 =#
            coeff_d[t] -= coeff_y[t]
            #= none:229 =#
            coeff_d[t + Nx] -= coeff_y[t]
            #= none:230 =#
        end
    end
    #= none:232 =#
    if dims[3]
        #= none:233 =#
        for k = 1:Nz - 1, j = 1:Ny, i = 1:Nx
            #= none:234 =#
            t = i + Nx * ((j - 1) + Ny * (k - 1))
            #= none:235 =#
            coeff_z[t] = Az[i, j, k + 1]
            #= none:236 =#
            coeff_d[t] -= coeff_z[t]
            #= none:237 =#
            coeff_d[t + Nx * Ny] -= coeff_z[t]
            #= none:238 =#
        end
    end
end
#= none:255 =#
#= none:255 =# @inline fill_boundaries_x!(coeff_d, coeff_bound_x, Ax, N, ::Type{Bounded}) = begin
            #= none:255 =#
            nothing
        end
#= none:256 =#
#= none:256 =# @inline fill_boundaries_x!(coeff_d, coeff_bound_x, Ax, N, ::Type{Flat}) = begin
            #= none:256 =#
            nothing
        end
#= none:257 =#
function fill_boundaries_x!(coeff_d, coeff_bound_x, Ax, N, ::Type{Periodic})
    #= none:257 =#
    #= none:258 =#
    (Nx, Ny, Nz) = N
    #= none:259 =#
    for k = 1:Nz, j = 1:Ny
        #= none:260 =#
        tₘ = 1 + Nx * ((j - 1) + Ny * (k - 1))
        #= none:261 =#
        tₚ = Nx + Nx * ((j - 1) + Ny * (k - 1))
        #= none:262 =#
        coeff_bound_x[tₘ] = Ax[1, j, k]
        #= none:263 =#
        coeff_d[tₘ] -= coeff_bound_x[tₘ]
        #= none:264 =#
        coeff_d[tₚ] -= coeff_bound_x[tₘ]
        #= none:265 =#
    end
end
#= none:268 =#
#= none:268 =# @inline fill_boundaries_y!(coeff_d, coeff_bound_y, Ay, N, ::Type{Bounded}) = begin
            #= none:268 =#
            nothing
        end
#= none:269 =#
#= none:269 =# @inline fill_boundaries_y!(coeff_d, coeff_bound_y, Ay, N, ::Type{Flat}) = begin
            #= none:269 =#
            nothing
        end
#= none:270 =#
function fill_boundaries_y!(coeff_d, coeff_bound_y, Ay, N, ::Type{Periodic})
    #= none:270 =#
    #= none:271 =#
    (Nx, Ny, Nz) = N
    #= none:273 =#
    for k = 1:Nz, i = 1:Nx
        #= none:274 =#
        tₘ = i + Nx * ((1 - 1) + Ny * (k - 1))
        #= none:275 =#
        tₚ = i + Nx * ((Ny - 1) + Ny * (k - 1))
        #= none:276 =#
        coeff_bound_y[tₘ] = Ay[i, 1, k]
        #= none:277 =#
        coeff_d[tₘ] -= coeff_bound_y[tₘ]
        #= none:278 =#
        coeff_d[tₚ] -= coeff_bound_y[tₘ]
        #= none:279 =#
    end
end
#= none:282 =#
#= none:282 =# @inline fill_boundaries_z!(coeff_d, coeff_bound_z, Az, N, ::Type{Bounded}) = begin
            #= none:282 =#
            nothing
        end
#= none:283 =#
#= none:283 =# @inline fill_boundaries_z!(coeff_d, coeff_bound_z, Az, N, ::Type{Flat}) = begin
            #= none:283 =#
            nothing
        end
#= none:284 =#
function fill_boundaries_z!(coeff_d, coeff_bound_z, Az, N, ::Type{Periodic})
    #= none:284 =#
    #= none:285 =#
    (Nx, Ny, Nz) = N
    #= none:286 =#
    for j = 1:Ny, i = 1:Nx
        #= none:287 =#
        tₘ = i + Nx * ((j - 1) + Ny * (1 - 1))
        #= none:288 =#
        tₚ = i + Nx * ((j - 1) + Ny * (Nz - 1))
        #= none:289 =#
        coeff_bound_z[tₘ] = Az[i, j, 1]
        #= none:290 =#
        coeff_d[tₘ] -= coeff_bound_z[tₘ]
        #= none:291 =#
        coeff_d[tₚ] -= coeff_bound_z[tₘ]
        #= none:292 =#
    end
end
#= none:295 =#
function solve!(x, solver::HeptadiagonalIterativeSolver, b, Δt)
    #= none:295 =#
    #= none:296 =#
    arch = architecture(solver.matrix)
    #= none:299 =#
    if Δt != solver.last_Δt
        #= none:300 =#
        constructors = deepcopy(solver.matrix_constructors)
        #= none:301 =#
        M = prod(solver.problem_size)
        #= none:302 =#
        update_diag!(constructors, arch, M, M, solver.diagonal, Δt, 0)
        #= none:303 =#
        solver.matrix = arch_sparse_matrix(arch, constructors)
        #= none:305 =#
        unsafe_free!(constructors)
        #= none:307 =#
        solver.preconditioner = build_preconditioner(Val(solver.preconditioner_method), solver.matrix, solver.preconditioner_settings)
        #= none:311 =#
        solver.last_Δt = Δt
    end
    #= none:314 =#
    solver.iterative_solver(x, solver.matrix, b, statevars = solver.state_vars, maxiter = solver.maximum_iterations, reltol = solver.tolerance, Pl = solver.preconditioner, verbose = solver.verbose)
    #= none:321 =#
    return nothing
end
#= none:324 =#
function Base.show(io::IO, solver::HeptadiagonalIterativeSolver)
    #= none:324 =#
    #= none:325 =#
    print(io, "Matrix-based iterative solver with: \n")
    #= none:326 =#
    print(io, "├── Problem size: ", solver.problem_size, "\n")
    #= none:327 =#
    print(io, "├── Grid: ", solver.grid, "\n")
    #= none:328 =#
    print(io, "├── Solution method: ", solver.iterative_solver, "\n")
    #= none:329 =#
    print(io, "└── Preconditioner: ", solver.preconditioner_method)
    #= none:331 =#
    return nothing
end