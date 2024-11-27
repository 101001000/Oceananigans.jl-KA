
#= none:2 =#
#= none:2 =# @inline zerofunction(args...) = begin
            #= none:2 =#
            0
        end
#= none:3 =#
#= none:3 =# @inline onefunction(args...) = begin
            #= none:3 =#
            1
        end
#= none:5 =#
T_zerofunction = typeof(zerofunction)
#= none:6 =#
T_onefunction = typeof(onefunction)
#= none:8 =#
Base.summary(::T_zerofunction) = begin
        #= none:8 =#
        "0"
    end
#= none:9 =#
Base.summary(::T_onefunction) = begin
        #= none:9 =#
        "1"
    end
#= none:11 =#
#= none:11 =# Core.@doc "    struct Relaxation{R, M, T}\n\nCallable object for restoring fields to a `target` at\nsome `rate` and within a `mask`ed region in `x, y, z`.\n" struct Relaxation{R, M, T}
        #= none:18 =#
        rate::R
        #= none:19 =#
        mask::M
        #= none:20 =#
        target::T
    end
#= none:23 =#
#= none:23 =# Core.@doc "    Relaxation(; rate, mask=onefunction, target=zerofunction)\n\nReturns a `Forcing` that restores a field to `target(X..., t)`\nat the specified `rate`, in the region `mask(X...)`.\n\nThe functions `onefunction` and `zerofunction` always return 1 and 0, respectively.\nThus the default `mask` leaves the whole domain uncovered, and the default `target` is zero.\n\nExample\n=======\n\n* Restore a field to zero on a timescale of \"3600\" (equal\n  to one hour if the time units of the simulation are seconds).\n\n```jldoctest relaxation\nusing Oceananigans\n\ndamping = Relaxation(rate = 1/3600)\n\n# output\nRelaxation{Float64, typeof(Oceananigans.Forcings.onefunction), typeof(Oceananigans.Forcings.zerofunction)}\n├── rate: 0.0002777777777777778\n├── mask: 1\n└── target: 0\n```\n\n* Restore a field to a linear z-gradient within the bottom 1/4 of a domain\n  on a timescale of \"60\" (equal to one minute if the time units of the simulation\n  are seconds).\n\n```jldoctest relaxation\ndTdz = 0.001 # ⁰C m⁻¹, temperature gradient\n\nT₀ = 20 # ⁰C, surface temperature at z=0\n\nLz = 100 # m, depth of domain\n\nbottom_sponge_layer = Relaxation(; rate = 1/60,\n                                   target = LinearTarget{:z}(intercept=T₀, gradient=dTdz),\n                                   mask = GaussianMask{:z}(center=-Lz, width=Lz/4))\n\n# output\nRelaxation{Float64, GaussianMask{:z, Float64}, LinearTarget{:z, Float64}}\n├── rate: 0.016666666666666666\n├── mask: exp(-(z + 100.0)^2 / (2 * 25.0^2))\n└── target: 20.0 + 0.001 * z\n```\n" Relaxation(; rate, mask = onefunction, target = zerofunction) = begin
            #= none:72 =#
            Relaxation(rate, mask, target)
        end
#= none:74 =#
#= none:74 =# Core.@doc " Wrap `forcing::Relaxation` in `ContinuousForcing` and add the appropriate field dependency. " function regularize_forcing(forcing::Relaxation, field, field_name, model_field_names)
        #= none:75 =#
        #= none:76 =#
        continuous_relaxation = ContinuousForcing(forcing, field_dependencies = field_name)
        #= none:77 =#
        return regularize_forcing(continuous_relaxation, field, field_name, model_field_names)
    end
#= none:80 =#
#= none:80 =# @inline (f::Relaxation)(x, y, z, t, field) = begin
            #= none:80 =#
            f.rate * f.mask(x, y, z) * (f.target(x, y, z, t) - field)
        end
#= none:83 =#
#= none:83 =# @inline ((f::Relaxation{R, M, <:Number})(x, y, z, t, field) where {R, M}) = begin
            #= none:83 =#
            f.rate * f.mask(x, y, z) * (f.target - field)
        end
#= none:90 =#
#= none:90 =# @inline (f::Relaxation)(x₁, x₂, t, field) = begin
            #= none:90 =#
            f.rate * f.mask(x₁, x₂) * (f.target(x₁, x₂, t) - field)
        end
#= none:93 =#
#= none:93 =# @inline ((f::Relaxation{R, M, <:Number})(x₁, x₂, t, field) where {R, M}) = begin
            #= none:93 =#
            f.rate * f.mask(x₁, x₂) * (f.target - field)
        end
#= none:97 =#
#= none:97 =# @inline (f::Relaxation)(x₁, t, field) = begin
            #= none:97 =#
            f.rate * f.mask(x₁) * (f.target(x₁, t) - field)
        end
#= none:100 =#
#= none:100 =# @inline ((f::Relaxation{R, M, <:Number})(x₁, t, field) where {R, M}) = begin
            #= none:100 =#
            f.rate * f.mask(x₁) * (f.target - field)
        end
#= none:103 =#
#= none:103 =# Core.@doc "Show the innards of a `Relaxation` in the REPL." (Base.show(io::IO, relaxation::Relaxation{R, M, T}) where {R, M, T}) = begin
            #= none:104 =#
            print(io, "Relaxation{$(R), $(M), $(T)}", "\n", "├── rate: $(relaxation.rate)", "\n", "├── mask: $(summary(relaxation.mask))", "\n", "└── target: $(summary(relaxation.target))")
        end
#= none:110 =#
Base.summary(relaxation::Relaxation) = begin
        #= none:110 =#
        "Relaxation(rate=$(relaxation.rate), mask=$(summary(relaxation.mask)), target=$(summary(relaxation.target)))"
    end
#= none:117 =#
#= none:117 =# Core.@doc "    GaussianMask{D}(center, width)\n\nCallable object that returns a Gaussian masking function centered on\n`center`, with `width`, and varying along direction `D`, i.e.,\n\n```\nexp(-(D - center)^2 / (2 * width^2))\n```\n\nExample\n=======\n\nCreate a Gaussian mask centered on `z=0` with width `1` meter.\n\n```julia\njulia> mask = GaussianMask{:z}(center=0, width=1)\n```\n" struct GaussianMask{D, T}
        #= none:137 =#
        center::T
        #= none:138 =#
        width::T
        #= none:140 =#
        function GaussianMask{D}(; center, width) where D
            #= none:140 =#
            #= none:141 =#
            T = promote_type(typeof(center), typeof(width))
            #= none:142 =#
            return new{D, T}(center, width)
        end
    end
#= none:146 =#
#= none:146 =# @inline (g::GaussianMask{:x})(x, y, z) = begin
            #= none:146 =#
            exp(-((x - g.center) ^ 2) / (2 * g.width ^ 2))
        end
#= none:147 =#
#= none:147 =# @inline (g::GaussianMask{:y})(x, y, z) = begin
            #= none:147 =#
            exp(-((y - g.center) ^ 2) / (2 * g.width ^ 2))
        end
#= none:148 =#
#= none:148 =# @inline (g::GaussianMask{:z})(x, y, z) = begin
            #= none:148 =#
            exp(-((z - g.center) ^ 2) / (2 * g.width ^ 2))
        end
#= none:150 =#
show_exp_arg(D, c) = begin
        #= none:150 =#
        if c == 0
            "$(D)^2"
        else
            if c > 0
                "($(D) - $(c))^2"
            else
                "($(D) + $(-c))^2"
            end
        end
    end
#= none:154 =#
(Base.summary(g::GaussianMask{D}) where D) = begin
        #= none:154 =#
        "exp(-$(show_exp_arg(D, g.center)) / (2 * $(g.width)^2))"
    end
#= none:161 =#
#= none:161 =# Core.@doc "    LinearTarget{D}(intercept, gradient)\n\nCallable object that returns a Linear target function\nwith `intercept` and `gradient`, and varying along direction `D`, i.e.,\n\n```\nintercept + D * gradient\n```\n\nExample\n=======\n\nCreate a linear target function varying in `z`, equal to `0` at\n`z=0` and with gradient 10⁻⁶:\n\n```julia\njulia> target = LinearTarget{:z}(intercept=0, gradient=1e-6)\n```\n" struct LinearTarget{D, T}
        #= none:182 =#
        intercept::T
        #= none:183 =#
        gradient::T
        #= none:185 =#
        function LinearTarget{D}(; intercept, gradient) where D
            #= none:185 =#
            #= none:186 =#
            T = promote_type(typeof(gradient), typeof(intercept))
            #= none:187 =#
            return new{D, T}(intercept, gradient)
        end
    end
#= none:191 =#
#= none:191 =# @inline (p::LinearTarget{:x})(x, y, z, t) = begin
            #= none:191 =#
            p.intercept + p.gradient * x
        end
#= none:192 =#
#= none:192 =# @inline (p::LinearTarget{:y})(x, y, z, t) = begin
            #= none:192 =#
            p.intercept + p.gradient * y
        end
#= none:193 =#
#= none:193 =# @inline (p::LinearTarget{:z})(x, y, z, t) = begin
            #= none:193 =#
            p.intercept + p.gradient * z
        end
#= none:195 =#
Base.summary(l::LinearTarget{:x}) = begin
        #= none:195 =#
        "$(l.intercept) + $(l.gradient) * x"
    end
#= none:196 =#
Base.summary(l::LinearTarget{:y}) = begin
        #= none:196 =#
        "$(l.intercept) + $(l.gradient) * y"
    end
#= none:197 =#
Base.summary(l::LinearTarget{:z}) = begin
        #= none:197 =#
        "$(l.intercept) + $(l.gradient) * z"
    end