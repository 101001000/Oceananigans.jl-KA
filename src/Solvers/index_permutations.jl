
#= none:5 =#
#= none:5 =# Core.@doc "    permute_index(i, N)\n\nPermute `i` such that, for example, `i ∈ 1:N` becomes\n\n    [1, 2, 3, 4, 5, 6, 7, 8] -> [1, 8, 2, 7, 3, 6, 4, 5]\n\n    [1, 2, 3, 4, 5, 6, 7, 8, 9] -> [1, 9, 2, 8, 3, 7, 4, 6, 5]\n\nfor `N=8` and `N=9` respectively.\n\nSee equation (20) of [Makhoul80](@citet).\n" #= none:18 =# @inline(permute_index(i, N)::Int = begin
                #= none:18 =#
                ifelse(isodd(i), Base.unsafe_trunc(Int, i / 2) + 1, N - Base.unsafe_trunc(Int, (i - 1) / 2))
            end)
#= none:22 =#
#= none:22 =# Core.@doc "    unpermute_index(i, N)\n\nPermute `i` in the opposite manner as `permute_index`, such that,\nfor example, `i ∈ 1:N` becomes\n\n   [1, 2, 3, 4, 5, 6, 7, 8] -> [1, 3, 5, 7, 8, 6, 4, 2]\n\n   [1, 2, 3, 4, 5, 6, 7, 8, 9] -> [1, 3, 5, 7, 9, 8, 6, 4, 2]\n\nfor `N=8` and `N=9` respectively.\n\nSee equation (20) of [Makhoul80](@citet).\n" #= none:36 =# @inline(unpermute_index(i, N) = begin
                #= none:36 =#
                ifelse(i <= ceil(N / 2), 2i - 1, 2 * ((N - i) + 1))
            end)
#= none:38 =#
#= none:38 =# @kernel function permute_x_indices!(dst, src, grid)
        #= none:38 =#
        #= none:39 =#
        (i, j, k) = #= none:39 =# @index(Global, NTuple)
        #= none:40 =#
        i′ = permute_index(i, grid.Nx)
        #= none:41 =#
        #= none:41 =# @inbounds dst[i′, j, k] = src[i, j, k]
    end
#= none:44 =#
#= none:44 =# @kernel function permute_y_indices!(dst, src, grid)
        #= none:44 =#
        #= none:45 =#
        (i, j, k) = #= none:45 =# @index(Global, NTuple)
        #= none:46 =#
        j′ = permute_index(j, grid.Ny)
        #= none:47 =#
        #= none:47 =# @inbounds dst[i, j′, k] = src[i, j, k]
    end
#= none:50 =#
#= none:50 =# @kernel function permute_z_indices!(dst, src, grid)
        #= none:50 =#
        #= none:51 =#
        (i, j, k) = #= none:51 =# @index(Global, NTuple)
        #= none:52 =#
        k′ = permute_index(k, grid.Nz)
        #= none:53 =#
        #= none:53 =# @inbounds dst[i, j, k′] = src[i, j, k]
    end
#= none:56 =#
#= none:56 =# @kernel function unpermute_x_indices!(dst, src, grid)
        #= none:56 =#
        #= none:57 =#
        (i, j, k) = #= none:57 =# @index(Global, NTuple)
        #= none:58 =#
        i′ = unpermute_index(i, grid.Nx)
        #= none:59 =#
        #= none:59 =# @inbounds dst[i′, j, k] = src[i, j, k]
    end
#= none:62 =#
#= none:62 =# @kernel function unpermute_y_indices!(dst, src, grid)
        #= none:62 =#
        #= none:63 =#
        (i, j, k) = #= none:63 =# @index(Global, NTuple)
        #= none:64 =#
        j′ = unpermute_index(j, grid.Ny)
        #= none:65 =#
        #= none:65 =# @inbounds dst[i, j′, k] = src[i, j, k]
    end
#= none:68 =#
#= none:68 =# @kernel function unpermute_z_indices!(dst, src, grid)
        #= none:68 =#
        #= none:69 =#
        (i, j, k) = #= none:69 =# @index(Global, NTuple)
        #= none:70 =#
        k′ = unpermute_index(k, grid.Nz)
        #= none:71 =#
        #= none:71 =# @inbounds dst[i, j, k′] = src[i, j, k]
    end
#= none:74 =#
permute_kernel! = Dict(1 => permute_x_indices!, 2 => permute_y_indices!, 3 => permute_z_indices!)
#= none:80 =#
unpermute_kernel! = Dict(1 => unpermute_x_indices!, 2 => unpermute_y_indices!, 3 => unpermute_z_indices!)
#= none:86 =#
permute_indices!(dst, src, arch, grid, dim) = begin
        #= none:86 =#
        launch!(arch, grid, :xyz, permute_kernel![dim], dst, src, grid)
    end
#= none:89 =#
unpermute_indices!(dst, src, arch, grid, dim) = begin
        #= none:89 =#
        launch!(arch, grid, :xyz, unpermute_kernel![dim], dst, src, grid)
    end