@testset "has_ssh_private_key" begin
    @testset "not-false" begin
        withenv(UpdateManifests.PRIVATE_SSH_ENVVAR => "foobar") do
            @test UpdateManifests.has_ssh_private_key()
        end
    end

    @testset "false" begin
        withenv(UpdateManifests.PRIVATE_SSH_ENVVAR => "false") do
            @test !(UpdateManifests.has_ssh_private_key())
        end
    end

    @testset "dne" begin
        withenv(UpdateManifests.PRIVATE_SSH_ENVVAR => "true") do
            delete!(ENV, UpdateManifests.PRIVATE_SSH_ENVVAR)
            @test !(UpdateManifests.has_ssh_private_key())
        end
    end
end

@testset "lower" begin
    expected = "foobar"

    @test UpdateManifests.lower("FOOBAR ") == expected
end

@testset "_max" begin
    expected = 5

    @test UpdateManifests._max(expected, 1) == expected
    @test UpdateManifests._max(1, expected) == expected
    @test UpdateManifests._max(nothing, expected) == expected
end

@testset "get_random_string" begin
    @test length(UpdateManifests.get_random_string()) == 35
end

@testset "add_compat_section!" begin
    dict = Dict{Any,Any}("a" => 1)
    @test !haskey(dict, "compat")
    UpdateManifests.add_compat_section!(dict)
    @test haskey(dict, "compat")

    dict = Dict("compat" => 1)
    @test dict["compat"] == 1
    UpdateManifests.add_compat_section!(dict)
    @test dict["compat"] == 1
end

@testset "with_temp_dir" begin
    current_dir = pwd()

    UpdateManifests.with_temp_dir() do tmpdir
        @test endswith(pwd(), tmpdir)
    end

    @test pwd() == current_dir
end
