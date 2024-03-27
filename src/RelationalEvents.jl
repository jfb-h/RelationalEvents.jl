module RelationalEvents

using Dates

export AbstractRelationalEvent, RelationalEvent, MarkedRelationalEvent
export EventHistory

export sender, receiver, eventtime, mark
export active, riskset

include("core.jl")
include("history.jl")
include("statistics.jl")

end # module
