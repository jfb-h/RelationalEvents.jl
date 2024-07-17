mutable struct EventHistory{A,T,E<:AbstractRelationalEvent{A,T},V<:AbstractArray{E},R<:AbstractRange{T}}
    events::V
    actors::Vector{A}
    spells::Vector{R}
end

function EventHistory(events::AbstractVector{<:AbstractRelationalEvent{A,T}}) where {A,T}
    sort!(events, by=eventtime)
    actors = Set{A}()
    for e in events
        push!(actors, src(e))
        push!(actors, dst(e))
    end
    actors = sort!(collect(actors))
    spells = fill(typemin(T):typemax(T), length(actors))
    EventHistory(events, actors, spells)
end

events(hist::EventHistory) = hist.events
actors(hist::EventHistory) = hist.actors
spells(hist::EventHistory) = hist.spells

actortype(::EventHistory{A,T,E,V,R}) where {A,T,E,V,R} = A
eventtype(::EventHistory{A,T,E,V,R}) where {A,T,E,V,R} = E
timetype(::EventHistory{A,T,E,V,R}) where {A,T,E,V,R} = T

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

