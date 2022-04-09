@testset "auto_detect_ci_service" begin
    @testset "GitHub: env var present" begin
        withenv("GITHUB_REPOSITORY" => "true") do
            expected = UpdateManifests.GitHubActions()

            @test UpdateManifests.auto_detect_ci_service() == expected
        end
    end

    @testset "GitLab: env var present" begin
        withenv("GITLAB_CI" => "true", "GITHUB_REPOSITORY" => "false") do
            delete!(ENV, "GITHUB_REPOSITORY")
            expected = UpdateManifests.GitLabCI()

            @test UpdateManifests.auto_detect_ci_service() == expected
        end
    end

    @testset "env var dne" begin
        withenv("GITHUB_REPOSITORY" => "foobar", "GITLAB_CI" => "foobar") do
            delete!(ENV, "GITHUB_REPOSITORY")
            delete!(ENV, "GITLAB_CI")
            @test_throws UpdateManifests.UnableToDetectCIService UpdateManifests.auto_detect_ci_service()
        end
    end
end

@testset "$(func)" for func in [UpdateManifests.ci_repository, UpdateManifests.ci_token]
    value = "value"
    ci = UpdateManifests.GitHubActions()

    @testset "exists" begin
        withenv("GITHUB_REPOSITORY" => value, "GITHUB_TOKEN" => value) do
            @test func(ci) == value
        end
    end

    @testset "dne" begin
        withenv("GITHUB_REPOSITORY" => value, "GITHUB_TOKEN" => value) do
            delete!(ENV, "GITHUB_REPOSITORY")
            delete!(ENV, "GITHUB_TOKEN")

            @test_throws KeyError func(ci)
        end
    end
end

@testset "$(func)" for func in [UpdateManifests.ci_repository, UpdateManifests.ci_token]
    value = "value"
    ci = UpdateManifests.GitLabCI()

    @testset "exists" begin
        withenv("CI_PROJECT_PATH" => value, "GITLAB_TOKEN" => value) do
            @test func(ci) == value
        end
    end

    @testset "dne" begin
        withenv("CI_PROJECT_PATH" => value, "GITLAB_TOKEN" => value) do
            delete!(ENV, "CI_PROJECT_PATH")
            delete!(ENV, "GITLAB_TOKEN")

            @test_throws KeyError func(ci)
        end
    end
end
