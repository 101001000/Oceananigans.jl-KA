
#= none:1 =#
using Oceananigans.Architectures: architecture
#= none:2 =#
using Oceananigans.Grids: conformal_cubed_sphere_panel, R_Earth, halo_size, size_summary, total_length, topology
#= none:9 =#
using CubedSphere
#= none:10 =#
using Distances
#= none:12 =#
import Oceananigans.Grids: grid_name
#= none:14 =#
const ConformalCubedSphereGrid{FT, TX, TY, TZ} = MultiRegionGrid{FT, TX, TY, TZ, <:CubedSpherePartition}
#= none:16 =#
#= none:16 =# Core.@doc "    ConformalCubedSphereGrid(arch=CPU(), FT=Float64;\n                             panel_size,\n                             z,\n                             horizontal_direction_halo = 1,\n                             z_halo = horizontal_direction_halo,\n                             horizontal_topology = FullyConnected,\n                             z_topology = Bounded,\n                             radius = R_Earth,\n                             partition = CubedSpherePartition(; R = 1),\n                             devices = nothing)\n\nReturn a `ConformalCubedSphereGrid` that comprises of six [`conformal_cubed_sphere_panel`](@ref)\ngrids; we refer to each of these grids as a \"panel\". Each panel corresponds to a face of the cube.\n\nThe keyword arguments prescribe the properties of each of the panels. Only the topology in\nthe vertical direction can be prescribed and that's done via the `z_topology` keyword\nargumet (default: `Bounded`). Topologies in both horizontal directions for a `ConformalCubedSphereGrid`\nare _always_ [`FullyConnected`](@ref).\n\nHalo size in both horizontal dimensions _must_ be equal; this is prescribed via the\n`horizontal_halo :: Integer` keyword argument. The number of halo points in the ``z``-direction\nis prescribed by the `z_halo :: Integer` keyword argument.\n\nThe connectivity between the `ConformalCubedSphereGrid` panels is depicted below.\n\n```\n                          +==========+==========+\n                          ∥    ↑     ∥    ↑     ∥\n                          ∥    1W    ∥    1S    ∥\n                          ∥←3N P5 6W→∥←5E P6 2S→∥\n                          ∥    4N    ∥    4E    ∥\n                          ∥    ↓     ∥    ↓     ∥\n               +==========+==========+==========+\n               ∥    ↑     ∥    ↑     ∥\n               ∥    5W    ∥    5S    ∥\n               ∥←1N P3 4W→∥←3E P4 6S→∥\n               ∥    2N    ∥    2E    ∥\n               ∥    ↓     ∥    ↓     ∥\n    +==========+==========+==========+\n    ∥    ↑     ∥    ↑     ∥\n    ∥    3W    ∥    3S    ∥\n    ∥←5N P1 2W→∥←1E P2 4S→∥\n    ∥    6N    ∥    6E    ∥\n    ∥    ↓     ∥    ↓     ∥\n    +==========+==========+\n```\n\nThe North Pole of the sphere lies in the center of panel 3 (P3) and the South Pole\nin the center of panel 6 (P6).\n\nThe `partition` keyword argument prescribes the partitioning in regions within each \npanel; see [`CubedSpherePartition`](@ref). For example, a `CubedSpherePartition(; R=2)`\nimplies that each of the panels are partitioned into 2 regions in each dimension;\nthis adds up, e.g., to 24 regions for the  whole sphere. In the depiction below,\nthe intra-panel `x, y` indices are depicted in the center of each region and the overall\nregion index is shown at the bottom right of each region.\n\n```\n                                                +==========+==========+==========+==========+\n                                                ∥    ↑     |    ↑     ∥    ↑     |    ↑     ∥\n                                                ∥          |          ∥          |          ∥\n                                                ∥← (1, 2) →|← (2, 2) →∥← (1, 2) →|← (2, 2) →∥\n                                                ∥          |          ∥          |          ∥\n                                                ∥    ↓  19 |    ↓  20 ∥    ↓  23 |    ↓  24 ∥\n                                                +-------- P 5 --------+-------- P 6 --------+\n                                                ∥    ↑     |    ↑     ∥    ↑     |    ↑     ∥\n                                                ∥          |          ∥          |          ∥\n                                                ∥← (1, 1) →|← (2, 1) →∥← (1, 1) →|← (2, 1) →∥\n                                                ∥          |          ∥          |          ∥\n                                                ∥    ↓  17 |    ↓  18 ∥    ↓  21 |    ↓  22 ∥\n                          +==========+==========+==========+==========+==========+==========+\n                          ∥    ↑     |    ↑     ∥    ↑     |    ↑     ∥\n                          ∥          |          ∥          |          ∥\n                          ∥← (1, 2) →|← (2, 2) →∥← (1, 2) →|← (2, 2) →∥\n                          ∥          |          ∥          |          ∥\n                          ∥    ↓ 11  |    ↓  12 ∥    ↓  15 |    ↓  16 ∥\n                          +-------- P 3 --------+-------- P 4 --------+\n                          ∥    ↑     |    ↑     ∥    ↑     |    ↑     ∥\n                          ∥          |          ∥          |          ∥\n                          ∥← (1, 1) →|← (2, 1) →∥← (1, 1) →|← (2, 1) →∥\n                          ∥          |          ∥          |          ∥\n                          ∥    ↓  9  |    ↓  10 ∥    ↓  13 |    ↓  14 ∥\n    +==========+==========+==========+==========+==========+==========+\n    ∥    ↑     |    ↑     ∥    ↑     |    ↑     ∥\n    ∥          |          ∥          |          ∥\n    ∥← (1, 2) →|← (2, 2) →∥← (1, 2) →|← (2, 2) →∥\n    ∥          |          ∥          |          ∥\n    ∥    ↓   3 |    ↓   4 ∥    ↓   7 |    ↓   8 ∥\n    +-------- P 1 --------+-------- P 2 --------+\n    ∥    ↑     |    ↑     ∥    ↑     |    ↑     ∥\n    ∥          |          ∥          |          ∥\n    ∥← (1, 1) →|← (2, 1) →∥← (1, 1) →|← (2, 1) →∥\n    ∥          |          ∥          |          ∥\n    ∥    ↓   1 |    ↓   2 ∥    ↓   5 |    ↓   6 ∥\n    +==========+==========+==========+==========+\n```\n\nBelow, we show in detail panels 1 and 2 and the connectivity\nof each panel.\n\n```\n+===============+==============+==============+===============+\n∥       ↑       |      ↑       ∥      ↑       |      ↑        ∥\n∥      11W      |      9W      ∥      9S      |     10S       ∥\n∥←19N (2, 1) 4W→|←3E (2, 2) 7W→∥←4E (2, 1) 8W→|←7E (2, 2) 13S→∥\n∥       1N      |      2N      ∥      5N      |      6N       ∥\n∥       ↓     3 |      ↓     4 ∥      ↓     7 |      ↓      8 ∥\n+------------- P 1 ------------+------------ P 2 -------------+\n∥       ↑       |      ↑       ∥      ↑       |      ↑        ∥\n∥       3S      |      4S      ∥      7S      |      8S       ∥\n∥←20N (1, 1) 2W→|←1E (2, 1) 5W→∥←2E (1, 1) 6W→|←5E (2, 1) 14S→∥\n∥      23N      |     24N      ∥     24N      |     22N       ∥\n∥       ↓     1 |      ↓     2 ∥      ↓     5 |      ↓      6 ∥\n+===============+==============+==============+===============+\n```\n\nExample\n=======\n\n```jldoctest cubedspheregrid\njulia> using Oceananigans\n\njulia> grid = ConformalCubedSphereGrid(panel_size=(12, 12, 1), z=(-1, 0), radius=1)\nConformalCubedSphereGrid{Float64, FullyConnected, FullyConnected, Bounded} partitioned on CPU(): \n├── grids: 12×12×1 OrthogonalSphericalShellGrid{Float64, FullyConnected, FullyConnected, Bounded} on CPU with 3×3×3 halo and with precomputed metrics \n├── partitioning: CubedSpherePartition with (1 region in each panel) \n├── connectivity: CubedSphereConnectivity \n└── devices: (CPU(), CPU(), CPU(), CPU(), CPU(), CPU())\n```\n\nThe connectivities of the regions of our grid are stored in `grid.connectivity`.\nFor example, to find out all connectivites on the South boundary of each region we call\n\n```jldoctest cubedspheregrid\njulia> using Oceananigans.MultiRegion: East, North, West, South\n\njulia> for region in 1:length(grid); println(grid.connectivity.connections[region].south); end\nCubedSphereRegionalConnectivity\n├── from: Oceananigans.MultiRegion.North side, region 6\n├── to:   Oceananigans.MultiRegion.South side, region 1\n└── no rotation\nCubedSphereRegionalConnectivity\n├── from: Oceananigans.MultiRegion.East side, region 6\n├── to:   Oceananigans.MultiRegion.South side, region 2\n└── counter-clockwise rotation ↺\nCubedSphereRegionalConnectivity\n├── from: Oceananigans.MultiRegion.North side, region 2\n├── to:   Oceananigans.MultiRegion.South side, region 3\n└── no rotation\nCubedSphereRegionalConnectivity\n├── from: Oceananigans.MultiRegion.East side, region 2\n├── to:   Oceananigans.MultiRegion.South side, region 4\n└── counter-clockwise rotation ↺\nCubedSphereRegionalConnectivity\n├── from: Oceananigans.MultiRegion.North side, region 4\n├── to:   Oceananigans.MultiRegion.South side, region 5\n└── no rotation\nCubedSphereRegionalConnectivity\n├── from: Oceananigans.MultiRegion.East side, region 4\n├── to:   Oceananigans.MultiRegion.South side, region 6\n└── counter-clockwise rotation ↺\n```\n" function ConformalCubedSphereGrid(arch::AbstractArchitecture = CPU(), FT = Float64; panel_size, z, horizontal_direction_halo = 3, z_halo = horizontal_direction_halo, horizontal_topology = FullyConnected, z_topology = Bounded, radius = R_Earth, partition = CubedSpherePartition(; R = 1), devices = nothing)
        #= none:180 =#
        #= none:191 =#
        (Nx, Ny, _) = panel_size
        #= none:192 =#
        region_topology = (horizontal_topology, horizontal_topology, z_topology)
        #= none:193 =#
        region_halo = (horizontal_direction_halo, horizontal_direction_halo, z_halo)
        #= none:195 =#
        Nx !== Ny && error("Horizontal sizes for ConformalCubedSphereGrid must be equal; Nx=Ny.")
        #= none:198 =#
        devices = validate_devices(partition, CPU(), devices)
        #= none:199 =#
        devices = assign_devices(partition, devices)
        #= none:201 =#
        connectivity = CubedSphereConnectivity(devices, partition)
        #= none:203 =#
        region_size = []
        #= none:204 =#
        region_η = []
        #= none:205 =#
        region_ξ = []
        #= none:206 =#
        region_rotation = []
        #= none:208 =#
        for r = 1:length(partition)
            #= none:209 =#
            (Lξ_total, Lη_total) = (2, 2)
            #= none:210 =#
            Lξᵢⱼ = Lξ_total / Rx(r, partition)
            #= none:211 =#
            Lηᵢⱼ = Lη_total / Ry(r, partition)
            #= none:213 =#
            pᵢ = intra_panel_index_x(r, partition)
            #= none:214 =#
            pⱼ = intra_panel_index_y(r, partition)
            #= none:216 =#
            push!(region_size, (panel_size[1] ÷ Rx(r, partition), panel_size[2] ÷ Ry(r, partition), panel_size[3]))
            #= none:217 =#
            push!(region_ξ, (-1 + Lξᵢⱼ * (pᵢ - 1), -1 + Lξᵢⱼ * pᵢ))
            #= none:218 =#
            push!(region_η, (-1 + Lηᵢⱼ * (pⱼ - 1), -1 + Lηᵢⱼ * pⱼ))
            #= none:219 =#
            push!(region_rotation, connectivity.rotations[panel_index(r, partition)])
            #= none:220 =#
        end
        #= none:222 =#
        region_size = MultiRegionObject(tuple(region_size...), devices)
        #= none:223 =#
        region_ξ = Iterate(region_ξ)
        #= none:224 =#
        region_η = Iterate(region_η)
        #= none:225 =#
        region_rotation = Iterate(region_rotation)
        #= none:228 =#
        region_grids = construct_regionally(conformal_cubed_sphere_panel, CPU(), FT; size = region_size, z, halo = region_halo, topology = region_topology, radius, ξ = region_ξ, η = region_η, rotation = region_rotation)
        #= none:238 =#
        grid = MultiRegionGrid{FT, region_topology...}(CPU(), partition, connectivity, region_grids, devices)
        #= none:244 =#
        λᶜᶜᵃ = Field((Center, Center, Nothing), grid)
        #= none:245 =#
        φᶜᶜᵃ = Field((Center, Center, Nothing), grid)
        #= none:246 =#
        Azᶜᶜᵃ = Field((Center, Center, Nothing), grid)
        #= none:247 =#
        λᶠᶠᵃ = Field((Face, Face, Nothing), grid)
        #= none:248 =#
        φᶠᶠᵃ = Field((Face, Face, Nothing), grid)
        #= none:249 =#
        Azᶠᶠᵃ = Field((Face, Face, Nothing), grid)
        #= none:251 =#
        for (field, name) = zip((λᶜᶜᵃ, φᶜᶜᵃ, Azᶜᶜᵃ, λᶠᶠᵃ, φᶠᶠᵃ, Azᶠᶠᵃ), (:λᶜᶜᵃ, :φᶜᶜᵃ, :Azᶜᶜᵃ, :λᶠᶠᵃ, :φᶠᶠᵃ, :Azᶠᶠᵃ))
            #= none:254 =#
            for region = 1:number_of_regions(grid)
                #= none:255 =#
                (getregion(field, region)).data .= getproperty(getregion(grid, region), name)
                #= none:256 =#
            end
            #= none:258 =#
            if horizontal_topology == FullyConnected
                #= none:259 =#
                fill_halo_regions!(field)
            end
            #= none:262 =#
            for region = 1:number_of_regions(grid)
                #= none:263 =#
                getproperty(getregion(grid, region), name) .= (getregion(field, region)).data
                #= none:264 =#
            end
            #= none:265 =#
        end
        #= none:267 =#
        Δxᶜᶜᵃ = Field((Center, Center, Nothing), grid)
        #= none:268 =#
        Δxᶠᶜᵃ = Field((Face, Center, Nothing), grid)
        #= none:269 =#
        Δyᶠᶜᵃ = Field((Face, Center, Nothing), grid)
        #= none:270 =#
        λᶠᶜᵃ = Field((Face, Center, Nothing), grid)
        #= none:271 =#
        φᶠᶜᵃ = Field((Face, Center, Nothing), grid)
        #= none:272 =#
        Azᶠᶜᵃ = Field((Face, Center, Nothing), grid)
        #= none:273 =#
        Δxᶠᶠᵃ = Field((Face, Face, Nothing), grid)
        #= none:275 =#
        fields₁ = (Δxᶜᶜᵃ, Δxᶠᶜᵃ, Δyᶠᶜᵃ, λᶠᶜᵃ, φᶠᶜᵃ, Azᶠᶜᵃ, Δxᶠᶠᵃ)
        #= none:276 =#
        names₁ = (:Δxᶜᶜᵃ, :Δxᶠᶜᵃ, :Δyᶠᶜᵃ, :λᶠᶜᵃ, :φᶠᶜᵃ, :Azᶠᶜᵃ, :Δxᶠᶠᵃ)
        #= none:278 =#
        Δyᶜᶜᵃ = Field((Center, Center, Nothing), grid)
        #= none:279 =#
        Δyᶜᶠᵃ = Field((Center, Face, Nothing), grid)
        #= none:280 =#
        Δxᶜᶠᵃ = Field((Center, Face, Nothing), grid)
        #= none:281 =#
        λᶜᶠᵃ = Field((Center, Face, Nothing), grid)
        #= none:282 =#
        φᶜᶠᵃ = Field((Center, Face, Nothing), grid)
        #= none:283 =#
        Azᶜᶠᵃ = Field((Center, Face, Nothing), grid)
        #= none:284 =#
        Δyᶠᶠᵃ = Field((Face, Face, Nothing), grid)
        #= none:286 =#
        fields₂ = (Δyᶜᶜᵃ, Δyᶜᶠᵃ, Δxᶜᶠᵃ, λᶜᶠᵃ, φᶜᶠᵃ, Azᶜᶠᵃ, Δyᶠᶠᵃ)
        #= none:287 =#
        names₂ = (:Δyᶜᶜᵃ, :Δyᶜᶠᵃ, :Δxᶜᶠᵃ, :λᶜᶠᵃ, :φᶜᶠᵃ, :Azᶜᶠᵃ, :Δyᶠᶠᵃ)
        #= none:289 =#
        for (field₁, field₂, name₁, name₂) = zip(fields₁, fields₂, names₁, names₂)
            #= none:290 =#
            for region = 1:number_of_regions(grid)
                #= none:291 =#
                (getregion(field₁, region)).data .= getproperty(getregion(grid, region), name₁)
                #= none:292 =#
                (getregion(field₂, region)).data .= getproperty(getregion(grid, region), name₂)
                #= none:293 =#
            end
            #= none:295 =#
            if horizontal_topology == FullyConnected
                #= none:296 =#
                fill_halo_regions!(field₁, field₂; signed = false)
            end
            #= none:299 =#
            for region = 1:number_of_regions(grid)
                #= none:300 =#
                getproperty(getregion(grid, region), name₁) .= (getregion(field₁, region)).data
                #= none:301 =#
                getproperty(getregion(grid, region), name₂) .= (getregion(field₂, region)).data
                #= none:302 =#
            end
            #= none:303 =#
        end
        #= none:310 =#
        number_of_regions(grid) !== 6 && error("requires cubed sphere grids with 1 region per panel")
        #= none:312 =#
        for region = 1:number_of_regions(grid)
            #= none:313 =#
            if isodd(region)
                #= none:316 =#
                (φc, λc) = cartesian_to_lat_lon(conformal_cubed_sphere_mapping(1, -1)...)
                #= none:317 =#
                (getregion(grid, region)).φᶠᶠᵃ[1, Ny + 1] = φc
                #= none:318 =#
                (getregion(grid, region)).λᶠᶠᵃ[1, Ny + 1] = λc
            elseif #= none:319 =# iseven(region)
                #= none:322 =#
                (φc, λc) = -1 .* cartesian_to_lat_lon(conformal_cubed_sphere_mapping(-1, -1)...)
                #= none:323 =#
                (getregion(grid, region)).φᶠᶠᵃ[Nx + 1, 1] = φc
                #= none:324 =#
                (getregion(grid, region)).λᶠᶠᵃ[Nx + 1, 1] = λc
            end
            #= none:327 =#
            (getregion(grid, region)).λᶜᶜᵃ[(getregion(grid, region)).λᶜᶜᵃ .== -180] .= 180
            #= none:328 =#
            (getregion(grid, region)).λᶠᶜᵃ[(getregion(grid, region)).λᶠᶜᵃ .== -180] .= 180
            #= none:329 =#
            (getregion(grid, region)).λᶜᶠᵃ[(getregion(grid, region)).λᶜᶠᵃ .== -180] .= 180
            #= none:330 =#
            (getregion(grid, region)).λᶠᶠᵃ[(getregion(grid, region)).λᶠᶠᵃ .== -180] .= 180
            #= none:331 =#
        end
        #= none:337 =#
        region_grids = grid.region_grids
        #= none:338 =#
        #= none:338 =# @apply_regionally new_region_grids = on_architecture(arch, region_grids)
        #= none:340 =#
        new_devices = if arch == CPU()
                Tuple((CPU() for _ = 1:length(partition)))
            else
                Tuple((KAUtils.device() for _ = 1:length(partition)))
            end
        #= none:342 =#
        new_region_grids = MultiRegionObject(new_region_grids.regional_objects, new_devices)
        #= none:344 =#
        new_grid = MultiRegionGrid{FT, region_topology...}(arch, partition, connectivity, new_region_grids, new_devices)
        #= none:350 =#
        return new_grid
    end
#= none:353 =#
#= none:353 =# Core.@doc "    ConformalCubedSphereGrid(filepath::AbstractString, arch::AbstractArchitecture=CPU(), FT=Float64;\n                             Nz,\n                             z,\n                             panel_halo = (4, 4, 4),\n                             panel_topology = (FullyConnected, FullyConnected, Bounded),\n                             radius = R_Earth,\n                             devices = nothing)\n\nLoad a `ConformalCubedSphereGrid` from `filepath`.\n" function ConformalCubedSphereGrid(filepath::AbstractString, arch::AbstractArchitecture = CPU(), FT = Float64; Nz, z, panel_halo = (4, 4, 4), panel_topology = (FullyConnected, FullyConnected, Bounded), radius = R_Earth, devices = nothing)
        #= none:364 =#
        #= none:373 =#
        partition = CubedSpherePartition(R = 1)
        #= none:375 =#
        devices = validate_devices(partition, arch, devices)
        #= none:376 =#
        devices = assign_devices(partition, devices)
        #= none:378 =#
        region_Nz = MultiRegionObject(Tuple(repeat([Nz], length(partition))), devices)
        #= none:379 =#
        region_panels = Iterate(Array(1:length(partition)))
        #= none:381 =#
        region_grids = construct_regionally(conformal_cubed_sphere_panel, filepath, arch, FT; Nz = region_Nz, z, panel = region_panels, topology = panel_topology, halo = panel_halo, radius)
        #= none:389 =#
        connectivity = CubedSphereConnectivity(devices, partition)
        #= none:391 =#
        return MultiRegionGrid{FT, panel_topology...}(arch, partition, connectivity, region_grids, devices)
    end
#= none:394 =#
function with_halo(new_halo, csg::ConformalCubedSphereGrid)
    #= none:394 =#
    #= none:395 =#
    region_rotation = []
    #= none:397 =#
    for region = 1:length(csg.partition)
        #= none:398 =#
        push!(region_rotation, (csg[region]).conformal_mapping.rotation)
        #= none:399 =#
    end
    #= none:401 =#
    apply_regionally!(with_halo, new_halo, csg; rotation = Iterate(region_rotation))
    #= none:403 =#
    return csg
end
#= none:406 =#
function Base.summary(grid::ConformalCubedSphereGrid{FT, TX, TY, TZ}) where {FT, TX, TY, TZ}
    #= none:406 =#
    #= none:407 =#
    return string(size_summary(size(grid)), " ConformalCubedSphereGrid{$(FT), $(TX), $(TY), $(TZ)} on ", summary(architecture(grid)), " with ", size_summary(halo_size(grid)), " halo")
end
#= none:412 =#
radius(mrg::ConformalCubedSphereGrid) = begin
        #= none:412 =#
        (first(mrg)).radius
    end
#= none:414 =#
grid_name(mrg::ConformalCubedSphereGrid) = begin
        #= none:414 =#
        "ConformalCubedSphereGrid"
    end