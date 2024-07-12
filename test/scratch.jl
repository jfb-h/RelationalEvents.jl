using Revise, REPL, Chairmarks, Profile
using RelationalEvents

h = generate(1000, 10; actortype=Int, datetype=Int, daterange=1:10_000)
spec = Spec(50, 10, 30.0f0, 0.01f0)
i = compute(h, spec, (inertia, reciprocity,))
