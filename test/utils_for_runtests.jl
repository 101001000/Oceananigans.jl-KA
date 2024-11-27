
#= none:1 =#
using Oceananigans.TimeSteppers: QuasiAdamsBashforth2TimeStepper, RungeKutta3TimeStepper, update_state!
#= none:2 =#
using Oceananigans.DistributedComputations: Distributed, Partition, child_architecture, Fractional, Equal
#= none:4 =#
import Oceananigans.Fields: interior
#= none:6 =#
test_child_arch() = begin
        #= none:6 =#
        if true
            GPU()
        else
            CPU()
        end
    end
#= none:8 =#
function test_architectures()
    #= none:8 =#
    #= none:9 =#
    child_arch = test_child_arch()
    #= none:14 =#
    if MPI.Initialized() && MPI.Comm_size(MPI.COMM_WORLD) == 4
        #= none:15 =#
        return (Distributed(child_arch; partition = Partition(4)), Distributed(child_arch; partition = Partition(1, 4)), Distributed(child_arch; partition = Partition(2, 2)), Distributed(child_arch; partition = Partition(x = Fractional(1, 2, 3, 4))), Distributed(child_arch; partition = Partition(y = Fractional(1, 2, 3, 4))), Distributed(child_arch; partition = Partition(x = Fractional(1, 2), y = Equal())))
    else
        #= none:22 =#
        return tuple(child_arch)
    end
end
#= none:28 =#
function nonhydrostatic_regression_test_architectures()
    #= none:28 =#
    #= none:29 =#
    child_arch = test_child_arch()
    #= none:34 =#
    if MPI.Initialized() && MPI.Comm_size(MPI.COMM_WORLD) == 4
        #= none:35 =#
        return (Distributed(child_arch; partition = Partition(4)), Distributed(child_arch; partition = Partition(1, 4)), Distributed(child_arch; partition = Partition(2, 2)))
    else
        #= none:39 =#
        return tuple(child_arch)
    end
end
#= none:43 =#
function summarize_regression_test(fields, correct_fields)
    #= none:43 =#
    #= none:44 =#
    for (field_name, φ, φ_c) = zip(keys(fields), fields, correct_fields)
        #= none:45 =#
        Δ = φ .- φ_c
        #= none:46 =#
        Δ_min = minimum(Δ)
        #= none:47 =#
        Δ_max = maximum(Δ)
        #= none:48 =#
        Δ_mean = mean(Δ)
        #= none:49 =#
        Δ_abs_mean = mean(abs, Δ)
        #= none:50 =#
        Δ_std = std(Δ)
        #= none:51 =#
        matching = sum(φ .≈ φ_c)
        #= none:52 =#
        grid_points = length(φ_c)
        #= none:54 =#
        #= none:54 =# @info #= none:54 =# @sprintf("Δ%s: min=%+.6e, max=%+.6e, mean=%+.6e, absmean=%+.6e, std=%+.6e (%d/%d matching grid points)", field_name, Δ_min, Δ_max, Δ_mean, Δ_abs_mean, Δ_std, matching, grid_points)
        #= none:56 =#
    end
end
#= none:64 =#
function center_clustered_coord(N, L, x₀)
    #= none:64 =#
    #= none:65 =#
    Δz(k) = begin
            #= none:65 =#
            if k < N / 2 + 1
                (2 / (N - 1)) * (k - 1) + 1
            else
                (-2 / (N - 1)) * (k - N) + 1
            end
        end
    #= none:66 =#
    z_faces = zeros(N + 1)
    #= none:67 =#
    for k = 2:N + 1
        #= none:68 =#
        z_faces[k] = (z_faces[k - 1] + 3) - Δz(k - 1)
        #= none:69 =#
    end
    #= none:70 =#
    z_faces = (z_faces ./ z_faces[end]) .* L .+ x₀
    #= none:71 =#
    return z_faces
end
#= none:75 =#
function boundary_clustered_coord(N, L, x₀)
    #= none:75 =#
    #= none:76 =#
    Δz(k) = begin
            #= none:76 =#
            if k < N / 2 + 1
                (2 / (N - 1)) * (k - 1) + 1
            else
                (-2 / (N - 1)) * (k - N) + 1
            end
        end
    #= none:77 =#
    z_faces = zeros(N + 1)
    #= none:78 =#
    for k = 2:N + 1
        #= none:79 =#
        z_faces[k] = z_faces[k - 1] + Δz(k - 1)
        #= none:80 =#
    end
    #= none:81 =#
    z_faces = (z_faces ./ z_faces[end]) .* L .+ x₀
    #= none:82 =#
    return z_faces
end
#= none:89 =#
#= none:89 =# @kernel function ∇²!(∇²f, grid, f)
        #= none:89 =#
        #= none:90 =#
        (i, j, k) = #= none:90 =# @index(Global, NTuple)
        #= none:91 =#
        #= none:91 =# @inbounds ∇²f[i, j, k] = ∇²ᶜᶜᶜ(i, j, k, grid, f)
    end
#= none:94 =#
#= none:94 =# @kernel function divergence!(grid, u, v, w, div)
        #= none:94 =#
        #= none:95 =#
        (i, j, k) = #= none:95 =# @index(Global, NTuple)
        #= none:96 =#
        #= none:96 =# @inbounds div[i, j, k] = divᶜᶜᶜ(i, j, k, grid, u, v, w)
    end
#= none:99 =#
function compute_∇²!(∇²ϕ, ϕ, arch, grid)
    #= none:99 =#
    #= none:100 =#
    fill_halo_regions!(ϕ)
    #= none:101 =#
    launch!(arch, grid, :xyz, ∇²!, ∇²ϕ, grid, ϕ)
    #= none:102 =#
    fill_halo_regions!(∇²ϕ)
    #= none:103 =#
    return nothing
end
#= none:110 =#
interior(a, grid) = begin
        #= none:110 =#
        view(a, grid.Hx + 1:grid.Nx + grid.Hx, grid.Hy + 1:grid.Ny + grid.Hy, grid.Hz + 1:grid.Nz + grid.Hz)
    end
#= none:114 =#
datatuple(A) = begin
        #= none:114 =#
        NamedTuple{propertynames(A)}((Array(data(a)) for a = A))
    end
#= none:115 =#
datatuple(args, names) = begin
        #= none:115 =#
        NamedTuple{names}((a.data for a = args))
    end
#= none:117 =#
function get_output_tuple(output, iter, tuplename)
    #= none:117 =#
    #= none:118 =#
    file = jldopen(output.filepath, "r")
    #= none:119 =#
    output_tuple = file["timeseries/$(tuplename)/$(iter)"]
    #= none:120 =#
    close(file)
    #= none:121 =#
    return output_tuple
end
#= none:124 =#
function run_script(replace_strings, script_name, script_filepath, module_suffix = "")
    #= none:124 =#
    #= none:125 =#
    file_content = read(script_filepath, String)
    #= none:126 =#
    test_script_filepath = script_name * "_test.jl"
    #= none:128 =#
    for strs = replace_strings
        #= none:129 =#
        new_file_content = replace(file_content, strs[1] => strs[2])
        #= none:130 =#
        if new_file_content == file_content
            #= none:131 =#
            error("$(strs[1]) => $(strs[2]) replacement not found in $(script_filepath). " * "Make sure the script has not changed, otherwise the test might take a long time.")
            #= none:133 =#
            return false
        else
            #= none:135 =#
            file_content = new_file_content
        end
        #= none:137 =#
    end
    #= none:139 =#
    open(test_script_filepath, "w") do f
        #= none:141 =#
        write(f, "module _Test_$(script_name)" * "_$(module_suffix)\n")
        #= none:142 =#
        write(f, file_content)
        #= none:143 =#
        write(f, "\nend # module")
    end
    #= none:146 =#
    try
        #= none:147 =#
        include(test_script_filepath)
    catch err
        #= none:149 =#
        #= none:149 =# @error sprint(showerror, err)
        #= none:152 =#
        test_file_content = read(test_script_filepath, String)
        #= none:153 =#
        delineated_file_content = split(test_file_content, "\n")
        #= none:154 =#
        for (number, line) = enumerate(delineated_file_content)
            #= none:155 =#
            #= none:155 =# @printf "% 3d %s\n" number line
            #= none:156 =#
        end
        #= none:158 =#
        rm(test_script_filepath)
        #= none:159 =#
        return false
    end
    #= none:163 =#
    rm(test_script_filepath)
    #= none:165 =#
    return true
end
#= none:172 =#
discrete_func(i, j, grid, clock, model_fields) = begin
        #= none:172 =#
        -(model_fields.u[i, j, grid.Nz])
    end
#= none:173 =#
parameterized_discrete_func(i, j, grid, clock, model_fields, p) = begin
        #= none:173 =#
        -(p.μ) * model_fields.u[i, j, grid.Nz]
    end
#= none:175 =#
parameterized_fun(ξ, η, t, p) = begin
        #= none:175 =#
        p.μ * cos(p.ω * t)
    end
#= none:176 =#
field_dependent_fun(ξ, η, t, u, v, w) = begin
        #= none:176 =#
        -w * sqrt(u ^ 2 + v ^ 2)
    end
#= none:177 =#
exploding_fun(ξ, η, t, T, S, p) = begin
        #= none:177 =#
        -(p.μ) * cosh(S - p.S0) * exp((T - p.T0) / p.λ)
    end
#= none:180 =#
integer_bc(C, FT = Float64, ArrayType = Array) = begin
        #= none:180 =#
        BoundaryCondition(C, 1)
    end
#= none:181 =#
float_bc(C, FT = Float64, ArrayType = Array) = begin
        #= none:181 =#
        BoundaryCondition(C, FT(π))
    end
#= none:182 =#
irrational_bc(C, FT = Float64, ArrayType = Array) = begin
        #= none:182 =#
        BoundaryCondition(C, π)
    end
#= none:183 =#
array_bc(C, FT = Float64, ArrayType = Array) = begin
        #= none:183 =#
        BoundaryCondition(C, ArrayType(rand(FT, 1, 1)))
    end
#= none:184 =#
simple_function_bc(C, FT = Float64, ArrayType = Array) = begin
        #= none:184 =#
        BoundaryCondition(C, ((ξ, η, t)->begin
                    #= none:184 =#
                    exp(ξ) * cos(η) * sin(t)
                end))
    end
#= none:185 =#
parameterized_function_bc(C, FT = Float64, ArrayType = Array) = begin
        #= none:185 =#
        BoundaryCondition(C, parameterized_fun, parameters = (μ = 0.1, ω = 2π))
    end
#= none:186 =#
field_dependent_function_bc(C, FT = Float64, ArrayType = Array) = begin
        #= none:186 =#
        BoundaryCondition(C, field_dependent_fun, field_dependencies = (:u, :v, :w))
    end
#= none:187 =#
discrete_function_bc(C, FT = Float64, ArrayType = Array) = begin
        #= none:187 =#
        BoundaryCondition(C, discrete_func, discrete_form = true)
    end
#= none:189 =#
parameterized_discrete_function_bc(C, FT = Float64, ArrayType = Array) = begin
        #= none:189 =#
        BoundaryCondition(C, parameterized_discrete_func, discrete_form = true, parameters = (μ = 0.1,))
    end
#= none:190 =#
parameterized_field_dependent_function_bc(C, FT = Float64, ArrayType = Array) = begin
        #= none:190 =#
        BoundaryCondition(C, exploding_fun, field_dependencies = (:T, :S), parameters = (S0 = 35, T0 = 100, μ = 2π, λ = FT(2)))
    end