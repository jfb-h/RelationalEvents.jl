struct Spec
    N_events::Int
    N_cases::Int
    halflife::Float32
    tol::Float32
    startmult::Float32
end

struct EventProcess{W,E}
    # Sparse Array with weights for all pairs
    weights::SparseArray{W,2}
    # Sparse Array holding the last time a weight was updated
    wutimes::SparseArray{E,2}
end

"""
EventProcess struct holding sparse arrays with weights and weight update times.
This is updated iterativeley as statistics are computed.
"""
function EventProcess{W,E}(N) where {W,E}
    weights = SparseArray{W,2}(undef, (N, N))
    wutimes = SparseArray{E,2}(undef, (N, N))
    EventProcess{W,E}(weights, wutimes)
end

"""
    update_process!(p, e, spec)

Update weights and time-of-last-update of `EventProcess` `p` for the
dyad and event time given by `e` and the specification `spec`.

See also [`update_weights!`](@ref), [`update_wutimes!`](@ref)
"""
function update_process!(p::EventProcess, e, spec::Spec)
    update_weights!(p, e, spec)
    update_wutimes!(p, e)
    p
end

function update_wutimes!(p::EventProcess, e)
    s, d, t = src(e), dst(e), eventtime(e)
    p.wutimes[s, d] = t
end

function update_weights!(p::EventProcess, e, spec::Spec)
    s, d, t = src(e), dst(e), eventtime(e)
    t_prev = p.wutimes[s, d]
    p.weights[s, d] = exp(-(t - t_prev) * log(2) / spec.halflife) * p.weights[s, d]
    p.weights[s, d] < spec.tol && delete!(p.weights.data, CartesianIndex(s, d))
    p.weights[s, d]
end

function add_event!(p::EventProcess, e, spec::Spec)
    update_process!(p, e, spec)
    p.weights[src(e), dst(e)] += one(eltype(p.weights))
end

"""
    sample_riskset(h, t, spec)

Sample a set of `spec.N_cases` control events from the riskset, i.e.,
all possible dyads of actors active at time `t`.
"""
function sample_riskset(h::EventHistory{A,T}, t::T, spec::Spec) where {A,T}
    rs = riskset(h, t)
    nt = length(rs)
    spec.N_cases <= nt * (nt - 1) || error("Can't sample more than N * (N-1) cases")
    out = Vector{eventtype(h)}()
    sizehint!(out, spec.N_cases)
    while length(out) < spec.N_cases
        s, d = rand(rs), rand(rs)
        s == d && continue
        (s, d) in out && continue
        push!(out, RelationalEvent(s, d, t))
    end
    out
end

# function sample_riskset(h::EventHistory, t, spec::Spec)
#     # more elegant but sadly slower. Maybe transducers?
#     rs = Iterators.filter(a -> isactive(h, a, t), actors(h))
#     rs = Iterators.product(rs, rs)
#     rs = Iterators.filter(t -> t[1] != t[2], rs)
#     itsample(rs, spec.N_cases)
# end

struct EventStats{
    T<:AbstractMatrix{<:Real},
    I<:AbstractVector{<:Integer},
    D<:AbstractVector{<:AbstractRelationalEvent},
    N<:AbstractVector{<:AbstractString}
}
    stats::T
    idxs::I
    dyads::D
    statnames::N
    N_events::Int
    N_actors::Int

    # function EventStats(s, i, d, n) #TODO: figure out type parameters
    #
    #     s1, s2, s3 = size(s, 1), length(i), length(d)
    #
    #     s1 == s2 == s3 || throw(DimensionMismatch(
    #         "size(stats, 1) = $(s1), length(idxs) = $(s2), and length(dyads) = $(s3) but the three should be equal."))
    #
    #     size(s, 2) == length(n) || throw(DimensionMismatch(
    #         "size(stats, 2) = $(size(s, 2)) and length(statnames) = $(length(n)) but should be equal."))
    #
    #     new(s, i, d, n)
    # end
end


function Base.show(io::IO, h::EventStats)
    compact = get(io, :compact, true)
    print_history(io, h, compact)
end

function Base.show(io::IO, ::MIME"text/plain", e::EventStats)
    compact = get(io, :compact, false)
    print_history(io, e, compact)
end

function print_history(io, h::EventStats, compact)
    N_sampled = length(unique(h.idxs))
    N_cases = findfirst(!=(first(h.idxs)), h.idxs) - 1
    if compact
        print(io, "EventStats ($(join(h.statnames, ", ")))")
    else
        println(io, "EventStats ($(join(h.statnames, ", ")))")
        print(io, " sampled events: $(_format(N_sampled)) out of ")
        println(io, "$(_format(h.N_events)) ($(Int(round(N_sampled / h.N_events * 100, digits=0)))%)")
        println(io, " sampled cases:  $(_format(N_cases)) with $(_format(h.N_actors)) nodes")
    end
end

"""
    statistics(h, spec; statfuns...)

Compute the statistics provided as keyword arguments for the event history `h`
according to the specification in `spec`. Statistics are only computed for 
a sample of the specified sizes of events and control cases. Returns an `EventStats` object.

# Arguments

- `h::EventHistory`: The event history for which to compute statistics.
- `spec::Spec`: The specification for sampling, decay, etc.
- `statfuns::Function...`: Functions to compute event history statistics.

# Examples

```julia
hist = ... # EventHistory
spec = Spec(
    50,   # number of events to sample
    10,   # number of control cases to sample
    30,   # halflife time (e.g., days)
    0.01, # threshold at which to set dyads to zero
    2     # halflife multiplier after which to start sampling
)

res = statistics(hist, spec; inertia, reciprocity)
```
"""
function statistics(h::EventHistory{S,T,E}, spec::Spec; funcs...) where {S,T,E<:AbstractRelationalEvent}
    # check dimensions
    spec.N_events <= length(h) || throw(DimensionMismatch("Cannot sample more events than there are in the history"))
    # initialize event process
    A = length(actors(h))
    N = spec.N_events * (spec.N_cases + 1)
    p = EventProcess{Float32,Int32}(A)
    # allocate result objects
    stats = zeros(Float32, N, length(funcs))
    eidxs = zeros(Int32, N)
    dyads = Vector{E}(undef, N)
    # sample events for which to compute stats
    t0 = eventtime(first(h))
    sample_range = findfirst(e -> eventtime(e) >= (t0 + spec.startmult * spec.halflife), events(h)):length(h)
    sampl = Set(sample(sample_range, spec.N_events; replace=false))
    # loop over all events
    evcount = 0
    for (i, e) in enumerate(h)
        t = eventtime(e)
        # only compute stats for sampled events
        if i in sampl
            rs = riskset(h, t)
            rscount = 0
            while rscount < spec.N_cases + 1
                idx = evcount * (spec.N_cases + 1) + rscount + 1
                # sample event from riskset, first is always the observed
                c = rscount == 0 ? e : RelationalEvent(rand(rs), rand(rs), t)
                # reject loops and duplicates
                src(c) == dst(c) || c in view(dyads, (idx-rscount):idx) && continue
                # store event id and sampled event
                eidxs[idx] = i
                dyads[idx] = c
                # compute and store stats for all stats funs, update process
                for (j, (_, f)) in enumerate(pairs(funcs))
                    @views stats[idx, j] = f(c, p, h, spec)
                end
                rscount += 1
            end
            evcount += 1
        end
        # update process for every event, even if not sampled
        add_event!(p, e, spec)
    end
    statnames = [string(n) for (n, _) in funcs]
    EventStats(stats, eidxs, dyads, statnames, length(h), length(actors(h)))
end

