
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:2 =#
using Oceananigans.Solvers: solve!, set_source_term!
#= none:3 =#
using Oceananigans.Solvers: poisson_eigenvalues
#= none:4 =#
using Oceananigans.Models.NonhydrostaticModels: solve_for_pressure!
#= none:5 =#
using Oceananigans.Models.HydrostaticFreeSurfaceModels: compute_w_from_continuity!
#= none:6 =#
using Oceananigans.BoundaryConditions: regularize_field_boundary_conditions
#= none:8 =#
function poisson_solver_instantiates(grid, planner_flag)
    #= none:8 =#
    #= none:9 =#
    solver = FFTBasedPoissonSolver(grid, planner_flag)
    #= none:10 =#
    return true
end
#= none:13 =#
function random_divergent_source_term(grid)
    #= none:13 =#
    #= none:14 =#
    arch = architecture(grid)
    #= none:15 =#
    default_bcs = FieldBoundaryConditions()
    #= none:16 =#
    u_bcs = regularize_field_boundary_conditions(default_bcs, grid, :u)
    #= none:17 =#
    v_bcs = regularize_field_boundary_conditions(default_bcs, grid, :v)
    #= none:18 =#
    w_bcs = regularize_field_boundary_conditions(default_bcs, grid, :w)
    #= none:20 =#
    (Ru, Rv, Rw) = VelocityFields(grid, (; u = u_bcs, v = v_bcs, w = w_bcs))
    #= none:22 =#
    U = (u = Ru, v = Rv, w = Rw)
    #= none:24 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:26 =#
    set!(Ru, rand(size(Ru)...))
    #= none:27 =#
    set!(Rv, rand(size(Rv)...))
    #= none:28 =#
    set!(Rw, rand(size(Rw)...))
    #= none:30 =#
    fill_halo_regions!(Ru)
    #= none:31 =#
    fill_halo_regions!(Rv)
    #= none:32 =#
    fill_halo_regions!(Rw)
    #= none:35 =#
    ArrayType = array_type(arch)
    #= none:36 =#
    R = zeros(Nx, Ny, Nz) |> ArrayType
    #= none:37 =#
    launch!(arch, grid, :xyz, divergence!, grid, U.u.data, U.v.data, U.w.data, R)
    #= none:39 =#
    return (R, U)
end
#= none:42 =#
function random_divergence_free_source_term(grid)
    #= none:42 =#
    #= none:43 =#
    default_bcs = FieldBoundaryConditions()
    #= none:44 =#
    u_bcs = regularize_field_boundary_conditions(default_bcs, grid, :u)
    #= none:45 =#
    v_bcs = regularize_field_boundary_conditions(default_bcs, grid, :v)
    #= none:46 =#
    w_bcs = regularize_field_boundary_conditions(default_bcs, grid, :w)
    #= none:49 =#
    (Ru, Rv, Rw) = VelocityFields(grid, (; u = u_bcs, v = v_bcs, w = w_bcs))
    #= none:51 =#
    U = (u = Ru, v = Rv, w = Rw)
    #= none:53 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:55 =#
    set!(Ru, rand(size(Ru)...))
    #= none:56 =#
    set!(Rv, rand(size(Rv)...))
    #= none:57 =#
    set!(Rw, rand(size(Rw)...))
    #= none:59 =#
    fill_halo_regions!(Ru)
    #= none:60 =#
    fill_halo_regions!(Rv)
    #= none:62 =#
    arch = architecture(grid)
    #= none:64 =#
    compute_w_from_continuity!(U, arch, grid)
    #= none:65 =#
    fill_halo_regions!(Rw)
    #= none:68 =#
    ArrayType = array_type(arch)
    #= none:69 =#
    R = zeros(Nx, Ny, Nz) |> ArrayType
    #= none:70 =#
    launch!(arch, grid, :xyz, divergence!, grid, Ru.data, Rv.data, Rw.data, R)
    #= none:72 =#
    return R
end
#= none:79 =#
function divergence_free_poisson_solution(grid, planner_flag = FFTW.MEASURE)
    #= none:79 =#
    #= none:80 =#
    arch = architecture(grid)
    #= none:81 =#
    ArrayType = array_type(arch)
    #= none:82 =#
    FT = eltype(grid)
    #= none:84 =#
    solver = FFTBasedPoissonSolver(grid, planner_flag)
    #= none:85 =#
    (R, U) = random_divergent_source_term(grid)
    #= none:87 =#
    p_bcs = FieldBoundaryConditions(grid, (Center, Center, Center))
    #= none:88 =#
    ϕ = CenterField(grid, boundary_conditions = p_bcs)
    #= none:89 =#
    ∇²ϕ = CenterField(grid, boundary_conditions = p_bcs)
    #= none:92 =#
    solve_for_pressure!(ϕ.data, solver, 1, U)
    #= none:94 =#
    compute_∇²!(∇²ϕ, ϕ, arch, grid)
    #= none:96 =#
    return #= none:96 =# CUDA.@allowscalar(interior(∇²ϕ) ≈ R)
end
#= none:103 =#
ψ(::Type{Bounded}, n, x) = begin
        #= none:103 =#
        cos((n * x) / 2)
    end
#= none:104 =#
ψ(::Type{Periodic}, n, x) = begin
        #= none:104 =#
        cos(n * x)
    end
#= none:106 =#
k²(::Type{Bounded}, n) = begin
        #= none:106 =#
        (n / 2) ^ 2
    end
#= none:107 =#
k²(::Type{Periodic}, n) = begin
        #= none:107 =#
        n ^ 2
    end
#= none:109 =#
function analytical_poisson_solver_test(arch, N, topo; FT = Float64, mode = 1)
    #= none:109 =#
    #= none:110 =#
    grid = RectilinearGrid(arch, FT, topology = topo, size = (N, N, N), x = (0, 2π), y = (0, 2π), z = (0, 2π))
    #= none:111 =#
    solver = FFTBasedPoissonSolver(grid)
    #= none:113 =#
    (xC, yC, zC) = nodes(grid, (Center(), Center(), Center()), reshape = true)
    #= none:115 =#
    (TX, TY, TZ) = topology(grid)
    #= none:116 =#
    Ψ(x, y, z) = begin
            #= none:116 =#
            ψ(TX, mode, x) * ψ(TY, mode, y) * ψ(TZ, mode, z)
        end
    #= none:117 =#
    f(x, y, z) = begin
            #= none:117 =#
            -((k²(TX, mode) + k²(TY, mode) + k²(TZ, mode))) * Ψ(x, y, z)
        end
    #= none:119 =#
    solver.storage .= convert(array_type(arch), f.(xC, yC, zC))
    #= none:121 =#
    ϕc = (rhs = solver.storage)
    #= none:122 =#
    solve!(ϕc, solver, rhs)
    #= none:124 =#
    ϕ = real(Array(solver.storage))
    #= none:126 =#
    L¹_error = mean(abs, ϕ - Ψ.(xC, yC, zC))
    #= none:128 =#
    return L¹_error
end
#= none:131 =#
function poisson_solver_convergence(arch, topo, N¹, N²; FT = Float64, mode = 1)
    #= none:131 =#
    #= none:132 =#
    error¹ = analytical_poisson_solver_test(arch, N¹, topo; FT, mode)
    #= none:133 =#
    error² = analytical_poisson_solver_test(arch, N², topo; FT, mode)
    #= none:135 =#
    rate = log(error¹ / error²) / log(N² / N¹)
    #= none:137 =#
    (TX, TY, TZ) = topo
    #= none:138 =#
    #= none:138 =# @info "Convergence of L¹-normed error, $(typeof(arch)), $(FT), ($(N¹)³ -> $(N²)³), topology=($(TX), $(TY), $(TZ)): $(rate)"
    #= none:140 =#
    return isapprox(rate, 2, rtol = 0.005)
end
#= none:147 =#
get_grid_size(TX, TY, TZ, Nx, Ny, Nz) = begin
        #= none:147 =#
        (Nx, Ny, Nz)
    end
#= none:148 =#
get_grid_size(::Type{Flat}, TY, TZ, Nx, Ny, Nz) = begin
        #= none:148 =#
        (Ny, Nz)
    end
#= none:149 =#
get_grid_size(TX, ::Type{Flat}, TZ, Nx, Ny, Nz) = begin
        #= none:149 =#
        (Nx, Nz)
    end
#= none:151 =#
get_interval_kwargs(TY, TZ, faces, ::Val{1}) = begin
        #= none:151 =#
        (x = faces, y = (0, 1), z = (0, 1))
    end
#= none:152 =#
get_interval_kwargs(TY, ::Type{Flat}, faces, ::Val{1}) = begin
        #= none:152 =#
        (x = faces, y = (0, 1))
    end
#= none:153 =#
get_interval_kwargs(::Type{Flat}, TZ, faces, ::Val{1}) = begin
        #= none:153 =#
        (x = faces, z = (0, 1))
    end
#= none:155 =#
get_interval_kwargs(TX, TZ, faces, ::Val{2}) = begin
        #= none:155 =#
        (x = (0, 1), y = faces, z = (0, 1))
    end
#= none:156 =#
get_interval_kwargs(TX, ::Type{Flat}, faces, ::Val{2}) = begin
        #= none:156 =#
        (x = (0, 1), y = faces)
    end
#= none:157 =#
get_interval_kwargs(::Type{Flat}, TZ, faces, ::Val{2}) = begin
        #= none:157 =#
        (y = faces, z = (0, 1))
    end
#= none:159 =#
get_interval_kwargs(TX, TY, faces, ::Val{3}) = begin
        #= none:159 =#
        (x = (0, 1), y = (0, 1), z = faces)
    end
#= none:160 =#
get_interval_kwargs(TX, ::Type{Flat}, faces, ::Val{3}) = begin
        #= none:160 =#
        (x = (0, 1), z = faces)
    end
#= none:161 =#
get_interval_kwargs(::Type{Flat}, TY, faces, ::Val{3}) = begin
        #= none:161 =#
        (y = (0, 1), z = faces)
    end
#= none:163 =#
function stretched_poisson_solver_correct_answer(FT, arch, topo, N1, N2, faces; stretched_axis = 3)
    #= none:163 =#
    #= none:164 =#
    N_stretched = length(faces) - 1
    #= none:165 =#
    unshifted_sizes = [N1, N2, N_stretched]
    #= none:166 =#
    sz = get_grid_size(topo..., circshift(unshifted_sizes, stretched_axis)...)
    #= none:168 =#
    regular_topos = Tuple((el for (i, el) = enumerate(topo) if i ≠ stretched_axis))
    #= none:169 =#
    intervals = get_interval_kwargs(regular_topos..., faces, Val(stretched_axis))
    #= none:170 =#
    stretched_grid = RectilinearGrid(arch, FT; topology = topo, size = sz, z = faces, intervals...)
    #= none:171 =#
    solver = FourierTridiagonalPoissonSolver(stretched_grid)
    #= none:173 =#
    p_bcs = FieldBoundaryConditions(stretched_grid, (Center, Center, Center))
    #= none:174 =#
    ϕ = CenterField(stretched_grid, boundary_conditions = p_bcs)
    #= none:175 =#
    ∇²ϕ = CenterField(stretched_grid, boundary_conditions = p_bcs)
    #= none:177 =#
    R = random_divergence_free_source_term(stretched_grid)
    #= none:179 =#
    set_source_term!(solver, R)
    #= none:180 =#
    ϕc = solver.storage
    #= none:181 =#
    solve!(ϕc, solver)
    #= none:184 =#
    #= none:184 =# CUDA.@allowscalar interior(ϕ) .= real.(solver.storage)
    #= none:185 =#
    compute_∇²!(∇²ϕ, ϕ, arch, stretched_grid)
    #= none:187 =#
    return Array(interior(∇²ϕ)) ≈ Array(R)
end