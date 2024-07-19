module RelationalEventsDataFramesExt

using RelationalEvents
using DataFrames

function DataFrames.DataFrames.DataFrame(es::RelationalEvents.EventStats)
    df = DataFrame(es.stats, es.statnames)
    insertcols!(df, 1, :id => es.idxs)
    insertcols!(df, 2, :event => es.dyads)
    df
end

function RelationalEvents.EventHistory(type::Type{<:AbstractRelationalEvent}, df::DataFrame)
    itr = Tables.namedtupleiterator(df)
    evs = map(row -> type(row...), itr)
    EventHistory(evs)
end

end#module
