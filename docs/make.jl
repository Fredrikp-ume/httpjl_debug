using Documenter, MvdaServer

makedocs(
    modules = [MvdaServer],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Fredrik Pettersson",
    sitename = "MvdaServer.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/Fredrikp-ume/MvdaServer.jl.git",
    push_preview = true
)
