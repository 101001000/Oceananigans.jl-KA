
#= none:1 =#
#= none:1 =# Core.@doc "    required_halo_size_x(tendency_term)\n\nReturn the required size of halos in the x direction for a term appearing\nin the tendency for a velocity field or tracer field.\n\nExample\n=======\n\n```jldoctest\nusing Oceananigans.Advection: CenteredFourthOrder\nusing Oceananigans.Grids: required_halo_size_x\n\nrequired_halo_size_x(CenteredFourthOrder())\n\n# output\n2\n" function required_halo_size_x end
#= none:21 =#
#= none:21 =# Core.@doc "    required_halo_size_y(tendency_term)\n\nReturn the required size of halos in the y direction for a term appearing\nin the tendency for a velocity field or tracer field.\n\nExample\n=======\n\n```jldoctest\nusing Oceananigans.Advection: CenteredFourthOrder\nusing Oceananigans.Grids: required_halo_size_y\n\nrequired_halo_size_y(CenteredFourthOrder())\n\n# output\n2\n" function required_halo_size_y end
#= none:41 =#
#= none:41 =# Core.@doc "    required_halo_size_z(tendency_term)\n\nReturn the required size of halos in the y direction for a term appearing\nin the tendency for a velocity field or tracer field.\n\nExample\n=======\n\n```jldoctest\nusing Oceananigans.Advection: CenteredFourthOrder\nusing Oceananigans.Grids: required_halo_size_z\n\nrequired_halo_size_z(CenteredFourthOrder())\n\n# output\n2\n" function required_halo_size_z end
#= none:61 =#
required_halo_size_x(tendency_term) = begin
        #= none:61 =#
        1
    end
#= none:62 =#
required_halo_size_x(::Nothing) = begin
        #= none:62 =#
        0
    end
#= none:63 =#
required_halo_size_y(tendency_term) = begin
        #= none:63 =#
        1
    end
#= none:64 =#
required_halo_size_y(::Nothing) = begin
        #= none:64 =#
        0
    end
#= none:65 =#
required_halo_size_z(tendency_term) = begin
        #= none:65 =#
        1
    end
#= none:66 =#
required_halo_size_z(::Nothing) = begin
        #= none:66 =#
        0
    end
#= none:68 =#
inflate_halo_size_one_dimension(req_H, old_H, _, grid) = begin
        #= none:68 =#
        max(req_H, old_H)
    end
#= none:69 =#
inflate_halo_size_one_dimension(req_H, old_H, ::Type{Flat}, grid) = begin
        #= none:69 =#
        0
    end
#= none:71 =#
function inflate_halo_size(Hx, Hy, Hz, grid, tendency_terms...)
    #= none:71 =#
    #= none:72 =#
    topo = topology(grid)
    #= none:73 =#
    for term = tendency_terms
        #= none:74 =#
        Hx_required = required_halo_size_x(term)
        #= none:75 =#
        Hy_required = required_halo_size_y(term)
        #= none:76 =#
        Hz_required = required_halo_size_z(term)
        #= none:77 =#
        Hx = inflate_halo_size_one_dimension(Hx_required, Hx, topo[1], grid)
        #= none:78 =#
        Hy = inflate_halo_size_one_dimension(Hy_required, Hy, topo[2], grid)
        #= none:79 =#
        Hz = inflate_halo_size_one_dimension(Hz_required, Hz, topo[3], grid)
        #= none:80 =#
    end
    #= none:82 =#
    return (Hx, Hy, Hz)
end