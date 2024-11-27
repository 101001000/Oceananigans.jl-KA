
#= none:1 =#
using Oceananigans.Grids: architecture
#= none:2 =#
using Oceananigans.Architectures: on_architecture
#= none:3 =#
using KernelAbstractions: @index, @kernel
#= none:4 =#
using MPI: VBuffer, Alltoallv!
#= none:12 =#
transpose_z_to_y!(::SlabYFields) = begin
        #= none:12 =#
        nothing
    end
#= none:13 =#
transpose_y_to_z!(::SlabYFields) = begin
        #= none:13 =#
        nothing
    end
#= none:14 =#
transpose_x_to_y!(::SlabXFields) = begin
        #= none:14 =#
        nothing
    end
#= none:15 =#
transpose_y_to_x!(::SlabXFields) = begin
        #= none:15 =#
        nothing
    end
#= none:25 =#
#= none:25 =# @kernel function _pack_buffer_z_to_y!(yzbuff, zfield, N)
        #= none:25 =#
        #= none:26 =#
        (i, j, k) = #= none:26 =# @index(Global, NTuple)
        #= none:27 =#
        (Nx, Ny, _) = N
        #= none:28 =#
        #= none:28 =# @inbounds yzbuff.send[j + Ny * ((i - 1) + Nx * (k - 1))] = zfield[i, j, k]
    end
#= none:31 =#
#= none:31 =# @kernel function _pack_buffer_x_to_y!(xybuff, xfield, N)
        #= none:31 =#
        #= none:32 =#
        (i, j, k) = #= none:32 =# @index(Global, NTuple)
        #= none:33 =#
        (_, Ny, Nz) = N
        #= none:34 =#
        #= none:34 =# @inbounds xybuff.send[j + Ny * ((k - 1) + Nz * (i - 1))] = xfield[i, j, k]
    end
#= none:38 =#
#= none:38 =# @kernel function _pack_buffer_y_to_x!(xybuff, yfield, N)
        #= none:38 =#
        #= none:39 =#
        (i, j, k) = #= none:39 =# @index(Global, NTuple)
        #= none:40 =#
        (Nx, _, Nz) = N
        #= none:41 =#
        #= none:41 =# @inbounds xybuff.send[i + Nx * ((k - 1) + Nz * (j - 1))] = yfield[i, j, k]
    end
#= none:45 =#
#= none:45 =# @kernel function _pack_buffer_y_to_z!(xybuff, yfield, N)
        #= none:45 =#
        #= none:46 =#
        (i, j, k) = #= none:46 =# @index(Global, NTuple)
        #= none:47 =#
        (Nx, _, Nz) = N
        #= none:48 =#
        #= none:48 =# @inbounds xybuff.send[k + Nz * ((i - 1) + Nx * (j - 1))] = yfield[i, j, k]
    end
#= none:51 =#
#= none:51 =# @kernel function _unpack_buffer_x_from_y!(xybuff, xfield, N, n)
        #= none:51 =#
        #= none:52 =#
        (i, j, k) = #= none:52 =# @index(Global, NTuple)
        #= none:53 =#
        size = (n[1], N[2], N[3])
        #= none:54 =#
        #= none:54 =# @inbounds begin
                #= none:55 =#
                i′ = mod(i - 1, size[1]) + 1
                #= none:56 =#
                m = (i - 1) ÷ size[1]
                #= none:57 =#
                idx = i′ + size[1] * ((k - 1) + size[3] * (j - 1)) + m * prod(size)
                #= none:58 =#
                xfield[i, j, k] = xybuff.recv[idx]
            end
    end
#= none:62 =#
#= none:62 =# @kernel function _unpack_buffer_z_from_y!(yzbuff, zfield, N, n)
        #= none:62 =#
        #= none:63 =#
        (i, j, k) = #= none:63 =# @index(Global, NTuple)
        #= none:64 =#
        size = (N[1], N[2], n[3])
        #= none:65 =#
        #= none:65 =# @inbounds begin
                #= none:66 =#
                k′ = mod(k - 1, size[3]) + 1
                #= none:67 =#
                m = (k - 1) ÷ size[3]
                #= none:68 =#
                idx = k′ + size[3] * ((i - 1) + size[1] * (j - 1)) + m * prod(size)
                #= none:69 =#
                zfield[i, j, k] = yzbuff.recv[idx]
            end
    end
#= none:74 =#
#= none:74 =# @kernel function _unpack_buffer_y_from_z!(yzbuff, yfield, N, n)
        #= none:74 =#
        #= none:75 =#
        (i, j, k) = #= none:75 =# @index(Global, NTuple)
        #= none:76 =#
        size = (N[1], n[2], N[3])
        #= none:77 =#
        #= none:77 =# @inbounds begin
                #= none:78 =#
                j′ = mod(j - 1, size[2]) + 1
                #= none:79 =#
                m = (j - 1) ÷ size[2]
                #= none:80 =#
                idx = j′ + size[2] * ((i - 1) + size[1] * (k - 1)) + m * prod(size)
                #= none:81 =#
                yfield[i, j, k] = yzbuff.recv[idx]
            end
    end
#= none:86 =#
#= none:86 =# @kernel function _unpack_buffer_y_from_x!(yzbuff, yfield, N, n)
        #= none:86 =#
        #= none:87 =#
        (i, j, k) = #= none:87 =# @index(Global, NTuple)
        #= none:88 =#
        size = (N[1], n[2], N[3])
        #= none:89 =#
        #= none:89 =# @inbounds begin
                #= none:90 =#
                j′ = mod(j - 1, size[2]) + 1
                #= none:91 =#
                m = (j - 1) ÷ size[2]
                #= none:92 =#
                idx = j′ + size[2] * ((k - 1) + size[3] * (i - 1)) + m * prod(size)
                #= none:93 =#
                yfield[i, j, k] = yzbuff.recv[idx]
            end
    end
#= none:97 =#
pack_buffer_x_to_y!(buff, f) = begin
        #= none:97 =#
        launch!(architecture(f), f.grid, :xyz, _pack_buffer_x_to_y!, buff, f, size(f))
    end
#= none:98 =#
pack_buffer_z_to_y!(buff, f) = begin
        #= none:98 =#
        launch!(architecture(f), f.grid, :xyz, _pack_buffer_z_to_y!, buff, f, size(f))
    end
#= none:99 =#
pack_buffer_y_to_x!(buff, f) = begin
        #= none:99 =#
        launch!(architecture(f), f.grid, :xyz, _pack_buffer_y_to_x!, buff, f, size(f))
    end
#= none:100 =#
pack_buffer_y_to_z!(buff, f) = begin
        #= none:100 =#
        launch!(architecture(f), f.grid, :xyz, _pack_buffer_y_to_z!, buff, f, size(f))
    end
#= none:102 =#
unpack_buffer_x_from_y!(f, fo, buff) = begin
        #= none:102 =#
        launch!(architecture(f), f.grid, :xyz, _unpack_buffer_x_from_y!, buff, f, size(f), size(fo))
    end
#= none:103 =#
unpack_buffer_z_from_y!(f, fo, buff) = begin
        #= none:103 =#
        launch!(architecture(f), f.grid, :xyz, _unpack_buffer_z_from_y!, buff, f, size(f), size(fo))
    end
#= none:104 =#
unpack_buffer_y_from_x!(f, fo, buff) = begin
        #= none:104 =#
        launch!(architecture(f), f.grid, :xyz, _unpack_buffer_y_from_x!, buff, f, size(f), size(fo))
    end
#= none:105 =#
unpack_buffer_y_from_z!(f, fo, buff) = begin
        #= none:105 =#
        launch!(architecture(f), f.grid, :xyz, _unpack_buffer_y_from_z!, buff, f, size(f), size(fo))
    end
#= none:107 =#
for (from, to, buff) = zip([:y, :z, :y, :x], [:z, :y, :x, :y], [:yz, :yz, :xy, :xy])
    #= none:108 =#
    transpose! = Symbol(:transpose_, from, :_to_, to, :!)
    #= none:109 =#
    pack_buffer! = Symbol(:pack_buffer_, from, :_to_, to, :!)
    #= none:110 =#
    unpack_buffer! = Symbol(:unpack_buffer_, to, :_from_, from, :!)
    #= none:112 =#
    buffer = Symbol(buff, :buff)
    #= none:113 =#
    fromfield = Symbol(from, :field)
    #= none:114 =#
    tofield = Symbol(to, :field)
    #= none:116 =#
    transpose_name = string(transpose!)
    #= none:117 =#
    to_name = string(to)
    #= none:118 =#
    from_name = string(from)
    #= none:120 =#
    pack_buffer_name = string(pack_buffer!)
    #= none:121 =#
    unpack_buffer_name = string(unpack_buffer!)
    #= none:123 =#
    #= none:123 =# @eval begin
            #= none:124 =#
            #= none:124 =# Core.@doc "    $($transpose_name)(pf::TransposableField)\n\nTranspose the fields in `TransposableField` from a $($from_name)-local configuration\n(located in `pf.$($from_name)field`) to a $($to_name)-local configuration located\nin `pf.$($to_name)field`.\n\nTranspose Algorithm:\n====================\n\nThe transpose algorithm works in the following manner\n\n1. We `pack` the three-dimensional data into a one-dimensional buffer to be sent to the other cores\n   We need to synchronize the GPU afterwards before any communication can take place. The packing is\n   done in the `$($pack_buffer_name)` function.\n\n2. The one-dimensional buffer is communicated to all the cores using an in-place `Alltoallv!` MPI\n   routine. From the [MPI.jl documentation](https://juliaparallel.org/MPI.jl/stable/reference/collective/):\n\n   Every process divides the Buffer into `Comm_size(comm)` chunks of equal size,\n   sending the j-th chunk to the process of rank j-1. Every process stores the data received from rank j-1 process\n   in the j-th chunk of the buffer.\n\n   ```\n   rank    send buf                             recv buf\n   ----    --------                             --------\n   0      a, b, c, d, e, f       Alltoall      a, b, A, B, α, β\n   1      A, B, C, D, E, F  ---------------->  c, d, C, D, γ, ψ\n   2      α, β, γ, ψ, η, ν                     e, f, E, F, η, ν\n   ```\n\n   The `Alltoallv` function allows chunks of different sizes to be sent to different cores by passing a `count`,\n   for the moment, chunks of the same size are passed, requiring that the ranks divide the number of grid\n   cells evenly.\n\n3. Once the chunks have been communicated, we `unpack` the received one-dimensional buffer into the three-dimensional\n   field making sure the configuration of the data fits the reshaping. The unpacking is\n   done via the `$($unpack_buffer_name)` function.\n\nLimitations:\n============\n\n- The tranpose is configured to work only in the following four directions:\n \n  1. z-local to y-local\n  2. y-local to x-local\n  3. x-local to y-local\n  4. y-local to z-local\n\n  i.e., there is no direct transpose connecting a x-local to a z-local configuration.\n\n- Since (at the moment) the `Alltoallv` allows only chunks of the same size to be communicated, and\n  x-local and z-local only communicate through the y-local configuration, the limitations are that:\n\n  * The number of ranks that divide the x-direction should divide evenly the y-direction\n  * The number of ranks that divide the y-direction should divide evenly the x-direction\n\n  which implies that\n\n  * For 2D fields in XY (flat z-direction) we can traspose only if the partitioning is in X\n" function $transpose!(pf::TransposableField)
                    #= none:185 =#
                    #= none:186 =#
                    $pack_buffer!(pf.$(buffer), pf.$(fromfield))
                    #= none:187 =#
                    sync_device!(architecture(pf.$(fromfield)))
                    #= none:188 =#
                    Alltoallv!(VBuffer(pf.$(buffer).send, pf.counts.$(buff)), VBuffer(pf.$(buffer).recv, pf.counts.$(buff)), pf.comms.$(buff))
                    #= none:189 =#
                    $unpack_buffer!(pf.$(tofield), pf.$(fromfield), pf.$(buffer))
                    #= none:190 =#
                    return nothing
                end
        end
    #= none:193 =#
end