
#= none:1 =#
import Oceananigans.Architectures: architecture, child_architecture
#= none:3 =#
abstract type AbstractTransformDirection end
#= none:5 =#
struct Forward <: AbstractTransformDirection
    #= none:5 =#
end
#= none:6 =#
struct Backward <: AbstractTransformDirection
    #= none:6 =#
end
#= none:8 =#
struct DiscreteTransform{P, D, G, Δ, Ω, N, T, Σ}
    #= none:9 =#
    plan::P
    #= none:10 =#
    grid::G
    #= none:11 =#
    direction::D
    #= none:12 =#
    dims::Δ
    #= none:13 =#
    topology::Ω
    #= none:14 =#
    normalization::N
    #= none:15 =#
    twiddle_factors::T
    #= none:16 =#
    transpose_dims::Σ
end
#= none:20 =#
architecture(transform::DiscreteTransform) = begin
        #= none:20 =#
        child_architecture(architecture(transform.grid))
    end
#= none:26 =#
normalization_factor(arch, topo, direction, N) = begin
        #= none:26 =#
        1
    end
#= none:28 =#
#= none:28 =# Core.@doc "    normalization_factor(::CPU, ::Bounded, ::Backward, N)\n\n`FFTW.REDFT01` needs to be normalized by 1/2N.\nSee: http://www.fftw.org/fftw3_doc/1d-Real_002deven-DFTs-_0028DCTs_0029.html#g_t1d-Real_002deven-DFTs-_0028DCTs_0029\n" normalization_factor(::CPU, ::Bounded, ::Backward, N) = begin
            #= none:34 =#
            1 / (2N)
        end
#= none:40 =#
twiddle_factors(arch, grid, dim) = begin
        #= none:40 =#
        nothing
    end
#= none:42 =#
#= none:42 =# Core.@doc "    twiddle_factors(arch::GPU, grid, dims)\n\nTwiddle factors are needed to perform DCTs on the GPU. See equations (19a) and (22) of [Makhoul80](@citet)\nfor the forward and backward twiddle factors respectively.\n" function twiddle_factors(arch::GPU, grid, dims)
        #= none:48 =#
        #= none:50 =#
        length(dims) > 1 && return nothing
        #= none:51 =#
        dim = dims[1]
        #= none:53 =#
        topo = topology(grid)
        #= none:54 =#
        topo[dim] != Bounded && return nothing
        #= none:56 =#
        Ns = size(grid)
        #= none:57 =#
        N = Ns[dim]
        #= none:59 =#
        inds⁺ = reshape(0:N - 1, reshaped_size(N, dim)...)
        #= none:60 =#
        inds⁻ = reshape(0:-1:-((N - 1)), reshaped_size(N, dim)...)
        #= none:62 =#
        ω_4N⁺ = ω.(4N, inds⁺)
        #= none:63 =#
        ω_4N⁻ = ω.(4N, inds⁻)
        #= none:67 =#
        ω_4N⁻[1] *= 1 / 2
        #= none:69 =#
        twiddle_factors = (forward = on_architecture(arch, ω_4N⁺), backward = on_architecture(arch, ω_4N⁻))
        #= none:74 =#
        return twiddle_factors
    end
#= none:81 =#
NoTransform() = begin
        #= none:81 =#
        DiscreteTransform([nothing for _ = fieldnames(DiscreteTransform)]...)
    end
#= none:83 =#
function DiscreteTransform(plan, direction, grid, dims)
    #= none:83 =#
    #= none:84 =#
    arch = child_architecture(grid)
    #= none:86 =#
    isnothing(plan) && return NoTransform()
    #= none:88 =#
    N = size(grid)
    #= none:89 =#
    topo = topology(grid)
    #= none:90 =#
    normalization = prod((normalization_factor(arch, (topo[d])(), direction, N[d]) for d = dims))
    #= none:91 =#
    twiddle = twiddle_factors(arch, grid, dims)
    #= none:92 =#
    transpose = if arch isa GPU && dims == [2]
            (2, 1, 3)
        else
            nothing
        end
    #= none:94 =#
    topo = [((topology(grid))[d])() for d = dims]
    #= none:95 =#
    topo = if length(topo) == 1
            topo[1]
        else
            topo
        end
    #= none:97 =#
    dims = if length(dims) == 1
            dims[1]
        else
            dims
        end
    #= none:99 =#
    return DiscreteTransform(plan, grid, direction, dims, topo, normalization, twiddle, transpose)
end
#= none:106 =#
(transform::DiscreteTransform{<:Nothing})(A, buffer) = begin
        #= none:106 =#
        nothing
    end
#= none:108 =#
function (transform::DiscreteTransform{P, <:Forward})(A, buffer) where P
    #= none:108 =#
    #= none:109 =#
    maybe_permute_indices!(A, buffer, architecture(transform), transform.grid, transform.dims, transform.topology)
    #= none:110 =#
    apply_transform!(A, buffer, transform.plan, transform.transpose_dims)
    #= none:111 =#
    maybe_twiddle_forward!(A, transform.twiddle_factors)
    #= none:112 =#
    maybe_normalize!(A, transform.normalization)
    #= none:113 =#
    return nothing
end
#= none:116 =#
function (transform::DiscreteTransform{P, <:Backward})(A, buffer) where P
    #= none:116 =#
    #= none:117 =#
    maybe_twiddle_backward!(A, transform.twiddle_factors)
    #= none:118 =#
    apply_transform!(A, buffer, transform.plan, transform.transpose_dims)
    #= none:119 =#
    maybe_unpermute_indices!(A, buffer, architecture(transform), transform.grid, transform.dims, transform.topology)
    #= none:120 =#
    maybe_normalize!(A, transform.normalization)
    #= none:121 =#
    return nothing
end
#= none:124 =#
maybe_permute_indices!(A, B, arch, grid, dim, dim_topo) = begin
        #= none:124 =#
        nothing
    end
#= none:126 =#
function maybe_permute_indices!(A, B, arch::GPU, grid, dim, ::Bounded)
    #= none:126 =#
    #= none:127 =#
    permute_indices!(B, A, arch, grid, dim)
    #= none:128 =#
    copyto!(A, B)
    #= none:129 =#
    return nothing
end
#= none:132 =#
maybe_unpermute_indices!(A, B, arch, grid, dim, dim_topo) = begin
        #= none:132 =#
        nothing
    end
#= none:134 =#
function maybe_unpermute_indices!(A, B, arch::GPU, grid, dim, ::Bounded)
    #= none:134 =#
    #= none:135 =#
    unpermute_indices!(B, A, arch, grid, dim)
    #= none:136 =#
    copyto!(A, B)
    #= none:137 =#
    #= none:137 =# @__dot__ A = real(A)
    #= none:138 =#
    return nothing
end
#= none:141 =#
function apply_transform!(A, B, plan, ::Nothing)
    #= none:141 =#
    #= none:142 =#
    plan * A
    #= none:143 =#
    return nothing
end
#= none:146 =#
function apply_transform!(A, B, plan, transpose_dims)
    #= none:146 =#
    #= none:147 =#
    old_size = size(A)
    #= none:148 =#
    transposed_size = Tuple((old_size[d] for d = transpose_dims))
    #= none:150 =#
    if old_size == transposed_size
        #= none:151 =#
        permutedims!(B, A, transpose_dims)
        #= none:152 =#
        plan * B
        #= none:153 =#
        permutedims!(A, B, transpose_dims)
    else
        #= none:155 =#
        B_reshaped = reshape(B, transposed_size...)
        #= none:156 =#
        permutedims!(B_reshaped, A, transpose_dims)
        #= none:157 =#
        plan * B_reshaped
        #= none:158 =#
        permutedims!(A, B_reshaped, transpose_dims)
    end
    #= none:161 =#
    return nothing
end
#= none:164 =#
maybe_twiddle_forward!(A, ::Nothing) = begin
        #= none:164 =#
        nothing
    end
#= none:166 =#
function maybe_twiddle_forward!(A, twiddle)
    #= none:166 =#
    #= none:167 =#
    #= none:167 =# @__dot__ A = 2 * real(twiddle.forward * A)
    #= none:168 =#
    return nothing
end
#= none:171 =#
maybe_twiddle_backward!(A, ::Nothing) = begin
        #= none:171 =#
        nothing
    end
#= none:173 =#
function maybe_twiddle_backward!(A, twiddle)
    #= none:173 =#
    #= none:174 =#
    #= none:174 =# @__dot__ A *= twiddle.backward
    #= none:175 =#
    return nothing
end
#= none:178 =#
function maybe_normalize!(A, normalization)
    #= none:178 =#
    #= none:180 =#
    if normalization != 1
        #= none:181 =#
        #= none:181 =# @__dot__ A *= normalization
    end
    #= none:183 =#
    return nothing
end