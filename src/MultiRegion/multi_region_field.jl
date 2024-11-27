
#= none:1 =#
using Oceananigans.BoundaryConditions: default_auxiliary_bc
#= none:2 =#
using Oceananigans.Fields: FunctionField, data_summary, AbstractField
#= none:3 =#
using Oceananigans.AbstractOperations: AbstractOperation, compute_computed_field!
#= none:4 =#
using Oceananigans.Operators: assumed_field_location
#= none:5 =#
using Oceananigans.OutputWriters: output_indices
#= none:7 =#
using Base: @propagate_inbounds
#= none:9 =#
import Oceananigans.DistributedComputations: reconstruct_global_field
#= none:10 =#
import Oceananigans.BoundaryConditions: FieldBoundaryConditions, regularize_field_boundary_conditions
#= none:11 =#
import Oceananigans.Grids: xnodes, ynodes
#= none:12 =#
import Oceananigans.Fields: set!, compute!, compute_at!, validate_field_data, validate_boundary_conditions
#= none:13 =#
import Oceananigans.Fields: validate_indices, FieldBoundaryBuffers
#= none:14 =#
import Oceananigans.Models: hasnan
#= none:16 =#
import Base: fill!, axes
#= none:19 =#
const MultiRegionField{LX, LY, LZ, O} = (Field{LX, LY, LZ, O, <:MultiRegionGrids} where {LX, LY, LZ, O})
#= none:20 =#
const MultiRegionComputedField{LX, LY, LZ, O} = (Field{LX, LY, LZ, <:AbstractOperation, <:MultiRegionGrids} where {LX, LY, LZ})
#= none:21 =#
const MultiRegionFunctionField{LX, LY, LZ, C, P, F} = (FunctionField{LX, LY, LZ, C, P, F, <:MultiRegionGrids} where {LX, LY, LZ, C, P, F})
#= none:23 =#
const GriddedMultiRegionField = Union{MultiRegionField, MultiRegionFunctionField}
#= none:24 =#
const GriddedMultiRegionFieldTuple{N, T} = (NTuple{N, T} where {N, T <: GriddedMultiRegionField})
#= none:25 =#
const GriddedMultiRegionFieldNamedTuple{S, N} = (NamedTuple{S, N} where {S, N <: GriddedMultiRegionFieldTuple})
#= none:28 =#
Base.size(f::GriddedMultiRegionField) = begin
        #= none:28 =#
        size(getregion(f.grid, 1))
    end
#= none:30 =#
#= none:30 =# @inline isregional(f::GriddedMultiRegionField) = begin
            #= none:30 =#
            true
        end
#= none:31 =#
#= none:31 =# @inline devices(f::GriddedMultiRegionField) = begin
            #= none:31 =#
            devices(f.grid)
        end
#= none:32 =#
#= none:32 =# @inline sync_all_devices!(f::GriddedMultiRegionField) = begin
            #= none:32 =#
            sync_all_devices!(devices(f.grid))
        end
#= none:34 =#
#= none:34 =# @inline switch_device!(f::GriddedMultiRegionField, d) = begin
            #= none:34 =#
            switch_device!(f.grid, d)
        end
#= none:35 =#
#= none:35 =# @inline getdevice(f::GriddedMultiRegionField, d) = begin
            #= none:35 =#
            getdevice(f.grid, d)
        end
#= none:37 =#
#= none:37 =# @inline (getregion(f::MultiRegionFunctionField{LX, LY, LZ}, r) where {LX, LY, LZ}) = begin
            #= none:37 =#
            FunctionField{LX, LY, LZ}(_getregion(f.func, r), _getregion(f.grid, r), clock = _getregion(f.clock, r), parameters = _getregion(f.parameters, r))
        end
#= none:43 =#
#= none:43 =# @inline (getregion(f::MultiRegionField{LX, LY, LZ}, r) where {LX, LY, LZ}) = begin
            #= none:43 =#
            Field{LX, LY, LZ}(_getregion(f.grid, r), _getregion(f.data, r), _getregion(f.boundary_conditions, r), _getregion(f.indices, r), _getregion(f.operand, r), _getregion(f.status, r), _getregion(f.boundary_buffers, r))
        end
#= none:52 =#
#= none:52 =# @inline (_getregion(f::MultiRegionFunctionField{LX, LY, LZ}, r) where {LX, LY, LZ}) = begin
            #= none:52 =#
            FunctionField{LX, LY, LZ}(getregion(f.func, r), getregion(f.grid, r), clock = getregion(f.clock, r), parameters = getregion(f.parameters, r))
        end
#= none:58 =#
#= none:58 =# @inline (_getregion(f::MultiRegionField{LX, LY, LZ}, r) where {LX, LY, LZ}) = begin
            #= none:58 =#
            Field{LX, LY, LZ}(getregion(f.grid, r), getregion(f.data, r), getregion(f.boundary_conditions, r), getregion(f.indices, r), getregion(f.operand, r), getregion(f.status, r), getregion(f.boundary_buffers, r))
        end
#= none:67 =#
#= none:67 =# Core.@doc "    reconstruct_global_field(mrf)\n\nReconstruct a global field from `mrf::MultiRegionField` on the `CPU`.\n" function reconstruct_global_field(mrf::MultiRegionField)
        #= none:72 =#
        #= none:73 =#
        global_grid = on_architecture(CPU(), reconstruct_global_grid(mrf.grid))
        #= none:74 =#
        indices = reconstruct_global_indices(mrf.indices, mrf.grid.partition, size(global_grid))
        #= none:75 =#
        global_field = Field(location(mrf), global_grid; indices)
        #= none:77 =#
        data = construct_regionally(interior, mrf)
        #= none:78 =#
        data = construct_regionally(Array, data)
        #= none:79 =#
        compact_data!(global_field, global_grid, data, mrf.grid.partition)
        #= none:81 =#
        fill_halo_regions!(global_field)
        #= none:82 =#
        return global_field
    end
#= none:85 =#
function reconstruct_global_indices(indices, p::XPartition, N)
    #= none:85 =#
    #= none:86 =#
    idx1 = (getregion(indices, 1))[1]
    #= none:87 =#
    idxl = (getregion(indices, length(p)))[1]
    #= none:89 =#
    if idx1 == Colon() && idxl == Colon()
        #= none:90 =#
        idx_x = Colon()
    else
        #= none:92 =#
        idx_x = UnitRange(if idx1 == Colon()
                    1
                else
                    first(idx1)
                end, if idxl == Colon()
                    N[1]
                else
                    last(idxl)
                end)
    end
    #= none:95 =#
    idx_y = (getregion(indices, 1))[2]
    #= none:96 =#
    idx_z = (getregion(indices, 1))[3]
    #= none:98 =#
    return (idx_x, idx_y, idx_z)
end
#= none:101 =#
function reconstruct_global_indices(indices, p::YPartition, N)
    #= none:101 =#
    #= none:102 =#
    idx1 = (getregion(indices, 1))[2]
    #= none:103 =#
    idxl = (getregion(indices, length(p)))[2]
    #= none:105 =#
    if idx1 == Colon() && idxl == Colon()
        #= none:106 =#
        idx_y = Colon()
    else
        #= none:108 =#
        idx_y = UnitRange(if ix1 == Colon()
                    1
                else
                    first(idx1)
                end, if idxl == Colon()
                    N[2]
                else
                    last(idxl)
                end)
    end
    #= none:111 =#
    idx_x = (getregion(indices, 1))[1]
    #= none:112 =#
    idx_z = (getregion(indices, 1))[3]
    #= none:114 =#
    return (idx_x, idx_y, idx_z)
end
#= none:118 =#
set!(mrf::MultiRegionField, v) = begin
        #= none:118 =#
        apply_regionally!(set!, mrf, v)
    end
#= none:119 =#
fill!(mrf::MultiRegionField, v) = begin
        #= none:119 =#
        apply_regionally!(fill!, mrf, v)
    end
#= none:121 =#
set!(mrf::MultiRegionField, f::Function) = begin
        #= none:121 =#
        apply_regionally!(set!, mrf, f)
    end
#= none:122 =#
set!(u::MultiRegionField, v::MultiRegionField) = begin
        #= none:122 =#
        apply_regionally!(set!, u, v)
    end
#= none:123 =#
compute!(mrf::GriddedMultiRegionField, time = nothing) = begin
        #= none:123 =#
        apply_regionally!(compute!, mrf, time)
    end
#= none:126 =#
function compute!(comp::MultiRegionComputedField, time = nothing)
    #= none:126 =#
    #= none:128 =#
    compute_at!(comp.operand, time)
    #= none:131 =#
    #= none:131 =# @apply_regionally compute_computed_field!(comp)
    #= none:133 =#
    fill_halo_regions!(comp)
    #= none:135 =#
    return comp
end
#= none:138 =#
#= none:138 =# @inline hasnan(field::MultiRegionField) = begin
            #= none:138 =#
            (&)((construct_regionally(hasnan, field)).regional_objects...)
        end
#= none:140 =#
validate_indices(indices, loc, mrg::MultiRegionGrid) = begin
        #= none:140 =#
        construct_regionally(validate_indices, indices, loc, mrg.region_grids)
    end
#= none:143 =#
FieldBoundaryBuffers(grid::MultiRegionGrid, args...; kwargs...) = begin
        #= none:143 =#
        construct_regionally(FieldBoundaryBuffers, grid, args...; kwargs...)
    end
#= none:146 =#
FieldBoundaryConditions(mrg::MultiRegionGrid, loc, indices; kwargs...) = begin
        #= none:146 =#
        construct_regionally(inject_regional_bcs, mrg, mrg.connectivity, Reference(loc), indices; kwargs...)
    end
#= none:149 =#
function regularize_field_boundary_conditions(bcs::FieldBoundaryConditions, mrg::MultiRegionGrids, field_name::Symbol, prognostic_field_name = nothing)
    #= none:149 =#
    #= none:154 =#
    reg_bcs = regularize_field_boundary_conditions(bcs, mrg.region_grids[1], field_name, prognostic_field_name)
    #= none:155 =#
    loc = assumed_field_location(field_name)
    #= none:157 =#
    return FieldBoundaryConditions(mrg, loc; west = reg_bcs.west, east = reg_bcs.east, south = reg_bcs.south, north = reg_bcs.north, bottom = reg_bcs.bottom, top = reg_bcs.top, immersed = reg_bcs.immersed)
end
#= none:166 =#
function inject_regional_bcs(grid, connectivity, loc, indices; west = default_auxiliary_bc((topology(grid, 1))(), (loc[1])()), east = default_auxiliary_bc((topology(grid, 1))(), (loc[1])()), south = default_auxiliary_bc((topology(grid, 2))(), (loc[2])()), north = default_auxiliary_bc((topology(grid, 2))(), (loc[2])()), bottom = default_auxiliary_bc((topology(grid, 3))(), (loc[3])()), top = default_auxiliary_bc((topology(grid, 3))(), (loc[3])()), immersed = NoFluxBoundaryCondition())
    #= none:166 =#
    #= none:175 =#
    west = inject_west_boundary(connectivity, west)
    #= none:176 =#
    east = inject_east_boundary(connectivity, east)
    #= none:177 =#
    south = inject_south_boundary(connectivity, south)
    #= none:178 =#
    north = inject_north_boundary(connectivity, north)
    #= none:180 =#
    return FieldBoundaryConditions(indices, west, east, south, north, bottom, top, immersed)
end
#= none:183 =#
function Base.show(io::IO, field::MultiRegionField)
    #= none:183 =#
    #= none:184 =#
    bcs = (getregion(field, 1)).boundary_conditions
    #= none:186 =#
    prefix = string("$(summary(field))\n", "├── grid: ", summary(field.grid), "\n", "├── boundary conditions: ", summary(bcs), "\n")
    #= none:190 =#
    middle = if isnothing(field.operand)
            ""
        else
            string("├── operand: ", summary(field.operand), "\n", "├── status: ", summary(field.status), "\n")
        end
    #= none:194 =#
    suffix = string("└── data: ", summary(field.data), "\n", "    └── ", data_summary(field))
    #= none:197 =#
    print(io, prefix, middle, suffix)
end
#= none:200 =#
xnodes(ψ::AbstractField{<:Any, <:Any, <:Any, <:OrthogonalSphericalShellGrid}) = begin
        #= none:200 =#
        xnodes((location(ψ, 1), location(ψ, 2)), ψ.grid)
    end
#= none:201 =#
ynodes(ψ::AbstractField{<:Any, <:Any, <:Any, <:OrthogonalSphericalShellGrid}) = begin
        #= none:201 =#
        ynodes((location(ψ, 1), location(ψ, 2)), ψ.grid)
    end
#= none:204 =#
#= none:204 =# @propagate_inbounds Base.getindex(mrf::MultiRegionField, r::Int) = begin
            #= none:204 =#
            getregion(mrf, r)
        end
#= none:205 =#
#= none:205 =# @propagate_inbounds Base.lastindex(mrf::MultiRegionField) = begin
            #= none:205 =#
            lastindex(mrf.grid)
        end