
#= none:1 =#
using Oceananigans.Grids: topology, node, _node, xspacings, yspacings, zspacings, λspacings, φspacings, XFlatGrid, YFlatGrid, ZFlatGrid, XYFlatGrid, YZFlatGrid, XZFlatGrid, XRegularRG, YRegularRG, ZRegularRG, XRegularLLG, YRegularLLG, ZRegularLLG, ZRegOrthogonalSphericalShellGrid, RectilinearGrid, LatitudeLongitudeGrid
#= none:10 =#
using Oceananigans.Architectures: child_architecture
#= none:13 =#
#= none:13 =# @inline middle_point(l, h) = begin
            #= none:13 =#
            Base.unsafe_trunc(Int, (l + h) / 2)
        end
#= none:15 =#
#= none:15 =# Core.@doc "    index_binary_search(val, vec, N)\n\nReturn indices `low, high` of `vec`tor for which\n\n```julia\nvec[low] ≤ val && vec[high] ≥ val\n```\n\nusing a binary search. The input array `vec` has to be monotonically increasing.\n\nCode credit: https://gist.github.com/cuongld2/8e4fed9ba44ea2b4598f90e7d5b6c612/155f9cb595314c8db3a266c3316889443b068017\n" #= none:28 =# @inline(function index_binary_search(vec, val::Number, N)
            #= none:28 =#
            #= none:29 =#
            low = 0
            #= none:30 =#
            high = N - 1
            #= none:32 =#
            while low + 1 < high
                #= none:33 =#
                mid = middle_point(low, high)
                #= none:34 =#
                if #= none:34 =# @inbounds(vec[mid + 1] == val)
                    #= none:35 =#
                    return (mid + 1, mid + 1)
                elseif #= none:36 =# #= none:36 =# @inbounds(vec[mid + 1] < val)
                    #= none:37 =#
                    low = mid
                else
                    #= none:39 =#
                    high = mid
                end
                #= none:41 =#
            end
            #= none:43 =#
            return (low + 1, high + 1)
        end)
#= none:46 =#
#= none:46 =# @inline function fractional_index(val, vec, N)
        #= none:46 =#
        #= none:47 =#
        (i₁, i₂) = index_binary_search(vec, val, N)
        #= none:49 =#
        #= none:49 =# @inbounds x₁ = vec[i₁]
        #= none:50 =#
        #= none:50 =# @inbounds x₂ = vec[i₂]
        #= none:52 =#
        ii = ((i₂ - i₁) / (x₂ - x₁)) * (val - x₁) + i₁
        #= none:53 =#
        ii = ifelse(i₁ == i₂, i₁, ii)
        #= none:55 =#
        FT = typeof(val)
        #= none:56 =#
        return convert(FT, ii)
    end
#= none:65 =#
#= none:65 =# @inline fractional_x_index(x, locs, grid::XFlatGrid) = begin
            #= none:65 =#
            zero(grid)
        end
#= none:67 =#
#= none:67 =# @inline function fractional_x_index(x, locs, grid::XRegularRG)
        #= none:67 =#
        #= none:68 =#
        x₀ = xnode(1, 1, 1, grid, locs...)
        #= none:69 =#
        Δx = xspacings(grid, locs...)
        #= none:70 =#
        FT = eltype(grid)
        #= none:71 =#
        return convert(FT, (x - x₀) / Δx)
    end
#= none:74 =#
#= none:74 =# @inline function fractional_x_index(λ, locs, grid::XRegularLLG)
        #= none:74 =#
        #= none:75 =#
        λ₀ = λnode(1, 1, 1, grid, locs...)
        #= none:76 =#
        Δλ = λspacings(grid, locs...)
        #= none:77 =#
        FT = eltype(grid)
        #= none:78 =#
        return convert(FT, (λ - λ₀) / Δλ)
    end
#= none:81 =#
#= none:81 =# @inline function fractional_x_index(x, locs, grid::RectilinearGrid)
        #= none:81 =#
        #= none:82 =#
        loc = #= none:82 =# @inbounds(locs[1])
        #= none:83 =#
        Tx = (topology(grid, 1))()
        #= none:84 =#
        Nx = length(loc, Tx, grid.Nx)
        #= none:85 =#
        xn = xnodes(grid, locs...)
        #= none:86 =#
        return fractional_index(x, xn, Nx) - 1
    end
#= none:89 =#
#= none:89 =# @inline function fractional_x_index(x, locs, grid::LatitudeLongitudeGrid)
        #= none:89 =#
        #= none:90 =#
        loc = #= none:90 =# @inbounds(locs[1])
        #= none:91 =#
        Tx = (topology(grid, 1))()
        #= none:92 =#
        Nx = length(loc, Tx, grid.Nx)
        #= none:93 =#
        xn = λnodes(grid, locs...)
        #= none:94 =#
        return fractional_index(x, xn, Nx) - 1
    end
#= none:97 =#
#= none:97 =# @inline fractional_y_index(y, locs, grid::YFlatGrid) = begin
            #= none:97 =#
            zero(grid)
        end
#= none:99 =#
#= none:99 =# @inline function fractional_y_index(y, locs, grid::YRegularRG)
        #= none:99 =#
        #= none:100 =#
        y₀ = ynode(1, 1, 1, grid, locs...)
        #= none:101 =#
        Δy = yspacings(grid, locs...)
        #= none:102 =#
        FT = eltype(grid)
        #= none:103 =#
        return convert(FT, (y - y₀) / Δy)
    end
#= none:106 =#
#= none:106 =# @inline function fractional_y_index(φ, locs, grid::YRegularLLG)
        #= none:106 =#
        #= none:107 =#
        φ₀ = φnode(1, 1, 1, grid, locs...)
        #= none:108 =#
        Δφ = φspacings(grid, locs...)
        #= none:109 =#
        FT = eltype(grid)
        #= none:110 =#
        return convert(FT, (φ - φ₀) / Δφ)
    end
#= none:113 =#
#= none:113 =# @inline function fractional_y_index(y, locs, grid::RectilinearGrid)
        #= none:113 =#
        #= none:114 =#
        loc = #= none:114 =# @inbounds(locs[2])
        #= none:115 =#
        Ty = (topology(grid, 2))()
        #= none:116 =#
        Ny = length(loc, Ty, grid.Ny)
        #= none:117 =#
        yn = ynodes(grid, locs...)
        #= none:118 =#
        return fractional_index(y, yn, Ny) - 1
    end
#= none:121 =#
#= none:121 =# @inline function fractional_y_index(y, locs, grid::LatitudeLongitudeGrid)
        #= none:121 =#
        #= none:122 =#
        loc = #= none:122 =# @inbounds(locs[2])
        #= none:123 =#
        Ty = (topology(grid, 2))()
        #= none:124 =#
        Ny = length(loc, Ty, grid.Ny)
        #= none:125 =#
        yn = φnodes(grid, locs...)
        #= none:126 =#
        return fractional_index(y, yn, Ny) - 1
    end
#= none:129 =#
#= none:129 =# @inline fractional_z_index(z, locs, grid::ZFlatGrid) = begin
            #= none:129 =#
            zero(grid)
        end
#= none:131 =#
ZRegGrid = Union{ZRegularRG, ZRegularLLG, ZRegOrthogonalSphericalShellGrid}
#= none:133 =#
#= none:133 =# @inline function fractional_z_index(z::FT, locs, grid::ZRegGrid) where FT
        #= none:133 =#
        #= none:134 =#
        z₀ = znode(1, 1, 1, grid, locs...)
        #= none:135 =#
        Δz = zspacings(grid, locs...)
        #= none:136 =#
        return convert(FT, (z - z₀) / Δz)
    end
#= none:139 =#
#= none:139 =# @inline function fractional_z_index(z, locs, grid)
        #= none:139 =#
        #= none:140 =#
        loc = #= none:140 =# @inbounds(locs[3])
        #= none:141 =#
        Tz = (topology(grid, 3))()
        #= none:142 =#
        Nz = length(loc, Tz, grid.Nz)
        #= none:143 =#
        zn = znodes(grid, loc)
        #= none:144 =#
        return fractional_index(z, zn, Nz) - 1
    end
#= none:147 =#
#= none:147 =# Core.@doc "    fractional_indices(x, y, z, grid, loc...)\n\nConvert the coordinates `(x, y, z)` to _fractional_ indices on a regular rectilinear grid\nlocated at `loc`, where `loc` is a 3-tuple of `Center` and `Face`. Fractional indices are\nfloats indicating a location between grid points.\n" #= none:154 =# @inline(fractional_indices(at_node, grid, ℓx, ℓy, ℓz) = begin
                #= none:154 =#
                _fractional_indices(at_node, grid, ℓx, ℓy, ℓz)
            end)
#= none:156 =#
#= none:156 =# @inline fractional_indices(at_node, grid::XFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:156 =#
            _fractional_indices(at_node, grid, nothing, ℓy, ℓz)
        end
#= none:157 =#
#= none:157 =# @inline fractional_indices(at_node, grid::YFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:157 =#
            _fractional_indices(at_node, grid, ℓx, nothing, ℓz)
        end
#= none:158 =#
#= none:158 =# @inline fractional_indices(at_node, grid::ZFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:158 =#
            _fractional_indices(at_node, grid, ℓx, ℓy, nothing)
        end
#= none:160 =#
#= none:160 =# @inline fractional_indices(at_node, grid::XYFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:160 =#
            _fractional_indices(at_node, grid, nothing, nothing, ℓz)
        end
#= none:161 =#
#= none:161 =# @inline fractional_indices(at_node, grid::YZFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:161 =#
            _fractional_indices(at_node, grid, ℓx, nothing, nothing)
        end
#= none:162 =#
#= none:162 =# @inline fractional_indices(at_node, grid::XZFlatGrid, ℓx, ℓy, ℓz) = begin
            #= none:162 =#
            _fractional_indices(at_node, grid, nothing, ℓy, nothing)
        end
#= none:164 =#
#= none:164 =# @inline function _fractional_indices((x, y, z), grid, ℓx, ℓy, ℓz)
        #= none:164 =#
        #= none:165 =#
        ii = fractional_x_index(x, (ℓx, ℓy, ℓz), grid)
        #= none:166 =#
        jj = fractional_y_index(y, (ℓx, ℓy, ℓz), grid)
        #= none:167 =#
        kk = fractional_z_index(z, (ℓx, ℓy, ℓz), grid)
        #= none:168 =#
        return (ii, jj, kk)
    end
#= none:171 =#
#= none:171 =# @inline function _fractional_indices((y, z), grid, ::Nothing, ℓy, ℓz)
        #= none:171 =#
        #= none:172 =#
        jj = fractional_y_index(y, (nothing, ℓy, ℓz), grid)
        #= none:173 =#
        kk = fractional_z_index(z, (nothing, ℓy, ℓz), grid)
        #= none:174 =#
        return (nothing, jj, kk)
    end
#= none:177 =#
#= none:177 =# @inline function _fractional_indices((x, z), grid, ℓx, ::Nothing, ℓz)
        #= none:177 =#
        #= none:178 =#
        ii = fractional_x_index(x, (ℓx, nothing, ℓz), grid)
        #= none:179 =#
        kk = fractional_z_index(z, (ℓx, nothing, ℓz), grid)
        #= none:180 =#
        return (ii, nothing, kk)
    end
#= none:183 =#
#= none:183 =# @inline function _fractional_indices((x, y), grid, ℓx, ℓy, ::Nothing)
        #= none:183 =#
        #= none:184 =#
        ii = fractional_x_index(x, (ℓx, ℓy, nothing), grid)
        #= none:185 =#
        jj = fractional_y_index(y, (ℓx, ℓy, nothing), grid)
        #= none:186 =#
        return (ii, jj, nothing)
    end
#= none:189 =#
#= none:189 =# @inline function _fractional_indices((x,), grid, ℓx, ::Nothing, ::Nothing)
        #= none:189 =#
        #= none:190 =#
        loc = (ℓx, nothing, nothing)
        #= none:191 =#
        ii = fractional_x_index(x, loc, grid)
        #= none:192 =#
        jj = nothing
        #= none:193 =#
        kk = nothing
        #= none:194 =#
        return (ii, jj, kk)
    end
#= none:197 =#
#= none:197 =# @inline function _fractional_indices((y,), grid, ::Nothing, ℓy, ::Nothing)
        #= none:197 =#
        #= none:198 =#
        loc = (nothing, ℓy, nothing)
        #= none:199 =#
        ii = nothing
        #= none:200 =#
        jj = fractional_y_index(y, loc, grid)
        #= none:201 =#
        kk = nothing
        #= none:202 =#
        return (ii, jj, kk)
    end
#= none:205 =#
#= none:205 =# @inline function _fractional_indices((z,), grid, ::Nothing, ::Nothing, ℓz)
        #= none:205 =#
        #= none:206 =#
        loc = (nothing, nothing, ℓz)
        #= none:207 =#
        ii = nothing
        #= none:208 =#
        jj = nothing
        #= none:209 =#
        kk = fractional_z_index(z, loc, grid)
        #= none:210 =#
        return (ii, jj, kk)
    end
#= none:213 =#
#= none:213 =# Core.@doc "    truncate_fractional_indices(fi, fj, fk)\n\nTruncate _fractional_ indices output from fractional indices `fi, fj, fk` to integer indices, dealing\nwith `nothing` indices for `Flat` domains.\n" #= none:219 =# @inline(function truncate_fractional_indices(fi, fj, fk)
            #= none:219 =#
            #= none:220 =#
            i = truncate_fractional_index(fi)
            #= none:221 =#
            j = truncate_fractional_index(fj)
            #= none:222 =#
            k = truncate_fractional_index(fk)
            #= none:223 =#
            return (i, j, k)
        end)
#= none:226 =#
#= none:226 =# @inline truncate_fractional_index(::Nothing) = begin
            #= none:226 =#
            1
        end
#= none:227 =#
#= none:227 =# @inline truncate_fractional_index(fi) = begin
            #= none:227 =#
            Base.unsafe_trunc(Int, fi)
        end
#= none:230 =#
#= none:230 =# Core.@doc "    interpolate(at_node, from_field, from_loc, from_grid)\n\nInterpolate `from_field`, `at_node`, on `from_grid` and at `from_loc`ation,\nwhere `at_node` is a tuple of coordinates and and `from_loc = (ℓx, ℓy, ℓz)`.\n\nNote that this is a lower-level `interpolate` method defined for use in CPU/GPU kernels.\n" #= none:238 =# @inline(function interpolate(at_node, from_field, from_loc, from_grid)
            #= none:238 =#
            #= none:239 =#
            (ii, jj, kk) = fractional_indices(at_node, from_grid, from_loc...)
            #= none:241 =#
            ix = interpolator(ii)
            #= none:242 =#
            iy = interpolator(jj)
            #= none:243 =#
            iz = interpolator(kk)
            #= none:245 =#
            return _interpolate(from_field, ix, iy, iz)
        end)
#= none:248 =#
#= none:248 =# Core.@doc "    interpolator(fractional_idx)\n\nReturn an ``interpolator tuple'' from the fractional index `fractional_idx`\ndefined as the 3-tuple\n\n```\n(i⁻, i⁺, ξ)\n```\n\nwhere `i⁻` is the index to the left of `i`, `i⁺` is the index to the\nright of `i`, and `ξ` is the fractional distance between `i` and the\nleft bound `i⁻`, such that `ξ ∈ [0, 1)`.\n" #= none:262 =# @inline(function interpolator(fractional_idx)
            #= none:262 =#
            #= none:268 =#
            i⁻ = Base.unsafe_trunc(Int, fractional_idx)
            #= none:269 =#
            i⁻ = Int(i⁻ + 1)
            #= none:270 =#
            shift = Int(sign(fractional_idx))
            #= none:271 =#
            i⁺ = i⁻ + shift
            #= none:272 =#
            ξ = mod(fractional_idx, 1)
            #= none:274 =#
            return (i⁻, i⁺, ξ)
        end)
#= none:277 =#
#= none:277 =# @inline interpolator(::Nothing) = begin
            #= none:277 =#
            (1, 1, 0)
        end
#= none:280 =#
#= none:280 =# @inline ϕ₁(ξ, η, ζ) = begin
            #= none:280 =#
            (1 - ξ) * (1 - η) * (1 - ζ)
        end
#= none:281 =#
#= none:281 =# @inline ϕ₂(ξ, η, ζ) = begin
            #= none:281 =#
            (1 - ξ) * (1 - η) * ζ
        end
#= none:282 =#
#= none:282 =# @inline ϕ₃(ξ, η, ζ) = begin
            #= none:282 =#
            (1 - ξ) * η * (1 - ζ)
        end
#= none:283 =#
#= none:283 =# @inline ϕ₄(ξ, η, ζ) = begin
            #= none:283 =#
            (1 - ξ) * η * ζ
        end
#= none:284 =#
#= none:284 =# @inline ϕ₅(ξ, η, ζ) = begin
            #= none:284 =#
            ξ * (1 - η) * (1 - ζ)
        end
#= none:285 =#
#= none:285 =# @inline ϕ₆(ξ, η, ζ) = begin
            #= none:285 =#
            ξ * (1 - η) * ζ
        end
#= none:286 =#
#= none:286 =# @inline ϕ₇(ξ, η, ζ) = begin
            #= none:286 =#
            ξ * η * (1 - ζ)
        end
#= none:287 =#
#= none:287 =# @inline ϕ₈(ξ, η, ζ) = begin
            #= none:287 =#
            ξ * η * ζ
        end
#= none:289 =#
#= none:289 =# @inline function _interpolate(data, ix, iy, iz, in...)
        #= none:289 =#
        #= none:291 =#
        (i⁻, i⁺, ξ) = ix
        #= none:292 =#
        (j⁻, j⁺, η) = iy
        #= none:293 =#
        (k⁻, k⁺, ζ) = iz
        #= none:295 =#
        return #= none:295 =# @inbounds(ϕ₁(ξ, η, ζ) * getindex(data, i⁻, j⁻, k⁻, in...) + ϕ₂(ξ, η, ζ) * getindex(data, i⁻, j⁻, k⁺, in...) + ϕ₃(ξ, η, ζ) * getindex(data, i⁻, j⁺, k⁻, in...) + ϕ₄(ξ, η, ζ) * getindex(data, i⁻, j⁺, k⁺, in...) + ϕ₅(ξ, η, ζ) * getindex(data, i⁺, j⁻, k⁻, in...) + ϕ₆(ξ, η, ζ) * getindex(data, i⁺, j⁻, k⁺, in...) + ϕ₇(ξ, η, ζ) * getindex(data, i⁺, j⁺, k⁻, in...) + ϕ₈(ξ, η, ζ) * getindex(data, i⁺, j⁺, k⁺, in...))
    end
#= none:305 =#
#= none:305 =# Core.@doc "    interpolate(to_node, from_field)\n\nInterpolate `field` to the physical point `(x, y, z)` using trilinear interpolation.\n" #= none:310 =# @inline(function interpolate(to_node, from_field)
            #= none:310 =#
            #= none:311 =#
            from_loc = Tuple((L() for L = location(from_field)))
            #= none:312 =#
            return interpolate(to_node, from_field, from_loc, from_field.grid)
        end)
#= none:315 =#
#= none:315 =# @inline flatten_node(x, y, z) = begin
            #= none:315 =#
            (x, y, z)
        end
#= none:317 =#
#= none:317 =# @inline flatten_node(::Nothing, y, z) = begin
            #= none:317 =#
            flatten_node(y, z)
        end
#= none:318 =#
#= none:318 =# @inline flatten_node(x, ::Nothing, z) = begin
            #= none:318 =#
            flatten_node(x, z)
        end
#= none:319 =#
#= none:319 =# @inline flatten_node(x, y, ::Nothing) = begin
            #= none:319 =#
            flatten_node(x, y)
        end
#= none:321 =#
#= none:321 =# @inline flatten_node(x, y) = begin
            #= none:321 =#
            (x, y)
        end
#= none:322 =#
#= none:322 =# @inline flatten_node(::Nothing, y) = begin
            #= none:322 =#
            flatten_node(y)
        end
#= none:323 =#
#= none:323 =# @inline flatten_node(x, ::Nothing) = begin
            #= none:323 =#
            flatten_node(x)
        end
#= none:325 =#
#= none:325 =# @inline flatten_node(x) = begin
            #= none:325 =#
            tuple(x)
        end
#= none:326 =#
#= none:326 =# @inline flatten_node(::Nothing) = begin
            #= none:326 =#
            tuple()
        end
#= none:328 =#
#= none:328 =# @kernel function _interpolate!(to_field, to_grid, to_location, from_field, from_grid, from_location)
        #= none:328 =#
        #= none:331 =#
        (i, j, k) = #= none:331 =# @index(Global, NTuple)
        #= none:333 =#
        to_node = _node(i, j, k, to_grid, to_location...)
        #= none:334 =#
        to_node = flatten_node(to_node...)
        #= none:336 =#
        #= none:336 =# @inbounds to_field[i, j, k] = interpolate(to_node, from_field, from_location, from_grid)
    end
#= none:339 =#
#= none:339 =# Core.@doc "    interpolate!(to_field::Field, from_field::AbstractField)\n\nInterpolate `from_field` `to_field` and then fill the halo regions of `to_field`.\n" function interpolate!(to_field::Field, from_field::AbstractField)
        #= none:344 =#
        #= none:345 =#
        to_grid = to_field.grid
        #= none:346 =#
        from_grid = from_field.grid
        #= none:348 =#
        to_arch = architecture(to_field)
        #= none:349 =#
        from_arch = architecture(from_field)
        #= none:353 =#
        to_arch = child_architecture(to_arch)
        #= none:354 =#
        from_arch = child_architecture(from_arch)
        #= none:356 =#
        if !(isnothing(from_arch)) && to_arch != from_arch
            #= none:357 =#
            msg = "Cannot interpolate! because from_field is on $(from_arch) while to_field is on $(to_arch)."
            #= none:358 =#
            throw(ArgumentError(msg))
        end
        #= none:362 =#
        from_location = Tuple((L() for L = location(from_field)))
        #= none:363 =#
        to_location = Tuple((L() for L = location(to_field)))
        #= none:365 =#
        launch!(to_arch, to_grid, size(to_field), _interpolate!, to_field, to_grid, to_location, from_field, from_grid, from_location)
        #= none:369 =#
        fill_halo_regions!(to_field)
        #= none:371 =#
        return to_field
    end