
#= none:2 =#
get_domain_extent(::Nothing, N) = begin
        #= none:2 =#
        (1, 1)
    end
#= none:3 =#
get_domain_extent(coord, N) = begin
        #= none:3 =#
        (coord[1], coord[2])
    end
#= none:4 =#
get_domain_extent(coord::Function, N) = begin
        #= none:4 =#
        (coord(1), coord(N + 1))
    end
#= none:5 =#
get_domain_extent(coord::AbstractVector, N) = begin
        #= none:5 =#
        #= none:5 =# CUDA.@allowscalar (coord[1], coord[N + 1])
    end
#= none:6 =#
get_domain_extent(coord::Number, N) = begin
        #= none:6 =#
        (coord, coord)
    end
#= none:8 =#
get_face_node(coord::Nothing, i) = begin
        #= none:8 =#
        1
    end
#= none:9 =#
get_face_node(coord::Function, i) = begin
        #= none:9 =#
        coord(i)
    end
#= none:10 =#
get_face_node(coord::AbstractVector, i) = begin
        #= none:10 =#
        #= none:10 =# CUDA.@allowscalar coord[i]
    end
#= none:12 =#
const AT = AbstractTopology
#= none:14 =#
lower_exterior_Δcoordᶠ(::AT, Fi, Hcoord) = begin
        #= none:14 =#
        [Fi[(end - Hcoord) + i] - Fi[((end - Hcoord) + i) - 1] for i = 1:Hcoord]
    end
#= none:15 =#
lower_exterior_Δcoordᶠ(::BoundedTopology, Fi, Hcoord) = begin
        #= none:15 =#
        [Fi[2] - Fi[1] for _ = 1:Hcoord]
    end
#= none:17 =#
upper_exterior_Δcoordᶠ(::AT, Fi, Hcoord) = begin
        #= none:17 =#
        [Fi[i + 1] - Fi[i] for i = 1:Hcoord]
    end
#= none:18 =#
upper_exterior_Δcoordᶠ(::BoundedTopology, Fi, Hcoord) = begin
        #= none:18 =#
        [Fi[end] - Fi[end - 1] for _ = 1:Hcoord]
    end
#= none:20 =#
upper_interior_F(::AT, coord, Δ) = begin
        #= none:20 =#
        coord - Δ
    end
#= none:21 =#
upper_interior_F(::BoundedTopology, coord) = begin
        #= none:21 =#
        coord
    end
#= none:23 =#
total_interior_length(::AT, N) = begin
        #= none:23 =#
        N
    end
#= none:24 =#
total_interior_length(::BoundedTopology, N) = begin
        #= none:24 =#
        N + 1
    end
#= none:26 =#
bad_coordinate_message(ξ::Function, name) = begin
        #= none:26 =#
        "The values of $(name)(index) must increase as the index increases!"
    end
#= none:27 =#
bad_coordinate_message(ξ::AbstractArray, name) = begin
        #= none:27 =#
        "The elements of $(name) must be increasing!"
    end
#= none:30 =#
function generate_coordinate(FT, topo::AT, N, H, node_generator, coordinate_name, arch)
    #= none:30 =#
    #= none:33 =#
    interior_face_nodes = zeros(FT, N + 1)
    #= none:36 =#
    for idx = 1:N + 1
        #= none:37 =#
        interior_face_nodes[idx] = get_face_node(node_generator, idx)
        #= none:38 =#
    end
    #= none:41 =#
    if !(issorted(interior_face_nodes))
        #= none:42 =#
        msg = bad_coordinate_message(node_generator, coordinate_name)
        #= none:43 =#
        throw(ArgumentError(msg))
    end
    #= none:47 =#
    L = interior_face_nodes[N + 1] - interior_face_nodes[1]
    #= none:50 =#
    Δᶠ₋ = lower_exterior_Δcoordᶠ(topo, interior_face_nodes, H)
    #= none:51 =#
    Δᶠ₊ = reverse(upper_exterior_Δcoordᶠ(topo, interior_face_nodes, H))
    #= none:53 =#
    (c¹, cᴺ⁺¹) = (interior_face_nodes[1], interior_face_nodes[N + 1])
    #= none:55 =#
    F₋ = [c¹ - sum(Δᶠ₋[i:H]) for i = 1:H]
    #= none:56 =#
    F₊ = reverse([cᴺ⁺¹ + sum(Δᶠ₊[i:H]) for i = 1:H])
    #= none:58 =#
    F = vcat(F₋, interior_face_nodes, F₊)
    #= none:61 =#
    TC = total_length(Center(), topo, N, H)
    #= none:62 =#
    C = [(F[i + 1] + F[i]) / 2 for i = 1:TC]
    #= none:63 =#
    Δᶠ = [C[i] - C[i - 1] for i = 2:TC]
    #= none:66 =#
    TF = total_length(Face(), topo, N, H)
    #= none:67 =#
    F = F[1:TF]
    #= none:69 =#
    Δᶜ = [F[i + 1] - F[i] for i = 1:TF - 1]
    #= none:71 =#
    Δᶠ = [Δᶠ[1], Δᶠ..., Δᶠ[end]]
    #= none:72 =#
    for i = length(Δᶠ):-1:2
        #= none:73 =#
        Δᶠ[i] = Δᶠ[i - 1]
        #= none:74 =#
    end
    #= none:76 =#
    Δᶜ = OffsetArray(on_architecture(arch, Δᶜ), -H)
    #= none:77 =#
    Δᶠ = OffsetArray(on_architecture(arch, Δᶠ), -H - 1)
    #= none:79 =#
    F = OffsetArray(F, -H)
    #= none:80 =#
    C = OffsetArray(C, -H)
    #= none:83 =#
    F = OffsetArray(on_architecture(arch, F.parent), F.offsets...)
    #= none:84 =#
    C = OffsetArray(on_architecture(arch, C.parent), C.offsets...)
    #= none:86 =#
    return (L, F, C, Δᶠ, Δᶜ)
end
#= none:90 =#
function generate_coordinate(FT, topo::AT, N, H, node_interval::Tuple{<:Number, <:Number}, coordinate_name, arch)
    #= none:90 =#
    #= none:92 =#
    if node_interval[2] < node_interval[1]
        #= none:93 =#
        msg = "$(coordinate_name) must be an increasing interval!"
        #= none:94 =#
        throw(ArgumentError(msg))
    end
    #= none:97 =#
    (c₁, c₂) = #= none:97 =# @__dot__(BigFloat(node_interval))
    #= none:98 =#
    #= none:98 =# @assert c₁ < c₂
    #= none:99 =#
    L = c₂ - c₁
    #= none:102 =#
    Δᶠ = (Δᶜ = (Δ = L / N))
    #= none:104 =#
    F₋ = c₁ - H * Δ
    #= none:105 =#
    F₊ = F₋ + total_extent(topo, H, Δ, L)
    #= none:107 =#
    C₋ = F₋ + Δ / 2
    #= none:108 =#
    C₊ = C₋ + L + Δ * (2H - 1)
    #= none:110 =#
    TF = total_length(Face(), topo, N, H)
    #= none:111 =#
    TC = total_length(Center(), topo, N, H)
    #= none:113 =#
    F = range(FT(F₋), FT(F₊), length = TF)
    #= none:114 =#
    C = range(FT(C₋), FT(C₊), length = TC)
    #= none:116 =#
    F = OffsetArray(F, -H)
    #= none:117 =#
    C = OffsetArray(C, -H)
    #= none:119 =#
    return (FT(L), F, C, FT(Δᶠ), FT(Δᶜ))
end
#= none:123 =#
generate_coordinate(FT, ::Flat, N, H, c::Number, coordinate_name, arch) = begin
        #= none:123 =#
        (FT(1), range(FT(c), FT(c), length = N), range(FT(c), FT(c), length = N), FT(1), FT(1))
    end
#= none:130 =#
generate_coordinate(FT, ::Flat, N, H, ::Nothing, coordinate_name, arch) = begin
        #= none:130 =#
        (FT(1), nothing, nothing, FT(1), FT(1))
    end