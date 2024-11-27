
#= none:5 =#
function closure_summary(closures::Tuple, padchar = "│")
    #= none:5 =#
    #= none:6 =#
    Nclosures = length(closures)
    #= none:7 =#
    if Nclosures == 1
        #= none:8 =#
        return string("Tuple with 1 closure:", "\n", "$(padchar)   └── ", summary(closures[1]))
    else
        #= none:11 =#
        return string("Tuple with $(Nclosures) closures:", "\n", Tuple((string("$(padchar)   ├── ", summary(c), "\n") for c = closures[1:end - 1]))..., "$(padchar)   └── ", summary(closures[end]))
    end
end
#= none:21 =#
outer_tendency_functions = [:∂ⱼ_τ₁ⱼ, :∂ⱼ_τ₂ⱼ, :∂ⱼ_τ₃ⱼ, :∇_dot_qᶜ]
#= none:22 =#
inner_tendency_functions = [:∂ⱼ_τ₁ⱼ, :∂ⱼ_τ₂ⱼ, :∂ⱼ_τ₃ⱼ, :∇_dot_qᶜ]
#= none:24 =#
diffusive_fluxes = [:diffusive_flux_x, :diffusive_flux_y, :diffusive_flux_z]
#= none:26 =#
viscous_fluxes = [:viscous_flux_ux, :viscous_flux_uy, :viscous_flux_uz, :viscous_flux_vx, :viscous_flux_vy, :viscous_flux_vz, :viscous_flux_wx, :viscous_flux_wy, :viscous_flux_wz]
#= none:30 =#
outer_ivd_functions = [:_ivd_upper_diagonal, :_ivd_lower_diagonal, :_implicit_linear_coefficient]
#= none:31 =#
inner_ivd_functions = [:ivd_upper_diagonal, :ivd_lower_diagonal, :implicit_linear_coefficient]
#= none:33 =#
outer_funcs = vcat(outer_tendency_functions, outer_ivd_functions, diffusive_fluxes, viscous_fluxes)
#= none:34 =#
inner_funcs = vcat(inner_tendency_functions, inner_ivd_functions, diffusive_fluxes, viscous_fluxes)
#= none:36 =#
for (outer_f, inner_f) = zip(outer_funcs, inner_funcs)
    #= none:37 =#
    #= none:37 =# @eval begin
            #= none:38 =#
            #= none:38 =# @inline $outer_f(i, j, k, grid, closures::Tuple{<:Any}, Ks, args...) = begin
                        #= none:38 =#
                        $inner_f(i, j, k, grid, closures[1], Ks[1], args...)
                    end
            #= none:41 =#
            #= none:41 =# @inline $outer_f(i, j, k, grid, closures::Tuple{<:Any, <:Any}, Ks, args...) = begin
                        #= none:41 =#
                        $inner_f(i, j, k, grid, closures[1], Ks[1], args...) + $inner_f(i, j, k, grid, closures[2], Ks[2], args...)
                    end
            #= none:45 =#
            #= none:45 =# @inline $outer_f(i, j, k, grid, closures::Tuple{<:Any, <:Any, <:Any}, Ks, args...) = begin
                        #= none:45 =#
                        $inner_f(i, j, k, grid, closures[1], Ks[1], args...) + $inner_f(i, j, k, grid, closures[2], Ks[2], args...) + $inner_f(i, j, k, grid, closures[3], Ks[3], args...)
                    end
            #= none:50 =#
            #= none:50 =# @inline $outer_f(i, j, k, grid, closures::Tuple{<:Any, <:Any, <:Any, <:Any}, Ks, args...) = begin
                        #= none:50 =#
                        $inner_f(i, j, k, grid, closures[1], Ks[1], args...) + $inner_f(i, j, k, grid, closures[2], Ks[2], args...) + $inner_f(i, j, k, grid, closures[3], Ks[3], args...) + $inner_f(i, j, k, grid, closures[4], Ks[4], args...)
                    end
            #= none:56 =#
            #= none:56 =# @inline $outer_f(i, j, k, grid, closures::Tuple{<:Any, <:Any, <:Any, <:Any, <:Any}, Ks, args...) = begin
                        #= none:56 =#
                        $inner_f(i, j, k, grid, closures[1], Ks[1], args...) + $inner_f(i, j, k, grid, closures[2], Ks[2], args...) + $inner_f(i, j, k, grid, closures[3], Ks[3], args...) + $inner_f(i, j, k, grid, closures[4], Ks[4], args...) + $inner_f(i, j, k, grid, closures[5], Ks[5], args...)
                    end
            #= none:63 =#
            #= none:63 =# @inline $outer_f(i, j, k, grid, closures::Tuple, Ks, args...) = begin
                        #= none:63 =#
                        $inner_f(i, j, k, grid, closures[1], Ks[1], args...) + $f(i, j, k, grid, closures[2:end], Ks[2:end], args...)
                    end
        end
    #= none:67 =#
end
#= none:74 =#
with_tracers(tracers, closure_tuple::Tuple) = begin
        #= none:74 =#
        Tuple((with_tracers(tracers, closure) for closure = closure_tuple))
    end
#= none:76 =#
function compute_diffusivities!(diffusivity_fields_tuple, closure_tuple::Tuple, args...; kwargs...)
    #= none:76 =#
    #= none:77 =#
    for (α, closure) = enumerate(closure_tuple)
        #= none:78 =#
        diffusivity_fields = diffusivity_fields_tuple[α]
        #= none:79 =#
        compute_diffusivities!(diffusivity_fields, closure, args...; kwargs...)
        #= none:80 =#
    end
    #= none:81 =#
    return nothing
end
#= none:84 =#
function add_closure_specific_boundary_conditions(closure_tuple::Tuple, bcs, args...)
    #= none:84 =#
    #= none:86 =#
    for closure = closure_tuple
        #= none:87 =#
        bcs = add_closure_specific_boundary_conditions(closure, bcs, args...)
        #= none:88 =#
    end
    #= none:89 =#
    return bcs
end
#= none:92 =#
required_halo_size_x(closure_tuple::Tuple) = begin
        #= none:92 =#
        maximum(map(required_halo_size_x, closure_tuple))
    end
#= none:93 =#
required_halo_size_y(closure_tuple::Tuple) = begin
        #= none:93 =#
        maximum(map(required_halo_size_y, closure_tuple))
    end
#= none:94 =#
required_halo_size_z(closure_tuple::Tuple) = begin
        #= none:94 =#
        maximum(map(required_halo_size_z, closure_tuple))
    end
#= none:100 =#
const ETD = ExplicitTimeDiscretization
#= none:101 =#
const VITD = VerticallyImplicitTimeDiscretization
#= none:103 =#
#= none:103 =# @inline combine_time_discretizations(disc) = begin
            #= none:103 =#
            disc
        end
#= none:104 =#
#= none:104 =# @inline combine_time_discretizations(::ETD, ::VITD) = begin
            #= none:104 =#
            VerticallyImplicitTimeDiscretization()
        end
#= none:105 =#
#= none:105 =# @inline combine_time_discretizations(::VITD, ::ETD) = begin
            #= none:105 =#
            VerticallyImplicitTimeDiscretization()
        end
#= none:106 =#
#= none:106 =# @inline combine_time_discretizations(::VITD, ::VITD) = begin
            #= none:106 =#
            VerticallyImplicitTimeDiscretization()
        end
#= none:107 =#
#= none:107 =# @inline combine_time_discretizations(::ETD, ::ETD) = begin
            #= none:107 =#
            ExplicitTimeDiscretization()
        end
#= none:109 =#
#= none:109 =# @inline combine_time_discretizations(d1, d2, other_discs...) = begin
            #= none:109 =#
            combine_time_discretizations(combine_time_discretizations(d1, d2), other_discs...)
        end
#= none:112 =#
#= none:112 =# @inline time_discretization(closures::Tuple) = begin
            #= none:112 =#
            combine_time_discretizations(time_discretization.(closures)...)
        end