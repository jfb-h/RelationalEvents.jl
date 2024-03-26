module RelationalEvents

using Dates

export AbstractRelationalEvent, RelationalEvent, MarkedRelationalEvent
export EventHistory

export sender, receiver, eventtime, mark
export active, riskset

abstract type AbstractRelationalEvent{A,T} end

actortype(::AbstractRelationalEvent{A,T}) where {A,T} = A
timetype(::AbstractRelationalEvent{A,T}) where {A,T} = T

sender(e::AbstractRelationalEvent) = e.sender
receiver(e::AbstractRelationalEvent) = e.receiver
eventtime(e::AbstractRelationalEvent) = e.time

struct RelationalEvent{A,T} <: AbstractRelationalEvent{A,T}
  sender::A
  receiver::A
  time::T
end

struct MarkedRelationalEvent{A,T,M} <: AbstractRelationalEvent{A,T}
  sender::A
  receiver::A
  time::T
  mark::M
end

mark(e::MarkedRelationalEvent) = e.mark

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
  min, max = extrema(eventtime, events)
  EventHistory(events, actors, fill(min, length(actors)), fill(max, length(actors)))
end

Base.length(hist::EventHistory) = length(hist.events)
Base.iterate(hist::EventHistory) = iterate(hist.events)
Base.iterate(hist::EventHistory, state) = iterate(hist.events, state)

Base.getindex(hist::EventHistory, i) = getindex(hist.events, i)
Base.setindex!(hist::EventHistory, v, i) = setindex!(hist.events, v, i)
Base.firstindex(hist::EventHistory) = Base.firstindex(hist.events)
Base.lastindex(hist::EventHistory) = Base.lastindex(hist.events)

function active(h::EventHistory, a, t)::Bool
  h.entries[a] <= t <= h.exits[a]
end

function riskset(h::EventHistory{E,A}, t)::Vector{A} where {E,A}
  findall(a -> active(h, a, t), h.actors)
end

end # module
