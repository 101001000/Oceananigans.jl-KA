
#= none:1 =#
using CubedSphere
#= none:2 =#
using JLD2
#= none:3 =#
using OffsetArrays
#= none:4 =#
using Adapt
#= none:5 =#
using Distances
#= none:7 =#
using Adapt: adapt_structure
#= none:9 =#
using Oceananigans
#= none:10 =#
using Oceananigans.Grids: prettysummary, coordinate_summary, BoundedTopology, length
#= none:12 =#
struct CubedSphereConformalMapping{FT, Rotation}
    #= none:13 =#
    ξ::Tuple{FT, FT}
    #= none:14 =#
    η::Tuple{FT, FT}
    #= none:15 =#
    rotation::Rotation
end
#= none:18 =#
struct OrthogonalSphericalShellGrid{FT, TX, TY, TZ, A, R, FR, C, Arch} <: AbstractHorizontallyCurvilinearGrid{FT, TX, TY, TZ, Arch}
    #= none:19 =#
    architecture::Arch
    #= none:20 =#
    Nx::Int
    #= none:21 =#
    Ny::Int
    #= none:22 =#
    Nz::Int
    #= none:23 =#
    Hx::Int
    #= none:24 =#
    Hy::Int
    #= none:25 =#
    Hz::Int
    #= none:26 =#
    Lz::FT
    #= none:27 =#
    λᶜᶜᵃ::A
    #= none:28 =#
    λᶠᶜᵃ::A
    #= none:29 =#
    λᶜᶠᵃ::A
    #= none:30 =#
    λᶠᶠᵃ::A
    #= none:31 =#
    φᶜᶜᵃ::A
    #= none:32 =#
    φᶠᶜᵃ::A
    #= none:33 =#
    φᶜᶠᵃ::A
    #= none:34 =#
    φᶠᶠᵃ::A
    #= none:35 =#
    zᵃᵃᶜ::R
    #= none:36 =#
    zᵃᵃᶠ::R
    #= none:37 =#
    Δxᶜᶜᵃ::A
    #= none:38 =#
    Δxᶠᶜᵃ::A
    #= none:39 =#
    Δxᶜᶠᵃ::A
    #= none:40 =#
    Δxᶠᶠᵃ::A
    #= none:41 =#
    Δyᶜᶜᵃ::A
    #= none:42 =#
    Δyᶜᶠᵃ::A
    #= none:43 =#
    Δyᶠᶜᵃ::A
    #= none:44 =#
    Δyᶠᶠᵃ::A
    #= none:45 =#
    Δzᵃᵃᶜ::FR
    #= none:46 =#
    Δzᵃᵃᶠ::FR
    #= none:47 =#
    Azᶜᶜᵃ::A
    #= none:48 =#
    Azᶠᶜᵃ::A
    #= none:49 =#
    Azᶜᶠᵃ::A
    #= none:50 =#
    Azᶠᶠᵃ::A
    #= none:51 =#
    radius::FT
    #= none:52 =#
    conformal_mapping::C
    #= none:54 =#
    (OrthogonalSphericalShellGrid{TX, TY, TZ}(architecture::Arch, Nx, Ny, Nz, Hx, Hy, Hz, Lz::FT, λᶜᶜᵃ::A, λᶠᶜᵃ::A, λᶜᶠᵃ::A, λᶠᶠᵃ::A, φᶜᶜᵃ::A, φᶠᶜᵃ::A, φᶜᶠᵃ::A, φᶠᶠᵃ::A, zᵃᵃᶜ::R, zᵃᵃᶠ::R, Δxᶜᶜᵃ::A, Δxᶠᶜᵃ::A, Δxᶜᶠᵃ::A, Δxᶠᶠᵃ::A, Δyᶜᶜᵃ::A, Δyᶜᶠᵃ::A, Δyᶠᶜᵃ::A, Δyᶠᶠᵃ::A, Δzᵃᵃᶜ::FR, Δzᵃᵃᶠ::FR, Azᶜᶜᵃ::A, Azᶠᶜᵃ::A, Azᶜᶠᵃ::A, Azᶠᶠᵃ::A, radius::FT, conformal_mapping::C) where {TX, TY, TZ, FT, A, R, FR, C, Arch}) = begin
            #= none:54 =#
            new{FT, TX, TY, TZ, A, R, FR, C, Arch}(architecture, Nx, Ny, Nz, Hx, Hy, Hz, Lz, λᶜᶜᵃ, λᶠᶜᵃ, λᶜᶠᵃ, λᶠᶠᵃ, φᶜᶜᵃ, φᶠᶜᵃ, φᶜᶠᵃ, φᶠᶠᵃ, zᵃᵃᶜ, zᵃᵃᶠ, Δxᶜᶜᵃ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δyᶜᶜᵃ, Δyᶜᶠᵃ, Δyᶠᶜᵃ, Δyᶠᶠᵃ, Δzᵃᵃᶜ, Δzᵃᵃᶠ, Azᶜᶜᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ, radius, conformal_mapping)
        end
end
#= none:76 =#
const OSSG = OrthogonalSphericalShellGrid
#= none:77 =#
const ZRegOSSG = OrthogonalSphericalShellGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Number}
#= none:78 =#
const ZRegOrthogonalSphericalShellGrid = ZRegOSSG
#= none:79 =#
const ConformalCubedSpherePanel = OrthogonalSphericalShellGrid{<:Any, FullyConnected, FullyConnected, <:Any, <:Any, <:Any, <:Any, <:CubedSphereConformalMapping}
#= none:82 =#
OrthogonalSphericalShellGrid(architecture, Nx, Ny, Nz, Hx, Hy, Hz, Lz, λᶜᶜᵃ, λᶠᶜᵃ, λᶜᶠᵃ, λᶠᶠᵃ, φᶜᶜᵃ, φᶠᶜᵃ, φᶜᶠᵃ, φᶠᶠᵃ, zᵃᵃᶜ, zᵃᵃᶠ, Δxᶜᶜᵃ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δyᶜᶜᵃ, Δyᶜᶠᵃ, Δyᶠᶜᵃ, Δyᶠᶠᵃ, Δzᵃᵃᶜ, Δzᵃᵃᶠ, Azᶜᶜᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ, radius) = begin
        #= none:82 =#
        OrthogonalSphericalShellGrid(architecture, Nx, Ny, Nz, Hx, Hy, Hz, Lz, λᶜᶜᵃ, λᶠᶜᵃ, λᶜᶠᵃ, λᶠᶠᵃ, φᶜᶜᵃ, φᶠᶜᵃ, φᶜᶠᵃ, φᶠᶠᵃ, zᵃᵃᶜ, zᵃᵃᶠ, Δxᶜᶜᵃ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δyᶜᶜᵃ, Δyᶜᶠᵃ, Δyᶠᶜᵃ, Δyᶠᶠᵃ, Δzᵃᵃᶜ, Δzᵃᵃᶠ, Azᶜᶜᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ, radius, nothing)
    end
#= none:91 =#
#= none:91 =# Core.@doc "    conformal_cubed_sphere_panel(architecture::AbstractArchitecture = CPU(),\n                                 FT::DataType = Float64;\n                                 size,\n                                 z,\n                                 topology = (Bounded, Bounded, Bounded),\n                                 ξ = (-1, 1),\n                                 η = (-1, 1),\n                                 radius = R_Earth,\n                                 halo = (1, 1, 1),\n                                 rotation = nothing)\n\nCreate a `OrthogonalSphericalShellGrid` that represents a section of a sphere after it has been \nconformally mapped from the face of a cube. The cube's coordinates are `ξ` and `η` (which, by default,\nboth take values in the range ``[-1, 1]``.\n\nThe mapping from the face of the cube to the sphere is done via the [CubedSphere.jl](https://github.com/CliMA/CubedSphere.jl)\npackage.\n\nPositional arguments\n====================\n\n- `architecture`: Specifies whether arrays of coordinates and spacings are stored\n                  on the CPU or GPU. Default: `CPU()`.\n\n- `FT` : Floating point data type. Default: `Float64`.\n\nKeyword arguments\n=================\n\n- `size` (required): A 3-tuple prescribing the number of grid points each direction.\n\n- `z` (required): Either a\n    1. 2-tuple that specify the end points of the ``z``-domain,\n    2. one-dimensional array specifying the cell interface locations, or\n    3. a single-argument function that takes an index and returns cell interface location.\n\n- `radius`: The radius of the sphere the grid lives on. By default this is equal to the radius of Earth.\n\n- `halo`: A 3-tuple of integers specifying the size of the halo region of cells surrounding\n          the physical interior. The default is 1 halo cells in every direction.\n\n- `rotation :: Rotation`: Rotation of the conformal cubed sphere panel about some axis that passes\n                          through the center of the sphere. If `nothing` is provided (default), then\n                          the panel includes the North Pole of the sphere in its center. For example,\n                          to construct a grid that includes tha South Pole we can pass either\n                          `rotation = RotX(π)` or `rotation = RotY(π)`.\n\nExamples\n========\n\n* The default conformal cubed sphere panel grid with `Float64` type:\n\n```jldoctest\njulia> using Oceananigans, Oceananigans.Grids\n\njulia> grid = conformal_cubed_sphere_panel(size=(36, 34, 25), z=(-1000, 0))\n36×34×25 OrthogonalSphericalShellGrid{Float64, Bounded, Bounded, Bounded} on CPU with 1×1×1 halo and with precomputed metrics\n├── centered at: North Pole, (λ, φ) = (0.0, 90.0)\n├── longitude: Bounded  extent 90.0 degrees variably spaced with min(Δλ)=0.616164, max(Δλ)=2.58892\n├── latitude:  Bounded  extent 90.0 degrees variably spaced with min(Δφ)=0.664958, max(Δφ)=2.74119\n└── z:         Bounded  z ∈ [-1000.0, 0.0]  regularly spaced with Δz=40.0\n```\n\n* The conformal cubed sphere panel that includes the South Pole with `Float32` type:\n\n```jldoctest\njulia> using Oceananigans, Oceananigans.Grids, Rotations\n\njulia> grid = conformal_cubed_sphere_panel(Float32, size=(36, 34, 25), z=(-1000, 0), rotation=RotY(π))\n36×34×25 OrthogonalSphericalShellGrid{Float32, Bounded, Bounded, Bounded} on CPU with 1×1×1 halo and with precomputed metrics\n├── centered at: South Pole, (λ, φ) = (0.0, -90.0)\n├── longitude: Bounded  extent 90.0 degrees variably spaced with min(Δλ)=0.616167, max(Δλ)=2.58891\n├── latitude:  Bounded  extent 90.0 degrees variably spaced with min(Δφ)=0.664956, max(Δφ)=2.7412\n└── z:         Bounded  z ∈ [-1000.0, 0.0]  regularly spaced with Δz=40.0\n```\n" function conformal_cubed_sphere_panel(architecture::AbstractArchitecture = CPU(), FT::DataType = Float64; size, z, topology = (Bounded, Bounded, Bounded), ξ = (-1, 1), η = (-1, 1), radius = R_Earth, halo = (1, 1, 1), rotation = nothing)
        #= none:168 =#
        #= none:179 =#
        if architecture == GPU() && !true
            #= none:180 =#
            throw(ArgumentError("Cannot create a GPU grid. No CUDA-enabled GPU was detected!"))
        end
        #= none:183 =#
        radius = FT(radius)
        #= none:185 =#
        (TX, TY, TZ) = topology
        #= none:186 =#
        (Nξ, Nη, Nz) = size
        #= none:187 =#
        (Hx, Hy, Hz) = halo
        #= none:191 =#
        ξη_grid_topology = (Bounded, Bounded, topology[3])
        #= none:194 =#
        ξη_grid = RectilinearGrid(CPU(), FT; size = (Nξ, Nη, Nz), topology = ξη_grid_topology, x = ξ, y = η, z, halo)
        #= none:199 =#
        ξᶠᵃᵃ = xnodes(ξη_grid, Face())
        #= none:200 =#
        ξᶜᵃᵃ = xnodes(ξη_grid, Center())
        #= none:201 =#
        ηᵃᶠᵃ = ynodes(ξη_grid, Face())
        #= none:202 =#
        ηᵃᶜᵃ = ynodes(ξη_grid, Center())
        #= none:205 =#
        zᵃᵃᶠ = ξη_grid.zᵃᵃᶠ
        #= none:206 =#
        zᵃᵃᶜ = ξη_grid.zᵃᵃᶜ
        #= none:207 =#
        Δzᵃᵃᶜ = ξη_grid.Δzᵃᵃᶜ
        #= none:208 =#
        Δzᵃᵃᶠ = ξη_grid.Δzᵃᵃᶠ
        #= none:209 =#
        Lz = ξη_grid.Lz
        #= none:214 =#
        λᶜᶜᵃ = zeros(FT, Nξ, Nη)
        #= none:215 =#
        λᶠᶜᵃ = zeros(FT, Nξ + 1, Nη)
        #= none:216 =#
        λᶜᶠᵃ = zeros(FT, Nξ, Nη + 1)
        #= none:217 =#
        λᶠᶠᵃ = zeros(FT, Nξ + 1, Nη + 1)
        #= none:219 =#
        φᶜᶜᵃ = zeros(FT, Nξ, Nη)
        #= none:220 =#
        φᶠᶜᵃ = zeros(FT, Nξ + 1, Nη)
        #= none:221 =#
        φᶜᶠᵃ = zeros(FT, Nξ, Nη + 1)
        #= none:222 =#
        φᶠᶠᵃ = zeros(FT, Nξ + 1, Nη + 1)
        #= none:224 =#
        ξS = (ξᶜᵃᵃ, ξᶠᵃᵃ, ξᶜᵃᵃ, ξᶠᵃᵃ)
        #= none:225 =#
        ηS = (ηᵃᶜᵃ, ηᵃᶜᵃ, ηᵃᶠᵃ, ηᵃᶠᵃ)
        #= none:226 =#
        λS = (λᶜᶜᵃ, λᶠᶜᵃ, λᶜᶠᵃ, λᶠᶠᵃ)
        #= none:227 =#
        φS = (φᶜᶜᵃ, φᶠᶜᵃ, φᶜᶠᵃ, φᶠᶠᵃ)
        #= none:229 =#
        for (ξ, η, λ, φ) = zip(ξS, ηS, λS, φS)
            #= none:230 =#
            for j = 1:length(η), i = 1:length(ξ)
                #= none:231 =#
                (x, y, z) = #= none:231 =# @inbounds(conformal_cubed_sphere_mapping(ξ[i], η[j]))
                #= none:233 =#
                if !(isnothing(rotation))
                    #= none:234 =#
                    (x, y, z) = rotation * [x, y, z]
                end
                #= none:237 =#
                #= none:237 =# @inbounds (φ[i, j], λ[i, j]) = cartesian_to_lat_lon(x, y, z)
                #= none:238 =#
            end
            #= none:239 =#
        end
        #= none:241 =#
        any(any.(isnan, λS)) && #= none:242 =# @warn("OrthogonalSphericalShellGrid contains a grid point at a pole whose longitude is undefined (NaN).")
        #= none:266 =#
        Δxᶜᶜᵃ = zeros(FT, Nξ, Nη)
        #= none:267 =#
        Δxᶠᶜᵃ = zeros(FT, Nξ + 1, Nη)
        #= none:268 =#
        Δxᶜᶠᵃ = zeros(FT, Nξ, Nη + 1)
        #= none:269 =#
        Δxᶠᶠᵃ = zeros(FT, Nξ + 1, Nη + 1)
        #= none:271 =#
        #= none:271 =# @inbounds begin
                #= none:274 =#
                for i = 1:Nξ, j = 1:Nη
                    #= none:275 =#
                    Δxᶜᶜᵃ[i, j] = haversine((λᶠᶜᵃ[i + 1, j], φᶠᶜᵃ[i + 1, j]), (λᶠᶜᵃ[i, j], φᶠᶜᵃ[i, j]), radius)
                    #= none:276 =#
                end
                #= none:281 =#
                for j = 1:Nη, i = 2:Nξ
                    #= none:282 =#
                    Δxᶠᶜᵃ[i, j] = haversine((λᶜᶜᵃ[i, j], φᶜᶜᵃ[i, j]), (λᶜᶜᵃ[i - 1, j], φᶜᶜᵃ[i - 1, j]), radius)
                    #= none:283 =#
                end
                #= none:285 =#
                for j = 1:Nη
                    #= none:286 =#
                    i = 1
                    #= none:287 =#
                    Δxᶠᶜᵃ[i, j] = 2 * haversine((λᶜᶜᵃ[i, j], φᶜᶜᵃ[i, j]), (λᶠᶜᵃ[i, j], φᶠᶜᵃ[i, j]), radius)
                    #= none:288 =#
                end
                #= none:290 =#
                for j = 1:Nη
                    #= none:291 =#
                    i = Nξ + 1
                    #= none:292 =#
                    Δxᶠᶜᵃ[i, j] = 2 * haversine((λᶠᶜᵃ[i, j], φᶠᶜᵃ[i, j]), (λᶜᶜᵃ[i - 1, j], φᶜᶜᵃ[i - 1, j]), radius)
                    #= none:293 =#
                end
                #= none:298 =#
                for j = 1:Nη + 1, i = 1:Nξ
                    #= none:299 =#
                    Δxᶜᶠᵃ[i, j] = haversine((λᶠᶠᵃ[i + 1, j], φᶠᶠᵃ[i + 1, j]), (λᶠᶠᵃ[i, j], φᶠᶠᵃ[i, j]), radius)
                    #= none:300 =#
                end
                #= none:305 =#
                for j = 1:Nη + 1, i = 2:Nξ
                    #= none:306 =#
                    Δxᶠᶠᵃ[i, j] = haversine((λᶜᶠᵃ[i, j], φᶜᶠᵃ[i, j]), (λᶜᶠᵃ[i - 1, j], φᶜᶠᵃ[i - 1, j]), radius)
                    #= none:307 =#
                end
                #= none:309 =#
                for j = 1:Nη + 1
                    #= none:310 =#
                    i = 1
                    #= none:311 =#
                    Δxᶠᶠᵃ[i, j] = 2 * haversine((λᶜᶠᵃ[i, j], φᶜᶠᵃ[i, j]), (λᶠᶠᵃ[i, j], φᶠᶠᵃ[i, j]), radius)
                    #= none:312 =#
                end
                #= none:314 =#
                for j = 1:Nη + 1
                    #= none:315 =#
                    i = Nξ + 1
                    #= none:316 =#
                    Δxᶠᶠᵃ[i, j] = 2 * haversine((λᶠᶠᵃ[i, j], φᶠᶠᵃ[i, j]), (λᶜᶠᵃ[i - 1, j], φᶜᶠᵃ[i - 1, j]), radius)
                    #= none:317 =#
                end
            end
        #= none:320 =#
        Δyᶜᶜᵃ = zeros(FT, Nξ, Nη)
        #= none:321 =#
        Δyᶠᶜᵃ = zeros(FT, Nξ + 1, Nη)
        #= none:322 =#
        Δyᶜᶠᵃ = zeros(FT, Nξ, Nη + 1)
        #= none:323 =#
        Δyᶠᶠᵃ = zeros(FT, Nξ + 1, Nη + 1)
        #= none:325 =#
        #= none:325 =# @inbounds begin
                #= none:328 =#
                for j = 1:Nη, i = 1:Nξ
                    #= none:329 =#
                    Δyᶜᶜᵃ[i, j] = haversine((λᶜᶠᵃ[i, j + 1], φᶜᶠᵃ[i, j + 1]), (λᶜᶠᵃ[i, j], φᶜᶠᵃ[i, j]), radius)
                    #= none:330 =#
                end
                #= none:335 =#
                for j = 2:Nη, i = 1:Nξ
                    #= none:336 =#
                    Δyᶜᶠᵃ[i, j] = haversine((λᶜᶜᵃ[i, j], φᶜᶜᵃ[i, j]), (λᶜᶜᵃ[i, j - 1], φᶜᶜᵃ[i, j - 1]), radius)
                    #= none:337 =#
                end
                #= none:339 =#
                for i = 1:Nξ
                    #= none:340 =#
                    j = 1
                    #= none:341 =#
                    Δyᶜᶠᵃ[i, j] = 2 * haversine((λᶜᶜᵃ[i, j], φᶜᶜᵃ[i, j]), (λᶜᶠᵃ[i, j], φᶜᶠᵃ[i, j]), radius)
                    #= none:342 =#
                end
                #= none:344 =#
                for i = 1:Nξ
                    #= none:345 =#
                    j = Nη + 1
                    #= none:346 =#
                    Δyᶜᶠᵃ[i, j] = 2 * haversine((λᶜᶠᵃ[i, j], φᶜᶠᵃ[i, j]), (λᶜᶜᵃ[i, j - 1], φᶜᶜᵃ[i, j - 1]), radius)
                    #= none:347 =#
                end
                #= none:352 =#
                for j = 1:Nη, i = 1:Nξ + 1
                    #= none:353 =#
                    Δyᶠᶜᵃ[i, j] = haversine((λᶠᶠᵃ[i, j + 1], φᶠᶠᵃ[i, j + 1]), (λᶠᶠᵃ[i, j], φᶠᶠᵃ[i, j]), radius)
                    #= none:354 =#
                end
                #= none:359 =#
                for j = 2:Nη, i = 1:Nξ + 1
                    #= none:360 =#
                    Δyᶠᶠᵃ[i, j] = haversine((λᶠᶜᵃ[i, j], φᶠᶜᵃ[i, j]), (λᶠᶜᵃ[i, j - 1], φᶠᶜᵃ[i, j - 1]), radius)
                    #= none:361 =#
                end
                #= none:363 =#
                for i = 1:Nξ + 1
                    #= none:364 =#
                    j = 1
                    #= none:365 =#
                    Δyᶠᶠᵃ[i, j] = 2 * haversine((λᶠᶜᵃ[i, j], φᶠᶜᵃ[i, j]), (λᶠᶠᵃ[i, j], φᶠᶠᵃ[i, j]), radius)
                    #= none:366 =#
                end
                #= none:368 =#
                for i = 1:Nξ + 1
                    #= none:369 =#
                    j = Nη + 1
                    #= none:370 =#
                    Δyᶠᶠᵃ[i, j] = 2 * haversine((λᶠᶠᵃ[i, j], φᶠᶠᵃ[i, j]), (λᶠᶜᵃ[i, j - 1], φᶠᶜᵃ[i, j - 1]), radius)
                    #= none:371 =#
                end
            end
        #= none:399 =#
        Azᶜᶜᵃ = zeros(FT, Nξ, Nη)
        #= none:400 =#
        Azᶠᶜᵃ = zeros(FT, Nξ + 1, Nη)
        #= none:401 =#
        Azᶜᶠᵃ = zeros(FT, Nξ, Nη + 1)
        #= none:402 =#
        Azᶠᶠᵃ = zeros(FT, Nξ + 1, Nη + 1)
        #= none:404 =#
        #= none:404 =# @inbounds begin
                #= none:407 =#
                for j = 1:Nη, i = 1:Nξ
                    #= none:408 =#
                    a = lat_lon_to_cartesian(φᶠᶠᵃ[i, j], λᶠᶠᵃ[i, j], 1)
                    #= none:409 =#
                    b = lat_lon_to_cartesian(φᶠᶠᵃ[i + 1, j], λᶠᶠᵃ[i + 1, j], 1)
                    #= none:410 =#
                    c = lat_lon_to_cartesian(φᶠᶠᵃ[i + 1, j + 1], λᶠᶠᵃ[i + 1, j + 1], 1)
                    #= none:411 =#
                    d = lat_lon_to_cartesian(φᶠᶠᵃ[i, j + 1], λᶠᶠᵃ[i, j + 1], 1)
                    #= none:413 =#
                    Azᶜᶜᵃ[i, j] = spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:414 =#
                end
                #= none:419 =#
                for j = 1:Nη, i = 2:Nξ
                    #= none:420 =#
                    a = lat_lon_to_cartesian(φᶜᶠᵃ[i - 1, j], λᶜᶠᵃ[i - 1, j], 1)
                    #= none:421 =#
                    b = lat_lon_to_cartesian(φᶜᶠᵃ[i, j], λᶜᶠᵃ[i, j], 1)
                    #= none:422 =#
                    c = lat_lon_to_cartesian(φᶜᶠᵃ[i, j + 1], λᶜᶠᵃ[i, j + 1], 1)
                    #= none:423 =#
                    d = lat_lon_to_cartesian(φᶜᶠᵃ[i - 1, j + 1], λᶜᶠᵃ[i - 1, j + 1], 1)
                    #= none:425 =#
                    Azᶠᶜᵃ[i, j] = spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:426 =#
                end
                #= none:428 =#
                for j = 1:Nη
                    #= none:429 =#
                    i = 1
                    #= none:430 =#
                    a = lat_lon_to_cartesian(φᶠᶠᵃ[i, j], λᶠᶠᵃ[i, j], 1)
                    #= none:431 =#
                    b = lat_lon_to_cartesian(φᶜᶠᵃ[i, j], λᶜᶠᵃ[i, j], 1)
                    #= none:432 =#
                    c = lat_lon_to_cartesian(φᶜᶠᵃ[i, j + 1], λᶜᶠᵃ[i, j + 1], 1)
                    #= none:433 =#
                    d = lat_lon_to_cartesian(φᶠᶠᵃ[i, j + 1], λᶠᶠᵃ[i, j + 1], 1)
                    #= none:435 =#
                    Azᶠᶜᵃ[i, j] = 2 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:436 =#
                end
                #= none:438 =#
                for j = 1:Nη
                    #= none:439 =#
                    i = Nξ + 1
                    #= none:440 =#
                    a = lat_lon_to_cartesian(φᶜᶠᵃ[i - 1, j], λᶜᶠᵃ[i - 1, j], 1)
                    #= none:441 =#
                    b = lat_lon_to_cartesian(φᶠᶠᵃ[i, j], λᶠᶠᵃ[i, j], 1)
                    #= none:442 =#
                    c = lat_lon_to_cartesian(φᶠᶠᵃ[i, j + 1], λᶠᶠᵃ[i, j + 1], 1)
                    #= none:443 =#
                    d = lat_lon_to_cartesian(φᶜᶠᵃ[i - 1, j + 1], λᶜᶠᵃ[i - 1, j + 1], 1)
                    #= none:445 =#
                    Azᶠᶜᵃ[i, j] = 2 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:446 =#
                end
                #= none:451 =#
                for j = 2:Nη, i = 1:Nξ
                    #= none:452 =#
                    a = lat_lon_to_cartesian(φᶠᶜᵃ[i, j - 1], λᶠᶜᵃ[i, j - 1], 1)
                    #= none:453 =#
                    b = lat_lon_to_cartesian(φᶠᶜᵃ[i + 1, j - 1], λᶠᶜᵃ[i + 1, j - 1], 1)
                    #= none:454 =#
                    c = lat_lon_to_cartesian(φᶠᶜᵃ[i + 1, j], λᶠᶜᵃ[i + 1, j], 1)
                    #= none:455 =#
                    d = lat_lon_to_cartesian(φᶠᶜᵃ[i, j], λᶠᶜᵃ[i, j], 1)
                    #= none:457 =#
                    Azᶜᶠᵃ[i, j] = spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:458 =#
                end
                #= none:460 =#
                for i = 1:Nξ
                    #= none:461 =#
                    j = 1
                    #= none:462 =#
                    a = lat_lon_to_cartesian(φᶠᶠᵃ[i, j], λᶠᶠᵃ[i, j], 1)
                    #= none:463 =#
                    b = lat_lon_to_cartesian(φᶠᶠᵃ[i + 1, j], λᶠᶠᵃ[i + 1, j], 1)
                    #= none:464 =#
                    c = lat_lon_to_cartesian(φᶠᶜᵃ[i + 1, j], λᶠᶜᵃ[i + 1, j], 1)
                    #= none:465 =#
                    d = lat_lon_to_cartesian(φᶠᶜᵃ[i, j], λᶠᶜᵃ[i, j], 1)
                    #= none:467 =#
                    Azᶜᶠᵃ[i, j] = 2 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:468 =#
                end
                #= none:470 =#
                for i = 1:Nξ
                    #= none:471 =#
                    j = Nη + 1
                    #= none:472 =#
                    a = lat_lon_to_cartesian(φᶠᶜᵃ[i, j - 1], λᶠᶜᵃ[i, j - 1], 1)
                    #= none:473 =#
                    b = lat_lon_to_cartesian(φᶠᶜᵃ[i + 1, j - 1], λᶠᶜᵃ[i + 1, j - 1], 1)
                    #= none:474 =#
                    c = lat_lon_to_cartesian(φᶠᶠᵃ[i + 1, j], λᶠᶠᵃ[i + 1, j], 1)
                    #= none:475 =#
                    d = lat_lon_to_cartesian(φᶠᶠᵃ[i, j], λᶠᶠᵃ[i, j], 1)
                    #= none:477 =#
                    Azᶜᶠᵃ[i, j] = 2 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:478 =#
                end
                #= none:483 =#
                for j = 2:Nη, i = 2:Nξ
                    #= none:484 =#
                    a = lat_lon_to_cartesian(φᶜᶜᵃ[i - 1, j - 1], λᶜᶜᵃ[i - 1, j - 1], 1)
                    #= none:485 =#
                    b = lat_lon_to_cartesian(φᶜᶜᵃ[i, j - 1], λᶜᶜᵃ[i, j - 1], 1)
                    #= none:486 =#
                    c = lat_lon_to_cartesian(φᶜᶜᵃ[i, j], λᶜᶜᵃ[i, j], 1)
                    #= none:487 =#
                    d = lat_lon_to_cartesian(φᶜᶜᵃ[i - 1, j], λᶜᶜᵃ[i - 1, j], 1)
                    #= none:489 =#
                    Azᶠᶠᵃ[i, j] = spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:490 =#
                end
                #= none:492 =#
                for i = 2:Nξ
                    #= none:493 =#
                    j = 1
                    #= none:494 =#
                    a = lat_lon_to_cartesian(φᶜᶠᵃ[i - 1, j], λᶜᶠᵃ[i - 1, j], 1)
                    #= none:495 =#
                    b = lat_lon_to_cartesian(φᶜᶠᵃ[i, j], λᶜᶠᵃ[i, j], 1)
                    #= none:496 =#
                    c = lat_lon_to_cartesian(φᶜᶜᵃ[i, j], λᶜᶜᵃ[i, j], 1)
                    #= none:497 =#
                    d = lat_lon_to_cartesian(φᶜᶜᵃ[i - 1, j], λᶜᶜᵃ[i - 1, j], 1)
                    #= none:499 =#
                    Azᶠᶠᵃ[i, j] = 2 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:500 =#
                end
                #= none:502 =#
                for i = 2:Nξ
                    #= none:503 =#
                    j = Nη + 1
                    #= none:504 =#
                    a = lat_lon_to_cartesian(φᶜᶜᵃ[i - 1, j - 1], λᶜᶜᵃ[i - 1, j - 1], 1)
                    #= none:505 =#
                    b = lat_lon_to_cartesian(φᶜᶜᵃ[i, j - 1], λᶜᶜᵃ[i, j - 1], 1)
                    #= none:506 =#
                    c = lat_lon_to_cartesian(φᶜᶠᵃ[i, j], λᶜᶠᵃ[i, j], 1)
                    #= none:507 =#
                    d = lat_lon_to_cartesian(φᶜᶠᵃ[i - 1, j], λᶜᶠᵃ[i - 1, j], 1)
                    #= none:509 =#
                    Azᶠᶠᵃ[i, j] = 2 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:510 =#
                end
                #= none:512 =#
                for j = 2:Nη
                    #= none:513 =#
                    i = 1
                    #= none:514 =#
                    a = lat_lon_to_cartesian(φᶠᶜᵃ[i, j - 1], λᶠᶜᵃ[i, j - 1], 1)
                    #= none:515 =#
                    b = lat_lon_to_cartesian(φᶜᶜᵃ[i, j - 1], λᶜᶜᵃ[i, j - 1], 1)
                    #= none:516 =#
                    c = lat_lon_to_cartesian(φᶜᶜᵃ[i, j], λᶜᶜᵃ[i, j], 1)
                    #= none:517 =#
                    d = lat_lon_to_cartesian(φᶠᶜᵃ[i, j], λᶠᶜᵃ[i, j], 1)
                    #= none:519 =#
                    Azᶠᶠᵃ[i, j] = 2 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:520 =#
                end
                #= none:522 =#
                for j = 2:Nη
                    #= none:523 =#
                    i = Nξ + 1
                    #= none:524 =#
                    a = lat_lon_to_cartesian(φᶜᶜᵃ[i - 1, j - 1], λᶜᶜᵃ[i - 1, j - 1], 1)
                    #= none:525 =#
                    b = lat_lon_to_cartesian(φᶠᶜᵃ[i, j - 1], λᶠᶜᵃ[i, j - 1], 1)
                    #= none:526 =#
                    c = lat_lon_to_cartesian(φᶠᶜᵃ[i, j], λᶠᶜᵃ[i, j], 1)
                    #= none:527 =#
                    d = lat_lon_to_cartesian(φᶜᶜᵃ[i - 1, j], λᶜᶜᵃ[i - 1, j], 1)
                    #= none:529 =#
                    Azᶠᶠᵃ[i, j] = 2 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                    #= none:530 =#
                end
                #= none:532 =#
                i = 1
                #= none:533 =#
                j = 1
                #= none:534 =#
                a = lat_lon_to_cartesian(φᶠᶠᵃ[i, j], λᶠᶠᵃ[i, j], 1)
                #= none:535 =#
                b = lat_lon_to_cartesian(φᶜᶠᵃ[i, j], λᶜᶠᵃ[i, j], 1)
                #= none:536 =#
                c = lat_lon_to_cartesian(φᶜᶜᵃ[i, j], λᶜᶜᵃ[i, j], 1)
                #= none:537 =#
                d = lat_lon_to_cartesian(φᶠᶜᵃ[i, j], λᶠᶜᵃ[i, j], 1)
                #= none:539 =#
                Azᶠᶠᵃ[i, j] = 4 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                #= none:541 =#
                i = Nξ + 1
                #= none:542 =#
                j = Nη + 1
                #= none:543 =#
                a = lat_lon_to_cartesian(φᶜᶜᵃ[i - 1, j - 1], λᶜᶜᵃ[i - 1, j - 1], 1)
                #= none:544 =#
                b = lat_lon_to_cartesian(φᶠᶜᵃ[i, j - 1], λᶠᶜᵃ[i, j - 1], 1)
                #= none:545 =#
                c = lat_lon_to_cartesian(φᶠᶠᵃ[i, j], λᶠᶠᵃ[i, j], 1)
                #= none:546 =#
                d = lat_lon_to_cartesian(φᶜᶠᵃ[i - 1, j], λᶜᶠᵃ[i - 1, j], 1)
                #= none:548 =#
                Azᶠᶠᵃ[i, j] = 4 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                #= none:550 =#
                i = Nξ + 1
                #= none:551 =#
                j = 1
                #= none:552 =#
                a = lat_lon_to_cartesian(φᶜᶠᵃ[i - 1, j], λᶜᶠᵃ[i - 1, j], 1)
                #= none:553 =#
                b = lat_lon_to_cartesian(φᶠᶠᵃ[i, j], λᶠᶠᵃ[i, j], 1)
                #= none:554 =#
                c = lat_lon_to_cartesian(φᶠᶜᵃ[i, j], λᶠᶜᵃ[i, j], 1)
                #= none:555 =#
                d = lat_lon_to_cartesian(φᶜᶜᵃ[i - 1, j], λᶜᶜᵃ[i - 1, j], 1)
                #= none:557 =#
                Azᶠᶠᵃ[i, j] = 4 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
                #= none:559 =#
                i = 1
                #= none:560 =#
                j = Nη + 1
                #= none:561 =#
                a = lat_lon_to_cartesian(φᶠᶜᵃ[i, j - 1], λᶠᶜᵃ[i, j - 1], 1)
                #= none:562 =#
                b = lat_lon_to_cartesian(φᶜᶜᵃ[i, j - 1], λᶜᶜᵃ[i, j - 1], 1)
                #= none:563 =#
                c = lat_lon_to_cartesian(φᶜᶠᵃ[i, j], λᶜᶠᵃ[i, j], 1)
                #= none:564 =#
                d = lat_lon_to_cartesian(φᶠᶠᵃ[i, j], λᶠᶠᵃ[i, j], 1)
                #= none:566 =#
                Azᶠᶠᵃ[i, j] = 4 * spherical_area_quadrilateral(a, b, c, d) * radius ^ 2
            end
        #= none:575 =#
        warnings = false
        #= none:577 =#
        args = (topology, (Nξ, Nη, Nz), (Hx, Hy, Hz))
        #= none:579 =#
        λᶜᶜᵃ = add_halos(λᶜᶜᵃ, (Center, Center, Nothing), args...; warnings)
        #= none:580 =#
        λᶠᶜᵃ = add_halos(λᶠᶜᵃ, (Face, Center, Nothing), args...; warnings)
        #= none:581 =#
        λᶜᶠᵃ = add_halos(λᶜᶠᵃ, (Center, Face, Nothing), args...; warnings)
        #= none:582 =#
        λᶠᶠᵃ = add_halos(λᶠᶠᵃ, (Face, Face, Nothing), args...; warnings)
        #= none:584 =#
        φᶜᶜᵃ = add_halos(φᶜᶜᵃ, (Center, Center, Nothing), args...; warnings)
        #= none:585 =#
        φᶠᶜᵃ = add_halos(φᶠᶜᵃ, (Face, Center, Nothing), args...; warnings)
        #= none:586 =#
        φᶜᶠᵃ = add_halos(φᶜᶠᵃ, (Center, Face, Nothing), args...; warnings)
        #= none:587 =#
        φᶠᶠᵃ = add_halos(φᶠᶠᵃ, (Face, Face, Nothing), args...; warnings)
        #= none:589 =#
        Δxᶜᶜᵃ = add_halos(Δxᶜᶜᵃ, (Center, Center, Nothing), args...; warnings)
        #= none:590 =#
        Δxᶠᶜᵃ = add_halos(Δxᶠᶜᵃ, (Face, Center, Nothing), args...; warnings)
        #= none:591 =#
        Δxᶜᶠᵃ = add_halos(Δxᶜᶠᵃ, (Center, Face, Nothing), args...; warnings)
        #= none:592 =#
        Δxᶠᶠᵃ = add_halos(Δxᶠᶠᵃ, (Face, Face, Nothing), args...; warnings)
        #= none:594 =#
        Δyᶜᶜᵃ = add_halos(Δyᶜᶜᵃ, (Center, Center, Nothing), args...; warnings)
        #= none:595 =#
        Δyᶠᶜᵃ = add_halos(Δyᶠᶜᵃ, (Face, Center, Nothing), args...; warnings)
        #= none:596 =#
        Δyᶜᶠᵃ = add_halos(Δyᶜᶠᵃ, (Center, Face, Nothing), args...; warnings)
        #= none:597 =#
        Δyᶠᶠᵃ = add_halos(Δyᶠᶠᵃ, (Face, Face, Nothing), args...; warnings)
        #= none:599 =#
        Azᶜᶜᵃ = add_halos(Azᶜᶜᵃ, (Center, Center, Nothing), args...; warnings)
        #= none:600 =#
        Azᶠᶜᵃ = add_halos(Azᶠᶜᵃ, (Face, Center, Nothing), args...; warnings)
        #= none:601 =#
        Azᶜᶠᵃ = add_halos(Azᶜᶠᵃ, (Center, Face, Nothing), args...; warnings)
        #= none:602 =#
        Azᶠᶠᵃ = add_halos(Azᶠᶠᵃ, (Face, Face, Nothing), args...; warnings)
        #= none:604 =#
        coordinate_arrays = (λᶜᶜᵃ, λᶠᶜᵃ, λᶜᶠᵃ, λᶠᶠᵃ, φᶜᶜᵃ, φᶠᶜᵃ, φᶜᶠᵃ, φᶠᶠᵃ, zᵃᵃᶜ, zᵃᵃᶠ)
        #= none:608 =#
        metric_arrays = (Δxᶜᶜᵃ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δyᶜᶜᵃ, Δyᶜᶠᵃ, Δyᶠᶜᵃ, Δyᶠᶠᵃ, Δzᵃᵃᶜ, Δzᵃᵃᶠ, Azᶜᶜᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ)
        #= none:613 =#
        conformal_mapping = CubedSphereConformalMapping(ξ, η, rotation)
        #= none:615 =#
        grid = OrthogonalSphericalShellGrid{TX, TY, TZ}(CPU(), Nξ, Nη, Nz, Hx, Hy, Hz, Lz, coordinate_arrays..., metric_arrays..., radius, conformal_mapping)
        #= none:621 =#
        fill_metric_halo_regions!(grid)
        #= none:625 =#
        coordinate_arrays = (grid.λᶜᶜᵃ, grid.λᶠᶜᵃ, grid.λᶜᶠᵃ, grid.λᶠᶠᵃ, grid.φᶜᶜᵃ, grid.φᶠᶜᵃ, grid.φᶜᶠᵃ, grid.φᶠᶠᵃ, grid.zᵃᵃᶜ, grid.zᵃᵃᶠ)
        #= none:629 =#
        metric_arrays = (grid.Δxᶜᶜᵃ, grid.Δxᶠᶜᵃ, grid.Δxᶜᶠᵃ, grid.Δxᶠᶠᵃ, grid.Δyᶜᶜᵃ, grid.Δyᶜᶠᵃ, grid.Δyᶠᶜᵃ, grid.Δyᶠᶠᵃ, grid.Δzᵃᵃᶜ, grid.Δzᵃᵃᶠ, grid.Azᶜᶜᵃ, grid.Azᶠᶜᵃ, grid.Azᶜᶠᵃ, grid.Azᶠᶠᵃ)
        #= none:634 =#
        coordinate_arrays = map((a->begin
                        #= none:634 =#
                        on_architecture(architecture, a)
                    end), coordinate_arrays)
        #= none:636 =#
        metric_arrays = map((a->begin
                        #= none:636 =#
                        on_architecture(architecture, a)
                    end), metric_arrays)
        #= none:638 =#
        grid = OrthogonalSphericalShellGrid{TX, TY, TZ}(architecture, Nξ, Nη, Nz, Hx, Hy, Hz, Lz, coordinate_arrays..., metric_arrays..., radius, conformal_mapping)
        #= none:643 =#
        return grid
    end
#= none:646 =#
#= none:646 =# Core.@doc "    fill_metric_halo_regions_x!(metric, ℓx, ℓy, tx, ty, Nx, Ny, Hx, Hy)\n\nFill the `x`-halo regions of the `metric` that lives on locations `ℓx`, `ℓy`, with halo size `Hx`, `Hy`,\nand topology `tx`, `ty`.\n" function fill_metric_halo_regions_x!(metric, ℓx, ℓy, tx::BoundedTopology, ty, Nx, Ny, Hx, Hy)
        #= none:652 =#
        #= none:654 =#
        Nx⁺ = length(ℓx, tx, Nx)
        #= none:655 =#
        Ny⁺ = length(ℓy, ty, Ny)
        #= none:657 =#
        #= none:657 =# @inbounds begin
                #= none:658 =#
                for j = 1:Ny⁺
                    #= none:660 =#
                    for i = 0:-1:-Hx + 1
                        #= none:661 =#
                        metric[i, j] = metric[i + 1, j]
                        #= none:662 =#
                    end
                    #= none:664 =#
                    for i = Nx⁺ + 1:Nx⁺ + Hx
                        #= none:665 =#
                        metric[i, j] = metric[i - 1, j]
                        #= none:666 =#
                    end
                    #= none:667 =#
                end
            end
        #= none:670 =#
        return nothing
    end
#= none:673 =#
function fill_metric_halo_regions_x!(metric, ℓx, ℓy, tx::AbstractTopology, ty, Nx, Ny, Hx, Hy)
    #= none:673 =#
    #= none:675 =#
    Nx⁺ = length(ℓx, tx, Nx)
    #= none:676 =#
    Ny⁺ = length(ℓy, ty, Ny)
    #= none:678 =#
    #= none:678 =# @inbounds begin
            #= none:679 =#
            for j = 1:Ny⁺
                #= none:681 =#
                for i = 0:-1:-Hx + 1
                    #= none:682 =#
                    metric[i, j] = metric[Nx + i, j]
                    #= none:683 =#
                end
                #= none:685 =#
                for i = Nx⁺ + 1:Nx⁺ + Hx
                    #= none:686 =#
                    metric[i, j] = metric[i - Nx, j]
                    #= none:687 =#
                end
                #= none:688 =#
            end
        end
    #= none:691 =#
    return nothing
end
#= none:694 =#
#= none:694 =# Core.@doc "    fill_metric_halo_regions_y!(metric, ℓx, ℓy, tx, ty, Nx, Ny, Hx, Hy)\n\nFill the `y`-halo regions of the `metric` that lives on locations `ℓx`, `ℓy`, with halo size `Hx`, `Hy`,\nand topology `tx`, `ty`.\n" function fill_metric_halo_regions_y!(metric, ℓx, ℓy, tx, ty::BoundedTopology, Nx, Ny, Hx, Hy)
        #= none:700 =#
        #= none:702 =#
        Nx⁺ = length(ℓx, tx, Nx)
        #= none:703 =#
        Ny⁺ = length(ℓy, ty, Ny)
        #= none:705 =#
        #= none:705 =# @inbounds begin
                #= none:706 =#
                for i = 1:Nx⁺
                    #= none:708 =#
                    for j = 0:-1:-Hy + 1
                        #= none:709 =#
                        metric[i, j] = metric[i, j + 1]
                        #= none:710 =#
                    end
                    #= none:712 =#
                    for j = Ny⁺ + 1:Ny⁺ + Hy
                        #= none:713 =#
                        metric[i, j] = metric[i, j - 1]
                        #= none:714 =#
                    end
                    #= none:715 =#
                end
            end
        #= none:718 =#
        return nothing
    end
#= none:721 =#
function fill_metric_halo_regions_y!(metric, ℓx, ℓy, tx, ty::AbstractTopology, Nx, Ny, Hx, Hy)
    #= none:721 =#
    #= none:723 =#
    Nx⁺ = length(ℓx, tx, Nx)
    #= none:724 =#
    Ny⁺ = length(ℓy, ty, Ny)
    #= none:726 =#
    #= none:726 =# @inbounds begin
            #= none:727 =#
            for i = 1:Nx⁺
                #= none:729 =#
                for j = 0:-1:-Hy + 1
                    #= none:730 =#
                    metric[i, j] = metric[i, Ny + j]
                    #= none:731 =#
                end
                #= none:733 =#
                for j = Ny⁺ + 1:Ny⁺ + Hy
                    #= none:734 =#
                    metric[i, j] = metric[i, j - Ny]
                    #= none:735 =#
                end
                #= none:736 =#
            end
        end
    #= none:739 =#
    return nothing
end
#= none:742 =#
#= none:742 =# Core.@doc "    fill_metric_halo_corner_regions!(metric, ℓx, ℓy, tx, ty, Nx, Ny, Hx, Hy)\n\nFill the corner halo regions of the `metric`  that lives on locations `ℓx`, `ℓy`,\nand with halo size `Hx`, `Hy`. We choose to fill with the average of the neighboring\nmetric in the halo regions. Thus this requires that the metric in the `x`- and `y`-halo\nregions have already been filled.\n" function fill_metric_halo_corner_regions!(metric, ℓx, ℓy, tx, ty, Nx, Ny, Hx, Hy)
        #= none:750 =#
        #= none:752 =#
        Nx⁺ = length(ℓx, tx, Nx)
        #= none:753 =#
        Ny⁺ = length(ℓy, ty, Ny)
        #= none:755 =#
        #= none:755 =# @inbounds begin
                #= none:756 =#
                for j = 0:-1:-Hy + 1, i = 0:-1:-Hx + 1
                    #= none:757 =#
                    metric[i, j] = (metric[i + 1, j] + metric[i, j + 1]) / 2
                    #= none:758 =#
                end
                #= none:759 =#
                for j = Ny⁺ + 1:Ny⁺ + Hy, i = 0:-1:-Hx + 1
                    #= none:760 =#
                    metric[i, j] = (metric[i + 1, j] + metric[i, j - 1]) / 2
                    #= none:761 =#
                end
                #= none:762 =#
                for j = 0:-1:-Hy + 1, i = Nx⁺ + 1:Nx⁺ + Hx
                    #= none:763 =#
                    metric[i, j] = (metric[i - 1, j] + metric[i, j + 1]) / 2
                    #= none:764 =#
                end
                #= none:765 =#
                for j = Ny⁺ + 1:Ny⁺ + Hy, i = Nx⁺ + 1:Nx⁺ + Hx
                    #= none:766 =#
                    metric[i, j] = (metric[i - 1, j] + metric[i, j - 1]) / 2
                    #= none:767 =#
                end
            end
        #= none:770 =#
        return nothing
    end
#= none:773 =#
function fill_metric_halo_regions!(grid)
    #= none:773 =#
    #= none:774 =#
    (Nx, Ny, _) = size(grid)
    #= none:775 =#
    (Hx, Hy, _) = halo_size(grid)
    #= none:776 =#
    (TX, TY, _) = topology(grid)
    #= none:778 =#
    (Δxᶜᶜᵃ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ) = (grid.Δxᶜᶜᵃ, grid.Δxᶠᶜᵃ, grid.Δxᶜᶠᵃ, grid.Δxᶠᶠᵃ)
    #= none:779 =#
    (Δyᶜᶜᵃ, Δyᶜᶠᵃ, Δyᶠᶜᵃ, Δyᶠᶠᵃ) = (grid.Δyᶜᶜᵃ, grid.Δyᶜᶠᵃ, grid.Δyᶠᶜᵃ, grid.Δyᶠᶠᵃ)
    #= none:780 =#
    (Azᶜᶜᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ) = (grid.Azᶜᶜᵃ, grid.Azᶠᶜᵃ, grid.Azᶜᶠᵃ, grid.Azᶠᶠᵃ)
    #= none:782 =#
    metric_arrays = (Δxᶜᶜᵃ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δyᶜᶜᵃ, Δyᶜᶠᵃ, Δyᶠᶜᵃ, Δyᶠᶠᵃ, Azᶜᶜᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ)
    #= none:783 =#
    LXs = (Center, Face, Center, Face, Center, Center, Face, Face, Center, Face, Center, Face)
    #= none:784 =#
    LYs = (Center, Center, Face, Face, Center, Face, Center, Face, Center, Center, Face, Face)
    #= none:786 =#
    for (metric, LX, LY) = zip(metric_arrays, LXs, LYs)
        #= none:787 =#
        fill_metric_halo_regions_x!(metric, LX(), LY(), TX(), TY(), Nx, Ny, Hx, Hy)
        #= none:788 =#
        fill_metric_halo_regions_y!(metric, LX(), LY(), TX(), TY(), Nx, Ny, Hx, Hy)
        #= none:789 =#
        fill_metric_halo_corner_regions!(metric, LX(), LY(), TX(), TY(), Nx, Ny, Hx, Hy)
        #= none:790 =#
    end
    #= none:792 =#
    return nothing
end
#= none:795 =#
function lat_lon_to_cartesian(lat, lon, radius)
    #= none:795 =#
    #= none:796 =#
    abs(lat) > 90 && error("lat must be within -90 ≤ lat ≤ 90")
    #= none:798 =#
    return [lat_lon_to_x(lat, lon, radius), lat_lon_to_y(lat, lon, radius), lat_lon_to_z(lat, lon, radius)]
end
#= none:801 =#
lat_lon_to_x(lat, lon, radius) = begin
        #= none:801 =#
        radius * cosd(lon) * cosd(lat)
    end
#= none:802 =#
lat_lon_to_y(lat, lon, radius) = begin
        #= none:802 =#
        radius * sind(lon) * cosd(lat)
    end
#= none:803 =#
lat_lon_to_z(lat, lon, radius) = begin
        #= none:803 =#
        radius * sind(lat)
    end
#= none:807 =#
conformal_cubed_sphere_panel(FT::DataType; kwargs...) = begin
        #= none:807 =#
        conformal_cubed_sphere_panel(CPU(), FT; kwargs...)
    end
#= none:809 =#
function load_and_offset_cubed_sphere_data(file, FT, arch, field_name, loc, topo, N, H)
    #= none:809 =#
    #= none:811 =#
    data = on_architecture(arch, file[field_name])
    #= none:812 =#
    data = convert.(FT, data)
    #= none:814 =#
    return offset_data(data, loc[1:2], topo[1:2], N[1:2], H[1:2])
end
#= none:817 =#
function conformal_cubed_sphere_panel(filepath::AbstractString, architecture = CPU(), FT = Float64; panel, Nz, z, topology = (FullyConnected, FullyConnected, Bounded), radius = R_Earth, halo = (4, 4, 4), rotation = nothing)
    #= none:817 =#
    #= none:824 =#
    (TX, TY, TZ) = topology
    #= none:825 =#
    (Hx, Hy, Hz) = halo
    #= none:829 =#
    z_grid = RectilinearGrid(architecture, FT; size = Nz, z, topology = (Flat, Flat, topology[3]), halo = halo[3])
    #= none:831 =#
    zᵃᵃᶠ = z_grid.zᵃᵃᶠ
    #= none:832 =#
    zᵃᵃᶜ = z_grid.zᵃᵃᶜ
    #= none:833 =#
    Δzᵃᵃᶜ = z_grid.Δzᵃᵃᶜ
    #= none:834 =#
    Δzᵃᵃᶠ = z_grid.Δzᵃᵃᶠ
    #= none:835 =#
    Lz = z_grid.Lz
    #= none:839 =#
    file = (jldopen(filepath, "r"))["panel$(panel)"]
    #= none:841 =#
    (Nξ, Nη) = size(file["λᶠᶠᵃ"])
    #= none:842 =#
    (Hξ, Hη) = (halo[1], halo[2])
    #= none:843 =#
    Nξ -= 2Hξ
    #= none:844 =#
    Nη -= 2Hη
    #= none:846 =#
    N = (Nξ, Nη, Nz)
    #= none:847 =#
    H = halo
    #= none:849 =#
    loc_cc = (Center, Center)
    #= none:850 =#
    loc_fc = (Face, Center)
    #= none:851 =#
    loc_cf = (Center, Face)
    #= none:852 =#
    loc_ff = (Face, Face)
    #= none:854 =#
    λᶜᶜᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "λᶜᶜᵃ", loc_cc, topology, N, H)
    #= none:855 =#
    λᶠᶠᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "λᶠᶠᵃ", loc_ff, topology, N, H)
    #= none:857 =#
    φᶜᶜᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "φᶜᶜᵃ", loc_cc, topology, N, H)
    #= none:858 =#
    φᶠᶠᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "φᶠᶠᵃ", loc_ff, topology, N, H)
    #= none:860 =#
    Δxᶜᶜᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Δxᶜᶜᵃ", loc_cc, topology, N, H)
    #= none:861 =#
    Δxᶠᶜᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Δxᶠᶜᵃ", loc_fc, topology, N, H)
    #= none:862 =#
    Δxᶜᶠᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Δxᶜᶠᵃ", loc_cf, topology, N, H)
    #= none:863 =#
    Δxᶠᶠᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Δxᶠᶠᵃ", loc_ff, topology, N, H)
    #= none:865 =#
    Δyᶜᶜᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Δyᶜᶜᵃ", loc_cc, topology, N, H)
    #= none:866 =#
    Δyᶠᶜᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Δyᶠᶜᵃ", loc_fc, topology, N, H)
    #= none:867 =#
    Δyᶜᶠᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Δyᶜᶠᵃ", loc_cf, topology, N, H)
    #= none:868 =#
    Δyᶠᶠᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Δyᶠᶠᵃ", loc_ff, topology, N, H)
    #= none:870 =#
    Azᶜᶜᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Azᶜᶜᵃ", loc_cc, topology, N, H)
    #= none:871 =#
    Azᶠᶜᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Azᶠᶜᵃ", loc_fc, topology, N, H)
    #= none:872 =#
    Azᶜᶠᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Azᶜᶠᵃ", loc_cf, topology, N, H)
    #= none:873 =#
    Azᶠᶠᵃ = load_and_offset_cubed_sphere_data(file, FT, architecture, "Azᶠᶠᵃ", loc_ff, topology, N, H)
    #= none:876 =#
    Txᶠᶜ = total_length((loc_fc[1])(), (topology[1])(), N[1], H[1])
    #= none:877 =#
    Txᶜᶠ = total_length((loc_cf[1])(), (topology[1])(), N[1], H[1])
    #= none:878 =#
    Tyᶠᶜ = total_length((loc_fc[2])(), (topology[2])(), N[2], H[2])
    #= none:879 =#
    Tyᶜᶠ = total_length((loc_cf[2])(), (topology[2])(), N[2], H[2])
    #= none:881 =#
    λᶠᶜᵃ = offset_data(zeros(FT, architecture, Txᶠᶜ, Tyᶠᶜ), loc_fc, topology[1:2], N[1:2], H[1:2])
    #= none:882 =#
    λᶜᶠᵃ = offset_data(zeros(FT, architecture, Txᶜᶠ, Tyᶜᶠ), loc_cf, topology[1:2], N[1:2], H[1:2])
    #= none:883 =#
    φᶠᶜᵃ = offset_data(zeros(FT, architecture, Txᶠᶜ, Tyᶠᶜ), loc_fc, topology[1:2], N[1:2], H[1:2])
    #= none:884 =#
    φᶜᶠᵃ = offset_data(zeros(FT, architecture, Txᶜᶠ, Tyᶜᶠ), loc_cf, topology[1:2], N[1:2], H[1:2])
    #= none:886 =#
    (ξ, η) = ((-1, 1), (-1, 1))
    #= none:887 =#
    conformal_mapping = CubedSphereConformalMapping(ξ, η, rotation)
    #= none:889 =#
    return OrthogonalSphericalShellGrid{TX, TY, TZ}(architecture, Nξ, Nη, Nz, Hx, Hy, Hz, Lz, λᶜᶜᵃ, λᶠᶜᵃ, λᶜᶠᵃ, λᶠᶠᵃ, φᶜᶜᵃ, φᶠᶜᵃ, φᶜᶠᵃ, φᶠᶠᵃ, zᵃᵃᶜ, zᵃᵃᶠ, Δxᶜᶜᵃ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δyᶜᶜᵃ, Δyᶜᶠᵃ, Δyᶠᶜᵃ, Δyᶠᶠᵃ, Δzᵃᵃᶜ, Δzᵃᵃᶠ, Azᶜᶜᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ, radius, conformal_mapping)
end
#= none:901 =#
function on_architecture(arch::AbstractSerialArchitecture, grid::OrthogonalSphericalShellGrid)
    #= none:901 =#
    #= none:903 =#
    coordinates = (:λᶜᶜᵃ, :λᶠᶜᵃ, :λᶜᶠᵃ, :λᶠᶠᵃ, :φᶜᶜᵃ, :φᶠᶜᵃ, :φᶜᶠᵃ, :φᶠᶠᵃ, :zᵃᵃᶜ, :zᵃᵃᶠ)
    #= none:914 =#
    grid_spacings = (:Δxᶜᶜᵃ, :Δxᶠᶜᵃ, :Δxᶜᶠᵃ, :Δxᶠᶠᵃ, :Δyᶜᶜᵃ, :Δyᶜᶠᵃ, :Δyᶠᶜᵃ, :Δyᶠᶠᵃ, :Δzᵃᵃᶜ, :Δzᵃᵃᶜ)
    #= none:925 =#
    horizontal_areas = (:Azᶜᶜᵃ, :Azᶠᶜᵃ, :Azᶜᶠᵃ, :Azᶠᶠᵃ)
    #= none:930 =#
    coordinate_data = Tuple((on_architecture(arch, getproperty(grid, name)) for name = coordinates))
    #= none:931 =#
    grid_spacing_data = Tuple((on_architecture(arch, getproperty(grid, name)) for name = grid_spacings))
    #= none:932 =#
    horizontal_area_data = Tuple((on_architecture(arch, getproperty(grid, name)) for name = horizontal_areas))
    #= none:934 =#
    (TX, TY, TZ) = topology(grid)
    #= none:936 =#
    new_grid = OrthogonalSphericalShellGrid{TX, TY, TZ}(arch, grid.Nx, grid.Ny, grid.Nz, grid.Hx, grid.Hy, grid.Hz, grid.Lz, coordinate_data..., grid_spacing_data..., horizontal_area_data..., grid.radius, grid.conformal_mapping)
    #= none:946 =#
    return new_grid
end
#= none:949 =#
function Adapt.adapt_structure(to, grid::OrthogonalSphericalShellGrid)
    #= none:949 =#
    #= none:950 =#
    (TX, TY, TZ) = topology(grid)
    #= none:952 =#
    return OrthogonalSphericalShellGrid{TX, TY, TZ}(nothing, grid.Nx, grid.Ny, grid.Nz, grid.Hx, grid.Hy, grid.Hz, grid.Lz, adapt(to, grid.λᶜᶜᵃ), adapt(to, grid.λᶠᶜᵃ), adapt(to, grid.λᶜᶠᵃ), adapt(to, grid.λᶠᶠᵃ), adapt(to, grid.φᶜᶜᵃ), adapt(to, grid.φᶠᶜᵃ), adapt(to, grid.φᶜᶠᵃ), adapt(to, grid.φᶠᶠᵃ), adapt(to, grid.zᵃᵃᶜ), adapt(to, grid.zᵃᵃᶠ), adapt(to, grid.Δxᶜᶜᵃ), adapt(to, grid.Δxᶠᶜᵃ), adapt(to, grid.Δxᶜᶠᵃ), adapt(to, grid.Δxᶠᶠᵃ), adapt(to, grid.Δyᶜᶜᵃ), adapt(to, grid.Δyᶜᶠᵃ), adapt(to, grid.Δyᶠᶜᵃ), adapt(to, grid.Δyᶠᶠᵃ), adapt(to, grid.Δzᵃᵃᶜ), adapt(to, grid.Δzᵃᵃᶠ), adapt(to, grid.Azᶜᶜᵃ), adapt(to, grid.Azᶠᶜᵃ), adapt(to, grid.Azᶜᶠᵃ), adapt(to, grid.Azᶠᶠᵃ), grid.radius, adapt(to, grid.conformal_mapping))
end
#= none:984 =#
function Base.summary(grid::OrthogonalSphericalShellGrid)
    #= none:984 =#
    #= none:985 =#
    FT = eltype(grid)
    #= none:986 =#
    (TX, TY, TZ) = topology(grid)
    #= none:987 =#
    metric_computation = if isnothing(grid.Δxᶠᶜᵃ)
            "without precomputed metrics"
        else
            "with precomputed metrics"
        end
    #= none:989 =#
    return string(size_summary(size(grid)), " OrthogonalSphericalShellGrid{$(FT), $(TX), $(TY), $(TZ)} on ", summary(architecture(grid)), " with ", size_summary(halo_size(grid)), " halo", " and ", metric_computation)
end
#= none:995 =#
#= none:995 =# Core.@doc "    get_center_and_extents_of_shell(grid::OSSG)\n\nReturn the latitude-longitude coordinates of the center of the shell `(λ_center, φ_center)`\nand also the longitudinal and latitudinal extend of the shell `(extent_λ, extent_φ)`.\n" function get_center_and_extents_of_shell(grid::OSSG)
        #= none:1001 =#
        #= none:1002 =#
        (Nx, Ny, _) = size(grid)
        #= none:1006 =#
        i_center = Nx ÷ 2 + 1
        #= none:1007 =#
        j_center = Ny ÷ 2 + 1
        #= none:1009 =#
        if mod(Nx, 2) == 0
            #= none:1010 =#
            ℓx = Face()
        elseif #= none:1011 =# mod(Nx, 2) == 1
            #= none:1012 =#
            ℓx = Center()
        end
        #= none:1015 =#
        if mod(Ny, 2) == 0
            #= none:1016 =#
            ℓy = Face()
        elseif #= none:1017 =# mod(Ny, 2) == 1
            #= none:1018 =#
            ℓy = Center()
        end
        #= none:1022 =#
        λ_center = #= none:1022 =# CUDA.@allowscalar(λnode(i_center, j_center, 1, grid, ℓx, ℓy, Center()))
        #= none:1023 =#
        φ_center = #= none:1023 =# CUDA.@allowscalar(φnode(i_center, j_center, 1, grid, ℓx, ℓy, Center()))
        #= none:1026 =#
        if mod(Ny, 2) == 0
            #= none:1027 =#
            extent_λ = #= none:1027 =# CUDA.@allowscalar(maximum(rad2deg.(sum(grid.Δxᶜᶠᵃ[1:Nx, :], dims = 1))) / grid.radius)
        elseif #= none:1028 =# mod(Ny, 2) == 1
            #= none:1029 =#
            extent_λ = #= none:1029 =# CUDA.@allowscalar(maximum(rad2deg.(sum(grid.Δxᶜᶜᵃ[1:Nx, :], dims = 1))) / grid.radius)
        end
        #= none:1032 =#
        if mod(Nx, 2) == 0
            #= none:1033 =#
            extent_φ = #= none:1033 =# CUDA.@allowscalar(maximum(rad2deg.(sum(grid.Δyᶠᶜᵃ[:, 1:Ny], dims = 2))) / grid.radius)
        elseif #= none:1034 =# mod(Nx, 2) == 1
            #= none:1035 =#
            extent_φ = #= none:1035 =# CUDA.@allowscalar(maximum(rad2deg.(sum(grid.Δyᶠᶜᵃ[:, 1:Ny], dims = 2))) / grid.radius)
        end
        #= none:1038 =#
        return ((λ_center, φ_center), (extent_λ, extent_φ))
    end
#= none:1041 =#
function Base.show(io::IO, grid::OrthogonalSphericalShellGrid, withsummary = true)
    #= none:1041 =#
    #= none:1042 =#
    (TX, TY, TZ) = topology(grid)
    #= none:1043 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:1045 =#
    (Nx_face, Ny_face) = (total_length(Face(), TX(), Nx, 0), total_length(Face(), TY(), Ny, 0))
    #= none:1047 =#
    (λ₁, λ₂) = (minimum(grid.λᶠᶠᵃ[1:Nx_face, 1:Ny_face]), maximum(grid.λᶠᶠᵃ[1:Nx_face, 1:Ny_face]))
    #= none:1048 =#
    (φ₁, φ₂) = (minimum(grid.φᶠᶠᵃ[1:Nx_face, 1:Ny_face]), maximum(grid.φᶠᶠᵃ[1:Nx_face, 1:Ny_face]))
    #= none:1049 =#
    Ωz = domain((topology(grid, 3))(), Nz, grid.zᵃᵃᶠ)
    #= none:1051 =#
    ((λ_center, φ_center), (extent_λ, extent_φ)) = get_center_and_extents_of_shell(grid)
    #= none:1053 =#
    λ_center = round(λ_center, digits = 4)
    #= none:1054 =#
    φ_center = round(φ_center, digits = 4)
    #= none:1056 =#
    λ_center = ifelse(λ_center ≈ 0, 0.0, λ_center)
    #= none:1057 =#
    φ_center = ifelse(φ_center ≈ 0, 0.0, φ_center)
    #= none:1059 =#
    center_str = "centered at (λ, φ) = (" * prettysummary(λ_center) * ", " * prettysummary(φ_center) * ")"
    #= none:1061 =#
    if φ_center ≈ 90
        #= none:1062 =#
        center_str = "centered at: North Pole, (λ, φ) = (" * prettysummary(λ_center) * ", " * prettysummary(φ_center) * ")"
    end
    #= none:1065 =#
    if φ_center ≈ -90
        #= none:1066 =#
        center_str = "centered at: South Pole, (λ, φ) = (" * prettysummary(λ_center) * ", " * prettysummary(φ_center) * ")"
    end
    #= none:1069 =#
    λ_summary = "$(TX)  extent $(prettysummary(extent_λ)) degrees"
    #= none:1070 =#
    φ_summary = "$(TY)  extent $(prettysummary(extent_φ)) degrees"
    #= none:1071 =#
    z_summary = domain_summary(TZ(), "z", Ωz)
    #= none:1073 =#
    longest = max(length(λ_summary), length(φ_summary), length(z_summary))
    #= none:1075 =#
    padding_λ = if length(λ_summary) < longest
            " " ^ (longest - length(λ_summary))
        else
            ""
        end
    #= none:1076 =#
    padding_φ = if length(φ_summary) < longest
            " " ^ (longest - length(φ_summary))
        else
            ""
        end
    #= none:1078 =#
    λ_summary = "longitude: $(TX)  extent $(prettysummary(extent_λ)) degrees" * padding_λ * " " * coordinate_summary(TX, rad2deg.(grid.Δxᶠᶠᵃ[1:Nx_face, 1:Ny_face] ./ grid.radius), "λ")
    #= none:1081 =#
    φ_summary = "latitude:  $(TY)  extent $(prettysummary(extent_φ)) degrees" * padding_φ * " " * coordinate_summary(TY, rad2deg.(grid.Δyᶠᶠᵃ[1:Nx_face, 1:Ny_face] ./ grid.radius), "φ")
    #= none:1084 =#
    z_summary = "z:         " * dimension_summary(TZ(), "z", Ωz, grid.Δzᵃᵃᶜ, longest - length(z_summary))
    #= none:1086 =#
    if withsummary
        #= none:1087 =#
        print(io, summary(grid), "\n")
    end
    #= none:1090 =#
    return print(io, "├── ", center_str, "\n", "├── ", λ_summary, "\n", "├── ", φ_summary, "\n", "└── ", z_summary)
end
#= none:1096 =#
#= none:1096 =# @inline (z_domain(grid::OrthogonalSphericalShellGrid{FT, TX, TY, TZ}) where {FT, TX, TY, TZ}) = begin
            #= none:1096 =#
            domain(TZ, grid.Nz, grid.zᵃᵃᶠ)
        end
#= none:1097 =#
#= none:1097 =# @inline cpu_face_constructor_z(grid::ZRegOrthogonalSphericalShellGrid) = begin
            #= none:1097 =#
            z_domain(grid)
        end
#= none:1099 =#
function with_halo(new_halo, old_grid::OrthogonalSphericalShellGrid; rotation = nothing)
    #= none:1099 =#
    #= none:1101 =#
    size = (old_grid.Nx, old_grid.Ny, old_grid.Nz)
    #= none:1102 =#
    topo = topology(old_grid)
    #= none:1104 =#
    ξ = old_grid.conformal_mapping.ξ
    #= none:1105 =#
    η = old_grid.conformal_mapping.η
    #= none:1107 =#
    z = cpu_face_constructor_z(old_grid)
    #= none:1109 =#
    new_grid = conformal_cubed_sphere_panel(architecture(old_grid), eltype(old_grid); size, z, ξ, η, topology = topo, radius = old_grid.radius, halo = new_halo, rotation)
    #= none:1116 =#
    return new_grid
end
#= none:1119 =#
function nodes(grid::OSSG, ℓx, ℓy, ℓz; reshape = false, with_halos = false)
    #= none:1119 =#
    #= none:1120 =#
    λ = λnodes(grid, ℓx, ℓy, ℓz; with_halos)
    #= none:1121 =#
    φ = φnodes(grid, ℓx, ℓy, ℓz; with_halos)
    #= none:1122 =#
    z = znodes(grid, ℓx, ℓy, ℓz; with_halos)
    #= none:1124 =#
    if reshape
        #= none:1126 =#
        N = (size(λ)..., size(z)...)
        #= none:1127 =#
        λ = Base.reshape(λ, N[1], Ν[2], 1)
        #= none:1128 =#
        φ = Base.reshape(φ, N[1], N[2], 1)
        #= none:1129 =#
        z = Base.reshape(z, 1, 1, N[3])
    end
    #= none:1132 =#
    return (λ, φ, z)
end
#= none:1135 =#
#= none:1135 =# @inline λnodes(grid::OSSG, ℓx::Face, ℓy::Face; with_halos = false) = begin
            #= none:1135 =#
            if with_halos
                grid.λᶠᶠᵃ
            else
                view(grid.λᶠᶠᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1137 =#
#= none:1137 =# @inline λnodes(grid::OSSG, ℓx::Face, ℓy::Center; with_halos = false) = begin
            #= none:1137 =#
            if with_halos
                grid.λᶠᶜᵃ
            else
                view(grid.λᶠᶜᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1139 =#
#= none:1139 =# @inline λnodes(grid::OSSG, ℓx::Center, ℓy::Face; with_halos = false) = begin
            #= none:1139 =#
            if with_halos
                grid.λᶜᶠᵃ
            else
                view(grid.λᶜᶠᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1141 =#
#= none:1141 =# @inline λnodes(grid::OSSG, ℓx::Center, ℓy::Center; with_halos = false) = begin
            #= none:1141 =#
            if with_halos
                grid.λᶜᶜᵃ
            else
                view(grid.λᶜᶜᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1144 =#
#= none:1144 =# @inline φnodes(grid::OSSG, ℓx::Face, ℓy::Face; with_halos = false) = begin
            #= none:1144 =#
            if with_halos
                grid.φᶠᶠᵃ
            else
                view(grid.φᶠᶠᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1146 =#
#= none:1146 =# @inline φnodes(grid::OSSG, ℓx::Face, ℓy::Center; with_halos = false) = begin
            #= none:1146 =#
            if with_halos
                grid.φᶠᶜᵃ
            else
                view(grid.φᶠᶜᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1148 =#
#= none:1148 =# @inline φnodes(grid::OSSG, ℓx::Center, ℓy::Face; with_halos = false) = begin
            #= none:1148 =#
            if with_halos
                grid.φᶜᶠᵃ
            else
                view(grid.φᶜᶠᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1150 =#
#= none:1150 =# @inline φnodes(grid::OSSG, ℓx::Center, ℓy::Center; with_halos = false) = begin
            #= none:1150 =#
            if with_halos
                grid.φᶜᶜᵃ
            else
                view(grid.φᶜᶜᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1153 =#
#= none:1153 =# @inline xnodes(grid::OSSG, ℓx, ℓy; with_halos = false) = begin
            #= none:1153 =#
            (grid.radius * deg2rad.(λnodes(grid, ℓx, ℓy; with_halos = with_halos))) .* hack_cosd.(φnodes(grid, ℓx, ℓy; with_halos = with_halos))
        end
#= none:1154 =#
#= none:1154 =# @inline ynodes(grid::OSSG, ℓx, ℓy; with_halos = false) = begin
            #= none:1154 =#
            grid.radius * deg2rad.(φnodes(grid, ℓx, ℓy; with_halos = with_halos))
        end
#= none:1156 =#
#= none:1156 =# @inline znodes(grid::OSSG, ℓz::Face; with_halos = false) = begin
            #= none:1156 =#
            if with_halos
                grid.zᵃᵃᶠ
            else
                view(grid.zᵃᵃᶠ, interior_indices(ℓz, (topology(grid, 3))(), grid.Nz))
            end
        end
#= none:1158 =#
#= none:1158 =# @inline znodes(grid::OSSG, ℓz::Center; with_halos = false) = begin
            #= none:1158 =#
            if with_halos
                grid.zᵃᵃᶜ
            else
                view(grid.zᵃᵃᶜ, interior_indices(ℓz, (topology(grid, 3))(), grid.Nz))
            end
        end
#= none:1162 =#
#= none:1162 =# @inline λnodes(grid::OSSG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:1162 =#
            λnodes(grid, ℓx, ℓy; with_halos)
        end
#= none:1163 =#
#= none:1163 =# @inline φnodes(grid::OSSG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:1163 =#
            φnodes(grid, ℓx, ℓy; with_halos)
        end
#= none:1164 =#
#= none:1164 =# @inline znodes(grid::OSSG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:1164 =#
            znodes(grid, ℓz; with_halos)
        end
#= none:1165 =#
#= none:1165 =# @inline xnodes(grid::OSSG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:1165 =#
            xnodes(grid, ℓx, ℓy; with_halos)
        end
#= none:1166 =#
#= none:1166 =# @inline ynodes(grid::OSSG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:1166 =#
            ynodes(grid, ℓx, ℓy; with_halos)
        end
#= none:1168 =#
#= none:1168 =# @inline λnode(i, j, grid::OSSG, ::Center, ::Center) = begin
            #= none:1168 =#
            #= none:1168 =# @inbounds grid.λᶜᶜᵃ[i, j]
        end
#= none:1169 =#
#= none:1169 =# @inline λnode(i, j, grid::OSSG, ::Face, ::Center) = begin
            #= none:1169 =#
            #= none:1169 =# @inbounds grid.λᶠᶜᵃ[i, j]
        end
#= none:1170 =#
#= none:1170 =# @inline λnode(i, j, grid::OSSG, ::Center, ::Face) = begin
            #= none:1170 =#
            #= none:1170 =# @inbounds grid.λᶜᶠᵃ[i, j]
        end
#= none:1171 =#
#= none:1171 =# @inline λnode(i, j, grid::OSSG, ::Face, ::Face) = begin
            #= none:1171 =#
            #= none:1171 =# @inbounds grid.λᶠᶠᵃ[i, j]
        end
#= none:1173 =#
#= none:1173 =# @inline φnode(i, j, grid::OSSG, ::Center, ::Center) = begin
            #= none:1173 =#
            #= none:1173 =# @inbounds grid.φᶜᶜᵃ[i, j]
        end
#= none:1174 =#
#= none:1174 =# @inline φnode(i, j, grid::OSSG, ::Face, ::Center) = begin
            #= none:1174 =#
            #= none:1174 =# @inbounds grid.φᶠᶜᵃ[i, j]
        end
#= none:1175 =#
#= none:1175 =# @inline φnode(i, j, grid::OSSG, ::Center, ::Face) = begin
            #= none:1175 =#
            #= none:1175 =# @inbounds grid.φᶜᶠᵃ[i, j]
        end
#= none:1176 =#
#= none:1176 =# @inline φnode(i, j, grid::OSSG, ::Face, ::Face) = begin
            #= none:1176 =#
            #= none:1176 =# @inbounds grid.φᶠᶠᵃ[i, j]
        end
#= none:1178 =#
#= none:1178 =# @inline xnode(i, j, grid::OSSG, ℓx, ℓy) = begin
            #= none:1178 =#
            grid.radius * deg2rad(λnode(i, j, grid, ℓx, ℓy)) * hack_cosd(φnode(i, j, grid, ℓx, ℓy))
        end
#= none:1179 =#
#= none:1179 =# @inline ynode(i, j, grid::OSSG, ℓx, ℓy) = begin
            #= none:1179 =#
            grid.radius * deg2rad(φnode(i, j, grid, ℓx, ℓy))
        end
#= none:1181 =#
#= none:1181 =# @inline znode(k, grid::OSSG, ::Center) = begin
            #= none:1181 =#
            #= none:1181 =# @inbounds grid.zᵃᵃᶜ[k]
        end
#= none:1182 =#
#= none:1182 =# @inline znode(k, grid::OSSG, ::Face) = begin
            #= none:1182 =#
            #= none:1182 =# @inbounds grid.zᵃᵃᶠ[k]
        end
#= none:1185 =#
#= none:1185 =# @inline λnode(i, j, k, grid::OSSG, ℓx, ℓy, ℓz) = begin
            #= none:1185 =#
            λnode(i, j, grid, ℓx, ℓy)
        end
#= none:1186 =#
#= none:1186 =# @inline φnode(i, j, k, grid::OSSG, ℓx, ℓy, ℓz) = begin
            #= none:1186 =#
            φnode(i, j, grid, ℓx, ℓy)
        end
#= none:1187 =#
#= none:1187 =# @inline znode(i, j, k, grid::OSSG, ℓx, ℓy, ℓz) = begin
            #= none:1187 =#
            znode(k, grid, ℓz)
        end
#= none:1188 =#
#= none:1188 =# @inline xnode(i, j, k, grid::OSSG, ℓx, ℓy, ℓz) = begin
            #= none:1188 =#
            xnode(i, j, grid, ℓx, ℓy)
        end
#= none:1189 =#
#= none:1189 =# @inline ynode(i, j, k, grid::OSSG, ℓx, ℓy, ℓz) = begin
            #= none:1189 =#
            ynode(i, j, grid, ℓx, ℓy)
        end
#= none:1192 =#
#= none:1192 =# @inline ξnode(i, j, k, grid::OSSG, ℓx, ℓy, ℓz) = begin
            #= none:1192 =#
            λnode(i, j, grid, ℓx, ℓy)
        end
#= none:1193 =#
#= none:1193 =# @inline ηnode(i, j, k, grid::OSSG, ℓx, ℓy, ℓz) = begin
            #= none:1193 =#
            φnode(i, j, grid, ℓx, ℓy)
        end
#= none:1194 =#
#= none:1194 =# @inline rnode(i, j, k, grid::OSSG, ℓx, ℓy, ℓz) = begin
            #= none:1194 =#
            znode(k, grid, ℓz)
        end
#= none:1196 =#
ξname(::OSSG) = begin
        #= none:1196 =#
        :λ
    end
#= none:1197 =#
ηname(::OSSG) = begin
        #= none:1197 =#
        :φ
    end
#= none:1198 =#
rname(::OSSG) = begin
        #= none:1198 =#
        :z
    end
#= none:1204 =#
#= none:1204 =# @inline xspacings(grid::OSSG, ℓx::Center, ℓy::Center; with_halos = false) = begin
            #= none:1204 =#
            if with_halos
                grid.Δxᶜᶜᵃ
            else
                view(grid.Δxᶜᶜᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1206 =#
#= none:1206 =# @inline xspacings(grid::OSSG, ℓx::Face, ℓy::Center; with_halos = false) = begin
            #= none:1206 =#
            if with_halos
                grid.Δxᶠᶜᵃ
            else
                view(grid.Δxᶠᶜᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1208 =#
#= none:1208 =# @inline xspacings(grid::OSSG, ℓx::Center, ℓy::Face; with_halos = false) = begin
            #= none:1208 =#
            if with_halos
                grid.Δxᶜᶠᵃ
            else
                view(grid.Δxᶜᶠᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1210 =#
#= none:1210 =# @inline xspacings(grid::OSSG, ℓx::Face, ℓy::Face; with_halos = false) = begin
            #= none:1210 =#
            if with_halos
                grid.Δxᶠᶠᵃ
            else
                view(grid.Δxᶠᶠᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1213 =#
#= none:1213 =# @inline yspacings(grid::OSSG, ℓx::Center, ℓy::Center; with_halos = false) = begin
            #= none:1213 =#
            if with_halos
                grid.Δyᶜᶜᵃ
            else
                view(grid.Δyᶜᶜᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1215 =#
#= none:1215 =# @inline yspacings(grid::OSSG, ℓx::Face, ℓy::Center; with_halos = false) = begin
            #= none:1215 =#
            if with_halos
                grid.Δyᶠᶜᵃ
            else
                view(grid.Δyᶠᶜᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1217 =#
#= none:1217 =# @inline yspacings(grid::OSSG, ℓx::Center, ℓy::Face; with_halos = false) = begin
            #= none:1217 =#
            if with_halos
                grid.Δyᶜᶠᵃ
            else
                view(grid.Δyᶜᶠᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1219 =#
#= none:1219 =# @inline yspacings(grid::OSSG, ℓx::Face, ℓy::Face; with_halos = false) = begin
            #= none:1219 =#
            if with_halos
                grid.Δyᶠᶠᵃ
            else
                view(grid.Δyᶠᶠᵃ, interior_indices(ℓx, (topology(grid, 1))(), grid.Nx), interior_indices(ℓy, (topology(grid, 2))(), grid.Ny))
            end
        end
#= none:1222 =#
#= none:1222 =# @inline zspacings(grid::OSSG, ℓz::Center; with_halos = false) = begin
            #= none:1222 =#
            if with_halos
                grid.Δzᵃᵃᶜ
            else
                view(grid.Δzᵃᵃᶜ, interior_indices(ℓz, (topology(grid, 3))(), grid.Nz))
            end
        end
#= none:1224 =#
#= none:1224 =# @inline zspacings(grid::ZRegOSSG, ℓz::Center; with_halos = false) = begin
            #= none:1224 =#
            grid.Δzᵃᵃᶜ
        end
#= none:1225 =#
#= none:1225 =# @inline zspacings(grid::OSSG, ℓz::Face; with_halos = false) = begin
            #= none:1225 =#
            if with_halos
                grid.Δzᵃᵃᶠ
            else
                view(grid.Δzᵃᵃᶠ, interior_indices(ℓz, (topology(grid, 3))(), grid.Nz))
            end
        end
#= none:1227 =#
#= none:1227 =# @inline zspacings(grid::ZRegOSSG, ℓz::Face; with_halos = false) = begin
            #= none:1227 =#
            grid.Δzᵃᵃᶠ
        end
#= none:1229 =#
#= none:1229 =# @inline xspacings(grid::OSSG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:1229 =#
            xspacings(grid, ℓx, ℓy; with_halos)
        end
#= none:1230 =#
#= none:1230 =# @inline yspacings(grid::OSSG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:1230 =#
            yspacings(grid, ℓx, ℓy; with_halos)
        end
#= none:1231 =#
#= none:1231 =# @inline zspacings(grid::OSSG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:1231 =#
            zspacings(grid, ℓz; with_halos)
        end