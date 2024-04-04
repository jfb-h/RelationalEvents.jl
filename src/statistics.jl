abstract type AbstractStatistic end

function kernel end

function map_kernel(stat::AbstractStatistic, hist::EventHistory, e_curr)
    k = kernel(stat)
    sum(events(hist)) do e_prev
        tdiff = eventtime(e_curr) - eventtime(e_prev)
        res = k(e_prev, e_curr, hist)
        float(res) * stat.decay(tdiff)
    end
end

function (stat::AbstractStatistic)(hist::EventHistory)::Vector{Vector{Float64}}
    tmap(events(hist)) do e_cur
        t = eventtime(e_cur)
        prev = before(hist, t)
        map(riskset(hist, t)) do rec
            e = RelationalEvent(src(e_cur), rec, t)
            map_kernel(stat, prev, e)
        end
    end
end

macro statistic(stat, exp)
    quote
        struct $(esc(stat)){D<:AbstractDecay} <: AbstractStatistic
            decay::D
        end

        function RelationalEvents.kernel(x::$(esc(stat)))
            $exp
        end
    end
end

