module RelationalEvents

using Dates

abstract type AbstractRelationalEvent end

struct RelationalEvent{S,R,T}
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

struct History{E<:AbstractRelationalEvent,A}
  events::Vector{E}
  actors::Vector{A}
end

function active(h::History{E,A}, t)::Vector{A} where {E,A}
end

function active(h::History, a, t)::Bool
end

end # module
