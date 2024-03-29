"""
struct representing a time window of type T.

This can be passed as a first argument to a statistic function
to compute the statistic only over a window of specified length
before the input event.
"""
struct Window{T}
    size::T
end

function getwindow(window::Window, hist::EventHistory{A,T,E}, t::T) where {A,T,E<:RelationalEvent}
    # dummy events because searchsortedfirst also applies `by` to x
    e1 = RelationalEvent(0, 0, t - window.size)
    e2 = RelationalEvent(0, 0, t)
    t1 = searchsortedfirst(events(hist), e1; by=eventtime)
    t2 = searchsortedfirst(events(hist), e2; by=eventtime)
    @view events(hist)[t1:t2-1]
end

# function inertia(::RelationalEvent, events, i::A, j::A, t::T) where {A,T}
#     count(events) do e
#         i == sender(e) && j == receiver(e)
#     end
# end

function inertia(events, event::RelationalEvent)
    count(events) do e
        sender(event) == sender(e) && receiver(event) == receiver(e)
    end
end

function inertia(events, event::MarkedRelationalEvent)
    count(events) do e
        sender(event) == sender(e) && receiver(event) == receiver(e) && mark(event) == mark(e)
    end
end

function inertia(
    window::Window,
    hist::EventHistory{A,T,E},
    event::E,
) where {A,T,E}

    t = eventtime(event)
    events = getwindow(window, hist, t)
    map(riskset(hist, t)) do r
        e = @set event.receiver = r
        inertia(events, e)
    end
end

