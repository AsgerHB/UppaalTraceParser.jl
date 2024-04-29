module UppaalTraceParser

export parse_trace
include("ParseTrace.jl")

export run_model, set_verifyta!
include("RunModel.jl")

end
