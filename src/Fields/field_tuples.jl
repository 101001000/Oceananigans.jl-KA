
#= none:1 =#
using Oceananigans.BoundaryConditions: FieldBoundaryConditions, regularize_field_boundary_conditions
#= none:7 =#
#= none:7 =# @inline flattened_unique_values(::Tuple{}) = begin
            #= none:7 =#
            tuple()
        end
#= none:9 =#
#= none:9 =# Core.@doc "    flattened_unique_values(a::NamedTuple)\n\nReturn values of the (possibly nested) `NamedTuple` `a`,\nflattened into a single tuple, with duplicate entries removed.\n" #= none:15 =# @inline(function flattened_unique_values(a::Union{NamedTuple, Tuple})
            #= none:15 =#
            #= none:16 =#
            tupled = Tuple((tuplify(ai) for ai = a))
            #= none:17 =#
            flattened = flatten_tuple(tupled)
            #= none:20 =#
            seen = []
            #= none:21 =#
            return Tuple((last(push!(seen, f)) for f = flattened if !(any((f === s for s = seen)))))
        end)
#= none:24 =#
const FullField = Field{<:Any, <:Any, <:Any, <:Any, <:Any, <:Tuple{<:Colon, <:Colon, <:Colon}}
#= none:27 =#
#= none:27 =# @inline tuplify(a::NamedTuple) = begin
            #= none:27 =#
            Tuple((tuplify(ai) for ai = a))
        end
#= none:28 =#
#= none:28 =# @inline tuplify(a) = begin
            #= none:28 =#
            a
        end
#= none:31 =#
#= none:31 =# @inline flatten_tuple(a::Tuple) = begin
            #= none:31 =#
            tuple(inner_flatten_tuple(a[1])..., inner_flatten_tuple(a[2:end])...)
        end
#= none:32 =#
#= none:32 =# @inline flatten_tuple(a::Tuple{<:Any}) = begin
            #= none:32 =#
            tuple(inner_flatten_tuple(a[1])...)
        end
#= none:34 =#
#= none:34 =# @inline inner_flatten_tuple(a) = begin
            #= none:34 =#
            tuple(a)
        end
#= none:35 =#
#= none:35 =# @inline inner_flatten_tuple(a::Tuple) = begin
            #= none:35 =#
            flatten_tuple(a)
        end
#= none:36 =#
#= none:36 =# @inline inner_flatten_tuple(a::Tuple{}) = begin
            #= none:36 =#
            ()
        end
#= none:38 =#
#= none:38 =# Core.@doc "    fill_halo_regions!(fields::NamedTuple, args...; kwargs...) \n\nFill halo regions for all `fields`. The algorithm:\n\n  1. Flattens fields, extracting `values` if the field is `NamedTuple`, and removing\n     duplicate entries to avoid \"repeated\" halo filling.\n    \n  2. Filters fields into three categories:\n     i. ReducedFields with non-trivial boundary conditions;\n     ii. Fields with non-trivial indices and boundary conditions;\n     iii. Fields spanning the whole grid with non-trivial boundary conditions.\n    \n  3. Halo regions for every `ReducedField` and windowed fields are filled independently.\n    \n  4. In every direction, the halo regions in each of the remaining `Field` tuple\n     are filled simultaneously.\n" function fill_halo_regions!(maybe_nested_tuple::Union{NamedTuple, Tuple}, args...; kwargs...)
        #= none:56 =#
        #= none:57 =#
        flattened = flattened_unique_values(maybe_nested_tuple)
        #= none:60 =#
        fields_with_bcs = filter((f->begin
                        #= none:60 =#
                        !(isnothing(boundary_conditions(f)))
                    end), flattened)
        #= none:61 =#
        reduced_fields = filter((f->begin
                        #= none:61 =#
                        f isa ReducedField
                    end), fields_with_bcs)
        #= none:63 =#
        for field = reduced_fields
            #= none:64 =#
            fill_halo_regions!(field, args...; kwargs...)
            #= none:65 =#
        end
        #= none:68 =#
        windowed_fields = filter((f->begin
                        #= none:68 =#
                        !(f isa FullField)
                    end), fields_with_bcs)
        #= none:69 =#
        ordinary_fields = filter((f->begin
                        #= none:69 =#
                        f isa FullField && !(f isa ReducedField)
                    end), fields_with_bcs)
        #= none:72 =#
        for field = windowed_fields
            #= none:73 =#
            fill_halo_regions!(field, args...; kwargs...)
            #= none:74 =#
        end
        #= none:77 =#
        if !(isempty(ordinary_fields))
            #= none:78 =#
            grid = (first(ordinary_fields)).grid
            #= none:79 =#
            tupled_fill_halo_regions!(ordinary_fields, grid, args...; kwargs...)
        end
        #= none:82 =#
        return nothing
    end
#= none:85 =#
function tupled_fill_halo_regions!(fields, grid, args...; kwargs...)
    #= none:85 =#
    #= none:88 =#
    indices = default_indices(3)
    #= none:90 =#
    return fill_halo_regions!(map(data, fields), map(boundary_conditions, fields), indices, map(instantiated_location, fields), grid, args...; kwargs...)
end
#= none:103 =#
#= none:103 =# Core.@doc "Returns true if the first three elements of `names` are `(:u, :v, :w)`." has_velocities(names) = begin
            #= none:104 =#
            :u == names[1] && (:v == names[2] && :w == names[3])
        end
#= none:107 =#
has_velocities(::Tuple{}) = begin
        #= none:107 =#
        false
    end
#= none:108 =#
(has_velocities(::Tuple{X}) where X) = begin
        #= none:108 =#
        false
    end
#= none:109 =#
(has_velocities(::Tuple{X, Y}) where {X, Y}) = begin
        #= none:109 =#
        false
    end
#= none:111 =#
tracernames(::Nothing) = begin
        #= none:111 =#
        ()
    end
#= none:112 =#
tracernames(name::Symbol) = begin
        #= none:112 =#
        tuple(name)
    end
#= none:113 =#
(tracernames(names::NTuple{N, Symbol}) where N) = begin
        #= none:113 =#
        if has_velocities(names)
            names[4:end]
        else
            names
        end
    end
#= none:114 =#
(tracernames(::NamedTuple{names}) where names) = begin
        #= none:114 =#
        tracernames(names)
    end
#= none:120 =#
validate_field_grid(grid, field) = begin
        #= none:120 =#
        grid === field.grid
    end
#= none:122 =#
validate_field_grid(grid, field_tuple::NamedTuple) = begin
        #= none:122 =#
        all((validate_field_grid(grid, field) for field = field_tuple))
    end
#= none:125 =#
#= none:125 =# Core.@doc "    validate_field_tuple_grid(tuple_name, field_tuple, grid)\n\nValidates the grids associated with grids in the (possibly nested) `field_tuple`,\nand returns `field_tuple` if validation succeeds.\n" function validate_field_tuple_grid(tuple_name, field_tuple, grid)
        #= none:131 =#
        #= none:133 =#
        all((validate_field_grid(grid, field) for field = field_tuple)) || throw(ArgumentError("Model grid and $(tuple_name) grid are not identical! " * "Check that the grid used to construct $(tuple_name) has the correct halo size."))
        #= none:137 =#
        return nothing
    end
#= none:144 =#
#= none:144 =# Core.@doc "    VelocityFields(grid, user_bcs = NamedTuple())\n\nReturn a `NamedTuple` with fields `u`, `v`, `w` initialized on `grid`.\nBoundary conditions `bcs` may be specified via a named tuple of\n`FieldBoundaryCondition`s.\n" function VelocityFields(grid::AbstractGrid, user_bcs = NamedTuple())
        #= none:151 =#
        #= none:153 =#
        template = FieldBoundaryConditions()
        #= none:155 =#
        default_bcs = (u = regularize_field_boundary_conditions(template, grid, :u), v = regularize_field_boundary_conditions(template, grid, :v), w = regularize_field_boundary_conditions(template, grid, :w))
        #= none:161 =#
        bcs = merge(default_bcs, user_bcs)
        #= none:163 =#
        u = XFaceField(grid, boundary_conditions = bcs.u)
        #= none:164 =#
        v = YFaceField(grid, boundary_conditions = bcs.v)
        #= none:165 =#
        w = ZFaceField(grid, boundary_conditions = bcs.w)
        #= none:167 =#
        return (u = u, v = v, w = w)
    end
#= none:174 =#
#= none:174 =# Core.@doc "    TracerFields(tracer_names, grid, user_bcs)\n\nReturn a `NamedTuple` with tracer fields specified by `tracer_names` initialized as\n`CenterField`s on `grid`. Boundary conditions `user_bcs`\nmay be specified via a named tuple of `FieldBoundaryCondition`s.\n" function TracerFields(tracer_names, grid, user_bcs)
        #= none:181 =#
        #= none:182 =#
        default_bcs = NamedTuple((name => FieldBoundaryConditions(grid, (Center, Center, Center)) for name = tracer_names))
        #= none:183 =#
        bcs = merge(default_bcs, user_bcs)
        #= none:184 =#
        return NamedTuple((c => CenterField(grid, boundary_conditions = bcs[c]) for c = tracer_names))
    end
#= none:187 =#
#= none:187 =# Core.@doc "    TracerFields(tracer_names, grid; kwargs...)\n\nReturn a `NamedTuple` with tracer fields specified by `tracer_names` initialized as\n`CenterField`s on `grid`. Fields may be passed via optional\nkeyword arguments `kwargs` for each field.\n\nThis function is used by `OutputWriters.Checkpointer` and `TendencyFields`.\n```\n" TracerFields(tracer_names, grid; kwargs...) = begin
            #= none:197 =#
            NamedTuple((c => if c ∈ keys(kwargs)
                        kwargs[c]
                    else
                        CenterField(grid)
                    end for c = tracer_names))
        end
#= none:201 =#
TracerFields(::Union{Tuple{}, Nothing}, grid, bcs) = begin
        #= none:201 =#
        NamedTuple()
    end
#= none:203 =#
#= none:203 =# Core.@doc "Shortcut constructor for empty tracer fields." TracerFields(::NamedTuple{(), Tuple{}}, grid, bcs) = begin
            #= none:204 =#
            NamedTuple()
        end
#= none:206 =#
#= none:206 =# Core.@doc "    TendencyFields(grid, tracer_names;\n                   u = XFaceField(grid),\n                   v = YFaceField(grid),\n                   w = ZFaceField(grid),\n                   kwargs...)\n\nReturn a `NamedTuple` with tendencies for all solution fields (velocity fields and\ntracer fields), initialized on `grid`. Optional `kwargs`\ncan be specified to assign data arrays to each tendency field.\n" function TendencyFields(grid, tracer_names; u = XFaceField(grid), v = YFaceField(grid), w = ZFaceField(grid), kwargs...)
        #= none:217 =#
        #= none:223 =#
        velocities = (u = u, v = v, w = w)
        #= none:225 =#
        tracers = TracerFields(tracer_names, grid; kwargs...)
        #= none:227 =#
        return merge(velocities, tracers)
    end
#= none:234 =#
VelocityFields(::Nothing, grid, bcs) = begin
        #= none:234 =#
        VelocityFields(grid, bcs)
    end
#= none:236 =#
#= none:236 =# Core.@doc "    VelocityFields(proposed_velocities::NamedTuple{(:u, :v, :w)}, grid, bcs)\n\nReturn a `NamedTuple` of velocity fields, overwriting boundary conditions\nin `proposed_velocities` with corresponding fields in the `NamedTuple` `bcs`.\n" function VelocityFields(proposed_velocities::NamedTuple{(:u, :v, :w)}, grid, bcs)
        #= none:242 =#
        #= none:244 =#
        validate_field_tuple_grid("velocities", proposed_velocities, grid)
        #= none:246 =#
        u = XFaceField(grid, boundary_conditions = bcs.u, data = proposed_velocities.u.data)
        #= none:247 =#
        v = YFaceField(grid, boundary_conditions = bcs.v, data = proposed_velocities.v.data)
        #= none:248 =#
        w = ZFaceField(grid, boundary_conditions = bcs.w, data = proposed_velocities.w.data)
        #= none:250 =#
        return (u = u, v = v, w = w)
    end
#= none:253 =#
#= none:253 =# Core.@doc "    TracerFields(proposed_tracers::NamedTuple, grid, bcs)\n\nReturn a `NamedTuple` of tracers, overwriting boundary conditions\nin `proposed_tracers` with corresponding fields in the `NamedTuple` `bcs`.\n" function TracerFields(proposed_tracers::NamedTuple, grid, bcs)
        #= none:259 =#
        #= none:261 =#
        validate_field_tuple_grid("tracers", proposed_tracers, grid)
        #= none:263 =#
        tracer_names = propertynames(proposed_tracers)
        #= none:264 =#
        tracer_fields = Tuple((CenterField(grid, boundary_conditions = bcs[c], data = (proposed_tracers[c]).data) for c = tracer_names))
        #= none:266 =#
        return NamedTuple{tracer_names}(tracer_fields)
    end