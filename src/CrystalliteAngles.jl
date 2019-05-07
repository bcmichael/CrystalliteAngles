module CrystalliteAngles
using LinearAlgebra
export EulerAngles, Crystallites

include("types.jl")
include("repulsion.jl")

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


end # module
