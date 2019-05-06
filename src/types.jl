import Base: convert, length

struct EulerAngles{T<:AbstractFloat}
    α::T
    β::T
    γ::T

    EulerAngles(α::T, β::T, γ::T) where T<:AbstractFloat = new{T}(α%360, β%360, γ%360)
    EulerAngles{T}(α, β, γ) where T<:AbstractFloat = new{T}(α%360, β%360, γ%360)
    EulerAngles{T}(angles::EulerAngles) where T = convert(EulerAngles{T}, angles)
end

EulerAngles(α ,β, γ) = EulerAngles{Float64}(α, β, γ)

convert(::Type{EulerAngles{T}}, angles::EulerAngles) where {T<:AbstractFloat} =
    EulerAngles(T(angles.α), T(angles.β), T(angles.γ))

struct Crystallites{T<:AbstractFloat}
    angles::Vector{EulerAngles{T}}
    weights::Vector{T}

    function Crystallites(angles::Vector{EulerAngles{T}}, weights::Vector{T}) where {T<:AbstractFloat}
        length(angles) == length(weights) || throw(ArgumentError("Number of angles and weights must match"))
        new{T}(angles, weights)
    end
end

length(x::Crystallites) = length(x.angles)
