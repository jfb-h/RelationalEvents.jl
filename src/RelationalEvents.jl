module RelationalEvents

using StatsBase: sample
using SparseArrayKit: SparseArray

export AbstractRelationalEvent, RelationalEvent, MarkedRelationalEvent
export src, dst, eventtime, mark

export EventHistory
export events, actors
export isactive, riskset

export EventProcess, Spec, sample_riskset, compute, inertia, reciprocity, update_weights!, generate

include("core.jl")
include("history.jl")
include("eventprocess.jl")
include("statistics.jl")

include("../test/fake-data.jl") # for testing

#TODO: Further profile allocations

#TODO: Stats macro and process updating logic

#TODO: Tests for eventprocesses and statistics

#TODO: Show methods for RelationalEvent, EventHistory, etc.

#TODO: Set up docs

end # module
