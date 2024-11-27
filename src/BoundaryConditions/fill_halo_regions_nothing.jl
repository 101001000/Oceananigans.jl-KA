
#= none:5 =#
fill_west_and_east_halo!(c, ::Nothing, ::Nothing, args...; kwargs...) = begin
        #= none:5 =#
        nothing
    end
#= none:6 =#
fill_south_and_north_halo!(c, ::Nothing, ::Nothing, args...; kwargs...) = begin
        #= none:6 =#
        nothing
    end
#= none:7 =#
fill_bottom_and_top_halo!(c, ::Nothing, ::Nothing, args...; kwargs...) = begin
        #= none:7 =#
        nothing
    end
#= none:9 =#
for dir = (:west, :east, :south, :north, :bottom, :top)
    #= none:10 =#
    fill_nothing! = Symbol(:fill_, dir, :_halo!)
    #= none:11 =#
    alt_fill_nothing! = Symbol(:_fill_, dir, :_halo!)
    #= none:12 =#
    #= none:12 =# @eval begin
            #= none:13 =#
            #= none:13 =# @inline $fill_nothing!(c, ::Nothing, args...; kwargs...) = begin
                        #= none:13 =#
                        nothing
                    end
            #= none:14 =#
            #= none:14 =# @inline $alt_fill_nothing!(i, j, grid, c, ::Nothing, args...) = begin
                        #= none:14 =#
                        nothing
                    end
            #= none:15 =#
            #= none:15 =# @inline $alt_fill_nothing!(i, j, grid, ::Nothing, ::Nothing, args...) = begin
                        #= none:15 =#
                        nothing
                    end
            #= none:16 =#
            #= none:16 =# @inline $alt_fill_nothing!(i, j, grid, ::Nothing, args...) = begin
                        #= none:16 =#
                        nothing
                    end
        end
    #= none:18 =#
end