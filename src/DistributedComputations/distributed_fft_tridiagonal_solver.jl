
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:2 =#
using Oceananigans.Grids: stretched_dimensions
#= none:3 =#
using Oceananigans.Grids: XDirection, YDirection
#= none:4 =#
using Oceananigans.Operators: Δxᶠᵃᵃ, Δyᵃᶠᵃ, Δzᵃᵃᶠ
#= none:6 =#
using Oceananigans.Solvers: BatchedTridiagonalSolver, stretched_direction, ZTridiagonalSolver, YTridiagonalSolver, XTridiagonalSolver, compute_main_diagonal!
#= none:13 =#
struct DistributedFourierTridiagonalPoissonSolver{G, L, B, P, R, S, β}
    #= none:14 =#
    plan::P
    #= none:15 =#
    global_grid::G
    #= none:16 =#
    local_grid::L
    #= none:17 =#
    batched_tridiagonal_solver::B
    #= none:18 =#
    source_term::R
    #= none:19 =#
    storage::S
    #= none:20 =#
    buffer::β
end
#= none:24 =#
const XStretchedDistributedSolver = DistributedFourierTridiagonalPoissonSolver{<:Any, <:Any, <:XTridiagonalSolver}
#= none:25 =#
const YStretchedDistributedSolver = DistributedFourierTridiagonalPoissonSolver{<:Any, <:Any, <:YTridiagonalSolver}
#= none:26 =#
const ZStretchedDistributedSolver = DistributedFourierTridiagonalPoissonSolver{<:Any, <:Any, <:ZTridiagonalSolver}
#= none:28 =#
architecture(solver::DistributedFourierTridiagonalPoissonSolver) = begin
        #= none:28 =#
        architecture(solver.global_grid)
    end
#= none:31 =#
#= none:31 =# @inline Δξᶠ(i, grid, ::Val{1}) = begin
            #= none:31 =#
            Δxᶠᵃᵃ(i, 1, 1, grid)
        end
#= none:32 =#
#= none:32 =# @inline Δξᶠ(j, grid, ::Val{2}) = begin
            #= none:32 =#
            Δyᵃᶠᵃ(1, j, 1, grid)
        end
#= none:33 =#
#= none:33 =# @inline Δξᶠ(k, grid, ::Val{3}) = begin
            #= none:33 =#
            Δzᵃᵃᶠ(1, 1, k, grid)
        end
#= none:35 =#
#= none:35 =# Core.@doc "    DistributedFourierTridiagonalPoissonSolver(global_grid, local_grid)\n\nReturn an FFT-based solver for the Poisson equation evaluated on a `local_grid` that has a non-uniform\nspacing in exactly one direction (i.e. either in x, y or z)\n\n```math\n∇²φ = b\n```\n\nfor `Distributed` architectures.\n\nSupported configurations\n========================\n\nIn the following, `Nx`, `Ny`, and `Nz` are the number of grid points of the **global** grid\nin the `x`, `y`, and `z` directions, while `Rx`, `Ry`, and `Rz` are the number of ranks in the\n`x`, `y`, and `z` directions, respectively. Furthermore, 'pencil' decomposition refers to a domain \ndecomposed in two different directions (i.e., with `Rx != 1` and `Ry != 1`), while 'slab' decomposition \nrefers to a domain decomposed only in one direction, (i.e., with either `Rx == 1` or `Ry == 1`).\nAdditionally, `storage` indicates the `TransposableField` used for storing intermediate results;\nsee [`TransposableField`](@ref).\n\n1. Three dimensional configurations with 'pencil' decompositions in ``(x, y)`` \nwhere `Ny ≥ Rx` and `Ny % Rx = 0`, and `Nz ≥ Ry` and `Nz % Ry = 0`.\n\n2. Two dimensional configurations decomposed in ``x`` where `Ny ≥ Rx` and `Ny % Rx = 0`\n    \n!!! warning \"Unsupported decompositions\"\n    _Any_ configuration decomposed in ``z`` direction is _not_ supported.\n    Furthermore, any ``(x, y)`` decompositions other than the configurations mentioned above are also _not_ supported.\n    \nAlgorithm for pencil decompositions\n============================================\n\nFor pencil decompositions (useful for three-dimensional problems),\nthere are two forward transforms, two backward transforms, one tri-diagonal matrix inversion\nand a variable number of transpositions that require MPI communication, dependent on the \nstretched direction:\n\n- a stretching in the x-direction requires four transpositions\n- a stretching in the y-direction requires six transpositions\n- a stretching in the z-direction requires eight transpositions\n\n!!! note \"Computational cost\"\n    Because of the additional transpositions, a stretching in the x-direction\n    is computationally cheaper than a stretching in the y-direction, and the latter\n    is cheaper than a stretching in the z-direction\n\nIn our implementation we require `Nz ≥ Ry` and `Nx ≥ Ry` with the additional constraint \nthat `Nz % Ry = 0` and `Ny % Rx = 0`.\n\nx - stretched algorithm\n========================\n\n1. `storage.zfield`, partitioned over ``(x, y)`` is initialized with the `rhs`.\n2. Transform along ``z``.\n3. Transpose `storage.zfield` + communicate to `storage.yfield` partitioned into `(Rx, Ry)` processes in ``(x, z)``.\n4. Transform along ``y``.\n5. Transpose `storage.yfield` + communicate to `storage.xfield` partitioned into `(Rx, Ry)` processes in ``(y, z)``.\n6. Solve the tri-diagonal linear system in the ``x`` direction.\n\nSteps 5 -> 1 are reversed to obtain the result in physical space stored in `storage.zfield` \npartitioned over ``(x, y)``.\n\ny - stretched algorithm\n========================\n\n1. `storage.zfield`, partitioned over ``(x, y)`` is initialized with the `rhs`.\n2. Transform along ``z``.\n3. Transpose `storage.zfield` + communicate to `storage.yfield` partitioned into `(Rx, Ry)` processes in ``(x, z)``.\n4. Transpose `storage.yfield` + communicate to `storage.xfield` partitioned into `(Rx, Ry)` processes in ``(y, z)``.\n5. Transform along ``x``.\n6. Transpose `storage.xfield` + communicate to `storage.yfield` partitioned into `(Rx, Ry)` processes in ``(x, z)``.\n7. Solve the tri-diagonal linear system in the ``y`` direction.\n\nSteps 6 -> 1 are reversed to obtain the result in physical space stored in `storage.zfield` \npartitioned over ``(x, y)``.\n\nz - stretched algorithm\n========================\n\n1. `storage.zfield`, partitioned over ``(x, y)`` is initialized with the `rhs`.\n2. Transpose `storage.zfield` + communicate to `storage.yfield` partitioned into `(Rx, Ry)` processes in ``(x, z)``.\n3. Transform along ``y``.\n4. Transpose `storage.yfield` + communicate to `storage.xfield` partitioned into `(Rx, Ry)` processes in ``(y, z)``.\n5. Transform along ``x``.\n6. Transpose `storage.xfield` + communicate to `storage.yfield` partitioned into `(Rx, Ry)` processes in ``(x, z)``.\n7. Transpose `storage.yfield` + communicate to `storage.zfield` partitioned into `(Rx, Ry)` processes in ``(x, y)``.\n8. Solve the tri-diagonal linear system in the ``z`` direction.\n\nSteps 7 -> 1 are reversed to obtain the result in physical space stored in `storage.zfield` \npartitioned over ``(x, y)``.\n\nAlgorithm for slab decompositions\n=============================\n\nThe 'slab' decomposition works in the same manner while skipping the transposes that\nare not required. For example if the domain is decomposed in ``x``, step 4. and 6. in the above algorithm\nare skipped (and the associated reversed step in the backward transform)\n\nRestrictions\n============\n\n1. Pencil decompositions:\n    - `Ny ≥ Rx` and `Ny % Rx = 0`\n    - `Nz ≥ Ry` and `Nz % Ry = 0`\n    - If the ``z`` direction is `Periodic`, also the ``y`` and the ``x`` directions must be `Periodic`\n    - If the ``y`` direction is `Periodic`, also the ``x`` direction must be `Periodic`\n\n2. Slab decomposition:\n    - Same as for two-dimensional decompositions with `Rx` (or `Ry`) equal to one\n\n" function DistributedFourierTridiagonalPoissonSolver(global_grid, local_grid, planner_flag = FFTW.PATIENT; tridiagonal_direction = nothing)
        #= none:149 =#
        #= none:151 =#
        validate_poisson_solver_distributed_grid(global_grid)
        #= none:152 =#
        validate_poisson_solver_configuration(global_grid, local_grid)
        #= none:154 =#
        if isnothing(tridiagonal_direction)
            #= none:155 =#
            tridiagonal_dim = (stretched_dimensions(local_grid))[1]
            #= none:156 =#
            tridiagonal_direction = stretched_direction(local_grid)
        else
            #= none:158 =#
            tridiagonal_dim = if tridiagonal_direction == XDirection()
                    1
                else
                    if tridiagonal_direction == YDirection()
                        2
                    else
                        3
                    end
                end
        end
        #= none:162 =#
        topology(global_grid, tridiagonal_dim) != Bounded && error("`DistributedFourierTridiagonalPoissonSolver` requires that the stretched direction (dimension $(tridiagonal_dim)) is `Bounded`.")
        #= none:165 =#
        FT = Complex{eltype(local_grid)}
        #= none:166 =#
        child_arch = child_architecture(local_grid)
        #= none:167 =#
        storage = TransposableField(CenterField(local_grid), FT)
        #= none:169 =#
        topo = ((TX, TY, TZ) = topology(global_grid))
        #= none:170 =#
        λx = dropdims(poisson_eigenvalues(global_grid.Nx, global_grid.Lx, 1, TX()), dims = (2, 3))
        #= none:171 =#
        λy = dropdims(poisson_eigenvalues(global_grid.Ny, global_grid.Ly, 2, TY()), dims = (1, 3))
        #= none:172 =#
        λz = dropdims(poisson_eigenvalues(global_grid.Nz, global_grid.Lz, 3, TZ()), dims = (1, 2))
        #= none:174 =#
        if tridiagonal_dim == 1
            #= none:175 =#
            arch = architecture(storage.xfield.grid)
            #= none:176 =#
            grid = storage.xfield.grid
            #= none:177 =#
            λ1 = partition_coordinate(λy, size(grid, 2), arch, 2)
            #= none:178 =#
            λ2 = partition_coordinate(λz, size(grid, 3), arch, 3)
        elseif #= none:179 =# tridiagonal_dim == 2
            #= none:180 =#
            arch = architecture(storage.yfield.grid)
            #= none:181 =#
            grid = storage.yfield.grid
            #= none:182 =#
            λ1 = partition_coordinate(λx, size(grid, 1), arch, 1)
            #= none:183 =#
            λ2 = partition_coordinate(λz, size(grid, 3), arch, 3)
        elseif #= none:184 =# tridiagonal_dim == 3
            #= none:185 =#
            arch = architecture(storage.zfield.grid)
            #= none:186 =#
            grid = storage.zfield.grid
            #= none:187 =#
            λ1 = partition_coordinate(λx, size(grid, 1), arch, 1)
            #= none:188 =#
            λ2 = partition_coordinate(λy, size(grid, 2), arch, 2)
        end
        #= none:191 =#
        λ1 = on_architecture(child_arch, λ1)
        #= none:192 =#
        λ2 = on_architecture(child_arch, λ2)
        #= none:194 =#
        plan = plan_distributed_transforms(global_grid, storage, planner_flag)
        #= none:197 =#
        lower_diagonal = #= none:197 =# @allowscalar([1 / Δξᶠ(q, grid, Val(tridiagonal_dim)) for q = 2:size(grid, tridiagonal_dim)])
        #= none:198 =#
        lower_diagonal = on_architecture(child_arch, lower_diagonal)
        #= none:199 =#
        upper_diagonal = lower_diagonal
        #= none:202 =#
        diagonal = zeros(eltype(grid), size(grid)...)
        #= none:203 =#
        diagonal = on_architecture(arch, diagonal)
        #= none:204 =#
        launch_config = if tridiagonal_dim == 1
                #= none:205 =#
                :yz
            elseif #= none:206 =# tridiagonal_dim == 2
                #= none:207 =#
                :xz
            elseif #= none:208 =# tridiagonal_dim == 3
                #= none:209 =#
                :xy
            end
        #= none:212 =#
        launch!(arch, grid, launch_config, compute_main_diagonal!, diagonal, grid, λ1, λ2, tridiagonal_direction)
        #= none:215 =#
        btsolver = BatchedTridiagonalSolver(grid; lower_diagonal, diagonal, upper_diagonal, tridiagonal_direction)
        #= none:218 =#
        x_buffer_needed = child_arch isa GPU && TX == Bounded
        #= none:219 =#
        z_buffer_needed = child_arch isa GPU && TZ == Bounded
        #= none:222 =#
        y_buffer_needed = child_arch isa GPU
        #= none:224 =#
        buffer_x = if x_buffer_needed
                on_architecture(child_arch, zeros(FT, size(storage.xfield)...))
            else
                nothing
            end
        #= none:225 =#
        buffer_y = if y_buffer_needed
                on_architecture(child_arch, zeros(FT, size(storage.yfield)...))
            else
                nothing
            end
        #= none:226 =#
        buffer_z = if z_buffer_needed
                on_architecture(child_arch, zeros(FT, size(storage.zfield)...))
            else
                nothing
            end
        #= none:228 =#
        buffer = if tridiagonal_dim == 1
                #= none:229 =#
                (; y = buffer_y, z = buffer_z)
            elseif #= none:230 =# tridiagonal_dim == 2
                #= none:231 =#
                (; x = buffer_x, z = buffer_z)
            elseif #= none:232 =# tridiagonal_dim == 3
                #= none:233 =#
                (; x = buffer_x, y = buffer_y)
            end
        #= none:236 =#
        if tridiagonal_dim == 1
            #= none:237 =#
            forward = (y! = plan.forward.y!, z! = plan.forward.z!)
            #= none:238 =#
            backward = (y! = plan.backward.y!, z! = plan.backward.z!)
        elseif #= none:239 =# tridiagonal_dim == 2
            #= none:240 =#
            forward = (x! = plan.forward.x!, z! = plan.forward.z!)
            #= none:241 =#
            backward = (x! = plan.backward.x!, z! = plan.backward.z!)
        elseif #= none:242 =# tridiagonal_dim == 3
            #= none:243 =#
            forward = (x! = plan.forward.x!, y! = plan.forward.y!)
            #= none:244 =#
            backward = (x! = plan.backward.x!, y! = plan.backward.y!)
        end
        #= none:247 =#
        plan = (; forward, backward)
        #= none:250 =#
        T = complex(eltype(grid))
        #= none:251 =#
        source_term = zeros(T, size(grid)...)
        #= none:252 =#
        source_term = on_architecture(arch, source_term)
        #= none:254 =#
        return DistributedFourierTridiagonalPoissonSolver(plan, global_grid, local_grid, btsolver, source_term, storage, buffer)
    end
#= none:260 =#
function solve!(x, solver::ZStretchedDistributedSolver)
    #= none:260 =#
    #= none:261 =#
    arch = architecture(solver)
    #= none:262 =#
    storage = solver.storage
    #= none:263 =#
    buffer = solver.buffer
    #= none:265 =#
    transpose_z_to_y!(storage)
    #= none:266 =#
    solver.plan.forward.y!(parent(storage.yfield), buffer.y)
    #= none:267 =#
    transpose_y_to_x!(storage)
    #= none:268 =#
    solver.plan.forward.x!(parent(storage.xfield), buffer.x)
    #= none:269 =#
    transpose_x_to_y!(storage)
    #= none:270 =#
    transpose_y_to_z!(storage)
    #= none:273 =#
    parent(solver.source_term) .= parent(storage.zfield)
    #= none:277 =#
    solve!(storage.zfield, solver.batched_tridiagonal_solver, solver.source_term)
    #= none:279 =#
    transpose_z_to_y!(storage)
    #= none:280 =#
    transpose_y_to_x!(storage)
    #= none:281 =#
    solver.plan.backward.x!(parent(storage.xfield), buffer.x)
    #= none:282 =#
    transpose_x_to_y!(storage)
    #= none:283 =#
    solver.plan.backward.y!(parent(storage.yfield), buffer.y)
    #= none:284 =#
    transpose_y_to_z!(storage)
    #= none:287 =#
    launch!(arch, solver.local_grid, :xyz, _copy_real_component!, x, parent(storage.zfield))
    #= none:290 =#
    return x
end
#= none:293 =#
function solve!(x, solver::YStretchedDistributedSolver)
    #= none:293 =#
    #= none:294 =#
    arch = architecture(solver)
    #= none:295 =#
    storage = solver.storage
    #= none:296 =#
    buffer = solver.buffer
    #= none:298 =#
    solver.plan.forward.z!(parent(storage.zfield), buffer.z)
    #= none:299 =#
    transpose_z_to_y!(storage)
    #= none:300 =#
    transpose_y_to_x!(storage)
    #= none:301 =#
    solver.plan.forward.x!(parent(storage.xfield), buffer.x)
    #= none:302 =#
    transpose_x_to_y!(storage)
    #= none:305 =#
    parent(solver.source_term) .= parent(storage.yfield)
    #= none:309 =#
    solve!(storage.yfield, solver.batched_tridiagonal_solver, solver.source_term)
    #= none:311 =#
    transpose_y_to_x!(storage)
    #= none:312 =#
    solver.plan.backward.x!(parent(storage.xfield), buffer.x)
    #= none:313 =#
    transpose_x_to_y!(storage)
    #= none:314 =#
    transpose_y_to_z!(storage)
    #= none:315 =#
    solver.plan.backward.z!(parent(storage.zfield), buffer.z)
    #= none:318 =#
    launch!(arch, solver.local_grid, :xyz, _copy_real_component!, x, parent(storage.zfield))
    #= none:321 =#
    return x
end
#= none:324 =#
function solve!(x, solver::XStretchedDistributedSolver)
    #= none:324 =#
    #= none:325 =#
    arch = architecture(solver)
    #= none:326 =#
    storage = solver.storage
    #= none:327 =#
    buffer = solver.buffer
    #= none:330 =#
    solver.plan.forward.z!(parent(storage.zfield), buffer.z)
    #= none:331 =#
    transpose_z_to_y!(storage)
    #= none:332 =#
    solver.plan.forward.y!(parent(storage.yfield), buffer.y)
    #= none:333 =#
    transpose_y_to_x!(storage)
    #= none:336 =#
    parent(solver.source_term) .= parent(storage.xfield)
    #= none:340 =#
    solve!(storage.xfield, solver.batched_tridiagonal_solver, solver.source_term)
    #= none:342 =#
    transpose_x_to_y!(storage)
    #= none:343 =#
    solver.plan.backward.y!(parent(storage.yfield), buffer.y)
    #= none:344 =#
    transpose_y_to_z!(storage)
    #= none:345 =#
    solver.plan.backward.z!(parent(storage.zfield), buffer.z)
    #= none:348 =#
    launch!(arch, solver.local_grid, :xyz, _copy_real_component!, x, parent(storage.zfield))
    #= none:351 =#
    return x
end