module RelationalEvents

using Dates
using Accessors
using OhMyThreads: tmap

export AbstractRelationalEvent, RelationalEvent, MarkedRelationalEvent
export sender, receiver, eventtime, mark

export EventHistory
export events, actors
export isactive, riskset

export Window, WindowPrevious
export window

export NoDecay, LinearDecay, ExponentialDecay

export inertia

include("core.jl")
include("history.jl")
include("window-decay.jl")
include("statistics.jl")

include("../test/fake-data.jl") # for testing

end # module
