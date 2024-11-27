
#= none:1 =#
import Base: push!, getindex, setindex!
#= none:3 =#
using OrderedCollections: OrderedDict
#= none:4 =#
using Oceananigans: AbstractOutputWriter, AbstractDiagnostic
#= none:10 =#
defaultname(::AbstractDiagnostic, nelems) = begin
        #= none:10 =#
        Symbol(:diag, nelems + 1)
    end
#= none:11 =#
defaultname(::AbstractOutputWriter, nelems) = begin
        #= none:11 =#
        Symbol(:writer, nelems + 1)
    end
#= none:13 =#
const DiagOrWriterDict = (OrderedDict{S, <:Union{AbstractDiagnostic, AbstractOutputWriter}} where S)
#= none:15 =#
function push!(container::DiagOrWriterDict, elem)
    #= none:15 =#
    #= none:16 =#
    name = defaultname(elem, length(container))
    #= none:17 =#
    container[name] = elem
    #= none:18 =#
    return nothing
end
#= none:21 =#
getindex(container::DiagOrWriterDict, inds::Integer...) = begin
        #= none:21 =#
        getindex(container.vals, inds...)
    end
#= none:22 =#
setindex!(container::DiagOrWriterDict, newvals, inds::Integer...) = begin
        #= none:22 =#
        setindex!(container.vals, newvals, inds...)
    end
#= none:24 =#
function push!(container::DiagOrWriterDict, elems...)
    #= none:24 =#
    #= none:25 =#
    for elem = elems
        #= none:26 =#
        push!(container, elem)
        #= none:27 =#
    end
    #= none:28 =#
    return nothing
end