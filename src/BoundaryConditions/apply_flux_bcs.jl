
#= none:1 =#
using Oceananigans: instantiated_location
#= none:2 =#
using Oceananigans.Architectures: AbstractArchitecture
#= none:3 =#
using Oceananigans.Grids
#= none:4 =#
using Oceananigans.Grids: AbstractGrid
#= none:12 =#
apply_x_bcs!(Gc, c, args...) = begin
        #= none:12 =#
        apply_x_bcs!(Gc, Gc.grid, c, c.boundary_conditions.west, c.boundary_conditions.east, args...)
    end
#= none:13 =#
apply_y_bcs!(Gc, c, args...) = begin
        #= none:13 =#
        apply_y_bcs!(Gc, Gc.grid, c, c.boundary_conditions.south, c.boundary_conditions.north, args...)
    end
#= none:14 =#
apply_z_bcs!(Gc, c, args...) = begin
        #= none:14 =#
        apply_z_bcs!(Gc, Gc.grid, c, c.boundary_conditions.bottom, c.boundary_conditions.top, args...)
    end
#= none:19 =#
apply_x_bcs!(::Nothing, args...) = begin
        #= none:19 =#
        nothing
    end
#= none:20 =#
apply_y_bcs!(::Nothing, args...) = begin
        #= none:20 =#
        nothing
    end
#= none:21 =#
apply_z_bcs!(::Nothing, args...) = begin
        #= none:21 =#
        nothing
    end
#= none:24 =#
const NotFluxBC = Union{PBC, MCBC, DCBC, VBC, GBC, OBC, ZFBC, Nothing}
#= none:26 =#
apply_x_bcs!(Gc, ::AbstractGrid, c, ::NotFluxBC, ::NotFluxBC, ::AbstractArchitecture, args...) = begin
        #= none:26 =#
        nothing
    end
#= none:27 =#
apply_y_bcs!(Gc, ::AbstractGrid, c, ::NotFluxBC, ::NotFluxBC, ::AbstractArchitecture, args...) = begin
        #= none:27 =#
        nothing
    end
#= none:28 =#
apply_z_bcs!(Gc, ::AbstractGrid, c, ::NotFluxBC, ::NotFluxBC, ::AbstractArchitecture, args...) = begin
        #= none:28 =#
        nothing
    end
#= none:31 =#
#= none:31 =# Core.@doc "Apply flux boundary conditions to a field `c` by adding the associated flux divergence to\nthe source term `Gc` at the left and right.\n" apply_x_bcs!(Gc, grid::AbstractGrid, c, west_bc, east_bc, arch::AbstractArchitecture, args...) = begin
            #= none:35 =#
            launch!(arch, grid, :yz, _apply_x_bcs!, Gc, instantiated_location(Gc), grid, west_bc, east_bc, Tuple(args))
        end
#= none:38 =#
#= none:38 =# Core.@doc "Apply flux boundary conditions to a field `c` by adding the associated flux divergence to\nthe source term `Gc` at the left and right.\n" apply_y_bcs!(Gc, grid::AbstractGrid, c, south_bc, north_bc, arch::AbstractArchitecture, args...) = begin
            #= none:42 =#
            launch!(arch, grid, :xz, _apply_y_bcs!, Gc, instantiated_location(Gc), grid, south_bc, north_bc, Tuple(args))
        end
#= none:45 =#
#= none:45 =# Core.@doc "Apply flux boundary conditions to a field `c` by adding the associated flux divergence to\nthe source term `Gc` at the top and bottom.\n" apply_z_bcs!(Gc, grid::AbstractGrid, c, bottom_bc, top_bc, arch::AbstractArchitecture, args...) = begin
            #= none:49 =#
            launch!(arch, grid, :xy, _apply_z_bcs!, Gc, instantiated_location(Gc), grid, bottom_bc, top_bc, Tuple(args))
        end
#= none:52 =#
#= none:52 =# Core.@doc "    _apply_x_bcs!(Gc, grid, west_bc, east_bc, args...)\n\nApply a west and/or east boundary condition to variable `c`.\n" #= none:57 =# @kernel(function _apply_x_bcs!(Gc, loc, grid, west_bc, east_bc, args)
            #= none:57 =#
            #= none:58 =#
            (j, k) = #= none:58 =# @index(Global, NTuple)
            #= none:59 =#
            apply_x_west_bc!(Gc, loc, west_bc, j, k, grid, args...)
            #= none:60 =#
            apply_x_east_bc!(Gc, loc, east_bc, j, k, grid, args...)
        end)
#= none:63 =#
#= none:63 =# Core.@doc "    _apply_y_bcs!(Gc, grid, south_bc, north_bc, args...)\n\nApply a south and/or north boundary condition to variable `c`.\n" #= none:68 =# @kernel(function _apply_y_bcs!(Gc, loc, grid, south_bc, north_bc, args)
            #= none:68 =#
            #= none:69 =#
            (i, k) = #= none:69 =# @index(Global, NTuple)
            #= none:70 =#
            apply_y_south_bc!(Gc, loc, south_bc, i, k, grid, args...)
            #= none:71 =#
            apply_y_north_bc!(Gc, loc, north_bc, i, k, grid, args...)
        end)
#= none:74 =#
#= none:74 =# Core.@doc "    _apply_z_bcs!(Gc, grid, bottom_bc, top_bc, args...)\n\nApply a top and/or bottom boundary condition to variable `c`.\n" #= none:79 =# @kernel(function _apply_z_bcs!(Gc, loc, grid, bottom_bc, top_bc, args)
            #= none:79 =#
            #= none:80 =#
            (i, j) = #= none:80 =# @index(Global, NTuple)
            #= none:81 =#
            apply_z_bottom_bc!(Gc, loc, bottom_bc, i, j, grid, args...)
            #= none:82 =#
            apply_z_top_bc!(Gc, loc, top_bc, i, j, grid, args...)
        end)
#= none:86 =#
#= none:86 =# @inline apply_x_east_bc!(Gc, loc, ::NotFluxBC, args...) = begin
            #= none:86 =#
            nothing
        end
#= none:87 =#
#= none:87 =# @inline apply_x_west_bc!(Gc, loc, ::NotFluxBC, args...) = begin
            #= none:87 =#
            nothing
        end
#= none:88 =#
#= none:88 =# @inline apply_y_north_bc!(Gc, loc, ::NotFluxBC, args...) = begin
            #= none:88 =#
            nothing
        end
#= none:89 =#
#= none:89 =# @inline apply_y_south_bc!(Gc, loc, ::NotFluxBC, args...) = begin
            #= none:89 =#
            nothing
        end
#= none:90 =#
#= none:90 =# @inline apply_z_top_bc!(Gc, loc, ::NotFluxBC, args...) = begin
            #= none:90 =#
            nothing
        end
#= none:91 =#
#= none:91 =# @inline apply_z_bottom_bc!(Gc, loc, ::NotFluxBC, args...) = begin
            #= none:91 =#
            nothing
        end
#= none:93 =#
#= none:93 =# @inline flip(::Center) = begin
            #= none:93 =#
            Face()
        end
#= none:94 =#
#= none:94 =# @inline flip(::Face) = begin
            #= none:94 =#
            Center()
        end
#= none:96 =#
#= none:96 =# Core.@doc "    apply_x_west_bc!(Gc, loc, west_flux::BC{<:Flux}, j, k, grid, args...)\n\nAdd the flux divergence associated with a west flux boundary condition on `c`.\nNote that because\n\n    `tendency = ∂c/∂t = Gc = - ∇ ⋅ flux`\n\na positive west flux is associated with an *increase* in `Gc` near the west boundary.\nIf `west_bc.condition` is a function, the function must have the signature\n\n    `west_bc.condition(j, k, grid, boundary_condition_args...)`\n\nThe same logic holds for south and bottom boundary conditions in `y`, and `z`, respectively.\n" #= none:111 =# @inline(function apply_x_west_bc!(Gc, loc, west_flux::BC{<:Flux}, j, k, grid, args...)
            #= none:111 =#
            #= none:112 =#
            (LX, LY, LZ) = loc
            #= none:113 =#
            #= none:113 =# @inbounds Gc[1, j, k] += (getbc(west_flux, j, k, grid, args...) * Ax(1, j, k, grid, flip(LX), LY, LZ)) / volume(1, j, k, grid, LX, LY, LZ)
            #= none:114 =#
            return nothing
        end)
#= none:117 =#
#= none:117 =# @inline function apply_y_south_bc!(Gc, loc, south_flux::BC{<:Flux}, i, k, grid, args...)
        #= none:117 =#
        #= none:118 =#
        (LX, LY, LZ) = loc
        #= none:119 =#
        #= none:119 =# @inbounds Gc[i, 1, k] += (getbc(south_flux, i, k, grid, args...) * Ay(i, 1, k, grid, LX, flip(LY), LZ)) / volume(i, 1, k, grid, LX, LY, LZ)
        #= none:120 =#
        return nothing
    end
#= none:123 =#
#= none:123 =# @inline function apply_z_bottom_bc!(Gc, loc, bottom_flux::BC{<:Flux}, i, j, grid, args...)
        #= none:123 =#
        #= none:124 =#
        (LX, LY, LZ) = loc
        #= none:125 =#
        #= none:125 =# @inbounds Gc[i, j, 1] += (getbc(bottom_flux, i, j, grid, args...) * Az(i, j, 1, grid, LX, LY, flip(LZ))) / volume(i, j, 1, grid, LX, LY, LZ)
        #= none:126 =#
        return nothing
    end
#= none:129 =#
#= none:129 =# Core.@doc "    apply_x_east_bc!(Gc, loc, east_flux::BC{<:Flux}, j, k, grid, args...)\n\nAdd the part of flux divergence associated with a east boundary condition on `c`.\nNote that because\n\n    `tendency = ∂c/∂t = Gc = - ∇ ⋅ flux`\n\na positive east flux is associated with a *decrease* in `Gc` near the east boundary.\nIf `east_bc.condition` is a function, the function must have the signature\n\n    `east_bc.condition(i, j, grid, boundary_condition_args...)`\n\nThe same logic holds for north and top boundary conditions in `y`, and `z`, respectively.\n" #= none:144 =# @inline(function apply_x_east_bc!(Gc, loc, east_flux::BC{<:Flux}, j, k, grid, args...)
            #= none:144 =#
            #= none:145 =#
            (LX, LY, LZ) = loc
            #= none:146 =#
            #= none:146 =# @inbounds Gc[grid.Nx, j, k] -= (getbc(east_flux, j, k, grid, args...) * Ax(grid.Nx + 1, j, k, grid, flip(LX), LY, LZ)) / volume(grid.Nx, j, k, grid, LX, LY, LZ)
            #= none:147 =#
            return nothing
        end)
#= none:150 =#
#= none:150 =# @inline function apply_y_north_bc!(Gc, loc, north_flux::BC{<:Flux}, i, k, grid, args...)
        #= none:150 =#
        #= none:151 =#
        (LX, LY, LZ) = loc
        #= none:152 =#
        #= none:152 =# @inbounds Gc[i, grid.Ny, k] -= (getbc(north_flux, i, k, grid, args...) * Ay(i, grid.Ny + 1, k, grid, LX, flip(LY), LZ)) / volume(i, grid.Ny, k, grid, LX, LY, LZ)
        #= none:153 =#
        return nothing
    end
#= none:156 =#
#= none:156 =# @inline function apply_z_top_bc!(Gc, loc, top_flux::BC{<:Flux}, i, j, grid, args...)
        #= none:156 =#
        #= none:157 =#
        (LX, LY, LZ) = loc
        #= none:158 =#
        #= none:158 =# @inbounds Gc[i, j, grid.Nz] -= (getbc(top_flux, i, j, grid, args...) * Az(i, j, grid.Nz + 1, grid, LX, LY, flip(LZ))) / volume(i, j, grid.Nz, grid, LX, LY, LZ)
        #= none:159 =#
        return nothing
    end