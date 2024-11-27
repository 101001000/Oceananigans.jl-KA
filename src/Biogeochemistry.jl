
#= none:1 =#
module Biogeochemistry
#= none:1 =#
#= none:3 =#
using Oceananigans.Grids: Center, xnode, ynode, znode
#= none:4 =#
using Oceananigans.Advection: div_Uc, CenteredSecondOrder
#= none:5 =#
using Oceananigans.Architectures: device, architecture
#= none:6 =#
using Oceananigans.Fields: ZeroField
#= none:8 =#
import Oceananigans.Fields: CenterField
#= none:14 =#
#= none:14 =# @inline biogeochemistry_rhs(i, j, k, grid, ::Nothing, val_tracer_name, clock, fields) = begin
            #= none:14 =#
            zero(grid)
        end
#= none:16 =#
#= none:16 =# Core.@doc "    update_tendencies!(bgc, model)\n\nUpdate prognostic tendencies after they have been computed.\n" update_tendencies!(bgc, model) = begin
            #= none:21 =#
            nothing
        end
#= none:23 =#
#= none:23 =# Core.@doc "    update_biogeochemical_state!(bgc, model)\n\nUpdate biogeochemical state variables. Called at the end of update_state!.\n" update_biogeochemical_state!(bgc, model) = begin
            #= none:28 =#
            nothing
        end
#= none:30 =#
#= none:30 =# @inline biogeochemical_drift_velocity(bgc, val_tracer_name) = begin
            #= none:30 =#
            (u = ZeroField(), v = ZeroField(), w = ZeroField())
        end
#= none:31 =#
#= none:31 =# @inline biogeochemical_auxiliary_fields(bgc) = begin
            #= none:31 =#
            NamedTuple()
        end
#= none:33 =#
#= none:33 =# Core.@doc "    AbstractBiogeochemistry\n\nAbstract type for biogeochemical models. To define a biogeochemcial relaionship\nthe following functions must have methods defined where `BiogeochemicalModel`\nis a subtype of `AbstractBioeochemistry`:\n\n  - `(bgc::BiogeochemicalModel)(i, j, k, grid, ::Val{:tracer_name}, clock, fields)` which \n     returns the biogeochemical reaction for for each tracer.\n\n  - `required_biogeochemical_tracers(::BiogeochemicalModel)` which returns a tuple of\n     required `tracer_names`.\n\n  - `required_biogeochemical_auxiliary_fields(::BiogeochemicalModel)` which returns \n     a tuple of required auxiliary fields.\n\n  - `biogeochemical_auxiliary_fields(bgc::BiogeochemicalModel)` which returns a `NamedTuple`\n     of the models auxiliary fields.\n\n  - `biogeochemical_drift_velocity(bgc::BiogeochemicalModel, ::Val{:tracer_name})` which \n     returns a velocity fields (i.e. a `NamedTuple` of fields with keys `u`, `v` & `w`)\n     for each tracer.\n\n  - `update_biogeochemical_state!(bgc::BiogeochemicalModel, model)` (optional) to update the\n      model state.\n" abstract type AbstractBiogeochemistry end
#= none:62 =#
#= none:62 =# @inline biogeochemical_transition(i, j, k, grid, bgc, val_tracer_name, clock, fields) = begin
            #= none:62 =#
            bgc(i, j, k, grid, val_tracer_name, clock, fields)
        end
#= none:65 =#
#= none:65 =# @inline biogeochemical_transition(i, j, k, grid, ::Nothing, val_tracer_name, clock, fields) = begin
            #= none:65 =#
            zero(grid)
        end
#= none:68 =#
#= none:68 =# @inline (bgc::AbstractBiogeochemistry)(i, j, k, grid, val_tracer_name, clock, fields) = begin
            #= none:68 =#
            zero(grid)
        end
#= none:70 =#
#= none:70 =# Core.@doc "    AbstractContinuousFormBiogeochemistry\n\nAbstract type for biogeochemical models with continuous form biogeochemical reaction \nfunctions. To define a biogeochemcial relaionship the following functions must have methods \ndefined where `BiogeochemicalModel` is a subtype of `AbstractContinuousFormBiogeochemistry`:\n\n  - `(bgc::BiogeochemicalModel)(::Val{:tracer_name}, x, y, z, t, tracers..., auxiliary_fields...)` \n     which returns the biogeochemical reaction for for each tracer.\n\n  - `required_biogeochemical_tracers(::BiogeochemicalModel)` which returns a tuple of\n     required tracer names.\n\n  - `required_biogeochemical_auxiliary_fields(::BiogeochemicalModel)` which returns \n     a tuple of required auxiliary fields.\n\n  - `biogeochemical_auxiliary_fields(bgc::BiogeochemicalModel)` which returns a `NamedTuple`\n     of the models auxiliary fields\n\n  - `biogeochemical_drift_velocity(bgc::BiogeochemicalModel, ::Val{:tracer_name})` which \n     returns \"additional\" velocity fields modeling, for example, sinking particles\n\n  - `update_biogeochemical_state!(bgc::BiogeochemicalModel, model)` (optional) to update the\n     model state\n" abstract type AbstractContinuousFormBiogeochemistry <: AbstractBiogeochemistry end
#= none:97 =#
#= none:97 =# @inline extract_biogeochemical_fields(i, j, k, grid, fields, names::NTuple{1}) = begin
            #= none:97 =#
            #= none:98 =# @inbounds tuple((fields[names[1]])[i, j, k])
        end
#= none:100 =#
#= none:100 =# @inline extract_biogeochemical_fields(i, j, k, grid, fields, names::NTuple{2}) = begin
            #= none:100 =#
            #= none:101 =# @inbounds ((fields[names[1]])[i, j, k], (fields[names[2]])[i, j, k])
        end
#= none:104 =#
#= none:104 =# @inline (extract_biogeochemical_fields(i, j, k, grid, fields, names::NTuple{N}) where N) = begin
            #= none:104 =#
            #= none:105 =# @inbounds ntuple((n->begin
                            #= none:105 =#
                            (fields[names[n]])[i, j, k]
                        end), Val(N))
        end
#= none:107 =#
#= none:107 =# Core.@doc "Return the biogeochemical forcing for `val_tracer_name` for continuous form when model is called." #= none:108 =# @inline(function biogeochemical_transition(i, j, k, grid, bgc::AbstractContinuousFormBiogeochemistry, val_tracer_name, clock, fields)
            #= none:108 =#
            #= none:111 =#
            names_to_extract = tuple(required_biogeochemical_tracers(bgc)..., required_biogeochemical_auxiliary_fields(bgc)...)
            #= none:114 =#
            fields_ijk = extract_biogeochemical_fields(i, j, k, grid, fields, names_to_extract)
            #= none:116 =#
            x = xnode(i, j, k, grid, Center(), Center(), Center())
            #= none:117 =#
            y = ynode(i, j, k, grid, Center(), Center(), Center())
            #= none:118 =#
            z = znode(i, j, k, grid, Center(), Center(), Center())
            #= none:120 =#
            return bgc(val_tracer_name, x, y, z, clock.time, fields_ijk...)
        end)
#= none:123 =#
#= none:123 =# @inline (bgc::AbstractContinuousFormBiogeochemistry)(val_tracer_name, x, y, z, t, fields...) = begin
            #= none:123 =#
            zero(t)
        end
#= none:125 =#
tracernames(tracers) = begin
        #= none:125 =#
        keys(tracers)
    end
#= none:126 =#
tracernames(tracers::Tuple) = begin
        #= none:126 =#
        tracers
    end
#= none:128 =#
add_biogeochemical_tracer(tracers::Tuple, name, grid) = begin
        #= none:128 =#
        tuple(tracers..., name)
    end
#= none:129 =#
add_biogeochemical_tracer(tracers::NamedTuple, name, grid) = begin
        #= none:129 =#
        merge(tracers, (; name => CenterField(grid)))
    end
#= none:131 =#
#= none:131 =# @inline function has_biogeochemical_tracers(fields, required_fields, grid)
        #= none:131 =#
        #= none:132 =#
        user_specified_tracers = [name in tracernames(fields) for name = required_fields]
        #= none:134 =#
        if !(all(user_specified_tracers)) && any(user_specified_tracers)
            #= none:135 =#
            throw(ArgumentError("The biogeochemical model you have selected requires $(required_fields).\n" * "You have specified some but not all of these as tracers so may be attempting\n" * "to use them for a different purpose. Please either specify all of the required\n" * "fields, or none and allow them to be automatically added."))
        elseif #= none:140 =# !(any(user_specified_tracers))
            #= none:141 =#
            for field_name = required_fields
                #= none:142 =#
                fields = add_biogeochemical_tracer(fields, field_name, grid)
                #= none:143 =#
            end
        else
            #= none:145 =#
            fields = fields
        end
        #= none:148 =#
        return fields
    end
#= none:151 =#
#= none:151 =# Core.@doc "    validate_biogeochemistry(tracers, auxiliary_fields, bgc, grid, clock)\n\nEnsure that `tracers` contains biogeochemical tracers and `auxiliary_fields`\ncontains biogeochemical auxiliary fields.\n" #= none:157 =# @inline(function validate_biogeochemistry(tracers, auxiliary_fields, bgc, grid, clock)
            #= none:157 =#
            #= none:158 =#
            req_tracers = required_biogeochemical_tracers(bgc)
            #= none:159 =#
            tracers = has_biogeochemical_tracers(tracers, req_tracers, grid)
            #= none:160 =#
            req_auxiliary_fields = required_biogeochemical_auxiliary_fields(bgc)
            #= none:162 =#
            all((field ∈ tracernames(auxiliary_fields) for field = req_auxiliary_fields)) || error("$(req_auxiliary_fields) must be among the list of auxiliary fields to use $((typeof(bgc)).name.wrapper)")
            #= none:167 =#
            return (tracers, auxiliary_fields)
        end)
#= none:170 =#
const AbstractBGCOrNothing = Union{Nothing, AbstractBiogeochemistry}
#= none:171 =#
required_biogeochemical_tracers(::AbstractBGCOrNothing) = begin
        #= none:171 =#
        ()
    end
#= none:172 =#
required_biogeochemical_auxiliary_fields(::AbstractBGCOrNothing) = begin
        #= none:172 =#
        ()
    end
end