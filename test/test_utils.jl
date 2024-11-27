
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
#= none:3 =# @testset "Utils" begin
        #= none:4 =#
        #= none:4 =# @info "Testing utils..."
        #= none:6 =#
        #= none:6 =# @testset "prettytime" begin
                #= none:7 =#
                #= none:7 =# @test prettytime(0) == "0 seconds"
                #= none:8 =#
                #= none:8 =# @test prettytime(3.5e-14) == "3.500e-14 seconds"
                #= none:10 =#
                #= none:10 =# @test prettytime(1.0e-9) == "1 ns"
                #= none:11 =#
                #= none:11 =# @test prettytime(1.0e-6) == "1 μs"
                #= none:12 =#
                #= none:12 =# @test prettytime(0.001) == "1 ms"
                #= none:14 =#
                #= none:14 =# @test prettytime(second) == "1 second"
                #= none:15 =#
                #= none:15 =# @test prettytime(minute) == "1 minute"
                #= none:16 =#
                #= none:16 =# @test prettytime(hour) == "1 hour"
                #= none:17 =#
                #= none:17 =# @test prettytime(day) == "1 day"
                #= none:19 =#
                #= none:19 =# @test prettytime(2second) == "2 seconds"
                #= none:20 =#
                #= none:20 =# @test prettytime(4minute) == "4 minutes"
                #= none:21 =#
                #= none:21 =# @test prettytime(8hour) == "8 hours"
                #= none:22 =#
                #= none:22 =# @test prettytime(16day) == "16 days"
                #= none:24 =#
                #= none:24 =# @test prettytime(13.7seconds) == "13.700 seconds"
                #= none:25 =#
                #= none:25 =# @test prettytime(6.666minutes) == "6.666 minutes"
                #= none:26 =#
                #= none:26 =# @test prettytime(1.234hour) == "1.234 hours"
                #= none:27 =#
                #= none:27 =# @test prettytime(40.5days) == "40.500 days"
            end
    end