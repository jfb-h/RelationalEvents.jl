mutable struct EventHistory{A,T,E<:AbstractRelationalEvent{A,T}}
    events::Vector{E}
    actors::Vector{A}
    entries::Union{Vector{T},Dict{A,T}}
    exits::Union{Vector{T},Dict{A,T}}
end

function EventHistory(events::Vector{<:AbstractRelationalEvent{A,T}}) where {A,T}
    actors = actortype(first(events))[]
    for e in events
        push!(actors, sender(e))
        push!(actors, receiver(e))
    end
    unique!(actors)

    sort!(events, by=eventtime)

    min, max = extrema(eventtime, events)
    entries = fill(min, length(actors))
    exits = fill(max, length(actors))

    EventHistory(events, actors, entries, exits)
end

# Iteration and indexing interfaces

Base.length(hist::EventHistory) = length(hist.events)
Base.iterate(hist::EventHistory) = iterate(hist.events)
Base.iterate(hist::EventHistory, state) = iterate(hist.events, state)

Base.getindex(hist::EventHistory, i) = getindex(hist.events, i)
Base.setindex!(hist::EventHistory, v, i) = setindex!(hist.events, v, i)
Base.firstindex(hist::EventHistory) = Base.firstindex(hist.events)
Base.lastindex(hist::EventHistory) = Base.lastindex(hist.events)

# Choice / risk set querying

active(h::EventHistory, a, t)::Bool = h.entries[a] <= t <= h.exits[a]
riskset(h::EventHistory, t) = findall(a -> active(h, a, t), h.actors)
