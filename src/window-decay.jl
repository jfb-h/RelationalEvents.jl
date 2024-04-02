abstract type AbstractWindow end

struct Window{T} <: AbstractWindow
    size::T
end

Base.:+(x::T, w::Window) where {T} = x + w.size
Base.:-(x::T, w::Window) where {T} = x - w.size

function window(window::Window, hist::EventHistory{A,T,E}, t::T) where {A,T,E<:RelationalEvent}
    # dummy events because searchsortedfirst also applies `by` to x
    e1 = RelationalEvent(0, 0, t - window)
    e2 = RelationalEvent(0, 0, t)
    t1 = searchsortedfirst(events(hist), e1; by=eventtime)
    t2 = searchsortedfirst(events(hist), e2; by=eventtime)
    es = view(events(hist), t1:t2-1)
    EventHistory(es, actors(hist), spells(hist))
end

struct WindowPrevious end

function window(::WindowPrevious, hist::EventHistory{A,T,E}, t::T) where {A,T,E<:RelationalEvent}
    now = searchsortedfirst(events(hist), RelationalEvent(0, 0, t); by=eventtime)
    EventHistory(view(events(hist), 1:now-1), actors(hist), spells(hist))
end

abstract type AbstractDecay end

struct NoDecay <: AbstractDecay end
(d::NoDecay)(stat::Real, ::T, ::T) where {T} = stat

struct LinearDecay{T<:Real} <: AbstractDecay
    p::T
end

# function (d::LinearDecay)(stat::Real, t1::T, t2::T) where {T<:Real}
#     stat - (t2 - t1) * d.p
# end


