function check_alderman_count(count)
    N = Int(floor(sqrt((count-2)/4)))
    if 4*N^2+2 != count
        a = 4*N^2+2
        b = 4*(N+1)^2+2
        throw(ArgumentError("Invalid Alderman count: $count\nClosest valid counts are: $a and $b"))
    end
end

function generate_alderman(count)
    N = Int(sqrt((count-2)/4))
    angles = Vector{EulerAngles{Float64}}(undef, count)
    weights = zeros(Float64, count)
    n = 1
    for i = 0:N
        for j = 0:N-i
            R = sqrt(i^2+j^2+(N-i-j)^2)
            weight = (N/R)^3
            α = atand(j, i)
            β = acosd((N-i-j)/R)
            if i == 0 && j == 0
                α_symmetry = 1
            elseif i == 0 || j == 0
                α_symmetry = 2
            else
                α_symmetry = 4
            end

            β_vals = i+j == N ? (β,) : (β, 180-β)
            for a = 1:α_symmetry
                α_val = 360*(a-1)/α_symmetry+α
                for β_val in β_vals
                    angles[n] = EulerAngles(α_val, β_val, 0)
                    weights[n] = weight
                    n += 1
                end
            end
        end
    end
    weights ./= sum(weights)
    return Crystallites(angles, weights)
end
