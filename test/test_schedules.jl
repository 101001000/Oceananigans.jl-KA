
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.Utils: TimeInterval, IterationInterval, WallTimeInterval, SpecifiedTimes
#= none:4 =#
using Oceananigans.Utils: schedule_aligned_time_step
#= none:5 =#
using Oceananigans.TimeSteppers: Clock
#= none:6 =#
using Oceananigans: initialize!
#= none:8 =#
#= none:8 =# @testset "Schedules" begin
        #= none:9 =#
        #= none:9 =# @info "Testing schedules..."
        #= none:12 =#
        fake_model_at_iter_0 = (; clock = Clock(time = 0.0, iteration = 0))
        #= none:13 =#
        fake_model_at_iter_3 = (; clock = Clock(time = 1.0, iteration = 3))
        #= none:14 =#
        fake_model_at_iter_5 = (; clock = Clock(time = 2.0, iteration = 5))
        #= none:16 =#
        fake_model_at_time_2 = (; clock = Clock(time = 2.0, iteration = 3))
        #= none:17 =#
        fake_model_at_time_3 = (; clock = Clock(time = 3.0, iteration = 3))
        #= none:18 =#
        fake_model_at_time_4 = (; clock = Clock(time = 4.0, iteration = 1))
        #= none:19 =#
        fake_model_at_time_5 = (; clock = Clock(time = 5.0, iteration = 1))
        #= none:22 =#
        ti = TimeInterval(2)
        #= none:23 =#
        initialize!(ti, fake_model_at_iter_0)
        #= none:25 =#
        #= none:25 =# @test ti.actuations == 0
        #= none:26 =#
        #= none:26 =# @test ti.interval == 2.0
        #= none:27 =#
        #= none:27 =# @test ti(fake_model_at_time_2)
        #= none:28 =#
        #= none:28 =# @test !(ti(fake_model_at_time_3))
        #= none:29 =#
        #= none:29 =# @test initialize!(ti, fake_model_at_iter_0)
        #= none:32 =#
        ii = IterationInterval(3)
        #= none:34 =#
        #= none:34 =# @test !(ii(fake_model_at_iter_5))
        #= none:35 =#
        #= none:35 =# @test ii(fake_model_at_iter_3)
        #= none:36 =#
        #= none:36 =# @test initialize!(ii, fake_model_at_iter_0)
        #= none:39 =#
        ti_and_ii = AndSchedule(TimeInterval(2), IterationInterval(3))
        #= none:40 =#
        #= none:40 =# @test ti_and_ii(fake_model_at_time_2)
        #= none:41 =#
        #= none:41 =# @test !(ti_and_ii(fake_model_at_time_4))
        #= none:42 =#
        #= none:42 =# @test !(ti_and_ii(fake_model_at_iter_3))
        #= none:43 =#
        #= none:43 =# @test !(ti_and_ii(fake_model_at_iter_5))
        #= none:44 =#
        #= none:44 =# @test !(ti_and_ii(fake_model_at_time_3))
        #= none:46 =#
        ti_or_ii = OrSchedule(TimeInterval(2), IterationInterval(3))
        #= none:47 =#
        #= none:47 =# @test ti_or_ii(fake_model_at_iter_3)
        #= none:48 =#
        #= none:48 =# @test ti_or_ii(fake_model_at_iter_5)
        #= none:49 =#
        #= none:49 =# @test ti_or_ii(fake_model_at_time_3)
        #= none:50 =#
        #= none:50 =# @test ti_or_ii(fake_model_at_time_4)
        #= none:51 =#
        #= none:51 =# @test !(ti_or_ii(fake_model_at_time_5))
        #= none:54 =#
        wti = WallTimeInterval(1.0e-9)
        #= none:56 =#
        #= none:56 =# @test wti.interval == 1.0e-9
        #= none:57 =#
        #= none:57 =# @test wti(nothing)
        #= none:60 =#
        st = (st_list = SpecifiedTimes(2, 5, 6))
        #= none:61 =#
        st_vector = SpecifiedTimes([2, 5, 6])
        #= none:62 =#
        #= none:62 =# @test st_list.times == st_vector.times
        #= none:63 =#
        #= none:63 =# @test st.times == [2.0, 5.0, 6.0]
        #= none:64 =#
        #= none:64 =# @test !(initialize!(st, fake_model_at_iter_0))
        #= none:67 =#
        st = SpecifiedTimes(5, 2, 6)
        #= none:68 =#
        #= none:68 =# @test st.times == [2.0, 5.0, 6.0]
        #= none:70 =#
        #= none:70 =# @test st(fake_model_at_time_2)
        #= none:72 =#
        #= none:72 =# @test !(st(fake_model_at_time_4))
        #= none:73 =#
        #= none:73 =# @test st(fake_model_at_time_5)
        #= none:76 =#
        st = SpecifiedTimes(0, 2, 4)
        #= none:77 =#
        #= none:77 =# @test initialize!(st, fake_model_at_iter_0)
        #= none:79 =#
        fake_clock = (; time = 2.1)
        #= none:80 =#
        st = SpecifiedTimes(2.5)
        #= none:81 =#
        #= none:81 =# @test 0.4 ≈ schedule_aligned_time_step(st, fake_clock, Inf)
    end