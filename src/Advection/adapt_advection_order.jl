
#= none:1 =#
using Oceananigans.Grids: topology
#= none:3 =#
#= none:3 =# Core.@doc "    adapt_advection_order(advection, grid::AbstractGrid)\n\nAdapts the advection operator `advection` based on the grid `grid` by adjusting the order of advection in each direction.\nFor example, if the grid has only one point in the x-direction, the advection operator in the x-direction is set to first order\nupwind or 2nd order centered scheme, depending on the original user-specified advection scheme. A high order advection sheme \nis reduced to a lower order advection scheme if the grid has fewer points in that direction.\n\n# Arguments\n- `advection`: The original advection scheme.\n- `grid::AbstractGrid`: The grid on which the advection scheme is applied.\n\nIf the order of advection is changed in at least one direction, the adapted advection scheme with adjusted advection order returned \nby this function is a `FluxFormAdvection`.\n" function adapt_advection_order(advection, grid::AbstractGrid)
        #= none:18 =#
        #= none:19 =#
        advection_x = x_advection(advection)
        #= none:20 =#
        advection_y = y_advection(advection)
        #= none:21 =#
        advection_z = z_advection(advection)
        #= none:23 =#
        new_advection_x = adapt_advection_order(advection_x, size(grid, 1), grid)
        #= none:24 =#
        new_advection_y = adapt_advection_order(advection_y, size(grid, 2), grid)
        #= none:25 =#
        new_advection_z = adapt_advection_order(advection_z, size(grid, 3), grid)
        #= none:28 =#
        changed_x = new_advection_x != advection_x
        #= none:29 =#
        changed_y = new_advection_y != advection_y
        #= none:30 =#
        changed_z = new_advection_z != advection_z
        #= none:32 =#
        new_advection = FluxFormAdvection(new_advection_x, new_advection_y, new_advection_z)
        #= none:33 =#
        changed_advection = any((changed_x, changed_y, changed_z))
        #= none:35 =#
        if changed_x
            #= none:36 =#
            #= none:36 =# @info "Using the advection scheme $(summary(new_advection.x)) in the x-direction because size(grid, 1) = $(size(grid, 1))"
        end
        #= none:38 =#
        if changed_y
            #= none:39 =#
            #= none:39 =# @info "Using the advection scheme $(summary(new_advection.y)) in the y-direction because size(grid, 2) = $(size(grid, 2))"
        end
        #= none:41 =#
        if changed_z
            #= none:42 =#
            #= none:42 =# @info "Using the advection scheme $(summary(new_advection.z)) in the x-direction because size(grid, 3) = $(size(grid, 3))"
        end
        #= none:45 =#
        return ifelse(changed_advection, new_advection, advection)
    end
#= none:49 =#
x_advection(flux_form::FluxFormAdvection) = begin
        #= none:49 =#
        flux_form.x
    end
#= none:50 =#
y_advection(flux_form::FluxFormAdvection) = begin
        #= none:50 =#
        flux_form.y
    end
#= none:51 =#
z_advection(flux_form::FluxFormAdvection) = begin
        #= none:51 =#
        flux_form.z
    end
#= none:53 =#
x_advection(advection) = begin
        #= none:53 =#
        advection
    end
#= none:54 =#
y_advection(advection) = begin
        #= none:54 =#
        advection
    end
#= none:55 =#
z_advection(advection) = begin
        #= none:55 =#
        advection
    end
#= none:58 =#
adapt_advection_order(advection::VectorInvariant, grid::AbstractGrid) = begin
        #= none:58 =#
        advection
    end
#= none:59 =#
adapt_advection_order(advection::Nothing, grid::AbstractGrid) = begin
        #= none:59 =#
        nothing
    end
#= none:60 =#
adapt_advection_order(advection::Nothing, N::Int, grid::AbstractGrid) = begin
        #= none:60 =#
        nothing
    end
#= none:66 =#
function adapt_advection_order(advection::Centered{B}, N::Int, grid::AbstractGrid) where B
    #= none:66 =#
    #= none:67 =#
    if N >= B
        #= none:68 =#
        return advection
    else
        #= none:70 =#
        return Centered(; order = 2N)
    end
end
#= none:74 =#
function adapt_advection_order(advection::UpwindBiased{B}, N::Int, grid::AbstractGrid) where B
    #= none:74 =#
    #= none:75 =#
    if N >= B
        #= none:76 =#
        return advection
    else
        #= none:78 =#
        return UpwindBiased(; order = 2N - 1)
    end
end
#= none:82 =#
#= none:82 =# Core.@doc "    new_weno_scheme(grid, order, bounds, XT, YT, ZT)\n\nConstructs a new WENO scheme based on the given parameters. `XT`, `YT`, and `ZT` is the type of the precomputed weno coefficients in the \nx-direction, y-direction and z-direction. A _non-stretched_ WENO scheme has `T` equal to `Nothing` everywhere. In case of a non-stretched WENO scheme, \nwe rebuild the advection without passing the grid information, otherwise we use the grid to account for stretched directions.\n" new_weno_scheme(::WENO, grid, order, bounds, ::Type{Nothing}, ::Type{Nothing}, ::Type{Nothing}) = begin
            #= none:89 =#
            WENO(; order, bounds)
        end
#= none:90 =#
new_weno_scheme(::WENO, grid, order, bounds, XT, YT, ZT) = begin
        #= none:90 =#
        WENO(grid; order, bounds)
    end
#= none:92 =#
function adapt_advection_order(advection::WENO{B, FT, XT, YT, ZT}, N::Int, grid::AbstractGrid) where {B, FT, XT, YT, ZT}
    #= none:92 =#
    #= none:93 =#
    if N >= B
        #= none:94 =#
        return advection
    else
        #= none:96 =#
        return new_weno_scheme(advection, grid, 2N - 1, advection.bounds, XT, YT, ZT)
    end
end