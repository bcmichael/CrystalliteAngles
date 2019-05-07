"""
    read_crystallites(crystallite_file, T=Float64)

Read a set of α and β crystallite angles and associated weights from a file and
return the values as a `Crystallites` object.
"""
function read_crystallites(crystallite_file, ::Type{T}=Float64) where {T<:AbstractFloat}
    raw = open(crystallite_file) do file
        readlines(file)
    end

    number = length(raw)
    angles = Vector{EulerAngles{T}}(undef, number)
    weights = Vector{T}(undef, number)
    for n = 1:number
        tokens = split(chomp(raw[n]))
        length(tokens) == 3 || throw(ArgumentError("Incorrect number of tokens on line $n"))

        values = [parse(T, j) for j in tokens]
        angles[n] = EulerAngles{T}(values[1], values[2], 0)
        weights[n] = values[3]
    end
    return Crystallites(angles, weights)
end

"""
    write_crystallites(crystallite_file, crystallites)

Write a set of α and β crystallite angles and associated weights from a
`Crystallites` object to a file.
"""
function write_crystallites(crystallite_file, crystallites::Crystallites)
    open(crystallite_file, "w") do file
        for n = 1:length(crystallites)
            angles = crystallites.angles[n]
            weight = crystallites.weights[n]
            line = "$(@sprintf("%7.3f", angles.α)) $(@sprintf("%7.3f", angles.β)) $(@sprintf("%6.4f", weight))\n"
            write(file, line)
        end
    end
end

const cache_dir = joinpath(@__DIR__, "..", "cache")

"""
    get_from_cache(crystallite_file, T=Float64)

Read crystallites from a file in the cache. Return a `Crystallites` object or
nothing if the file is not in the cache or is invalid.
"""
function get_from_cache(crystallite_file)
    file = joinpath(cache_dir, crystallite_file)
    if isfile(file)
        try
            return read_crystallites(file)
        catch
            println("Invalid cache file $crystallite_file")
            return nothing
        end
    else
        return nothing
    end
end

"""
    save_to_cache(crystallite_file, crystallites)

Save a set of crystallites to a file in the cache to avoid having to calculate
them again.
"""
function save_to_cache(crystallite_file, crystallites::Crystallites)
    file = joinpath(cache_dir, crystallite_file)
    isdir(cache_dir) || mkdir(cache_dir)
    write_crystallites(file, crystallites)
end

"""
    clear_cache()

Delete all crystallite files from the cache to ensure new crystallites are
generated in the future.
"""
clear_cache() = rm(cache_dir, force=true, recursive=true)
