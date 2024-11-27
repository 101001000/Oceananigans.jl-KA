
#= none:1 =#
include("dependencies_for_runtests.jl")
#= none:3 =#
using Oceananigans.BoundaryConditions: PBC, ZFBC, OBC, ContinuousBoundaryFunction, DiscreteBoundaryFunction, regularize_field_boundary_conditions
#= none:4 =#
using Oceananigans.Fields: Face, Center
#= none:6 =#
simple_bc(ξ, η, t) = begin
        #= none:6 =#
        exp(ξ) * cos(η) * sin(t)
    end
#= none:8 =#
function can_instantiate_boundary_condition(bc, C, FT = Float64, ArrayType = Array)
    #= none:8 =#
    #= none:9 =#
    success = try
            #= none:10 =#
            bc(C, FT, ArrayType)
            #= none:11 =#
            true
        catch
            #= none:13 =#
            false
        end
    #= none:15 =#
    return success
end
#= none:18 =#
#= none:18 =# @testset "Boundary conditions" begin
        #= none:19 =#
        #= none:19 =# @info "Testing boundary conditions..."
        #= none:21 =#
        #= none:21 =# @testset "Boundary condition instantiation" begin
                #= none:22 =#
                #= none:22 =# @info "  Testing boundary condition instantiation..."
                #= none:24 =#
                for C = (Value, Gradient, Flux, Value(), Gradient(), Flux())
                    #= none:25 =#
                    #= none:25 =# @test can_instantiate_boundary_condition(integer_bc, C)
                    #= none:26 =#
                    #= none:26 =# @test can_instantiate_boundary_condition(irrational_bc, C)
                    #= none:27 =#
                    #= none:27 =# @test can_instantiate_boundary_condition(simple_function_bc, C)
                    #= none:28 =#
                    #= none:28 =# @test can_instantiate_boundary_condition(parameterized_function_bc, C)
                    #= none:29 =#
                    #= none:29 =# @test can_instantiate_boundary_condition(field_dependent_function_bc, C)
                    #= none:30 =#
                    #= none:30 =# @test can_instantiate_boundary_condition(discrete_function_bc, C)
                    #= none:31 =#
                    #= none:31 =# @test can_instantiate_boundary_condition(parameterized_discrete_function_bc, C)
                    #= none:33 =#
                    for FT = float_types
                        #= none:34 =#
                        #= none:34 =# @test can_instantiate_boundary_condition(float_bc, C, FT)
                        #= none:35 =#
                        #= none:35 =# @test can_instantiate_boundary_condition(parameterized_field_dependent_function_bc, C, FT)
                        #= none:37 =#
                        for arch = archs
                            #= none:38 =#
                            ArrayType = array_type(arch)
                            #= none:39 =#
                            #= none:39 =# @test can_instantiate_boundary_condition(array_bc, C, FT, ArrayType)
                            #= none:40 =#
                        end
                        #= none:41 =#
                    end
                    #= none:42 =#
                end
            end
        #= none:45 =#
        #= none:45 =# @testset "Field and coordinate boundary conditions" begin
                #= none:46 =#
                #= none:46 =# @info "  Testing field and coordinate boundary conditions..."
                #= none:49 =#
                ppp_topology = (Periodic, Periodic, Periodic)
                #= none:50 =#
                ppp_grid = RectilinearGrid(size = (1, 1, 1), extent = (1, 1, 1), topology = ppp_topology)
                #= none:52 =#
                default_bcs = FieldBoundaryConditions()
                #= none:54 =#
                u_bcs = regularize_field_boundary_conditions(default_bcs, ppp_grid, :u)
                #= none:55 =#
                v_bcs = regularize_field_boundary_conditions(default_bcs, ppp_grid, :v)
                #= none:56 =#
                w_bcs = regularize_field_boundary_conditions(default_bcs, ppp_grid, :w)
                #= none:57 =#
                T_bcs = regularize_field_boundary_conditions(default_bcs, ppp_grid, :T)
                #= none:59 =#
                #= none:59 =# @test u_bcs isa FieldBoundaryConditions
                #= none:60 =#
                #= none:60 =# @test u_bcs.west isa PBC
                #= none:61 =#
                #= none:61 =# @test u_bcs.east isa PBC
                #= none:62 =#
                #= none:62 =# @test u_bcs.south isa PBC
                #= none:63 =#
                #= none:63 =# @test u_bcs.north isa PBC
                #= none:64 =#
                #= none:64 =# @test u_bcs.bottom isa PBC
                #= none:65 =#
                #= none:65 =# @test u_bcs.top isa PBC
                #= none:67 =#
                #= none:67 =# @test v_bcs isa FieldBoundaryConditions
                #= none:68 =#
                #= none:68 =# @test v_bcs.west isa PBC
                #= none:69 =#
                #= none:69 =# @test v_bcs.east isa PBC
                #= none:70 =#
                #= none:70 =# @test v_bcs.south isa PBC
                #= none:71 =#
                #= none:71 =# @test v_bcs.north isa PBC
                #= none:72 =#
                #= none:72 =# @test v_bcs.bottom isa PBC
                #= none:73 =#
                #= none:73 =# @test v_bcs.top isa PBC
                #= none:75 =#
                #= none:75 =# @test w_bcs isa FieldBoundaryConditions
                #= none:76 =#
                #= none:76 =# @test w_bcs.west isa PBC
                #= none:77 =#
                #= none:77 =# @test w_bcs.east isa PBC
                #= none:78 =#
                #= none:78 =# @test w_bcs.south isa PBC
                #= none:79 =#
                #= none:79 =# @test w_bcs.north isa PBC
                #= none:80 =#
                #= none:80 =# @test w_bcs.bottom isa PBC
                #= none:81 =#
                #= none:81 =# @test w_bcs.top isa PBC
                #= none:83 =#
                #= none:83 =# @test T_bcs isa FieldBoundaryConditions
                #= none:84 =#
                #= none:84 =# @test T_bcs.west isa PBC
                #= none:85 =#
                #= none:85 =# @test T_bcs.east isa PBC
                #= none:86 =#
                #= none:86 =# @test T_bcs.south isa PBC
                #= none:87 =#
                #= none:87 =# @test T_bcs.north isa PBC
                #= none:88 =#
                #= none:88 =# @test T_bcs.bottom isa PBC
                #= none:89 =#
                #= none:89 =# @test T_bcs.top isa PBC
                #= none:92 =#
                ppb_topology = (Periodic, Periodic, Bounded)
                #= none:93 =#
                ppb_grid = RectilinearGrid(size = (1, 1, 1), extent = (1, 1, 1), topology = ppb_topology)
                #= none:95 =#
                u_bcs = regularize_field_boundary_conditions(default_bcs, ppb_grid, :u)
                #= none:96 =#
                v_bcs = regularize_field_boundary_conditions(default_bcs, ppb_grid, :v)
                #= none:97 =#
                w_bcs = regularize_field_boundary_conditions(default_bcs, ppb_grid, :w)
                #= none:98 =#
                T_bcs = regularize_field_boundary_conditions(default_bcs, ppb_grid, :T)
                #= none:100 =#
                #= none:100 =# @test u_bcs isa FieldBoundaryConditions
                #= none:101 =#
                #= none:101 =# @test u_bcs.west isa PBC
                #= none:102 =#
                #= none:102 =# @test u_bcs.east isa PBC
                #= none:103 =#
                #= none:103 =# @test u_bcs.south isa PBC
                #= none:104 =#
                #= none:104 =# @test u_bcs.north isa PBC
                #= none:105 =#
                #= none:105 =# @test u_bcs.bottom isa ZFBC
                #= none:106 =#
                #= none:106 =# @test u_bcs.top isa ZFBC
                #= none:108 =#
                #= none:108 =# @test v_bcs isa FieldBoundaryConditions
                #= none:109 =#
                #= none:109 =# @test v_bcs.west isa PBC
                #= none:110 =#
                #= none:110 =# @test v_bcs.east isa PBC
                #= none:111 =#
                #= none:111 =# @test v_bcs.south isa PBC
                #= none:112 =#
                #= none:112 =# @test v_bcs.north isa PBC
                #= none:113 =#
                #= none:113 =# @test v_bcs.bottom isa ZFBC
                #= none:114 =#
                #= none:114 =# @test v_bcs.top isa ZFBC
                #= none:116 =#
                #= none:116 =# @test w_bcs isa FieldBoundaryConditions
                #= none:117 =#
                #= none:117 =# @test w_bcs.west isa PBC
                #= none:118 =#
                #= none:118 =# @test w_bcs.east isa PBC
                #= none:119 =#
                #= none:119 =# @test w_bcs.south isa PBC
                #= none:120 =#
                #= none:120 =# @test w_bcs.north isa PBC
                #= none:121 =#
                #= none:121 =# @test w_bcs.bottom isa OBC
                #= none:122 =#
                #= none:122 =# @test w_bcs.top isa OBC
                #= none:124 =#
                #= none:124 =# @test T_bcs isa FieldBoundaryConditions
                #= none:125 =#
                #= none:125 =# @test T_bcs.west isa PBC
                #= none:126 =#
                #= none:126 =# @test T_bcs.east isa PBC
                #= none:127 =#
                #= none:127 =# @test T_bcs.south isa PBC
                #= none:128 =#
                #= none:128 =# @test T_bcs.north isa PBC
                #= none:129 =#
                #= none:129 =# @test T_bcs.bottom isa ZFBC
                #= none:130 =#
                #= none:130 =# @test T_bcs.top isa ZFBC
                #= none:133 =#
                pbb_topology = (Periodic, Bounded, Bounded)
                #= none:134 =#
                pbb_grid = RectilinearGrid(size = (1, 1, 1), extent = (1, 1, 1), topology = pbb_topology)
                #= none:136 =#
                u_bcs = regularize_field_boundary_conditions(default_bcs, pbb_grid, :u)
                #= none:137 =#
                v_bcs = regularize_field_boundary_conditions(default_bcs, pbb_grid, :v)
                #= none:138 =#
                w_bcs = regularize_field_boundary_conditions(default_bcs, pbb_grid, :w)
                #= none:139 =#
                T_bcs = regularize_field_boundary_conditions(default_bcs, pbb_grid, :T)
                #= none:141 =#
                #= none:141 =# @test u_bcs isa FieldBoundaryConditions
                #= none:142 =#
                #= none:142 =# @test u_bcs.west isa PBC
                #= none:143 =#
                #= none:143 =# @test u_bcs.east isa PBC
                #= none:144 =#
                #= none:144 =# @test u_bcs.south isa ZFBC
                #= none:145 =#
                #= none:145 =# @test u_bcs.north isa ZFBC
                #= none:146 =#
                #= none:146 =# @test u_bcs.bottom isa ZFBC
                #= none:147 =#
                #= none:147 =# @test u_bcs.top isa ZFBC
                #= none:149 =#
                #= none:149 =# @test v_bcs isa FieldBoundaryConditions
                #= none:150 =#
                #= none:150 =# @test v_bcs.west isa PBC
                #= none:151 =#
                #= none:151 =# @test v_bcs.east isa PBC
                #= none:152 =#
                #= none:152 =# @test v_bcs.south isa OBC
                #= none:153 =#
                #= none:153 =# @test v_bcs.north isa OBC
                #= none:154 =#
                #= none:154 =# @test v_bcs.bottom isa ZFBC
                #= none:155 =#
                #= none:155 =# @test v_bcs.top isa ZFBC
                #= none:157 =#
                #= none:157 =# @test w_bcs isa FieldBoundaryConditions
                #= none:158 =#
                #= none:158 =# @test w_bcs.west isa PBC
                #= none:159 =#
                #= none:159 =# @test w_bcs.east isa PBC
                #= none:160 =#
                #= none:160 =# @test w_bcs.south isa ZFBC
                #= none:161 =#
                #= none:161 =# @test w_bcs.north isa ZFBC
                #= none:162 =#
                #= none:162 =# @test w_bcs.bottom isa OBC
                #= none:163 =#
                #= none:163 =# @test w_bcs.top isa OBC
                #= none:165 =#
                #= none:165 =# @test T_bcs isa FieldBoundaryConditions
                #= none:166 =#
                #= none:166 =# @test T_bcs.west isa PBC
                #= none:167 =#
                #= none:167 =# @test T_bcs.east isa PBC
                #= none:168 =#
                #= none:168 =# @test T_bcs.south isa ZFBC
                #= none:169 =#
                #= none:169 =# @test T_bcs.north isa ZFBC
                #= none:170 =#
                #= none:170 =# @test T_bcs.bottom isa ZFBC
                #= none:171 =#
                #= none:171 =# @test T_bcs.top isa ZFBC
                #= none:174 =#
                bbb_topology = (Bounded, Bounded, Bounded)
                #= none:175 =#
                bbb_grid = RectilinearGrid(size = (1, 1, 1), extent = (1, 1, 1), topology = bbb_topology)
                #= none:177 =#
                u_bcs = regularize_field_boundary_conditions(default_bcs, bbb_grid, :u)
                #= none:178 =#
                v_bcs = regularize_field_boundary_conditions(default_bcs, bbb_grid, :v)
                #= none:179 =#
                w_bcs = regularize_field_boundary_conditions(default_bcs, bbb_grid, :w)
                #= none:180 =#
                T_bcs = regularize_field_boundary_conditions(default_bcs, bbb_grid, :T)
                #= none:182 =#
                #= none:182 =# @test u_bcs isa FieldBoundaryConditions
                #= none:183 =#
                #= none:183 =# @test u_bcs.west isa OBC
                #= none:184 =#
                #= none:184 =# @test u_bcs.east isa OBC
                #= none:185 =#
                #= none:185 =# @test u_bcs.south isa ZFBC
                #= none:186 =#
                #= none:186 =# @test u_bcs.north isa ZFBC
                #= none:187 =#
                #= none:187 =# @test u_bcs.bottom isa ZFBC
                #= none:188 =#
                #= none:188 =# @test u_bcs.top isa ZFBC
                #= none:190 =#
                #= none:190 =# @test v_bcs isa FieldBoundaryConditions
                #= none:191 =#
                #= none:191 =# @test v_bcs.west isa ZFBC
                #= none:192 =#
                #= none:192 =# @test v_bcs.east isa ZFBC
                #= none:193 =#
                #= none:193 =# @test v_bcs.south isa OBC
                #= none:194 =#
                #= none:194 =# @test v_bcs.north isa OBC
                #= none:195 =#
                #= none:195 =# @test v_bcs.bottom isa ZFBC
                #= none:196 =#
                #= none:196 =# @test v_bcs.top isa ZFBC
                #= none:198 =#
                #= none:198 =# @test w_bcs isa FieldBoundaryConditions
                #= none:199 =#
                #= none:199 =# @test w_bcs.west isa ZFBC
                #= none:200 =#
                #= none:200 =# @test w_bcs.east isa ZFBC
                #= none:201 =#
                #= none:201 =# @test w_bcs.south isa ZFBC
                #= none:202 =#
                #= none:202 =# @test w_bcs.north isa ZFBC
                #= none:203 =#
                #= none:203 =# @test w_bcs.bottom isa OBC
                #= none:204 =#
                #= none:204 =# @test w_bcs.top isa OBC
                #= none:206 =#
                #= none:206 =# @test T_bcs isa FieldBoundaryConditions
                #= none:207 =#
                #= none:207 =# @test T_bcs.west isa ZFBC
                #= none:208 =#
                #= none:208 =# @test T_bcs.east isa ZFBC
                #= none:209 =#
                #= none:209 =# @test T_bcs.south isa ZFBC
                #= none:210 =#
                #= none:210 =# @test T_bcs.north isa ZFBC
                #= none:211 =#
                #= none:211 =# @test T_bcs.bottom isa ZFBC
                #= none:212 =#
                #= none:212 =# @test T_bcs.top isa ZFBC
                #= none:214 =#
                grid = bbb_grid
                #= none:216 =#
                T_bcs = FieldBoundaryConditions(grid, (Center, Center, Center), east = ValueBoundaryCondition(simple_bc), west = ValueBoundaryCondition(simple_bc), bottom = ValueBoundaryCondition(simple_bc), top = ValueBoundaryCondition(simple_bc), north = ValueBoundaryCondition(simple_bc), south = ValueBoundaryCondition(simple_bc))
                #= none:224 =#
                #= none:224 =# @test T_bcs.east.condition isa ContinuousBoundaryFunction
                #= none:225 =#
                #= none:225 =# @test T_bcs.west.condition isa ContinuousBoundaryFunction
                #= none:226 =#
                #= none:226 =# @test T_bcs.north.condition isa ContinuousBoundaryFunction
                #= none:227 =#
                #= none:227 =# @test T_bcs.south.condition isa ContinuousBoundaryFunction
                #= none:228 =#
                #= none:228 =# @test T_bcs.top.condition isa ContinuousBoundaryFunction
                #= none:229 =#
                #= none:229 =# @test T_bcs.bottom.condition isa ContinuousBoundaryFunction
                #= none:231 =#
                #= none:231 =# @test T_bcs.east.condition.func === simple_bc
                #= none:232 =#
                #= none:232 =# @test T_bcs.west.condition.func === simple_bc
                #= none:233 =#
                #= none:233 =# @test T_bcs.north.condition.func === simple_bc
                #= none:234 =#
                #= none:234 =# @test T_bcs.south.condition.func === simple_bc
                #= none:235 =#
                #= none:235 =# @test T_bcs.top.condition.func === simple_bc
                #= none:236 =#
                #= none:236 =# @test T_bcs.bottom.condition.func === simple_bc
                #= none:238 =#
                one_bc = BoundaryCondition(Value(), 1.0)
                #= none:240 =#
                T_bcs = FieldBoundaryConditions(east = one_bc, west = one_bc, bottom = one_bc, top = one_bc, north = one_bc, south = one_bc)
                #= none:247 =#
                T_bcs = regularize_field_boundary_conditions(T_bcs, grid, :T)
                #= none:249 =#
                #= none:249 =# @test T_bcs.east === one_bc
                #= none:250 =#
                #= none:250 =# @test T_bcs.west === one_bc
                #= none:251 =#
                #= none:251 =# @test T_bcs.north === one_bc
                #= none:252 =#
                #= none:252 =# @test T_bcs.south === one_bc
                #= none:253 =#
                #= none:253 =# @test T_bcs.top === one_bc
                #= none:254 =#
                #= none:254 =# @test T_bcs.bottom === one_bc
            end
    end