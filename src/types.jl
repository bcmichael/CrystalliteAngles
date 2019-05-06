import Base.convert

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
