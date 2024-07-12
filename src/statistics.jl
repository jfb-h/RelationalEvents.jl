
function inertia(e::AbstractRelationalEvent, p::EventProcess, h::EventHistory)
    p.weights[src(e), dst(e)]
end

function reciprocity(e::AbstractRelationalEvent, p::EventProcess, h::EventHistory)
    p.weights[dst(e), src(e)]
end
