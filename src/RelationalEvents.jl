module RelationalEvents

using Dates

export RelationalEvent
export EventHistory
export active

abstract type AbstractRelationalEvent end

struct RelationalEvent{S,R,T} <: AbstractRelationalEvent
  sender::S
  receiver::R
  time::T
end

struct MarkedRelationalEvent{S,R,T,M}
  sender::S
  receiver::R
  time::T
  mark::M
end

struct EventHistory{E<:AbstractRelationalEvent,A,T}
  events::Vector{E}
  actors::Vector{A}
  entries::Vector{T}
  exits::Vector{T}
end

function active(h::EventHistory, a, t)::Bool
  h.entries[a] <= t <= h.exits[a]
end

function active(h::EventHistory{E,A}, t)::Vector{A} where {E,A}
  findall(a -> active(h, a, t), h.actors)
end


end # module
