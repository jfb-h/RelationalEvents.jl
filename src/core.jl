abstract type AbstractRelationalEvent{A,T} end

actortype(::AbstractRelationalEvent{A,T}) where {A,T} = A
timetype(::AbstractRelationalEvent{A,T}) where {A,T} = T

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

sender(e::AbstractRelationalEvent) = e.sender
receiver(e::AbstractRelationalEvent) = e.receiver
eventtime(e::AbstractRelationalEvent) = e.time
mark(e::MarkedRelationalEvent) = e.mark

