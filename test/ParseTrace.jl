example_output = """
Options for the verification:
    Generating no trace
    Search order is breadth first
    Using conservative space optimisation
    Seed is 1714392370
    State space representation uses minimal constraint systems with future testing
    Using HashMap + Compress integers for discrete state storage

Verifying formula 1 at /tmp/jl_4yjftG/queries.q:1
-- Formula is satisfied.
x:
[0]: (0,0) (10,20)
2 * x:
[0]: (0,0) (10,40)
"""

@testset "get_observation_names" begin


    observation_names = UppaalTraceParser.get_observation_names(example_output)
    @test "x" ∈  observation_names
    @test "2 * x" ∈ observation_names
    @test length(observation_names) == 2
end

@testset "parse_trace" begin
    sample_rate = 1
    parse_trace_result = parse_trace(example_output, sample_rate)

    @test parse_trace_result["x"] == 0.0:2:18
    @test parse_trace_result["2 * x"] == 0.0:4:36
end