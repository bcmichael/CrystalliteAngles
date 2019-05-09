module CrystalliteAngles
using LinearAlgebra
using Printf
export EulerAngles, Crystallites, get_crystallites

include("types.jl")
include("repulsion.jl")
include("alderman.jl")
include("caching.jl")

function check_count(count, algorithm)
    count > 1 || throw(ArgumentError("The number of crystallites must be greater than 1"))
    if algorithm == :repulsion
        # repulsion can handle any count
    elseif algorithm == :alderman
        check_alderman_count(count)
    else
        throw(ArgumentError("Algorithm not recognized: $algorithm"))
    end
end

function generate_crystallites(count, algorithm)
    if algorithm == :repulsion
        crystallites = generate_repulsion(count)
    elseif algorithm == :alderman
        crystallites = generate_alderman(count)
    else
        throw(ArgumentError("Algorithm not recognized: $algorithm"))
    end
end

"""
    get_crystallites(count, T=Float64; read_cache=true, save_cache=true)

Return a `Crystallite` object containing a set of crystallites orientations for
powder averaging. The number of crystallites is set by `count` and the floating
point precision by `T`. If `read_cache` is true the crystallites will come from
a file in the cache if a matching file is available. Otherwise a new set of
crystallites will be generated. Newly generated sets of crystallites are added
to the cache if `save_cache` is true.
"""
function get_crystallites(count, ::Type{T}=Float64; read_cache::Bool=true, save_cache::Bool=true,
    algorithm=:repulsion)::Crystallites{T} where {T<:AbstractFloat}

    check_count(count, algorithm)

    crystallite_file = "$algorithm$count.cry"
    if read_cache
        cached = get_from_cache(crystallite_file)
        if cached == nothing
        elseif length(cached) == count
            return cached
        elseif length(cached) != count
            println("Incorrect number of crystallites in cache file $crystallite_file")
        end
    end

    println("Generating crystallites")
    crystallites = generate_crystallites(count, algorithm)
    if save_cache
        save_to_cache(crystallite_file, crystallites)
    end
    return crystallites
end

end # module
