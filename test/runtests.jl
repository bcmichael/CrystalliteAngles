using Test
using CrystalliteAngles

@testset "EulerAngles" begin
    a=rand(3).*360
    @test EulerAngles(a...) isa EulerAngles{Float64}
    @test EulerAngles{Float32}(a...) isa EulerAngles{Float32}
    @test EulerAngles(a[1],a[2],Float32(a[3])) isa EulerAngles{Float64}
    b=EulerAngles(a...)
    @test EulerAngles{Float32}(b) isa EulerAngles{Float32}
end
