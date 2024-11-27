
#= none:6 =#
#= none:6 =# @inline ∂x_u(i, j, k, grid, u) = begin
            #= none:6 =#
            ∂xᶜᶜᶜ(i, j, k, grid, u)
        end
#= none:7 =#
#= none:7 =# @inline ∂y_v(i, j, k, grid, v) = begin
            #= none:7 =#
            ∂yᶜᶜᶜ(i, j, k, grid, v)
        end
#= none:8 =#
#= none:8 =# @inline ∂z_w(i, j, k, grid, w) = begin
            #= none:8 =#
            ∂zᶜᶜᶜ(i, j, k, grid, w)
        end
#= none:11 =#
#= none:11 =# @inline ∂x_v(i, j, k, grid, v) = begin
            #= none:11 =#
            ∂xᶠᶠᶜ(i, j, k, grid, v)
        end
#= none:12 =#
#= none:12 =# @inline ∂x_w(i, j, k, grid, w) = begin
            #= none:12 =#
            ∂xᶠᶜᶠ(i, j, k, grid, w)
        end
#= none:14 =#
#= none:14 =# @inline ∂y_u(i, j, k, grid, u) = begin
            #= none:14 =#
            ∂yᶠᶠᶜ(i, j, k, grid, u)
        end
#= none:15 =#
#= none:15 =# @inline ∂y_w(i, j, k, grid, w) = begin
            #= none:15 =#
            ∂yᶜᶠᶠ(i, j, k, grid, w)
        end
#= none:17 =#
#= none:17 =# @inline ∂z_u(i, j, k, grid, u) = begin
            #= none:17 =#
            ∂zᶠᶜᶠ(i, j, k, grid, u)
        end
#= none:18 =#
#= none:18 =# @inline ∂z_v(i, j, k, grid, v) = begin
            #= none:18 =#
            ∂zᶜᶠᶠ(i, j, k, grid, v)
        end
#= none:25 =#
#= none:25 =# @inline Σ₁₁(i, j, k, grid, u) = begin
            #= none:25 =#
            ∂xᶜᶜᶜ(i, j, k, grid, u)
        end
#= none:26 =#
#= none:26 =# @inline Σ₂₂(i, j, k, grid, v) = begin
            #= none:26 =#
            ∂yᶜᶜᶜ(i, j, k, grid, v)
        end
#= none:27 =#
#= none:27 =# @inline Σ₃₃(i, j, k, grid, w) = begin
            #= none:27 =#
            ∂zᶜᶜᶜ(i, j, k, grid, w)
        end
#= none:29 =#
#= none:29 =# @inline tr_Σ(i, j, k, grid, u, v, w) = begin
            #= none:29 =#
            Σ₁₁(i, j, k, grid, u) + Σ₂₂(i, j, k, grid, v) + Σ₃₃(i, j, k, grid, w)
        end
#= none:33 =#
#= none:33 =# @inline (Σ₁₂(i, j, k, grid::AbstractGrid{FT}, u, v) where FT) = begin
            #= none:33 =#
            FT(0.5) * (∂y_u(i, j, k, grid, u) + ∂x_v(i, j, k, grid, v))
        end
#= none:37 =#
#= none:37 =# @inline (Σ₁₃(i, j, k, grid::AbstractGrid{FT}, u, w) where FT) = begin
            #= none:37 =#
            FT(0.5) * (∂z_u(i, j, k, grid, u) + ∂x_w(i, j, k, grid, w))
        end
#= none:41 =#
#= none:41 =# @inline (Σ₂₃(i, j, k, grid::AbstractGrid{FT}, v, w) where FT) = begin
            #= none:41 =#
            FT(0.5) * (∂z_v(i, j, k, grid, v) + ∂y_w(i, j, k, grid, w))
        end
#= none:44 =#
#= none:44 =# @inline Σ₁₂²(i, j, k, grid, u, v) = begin
            #= none:44 =#
            Σ₁₂(i, j, k, grid, u, v) ^ 2
        end
#= none:45 =#
#= none:45 =# @inline Σ₁₃²(i, j, k, grid, u, w) = begin
            #= none:45 =#
            Σ₁₃(i, j, k, grid, u, w) ^ 2
        end
#= none:46 =#
#= none:46 =# @inline Σ₂₃²(i, j, k, grid, v, w) = begin
            #= none:46 =#
            Σ₂₃(i, j, k, grid, v, w) ^ 2
        end
#= none:52 =#
#= none:52 =# @inline ∂x_u(i, j, k, grid, u, v, w) = begin
            #= none:52 =#
            ∂x_u(i, j, k, grid, u)
        end
#= none:53 =#
#= none:53 =# @inline ∂x_v(i, j, k, grid, u, v, w) = begin
            #= none:53 =#
            ∂x_v(i, j, k, grid, v)
        end
#= none:54 =#
#= none:54 =# @inline ∂x_w(i, j, k, grid, u, v, w) = begin
            #= none:54 =#
            ∂x_w(i, j, k, grid, w)
        end
#= none:56 =#
#= none:56 =# @inline ∂y_u(i, j, k, grid, u, v, w) = begin
            #= none:56 =#
            ∂y_u(i, j, k, grid, u)
        end
#= none:57 =#
#= none:57 =# @inline ∂y_v(i, j, k, grid, u, v, w) = begin
            #= none:57 =#
            ∂y_v(i, j, k, grid, v)
        end
#= none:58 =#
#= none:58 =# @inline ∂y_w(i, j, k, grid, u, v, w) = begin
            #= none:58 =#
            ∂y_w(i, j, k, grid, w)
        end
#= none:60 =#
#= none:60 =# @inline ∂z_u(i, j, k, grid, u, v, w) = begin
            #= none:60 =#
            ∂z_u(i, j, k, grid, u)
        end
#= none:61 =#
#= none:61 =# @inline ∂z_v(i, j, k, grid, u, v, w) = begin
            #= none:61 =#
            ∂z_v(i, j, k, grid, v)
        end
#= none:62 =#
#= none:62 =# @inline ∂z_w(i, j, k, grid, u, v, w) = begin
            #= none:62 =#
            ∂z_w(i, j, k, grid, w)
        end
#= none:64 =#
#= none:64 =# @inline Σ₁₁(i, j, k, grid, u, v, w) = begin
            #= none:64 =#
            Σ₁₁(i, j, k, grid, u)
        end
#= none:65 =#
#= none:65 =# @inline Σ₂₂(i, j, k, grid, u, v, w) = begin
            #= none:65 =#
            Σ₂₂(i, j, k, grid, v)
        end
#= none:66 =#
#= none:66 =# @inline Σ₃₃(i, j, k, grid, u, v, w) = begin
            #= none:66 =#
            Σ₃₃(i, j, k, grid, w)
        end
#= none:68 =#
#= none:68 =# @inline Σ₁₂(i, j, k, grid, u, v, w) = begin
            #= none:68 =#
            Σ₁₂(i, j, k, grid, u, v)
        end
#= none:69 =#
#= none:69 =# @inline Σ₁₃(i, j, k, grid, u, v, w) = begin
            #= none:69 =#
            Σ₁₃(i, j, k, grid, u, w)
        end
#= none:70 =#
#= none:70 =# @inline Σ₂₃(i, j, k, grid, u, v, w) = begin
            #= none:70 =#
            Σ₂₃(i, j, k, grid, v, w)
        end
#= none:73 =#
const Σ₂₁ = Σ₁₂
#= none:74 =#
const Σ₃₁ = Σ₁₃
#= none:75 =#
const Σ₃₂ = Σ₂₃
#= none:78 =#
#= none:78 =# @inline tr_Σ²(ijk...) = begin
            #= none:78 =#
            Σ₁₁(ijk...) ^ 2 + Σ₂₂(ijk...) ^ 2 + Σ₃₃(ijk...) ^ 2
        end
#= none:80 =#
#= none:80 =# @inline Σ₁₂²(i, j, k, grid, u, v, w) = begin
            #= none:80 =#
            Σ₁₂²(i, j, k, grid, u, v)
        end
#= none:81 =#
#= none:81 =# @inline Σ₁₃²(i, j, k, grid, u, v, w) = begin
            #= none:81 =#
            Σ₁₃²(i, j, k, grid, u, w)
        end
#= none:82 =#
#= none:82 =# @inline Σ₂₃²(i, j, k, grid, u, v, w) = begin
            #= none:82 =#
            Σ₂₃²(i, j, k, grid, v, w)
        end
#= none:89 =#
#= none:89 =# @inline ∂x_u²(ijk...) = begin
            #= none:89 =#
            ∂x_u(ijk...) ^ 2
        end
#= none:90 =#
#= none:90 =# @inline ∂y_v²(ijk...) = begin
            #= none:90 =#
            ∂y_v(ijk...) ^ 2
        end
#= none:91 =#
#= none:91 =# @inline ∂z_w²(ijk...) = begin
            #= none:91 =#
            ∂z_w(ijk...) ^ 2
        end
#= none:94 =#
#= none:94 =# @inline ∂x_v²(ijk...) = begin
            #= none:94 =#
            ∂x_v(ijk...) ^ 2
        end
#= none:95 =#
#= none:95 =# @inline ∂y_u²(ijk...) = begin
            #= none:95 =#
            ∂y_u(ijk...) ^ 2
        end
#= none:97 =#
#= none:97 =# @inline ∂x_v_Σ₁₂(ijk...) = begin
            #= none:97 =#
            ∂x_v(ijk...) * Σ₁₂(ijk...)
        end
#= none:98 =#
#= none:98 =# @inline ∂y_u_Σ₁₂(ijk...) = begin
            #= none:98 =#
            ∂y_u(ijk...) * Σ₁₂(ijk...)
        end
#= none:101 =#
#= none:101 =# @inline ∂z_u²(ijk...) = begin
            #= none:101 =#
            ∂z_u(ijk...) ^ 2
        end
#= none:102 =#
#= none:102 =# @inline ∂x_w²(ijk...) = begin
            #= none:102 =#
            ∂x_w(ijk...) ^ 2
        end
#= none:104 =#
#= none:104 =# @inline ∂x_w_Σ₁₃(ijk...) = begin
            #= none:104 =#
            ∂x_w(ijk...) * Σ₁₃(ijk...)
        end
#= none:105 =#
#= none:105 =# @inline ∂z_u_Σ₁₃(ijk...) = begin
            #= none:105 =#
            ∂z_u(ijk...) * Σ₁₃(ijk...)
        end
#= none:108 =#
#= none:108 =# @inline ∂z_v²(ijk...) = begin
            #= none:108 =#
            ∂z_v(ijk...) ^ 2
        end
#= none:109 =#
#= none:109 =# @inline ∂y_w²(ijk...) = begin
            #= none:109 =#
            ∂y_w(ijk...) ^ 2
        end
#= none:110 =#
#= none:110 =# @inline ∂z_v_Σ₂₃(ijk...) = begin
            #= none:110 =#
            ∂z_v(ijk...) * Σ₂₃(ijk...)
        end
#= none:111 =#
#= none:111 =# @inline ∂y_w_Σ₂₃(ijk...) = begin
            #= none:111 =#
            ∂y_w(ijk...) * Σ₂₃(ijk...)
        end
#= none:117 =#
#= none:117 =# @inline ∂x_c²(ijk...) = begin
            #= none:117 =#
            ∂xᶠᶜᶜ(ijk...) ^ 2
        end
#= none:118 =#
#= none:118 =# @inline ∂y_c²(ijk...) = begin
            #= none:118 =#
            ∂yᶜᶠᶜ(ijk...) ^ 2
        end
#= none:119 =#
#= none:119 =# @inline ∂z_c²(ijk...) = begin
            #= none:119 =#
            ∂zᶜᶜᶠ(ijk...) ^ 2
        end
#= none:126 =#
const norm_∂x_u = ∂x_u
#= none:127 =#
const norm_∂y_v = ∂y_v
#= none:128 =#
const norm_∂z_w = ∂z_w
#= none:131 =#
#= none:131 =# @inline norm_∂x_v(i, j, k, grid, v) = begin
            #= none:131 =#
            (Δᶠx_ffc(i, j, k, grid) / Δᶠy_ffc(i, j, k, grid)) * ∂x_v(i, j, k, grid, v)
        end
#= none:134 =#
#= none:134 =# @inline norm_∂y_u(i, j, k, grid, u) = begin
            #= none:134 =#
            (Δᶠy_ffc(i, j, k, grid) / Δᶠx_ffc(i, j, k, grid)) * ∂y_u(i, j, k, grid, u)
        end
#= none:138 =#
#= none:138 =# @inline norm_∂x_w(i, j, k, grid, w) = begin
            #= none:138 =#
            (Δᶠx_fcf(i, j, k, grid) / Δᶠz_fcf(i, j, k, grid)) * ∂x_w(i, j, k, grid, w)
        end
#= none:141 =#
#= none:141 =# @inline norm_∂z_u(i, j, k, grid, u) = begin
            #= none:141 =#
            (Δᶠz_fcf(i, j, k, grid) / Δᶠx_fcf(i, j, k, grid)) * ∂z_u(i, j, k, grid, u)
        end
#= none:145 =#
#= none:145 =# @inline norm_∂y_w(i, j, k, grid, w) = begin
            #= none:145 =#
            (Δᶠy_cff(i, j, k, grid) / Δᶠz_cff(i, j, k, grid)) * ∂y_w(i, j, k, grid, w)
        end
#= none:148 =#
#= none:148 =# @inline norm_∂z_v(i, j, k, grid, v) = begin
            #= none:148 =#
            (Δᶠz_cff(i, j, k, grid) / Δᶠy_cff(i, j, k, grid)) * ∂z_v(i, j, k, grid, v)
        end
#= none:152 =#
#= none:152 =# @inline norm_∂x_c(i, j, k, grid, c) = begin
            #= none:152 =#
            Δᶠx_fcc(i, j, k, grid) * ∂xᶠᶜᶜ(i, j, k, grid, c)
        end
#= none:153 =#
#= none:153 =# @inline norm_∂y_c(i, j, k, grid, c) = begin
            #= none:153 =#
            Δᶠy_cfc(i, j, k, grid) * ∂yᶜᶠᶜ(i, j, k, grid, c)
        end
#= none:154 =#
#= none:154 =# @inline norm_∂z_c(i, j, k, grid, c) = begin
            #= none:154 =#
            Δᶠz_ccf(i, j, k, grid) * ∂zᶜᶜᶠ(i, j, k, grid, c)
        end
#= none:161 =#
#= none:161 =# @inline norm_Σ₁₁(i, j, k, grid, u) = begin
            #= none:161 =#
            norm_∂x_u(i, j, k, grid, u)
        end
#= none:162 =#
#= none:162 =# @inline norm_Σ₂₂(i, j, k, grid, v) = begin
            #= none:162 =#
            norm_∂y_v(i, j, k, grid, v)
        end
#= none:163 =#
#= none:163 =# @inline norm_Σ₃₃(i, j, k, grid, w) = begin
            #= none:163 =#
            norm_∂z_w(i, j, k, grid, w)
        end
#= none:165 =#
#= none:165 =# @inline norm_tr_Σ(i, j, k, grid, u, v, w) = begin
            #= none:165 =#
            norm_Σ₁₁(i, j, k, grid, u) + norm_Σ₂₂(i, j, k, grid, v) + norm_Σ₃₃(i, j, k, grid, w)
        end
#= none:169 =#
#= none:169 =# @inline (norm_Σ₁₂(i, j, k, grid::AbstractGrid{T}, u, v) where T) = begin
            #= none:169 =#
            T(0.5) * (norm_∂y_u(i, j, k, grid, u) + norm_∂x_v(i, j, k, grid, v))
        end
#= none:173 =#
#= none:173 =# @inline (norm_Σ₁₃(i, j, k, grid::AbstractGrid{T}, u, w) where T) = begin
            #= none:173 =#
            T(0.5) * (norm_∂z_u(i, j, k, grid, u) + norm_∂x_w(i, j, k, grid, w))
        end
#= none:177 =#
#= none:177 =# @inline (norm_Σ₂₃(i, j, k, grid::AbstractGrid{T}, v, w) where T) = begin
            #= none:177 =#
            T(0.5) * (norm_∂z_v(i, j, k, grid, v) + norm_∂y_w(i, j, k, grid, w))
        end
#= none:180 =#
#= none:180 =# @inline norm_Σ₁₂²(i, j, k, grid, u, v) = begin
            #= none:180 =#
            norm_Σ₁₂(i, j, k, grid, u, v) ^ 2
        end
#= none:181 =#
#= none:181 =# @inline norm_Σ₁₃²(i, j, k, grid, u, w) = begin
            #= none:181 =#
            norm_Σ₁₃(i, j, k, grid, u, w) ^ 2
        end
#= none:182 =#
#= none:182 =# @inline norm_Σ₂₃²(i, j, k, grid, v, w) = begin
            #= none:182 =#
            norm_Σ₂₃(i, j, k, grid, v, w) ^ 2
        end
#= none:185 =#
#= none:185 =# @inline norm_∂x_v(i, j, k, grid, u, v, w) = begin
            #= none:185 =#
            norm_∂x_v(i, j, k, grid, v)
        end
#= none:186 =#
#= none:186 =# @inline norm_∂x_w(i, j, k, grid, u, v, w) = begin
            #= none:186 =#
            norm_∂x_w(i, j, k, grid, w)
        end
#= none:188 =#
#= none:188 =# @inline norm_∂y_u(i, j, k, grid, u, v, w) = begin
            #= none:188 =#
            norm_∂y_u(i, j, k, grid, u)
        end
#= none:189 =#
#= none:189 =# @inline norm_∂y_w(i, j, k, grid, u, v, w) = begin
            #= none:189 =#
            norm_∂y_w(i, j, k, grid, w)
        end
#= none:191 =#
#= none:191 =# @inline norm_∂z_u(i, j, k, grid, u, v, w) = begin
            #= none:191 =#
            norm_∂z_u(i, j, k, grid, u)
        end
#= none:192 =#
#= none:192 =# @inline norm_∂z_v(i, j, k, grid, u, v, w) = begin
            #= none:192 =#
            norm_∂z_v(i, j, k, grid, v)
        end
#= none:194 =#
#= none:194 =# @inline norm_Σ₁₁(i, j, k, grid, u, v, w) = begin
            #= none:194 =#
            norm_Σ₁₁(i, j, k, grid, u)
        end
#= none:195 =#
#= none:195 =# @inline norm_Σ₂₂(i, j, k, grid, u, v, w) = begin
            #= none:195 =#
            norm_Σ₂₂(i, j, k, grid, v)
        end
#= none:196 =#
#= none:196 =# @inline norm_Σ₃₃(i, j, k, grid, u, v, w) = begin
            #= none:196 =#
            norm_Σ₃₃(i, j, k, grid, w)
        end
#= none:198 =#
#= none:198 =# @inline norm_Σ₁₂(i, j, k, grid, u, v, w) = begin
            #= none:198 =#
            norm_Σ₁₂(i, j, k, grid, u, v)
        end
#= none:199 =#
#= none:199 =# @inline norm_Σ₁₃(i, j, k, grid, u, v, w) = begin
            #= none:199 =#
            norm_Σ₁₃(i, j, k, grid, u, w)
        end
#= none:200 =#
#= none:200 =# @inline norm_Σ₂₃(i, j, k, grid, u, v, w) = begin
            #= none:200 =#
            norm_Σ₂₃(i, j, k, grid, v, w)
        end
#= none:203 =#
const norm_Σ₂₁ = norm_Σ₁₂
#= none:204 =#
const norm_Σ₃₁ = norm_Σ₁₃
#= none:205 =#
const norm_Σ₃₂ = norm_Σ₂₃
#= none:208 =#
#= none:208 =# @inline norm_tr_Σ²(ijk...) = begin
            #= none:208 =#
            norm_Σ₁₁(ijk...) ^ 2 + norm_Σ₂₂(ijk...) ^ 2 + norm_Σ₃₃(ijk...) ^ 2
        end
#= none:210 =#
#= none:210 =# @inline norm_Σ₁₂²(i, j, k, grid, u, v, w) = begin
            #= none:210 =#
            norm_Σ₁₂²(i, j, k, grid, u, v)
        end
#= none:211 =#
#= none:211 =# @inline norm_Σ₁₃²(i, j, k, grid, u, v, w) = begin
            #= none:211 =#
            norm_Σ₁₃²(i, j, k, grid, u, w)
        end
#= none:212 =#
#= none:212 =# @inline norm_Σ₂₃²(i, j, k, grid, u, v, w) = begin
            #= none:212 =#
            norm_Σ₂₃²(i, j, k, grid, v, w)
        end
#= none:219 =#
#= none:219 =# @inline norm_∂x_u²(ijk...) = begin
            #= none:219 =#
            norm_∂x_u(ijk...) ^ 2
        end
#= none:220 =#
#= none:220 =# @inline norm_∂y_v²(ijk...) = begin
            #= none:220 =#
            norm_∂y_v(ijk...) ^ 2
        end
#= none:221 =#
#= none:221 =# @inline norm_∂z_w²(ijk...) = begin
            #= none:221 =#
            norm_∂z_w(ijk...) ^ 2
        end
#= none:224 =#
#= none:224 =# @inline norm_∂x_v²(ijk...) = begin
            #= none:224 =#
            norm_∂x_v(ijk...) ^ 2
        end
#= none:225 =#
#= none:225 =# @inline norm_∂y_u²(ijk...) = begin
            #= none:225 =#
            norm_∂y_u(ijk...) ^ 2
        end
#= none:227 =#
#= none:227 =# @inline norm_∂x_v_Σ₁₂(ijk...) = begin
            #= none:227 =#
            norm_∂x_v(ijk...) * norm_Σ₁₂(ijk...)
        end
#= none:228 =#
#= none:228 =# @inline norm_∂y_u_Σ₁₂(ijk...) = begin
            #= none:228 =#
            norm_∂y_u(ijk...) * norm_Σ₁₂(ijk...)
        end
#= none:231 =#
#= none:231 =# @inline norm_∂z_u²(ijk...) = begin
            #= none:231 =#
            norm_∂z_u(ijk...) ^ 2
        end
#= none:232 =#
#= none:232 =# @inline norm_∂x_w²(ijk...) = begin
            #= none:232 =#
            norm_∂x_w(ijk...) ^ 2
        end
#= none:234 =#
#= none:234 =# @inline norm_∂x_w_Σ₁₃(ijk...) = begin
            #= none:234 =#
            norm_∂x_w(ijk...) * norm_Σ₁₃(ijk...)
        end
#= none:235 =#
#= none:235 =# @inline norm_∂z_u_Σ₁₃(ijk...) = begin
            #= none:235 =#
            norm_∂z_u(ijk...) * norm_Σ₁₃(ijk...)
        end
#= none:238 =#
#= none:238 =# @inline norm_∂z_v²(ijk...) = begin
            #= none:238 =#
            norm_∂z_v(ijk...) ^ 2
        end
#= none:239 =#
#= none:239 =# @inline norm_∂y_w²(ijk...) = begin
            #= none:239 =#
            norm_∂y_w(ijk...) ^ 2
        end
#= none:241 =#
#= none:241 =# @inline norm_∂z_v_Σ₂₃(ijk...) = begin
            #= none:241 =#
            norm_∂z_v(ijk...) * norm_Σ₂₃(ijk...)
        end
#= none:242 =#
#= none:242 =# @inline norm_∂y_w_Σ₂₃(ijk...) = begin
            #= none:242 =#
            norm_∂y_w(ijk...) * norm_Σ₂₃(ijk...)
        end
#= none:248 =#
#= none:248 =# @inline norm_∂x_c²(ijk...) = begin
            #= none:248 =#
            norm_∂x_c(ijk...) ^ 2
        end
#= none:249 =#
#= none:249 =# @inline norm_∂y_c²(ijk...) = begin
            #= none:249 =#
            norm_∂y_c(ijk...) ^ 2
        end
#= none:250 =#
#= none:250 =# @inline norm_∂z_c²(ijk...) = begin
            #= none:250 =#
            norm_∂z_c(ijk...) ^ 2
        end