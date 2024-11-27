
#= none:1 =#
struct RectilinearGrid{FT, TX, TY, TZ, FX, FY, FZ, VX, VY, VZ, Arch} <: AbstractUnderlyingGrid{FT, TX, TY, TZ, Arch}
    #= none:2 =#
    architecture::Arch
    #= none:3 =#
    Nx::Int
    #= none:4 =#
    Ny::Int
    #= none:5 =#
    Nz::Int
    #= none:6 =#
    Hx::Int
    #= none:7 =#
    Hy::Int
    #= none:8 =#
    Hz::Int
    #= none:9 =#
    Lx::FT
    #= none:10 =#
    Ly::FT
    #= none:11 =#
    Lz::FT
    #= none:14 =#
    Δxᶠᵃᵃ::FX
    #= none:15 =#
    Δxᶜᵃᵃ::FX
    #= none:16 =#
    xᶠᵃᵃ::VX
    #= none:17 =#
    xᶜᵃᵃ::VX
    #= none:18 =#
    Δyᵃᶠᵃ::FY
    #= none:19 =#
    Δyᵃᶜᵃ::FY
    #= none:20 =#
    yᵃᶠᵃ::VY
    #= none:21 =#
    yᵃᶜᵃ::VY
    #= none:22 =#
    Δzᵃᵃᶠ::FZ
    #= none:23 =#
    Δzᵃᵃᶜ::FZ
    #= none:24 =#
    zᵃᵃᶠ::VZ
    #= none:25 =#
    zᵃᵃᶜ::VZ
    #= none:27 =#
    (RectilinearGrid{TX, TY, TZ}(arch::Arch, Nx, Ny, Nz, Hx, Hy, Hz, Lx::FT, Ly::FT, Lz::FT, Δxᶠᵃᵃ::FX, Δxᶜᵃᵃ::FX, xᶠᵃᵃ::VX, xᶜᵃᵃ::VX, Δyᵃᶠᵃ::FY, Δyᵃᶜᵃ::FY, yᵃᶠᵃ::VY, yᵃᶜᵃ::VY, Δzᵃᵃᶠ::FZ, Δzᵃᵃᶜ::FZ, zᵃᵃᶠ::VZ, zᵃᵃᶜ::VZ) where {Arch, FT, TX, TY, TZ, FX, VX, FY, VY, FZ, VZ}) = begin
            #= none:27 =#
            new{FT, TX, TY, TZ, FX, FY, FZ, VX, VY, VZ, Arch}(arch, Nx, Ny, Nz, Hx, Hy, Hz, Lx, Ly, Lz, Δxᶠᵃᵃ, Δxᶜᵃᵃ, xᶠᵃᵃ, xᶜᵃᵃ, Δyᵃᶠᵃ, Δyᵃᶜᵃ, yᵃᶠᵃ, yᵃᶜᵃ, Δzᵃᵃᶠ, Δzᵃᵃᶜ, zᵃᵃᶠ, zᵃᵃᶜ)
        end
end
#= none:47 =#
const RG = RectilinearGrid
#= none:49 =#
const XRegularRG = RectilinearGrid{<:Any, <:Any, <:Any, <:Any, <:Number}
#= none:50 =#
const YRegularRG = RectilinearGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Number}
#= none:51 =#
const ZRegularRG = RectilinearGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Any, <:Number}
#= none:52 =#
const XYRegularRG = RectilinearGrid{<:Any, <:Any, <:Any, <:Any, <:Number, <:Number}
#= none:53 =#
const XZRegularRG = RectilinearGrid{<:Any, <:Any, <:Any, <:Any, <:Number, <:Any, <:Number}
#= none:54 =#
const YZRegularRG = RectilinearGrid{<:Any, <:Any, <:Any, <:Any, <:Any, <:Number, <:Number}
#= none:55 =#
const XYZRegularRG = RectilinearGrid{<:Any, <:Any, <:Any, <:Any, <:Number, <:Number, <:Number}
#= none:57 =#
regular_dimensions(::XRegularRG) = begin
        #= none:57 =#
        tuple(1)
    end
#= none:58 =#
regular_dimensions(::YRegularRG) = begin
        #= none:58 =#
        tuple(2)
    end
#= none:59 =#
regular_dimensions(::ZRegularRG) = begin
        #= none:59 =#
        tuple(3)
    end
#= none:60 =#
regular_dimensions(::XYRegularRG) = begin
        #= none:60 =#
        (1, 2)
    end
#= none:61 =#
regular_dimensions(::XZRegularRG) = begin
        #= none:61 =#
        (1, 3)
    end
#= none:62 =#
regular_dimensions(::YZRegularRG) = begin
        #= none:62 =#
        (2, 3)
    end
#= none:63 =#
regular_dimensions(::XYZRegularRG) = begin
        #= none:63 =#
        (1, 2, 3)
    end
#= none:65 =#
stretched_dimensions(::YZRegularRG) = begin
        #= none:65 =#
        tuple(1)
    end
#= none:66 =#
stretched_dimensions(::XZRegularRG) = begin
        #= none:66 =#
        tuple(2)
    end
#= none:67 =#
stretched_dimensions(::XYRegularRG) = begin
        #= none:67 =#
        tuple(3)
    end
#= none:69 =#
#= none:69 =# Core.@doc "    RectilinearGrid([architecture = CPU(), FT = Float64];\n                    size,\n                    x = nothing,\n                    y = nothing,\n                    z = nothing,\n                    halo = nothing,\n                    extent = nothing,\n                    topology = (Periodic, Periodic, Bounded))\n\nCreate a `RectilinearGrid` with `size = (Nx, Ny, Nz)` grid points.\n\nPositional arguments\n====================\n\n- `architecture`: Specifies whether arrays of coordinates and spacings are stored\n                  on the CPU or GPU. Default: `CPU()`.\n\n- `FT`: Floating point data type. Default: `Float64`.\n\nKeyword arguments\n=================\n\n- `size` (required): A tuple prescribing the number of grid points in non-`Flat` directions.\n                     `size` is a 3-tuple for 3D models, a 2-tuple for 2D models, and either a\n                     scalar or 1-tuple for 1D models.\n\n- `topology`: A 3-tuple `(TX, TY, TZ)` specifying the topology of the domain.\n              `TX`, `TY`, and `TZ` specify whether the `x`-, `y`-, and `z` directions are\n              `Periodic`, `Bounded`, or `Flat`. The topology `Flat` indicates that a model does\n              not vary in those directions so that derivatives and interpolation are zero.\n              The default is `topology = (Periodic, Periodic, Bounded)`.\n\n- `extent`: A tuple prescribing the physical extent of the grid in non-`Flat` directions, e.g.,\n            `(Lx, Ly, Lz)`. All directions are constructed with regular grid spacing and the domain\n            (in the case that no direction is `Flat`) is ``0 ≤ x ≤ L_x``, ``0 ≤ y ≤ L_y``, and\n            ``-L_z ≤ z ≤ 0``, which is most appropriate for oceanic applications in which ``z = 0``\n            usually is the ocean's surface.\n\n- `x`, `y`, and `z`: Each of `x, y, z` are either (i) 2-tuples that specify the end points of the domain\n                     in their respect directions (in which case scalar values may be used in `Flat`\n                     directions), or (ii) arrays or functions of the corresponding indices `i`, `j`, or `k`\n                     that specify the locations of cell faces in the `x`-, `y`-, or `z`-direction, respectively.\n                     For example, to prescribe the cell faces in `z` we need to provide a function that takes\n                     `k` as argument and returns the location of the faces for indices `k = 1` through `k = Nz + 1`,\n                     where `Nz` is the `size` of the stretched `z` dimension.\n\n**Note**: _Either_ `extent`, or _all_ of `x`, `y`, and `z` must be specified.\n\n- `halo`: A tuple of integers that specifies the size of the halo region of cells surrounding\n          the physical interior for each non-`Flat` direction. The default is 3 halo cells in every direction.\n\nThe physical extent of the domain can be specified either via `x`, `y`, and `z` keyword arguments\nindicating the left and right endpoints of each dimensions, e.g., `x = (-π, π)` or via\nthe `extent` argument, e.g., `extent = (Lx, Ly, Lz)`, which specifies the extent of each dimension\nin which case ``0 ≤ x ≤ L_x``, ``0 ≤ y ≤ L_y``, and ``-L_z ≤ z ≤ 0``.\n\nA grid topology may be specified via a tuple assigning one of `Periodic`, `Bounded`, and, `Flat`\nto each dimension. By default, a horizontally periodic grid topology `(Periodic, Periodic, Bounded)`\nis assumed.\n\nConstants are stored using floating point values of type `FT`. By default this is `Float64`.\nMake sure to specify the desired `FT` if not using `Float64`.\n\nGrid properties\n===============\n\n- `(Nx, Ny, Nz) :: Int`: Number of physical points in the ``(x, y, z)``-direction.\n\n- `(Hx, Hy, Hz) :: Int`: Number of halo points in the ``(x, y, z)``-direction.\n\n- `(Lx, Ly, Lz) :: FT`: Physical extent of the grid in the ``(x, y, z)``-direction.\n\n- `(Δxᶜᵃᵃ, Δyᵃᶜᵃ, Δzᵃᵃᶜ)`: Spacings in the ``(x, y, z)``-directions between the cell faces.\n                           These are the lengths in ``x``, ``y``, and ``z`` of `Center` cells and are\n                           defined at `Center` locations.\n\n- `(Δxᶠᵃᵃ, Δyᵃᶠᵃ, Δzᵃᵃᶠ)`: Spacings in the ``(x, y, z)``-directions between the cell centers.\n                           These are the lengths in ``x``, ``y``, and ``z`` of `Face` cells and are\n                           defined at `Face` locations.\n\n- `(xᶜᵃᵃ, yᵃᶜᵃ, zᵃᵃᶜ)`: ``(x, y, z)`` coordinates of cell `Center`s.\n\n- `(xᶠᵃᵃ, yᵃᶠᵃ, zᵃᵃᶠ)`: ``(x, y, z)`` coordinates of cell `Face`s.\n\nExamples\n========\n\n* A grid with the default `Float64` type:\n\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=(32, 32, 32), extent=(1, 2, 3))\n32×32×32 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 3×3×3 halo\n├── Periodic x ∈ [0.0, 1.0)  regularly spaced with Δx=0.03125\n├── Periodic y ∈ [0.0, 2.0)  regularly spaced with Δy=0.0625\n└── Bounded  z ∈ [-3.0, 0.0] regularly spaced with Δz=0.09375\n```\n\n* A grid with `Float32` type:\n\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(Float32; size=(32, 32, 16), x=(0, 8), y=(-10, 10), z=(-π, π))\n32×32×16 RectilinearGrid{Float32, Periodic, Periodic, Bounded} on CPU with 3×3×3 halo\n├── Periodic x ∈ [0.0, 8.0)          regularly spaced with Δx=0.25\n├── Periodic y ∈ [-10.0, 10.0)       regularly spaced with Δy=0.625\n└── Bounded  z ∈ [-3.14159, 3.14159] regularly spaced with Δz=0.392699\n```\n\n* A two-dimenisional, horizontally-periodic grid:\n\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=(32, 32), extent=(2π, 4π), topology=(Periodic, Periodic, Flat))\n32×32×1 RectilinearGrid{Float64, Periodic, Periodic, Flat} on CPU with 3×3×0 halo\n├── Periodic x ∈ [3.60072e-17, 6.28319) regularly spaced with Δx=0.19635\n├── Periodic y ∈ [7.20145e-17, 12.5664) regularly spaced with Δy=0.392699\n└── Flat z\n```\n\n* A one-dimensional \"column\" grid:\n\n```jldoctest\njulia> using Oceananigans\n\njulia> grid = RectilinearGrid(size=256, z=(-128, 0), topology=(Flat, Flat, Bounded))\n1×1×256 RectilinearGrid{Float64, Flat, Flat, Bounded} on CPU with 0×0×3 halo\n├── Flat x\n├── Flat y\n└── Bounded  z ∈ [-128.0, 0.0] regularly spaced with Δz=0.5\n```\n\n* A horizontally-periodic regular grid with cell interfaces stretched hyperbolically near the top:\n\n```jldoctest\njulia> using Oceananigans\n\njulia> σ = 1.1; # stretching factor\n\njulia> Nz = 24; # vertical resolution\n\njulia> Lz = 32; # depth (m)\n\njulia> hyperbolically_spaced_faces(k) = - Lz * (1 - tanh(σ * (k - 1) / Nz) / tanh(σ));\n\njulia> grid = RectilinearGrid(size = (32, 32, Nz),\n                              x = (0, 64), y = (0, 64),\n                              z = hyperbolically_spaced_faces)\n32×32×24 RectilinearGrid{Float64, Periodic, Periodic, Bounded} on CPU with 3×3×3 halo\n├── Periodic x ∈ [0.0, 64.0)   regularly spaced with Δx=2.0\n├── Periodic y ∈ [0.0, 64.0)   regularly spaced with Δy=2.0\n└── Bounded  z ∈ [-32.0, -0.0] variably spaced with min(Δz)=0.682695, max(Δz)=1.83091\n```\n\n* A three-dimensional grid with regular spacing in ``x``, cell interfaces at Chebyshev nodes\n  in ``y``, and cell interfaces hyperbolically stretched in ``z`` near the top:\n\n```jldoctest\njulia> using Oceananigans\n\njulia> Nx, Ny, Nz = 32, 30, 24;\n\njulia> Lx, Ly, Lz = 200, 100, 32; # (m)\n\njulia> chebychev_nodes(j) = - Ly/2 * cos(π * (j - 1) / Ny);\n\njulia> σ = 1.1; # stretching factor\n\njulia> hyperbolically_spaced_faces(k) = - Lz * (1 - tanh(σ * (k - 1) / Nz) / tanh(σ));\n\njulia> grid = RectilinearGrid(size = (Nx, Ny, Nz),\n                              topology = (Periodic, Bounded, Bounded),\n                              x = (0, Lx),\n                              y = chebychev_nodes,\n                              z = hyperbolically_spaced_faces)\n32×30×24 RectilinearGrid{Float64, Periodic, Bounded, Bounded} on CPU with 3×3×3 halo\n├── Periodic x ∈ [0.0, 200.0)  regularly spaced with Δx=6.25\n├── Bounded  y ∈ [-50.0, 50.0] variably spaced with min(Δy)=0.273905, max(Δy)=5.22642\n└── Bounded  z ∈ [-32.0, -0.0] variably spaced with min(Δz)=0.682695, max(Δz)=1.83091\n```\n" function RectilinearGrid(architecture::AbstractArchitecture = CPU(), FT::DataType = Float64; size, x = nothing, y = nothing, z = nothing, halo = nothing, extent = nothing, topology = (Periodic, Periodic, Bounded))
        #= none:254 =#
        #= none:264 =#
        if architecture == GPU() && !true
            #= none:265 =#
            throw(ArgumentError("Cannot create a GPU grid. No CUDA-enabled GPU was detected!"))
        end
        #= none:268 =#
        (topology, size, halo, x, y, z) = validate_rectilinear_grid_args(topology, size, halo, FT, extent, x, y, z)
        #= none:270 =#
        (TX, TY, TZ) = topology
        #= none:271 =#
        (Nx, Ny, Nz) = size
        #= none:272 =#
        (Hx, Hy, Hz) = halo
        #= none:274 =#
        (Lx, xᶠᵃᵃ, xᶜᵃᵃ, Δxᶠᵃᵃ, Δxᶜᵃᵃ) = generate_coordinate(FT, TX(), Nx, Hx, x, :x, architecture)
        #= none:275 =#
        (Ly, yᵃᶠᵃ, yᵃᶜᵃ, Δyᵃᶠᵃ, Δyᵃᶜᵃ) = generate_coordinate(FT, TY(), Ny, Hy, y, :y, architecture)
        #= none:276 =#
        (Lz, zᵃᵃᶠ, zᵃᵃᶜ, Δzᵃᵃᶠ, Δzᵃᵃᶜ) = generate_coordinate(FT, TZ(), Nz, Hz, z, :z, architecture)
        #= none:278 =#
        return RectilinearGrid{TX, TY, TZ}(architecture, Nx, Ny, Nz, Hx, Hy, Hz, Lx, Ly, Lz, Δxᶠᵃᵃ, Δxᶜᵃᵃ, xᶠᵃᵃ, xᶜᵃᵃ, Δyᵃᶠᵃ, Δyᵃᶜᵃ, yᵃᶠᵃ, yᵃᶜᵃ, Δzᵃᵃᶠ, Δzᵃᵃᶜ, zᵃᵃᶠ, zᵃᵃᶜ)
    end
#= none:287 =#
#= none:287 =# Core.@doc " Validate user input arguments to the `RectilinearGrid` constructor. " function validate_rectilinear_grid_args(topology, size, halo, FT, extent, x, y, z)
        #= none:288 =#
        #= none:289 =#
        (TX, TY, TZ) = (topology = validate_topology(topology))
        #= none:290 =#
        size = validate_size(TX, TY, TZ, size)
        #= none:291 =#
        halo = validate_halo(TX, TY, TZ, size, halo)
        #= none:294 =#
        (x, y, z) = validate_rectilinear_domain(TX, TY, TZ, FT, size, extent, x, y, z)
        #= none:296 =#
        return (topology, size, halo, x, y, z)
    end
#= none:303 =#
x_domain(grid::RectilinearGrid) = begin
        #= none:303 =#
        domain((topology(grid, 1))(), grid.Nx, grid.xᶠᵃᵃ)
    end
#= none:304 =#
y_domain(grid::RectilinearGrid) = begin
        #= none:304 =#
        domain((topology(grid, 2))(), grid.Ny, grid.yᵃᶠᵃ)
    end
#= none:305 =#
z_domain(grid::RectilinearGrid) = begin
        #= none:305 =#
        domain((topology(grid, 3))(), grid.Nz, grid.zᵃᵃᶠ)
    end
#= none:309 =#
RectilinearGrid(FT::DataType; kwargs...) = begin
        #= none:309 =#
        RectilinearGrid(CPU(), FT; kwargs...)
    end
#= none:311 =#
function Base.summary(grid::RectilinearGrid)
    #= none:311 =#
    #= none:312 =#
    FT = eltype(grid)
    #= none:313 =#
    (TX, TY, TZ) = topology(grid)
    #= none:315 =#
    return string(size_summary(size(grid)), " RectilinearGrid{$(FT), $(TX), $(TY), $(TZ)} on ", summary(architecture(grid)), " with ", size_summary(halo_size(grid)), " halo")
end
#= none:320 =#
function Base.show(io::IO, grid::RectilinearGrid, withsummary = true)
    #= none:320 =#
    #= none:321 =#
    (TX, TY, TZ) = topology(grid)
    #= none:323 =#
    Ωx = domain(TX(), grid.Nx, grid.xᶠᵃᵃ)
    #= none:324 =#
    Ωy = domain(TY(), grid.Ny, grid.yᵃᶠᵃ)
    #= none:325 =#
    Ωz = domain(TZ(), grid.Nz, grid.zᵃᵃᶠ)
    #= none:327 =#
    x_summary = domain_summary(TX(), "x", Ωx)
    #= none:328 =#
    y_summary = domain_summary(TY(), "y", Ωy)
    #= none:329 =#
    z_summary = domain_summary(TZ(), "z", Ωz)
    #= none:331 =#
    longest = max(length(x_summary), length(y_summary), length(z_summary))
    #= none:333 =#
    x_summary = dimension_summary(TX(), "x", Ωx, grid.Δxᶜᵃᵃ, longest - length(x_summary))
    #= none:334 =#
    y_summary = dimension_summary(TY(), "y", Ωy, grid.Δyᵃᶜᵃ, longest - length(y_summary))
    #= none:335 =#
    z_summary = dimension_summary(TZ(), "z", Ωz, grid.Δzᵃᵃᶜ, longest - length(z_summary))
    #= none:337 =#
    if withsummary
        #= none:338 =#
        print(io, summary(grid), "\n")
    end
    #= none:341 =#
    return print(io, "├── ", x_summary, "\n", "├── ", y_summary, "\n", "└── ", z_summary)
end
#= none:350 =#
function Adapt.adapt_structure(to, grid::RectilinearGrid)
    #= none:350 =#
    #= none:351 =#
    (TX, TY, TZ) = topology(grid)
    #= none:352 =#
    return RectilinearGrid{TX, TY, TZ}(nothing, grid.Nx, grid.Ny, grid.Nz, grid.Hx, grid.Hy, grid.Hz, grid.Lx, grid.Ly, grid.Lz, Adapt.adapt(to, grid.Δxᶠᵃᵃ), Adapt.adapt(to, grid.Δxᶜᵃᵃ), Adapt.adapt(to, grid.xᶠᵃᵃ), Adapt.adapt(to, grid.xᶜᵃᵃ), Adapt.adapt(to, grid.Δyᵃᶠᵃ), Adapt.adapt(to, grid.Δyᵃᶜᵃ), Adapt.adapt(to, grid.yᵃᶠᵃ), Adapt.adapt(to, grid.yᵃᶜᵃ), Adapt.adapt(to, grid.Δzᵃᵃᶠ), Adapt.adapt(to, grid.Δzᵃᵃᶜ), Adapt.adapt(to, grid.zᵃᵃᶠ), Adapt.adapt(to, grid.zᵃᵃᶜ))
end
#= none:370 =#
cpu_face_constructor_x(grid::XRegularRG) = begin
        #= none:370 =#
        x_domain(grid)
    end
#= none:371 =#
cpu_face_constructor_y(grid::YRegularRG) = begin
        #= none:371 =#
        y_domain(grid)
    end
#= none:372 =#
cpu_face_constructor_z(grid::ZRegularRG) = begin
        #= none:372 =#
        z_domain(grid)
    end
#= none:374 =#
function constructor_arguments(grid::RectilinearGrid)
    #= none:374 =#
    #= none:375 =#
    arch = architecture(grid)
    #= none:376 =#
    FT = eltype(grid)
    #= none:377 =#
    args = Dict(:architecture => arch, :number_type => eltype(grid))
    #= none:380 =#
    topo = topology(grid)
    #= none:381 =#
    size = (grid.Nx, grid.Ny, grid.Nz)
    #= none:382 =#
    halo = (grid.Hx, grid.Hy, grid.Hz)
    #= none:383 =#
    size = pop_flat_elements(size, topo)
    #= none:384 =#
    halo = pop_flat_elements(halo, topo)
    #= none:386 =#
    kwargs = Dict(:size => size, :halo => halo, :x => cpu_face_constructor_x(grid), :y => cpu_face_constructor_y(grid), :z => cpu_face_constructor_z(grid), :topology => topo)
    #= none:393 =#
    return (args, kwargs)
end
#= none:396 =#
function Base.similar(grid::RectilinearGrid)
    #= none:396 =#
    #= none:397 =#
    (args, kwargs) = constructor_arguments(grid)
    #= none:398 =#
    arch = args[:architecture]
    #= none:399 =#
    FT = args[:number_type]
    #= none:400 =#
    return RectilinearGrid(arch, FT; kwargs...)
end
#= none:403 =#
#= none:403 =# Core.@doc "    with_number_type(number_type, grid)\n\nReturn a `new_grid` that's identical to `grid` but with `number_type`.\n" function with_number_type(FT, grid::RectilinearGrid)
        #= none:408 =#
        #= none:409 =#
        (args, kwargs) = constructor_arguments(grid)
        #= none:410 =#
        arch = args[:architecture]
        #= none:411 =#
        return RectilinearGrid(arch, FT; kwargs...)
    end
#= none:414 =#
#= none:414 =# Core.@doc "    with_halo(halo, grid)\n\nReturn a `new_grid` that's identical to `grid` but with `halo`.\n" function with_halo(halo, grid::RectilinearGrid)
        #= none:419 =#
        #= none:420 =#
        (args, kwargs) = constructor_arguments(grid)
        #= none:421 =#
        halo = pop_flat_elements(halo, topology(grid))
        #= none:422 =#
        kwargs[:halo] = halo
        #= none:423 =#
        arch = args[:architecture]
        #= none:424 =#
        FT = args[:number_type]
        #= none:425 =#
        return RectilinearGrid(arch, FT; kwargs...)
    end
#= none:428 =#
#= none:428 =# Core.@doc "    on_architecture(architecture, grid)\n\nReturn a `new_grid` that's identical to `grid` but on `architecture`.\n" function on_architecture(arch::AbstractSerialArchitecture, grid::RectilinearGrid)
        #= none:433 =#
        #= none:434 =#
        if arch == architecture(grid)
            #= none:435 =#
            return grid
        end
        #= none:438 =#
        (args, kwargs) = constructor_arguments(grid)
        #= none:439 =#
        FT = args[:number_type]
        #= none:440 =#
        return RectilinearGrid(arch, FT; kwargs...)
    end
#= none:443 =#
coordinates(::RectilinearGrid) = begin
        #= none:443 =#
        (:xᶠᵃᵃ, :xᶜᵃᵃ, :yᵃᶠᵃ, :yᵃᶜᵃ, :zᵃᵃᶠ, :zᵃᵃᶜ)
    end
#= none:449 =#
ξname(::RG) = begin
        #= none:449 =#
        :x
    end
#= none:450 =#
ηname(::RG) = begin
        #= none:450 =#
        :y
    end
#= none:451 =#
rname(::RG) = begin
        #= none:451 =#
        :z
    end
#= none:453 =#
#= none:453 =# @inline xnode(i, grid::RG, ::Center) = begin
            #= none:453 =#
            getnode(grid.xᶜᵃᵃ, i)
        end
#= none:454 =#
#= none:454 =# @inline xnode(i, grid::RG, ::Face) = begin
            #= none:454 =#
            getnode(grid.xᶠᵃᵃ, i)
        end
#= none:455 =#
#= none:455 =# @inline ynode(j, grid::RG, ::Center) = begin
            #= none:455 =#
            getnode(grid.yᵃᶜᵃ, j)
        end
#= none:456 =#
#= none:456 =# @inline ynode(j, grid::RG, ::Face) = begin
            #= none:456 =#
            getnode(grid.yᵃᶠᵃ, j)
        end
#= none:457 =#
#= none:457 =# @inline znode(k, grid::RG, ::Center) = begin
            #= none:457 =#
            getnode(grid.zᵃᵃᶜ, k)
        end
#= none:458 =#
#= none:458 =# @inline znode(k, grid::RG, ::Face) = begin
            #= none:458 =#
            getnode(grid.zᵃᵃᶠ, k)
        end
#= none:460 =#
#= none:460 =# @inline ξnode(i, j, k, grid::RG, ℓx, ℓy, ℓz) = begin
            #= none:460 =#
            xnode(i, grid, ℓx)
        end
#= none:461 =#
#= none:461 =# @inline ηnode(i, j, k, grid::RG, ℓx, ℓy, ℓz) = begin
            #= none:461 =#
            ynode(j, grid, ℓy)
        end
#= none:462 =#
#= none:462 =# @inline rnode(i, j, k, grid::RG, ℓx, ℓy, ℓz) = begin
            #= none:462 =#
            znode(k, grid, ℓz)
        end
#= none:465 =#
#= none:465 =# @inline xnode(i, j, k, grid::RG, ℓx, ℓy, ℓz) = begin
            #= none:465 =#
            xnode(i, grid, ℓx)
        end
#= none:466 =#
#= none:466 =# @inline ynode(i, j, k, grid::RG, ℓx, ℓy, ℓz) = begin
            #= none:466 =#
            ynode(j, grid, ℓy)
        end
#= none:467 =#
#= none:467 =# @inline znode(i, j, k, grid::RG, ℓx, ℓy, ℓz) = begin
            #= none:467 =#
            znode(k, grid, ℓz)
        end
#= none:469 =#
function nodes(grid::RectilinearGrid, ℓx, ℓy, ℓz; reshape = false, with_halos = false)
    #= none:469 =#
    #= none:470 =#
    x = xnodes(grid, ℓx, ℓy, ℓz; with_halos)
    #= none:471 =#
    y = ynodes(grid, ℓx, ℓy, ℓz; with_halos)
    #= none:472 =#
    z = znodes(grid, ℓx, ℓy, ℓz; with_halos)
    #= none:474 =#
    if reshape
        #= none:485 =#
        Nx = if isnothing(x)
                1
            else
                length(x)
            end
        #= none:486 =#
        Ny = if isnothing(y)
                1
            else
                length(y)
            end
        #= none:487 =#
        Nz = if isnothing(z)
                1
            else
                length(z)
            end
        #= none:489 =#
        x = if isnothing(x)
                zeros(1, 1, 1)
            else
                Base.reshape(x, Nx, 1, 1)
            end
        #= none:490 =#
        y = if isnothing(y)
                zeros(1, 1, 1)
            else
                Base.reshape(y, 1, Ny, 1)
            end
        #= none:491 =#
        z = if isnothing(z)
                zeros(1, 1, 1)
            else
                Base.reshape(z, 1, 1, Nz)
            end
    end
    #= none:494 =#
    return (x, y, z)
end
#= none:497 =#
const F = Face
#= none:498 =#
const C = Center
#= none:500 =#
#= none:500 =# @inline xnodes(grid::RG, ℓx::F; with_halos = false) = begin
            #= none:500 =#
            _property(grid.xᶠᵃᵃ, ℓx, topology(grid, 1), size(grid, 1), with_halos)
        end
#= none:501 =#
#= none:501 =# @inline xnodes(grid::RG, ℓx::C; with_halos = false) = begin
            #= none:501 =#
            _property(grid.xᶜᵃᵃ, ℓx, topology(grid, 1), size(grid, 1), with_halos)
        end
#= none:502 =#
#= none:502 =# @inline ynodes(grid::RG, ℓy::F; with_halos = false) = begin
            #= none:502 =#
            _property(grid.yᵃᶠᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:503 =#
#= none:503 =# @inline ynodes(grid::RG, ℓy::C; with_halos = false) = begin
            #= none:503 =#
            _property(grid.yᵃᶜᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:504 =#
#= none:504 =# @inline znodes(grid::RG, ℓz::F; with_halos = false) = begin
            #= none:504 =#
            _property(grid.zᵃᵃᶠ, ℓz, topology(grid, 3), size(grid, 3), with_halos)
        end
#= none:505 =#
#= none:505 =# @inline znodes(grid::RG, ℓz::C; with_halos = false) = begin
            #= none:505 =#
            _property(grid.zᵃᵃᶜ, ℓz, topology(grid, 3), size(grid, 3), with_halos)
        end
#= none:508 =#
#= none:508 =# @inline xnodes(grid::RG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:508 =#
            xnodes(grid, ℓx; with_halos)
        end
#= none:509 =#
#= none:509 =# @inline ynodes(grid::RG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:509 =#
            ynodes(grid, ℓy; with_halos)
        end
#= none:510 =#
#= none:510 =# @inline znodes(grid::RG, ℓx, ℓy, ℓz; with_halos = false) = begin
            #= none:510 =#
            znodes(grid, ℓz; with_halos)
        end
#= none:513 =#
#= none:513 =# @inline ξnodes(grid::RG, ℓx; kwargs...) = begin
            #= none:513 =#
            xnodes(grid, ℓx; kwargs...)
        end
#= none:514 =#
#= none:514 =# @inline ηnodes(grid::RG, ℓy; kwargs...) = begin
            #= none:514 =#
            ynodes(grid, ℓy; kwargs...)
        end
#= none:515 =#
#= none:515 =# @inline rnodes(grid::RG, ℓz; kwargs...) = begin
            #= none:515 =#
            znodes(grid, ℓz; kwargs...)
        end
#= none:517 =#
#= none:517 =# @inline ξnodes(grid::RG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:517 =#
            xnodes(grid, ℓx; kwargs...)
        end
#= none:518 =#
#= none:518 =# @inline ηnodes(grid::RG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:518 =#
            ynodes(grid, ℓy; kwargs...)
        end
#= none:519 =#
#= none:519 =# @inline rnodes(grid::RG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:519 =#
            znodes(grid, ℓz; kwargs...)
        end
#= none:525 =#
#= none:525 =# @inline xspacings(grid::RG, ℓx::C; with_halos = false) = begin
            #= none:525 =#
            _property(grid.Δxᶜᵃᵃ, ℓx, topology(grid, 1), size(grid, 1), with_halos)
        end
#= none:526 =#
#= none:526 =# @inline xspacings(grid::RG, ℓx::F; with_halos = false) = begin
            #= none:526 =#
            _property(grid.Δxᶠᵃᵃ, ℓx, topology(grid, 1), size(grid, 1), with_halos)
        end
#= none:527 =#
#= none:527 =# @inline yspacings(grid::RG, ℓy::C; with_halos = false) = begin
            #= none:527 =#
            _property(grid.Δyᵃᶜᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:528 =#
#= none:528 =# @inline yspacings(grid::RG, ℓy::F; with_halos = false) = begin
            #= none:528 =#
            _property(grid.Δyᵃᶠᵃ, ℓy, topology(grid, 2), size(grid, 2), with_halos)
        end
#= none:529 =#
#= none:529 =# @inline zspacings(grid::RG, ℓz::C; with_halos = false) = begin
            #= none:529 =#
            _property(grid.Δzᵃᵃᶜ, ℓz, topology(grid, 3), size(grid, 3), with_halos)
        end
#= none:530 =#
#= none:530 =# @inline zspacings(grid::RG, ℓz::F; with_halos = false) = begin
            #= none:530 =#
            _property(grid.Δzᵃᵃᶠ, ℓz, topology(grid, 3), size(grid, 3), with_halos)
        end
#= none:532 =#
#= none:532 =# @inline xspacings(grid::RG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:532 =#
            xspacings(grid, ℓx; kwargs...)
        end
#= none:533 =#
#= none:533 =# @inline yspacings(grid::RG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:533 =#
            yspacings(grid, ℓy; kwargs...)
        end
#= none:534 =#
#= none:534 =# @inline zspacings(grid::RG, ℓx, ℓy, ℓz; kwargs...) = begin
            #= none:534 =#
            zspacings(grid, ℓz; kwargs...)
        end
#= none:536 =#
#= none:536 =# @inline isrectilinear(::RG) = begin
            #= none:536 =#
            true
        end