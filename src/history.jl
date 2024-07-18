"""
    EventHistory(events, actors, spells)
    EventHistory(events)

Type representing a relational event history. This holds a sorted list of events and
the actors that appear throughout the observation period, as well as their activity spells.
"""
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
    nactors = length(actors(h))
    nevents = length(events(h))
    if compact
        print(io, "EventHistory{$A, $T, $E, ...}")
    else
        println(io, "EventHistory with $(_format(nevents)) events and $(_format(nactors)) actors")
        println(io, " event type: $E")
        println(io, " actor type: $A")
        println(io, " time  type: $T")
    end
end

# Choice / risk set querying

"""
    isactive(h, i, t)

Check if the `i`th actor is active at time `t`. Note that when 
actors `actors(h)` are represented by a range of contiguous
integers, `i` is equal to `actors(h)[i]`.
"""
isactive(h::EventHistory, i::Integer, t)::Bool = t in spells(h)[i]
riskset(h::EventHistory, t) = findall(a -> isactive(h, a, t), actors(h))

