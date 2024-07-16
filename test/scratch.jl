using Revise, REPL, Chairmarks, Profile
using RelationalEvents

h = generate(1000, 10; actortype=Int, datetype=Int, daterange=1:10_000)
spec = Spec(50, 10, 30.0f0, 0.01f0)

@profview compute(h, spec, (;inertia, reciprocity,))
@profview_allocs compute(h, spec, (;inertia, reciprocity,))
@b compute(h, spec, (;inertia, reciprocity,))
stats, event, dyads = compute(h, spec, (;inertia, reciprocity,))

p = EventProcess{Float32, Int32}(10)
@b RelationalEvents.update_weights!(p, h[500], spec)
