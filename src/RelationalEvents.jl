module RelationalEvents

using StatsBase: sample
using SparseArrayKit: SparseArray

export AbstractRelationalEvent, RelationalEvent, MarkedRelationalEvent
export src, dst, eventtime, mark

export EventHistory
export events, actors
export isactive, riskset

export Spec
export statistics
export inertia, reciprocity

include("core.jl")
include("history.jl")
include("eventprocess.jl")
include("statistics.jl")

include("../test/fake-data.jl") # for testing

#TODO: improve MarkedRelationalEvent support

#TODO: Makie plotting recipies

#TODO: Stats macro and process updating logic

#TODO: Add further standard statistics

#TODO: Further profile allocations

end # module
