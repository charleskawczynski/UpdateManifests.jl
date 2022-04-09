# You should set up a Git repo with an example Julia package for the integration tests.
# You should create a bot user GitHub account, and give the bot user GitHub account push access to the testing repo.
# You should generate a personal access token (PAT) for the bot user GitHub account.
# You should add the PAT as an encrypted Travis CI environment variable named `BCBI_TEST_USER_GITHUB_TOKEN`.
# You should generate an SSH deploy key. Upload the public key as a deploy key for the testing repo.
# You should make the private key an encrypted Travis CI environment variable named `UpdateManifests_PRIV`. Probably you will want to Base64-encode it.
const GLOBAL_PR_TITLE_PREFIX = Random.randstring(8)
const GITHUB = "GITHUB"
const GITLAB = "GITLAB"

function run_integration_tests(
    url::AbstractString, env::AbstractDict, ci_cfg::UpdateManifests.CIService
)
    @testset "main_1" begin
        with_main_branch(templates("main_1"), url, "main") do main_1
            withenv(env...) do
                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-1c] ",
                    main_branch=main_1,
                    entry_type=KeepEntry(),
                )
            end
        end
    end

    sleep(1)  # Prevent hitting the GH Secondary Rate Limits

    @testset "main_2" begin
        with_main_branch(templates("main_2"), url, "main") do main_2
            withenv(env...) do
                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-2c] ",
                    main_branch=main_2,
                    entry_type=KeepEntry(),
                )
            end
        end
    end

    sleep(1)  # Prevent hitting the GH Secondary Rate Limits

    @testset "main_3" begin
        with_main_branch(templates("main_3"), url, "main") do main_3
            withenv(env...) do
                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-3a] ",
                    main_branch=main_3,
                    entry_type=DropEntry(),
                )

                sleep(1)  # Prevent hitting the GH Secondary Rate Limits

                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-3b] ",
                    main_branch=main_3,
                    entry_type=KeepEntry(),
                )

                sleep(1)  # Prevent hitting the GH Secondary Rate Limits

                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-3c] ",
                    main_branch=main_3,
                    entry_type=KeepEntry(),
                )
            end
        end
    end

    sleep(1)  # Prevent hitting the GH Secondary Rate Limits

    @testset "main_4" begin
        with_main_branch(templates("main_4"), url, "main") do main_4
            withenv(env...) do
                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-4c] ",
                    main_branch=main_4,
                    entry_type=KeepEntry(),
                )
            end
        end
    end

    sleep(1)  # Prevent hitting the GH Secondary Rate Limits

    @testset "main_5" begin
        with_main_branch(templates("main_5"), url, "main") do main_5
            withenv(env...) do
                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-5a] ",
                    main_branch=main_5,
                    entry_type=DropEntry(),
                )
            end
        end
    end

    sleep(1)  # Prevent hitting the GH Secondary Rate Limits

    @testset "main_6" begin
        with_main_branch(templates("main_6"), url, "main") do main_6
            withenv(env...) do
                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-6c] ",
                    main_branch=main_6,
                    entry_type=KeepEntry(),
                    subdirs=["subdir_1", "subdir_2"],
                )
            end
        end
    end

    sleep(1)  # Prevent hitting the GH Secondary Rate Limits

    @testset "main_7" begin
        with_main_branch(templates("main_7"), url, "main") do main_7
            withenv(env...) do
                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-7a] ",
                    main_branch=main_7,
                    entry_type=DropEntry(),
                    bump_compat_containing_equality_specifier=false,
                )

                sleep(1)  # Prevent hitting the GH Secondary Rate Limits

                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-7b] ",
                    main_branch=main_7,
                    entry_type=DropEntry(),
                    bump_compat_containing_equality_specifier=true,
                )
            end
        end
    end

    sleep(1)  # Prevent hitting the GH Secondary Rate Limits

    @testset "main_8" begin
        with_main_branch(templates("main_8"), url, "main") do main_8
            withenv(env...) do
                UpdateManifests.main(
                    ENV,
                    ci_cfg;
                    pr_title_prefix="$(GLOBAL_PR_TITLE_PREFIX) [test-8a] ",
                    main_branch=main_8,
                    entry_type=DropEntry(),
                    use_existing_registries=true,
                )
            end
        end
    end

    return _cleanup_old_branches(url)
end

@testset "$(service)" for service in [GITHUB, GITLAB]
    personal_access_token = ENV["INTEGRATION_PAT_$(service)"]
    test_repo = ENV["INTEGRATION_TEST_REPO_$(service)"]

    env = Dict(
        "$(service)_REPOSITORY" => test_repo,
        "$(service)_TOKEN" => personal_access_token,
        "CI_PROJECT_PATH" => ENV["INTEGRATION_TEST_REPO_GITLAB"],
    )

    # Otherwise auto_detect_ci_service() will think we're testing on GitHub
    if service == GITLAB
        delete!(env, "GITHUB_REPOSITORY")
        env["GITLAB_CI"] = "true"
    end

    ci_cfg = UpdateManifests.auto_detect_ci_service(; env=env)
    api, repo = UpdateManifests.get_api_and_repo(ci_cfg; env=env)
    url = UpdateManifests.get_url_with_auth(api, ci_cfg, repo)

    run_integration_tests(url, env, ci_cfg)
end
