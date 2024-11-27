
#= none:1 =#
#= none:1 =# Core.@doc "    poisson_eigenvalues(N, L, dim, ::Periodic)\n\nReturn the eigenvalues satisfying the discrete form of Poisson's equation\nwith periodic boundary conditions along the dimension `dim` with `N` grid\npoints and domain extent `L`.\n" function poisson_eigenvalues(N, L, dim, ::Periodic)
        #= none:8 =#
        #= none:9 =#
        inds = reshape(1:N, reshaped_size(N, dim)...)
        #= none:10 =#
        return #= none:10 =# @__dot__(((2 * sin(((inds - 1) * π) / N)) / (L / N)) ^ 2)
    end
#= none:13 =#
#= none:13 =# Core.@doc "    poisson_eigenvalues(N, L, dim, ::Bounded)\n\nReturn the eigenvalues satisfying the discrete form of Poisson's equation\nwith staggered Neumann boundary conditions along the dimension `dim` with\n`N` grid points and domain extent `L`.\n" function poisson_eigenvalues(N, L, dim, ::Bounded)
        #= none:20 =#
        #= none:21 =#
        inds = reshape(1:N, reshaped_size(N, dim)...)
        #= none:22 =#
        return #= none:22 =# @__dot__(((2 * sin(((inds - 1) * π) / (2N))) / (L / N)) ^ 2)
    end
#= none:25 =#
#= none:25 =# Core.@doc "    poisson_eigenvalues(N, L, dim, ::Flat)\n\nReturn N-element array of `0.0` reshaped to three-dimensions.\nThis is also the first `poisson_eigenvalue` for `Bounded` and `Periodic` directions.\n" poisson_eigenvalues(N, L, dim, ::Flat) = begin
            #= none:31 =#
            reshape(zeros(N), reshaped_size(N, dim)...)
        end