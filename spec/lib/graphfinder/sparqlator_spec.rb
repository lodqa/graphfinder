require 'spec_helper'

module GraphFinder
	describe Sparqlator do
		describe "#initialize" do
			context "for error handling" do
			  context "when nothing is passed to apgp" do
				  it "should raise an ArgumentError" do
				    expect{GraphFinder::Sparqlator.new(nil)}.to raise_error(ArgumentError)
				  end
				end
			end

			context "for normal input" do
			  before do
			  	input = JSON.parse IO.read("spec/fixtures/sparqlator_input_1.json")
			  	@apgp = input["apgp"]
			  	@frame = input["frame"]

			  	@output = JSON.parse IO.read("spec/fixtures/sparqlator_output_1.json")
			  end

			  it "should extract a APGP and a frame from the template and disambiguation" do
			  	expect(GraphFinder::Sparqlator.new(@apgp, @frame).sparql_queries).to eq(@output)
			  end
			end
		end
	end
end