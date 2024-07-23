using Revise, REPL, Chairmarks, Profile
using Dates
using RelationalEvents
using RelationalEvents: sample_active, spells

h = RelationalEvents.generate(2_500_000, 40_000; actortype=String, datetype=Int, daterange=1:10_000_000)
spec = Spec(10_000, 9, 90, 0.01, 2.0, 0)

sampled_events = RelationalEvents.sample_events(h, spec)
es, cs = RelationalEvents.sample_cases(sampled_events, h, spec)
cs

@time RelationalEvents.sample_cases(sampled_events, h, spec)
# @profview RelationalEvents.sample_cases(sampled_events, h, spec)

