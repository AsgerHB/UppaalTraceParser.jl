
function parse_pair(str)
	left = match(r"\(([-0-9.e]+),", str)
	if isnothing(left) error("left side of pair not found in $str") end
	left = left[1]
	left = parse(Float64, left)
	right = match(r",([-0-9.e]+)\)", str)
	if isnothing(right) error("right side of pair not found in $str") end
	right = right[1]
	right = parse(Float64, right)
	(left, right)
end

function parse_pairs(str)
	[parse_pair(s) for s in split(str, " ") if s != ""]
end

function get_pairs_for_array(output::String, keyword::String, i=0)::Vector{Tuple{Float64, Float64}}
	right_keyword = false
	re_keyword = Regex("^\\Q$keyword\\E:")
	for line in split(output, "\n")
		if occursin(re_keyword, line)
			right_keyword = true
		end
		if !right_keyword continue end
		
		re_values = Regex("\\[$i\\]:(?<values>.*)", "m")
		m = match(re_values, line)
		if !isnothing(m)
			return parse_pairs(m[:values])
		end
	end
	if !right_keyword
		error("Keyword not found in output: '$keyword.'")
	else
		error("Index $i not found for keyword  '$keyword'")
	end
end

function value_at_time(trace::T, time::S) where T <: AbstractVector{Tuple{Float64, Float64}} where S <: Number
	
	time_before, value_before = last([(t, v) 
		for (t, v) in trace if t <= time])

	time_after, value_after = first([(t, v) 
		for (t, v) in trace if t >= time])

	sample_rate = time_after - time_before
	if sample_rate == 0 # Happens if there is an exact match
		return value_after
	end
	fraction = (time - time_before)/sample_rate
	return value_before + fraction*(value_after - value_before)
end

function at_regular_intervals(trace::T, interval::S) where T <: 
		AbstractVector{Tuple{Float64, Float64}} where S <: Number

	t_max = trace[end][1]
	return [ value_at_time(trace, i) for i in 0:interval:prevfloat(t_max) ]
end

function get_observation_names(output::AbstractString)
	result = String[]
	for line in split(output, "\n")
		m = match(r"^(.*):$", line)
		if m == nothing continue end
		if occursin(m[1], "Options for the verification") continue end
		push!(result, m[1])
	end
	result
end

function get_number_of_traces(output)
	highest = 0
	for line in split(output, "\n")
		m = match(r"^\[(\d+)\]:", line)
		if isnothing(m) continue end
		highest = max(highest, parse(Int64, m[1]))
	end
	return highest + 1 # Traces are 0-indexed
end

"""
    parse_trace(output, sample_rate, observations...)

Parse the output of a `simulate` query. 

Multiple traces in the same simulate-query are not supported. E.g. `simulate[<=10;1]` is allowed, but `simulate[<=10;2]` is not.

Arguments:
 - `output` Output of the `simulate` query
 - `sample_rate` Time between observations of each variable.
 - `observations` Variable names or expressions which are output from the `simulate` query.

Example:

    simulate[<=10;1] {foo, bar*2, sqrt(baz)}

    parse_trace(output, 0.5, "foo", "bar*2", "sqrt(baz)") 
    # returns Dict("foo" => [1, 1.5, 2, 2.5 ... 10], "bar*2" => ...)

A sample-rate of 0.5 corresponds to two samples per second, which results in vectors of length 20.
"""
function parse_traces(output, sample_rate)
	result = Dict{String, Vector{Float64}}[]
	observations = get_observation_names(output)
	number_of_traces = get_number_of_traces(output)
	for i in 1:number_of_traces
		d = Dict{String, Vector{Float64}}()
		for keyword in observations
			trace = get_pairs_for_array(output, keyword, i - 1) # recall: zero-indexed
			d[keyword] = at_regular_intervals(trace, sample_rate)
		end
		push!(result, d)
	end
	result
end
