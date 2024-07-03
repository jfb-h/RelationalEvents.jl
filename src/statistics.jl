abstract type AbstractStatistic end

using SparseArrayKit: SparseArray

struct Spec{F}
    N_events::Int
    N_cases::Int
    halflife::Float32
    tol::Float32
    statistics::F
end

struct EventProcess{W,E}
    weights::W
    evtimes::E
end

update_evtimes!(L, e) = update_evtimes!(L, src(e), dst(e), eventtime(e))
function update_evtimes!(L, s, r, t)
    L[s, r] = t
end
update_weights!(G, L, e, spec) = update_weights!(G, L, src(e), dst(e), eventtime(e), spec)
function update_weights!(G, L, s, r, t, spec)
    t_prev = L[s, r]
    G[s, r] += exp(-(t - t_prev) * log(2) / spec.halflife) * (1 + G[s, r])
    G[s, r] < spec.tol && delete!(G.data, CartesianIndex(s, r))
    G[s, r]
end

inertia(G, L, e, spec) = inertia(G, L, src(e), dst(e), eventtime(e), spec)
function inertia(G, L, s, r, t, spec)
    G[s, r]
end

function sample_riskset(h, t)
    rs = riskset(h, t)
    # TODO...
end

function compute_statistic(stat, G, L, e, h, spec)
    t = eventtime(e)
    rs = sample_riskset(h, t)
    ev = [(src(e), dst(e)), rs...]
    map(ev) do (s, r)
        update_weights!(G, L, s, r, t, spec)
        # TODO...
    end
end

function compute(h::EventHistory, spec::Spec)
    N = maximum(actors(h))
    E = length(h)
    sampled_events = sample(1:E, spec.N_events; replace=false)

    G = SparseArray{Float32}(undef, N, N)
    L = SparseArray{Int32}(undef, N, N)

    out = []
    @showprogress for (i, e) in enumerate(h)
        if i in sampled_events
            y = map(spec.statistics) do f
                Symbol(string(f)) => compute_statistic(f, G, L, e, h, spec)
            end |> NamedTuple
            push!(out, y)
        end
        update_evtimes!(L, e)
    end
    out
end


function kernel end

function map_kernel(stat::AbstractStatistic, hist::EventHistory, e_curr)
    k = kernel(stat)
    sum(events(hist)) do e_prev
        tdiff = eventtime(e_curr) - eventtime(e_prev)
        res = k(e_prev, e_curr, hist)
        float(res) * stat.decay(tdiff)
    end
end

function (stat::AbstractStatistic)(hist::EventHistory)::Vector{Vector{Float64}}
    tmap(events(hist)) do e_cur
        t = eventtime(e_cur)
        prev = before(hist, t)
        map(riskset(hist, t)) do rec
            e = RelationalEvent(src(e_cur), rec, t)
            map_kernel(stat, prev, e)
        end
    end
end

macro statistic(stat, exp)
    quote
        struct $(esc(stat)){D<:AbstractDecay} <: AbstractStatistic
            decay::D
        end

        function RelationalEvents.kernel(x::$(esc(stat)))
            $exp
        end
    end
end

