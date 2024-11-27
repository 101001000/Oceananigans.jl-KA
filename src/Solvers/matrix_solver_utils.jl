
#= none:1 =#
using Oceananigans.Architectures
#= none:2 =#
using Oceananigans.Architectures: device
#= none:3 =#
import Oceananigans.Architectures: architecture, unified_array
#= none:4 =#
begin
    using CUDA, CUDA.CUSPARSE, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:5 =#
using KernelAbstractions: @kernel, @index
#= none:7 =#
using LinearAlgebra, SparseArrays, IncompleteLU
#= none:8 =#
using SparseArrays: fkeep!
#= none:12 =#
#= none:12 =# @inline constructors(::CPU, A::SparseMatrixCSC) = begin
            #= none:12 =#
            (A.m, A.n, A.colptr, A.rowval, A.nzval)
        end
#= none:13 =#
#= none:13 =# @inline constructors(::GPU, A::SparseMatrixCSC) = begin
            #= none:13 =#
            (KAUtils.ArrayConstructor(KAUtils.get_backend(), A.colptr), KAUtils.ArrayConstructor(KAUtils.get_backend(), A.rowval), KAUtils.ArrayConstructor(KAUtils.get_backend(), A.nzval), (A.m, A.n))
        end
#= none:14 =#
#= none:14 =# @inline constructors(::CPU, A::CuSparseMatrixCSC) = begin
            #= none:14 =#
            (A.dims[1], A.dims[2], Int64.(Array(A.colPtr)), Int64.(Array(A.rowVal)), Array(A.nzVal))
        end
#= none:15 =#
#= none:15 =# @inline constructors(::GPU, A::CuSparseMatrixCSC) = begin
            #= none:15 =#
            (A.colPtr, A.rowVal, A.nzVal, A.dims)
        end
#= none:16 =#
#= none:16 =# @inline constructors(::CPU, m::Number, n::Number, constr::Tuple) = begin
            #= none:16 =#
            (m, n, constr...)
        end
#= none:17 =#
#= none:17 =# @inline constructors(::GPU, m::Number, n::Number, constr::Tuple) = begin
            #= none:17 =#
            (constr..., (m, n))
        end
#= none:19 =#
#= none:19 =# @inline unpack_constructors(::CPU, constr::Tuple) = begin
            #= none:19 =#
            (constr[3], constr[4], constr[5])
        end
#= none:20 =#
#= none:20 =# @inline unpack_constructors(::GPU, constr::Tuple) = begin
            #= none:20 =#
            (constr[1], constr[2], constr[3])
        end
#= none:21 =#
#= none:21 =# @inline copy_unpack_constructors(::CPU, constr::Tuple) = begin
            #= none:21 =#
            deepcopy((constr[3], constr[4], constr[5]))
        end
#= none:22 =#
#= none:22 =# @inline copy_unpack_constructors(::GPU, constr::Tuple) = begin
            #= none:22 =#
            deepcopy((constr[1], constr[2], constr[3]))
        end
#= none:24 =#
#= none:24 =# @inline arch_sparse_matrix(::CPU, constr::Tuple) = begin
            #= none:24 =#
            SparseMatrixCSC(constr...)
        end
#= none:25 =#
#= none:25 =# @inline arch_sparse_matrix(::GPU, constr::Tuple) = begin
            #= none:25 =#
            CuSparseMatrixCSC(constr...)
        end
#= none:26 =#
#= none:26 =# @inline arch_sparse_matrix(::CPU, A::CuSparseMatrixCSC) = begin
            #= none:26 =#
            SparseMatrixCSC(constructors(CPU(), A)...)
        end
#= none:27 =#
#= none:27 =# @inline arch_sparse_matrix(::GPU, A::SparseMatrixCSC) = begin
            #= none:27 =#
            CuSparseMatrixCSC(constructors(GPU(), A)...)
        end
#= none:29 =#
#= none:29 =# @inline arch_sparse_matrix(::CPU, A::SparseMatrixCSC) = begin
            #= none:29 =#
            A
        end
#= none:30 =#
#= none:30 =# @inline arch_sparse_matrix(::GPU, A::CuSparseMatrixCSC) = begin
            #= none:30 =#
            A
        end
#= none:33 =#
function update_diag!(constr, arch, M, N, diag, Δt, disp)
    #= none:33 =#
    #= none:34 =#
    (colptr, rowval, nzval) = unpack_constructors(arch, constr)
    #= none:35 =#
    loop! = _update_diag!(device(arch), min(256, M), M)
    #= none:36 =#
    loop!(nzval, colptr, rowval, diag, Δt, disp)
    #= none:38 =#
    constr = constructors(arch, M, N, (colptr, rowval, nzval))
end
#= none:41 =#
#= none:41 =# @kernel function _update_diag!(nzval, colptr, rowval, diag, Δt, disp)
        #= none:41 =#
        #= none:42 =#
        col = #= none:42 =# @index(Global, Linear)
        #= none:43 =#
        col = col + disp
        #= none:44 =#
        map = 1
        #= none:45 =#
        for idx = colptr[col]:colptr[col + 1] - 1
            #= none:46 =#
            if rowval[idx] + disp == col
                #= none:47 =#
                map = idx
                #= none:48 =#
                break
            end
            #= none:50 =#
        end
        #= none:51 =#
        nzval[map] += diag[col - disp] / Δt ^ 2
    end
#= none:54 =#
#= none:54 =# @kernel function _get_inv_diag!(invdiag, colptr, rowval, nzval)
        #= none:54 =#
        #= none:55 =#
        col = #= none:55 =# @index(Global, Linear)
        #= none:56 =#
        map = 1
        #= none:57 =#
        for idx = colptr[col]:colptr[col + 1] - 1
            #= none:58 =#
            if rowval[idx] == col
                #= none:59 =#
                map = idx
                #= none:60 =#
                break
            end
            #= none:62 =#
        end
        #= none:63 =#
        if nzval[map] == 0
            #= none:64 =#
            invdiag[col] = 0
        else
            #= none:66 =#
            invdiag[col] = 1 / nzval[map]
        end
    end
#= none:70 =#
#= none:70 =# @kernel function _get_diag!(diag, colptr, rowval, nzval)
        #= none:70 =#
        #= none:71 =#
        col = #= none:71 =# @index(Global, Linear)
        #= none:72 =#
        map = 1
        #= none:73 =#
        for idx = colptr[col]:colptr[col + 1] - 1
            #= none:74 =#
            if rowval[idx] == col
                #= none:75 =#
                map = idx
                #= none:76 =#
                break
            end
            #= none:78 =#
        end
        #= none:79 =#
        diag[col] = nzval[map]
    end
#= none:83 =#
#= none:83 =# @inline map_row_to_diag_element(i, rowval, colptr) = begin
            #= none:83 =#
            (colptr[i] - 1) + findfirst(rowval[colptr[i]:colptr[i + 1] - 1] .== i)
        end
#= none:85 =#
#= none:85 =# @inline function validate_laplacian_direction(N, topo, reduced_dim)
        #= none:85 =#
        #= none:86 =#
        dim = N > 1 && reduced_dim == false
        #= none:87 =#
        if N < 3 && (topo == Bounded && dim == true)
            #= none:88 =#
            throw(ArgumentError("Cannot calculate Laplacian in bounded domain with N < 3!"))
        end
        #= none:91 =#
        return dim
    end
#= none:94 =#
#= none:94 =# @inline validate_laplacian_size(N, dim) = begin
            #= none:94 =#
            if dim == true
                N
            else
                1
            end
        end
#= none:96 =#
#= none:96 =# @inline ensure_diagonal_elements_are_present!(A) = begin
            #= none:96 =#
            fkeep!(((i, j, x)->begin
                        #= none:96 =#
                        i == j || !(iszero(x))
                    end), A)
        end
#= none:98 =#
#= none:98 =# Core.@doc "    compute_matrix_for_linear_operation(arch, template_field, linear_operation!, args...;\n                                        boundary_conditions_input=nothing,\n                                        boundary_conditions_output=nothing)\n\nReturn the sparse matrix that corresponds to the `linear_operation!`. The `linear_operation!`\nis expected to have the argument structure:\n\n```julia\nlinear_operation!(output, input, args...)\n```\n\nKeyword arguments `boundary_conditions_input` and `boundary_conditions_output` determine the\nboundary conditions that the `input` and `output` fields are expected to have. If `nothing`\nis provided, then the `input` and `output` fields inherit the default boundary conditions\naccording to the `template_field`.\n\nFor `architecture = CPU()` the matrix returned is a `SparseArrays.SparseMatrixCSC`; for `GPU()`\nis a `CUDA.CuSparseMatrixCSC`.\n" function compute_matrix_for_linear_operation(::CPU, template_field, linear_operation!, args...; boundary_conditions_input = nothing, boundary_conditions_output = nothing)
        #= none:118 =#
        #= none:122 =#
        loc = location(template_field)
        #= none:123 =#
        (Nx, Ny, Nz) = size(template_field)
        #= none:124 =#
        grid = template_field.grid
        #= none:127 =#
        A = spzeros(eltype(grid), Nx * Ny * Nz, Nx * Ny * Nz)
        #= none:129 =#
        if boundary_conditions_input === nothing
            #= none:130 =#
            boundary_conditions_input = FieldBoundaryConditions(grid, loc, template_field.indices)
        end
        #= none:133 =#
        if boundary_conditions_output === nothing
            #= none:134 =#
            boundary_conditions_output = FieldBoundaryConditions(grid, loc, template_field.indices)
        end
        #= none:138 =#
        eᵢⱼₖ = Field(loc, grid; boundary_conditions = boundary_conditions_input)
        #= none:139 =#
        Aeᵢⱼₖ = Field(loc, grid; boundary_conditions = boundary_conditions_output)
        #= none:141 =#
        for k = 1:Nz, j = 1:Ny, i = 1:Nx
            #= none:142 =#
            parent(eᵢⱼₖ) .= 0
            #= none:143 =#
            parent(Aeᵢⱼₖ) .= 0
            #= none:145 =#
            eᵢⱼₖ[i, j, k] = 1
            #= none:147 =#
            fill_halo_regions!(eᵢⱼₖ)
            #= none:149 =#
            linear_operation!(Aeᵢⱼₖ, eᵢⱼₖ, args...)
            #= none:151 =#
            A[:, Ny * Nx * (k - 1) + Nx * (j - 1) + i] .= vec(Aeᵢⱼₖ)
            #= none:152 =#
        end
        #= none:154 =#
        return A
    end
#= none:157 =#
function compute_matrix_for_linear_operation(::GPU, template_field, linear_operation!, args...; boundary_conditions_input = nothing, boundary_conditions_output = nothing)
    #= none:157 =#
    #= none:161 =#
    loc = location(template_field)
    #= none:162 =#
    (Nx, Ny, Nz) = size(template_field)
    #= none:163 =#
    grid = template_field.grid
    #= none:165 =#
    if boundary_conditions_input === nothing
        #= none:166 =#
        boundary_conditions_input = FieldBoundaryConditions(grid, loc, template_field.indices)
    end
    #= none:169 =#
    if boundary_conditions_output === nothing
        #= none:170 =#
        boundary_conditions_output = FieldBoundaryConditions(grid, loc, template_field.indices)
    end
    #= none:174 =#
    eᵢⱼₖ = Field(loc, grid; boundary_conditions = boundary_conditions_input)
    #= none:175 =#
    Aeᵢⱼₖ = Field(loc, grid; boundary_conditions = boundary_conditions_output)
    #= none:177 =#
    colptr = KAUtils.ArrayConstructor(KAUtils.get_backend(), Int, undef, Nx * Ny * Nz + 1)
    #= none:178 =#
    rowval = KAUtils.ArrayConstructor(KAUtils.get_backend(), Int, undef, 0)
    #= none:179 =#
    nzval = KAUtils.ArrayConstructor(KAUtils.get_backend(), eltype(grid), undef, 0)
    #= none:181 =#
    #= none:181 =# CUDA.@allowscalar colptr[1] = 1
    #= none:183 =#
    for k = 1:Nz, j = 1:Ny, i = 1:Nx
        #= none:184 =#
        parent(eᵢⱼₖ) .= 0
        #= none:185 =#
        parent(Aeᵢⱼₖ) .= 0
        #= none:187 =#
        #= none:187 =# CUDA.@allowscalar eᵢⱼₖ[i, j, k] = 1
        #= none:189 =#
        fill_halo_regions!(eᵢⱼₖ)
        #= none:191 =#
        linear_operation!(Aeᵢⱼₖ, eᵢⱼₖ, args...)
        #= none:193 =#
        count = 0
        #= none:194 =#
        for n = 1:Nz, m = 1:Ny, l = 1:Nx
            #= none:195 =#
            Aeᵢⱼₖₗₘₙ = #= none:195 =# CUDA.@allowscalar(Aeᵢⱼₖ[l, m, n])
            #= none:196 =#
            if Aeᵢⱼₖₗₘₙ != 0
                #= none:197 =#
                append!(rowval, Ny * Nx * (n - 1) + Nx * (m - 1) + l)
                #= none:198 =#
                append!(nzval, Aeᵢⱼₖₗₘₙ)
                #= none:199 =#
                count += 1
            end
            #= none:201 =#
        end
        #= none:203 =#
        #= none:203 =# CUDA.@allowscalar colptr[Ny * Nx * (k - 1) + Nx * (j - 1) + i + 1] = colptr[Ny * Nx * (k - 1) + Nx * (j - 1) + i] + count
        #= none:204 =#
    end
    #= none:206 =#
    return CuSparseMatrixCSC(colptr, rowval, nzval, (Nx * Ny * Nz, Nx * Ny * Nz))
end