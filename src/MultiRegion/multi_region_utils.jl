
#= none:1 =#
import Oceananigans.Fields: flatten_tuple
#= none:3 =#
flatten_tuple(mro::MultiRegionObject) = begin
        #= none:3 =#
        flatten_tuple(mro.regional_objects)
    end
#= none:5 =#
validate_devices(partition, ::CPU, devices) = begin
        #= none:5 =#
        nothing
    end
#= none:6 =#
validate_devices(p, ::CPU, ::Nothing) = begin
        #= none:6 =#
        nothing
    end
#= none:9 =#
validate_devices(p, ::GPU, ::Nothing) = begin
        #= none:9 =#
        1
    end
#= none:11 =#
function validate_devices(partition, ::GPU, devices)
    #= none:11 =#
    #= none:12 =#
    #= none:12 =# @assert length(unique(devices)) ≤ length(KAUtils.devices())
    #= none:13 =#
    #= none:13 =# @assert maximum(devices) ≤ length(KAUtils.devices())
    #= none:14 =#
    #= none:14 =# @assert length(devices) ≤ length(partition)
    #= none:15 =#
    return devices
end
#= none:18 =#
function validate_devices(partition, ::GPU, devices::Number)
    #= none:18 =#
    #= none:19 =#
    #= none:19 =# @assert devices ≤ length(KAUtils.devices())
    #= none:20 =#
    #= none:20 =# @assert devices ≤ length(partition)
    #= none:21 =#
    return devices
end
#= none:24 =#
assign_devices(p, ::Nothing) = begin
        #= none:24 =#
        Tuple((CPU() for i = 1:length(p)))
    end
#= none:26 =#
function assign_devices(p::AbstractPartition, dev::Number)
    #= none:26 =#
    #= none:27 =#
    part = length(p)
    #= none:28 =#
    repeat = part ÷ dev
    #= none:29 =#
    leftover = mod(part, dev)
    #= none:30 =#
    devices = []
    #= none:32 =#
    for i = 1:dev
        #= none:33 =#
        nothing
        #= none:34 =#
        for _ = 1:repeat
            #= none:35 =#
            push!(devices, KAUtils.device())
            #= none:36 =#
        end
        #= none:37 =#
        if i ≤ leftover
            #= none:38 =#
            push!(devices, KAUtils.device())
        end
        #= none:40 =#
    end
    #= none:41 =#
    return Tuple(devices)
end
#= none:44 =#
function assign_devices(p::AbstractPartition, dev::Tuple)
    #= none:44 =#
    #= none:45 =#
    part = length(p)
    #= none:46 =#
    repeat = part ÷ length(dev)
    #= none:47 =#
    leftover = mod(part, length(dev))
    #= none:48 =#
    devices = []
    #= none:50 =#
    for i = 1:length(dev)
        #= none:51 =#
        nothing
        #= none:52 =#
        for _ = 1:repeat
            #= none:53 =#
            push!(devices, KAUtils.device())
            #= none:54 =#
        end
        #= none:55 =#
        if i ≤ leftover
            #= none:56 =#
            push!(devices, KAUtils.device())
        end
        #= none:58 =#
    end
    #= none:59 =#
    return Tuple(devices)
end
#= none:62 =#
maybe_enable_peer_access!(devices) = begin
        #= none:62 =#
        nothing
    end
#= none:65 =#
function maybe_enable_peer_access!(devices::NTuple{<:Any, <:KAUtils.Device})
    #= none:65 =#
    #= none:67 =#
    fake_arrays = []
    #= none:68 =#
    for dev = devices
        #= none:69 =#
        switch_device!(dev)
        #= none:70 =#
        push!(fake_arrays, KAUtils.ArrayConstructor(KAUtils.get_backend(), zeros(2, 2, 2)))
        #= none:71 =#
    end
    #= none:73 =#
    sync_all_devices!(devices)
    #= none:75 =#
    for (idx_dst, dev_dst) = enumerate(devices)
        #= none:76 =#
        for (idx_src, dev_src) = enumerate(devices)
            #= none:77 =#
            if idx_dst != idx_src
                #= none:78 =#
                switch_device!(dev_src)
                #= none:79 =#
                src = fake_arrays[idx_src]
                #= none:80 =#
                switch_device!(dev_dst)
                #= none:81 =#
                dst = fake_arrays[idx_dst]
                #= none:82 =#
                copyto!(dst, src)
            end
            #= none:84 =#
        end
        #= none:85 =#
    end
    #= none:87 =#
    sync_all_devices!(devices)
    #= none:88 =#
    return nothing
end