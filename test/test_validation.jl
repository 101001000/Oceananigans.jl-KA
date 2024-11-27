
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
VALIDATION_DIR = "../validation/"
#= none:4 =#
EXPERIMENTS = ["stratified_couette_flow"]
#= none:6 =#
for exp = EXPERIMENTS
    #= none:7 =#
    script_filepath = joinpath(VALIDATION_DIR, exp, exp * ".jl")
    #= none:8 =#
    try
        #= none:9 =#
        include(script_filepath)
    catch err
        #= none:11 =#
        #= none:11 =# @error sprint(showerror, err)
    end
    #= none:13 =#
end
#= none:15 =#
function run_stratified_couette_flow_validation(arch)
    #= none:15 =#
    #= none:16 =#
    simulate_stratified_couette_flow(Nxy = 16, Nz = 8, arch = arch, Ri = 0.01, Ni = 1, end_time = 1.0e-5)
    #= none:17 =#
    return true
end
#= none:20 =#
#= none:20 =# @testset "Validation" begin
        #= none:21 =#
        #= none:21 =# @info "Testing validation scripts..."
        #= none:23 =#
        for arch = archs
            #= none:24 =#
            #= none:24 =# @testset "Stratified Couette flow validation [$(typeof(arch))]" begin
                    #= none:25 =#
                    #= none:25 =# @info "  Testing stratified Couette flow validation [$(typeof(arch))]"
                    #= none:26 =#
                    #= none:26 =# @test run_stratified_couette_flow_validation(arch)
                end
            #= none:28 =#
        end
    end