using RelationalEvents
using Dates
using Test

const RE = RelationalEvents

@testset "RelationalEvent" begin
    re = RelationalEvent(1, 2, 1)

    @test re isa AbstractRelationalEvent{Int64}
    @test RE.actortype(re) == Int64
    @test RE.timetype(re) == Int64

    @test src(re) == 1
    @test dst(re) == 2
    @test eventtime(re) == 1

    struct Actor
        name::String
    end

    a = Actor("a")
    b = Actor("b")
    t = Date(2020)
    re2 = RelationalEvent(a, b, t)

    @test re2 isa AbstractRelationalEvent{Actor}
    @test src(re2) isa Actor
    @test dst(re2) isa Actor
    @test eventtime(re2) isa Date
end

@testset "EventHistory" begin
    es = [(3, 1, 1), (2, 3, 2), (1, 3, 3), (3, 1, 4)]
    es = map(t -> RelationalEvent(t...), es)
    actors = [1, 2, 3]
    spells = [1:5, 1:3, 1:5]
    hist1 = EventHistory(es)
    hist2 = EventHistory(es, actors, spells)

    @test typeof(es) <: Vector{<:AbstractRelationalEvent}
    @test hist1 isa EventHistory
    @test hist2 isa EventHistory

    @test length(hist1) == 4
    @test events(hist1) == events(hist2) == es
    @test map(identity, hist1) == es
    @test src.(hist1) == src.(es)

    @test issorted(hist1, by=eventtime)
    @test issorted(hist2, by=eventtime)

    @test hist1[2] == es[2]
    @test all(e isa AbstractRelationalEvent{Int64} for e in [first(hist1), last(hist1), hist1[1]])

    @test isactive(hist2, 2, 4) == false
    @test isactive(hist2, 1, 4) == true
    @test riskset(hist2, 4) == [1, 3]
end


hist = let
    es = [(1, 2, 5), (2, 1, 8), (1, 2, 9), (1, 3, 12), (2, 3, 13), (1, 2, 14)]
    es = map(t -> RelationalEvent(t...), es)
    EventHistory(es)
end

spec = let
    events_sampled, cases_sampled = length(hist), 5
    thalf, thresh, mult = 3, 0.01, 0.0
    Spec(events_sampled, cases_sampled, thalf, thresh, mult)
end

@testset "EventProcess" begin
    res = compute(hist, spec)
    cases = spec.N_cases + 1

    @test issorted(res.dyads; by=eventtime)
    @test all(res.idxs .== repeat(1:length(hist); inner=cases))
    @test all(hist[i] == d for (i, d) in enumerate(res.dyads) if i % spec.N_cases + 1 == 0)
end

@testset "Statistics" begin
    res = compute(hist, spec; inertia, reciprocity)

    @test res.stats[findfirst(==(3), res.idxs), 1] ≈ 0.39685
    @test res.stats[findfirst(==(6), res.idxs), 1] ≈ 0.43998

    @test res.stats[findfirst(==(2), res.idxs), 2] ≈ 0.5
    @test res.stats[findfirst(==(3), res.idxs), 2] ≈ 0.79370
    @test res.stats[findfirst(==(6), res.idxs), 2] ≈ 0.25
end
