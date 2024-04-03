
export Inertia

abstract type AbstractStatistic end

function map_kernel(stat::AbstractStatistic, hist::EventHistory, current_event)
    k = kernel(stat)
    sum(events(hist)) do previous_event
        res = k(previous_event, current_event, hist)
        stat.decay(res, eventtime(previous_event), eventtime(current_event))
    end
end

function (stat::AbstractStatistic)(hist::EventHistory)::Vector{Vector{Float64}}
    es = events(hist)
    tstart = eventtime(first(hist)) + stat.window
    start = searchsortedfirst(es, RelationalEvent(0, 0, tstart); by=eventtime)
    tmap(@view es[start:end]) do current_event
        t = eventtime(current_event)
        prev = window(stat.window, hist, t)
        map(riskset(hist, t)) do rec
            e = RelationalEvent(sender(current_event), rec, t)
            map_kernel(stat, prev, e)
        end
    end
end

# struct Inertia{W<:AbstractWindow,D<:AbstractDecay} <: AbstractStatistic
#     window::W
#     decay::D
# end
#
# @inline function kernel(::Inertia)
#     (current_event, previous_event, hist) -> begin
#         res = sender(current_event) == sender(previous_event) &&
#               receiver(current_event) == receiver(previous_event)
#         float(res)
#     end
# end

# @stat Inertia (ec, ep, hist) -> begin
#     sender(ec) == sender(ep) && receiver(ec) == receiver(ep)
# end
