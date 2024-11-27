
#= none:1 =#
using Oceananigans.Grids: architecture, deflate_tuple
#= none:2 =#
using Oceananigans.Architectures: on_architecture
#= none:4 =#
struct TransposableField{FX, FY, FZ, YZ, XY, C, Comms}
    #= none:5 =#
    xfield::FX
    #= none:6 =#
    yfield::FY
    #= none:7 =#
    zfield::FZ
    #= none:8 =#
    yzbuff::YZ
    #= none:9 =#
    xybuff::XY
    #= none:10 =#
    counts::C
    #= none:11 =#
    comms::Comms
end
#= none:14 =#
const SlabYFields = TransposableField{<:Any, <:Any, <:Any, <:Nothing}
#= none:15 =#
const SlabXFields = TransposableField{<:Any, <:Any, <:Any, <:Any, <:Nothing}
#= none:17 =#
#= none:17 =# Core.@doc "    TransposableField(field_in, FT = eltype(field_in); with_halos = false)\n\nConstruct a TransposableField object that containes the allocated memory and the ruleset required\nfor distributed transpositions. This includes:\n- `xfield`: A field with an unpartitioned x-direction (x-local)\n- `yfield`: A field with an unpartitioned y-direction (y-local)\n- `zfield`: A field with an unpartitioned z-direction (z-local)\n- one-dimensional buffers for performing communication between the different configurations, in particular:\n    - `yzbuffer`: A buffer for communication between the z- and y-configurations\n    - `xybuffer`: A buffer for communication between the y- and x-configurations\n  These buffers are \"packed\" with the three dimensional data and then \"unpacked\" in the target configuration once\n  received by the target rank.\n- `counts`: The size of the chunks in the buffers to be sent and received\n- `comms`: The MPI communicators for the yz and xy directions (different from MPI.COMM_WORLD!!!)\n\nA `TransposableField` object is used to perform distributed transpositions between different configurations with the \n`transpose_z_to_y!`, `transpose_y_to_x!`, `transpose_x_to_y!`, and `transpose_y_to_z!` functions. \nIn particular:\n- `transpose_z_to_y!` copies data from the z-configuration (`zfield`) to the y-configuration (`yfield`)\n- `transpose_y_to_x!` copies data from the y-configuration (`yfield`) to the x-configuration (`xfield`)\n- `transpose_x_to_y!` copies data from the x-configuration (`xfield`) to the y-configuration (`yfield`)\n- `transpose_y_to_z!` copies data from the y-configuration (`yfield`) to the z-configuration (`zfield`)\n\nFor more information on the transposition algorithm, see the docstring for the `transpose` functions.\n\n# Arguments\n- `field_in`: The input field. It needs to be in a _z-free_ configuration (i.e. ranks[3] == 1).\n- `FT`: The element type of the field. Defaults to the element type of `field_in`.\n- `with_halos`: A boolean indicating whether to include halos in the field. Defaults to `false`.\n" function TransposableField(field_in, FT = eltype(field_in); with_halos = false)
        #= none:48 =#
        #= none:50 =#
        zgrid = field_in.grid
        #= none:51 =#
        ygrid = twin_grid(zgrid; local_direction = :y)
        #= none:52 =#
        xgrid = twin_grid(zgrid; local_direction = :x)
        #= none:54 =#
        xN = size(xgrid)
        #= none:55 =#
        yN = size(ygrid)
        #= none:56 =#
        zN = size(zgrid)
        #= none:58 =#
        zarch = architecture(zgrid)
        #= none:59 =#
        yarch = architecture(ygrid)
        #= none:61 =#
        loc = location(field_in)
        #= none:63 =#
        (Rx, Ry, _) = zarch.ranks
        #= none:64 =#
        if with_halos
            #= none:65 =#
            zfield = Field(loc, zgrid, FT)
            #= none:66 =#
            yfield = if Ry == 1
                    zfield
                else
                    Field(loc, ygrid, FT)
                end
            #= none:67 =#
            xfield = if Rx == 1
                    yfield
                else
                    Field(loc, xgrid, FT)
                end
        else
            #= none:69 =#
            zfield = Field(loc, zgrid, FT; indices = (1:zN[1], 1:zN[2], 1:zN[3]))
            #= none:70 =#
            yfield = if Ry == 1
                    zfield
                else
                    Field(loc, ygrid, FT; indices = (1:yN[1], 1:yN[2], 1:yN[3]))
                end
            #= none:71 =#
            xfield = if Rx == 1
                    yfield
                else
                    Field(loc, xgrid, FT; indices = (1:xN[1], 1:xN[2], 1:xN[3]))
                end
        end
        #= none:75 =#
        yzbuffer = if Ry == 1
                nothing
            else
                (send = on_architecture(zarch, zeros(FT, prod(yN))), recv = on_architecture(zarch, zeros(FT, prod(zN))))
            end
        #= none:77 =#
        xybuffer = if Rx == 1
                nothing
            else
                (send = on_architecture(zarch, zeros(FT, prod(xN))), recv = on_architecture(zarch, zeros(FT, prod(yN))))
            end
        #= none:80 =#
        yzcomm = MPI.Comm_split(MPI.COMM_WORLD, zarch.local_index[1], zarch.local_index[1])
        #= none:81 =#
        xycomm = MPI.Comm_split(MPI.COMM_WORLD, yarch.local_index[3], yarch.local_index[3])
        #= none:83 =#
        (zRx, zRy, zRz) = ranks(zarch)
        #= none:84 =#
        (yRx, yRy, yRz) = ranks(yarch)
        #= none:88 =#
        yzcounts = zeros(Int, zRy * zRz)
        #= none:89 =#
        xycounts = zeros(Int, yRx * yRy)
        #= none:91 =#
        yzrank = MPI.Comm_rank(yzcomm)
        #= none:92 =#
        xyrank = MPI.Comm_rank(xycomm)
        #= none:94 =#
        yzcounts[yzrank + 1] = yN[1] * zN[2] * yN[3]
        #= none:95 =#
        xycounts[xyrank + 1] = yN[1] * xN[2] * xN[3]
        #= none:97 =#
        MPI.Allreduce!(yzcounts, +, yzcomm)
        #= none:98 =#
        MPI.Allreduce!(xycounts, +, xycomm)
        #= none:100 =#
        return TransposableField(xfield, yfield, zfield, yzbuffer, xybuffer, (; yz = yzcounts, xy = xycounts), (; yz = yzcomm, xy = xycomm))
    end
#= none:110 =#
#= none:110 =# Core.@doc "    twin_grid(grid::DistributedGrid; local_direction = :y)\n\nConstruct a \"twin\" grid based on the provided distributed `grid` object.\nThe twin grid is a grid that discretizes the same domain of the original grid, just with a\ndifferent partitioning strategy whereas the \"local dimension\" (i.e. the non-partitioned dimension)\nis specified by the keyword argument `local_direction`. This could be either `:x` or `:y`.\n\nNote that `local_direction = :z` will return the original grid as we do not allow partitioning in\nthe `z` direction.\n" function twin_grid(grid::DistributedGrid; local_direction = :y)
        #= none:121 =#
        #= none:123 =#
        arch = grid.architecture
        #= none:124 =#
        (ri, rj, rk) = arch.local_index
        #= none:126 =#
        R = arch.ranks
        #= none:128 =#
        (nx, ny, nz) = (n = size(grid))
        #= none:129 =#
        (Nx, Ny, Nz) = global_size(arch, n)
        #= none:131 =#
        (TX, TY, TZ) = topology(grid)
        #= none:133 =#
        TX = reconstruct_global_topology(TX, R[1], ri, rj, rk, arch.communicator)
        #= none:134 =#
        TY = reconstruct_global_topology(TY, R[2], rj, ri, rk, arch.communicator)
        #= none:135 =#
        TZ = reconstruct_global_topology(TZ, R[3], rk, ri, rj, arch.communicator)
        #= none:137 =#
        x = cpu_face_constructor_x(grid)
        #= none:138 =#
        y = cpu_face_constructor_y(grid)
        #= none:139 =#
        z = cpu_face_constructor_z(grid)
        #= none:141 =#
        xG = if R[1] == 1
                x
            else
                assemble_coordinate(x, nx, arch, 1)
            end
        #= none:142 =#
        yG = if R[2] == 1
                y
            else
                assemble_coordinate(y, ny, arch, 2)
            end
        #= none:143 =#
        zG = if R[3] == 1
                z
            else
                assemble_coordinate(z, nz, arch, 3)
            end
        #= none:145 =#
        child_arch = child_architecture(arch)
        #= none:147 =#
        FT = eltype(grid)
        #= none:149 =#
        if local_direction == :y
            #= none:150 =#
            ranks = (R[1], 1, R[2])
            #= none:152 =#
            (nnx, nny, nnz) = (nx, Ny, nz ÷ ranks[3])
            #= none:154 =#
            if nnz * ranks[3] < Nz && rj == ranks[3]
                #= none:155 =#
                nnz = Nz - nnz * (ranks[3] - 1)
            end
        elseif #= none:157 =# local_direction == :x
            #= none:158 =#
            ranks = (1, R[1], R[2])
            #= none:160 =#
            (nnx, nny, nnz) = (Nx, Ny ÷ ranks[2], nz ÷ ranks[3])
            #= none:162 =#
            if nny * ranks[2] < Ny && ri == ranks[2]
                #= none:163 =#
                nny = Ny - nny * (ranks[2] - 1)
            end
        elseif #= none:165 =# local_direction == :z
            #= none:167 =#
            return grid
        end
        #= none:170 =#
        new_arch = Distributed(child_arch; partition = Partition(ranks...))
        #= none:171 =#
        global_sz = global_size(new_arch, (nnx, nny, nnz))
        #= none:172 =#
        global_sz = deflate_tuple(TX, TY, TZ, global_sz)
        #= none:174 =#
        return construct_grid(grid, new_arch, FT; size = global_sz, x = xG, y = yG, z = zG, topology = (TX, TY, TZ))
    end
#= none:180 =#
function construct_grid(::RectilinearGrid, arch, FT; size, x, y, z, topology)
    #= none:180 =#
    #= none:181 =#
    (TX, TY, TZ) = topology
    #= none:182 =#
    x = if TX == Flat
            nothing
        else
            x
        end
    #= none:183 =#
    y = if TY == Flat
            nothing
        else
            y
        end
    #= none:184 =#
    z = if TZ == Flat
            nothing
        else
            z
        end
    #= none:186 =#
    return RectilinearGrid(arch, FT; size, x, y, z, topology)
end
#= none:191 =#
function construct_grid(::LatitudeLongitudeGrid, arch, FT; size, x, y, z, topology)
    #= none:191 =#
    #= none:192 =#
    (TX, TY, TZ) = topology
    #= none:193 =#
    longitude = if TX == Flat
            nothing
        else
            x
        end
    #= none:194 =#
    latitude = if TY == Flat
            nothing
        else
            y
        end
    #= none:195 =#
    z = if TZ == Flat
            nothing
        else
            z
        end
    #= none:197 =#
    return LatitudeLongitudeGrid(arch, FT; size, longitude, latitude, z, topology)
end