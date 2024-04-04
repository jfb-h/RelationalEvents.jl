mutable struct EventHistory{A,T,E<:AbstractRelationalEvent{A,T},V<:AbstractArray{E},R<:AbstractRange{T}}
    events::V
    actors::Vector{A}
    spells::Vector{R}
end

function EventHistory(events::AbstractVector{<:AbstractRelationalEvent{A,T}}) where {A,T}
    actors = actortype(first(events))[]
    for e in events
        push!(actors, src(e))
        push!(actors, dst(e))
    end
    unique!(actors)

    sort!(events, by=eventtime)

    spells = fill(typemin(T):typemax(T), length(actors))

    EventHistory(events, actors, spells)
end

events(hist::EventHistory) = hist.events
actors(hist::EventHistory) = hist.actors
spells(hist::EventHistory) = hist.spells

# Iteration and indexing interfaces

Base.length(hist::EventHistory) = length(hist.events)
Base.iterate(hist::EventHistory) = iterate(hist.events)
Base.iterate(hist::EventHistory, state) = iterate(hist.events, state)

Base.getindex(hist::EventHistory, i) = getindex(hist.events, i)
Base.setindex!(hist::EventHistory, v, i) = setindex!(hist.events, v, i)
Base.firstindex(hist::EventHistory) = Base.firstindex(hist.events)
Base.lastindex(hist::EventHistory) = Base.lastindex(hist.events)

# Choice / risk set querying

"""
    isactive(h, i, t)

Check if the `i`th actor is active at time `t`. Note that when 
actors `actors(h)` are represented by a range of contiguous
integers, `i` is equal to `actors(h)[i]`.
"""
isactive(h::EventHistory, i::Integer, t)::Bool = t in spells(h)[i]
riskset(h::EventHistory, t) = findall(a -> isactive(h, a, t), actors(h))

function before(hist::EventHistory{A,T,E}, t::T) where {A,T,E<:AbstractRelationalEvent{A,T}}
    i = searchsortedfirst(events(hist), E(time=t); by=eventtime)
    EventHistory(view(events(hist), firstindex(events(hist), i)), actors(hist), spells(hist))
end

# function tosparse(hist::EventHistory)
#     N, M = length(hist), length(actors(hist))
#     dims = (N, M, M)
#     data = Dict(map(enumerate(events(hist))) do (i, e)
#         CartesianIndex(i, sender(e), receiver(e)) => true
#     end)
#
#     SparseArray{Bool,3}(data, dims)
# end


