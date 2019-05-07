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
    temp_path = tempname()
    CrystalliteAngles.write_crystallites(temp_path, a)
    @test isfile(temp_path)
    @test filesize(temp_path) == 2300
    b = CrystalliteAngles.read_crystallites(temp_path)
    rm(temp_path)
    @test a.angles == b.angles
    @test a.weights == b.weights
end

@testset "REPULSION" begin
    @test all(sum(CrystalliteAngles.random_point().^2) ≈ 1 for n = 1:10)
    a = CrystalliteAngles.generate_repulsion(100)
    @test a isa Crystallites
    @test maximum(a.weights.-0.01)/0.01 < 0.05
    @test length(a) == 100
end

@testset "Caching" begin
    for f in ("rep2","rep3")
        path = joinpath(CrystalliteAngles.cache_dir,"$f.cry")
        if isfile(path)
            mv(path, joinpath(CrystalliteAngles.cache_dir,"$(f)_temp.cry"), force=true)
        end
    end
    out = stdout
    (a,b) = redirect_stdout()
    @test get_crystallites(2) isa Crystallites
    redirect_stdout(out)
    close(b)
    @test readline(a) == "Generating crystallites"
    @test readline(a) == ""

    (a,b) = redirect_stdout()
    @test get_crystallites(2) isa Crystallites
    redirect_stdout(out)
    close(b)
    @test readline(a) == ""

    mv(joinpath(CrystalliteAngles.cache_dir,"rep2.cry"), joinpath(CrystalliteAngles.cache_dir,"rep3.cry"))
    sleep(0.5)
    (a,b) = redirect_stdout()
    @test get_crystallites(3) isa Crystallites
    redirect_stdout(out)
    close(b)
    @test readline(a) == "Incorrect number of crystallites in cache file rep3.cry"
    @test readline(a) == "Generating crystallites"
    @test readline(a) == ""

    @test_throws ArgumentError get_crystallites(1)
    (a,b) = redirect_stdout()
    @test get_crystallites(2, Float32) isa Crystallites{Float32}
    redirect_stdout(out)
    close(b)
    @test get_crystallites(3, Float32) isa Crystallites{Float32}

    sleep(0.5)
    for f in ("rep2","rep3")
        path1 = joinpath(CrystalliteAngles.cache_dir,"$f.cry")
        path2 = joinpath(CrystalliteAngles.cache_dir,"$(f)_temp.cry")
        if isfile(path2)
            mv(path2, path1, force=true)
        elseif isfile(path1)
            rm(path1)
        end
    end
end
