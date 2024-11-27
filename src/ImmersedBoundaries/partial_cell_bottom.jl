
#= none:1 =#
using Oceananigans.Utils: prettysummary
#= none:2 =#
using Oceananigans.Fields: fill_halo_regions!
#= none:3 =#
using Printf
#= none:9 =#
struct PartialCellBottom{H, E} <: AbstractGridFittedBottom{H}
    #= none:10 =#
    bottom_height::H
    #= none:11 =#
    minimum_fractional_cell_height::E
end
#= none:14 =#
const PCBIBG{FT, TX, TY, TZ} = (ImmersedBoundaryGrid{FT, TX, TY, TZ, <:Any, <:PartialCellBottom} where {FT, TX, TY, TZ})
#= none:16 =#
function Base.summary(ib::PartialCellBottom)
    #= none:16 =#
    #= none:17 =#
    zmax = maximum(parent(ib.bottom_height))
    #= none:18 =#
    zmin = minimum(parent(ib.bottom_height))
    #= none:19 =#
    zmean = mean(parent(ib.bottom_height))
    #= none:21 =#
    summary1 = "PartialCellBottom("
    #= none:23 =#
    summary2 = string("mean(zb)=", prettysummary(zmean), ", min(zb)=", prettysummary(zmin), ", max(zb)=", prettysummary(zmax), ", ϵ=", prettysummary(ib.minimum_fractional_cell_height))
    #= none:28 =#
    summary3 = ")"
    #= none:30 =#
    return summary1 * summary2 * summary3
end
#= none:33 =#
Base.summary(ib::PartialCellBottom{<:Function}) = begin
        #= none:33 =#
        #= none:33 =# @sprintf "PartialCellBottom(%s, ϵ=%.1f)" prettysummary(ib.bottom_height, false) prettysummary(ib.minimum_fractional_cell_height)
    end
#= none:37 =#
function Base.show(io::IO, ib::PartialCellBottom)
    #= none:37 =#
    #= none:38 =#
    print(io, summary(ib), '\n')
    #= none:39 =#
    print(io, "├── bottom_height: ", prettysummary(ib.bottom_height), '\n')
    #= none:40 =#
    print(io, "└── minimum_fractional_cell_height: ", prettysummary(ib.minimum_fractional_cell_height))
end
#= none:43 =#
#= none:43 =# Core.@doc "    PartialCellBottom(bottom_height; minimum_fractional_cell_height=0.2)\n\nReturn `PartialCellBottom` representing an immersed boundary with \"partial\"\nbottom cells. That is, the height of the bottommost cell in each column is reduced\nto fit the provided `bottom_height`, which may be a `Field`, `Array`, or function\nof `(x, y)`.\n\nThe height of partial bottom cells is greater than\n\n```\nminimum_fractional_cell_height * Δz,\n```\n\nwhere `Δz` is the original height of the bottom cell underlying grid.\n" function PartialCellBottom(bottom_height; minimum_fractional_cell_height = 0.2)
        #= none:59 =#
        #= none:60 =#
        return PartialCellBottom(bottom_height, minimum_fractional_cell_height)
    end
#= none:63 =#
function ImmersedBoundaryGrid(grid, ib::PartialCellBottom)
    #= none:63 =#
    #= none:64 =#
    bottom_field = Field{Center, Center, Nothing}(grid)
    #= none:65 =#
    set!(bottom_field, ib.bottom_height)
    #= none:66 =#
    #= none:66 =# @apply_regionally clamp_bottom_height!(bottom_field, grid)
    #= none:67 =#
    fill_halo_regions!(bottom_field)
    #= none:68 =#
    new_ib = PartialCellBottom(bottom_field, ib.minimum_fractional_cell_height)
    #= none:69 =#
    (TX, TY, TZ) = topology(grid)
    #= none:70 =#
    return ImmersedBoundaryGrid{TX, TY, TZ}(grid, new_ib)
end
#= none:73 =#
function on_architecture(arch, ib::PartialCellBottom{<:Field})
    #= none:73 =#
    #= none:74 =#
    architecture(ib.bottom_height) == arch && return ib
    #= none:75 =#
    arch_grid = on_architecture(arch, ib.bottom_height.grid)
    #= none:76 =#
    new_bottom_height = Field{Center, Center, Nothing}(arch_grid)
    #= none:77 =#
    copyto!(parent(new_bottom_height), parent(ib.bottom_height))
    #= none:78 =#
    return PartialCellBottom(new_bottom_height, ib.minimum_fractional_cell_height)
end
#= none:81 =#
Adapt.adapt_structure(to, ib::PartialCellBottom) = begin
        #= none:81 =#
        PartialCellBottom(adapt(to, ib.bottom_height), ib.minimum_fractional_cell_height)
    end
#= none:84 =#
on_architecture(to, ib::PartialCellBottom) = begin
        #= none:84 =#
        PartialCellBottom(on_architecture(to, ib.bottom_height), on_architecture(to, ib.minimum_fractional_cell_height))
    end
#= none:87 =#
#= none:87 =# Core.@doc "    immersed     underlying\n\n      --x--        --x--\n            \n            \n        ∘   ↑        ∘   k+1\n            |\n            |               \n  k+1 --x-- |  k+1 --x--    ↑      <- node z\n        ∘   ↓               |\n   zb ⋅⋅x⋅⋅                 |\n                            |\n                     ∘   k  | Δz\n                            |\n                            |\n                 k --x--    ↓\n      \nCriterion is zb ≥ z - ϵ Δz\n\n" #= none:108 =# @inline(function _immersed_cell(i, j, k, underlying_grid, ib::PartialCellBottom)
            #= none:108 =#
            #= none:110 =#
            z = znode(i, j, k, underlying_grid, c, c, f)
            #= none:111 =#
            zb = #= none:111 =# @inbounds(ib.bottom_height[i, j, 1])
            #= none:112 =#
            ϵ = ib.minimum_fractional_cell_height
            #= none:114 =#
            Δz = Δzᶜᶜᶜ(i, j, k, underlying_grid)
            #= none:115 =#
            return z + Δz * (1 - ϵ) ≤ zb
        end)
#= none:118 =#
#= none:118 =# @inline function bottom_cell(i, j, k, ibg::PCBIBG)
        #= none:118 =#
        #= none:119 =#
        grid = ibg.underlying_grid
        #= none:120 =#
        ib = ibg.immersed_boundary
        #= none:122 =#
        return !(immersed_cell(i, j, k, grid, ib)) & immersed_cell(i, j, k - 1, grid, ib)
    end
#= none:125 =#
#= none:125 =# @inline function Δzᶜᶜᶜ(i, j, k, ibg::PCBIBG)
        #= none:125 =#
        #= none:126 =#
        underlying_grid = ibg.underlying_grid
        #= none:127 =#
        ib = ibg.immersed_boundary
        #= none:130 =#
        z = znode(i, j, k + 1, underlying_grid, c, c, f)
        #= none:133 =#
        h = #= none:133 =# @inbounds(ib.bottom_height[i, j, 1])
        #= none:134 =#
        ϵ = ibg.immersed_boundary.minimum_fractional_cell_height
        #= none:137 =#
        at_the_bottom = bottom_cell(i, j, k, ibg)
        #= none:139 =#
        full_Δz = Δzᶜᶜᶜ(i, j, k, ibg.underlying_grid)
        #= none:140 =#
        partial_Δz = max(ϵ * full_Δz, z - h)
        #= none:142 =#
        return ifelse(at_the_bottom, partial_Δz, full_Δz)
    end
#= none:145 =#
#= none:145 =# @inline function Δzᶜᶜᶠ(i, j, k, ibg::PCBIBG)
        #= none:145 =#
        #= none:146 =#
        just_above_bottom = bottom_cell(i, j, k - 1, ibg)
        #= none:147 =#
        zc = znode(i, j, k, ibg.underlying_grid, c, c, c)
        #= none:148 =#
        zf = znode(i, j, k, ibg.underlying_grid, c, c, f)
        #= none:150 =#
        full_Δz = Δzᶜᶜᶠ(i, j, k, ibg.underlying_grid)
        #= none:151 =#
        partial_Δz = (zc - zf) + Δzᶜᶜᶜ(i, j, k - 1, ibg) / 2
        #= none:153 =#
        Δz = ifelse(just_above_bottom, partial_Δz, full_Δz)
        #= none:155 =#
        return Δz
    end
#= none:158 =#
#= none:158 =# @inline Δzᶠᶜᶜ(i, j, k, ibg::PCBIBG) = begin
            #= none:158 =#
            min(Δzᶜᶜᶜ(i - 1, j, k, ibg), Δzᶜᶜᶜ(i, j, k, ibg))
        end
#= none:159 =#
#= none:159 =# @inline Δzᶜᶠᶜ(i, j, k, ibg::PCBIBG) = begin
            #= none:159 =#
            min(Δzᶜᶜᶜ(i, j - 1, k, ibg), Δzᶜᶜᶜ(i, j, k, ibg))
        end
#= none:160 =#
#= none:160 =# @inline Δzᶠᶠᶜ(i, j, k, ibg::PCBIBG) = begin
            #= none:160 =#
            min(Δzᶠᶜᶜ(i, j - 1, k, ibg), Δzᶠᶜᶜ(i, j, k, ibg))
        end
#= none:162 =#
#= none:162 =# @inline Δzᶠᶜᶠ(i, j, k, ibg::PCBIBG) = begin
            #= none:162 =#
            min(Δzᶜᶜᶠ(i - 1, j, k, ibg), Δzᶜᶜᶠ(i, j, k, ibg))
        end
#= none:163 =#
#= none:163 =# @inline Δzᶜᶠᶠ(i, j, k, ibg::PCBIBG) = begin
            #= none:163 =#
            min(Δzᶜᶜᶠ(i, j - 1, k, ibg), Δzᶜᶜᶠ(i, j, k, ibg))
        end
#= none:164 =#
#= none:164 =# @inline Δzᶠᶠᶠ(i, j, k, ibg::PCBIBG) = begin
            #= none:164 =#
            min(Δzᶠᶜᶠ(i, j - 1, k, ibg), Δzᶠᶜᶠ(i, j, k, ibg))
        end
#= none:168 =#
XFlatPCBIBG = ImmersedBoundaryGrid{<:Any, <:Flat, <:Any, <:Any, <:Any, <:PartialCellBottom}
#= none:169 =#
YFlatPCBIBG = ImmersedBoundaryGrid{<:Any, <:Any, <:Flat, <:Any, <:Any, <:PartialCellBottom}
#= none:171 =#
#= none:171 =# @inline Δzᶠᶜᶜ(i, j, k, ibg::XFlatPCBIBG) = begin
            #= none:171 =#
            Δzᶜᶜᶜ(i, j, k, ibg)
        end
#= none:172 =#
#= none:172 =# @inline Δzᶠᶜᶠ(i, j, k, ibg::XFlatPCBIBG) = begin
            #= none:172 =#
            Δzᶜᶜᶠ(i, j, k, ibg)
        end
#= none:173 =#
#= none:173 =# @inline Δzᶜᶠᶜ(i, j, k, ibg::YFlatPCBIBG) = begin
            #= none:173 =#
            Δzᶜᶜᶜ(i, j, k, ibg)
        end
#= none:175 =#
#= none:175 =# @inline Δzᶜᶠᶠ(i, j, k, ibg::YFlatPCBIBG) = begin
            #= none:175 =#
            Δzᶜᶜᶠ(i, j, k, ibg)
        end
#= none:176 =#
#= none:176 =# @inline Δzᶠᶠᶜ(i, j, k, ibg::XFlatPCBIBG) = begin
            #= none:176 =#
            Δzᶜᶠᶜ(i, j, k, ibg)
        end
#= none:177 =#
#= none:177 =# @inline Δzᶠᶠᶜ(i, j, k, ibg::YFlatPCBIBG) = begin
            #= none:177 =#
            Δzᶠᶜᶜ(i, j, k, ibg)
        end
#= none:179 =#
#= none:179 =# @inline z_bottom(i, j, ibg::PCBIBG) = begin
            #= none:179 =#
            #= none:179 =# @inbounds ibg.immersed_boundary.bottom_height[i, j, 1]
        end