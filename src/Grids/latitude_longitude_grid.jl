
#= none:1 =#
using KernelAbstractions: @kernel, @index
#= none:3 =#
struct LatitudeLongitudeGrid{FT, TX, TY, TZ, M, MY, FX, FY, FZ, VX, VY, VZ, Arch} <: AbstractHorizontallyCurvilinearGrid{FT, TX, TY, TZ, Arch}
    #= none:4 =#
    architecture::Arch
    #= none:5 =#
    Nx::Int
    #= none:6 =#
    Ny::Int
    #= none:7 =#
    Nz::Int
    #= none:8 =#
    Hx::Int
    #= none:9 =#
    Hy::Int
    #= none:10 =#
    Hz::Int
    #= none:11 =#
    Lx::FT
    #= none:12 =#
    Ly::FT
    #= none:13 =#
    Lz::FT
    #= none:16 =#
    Δλᶠᵃᵃ::FX
    #= none:17 =#
    Δλᶜᵃᵃ::FX
    #= none:18 =#
    λᶠᵃᵃ::VX
    #= none:19 =#
    λᶜᵃᵃ::VX
    #= none:20 =#
    Δφᵃᶠᵃ::FY
    #= none:21 =#
    Δφᵃᶜᵃ::FY
    #= none:22 =#
    φᵃᶠᵃ::VY
    #= none:23 =#
    φᵃᶜᵃ::VY
    #= none:24 =#
    Δzᵃᵃᶠ::FZ
    #= none:25 =#
    Δzᵃᵃᶜ::FZ
    #= none:26 =#
    zᵃᵃᶠ::VZ
    #= none:27 =#
    zᵃᵃᶜ::VZ
    #= none:29 =#
    Δxᶠᶜᵃ::M
    #= none:30 =#
    Δxᶜᶠᵃ::M
    #= none:31 =#
    Δxᶠᶠᵃ::M
    #= none:32 =#
    Δxᶜᶜᵃ::M
    #= none:33 =#
    Δyᶠᶜᵃ::MY
    #= none:34 =#
    Δyᶜᶠᵃ::MY
    #= none:35 =#
    Azᶠᶜᵃ::M
    #= none:36 =#
    Azᶜᶠᵃ::M
    #= none:37 =#
    Azᶠᶠᵃ::M
    #= none:38 =#
    Azᶜᶜᵃ::M
    #= none:40 =#
    radius::FT
    #= none:42 =#
    (LatitudeLongitudeGrid{TX, TY, TZ}(architecture::Arch, Nλ, Nφ, Nz, Hλ, Hφ, Hz, Lλ::FT, Lφ::FT, Lz::FT, Δλᶠᵃᵃ::FX, Δλᶜᵃᵃ::FX, λᶠᵃᵃ::VX, λᶜᵃᵃ::VX, Δφᵃᶠᵃ::FY, Δφᵃᶜᵃ::FY, φᵃᶠᵃ::VY, φᵃᶜᵃ::VY, Δzᵃᵃᶠ::FZ, Δzᵃᵃᶜ::FZ, zᵃᵃᶠ::VZ, zᵃᵃᶜ::VZ, Δxᶠᶜᵃ::M, Δxᶜᶠᵃ::M, Δxᶠᶠᵃ::M, Δxᶜᶜᵃ::M, Δyᶠᶜᵃ::MY, Δyᶜᶠᵃ::MY, Azᶠᶜᵃ::M, Azᶜᶠᵃ::M, Azᶠᶠᵃ::M, Azᶜᶜᵃ::M, radius::FT) where {Arch, FT, TX, TY, TZ, FX, FY, FZ, VX, VY, VZ, M, MY}) = begin
            #= none:42 =#
            new{FT, TX, TY, TZ, M, MY, FX, FY, FZ, VX, VY, VZ, Arch}(architecture, Nλ, Nφ, Nz, Hλ, Hφ, Hz, Lλ, Lφ, Lz, Δλᶠᵃᵃ, Δλᶜᵃᵃ, λᶠᵃᵃ, λᶜᵃᵃ, Δφᵃᶠᵃ, Δφᵃᶜᵃ, φᵃᶠᵃ, φᵃᶜᵃ, Δzᵃᵃᶠ, Δzᵃᵃᶜ, zᵃᵃᶠ, zᵃᵃᶜ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δxᶜᶜᵃ, Δyᶠᶜᵃ, Δyᶜᶠᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ, Azᶜᶜᵃ, radius)
        end
end
#= none:72 =#
const LLG = LatitudeLongitudeGrid
#= none:73 =#
const XRegularLLG = LatitudeLongitudeGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Number}
#= none:74 =#
const YRegularLLG = LatitudeLongitudeGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Number}
#= none:75 =#
const ZRegularLLG = LatitudeLongitudeGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Number}
#= none:76 =#
const HRegularLLG = LatitudeLongitudeGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Number, <:Number}
#= none:77 =#
const HNonRegularLLG = LatitudeLongitudeGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:AbstractArray, <:AbstractArray}
#= none:78 =#
const YNonRegularLLG = LatitudeLongitudeGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Number, <:AbstractArray}
#= none:80 =#
regular_dimensions(::ZRegularLLG) = begin
        #= none:80 =#
        tuple(3)
    end
#= none:82 =#
#= none:82 =# Core.@doc "    LatitudeLongitudeGrid([architecture = CPU(), FT = Float64];\n                          size,\n                          longitude,\n                          latitude,\n                          z = nothing,\n                          radius = R_Earth,\n                          topology = nothing,\n                          precompute_metrics = true,\n                          halo = nothing)\n\nCreates a `LatitudeLongitudeGrid` with coordinates `(λ, φ, z)` denoting longitude, latitude,\nand vertical coordinate respectively.\n\nPositional arguments\n====================\n\n- `architecture`: Specifies whether arrays of coordinates and spacings are stored\n                  on the CPU or GPU. Default: `CPU()`.\n\n- `FT` : Floating point data type. Default: `Float64`.\n\nKeyword arguments\n=================\n\n- `size` (required): A 3-tuple prescribing the number of grid points each direction.\n\n- `longitude` (required), `latitude` (required), `z` (default: `nothing`):\n  Each is either a:\n  1. 2-tuple that specify the end points of the domain,\n  2. one-dimensional array specifying the cell interface locations, or\n  3. a single-argument function that takes an index and returns cell interface location.\n\n  **Note**: the latitude and longitude coordinates extents are expected in degrees.\n\n- `radius`: The radius of the sphere the grid lives on. By default is equal to the radius of Earth.\n\n- `topology`: Tuple of topologies (`Flat`, `Bounded`, `Periodic`) for each direction. The vertical\n              `topology[3]` must be `Bounded`, while the latitude-longitude topologies can be\n              `Bounded`, `Periodic`, or `Flat`. If no topology is provided then, by default, the\n              topology is (`Periodic`, `Bounded`, `Bounded`) if the latitudinal extent is 360 degrees\n              or (`Bounded`, `Bounded`, `Bounded`) otherwise.\n\n- `precompute_metrics`: Boolean specifying whether to precompute horizontal spacings and areas.\n                        Default: `true`. When `false`, horizontal spacings and areas are computed\n                        on-the-fly during a simulation.\n\n- `halo`: A 3-tuple of integers specifying the size of the halo region of cells surrounding\n          the physical interior. The default is 3 halo cells in every direction.\n\nExamples\n========\n\n* A default grid with `Float64` type:\n\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = LatitudeLongitudeGrid(size=(36, 34, 25),\n                                    longitude = (-180, 180),\n                                    latitude = (-85, 85),\n                                    z = (-1000, 0))\n36×34×25 LatitudeLongitudeGrid{Float64, Periodic, Bounded, Bounded} on CPU with 3×3×3 halo and with precomputed metrics\n├── longitude: Periodic λ ∈ [-180.0, 180.0) regularly spaced with Δλ=10.0\n├── latitude:  Bounded  φ ∈ [-85.0, 85.0]   regularly spaced with Δφ=5.0\n└── z:         Bounded  z ∈ [-1000.0, 0.0]  regularly spaced with Δz=40.0\n```\n\n* A bounded spherical sector with cell interfaces stretched hyperbolically near the top:\n\n```jldoctest\njulia> using Oceananigans\n\njulia> σ = 1.1; # stretching factor\n\njulia> Nz = 24; # vertical resolution\n\njulia> Lz = 1000; # depth (m)\n\njulia> hyperbolically_spaced_faces(k) = - Lz * (1 - tanh(σ * (k - 1) / Nz) / tanh(σ));\n\njulia> grid = LatitudeLongitudeGrid(size=(36, 34, Nz),\n                                    longitude = (-180, 180),\n                                    latitude = (-20, 20),\n                                    z = hyperbolically_spaced_faces,\n                                    topology = (Bounded, Bounded, Bounded))\n36×34×24 LatitudeLongitudeGrid{Float64, Bounded, Bounded, Bounded} on CPU with 3×3×3 halo and with precomputed metrics\n├── longitude: Bounded  λ ∈ [-180.0, 180.0] regularly spaced with Δλ=10.0\n├── latitude:  Bounded  φ ∈ [-20.0, 20.0]   regularly spaced with Δφ=1.17647\n└── z:         Bounded  z ∈ [-1000.0, -0.0] variably spaced with min(Δz)=21.3342, max(Δz)=57.2159\n```\n" function LatitudeLongitudeGrid(architecture::AbstractArchitecture = CPU(), FT::DataType = Float64; size, longitude = nothing, latitude = nothing, z = nothing, radius = R_Earth, topology = nothing, precompute_metrics = true, halo = nothing)
        #= none:174 =#
        #= none:185 =#
        if architecture == GPU() && !true
            #= none:186 =#
            throw(ArgumentError("Cannot create a GPU grid. No CUDA-enabled GPU was detected!"))
        end
        #= none:189 =#
        (topology, size, halo, latitude, longitude, z, precompute_metrics) = validate_lat_lon_grid_args(topology, size, halo, FT, latitude, longitude, z, precompute_metrics)
        #= none:192 =#
        (Nλ, Nφ, Nz) = size
        #= none:193 =#
        (Hλ, Hφ, Hz) = halo
        #= none:198 =#
        (TX, TY, TZ) = topology
        #= none:200 =#
        (Lλ, λᶠᵃᵃ, λᶜᵃᵃ, Δλᶠᵃᵃ, Δλᶜᵃᵃ) = generate_coordinate(FT, TX(), Nλ, Hλ, longitude, :longitude, architecture)
        #= none:201 =#
        (Lφ, φᵃᶠᵃ, φᵃᶜᵃ, Δφᵃᶠᵃ, Δφᵃᶜᵃ) = generate_coordinate(FT, TY(), Nφ, Hφ, latitude, :latitude, architecture)
        #= none:202 =#
        (Lz, zᵃᵃᶠ, zᵃᵃᶜ, Δzᵃᵃᶠ, Δzᵃᵃᶜ) = generate_coordinate(FT, TZ(), Nz, Hz, z, :z, architecture)
        #= none:204 =#
        preliminary_grid = LatitudeLongitudeGrid{TX, TY, TZ}(architecture, Nλ, Nφ, Nz, Hλ, Hφ, Hz, Lλ, Lφ, Lz, Δλᶠᵃᵃ, Δλᶜᵃᵃ, λᶠᵃᵃ, λᶜᵃᵃ, Δφᵃᶠᵃ, Δφᵃᶜᵃ, φᵃᶠᵃ, φᵃᶜᵃ, Δzᵃᵃᶠ, Δzᵃᵃᶜ, zᵃᵃᶠ, zᵃᵃᶜ, (nothing for i = 1:10)..., FT(radius))
        #= none:213 =#
        if !precompute_metrics
            #= none:214 =#
            return preliminary_grid
        else
            #= none:216 =#
            return with_precomputed_metrics(preliminary_grid)
        end
    end
#= none:222 =#
LatitudeLongitudeGrid(FT::DataType; kwargs...) = begin
        #= none:222 =#
        LatitudeLongitudeGrid(CPU(), FT; kwargs...)
    end
#= none:224 =#
#= none:224 =# Core.@doc " Return a reproduction of `grid` with precomputed metric terms. " function with_precomputed_metrics(grid)
        #= none:225 =#
        #= none:226 =#
        (Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δxᶜᶜᵃ, Δyᶠᶜᵃ, Δyᶜᶠᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ, Azᶜᶜᵃ) = allocate_metrics(grid)
        #= none:229 =#
        arch = grid.architecture
        #= none:230 =#
        dev = Architectures.device(arch)
        #= none:231 =#
        (workgroup, worksize) = (metric_workgroup(grid), metric_worksize(grid))
        #= none:232 =#
        loop! = compute_Δx_Az!(dev, workgroup, worksize)
        #= none:233 =#
        loop!(grid, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δxᶜᶜᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ, Azᶜᶜᵃ)
        #= none:236 =#
        if !(grid isa YRegularLLG)
            #= none:237 =#
            loop! = compute_Δy!(dev, 16, length(grid.Δφᵃᶜᵃ) - 1)
            #= none:238 =#
            loop!(grid, Δyᶠᶜᵃ, Δyᶜᶠᵃ)
        end
        #= none:241 =#
        (Nλ, Nφ, Nz) = size(grid)
        #= none:242 =#
        (Hλ, Hφ, Hz) = halo_size(grid)
        #= none:243 =#
        (TX, TY, TZ) = topology(grid)
        #= none:245 =#
        return LatitudeLongitudeGrid{TX, TY, TZ}(architecture(grid), Nλ, Nφ, Nz, Hλ, Hφ, Hz, grid.Lx, grid.Ly, grid.Lz, grid.Δλᶠᵃᵃ, grid.Δλᶜᵃᵃ, grid.λᶠᵃᵃ, grid.λᶜᵃᵃ, grid.Δφᵃᶠᵃ, grid.Δφᵃᶜᵃ, grid.φᵃᶠᵃ, grid.φᵃᶜᵃ, grid.Δzᵃᵃᶠ, grid.Δzᵃᵃᶜ, grid.zᵃᵃᶠ, grid.zᵃᵃᶜ, Δxᶠᶜᵃ, Δxᶜᶠᵃ, Δxᶠᶠᵃ, Δxᶜᶜᵃ, Δyᶠᶜᵃ, Δyᶜᶠᵃ, Azᶠᶜᵃ, Azᶜᶠᵃ, Azᶠᶠᵃ, Azᶜᶜᵃ, grid.radius)
    end
#= none:256 =#
function validate_lat_lon_grid_args(topology, size, halo, FT, latitude, longitude, z, precompute_metrics)
    #= none:256 =#
    #= none:257 =#
    if !(isnothing(topology))
        #= none:258 =#
        (TX, TY, TZ) = validate_topology(topology)
        #= none:259 =#
        (Nλ, Nφ, Nz) = (size = validate_size(TX, TY, TZ, size))
    else
        #= none:261 =#
        (Nλ, Nφ, Nz) = size
        #= none:262 =#
        (λ₁, λ₂) = get_domain_extent(longitude, Nλ)
        #= none:264 =#
        Lλ = λ₂ - λ₁
        #= none:265 =#
        TX = if Lλ == 360
                Periodic
            else
                Bounded
            end
        #= none:266 =#
        TY = Bounded
        #= none:267 =#
        TZ = Bounded
    end
    #= none:270 =#
    if TY() isa Periodic
        #= none:271 =#
        throw(ArgumentError("LatitudeLongitudeGrid cannot be Periodic in latitude!"))
    end
    #= none:275 =#
    (λ₁, λ₂) = get_domain_extent(longitude, Nλ)
    #= none:276 =#
    λ₂ - λ₁ ≤ 360 || throw(ArgumentError("Longitudinal extent cannot be greater than 360 degrees."))
    #= none:277 =#
    λ₁ <= λ₂ || throw(ArgumentError("Longitudes must increase west to east."))
    #= none:279 =#
    (φ₁, φ₂) = get_domain_extent(latitude, Nφ)
    #= none:280 =#
    -90 <= φ₁ || throw(ArgumentError("The southernmost latitude cannot be less than -90 degrees."))
    #= none:281 =#
    φ₂ <= 90 || throw(ArgumentError("The northern latitude cannot be less than -90 degrees."))
    #= none:282 =#
    φ₁ <= φ₂ || throw(ArgumentError("Latitudes must increase south to north."))
    #= none:284 =#
    if TX == Flat || TY == Flat
        #= none:285 =#
        precompute_metrics = false
    end
    #= none:288 =#
    longitude = validate_dimension_specification(TX, longitude, :longitude, Nλ, FT)
    #= none:289 =#
    latitude = validate_dimension_specification(TY, latitude, :latitude, Nφ, FT)
    #= none:290 =#
    z = validate_dimension_specification(TZ, z, :z, Nz, FT)
    #= none:292 =#
    halo = validate_halo(TX, TY, TZ, size, halo)
    #= none:293 =#
    topology = (TX, TY, TZ)
    #= none:295 =#
    return (topology, size, halo, latitude, longitude, z, precompute_metrics)
end
#= none:298 =#
function Base.summary(grid::LatitudeLongitudeGrid)
    #= none:298 =#
    #= none:299 =#
    FT = eltype(grid)
    #= none:300 =#
    (TX, TY, TZ) = topology(grid)
    #= none:301 =#
    metric_computation = if isnothing(grid.Δxᶠᶜᵃ)
            "without precomputed metrics"
        else
            "with precomputed metrics"
        end
    #= none:303 =#
    return string(size_summary(size(grid)), " LatitudeLongitudeGrid{$(FT), $(TX), $(TY), $(TZ)} on ", summary(architecture(grid)), " with ", size_summary(halo_size(grid)), " halo", " and ", metric_computation)
end
#= none:309 =#
function Base.show(io::IO, grid::LatitudeLongitudeGrid, withsummary = true)
    #= none:309 =#
    #= none:310 =#
    (TX, TY, TZ) = topology(grid)
    #= none:312 =#
    Ωλ = domain(TX(), size(grid, 1), grid.λᶠᵃᵃ)
    #= none:313 =#
    Ωφ = domain(TY(), size(grid, 2), grid.φᵃᶠᵃ)
    #= none:314 =#
    Ωz = domain(TZ(), size(grid, 3), grid.zᵃᵃᶠ)
    #= none:316 =#
    x_summary = domain_summary(TX(), "λ", Ωλ)
    #= none:317 =#
    y_summary = domain_summary(TY(), "φ", Ωφ)
    #= none:318 =#
    z_summary = domain_summary(TZ(), "z", Ωz)
    #= none:320 =#
    longest = max(length(x_summary), length(y_summary), length(z_summary))
    #= none:322 =#
    x_summary = "longitude: " * dimension_summary(TX(), "λ", Ωλ, grid.Δλᶜᵃᵃ, longest - length(x_summary))
    #= none:323 =#
    y_summary = "latitude:  " * dimension_summary(TY(), "φ", Ωφ, grid.Δφᵃᶜᵃ, longest - length(y_summary))
    #= none:324 =#
    z_summary = "z:         " * dimension_summary(TZ(), "z", Ωz, grid.Δzᵃᵃᶜ, longest - length(z_summary))
    #= none:326 =#
    if withsummary
        #= none:327 =#
        print(io, summary(grid), "\n")
    end
    #= none:330 =#
    return print(io, "├── ", x_summary, "\n", "├── ", y_summary, "\n", "└── ", z_summary)
end
#= none:335 =#
#= none:335 =# @inline x_domain(grid::LLG) = begin
            #= none:335 =#
            domain((topology(grid, 1))(), grid.Nx, grid.λᶠᵃᵃ)
        end
#= none:336 =#
#= none:336 =# @inline y_domain(grid::LLG) = begin
            #= none:336 =#
            domain((topology(grid, 2))(), grid.Ny, grid.φᵃᶠᵃ)
        end
#= none:337 =#
#= none:337 =# @inline z_domain(grid::LLG) = begin
            #= none:337 =#
            domain((topology(grid, 3))(), grid.Nz, grid.zᵃᵃᶠ)
        end
#= none:339 =#
#= none:339 =# @inline cpu_face_constructor_x(grid::XRegularLLG) = begin
            #= none:339 =#
            x_domain(grid)
        end
#= none:340 =#
#= none:340 =# @inline cpu_face_constructor_y(grid::YRegularLLG) = begin
            #= none:340 =#
            y_domain(grid)
        end
#= none:341 =#
#= none:341 =# @inline cpu_face_constructor_z(grid::ZRegularLLG) = begin
            #= none:341 =#
            z_domain(grid)
        end
#= none:343 =#
function constructor_arguments(grid::LatitudeLongitudeGrid)
    #= none:343 =#
    #= none:344 =#
    arch = architecture(grid)
    #= none:345 =#
    FT = eltype(grid)
    #= none:346 =#
    args = Dict(:architecture => arch, :number_type => eltype(grid))
    #= none:349 =#
    topo = topology(grid)
    #= none:350 =#
    size = (grid.Nx, grid.Ny, grid.Nz)
    #= none:351 =#
    halo = (grid.Hx, grid.Hy, grid.Hz)
    #= none:352 =#
    size = pop_flat_elements(size, topo)
    #= none:353 =#
    halo = pop_flat_elements(halo, topo)
    #= none:355 =#
    kwargs = Dict(:size => size, :halo => halo, :longitude => cpu_face_constructor_x(grid), :latitude => cpu_face_constructor_y(grid), :z => cpu_face_constructor_z(grid), :topology => topo, :radius => grid.radius, :precompute_metrics => metrics_precomputed(grid))
    #= none:364 =#
    return (args, kwargs)
end
#= none:367 =#
function Base.similar(grid::LatitudeLongitudeGrid)
    #= none:367 =#
    #= none:368 =#
    (args, kwargs) = constructor_arguments(grid)
    #= none:369 =#
    arch = args[:architecture]
    #= none:370 =#
    FT = args[:number_type]
    #= none:371 =#
    return LatitudeLongitudeGrid(arch, FT; kwargs...)
end
#= none:374 =#
function with_number_type(FT, grid::LatitudeLongitudeGrid)
    #= none:374 =#
    #= none:375 =#
    (args, kwargs) = constructor_arguments(grid)
    #= none:376 =#
    arch = args[:architecture]
    #= none:377 =#
    return LatitudeLongitudeGrid(arch, FT; kwargs...)
end
#= none:380 =#
function with_halo(halo, grid::LatitudeLongitudeGrid)
    #= none:380 =#
    #= none:381 =#
    (args, kwargs) = constructor_arguments(grid)
    #= none:382 =#
    halo = pop_flat_elements(halo, topology(grid))
    #= none:383 =#
    kwargs[:halo] = halo
    #= none:384 =#
    arch = args[:architecture]
    #= none:385 =#
    FT = args[:number_type]
    #= none:386 =#
    return LatitudeLongitudeGrid(arch, FT; kwargs...)
end
#= none:389 =#
function on_architecture(arch::AbstractSerialArchitecture, grid::LatitudeLongitudeGrid)
    #= none:389 =#
    #= none:390 =#
    if arch == architecture(grid)
        #= none:391 =#
        return grid
    end
    #= none:394 =#
    (args, kwargs) = constructor_arguments(grid)
    #= none:395 =#
    FT = args[:number_type]
    #= none:396 =#
    return LatitudeLongitudeGrid(arch, FT; kwargs...)
end
#= none:399 =#
function Adapt.adapt_structure(to, grid::LatitudeLongitudeGrid)
    #= none:399 =#
    #= none:400 =#
    (TX, TY, TZ) = topology(grid)
    #= none:401 =#
    return LatitudeLongitudeGrid{TX, TY, TZ}(nothing, grid.Nx, grid.Ny, grid.Nz, grid.Hx, grid.Hy, grid.Hz, grid.Lx, grid.Ly, grid.Lz, Adapt.adapt(to, grid.Δλᶠᵃᵃ), Adapt.adapt(to, grid.Δλᶜᵃᵃ), Adapt.adapt(to, grid.λᶠᵃᵃ), Adapt.adapt(to, grid.λᶜᵃᵃ), Adapt.adapt(to, grid.Δφᵃᶠᵃ), Adapt.adapt(to, grid.Δφᵃᶜᵃ), Adapt.adapt(to, grid.φᵃᶠᵃ), Adapt.adapt(to, grid.φᵃᶜᵃ), Adapt.adapt(to, grid.Δzᵃᵃᶠ), Adapt.adapt(to, grid.Δzᵃᵃᶜ), Adapt.adapt(to, grid.zᵃᵃᶠ), Adapt.adapt(to, grid.zᵃᵃᶜ), Adapt.adapt(to, grid.Δxᶠᶜᵃ), Adapt.adapt(to, grid.Δxᶜᶠᵃ), Adapt.adapt(to, grid.Δxᶠᶠᵃ), Adapt.adapt(to, grid.Δxᶜᶜᵃ), Adapt.adapt(to, grid.Δyᶠᶜᵃ), Adapt.adapt(to, grid.Δyᶜᶠᵃ), Adapt.adapt(to, grid.Azᶠᶜᵃ), Adapt.adapt(to, grid.Azᶜᶠᵃ), Adapt.adapt(to, grid.Azᶠᶠᵃ), Adapt.adapt(to, grid.Azᶜᶜᵃ), grid.radius)
end
#= none:434 =#
#= none:434 =# @inline hack_cosd(φ) = begin
            #= none:434 =#
            cos((π * φ) / 180)
        end
#= none:435 =#
#= none:435 =# @inline hack_sind(φ) = begin
            #= none:435 =#
            sin((π * φ) / 180)
        end
#= none:437 =#
#= none:437 =# @inline Δxᶠᶜᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:437 =#
            #= none:437 =# @inbounds grid.radius * hack_cosd(grid.φᵃᶜᵃ[j]) * deg2rad(grid.Δλᶠᵃᵃ[i])
        end
#= none:438 =#
#= none:438 =# @inline Δxᶜᶠᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:438 =#
            #= none:438 =# @inbounds grid.radius * hack_cosd(grid.φᵃᶠᵃ[j]) * deg2rad(grid.Δλᶜᵃᵃ[i])
        end
#= none:439 =#
#= none:439 =# @inline Δxᶠᶠᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:439 =#
            #= none:439 =# @inbounds grid.radius * hack_cosd(grid.φᵃᶠᵃ[j]) * deg2rad(grid.Δλᶠᵃᵃ[i])
        end
#= none:440 =#
#= none:440 =# @inline Δxᶜᶜᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:440 =#
            #= none:440 =# @inbounds grid.radius * hack_cosd(grid.φᵃᶜᵃ[j]) * deg2rad(grid.Δλᶜᵃᵃ[i])
        end
#= none:441 =#
#= none:441 =# @inline Δyᶜᶠᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:441 =#
            #= none:441 =# @inbounds grid.radius * deg2rad(grid.Δφᵃᶠᵃ[j])
        end
#= none:442 =#
#= none:442 =# @inline Δyᶠᶜᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:442 =#
            #= none:442 =# @inbounds grid.radius * deg2rad(grid.Δφᵃᶜᵃ[j])
        end
#= none:443 =#
#= none:443 =# @inline Azᶠᶜᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:443 =#
            #= none:443 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶠᵃᵃ[i]) * (hack_sind(grid.φᵃᶠᵃ[j + 1]) - hack_sind(grid.φᵃᶠᵃ[j]))
        end
#= none:444 =#
#= none:444 =# @inline Azᶜᶠᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:444 =#
            #= none:444 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶜᵃᵃ[i]) * (hack_sind(grid.φᵃᶜᵃ[j]) - hack_sind(grid.φᵃᶜᵃ[j - 1]))
        end
#= none:445 =#
#= none:445 =# @inline Azᶠᶠᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:445 =#
            #= none:445 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶠᵃᵃ[i]) * (hack_sind(grid.φᵃᶜᵃ[j]) - hack_sind(grid.φᵃᶜᵃ[j - 1]))
        end
#= none:446 =#
#= none:446 =# @inline Azᶜᶜᵃ(i, j, k, grid::LatitudeLongitudeGrid) = begin
            #= none:446 =#
            #= none:446 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶜᵃᵃ[i]) * (hack_sind(grid.φᵃᶠᵃ[j + 1]) - hack_sind(grid.φᵃᶠᵃ[j]))
        end
#= none:448 =#
#= none:448 =# @inline Δxᶠᶜᵃ(i, j, k, grid::XRegularLLG) = begin
            #= none:448 =#
            #= none:448 =# @inbounds grid.radius * hack_cosd(grid.φᵃᶜᵃ[j]) * deg2rad(grid.Δλᶠᵃᵃ)
        end
#= none:449 =#
#= none:449 =# @inline Δxᶜᶠᵃ(i, j, k, grid::XRegularLLG) = begin
            #= none:449 =#
            #= none:449 =# @inbounds grid.radius * hack_cosd(grid.φᵃᶠᵃ[j]) * deg2rad(grid.Δλᶜᵃᵃ)
        end
#= none:450 =#
#= none:450 =# @inline Δxᶠᶠᵃ(i, j, k, grid::XRegularLLG) = begin
            #= none:450 =#
            #= none:450 =# @inbounds grid.radius * hack_cosd(grid.φᵃᶠᵃ[j]) * deg2rad(grid.Δλᶠᵃᵃ)
        end
#= none:451 =#
#= none:451 =# @inline Δxᶜᶜᵃ(i, j, k, grid::XRegularLLG) = begin
            #= none:451 =#
            #= none:451 =# @inbounds grid.radius * hack_cosd(grid.φᵃᶜᵃ[j]) * deg2rad(grid.Δλᶜᵃᵃ)
        end
#= none:452 =#
#= none:452 =# @inline Δyᶜᶠᵃ(i, j, k, grid::YRegularLLG) = begin
            #= none:452 =#
            #= none:452 =# @inbounds grid.radius * deg2rad(grid.Δφᵃᶠᵃ)
        end
#= none:453 =#
#= none:453 =# @inline Δyᶠᶜᵃ(i, j, k, grid::YRegularLLG) = begin
            #= none:453 =#
            #= none:453 =# @inbounds grid.radius * deg2rad(grid.Δφᵃᶜᵃ)
        end
#= none:454 =#
#= none:454 =# @inline Azᶠᶜᵃ(i, j, k, grid::XRegularLLG) = begin
            #= none:454 =#
            #= none:454 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶠᵃᵃ) * (hack_sind(grid.φᵃᶠᵃ[j + 1]) - hack_sind(grid.φᵃᶠᵃ[j]))
        end
#= none:455 =#
#= none:455 =# @inline Azᶜᶠᵃ(i, j, k, grid::XRegularLLG) = begin
            #= none:455 =#
            #= none:455 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶜᵃᵃ) * (hack_sind(grid.φᵃᶜᵃ[j]) - hack_sind(grid.φᵃᶜᵃ[j - 1]))
        end
#= none:456 =#
#= none:456 =# @inline Azᶠᶠᵃ(i, j, k, grid::XRegularLLG) = begin
            #= none:456 =#
            #= none:456 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶠᵃᵃ) * (hack_sind(grid.φᵃᶜᵃ[j]) - hack_sind(grid.φᵃᶜᵃ[j - 1]))
        end
#= none:457 =#
#= none:457 =# @inline Azᶜᶜᵃ(i, j, k, grid::XRegularLLG) = begin
            #= none:457 =#
            #= none:457 =# @inbounds grid.radius ^ 2 * deg2rad(grid.Δλᶜᵃᵃ) * (hack_sind(grid.φᵃᶠᵃ[j + 1]) - hack_sind(grid.φᵃᶠᵃ[j]))
        end
#= none:463 =#
#= none:463 =# @inline metrics_precomputed(::LatitudeLongitudeGrid{<:Any, <:Any, <:Any, <:Any, Nothing}) = begin
            #= none:463 =#
            false
        end
#= none:464 =#
#= none:464 =# @inline metrics_precomputed(::LatitudeLongitudeGrid) = begin
            #= none:464 =#
            true
        end
#= none:470 =#
#= none:470 =# @inline metric_worksize(grid::LatitudeLongitudeGrid) = begin
            #= none:470 =#
            (length(grid.Δλᶜᵃᵃ), length(grid.φᵃᶠᵃ) - 2)
        end
#= none:471 =#
#= none:471 =# @inline metric_workgroup(grid::LatitudeLongitudeGrid) = begin
            #= none:471 =#
            (16, 16)
        end
#= none:473 =#
#= none:473 =# @inline metric_worksize(grid::XRegularLLG) = begin
            #= none:473 =#
            length(grid.φᵃᶠᵃ) - 2
        end
#= none:474 =#
#= none:474 =# @inline metric_workgroup(grid::XRegularLLG) = begin
            #= none:474 =#
            16
        end
#= none:476 =#
#= none:476 =# @kernel function compute_Δx_Az!(grid::LatitudeLongitudeGrid, Δxᶠᶜ, Δxᶜᶠ, Δxᶠᶠ, Δxᶜᶜ, Azᶠᶜ, Azᶜᶠ, Azᶠᶠ, Azᶜᶜ)
        #= none:476 =#
        #= none:477 =#
        (i, j) = #= none:477 =# @index(Global, NTuple)
        #= none:480 =#
        i′ = i + grid.Δλᶜᵃᵃ.offsets[1]
        #= none:481 =#
        j′ = j + grid.φᵃᶜᵃ.offsets[1] + 1
        #= none:483 =#
        #= none:483 =# @inbounds begin
                #= none:484 =#
                Δxᶠᶜ[i′, j′] = Δxᶠᶜᵃ(i′, j′, 1, grid)
                #= none:485 =#
                Δxᶜᶠ[i′, j′] = Δxᶜᶠᵃ(i′, j′, 1, grid)
                #= none:486 =#
                Δxᶠᶠ[i′, j′] = Δxᶠᶠᵃ(i′, j′, 1, grid)
                #= none:487 =#
                Δxᶜᶜ[i′, j′] = Δxᶜᶜᵃ(i′, j′, 1, grid)
                #= none:488 =#
                Azᶠᶜ[i′, j′] = Azᶠᶜᵃ(i′, j′, 1, grid)
                #= none:489 =#
                Azᶜᶠ[i′, j′] = Azᶜᶠᵃ(i′, j′, 1, grid)
                #= none:490 =#
                Azᶠᶠ[i′, j′] = Azᶠᶠᵃ(i′, j′, 1, grid)
                #= none:491 =#
                Azᶜᶜ[i′, j′] = Azᶜᶜᵃ(i′, j′, 1, grid)
            end
    end
#= none:495 =#
#= none:495 =# @kernel function compute_Δx_Az!(grid::XRegularLLG, Δxᶠᶜ, Δxᶜᶠ, Δxᶠᶠ, Δxᶜᶜ, Azᶠᶜ, Azᶜᶠ, Azᶠᶠ, Azᶜᶜ)
        #= none:495 =#
        #= none:496 =#
        j = #= none:496 =# @index(Global, Linear)
        #= none:499 =#
        j′ = j + grid.φᵃᶜᵃ.offsets[1] + 1
        #= none:501 =#
        #= none:501 =# @inbounds begin
                #= none:502 =#
                Δxᶠᶜ[j′] = Δxᶠᶜᵃ(1, j′, 1, grid)
                #= none:503 =#
                Δxᶜᶠ[j′] = Δxᶜᶠᵃ(1, j′, 1, grid)
                #= none:504 =#
                Δxᶠᶠ[j′] = Δxᶠᶠᵃ(1, j′, 1, grid)
                #= none:505 =#
                Δxᶜᶜ[j′] = Δxᶜᶜᵃ(1, j′, 1, grid)
                #= none:506 =#
                Azᶠᶜ[j′] = Azᶠᶜᵃ(1, j′, 1, grid)
                #= none:507 =#
                Azᶜᶠ[j′] = Azᶜᶠᵃ(1, j′, 1, grid)
                #= none:508 =#
                Azᶠᶠ[j′] = Azᶠᶠᵃ(1, j′, 1, grid)
                #= none:509 =#
                Azᶜᶜ[j′] = Azᶜᶜᵃ(1, j′, 1, grid)
            end
    end
#= none:517 =#
#= none:517 =# @kernel function compute_Δy!(grid, Δyᶠᶜ, Δyᶜᶠ)
        #= none:517 =#
        #= none:518 =#
        j = #= none:518 =# @index(Global, Linear)
        #= none:521 =#
        j′ = j + grid.Δφᵃᶜᵃ.offsets[1] + 1
        #= none:523 =#
        #= none:523 =# @inbounds begin
                #= none:524 =#
                Δyᶜᶠ[j′] = Δyᶜᶠᵃ(1, j′, 1, grid)
                #= none:525 =#
                Δyᶠᶜ[j′] = Δyᶠᶜᵃ(1, j′, 1, grid)
            end
    end
#= none:533 =#
function allocate_metrics(grid::LatitudeLongitudeGrid)
    #= none:533 =#
    #= none:534 =#
    FT = eltype(grid)
    #= none:536 =#
    arch = grid.architecture
    #= none:538 =#
    if grid isa XRegularLLG
        #= none:539 =#
        offsets = grid.φᵃᶜᵃ.offsets[1]
        #= none:540 =#
        metric_size = length(grid.φᵃᶜᵃ)
    else
        #= none:542 =#
        offsets = (grid.Δλᶜᵃᵃ.offsets[1], grid.φᵃᶜᵃ.offsets[1])
        #= none:543 =#
        metric_size = (length(grid.Δλᶜᵃᵃ), length(grid.φᵃᶜᵃ))
    end
    #= none:546 =#
    Δxᶠᶜ = OffsetArray(zeros(FT, arch, metric_size...), offsets...)
    #= none:547 =#
    Δxᶜᶠ = OffsetArray(zeros(FT, arch, metric_size...), offsets...)
    #= none:548 =#
    Δxᶠᶠ = OffsetArray(zeros(FT, arch, metric_size...), offsets...)
    #= none:549 =#
    Δxᶜᶜ = OffsetArray(zeros(FT, arch, metric_size...), offsets...)
    #= none:550 =#
    Azᶠᶜ = OffsetArray(zeros(FT, arch, metric_size...), offsets...)
    #= none:551 =#
    Azᶜᶠ = OffsetArray(zeros(FT, arch, metric_size...), offsets...)
    #= none:552 =#
    Azᶠᶠ = OffsetArray(zeros(FT, arch, metric_size...), offsets...)
    #= none:553 =#
    Azᶜᶜ = OffsetArray(zeros(FT, arch, metric_size...), offsets...)
    #= none:555 =#
    if grid isa YRegularLLG
        #= none:556 =#
        Δyᶠᶜ = Δyᶠᶜᵃ(1, 1, 1, grid)
        #= none:557 =#
        Δyᶜᶠ = Δyᶜᶠᵃ(1, 1, 1, grid)
    else
        #= none:559 =#
        parentC = zeros(FT, length(grid.Δφᵃᶜᵃ))
        #= none:560 =#
        parentF = zeros(FT, length(grid.Δφᵃᶜᵃ))
        #= none:561 =#
        Δyᶠᶜ = OffsetArray(on_architecture(arch, parentC), grid.Δφᵃᶜᵃ.offsets[1])
        #= none:562 =#
        Δyᶜᶠ = OffsetArray(on_architecture(arch, parentF), grid.Δφᵃᶜᵃ.offsets[1])
    end
    #= none:565 =#
    return (Δxᶠᶜ, Δxᶜᶠ, Δxᶠᶠ, Δxᶜᶜ, Δyᶠᶜ, Δyᶜᶠ, Azᶠᶜ, Azᶜᶠ, Azᶠᶠ, Azᶜᶜ)
end
#= none:572 =#
coordinates(::LatitudeLongitudeGrid) = begin
        #= none:572 =#
        (:λᶠᵃᵃ, :λᶜᵃᵃ, :φᵃᶠᵃ, :φᵃᶜᵃ, :zᵃᵃᶠ, :zᵃᵃᶜ)
    end
#= none:578 =#
ξname(::LLG) = begin
        #= none:578 =#
        :λ
    end
#= none:579 =#
ηname(::LLG) = begin
        #= none:579 =#
        :φ
    end
#= none:580 =#
rname(::LLG) = begin
        #= none:580 =#
        :z
    end
#= none:582 =#
#= none:582 =# @inline λnode(i, grid::LLG, ::Center) = begin
            #= none:582 =#
            getnode(grid.λᶜᵃᵃ, i)
        end
#= none:583 =#
#= none:583 =# @inline λnode(i, grid::LLG, ::Face) = begin
            #= none:583 =#
            getnode(grid.λᶠᵃᵃ, i)
        end
#= none:584 =#
#= none:584 =# @inline φnode(j, grid::LLG, ::Center) = begin
            #= none:584 =#
            getnode(grid.φᵃᶜᵃ, j)
        end
#= none:585 =#
#= none:585 =# @inline φnode(j, grid::LLG, ::Face) = begin
            #= none:585 =#
            getnode(grid.φᵃᶠᵃ, j)
        end
#= none:586 =#
#= none:586 =# @inline znode(k, grid::LLG, ::Center) = begin
            #= none:586 =#
            getnode(grid.zᵃᵃᶜ, k)
        end
#= none:587 =#
#= none:587 =# @inline znode(k, grid::LLG, ::Face) = begin
            #= none:587 =#
            getnode(grid.zᵃᵃᶠ, k)
        end
#= none:590 =#
#= none:590 =# @inline ξnode(i, j, k, grid::LLG, ℓx, ℓy, ℓz) = begin
            #= none:590 =#
            λnode(i, grid, ℓx)
        end
#= none:591 =#
#= none:591 =# @inline ηnode(i, j, k, grid::LLG, ℓx, ℓy, ℓz) = begin
            #= none:591 =#
            φnode(j, grid, ℓy)
        end
#= none:592 =#
#= none:592 =# @inline rnode(i, j, k, grid::LLG, ℓx, ℓy, ℓz) = begin
            #= none:592 =#
            znode(k, grid, ℓz)
        end
#= none:594 =#
#= none:594 =# @inline xnode(i, j, grid::LLG, ℓx, ℓy) = begin
            #= none:594 =#
            grid.radius * deg2rad(λnode(i, grid, ℓx)) * hack_cosd(φnode(j, grid, ℓy))
        end
#= none:595 =#
#= none:595 =# @inline ynode(j, grid::LLG, ℓy) = begin
            #= none:595 =#
            grid.radius * deg2rad(φnode(j, grid, ℓy))
        end
#= none:598 =#
#= none:598 =# @inline λnode(i, j, k, grid::LLG, ℓx, ℓy, ℓz) = begin
            #= none:598 =#
            λnode(i, grid, ℓx)
        end
#= none:599 =#
#= none:599 =# @inline φnode(i, j, k, grid::LLG, ℓx, ℓy, ℓz) = begin
            #= none:599 =#
            φnode(j, grid, ℓy)
        end
#= none:600 =#
#= none:600 =# @inline xnode(i, j, k, grid::LLG, ℓx, ℓy, ℓz) = begin
            #= none:600 =#
            xnode(i, j, grid, ℓx, ℓy)
        end
#= none:601 =#
#= none:601 =# @inline ynode(i, j, k, grid::LLG, ℓx, ℓy, ℓz) = begin
            #= none:601 =#
            ynode(j, grid, ℓy)
        end
#= none:602 =#
#= none:602 =# @inline znode(i, j, k, grid::LLG, ℓx, ℓy, ℓz) = begin
            #= none:602 =#
            znode(k, grid, ℓz)
        end
#= none:604 =#
function nodes(grid::LLG, ℓx, ℓy, ℓz; reshape = false, with_halos = false)
    #= none:604 =#
    #= none:605 =#
    λ = λnodes(grid, ℓx, ℓy, ℓz; with_halos)
    #= none:606 =#
    φ = φnodes(grid, ℓx, ℓy, ℓz; with_halos)
    #= none:607 =#
    z = znodes(grid, ℓx, ℓy, ℓz; with_halos)
    #= none:609 =#
    if reshape
        #= none:620 =#
        Nλ = if isnothing(λ)
                1
            else
                length(λ)
            end
        #= none:621 =#
        Nφ = if isnothing(φ)
                1
            else
                length(φ)
            end
        #= none:622 =#
        Nz = if isnothing(z)
                1
            else
                length(z)
            end
        #= none:624 =#
        λ = if isnothing(λ)
                zeros(1, 1, 1)
            else
                Base.reshape(λ, Nλ, 1, 1)
            end
        #= none:625 =#
        φ = if isnothing(φ)
                zeros(1, 1, 1)
            else
                Base.reshape(φ, 1, Nφ, 1)
            end
        #= none:626 =#
        z = if isnothing(z)
                zeros(1, 1, 1)
            else
                Base.reshape(z, 1, 1, Nz)
            end
    end
    #= none:629 =#
    return (λ, φ, z)
end
#= none:632 =#
const F = Face
#= none:633 =#
const C = Center
#= none:635 =#
#= none:635 =# @inline function xnodes(grid::LLG, ℓx, ℓy; with_halos = false)
        #= none:635 =#
        #= none:636 =#
        λ = (λnodes(grid, ℓx; with_halos = with_halos))'
        #= none:637 =#
        φ = φnodes(grid, ℓy; with_halos = with_halos)
        #= none:638 =#
        R = grid.radius
        #= none:639 =#
        return #= none:639 =# @__dot__(R * deg2rad(λ) * hack_cosd(φ))
    end
#= none:642 =#
#= none:642 =# @inline function ynodes(grid::LLG, ℓy; with_halos = false)
        #= none:642 =#
        #= none:643 =#
        φ = φnodes(grid, ℓy; with_halos = with_halos)
        #= none:644 =#
        R = grid.radius
        #= none:645 =#
        return #= none:645 =# @__dot__(R * deg2rad(φ))
    end
#= none:648 =#
#= none:648 =# @inline znodes(grid::LLG, ℓz::F; with_halos = false) = begin
            #= none:648 =#
            _property(grid.zᵃᵃᶠ, ℓz, topology(grid, 3), size(grid, 3), with_halos)
        end
#= none:649 =#
#= none:649 =# @inline znodes(grid::LLG, ℓz::C; with_halos = false) = begin
            #= none:649 =#
            _property(grid.zᵃᵃᶜ, ℓz, topology(grid, 3), size(grid, 3), with_halos)
        end
#= none:652 =#
#= none:652 =# @inline λnodes(grid::LLG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:652 =#
            λnodes(grid, ℓx; with_halos)
        end
#= none:653 =#
#= none:653 =# @inline φnodes(grid::LLG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:653 =#
            φnodes(grid, ℓy; with_halos)
        end
#= none:654 =#
#= none:654 =# @inline znodes(grid::LLG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:654 =#
            znodes(grid, ℓz; with_halos)
        end
#= none:655 =#
#= none:655 =# @inline xnodes(grid::LLG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:655 =#
            xnodes(grid, ℓx, ℓy; with_halos)
        end
#= none:656 =#
#= none:656 =# @inline ynodes(grid::LLG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:656 =#
            ynodes(grid, ℓy; with_halos)
        end
#= none:659 =#
#= none:659 =# @inline ξnodes(grid::LLG, ℓx; kwargs...) = begin
            #= none:659 =#
            λnodes(grid, ℓx; kwargs...)
        end
#= none:660 =#
#= none:660 =# @inline ηnodes(grid::LLG, ℓy; kwargs...) = begin
            #= none:660 =#
            φnodes(grid, ℓy; kwargs...)
        end
#= none:661 =#
#= none:661 =# @inline rnodes(grid::LLG, ℓz; kwargs...) = begin
            #= none:661 =#
            znodes(grid, ℓz; kwargs...)
        end
#= none:663 =#
#= none:663 =# @inline ξnodes(grid::LLG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:663 =#
            λnodes(grid, ℓx; kwargs...)
        end
#= none:664 =#
#= none:664 =# @inline ηnodes(grid::LLG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:664 =#
            φnodes(grid, ℓy; kwargs...)
        end
#= none:665 =#
#= none:665 =# @inline rnodes(grid::LLG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:665 =#
            znodes(grid, ℓz; kwargs...)
        end
#= none:671 =#
#= none:671 =# @inline xspacings(grid::LLG, ℓx::C, ℓy::C; with_halos = false) = begin
            #= none:671 =#
            _property(grid.Δxᶜᶜᵃ, ℓx, ℓy, topology(grid, 1), topology(grid, 2), size(grid, 1), size(grid, 2), with_halos)
        end
#= none:675 =#
#= none:675 =# @inline xspacings(grid::LLG, ℓx::C, ℓy::F; with_halos = false) = begin
            #= none:675 =#
            _property(grid.Δxᶜᶠᵃ, ℓx, ℓy, topology(grid, 1), topology(grid, 2), size(grid, 1), size(grid, 2), with_halos)
        end
#= none:679 =#
#= none:679 =# @inline xspacings(grid::LLG, ℓx::F, ℓy::C; with_halos = false) = begin
            #= none:679 =#
            _property(grid.Δxᶠᶜᵃ, ℓx, ℓy, topology(grid, 1), topology(grid, 2), size(grid, 1), size(grid, 2), with_halos)
        end
#= none:683 =#
#= none:683 =# @inline xspacings(grid::LLG, ℓx::F, ℓy::F; with_halos = false) = begin
            #= none:683 =#
            _property(grid.Δxᶠᶠᵃ, ℓx, ℓy, topology(grid, 1), topology(grid, 2), size(grid, 1), size(grid, 2), with_halos)
        end
#= none:687 =#
#= none:687 =# @inline xspacings(grid::HRegularLLG, ℓx::C, ℓy::C; with_halos = false) = begin
            #= none:687 =#
            _property(grid.Δxᶜᶜᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:690 =#
#= none:690 =# @inline xspacings(grid::HRegularLLG, ℓx::C, ℓy::F; with_halos = false) = begin
            #= none:690 =#
            _property(grid.Δxᶜᶠᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:693 =#
#= none:693 =# @inline xspacings(grid::HRegularLLG, ℓx::F, ℓy::C; with_halos = false) = begin
            #= none:693 =#
            _property(grid.Δxᶠᶜᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:696 =#
#= none:696 =# @inline xspacings(grid::HRegularLLG, ℓx::F, ℓy::F; with_halos = false) = begin
            #= none:696 =#
            _property(grid.Δxᶠᶠᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:700 =#
#= none:700 =# @inline yspacings(grid::YNonRegularLLG, ℓx::C, ℓy::F; with_halos = false) = begin
            #= none:700 =#
            _property(grid.Δyᶜᶠᵃ, ℓy, topoloy(grid, 2), size(grid, 2), with_halos)
        end
#= none:703 =#
#= none:703 =# @inline yspacings(grid::YNonRegularLLG, ℓx::F, ℓy::C; with_halos = false) = begin
            #= none:703 =#
            _property(grid.Δyᶠᶜᵃ, ℓy, topoloy(grid, 2), size(grid, 2), with_halos)
        end
#= none:706 =#
#= none:706 =# @inline yspacings(grid::YRegularLLG, ℓx, ℓy; with_halos = false) = begin
            #= none:706 =#
            yspacings(grid, ℓy; with_halos)
        end
#= none:707 =#
#= none:707 =# @inline yspacings(grid, ℓy::C; kwargs...) = begin
            #= none:707 =#
            grid.Δyᶠᶜᵃ
        end
#= none:708 =#
#= none:708 =# @inline yspacings(grid, ℓy::F; kwargs...) = begin
            #= none:708 =#
            grid.Δyᶜᶠᵃ
        end
#= none:710 =#
#= none:710 =# @inline xspacings(grid::LLG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:710 =#
            xspacings(grid, ℓx, ℓy; kwargs...)
        end
#= none:711 =#
#= none:711 =# @inline yspacings(grid::LLG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:711 =#
            yspacings(grid, ℓx, ℓy; kwargs...)
        end
#= none:712 =#
#= none:712 =# @inline zspacings(grid::LLG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:712 =#
            zspacings(grid, ℓz; kwargs...)
        end
#= none:718 =#
#= none:718 =# @inline λnodes(grid::LLG, ℓx::F; with_halos = false) = begin
            #= none:718 =#
            _property(grid.λᶠᵃᵃ, ℓx, topology(grid, 1), size(grid, 1), with_halos)
        end
#= none:719 =#
#= none:719 =# @inline λnodes(grid::LLG, ℓx::C; with_halos = false) = begin
            #= none:719 =#
            _property(grid.λᶜᵃᵃ, ℓx, topology(grid, 1), size(grid, 1), with_halos)
        end
#= none:720 =#
#= none:720 =# @inline φnodes(grid::LLG, ℓy::F; with_halos = false) = begin
            #= none:720 =#
            _property(grid.φᵃᶠᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:721 =#
#= none:721 =# @inline φnodes(grid::LLG, ℓy::C; with_halos = false) = begin
            #= none:721 =#
            _property(grid.φᵃᶜᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:727 =#
#= none:727 =# @inline λspacings(grid::LLG, ℓx::C; with_halos = false) = begin
            #= none:727 =#
            _property(grid.Δλᶜᵃᵃ, ℓx, topology(grid, 1), size(grid, 1), with_halos)
        end
#= none:728 =#
#= none:728 =# @inline λspacings(grid::LLG, ℓx::F; with_halos = false) = begin
            #= none:728 =#
            _property(grid.Δλᶠᵃᵃ, ℓx, topology(grid, 1), size(grid, 1), with_halos)
        end
#= none:729 =#
#= none:729 =# @inline φspacings(grid::LLG, ℓy::C; with_halos = false) = begin
            #= none:729 =#
            _property(grid.Δφᵃᶜᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:730 =#
#= none:730 =# @inline φspacings(grid::LLG, ℓy::F; with_halos = false) = begin
            #= none:730 =#
            _property(grid.Δφᵃᶠᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:731 =#
#= none:731 =# @inline zspacings(grid::LLG, ℓz::C; with_halos = false) = begin
            #= none:731 =#
            _property(grid.Δzᵃᵃᶜ, ℓz, topology(grid, 3), size(grid, 3), with_halos)
        end
#= none:732 =#
#= none:732 =# @inline zspacings(grid::LLG, ℓz::F; with_halos = false) = begin
            #= none:732 =#
            _property(grid.Δzᵃᵃᶠ, ℓz, topology(grid, 3), size(grid, 3), with_halos)
        end
#= none:734 =#
#= none:734 =# @inline λspacings(grid::LLG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:734 =#
            λspacings(grid, ℓx; kwargs...)
        end
#= none:735 =#
#= none:735 =# @inline φspacings(grid::LLG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:735 =#
            φspacings(grid, ℓy; kwargs...)
        end
#= none:737 =#
#= none:737 =# @inline λspacing(i, grid::LLG, ::C) = begin
            #= none:737 =#
            #= none:737 =# @inbounds grid.Δλᶜᵃᵃ[i]
        end
#= none:738 =#
#= none:738 =# @inline λspacing(i, grid::LLG, ::F) = begin
            #= none:738 =#
            #= none:738 =# @inbounds grid.Δλᶠᵃᵃ[i]
        end
#= none:739 =#
#= none:739 =# @inline λspacing(i, grid::XRegularLLG, ::C) = begin
            #= none:739 =#
            grid.Δλᶜᵃᵃ
        end
#= none:740 =#
#= none:740 =# @inline λspacing(i, grid::XRegularLLG, ::F) = begin
            #= none:740 =#
            grid.Δλᶠᵃᵃ
        end
#= none:742 =#
#= none:742 =# @inline φspacing(j, grid::LLG, ::C) = begin
            #= none:742 =#
            #= none:742 =# @inbounds grid.Δφᵃᶜᵃ[j]
        end
#= none:743 =#
#= none:743 =# @inline φspacing(j, grid::LLG, ::F) = begin
            #= none:743 =#
            #= none:743 =# @inbounds grid.Δφᵃᶠᵃ[j]
        end
#= none:744 =#
#= none:744 =# @inline φspacing(j, grid::YRegularLLG, ::C) = begin
            #= none:744 =#
            grid.Δφᵃᶜᵃ
        end
#= none:745 =#
#= none:745 =# @inline φspacing(j, grid::YRegularLLG, ::F) = begin
            #= none:745 =#
            grid.Δφᵃᶠᵃ
        end
#= none:747 =#
#= none:747 =# @inline λspacing(i, j, k, grid::LLG, ℓx, ℓy, ℓz) = begin
            #= none:747 =#
            λspacing(i, grid, ℓx)
        end
#= none:748 =#
#= none:748 =# @inline φspacing(i, j, k, grid::LLG, ℓx, ℓy, ℓz) = begin
            #= none:748 =#
            φspacing(j, grid, ℓy)
        end