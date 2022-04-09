```@meta
CurrentModule = UpdateManifests
```

# Troubleshooting

Here are some tips for troubleshooting UpdateManifests.

## UpdateManifests workflow file

The first step is to update your UpdateManifests workflow file, which is usually
located  in your repository at `.github/workflows/UpdateManifests.yml.` Make sure
that this file exactly matches the contents of the file located at [https://github.com/JuliaRegistries/UpdateManifests.jl/blob/main/.github/workflows/UpdateManifests.yml](https://github.com/JuliaRegistries/UpdateManifests.jl/blob/main/.github/workflows/UpdateManifests.yml).

## Manifest files

If UpdateManifests is still failing, try deleting the following files (if they
exist):
- `/Manifest.toml`
- `/test/Manifest.toml`
- `/JuliaManifest.toml`
- `/test/JuliaManifest.toml`

If you continue to experience errors, try deleting all `Manifest.toml` files
and `JuliaManifest.toml` files from your repository.
