
#= none:1 =#
using Oceananigans.Fields: indices, offset_compute_index
#= none:3 =#
import Oceananigans.Architectures: architecture
#= none:5 =#
struct FFTBasedPoissonSolver{G, Λ, S, B, T}
    #= none:6 =#
    grid::G
    #= none:7 =#
    eigenvalues::Λ
    #= none:8 =#
    storage::S
    #= none:9 =#
    buffer::B
    #= none:10 =#
    transforms::T
end
#= none:13 =#
architecture(solver::FFTBasedPoissonSolver) = begin
        #= none:13 =#
        architecture(solver.grid)
    end
#= none:15 =#
transform_str(transform) = begin
        #= none:15 =#
        string((typeof(transform)).name.wrapper, ", ")
    end
#= none:17 =#
function transform_list_str(transform_list)
    #= none:17 =#
    #= none:18 =#
    transform_strs = (transform_str(t) for t = transform_list)
    #= none:19 =#
    list = string(transform_strs...)
    #= none:20 =#
    list = list[1:end - 2]
    #= none:21 =#
    return list
end
#= none:24 =#
Base.summary(solver::FFTBasedPoissonSolver) = begin
        #= none:24 =#
        "FFTBasedPoissonSolver"
    end
#= none:26 =#
Base.show(io::IO, solver::FFTBasedPoissonSolver) = begin
        #= none:26 =#
        print(io, "FFTBasedPoissonSolver on ", string(typeof(architecture(solver))), ": \n", "├── grid: $(summary(solver.grid))\n", "├── storage: $(typeof(solver.storage))\n", "├── buffer: $(typeof(solver.buffer))\n", "└── transforms:\n", "    ├── forward: ", transform_list_str(solver.transforms.forward), "\n", "    └── backward: ", transform_list_str(solver.transforms.backward))
    end
#= none:35 =#
#= none:35 =# Core.@doc "    FFTBasedPoissonSolver(grid, planner_flag=FFTW.PATIENT)\n\nReturn an `FFTBasedPoissonSolver` that solves the \"generalized\" Poisson equation,\n\n```math\n(∇² + m) ϕ = b,\n```\n\nwhere ``m`` is a number, using a eigenfunction expansion of the discrete Poisson operator\non a staggered grid and for periodic or Neumann boundary conditions.\n\nIn-place transforms are applied to ``b``, which means ``b`` must have complex-valued\nelements (typically the same type as `solver.storage`).\n\nSee [`solve!`](@ref) for more information about the FFT-based Poisson solver algorithm.\n" function FFTBasedPoissonSolver(grid, planner_flag = FFTW.PATIENT)
        #= none:52 =#
        #= none:53 =#
        topo = ((TX, TY, TZ) = topology(grid))
        #= none:55 =#
        λx = poisson_eigenvalues(grid.Nx, grid.Lx, 1, TX())
        #= none:56 =#
        λy = poisson_eigenvalues(grid.Ny, grid.Ly, 2, TY())
        #= none:57 =#
        λz = poisson_eigenvalues(grid.Nz, grid.Lz, 3, TZ())
        #= none:59 =#
        arch = architecture(grid)
        #= none:61 =#
        eigenvalues = (λx = on_architecture(arch, λx), λy = on_architecture(arch, λy), λz = on_architecture(arch, λz))
        #= none:65 =#
        storage = on_architecture(arch, zeros(complex(eltype(grid)), size(grid)...))
        #= none:67 =#
        transforms = plan_transforms(grid, storage, planner_flag)
        #= none:70 =#
        buffer_needed = arch isa GPU && Bounded in topo
        #= none:71 =#
        buffer = if buffer_needed
                similar(storage)
            else
                nothing
            end
        #= none:73 =#
        return FFTBasedPoissonSolver(grid, eigenvalues, storage, buffer, transforms)
    end
#= none:76 =#
#= none:76 =# Core.@doc "    solve!(ϕ, solver::FFTBasedPoissonSolver, b, m=0)\n\nSolve the \"generalized\" Poisson equation,\n\n```math\n(∇² + m) ϕ = b,\n```\n\nwhere ``m`` is a number, using a eigenfunction expansion of the discrete Poisson operator\non a staggered grid and for periodic or Neumann boundary conditions.\n\nIn-place transforms are applied to ``b``, which means ``b`` must have complex-valued\nelements (typically the same type as `solver.storage`).\n\n!!! info \"Alternative names for 'generalized' Poisson equation\"\n    Equation ``(∇² + m) ϕ = b`` is sometimes referred to as the \"screened Poisson\" equation\n    when ``m < 0``, or the Helmholtz equation when ``m > 0``.\n" function solve!(ϕ, solver::FFTBasedPoissonSolver, b = solver.storage, m = 0)
        #= none:95 =#
        #= none:96 =#
        arch = architecture(solver)
        #= none:97 =#
        topo = ((TX, TY, TZ) = topology(solver.grid))
        #= none:98 =#
        (Nx, Ny, Nz) = size(solver.grid)
        #= none:99 =#
        (λx, λy, λz) = solver.eigenvalues
        #= none:102 =#
        ϕc = solver.storage
        #= none:105 =#
        for transform! = solver.transforms.forward
            #= none:106 =#
            transform!(b, solver.buffer)
            #= none:107 =#
        end
        #= none:110 =#
        #= none:110 =# @__dot__ ϕc = -b / ((λx + λy + λz) - m)
        #= none:115 =#
        m === 0 && #= none:115 =# CUDA.@allowscalar(ϕc[1, 1, 1] = 0)
        #= none:118 =#
        for transform! = solver.transforms.backward
            #= none:119 =#
            transform!(ϕc, solver.buffer)
            #= none:120 =#
        end
        #= none:122 =#
        launch!(arch, solver.grid, :xyz, copy_real_component!, ϕ, ϕc, indices(ϕ))
        #= none:124 =#
        return ϕ
    end
#= none:129 =#
#= none:129 =# @kernel function copy_real_component!(ϕ, ϕc, index_ranges)
        #= none:129 =#
        #= none:130 =#
        (i, j, k) = #= none:130 =# @index(Global, NTuple)
        #= none:132 =#
        i′ = offset_compute_index(index_ranges[1], i)
        #= none:133 =#
        j′ = offset_compute_index(index_ranges[2], j)
        #= none:134 =#
        k′ = offset_compute_index(index_ranges[3], k)
        #= none:136 =#
        #= none:136 =# @inbounds ϕ[i′, j′, k′] = real(ϕc[i, j, k])
    end