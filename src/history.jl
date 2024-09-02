"""
    EventHistory(events, nodes, spells)
    EventHistory(events)

Type representing a relational event history. This holds a sorted list of events and
the nodes that appear throughout the observation period, as well as their activity spells.
"""
mutable struct EventHistory{A,T,E<:AbstractRelationalEvent{A,T},R<:AbstractRange{T}}
    events::Vector{E}
    nodes::Vector{Node{A}}
    spells::Vector{R}

    function EventHistory(
        events::Vector{E},
        nodes::Vector{Node{A}},
        spells::Vector{R}
    ) where {A,T,E<:AbstractRelationalEvent{A,T},R<:AbstractRange{T}}
        all(a.idx == i for (i, a) in enumerate(nodes)) || error("Node indexes need to be contiguous.")
        new{A,T,E,R}(events, nodes, spells)
    end
end

function EventHistory(events::AbstractVector{<:AbstractRelationalEvent{A,T}}) where {A,T}
    # events = sort(events, by=eventtime)
    nodes = Set{Node{A}}()
    for e in events
        push!(nodes, e.src)
        push!(nodes, e.dst)
    end
    nodes = sort!(collect(nodes); by=t -> t.idx)
    spells = fill(typemin(T):typemax(T), length(nodes))
    EventHistory(events, nodes, spells)
end

function _tonode(e, ns)
    map(enumerate(e)) do (i, field)
        i == 1 || i == 2 ? ns[field] : field
    end
end

function EventHistory{A,T,E}(events) where {A,T,E<:AbstractRelationalEvent}
    ns = Dict{A,Node{A}}()
    i = 1
    es = map(events) do e
        for a in (e[1], e[2])
            haskey(ns, a) && continue
            push!(ns, a => Node(Int32(i), a))
            i += 1
        end
        E(_tonode(e, ns)...)
    end
    ns = sort!(collect(values(ns)); by=t -> t.idx)
    spells = fill(typemin(T):typemax(T), length(ns))
    EventHistory(es, ns, spells)
end

events(hist::EventHistory) = hist.events
nodes(hist::EventHistory) = hist.nodes
spells(hist::EventHistory) = hist.spells
entry(node::Node, hist::EventHistory) = first(hist.spells[node.idx])
exit(node::Node, hist::EventHistory) = last(hist.spells[node.idx])

eventtype(::EventHistory{A,T,E}) where {A,T,E} = E
timetype(::EventHistory{A,T}) where {A,T} = T
actortype(::EventHistory{A}) where {A} = A

# Iteration and indexing interfaces

Base.length(hist::EventHistory) = length(hist.events)
Base.iterate(hist::EventHistory) = iterate(hist.events)
Base.iterate(hist::EventHistory, state) = iterate(hist.events, state)

Base.getindex(hist::EventHistory, i) = getindex(hist.events, i)
Base.setindex!(hist::EventHistory, v, i) = setindex!(hist.events, v, i)
Base.firstindex(hist::EventHistory) = Base.firstindex(hist.events)
Base.lastindex(hist::EventHistory) = Base.lastindex(hist.events)

function Base.show(io::IO, h::EventHistory)
    compact = get(io, :compact, true)
    print_history(io, h, compact)
end

function Base.show(io::IO, ::MIME"text/plain", e::EventHistory)
    compact = get(io, :compact, false)
    print_history(io, e, compact)
end

function _format(x::Integer)
    str = collect(string(x))
    out = Char[]
    n = 1
    while !isempty(str)
        push!(out, pop!(str))
        n % 3 == 0 && !isempty(str) && push!(out, ',')
        n += 1
    end
    String(reverse(out))
end

function print_history(io, h::EventHistory{A,T,E}, compact) where {A,T,E}
    nnodes = length(nodes(h))
    nevents = length(events(h))
    if compact
        print(io, "EventHistory{$A, $T, $E, ...}")
    else
        println(io, "EventHistory with $(_format(nevents)) events and $(_format(nnodes)) nodes")
        println(io, " event type: $E")
        println(io, " actor type: $A")
        println(io, " time  type: $T")
    end
end

# Choice / risk set querying

"""
    isactive(h, i, t)

Check if the `i`th actor is active at time `t`. Note that when 
nodes `nodes(h)` are represented by a range of contiguous
integers, `i` is equal to `nodes(h)[i]`.
"""
isactive(h::EventHistory{A,T}, i::Integer, t::T) where {A,T} = t in h.spells[i]
isactive(h::EventHistory{A,T}, i::Node{A}, t::T) where {A,T} = t in h.spells[i.idx]

riskset(h::EventHistory, t) = filter(a -> isactive(h, a, t), nodes(h))

