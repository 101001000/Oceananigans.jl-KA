
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Statistics: mean
#= none:4 =#
using Oceananigans.Operators
#= none:7 =#
#= none:7 =# @inline intrinsic_vector_x_component(i, j, k, grid, uₑ, vₑ) = begin
            #= none:7 =#
            #= none:8 =# @inbounds (intrinsic_vector(i, j, k, grid, uₑ, vₑ))[1]
        end
#= none:10 =#
#= none:10 =# @inline intrinsic_vector_y_component(i, j, k, grid, uₑ, vₑ) = begin
            #= none:10 =#
            #= none:11 =# @inbounds (intrinsic_vector(i, j, k, grid, uₑ, vₑ))[2]
        end
#= none:13 =#
#= none:13 =# @inline extrinsic_vector_x_component(i, j, k, grid, uᵢ, vᵢ) = begin
            #= none:13 =#
            #= none:14 =# @inbounds (extrinsic_vector(i, j, k, grid, uᵢ, vᵢ))[1]
        end
#= none:16 =#
#= none:16 =# @inline extrinsic_vector_y_component(i, j, k, grid, uᵢ, vᵢ) = begin
            #= none:16 =#
            #= none:17 =# @inbounds (extrinsic_vector(i, j, k, grid, uᵢ, vᵢ))[2]
        end
#= none:19 =#
#= none:19 =# @inline function kinetic_energyᶜᶜᶜ(i, j, k, grid, uᶜᶜᶜ, vᶜᶜᶜ)
        #= none:19 =#
        #= none:20 =#
        #= none:20 =# @inbounds u² = uᶜᶜᶜ[i, j, k] ^ 2
        #= none:21 =#
        #= none:21 =# @inbounds v² = vᶜᶜᶜ[i, j, k] ^ 2
        #= none:22 =#
        return (u² + v²) / 2
    end
#= none:25 =#
function kinetic_energy(u, v)
    #= none:25 =#
    #= none:26 =#
    grid = u.grid
    #= none:27 =#
    ke_op = KernelFunctionOperation{Center, Center, Center}(kinetic_energyᶜᶜᶜ, grid, u, v)
    #= none:28 =#
    ke = Field(ke_op)
    #= none:29 =#
    return compute!(ke)
end
#= none:32 =#
function pointwise_approximate_equal(field, val)
    #= none:32 =#
    #= none:33 =#
    CPU_field = on_architecture(CPU(), field)
    #= none:34 =#
    #= none:34 =# @test all(interior(CPU_field) .≈ val)
end
#= none:40 =#
function test_purely_zonal_flow(uᵢ, vᵢ, grid)
    #= none:40 =#
    #= none:41 =#
    c1 = maximum(uᵢ) ≈ -(minimum(vᵢ))
    #= none:42 =#
    c2 = minimum(uᵢ) ≈ -(maximum(vᵢ))
    #= none:43 =#
    c3 = mean(uᵢ) ≈ -(mean(vᵢ))
    #= none:44 =#
    c4 = mean(uᵢ) > 0
    #= none:46 =#
    return ((c1 & c2) & c3) & c4
end
#= none:52 =#
function test_purely_meridional_flow(uᵢ, vᵢ, grid)
    #= none:52 =#
    #= none:53 =#
    c1 = maximum(uᵢ) ≈ maximum(vᵢ)
    #= none:54 =#
    c2 = minimum(uᵢ) ≈ minimum(vᵢ)
    #= none:55 =#
    c3 = mean(uᵢ) ≈ mean(vᵢ)
    #= none:56 =#
    c4 = mean(vᵢ) > 0
    #= none:58 =#
    return ((c1 & c2) & c3) & c4
end
#= none:61 =#
function test_vector_rotation(grid)
    #= none:61 =#
    #= none:62 =#
    u = CenterField(grid)
    #= none:63 =#
    v = CenterField(grid)
    #= none:66 =#
    fill!(u, 1)
    #= none:67 =#
    fill!(v, 0)
    #= none:70 =#
    uᵢ = KernelFunctionOperation{Center, Center, Center}(intrinsic_vector_x_component, grid, u, v)
    #= none:71 =#
    vᵢ = KernelFunctionOperation{Center, Center, Center}(intrinsic_vector_y_component, grid, u, v)
    #= none:73 =#
    uᵢ = compute!(Field(uᵢ))
    #= none:74 =#
    vᵢ = compute!(Field(vᵢ))
    #= none:78 =#
    #= none:78 =# @test test_purely_zonal_flow(uᵢ, vᵢ, grid)
    #= none:81 =#
    KE = kinetic_energy(uᵢ, vᵢ)
    #= none:82 =#
    #= none:82 =# @apply_regionally pointwise_approximate_equal(KE, 0.5)
    #= none:85 =#
    uₑ = KernelFunctionOperation{Center, Center, Center}(extrinsic_vector_x_component, grid, uᵢ, vᵢ)
    #= none:86 =#
    vₑ = KernelFunctionOperation{Center, Center, Center}(extrinsic_vector_y_component, grid, uᵢ, vᵢ)
    #= none:88 =#
    uₑ = compute!(Field(uₑ))
    #= none:89 =#
    vₑ = compute!(Field(vₑ))
    #= none:93 =#
    if architecture(grid) isa CPU
        #= none:96 =#
        #= none:96 =# @apply_regionally pointwise_approximate_equal(vₑ, 0)
    end
    #= none:99 =#
    #= none:99 =# @apply_regionally pointwise_approximate_equal(uₑ, 1)
    #= none:102 =#
    fill!(u, 0)
    #= none:103 =#
    fill!(v, 1)
    #= none:106 =#
    uᵢ = KernelFunctionOperation{Center, Center, Center}(intrinsic_vector_x_component, grid, u, v)
    #= none:107 =#
    vᵢ = KernelFunctionOperation{Center, Center, Center}(intrinsic_vector_y_component, grid, u, v)
    #= none:109 =#
    uᵢ = compute!(Field(uᵢ))
    #= none:110 =#
    vᵢ = compute!(Field(vᵢ))
    #= none:114 =#
    #= none:114 =# @test test_purely_meridional_flow(uᵢ, vᵢ, grid)
    #= none:117 =#
    KE = kinetic_energy(uᵢ, vᵢ)
    #= none:118 =#
    #= none:118 =# @apply_regionally pointwise_approximate_equal(KE, 0.5)
    #= none:121 =#
    uₑ = KernelFunctionOperation{Center, Center, Center}(extrinsic_vector_x_component, grid, uᵢ, vᵢ)
    #= none:122 =#
    vₑ = KernelFunctionOperation{Center, Center, Center}(extrinsic_vector_y_component, grid, uᵢ, vᵢ)
    #= none:124 =#
    uₑ = compute!(Field(uₑ))
    #= none:125 =#
    vₑ = compute!(Field(vₑ))
    #= none:129 =#
    #= none:129 =# @apply_regionally pointwise_approximate_equal(vₑ, 1)
    #= none:131 =#
    if architecture(grid) isa CPU
        #= none:134 =#
        #= none:134 =# @apply_regionally pointwise_approximate_equal(uₑ, 0)
    end
    #= none:138 =#
    fill!(u, 0.5)
    #= none:139 =#
    fill!(v, 0.5)
    #= none:142 =#
    uᵢ = KernelFunctionOperation{Center, Center, Center}(intrinsic_vector_x_component, grid, u, v)
    #= none:143 =#
    vᵢ = KernelFunctionOperation{Center, Center, Center}(intrinsic_vector_y_component, grid, u, v)
    #= none:145 =#
    uᵢ = compute!(Field(uᵢ))
    #= none:146 =#
    vᵢ = compute!(Field(vᵢ))
    #= none:150 =#
    #= none:150 =# @test maximum(uᵢ) ≈ maximum(vᵢ)
    #= none:151 =#
    #= none:151 =# @test minimum(uᵢ) ≈ minimum(vᵢ)
    #= none:154 =#
    KE = kinetic_energy(uᵢ, vᵢ)
    #= none:155 =#
    #= none:155 =# @apply_regionally pointwise_approximate_equal(KE, 0.25)
    #= none:158 =#
    uₑ = KernelFunctionOperation{Center, Center, Center}(extrinsic_vector_x_component, grid, uᵢ, vᵢ)
    #= none:159 =#
    vₑ = KernelFunctionOperation{Center, Center, Center}(extrinsic_vector_y_component, grid, uᵢ, vᵢ)
    #= none:161 =#
    uₑ = compute!(Field(uₑ))
    #= none:162 =#
    vₑ = compute!(Field(vₑ))
    #= none:166 =#
    #= none:166 =# @apply_regionally pointwise_approximate_equal(vₑ, 0.5)
    #= none:167 =#
    #= none:167 =# @apply_regionally pointwise_approximate_equal(uₑ, 0.5)
end
#= none:170 =#
#= none:170 =# @testset "Vector rotation" begin
        #= none:171 =#
        for arch = archs
            #= none:172 =#
            #= none:172 =# @testset "Conversion from Intrinsic to Extrinsic reference frame [$(typeof(arch))]" begin
                    #= none:173 =#
                    #= none:173 =# @info "  Testing the conversion of a vector between the Intrinsic and Extrinsic reference frame"
                    #= none:174 =#
                    grid = ConformalCubedSphereGrid(arch; panel_size = (10, 10, 1), z = (-1, 0))
                    #= none:175 =#
                    test_vector_rotation(grid)
                end
            #= none:177 =#
        end
    end