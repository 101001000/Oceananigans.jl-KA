
#= none:1 =#
using OrderedCollections: OrderedDict
#= none:3 =#
function ordered_dict_show(dict::OrderedDict, padchar)
    #= none:3 =#
    #= none:4 =#
    name = "OrderedDict"
    #= none:5 =#
    N = length(dict)
    #= none:7 =#
    if N === 0
        #= none:8 =#
        return "$(name) with no entries"
    elseif #= none:9 =# N == 1
        #= none:10 =#
        return string("$(name) with 1 entry:", "\n", padchar, "   └── ", dict.keys[1], " => ", summary(dict.vals[1]))
    else
        #= none:13 =#
        return string(name, " with $(N) entries:\n", Tuple((string(padchar, "   ├── $(name) => ", summary(dict[name]), "\n") for name = dict.keys[1:end - 1]))..., string(padchar, "   └── ", dict.keys[end], " => ", summary(dict.vals[end])))
    end
end