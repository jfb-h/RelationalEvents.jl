using RelationalEvents
using SparseArrays
using DimensionalData
using Dates

const RE = RelationalEvents

hist = RE.generate(1000, 200)

function todimarray(hist)
    res = zeros(Float32, Ti(eventtime.(hist)), Y(sort(actors(hist))))
    res
end

val(x::Number) = x
val(x::Period) = x.value

function decay(γ, θ)
    γ <= θ ? 1.0 : 0.0
end

function fwdinertia(hist; θ=Day(365))
    #out = zeros(length(hist), length(actors(hist)), length(actors(hist)))
    N = length(actors(hist))
    out = [spzeros(N, N) for _ in 1:length(hist)]

    for (i, e) in enumerate(events(hist))
        s = sender(e)
        r = receiver(e)
        for j in i+1:length(hist)
            j > lastindex(hist) && continue
            γ = eventtime(hist[j]) - eventtime(hist[i])
            out[j][s, r] += decay(γ, θ)
        end
    end

    out
end
