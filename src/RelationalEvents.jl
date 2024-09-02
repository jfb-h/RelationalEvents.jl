module RelationalEvents

using StatsBase: sample, Weights
using SparseArrayKit: SparseArray
# using StreamSampling: itsample

export AbstractRelationalEvent, RelationalEvent, MarkedRelationalEvent
export src, dst, eventtime, mark

export EventHistory
export events, nodes
export spells
export isactive, riskset

export Spec
export statistics
export inertia, reciprocity
export activity, popularity, assortativity

include("core.jl")
include("history.jl")
include("eventprocess.jl")
include("statistics.jl")

# include("../test/fake-data.jl") # for testing

#TODO: improve activity handling (maintain active / inactive list in EventProcess)

#TODO: spells constructor

#TODO: make Survival an extension

#TODO: Makie plotting recipies

#TODO: Add further standard statistics

end # module
