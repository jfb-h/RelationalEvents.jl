generate_eventtimes(N, ::Type{Date}) =
  sort!(rand(Date(2000):Date(2020), N))

generate_eventtimes(N, ::Type{Int}) = sort!(rand(1:10_000, N))

generate_actors(M, ::Type{Int}) = collect(1:M)

function generate_events(actors, eventtimes)
  map(eventtimes) do t
    sender = rand(actors)
    receiver = rand(actors)

    while receiver == sender
      receiver = rand(actors)
    end

    RelationalEvent(sender, receiver, t)
  end
end

function generate(N, M; actortype=Int, datetype=Date)
  etimes = generate_eventtimes(N, datetype)
  actors = generate_actors(M, actortype)
  events = generate_events(actors, etimes)
  EventHistory(events)
end

