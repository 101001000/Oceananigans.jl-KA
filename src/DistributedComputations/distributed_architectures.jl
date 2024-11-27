
#= none:1 =#
using Oceananigans.Architectures
#= none:2 =#
using Oceananigans.Grids: topology, validate_tupled_argument
#= none:3 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:5 =#
import Oceananigans.Architectures: device, cpu_architecture, on_architecture, array_type, child_architecture, convert_args
#= none:6 =#
import Oceananigans.Grids: zeros
#= none:7 =#
import Oceananigans.Utils: sync_device!, tupleit
#= none:9 =#
import Base
#= none:15 =#
struct Partition{Sx, Sy, Sz}
    #= none:16 =#
    x::Sx
    #= none:17 =#
    y::Sy
    #= none:18 =#
    z::Sz
end
#= none:21 =#
#= none:21 =# Core.@doc "    Partition(; x = 1, y = 1, z = 1)\n\nReturn `Partition` representing the division of a domain in\nthe `x` (first), `y` (second) and `z` (third) dimension\n\nKeyword arguments:\n==================\n\n- `x`: partitioning of the first dimension \n- `y`: partitioning of the second dimension\n- `z`: partitioning of the third dimension\n\nif supplied as positional arguments `x` will be the first argument, \n`y` the second and `z` the third\n\n`x`, `y` and `z` can be:\n- `x::Int`: allocate `x` processors to the first dimension\n- `Equal()`: divide the domain in `x` equally among the remaining processes (not supported for multiple directions)\n- `Fractional(ϵ₁, ϵ₂, ..., ϵₙ):` divide the domain unequally among `N` processes. The total work is `W = sum(ϵᵢ)`, \n                                 and each process is then allocated `ϵᵢ / W` of the domain.\n- `Sizes(n₁, n₂, ..., nₙ)`: divide the domain unequally. The total work is `W = sum(nᵢ)`, \n                            and each process is then allocated `nᵢ`.\n\nExamples:\n========\n\n```jldoctest\njulia> using Oceananigans; using Oceananigans.DistributedComputations\n\njulia> Partition(1, 4)\nPartition across 4 = 1×4×1 ranks:\n└── y: 4\n\njulia> Partition(x = Fractional(1, 2, 3, 4))\nPartition across 4 = 4×1×1 ranks:\n└── x: Fractional(0.1, 0.2, 0.3, 0.4)\n\n```\n" Partition(x) = begin
            #= none:61 =#
            Partition(validate_partition(x, nothing, nothing)...)
        end
#= none:62 =#
Partition(x, y) = begin
        #= none:62 =#
        Partition(validate_partition(x, y, nothing)...)
    end
#= none:64 =#
Partition(; x = nothing, y = nothing, z = nothing) = begin
        #= none:64 =#
        Partition(validate_partition(x, y, z)...)
    end
#= none:66 =#
function Base.show(io::IO, p::Partition)
    #= none:66 =#
    #= none:67 =#
    r = ((Rx, Ry, Rz) = ranks(p))
    #= none:68 =#
    Nr = prod(r)
    #= none:69 =#
    last_rank = Nr - 1
    #= none:71 =#
    rank_info = if Nr == 1
            #= none:72 =#
            "1 rank"
        else
            #= none:74 =#
            "$(Nr) = $(Rx)×$(Ry)×$(Rz) ranks:"
        end
    #= none:77 =#
    print(io, "Partition across ", rank_info)
    #= none:79 =#
    if Rx > 1
        #= none:80 =#
        s = spine(Ry, Rz)
        #= none:81 =#
        print(io, '\n')
        #= none:82 =#
        print(io, s, " x: ", p.x)
    end
    #= none:85 =#
    if Ry > 1
        #= none:86 =#
        s = spine(Rz)
        #= none:87 =#
        print(io, '\n')
        #= none:88 =#
        print(io, s, " y: ", p.y)
    end
    #= none:91 =#
    if Rz > 1
        #= none:92 =#
        s = "└── "
        #= none:93 =#
        print(io, '\n')
        #= none:94 =#
        print(io, s, " z: ", p.z)
    end
end
#= none:98 =#
spine(ξ, η = 1) = begin
        #= none:98 =#
        if ξ > 1 || η > 1
            "├──"
        else
            "└──"
        end
    end
#= none:100 =#
#= none:100 =# Core.@doc "    Equal()\n\nReturn a type that partitions a direction equally among remaining processes.\n\n`Equal()` can be used for only one direction. Other directions must either be unspecified, or\nspecifically defined by `Int`, `Fractional`, or `Sizes`.\n" struct Equal
        #= none:108 =#
    end
#= none:110 =#
struct Fractional{S}
    #= none:111 =#
    sizes::S
end
#= none:114 =#
struct Sizes{S}
    #= none:115 =#
    sizes::S
end
#= none:118 =#
#= none:118 =# Core.@doc "    Fractional(ϵ₁, ϵ₂, ..., ϵₙ)\n\nReturn a type that partitions a direction unequally. The total work is `W = sum(ϵᵢ)`, \nand each process is then allocated `ϵᵢ / W` of the domain.\n" Fractional(args...) = begin
            #= none:124 =#
            Fractional(tuple(args ./ sum(args)...))
        end
#= none:126 =#
#= none:126 =# Core.@doc "    Sizes(n₁, n₂, ..., nₙ)\n\nReturn a type that partitions a direction unequally. The total work is `W = sum(nᵢ)`, \nand each process is then allocated `nᵢ`.\n" Sizes(args...) = begin
            #= none:132 =#
            Sizes(tuple(args...))
        end
#= none:134 =#
Partition(x::Equal, y, z) = begin
        #= none:134 =#
        Partition(validate_partition(x, y, z)...)
    end
#= none:135 =#
Partition(x, y::Equal, z) = begin
        #= none:135 =#
        Partition(validate_partition(x, y, z)...)
    end
#= none:136 =#
Partition(x, y, z::Equal) = begin
        #= none:136 =#
        Partition(validate_partition(x, y, z)...)
    end
#= none:138 =#
Base.summary(s::Sizes) = begin
        #= none:138 =#
        string("Sizes", s.sizes)
    end
#= none:139 =#
Base.summary(f::Fractional) = begin
        #= none:139 =#
        string("Fractional", f.sizes)
    end
#= none:141 =#
Base.show(io::IO, s::Sizes) = begin
        #= none:141 =#
        print(io, summary(s))
    end
#= none:142 =#
Base.show(io::IO, f::Fractional) = begin
        #= none:142 =#
        print(io, summary(f))
    end
#= none:144 =#
ranks(p::Partition) = begin
        #= none:144 =#
        (ranks(p.x), ranks(p.y), ranks(p.z))
    end
#= none:145 =#
ranks(::Nothing) = begin
        #= none:145 =#
        1
    end
#= none:146 =#
ranks(r::Int) = begin
        #= none:146 =#
        r
    end
#= none:147 =#
ranks(r::Sizes) = begin
        #= none:147 =#
        length(r.sizes)
    end
#= none:148 =#
ranks(r::Fractional) = begin
        #= none:148 =#
        length(r.sizes)
    end
#= none:150 =#
Base.size(p::Partition) = begin
        #= none:150 =#
        ranks(p)
    end
#= none:153 =#
validate_partition(x) = begin
        #= none:153 =#
        ifelse(ranks(x) == 1, nothing, x)
    end
#= none:155 =#
validate_partition(x, y, z) = begin
        #= none:155 =#
        map(validate_partition, (x, y, z))
    end
#= none:156 =#
validate_partition(::Equal, y, z) = begin
        #= none:156 =#
        (remaining_workers(y, z), y, z)
    end
#= none:158 =#
validate_partition(x, ::Equal, z) = begin
        #= none:158 =#
        (x, remaining_workers(x, z), z)
    end
#= none:159 =#
validate_partition(x, y, ::Equal) = begin
        #= none:159 =#
        (x, y, remaining_workers(x, y))
    end
#= none:161 =#
function remaining_workers(r1, r2)
    #= none:161 =#
    #= none:162 =#
    MPI.Initialized() || MPI.Init()
    #= none:163 =#
    r12 = ranks(r1) * ranks(r2)
    #= none:164 =#
    return MPI.Comm_size(MPI.COMM_WORLD) ÷ r12
end
#= none:167 =#
struct Distributed{A, S, Δ, R, ρ, I, C, γ, M, T} <: AbstractArchitecture
    #= none:168 =#
    child_architecture::A
    #= none:169 =#
    partition::Δ
    #= none:170 =#
    ranks::R
    #= none:171 =#
    local_rank::ρ
    #= none:172 =#
    local_index::I
    #= none:173 =#
    connectivity::C
    #= none:174 =#
    communicator::γ
    #= none:175 =#
    mpi_requests::M
    #= none:176 =#
    mpi_tag::T
    #= none:178 =#
    (Distributed{S}(child_architecture::A, partition::Δ, ranks::R, local_rank::ρ, local_index::I, connectivity::C, communicator::γ, mpi_requests::M, mpi_tag::T) where {S, A, Δ, R, ρ, I, C, γ, M, T}) = begin
            #= none:178 =#
            new{A, S, Δ, R, ρ, I, C, γ, M, T}(child_architecture, partition, ranks, local_rank, local_index, connectivity, communicator, mpi_requests, mpi_tag)
        end
end
#= none:202 =#
#= none:202 =# Core.@doc "    Distributed(child_architecture = CPU(); \n                partition = Partition(MPI.Comm_size(communicator)),\n                devices = nothing, \n                communicator = MPI.COMM_WORLD,\n                synchronized_communication = false)\n\nReturn a distributed architecture that uses MPI for communications.\n\nPositional arguments\n====================\n\n- `child_architecture`: Specifies whether the computation is performed on CPUs or GPUs. \n                        Default: `CPU()`.\n\nKeyword arguments\n=================\n\n- `partition`: A [`Partition`](@ref) specifying the total processors in the `x`, `y`, and `z` direction.\n               Note that support for distributed `z` direction is  limited; we strongly suggest\n               using partition with `z = 1` kwarg.\n\n- `devices`: `GPU` device linked to local rank. The GPU will be assigned based on the \n             local node rank as such `devices[node_rank]`. Make sure to run `--ntasks-per-node` <= `--gres=gpu`.\n             If `nothing`, the devices will be assigned automatically based on the available resources.\n             This argument is irrelevant if `child_architecture = CPU()`.\n\n- `communicator`: the MPI communicator that orchestrates data transfer between nodes.\n                  Default: `MPI.COMM_WORLD`.\n\n- `synchronized_communication`: This keyword argument can be used to control downstream code behavior.\n                                If `true`, then downstream code may use this tag to toggle between an algorithm\n                                that permits communication between nodes \"asynchronously\" with other computations,\n                                and an alternative serial algorithm in which communication and computation are\n                                \"synchronous\" (that is, performed one after the other).\n                                Default: `false`, specifying the use of asynchronous algorithms where supported,\n                                which may result in faster time-to-solution.\n" function Distributed(child_architecture = CPU(); partition = nothing, devices = nothing, communicator = nothing, synchronized_communication = false)
        #= none:240 =#
        #= none:246 =#
        if !(MPI.Initialized())
            #= none:247 =#
            #= none:247 =# @info "MPI has not been initialized, so we are calling MPI.Init()."
            #= none:248 =#
            MPI.Init()
        end
        #= none:251 =#
        if isnothing(communicator)
            #= none:252 =#
            communicator = MPI.COMM_WORLD
        end
        #= none:255 =#
        mpi_ranks = MPI.Comm_size(communicator)
        #= none:257 =#
        if isnothing(partition)
            #= none:258 =#
            partition = Partition(mpi_ranks)
        end
        #= none:261 =#
        ranks = ((Rx, Ry, Rz) = size(partition))
        #= none:262 =#
        partition_ranks = Rx * Ry * Rz
        #= none:265 =#
        if partition_ranks != mpi_ranks
            #= none:266 =#
            throw(ArgumentError("Partition($(Rx), $(Ry), $(Rz)) [$(partition_ranks) ranks] inconsistent " * "with $(mpi_ranks) MPI ranks"))
        end
        #= none:270 =#
        local_rank = MPI.Comm_rank(communicator)
        #= none:271 =#
        local_index = rank2index(local_rank, Rx, Ry, Rz)
        #= none:273 =#
        local_connectivity = RankConnectivity(local_index, ranks)
        #= none:276 =#
        if child_architecture isa GPU
            #= none:277 =#
            local_comm = MPI.Comm_split_type(communicator, MPI.COMM_TYPE_SHARED, local_rank)
            #= none:278 =#
            node_rank = MPI.Comm_rank(local_comm)
            #= none:279 =#
            if isnothing(devices)
                nothing
            else
                nothing
            end
        end
        #= none:282 =#
        mpi_requests = MPI.Request[]
        #= none:284 =#
        return Distributed{synchronized_communication}(child_architecture, partition, ranks, local_rank, local_index, local_connectivity, communicator, mpi_requests, Ref(0))
    end
#= none:295 =#
const DistributedCPU = Distributed{CPU}
#= none:296 =#
const DistributedGPU = Distributed{GPU}
#= none:298 =#
const SynchronizedDistributed = Distributed{<:Any, true}
#= none:304 =#
ranks(arch::Distributed) = begin
        #= none:304 =#
        ranks(arch.partition)
    end
#= none:306 =#
child_architecture(arch::Distributed) = begin
        #= none:306 =#
        arch.child_architecture
    end
#= none:307 =#
device(arch::Distributed) = begin
        #= none:307 =#
        device(child_architecture(arch))
    end
#= none:309 =#
zeros(FT, arch::Distributed, N...) = begin
        #= none:309 =#
        zeros(FT, child_architecture(arch), N...)
    end
#= none:310 =#
array_type(arch::Distributed) = begin
        #= none:310 =#
        array_type(child_architecture(arch))
    end
#= none:311 =#
sync_device!(arch::Distributed) = begin
        #= none:311 =#
        sync_device!(arch.child_architecture)
    end
#= none:312 =#
convert_args(arch::Distributed, arg) = begin
        #= none:312 =#
        convert_args(child_architecture(arch), arg)
    end
#= none:314 =#
cpu_architecture(arch::DistributedCPU) = begin
        #= none:314 =#
        arch
    end
#= none:315 =#
(cpu_architecture(arch::Distributed{A, S}) where {A, S}) = begin
        #= none:315 =#
        Distributed{S}(CPU(), arch.partition, arch.ranks, arch.local_rank, arch.local_index, arch.connectivity, arch.communicator, arch.mpi_requests, arch.mpi_tag)
    end
#= none:330 =#
index2rank(i, j, k, Rx, Ry, Rz) = begin
        #= none:330 =#
        (i - 1) * Ry * Rz + (j - 1) * Rz + (k - 1)
    end
#= none:332 =#
function rank2index(r, Rx, Ry, Rz)
    #= none:332 =#
    #= none:333 =#
    i = div(r, Ry * Rz)
    #= none:334 =#
    r -= i * Ry * Rz
    #= none:335 =#
    j = div(r, Rz)
    #= none:336 =#
    k = mod(r, Rz)
    #= none:337 =#
    return (i + 1, j + 1, k + 1)
end
#= none:344 =#
struct RankConnectivity{E, W, N, S, SW, SE, NW, NE}
    #= none:345 =#
    east::E
    #= none:346 =#
    west::W
    #= none:347 =#
    north::N
    #= none:348 =#
    south::S
    #= none:349 =#
    southwest::SW
    #= none:350 =#
    southeast::SE
    #= none:351 =#
    northwest::NW
    #= none:352 =#
    northeast::NE
end
#= none:355 =#
const NoConnectivity = RankConnectivity{Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing}
#= none:357 =#
#= none:357 =# Core.@doc "    RankConnectivity(; east, west, north, south, southwest, southeast, northwest, northeast)\n\nGenerate a `RankConnectivity` object that holds the MPI ranks of the neighboring processors.\n" RankConnectivity(; east, west, north, south, southwest, southeast, northwest, northeast) = begin
            #= none:362 =#
            RankConnectivity(east, west, north, south, southwest, southeast, northwest, northeast)
        end
#= none:367 =#
function increment_index(i, R)
    #= none:367 =#
    #= none:368 =#
    R == 1 && return nothing
    #= none:369 =#
    if i + 1 > R
        #= none:370 =#
        return 1
    else
        #= none:372 =#
        return i + 1
    end
end
#= none:376 =#
function decrement_index(i, R)
    #= none:376 =#
    #= none:377 =#
    R == 1 && return nothing
    #= none:378 =#
    if i - 1 < 1
        #= none:379 =#
        return R
    else
        #= none:381 =#
        return i - 1
    end
end
#= none:385 =#
function RankConnectivity(local_index, ranks)
    #= none:385 =#
    #= none:386 =#
    (i, j, k) = local_index
    #= none:387 =#
    (Rx, Ry, Rz) = ranks
    #= none:389 =#
    i_east = increment_index(i, Rx)
    #= none:390 =#
    i_west = decrement_index(i, Rx)
    #= none:391 =#
    j_north = increment_index(j, Ry)
    #= none:392 =#
    j_south = decrement_index(j, Ry)
    #= none:394 =#
    east_rank = if isnothing(i_east)
            nothing
        else
            index2rank(i_east, j, k, Rx, Ry, Rz)
        end
    #= none:395 =#
    west_rank = if isnothing(i_west)
            nothing
        else
            index2rank(i_west, j, k, Rx, Ry, Rz)
        end
    #= none:396 =#
    north_rank = if isnothing(j_north)
            nothing
        else
            index2rank(i, j_north, k, Rx, Ry, Rz)
        end
    #= none:397 =#
    south_rank = if isnothing(j_south)
            nothing
        else
            index2rank(i, j_south, k, Rx, Ry, Rz)
        end
    #= none:399 =#
    northeast_rank = if isnothing(i_east) || isnothing(j_north)
            nothing
        else
            index2rank(i_east, j_north, k, Rx, Ry, Rz)
        end
    #= none:400 =#
    northwest_rank = if isnothing(i_west) || isnothing(j_north)
            nothing
        else
            index2rank(i_west, j_north, k, Rx, Ry, Rz)
        end
    #= none:401 =#
    southeast_rank = if isnothing(i_east) || isnothing(j_south)
            nothing
        else
            index2rank(i_east, j_south, k, Rx, Ry, Rz)
        end
    #= none:402 =#
    southwest_rank = if isnothing(i_west) || isnothing(j_south)
            nothing
        else
            index2rank(i_west, j_south, k, Rx, Ry, Rz)
        end
    #= none:404 =#
    return RankConnectivity(west = west_rank, east = east_rank, south = south_rank, north = north_rank, southwest = southwest_rank, southeast = southeast_rank, northwest = northwest_rank, northeast = northeast_rank)
end
#= none:416 =#
function Base.summary(arch::Distributed)
    #= none:416 =#
    #= none:417 =#
    child_arch = child_architecture(arch)
    #= none:418 =#
    A = typeof(child_arch)
    #= none:419 =#
    return string("Distributed{$(A)}")
end
#= none:422 =#
function Base.show(io::IO, arch::Distributed)
    #= none:422 =#
    #= none:424 =#
    (Rx, Ry, Rz) = arch.ranks
    #= none:425 =#
    local_rank = arch.local_rank
    #= none:426 =#
    Nr = prod(arch.ranks)
    #= none:427 =#
    last_rank = Nr - 1
    #= none:429 =#
    rank_info = if last_rank == 0
            #= none:430 =#
            "1 rank:"
        else
            #= none:432 =#
            "$(Nr) = $(Rx)×$(Ry)×$(Rz) ranks:"
        end
    #= none:435 =#
    print(io, summary(arch), " across ", rank_info, '\n')
    #= none:436 =#
    print(io, "├── local_rank: ", local_rank, " of 0-$(last_rank)", '\n')
    #= none:438 =#
    (ix, iy, iz) = arch.local_index
    #= none:439 =#
    index_info = string("index [$(ix), $(iy), $(iz)]")
    #= none:441 =#
    c = arch.connectivity
    #= none:442 =#
    connectivity_info = if c isa NoConnectivity
            #= none:443 =#
            nothing
        else
            #= none:445 =#
            string("└── connectivity:", if isnothing(c.east)
                    ""
                else
                    " east=$(c.east)"
                end, if isnothing(c.west)
                    ""
                else
                    " west=$(c.west)"
                end, if isnothing(c.north)
                    ""
                else
                    " north=$(c.north)"
                end, if isnothing(c.south)
                    ""
                else
                    " south=$(c.south)"
                end, if isnothing(c.southwest)
                    ""
                else
                    " southwest=$(c.southwest)"
                end, if isnothing(c.southeast)
                    ""
                else
                    " southeast=$(c.southeast)"
                end, if isnothing(c.northwest)
                    ""
                else
                    " northwest=$(c.northwest)"
                end, if isnothing(c.northeast)
                    ""
                else
                    " northeast=$(c.northeast)"
                end)
        end
    #= none:456 =#
    if isnothing(connectivity_info)
        #= none:457 =#
        print(io, "└── local_index: [$(ix), $(iy), $(iz)]")
    else
        #= none:459 =#
        print(io, "├── local_index: [$(ix), $(iy), $(iz)]", '\n')
        #= none:460 =#
        print(io, connectivity_info)
    end
end