using RelationalEvents
using Dates
using Test

const RE = RelationalEvents

@testset "RelationalEvent" begin
    a, b, t = "a", "b", 1
    re = RelationalEvent(RE.Node(1, a), RE.Node(2, b), 1)

    @test re isa AbstractRelationalEvent{String}

    @test src(re) == "a"
    @test dst(re) == "b"
    @test RE.isrc(re) == 1
    @test RE.idst(re) == 2
    @test eventtime(re) == 1

    struct Actor
        name::String
    end

    a = Actor("a")
    b = Actor("b")
    t = Date(2020)
    re2 = RelationalEvent(RE.Node(1, a), RE.Node(2, b), t)

    @test re2 isa AbstractRelationalEvent{Actor}
    @test src(re2) isa Actor
    @test dst(re2) isa Actor
    @test eventtime(re2) isa Date
end

@testset "EventHistory" begin
    ns = [RE.Node(i) for i in 1:3]
    es = [(3, 1, 1), (2, 3, 2), (1, 3, 3), (3, 1, 4)]
    es = map(es) do (s, r, t)
        RelationalEvent(ns[s], ns[r], t)
    end
    spells = [1:5, 1:3, 1:5]
    hist1 = EventHistory(es)
    hist2 = EventHistory(es, ns, spells)

    @test hist1 isa EventHistory && hist2 isa EventHistory

    @test length(hist1) == 4
    @test events(hist1) == events(hist2) == es

    @test issorted(hist1, by=eventtime)
    @test issorted(hist2, by=eventtime)

    @test src(first(hist1)) == src(first(es))
    @test all(e isa AbstractRelationalEvent{Int64} for e in [first(hist1), last(hist1), hist1[1]])

    @test isactive(hist2, 2, 4) == false
    @test isactive(hist2, 1, 4) == true
    # @test riskset(hist2, 4) == [1, 3]
end


hist = EventHistory([(1, 2, 5), (2, 1, 8), (1, 2, 9), (1, 3, 12), (2, 3, 13), (1, 2, 14)])
spec = Spec(N_events=6, N_cases=5, t0=1, thalf=3, tol=0.01, startmult=0.0)

@testset "EventProcess" begin
    res = statistics(hist, spec)
    cases = spec.N_cases

    @test issorted(res.events; by=eventtime)
    @test all(res.idxs .== repeat(1:length(hist); inner=cases))
    @test all(hist[i] == d for (i, d) in enumerate(res.events) if i % spec.N_cases + 1 == 0)
end

@testset "Statistics" begin
    res = statistics(hist, spec; inertia, reciprocity)

    @test res.events[1:spec.N_cases:(spec.N_events*spec.N_cases)] == events(hist)

    @test res.stats[findfirst(==(3), res.idxs), 1] ≈ 0.39685
    @test res.stats[findfirst(==(6), res.idxs), 1] ≈ 0.43998

    @test res.stats[findfirst(==(2), res.idxs), 2] ≈ 0.5
    @test res.stats[findfirst(==(3), res.idxs), 2] ≈ 0.79370
    @test res.stats[findfirst(==(6), res.idxs), 2] ≈ 0.25
end
