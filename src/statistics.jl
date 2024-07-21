
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
