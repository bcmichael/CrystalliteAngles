using Test
using CrystalliteAngles

@testset "EulerAngles" begin
    a = rand(3).*360
    @test EulerAngles(a...) isa EulerAngles{Float64}
    @test EulerAngles{Float32}(a...) isa EulerAngles{Float32}
    @test EulerAngles(a[1],a[2],Float32(a[3])) isa EulerAngles{Float64}
    b = EulerAngles(a...)
    @test EulerAngles{Float32}(b) isa EulerAngles{Float32}
end

@testset "Crystallites" begin
    a = [EulerAngles((rand(3).*360)...) for n = 1:10]
    b = rand(10)
    @test Crystallites(a, b) isa Crystallites
    @test_throws ArgumentError Crystallites(a,b[1:9])
    c = Crystallites(a, b)
    @test length(c) == 10
end

@testset "IO" begin
    @test CrystalliteAngles.read_crystallites("rep100.cry") isa Crystallites
    a = CrystalliteAngles.read_crystallites("rep100.cry")
    @test length(a) == 100
    @test all(isassigned(a.angles, n) for n = 1:100)
    @test all(isassigned(a.weights, n) for n = 1:100)
end

@testset "REPULSION" begin
    @test all(sum(CrystalliteAngles.random_point().^2) ≈ 1 for n = 1:10)
    a = CrystalliteAngles.generate_repulsion(100)
    @test a isa Crystallites
    @test maximum(a.weights.-0.01)/0.01 < 0.05
    @test length(a) == 100
    @test CrystalliteAngles.generate_repulsion(100, 100, Float32) isa Crystallites{Float32}
end
