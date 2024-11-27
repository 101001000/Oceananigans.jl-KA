
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Solvers: solve!
#= none:4 =#
using Statistics
#= none:6 =#
function identity_operator!(b, x)
    #= none:6 =#
    #= none:7 =#
    parent(b) .= parent(x)
    #= none:8 =#
    return nothing
end
#= none:11 =#
function run_identity_operator_test(grid)
    #= none:11 =#
    #= none:12 =#
    b = CenterField(grid)
    #= none:13 =#
    solver = ConjugateGradientSolver(identity_operator!, template_field = b, reltol = 0, abstol = 10 * sqrt(eps(eltype(grid))))
    #= none:14 =#
    initial_guess = (solution = similar(b))
    #= none:15 =#
    set!(initial_guess, ((x, y, z)->begin
                #= none:15 =#
                rand()
            end))
    #= none:17 =#
    solve!(initial_guess, solver, b)
    #= none:19 =#
    #= none:19 =# @test norm(solution) .< solver.abstol
end
#= none:22 =#
function run_poisson_equation_test(grid)
    #= none:22 =#
    #= none:23 =#
    arch = architecture(grid)
    #= none:25 =#
    ϕ_truth = CenterField(grid)
    #= none:28 =#
    set!(ϕ_truth, ((x, y, z)->begin
                #= none:28 =#
                rand()
            end))
    #= none:29 =#
    parent(ϕ_truth) .-= mean(ϕ_truth)
    #= none:30 =#
    fill_halo_regions!(ϕ_truth)
    #= none:33 =#
    ∇²ϕ = (r = CenterField(grid))
    #= none:34 =#
    compute_∇²!(∇²ϕ, ϕ_truth, arch, grid)
    #= none:36 =#
    solver = ConjugateGradientSolver(compute_∇²!, template_field = ϕ_truth, reltol = eps(eltype(grid)), maxiter = Int(1.0e10))
    #= none:39 =#
    ϕ_solution = CenterField(grid)
    #= none:40 =#
    solve!(ϕ_solution, solver, r, arch, grid)
    #= none:41 =#
    fill_halo_regions!(ϕ_solution)
    #= none:44 =#
    ∇²ϕ_solution = CenterField(grid)
    #= none:45 =#
    compute_∇²!(∇²ϕ_solution, ϕ_solution, arch, grid)
    #= none:48 =#
    extrema_tolerance = 1.0e-12
    #= none:49 =#
    std_tolerance = 1.0e-13
    #= none:51 =#
    #= none:51 =# CUDA.@allowscalar begin
            #= none:52 =#
            #= none:52 =# @test minimum(abs, interior(∇²ϕ_solution) .- interior(∇²ϕ)) < extrema_tolerance
            #= none:53 =#
            #= none:53 =# @test maximum(abs, interior(∇²ϕ_solution) .- interior(∇²ϕ)) < extrema_tolerance
            #= none:54 =#
            #= none:54 =# @test std(interior(∇²ϕ_solution) .- interior(∇²ϕ)) < std_tolerance
            #= none:56 =#
            #= none:56 =# @test minimum(abs, interior(ϕ_solution) .- interior(ϕ_truth)) < extrema_tolerance
            #= none:57 =#
            #= none:57 =# @test maximum(abs, interior(ϕ_solution) .- interior(ϕ_truth)) < extrema_tolerance
            #= none:58 =#
            #= none:58 =# @test std(interior(ϕ_solution) .- interior(ϕ_truth)) < std_tolerance
        end
    #= none:61 =#
    return nothing
end
#= none:64 =#
#= none:64 =# @testset "ConjugateGradientSolver" begin
        #= none:65 =#
        for arch = archs
            #= none:66 =#
            #= none:66 =# @info "Testing ConjugateGradientSolver [$(typeof(arch))]..."
            #= none:67 =#
            grid = RectilinearGrid(arch, size = (4, 8, 4), extent = (1, 3, 1))
            #= none:68 =#
            run_identity_operator_test(grid)
            #= none:69 =#
            run_poisson_equation_test(grid)
            #= none:70 =#
        end
    end