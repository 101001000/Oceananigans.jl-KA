
#= none:1 =#
push!(LOAD_PATH, joinpath(#= none:1 =# @__DIR__(), ".."))
#= none:3 =#
using JLD2
#= none:4 =#
using BenchmarkTools
#= none:5 =#
using Benchmarks
#= none:6 =#
using Plots
#= none:7 =#
pyplot()
#= none:10 =#
print_system_info()
#= none:13 =#
strong = false
#= none:15 =#
threaded = false
#= none:17 =#
decomposition = Slab()
#= none:22 =#
ranks = (Dict(Slab() => (1, 2, 4), Pencil() => (1, 4, 16)))[decomposition]
#= none:27 =#
if strong
    #= none:28 =#
    grid_size(R, decomposition) = begin
            #= none:28 =#
            (256, 256, 256)
        end
    #= none:29 =#
    title = "strong"
else
    #= none:31 =#
    grid_size(R, decomposition) = begin
            #= none:31 =#
            (128, 128, 16R)
        end
    #= none:32 =#
    title = "weak"
end
#= none:35 =#
if threaded
    #= none:36 =#
    command(julia, R, Nx, Ny, Nz, Rx, Ry, Rz) = begin
            #= none:36 =#
            `$julia --threads $R --project distributed_nonhydrostatic_model_threaded.jl $Nx $Ny $Nz`
        end
    #= none:37 =#
    label = "threads"
    #= none:38 =#
    dis_type = "threaded"
    #= none:39 =#
    keyop = (v->begin
                #= none:39 =#
                v[2]
            end)
else
    #= none:41 =#
    command(julia, R, Nx, Ny, Nz, Rx, Ry, Rz) = begin
            #= none:41 =#
            `mpiexec -np $R $julia --project distributed_nonhydrostatic_model_mpi.jl $Nx $Ny $Nz $Rx $Ry $Rz`
        end
    #= none:42 =#
    label = "ranks"
    #= none:43 =#
    dis_type = "mpi"
    #= none:44 =#
    keyop = (v->begin
                #= none:44 =#
                (v[2])[2]
            end)
end
#= none:47 =#
rank_size(R, ::Slab) = begin
        #= none:47 =#
        (1, R, 1)
    end
#= none:48 =#
rank_size(R, ::Pencil) = begin
        #= none:48 =#
        Int.((1, √R, √R))
    end
#= none:51 =#
for R = ranks
    #= none:52 =#
    (Nx, Ny, Nz) = grid_size(R, decomposition)
    #= none:53 =#
    (Rx, Ry, Rz) = rank_size(R, decomposition)
    #= none:54 =#
    #= none:54 =# @info string("Benchmarking ", title, " scaling nonhydrostatic model with $(typeof(decomposition)) decomposition [N=($(Nx), $(Ny), $(Nz)), ", label, "=($(Rx), $(Ry), $(Rz))]...")
    #= none:55 =#
    julia = Base.julia_cmd()
    #= none:56 =#
    run(command(julia, R, Nx, Ny, Nz, Rx, Ry, Rz))
    #= none:57 =#
end
#= none:60 =#
suite = BenchmarkGroup(["size", label])
#= none:62 =#
for R = ranks
    #= none:63 =#
    (Nx, Ny, Nz) = grid_size(R, decomposition)
    #= none:64 =#
    (Rx, Ry, Rz) = rank_size(R, decomposition)
    #= none:66 =#
    if threaded
        #= none:67 =#
        case = ((Nx, Ny, Nz), R)
        #= none:68 =#
        filename = string("distributed_nonhydrostatic_model_threads$(R).jld2")
        #= none:69 =#
        file = jldopen(filename, "r")
        #= none:70 =#
        suite[case] = file["trial"]
    else
        #= none:72 =#
        case = ((Nx, Ny, Nz), (Rx, Ry, Rz))
        #= none:73 =#
        for local_rank = 0:R - 1
            #= none:74 =#
            filename = string("distributed_nonhydrostatic_model_$(R)ranks_$(local_rank).jld2")
            #= none:75 =#
            jldopen(filename, "r") do file
                #= none:76 =#
                if local_rank == 0
                    #= none:77 =#
                    suite[case] = file["trial"]
                else
                    #= none:79 =#
                    merged_trial = suite[case]
                    #= none:80 =#
                    local_trial = file["trial"]
                    #= none:81 =#
                    append!(merged_trial.times, local_trial.times)
                    #= none:82 =#
                    append!(merged_trial.gctimes, local_trial.gctimes)
                end
            end
            #= none:85 =#
        end
    end
    #= none:87 =#
end
#= none:89 =#
plot_keys = collect(keys(suite))
#= none:90 =#
sort!(plot_keys, by = keyop)
#= none:91 =#
plot_num = length(plot_keys)
#= none:92 =#
rank_num = zeros(Int64, plot_num)
#= none:93 =#
run_times = zeros(Float64, plot_num)
#= none:94 =#
eff_ratio = zeros(Float64, plot_num)
#= none:95 =#
for i = 1:plot_num
    #= none:96 =#
    run_times[i] = mean((suite[plot_keys[i]]).times) / 1.0e6
    #= none:97 =#
    if threaded
        rank_num[i] = (plot_keys[i])[2]
    else
        rank_num[i] = ((plot_keys[i])[2])[2]
    end
    #= none:98 =#
    eff_ratio[i] = median((suite[plot_keys[1]]).times) / (rank_num[i] ^ strong * median((suite[plot_keys[i]]).times))
    #= none:99 =#
end
#= none:101 =#
plt = plot(rank_num, run_times, lw = 4, xaxis = :log2, legend = :none, xlabel = label, ylabel = "Times (ms)", title = string(dis_type, " ", title, " scaling nonhydrostatic times"))
#= none:103 =#
display(plt)
#= none:104 =#
savefig(plt, string(dis_type, "_", title, "_nonhydrostatic_times.png"))
#= none:107 =#
plt2 = plot(rank_num, eff_ratio, lw = 4, xaxis = :log2, legend = :none, ylims = (0, 1.1), xlabel = label, ylabel = "Efficiency", title = string(dis_type, " ", title, " scaling nonhydrostatic efficiency"))
#= none:109 =#
display(plt2)
#= none:110 =#
savefig(plt2, string(dis_type, "_", title, "_nonhydrostatic_efficiency.png"))
#= none:114 =#
df = benchmarks_dataframe(suite)
#= none:115 =#
sort!(df, Symbol(label))
#= none:116 =#
benchmarks_pretty_table(df, title = string(dis_type, " ", title, " scaling nonhydrostatic times"))
#= none:118 =#
base_case = (grid_size(ranks[1], decomposition), if threaded
            ranks[1]
        else
            rank_size(ranks[1], decomposition)
        end)
#= none:119 =#
suite_Δ = speedups_suite(suite, base_case = base_case)
#= none:120 =#
df_Δ = speedups_dataframe(suite_Δ, slowdown = true, efficiency = Symbol(title), base_case = base_case, key2rank = (k->begin
                    #= none:120 =#
                    prod(k[2])
                end))
#= none:121 =#
sort!(df_Δ, Symbol(label))
#= none:122 =#
benchmarks_pretty_table(df_Δ, title = string(dis_type, " ", title, " scaling nonhydrostatic efficiency"))