
#= none:5 =#
for metric = (:Δ, :A), dir = (:x, :y, :z), LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ), LZ = (:ᶜ, :ᶠ)
    #= none:7 =#
    operator = Symbol(metric, dir, :_q, LX, LY, LZ)
    #= none:8 =#
    grid_metric = Symbol(metric, dir, LX, LY, LZ)
    #= none:10 =#
    #= none:10 =# @eval begin
            #= none:11 =#
            #= none:11 =# @inline $operator(i, j, k, grid, q) = begin
                        #= none:11 =#
                        #= none:11 =# @inbounds $grid_metric(i, j, k, grid) * q[i, j, k]
                    end
            #= none:12 =#
            #= none:12 =# @inline $operator(i, j, k, grid, f::Function, args...) = begin
                        #= none:12 =#
                        $grid_metric(i, j, k, grid) * f(i, j, k, grid, args...)
                    end
        end
    #= none:14 =#
end