
#= none:1 =#
module ImmersedBoundaries
#= none:1 =#
#= none:3 =#
export ImmersedBoundaryGrid, GridFittedBoundary, GridFittedBottom, PartialCellBottom, ImmersedBoundaryCondition
#= none:5 =#
using Adapt
#= none:7 =#
using Oceananigans.Grids
#= none:8 =#
using Oceananigans.Operators
#= none:9 =#
using Oceananigans.Fields
#= none:10 =#
using Oceananigans.Utils
#= none:11 =#
using Oceananigans.Architectures
#= none:13 =#
using Oceananigans.Grids: size_summary, inactive_node, peripheral_node, AbstractGrid
#= none:15 =#
import Base: show, summary
#= none:17 =#
import Oceananigans.Grids: cpu_face_constructor_x, cpu_face_constructor_y, cpu_face_constructor_z, x_domain, y_domain, z_domain
#= none:20 =#
import Oceananigans.Grids: architecture, on_architecture, with_halo, inflate_halo_size_one_dimension, xnode, ynode, znode, λnode, φnode, node, ξnode, ηnode, rnode, ξname, ηname, rname, node_names, xnodes, ynodes, znodes, λnodes, φnodes, nodes, ξnodes, ηnodes, rnodes, inactive_cell
#= none:29 =#
import Oceananigans.Fields: fractional_x_index, fractional_y_index, fractional_z_index
#= none:31 =#
#= none:31 =# Core.@doc "    abstract type AbstractImmersedBoundary\n\nAbstract supertype for immersed boundary grids.\n" abstract type AbstractImmersedBoundary end
#= none:42 =#
struct ImmersedBoundaryGrid{FT, TX, TY, TZ, G, I, M, S, Arch} <: AbstractGrid{FT, TX, TY, TZ, Arch}
    #= none:43 =#
    architecture::Arch
    #= none:44 =#
    underlying_grid::G
    #= none:45 =#
    immersed_boundary::I
    #= none:46 =#
    interior_active_cells::M
    #= none:47 =#
    active_z_columns::S
    #= none:50 =#
    function ImmersedBoundaryGrid{TX, TY, TZ}(grid::G, ib::I, mi::M, ms::S) where {TX, TY, TZ, G <: AbstractUnderlyingGrid, I, M, S}
        #= none:50 =#
        #= none:51 =#
        FT = eltype(grid)
        #= none:52 =#
        arch = architecture(grid)
        #= none:53 =#
        Arch = typeof(arch)
        #= none:54 =#
        return new{FT, TX, TY, TZ, G, I, M, S, Arch}(arch, grid, ib, mi, ms)
    end
    #= none:58 =#
    function ImmersedBoundaryGrid{TX, TY, TZ}(grid::G, ib::I) where {TX, TY, TZ, G <: AbstractUnderlyingGrid, I}
        #= none:58 =#
        #= none:59 =#
        FT = eltype(grid)
        #= none:60 =#
        arch = architecture(grid)
        #= none:61 =#
        Arch = typeof(arch)
        #= none:62 =#
        return new{FT, TX, TY, TZ, G, I, Nothing, Nothing, Arch}(arch, grid, ib, nothing, nothing)
    end
end
#= none:66 =#
const IBG = ImmersedBoundaryGrid
#= none:68 =#
#= none:68 =# @inline Base.getproperty(ibg::IBG, property::Symbol) = begin
            #= none:68 =#
            get_ibg_property(ibg, Val(property))
        end
#= none:69 =#
#= none:69 =# @inline (get_ibg_property(ibg::IBG, ::Val{property}) where property) = begin
            #= none:69 =#
            getfield(getfield(ibg, :underlying_grid), property)
        end
#= none:70 =#
#= none:70 =# @inline get_ibg_property(ibg::IBG, ::Val{:immersed_boundary}) = begin
            #= none:70 =#
            getfield(ibg, :immersed_boundary)
        end
#= none:71 =#
#= none:71 =# @inline get_ibg_property(ibg::IBG, ::Val{:underlying_grid}) = begin
            #= none:71 =#
            getfield(ibg, :underlying_grid)
        end
#= none:72 =#
#= none:72 =# @inline get_ibg_property(ibg::IBG, ::Val{:interior_active_cells}) = begin
            #= none:72 =#
            getfield(ibg, :interior_active_cells)
        end
#= none:73 =#
#= none:73 =# @inline get_ibg_property(ibg::IBG, ::Val{:active_z_columns}) = begin
            #= none:73 =#
            getfield(ibg, :active_z_columns)
        end
#= none:75 =#
#= none:75 =# @inline architecture(ibg::IBG) = begin
            #= none:75 =#
            architecture(ibg.underlying_grid)
        end
#= none:77 =#
#= none:77 =# @inline x_domain(ibg::IBG) = begin
            #= none:77 =#
            x_domain(ibg.underlying_grid)
        end
#= none:78 =#
#= none:78 =# @inline y_domain(ibg::IBG) = begin
            #= none:78 =#
            y_domain(ibg.underlying_grid)
        end
#= none:79 =#
#= none:79 =# @inline z_domain(ibg::IBG) = begin
            #= none:79 =#
            z_domain(ibg.underlying_grid)
        end
#= none:81 =#
(Adapt.adapt_structure(to, ibg::IBG{FT, TX, TY, TZ}) where {FT, TX, TY, TZ}) = begin
        #= none:81 =#
        ImmersedBoundaryGrid{TX, TY, TZ}(adapt(to, ibg.underlying_grid), adapt(to, ibg.immersed_boundary), nothing, nothing)
    end
#= none:87 =#
with_halo(halo, ibg::ImmersedBoundaryGrid) = begin
        #= none:87 =#
        ImmersedBoundaryGrid(with_halo(halo, ibg.underlying_grid), ibg.immersed_boundary)
    end
#= none:92 =#
inflate_halo_size_one_dimension(req_H, old_H, _, ::IBG) = begin
        #= none:92 =#
        max(req_H + 1, old_H)
    end
#= none:93 =#
inflate_halo_size_one_dimension(req_H, old_H, ::Type{Flat}, ::IBG) = begin
        #= none:93 =#
        0
    end
#= none:96 =#
#= none:96 =# @inline z_bottom(i, j, grid) = begin
            #= none:96 =#
            znode(i, j, 1, grid, c, c, f)
        end
#= none:97 =#
#= none:97 =# @inline z_bottom(i, j, ibg::IBG) = begin
            #= none:97 =#
            error("The function `bottom` has not been defined for $(summary(ibg))!")
        end
#= none:99 =#
function Base.summary(grid::ImmersedBoundaryGrid)
    #= none:99 =#
    #= none:100 =#
    FT = eltype(grid)
    #= none:101 =#
    (TX, TY, TZ) = topology(grid)
    #= none:103 =#
    return string(size_summary(size(grid)), " ImmersedBoundaryGrid{$(FT), $(TX), $(TY), $(TZ)} on ", summary(architecture(grid)), " with ", size_summary(halo_size(grid)), " halo")
end
#= none:108 =#
function show(io::IO, ibg::ImmersedBoundaryGrid)
    #= none:108 =#
    #= none:109 =#
    print(io, summary(ibg), ":", "\n", "├── immersed_boundary: ", summary(ibg.immersed_boundary), "\n", "├── underlying_grid: ", summary(ibg.underlying_grid), "\n")
    #= none:113 =#
    return show(io, ibg.underlying_grid, false)
end
#= none:120 =#
#= none:120 =# Core.@doc "    immersed_cell(i, j, k, grid)\n\nReturn true if a `cell` is \"completely\" immersed, and thus\nis not part of the prognostic state.\n" #= none:126 =# @inline(immersed_cell(i, j, k, grid) = begin
                #= none:126 =#
                false
            end)
#= none:129 =#
#= none:129 =# @inline immersed_cell(i, j, k, grid::ImmersedBoundaryGrid) = begin
            #= none:129 =#
            immersed_cell(i, j, k, grid.underlying_grid, grid.immersed_boundary)
        end
#= none:132 =#
#= none:132 =# Core.@doc "    inactive_cell(i, j, k, grid::ImmersedBoundaryGrid)\n\nReturn `true` if the tracer cell at `i, j, k` either (i) lies outside the `Bounded` domain\nor (ii) lies within the immersed region of `ImmersedBoundaryGrid`.\n\nExample\n=======\n\nConsider the configuration\n\n```\n   Immersed      Fluid\n  =========== ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅\n\n       c           c\n      i-1          i\n\n | ========= |           |\n × === ∘ === ×     ∘     ×\n | ========= |           |\n\ni-1          i\n f           f           f\n```\n\nWe then have\n\n* `inactive_node(i, 1, 1, grid, f, c, c) = false`\n\nAs well as\n\n* `inactive_node(i,   1, 1, grid, c, c, c) = false`\n* `inactive_node(i-1, 1, 1, grid, c, c, c) = true`\n* `inactive_node(i-1, 1, 1, grid, f, c, c) = true`\n" #= none:168 =# @inline(inactive_cell(i, j, k, ibg::IBG) = begin
                #= none:168 =#
                immersed_cell(i, j, k, ibg) | inactive_cell(i, j, k, ibg.underlying_grid)
            end)
#= none:171 =#
#= none:171 =# @inline immersed_peripheral_node(i, j, k, ibg::IBG, LX, LY, LZ) = begin
            #= none:171 =#
            peripheral_node(i, j, k, ibg, LX, LY, LZ) & !(peripheral_node(i, j, k, ibg.underlying_grid, LX, LY, LZ))
        end
#= none:174 =#
#= none:174 =# @inline immersed_inactive_node(i, j, k, ibg::IBG, LX, LY, LZ) = begin
            #= none:174 =#
            inactive_node(i, j, k, ibg, LX, LY, LZ) & !(inactive_node(i, j, k, ibg.underlying_grid, LX, LY, LZ))
        end
#= none:181 =#
const c = Center()
#= none:182 =#
const f = Face()
#= none:184 =#
#= none:184 =# @inline Base.zero(ibg::IBG) = begin
            #= none:184 =#
            zero(ibg.underlying_grid)
        end
#= none:186 =#
#= none:186 =# @inline xnode(i, j, k, ibg::IBG, ℓx, ℓy, ℓz) = begin
            #= none:186 =#
            xnode(i, j, k, ibg.underlying_grid, ℓx, ℓy, ℓz)
        end
#= none:187 =#
#= none:187 =# @inline ynode(i, j, k, ibg::IBG, ℓx, ℓy, ℓz) = begin
            #= none:187 =#
            ynode(i, j, k, ibg.underlying_grid, ℓx, ℓy, ℓz)
        end
#= none:188 =#
#= none:188 =# @inline znode(i, j, k, ibg::IBG, ℓx, ℓy, ℓz) = begin
            #= none:188 =#
            znode(i, j, k, ibg.underlying_grid, ℓx, ℓy, ℓz)
        end
#= none:190 =#
#= none:190 =# @inline λnode(i, j, k, ibg::IBG, ℓx, ℓy, ℓz) = begin
            #= none:190 =#
            λnode(i, j, k, ibg.underlying_grid, ℓx, ℓy, ℓz)
        end
#= none:191 =#
#= none:191 =# @inline φnode(i, j, k, ibg::IBG, ℓx, ℓy, ℓz) = begin
            #= none:191 =#
            φnode(i, j, k, ibg.underlying_grid, ℓx, ℓy, ℓz)
        end
#= none:193 =#
#= none:193 =# @inline ξnode(i, j, k, ibg::IBG, ℓx, ℓy, ℓz) = begin
            #= none:193 =#
            ξnode(i, j, k, ibg.underlying_grid, ℓx, ℓy, ℓz)
        end
#= none:194 =#
#= none:194 =# @inline ηnode(i, j, k, ibg::IBG, ℓx, ℓy, ℓz) = begin
            #= none:194 =#
            ηnode(i, j, k, ibg.underlying_grid, ℓx, ℓy, ℓz)
        end
#= none:195 =#
#= none:195 =# @inline rnode(i, j, k, ibg::IBG, ℓx, ℓy, ℓz) = begin
            #= none:195 =#
            rnode(i, j, k, ibg.underlying_grid, ℓx, ℓy, ℓz)
        end
#= none:197 =#
#= none:197 =# @inline node(i, j, k, ibg::IBG, ℓx, ℓy, ℓz) = begin
            #= none:197 =#
            node(i, j, k, ibg.underlying_grid, ℓx, ℓy, ℓz)
        end
#= none:199 =#
nodes(ibg::IBG, ℓx, ℓy, ℓz; kwargs...) = begin
        #= none:199 =#
        nodes(ibg.underlying_grid, ℓx, ℓy, ℓz; kwargs...)
    end
#= none:200 =#
nodes(ibg::IBG, (ℓx, ℓy, ℓz); kwargs...) = begin
        #= none:200 =#
        nodes(ibg, ℓx, ℓy, ℓz; kwargs...)
    end
#= none:202 =#
xnodes(ibg::IBG, loc; kwargs...) = begin
        #= none:202 =#
        xnodes(ibg.underlying_grid, loc; kwargs...)
    end
#= none:203 =#
ynodes(ibg::IBG, loc; kwargs...) = begin
        #= none:203 =#
        ynodes(ibg.underlying_grid, loc; kwargs...)
    end
#= none:204 =#
znodes(ibg::IBG, loc; kwargs...) = begin
        #= none:204 =#
        znodes(ibg.underlying_grid, loc; kwargs...)
    end
#= none:206 =#
λnodes(ibg::IBG, loc; kwargs...) = begin
        #= none:206 =#
        λnodes(ibg.underlying_grid, loc; kwargs...)
    end
#= none:207 =#
φnodes(ibg::IBG, loc; kwargs...) = begin
        #= none:207 =#
        φnodes(ibg.underlying_grid, loc; kwargs...)
    end
#= none:209 =#
ξnodes(ibg::IBG, loc; kwargs...) = begin
        #= none:209 =#
        ξnodes(ibg.underlying_grid, loc; kwargs...)
    end
#= none:210 =#
ηnodes(ibg::IBG, loc; kwargs...) = begin
        #= none:210 =#
        ηnodes(ibg.underlying_grid, loc; kwargs...)
    end
#= none:211 =#
rnodes(ibg::IBG, loc; kwargs...) = begin
        #= none:211 =#
        rnodes(ibg.underlying_grid, loc; kwargs...)
    end
#= none:213 =#
xnodes(ibg::IBG, ℓx, ℓy, ℓz; kwargs...) = begin
        #= none:213 =#
        xnodes(ibg.underlying_grid, ℓx, ℓy, ℓz; kwargs...)
    end
#= none:214 =#
ynodes(ibg::IBG, ℓx, ℓy, ℓz; kwargs...) = begin
        #= none:214 =#
        ynodes(ibg.underlying_grid, ℓx, ℓy, ℓz; kwargs...)
    end
#= none:215 =#
znodes(ibg::IBG, ℓx, ℓy, ℓz; kwargs...) = begin
        #= none:215 =#
        znodes(ibg.underlying_grid, ℓx, ℓy, ℓz; kwargs...)
    end
#= none:217 =#
λnodes(ibg::IBG, ℓx, ℓy, ℓz; kwargs...) = begin
        #= none:217 =#
        λnodes(ibg.underlying_grid, ℓx, ℓy, ℓz; kwargs...)
    end
#= none:218 =#
φnodes(ibg::IBG, ℓx, ℓy, ℓz; kwargs...) = begin
        #= none:218 =#
        φnodes(ibg.underlying_grid, ℓx, ℓy, ℓz; kwargs...)
    end
#= none:220 =#
ξnodes(ibg::IBG, ℓx, ℓy, ℓz; kwargs...) = begin
        #= none:220 =#
        ξnodes(ibg.underlying_grid, ℓx, ℓy, ℓz; kwargs...)
    end
#= none:221 =#
ηnodes(ibg::IBG, ℓx, ℓy, ℓz; kwargs...) = begin
        #= none:221 =#
        ηnodes(ibg.underlying_grid, ℓx, ℓy, ℓz; kwargs...)
    end
#= none:222 =#
rnodes(ibg::IBG, ℓx, ℓy, ℓz; kwargs...) = begin
        #= none:222 =#
        rnodes(ibg.underlying_grid, ℓx, ℓy, ℓz; kwargs...)
    end
#= none:224 =#
#= none:224 =# @inline cpu_face_constructor_x(ibg::IBG) = begin
            #= none:224 =#
            cpu_face_constructor_x(ibg.underlying_grid)
        end
#= none:225 =#
#= none:225 =# @inline cpu_face_constructor_y(ibg::IBG) = begin
            #= none:225 =#
            cpu_face_constructor_y(ibg.underlying_grid)
        end
#= none:226 =#
#= none:226 =# @inline cpu_face_constructor_z(ibg::IBG) = begin
            #= none:226 =#
            cpu_face_constructor_z(ibg.underlying_grid)
        end
#= none:228 =#
node_names(ibg::IBG, ℓx, ℓy, ℓz) = begin
        #= none:228 =#
        node_names(ibg.underlying_grid, ℓx, ℓy, ℓz)
    end
#= none:229 =#
ξname(ibg::IBG) = begin
        #= none:229 =#
        ξname(ibg.underlying_grid)
    end
#= none:230 =#
ηname(ibg::IBG) = begin
        #= none:230 =#
        ηname(ibg.underlying_grid)
    end
#= none:231 =#
rname(ibg::IBG) = begin
        #= none:231 =#
        rname(ibg.underlying_grid)
    end
#= none:233 =#
function on_architecture(arch, ibg::IBG)
    #= none:233 =#
    #= none:234 =#
    underlying_grid = on_architecture(arch, ibg.underlying_grid)
    #= none:235 =#
    immersed_boundary = on_architecture(arch, ibg.immersed_boundary)
    #= none:236 =#
    return ImmersedBoundaryGrid(underlying_grid, immersed_boundary)
end
#= none:239 =#
isrectilinear(ibg::IBG) = begin
        #= none:239 =#
        isrectilinear(ibg.underlying_grid)
    end
#= none:241 =#
#= none:241 =# @inline fractional_x_index(x, locs, grid::ImmersedBoundaryGrid) = begin
            #= none:241 =#
            fractional_x_index(x, locs, grid.underlying_grid)
        end
#= none:242 =#
#= none:242 =# @inline fractional_y_index(x, locs, grid::ImmersedBoundaryGrid) = begin
            #= none:242 =#
            fractional_y_index(x, locs, grid.underlying_grid)
        end
#= none:243 =#
#= none:243 =# @inline fractional_z_index(x, locs, grid::ImmersedBoundaryGrid) = begin
            #= none:243 =#
            fractional_z_index(x, locs, grid.underlying_grid)
        end
#= none:245 =#
include("active_cells_map.jl")
#= none:246 =#
include("immersed_grid_metrics.jl")
#= none:247 =#
include("abstract_grid_fitted_boundary.jl")
#= none:248 =#
include("grid_fitted_boundary.jl")
#= none:249 =#
include("grid_fitted_bottom.jl")
#= none:250 =#
include("partial_cell_bottom.jl")
#= none:251 =#
include("immersed_boundary_condition.jl")
#= none:252 =#
include("conditional_differences.jl")
#= none:253 =#
include("mask_immersed_field.jl")
#= none:254 =#
include("immersed_reductions.jl")
end