module UppaalTraceParser

export parse_traces
include("ParseTraces.jl")

export run_model, set_verifyta!
include("RunModel.jl")

end
