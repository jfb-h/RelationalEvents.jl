"""
    Spec{T,S}

Struct containing the specification for the computation of event statistics.

# Fields
- `N_events::Int`             # number of events to sample
- `N_cases::Int`              # number of control cases to sample
- `t0::S`                     # Startpoint of the event history
- `thalf::T`                  # halflife time for exponential decay
- `tol::Float64 = 0.01`       # tolerance at which to set weights to zero
- `startmult::Float64 = 2.0`  # halflife multiplier after which to start sampling
"""
@kwdef struct Spec{T,S}
    N_events::Int
    N_cases::Int
    t0::S
    thalf::T
    tol::Float64 = 0.01
    startmult::Float64 = 2.0
end

"""
    EventProcess{W,E}

Struct holding sparse arrays with weights and weight update times, and vectors with
in- and outdegrees. This is updated iterativeley as statistics are computed.
"""
struct EventProcess{W,E}
    # Sparse Array with weights for all pairs
    weights::SparseArray{W,2}
    # Sparse Array holding the last time a weight was updated
    wutimes::SparseArray{E,2}
    # Vectors holding accumulated degrees
    indegrees::Vector{W}
    outdegrees::Vector{W}
    # Vectors with update times for degrees
    indegtimes::Vector{E}
    outdegtimes::Vector{E}
    # Vector with node ids of active nodes
    active::Vector{Int32}
end
function EventProcess{W,E}(N, S) where {W,E}
    weights = SparseArray{W,2}(undef, (N, N))
    wutimes = SparseArray{E,2}(undef, (N, N))
    sizehint!(weights.data, S)
    sizehint!(wutimes.data, S)
    indegrees = zeros(W, N)
    outdegrees = zeros(W, N)
    indegtimes = zeros(E, N)
    outdegtimes = zeros(E, N)
    active = Int32[]
    sizehint!(active, N)
    EventProcess{W,E}(
        weights, wutimes,
        indegrees, outdegrees,
        indegtimes, outdegtimes,
        active
    )
end

"""
    update_process!(p, e, spec)

Update weights and time-of-last-update of `EventProcess` `p` for the
dyad and event time given by `e` and the specification `spec`.
"""
function update_process!(p::EventProcess, e, spec::Spec)
    update_weights!(p, e, spec)
    update_wutimes!(p, e, spec)
    p
end

"""
    update_wutimes!(p, e)

Set the time of the last weight update in `EventProcess` `p` to `eventtime(e)`.
"""
function update_wutimes!(p::EventProcess, e, spec::Spec)
    s, d, t = isrc(e), idst(e), eventtime(e)
    p.wutimes[s, d] = t - spec.t0
    p
end

decay(w, t, t_prev, thalf) = exp(-(t - t_prev) / thalf * log(2)) * w

"""
    update_weights!(p, e, spec)

Apply exponential decay to the weight of the dyad given by `e` based on the 
halflife time specified by `spec`. If the weight is below given tolerance `spec.tol`,
the weight will be set to zero for reasons of memory efficiency.
"""
function update_weights!(p::EventProcess, e, spec::Spec)
    s, d, t = isrc(e), idst(e), eventtime(e) - spec.t0
    t_prev = p.wutimes[s, d]
    p.weights[s, d] = decay(p.weights[s, d], t, t_prev, spec.thalf)
    p.weights[s, d] < spec.tol && delete!(p.weights.data, CartesianIndex(s, d))
    p.weights[s, d]
    p
end

function update_outdegrees!(p::EventProcess, v, t, spec::Spec)
    t = t - spec.t0
    t_prev = p.outdegtimes[v]
    p.outdegrees[v] = decay(p.outdegrees[v], t, t_prev, spec.thalf)
    p.outdegtimes[v] = t
    p
end

function update_indegrees!(p::EventProcess, v, t, spec::Spec)
    t = t - spec.t0
    t_prev = p.indegtimes[v]
    p.indegrees[v] = decay(p.indegrees[v], t, t_prev, spec.thalf)
    p.indegtimes[v] = t
    p
end

"""
    add_event!(p, e, spec)

Update `EventProcess` `p` according to specification `spec` for the occurred event `e`.
"""
function add_event!(p::EventProcess{W}, e, spec::Spec) where {W}
    update_process!(p, e, spec)
    update_outdegrees!(p, isrc(e), eventtime(e), spec)
    update_indegrees!(p, idst(e), eventtime(e), spec)
    p.weights[isrc(e), idst(e)] += one(W)
    p.outdegrees[isrc(e)] += one(W)
    p.indegrees[idst(e)] += one(W)
    p
end

# function init_active!(p::EventProcess, h::EventHistory, spec::Spec)
#     for n in nodes(h)
#         entry(n) <= spec.t0 && push!(p.active, n.idx)
#     end
#     p
# end
#
# function update_active!(p::EventProcess, t, spec)
#
# end

"""
Struct containing statistics about a sampled event history and control cases, 
to be used for fitting a relational event model.
"""
struct EventStats{
    T<:AbstractMatrix{<:Real},
    I<:AbstractVector{<:Integer},
    D<:AbstractVector{<:AbstractRelationalEvent},
    N<:AbstractVector{<:AbstractString}
}
    stats::T
    idxs::I
    events::D
    statnames::N
    N_events::Int
    N_nodes::Int
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
        println(io, "$(_format(h.N_events)) ($(round(N_sampled / h.N_events * 100, digits=2))%)")
        println(io, " sampled cases:  $(_format(N_cases)) with $(_format(h.N_nodes)) nodes")
    end
end

# """
#     sample_riskset(h, t, spec)
#
# Sample a set of `spec.N_cases` control events from the riskset, i.e.,
# all possible dyads of nodes active at time `t`.
# """
# function sample_riskset(h::EventHistory{A,T,E}, t::T, spec::Spec) where {A,T,E<:AbstractRelationalEvent}
#     rs = riskset(h, t)
#     nt = length(rs)
#     spec.N_cases <= nt * (nt - 1) || error("Can't sample more than N(N-1) cases")
#     out = Vector{E}()
#     sizehint!(out, spec.N_cases)
#     while length(out) < spec.N_cases
#         s, d = rand(rs), rand(rs)
#         s == d && continue
#         (s, d) in out && continue
#         push!(out, E(s, d, t)) #TODO: handle marks
#     end
#     out
# end

function sample_events(h::EventHistory, spec::Spec)
    t0 = eventtime(first(h)) + spec.startmult * spec.thalf
    from = findfirst(e -> eventtime(e) >= t0, events(h))
    to = length(h)
    sort!(sample(from:to, spec.N_events; replace=false))
end

_construct_event(e::E, s, d) where {E<:RelationalEvent} = E(s, d, eventtime(e))
_construct_event(e::E, s, d) where {E<:MarkedRelationalEvent} = E(s, d, eventtime(e), mark(e))
# _construct_event(E::Type{RelationalEvent}, x) = E(x...)
# _construct_event(E::Type{MarkedRelationalEvent}, x) = E(x...)

function sample_cases(sampled_events, h::EventHistory, spec::Spec)
    es = repeat(sampled_events; inner=spec.N_cases)
    cs = fill(first(h), spec.N_events * (spec.N_cases))
    for (i, eid) in enumerate(sampled_events)
        e = events(h)[eid]
        t = eventtime(e)
        active = findall(s -> first(s) <= t <= last(s), spells(h))
        #TODO: Maybe give IntervalTrees another try
        rscount = 0
        while rscount < spec.N_cases
            idx = (i - 1) * (spec.N_cases) + rscount + 1
            # sample event from riskset, first is always the observed
            s, d = rand(active), rand(active)
            s, d = nodes(h)[s], nodes(h)[d]
            c = rscount == 0 ? e : _construct_event(e, s, d)
            # reject loops and duplicates
            isrc(c) == idst(c) && continue
            if rscount > 0
                c in view(cs, (idx-rscount):(idx-1)) && continue
            end
            # store sampled event
            cs[idx] = c
            rscount += 1
        end
    end
    es, cs
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
    1,    # origin time of the event history
    30,   # halflife time (e.g., days)
    0.01, # threshold at which to set dyads to zero
    2     # halflife multiplier after which to start sampling
)

res = statistics(hist, spec; inertia, reciprocity)
```
"""
function statistics(h::EventHistory{S,T,E}, spec::Spec{U,T}; funcs...) where {S,T,E<:AbstractRelationalEvent,U}
    # check dimensions
    N, A = length(h), length(nodes(h))
    spec.N_events <= length(h) || throw(DimensionMismatch("Cannot sample more events than there are in the history"))
    # initialize event process
    p = EventProcess{Float32,U}(A, N)
    # init_active!(p, h)
    statnames = [string(k) for k in keys(funcs)]
    # allocate result object
    stats = zeros(Float32, spec.N_events * spec.N_cases, length(funcs))
    # sample events and control cases for which to compute stats
    sampled = sample_events(h, spec)
    eventids, cases = sample_cases(sampled, h, spec)
    # loop through events and compute stats, update process
    for i in eachindex(cases)
        for (j, (_, f)) in enumerate(pairs(funcs))
            @views stats[i, j] = f(cases[i], p, h, spec)
        end
        i % spec.N_cases == 0 && add_event!(p, h.events[eventids[i]], spec)
    end
    EventStats(stats, eventids, cases, statnames, length(h), length(nodes(h)))
end

