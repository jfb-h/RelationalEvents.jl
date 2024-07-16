struct Spec
    N_events::Int
    N_cases::Int
    halflife::Float32
    tol::Float32
end

struct EventProcess{W,E}
    # Sparse Array with weights for all pairs
    weights::SparseArray{W,2}
    # Sparse Array holding the last time a weight was updated
    wutimes::SparseArray{E,2}
end

function EventProcess{W,E}(N) where {W,E}
    weights = SparseArray{W,2}(undef, (N, N))
    wutimes = SparseArray{E,2}(undef, (N, N))
    EventProcess{W,E}(weights, wutimes)
end

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

    # function EventStats{T,I,D,N}(s, i, d, n) where {
    #     T<:AbstractMatrix{<:Real},
    #     I<:AbstractVector{<:Integer},
    #     D<:AbstractVector{<:AbstractRelationalEvent},
    #     N<:AbstractVector{<:AbstractString}
    # }
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

function compute(h::EventHistory{S,T,E}, spec::Spec; funcs...) where {S,T,E<:AbstractRelationalEvent}
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
    sample_range = findfirst(e -> eventtime(e) > (t0 + 2 * spec.halflife), events(h)):length(h)
    sampl = Set(sample(sample_range, spec.N_events))
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
                src(c) == dst(c) || c in view(events(h), (idx-rscount):idx) && continue
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
    EventStats(stats, eidxs, dyads, [string(n) for (n, f) in funcs])
end

function DataFrames.DataFrame(es::EventStats)
    df = DataFrame(es.stats, es.statnames)
    insertcols!(df, 1, :eventid => es.idxs)
    insertcols!(df, 2, :dyad => es.dyads)
    df
end
