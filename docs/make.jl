using RelationalEvents
using Documenter

DocMeta.setdocmeta!(RelationalEvents, :DocTestSetup, :(using RelationalEvents); recursive=true)

makedocs(;
    modules=[RelationalEvents],
    authors="Jakob Hoffmann <jfb-hoffmann@hotmail.de> and contributors",
    sitename="RelationalEvents.jl",
    format=Documenter.HTML(;
        canonical="https://jfb-h.github.io/RelationalEvents.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "index.md",
        "Introduction" => "introduction.md",
        "Examples" => "examples.md",
        "Reference" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/jfb-h/RelationalEvents.jl",
    devbranch="main",
)
