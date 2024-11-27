
#= none:5 =#
for LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ), LZ = (:ᶜ, :ᶠ)
    #= none:7 =#
    x_derivative = Symbol(:∂x, LX, LY, LZ)
    #= none:8 =#
    x_spacing = Symbol(:Δx, LX, LY, LZ)
    #= none:9 =#
    x_difference = Symbol(:δx, LX, LY, LZ)
    #= none:11 =#
    y_derivative = Symbol(:∂y, LX, LY, LZ)
    #= none:12 =#
    y_spacing = Symbol(:Δy, LX, LY, LZ)
    #= none:13 =#
    y_difference = Symbol(:δy, LX, LY, LZ)
    #= none:15 =#
    z_derivative = Symbol(:∂z, LX, LY, LZ)
    #= none:16 =#
    z_spacing = Symbol(:Δz, LX, LY, LZ)
    #= none:17 =#
    z_difference = Symbol(:δz, LX, LY, LZ)
    #= none:19 =#
    #= none:19 =# @eval begin
            #= none:20 =#
            #= none:20 =# @inline $x_derivative(i, j, k, grid, c) = begin
                        #= none:20 =#
                        $x_difference(i, j, k, grid, c) / $x_spacing(i, j, k, grid)
                    end
            #= none:21 =#
            #= none:21 =# @inline $y_derivative(i, j, k, grid, c) = begin
                        #= none:21 =#
                        $y_difference(i, j, k, grid, c) / $y_spacing(i, j, k, grid)
                    end
            #= none:22 =#
            #= none:22 =# @inline $z_derivative(i, j, k, grid, c) = begin
                        #= none:22 =#
                        $z_difference(i, j, k, grid, c) / $z_spacing(i, j, k, grid)
                    end
            #= none:24 =#
            #= none:24 =# @inline $x_derivative(i, j, k, grid, c::Number) = begin
                        #= none:24 =#
                        zero(grid)
                    end
            #= none:25 =#
            #= none:25 =# @inline $y_derivative(i, j, k, grid, c::Number) = begin
                        #= none:25 =#
                        zero(grid)
                    end
            #= none:26 =#
            #= none:26 =# @inline $z_derivative(i, j, k, grid, c::Number) = begin
                        #= none:26 =#
                        zero(grid)
                    end
            #= none:28 =#
            #= none:28 =# @inline $x_derivative(i, j, k, grid, f::Function, args...) = begin
                        #= none:28 =#
                        $x_difference(i, j, k, grid, f, args...) / $x_spacing(i, j, k, grid)
                    end
            #= none:29 =#
            #= none:29 =# @inline $y_derivative(i, j, k, grid, f::Function, args...) = begin
                        #= none:29 =#
                        $y_difference(i, j, k, grid, f, args...) / $y_spacing(i, j, k, grid)
                    end
            #= none:30 =#
            #= none:30 =# @inline $z_derivative(i, j, k, grid, f::Function, args...) = begin
                        #= none:30 =#
                        $z_difference(i, j, k, grid, f, args...) / $z_spacing(i, j, k, grid)
                    end
        end
    #= none:32 =#
end
#= none:38 =#
#= none:38 =# @inline insert_symbol(dir, L, L1, L2) = begin
            #= none:38 =#
            if dir == :x
                (L, L1, L2)
            else
                if dir == :y
                    (L1, L, L2)
                else
                    (L1, L2, L)
                end
            end
        end
#= none:46 =#
for dir = (:x, :y, :z), L1 = (:ᶜ, :ᶠ), L2 = (:ᶜ, :ᶠ)
    #= none:48 =#
    first_order_face = Symbol(:∂, dir, insert_symbol(dir, :ᶠ, L1, L2)...)
    #= none:49 =#
    second_order_face = Symbol(:∂², dir, insert_symbol(dir, :ᶠ, L1, L2)...)
    #= none:50 =#
    third_order_face = Symbol(:∂³, dir, insert_symbol(dir, :ᶠ, L1, L2)...)
    #= none:51 =#
    fourth_order_face = Symbol(:∂⁴, dir, insert_symbol(dir, :ᶠ, L1, L2)...)
    #= none:53 =#
    first_order_center = Symbol(:∂, dir, insert_symbol(dir, :ᶜ, L1, L2)...)
    #= none:54 =#
    second_order_center = Symbol(:∂², dir, insert_symbol(dir, :ᶜ, L1, L2)...)
    #= none:55 =#
    third_order_center = Symbol(:∂³, dir, insert_symbol(dir, :ᶜ, L1, L2)...)
    #= none:56 =#
    fourth_order_center = Symbol(:∂⁴, dir, insert_symbol(dir, :ᶜ, L1, L2)...)
    #= none:58 =#
    #= none:58 =# @eval begin
            #= none:59 =#
            #= none:59 =# @inline $second_order_face(i, j, k, grid, c) = begin
                        #= none:59 =#
                        $first_order_face(i, j, k, grid, $first_order_center, c)
                    end
            #= none:60 =#
            #= none:60 =# @inline $third_order_face(i, j, k, grid, c) = begin
                        #= none:60 =#
                        $first_order_face(i, j, k, grid, $second_order_center, c)
                    end
            #= none:61 =#
            #= none:61 =# @inline $fourth_order_face(i, j, k, grid, c) = begin
                        #= none:61 =#
                        $second_order_face(i, j, k, grid, $second_order_face, c)
                    end
            #= none:63 =#
            #= none:63 =# @inline $second_order_center(i, j, k, grid, c) = begin
                        #= none:63 =#
                        $first_order_center(i, j, k, grid, $first_order_face, c)
                    end
            #= none:64 =#
            #= none:64 =# @inline $third_order_center(i, j, k, grid, c) = begin
                        #= none:64 =#
                        $first_order_center(i, j, k, grid, $second_order_face, c)
                    end
            #= none:65 =#
            #= none:65 =# @inline $fourth_order_center(i, j, k, grid, c) = begin
                        #= none:65 =#
                        $second_order_center(i, j, k, grid, $second_order_center, c)
                    end
            #= none:67 =#
            #= none:67 =# @inline $second_order_face(i, j, k, grid, f::Function, args...) = begin
                        #= none:67 =#
                        $first_order_face(i, j, k, grid, $first_order_center, f::Function, args...)
                    end
            #= none:68 =#
            #= none:68 =# @inline $third_order_face(i, j, k, grid, f::Function, args...) = begin
                        #= none:68 =#
                        $first_order_face(i, j, k, grid, $second_order_center, f::Function, args...)
                    end
            #= none:69 =#
            #= none:69 =# @inline $fourth_order_face(i, j, k, grid, f::Function, args...) = begin
                        #= none:69 =#
                        $second_order_face(i, j, k, grid, $second_order_face, f::Function, args...)
                    end
            #= none:71 =#
            #= none:71 =# @inline $second_order_center(i, j, k, grid, f::Function, args...) = begin
                        #= none:71 =#
                        $first_order_center(i, j, k, grid, $first_order_face, f::Function, args...)
                    end
            #= none:72 =#
            #= none:72 =# @inline $third_order_center(i, j, k, grid, f::Function, args...) = begin
                        #= none:72 =#
                        $first_order_center(i, j, k, grid, $second_order_face, f::Function, args...)
                    end
            #= none:73 =#
            #= none:73 =# @inline $fourth_order_center(i, j, k, grid, f::Function, args...) = begin
                        #= none:73 =#
                        $second_order_center(i, j, k, grid, $second_order_center, f::Function, args...)
                    end
        end
    #= none:75 =#
end
#= none:81 =#
for dir = (:x, :y, :z), LX = (:ᶜ, :ᶠ), LY = (:ᶜ, :ᶠ), LZ = (:ᶜ, :ᶠ)
    #= none:83 =#
    operator = Symbol(:A, dir, :_∂, dir, LX, LY, LZ)
    #= none:84 =#
    area = Symbol(:A, dir, LX, LY, LZ)
    #= none:85 =#
    derivative = Symbol(:∂, dir, LX, LY, LZ)
    #= none:87 =#
    #= none:87 =# @eval begin
            #= none:88 =#
            #= none:88 =# @inline $operator(i, j, k, grid, c) = begin
                        #= none:88 =#
                        $area(i, j, k, grid) * $derivative(i, j, k, grid, c)
                    end
        end
    #= none:90 =#
end