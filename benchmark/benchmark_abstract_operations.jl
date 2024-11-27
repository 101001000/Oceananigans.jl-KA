
#= none:1 =#
push!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using BenchmarkTools
#= none:4 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:5 =#
using OrderedCollections
#= none:6 =#
using Oceananigans
#= none:7 =#
using Oceananigans.Grids
#= none:8 =#
using Oceananigans.AbstractOperations
#= none:9 =#
using Oceananigans.Fields
#= none:10 =#
using Oceananigans.Utils
#= none:11 =#
using Benchmarks
#= none:13 =#
FT = Float64
#= none:14 =#
Archs = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:20 =#
tags = ["Architecture", "ID", "Operation"]
#= none:21 =#
suite = BenchmarkGroup(tags)
#= none:23 =#
print_system_info()
#= none:25 =#
for Arch = Archs
    #= none:26 =#
    N = if Arch == CPU
            (32, 32, 32)
        else
            (256, 256, 256)
        end
    #= none:28 =#
    grid = RectilinearGrid(Arch(), FT, size = N, extent = (1, 1, 1))
    #= none:29 =#
    model = NonhydrostaticModel(grid = grid, buoyancy = nothing, tracers = (:α, :β, :γ, :δ, :ζ))
    #= none:31 =#
    ε(x, y, z) = begin
            #= none:31 =#
            randn()
        end
    #= none:32 =#
    ε⁺(x, y, z) = begin
            #= none:32 =#
            abs(randn())
        end
    #= none:33 =#
    set!(model, u = ε, v = ε, w = ε, α = ε, β = ε, γ = ε, δ = ε, ζ = ε⁺)
    #= none:35 =#
    (u, v, w) = model.velocities
    #= none:36 =#
    (α, β, γ, δ, ζ) = model.tracers
    #= none:38 =#
    dump_field = Field(Center, Center, Center, Arch(), grid)
    #= none:40 =#
    test_cases = OrderedDict("-α" => -α, "√ζ" => √ζ, "sin(β)" => sin(β), "cos(γ)" => cos(γ), "exp(δ)" => exp(δ), "tanh(ζ)" => tanh(ζ), "α - β" => α - β, "α + β - γ" => (α + β) - γ, "α * β * γ * δ" => α * β * γ * δ, "α * β - γ * δ / ζ" => α * β - (γ * δ) / ζ, "u^2 + v^2" => u ^ 2 + v ^ 2, "√(u^2 + v^2 + w^2)" => √(u ^ 2 + v ^ 2 + w ^ 2), "∂x(α)" => ∂x(α), "∂y(∂y(β))" => ∂y(∂y(β)), "∂z(∂z(∂z(∂z(γ))))" => ∂z(∂z(∂z(∂z(γ)))), "∂x(δ + ζ)" => ∂x(δ + ζ), "∂x(v) - δy(u)" => ∂x(v) - ∂y(u), "∂z(α * β + γ)" => ∂z(α * β + γ), "∂x(u) * ∂y(v) + ∂z(w)" => ∂x(u) * ∂y(v) + ∂z(w), "∂x(α)^2 + ∂y(α)^2 + ∂z(α)^2" => ∂x(α) + ∂y(α) + ∂z(α) ^ 2, "∂x(ζ)^4 + ∂y(ζ)^4 + ∂z(ζ)^4 + 2*∂x(∂x(∂y(∂y(ζ)))) + 2*∂x(∂x(∂z(∂z(ζ)))) + 2*∂y(∂y(∂z(∂z(ζ))))" => ∂x(ζ) ^ 4 + ∂y(ζ) ^ 4 + ∂z(ζ) ^ 4 + 2 * ∂x(∂x(∂y(∂y(ζ)))) + 2 * ∂x(∂x(∂z(∂z(ζ)))) + 2 * ∂y(∂y(∂z(∂z(ζ)))))
    #= none:65 =#
    for (i, (test_name, op)) = enumerate(test_cases)
        #= none:66 =#
        computed_field = ComputedField(op)
        #= none:68 =#
        compute!(computed_field)
        #= none:70 =#
        #= none:70 =# @info "Running abstract operation benchmark: $(test_name)..."
        #= none:72 =#
        trial = #= none:72 =# @benchmark(begin
                    #= none:73 =#
                    #= none:73 =# @sync_gpu compute!($computed_field)
                end, samples = 10)
        #= none:76 =#
        suite[(Arch, i, test_name)] = trial
        #= none:77 =#
    end
    #= none:78 =#
end
#= none:80 =#
df = benchmarks_dataframe(suite)
#= none:81 =#
sort!(df, :ID)
#= none:82 =#
benchmarks_pretty_table(df, title = "Abstract operations benchmarks")
#= none:84 =#
for Arch = Archs
    #= none:85 =#
    suite_arch = speedups_suite(suite[#= none:85 =# @tagged(Arch)], base_case = (Arch, 1, "-α"))
    #= none:86 =#
    df_arch = speedups_dataframe(suite_arch, slowdown = true)
    #= none:87 =#
    sort!(df_arch, :ID)
    #= none:88 =#
    benchmarks_pretty_table(df_arch, title = "Abstract operations relative peformance ($(Arch))")
    #= none:89 =#
end