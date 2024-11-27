
#= none:1 =#
using Oceananigans.Grids: metrics_precomputed, on_architecture, pop_flat_elements, grid_name
#= none:2 =#
using Oceananigans.ImmersedBoundaries: GridFittedBottom, PartialCellBottom, GridFittedBoundary
#= none:4 =#
import Oceananigans.Grids: architecture, size, new_data, halo_size
#= none:5 =#
import Oceananigans.Grids: with_halo, on_architecture
#= none:6 =#
import Oceananigans.Models.HydrostaticFreeSurfaceModels: default_free_surface
#= none:7 =#
import Oceananigans.DistributedComputations: reconstruct_global_grid
#= none:8 =#
import Oceananigans.Grids: minimum_spacing, destantiate
#= none:10 =#
struct MultiRegionGrid{FT, TX, TY, TZ, P, C, G, D, Arch} <: AbstractMultiRegionGrid{FT, TX, TY, TZ, Arch}
    #= none:11 =#
    architecture::Arch
    #= none:12 =#
    partition::P
    #= none:13 =#
    connectivity::C
    #= none:14 =#
    region_grids::G
    #= none:15 =#
    devices::D
    #= none:17 =#
    (MultiRegionGrid{FT, TX, TY, TZ}(arch::A, partition::P, connectivity::C, region_grids::G, devices::D) where {FT, TX, TY, TZ, P, C, G, D, A}) = begin
            #= none:17 =#
            new{FT, TX, TY, TZ, P, C, G, D, A}(arch, partition, connectivity, region_grids, devices)
        end
end
#= none:22 =#
const ImmersedMultiRegionGrid = ImmersedBoundaryGrid{<:Any, <:Any, <:Any, <:Any, <:MultiRegionGrid}
#= none:24 =#
const MultiRegionGrids = Union{MultiRegionGrid, ImmersedMultiRegionGrid}
#= none:26 =#
#= none:26 =# @inline isregional(mrg::MultiRegionGrids) = begin
            #= none:26 =#
            true
        end
#= none:27 =#
#= none:27 =# @inline getdevice(mrg::MultiRegionGrid, i) = begin
            #= none:27 =#
            getdevice(mrg.region_grids, i)
        end
#= none:28 =#
#= none:28 =# @inline switch_device!(mrg::MultiRegionGrid, i) = begin
            #= none:28 =#
            switch_device!(getdevice(mrg, i))
        end
#= none:29 =#
#= none:29 =# @inline devices(mrg::MultiRegionGrid) = begin
            #= none:29 =#
            devices(mrg.region_grids)
        end
#= none:30 =#
#= none:30 =# @inline sync_all_devices!(mrg::MultiRegionGrid) = begin
            #= none:30 =#
            sync_all_devices!(devices(mrg))
        end
#= none:32 =#
#= none:32 =# @inline getregion(mrg::MultiRegionGrid, r) = begin
            #= none:32 =#
            _getregion(mrg.region_grids, r)
        end
#= none:33 =#
#= none:33 =# @inline _getregion(mrg::MultiRegionGrid, r) = begin
            #= none:33 =#
            getregion(mrg.region_grids, r)
        end
#= none:36 =#
#= none:36 =# @inline Base.getindex(mrg::MultiRegionGrids, r::Int) = begin
            #= none:36 =#
            getregion(mrg, r)
        end
#= none:37 =#
#= none:37 =# @inline Base.first(mrg::MultiRegionGrids) = begin
            #= none:37 =#
            mrg[1]
        end
#= none:38 =#
#= none:38 =# @inline Base.lastindex(mrg::MultiRegionGrids) = begin
            #= none:38 =#
            length(mrg)
        end
#= none:39 =#
number_of_regions(mrg::MultiRegionGrids) = begin
        #= none:39 =#
        lastindex(mrg)
    end
#= none:41 =#
minimum_spacing(dir, grid::MultiRegionGrid, ℓx, ℓy, ℓz) = begin
        #= none:41 =#
        minimum((minimum_spacing(dir, grid[r], ℓx, ℓy, ℓz) for r = 1:number_of_regions(grid)))
    end
#= none:44 =#
#= none:44 =# @inline getdevice(mrg::ImmersedMultiRegionGrid, i) = begin
            #= none:44 =#
            getdevice(mrg.underlying_grid.region_grids, i)
        end
#= none:45 =#
#= none:45 =# @inline switch_device!(mrg::ImmersedMultiRegionGrid, i) = begin
            #= none:45 =#
            switch_device!(getdevice(mrg.underlying_grid, i))
        end
#= none:46 =#
#= none:46 =# @inline devices(mrg::ImmersedMultiRegionGrid) = begin
            #= none:46 =#
            devices(mrg.underlying_grid.region_grids)
        end
#= none:47 =#
#= none:47 =# @inline sync_all_devices!(mrg::ImmersedMultiRegionGrid) = begin
            #= none:47 =#
            sync_all_devices!(devices(mrg.underlying_grid))
        end
#= none:49 =#
#= none:49 =# @inline Base.length(mrg::MultiRegionGrid) = begin
            #= none:49 =#
            Base.length(mrg.region_grids)
        end
#= none:50 =#
#= none:50 =# @inline Base.length(mrg::ImmersedMultiRegionGrid) = begin
            #= none:50 =#
            Base.length(mrg.underlying_grid.region_grids)
        end
#= none:53 =#
default_free_surface(grid::MultiRegionGrid; gravitational_acceleration = g_Earth) = begin
        #= none:53 =#
        SplitExplicitFreeSurface(; substeps = 50, gravitational_acceleration)
    end
#= none:56 =#
#= none:56 =# Core.@doc "    MultiRegionGrid(global_grid; partition = XPartition(2),\n                                 devices = nothing,\n                                 validate = true)\n\nSplit a `global_grid` into different regions handled by `devices`.\n\nPositional Arguments\n====================\n\n- `global_grid`: the grid to be divided into regions.\n\nKeyword Arguments\n=================\n\n- `partition`: the partitioning required. The implemented partitioning are `XPartition` \n               (division along the ``x`` direction) and `YPartition` (division along\n               the ``y`` direction).\n\n- `devices`: the devices to allocate memory on. If `nothing` is provided (default) then memorey is\n             allocated on the the `CPU`. For `GPU` computation it is possible to specify the total\n             number of GPUs or the specific GPUs to allocate memory on. The number of devices does\n             not need to match the number of regions.\n\n- `validate :: Boolean`: Whether to validate `devices`; defautl: `true`.\n\nExample\n=======\n\n```jldoctest; filter = r\".*@ Oceananigans.MultiRegion.*\"\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=(12, 12), extent=(1, 1), topology=(Bounded, Bounded, Flat))\n12×12×1 RectilinearGrid{Float64, Bounded, Bounded, Flat} on CPU with 3×3×0 halo\n├── Bounded  x ∈ [0.0, 1.0] regularly spaced with Δx=0.0833333\n├── Bounded  y ∈ [0.0, 1.0] regularly spaced with Δy=0.0833333\n└── Flat z\n\njulia> multi_region_grid = MultiRegionGrid(grid, partition = XPartition(4))\n┌ Warning: MultiRegion functionalities are experimental: help the development by reporting bugs or non-implemented features!\n└ @ Oceananigans.MultiRegion ~/Research/OC11.jl/src/MultiRegion/multi_region_grid.jl:108\nMultiRegionGrid{Float64, Bounded, Bounded, Flat} partitioned on CPU():\n├── grids: 3×12×1 RectilinearGrid{Float64, RightConnected, Bounded, Flat} on CPU with 3×3×0 halo\n├── partitioning: Equal partitioning in X with (4 regions)\n├── connectivity: MultiRegionObject{Tuple{@NamedTuple{west::Nothing, east::Oceananigans.MultiRegion.RegionalConnectivity{Oceananigans.MultiRegion.East, Oceananigans.MultiRegion.West}, north::Nothing, south::Nothing}, @NamedTuple{west::Oceananigans.MultiRegion.RegionalConnectivity{Oceananigans.MultiRegion.West, Oceananigans.MultiRegion.East}, east::Oceananigans.MultiRegion.RegionalConnectivity{Oceananigans.MultiRegion.East, Oceananigans.MultiRegion.West}, north::Nothing, south::Nothing}, @NamedTuple{west::Oceananigans.MultiRegion.RegionalConnectivity{Oceananigans.MultiRegion.West, Oceananigans.MultiRegion.East}, east::Oceananigans.MultiRegion.RegionalConnectivity{Oceananigans.MultiRegion.East, Oceananigans.MultiRegion.West}, north::Nothing, south::Nothing}, @NamedTuple{west::Oceananigans.MultiRegion.RegionalConnectivity{Oceananigans.MultiRegion.West, Oceananigans.MultiRegion.East}, east::Nothing, north::Nothing, south::Nothing}}, NTuple{4, CPU}}\n└── devices: (CPU(), CPU(), CPU(), CPU())\n```\n" function MultiRegionGrid(global_grid; partition = XPartition(2), devices = nothing, validate = true)
        #= none:104 =#
        #= none:108 =#
        #= none:108 =# @warn "MultiRegion functionalities are experimental: help the development by reporting bugs or non-implemented features!"
        #= none:110 =#
        if length(partition) == 1
            #= none:111 =#
            return global_grid
        end
        #= none:114 =#
        arch = architecture(global_grid)
        #= none:116 =#
        if validate
            #= none:117 =#
            devices = validate_devices(partition, arch, devices)
            #= none:118 =#
            devices = assign_devices(partition, devices)
        end
        #= none:121 =#
        connectivity = Connectivity(devices, partition, global_grid)
        #= none:123 =#
        global_grid = on_architecture(CPU(), global_grid)
        #= none:124 =#
        local_size = MultiRegionObject(partition_size(partition, global_grid), devices)
        #= none:125 =#
        local_extent = MultiRegionObject(partition_extent(partition, global_grid), devices)
        #= none:126 =#
        local_topo = MultiRegionObject(partition_topology(partition, global_grid), devices)
        #= none:128 =#
        global_topo = topology(global_grid)
        #= none:130 =#
        FT = eltype(global_grid)
        #= none:132 =#
        args = (Reference(global_grid), Reference(arch), local_topo, local_size, local_extent, Reference(partition), Iterate(1:length(partition)))
        #= none:140 =#
        region_grids = construct_regionally(construct_grid, args...)
        #= none:143 =#
        maybe_enable_peer_access!(devices)
        #= none:145 =#
        return MultiRegionGrid{FT, global_topo[1], global_topo[2], global_topo[3]}(arch, partition, connectivity, region_grids, devices)
    end
#= none:148 =#
function construct_grid(grid::RectilinearGrid, child_arch, topo, size, extent, args...)
    #= none:148 =#
    #= none:149 =#
    halo = halo_size(grid)
    #= none:150 =#
    size = pop_flat_elements(size, topo)
    #= none:151 =#
    halo = pop_flat_elements(halo, topo)
    #= none:152 =#
    FT = eltype(grid)
    #= none:154 =#
    return RectilinearGrid(child_arch, FT; size = size, halo = halo, topology = topo, extent...)
end
#= none:157 =#
function construct_grid(grid::LatitudeLongitudeGrid, child_arch, topo, size, extent, args...)
    #= none:157 =#
    #= none:158 =#
    halo = halo_size(grid)
    #= none:159 =#
    FT = eltype(grid)
    #= none:160 =#
    (lon, lat, z) = extent
    #= none:161 =#
    return LatitudeLongitudeGrid(child_arch, FT; size = size, halo = halo, radius = grid.radius, latitude = lat, longitude = lon, z = z, topology = topo, precompute_metrics = metrics_precomputed(grid))
end
#= none:167 =#
#= none:167 =# Core.@doc "    reconstruct_global_grid(mrg::MultiRegionGrid)\n\nReconstruct the `mrg` global grid associated with the `MultiRegionGrid` on `architecture(mrg)`.\n" function reconstruct_global_grid(mrg::MultiRegionGrid)
        #= none:172 =#
        #= none:173 =#
        size = reconstruct_size(mrg, mrg.partition)
        #= none:174 =#
        extent = reconstruct_extent(mrg, mrg.partition)
        #= none:175 =#
        topo = topology(mrg)
        #= none:176 =#
        switch_device!(mrg.devices[1])
        #= none:177 =#
        return construct_grid(mrg.region_grids[1], architecture(mrg), topo, size, extent)
    end
#= none:184 =#
function reconstruct_global_grid(mrg::ImmersedMultiRegionGrid)
    #= none:184 =#
    #= none:185 =#
    global_grid = reconstruct_global_grid(mrg.underlying_grid)
    #= none:186 =#
    global_boundary = reconstruct_global_boundary(mrg.immersed_boundary)
    #= none:188 =#
    return ImmersedBoundaryGrid(global_grid, global_boundary)
end
#= none:191 =#
reconstruct_global_boundary(g::GridFittedBottom{<:Field}) = begin
        #= none:191 =#
        GridFittedBottom(reconstruct_global_field(g.bottom_height), g.immersed_condition)
    end
#= none:192 =#
reconstruct_global_boundary(g::PartialCellBottom{<:Field}) = begin
        #= none:192 =#
        PartialCellBottom(reconstruct_global_field(g.bottom_height), g.minimum_fractional_cell_height)
    end
#= none:193 =#
reconstruct_global_boundary(g::GridFittedBoundary{<:Field}) = begin
        #= none:193 =#
        GridFittedBoundary(reconstruct_global_field(g.mask))
    end
#= none:195 =#
#= none:195 =# @inline (getregion(mrg::ImmersedMultiRegionGrid{FT, TX, TY, TZ}, r) where {FT, TX, TY, TZ}) = begin
            #= none:195 =#
            ImmersedBoundaryGrid{TX, TY, TZ}(_getregion(mrg.underlying_grid, r), _getregion(mrg.immersed_boundary, r))
        end
#= none:196 =#
#= none:196 =# @inline (_getregion(mrg::ImmersedMultiRegionGrid{FT, TX, TY, TZ}, r) where {FT, TX, TY, TZ}) = begin
            #= none:196 =#
            ImmersedBoundaryGrid{TX, TY, TZ}(getregion(mrg.underlying_grid, r), getregion(mrg.immersed_boundary, r))
        end
#= none:198 =#
#= none:198 =# Core.@doc "    multi_region_object_from_array(a::AbstractArray, mrg::MultiRegionGrid)\n\nAdapt an array `a` to be compatible with a `MultiRegionGrid`.\n" function multi_region_object_from_array(a::AbstractArray, mrg::MultiRegionGrid)
        #= none:203 =#
        #= none:204 =#
        local_size = construct_regionally(size, mrg)
        #= none:205 =#
        arch = architecture(mrg)
        #= none:206 =#
        a = on_architecture(CPU(), a)
        #= none:207 =#
        ma = construct_regionally(partition, a, mrg.partition, local_size, Iterate(1:length(mrg)), arch)
        #= none:208 =#
        return ma
    end
#= none:212 =#
multi_region_object_from_array(a::AbstractArray, grid) = begin
        #= none:212 =#
        on_architecture(architecture(grid), a)
    end
#= none:218 =#
new_data(FT::DataType, mrg::MultiRegionGrids, args...) = begin
        #= none:218 =#
        construct_regionally(new_data, FT, mrg, args...)
    end
#= none:221 =#
function with_halo(new_halo, mrg::MultiRegionGrid)
    #= none:221 =#
    #= none:222 =#
    devices = mrg.devices
    #= none:223 =#
    partition = mrg.partition
    #= none:224 =#
    cpu_mrg = on_architecture(CPU(), mrg)
    #= none:226 =#
    global_grid = reconstruct_global_grid(cpu_mrg)
    #= none:227 =#
    new_global = with_halo(new_halo, global_grid)
    #= none:228 =#
    new_global = on_architecture(architecture(mrg), new_global)
    #= none:230 =#
    return MultiRegionGrid(new_global; partition, devices, validate = false)
end
#= none:233 =#
function on_architecture(::CPU, mrg::MultiRegionGrid{FT, TX, TY, TZ}) where {FT, TX, TY, TZ}
    #= none:233 =#
    #= none:234 =#
    new_grids = construct_regionally(on_architecture, CPU(), mrg)
    #= none:235 =#
    devices = Tuple((CPU() for i = 1:length(mrg)))
    #= none:236 =#
    return MultiRegionGrid{FT, TX, TY, TZ}(CPU(), mrg.partition, mrg.connectivity, new_grids, devices)
end
#= none:239 =#
(Base.summary(mrg::MultiRegionGrid{FT, TX, TY, TZ}) where {FT, TX, TY, TZ}) = begin
        #= none:239 =#
        "MultiRegionGrid{$(FT), $(TX), $(TY), $(TZ)} with $(summary(mrg.partition)) on $(string((typeof(mrg.region_grids[1])).name.wrapper))"
    end
#= none:242 =#
(Base.show(io::IO, mrg::MultiRegionGrid{FT, TX, TY, TZ}) where {FT, TX, TY, TZ}) = begin
        #= none:242 =#
        print(io, "$(grid_name(mrg)){$(FT), $(TX), $(TY), $(TZ)} partitioned on $(architecture(mrg)): \n", "├── grids: $(summary(mrg.region_grids[1])) \n", "├── partitioning: $(summary(mrg.partition)) \n", "├── connectivity: $(summary(mrg.connectivity)) \n", "└── devices: $(devices(mrg))")
    end
#= none:249 =#
function Base.:(==)(mrg₁::MultiRegionGrid, mrg₂::MultiRegionGrid)
    #= none:249 =#
    #= none:251 =#
    vals = construct_regionally(Base.:(==), mrg₁, mrg₂)
    #= none:252 =#
    return all(vals.regional_objects)
end
#= none:259 =#
size(mrg::MultiRegionGrids) = begin
        #= none:259 =#
        size(getregion(mrg, 1))
    end
#= none:260 =#
halo_size(mrg::MultiRegionGrids) = begin
        #= none:260 =#
        halo_size(getregion(mrg, 1))
    end
#= none:268 =#
grids(mrg::MultiRegionGrid) = begin
        #= none:268 =#
        mrg.region_grids
    end
#= none:270 =#
getmultiproperty(mrg::MultiRegionGrid, x::Symbol) = begin
        #= none:270 =#
        construct_regionally(Base.getproperty, grids(mrg), x)
    end
#= none:272 =#
const MRG = MultiRegionGrid
#= none:274 =#
#= none:274 =# @inline Base.getproperty(mrg::MRG, property::Symbol) = begin
            #= none:274 =#
            get_multi_property(mrg, Val(property))
        end
#= none:275 =#
#= none:275 =# @inline (get_multi_property(mrg::MRG, ::Val{property}) where property) = begin
            #= none:275 =#
            getproperty(getindex(getfield(mrg, :region_grids), 1), property)
        end
#= none:276 =#
#= none:276 =# @inline get_multi_property(mrg::MRG, ::Val{:architecture}) = begin
            #= none:276 =#
            getfield(mrg, :architecture)
        end
#= none:277 =#
#= none:277 =# @inline get_multi_property(mrg::MRG, ::Val{:partition}) = begin
            #= none:277 =#
            getfield(mrg, :partition)
        end
#= none:278 =#
#= none:278 =# @inline get_multi_property(mrg::MRG, ::Val{:connectivity}) = begin
            #= none:278 =#
            getfield(mrg, :connectivity)
        end
#= none:279 =#
#= none:279 =# @inline get_multi_property(mrg::MRG, ::Val{:region_grids}) = begin
            #= none:279 =#
            getfield(mrg, :region_grids)
        end
#= none:280 =#
#= none:280 =# @inline get_multi_property(mrg::MRG, ::Val{:devices}) = begin
            #= none:280 =#
            getfield(mrg, :devices)
        end