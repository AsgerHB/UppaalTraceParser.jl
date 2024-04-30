# UppaalTraceParser

A small Julia-library for running [UPPAAL](https://uppaal.org/) models and parsing the resulting traces.

## Quickstart:

Make sure this library uses the right binary by calling:

    set_verifyta!("PATH/TO/YOUR/uppaal-5.0.0-linux64/bin/verifyta")

### Running a model

Consider the example UPPAAL automaton:

![Single location with invariant x' == RATE](https://github.com/AsgerHB/UppaalTraceParser.jl/assets/11016262/e2a67eb2-a301-4866-9009-fe722080bbde)


With the following declarations:

    clock x;
    const int RATE = 1;

Say it's saved in a file called "LinearGrowth.xml". We can run any query on this model using the `run_model` function:

    julia> output = run_model("./LinearGrowthModel.xml", "simulate[<=10;1] {x, 2*x}")
    """Options for the verification:      Generating no trace
      Search order is breadth first
      Using conservative space optimisation
      Seed is 1714393759
      State space representation uses minimal constraint systems with future testing
      Using HashMap + Compress integers for discrete state storage
    
    Verifying formula 1 at /tmp/jl_4yjftG/queries.q:1
     -- Formula is satisfied.
    x:
    [0]: (0,0) (10,10)
    2 * x:
    [0]: (0,0) (10,20)"""


### Parsing a Trace

The output of a `simulate` query can be turned into a list of traces. 
In this example, the query only produces one trace.
Each trace is a dictionary mapping variables to vectors of values. 
The second parameter, `sample_rate`, specifies the time between these values. 
This is done using the `parse_traces` function:

    julia> parse_traces(output, 1.0)
    1-element Vector{Dict{String, Vector{Float64}}}:
    Dict("2 * x" => [0.0, 4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 28.0, 32.0, 36.0], "x" => [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0])


> [!NOTE]
> If the simulate query generates more than one trace (e.g. `simulate[<=10;2] {x}`) only the first trace is parsed. Subsequent traces are ignored.

### Replacements
The library also supports **replacements** on the form 

    // [[ KEY
    to_be_replaced;
    // ]]

If the model declaration is changed to

    clock x;
    const int RATE = // [[ CLOCK_RATE
        1;
    // ]]

Then we can set any rate we like using the `run_model` function:

    julia> output = run_model("./LinearGrowthModel.xml", "simulate[<=10;1] {x, 2*x}", Dict("CLOCK_RATE" => "2;"));
    """ Options for the verification:      Generating no trace
      Search order is breadth first
      Using conservative space optimisation
      Seed is 1714394014
      State space representation uses minimal constraint systems with future testing
      Using HashMap + Compress integers for discrete state storage
    
    Verifying formula 1 at /tmp/jl_4yjftG/queries.q:1
     -- Formula is satisfied.
    x:
    [0]: (0,0) (10,20)
    2 * x:
    [0]: (0,0) (10,40)"""
    julia> parse_traces(output, 1.0)
    1-element Vector{Dict{String, Vector{Float64}}}:
    Dict("2 * x" => [0.0, 4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 28.0, 32.0, 36.0], "x" => [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0])
