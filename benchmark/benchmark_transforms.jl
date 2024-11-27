
#= none:1 =#
push!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using Printf
#= none:4 =#
using BenchmarkTools
#= none:5 =#
using FFTW
#= none:6 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:7 =#
using Oceananigans
#= none:8 =#
using Benchmarks
#= none:12 =#
function benchmark_fft(::Type{CPU}, N, dims; FT = Float64, planner_flag = FFTW.PATIENT)
    #= none:12 =#
    #= none:13 =#
    A = zeros(complex(FT), N, N, N)
    #= none:14 =#
    FFT! = FFTW.plan_fft!(A, dims, flags = planner_flag)
    #= none:15 =#
    trial = #= none:15 =# @benchmark($FFT! * $A, samples = 10)
    #= none:16 =#
    return trial
end
#= none:19 =#
function benchmark_fft(::Type{GPU}, N, dims; FT = Float64, planner_flag = FFTW.PATIENT)
    #= none:19 =#
    #= none:20 =#
    A = zeros(complex(FT), N, N, N) |> GPUArrays.AbstractGPUArray
    #= none:24 =#
    if dims == 2
        #= none:25 =#
        B = similar(A)
        #= none:26 =#
        FFT! = CUDA.CUFFT.plan_fft!(A, 1)
        #= none:28 =#
        trial = #= none:28 =# @benchmark(begin
                    #= none:1 =#
                    #= none:30 =#
                    permutedims!($B, $A, (2, 1, 3))
                    #= none:31 =#
                    $FFT! * $B
                    #= none:32 =#
                    permutedims!($A, $B, (2, 1, 3))
                    #= none:1 =#
                    KernelAbstractions.synchronize(KAUtils.get_backend())
                end, samples = 10)
    else
        #= none:36 =#
        FFT! = CUDA.CUFFT.plan_fft!(A, dims)
        #= none:38 =#
        trial = #= none:38 =# @benchmark(begin
                    #= none:1 =#
                    $FFT! * $A
                    #= none:1 =#
                    KernelAbstractions.synchronize(KAUtils.get_backend())
                end, samples = 10)
    end
    #= none:43 =#
    return trial
end
#= none:48 =#
Architectures = if true
        [CPU, GPU]
    else
        [CPU]
    end
#= none:49 =#
Ns = [16, 64, 256]
#= none:50 =#
dims = [1, 2, 3, (1, 2, 3)]
#= none:54 =#
print_system_info()
#= none:55 =#
suite = run_benchmarks(benchmark_fft; Architectures, Ns, dims)
#= none:57 =#
df = benchmarks_dataframe(suite)
#= none:58 =#
sort!(df, [:Architectures, :dims, :Ns], by = (string, string, identity))
#= none:59 =#
benchmarks_pretty_table(df, title = "FFT benchmarks")
#= none:61 =#
println("3D FFT --> 3 × 1D FFTs slowdown:")
#= none:62 =#
for Arch = Architectures, N = Ns
    #= none:63 =#
    fft_x_time = (median(suite[(Arch, N, 1)])).time
    #= none:64 =#
    fft_y_time = (median(suite[(Arch, N, 2)])).time
    #= none:65 =#
    fft_z_time = (median(suite[(Arch, N, 3)])).time
    #= none:66 =#
    fft_xyz_time = (median(suite[(Arch, N, (1, 2, 3))])).time
    #= none:67 =#
    slowdown = (fft_x_time + fft_y_time + fft_z_time) / fft_xyz_time
    #= none:68 =#
    #= none:68 =# @printf "%s, %3d: %.4fx\n" Arch N slowdown
    #= none:69 =#
end