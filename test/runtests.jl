using RelationalEvents
using Test

const RE = RelationalEvents

@testset "RelationalEvent" begin
  re = RelationalEvent(1, 2, 1)

  @test re isa AbstractRelationalEvent{Int64}
  @test RE.actortype(re) == Int64
  @test RE.timetype(re) == Int64

  @test sender(re) == 1
  @test receiver(re) == 2
  @test eventtime(re) == 1
end

es = [(1, 2, 1), (2, 3, 2), (1, 3, 3), (3, 1, 4)]
es = map(t -> RelationalEvent(t...), es)
actors = [1, 2, 3]
entries = [1, 1, 1]
exits = [5, 3, 5]
hist1 = EventHistory(es)
hist2 = EventHistory(es, actors, entries, exits)

@testset "EventHistory" begin
  @test typeof(es) <: Vector{<:AbstractRelationalEvent}
  @test hist1 isa EventHistory
  @test hist2 isa EventHistory

  @test length(hist1) == 4
  @test map(identity, hist1) == es
  @test sender.(hist1) == sender.(es)

  @test hist1[2] == es[2]

  for e in [first(hist1), last(hist1), hist1[1]]
    @test e isa AbstractRelationalEvent{Int64}
  end
end

@testset "EventHistory - choiceset" begin
  @test active(hist2, 2, 4) == false
  @test active(hist2, 1, 4) == true
  @test riskset(hist2, 4) == [1, 3]
end
