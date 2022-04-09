```@meta
CurrentModule = UpdateManifests
```

```@autodocs
Modules = [UpdateManifests]
```

# [UpdateManifests.jl](https://github.com/JuliaRegistries/UpdateManifests.jl)

UpdateManifests is a Julia package that helps you keep your `[compat]` entries up-to-date.
Whenever one of your package's dependencies releases a new breaking version, UpdateManifests opens a pull request on your repository that modifies your `[compat]` entry to reflect the newly released version.
We would like to eventually add Julia support to [Dependabot](https://dependabot.com).
If you would like to help with adding Julia support to Dependabot, join us in the `#dependabot` channel on the [Julia Language Slack](https://julialang.org/slack/).

## Installation
### GitHub
Create a file at `.github/workflows/UpdateManifests.yml` with the contents of the [UpdateManifests.yml](https://github.com/JuliaRegistries/UpdateManifests.jl/blob/main/.github/workflows/UpdateManifests.yml) that is included in this repository.

If you need to use any special arguments for the `main` function, you can modify this file to add them.

### GitLab
For GitLab you will want to add UpdateManifests as a job in your `.gitlab-ci.yml` file such as:

```yaml
UpdateManifests:
  image: julia:1.6 # Set to the Julia version you want to use
  stage: compat # You can place this in any stage that makes sense for your setup
  before_script:
    - apt-get update -qq && apt-get install -y git
    - |
      julia --color=yes -e "
        import Pkg;
        name = \"UpdateManifests\";
        uuid = \"aa819f21-2bde-4658-8897-bab36330d9b7\";
        version = \"3\";
        Pkg.add(; name, uuid, version)"
  script:
    - |
      julia --color=yes -e "
        import UpdateManifests;
        UpdateManifests.main()"
```

Similarly to the GitHub setup, you can modify the `main` call here if you need to change any of the default arguments.
You must also remember to add the `GITLAB_TOKEN` and `UpdateManifests_PRIV` CI secrets to the project so that UpdateManifests can find them.

#### Creating SSH Key
If you use GitHub Actions to either test your packge using continuous integration, or build and deploy documentation you will need to create an SSH deploy key.
If you wish to reuse an existing SSH key simplify modify the workflow above environment variable to use `UpdateManifests_PRIV: ${{ secrets.DOCUMENTER_KEY }}`.
Otherwise follow the below instructions to generate a new key,

1. Generate a new SSH key
   1. `ssh-keygen -m PEM -N "" -f UpdateManifests_key`
2. Create a new GitHub secret
   1. Copy the private key, `cat UpdateManifests_key`
   2. Go to your repositories settings page
   3. Select `Secrets`, and `New Repository Secret`
   4. Name the secret `UpdateManifests_PRIV`, paste the copied private key
3. Create a new deploy key
   1. Copy the public key, `cat UpdateManifests_key.pub`
   2. Go to your repositories settings page
   3. Select `Deploy Keys`, and `Add Deploy Key`
   4. Name the deploy key `UpdateManifests_PUB`, paste in the copied public key
   5. Ensure that the key has `Write Access`
4. Cleanup the SSH key from your computer, `rm -f UpdateManifests_key UpdateManifests_key.pub`

##### Base64 SSH Public Key
UpdateManifests also supports Base64 encoded SSH Public Keys. One reason for this would be for GitLab usage. On GitLab, if you add an SSH privary key to the CI secrets, if for any reason it prints out, it will show up in the log in plain text. To fix this, you can encode the private key in Base64 which is a format that GitLab can mask in log files.

Once you have created your SSH Public Key as mentioned above, before you delete it, you can convert it to Base64 like so:

```bash
openssl enc -base64 -in UpdateManifests_key.pub -out UpdateManifests_key.pub.base64
```

You can then use the Base64 version in your CI Secret rather than the plain text version. Once that is done, you can delete it from your computer.
