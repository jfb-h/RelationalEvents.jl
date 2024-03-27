"""
struct representing a time window of type T.

This can be passed as a first argument to a statistic function
to compute the statistic only over a window of specified length
before the input event.
"""
struct Window{T}
    size::T
end

function getwindow(window::Window, hist::EventHistory, i::Integer)
    e = RelationalEvent(0, 0, eventtime(hist[i]) - window.size)
    w = searchsortedfirst(events(hist), e; by=eventtime)
    @view events(hist)[w:i-1]
end

function inertia(window::Window, hist::EventHistory{A,T,E}, i::Integer) where {A,T,E<:RelationalEvent}
    events = getwindow(window, hist, i)
    src = sender(hist[i])
    dst = receiver(hist[i])
    count(events) do e
        src == sender(e) && dst == receiver(e)
    end
end

