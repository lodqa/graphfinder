require 'spec_helper'

describe GraphFinder, "okbqa_wrapper" do
	context "for error handling" do
	  context "when both template and disambiguation are nil" do
		  it "should raise an ArgumentError" do
		    expect{GraphFinder::template_to_gp(nil, nil)}.to raise_error(ArgumentError)
		  end
		end

	  context "when template is nil" do
		  it "should raise an ArgumentError" do
		    expect{GraphFinder::template_to_gp(nil, {})}.to raise_error(ArgumentError)
		  end
		end

	  context "when disambiguation is nil" do
		  it "should raise an ArgumentError" do
		    expect{GraphFinder::template_to_gp({}, nil)}.to raise_error(ArgumentError)
		  end
		end

	end

	context "for normal inputs" do
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

	  	@gp = {
	  		nodes:{
	  			"v1" => {
	  				text:"Free University in Amsterdam",
	  				term:"<http://dbpedia.org/resource/Free_University_of_Berlin>",
	  				annotation: "owl:NamedIndividual"
	  			},
	  			"v2" => {}
	  		},
	  		edges:[
	  			{
	  				subject: "v1",
	  				object: "v2",
	  				text: "students",
	  				annotation: "owl:DatatypeProperty"
	  			}
	  		],
	  	}

			@frame = "SELECT ?v2 WHERE { _BGP_ } "
	  end

	  it "should extract a gp from the template" do
	  	expect(GraphFinder::template_to_gp(@template, @disambiguation)).to eq([@gp, @frame])
	  end
	end
end

