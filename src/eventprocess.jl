struct Spec
    N_events::Int
    N_cases::Int
    halflife::Float32
    tol::Float32
end

struct EventProcess{W,E}
    # Sparse Array with weights for all pairs
    weights::SparseArray{W}
    # Sparse Array holding the last time a weight was updated
    wutimes::SparseArray{E}
end

function update_process!(p::EventProcess, e, spec::Spec)
    update_weights!(p, e, spec)
    update_wutimes!(p, e, spec)
    p
end

function update_wutimes!(p::EventProcess, e, spec::Spec)
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

function sample_riskset(h::EventHistory, t, spec::Spec)
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

# TODO: TESTS

function compute(h::EventHistory, spec::Spec, funcs)
    #TODO: sample events
    N = maximum(actors(h))
    G = SparseArray{Float32}(undef, N, N)
    L = SparseArray{Int32}(undef, N, N)
    p = EventProcess(G, L)
    mapreduce(vcat, enumerate(h)) do (i, e)
        t = eventtime(e)
        rs = vcat(e, sample_riskset(h, t, spec))
        out_e = map(rs) do c
            update_process!(p, c, spec)
            stats_nt = map(funcs) do f
                f(c, p, h)
            end
            merge((; event=i, dyad=c), stats_nt)
        end
        add_event!(p, e, spec)
        out_e
    end#|> StructArray
end

export sample_riskset, compute, inertia, reciprocity, update_weights!
