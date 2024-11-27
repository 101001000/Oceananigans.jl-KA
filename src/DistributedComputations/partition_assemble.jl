
#= none:1 =#
using Oceananigans.Fields: Field
#= none:3 =#
import Oceananigans.Architectures: on_architecture
#= none:5 =#
all_reduce(op, val, arch::Distributed) = begin
        #= none:5 =#
        MPI.Allreduce(val, op, arch.communicator)
    end
#= none:6 =#
all_reduce(op, val, arch) = begin
        #= none:6 =#
        val
    end
#= none:9 =#
barrier!(arch) = begin
        #= none:9 =#
        nothing
    end
#= none:10 =#
barrier!(arch::Distributed) = begin
        #= none:10 =#
        MPI.Barrier(arch.communicator)
    end
#= none:12 =#
#= none:12 =# Core.@doc "    concatenate_local_sizes(local_size, arch::Distributed) \n\nReturn a 3-Tuple containing a vector of `size(grid, dim)` for each rank in \nall 3 directions.\n" concatenate_local_sizes(local_size, arch::Distributed) = begin
            #= none:18 =#
            Tuple((concatenate_local_sizes(local_size, arch, d) for d = 1:length(local_size)))
        end
#= none:21 =#
concatenate_local_sizes(sz, arch, dim) = begin
        #= none:21 =#
        concatenate_local_sizes(sz[dim], arch, dim)
    end
#= none:23 =#
function concatenate_local_sizes(n::Number, arch::Distributed, dim)
    #= none:23 =#
    #= none:24 =#
    R = arch.ranks[dim]
    #= none:25 =#
    r = arch.local_index[dim]
    #= none:26 =#
    N = zeros(Int, R)
    #= none:28 =#
    (r1, r2) = arch.local_index[[1, 2, 3] .!= dim]
    #= none:30 =#
    if r1 == 1 && r2 == 1
        #= none:31 =#
        N[r] = n
    end
    #= none:34 =#
    MPI.Allreduce!(N, +, arch.communicator)
    #= none:36 =#
    return N
end
#= none:39 =#
#= none:39 =# Core.@doc "    partition_coordinate(coordinate, n, arch, dim)\n\nReturn the local component of the global `coordinate`, which has\nlocal length `n` and is distributed on `arch`itecture\nin the x-, y-, or z- `dim`ension.\n" function partition_coordinate(c::AbstractVector, n, arch, dim)
        #= none:46 =#
        #= none:47 =#
        nl = concatenate_local_sizes(n, arch, dim)
        #= none:48 =#
        r = arch.local_index[dim]
        #= none:50 =#
        start_idx = sum(nl[1:r - 1]) + 1
        #= none:51 =#
        end_idx = if r == (ranks(arch))[dim]
                #= none:52 =#
                length(c)
            else
                #= none:54 =#
                sum(nl[1:r]) + 1
            end
        #= none:57 =#
        return c[start_idx:end_idx]
    end
#= none:60 =#
function partition_coordinate(c::Tuple, n, arch, dim)
    #= none:60 =#
    #= none:61 =#
    nl = concatenate_local_sizes(n, arch, dim)
    #= none:62 =#
    N = sum(nl)
    #= none:63 =#
    R = arch.ranks[dim]
    #= none:64 =#
    Δl = (c[2] - c[1]) / N
    #= none:66 =#
    l = Tuple{Float64, Float64}[(c[1], c[1] + Δl * nl[1])]
    #= none:67 =#
    for i = 2:R
        #= none:68 =#
        lp = (l[i - 1])[2]
        #= none:69 =#
        push!(l, (lp, lp + Δl * nl[i]))
        #= none:70 =#
    end
    #= none:72 =#
    return l[arch.local_index[dim]]
end
#= none:75 =#
#= none:75 =# Core.@doc "    assemble_coordinate(c::AbstractVector, n, R, r, r1, r2, comm) \n\nBuilds a linear global coordinate vector given a local coordinate vector `c_local`\na local number of elements `Nc`, number of ranks `Nr`, rank `r`,\nand `arch`itecture. Since we use a global reduction, only ranks at positions\n1 in the other two directions `r1 == 1` and `r2 == 1` fill the 1D array.\n" function assemble_coordinate(c_local::AbstractVector, n, arch, dim)
        #= none:83 =#
        #= none:84 =#
        nl = concatenate_local_sizes(n, arch, dim)
        #= none:85 =#
        R = arch.ranks[dim]
        #= none:86 =#
        r = arch.local_index[dim]
        #= none:87 =#
        r2 = [arch.local_index[i] for i = filter((x->begin
                                #= none:87 =#
                                x != dim
                            end), (1, 2, 3))]
        #= none:89 =#
        c_global = zeros(eltype(c_local), sum(nl) + 1)
        #= none:91 =#
        if r2[1] == 1 && r2[2] == 1
            #= none:92 =#
            c_global[1 + sum(nl[1:r - 1]):sum(nl[1:r])] .= c_local[1:end - 1]
            #= none:93 =#
            r == R && (c_global[end] = c_local[end])
        end
        #= none:96 =#
        MPI.Allreduce!(c_global, +, arch.communicator)
        #= none:98 =#
        return c_global
    end
#= none:102 =#
function assemble_coordinate(c_local::Tuple, n, arch, dim)
    #= none:102 =#
    #= none:103 =#
    c_global = zeros(Float64, 2)
    #= none:105 =#
    rank = arch.local_index
    #= none:106 =#
    R = arch.ranks[dim]
    #= none:107 =#
    r = rank[dim]
    #= none:108 =#
    r2 = [rank[i] for i = filter((x->begin
                            #= none:108 =#
                            x != dim
                        end), (1, 2, 3))]
    #= none:110 =#
    if rank[1] == 1 && (rank[2] == 1 && rank[3] == 1)
        #= none:111 =#
        c_global[1] = c_local[1]
    elseif #= none:112 =# r == R && (r2[1] == 1 && r2[1] == 1)
        #= none:113 =#
        c_global[2] = c_local[2]
    end
    #= none:116 =#
    MPI.Allreduce!(c_global, +, arch.communicator)
    #= none:118 =#
    return tuple(c_global...)
end
#= none:123 =#
#= none:123 =# Core.@doc "    partition(A, b)\n\nPartition the globally-sized `A` into local arrays with the same size as `b`.\n" partition(A, b::Field) = begin
            #= none:128 =#
            partition(A, architecture(b), size(b))
        end
#= none:129 =#
partition(F::Field, b::Field) = begin
        #= none:129 =#
        partition(interior(F), b)
    end
#= none:130 =#
partition(f::Function, arch, n) = begin
        #= none:130 =#
        f
    end
#= none:131 =#
partition(A::AbstractArray, arch::AbstractSerialArchitecture, local_size) = begin
        #= none:131 =#
        A
    end
#= none:133 =#
#= none:133 =# Core.@doc "    partition(A, arch, local_size)\n\nPartition the globally-sized `A` into local arrays with `local_size` on `arch`itecture.\n" function partition(A::AbstractArray, arch::Distributed, local_size)
        #= none:138 =#
        #= none:139 =#
        A = on_architecture(CPU(), A)
        #= none:141 =#
        (ri, rj, rk) = arch.local_index
        #= none:142 =#
        dims = length(size(A))
        #= none:145 =#
        (nxs, nys, nzs) = concatenate_local_sizes(local_size, arch)
        #= none:148 =#
        nx = nxs[ri]
        #= none:149 =#
        ny = nys[rj]
        #= none:150 =#
        nz = nzs[1]
        #= none:153 =#
        up_to = nxs[1:ri - 1]
        #= none:154 =#
        including = nxs[1:ri]
        #= none:155 =#
        i₁ = sum(up_to) + 1
        #= none:156 =#
        i₂ = sum(including)
        #= none:158 =#
        up_to = nys[1:rj - 1]
        #= none:159 =#
        including = nys[1:rj]
        #= none:160 =#
        j₁ = sum(up_to) + 1
        #= none:161 =#
        j₂ = sum(including)
        #= none:163 =#
        ii = UnitRange(i₁, i₂)
        #= none:164 =#
        jj = UnitRange(j₁, j₂)
        #= none:165 =#
        kk = 1:nz
        #= none:168 =#
        if dims == 2
            #= none:169 =#
            a = zeros(eltype(A), nx, ny)
            #= none:170 =#
            a .= A[ii, jj]
        else
            #= none:172 =#
            a = zeros(eltype(A), nx, ny, nz)
            #= none:173 =#
            a .= A[ii, jj, 1:nz]
        end
        #= none:176 =#
        return on_architecture(child_architecture(arch), a)
    end
#= none:179 =#
#= none:179 =# Core.@doc "    construct_global_array(arch, c_local, (nx, ny, nz))\n\nConstruct global array from local arrays (2D of size `(nx, ny)` or 3D of size (`nx, ny, nz`)).\nUsefull for boundary arrays, forcings and initial conditions.\n" construct_global_array(arch, c_local::AbstractArray, n) = begin
            #= none:185 =#
            c_local
        end
#= none:186 =#
construct_global_array(arch, c_local::Function, N) = begin
        #= none:186 =#
        c_local
    end
#= none:189 =#
function construct_global_array(arch::Distributed, c_local::AbstractArray, n)
    #= none:189 =#
    #= none:190 =#
    c_local = on_architecture(CPU(), c_local)
    #= none:192 =#
    (ri, rj, rk) = arch.local_index
    #= none:194 =#
    dims = length(size(c_local))
    #= none:196 =#
    (nx, ny, nz) = concatenate_local_sizes(n, arch)
    #= none:198 =#
    Nx = sum(nx)
    #= none:199 =#
    Ny = sum(ny)
    #= none:200 =#
    Nz = nz[1]
    #= none:202 =#
    if dims == 2
        #= none:203 =#
        c_global = zeros(eltype(c_local), Nx, Ny)
        #= none:205 =#
        c_global[1 + sum(nx[1:ri - 1]):sum(nx[1:ri]), 1 + sum(ny[1:rj - 1]):sum(ny[1:rj])] .= c_local[1:nx[ri], 1:ny[rj]]
        #= none:208 =#
        MPI.Allreduce!(c_global, +, arch.communicator)
    else
        #= none:210 =#
        c_global = zeros(eltype(c_local), Nx, Ny, Nz)
        #= none:212 =#
        c_global[1 + sum(nx[1:ri - 1]):sum(nx[1:ri]), 1 + sum(ny[1:rj - 1]):sum(ny[1:rj]), 1:Nz] .= c_local[1:nx[ri], 1:ny[rj], 1:Nz]
        #= none:216 =#
        MPI.Allreduce!(c_global, +, arch.communicator)
    end
    #= none:219 =#
    return on_architecture(child_architecture(arch), c_global)
end