require 'spec_helper'

describe GraphFinder, "okbqa_wrapper" do
	context "for error handling" do
	  context "when both template and disambiguation are nil" do
		  it "should raise an ArgumentError" do
		    expect{GraphFinder::okbqa_wrapper(nil, nil)}.to raise_error(ArgumentError)
		  end
		end

	  context "when template is nil" do
		  it "should raise an ArgumentError" do
		    expect{GraphFinder::okbqa_wrapper(nil, {})}.to raise_error(ArgumentError)
		  end
		end

	  context "when disambiguation is nil" do
		  it "should raise an ArgumentError" do
		    expect{GraphFinder::okbqa_wrapper({}, nil)}.to raise_error(ArgumentError)
		  end
		end

	end

	context "for normal inputs" do
	  before do
	  	input = JSON.parse IO.read("spec/fixtures/query_generation_input_1.json")
	  	@template = input["template"]
	  	@disambiguation = input["disambiguation"]

	  	output = JSON.parse IO.read("spec/fixtures/sparqlator_input_1.json")
	  	@apgp = output["apgp"]
	  	@frame = output["frame"]
	  end

	  it "should extract a APGP and a frame from the template and disambiguation" do
	  	expect(GraphFinder::okbqa_wrapper(@template, @disambiguation)).to eq([@apgp, @frame])
	  end
	end

end