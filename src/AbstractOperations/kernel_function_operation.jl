
#= none:1 =#
using Oceananigans.Grids: prettysummary
#= none:3 =#
struct KernelFunctionOperation{LX, LY, LZ, G, T, K, D} <: AbstractOperation{LX, LY, LZ, G, T}
    #= none:4 =#
    kernel_function::K
    #= none:5 =#
    grid::G
    #= none:6 =#
    arguments::D
    #= none:8 =#
    #= none:8 =# @doc "    KernelFunctionOperation{LX, LY, LZ}(kernel_function, grid, arguments...)\n\nConstruct a `KernelFunctionOperation` at location `(LX, LY, LZ)` on `grid` with `arguments`.\n\n`kernel_function` is called with\n\n```julia\nkernel_function(i, j, k, grid, arguments...)\n```\n\nNote that `compute!(kfo::KernelFunctionOperation)` calls `compute!` on all `kfo.arguments`.\n\nExamples\n========\n\nConstruct a `KernelFunctionOperation` that returns random numbers:\n\n```jldoctest kfo\nusing Oceananigans\n\ngrid = RectilinearGrid(size=(1, 8, 8), extent=(1, 1, 1));\n\nrandom_kernel_function(i, j, k, grid) = rand(); # use CUDA.rand on the GPU\n\nkernel_op = KernelFunctionOperation{Center, Center, Center}(random_kernel_function, grid)\n\n# output\n\nKernelFunctionOperation at (Center, Center, Center)\n├── grid: 1×8×8 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 1×3×3 halo\n├── kernel_function: random_kernel_function (generic function with 1 method)\n└── arguments: ()\n```\n\nConstruct a `KernelFunctionOperation` using the vertical vorticity operator used internally\nto compute vertical vorticity on all grids:\n\n```jldoctest kfo\nusing Oceananigans.Operators: ζ₃ᶠᶠᶜ # called with signature ζ₃ᶠᶠᶜ(i, j, k, grid, u, v)\n\nmodel = HydrostaticFreeSurfaceModel(; grid);\n\nu, v, w = model.velocities;\n\nζ_op = KernelFunctionOperation{Face, Face, Center}(ζ₃ᶠᶠᶜ, grid, u, v)\n\n# output\n\nKernelFunctionOperation at (Face, Face, Center)\n├── grid: 1×8×8 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 1×3×3 halo\n├── kernel_function: ζ₃ᶠᶠᶜ (generic function with 1 method)\n└── arguments: (\"1×8×8 Field{Face, Center, Center} on RectilinearGrid on CPU\", \"1×8×8 Field{Center, Face, Center} on RectilinearGrid on CPU\")\n```\n" function KernelFunctionOperation{LX, LY, LZ}(kernel_function::K, grid::G, arguments...) where {LX, LY, LZ, K, G}
            #= none:63 =#
            #= none:66 =#
            T = eltype(grid)
            #= none:67 =#
            D = typeof(arguments)
            #= none:68 =#
            return new{LX, LY, LZ, G, T, K, D}(kernel_function, grid, arguments)
        end
end
#= none:73 =#
#= none:73 =# @inline Base.getindex(κ::KernelFunctionOperation, i, j, k) = begin
            #= none:73 =#
            κ.kernel_function(i, j, k, κ.grid, κ.arguments...)
        end
#= none:74 =#
indices(κ::KernelFunctionOperation) = begin
        #= none:74 =#
        construct_regionally(intersect_indices, location(κ), κ.arguments...)
    end
#= none:75 =#
compute_at!(κ::KernelFunctionOperation, time) = begin
        #= none:75 =#
        Tuple((compute_at!(d, time) for d = κ.arguments))
    end
#= none:77 =#
#= none:77 =# Core.@doc "Adapt `KernelFunctionOperation` to work on the GPU via CUDAnative and CUDAdrv." (Adapt.adapt_structure(to, κ::KernelFunctionOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
            #= none:78 =#
            KernelFunctionOperation{LX, LY, LZ}(Adapt.adapt(to, κ.kernel_function), Adapt.adapt(to, κ.grid), Tuple((Adapt.adapt(to, a) for a = κ.arguments))...)
        end
#= none:83 =#
(on_architecture(to, κ::KernelFunctionOperation{LX, LY, LZ}) where {LX, LY, LZ}) = begin
        #= none:83 =#
        KernelFunctionOperation{LX, LY, LZ}(on_architecture(to, κ.kernel_function), on_architecture(to, κ.grid), Tuple((on_architecture(to, a) for a = κ.arguments))...)
    end
#= none:88 =#
Base.show(io::IO, kfo::KernelFunctionOperation) = begin
        #= none:88 =#
        print(io, summary(kfo), '\n', "├── grid: ", summary(kfo.grid), '\n', "├── kernel_function: ", prettysummary(kfo.kernel_function), '\n', "└── arguments: ", if isempty(kfo.arguments)
                #= none:94 =#
                "()"
            else
                #= none:96 =#
                (Tuple((string(prettysummary(a)) for a = kfo.arguments[1:end - 1]))..., prettysummary(kfo.arguments[end]))
            end)
    end