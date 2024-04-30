@testset "Replacements" begin
    @test UppaalTraceParser.is_replacement_start(" 	 //[[ foo")
    @test UppaalTraceParser.get_replacement_key(" 	 //[[ foo") == "foo"
    @test !UppaalTraceParser.is_replacement_end(" 	 //[[ foo")
    @test UppaalTraceParser.is_replacement_end(" 	 //]]")
    @test UppaalTraceParser.is_replacement_start(" 	 // 	 [[foo")
    @test !UppaalTraceParser.is_replacement_end(" 	 // 	 [[ foo")
    @test UppaalTraceParser.is_replacement_end(" 	 // 	 ]]")

    begin
        working_dir = tempdir()
        input_file = joinpath(working_dir, "input.txt")
    
        write(input_file, """
        hello
        hello
        // [[ REPLACEMENT_KEY
            THIS SHOULD BE REPLACED
        // ]]
        hello
        """)

        output_file = joinpath(working_dir, "output.txt")
        
        UppaalTraceParser.apply_replacements(input_file, output_file, Dict(
            "REPLACEMENT_KEY" => "foo"
        ))

        # Trailing line break added by println.
        @test (output_file |> read |> String) == """
        hello
        hello
        // [[ REPLACEMENT_KEY
        foo
        // ]]
        hello

        """
    end
end


@testset "run_model" begin
    verifyta_file = joinpath(homedir(), "opt/uppaal-5.0.0-linux64/bin/verifyta")
    if isfile(verifyta_file)
        set_verifyta!(verifyta_file)
        linear_growth_model = joinpath(pwd(), "LinearGrowth.xml")
        linear_growth_output = run_model(linear_growth_model, "simulate[<=10;1] {x, 2*x}", Dict("RATE" => "2;"));

        @test occursin("Formula is satisfied.", linear_growth_output)
        @test occursin("[0]: (0,0) (10,20)", linear_growth_output)
        @test occursin("[0]: (0,0) (10,40)", linear_growth_output)
    else
        @info "No UPPAAL install found. Skipping the integration test."
    end
end
