
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
∂t_uˢ_uniform(z, t, h) = begin
        #= none:3 =#
        exp(z / h) * cos(t)
    end
#= none:4 =#
∂t_vˢ_uniform(z, t, h) = begin
        #= none:4 =#
        exp(z / h) * cos(t)
    end
#= none:5 =#
∂z_uˢ_uniform(z, t, h) = begin
        #= none:5 =#
        (exp(z / h) / h) * sin(t)
    end
#= none:6 =#
∂z_vˢ_uniform(z, t, h) = begin
        #= none:6 =#
        (exp(z / h) / h) * sin(t)
    end
#= none:8 =#
∂t_uˢ(x, y, z, t, h) = begin
        #= none:8 =#
        exp(z / h) * cos(t)
    end
#= none:9 =#
∂t_vˢ(x, y, z, t, h) = begin
        #= none:9 =#
        exp(z / h) * cos(t)
    end
#= none:10 =#
∂t_wˢ(x, y, z, t, h) = begin
        #= none:10 =#
        0
    end
#= none:11 =#
∂x_vˢ(x, y, z, t, h) = begin
        #= none:11 =#
        0
    end
#= none:12 =#
∂x_wˢ(x, y, z, t, h) = begin
        #= none:12 =#
        0
    end
#= none:13 =#
∂y_uˢ(x, y, z, t, h) = begin
        #= none:13 =#
        0
    end
#= none:14 =#
∂y_wˢ(x, y, z, t, h) = begin
        #= none:14 =#
        0
    end
#= none:15 =#
∂z_uˢ(x, y, z, t, h) = begin
        #= none:15 =#
        (exp(z / h) / h) * sin(t)
    end
#= none:16 =#
∂z_vˢ(x, y, z, t, h) = begin
        #= none:16 =#
        (exp(z / h) / h) * sin(t)
    end
#= none:18 =#
function instantiate_uniform_stokes_drift()
    #= none:18 =#
    #= none:19 =#
    stokes_drift = UniformStokesDrift(∂t_uˢ = ∂t_uˢ_uniform, ∂t_vˢ = ∂t_vˢ_uniform, ∂z_uˢ = ∂z_uˢ_uniform, ∂z_vˢ = ∂z_vˢ_uniform, parameters = 20)
    #= none:25 =#
    return true
end
#= none:28 =#
function instantiate_stokes_drift()
    #= none:28 =#
    #= none:29 =#
    stokes_drift = StokesDrift(∂t_uˢ = ∂t_uˢ, ∂t_vˢ = ∂t_vˢ, ∂t_wˢ = ∂t_wˢ, ∂x_vˢ = ∂x_vˢ, ∂x_wˢ = ∂x_wˢ, ∂y_uˢ = ∂y_uˢ, ∂y_wˢ = ∂y_wˢ, ∂z_uˢ = ∂z_uˢ, ∂z_vˢ = ∂z_vˢ, parameters = 20)
    #= none:40 =#
    return true
end
#= none:43 =#
#= none:43 =# @testset "Stokes drift" begin
        #= none:44 =#
        #= none:44 =# @info "Testing Stokes drift..."
        #= none:46 =#
        #= none:46 =# @testset "Stokes drift" begin
                #= none:47 =#
                #= none:47 =# @test instantiate_uniform_stokes_drift()
                #= none:48 =#
                #= none:48 =# @test instantiate_stokes_drift()
            end
    end