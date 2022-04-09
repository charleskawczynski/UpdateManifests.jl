using UpdateManifests
using Documenter

DocMeta.setdocmeta!(UpdateManifests, :DocTestSetup, :(using UpdateManifests); recursive=true)

makedocs(;
    modules=[UpdateManifests],
    authors="Dilum Aluthge, Brown Center for Biomedical Informatics, and contributors",
    repo="https://github.com/JuliaRegistries/UpdateManifests.jl/blob/{commit}{path}#{line}",
    sitename="UpdateManifests.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaRegistries.github.io/UpdateManifests.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Configuration Options" => "options.md",
        "Acknowledgements" => "acknowledgements.md",
        "Other Environments" => "other-environments.md",
        "TroubleShooting" => "troubleshooting.md",
    ],
    strict=true,
)

deploydocs(; repo="github.com/JuliaRegistries/UpdateManifests.jl")
