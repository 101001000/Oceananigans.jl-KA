
#= none:1 =#
import Oceananigans.Utils: _launch!
#= none:3 =#
function _launch!(arch::Distributed, args...; kwargs...)
    #= none:3 =#
    #= none:4 =#
    child_arch = child_architecture(arch)
    #= none:5 =#
    return _launch!(child_arch, args...; kwargs...)
end