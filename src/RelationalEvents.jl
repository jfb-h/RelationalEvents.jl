module RelationalEvents

using Dates
using Accessors
using OhMyThreads: tmap

export AbstractRelationalEvent, RelationalEvent, MarkedRelationalEvent
export src, dst, eventtime, mark

export EventHistory
export events, actors
export isactive, riskset

export AbstractDecay, Window, NoDecay, LinearDecay, ExponentialDecay

export AbstractStatistic
export @statistic

export Inertia, Reciprocity, Transitivity

include("core.jl")
include("history.jl")
include("window-decay.jl")
include("statistics.jl")

include("../test/fake-data.jl") # for testing

end # module
