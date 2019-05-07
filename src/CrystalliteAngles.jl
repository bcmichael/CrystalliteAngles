module CrystalliteAngles
using LinearAlgebra
using Printf
export EulerAngles, Crystallites, get_crystallites

include("types.jl")
include("repulsion.jl")
include("caching.jl")

"""
    get_crystallites(count, T=Float64)

Return a `Crystallite` object containing a set of crystallites orientations for
powder averaging. The number of crystallites is set by `count` and the floating
point precision by `T`. The crystallites will come from a file in the cache if a
macthing file is available. Otherwise a new set of crystallites will be
generated. Newly generated sets of crystallites are also added to the cache.
"""
function get_crystallites(count, ::Type{T}=Float64)::Crystallites{T} where {T<:AbstractFloat}
    count > 1 || throw(ArgumentError("The number of crystallites must be greater than 1"))

    crystallite_file = "rep$count.cry"
    cached = get_from_cache(crystallite_file)
    if cached isa Crystallites && length(cached) == count
        return cached
    end

    if cached != nothing && length(cached) != count
        println("Incorrect number of crystallites in cache file $crystallite_file")
    end

    println("Generating crystallites")
    crystallites = generate_repulsion(count)
    save_to_cache(crystallite_file, crystallites)
    return crystallites
end

end # module
