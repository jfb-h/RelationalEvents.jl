library(goldfish)
library(readr)

edgelist <- read_csv("hist.csv")
edgelist$increment <- 1
edgelist$sender <- as.character(edgelist$sender)
edgelist$receiver <- as.character(edgelist$receiver)
edgelist$time <- as.POSIXct(edgelist$time)


actors <- tibble(label = as.character(1:1000))

net <- defineNetwork(nodes = actors, directed = TRUE) |>
    linkEvents(changeEvent = edgelist, nodes = actors)

dep <- defineDependentEvents(
    events = edgelist, nodes = actors,
    defaultNetwork = net
)

choice <- estimate(
    dep ~ inertia + recip,
    model = "DyNAM", subModel = "choice"
)

rate <- estimate(
    dep ~ indeg + outdeg,
    model = "DyNAM", subModel = "rate"
)
