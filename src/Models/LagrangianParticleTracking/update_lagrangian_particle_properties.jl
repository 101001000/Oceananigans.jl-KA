
#= none:6 =#
#= none:6 =# @kernel function update_property!(particle_property, particles, grid, field, ℓx, ℓy, ℓz)
        #= none:6 =#
        #= none:7 =#
        p = #= none:7 =# @index(Global)
        #= none:8 =#
        #= none:8 =# @inbounds begin
                #= none:9 =#
                x = particles.x[p]
                #= none:10 =#
                y = particles.y[p]
                #= none:11 =#
                z = particles.z[p]
                #= none:12 =#
                X = flattened_node((x, y, z), grid)
                #= none:13 =#
                particle_property[p] = interpolate(X, field, (ℓx, ℓy, ℓz), grid)
            end
    end
#= none:17 =#
function update_lagrangian_particle_properties!(particles, model, Δt)
    #= none:17 =#
    #= none:18 =#
    grid = model.grid
    #= none:19 =#
    arch = architecture(grid)
    #= none:20 =#
    workgroup = min(length(particles), 256)
    #= none:21 =#
    worksize = length(particles)
    #= none:24 =#
    for (name, field) = pairs(particles.tracked_fields)
        #= none:25 =#
        compute!(field)
        #= none:26 =#
        particle_property = getproperty(particles.properties, name)
        #= none:27 =#
        (ℓx, ℓy, ℓz) = map(instantiate, location(field))
        #= none:29 =#
        update_field_property_kernel! = update_property!(device(arch), workgroup, worksize)
        #= none:31 =#
        update_field_property_kernel!(particle_property, particles.properties, model.grid, datatuple(field), ℓx, ℓy, ℓz)
        #= none:33 =#
    end
    #= none:35 =#
    return nothing
end