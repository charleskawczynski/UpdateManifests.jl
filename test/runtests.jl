using Aqua
using Base64
using UpdateManifests
using UpdateManifests: DepInfo, EntryType
using Dates
using GitForge
using GitForge: GitForge, GitHub, GitLab
using Mocking
using Pkg
using Random
using SHA
using Test
using TimeZones
using TOML
using UUIDs

Mocking.activate()

Aqua.test_all(UpdateManifests; ambiguities=false)

include("patches.jl")

@testset "UpdateManifests.jl" begin
    include(joinpath("utilities", "ci.jl"))
    include(joinpath("utilities", "git.jl"))
    include(joinpath("utilities", "new_versions.jl"))
    include(joinpath("utilities", "ssh.jl"))
    include(joinpath("utilities", "types.jl"))
    include(joinpath("utilities", "utilities.jl"))
    include(joinpath("utilities", "rate_limiting.jl"))
    include(joinpath("utilities", "timestamps.jl"))

    include("dependencies.jl")
    include("exceptions.jl")
    include("pull_requests.jl")
    include("main.jl")

    UpdateManifests_RUN_INTEGRATION_TESTS = get(ENV, "UpdateManifests_RUN_INTEGRATION_TESTS", "")
    if UpdateManifests_RUN_INTEGRATION_TESTS == "true"
        @testset "Integration Tests" begin
            @info "Running Integration Tests"
            include(joinpath("utilities", "integration_tests.jl"))
            include("integration_tests.jl")
        end
    end
end
