
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:2 =#
using OffsetArrays
#= none:3 =#
using Oceananigans.Grids: AbstractGrid
#= none:5 =#
import Base: length
#= none:7 =#
const GPUVar = Union{GPUArrays.AbstractGPUArray, CuContext, CuPtr, Ptr}
#= none:13 =#
struct MultiRegionObject{R, D}
    #= none:14 =#
    regional_objects::R
    #= none:15 =#
    devices::D
    #= none:17 =#
    function MultiRegionObject(regional_objects...; devices = Tuple((CPU() for _ = regional_objects)))
        #= none:17 =#
        #= none:18 =#
        R = typeof(regional_objects)
        #= none:19 =#
        D = typeof(devices)
        #= none:20 =#
        return new{R, D}(regional_objects, devices)
    end
    #= none:23 =#
    function MultiRegionObject(regional_objects::Tuple, devices::Tuple)
        #= none:23 =#
        #= none:24 =#
        R = typeof(regional_objects)
        #= none:25 =#
        D = typeof(devices)
        #= none:26 =#
        return new{R, D}(regional_objects, devices)
    end
end
#= none:30 =#
#= none:30 =# Core.@doc "    MultiRegionObject(regional_objects::Tuple; devices)\n\nReturn a MultiRegionObject\n" MultiRegionObject(regional_objects::Tuple; devices = Tuple((CPU() for _ = regional_objects))) = begin
            #= none:35 =#
            MultiRegionObject(regional_objects, devices)
        end
#= none:43 =#
struct Reference{R}
    #= none:44 =#
    ref::R
end
#= none:47 =#
struct Iterate{I}
    #= none:48 =#
    iter::I
end
#= none:55 =#
#= none:55 =# @inline getdevice(a, i) = begin
            #= none:55 =#
            nothing
        end
#= none:56 =#
#= none:56 =# @inline getdevice(cu::GPUVar, i) = begin
            #= none:56 =#
            CUDA.device(cu)
        end
#= none:57 =#
#= none:57 =# @inline getdevice(cu::OffsetArray, i) = begin
            #= none:57 =#
            getdevice(cu.parent)
        end
#= none:58 =#
#= none:58 =# @inline getdevice(mo::MultiRegionObject, i) = begin
            #= none:58 =#
            mo.devices[i]
        end
#= none:60 =#
#= none:60 =# @inline getdevice(a) = begin
            #= none:60 =#
            nothing
        end
#= none:61 =#
#= none:61 =# @inline getdevice(cu::GPUVar) = begin
            #= none:61 =#
            CUDA.device(cu)
        end
#= none:62 =#
#= none:62 =# @inline getdevice(cu::OffsetArray) = begin
            #= none:62 =#
            getdevice(cu.parent)
        end
#= none:64 =#
#= none:64 =# @inline switch_device!(a) = begin
            #= none:64 =#
            nothing
        end
#= none:65 =#
#= none:65 =# @inline switch_device!(dev::Int) = nothing
#= none:66 =#
#= none:66 =# @inline switch_device!(dev::KAUtils.Device) = nothing
#= none:67 =#
#= none:67 =# @inline switch_device!(dev::Tuple, i) = begin
            #= none:67 =#
            switch_device!(dev[i])
        end
#= none:68 =#
#= none:68 =# @inline switch_device!(mo::MultiRegionObject, i) = begin
            #= none:68 =#
            switch_device!(getdevice(mo, i))
        end
#= none:70 =#
#= none:70 =# @inline getregion(a, i) = begin
            #= none:70 =#
            a
        end
#= none:71 =#
#= none:71 =# @inline getregion(ref::Reference, i) = begin
            #= none:71 =#
            ref.ref
        end
#= none:72 =#
#= none:72 =# @inline getregion(iter::Iterate, i) = begin
            #= none:72 =#
            iter.iter[i]
        end
#= none:73 =#
#= none:73 =# @inline getregion(mo::MultiRegionObject, i) = begin
            #= none:73 =#
            _getregion(mo.regional_objects[i], i)
        end
#= none:74 =#
#= none:74 =# @inline getregion(p::Pair, i) = begin
            #= none:74 =#
            p.first => _getregion(p.second, i)
        end
#= none:76 =#
#= none:76 =# @inline _getregion(a, i) = begin
            #= none:76 =#
            a
        end
#= none:77 =#
#= none:77 =# @inline _getregion(ref::Reference, i) = begin
            #= none:77 =#
            ref.ref
        end
#= none:78 =#
#= none:78 =# @inline _getregion(iter::Iterate, i) = begin
            #= none:78 =#
            iter.iter[i]
        end
#= none:79 =#
#= none:79 =# @inline _getregion(mo::MultiRegionObject, i) = begin
            #= none:79 =#
            getregion(mo.regional_objects[i], i)
        end
#= none:80 =#
#= none:80 =# @inline _getregion(p::Pair, i) = begin
            #= none:80 =#
            p.first => getregion(p.second, i)
        end
#= none:83 =#
#= none:83 =# @inline getregion(t::Tuple{}, i) = begin
            #= none:83 =#
            ()
        end
#= none:84 =#
#= none:84 =# @inline getregion(t::Tuple{<:Any}, i) = begin
            #= none:84 =#
            (_getregion(t[1], i),)
        end
#= none:85 =#
#= none:85 =# @inline getregion(t::Tuple{<:Any, <:Any}, i) = begin
            #= none:85 =#
            (_getregion(t[1], i), _getregion(t[2], i))
        end
#= none:86 =#
#= none:86 =# @inline getregion(t::Tuple{<:Any, <:Any, <:Any}, i) = begin
            #= none:86 =#
            (_getregion(t[1], i), _getregion(t[2], i), _getregion(t[3], i))
        end
#= none:87 =#
#= none:87 =# @inline getregion(t::Tuple, i) = begin
            #= none:87 =#
            (_getregion(t[1], i), _getregion(t[2:end], i)...)
        end
#= none:89 =#
#= none:89 =# @inline _getregion(t::Tuple{}, i) = begin
            #= none:89 =#
            ()
        end
#= none:90 =#
#= none:90 =# @inline _getregion(t::Tuple{<:Any}, i) = begin
            #= none:90 =#
            (getregion(t[1], i),)
        end
#= none:91 =#
#= none:91 =# @inline _getregion(t::Tuple{<:Any, <:Any}, i) = begin
            #= none:91 =#
            (getregion(t[1], i), getregion(t[2], i))
        end
#= none:92 =#
#= none:92 =# @inline _getregion(t::Tuple{<:Any, <:Any, <:Any}, i) = begin
            #= none:92 =#
            (getregion(t[1], i), getregion(t[2], i), getregion(t[3], i))
        end
#= none:93 =#
#= none:93 =# @inline _getregion(t::Tuple, i) = begin
            #= none:93 =#
            (getregion(t[1], i), getregion(t[2:end], i)...)
        end
#= none:95 =#
#= none:95 =# @inline getregion(nt::NamedTuple, i) = begin
            #= none:95 =#
            NamedTuple{keys(nt)}(_getregion(Tuple(nt), i))
        end
#= none:96 =#
#= none:96 =# @inline _getregion(nt::NamedTuple, i) = begin
            #= none:96 =#
            NamedTuple{keys(nt)}(getregion(Tuple(nt), i))
        end
#= none:98 =#
#= none:98 =# @inline isregional(a) = begin
            #= none:98 =#
            false
        end
#= none:99 =#
#= none:99 =# @inline isregional(::MultiRegionObject) = begin
            #= none:99 =#
            true
        end
#= none:101 =#
#= none:101 =# @inline isregional(t::Tuple{}) = begin
            #= none:101 =#
            false
        end
#= none:102 =#
#= none:102 =# @inline (isregional(nt::NT) where NT <: NamedTuple{(), Tuple{}}) = begin
            #= none:102 =#
            false
        end
#= none:103 =#
for func = [:isregional, :devices, :switch_device!]
    #= none:104 =#
    #= none:104 =# @eval begin
            #= none:105 =#
            #= none:105 =# @inline $func(t::Union{Tuple, NamedTuple}) = begin
                        #= none:105 =#
                        $func(first(t))
                    end
        end
    #= none:107 =#
end
#= none:109 =#
#= none:109 =# @inline devices(mo::MultiRegionObject) = begin
            #= none:109 =#
            mo.devices
        end
#= none:111 =#
Base.getindex(mo::MultiRegionObject, i, args...) = begin
        #= none:111 =#
        Base.getindex(mo.regional_objects, i, args...)
    end
#= none:112 =#
Base.length(mo::MultiRegionObject) = begin
        #= none:112 =#
        Base.length(mo.regional_objects)
    end
#= none:114 =#
Base.similar(mo::MultiRegionObject) = begin
        #= none:114 =#
        construct_regionally(similar, mo)
    end
#= none:115 =#
Base.parent(mo::MultiRegionObject) = begin
        #= none:115 =#
        construct_regionally(parent, mo)
    end
#= none:118 =#
#= none:118 =# @inline function apply_regionally!(regional_func!, args...; kwargs...)
        #= none:118 =#
        #= none:119 =#
        multi_region_args = if isnothing(findfirst(isregional, args))
                nothing
            else
                args[findfirst(isregional, args)]
            end
        #= none:120 =#
        multi_region_kwargs = if isnothing(findfirst(isregional, kwargs))
                nothing
            else
                kwargs[findfirst(isregional, kwargs)]
            end
        #= none:121 =#
        isnothing(multi_region_args) && (isnothing(multi_region_kwargs) && return regional_func!(args...; kwargs...))
        #= none:123 =#
        if isnothing(multi_region_args)
            #= none:124 =#
            devs = devices(multi_region_kwargs)
        else
            #= none:126 =#
            devs = devices(multi_region_args)
        end
        #= none:129 =#
        for (r, dev) = enumerate(devs)
            #= none:130 =#
            switch_device!(dev)
            #= none:131 =#
            regional_func!((getregion(arg, r) for arg = args)...; (getregion(kwarg, r) for kwarg = kwargs)...)
            #= none:132 =#
        end
        #= none:134 =#
        sync_all_devices!(devs)
        #= none:136 =#
        return nothing
    end
#= none:139 =#
#= none:139 =# @inline construct_regionally(regional_func::Base.Callable, args...; kwargs...) = begin
            #= none:139 =#
            construct_regionally(1, regional_func, args...; kwargs...)
        end
#= none:143 =#
#= none:143 =# @inline function construct_regionally(Nreturns::Int, regional_func::Base.Callable, args...; kwargs...)
        #= none:143 =#
        #= none:146 =#
        multi_region_args = if isnothing(findfirst(isregional, args))
                nothing
            else
                args[findfirst(isregional, args)]
            end
        #= none:147 =#
        multi_region_kwargs = if isnothing(findfirst(isregional, kwargs))
                nothing
            else
                kwargs[findfirst(isregional, kwargs)]
            end
        #= none:148 =#
        isnothing(multi_region_args) && (isnothing(multi_region_kwargs) && return regional_func(args...; kwargs...))
        #= none:150 =#
        if isnothing(multi_region_args)
            #= none:151 =#
            devs = devices(multi_region_kwargs)
        else
            #= none:153 =#
            devs = devices(multi_region_args)
        end
        #= none:158 =#
        regional_return_values = Vector(undef, length(devs))
        #= none:159 =#
        for (r, dev) = enumerate(devs)
            #= none:160 =#
            switch_device!(dev)
            #= none:161 =#
            regional_return_values[r] = regional_func((getregion(arg, r) for arg = args)...; (getregion(kwarg, r) for kwarg = kwargs)...)
            #= none:163 =#
        end
        #= none:164 =#
        sync_all_devices!(devs)
        #= none:166 =#
        if Nreturns == 1
            #= none:167 =#
            return MultiRegionObject(Tuple(regional_return_values), devs)
        else
            #= none:169 =#
            return Tuple((MultiRegionObject(Tuple(((regional_return_values[r])[i] for r = 1:length(devs))), devs) for i = 1:Nreturns))
        end
    end
#= none:173 =#
#= none:173 =# @inline sync_all_devices!(grid::AbstractGrid) = begin
            #= none:173 =#
            nothing
        end
#= none:174 =#
#= none:174 =# @inline sync_all_devices!(mo::MultiRegionObject) = begin
            #= none:174 =#
            sync_all_devices!(devices(mo))
        end
#= none:176 =#
#= none:176 =# @inline function sync_all_devices!(devices)
        #= none:176 =#
        #= none:177 =#
        for dev = devices
            #= none:178 =#
            switch_device!(dev)
            #= none:179 =#
            sync_device!(dev)
            #= none:180 =#
        end
    end
#= none:183 =#
#= none:183 =# @inline sync_device!(::Nothing) = begin
            #= none:183 =#
            nothing
        end
#= none:184 =#
#= none:184 =# @inline sync_device!(::CPU) = begin
            #= none:184 =#
            nothing
        end
#= none:185 =#
#= none:185 =# @inline sync_device!(::GPU) = KernelAbstractions.synchronize(KAUtils.get_backend())
#= none:186 =#
#= none:186 =# @inline sync_device!(::KAUtils.Device) = KernelAbstractions.synchronize(KAUtils.get_backend())
#= none:192 =#
#= none:192 =# Core.@doc "    @apply_regionally expr\n    \nDistributes locally the function calls in `expr`ession\n\nIt calls [`apply_regionally!`](@ref) when the functions do not return anything.\n\nIn case the function in `expr` returns something, `@apply_regionally` calls [`construct_regionally`](@ref).\n" macro apply_regionally(expr)
        #= none:201 =#
        #= none:202 =#
        if expr.head == :call
            #= none:203 =#
            func = expr.args[1]
            #= none:204 =#
            args = expr.args[2:end]
            #= none:205 =#
            multi_region = quote
                    #= none:206 =#
                    apply_regionally!($func, $(args...))
                end
            #= none:208 =#
            return quote
                    #= none:209 =#
                    $(esc(multi_region))
                end
        elseif #= none:211 =# expr.head == :(=)
            #= none:212 =#
            ret = expr.args[1]
            #= none:213 =#
            Nret = 1
            #= none:214 =#
            if expr.args[1] isa Expr
                #= none:215 =#
                Nret = length((expr.args[1]).args)
            end
            #= none:217 =#
            exp = expr.args[2]
            #= none:218 =#
            func = exp.args[1]
            #= none:219 =#
            args = exp.args[2:end]
            #= none:220 =#
            multi_region = quote
                    #= none:221 =#
                    $ret = construct_regionally($Nret, $func, $(args...))
                end
            #= none:223 =#
            return quote
                    #= none:224 =#
                    $(esc(multi_region))
                end
        elseif #= none:226 =# expr.head == :block
            #= none:227 =#
            new_expr = deepcopy(expr)
            #= none:228 =#
            for (idx, arg) = enumerate(expr.args)
                #= none:229 =#
                if arg isa Expr && arg.head == :call
                    #= none:230 =#
                    func = arg.args[1]
                    #= none:231 =#
                    args = arg.args[2:end]
                    #= none:232 =#
                    new_expr.args[idx] = quote
                            #= none:233 =#
                            apply_regionally!($func, $(args...))
                        end
                elseif #= none:235 =# arg isa Expr && arg.head == :(=)
                    #= none:236 =#
                    ret = arg.args[1]
                    #= none:237 =#
                    Nret = 1
                    #= none:238 =#
                    if arg.args[1] isa Expr
                        #= none:239 =#
                        Nret = length((arg.args[1]).args)
                    end
                    #= none:241 =#
                    exp = arg.args[2]
                    #= none:242 =#
                    func = exp.args[1]
                    #= none:243 =#
                    args = exp.args[2:end]
                    #= none:244 =#
                    new_expr.args[idx] = quote
                            #= none:245 =#
                            $ret = construct_regionally($Nret, $func, $(args...))
                        end
                end
                #= none:248 =#
            end
            #= none:249 =#
            return quote
                    #= none:250 =#
                    $(esc(new_expr))
                end
        end
    end