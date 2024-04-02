abstract type AbstractDecay end


# function window(window::Window, hist::EventHistory{A,T,E}, t::T) where {A,T,E<:RelationalEvent}
#     # dummy events because searchsortedfirst also applies `by` to x
#     e1 = RelationalEvent(0, 0, t - window)
#     e2 = RelationalEvent(0, 0, t)
#     t1 = searchsortedfirst(events(hist), e1; by=eventtime)
#     t2 = searchsortedfirst(events(hist), e2; by=eventtime)
#     es = view(events(hist), t1:t2-1)
#     EventHistory(es, actors(hist), spells(hist))
# end
#
# struct WindowPrevious end
#
# function window(::WindowPrevious, hist::EventHistory{A,T,E}, t::T) where {A,T,E<:RelationalEvent}
#     now = searchsortedfirst(events(hist), RelationalEvent(0, 0, t); by=eventtime)
#     EventHistory(view(events(hist), 1:now-1), actors(hist), spells(hist))
# end

struct NoDecay <: AbstractDecay end
(d::NoDecay)(γ) = 1.0

struct Window{T} <: AbstractDecay
    size::T
end

Base.:+(x::T, w::Window) where {T} = x + w.size
Base.:-(x::T, w::Window) where {T} = x - w.size

(d::Window)(γ) = γ <= d.size ? 1.0 : 0.0

struct LinearDecay{T<:Real} <: AbstractDecay
    θ::T # half-life
end

(d::LinearDecay)(γ) = γ <= 2 * d.θ ? (1 - 1 / (2 * d.θ) * γ) : 0.0

struct ExponentialDecay{T<:Real} <: AbstractDecay
    θ::T # half-life
end

(d::ExponentialDecay)(γ) = exp(-γ * log(2) / d.θ)


