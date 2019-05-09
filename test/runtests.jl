using Test
using CrystalliteAngles

macro test_stdout(block, expected)
    quote
        out = stdout
        rd, wr = redirect_stdout()
        local output
        try
            $(block)
        finally
            redirect_stdout(out)
            close(wr)
            output = read(rd, String)
        end
        @test $expected == output
    end
end

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

@testset "Repulsion" begin
    @test all(sum(CrystalliteAngles.random_point().^2) ≈ 1 for n = 1:10)
    a = CrystalliteAngles.generate_repulsion(100)
    @test a isa Crystallites
    @test maximum(a.weights.-0.01)/0.01 < 0.05
    @test length(a) == 100
    @test all(isassigned(a.angles, n) for n = 1:100)
    @test all(isassigned(a.weights, n) for n = 1:100)
end

@testset "Alderman" begin
    @test CrystalliteAngles.generate_alderman(102) isa Crystallites
    @test CrystalliteAngles.check_alderman_count(102) == nothing
    @test_throws InexactError CrystalliteAngles.generate_alderman(100)
    @test_throws ArgumentError CrystalliteAngles.check_alderman_count(100)
    a = CrystalliteAngles.generate_alderman(102)
    @test length(a) == 102
    @test all(isassigned(a.angles, n) for n = 1:102)
    @test all(isassigned(a.weights, n) for n = 1:102)
    @test sum(a.weights) ≈ 1.0
    @test_throws ArgumentError get_crystallites(100, algorithm=:alderman)
end

@testset "SOPHE" begin
    @test CrystalliteAngles.generate_sophe(102) isa Crystallites
    @test CrystalliteAngles.check_alderman_count(102) == nothing
    @test_throws InexactError CrystalliteAngles.generate_sophe(100)
    @test_throws ArgumentError CrystalliteAngles.check_alderman_count(100)
    a = CrystalliteAngles.generate_sophe(102)
    @test length(a) == 102
    @test all(isassigned(a.angles, n) for n = 1:102)
    @test all(isassigned(a.weights, n) for n = 1:102)
    @test sum(a.weights) ≈ 1.0
    @test_throws ArgumentError get_crystallites(100, algorithm=:sophe)
end

@testset "Caching" begin
    for f in ("repulsion2","repulsion3")
        path = joinpath(CrystalliteAngles.cache_dir,"$f.cry")
        if isfile(path)
            mv(path, joinpath(CrystalliteAngles.cache_dir,"$(f)_temp.cry"), force=true)
        end
    end
    @test_stdout (@test get_crystallites(2) isa Crystallites) "Generating crystallites\n"
    @test_stdout (@test get_crystallites(2) isa Crystallites) ""

    mv(joinpath(CrystalliteAngles.cache_dir,"repulsion2.cry"), joinpath(CrystalliteAngles.cache_dir,"repulsion3.cry"))
    sleep(0.5)
    @test_stdout (@test get_crystallites(3) isa Crystallites) "Incorrect number of crystallites in cache file repulsion3.cry\nGenerating crystallites\n"

    @test_throws ArgumentError get_crystallites(1)
    @test_stdout get_crystallites(2, save_cache=false) "Generating crystallites\n"
    @test ! isfile(joinpath(CrystalliteAngles.cache_dir,"repulsion2.cry"))
    @test_stdout (@test get_crystallites(3, read_cache=false) isa Crystallites) "Generating crystallites\n"

    @test_stdout (@test get_crystallites(2, Float32) isa Crystallites{Float32}) "Generating crystallites\n"
    @test get_crystallites(3, Float32) isa Crystallites{Float32}

    sleep(0.5)
    for f in ("repulsion2","repulsion3")
        path1 = joinpath(CrystalliteAngles.cache_dir,"$f.cry")
        path2 = joinpath(CrystalliteAngles.cache_dir,"$(f)_temp.cry")
        if isfile(path2)
            mv(path2, path1, force=true)
        elseif isfile(path1)
            rm(path1)
        end
    end
end
