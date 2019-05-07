function random_point()
    x = 2*(rand()-0.5)
    y = 2*(rand()-0.5)*sqrt(1-x^2)
    z = sqrt(1-x^2-y^2)
    if rand() > 0.5
        z = -z
    end
    return [x, y, z]
end

function repulsion_updates(points::Vector{Vector{Float64}})
    count = length(points)
    updates = [zeros(Float64, 3) for n = 1:count]
    for i = 1:count
        Pi = points[i]
        for j = 1:count
            i == j && continue
            Pj = points[j]
            direction = cross(cross(Pj, Pi), Pi)
            angle = acos(dot(Pj, Pi))
            updates[i] .+= direction./(norm(direction*angle^2))
        end
    end
    updates
end

function repulsion_weights(points::Vector{Vector{Float64}})
    weights = zeros(Float64, length(points))
    for i = 1:length(points)
        Pi = points[i]
        for j = i+1:length(points)
            Pj = points[j]
            angle = acos(dot(Pj, Pi))
            weights[i] += angle^-2
            weights[j] += angle^-2
        end
    end
    weights .^= -2
    weights ./= sum(weights)
    weights
end

function generate_repulsion(count, iterations=1000, C=1E-1)
    C = C/count
    points = [random_point() for n = 1:count]
    for n = 1:iterations
        updates = repulsion_updates(points)
        updates .*= C
        for i = 1:count
            points[i] .+= updates[i]
            points[i] ./= norm(points[i])
        end
    end

    angles = Vector{EulerAngles{Float64}}(undef, count)
    weights = repulsion_weights(points)
    for i = 1:count
        Pi = points[i]
        α = atand(Pi[1], Pi[2])+180
        β = acosd(Pi[3])
        angles[i] = EulerAngles{Float64}(α, β, 0)
    end
    return Crystallites(angles, weights)
end
