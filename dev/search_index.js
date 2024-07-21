var documenterSearchIndex = {"docs":
[{"location":"api/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"api/#Public-API","page":"Reference","title":"Public API","text":"","category":"section"},{"location":"api/","page":"Reference","title":"Reference","text":"RelationalEvent","category":"page"},{"location":"api/#RelationalEvents.RelationalEvent","page":"Reference","title":"RelationalEvents.RelationalEvent","text":"RelationalEvent(sender, receiver, time)\n\nType to represent a basic unmarked relational event containing the sender, the receiver, and the timestamp of the event.\n\nSender and receiver are required to be of the same type.\n\nExamples\n\njulia> sender = 2;\n\njulia> receiver = 4;\n\njulia> time = 1.0;\n\njulia> RelationalEvent(sender, receiver, time)\nRelationalEvent{Int64, Float64}\n sender: 2\n receiver: 4\n time: 1.0\n\n\n\n\n\n","category":"type"},{"location":"api/","page":"Reference","title":"Reference","text":"MarkedRelationalEvent","category":"page"},{"location":"api/#RelationalEvents.MarkedRelationalEvent","page":"Reference","title":"RelationalEvents.MarkedRelationalEvent","text":"MarkedRelationalEvent(sender, receiver, time, mark)\n\nType to represent a marked relational event containing the sender, the receiver, the timestamp, and the mark of the event.\n\nSender and receiver are required to be of the same type.\n\nExamples\n\njulia> sender = 2;\n\njulia> receiver = 4;\n\njulia> time = 1.0;\n\njulia> type = \"x\";\n\njulia> MarkedRelationalEvent(sender, receiver, time, type)\nMarkedRelationalEvent{Int64, Float64, String}\n sender: 2\n receiver: 4\n time: 1.0\n mark: x\n\n\n\n\n\n","category":"type"},{"location":"api/","page":"Reference","title":"Reference","text":"EventHistory","category":"page"},{"location":"api/#RelationalEvents.EventHistory","page":"Reference","title":"RelationalEvents.EventHistory","text":"EventHistory(events, nodes, spells)\nEventHistory(events)\n\nType representing a relational event history. This holds a sorted list of events and the nodes that appear throughout the observation period, as well as their activity spells.\n\n\n\n\n\n","category":"type"},{"location":"api/","page":"Reference","title":"Reference","text":"Spec","category":"page"},{"location":"api/#RelationalEvents.Spec","page":"Reference","title":"RelationalEvents.Spec","text":"Spec{T,S}\n\nStruct containing the specification for the computation of event statistics.\n\nFields\n\nN_events::Int             # number of events to sample\nN_cases::Int              # number of control cases to sample\nhalflife::T         # halflife time for exponential decay\ntol::Float64 = 0.01       # tolerance at which to set weights to zero\nstartmult::Float64 = 2.0  # halflife multiplier after which to start sampling\n\n\n\n\n\n","category":"type"},{"location":"api/","page":"Reference","title":"Reference","text":"statistics","category":"page"},{"location":"api/#RelationalEvents.statistics","page":"Reference","title":"RelationalEvents.statistics","text":"statistics(h, spec; statfuns...)\n\nCompute the statistics provided as keyword arguments for the event history h according to the specification in spec. Statistics are only computed for  a sample of the specified sizes of events and control cases. Returns an EventStats object.\n\nArguments\n\nh::EventHistory: The event history for which to compute statistics.\nspec::Spec: The specification for sampling, decay, etc.\nstatfuns::Function...: Functions to compute event history statistics.\n\nExamples\n\nhist = ... # EventHistory\nspec = Spec(\n    50,   # number of events to sample\n    10,   # number of control cases to sample\n    30,   # halflife time (e.g., days)\n    0.01, # threshold at which to set dyads to zero\n    2     # halflife multiplier after which to start sampling\n)\n\nres = statistics(hist, spec; inertia, reciprocity)\n\n\n\n\n\n","category":"function"},{"location":"api/","page":"Reference","title":"Reference","text":"isactive","category":"page"},{"location":"api/#RelationalEvents.isactive","page":"Reference","title":"RelationalEvents.isactive","text":"isactive(h, i, t)\n\nCheck if the ith actor is active at time t. Note that when  nodes nodes(h) are represented by a range of contiguous integers, i is equal to nodes(h)[i].\n\n\n\n\n\n","category":"function"},{"location":"api/","page":"Reference","title":"Reference","text":"inertia","category":"page"},{"location":"api/#RelationalEvents.inertia","page":"Reference","title":"RelationalEvents.inertia","text":"inertia(e, p, h, spec)\n\nCompute the inertia statistic for event e, using the EventProcess p and specification spec.\n\n\n\n\n\n","category":"function"},{"location":"api/","page":"Reference","title":"Reference","text":"reciprocity","category":"page"},{"location":"api/#RelationalEvents.reciprocity","page":"Reference","title":"RelationalEvents.reciprocity","text":"reciprocity(e, p, h, spec)\n\nCompute the reciprocity statistic for event e, using the EventProcess p and specification spec.\n\n\n\n\n\n","category":"function"},{"location":"api/#Internals","page":"Reference","title":"Internals","text":"","category":"section"},{"location":"api/","page":"Reference","title":"Reference","text":"RelationalEvents.EventStats","category":"page"},{"location":"api/#RelationalEvents.EventStats","page":"Reference","title":"RelationalEvents.EventStats","text":"Struct containing statistics about a sampled event history and control cases,  to be used for fitting a relational event model.\n\n\n\n\n\n","category":"type"},{"location":"api/","page":"Reference","title":"Reference","text":"RelationalEvents.EventProcess","category":"page"},{"location":"api/#RelationalEvents.EventProcess","page":"Reference","title":"RelationalEvents.EventProcess","text":"EventProcess{W,E}\n\nStruct holding sparse arrays with weights and weight update times. This is updated iterativeley as statistics are computed.\n\n\n\n\n\n","category":"type"},{"location":"api/","page":"Reference","title":"Reference","text":"RelationalEvents.Node","category":"page"},{"location":"api/#RelationalEvents.Node","page":"Reference","title":"RelationalEvents.Node","text":"Wrapper struct containing node metadata and a contiguous integer index.\n\n\n\n\n\n","category":"type"},{"location":"api/","page":"Reference","title":"Reference","text":"RelationalEvents.sample_riskset","category":"page"},{"location":"api/#RelationalEvents.sample_riskset","page":"Reference","title":"RelationalEvents.sample_riskset","text":"sample_riskset(h, t, spec)\n\nSample a set of spec.N_cases control events from the riskset, i.e., all possible dyads of nodes active at time t.\n\n\n\n\n\n","category":"function"},{"location":"api/","page":"Reference","title":"Reference","text":"RelationalEvents.update_process!","category":"page"},{"location":"api/#RelationalEvents.update_process!","page":"Reference","title":"RelationalEvents.update_process!","text":"update_process!(p, e, spec)\n\nUpdate weights and time-of-last-update of EventProcess p for the dyad and event time given by e and the specification spec.\n\n\n\n\n\n","category":"function"},{"location":"api/","page":"Reference","title":"Reference","text":"RelationalEvents.update_weights!","category":"page"},{"location":"api/#RelationalEvents.update_weights!","page":"Reference","title":"RelationalEvents.update_weights!","text":"update_weights!(p, e, spec)\n\nApply exponential decay to the weight of the dyad given by e based on the  halflife time specified by spec. If the weight is below given tolerance spec.tol, the weight will be set to zero for reasons of memory efficiency.\n\n\n\n\n\n","category":"function"},{"location":"api/","page":"Reference","title":"Reference","text":"RelationalEvents.update_wutimes!","category":"page"},{"location":"api/#RelationalEvents.update_wutimes!","page":"Reference","title":"RelationalEvents.update_wutimes!","text":"update_wutimes!(p, e)\n\nSet the time of the last weight update in EventProcess p to eventtime(e).\n\n\n\n\n\n","category":"function"},{"location":"api/","page":"Reference","title":"Reference","text":"RelationalEvents.add_event!","category":"page"},{"location":"api/#RelationalEvents.add_event!","page":"Reference","title":"RelationalEvents.add_event!","text":"add_event!(p, e, spec)\n\nUpdate EventProcess p according to specification spec for the occurred event e.\n\n\n\n\n\n","category":"function"},{"location":"#RelationalEvents.jl","page":"RelationalEvents.jl","title":"RelationalEvents.jl","text":"","category":"section"},{"location":"","page":"RelationalEvents.jl","title":"RelationalEvents.jl","text":"Relational event modeling in Julia","category":"page"},{"location":"","page":"RelationalEvents.jl","title":"RelationalEvents.jl","text":"Welcome to the RelationalEvents.jl documentation! RelationalEvents.jl is a Julia package for handling and modelling relational event histories.","category":"page"},{"location":"#Overview","page":"RelationalEvents.jl","title":"Overview","text":"","category":"section"},{"location":"","page":"RelationalEvents.jl","title":"RelationalEvents.jl","text":"TODO: Add an overview of the packages features here","category":"page"},{"location":"#Representing-relational-event-histories","page":"RelationalEvents.jl","title":"Representing relational event histories","text":"","category":"section"},{"location":"#Plotting-relational-event-histories","page":"RelationalEvents.jl","title":"Plotting relational event histories","text":"","category":"section"},{"location":"#Computing-relational-event-statistics","page":"RelationalEvents.jl","title":"Computing relational event statistics","text":"","category":"section"},{"location":"#Fitting-relational-event-models","page":"RelationalEvents.jl","title":"Fitting relational event models","text":"","category":"section"},{"location":"#Literature","page":"RelationalEvents.jl","title":"Literature","text":"","category":"section"},{"location":"","page":"RelationalEvents.jl","title":"RelationalEvents.jl","text":"TODO: Add references to the most important papers here","category":"page"}]
}
