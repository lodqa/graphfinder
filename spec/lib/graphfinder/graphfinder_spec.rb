require 'spec_helper'

describe GraphFinder, "the initializer" do
	context "for error handling" do
	  context "when nothing is passed to apgp" do
		  it "should raise an ArgumentError" do
		    expect{GraphFinder::GraphFinder.new(nil)}.to raise_error(ArgumentError)
		  end
		end
	end

	context "for normal input" do
	  before do
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

			@queries = [
				"SELECT ?v2 WHERE { <http://dbpedia.org/resource/Free_University_of_Berlin> ?p01 ?v2 . } ",
				"SELECT ?v2 WHERE { ?v2 ?p01 <http://dbpedia.org/resource/Free_University_of_Berlin> . } ",
				"SELECT ?v2 WHERE { <http://dbpedia.org/resource/Free_University_of_Berlin> ?p01 ?x01 . ?x01 ?p02 ?v2 . } ",
				"SELECT ?v2 WHERE { <http://dbpedia.org/resource/Free_University_of_Berlin> ?p01 ?x01 . ?v2 ?p02 ?x01 . } ",
				"SELECT ?v2 WHERE { ?x01 ?p01 <http://dbpedia.org/resource/Free_University_of_Berlin> . ?x01 ?p02 ?v2 . } ",
				"SELECT ?v2 WHERE { ?x01 ?p01 <http://dbpedia.org/resource/Free_University_of_Berlin> . ?v2 ?p02 ?x01 . } "
			]

	  end

	  it "should generate variations of equivalent SPARQL queries" do
			gf = GraphFinder::GraphFinder.new(@gp, @frame)
	  	expect(gf.sparql_queries).to eql(@queries)
	  end

	  it "should generate variations of equivalent SPARQL queries" do
			gf = GraphFinder::GraphFinder.new(@gp)
	  	expect(gf.sparql_queries).to eql(@gp)
	  end

	end
end

