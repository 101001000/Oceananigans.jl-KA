
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
strong = true
#= none:15 =#
threaded = false
#= none:17 =#
decomposition = Slab()
#= none:22 =#
ranks = (Dict(Slab() => (1, 2, 4, 8, 16, 32, 64, 128), Pencil() => (1, 4, 16)))[decomposition]
#= none:27 =#
if strong
    #= none:28 =#
    grid_size(R, decomposition) = begin
            #= none:28 =#
            (4096, 4096)
        end
    #= none:29 =#
    title = "strong"
else
    #= none:31 =#
    grid_size(R, ::Slab) = begin
            #= none:31 =#
            (4096, 256R)
        end
    #= none:32 =#
    grid_size(R, ::Pencil) = begin
            #= none:32 =#
            (1024 * Int(√R), 1024 * Int(√R))
        end
    #= none:33 =#
    title = "weak"
end
#= none:36 =#
if threaded
    #= none:37 =#
    command(julia, R, Nx, Ny, Rx, Ry) = begin
            #= none:37 =#
            `$julia --threads $R --project distributed_shallow_water_model_threaded.jl $Nx $Ny`
        end
    #= none:38 =#
    label = "threads"
    #= none:39 =#
    dis_type = "threaded"
    #= none:40 =#
    keyop = (v->begin
                #= none:40 =#
                v[2]
            end)
else
    #= none:42 =#
    command(julia, R, Nx, Ny, Rx, Ry) = begin
            #= none:42 =#
            `mpiexec -np $R $julia --project distributed_shallow_water_model_mpi.jl $Nx $Ny $Rx $Ry`
        end
    #= none:43 =#
    label = "ranks"
    #= none:44 =#
    dis_type = "mpi"
    #= none:45 =#
    keyop = (v->begin
                #= none:45 =#
                (v[2])[2]
            end)
end
#= none:48 =#
rank_size(R, ::Slab) = begin
        #= none:48 =#
        (1, R)
    end
#= none:49 =#
rank_size(R, ::Pencil) = begin
        #= none:49 =#
        Int.((√R, √R))
    end
#= none:52 =#
for R = ranks
    #= none:53 =#
    (Nx, Ny) = grid_size(R, decomposition)
    #= none:54 =#
    (Rx, Ry) = rank_size(R, decomposition)
    #= none:55 =#
    #= none:55 =# @info string("Benchmarking ", title, " scaling shallow water model with $(typeof(decomposition)) decomposition [N=($(Nx), $(Ny)), ", label, "=($(Rx), $(Ry))]...")
    #= none:56 =#
    julia = Base.julia_cmd()
    #= none:57 =#
    run(command(julia, R, Nx, Ny, Rx, Ry))
    #= none:58 =#
end
#= none:61 =#
suite = BenchmarkGroup(["size", label])
#= none:63 =#
for R = ranks
    #= none:64 =#
    (Nx, Ny) = grid_size(R, decomposition)
    #= none:65 =#
    (Rx, Ry) = rank_size(R, decomposition)
    #= none:67 =#
    if threaded
        #= none:68 =#
        case = ((Nx, Ny), R)
        #= none:69 =#
        filename = string("distributed_shallow_water_model_threads$(R).jld2")
        #= none:70 =#
        file = jldopen(filename, "r")
        #= none:71 =#
        suite[case] = file["trial"]
    else
        #= none:73 =#
        case = ((Nx, Ny), (Rx, Ry))
        #= none:74 =#
        for local_rank = 0:R - 1
            #= none:75 =#
            filename = string("distributed_shallow_water_model_$(R)ranks_$(local_rank).jld2")
            #= none:76 =#
            jldopen(filename, "r") do file
                #= none:77 =#
                if local_rank == 0
                    #= none:78 =#
                    suite[case] = file["trial"]
                else
                    #= none:80 =#
                    merged_trial = suite[case]
                    #= none:81 =#
                    local_trial = file["trial"]
                    #= none:82 =#
                    append!(merged_trial.times, local_trial.times)
                    #= none:83 =#
                    append!(merged_trial.gctimes, local_trial.gctimes)
                end
            end
            #= none:86 =#
        end
    end
    #= none:88 =#
end
#= none:90 =#
plot_keys = collect(keys(suite))
#= none:91 =#
sort!(plot_keys, by = keyop)
#= none:92 =#
plot_num = length(plot_keys)
#= none:93 =#
rank_num = zeros(Int64, plot_num)
#= none:94 =#
run_times = zeros(Float64, plot_num)
#= none:95 =#
eff_ratio = zeros(Float64, plot_num)
#= none:96 =#
for i = 1:plot_num
    #= none:97 =#
    run_times[i] = mean((suite[plot_keys[i]]).times) / 1.0e6
    #= none:98 =#
    if threaded
        rank_num[i] = (plot_keys[i])[2]
    else
        rank_num[i] = ((plot_keys[i])[2])[2]
    end
    #= none:99 =#
    eff_ratio[i] = median((suite[plot_keys[1]]).times) / (rank_num[i] ^ strong * median((suite[plot_keys[i]]).times))
    #= none:100 =#
end
#= none:102 =#
plt = plot(rank_num, run_times, lw = 4, xaxis = :log2, legend = :none, xlabel = label, ylabel = "Times (ms)", title = string(dis_type, " ", title, " scaling shallow water times"))
#= none:104 =#
display(plt)
#= none:105 =#
savefig(plt, string(dis_type, "_", title, "_shallow_water_times.png"))
#= none:108 =#
plt2 = plot(rank_num, eff_ratio, lw = 4, xaxis = :log2, legend = :none, ylims = (0, 1.1), xlabel = label, ylabel = "Efficiency", title = string(dis_type, " ", title, " scaling shallow water efficiency"))
#= none:110 =#
display(plt2)
#= none:111 =#
savefig(plt2, string(dis_type, "_", title, "_shallow_water_efficiency.png"))
#= none:115 =#
df = benchmarks_dataframe(suite)
#= none:116 =#
sort!(df, Symbol(label))
#= none:117 =#
benchmarks_pretty_table(df, title = string(dis_type, " ", title, " scaling shallow water times"))
#= none:119 =#
base_case = (grid_size(ranks[1], decomposition), if threaded
            ranks[1]
        else
            rank_size(ranks[1], decomposition)
        end)
#= none:120 =#
suite_Δ = speedups_suite(suite, base_case = base_case)
#= none:121 =#
df_Δ = speedups_dataframe(suite_Δ, slowdown = true, efficiency = Symbol(title), base_case = base_case, key2rank = (k->begin
                    #= none:121 =#
                    prod(k[2])
                end))
#= none:122 =#
sort!(df_Δ, Symbol(label))
#= none:123 =#
benchmarks_pretty_table(df_Δ, title = string(dis_type, " ", title, " scaling shallow water efficiency"))