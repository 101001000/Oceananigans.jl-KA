
#= none:1 =#
using Pkg
#= none:2 =#
using InteractiveUtils
#= none:3 =#
using Oceananigans.Architectures
#= none:5 =#
function versioninfo_with_gpu()
    #= none:5 =#
    #= none:6 =#
    s = sprint(versioninfo)
    #= none:7 =#
    if true
        #= none:8 =#
        gpu_name = KAUtils.device() |> KAUtils.name
        #= none:9 =#
        s = s * "  GPU: $(gpu_name)\n"
    end
    #= none:11 =#
    return s
end
#= none:14 =#
function oceananigans_versioninfo()
    #= none:14 =#
    #= none:15 =#
    project = Pkg.project()
    #= none:19 =#
    if "Oceananigans" in keys(project.dependencies)
        #= none:20 =#
        uuid = project.dependencies["Oceananigans"]
        #= none:21 =#
        pkg_info = (Pkg.dependencies())[uuid]
        #= none:22 =#
        s = "Oceananigans v$(pkg_info.version)"
        #= none:23 =#
        s *= if isnothing(pkg_info.git_revision)
                ""
            else
                "#$(pkg_info.git_revision)"
            end
        #= none:24 =#
        return s
    end
    #= none:30 =#
    if "Oceananigans" == project.name
        #= none:31 =#
        return "Oceananigans v$(project.version) (DEVELOPMENT BRANCH)"
    end
    #= none:37 =#
    return ""
end