abstract type AbstractRelationalEvent{A,T} end

actortype(::AbstractRelationalEvent{A,T}) where {A,T} = A
timetype(::AbstractRelationalEvent{A,T}) where {A,T} = T

@kwdef struct RelationalEvent{A,T} <: AbstractRelationalEvent{A,T}
    # default is to enable convenient searchsortedfirst (not sure if worth, but also not sure if problematic)
    src::A = 0
    dst::A = 0
    time::T
end

@kwdef struct MarkedRelationalEvent{A,T,M} <: AbstractRelationalEvent{A,T}
    src::A = 0
    dst::A = 0
    time::T
    mark::M = 0
end

src(e::AbstractRelationalEvent) = e.src
dst(e::AbstractRelationalEvent) = e.dst
eventtime(e::AbstractRelationalEvent) = e.time
mark(e::MarkedRelationalEvent) = e.mark

