require 'spec_helper'

describe GraphFinderWS do
	context "for the request GET /" do
	  it "should respond with 'OK'" do
	    get '/'
	    expect(last_response).to be_ok
		end
	end

	context "for the request POST /queries" do
		before do
	  	@input = JSON.parse IO.read("spec/fixtures/sparqlator_input_1.json")
	  	@output = JSON.parse IO.read("spec/fixtures/sparqlator_output_1.json")
		end

	  it "should respond with an error message for not passing APGP." do
	    post '/queries'
	    expect(last_response.status).to eq(400)
		end

	  it "should respond with an array of SPARQL queries" do
	    post '/queries', @input
	    expect(JSON.parse last_response.body).to eq(@output)
		end

	end

end