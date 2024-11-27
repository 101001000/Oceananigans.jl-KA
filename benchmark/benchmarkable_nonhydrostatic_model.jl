
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
using Oceananigans
#= none:6 =#
using Benchmarks
#= none:10 =#
Architectures = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:11 =#
Ns = [32, 64, 128, 256]
#= none:15 =#
SUITE = BenchmarkGroup()
#= none:17 =#
for Arch = Architectures, N = Ns
    #= none:18 =#
    #= none:18 =# @info "Setting up benchmark: ($(Arch), $(N))..."
    #= none:20 =#
    grid = RectilinearGrid(FT, size = (N, N, N), extent = (1, 1, 1))
    #= none:21 =#
    model = NonhydrostaticModel(Arch(); grid)
    #= none:23 =#
    time_step!(model, 1)
    #= none:25 =#
    benchmark = #= none:25 =# @benchmarkable(begin
                #= none:26 =#
                #= none:26 =# @sync_gpu time_step!($model, 1)
            end, samples = 10)
    #= none:29 =#
    SUITE[(Arch, N)] = benchmark
    #= none:30 =#
end