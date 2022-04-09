# This pkey is just a randomly generated key so we have something to use. This isn't used
# for authenticating anywhere.
const TEST_PKEY = """
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAIEA3nPemZYYdXxCpkn9z/50Pk2LO5+8m4FkmQBKUY0arKlsymrRy88O
dYu9Y9fiu3WplgG2PLpqj2Vd1SJq7DzdUOEmZ9Vp47rO2Tx/bkRn1AfqLGS7AYwMMejqdd
rC03o/6m1mEQdI4AblLiK2U/gWOe3dZdiq1AuhFD6Bmp/+7DkAAAIQ+Ce3m/gnt5sAAAAH
c3NoLXJzYQAAAIEA3nPemZYYdXxCpkn9z/50Pk2LO5+8m4FkmQBKUY0arKlsymrRy88OdY
u9Y9fiu3WplgG2PLpqj2Vd1SJq7DzdUOEmZ9Vp47rO2Tx/bkRn1AfqLGS7AYwMMejqddrC
03o/6m1mEQdI4AblLiK2U/gWOe3dZdiq1AuhFD6Bmp/+7DkAAAADAQABAAAAgQCSs69Vcl
rm/++kYp90D8bxX4o24/0qQIbrL/nTFk9FFuacBx4cXoyWkHVx5umr3sjcGHzqR7YGoz7i
VDRXXzxD47SRdYJ0IHvUB8dCpZHJt6qDxndMUvp5z/eLccAATm77L1i3ve3D4Eferj+mvR
JV+ZLzLT/e3MBzjdkgcXZDQQAAAEANLoS7phEEVMxZKiC03q0NNmTUFmx85P3TiDSiXtYe
7ZlAK9fns0873twevFWeVBYOQ30QhEJc1mKanjEvXcc1AAAAQQDwNqt5yA6KvzdV3dH1ZX
rTwWx1CO5ERpuMSOAQhk3y6hfmeLa5HnbSCP5Z3uVqizEDnGXkvRfhSyfEUu/jJTU1AAAA
QQDtEmQvWdgz+HtIuTG1ySJ9FYO6LeCEXHtQX78aOfNaj2jqLTXHdqrMr0V5exJcNV4XSc
8e9dZXl8OX+9Ub0Y91AAAAGmZjaG9ybmV5QEZlcm5hbmRvcy1NQlAubGFu
-----END OPENSSH PRIVATE KEY-----
"""

@testset "git_push" begin
    function create_local_remote(dir::AbstractString)
        remote_path = joinpath(dir, "localremote.git")
        run(`git init --bare $remote_path`)

        return remote_path
    end

    pushed_str = "HEAD -> main, origin/main"

    @testset "basic push" begin
        mktempdir() do local_remote_dir
            mktempdir() do f
                local_remote_path = create_local_remote(local_remote_dir)

                cd(f) do
                    run(`git init`)
                    run(`git remote add origin $local_remote_path`)

                    run(`touch foobar.txt`)
                    UpdateManifests.git_add()
                    UpdateManifests.git_commit("Message")

                    output = read(`git log --decorate`, String)
                    @test !occursin(pushed_str, output)

                    UpdateManifests.git_push("origin", "main")

                    output = read(`git log --decorate`, String)
                    @test occursin(pushed_str, output)
                end
            end
        end
    end

    @testset "force push" begin
        mktempdir() do local_remote_dir
            mktempdir() do f
                local_remote_path = create_local_remote(local_remote_dir)

                cd(f) do
                    run(`git init`)
                    run(`git remote add origin $local_remote_path`)

                    run(`touch foobar.txt`)
                    UpdateManifests.git_add()
                    UpdateManifests.git_commit("Message 1")

                    output = read(`git log --decorate`, String)
                    @test !occursin(pushed_str, output)

                    UpdateManifests.git_push("origin", "main")

                    output = read(`git log --decorate`, String)
                    @test occursin(pushed_str, output)
                    @test occursin("Message 1", output)

                    run(`touch baz.txt`)
                    UpdateManifests.git_add()
                    run(
                        `git -c user.name=user -c user.email=email commit --amend --no-edit -m "Message 2"`,
                    )

                    UpdateManifests.git_push("origin", "main"; force=true)
                    output = read(`git log --decorate`, String)
                    @test occursin(pushed_str, output)
                    @test occursin("Message 2", output)
                end
            end
        end
    end

    @testset "SSH push" begin
        mktempdir() do local_remote_dir
            mktempdir() do f
                local_path = joinpath(f, UpdateManifests.LOCAL_REPO_NAME)
                pkey = joinpath(f, "privatekey")

                open(pkey, "w") do io
                    print(io, TEST_PKEY)
                end

                local_remote_path = create_local_remote(local_remote_dir)

                cd(f) do
                    run(`git init`)
                    run(`git remote add origin $local_remote_path`)

                    run(`touch foobar.txt`)
                    UpdateManifests.git_add()
                    UpdateManifests.git_commit("Message")

                    output = read(`git log --decorate`, String)
                    @test !occursin(pushed_str, output)

                    UpdateManifests.git_push("origin", "main", pkey)

                    output = read(`git log --decorate`, String)
                    @test occursin(pushed_str, output)
                end
            end
        end
    end
end

@testset "git_reset" begin
    mktempdir() do f
        cd(f) do
            run(`git init`)

            @test !isfile("foobar.txt")

            run(`touch foobar.txt`)
            UpdateManifests.git_add()
            @test UpdateManifests.git_commit("Message")

            @test !isfile("bazbar.txt")

            run(`touch bazbar.txt`)
            UpdateManifests.git_add()
            @test UpdateManifests.git_commit("Message2")

            @test isfile("foobar.txt")
            @test isfile("bazbar.txt")

            hash = read(`git rev-parse HEAD`, String)
            UpdateManifests.git_reset("HEAD~1"; soft=true)

            @test isfile("foobar.txt")
            @test isfile("bazbar.txt")

            sleep(1) # To make sure we get a new timestamp
            @test UpdateManifests.git_commit("Message2")

            new_hash = read(`git rev-parse HEAD`, String)
            @test hash != new_hash
        end
    end
end

@testset "git_commit" begin
    @testset "success" begin
        mktempdir() do f
            cd(f) do
                run(`git init`)
                run(`touch foobar.txt`)
                UpdateManifests.git_add()

                @test UpdateManifests.git_commit("Message")
            end
        end
    end

    @testset "failure" begin
        mktempdir() do f
            cd(f) do
                run(`git init`)
                run(`touch foobar.txt`)
                UpdateManifests.git_add()

                # Manually create an index lock file, so that the commit fails
                run(`touch .git/index.lock`)

                @test !UpdateManifests.git_commit("Message")
            end
        end
    end
end

@testset "git_branch" begin
    branch = "foobar"

    @testset "no checkout" begin
        mktempdir() do f
            cd(f) do
                run(`git init`)
                run(`touch foobar.txt`)
                UpdateManifests.git_add()
                UpdateManifests.git_commit("Message")

                output = strip(read(`git branch`, String))
                @test output == "* main"

                UpdateManifests.git_branch(branch)

                output = strip(read(`git branch`, String))
                @test output == "$branch\n* main"

                UpdateManifests.git_checkout(branch)

                output = strip(read(`git branch`, String))
                @test output == "* $branch\n  main"
            end
        end
    end

    @testset "with checkout" begin
        mktempdir() do f
            cd(f) do
                run(`git init`)
                run(`touch foobar.txt`)
                UpdateManifests.git_add()
                UpdateManifests.git_commit("Message")

                output = strip(read(`git branch`, String))
                @test output == "* main"

                UpdateManifests.git_branch(branch; checkout=true)

                output = strip(read(`git branch`, String))
                @test output == "* $branch\n  main"
            end
        end
    end
end

@testset "git_add" begin
    untracked_str = "Untracked files"
    committed_str = "Changes to be committed"

    mktempdir() do f
        cd(f) do
            run(`git init`)
            run(`touch foo.txt`)
            run(`touch bar.txt`)

            output = read(`git status`, String)
            @test occursin(untracked_str, output)

            UpdateManifests.git_add()

            output = read(`git status`, String)
            @test !occursin(untracked_str, output)
            @test occursin(committed_str, output)
        end
    end
end

@testset "get_git_name_and_email" begin
    @testset "using defaults" begin
        expected = (
            UpdateManifests.UpdateManifests_GIT_COMMITTER_NAME,
            UpdateManifests.UpdateManifests_GIT_COMMITTER_EMAIL,
        )

        results = UpdateManifests.get_git_name_and_email()
        @test results == expected
    end

    @testset "setting env vars" begin
        expected = ("User", "Email")

        withenv("GIT_COMMITTER_NAME" => "User", "GIT_COMMITTER_EMAIL" => "Email") do
            results = UpdateManifests.get_git_name_and_email()
            @test results == expected
        end
    end
end

@testset "git_clone" begin
    @testset "HTTPS" begin
        mktempdir() do f
            cd(f) do
                local_path = joinpath(f, UpdateManifests.LOCAL_REPO_NAME)
                UpdateManifests.git_clone(
                    "https://github.com/JuliaRegistries/CompatHelper.jl/", local_path
                )

                @test !isempty(readdir(local_path))
            end
        end
    end

    @testset "SSH" begin
        mktempdir() do f
            cd(f) do
                local_path = joinpath(f, UpdateManifests.LOCAL_REPO_NAME)

                apply(make_ssh_clone_patch(local_path)) do
                    UpdateManifests.git_clone(
                        "git@github.com:JuliaRegistries/UpdateManifests.jl.git", local_path
                    )
                end

                @test !isempty(readdir(local_path))
            end
        end
    end
end

@testset "git_checkout" begin
    main = "main"

    mktempdir() do f
        cd(f) do
            run(`git init`)
            # Need to create a commit before hand, see below
            # https://stackoverflow.com/a/63480330/1327636
            run(`touch foobar.txt`)
            UpdateManifests.git_add()
            UpdateManifests.git_commit("Message")

            UpdateManifests.git_checkout(main)
            result = String(read((`git branch --show-current`)))

            @test contains(result, main)
        end
    end
end

@testset "git_get_main_branch" begin
    @testset "default branch" begin
        branch = "main"
        mktempdir() do f
            cd(f) do
                run(`git init`)
                run(`touch foobar.txt`)
                UpdateManifests.git_add()
                UpdateManifests.git_commit("Message")
                UpdateManifests.git_checkout(branch)

                @test UpdateManifests.git_get_main_branch(UpdateManifests.DefaultBranch()) ==
                      branch
            end
        end
    end

    @testset "main branch" begin
        branch = "main"
        mktempdir() do f
            cd(f) do
                run(`git init`)
                run(`git branch -m $branch`)
                run(`touch foobar.txt`)
                UpdateManifests.git_add()
                UpdateManifests.git_commit("Message")
                UpdateManifests.git_checkout(branch)

                @test UpdateManifests.git_get_main_branch(branch) == branch
            end
        end
    end
end
