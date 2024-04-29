verifyta = "verifyta"


"""
    set_verifyta!(command)

Set up how `verifyta` is called. Default: Just `verifyta`. 

Example:

    set_verifyta!(joinpath(homedir(), "opt/uppaal-5.0.0-linux64/bin/verifyta"))
"""
function set_verifyta!(command)
    verifyta = command
end

function run_model(model::AbstractString, query::AbstractString, replacements=Dict();  working_dir = mktempdir(), discretization=0.01)
    if !isfile(model) error("Model not found at $model") end

    model′ = joinpath(working_dir, "model.xml")
    apply_replacements(model, model′, replacements)
    
    query_file = let
        query_file = joinpath(working_dir, "queries.q")
        write(query_file, query)
        query_file
    end

    output = Cmd(String[
        verifyta,
        "-s",
        split("--discretization $discretization --truncation-error $discretization --truncation-time-error $discretization", " ")...,
        model′,
        query_file
    ]) |> read |> String;

    return output
end

function apply_replacements(input_file, output_file, replacements::Dict)
	file = input_file |> read |> String
	open(output_file, "w") do io
        replacement_key = nothing
        replacing = false
		for line in split(file, "\n")
			if is_replacement_start(line)
                replacement_key = get_replacement_key(line)
                replacing = true
                println(io, line)
            end
            if !replacing
                println(io, line)
            end
            if is_replacement_end(line)
                replacing = false
                println(io, replacements[replacement_key])
                println(io, line)
            end
		end
	end
	output_file
end

function is_replacement_start(line::AbstractString)
    return occursin(r"\s*//\s*\[\[", line)
end

function get_replacement_key(line::AbstractString)
    return match(r"\s*//\s*\[\[\s*([a-zA-Z_]+)", line)[1]
end

function is_replacement_end(line::AbstractString)
    return occursin(r"\s*//\s*\]\]", line)
end