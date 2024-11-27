
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
function simple_binary_operation(op, a, b, num1, num2)
    #= none:3 =#
    #= none:4 =#
    a_b = op(a, b)
    #= none:5 =#
    interior(a) .= num1
    #= none:6 =#
    interior(b) .= num2
    #= none:7 =#
    return #= none:7 =# CUDA.@allowscalar(a_b[2, 2, 2] == op(num1, num2))
end
#= none:10 =#
function three_field_addition(a, b, c, num1, num2)
    #= none:10 =#
    #= none:11 =#
    a_b_c = a + b + c
    #= none:12 =#
    interior(a) .= num1
    #= none:13 =#
    interior(b) .= num2
    #= none:14 =#
    interior(c) .= num2
    #= none:15 =#
    return #= none:15 =# CUDA.@allowscalar(a_b_c[2, 2, 2] == num1 + num2 + num2)
end
#= none:18 =#
function x_derivative(a)
    #= none:18 =#
    #= none:19 =#
    dx_a = ∂x(a)
    #= none:21 =#
    arch = architecture(a)
    #= none:22 =#
    one_two_three = on_architecture(arch, [1, 2, 3])
    #= none:24 =#
    for k = 1:3
        #= none:25 =#
        (interior(a))[:, 1, k] .= one_two_three
        #= none:26 =#
        (interior(a))[:, 2, k] .= one_two_three
        #= none:27 =#
        (interior(a))[:, 3, k] .= one_two_three
        #= none:28 =#
    end
    #= none:30 =#
    return #= none:30 =# CUDA.@allowscalar(dx_a[2, 2, 2] == 1)
end
#= none:33 =#
function y_derivative(a)
    #= none:33 =#
    #= none:34 =#
    dy_a = ∂y(a)
    #= none:36 =#
    arch = architecture(a)
    #= none:37 =#
    one_three_five = on_architecture(arch, [1, 3, 5])
    #= none:39 =#
    for k = 1:3
        #= none:40 =#
        (interior(a))[1, :, k] .= one_three_five
        #= none:41 =#
        (interior(a))[2, :, k] .= one_three_five
        #= none:42 =#
        (interior(a))[3, :, k] .= one_three_five
        #= none:43 =#
    end
    #= none:45 =#
    return #= none:45 =# CUDA.@allowscalar(dy_a[2, 2, 2] == 2)
end
#= none:48 =#
function z_derivative(a)
    #= none:48 =#
    #= none:49 =#
    dz_a = ∂z(a)
    #= none:51 =#
    arch = architecture(a)
    #= none:52 =#
    one_four_seven = on_architecture(arch, [1, 4, 7])
    #= none:54 =#
    for k = 1:3
        #= none:55 =#
        (interior(a))[1, k, :] .= one_four_seven
        #= none:56 =#
        (interior(a))[2, k, :] .= one_four_seven
        #= none:57 =#
        (interior(a))[3, k, :] .= one_four_seven
        #= none:58 =#
    end
    #= none:60 =#
    return #= none:60 =# CUDA.@allowscalar(dz_a[2, 2, 2] == 3)
end
#= none:63 =#
function x_derivative_cell(arch)
    #= none:63 =#
    #= none:64 =#
    grid = RectilinearGrid(arch, size = (3, 3, 3), extent = (3, 3, 3))
    #= none:65 =#
    a = Field{Center, Center, Center}(grid)
    #= none:66 =#
    dx_a = ∂x(a)
    #= none:68 =#
    one_four_four = on_architecture(arch, [1, 4, 4])
    #= none:70 =#
    for k = 1:3
        #= none:71 =#
        (interior(a))[:, 1, k] .= one_four_four
        #= none:72 =#
        (interior(a))[:, 2, k] .= one_four_four
        #= none:73 =#
        (interior(a))[:, 3, k] .= one_four_four
        #= none:74 =#
    end
    #= none:76 =#
    return #= none:76 =# CUDA.@allowscalar(dx_a[2, 2, 2] == 3)
end
#= none:79 =#
function times_x_derivative(a, b, location, i, j, k, answer)
    #= none:79 =#
    #= none:80 =#
    a∇b = #= none:80 =# @at(location, b * ∂x(a))
    #= none:82 =#
    return #= none:82 =# CUDA.@allowscalar(a∇b[i, j, k] == answer)
end
#= none:85 =#
for arch = archs
    #= none:86 =#
    #= none:86 =# @testset "Abstract operations [$(typeof(arch))]" begin
            #= none:87 =#
            #= none:87 =# @info "Testing abstract operations [$(typeof(arch))]..."
            #= none:89 =#
            grid = RectilinearGrid(arch, size = (3, 3, 3), extent = (3, 3, 3))
            #= none:90 =#
            (u, v, w) = VelocityFields(grid)
            #= none:91 =#
            c = Field{Center, Center, Center}(grid)
            #= none:93 =#
            #= none:93 =# @testset "Unary operations and derivatives [$(typeof(arch))]" begin
                    #= none:94 =#
                    for ψ = (u, v, w, c)
                        #= none:95 =#
                        for op = (sqrt, sin, cos, exp, tanh)
                            #= none:96 =#
                            #= none:96 =# @test #= none:96 =# CUDA.@allowscalar(typeof((op(ψ))[2, 2, 2]) <: Number)
                            #= none:97 =#
                        end
                        #= none:99 =#
                        for d_symbol = Oceananigans.AbstractOperations.derivative_operators
                            #= none:100 =#
                            d = eval(d_symbol)
                            #= none:101 =#
                            #= none:101 =# @test #= none:101 =# CUDA.@allowscalar(typeof((d(ψ))[2, 2, 2]) <: Number)
                            #= none:102 =#
                        end
                        #= none:103 =#
                    end
                end
            #= none:106 =#
            #= none:106 =# @testset "Binary operations [$(typeof(arch))]" begin
                    #= none:107 =#
                    generic_function(x, y, z) = begin
                            #= none:107 =#
                            x + y + z
                        end
                    #= none:108 =#
                    for (ψ, ϕ) = ((u, v), (u, w), (v, w), (u, c), (generic_function, c), (u, generic_function))
                        #= none:109 =#
                        for op_symbol = Oceananigans.AbstractOperations.binary_operators
                            #= none:110 =#
                            op = eval(op_symbol)
                            #= none:111 =#
                            #= none:111 =# @test #= none:111 =# CUDA.@allowscalar(typeof((op(ψ, ϕ))[2, 2, 2]) <: Number)
                            #= none:112 =#
                        end
                        #= none:113 =#
                    end
                    #= none:115 =#
                    #= none:115 =# @test compute!(Field(ZeroField() + u)) == u
                    #= none:116 =#
                    #= none:116 =# @test compute!(Field(u + ZeroField())) == u
                    #= none:117 =#
                    #= none:117 =# @test compute!(Field(-(ZeroField()) + u)) == u
                    #= none:118 =#
                    #= none:118 =# @test compute!(Field(u - ZeroField())) == u
                    #= none:119 =#
                    #= none:119 =# @test compute!(Field(ZeroField() * u)) == ZeroField()
                    #= none:120 =#
                    #= none:120 =# @test compute!(Field(u * ZeroField())) == ZeroField()
                    #= none:121 =#
                    #= none:121 =# @test compute!(Field(ZeroField() / u)) == ZeroField()
                    #= none:122 =#
                    #= none:122 =# @test u / ZeroField() == ConstantField(Inf)
                    #= none:124 =#
                    #= none:124 =# @test ZeroField() + 1 == ConstantField(1)
                    #= none:125 =#
                    #= none:125 =# @test 1 + ZeroField() == ConstantField(1)
                    #= none:126 =#
                    #= none:126 =# @test ZeroField() - 1 == ConstantField(-1)
                    #= none:127 =#
                    #= none:127 =# @test 1 - ZeroField() == ConstantField(1)
                    #= none:128 =#
                    #= none:128 =# @test ZeroField() * 1 == ZeroField()
                    #= none:129 =#
                    #= none:129 =# @test 1 * ZeroField() == ZeroField()
                    #= none:130 =#
                    #= none:130 =# @test ZeroField() / 1 == ZeroField()
                    #= none:131 =#
                    #= none:131 =# @test 1 / ZeroField() == ConstantField(Inf)
                    #= none:133 =#
                    #= none:133 =# @test ZeroField() + ZeroField() == ZeroField()
                    #= none:134 =#
                    #= none:134 =# @test ZeroField() - ZeroField() == ZeroField()
                    #= none:135 =#
                    #= none:135 =# @test ZeroField() * ZeroField() == ZeroField()
                    #= none:137 =#
                    #= none:137 =# @test compute!(Field(ConstantField(1) + u)) == compute!(Field(1 + u))
                    #= none:138 =#
                    #= none:138 =# @test compute!(Field(ConstantField(1) - u)) == compute!(Field(1 - u))
                    #= none:139 =#
                    #= none:139 =# @test compute!(Field(ConstantField(1) * u)) == compute!(Field(1u))
                    #= none:140 =#
                    #= none:140 =# @test compute!(Field(u / ConstantField(1))) == compute!(Field(u / 1))
                    #= none:142 =#
                    #= none:142 =# @test ConstantField(1) + 1 == ConstantField(2)
                    #= none:143 =#
                    #= none:143 =# @test ConstantField(1) - 1 == ConstantField(0)
                    #= none:144 =#
                    #= none:144 =# @test ConstantField(1) * 2 == ConstantField(2)
                    #= none:145 =#
                    #= none:145 =# @test ConstantField(1) / 2 == ConstantField(1 / 2)
                end
            #= none:148 =#
            #= none:148 =# @testset "Multiary operations [$(typeof(arch))]" begin
                    #= none:149 =#
                    generic_function(x, y, z) = begin
                            #= none:149 =#
                            x + y + z
                        end
                    #= none:150 =#
                    for (ψ, ϕ, σ) = ((u, v, w), (u, v, c), (u, v, generic_function))
                        #= none:151 =#
                        for op_symbol = Oceananigans.AbstractOperations.multiary_operators
                            #= none:152 =#
                            op = eval(op_symbol)
                            #= none:153 =#
                            #= none:153 =# @test #= none:153 =# CUDA.@allowscalar(typeof((op((Center, Center, Center), ψ, ϕ, σ))[2, 2, 2]) <: Number)
                            #= none:154 =#
                        end
                        #= none:155 =#
                    end
                end
            #= none:158 =#
            #= none:158 =# @testset "KernelFunctionOperations [$(typeof(arch))]" begin
                    #= none:159 =#
                    trivial_kernel_function(i, j, k, grid) = begin
                            #= none:159 =#
                            1
                        end
                    #= none:160 =#
                    op = KernelFunctionOperation{Center, Center, Center}(trivial_kernel_function, grid)
                    #= none:161 =#
                    #= none:161 =# @test op isa KernelFunctionOperation
                    #= none:163 =#
                    less_trivial_kernel_function(i, j, k, grid, u, v) = begin
                            #= none:163 =#
                            #= none:163 =# @inbounds u[i, j, k] * ℑxyᶠᶜᵃ(i, j, k, grid, v)
                        end
                    #= none:164 =#
                    op = KernelFunctionOperation{Face, Center, Center}(less_trivial_kernel_function, grid, u, v)
                    #= none:165 =#
                    #= none:165 =# @test op isa KernelFunctionOperation
                end
            #= none:168 =#
            #= none:168 =# @testset "Fidelity of simple binary operations" begin
                    #= none:169 =#
                    #= none:169 =# @info "  Testing simple binary operations..."
                    #= none:170 =#
                    num1 = Float64(π)
                    #= none:171 =#
                    num2 = Float64(42)
                    #= none:172 =#
                    grid = RectilinearGrid(arch, size = (3, 3, 3), extent = (3, 3, 3))
                    #= none:174 =#
                    (u, v, w) = VelocityFields(grid)
                    #= none:175 =#
                    (T, S) = TracerFields((:T, :S), grid)
                    #= none:177 =#
                    for op = (+, *, -, /)
                        #= none:178 =#
                        #= none:178 =# @test simple_binary_operation(op, u, v, num1, num2)
                        #= none:179 =#
                        #= none:179 =# @test simple_binary_operation(op, u, w, num1, num2)
                        #= none:180 =#
                        #= none:180 =# @test simple_binary_operation(op, u, T, num1, num2)
                        #= none:181 =#
                        #= none:181 =# @test simple_binary_operation(op, T, S, num1, num2)
                        #= none:182 =#
                    end
                    #= none:183 =#
                    #= none:183 =# @test three_field_addition(u, v, w, num1, num2)
                end
            #= none:186 =#
            #= none:186 =# @testset "Derivatives" begin
                    #= none:187 =#
                    #= none:187 =# @info "  Testing derivatives..."
                    #= none:188 =#
                    grid = RectilinearGrid(arch, size = (3, 3, 3), extent = (3, 3, 3), topology = (Periodic, Periodic, Periodic))
                    #= none:191 =#
                    (u, v, w) = VelocityFields(grid)
                    #= none:192 =#
                    (T, S) = TracerFields((:T, :S), grid)
                    #= none:193 =#
                    for a = (u, v, w, T)
                        #= none:194 =#
                        #= none:194 =# @test x_derivative(a)
                        #= none:195 =#
                        #= none:195 =# @test y_derivative(a)
                        #= none:196 =#
                        #= none:196 =# @test z_derivative(a)
                        #= none:197 =#
                    end
                    #= none:199 =#
                    #= none:199 =# @test x_derivative_cell(arch)
                end
            #= none:202 =#
            #= none:202 =# @testset "Combined binary operations and derivatives" begin
                    #= none:203 =#
                    #= none:203 =# @info "  Testing combined binary operations and derivatives..."
                    #= none:204 =#
                    Nx = 3
                    #= none:205 =#
                    grid = RectilinearGrid(arch, size = (Nx, Nx, Nx), extent = (Nx, Nx, Nx))
                    #= none:206 =#
                    (a, b) = (Field{Center, Center, Center}(grid) for i = 1:2)
                    #= none:208 =#
                    set!(b, 2)
                    #= none:209 =#
                    set!(a, ((x, y, z)->begin
                                #= none:209 =#
                                if x < 2
                                    3x
                                else
                                    6
                                end
                            end))
                    #= none:227 =#
                    C = Center
                    #= none:228 =#
                    F = Face
                    #= none:230 =#
                    #= none:230 =# @test times_x_derivative(a, b, (C, C, C), 1, 2, 2, 4.5)
                    #= none:231 =#
                    #= none:231 =# @test times_x_derivative(a, b, (C, C, C), 2, 2, 2, 4.5)
                    #= none:232 =#
                    #= none:232 =# @test times_x_derivative(a, b, (C, C, C), 3, 2, 2, -4.5)
                    #= none:234 =#
                    #= none:234 =# @test times_x_derivative(a, b, (F, C, C), 1, 2, 2, 1.5)
                    #= none:235 =#
                    #= none:235 =# @test times_x_derivative(a, b, (F, C, C), 2, 2, 2, 6)
                    #= none:236 =#
                    #= none:236 =# @test times_x_derivative(a, b, (F, C, C), 3, 2, 2, 3)
                    #= none:237 =#
                    #= none:237 =# @test times_x_derivative(a, b, (F, C, C), 4, 2, 2, -6)
                end
            #= none:240 =#
            grid = RectilinearGrid(arch, size = (4, 4, 4), extent = (1, 1, 1), topology = (Periodic, Periodic, Bounded))
            #= none:243 =#
            buoyancy = SeawaterBuoyancy(gravitational_acceleration = 1, equation_of_state = LinearEquationOfState(thermal_expansion = 1, haline_contraction = 1))
            #= none:246 =#
            model = NonhydrostaticModel(; grid, buoyancy, tracers = (:T, :S))
            #= none:248 =#
            #= none:248 =# @testset "Construction of abstract operations [$(typeof(arch))]" begin
                    #= none:249 =#
                    #= none:249 =# @info "    Testing construction of abstract operations [$(typeof(arch))]..."
                    #= none:251 =#
                    (u, v, w, T, S) = fields(model)
                    #= none:253 =#
                    for ϕ = (u, v, w, T)
                        #= none:254 =#
                        for op = (sin, cos, sqrt, exp, tanh)
                            #= none:255 =#
                            #= none:255 =# @test op(ϕ) isa UnaryOperation
                            #= none:256 =#
                        end
                        #= none:258 =#
                        for ∂ = (∂x, ∂y, ∂z)
                            #= none:259 =#
                            #= none:259 =# @test ∂(ϕ) isa Derivative
                            #= none:260 =#
                        end
                        #= none:262 =#
                        for ψ = (u, v, w, T, S)
                            #= none:263 =#
                            #= none:263 =# @test ψ ^ ϕ isa BinaryOperation
                            #= none:264 =#
                            #= none:264 =# @test ψ * ϕ isa BinaryOperation
                            #= none:265 =#
                            #= none:265 =# @test ψ + ϕ isa BinaryOperation
                            #= none:266 =#
                            #= none:266 =# @test ψ - ϕ isa BinaryOperation
                            #= none:267 =#
                            #= none:267 =# @test ψ / ϕ isa BinaryOperation
                            #= none:269 =#
                            for χ = (u, v, w, T, S)
                                #= none:270 =#
                                #= none:270 =# @test ψ * ϕ * χ isa MultiaryOperation
                                #= none:271 =#
                                #= none:271 =# @test ψ + ϕ + χ isa MultiaryOperation
                                #= none:272 =#
                            end
                            #= none:273 =#
                        end
                        #= none:275 =#
                        for metric = (AbstractOperations.Δx, AbstractOperations.Δy, AbstractOperations.Δz, AbstractOperations.Ax, AbstractOperations.Ay, AbstractOperations.Az, AbstractOperations.volume)
                            #= none:283 =#
                            #= none:283 =# @test location(metric * ϕ) == location(ϕ)
                            #= none:284 =#
                        end
                        #= none:285 =#
                    end
                    #= none:287 =#
                    #= none:287 =# @test u ^ 2 isa BinaryOperation
                    #= none:288 =#
                    #= none:288 =# @test u * 2 isa BinaryOperation
                    #= none:289 =#
                    #= none:289 =# @test u + 2 isa BinaryOperation
                    #= none:290 =#
                    #= none:290 =# @test u - 2 isa BinaryOperation
                    #= none:291 =#
                    #= none:291 =# @test u / 2 isa BinaryOperation
                end
            #= none:294 =#
            #= none:294 =# @testset "BinaryOperations with GridMetricOperation [$(typeof(arch))]" begin
                    #= none:295 =#
                    lat_lon_grid = LatitudeLongitudeGrid(arch, size = (1, 1, 1), longitude = (0, 1), latitude = (0, 1), z = (0, 1))
                    #= none:296 =#
                    rectilinear_grid = RectilinearGrid(arch, size = (1, 1, 1), extent = (2, 3, 4))
                    #= none:298 =#
                    for LX = (Center, Face)
                        #= none:299 =#
                        for LY = (Center, Face)
                            #= none:300 =#
                            for LZ = (Center, Face)
                                #= none:301 =#
                                loc = (LX, LY, LZ)
                                #= none:302 =#
                                f = Field(loc, rectilinear_grid)
                                #= none:303 =#
                                f .= 1
                                #= none:305 =#
                                #= none:305 =# CUDA.@allowscalar begin
                                        #= none:309 =#
                                        op = f * AbstractOperations.Δx
                                        #= none:309 =#
                                        #= none:309 =# @test op[1, 1, 1] == 2
                                        #= none:310 =#
                                        op = f * AbstractOperations.Δy
                                        #= none:310 =#
                                        #= none:310 =# @test op[1, 1, 1] == 3
                                        #= none:311 =#
                                        op = f * AbstractOperations.Δz
                                        #= none:311 =#
                                        #= none:311 =# @test op[1, 1, 1] == 4
                                        #= none:312 =#
                                        op = f * AbstractOperations.Ax
                                        #= none:312 =#
                                        #= none:312 =# @test op[1, 1, 1] == 12
                                        #= none:313 =#
                                        op = f * AbstractOperations.Ay
                                        #= none:313 =#
                                        #= none:313 =# @test op[1, 1, 1] == 8
                                        #= none:314 =#
                                        op = f * AbstractOperations.Az
                                        #= none:314 =#
                                        #= none:314 =# @test op[1, 1, 1] == 6
                                        #= none:315 =#
                                        op = f * AbstractOperations.volume
                                        #= none:315 =#
                                        #= none:315 =# @test op[1, 1, 1] == 24
                                        #= none:318 =#
                                        f = Field(loc, lat_lon_grid)
                                        #= none:319 =#
                                        op = f * AbstractOperations.Δx
                                        #= none:319 =#
                                        #= none:319 =# @test op[1, 1, 1] == 0
                                        #= none:320 =#
                                        op = f * AbstractOperations.Δy
                                        #= none:320 =#
                                        #= none:320 =# @test op[1, 1, 1] == 0
                                        #= none:321 =#
                                        op = f * AbstractOperations.Δz
                                        #= none:321 =#
                                        #= none:321 =# @test op[1, 1, 1] == 0
                                        #= none:322 =#
                                        op = f * AbstractOperations.Ax
                                        #= none:322 =#
                                        #= none:322 =# @test op[1, 1, 1] == 0
                                        #= none:323 =#
                                        op = f * AbstractOperations.Ay
                                        #= none:323 =#
                                        #= none:323 =# @test op[1, 1, 1] == 0
                                        #= none:324 =#
                                        op = f * AbstractOperations.Az
                                        #= none:324 =#
                                        #= none:324 =# @test op[1, 1, 1] == 0
                                        #= none:325 =#
                                        op = f * AbstractOperations.volume
                                        #= none:325 =#
                                        #= none:325 =# @test op[1, 1, 1] == 0
                                    end
                                #= none:327 =#
                            end
                            #= none:328 =#
                        end
                        #= none:329 =#
                    end
                end
            #= none:332 =#
            #= none:332 =# @testset "Indexing of AbstractOperations [$(typeof(arch))]" begin
                    #= none:334 =#
                    grid = RectilinearGrid(arch, size = (3, 3, 3), extent = (1, 1, 1))
                    #= none:336 =#
                    test_indices = [(2:3, :, :), (:, 2:3, :), (:, :, 2:3)]
                    #= none:337 =#
                    face_indices = [(2:2, :, :), (:, 2:2, :), (:, :, 2:2)]
                    #= none:338 =#
                    center_indices = [(3:3, :, :), (:, 3:3, :), (:, :, 3:3)]
                    #= none:340 =#
                    FaceFields = (XFaceField, YFaceField, ZFaceField)
                    #= none:342 =#
                    for (ti, fi, ci, FaceField) = zip(test_indices, face_indices, center_indices, FaceFields)
                        #= none:343 =#
                        a = CenterField(grid)
                        #= none:344 =#
                        b = CenterField(grid, indices = ti)
                        #= none:345 =#
                        #= none:345 =# @test indices(a * b) == ti
                        #= none:346 =#
                        #= none:346 =# @test indices(sin(b)) == ti
                        #= none:348 =#
                        c = CenterField(grid, indices = ti)
                        #= none:349 =#
                        d = FaceField(grid, indices = ti)
                        #= none:350 =#
                        #= none:350 =# @test indices(c * d) == fi
                        #= none:351 =#
                        #= none:351 =# @test indices(d * c) == ci
                        #= none:352 =#
                    end
                    #= none:354 =#
                    a = CenterField(grid, indices = test_indices[1])
                    #= none:355 =#
                    b = XFaceField(grid, indices = test_indices[2])
                    #= none:356 =#
                    c = YFaceField(grid, indices = test_indices[3])
                    #= none:358 =#
                    d = Field((Face, Face, Center), grid, indices = (:, 2:3, 1:2))
                    #= none:360 =#
                    #= none:360 =# @test indices(a * b * c) == (2:3, 2:3, 2:3)
                    #= none:361 =#
                    #= none:361 =# @test indices(b * a * c) == (3:3, 2:3, 2:3)
                    #= none:362 =#
                    #= none:362 =# @test indices(c * a * b) == (2:3, 3:3, 2:3)
                    #= none:363 =#
                    #= none:363 =# @test indices(a * b * c * d) == (2:3, 2:2, 2:2)
                    #= none:364 =#
                    #= none:364 =# @test indices(b * c * d * a) == (3:3, 2:2, 2:2)
                    #= none:365 =#
                    #= none:365 =# @test indices(c * d * a * b) == (2:3, 3:3, 2:2)
                    #= none:366 =#
                    #= none:366 =# @test indices(d * a * b * c) == (3:3, 3:3, 2:2)
                end
        end
    #= none:369 =#
end