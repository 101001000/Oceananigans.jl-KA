
#= none:14 =#
using Oceananigans.Grids: XYRegularRG, XZRegularRG, YZRegularRG, XYZRegularRG, regular_dimensions, stretched_dimensions
#= none:16 =#
function plan_forward_transform(A::Array, ::Periodic, dims, planner_flag = FFTW.PATIENT)
    #= none:16 =#
    #= none:17 =#
    length(dims) == 0 && return nothing
    #= none:18 =#
    return FFTW.plan_fft!(A, dims, flags = planner_flag)
end
#= none:21 =#
function plan_forward_transform(A::Array, ::Bounded, dims, planner_flag = FFTW.PATIENT)
    #= none:21 =#
    #= none:22 =#
    length(dims) == 0 && return nothing
    #= none:23 =#
    return FFTW.plan_r2r!(A, FFTW.REDFT10, dims, flags = planner_flag)
end
#= none:26 =#
function plan_backward_transform(A::Array, ::Periodic, dims, planner_flag = FFTW.PATIENT)
    #= none:26 =#
    #= none:27 =#
    length(dims) == 0 && return nothing
    #= none:28 =#
    return FFTW.plan_ifft!(A, dims, flags = planner_flag)
end
#= none:31 =#
function plan_backward_transform(A::Array, ::Bounded, dims, planner_flag = FFTW.PATIENT)
    #= none:31 =#
    #= none:32 =#
    length(dims) == 0 && return nothing
    #= none:33 =#
    return FFTW.plan_r2r!(A, FFTW.REDFT01, dims, flags = planner_flag)
end
#= none:36 =#
function plan_forward_transform(A::GPUArrays.AbstractGPUArray, ::Union{Bounded, Periodic}, dims, planner_flag)
    #= none:36 =#
    #= none:37 =#
    length(dims) == 0 && return nothing
    #= none:38 =#
    return CUDA.CUFFT.plan_fft!(A, dims)
end
#= none:41 =#
function plan_backward_transform(A::GPUArrays.AbstractGPUArray, ::Union{Bounded, Periodic}, dims, planner_flag)
    #= none:41 =#
    #= none:42 =#
    length(dims) == 0 && return nothing
    #= none:43 =#
    return CUDA.CUFFT.plan_ifft!(A, dims)
end
#= none:46 =#
plan_backward_transform(A::Union{Array, GPUArrays.AbstractGPUArray}, ::Flat, args...) = begin
        #= none:46 =#
        nothing
    end
#= none:47 =#
plan_forward_transform(A::Union{Array, GPUArrays.AbstractGPUArray}, ::Flat, args...) = begin
        #= none:47 =#
        nothing
    end
#= none:49 =#
batchable_GPU_topologies = ((Periodic, Periodic, Periodic), (Periodic, Periodic, Bounded), (Bounded, Periodic, Periodic))
#= none:65 =#
forward_orders(::Type{Periodic}, ::Type{Bounded}, ::Type{Bounded}) = begin
        #= none:65 =#
        (3, 2, 1)
    end
#= none:66 =#
forward_orders(::Type{Periodic}, ::Type{Bounded}, ::Type{Periodic}) = begin
        #= none:66 =#
        (2, 1, 3)
    end
#= none:67 =#
forward_orders(::Type{Bounded}, ::Type{Periodic}, ::Type{Bounded}) = begin
        #= none:67 =#
        (1, 3, 2)
    end
#= none:68 =#
forward_orders(::Type{Bounded}, ::Type{Bounded}, ::Type{Periodic}) = begin
        #= none:68 =#
        (1, 2, 3)
    end
#= none:69 =#
forward_orders(::Type{Bounded}, ::Type{Bounded}, ::Type{Bounded}) = begin
        #= none:69 =#
        (1, 2, 3)
    end
#= none:71 =#
backward_orders(::Type{Periodic}, ::Type{Bounded}, ::Type{Bounded}) = begin
        #= none:71 =#
        (1, 2, 3)
    end
#= none:72 =#
backward_orders(::Type{Periodic}, ::Type{Bounded}, ::Type{Periodic}) = begin
        #= none:72 =#
        (3, 1, 2)
    end
#= none:73 =#
backward_orders(::Type{Bounded}, ::Type{Periodic}, ::Type{Bounded}) = begin
        #= none:73 =#
        (2, 1, 3)
    end
#= none:74 =#
backward_orders(::Type{Bounded}, ::Type{Bounded}, ::Type{Periodic}) = begin
        #= none:74 =#
        (3, 1, 2)
    end
#= none:75 =#
backward_orders(::Type{Bounded}, ::Type{Bounded}, ::Type{Bounded}) = begin
        #= none:75 =#
        (1, 2, 3)
    end
#= none:77 =#
#= none:77 =# Core.@doc " Used by FFTBasedPoissonSolver " function plan_transforms(grid::XYZRegularRG, storage, planner_flag)
        #= none:78 =#
        #= none:79 =#
        (Nx, Ny, Nz) = size(grid)
        #= none:80 =#
        topo = topology(grid)
        #= none:81 =#
        periodic_dims = findall((t->begin
                        #= none:81 =#
                        t == Periodic
                    end), topo)
        #= none:82 =#
        bounded_dims = findall((t->begin
                        #= none:82 =#
                        t == Bounded
                    end), topo)
        #= none:86 =#
        unflattened_topo = Tuple((if T() isa Flat
                    Bounded
                else
                    T
                end for T = topo))
        #= none:88 =#
        arch = architecture(grid)
        #= none:90 =#
        if arch isa GPU && !(unflattened_topo in batchable_GPU_topologies)
            #= none:92 =#
            reshaped_storage = reshape(storage, (Ny, Nx, Nz))
            #= none:93 =#
            forward_plan_x = plan_forward_transform(storage, (topo[1])(), [1], planner_flag)
            #= none:94 =#
            forward_plan_y = plan_forward_transform(reshaped_storage, (topo[2])(), [1], planner_flag)
            #= none:95 =#
            forward_plan_z = plan_forward_transform(storage, (topo[3])(), [3], planner_flag)
            #= none:97 =#
            backward_plan_x = plan_backward_transform(storage, (topo[1])(), [1], planner_flag)
            #= none:98 =#
            backward_plan_y = plan_backward_transform(reshaped_storage, (topo[2])(), [1], planner_flag)
            #= none:99 =#
            backward_plan_z = plan_backward_transform(storage, (topo[3])(), [3], planner_flag)
            #= none:101 =#
            forward_plans = (forward_plan_x, forward_plan_y, forward_plan_z)
            #= none:102 =#
            backward_plans = (backward_plan_x, backward_plan_y, backward_plan_z)
            #= none:104 =#
            f_order = forward_orders(unflattened_topo...)
            #= none:105 =#
            b_order = backward_orders(unflattened_topo...)
            #= none:107 =#
            forward_transforms = (DiscreteTransform(forward_plans[f_order[1]], Forward(), grid, [f_order[1]]), DiscreteTransform(forward_plans[f_order[2]], Forward(), grid, [f_order[2]]), DiscreteTransform(forward_plans[f_order[3]], Forward(), grid, [f_order[3]]))
            #= none:113 =#
            backward_transforms = (DiscreteTransform(backward_plans[b_order[1]], Backward(), grid, [b_order[1]]), DiscreteTransform(backward_plans[b_order[2]], Backward(), grid, [b_order[2]]), DiscreteTransform(backward_plans[b_order[3]], Backward(), grid, [b_order[3]]))
        else
            #= none:126 =#
            forward_periodic_plan = plan_forward_transform(storage, Periodic(), periodic_dims, planner_flag)
            #= none:127 =#
            forward_bounded_plan = plan_forward_transform(storage, Bounded(), bounded_dims, planner_flag)
            #= none:129 =#
            forward_transforms = (DiscreteTransform(forward_bounded_plan, Forward(), grid, bounded_dims), DiscreteTransform(forward_periodic_plan, Forward(), grid, periodic_dims))
            #= none:134 =#
            backward_periodic_plan = plan_backward_transform(storage, Periodic(), periodic_dims, planner_flag)
            #= none:135 =#
            backward_bounded_plan = plan_backward_transform(storage, Bounded(), bounded_dims, planner_flag)
            #= none:137 =#
            backward_transforms = (DiscreteTransform(backward_periodic_plan, Backward(), grid, periodic_dims), DiscreteTransform(backward_bounded_plan, Backward(), grid, bounded_dims))
        end
        #= none:143 =#
        transforms = (forward = forward_transforms, backward = backward_transforms)
        #= none:145 =#
        return transforms
    end
#= none:148 =#
#= none:148 =# Core.@doc " Used by FourierTridiagonalPoissonSolver. " function plan_transforms(grid::Union{XYRegularRG, XZRegularRG, YZRegularRG}, storage, planner_flag)
        #= none:149 =#
        #= none:150 =#
        (Nx, Ny, Nz) = size(grid)
        #= none:151 =#
        topo = topology(grid)
        #= none:153 =#
        irreg_dim = (stretched_dimensions(grid))[1]
        #= none:154 =#
        reg_dims = regular_dimensions(grid)
        #= none:155 =#
        !(topo[irreg_dim] === Bounded) && error("Transforms can be planned only when the stretched direction's topology is `Bounded`.")
        #= none:157 =#
        periodic_dims = Tuple((dim for dim = findall((t->begin
                                    #= none:157 =#
                                    t == Periodic
                                end), topo) if dim ≠ irreg_dim))
        #= none:158 =#
        bounded_dims = Tuple((dim for dim = findall((t->begin
                                    #= none:158 =#
                                    t == Bounded
                                end), topo) if dim ≠ irreg_dim))
        #= none:160 =#
        arch = architecture(grid)
        #= none:162 =#
        if arch isa CPU
            #= none:169 =#
            forward_periodic_plan = plan_forward_transform(storage, Periodic(), periodic_dims, planner_flag)
            #= none:170 =#
            forward_bounded_plan = plan_forward_transform(storage, Bounded(), bounded_dims, planner_flag)
            #= none:172 =#
            forward_transforms = (DiscreteTransform(forward_bounded_plan, Forward(), grid, bounded_dims), DiscreteTransform(forward_periodic_plan, Forward(), grid, periodic_dims))
            #= none:175 =#
            backward_periodic_plan = plan_backward_transform(storage, Periodic(), periodic_dims, planner_flag)
            #= none:176 =#
            backward_bounded_plan = plan_backward_transform(storage, Bounded(), bounded_dims, planner_flag)
            #= none:178 =#
            backward_transforms = (DiscreteTransform(backward_periodic_plan, Backward(), grid, periodic_dims), DiscreteTransform(backward_bounded_plan, Backward(), grid, bounded_dims))
        elseif #= none:181 =# bounded_dims == ()
            #= none:186 =#
            forward_periodic_plan = plan_forward_transform(storage, Periodic(), reg_dims, planner_flag)
            #= none:187 =#
            backward_periodic_plan = plan_backward_transform(storage, Periodic(), reg_dims, planner_flag)
            #= none:189 =#
            forward_transforms = tuple(DiscreteTransform(forward_periodic_plan, Forward(), grid, reg_dims))
            #= none:190 =#
            backward_transforms = tuple(DiscreteTransform(backward_periodic_plan, Backward(), grid, reg_dims))
        else
            #= none:193 =#
            (Nx, Ny, Nz) = size(grid)
            #= none:194 =#
            reshaped_storage = reshape(storage, (Ny, Nx, Nz))
            #= none:196 =#
            if irreg_dim == 1
                #= none:197 =#
                forward_plan_1 = plan_forward_transform(reshaped_storage, (topo[2])(), [1], planner_flag)
                #= none:198 =#
                forward_plan_2 = plan_forward_transform(storage, (topo[3])(), [3], planner_flag)
                #= none:200 =#
                backward_plan_1 = plan_backward_transform(reshaped_storage, (topo[2])(), [1], planner_flag)
                #= none:201 =#
                backward_plan_2 = plan_backward_transform(storage, (topo[3])(), [3], planner_flag)
            elseif #= none:203 =# irreg_dim == 2
                #= none:204 =#
                forward_plan_1 = plan_forward_transform(storage, (topo[1])(), [1], planner_flag)
                #= none:205 =#
                forward_plan_2 = plan_forward_transform(storage, (topo[3])(), [3], planner_flag)
                #= none:207 =#
                backward_plan_1 = plan_backward_transform(storage, (topo[1])(), [1], planner_flag)
                #= none:208 =#
                backward_plan_2 = plan_backward_transform(storage, (topo[3])(), [3], planner_flag)
            elseif #= none:210 =# irreg_dim == 3
                #= none:211 =#
                forward_plan_1 = plan_forward_transform(storage, (topo[1])(), [1], planner_flag)
                #= none:212 =#
                forward_plan_2 = plan_forward_transform(reshaped_storage, (topo[2])(), [1], planner_flag)
                #= none:214 =#
                backward_plan_1 = plan_backward_transform(storage, (topo[1])(), [1], planner_flag)
                #= none:215 =#
                backward_plan_2 = plan_backward_transform(reshaped_storage, (topo[2])(), [1], planner_flag)
            end
            #= none:218 =#
            forward_plans = Dict(reg_dims[1] => forward_plan_1, reg_dims[2] => forward_plan_2)
            #= none:219 =#
            backward_plans = Dict(reg_dims[1] => backward_plan_1, reg_dims[2] => backward_plan_2)
            #= none:222 =#
            unflattened_topo = Tuple((if T() isa Flat
                        Bounded
                    else
                        T
                    end for T = topo))
            #= none:223 =#
            f_order = forward_orders(unflattened_topo...)
            #= none:224 =#
            b_order = backward_orders(unflattened_topo...)
            #= none:227 =#
            f_order = Tuple((f_order[i] for i = findall((d->begin
                                        #= none:227 =#
                                        d != irreg_dim
                                    end), f_order)))
            #= none:228 =#
            b_order = Tuple((b_order[i] for i = findall((d->begin
                                        #= none:228 =#
                                        d != irreg_dim
                                    end), b_order)))
            #= none:230 =#
            forward_transforms = (DiscreteTransform(forward_plans[f_order[1]], Forward(), grid, [f_order[1]]), DiscreteTransform(forward_plans[f_order[2]], Forward(), grid, [f_order[2]]))
            #= none:233 =#
            backward_transforms = (DiscreteTransform(backward_plans[b_order[1]], Backward(), grid, [b_order[1]]), DiscreteTransform(backward_plans[b_order[2]], Backward(), grid, [b_order[2]]))
        end
        #= none:237 =#
        transforms = (forward = forward_transforms, backward = backward_transforms)
        #= none:239 =#
        return transforms
    end