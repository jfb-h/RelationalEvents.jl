abstract type AbstractRelationalEvent{A,T} end

actortype(::AbstractRelationalEvent{A,T}) where {A,T} = A
timetype(::AbstractRelationalEvent{A,T}) where {A,T} = T

src(e::AbstractRelationalEvent) = e.src.info
dst(e::AbstractRelationalEvent) = e.dst.info
isrc(e::AbstractRelationalEvent) = e.src.idx
idst(e::AbstractRelationalEvent) = e.dst.idx
eventtime(e::AbstractRelationalEvent) = e.time

isrc(e::Tuple) = e[1]
idst(e::Tuple) = e[2]
eventtime(e::Tuple) = e[3]

function Base.show(io::IO, e::AbstractRelationalEvent)
    compact = get(io, :compact, true)
    print_event(io, e, compact)
end

function Base.show(io::IO, ::MIME"text/plain", e::AbstractRelationalEvent)
    compact = get(io, :compact, false)
    print_event(io, e, compact)
end

"""
Wrapper struct containing node metadata and a contiguous integer index.
"""
struct Node{T}
    idx::Int32
    info::T
end

Node(i::Integer) = Node(convert(Int32, i), i)
Node(i::Integer, a) = Node(convert(Int32, i), a)

"""
    RelationalEvent(sender, receiver, time)


Type to represent a basic unmarked relational event containing the
sender, the receiver, and the timestamp of the event.

Sender and receiver are required to be `Node{T}`, where T can be any type.
Nodes carry a contiguous integer id alongside the node data.

# Examples

```julia
julia> sender = RelationalEvents.Node(1, "a");

julia> receiver = RelationalEvents.Node(2, "b");

julia> time = 1.0;

julia> RelationalEvent(sender, receiver, time)
RelationalEvent{String, Float64}
 sender: a
 receiver: b
 time: 1.0
```
"""
@kwdef struct RelationalEvent{A,T} <: AbstractRelationalEvent{A,T}
    src::Node{A}
    dst::Node{A}
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

"""
    MarkedRelationalEvent(sender, receiver, time, mark)

Type to represent a marked relational event containing the
sender, the receiver, the timestamp, and the mark of the event.

Sender and receiver are required to be `Node{T}`, where T can be any type.
Nodes carry a contiguous integer id alongside the node data.

# Examples

julia> sender = RelationalEvents.Node(1, "a");

julia> receiver = RelationalEvents.Node(2, "b");

julia> time = 1.0;

julia> mark = "x";

julia> MarkedRelationalEvent(sender, receiver, time, mark)
RelationalEvent{String, Float64, String}
 sender: a
 receiver: b
 time: 1.0
 mark: x
```
"""
@kwdef struct MarkedRelationalEvent{A,T,M} <: AbstractRelationalEvent{A,T}
    src::Node{A}
    dst::Node{A}
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


