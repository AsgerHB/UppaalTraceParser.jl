### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 6d56d6be-0619-11ef-1e0a-b5a701da0fb3
begin
	using Pkg
	Pkg.activate(".")
	Pkg.develop("UppaalTraceParser")
	
	using Plots
	using PlutoLinks
	using PlutoUI
end

# ╔═╡ 7e281c42-9043-4ced-9090-964d41271477
@revise using UppaalTraceParser

# ╔═╡ 7eacc43a-6299-4875-80af-cb4a22ddd41f
function multiline(str)
	HTML("""
	<pre style='max-height:30em; margin:8pt 0 8pt 0; overflow-y:scroll'>
	$str
	</pre>
	""")
end

# ╔═╡ 1dd2fe4f-afba-47ed-b676-11da2527bf2c
@bind working_dir TextField(95, default=mktempdir())

# ╔═╡ 455ed4dc-6713-4d9a-935d-a8a25e00e743
working_dir; @bind open_folder_button CounterButton("Open Folder")

# ╔═╡ 7bc6b387-79b7-487e-bc4a-9b04ca69874b
if open_folder_button > 0
	run(`nautilus $working_dir`, wait=false)
end; "This cell opens the working dir (`$working_dir`) in nautilus" |> Markdown.parse

# ╔═╡ be08610a-3d58-412e-84be-7971e87a244e
begin
	input_file = joinpath(working_dir, "input.txt")

	write(input_file, """
	hello
	hello
	// [[ foo
		THIS SHOULD BE REPLACED
	// ]] this should be preserved
	hello
	""")
	
	output_file = joinpath(working_dir, "output.txt")

	UppaalTraceParser.apply_replacements(input_file, output_file, Dict(
		"foo" => "bar"
	))
end

# ╔═╡ f3a5045d-1a7d-47c4-a509-5b887a4e3e25
output_file |> read |> String

# ╔═╡ d658cd35-c9da-4167-816a-57918c6bea79
@bind linear_growth_model TextField(80, default=joinpath(pwd(), "../test/LinearGrowth.xml"))

# ╔═╡ be297956-aac4-4b60-bd8b-0b40a5b63e3b
linear_growth_output = run_model(linear_growth_model, "simulate[<=10;1] {x, 2*x}", Dict("RATE" => "2;"); working_dir);

# ╔═╡ a32f28b7-1897-4289-92c5-0cfa76ef161a
linear_growth_output |> multiline

# ╔═╡ 9bd63b43-aa90-4598-8097-2568081aeb04


# ╔═╡ a904a16d-6e8b-4ad3-a95f-458bebac28a9
@bind sample_rate NumberField(0.1:0.1:10)

# ╔═╡ 6f6252e0-37db-411e-9754-70ef27dcc861
trace = parse_trace(linear_growth_output, sample_rate)

# ╔═╡ 8902b6a0-49c8-456e-a937-c174618c0a05
begin
	plot(xlabel="time")
	plot!(trace["x"], label="x")
	plot!(trace["2 * x"], label="2 * x")
end

# ╔═╡ Cell order:
# ╠═6d56d6be-0619-11ef-1e0a-b5a701da0fb3
# ╠═7eacc43a-6299-4875-80af-cb4a22ddd41f
# ╠═7e281c42-9043-4ced-9090-964d41271477
# ╠═1dd2fe4f-afba-47ed-b676-11da2527bf2c
# ╟─455ed4dc-6713-4d9a-935d-a8a25e00e743
# ╟─7bc6b387-79b7-487e-bc4a-9b04ca69874b
# ╠═be08610a-3d58-412e-84be-7971e87a244e
# ╠═f3a5045d-1a7d-47c4-a509-5b887a4e3e25
# ╠═d658cd35-c9da-4167-816a-57918c6bea79
# ╠═be297956-aac4-4b60-bd8b-0b40a5b63e3b
# ╠═a32f28b7-1897-4289-92c5-0cfa76ef161a
# ╠═9bd63b43-aa90-4598-8097-2568081aeb04
# ╠═6f6252e0-37db-411e-9754-70ef27dcc861
# ╠═8902b6a0-49c8-456e-a937-c174618c0a05
# ╠═a904a16d-6e8b-4ad3-a95f-458bebac28a9
