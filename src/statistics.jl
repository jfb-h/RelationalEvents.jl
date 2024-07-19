
"""
    inertia(e, p, h, spec)

Compute the inertia statistic for event `e`, using the `EventProcess` `p` and specification `spec`.
"""
function inertia(e::AbstractRelationalEvent, p::EventProcess, h::EventHistory, spec::Spec)
    update_process!(p, e, spec)
    p.weights[src(e), dst(e)]
end

"""
    reciprocity(e, p, h, spec)

Compute the reciprocity statistic for event `e`, using the `EventProcess` `p` and specification `spec`.
"""
function reciprocity(e::AbstractRelationalEvent, p::EventProcess, h::EventHistory, spec::Spec)
    c = RelationalEvent(dst(e), src(e), eventtime(e))
    update_process!(p, c, spec)
    p.weights[dst(e), src(e)]
end
