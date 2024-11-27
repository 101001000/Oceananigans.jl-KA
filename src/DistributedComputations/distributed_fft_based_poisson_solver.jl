
#= none:1 =#
import FFTW
#= none:3 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:4 =#
using Oceananigans.Grids: XYZRegularRG, XYRegularRG, XZRegularRG, YZRegularRG
#= none:6 =#
import Oceananigans.Solvers: poisson_eigenvalues, solve!
#= none:7 =#
import Oceananigans.Architectures: architecture
#= none:8 =#
import Oceananigans.Fields: interior
#= none:10 =#
struct DistributedFFTBasedPoissonSolver{P, F, L, λ, B, S}
    #= none:11 =#
    plan::P
    #= none:12 =#
    global_grid::F
    #= none:13 =#
    local_grid::L
    #= none:14 =#
    eigenvalues::λ
    #= none:15 =#
    buffer::B
    #= none:16 =#
    storage::S
end
#= none:19 =#
architecture(solver::DistributedFFTBasedPoissonSolver) = begin
        #= none:19 =#
        architecture(solver.global_grid)
    end
#= none:22 =#
#= none:22 =# Core.@doc "    DistributedFFTBasedPoissonSolver(global_grid, local_grid)\n\nReturn an FFT-based solver for the Poisson equation,\n\n```math\n∇²φ = b\n```\n\nfor `Distributed` architectures.\n\nSupported configurations\n========================\n\nIn the following, `Nx`, `Ny`, and `Nz` are the number of grid points of the **global** grid, \nin the `x`, `y`, and `z` directions, while `Rx`, `Ry`, and `Rz` are the number of ranks in the\n`x`, `y`, and `z` directions, respectively. Furthermore, 'pencil' decomposition refers to a domain \ndecomposed in two different directions (i.e., with `Rx != 1` and `Ry != 1`), while 'slab' decomposition \nrefers to a domain decomposed only in one direction, (i.e., with either `Rx == 1` or `Ry == 1`).\nAdditionally, `storage` indicates the `TransposableField` used for storing intermediate results;\nsee [`TransposableField`](@ref).\n\n1. Three dimensional grids with pencil decompositions in ``(x, y)`` such the:\nthe `z` direction is local, `Ny ≥ Rx` and `Ny % Rx = 0`, and `Nz ≥ Ry` and `Nz % Ry = 0`.\n\n2. Two dimensional grids decomposed in ``x`` where `Ny ≥ Rx` and `Ny % Rx = 0`.\n\n!!! warning \"Unsupported decompositions\"\n    _Any_ configuration decomposed in ``z`` direction is _not_ supported.\n    Furthermore, any ``(x, y)`` decompositions other than the configurations mentioned above are also _not_ supported.\n\nAlgorithm for pencil decompositions\n===================================\n\nFor pencil decompositions (useful for three-dimensional problems), there are three forward transforms, \nthree backward transforms, and four transpositions that require MPI communication. \nIn the algorithm below, the first dimension is always the local dimension. In our implementation we require\n`Nz ≥ Ry` and `Nx ≥ Ry` with the additional constraint that `Nz % Ry = 0` and `Ny % Rx = 0`.\n\n1. `storage.zfield`, partitioned over ``(x, y)`` is initialized with the `rhs` that is ``b``.\n2. Transform along ``z``.\n3  Transpose `storage.zfield` + communicate to `storage.yfield` partitioned into `(Rx, Ry)` processes in ``(x, z)``.\n4. Transform along ``y``.\n5. Transpose `storage.yfield` + communicate to `storage.xfield` partitioned into `(Rx, Ry)` processes in ``(y, z)``.\n6. Transform in ``x``.\n\nAt this point the three in-place forward transforms are complete, and we\nsolve the Poisson equation by updating `storage.xfield`.\nThen the process is reversed to obtain `storage.zfield` in physical\nspace partitioned over ``(x, y)``.\n\nAlgorithm for stencil decompositions\n====================================\n\nThe stecil decomposition algorithm works in the same manner as the pencil decompostion described above\nwhile skipping the transposes that are not required. For example if the domain is decomposed in ``x``, \nstep 3 in the above algorithm is skipped (and the associated transposition step in the bakward transform)\n\nRestrictions\n============\n\n1. Pencil decomopositions:\n    - `Ny ≥ Rx` and `Ny % Rx = 0`\n    - `Nz ≥ Ry` and `Nz % Ry = 0`\n    - If the ``z`` direction is `Periodic`, also the ``y`` and the ``x`` directions must be `Periodic`\n    - If the ``y`` direction is `Periodic`, also the ``x`` direction must be `Periodic`\n\n2. Stencil decomposition:\n    - same as for pencil decompositions with `Rx` (or `Ry`) equal to one\n" function DistributedFFTBasedPoissonSolver(global_grid, local_grid, planner_flag = FFTW.PATIENT)
        #= none:92 =#
        #= none:94 =#
        validate_poisson_solver_distributed_grid(global_grid)
        #= none:95 =#
        validate_poisson_solver_configuration(global_grid, local_grid)
        #= none:97 =#
        FT = Complex{eltype(local_grid)}
        #= none:99 =#
        storage = TransposableField(CenterField(local_grid), FT)
        #= none:101 =#
        arch = architecture(storage.xfield.grid)
        #= none:102 =#
        child_arch = child_architecture(arch)
        #= none:105 =#
        topo = ((TX, TY, TZ) = topology(global_grid))
        #= none:106 =#
        λx = dropdims(poisson_eigenvalues(global_grid.Nx, global_grid.Lx, 1, TX()), dims = (2, 3))
        #= none:107 =#
        λy = dropdims(poisson_eigenvalues(global_grid.Ny, global_grid.Ly, 2, TY()), dims = (1, 3))
        #= none:108 =#
        λz = dropdims(poisson_eigenvalues(global_grid.Nz, global_grid.Lz, 3, TZ()), dims = (1, 2))
        #= none:110 =#
        λx = partition_coordinate(λx, size(storage.xfield.grid, 1), arch, 1)
        #= none:111 =#
        λy = partition_coordinate(λy, size(storage.xfield.grid, 2), arch, 2)
        #= none:112 =#
        λz = partition_coordinate(λz, size(storage.xfield.grid, 3), arch, 3)
        #= none:114 =#
        λx = on_architecture(child_arch, λx)
        #= none:115 =#
        λy = on_architecture(child_arch, λy)
        #= none:116 =#
        λz = on_architecture(child_arch, λz)
        #= none:118 =#
        eigenvalues = (λx, λy, λz)
        #= none:120 =#
        plan = plan_distributed_transforms(global_grid, storage, planner_flag)
        #= none:123 =#
        x_buffer_needed = child_arch isa GPU && TX == Bounded
        #= none:124 =#
        z_buffer_needed = child_arch isa GPU && TZ == Bounded
        #= none:127 =#
        y_buffer_needed = child_arch isa GPU
        #= none:129 =#
        buffer_x = if x_buffer_needed
                on_architecture(child_arch, zeros(FT, size(storage.xfield)...))
            else
                nothing
            end
        #= none:130 =#
        buffer_y = if y_buffer_needed
                on_architecture(child_arch, zeros(FT, size(storage.yfield)...))
            else
                nothing
            end
        #= none:131 =#
        buffer_z = if z_buffer_needed
                on_architecture(child_arch, zeros(FT, size(storage.zfield)...))
            else
                nothing
            end
        #= none:133 =#
        buffer = (; x = buffer_x, y = buffer_y, z = buffer_z)
        #= none:135 =#
        return DistributedFFTBasedPoissonSolver(plan, global_grid, local_grid, eigenvalues, buffer, storage)
    end
#= none:141 =#
function solve!(x, solver::DistributedFFTBasedPoissonSolver)
    #= none:141 =#
    #= none:142 =#
    storage = solver.storage
    #= none:143 =#
    buffer = solver.buffer
    #= none:144 =#
    arch = architecture(storage.xfield.grid)
    #= none:147 =#
    solver.plan.forward.z!(parent(storage.zfield), buffer.z)
    #= none:148 =#
    transpose_z_to_y!(storage)
    #= none:149 =#
    solver.plan.forward.y!(parent(storage.yfield), buffer.y)
    #= none:150 =#
    transpose_y_to_x!(storage)
    #= none:151 =#
    solver.plan.forward.x!(parent(storage.xfield), buffer.x)
    #= none:155 =#
    λ = solver.eigenvalues
    #= none:156 =#
    x̂ = (b̂ = parent(storage.xfield))
    #= none:158 =#
    launch!(arch, storage.xfield.grid, :xyz, _solve_poisson_in_spectral_space!, x̂, b̂, λ[1], λ[2], λ[3])
    #= none:162 =#
    if arch.local_rank == 0
        #= none:163 =#
        #= none:163 =# @allowscalar x̂[1, 1, 1] = 0
    end
    #= none:167 =#
    solver.plan.backward.x!(parent(storage.xfield), buffer.x)
    #= none:168 =#
    transpose_x_to_y!(storage)
    #= none:169 =#
    solver.plan.backward.y!(parent(storage.yfield), buffer.y)
    #= none:170 =#
    transpose_y_to_z!(storage)
    #= none:171 =#
    solver.plan.backward.z!(parent(storage.zfield), buffer.z)
    #= none:174 =#
    launch!(arch, solver.local_grid, :xyz, _copy_real_component!, x, parent(storage.zfield))
    #= none:177 =#
    return x
end
#= none:180 =#
#= none:180 =# @kernel function _solve_poisson_in_spectral_space!(x̂, b̂, λx, λy, λz)
        #= none:180 =#
        #= none:181 =#
        (i, j, k) = #= none:181 =# @index(Global, NTuple)
        #= none:182 =#
        #= none:182 =# @inbounds x̂[i, j, k] = -(b̂[i, j, k]) / (λx[i] + λy[j] + λz[k])
    end
#= none:185 =#
#= none:185 =# @kernel function _copy_real_component!(ϕ, ϕc)
        #= none:185 =#
        #= none:186 =#
        (i, j, k) = #= none:186 =# @index(Global, NTuple)
        #= none:187 =#
        #= none:187 =# @inbounds ϕ[i, j, k] = real(ϕc[i, j, k])
    end
#= none:191 =#
validate_poisson_solver_distributed_grid(global_grid) = begin
        #= none:191 =#
        throw("Grids other than the RectilinearGrid are not supported in the Distributed NonhydrostaticModels")
    end
#= none:194 =#
function validate_poisson_solver_distributed_grid(global_grid::RectilinearGrid)
    #= none:194 =#
    #= none:195 =#
    (TX, TY, TZ) = topology(global_grid)
    #= none:197 =#
    if TY == Bounded && TZ == Periodic || (TX == Bounded && TY == Periodic || TX == Bounded && TZ == Periodic)
        #= none:198 =#
        throw("Distributed Poisson solvers do not support grids with topology ($(TX), $(TY), $(TZ)) at the moment.\n               A Periodic z-direction requires also the y- and and x-directions to be Periodic, while a Periodic y-direction requires also \n               the x-direction to be Periodic.")
    end
    #= none:203 =#
    if !(global_grid isa YZRegularRG) && (!(global_grid isa XYRegularRG) && !(global_grid isa XZRegularRG))
        #= none:204 =#
        throw("The provided grid is stretched in directions $(stretched_dimensions(global_grid)). \n               A distributed Poisson solver supports only RectilinearGrids that have variably-spaced cells in at most one direction.")
    end
    #= none:208 =#
    return nothing
end
#= none:211 =#
function validate_poisson_solver_configuration(global_grid, local_grid)
    #= none:211 =#
    #= none:214 =#
    (Rx, Ry, Rz) = (architecture(local_grid)).ranks
    #= none:215 =#
    Rz == 1 || throw("Non-singleton ranks in the vertical are not supported by distributed Poisson solvers.")
    #= none:218 =#
    if global_grid.Nz % Ry != 0
        #= none:219 =#
        throw("The number of ranks in the y-direction are $(Ry) with Nz = $(global_grid.Nz) cells in the z-direction.\n               The distributed Poisson solver requires that the number of ranks in the y-direction divide Nz.")
    end
    #= none:223 =#
    if global_grid.Ny % Rx != 0
        #= none:224 =#
        throw("The number of ranks in the y-direction are $(Rx) with Ny = $(global_grid.Ny) cells in the y-direction.\n               The distributed Poisson solver requires that the number of ranks in the x-direction divide Ny.")
    end
    #= none:228 =#
    return nothing
end