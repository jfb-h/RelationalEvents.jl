module RelationalEvents

using Dates

export AbstractRelationalEvent, RelationalEvent, MarkedRelationalEvent
export sender, receiver, eventtime, mark

export EventHistory
export events
export active, riskset

export Window
export inertia

include("core.jl")
include("history.jl")
include("statistics.jl")

include("../test/fake-data.jl") # for testing

end # module
