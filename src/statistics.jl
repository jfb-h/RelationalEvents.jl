
"""
    inertia(e, p, h, spec)

Compute the inertia statistic for event `e`, using the `EventProcess` `p` and specification `spec`.
"""
function inertia(e::AbstractRelationalEvent, p::EventProcess, h::EventHistory, spec::Spec)
    update_process!(p, e, spec)
    p.weights[isrc(e), idst(e)]
end

"""
    reciprocity(e, p, h, spec)

Compute the reciprocity statistic for event `e`, using the `EventProcess` `p` and specification `spec`.
"""
function reciprocity(e::AbstractRelationalEvent, p::EventProcess, h::EventHistory, spec::Spec)
    c = RelationalEvent(e.dst, e.src, eventtime(e))
    update_process!(p, c, spec)
    p.weights[idst(e), isrc(e)]
end

function sender_indegree(e::AbstractRelationalEvent, p::EventProcess{W}, h::EventHistory, spec::Spec) where {W}
    update_indegrees!(p, isrc(e), eventtime(e), spec)
    p.indegrees[isrc(e)]
end

function sender_outdegree(e::AbstractRelationalEvent, p::EventProcess{W}, h::EventHistory, spec::Spec) where {W}
    update_outdegrees!(p, isrc(e), eventtime(e), spec)
    p.outdegrees[isrc(e)]
end

function receiver_indegree(e::AbstractRelationalEvent, p::EventProcess{W}, h::EventHistory, spec::Spec) where {W}
    update_indegrees!(p, idst(e), eventtime(e), spec)
    p.indegrees[idst(e)]
end

function receiver_outdegree(e::AbstractRelationalEvent, p::EventProcess{W}, h::EventHistory, spec::Spec) where {W}
    update_outdegrees!(p, idst(e), eventtime(e), spec)
    p.outdegrees[idst(e)]
end

activity(e, p, h, spec) = sender_outdegree(e, p, h, spec)
popularity(e, p, h, spec) = receiver_indegree(e, p, h, spec)
assortativity(e, p, h, spec) = activity(e, p, h, spec) * popularity(e, p, h, spec)

function transitivity(e::AbstractRelationalEvent, p::EventProcess{W}, h::EventHistory, spec::Spec) where {W}
    as = riskset(h, eventtime(e))
    s = 0.0
    for a in as
        a == src(e) || a == dst(e) && continue

        iszero(p.weights[isrc(e), a.idx]) || iszero(p.weights[a.idx, idst(e)]) && continue

        ia = RelationalEvent(e.src, a, eventtime(e))
        update_process!(p, ia, spec)

        aj = RelationalEvent(a, e.dst, eventtime(e))
        update_process!(p, aj, spec)

        w_ia = p.weights[isrc(ia), idst(ia)]
        w_aj = p.weights[idst(ia), isrc(ia)]

        s += w_ia * w_aj
    end

    s
end

