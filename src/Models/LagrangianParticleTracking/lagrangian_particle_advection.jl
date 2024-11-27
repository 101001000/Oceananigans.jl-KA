
#= none:1 =#
using Oceananigans.Utils: instantiate
#= none:2 =#
using Oceananigans.Models: total_velocities
#= none:9 =#
#= none:9 =# @inline bounce_left(x, xᴿ, Cʳ) = begin
            #= none:9 =#
            xᴿ - Cʳ * (x - xᴿ)
        end
#= none:10 =#
#= none:10 =# @inline bounce_right(x, xᴸ, Cʳ) = begin
            #= none:10 =#
            xᴸ + Cʳ * (xᴸ - x)
        end
#= none:12 =#
#= none:12 =# Core.@doc "    enforce_boundary_conditions(::Bounded, x, xᴸ, xᴿ, Cʳ)\n\nReturn a new particle position if the particle position `x`\nis outside the Bounded interval `(xᴸ, xᴿ)` by bouncing the particle off\nthe interval edge with coefficient of restitution `Cʳ).\n" #= none:19 =# @inline(enforce_boundary_conditions(::Bounded, x, xᴸ, xᴿ, Cʳ) = begin
                #= none:19 =#
                ifelse(x > xᴿ, bounce_left(x, xᴿ, Cʳ), ifelse(x < xᴸ, bounce_right(x, xᴸ, Cʳ), x))
            end)
#= none:22 =#
#= none:22 =# Core.@doc "    enforce_boundary_conditions(::Periodic, x, xᴸ, xᴿ, Cʳ)\n\nReturn a new particle position if the particle position `x`\nis outside the Periodic interval `(xᴸ, xᴿ)`.\n" #= none:28 =# @inline(enforce_boundary_conditions(::Periodic, x, xᴸ, xᴿ, Cʳ) = begin
                #= none:28 =#
                ifelse(x > xᴿ, xᴸ + (x - xᴿ), ifelse(x < xᴸ, xᴿ - (xᴸ - x), x))
            end)
#= none:31 =#
#= none:31 =# Core.@doc "    enforce_boundary_conditions(::Flat, x, xᴸ, xᴿ, Cʳ)\n\nDo nothing on Flat dimensions.\n" #= none:36 =# @inline(enforce_boundary_conditions(::Flat, x, xᴸ, xᴿ, Cʳ) = begin
                #= none:36 =#
                x
            end)
#= none:38 =#
const f = Face()
#= none:39 =#
const c = Center()
#= none:41 =#
#= none:41 =# Core.@doc "    immersed_boundary_topology(grid_topology)\n\nUnless `Flat`, immersed boundaries are treated as `Bounded` regardless of underlying grid topology.\n" immersed_boundary_topology(grid_topology) = begin
            #= none:46 =#
            ifelse(grid_topology == Flat, Flat(), Bounded())
        end
#= none:48 =#
#= none:48 =# Core.@doc "    bounce_immersed_particle((x, y, z), grid, restitution, previous_particle_indices)\n\nReturn a new particle position if the position `(x, y, z)` lies in an immersed cell by\nbouncing the particle off the immersed boundary with a coefficient or `restitution`.\n" #= none:54 =# @inline(function bounce_immersed_particle((x, y, z), ibg, restitution, previous_particle_indices)
            #= none:54 =#
            #= none:55 =#
            X = flattened_node((x, y, z), ibg)
            #= none:58 =#
            (fi, fj, fk) = fractional_indices(X, ibg.underlying_grid, c, c, c)
            #= none:59 =#
            (i, j, k) = truncate_fractional_indices(fi, fj, fk)
            #= none:62 =#
            (i⁻, j⁻, k⁻) = previous_particle_indices
            #= none:65 =#
            xᴿ = ξnode(i⁻ + 1, j⁻ + 1, k⁻ + 1, ibg, f, f, f)
            #= none:66 =#
            yᴿ = ηnode(i⁻ + 1, j⁻ + 1, k⁻ + 1, ibg, f, f, f)
            #= none:67 =#
            zᴿ = rnode(i⁻ + 1, j⁻ + 1, k⁻ + 1, ibg, f, f, f)
            #= none:70 =#
            xᴸ = ξnode(i⁻, j⁻, k⁻, ibg, f, f, f)
            #= none:71 =#
            yᴸ = ηnode(i⁻, j⁻, k⁻, ibg, f, f, f)
            #= none:72 =#
            zᴸ = rnode(i⁻, j⁻, k⁻, ibg, f, f, f)
            #= none:74 =#
            Cʳ = restitution
            #= none:75 =#
            (tx, ty, tz) = map(immersed_boundary_topology, topology(ibg))
            #= none:76 =#
            xb⁺ = enforce_boundary_conditions(tx, x, xᴸ, xᴿ, Cʳ)
            #= none:77 =#
            yb⁺ = enforce_boundary_conditions(ty, y, yᴸ, yᴿ, Cʳ)
            #= none:78 =#
            zb⁺ = enforce_boundary_conditions(tz, z, zᴸ, zᴿ, Cʳ)
            #= none:80 =#
            immersed = immersed_cell(i, j, k, ibg)
            #= none:81 =#
            x⁺ = ifelse(immersed, xb⁺, x)
            #= none:82 =#
            y⁺ = ifelse(immersed, yb⁺, y)
            #= none:83 =#
            z⁺ = ifelse(immersed, zb⁺, z)
            #= none:85 =#
            return (x⁺, y⁺, z⁺)
        end)
#= none:88 =#
#= none:88 =# Core.@doc "    rightmost_interface_index(topology, N)\n\nReturn the index of the rightmost cell interface for a grid with `topology` and `N` cells.\n" rightmost_interface_index(::Bounded, N) = begin
            #= none:93 =#
            N + 1
        end
#= none:94 =#
rightmost_interface_index(::Periodic, N) = begin
        #= none:94 =#
        N + 1
    end
#= none:95 =#
rightmost_interface_index(::Flat, N) = begin
        #= none:95 =#
        N
    end
#= none:97 =#
#= none:97 =# Core.@doc "    advect_particle((x, y, z), p, restitution, grid, Δt, velocities)\n\nReturn new position `(x⁺, y⁺, z⁺)` for a particle at current position (x, y, z),\ngiven `velocities`, time-step `Δt, and coefficient of `restitution`.\n" #= none:103 =# @inline(function advect_particle((x, y, z), p, restitution, grid, Δt, velocities)
            #= none:103 =#
            #= none:104 =#
            X = flattened_node((x, y, z), grid)
            #= none:107 =#
            (fi, fj, fk) = fractional_indices(X, grid, c, c, c)
            #= none:108 =#
            (i, j, k) = truncate_fractional_indices(fi, fj, fk)
            #= none:110 =#
            current_particle_indices = (i, j, k)
            #= none:113 =#
            u = interpolate(X, velocities.u, (f, c, c), grid)
            #= none:114 =#
            v = interpolate(X, velocities.v, (c, f, c), grid)
            #= none:115 =#
            w = interpolate(X, velocities.w, (c, c, f), grid)
            #= none:120 =#
            ξ = x_metric(i, j, grid)
            #= none:121 =#
            η = y_metric(i, j, grid)
            #= none:123 =#
            x⁺ = x + ξ * u * Δt
            #= none:124 =#
            y⁺ = y + η * v * Δt
            #= none:125 =#
            z⁺ = z + w * Δt
            #= none:128 =#
            (tx, ty, tz) = map(instantiate, topology(grid))
            #= none:129 =#
            (Nx, Ny, Nz) = size(grid)
            #= none:132 =#
            iᴿ = rightmost_interface_index(tx, Nx)
            #= none:133 =#
            jᴿ = rightmost_interface_index(ty, Ny)
            #= none:134 =#
            kᴿ = rightmost_interface_index(tz, Nz)
            #= none:136 =#
            xᴸ = ξnode(1, j, k, grid, f, f, f)
            #= none:137 =#
            yᴸ = ηnode(i, 1, k, grid, f, f, f)
            #= none:138 =#
            zᴸ = rnode(i, j, 1, grid, f, f, f)
            #= none:140 =#
            xᴿ = ξnode(iᴿ, j, k, grid, f, f, f)
            #= none:141 =#
            yᴿ = ηnode(i, jᴿ, k, grid, f, f, f)
            #= none:142 =#
            zᴿ = rnode(i, j, kᴿ, grid, f, f, f)
            #= none:145 =#
            Cʳ = restitution
            #= none:146 =#
            x⁺ = enforce_boundary_conditions(tx, x⁺, xᴸ, xᴿ, Cʳ)
            #= none:147 =#
            y⁺ = enforce_boundary_conditions(ty, y⁺, yᴸ, yᴿ, Cʳ)
            #= none:148 =#
            z⁺ = enforce_boundary_conditions(tz, z⁺, zᴸ, zᴿ, Cʳ)
            #= none:149 =#
            if grid isa ImmersedBoundaryGrid
                #= none:150 =#
                previous_particle_indices = current_particle_indices
                #= none:151 =#
                (x⁺, y⁺, z⁺) = bounce_immersed_particle((x⁺, y⁺, z⁺), grid, Cʳ, previous_particle_indices)
            end
            #= none:154 =#
            return (x⁺, y⁺, z⁺)
        end)
#= none:160 =#
#= none:160 =# @inline x_metric(i, j, grid::RectilinearGrid) = begin
            #= none:160 =#
            1
        end
#= none:161 =#
#= none:161 =# @inline (x_metric(i, j, grid::LatitudeLongitudeGrid{FT}) where FT) = begin
            #= none:161 =#
            #= none:161 =# @inbounds (1 / (grid.radius * hack_cosd(grid.φᵃᶜᵃ[j]))) * FT(360 / (2π))
        end
#= none:162 =#
#= none:162 =# @inline x_metric(i, j, grid::ImmersedBoundaryGrid) = begin
            #= none:162 =#
            x_metric(i, j, grid.underlying_grid)
        end
#= none:164 =#
#= none:164 =# @inline y_metric(i, j, grid::RectilinearGrid) = begin
            #= none:164 =#
            1
        end
#= none:165 =#
#= none:165 =# @inline (y_metric(i, j, grid::LatitudeLongitudeGrid{FT}) where FT) = begin
            #= none:165 =#
            (1 / grid.radius) * FT(360 / (2π))
        end
#= none:166 =#
#= none:166 =# @inline y_metric(i, j, grid::ImmersedBoundaryGrid) = begin
            #= none:166 =#
            y_metric(i, j, grid.underlying_grid)
        end
#= none:168 =#
#= none:168 =# @kernel function _advect_particles!(particles, restitution, grid::AbstractGrid, Δt, velocities)
        #= none:168 =#
        #= none:169 =#
        p = #= none:169 =# @index(Global)
        #= none:171 =#
        #= none:171 =# @inbounds begin
                #= none:172 =#
                x = particles.x[p]
                #= none:173 =#
                y = particles.y[p]
                #= none:174 =#
                z = particles.z[p]
            end
        #= none:177 =#
        (x⁺, y⁺, z⁺) = advect_particle((x, y, z), p, restitution, grid, Δt, velocities)
        #= none:179 =#
        #= none:179 =# @inbounds begin
                #= none:180 =#
                particles.x[p] = x⁺
                #= none:181 =#
                particles.y[p] = y⁺
                #= none:182 =#
                particles.z[p] = z⁺
            end
    end
#= none:186 =#
function advect_lagrangian_particles!(particles, model, Δt)
    #= none:186 =#
    #= none:187 =#
    grid = model.grid
    #= none:188 =#
    arch = architecture(grid)
    #= none:189 =#
    workgroup = min(length(particles), 256)
    #= none:190 =#
    worksize = length(particles)
    #= none:192 =#
    advect_particles_kernel! = _advect_particles!(device(arch), workgroup, worksize)
    #= none:193 =#
    advect_particles_kernel!(particles.properties, particles.restitution, model.grid, Δt, total_velocities(model))
    #= none:195 =#
    return nothing
end