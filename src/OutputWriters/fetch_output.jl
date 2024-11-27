
#= none:1 =#
begin
    using CUDA, Juliana, GPUArrays
    import KernelAbstractions
end
#= none:3 =#
using Oceananigans.Fields: AbstractField, compute_at!, ZeroField
#= none:4 =#
using Oceananigans.Models.LagrangianParticleTracking: LagrangianParticles
#= none:12 =#
time(model) = begin
        #= none:12 =#
        model.clock.time
    end
#= none:13 =#
time(::Nothing) = begin
        #= none:13 =#
        nothing
    end
#= none:15 =#
fetch_output(output, model) = begin
        #= none:15 =#
        output(model)
    end
#= none:17 =#
function fetch_output(field::AbstractField, model)
    #= none:17 =#
    #= none:18 =#
    compute_at!(field, time(model))
    #= none:19 =#
    return parent(field)
end
#= none:22 =#
function fetch_output(lagrangian_particles::LagrangianParticles, model)
    #= none:22 =#
    #= none:23 =#
    particle_properties = lagrangian_particles.properties
    #= none:24 =#
    names = propertynames(particle_properties)
    #= none:25 =#
    return NamedTuple{names}([getproperty(particle_properties, name) for name = names])
end
#= none:28 =#
convert_output(output, writer) = begin
        #= none:28 =#
        output
    end
#= none:30 =#
function convert_output(output::AbstractArray, writer)
    #= none:30 =#
    #= none:31 =#
    if architecture(output) isa GPU
        #= none:32 =#
        output_array = writer.array_type(undef, size(output)...)
        #= none:33 =#
        copyto!(output_array, output)
    else
        #= none:35 =#
        output_array = convert(writer.array_type, output)
    end
    #= none:38 =#
    return output_array
end
#= none:42 =#
convert_output(outputs::NamedTuple, writer) = begin
        #= none:42 =#
        NamedTuple((name => convert_output(outputs[name], writer) for name = keys(outputs)))
    end
#= none:45 =#
function fetch_and_convert_output(output, model, writer)
    #= none:45 =#
    #= none:46 =#
    fetched = fetch_output(output, model)
    #= none:47 =#
    return convert_output(fetched, writer)
end
#= none:50 =#
fetch_and_convert_output(output::ZeroField, model, writer) = begin
        #= none:50 =#
        zero(eltype(output))
    end