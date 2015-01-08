require 'spec_helper'

describe GraphFinderWS, "index" do
	context "the path: get /" do
	  it "should respond with 'ok' for 'get'" do
	    get '/'
	    expect(last_response).to be_ok
		end
	end

	context "the path: post /okbqa/queries" do
		before do
	  	@template = {
				query: "SELECT ?v2 WHERE { ?v1 ?p1 ?v2 . } ", 
			  slots: [
			  	{var: "v1", form: "Free University in Amsterdam", annotation: "owl:NamedIndividual" }, 
			    {var: "p1", form: "students", annotation: "owl:DatatypeProperty" } 
			  ], 
			  score: 0.5
    	}

    	@disambiguation = {
    		score:0.3,
				entities: [
					{
						var: "v1", 
            value: "http://dbpedia.org/resource/Free_University_of_Berlin",
            score: 0.3
					}
    		],
				properties: [
					{
          	var: "p1",
          	value: "http://dbpedia.org/property/students",
          	score: 0.7
					}
				]
    	}
		end

	  it "should respond with 'ok' for 'post'" do
	    post '/okbqa/queries'
	    expect(last_response).to be_ok
		end

	end
end