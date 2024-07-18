using Documenter, RelationalEvents

# push!(LOAD_PATH, "../src/")

makedocs(
    sitename="RelationalEvents.jl",
    pages=[
        "index.md",
        "Introduction" => "introduction.md",
        "Examples" => "examples.md",
        "Reference" => "api.md",
    ]
)

deploydocs(
    repo="github.com/USER_NAME/PACKAGE_NAME.jl.git",
)
