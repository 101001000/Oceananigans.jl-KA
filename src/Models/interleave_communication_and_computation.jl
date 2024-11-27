
#= none:1 =#
using Oceananigans: prognostic_fields
#= none:2 =#
using Oceananigans.Grids
#= none:3 =#
using Oceananigans.Utils: KernelParameters
#= none:4 =#
using Oceananigans.Grids: halo_size, topology, architecture
#= none:5 =#
using Oceananigans.DistributedComputations
#= none:6 =#
using Oceananigans.DistributedComputations: DistributedGrid
#= none:7 =#
using Oceananigans.DistributedComputations: synchronize_communication!, SynchronizedDistributed
#= none:9 =#
function complete_communication_and_compute_buffer!(model, ::DistributedGrid, arch)
    #= none:9 =#
    #= none:12 =#
    for field = prognostic_fields(model)
        #= none:13 =#
        synchronize_communication!(field)
        #= none:14 =#
    end
    #= none:17 =#
    compute_buffer_tendencies!(model)
    #= none:19 =#
    return nothing
end
#= none:23 =#
complete_communication_and_compute_buffer!(model, ::DistributedGrid, ::SynchronizedDistributed) = begin
        #= none:23 =#
        nothing
    end
#= none:24 =#
complete_communication_and_compute_buffer!(model, grid, arch) = begin
        #= none:24 =#
        nothing
    end
#= none:26 =#
compute_buffer_tendencies!(model) = begin
        #= none:26 =#
        nothing
    end
#= none:28 =#
#= none:28 =# Core.@doc " Kernel parameters for computing interior tendencies. " interior_tendency_kernel_parameters(arch, grid) = begin
            #= none:29 =#
            :xyz
        end
#= none:30 =#
interior_tendency_kernel_parameters(::SynchronizedDistributed, grid) = begin
        #= none:30 =#
        :xyz
    end
#= none:32 =#
function interior_tendency_kernel_parameters(arch::Distributed, grid)
    #= none:32 =#
    #= none:33 =#
    (Rx, Ry, _) = arch.ranks
    #= none:34 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:35 =#
    (Tx, Ty, _) = topology(grid)
    #= none:36 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:40 =#
    local_x = Rx == 1
    #= none:41 =#
    local_y = Ry == 1
    #= none:42 =#
    one_sided_x = Tx == RightConnected || Tx == LeftConnected
    #= none:43 =#
    one_sided_y = Ty == RightConnected || Ty == LeftConnected
    #= none:46 =#
    Sx = if local_x
            #= none:47 =#
            Nx
        elseif #= none:48 =# one_sided_x
            #= none:49 =#
            Nx - Hx
        else
            #= none:51 =#
            Nx - 2Hx
        end
    #= none:54 =#
    Sy = if local_y
            #= none:55 =#
            Ny
        elseif #= none:56 =# one_sided_y
            #= none:57 =#
            Ny - Hy
        else
            #= none:59 =#
            Ny - 2Hy
        end
    #= none:63 =#
    Ox = if Rx == 1 || Tx == RightConnected
            0
        else
            Hx
        end
    #= none:64 =#
    Oy = if Ry == 1 || Ty == RightConnected
            0
        else
            Hy
        end
    #= none:66 =#
    sizes = (Sx, Sy, Nz)
    #= none:67 =#
    offsets = (Ox, Oy, 0)
    #= none:69 =#
    return KernelParameters(sizes, offsets)
end