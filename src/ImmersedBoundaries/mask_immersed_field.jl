
#= none:1 =#
using KernelAbstractions: @kernel, @index
#= none:2 =#
using Statistics
#= none:3 =#
using Oceananigans.AbstractOperations: BinaryOperation
#= none:4 =#
using Oceananigans.Fields: location, ZReducedField, Field
#= none:6 =#
instantiate(T::Type) = begin
        #= none:6 =#
        T()
    end
#= none:7 =#
instantiate(t) = begin
        #= none:7 =#
        t
    end
#= none:9 =#
mask_immersed_field!(field, grid, loc, value) = begin
        #= none:9 =#
        nothing
    end
#= none:10 =#
mask_immersed_field!(field::Field, value = zero(eltype(field.grid))) = begin
        #= none:10 =#
        mask_immersed_field!(field, field.grid, location(field), value)
    end
#= none:13 =#
mask_immersed_field!(::Number, args...) = begin
        #= none:13 =#
        nothing
    end
#= none:15 =#
function mask_immersed_field!(bop::BinaryOperation{<:Any, <:Any, <:Any, typeof(+)}, value = zero(eltype(bop)))
    #= none:15 =#
    #= none:16 =#
    a_value = ifelse(bop.b isa Number, -(bop.b), value)
    #= none:17 =#
    mask_immersed_field!(bop.a, a_value)
    #= none:19 =#
    b_value = ifelse(bop.a isa Number, -(bop.a), value)
    #= none:20 =#
    mask_immersed_field!(bop.b, b_value)
    #= none:21 =#
    return nothing
end
#= none:24 =#
function mask_immersed_field!(bop::BinaryOperation{<:Any, <:Any, <:Any, typeof(-)}, value = zero(eltype(bop)))
    #= none:24 =#
    #= none:25 =#
    a_value = ifelse(bop.b isa Number, bop.b, value)
    #= none:26 =#
    mask_immersed_field!(bop.a, a_value)
    #= none:28 =#
    b_value = ifelse(bop.a isa Number, bop.a, value)
    #= none:29 =#
    mask_immersed_field!(bop.b, b_value)
    #= none:30 =#
    return nothing
end
#= none:33 =#
#= none:33 =# Core.@doc "    mask_immersed_field!(field::Field, grid::ImmersedBoundaryGrid, loc, value)\n\nmasks `field` defined on `grid` with a value `val` at locations where `peripheral_node` evaluates to `true`\n" function mask_immersed_field!(field::Field, grid::ImmersedBoundaryGrid, loc, value)
        #= none:38 =#
        #= none:39 =#
        arch = architecture(field)
        #= none:40 =#
        loc = instantiate.(loc)
        #= none:41 =#
        launch!(arch, grid, :xyz, _mask_immersed_field!, field, loc, grid, value)
        #= none:42 =#
        return nothing
    end
#= none:45 =#
#= none:45 =# @kernel function _mask_immersed_field!(field, loc, grid, value)
        #= none:45 =#
        #= none:46 =#
        (i, j, k) = #= none:46 =# @index(Global, NTuple)
        #= none:47 =#
        #= none:47 =# @inbounds field[i, j, k] = scalar_mask(i, j, k, grid, grid.immersed_boundary, loc..., value, field)
    end
#= none:50 =#
mask_immersed_field_xy!(field, args...; kw...) = begin
        #= none:50 =#
        nothing
    end
#= none:51 =#
mask_immersed_field_xy!(::Nothing, args...; kw...) = begin
        #= none:51 =#
        nothing
    end
#= none:52 =#
mask_immersed_field_xy!(field, value = zero(eltype(field.grid)); k, mask = peripheral_node) = begin
        #= none:52 =#
        mask_immersed_field_xy!(field, field.grid, location(field), value; k, mask)
    end
#= none:55 =#
mask_immersed_field_xy!(::Number, args...) = begin
        #= none:55 =#
        nothing
    end
#= none:57 =#
function mask_immersed_field_xy!(bop::BinaryOperation{<:Any, <:Any, <:Any, typeof(+)}, value = zero(eltype(bop)))
    #= none:57 =#
    #= none:58 =#
    a_value = ifelse(bop.b isa Number, -(bop.b), value)
    #= none:59 =#
    mask_immersed_field_xy!(bop.a, a_value)
    #= none:61 =#
    b_value = ifelse(bop.a isa Number, -(bop.a), value)
    #= none:62 =#
    mask_immersed_field_xy!(bop.b, b_value)
    #= none:63 =#
    return nothing
end
#= none:66 =#
function mask_immersed_field_xy!(bop::BinaryOperation{<:Any, <:Any, <:Any, typeof(-)}, value = zero(eltype(bop)))
    #= none:66 =#
    #= none:67 =#
    a_value = ifelse(bop.b isa Number, bop.b, value)
    #= none:68 =#
    mask_immersed_field_xy!(bop.a, a_value)
    #= none:70 =#
    b_value = ifelse(bop.a isa Number, bop.a, value)
    #= none:71 =#
    mask_immersed_field_xy!(bop.b, b_value)
    #= none:72 =#
    return nothing
end
#= none:75 =#
#= none:75 =# Core.@doc "    mask_immersed_field_xy!(field::Field, grid::ImmersedBoundaryGrid, loc, value; k, mask=peripheral_node)\n\nMask `field` on `grid` with a `value` on the slices `[:, :, k]` where `mask` is `true`.\n" function mask_immersed_field_xy!(field::Field, grid::ImmersedBoundaryGrid, loc, value; k, mask)
        #= none:80 =#
        #= none:81 =#
        arch = architecture(field)
        #= none:82 =#
        loc = instantiate.(loc)
        #= none:83 =#
        return launch!(arch, grid, :xy, _mask_immersed_field_xy!, field, loc, grid, value, k, mask)
    end
#= none:87 =#
#= none:87 =# @kernel function _mask_immersed_field_xy!(field, loc, grid, value, k, mask)
        #= none:87 =#
        #= none:88 =#
        (i, j) = #= none:88 =# @index(Global, NTuple)
        #= none:89 =#
        #= none:89 =# @inbounds field[i, j, k] = scalar_mask(i, j, k, grid, grid.immersed_boundary, loc..., value, field, mask)
    end
#= none:96 =#
#= none:96 =# @inline scalar_mask(i, j, k, grid, ::AbstractGridFittedBoundary, LX, LY, LZ, value, field, mask = peripheral_node) = begin
            #= none:96 =#
            #= none:97 =# @inbounds ifelse(mask(i, j, k, grid, LX, LY, LZ), value, field[i, j, k])
        end