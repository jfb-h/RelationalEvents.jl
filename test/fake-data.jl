using Dates

generate_eventtimes(N, ::Type{Date}) =
    sort!(rand(Date(2000):Date(2020), N))

generate_eventtimes(N, ::Type{Int}, daterange) = sort!(rand(daterange, N))

generate_actors(M, ::Type{Int}) = collect(1:M)
generate_actors(M, ::Type{String}) = [i => string(i) for i in 1:M]

function generate_events(actors, eventtimes)
    map(eventtimes) do t
        sender = rand(actors)
        receiver = rand(actors)
        while receiver == sender
            receiver = rand(actors)
        end
        RelationalEvent(Node(sender...), Node(receiver...), t)
    end
end

function generate(N, M; actortype=Int, datetype=Int, daterange=1:100_000)
    etimes = generate_eventtimes(N, datetype, daterange)
    actors = generate_actors(M, actortype)
    events = generate_events(actors, etimes)
    EventHistory(events)
end

