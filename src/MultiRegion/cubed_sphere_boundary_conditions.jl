
#= none:1 =#
using Oceananigans.MultiRegion: number_of_regions
#= none:3 =#
import Oceananigans.BoundaryConditions: fill_halo_regions!
#= none:5 =#
function find_neighboring_panels(grid::ConformalCubedSphereGrid, region)
    #= none:5 =#
    #= none:6 =#
    number_of_regions(grid) !== 6 && error("requires cubed sphere grids with 1 region per panel")
    #= none:8 =#
    if isodd(region)
        #= none:9 =#
        region_E = mod(region + 0, 6) + 1
        #= none:10 =#
        region_N = mod(region + 1, 6) + 1
        #= none:11 =#
        region_W = mod(region + 3, 6) + 1
        #= none:12 =#
        region_S = mod(region + 4, 6) + 1
    elseif #= none:13 =# iseven(region)
        #= none:14 =#
        region_E = mod(region + 1, 6) + 1
        #= none:15 =#
        region_N = mod(region + 0, 6) + 1
        #= none:16 =#
        region_W = mod(region + 4, 6) + 1
        #= none:17 =#
        region_S = mod(region + 3, 6) + 1
    end
    #= none:20 =#
    return (; region_E, region_N, region_W, region_S)
end
#= none:23 =#
function fill_halo_regions!(field::CubedSphereField{<:Center, <:Center})
    #= none:23 =#
    #= none:24 =#
    grid = field.grid
    #= none:26 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:27 =#
    (Hx, Hy, Hz) = halo_size(grid)
    #= none:29 =#
    Nx == Ny || error("horizontal grid size Nx and Ny must be the same")
    #= none:30 =#
    Nc = Nx
    #= none:32 =#
    Hx == Hy || error("horizontal halo size Hx and Hy must be the same")
    #= none:33 =#
    Hc = Hx
    #= none:36 =#
    for region = 1:6
        #= none:38 =#
        (region_E, region_N, region_W, region_S) = find_neighboring_panels(grid, region)
        #= none:40 =#
        if isodd(region)
            #= none:42 =#
            for k = -Hz + 1:Nz + Hz
                #= none:44 =#
                (field[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (field[region_E])[1:Hc, 1:Nc, k]
                #= none:45 =#
                (field[region])[1 - Hc:0, 1:Nc, k] .= (reverse((field[region_W])[1:Nc, (Nc + 1) - Hc:Nc, k], dims = 1))'
                #= none:47 =#
                (field[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (reverse((field[region_N])[1:Hc, 1:Nc, k], dims = 2))'
                #= none:48 =#
                (field[region])[1:Nc, 1 - Hc:0, k] .= (field[region_S])[1:Nc, (Nc + 1) - Hc:Nc, k]
                #= none:49 =#
            end
        elseif #= none:50 =# iseven(region)
            #= none:52 =#
            for k = -Hz + 1:Nz + Hz
                #= none:54 =#
                (field[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (reverse((field[region_E])[1:Nc, 1:Hc, k], dims = 1))'
                #= none:55 =#
                (field[region])[1 - Hc:0, 1:Nc, k] .= (field[region_W])[(Nc + 1) - Hc:Nc, 1:Nc, k]
                #= none:57 =#
                (field[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (field[region_N])[1:Nc, 1:Hc, k]
                #= none:58 =#
                (field[region])[1:Nc, 1 - Hc:0, k] .= (reverse((field[region_S])[(Nc + 1) - Hc:Nc, 1:Nc, k], dims = 2))'
                #= none:59 =#
            end
        end
        #= none:61 =#
    end
    #= none:63 =#
    return nothing
end
#= none:66 =#
function fill_halo_regions!(field::CubedSphereField{<:Face, <:Face})
    #= none:66 =#
    #= none:67 =#
    grid = field.grid
    #= none:69 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:70 =#
    (Hx, Hy, Hz) = halo_size(grid)
    #= none:72 =#
    Nx == Ny || error("horizontal grid size Nx and Ny must be the same")
    #= none:73 =#
    Nc = Nx
    #= none:75 =#
    Hx == Hy || error("horizontal halo size Hx and Hy must be the same")
    #= none:76 =#
    Hc = Hx
    #= none:79 =#
    for region = 1:6
        #= none:81 =#
        (region_E, region_N, region_W, region_S) = find_neighboring_panels(grid, region)
        #= none:83 =#
        if isodd(region)
            #= none:85 =#
            for k = -Hz + 1:Nz + Hz
                #= none:87 =#
                (field[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (field[region_E])[1:Hc, 1:Nc, k]
                #= none:88 =#
                (field[region])[1 - Hc:0, 2:Nc + 1, k] .= (reverse((field[region_W])[1:Nc, (Nc + 1) - Hc:Nc, k], dims = 1))'
                #= none:89 =#
                (field[region])[1 - Hc:0, 1, k] .= (field[region_S])[1, (Nc + 1) - Hc:Nc, k]
                #= none:91 =#
                (field[region])[2:Nc + 1, Nc + 1:Nc + Hc, k] .= (reverse((field[region_N])[1:Hc, 1:Nc, k], dims = 2))'
                #= none:92 =#
                if Hc > 1
                    #= none:93 =#
                    (field[region])[1, Nc + 2:Nc + Hc, k] .= (reverse((field[region_W])[1, (Nc + 2) - Hc:Nc, k]))'
                end
                #= none:97 =#
                (field[region])[1:Nc, 1 - Hc:0, k] .= (field[region_S])[1:Nc, (Nc + 1) - Hc:Nc, k]
                #= none:98 =#
                (field[region])[Nc + 1, 1 - Hc:0, k] .= (reverse((field[region_E])[2:Hc + 1, 1, k]))'
                #= none:99 =#
            end
        elseif #= none:100 =# iseven(region)
            #= none:102 =#
            for k = -Hz + 1:Nz + Hz
                #= none:104 =#
                (field[region])[Nc + 1:Nc + Hc, 2:Nc, k] .= (reverse((field[region_E])[2:Nc, 1:Hc, k], dims = 1))'
                #= none:105 =#
                if Hc > 1
                    #= none:106 =#
                    (field[region])[Nc + 2:Nc + Hc, 1, k] .= reverse((field[region_S])[(Nc + 2) - Hc:Nc, 1, k])
                end
                #= none:110 =#
                (field[region])[1 - Hc:0, 1:Nc, k] .= (field[region_W])[(Nc + 1) - Hc:Nc, 1:Nc, k]
                #= none:112 =#
                (field[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (field[region_N])[1:Nc, 1:Hc, k]
                #= none:113 =#
                (field[region])[Nc + 1, Nc + 1:Nc + Hc, k] .= ((field[region_E])[1, 1:Hc, k])'
                #= none:114 =#
                (field[region])[2:Nc + 1, 1 - Hc:0, k] .= (reverse((field[region_S])[(Nc + 1) - Hc:Nc, 1:Nc, k], dims = 2))'
                #= none:115 =#
                (field[region])[1, 1 - Hc:0, k] .= ((field[region_W])[(Nc + 1) - Hc:Nc, 1, k])'
                #= none:116 =#
            end
        end
        #= none:118 =#
    end
    #= none:120 =#
    return nothing
end
#= none:123 =#
fill_halo_regions!(fields::Tuple{CubedSphereField, CubedSphereField}; signed = true) = begin
        #= none:123 =#
        fill_halo_regions!(fields...; signed)
    end
#= none:125 =#
function fill_halo_regions!(field_1::CubedSphereField{<:Center, <:Center}, field_2::CubedSphereField{<:Center, <:Center}; signed = true)
    #= none:125 =#
    #= none:128 =#
    field_1.grid == field_2.grid || error("fields must be on the same grid")
    #= none:129 =#
    grid = field_1.grid
    #= none:131 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:132 =#
    (Hx, Hy, Hz) = halo_size(grid)
    #= none:133 =#
    if signed
        plmn = -1
    else
        plmn = 1
    end
    #= none:135 =#
    Nx == Ny || error("horizontal grid size Nx and Ny must be the same")
    #= none:136 =#
    Nc = Nx
    #= none:138 =#
    Hx == Hy || error("horizontal halo size Hx and Hy must be the same")
    #= none:139 =#
    Hc = Hx
    #= none:142 =#
    for region = 1:6
        #= none:144 =#
        (region_E, region_N, region_W, region_S) = find_neighboring_panels(grid, region)
        #= none:146 =#
        if isodd(region)
            #= none:148 =#
            for k = -Hz + 1:Nz + Hz
                #= none:150 =#
                (field_1[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (field_1[region_E])[1:Hc, 1:Nc, k]
                #= none:151 =#
                (field_2[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (field_2[region_E])[1:Hc, 1:Nc, k]
                #= none:153 =#
                (field_1[region])[1 - Hc:0, 1:Nc, k] .= (reverse((field_2[region_W])[1:Nc, (Nc + 1) - Hc:Nc, k], dims = 1))'
                #= none:154 =#
                (field_2[region])[1 - Hc:0, 1:Nc, k] .= (reverse((field_1[region_W])[1:Nc, (Nc + 1) - Hc:Nc, k], dims = 1))' * plmn
                #= none:156 =#
                (field_1[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (reverse((field_2[region_N])[1:Hc, 1:Nc, k], dims = 2))' * plmn
                #= none:157 =#
                (field_2[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (reverse((field_1[region_N])[1:Hc, 1:Nc, k], dims = 2))'
                #= none:159 =#
                (field_1[region])[1:Nc, 1 - Hc:0, k] .= (field_1[region_S])[1:Nc, (Nc + 1) - Hc:Nc, k]
                #= none:160 =#
                (field_2[region])[1:Nc, 1 - Hc:0, k] .= (field_2[region_S])[1:Nc, (Nc + 1) - Hc:Nc, k]
                #= none:161 =#
            end
        elseif #= none:162 =# iseven(region)
            #= none:164 =#
            for k = -Hz + 1:Nz + Hz
                #= none:166 =#
                (field_1[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (reverse((field_2[region_E])[1:Nc, 1:Hc, k], dims = 1))'
                #= none:167 =#
                (field_2[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (reverse((field_1[region_E])[1:Nc, 1:Hc, k], dims = 1))' * plmn
                #= none:169 =#
                (field_1[region])[1 - Hc:0, 1:Nc, k] .= (field_1[region_W])[(Nc + 1) - Hc:Nc, 1:Nc, k]
                #= none:170 =#
                (field_2[region])[1 - Hc:0, 1:Nc, k] .= (field_2[region_W])[(Nc + 1) - Hc:Nc, 1:Nc, k]
                #= none:172 =#
                (field_1[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (field_1[region_N])[1:Nc, 1:Hc, k]
                #= none:173 =#
                (field_2[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (field_2[region_N])[1:Nc, 1:Hc, k]
                #= none:175 =#
                (field_1[region])[1:Nc, 1 - Hc:0, k] .= (reverse((field_2[region_S])[(Nc + 1) - Hc:Nc, 1:Nc, k], dims = 2))' * plmn
                #= none:176 =#
                (field_2[region])[1:Nc, 1 - Hc:0, k] .= (reverse((field_1[region_S])[(Nc + 1) - Hc:Nc, 1:Nc, k], dims = 2))'
                #= none:177 =#
            end
        end
        #= none:179 =#
    end
    #= none:181 =#
    return nothing
end
#= none:184 =#
function fill_halo_regions!(field_1::CubedSphereField{<:Face, <:Center}, field_2::CubedSphereField{<:Center, <:Face}; signed = true)
    #= none:184 =#
    #= none:187 =#
    field_1.grid == field_2.grid || error("fields must be on the same grid")
    #= none:188 =#
    grid = field_1.grid
    #= none:190 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:191 =#
    (Hx, Hy, Hz) = halo_size(grid)
    #= none:192 =#
    if signed
        plmn = -1
    else
        plmn = 1
    end
    #= none:194 =#
    Nx == Ny || error("horizontal grid size Nx and Ny must be the same")
    #= none:195 =#
    Nc = Nx
    #= none:197 =#
    Hx == Hy || error("horizontal halo size Hx and Hy must be the same")
    #= none:198 =#
    Hc = Hx
    #= none:201 =#
    for region = 1:6
        #= none:203 =#
        (region_E, region_N, region_W, region_S) = find_neighboring_panels(grid, region)
        #= none:205 =#
        if isodd(region)
            #= none:207 =#
            for k = -Hz + 1:Nz + Hz
                #= none:209 =#
                (field_1[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (field_1[region_E])[1:Hc, 1:Nc, k]
                #= none:210 =#
                (field_1[region])[1 - Hc:0, 1:Nc, k] .= (reverse((field_2[region_W])[1:Nc, (Nc + 1) - Hc:Nc, k], dims = 1))'
                #= none:212 =#
                (field_1[region])[2:Nc + 1, Nc + 1:Nc + Hc, k] .= (reverse((field_2[region_N])[1:Hc, 1:Nc, k], dims = 2))' * plmn
                #= none:213 =#
                (field_1[region])[1, Nc + 1:Nc + Hc, k] .= (reverse((field_1[region_W])[1, (Nc + 1) - Hc:Nc, k]))' * plmn
                #= none:214 =#
                (field_1[region])[1:Nc, 1 - Hc:0, k] .= (field_1[region_S])[1:Nc, (Nc + 1) - Hc:Nc, k]
                #= none:215 =#
                (field_1[region])[Nc + 1, 1 - Hc:0, k] .= (reverse((field_2[region_E])[1:Hc, 1, k]))'
                #= none:217 =#
                (field_2[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (field_2[region_E])[1:Hc, 1:Nc, k]
                #= none:218 =#
                (field_2[region])[Nc + 1:Nc + Hc, Nc + 1, k] .= (field_2[region_N])[1:Hc, 1, k]
                #= none:219 =#
                (field_2[region])[1 - Hc:0, 2:Nc + 1, k] .= (reverse((field_1[region_W])[1:Nc, (Nc + 1) - Hc:Nc, k], dims = 1))' * plmn
                #= none:220 =#
                (field_2[region])[1 - Hc:0, 1, k] .= (field_1[region_S])[1, (Nc + 1) - Hc:Nc, k] * plmn
                #= none:222 =#
                (field_2[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (reverse((field_1[region_N])[1:Hc, 1:Nc, k], dims = 2))'
                #= none:223 =#
                (field_2[region])[1:Nc, 1 - Hc:0, k] .= (field_2[region_S])[1:Nc, (Nc + 1) - Hc:Nc, k]
                #= none:224 =#
            end
        elseif #= none:225 =# iseven(region)
            #= none:227 =#
            for k = -Hz + 1:Nz + Hz
                #= none:229 =#
                (field_1[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (reverse((field_2[region_E])[1:Nc, 1:Hc, k], dims = 1))'
                #= none:230 =#
                (field_1[region])[1 - Hc:0, 1:Nc, k] .= (field_1[region_W])[(Nc + 1) - Hc:Nc, 1:Nc, k]
                #= none:232 =#
                (field_1[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (field_1[region_N])[1:Nc, 1:Hc, k]
                #= none:233 =#
                (field_1[region])[Nc + 1, Nc + 1:Nc + Hc, k] .= ((field_1[region_E])[1, 1:Hc, k])'
                #= none:234 =#
                (field_1[region])[2:Nc + 1, 1 - Hc:0, k] .= (reverse((field_2[region_S])[(Nc + 1) - Hc:Nc, 1:Nc, k], dims = 2))' * plmn
                #= none:235 =#
                (field_1[region])[1, 1 - Hc:0, k] .= ((field_2[region_W])[(Nc + 1) - Hc:Nc, 1, k])' * plmn
                #= none:237 =#
                (field_2[region])[Nc + 1:Nc + Hc, 2:Nc + 1, k] .= (reverse((field_1[region_E])[1:Nc, 1:Hc, k], dims = 1))' * plmn
                #= none:238 =#
                (field_2[region])[Nc + 1:Nc + Hc, 1, k] .= reverse((field_2[region_S])[(Nc + 1) - Hc:Nc, 1, k]) * plmn
                #= none:239 =#
                (field_2[region])[1 - Hc:0, 1:Nc, k] .= (field_2[region_W])[(Nc + 1) - Hc:Nc, 1:Nc, k]
                #= none:240 =#
                (field_2[region])[1 - Hc:0, Nc + 1, k] .= reverse((field_1[region_N])[1, 1:Hc, k])
                #= none:242 =#
                (field_2[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (field_2[region_N])[1:Nc, 1:Hc, k]
                #= none:243 =#
                (field_2[region])[1:Nc, 1 - Hc:0, k] .= (reverse((field_1[region_S])[(Nc + 1) - Hc:Nc, 1:Nc, k], dims = 2))'
                #= none:244 =#
            end
        end
        #= none:246 =#
    end
    #= none:250 =#
    if Hc > 1
        #= none:251 =#
        for region = 1:6
            #= none:252 =#
            for k = -Hz + 1:Nz + Hz
                #= none:254 =#
                (field_1[region])[1 - Hc:0, 0, k] .= (field_2[region])[1, 1 - Hc:0, k]
                #= none:255 =#
                (field_2[region])[0, 1 - Hc:0, k] .= ((field_1[region])[1 - Hc:0, 1, k])'
                #= none:257 =#
                (field_1[region])[2 - Hc:0, Nc + 1, k] .= reverse((field_2[region])[1, Nc + 2:Nc + Hc, k]) * plmn
                #= none:258 =#
                (field_2[region])[0, Nc + 2:Nc + Hc, k] .= (reverse((field_1[region])[2 - Hc:0, Nc, k]))' * plmn
                #= none:260 =#
                (field_1[region])[Nc + 2:Nc + Hc, 0, k] .= reverse((field_2[region])[Nc, 2 - Hc:0, k]) * plmn
                #= none:261 =#
                (field_2[region])[Nc + 1, 2 - Hc:0, k] .= (reverse((field_1[region])[Nc + 2:Nc + Hc, 1, k]))' * plmn
                #= none:263 =#
                (field_1[region])[Nc + 2:Nc + Hc, Nc + 1, k] .= (field_2[region])[Nc, Nc + 2:Nc + Hc, k]
                #= none:264 =#
                (field_2[region])[Nc + 1, Nc + 2:Nc + Hc, k] .= ((field_1[region])[Nc + 2:Nc + Hc, Nc, k])'
                #= none:265 =#
            end
            #= none:266 =#
        end
    end
    #= none:269 =#
    return nothing
end
#= none:272 =#
function fill_halo_regions!(field_1::CubedSphereField{<:Face, <:Face}, field_2::CubedSphereField{<:Face, <:Face}; signed = true)
    #= none:272 =#
    #= none:275 =#
    field_1.grid == field_2.grid || error("fields must be on the same grid")
    #= none:276 =#
    grid = field_1.grid
    #= none:278 =#
    (Nx, Ny, Nz) = size(grid)
    #= none:279 =#
    (Hx, Hy, Hz) = halo_size(grid)
    #= none:280 =#
    if signed
        plmn = -1
    else
        plmn = 1
    end
    #= none:282 =#
    Nx == Ny || error("horizontal grid size Nx and Ny must be the same")
    #= none:283 =#
    Nc = Nx
    #= none:285 =#
    Hx == Hy || error("horizontal halo size Hx and Hy must be the same")
    #= none:286 =#
    Hc = Hx
    #= none:289 =#
    for region = 1:6
        #= none:291 =#
        (region_E, region_N, region_W, region_S) = find_neighboring_panels(grid, region)
        #= none:293 =#
        if isodd(region)
            #= none:295 =#
            for k = -Hz + 1:Nz + Hz
                #= none:297 =#
                (field_1[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (field_1[region_E])[1:Hc, 1:Nc, k]
                #= none:298 =#
                (field_2[region])[Nc + 1:Nc + Hc, 1:Nc, k] .= (field_2[region_E])[1:Hc, 1:Nc, k]
                #= none:299 =#
                (field_2[region])[Nc + 1:Nc + Hc, Nc + 1, k] .= (field_2[region_N])[1:Hc, 1, k]
                #= none:301 =#
                (field_1[region])[1 - Hc:0, 2:Nc + 1, k] .= (reverse((field_2[region_W])[1:Nc, (Nc + 1) - Hc:Nc, k], dims = 1))'
                #= none:302 =#
                (field_2[region])[1 - Hc:0, 2:Nc + 1, k] .= (reverse((field_1[region_W])[1:Nc, (Nc + 1) - Hc:Nc, k], dims = 1))' * plmn
                #= none:303 =#
                (field_1[region])[1 - Hc:0, 1, k] .= (field_2[region_S])[1, (Nc + 1) - Hc:Nc, k]
                #= none:304 =#
                (field_2[region])[1 - Hc:0, 1, k] .= (field_1[region_S])[1, (Nc + 1) - Hc:Nc, k] * plmn
                #= none:306 =#
                (field_1[region])[2:Nc + 1, Nc + 1:Nc + Hc, k] .= (reverse((field_2[region_N])[1:Hc, 1:Nc, k], dims = 2))' * plmn
                #= none:307 =#
                (field_2[region])[2:Nc, Nc + 1:Nc + Hc, k] .= (reverse((field_1[region_N])[1:Hc, 2:Nc, k], dims = 2))'
                #= none:308 =#
                if Hc > 1
                    #= none:309 =#
                    (field_1[region])[1, Nc + 2:Nc + Hc, k] .= (reverse((field_1[region_W])[1, (Nc + 2) - Hc:Nc, k]))' * plmn
                    #= none:310 =#
                    (field_2[region])[1, Nc + 2:Nc + Hc, k] .= (reverse((field_2[region_W])[1, (Nc + 2) - Hc:Nc, k]))' * plmn
                end
                #= none:315 =#
                (field_1[region])[1:Nc, 1 - Hc:0, k] .= (field_1[region_S])[1:Nc, (Nc + 1) - Hc:Nc, k]
                #= none:316 =#
                (field_2[region])[1:Nc, 1 - Hc:0, k] .= (field_2[region_S])[1:Nc, (Nc + 1) - Hc:Nc, k]
                #= none:317 =#
                (field_1[region])[Nc + 1, 1 - Hc:0, k] .= (reverse((field_2[region_E])[2:Hc + 1, 1, k]))'
                #= none:318 =#
            end
        else
            #= none:321 =#
            for k = -Hz + 1:Nz + Hz
                #= none:323 =#
                (field_1[region])[Nc + 1:Nc + Hc, 2:Nc, k] .= (reverse((field_2[region_E])[2:Nc, 1:Hc, k], dims = 1))'
                #= none:324 =#
                (field_2[region])[Nc + 1:Nc + Hc, 2:Nc + 1, k] .= (reverse((field_1[region_E])[1:Nc, 1:Hc, k], dims = 1))' * plmn
                #= none:325 =#
                if Hc > 1
                    #= none:326 =#
                    (field_1[region])[Nc + 2:Nc + Hc, 1, k] .= reverse((field_1[region_S])[(Nc + 2) - Hc:Nc, 1, k]) * plmn
                    #= none:327 =#
                    (field_2[region])[Nc + 2:Nc + Hc, 1, k] .= reverse((field_2[region_S])[(Nc + 2) - Hc:Nc, 1, k]) * plmn
                end
                #= none:332 =#
                (field_1[region])[1 - Hc:0, 1:Nc, k] .= (field_1[region_W])[(Nc + 1) - Hc:Nc, 1:Nc, k]
                #= none:333 =#
                (field_2[region])[1 - Hc:0, 1:Nc, k] .= (field_2[region_W])[(Nc + 1) - Hc:Nc, 1:Nc, k]
                #= none:334 =#
                (field_2[region])[1 - Hc:0, Nc + 1, k] .= reverse((field_1[region_N])[1, 2:Hc + 1, k])
                #= none:336 =#
                (field_1[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (field_1[region_N])[1:Nc, 1:Hc, k]
                #= none:337 =#
                (field_2[region])[1:Nc, Nc + 1:Nc + Hc, k] .= (field_2[region_N])[1:Nc, 1:Hc, k]
                #= none:338 =#
                (field_1[region])[Nc + 1, Nc + 1:Nc + Hc, k] .= ((field_1[region_E])[1, 1:Hc, k])'
                #= none:340 =#
                (field_1[region])[2:Nc + 1, 1 - Hc:0, k] .= (reverse((field_2[region_S])[(Nc + 1) - Hc:Nc, 1:Nc, k], dims = 2))' * plmn
                #= none:341 =#
                (field_2[region])[2:Nc, 1 - Hc:0, k] .= (reverse((field_1[region_S])[(Nc + 1) - Hc:Nc, 2:Nc, k], dims = 2))'
                #= none:342 =#
                (field_1[region])[1, 1 - Hc:0, k] .= ((field_2[region_W])[(Nc + 1) - Hc:Nc, 1, k])' * plmn
                #= none:343 =#
                (field_2[region])[1, 1 - Hc:0, k] .= ((field_1[region_W])[(Nc + 1) - Hc:Nc, 1, k])'
                #= none:344 =#
            end
        end
        #= none:346 =#
    end
    #= none:348 =#
    return nothing
end