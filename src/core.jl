abstract type AbstractRelationalEvent{A,T} end

actortype(::AbstractRelationalEvent{A,T}) where {A,T} = A
timetype(::AbstractRelationalEvent{A,T}) where {A,T} = T

src(e::AbstractRelationalEvent) = e.src
dst(e::AbstractRelationalEvent) = e.dst
eventtime(e::AbstractRelationalEvent) = e.time

function Base.show(io::IO, e::AbstractRelationalEvent)
    compact = get(io, :compact, true)
    print_event(io, e, compact)
end

function Base.show(io::IO, ::MIME"text/plain", e::AbstractRelationalEvent)
    compact = get(io, :compact, false)
    print_event(io, e, compact)
end


"""
    RelationalEvent(sender, receiver, time)

Type to represent a basic unmarked relational event containing the
sender, the receiver, and the timestamp of the event.

Sender and receiver are required to be of the same type.

# Examples

```jldoctest
julia> sender = 2;

julia> receiver = 4;

julia> time = 1.0;

julia> RelationalEvent(sender, receiver, time)
RelationalEvent{Int64, Float64}
 sender: 2
 receiver: 4
 time: 1.0
```
"""
struct RelationalEvent{A,T} <: AbstractRelationalEvent{A,T}
    src::A
    dst::A
    time::T
end

function print_event(io, e::RelationalEvent, compact)
    if compact
        print(io, "($(src(e)), $(dst(e)), $(eventtime(e)))")
    else
        println(typeof(e))
        println(" sender: $(src(e))")
        println(" receiver: $(dst(e))")
        println(" time: $(eventtime(e))")
    end
end

struct MarkedRelationalEvent{A,T,M} <: AbstractRelationalEvent{A,T}
    src::A
    dst::A
    time::T
    mark::M
end

mark(e::MarkedRelationalEvent) = e.mark

function print_event(io, e::MarkedRelationalEvent, compact)
    if compact
        print(io, "($(src(e)), $(dst(e)), $(eventtime(e)), $(mark(e))")
    else
        println(typeof(e))
        println(" sender: $(src(e))")
        println(" receiver: $(dst(e))")
        println(" time: $(eventtime(e))")
        println(" mark: $(mark(e))")
    end
end

