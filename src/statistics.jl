
function inertia(e::AbstractRelationalEvent, p::EventProcess, h::EventHistory, spec::Spec)
    update_process!(p, e, spec)
    p.weights[src(e), dst(e)]
end

function reciprocity(e::AbstractRelationalEvent, p::EventProcess, h::EventHistory, spec::Spec)
    c = RelationalEvent(dst(e), src(e), eventtime(e))
    update_process!(p, c, spec)
    p.weights[dst(e), src(e)]
end
