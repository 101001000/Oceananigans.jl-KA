
#= none:1 =#
using Printf
#= none:3 =#
#= none:3 =# Core.@doc "    pretty_filesize(s, suffix=\"B\")\n\nConvert a floating point value `s` representing a file size to a more human-friendly\nformatted string with one decimal places with a `suffix` defaulting to \"B\". Depending on\nthe value of `s` the string will be formatted to show `s` using an SI prefix from bytes,\nkiB (1024 bytes), MiB (1024² bytes), and so on up to YiB (1024⁸ bytes).\n" function pretty_filesize(s, suffix = "B")
        #= none:11 =#
        #= none:13 =#
        for unit = ["", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"]
            #= none:14 =#
            abs(s) < 1024 && return #= none:14 =# @sprintf("%3.1f %s%s", s, unit, suffix)
            #= none:15 =#
            s /= 1024
            #= none:16 =#
        end
        #= none:17 =#
        return #= none:17 =# @sprintf("%.1f %s%s", s, "Yi", suffix)
    end