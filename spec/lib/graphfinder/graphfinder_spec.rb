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
	  	@apgp = {
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
				"SELECT ?v2 WHERE { <http://dbpedia.org/resource/Free_University_of_Berlin> ?p01 ?v2 . FILTER (str(?p01) NOT IN (\"rdf:type\", \"rdfs:Class\")) } ",
				"SELECT ?v2 WHERE { ?v2 ?p01 <http://dbpedia.org/resource/Free_University_of_Berlin> . FILTER (str(?p01) NOT IN (\"rdf:type\", \"rdfs:Class\")) } ",
				"SELECT ?v2 WHERE { <http://dbpedia.org/resource/Free_University_of_Berlin> ?p01 ?x01 . ?x01 ?p02 ?v2 . FILTER (str(?p01) NOT IN (\"rdf:type\", \"rdfs:Class\")) } ",
				"SELECT ?v2 WHERE { <http://dbpedia.org/resource/Free_University_of_Berlin> ?p01 ?x01 . ?v2 ?p02 ?x01 . FILTER (str(?p01) NOT IN (\"rdf:type\", \"rdfs:Class\")) } ",
				"SELECT ?v2 WHERE { ?x01 ?p01 <http://dbpedia.org/resource/Free_University_of_Berlin> . ?x01 ?p02 ?v2 . FILTER (str(?p01) NOT IN (\"rdf:type\", \"rdfs:Class\")) } ",
				"SELECT ?v2 WHERE { ?x01 ?p01 <http://dbpedia.org/resource/Free_University_of_Berlin> . ?v2 ?p02 ?x01 . FILTER (str(?p01) NOT IN (\"rdf:type\", \"rdfs:Class\")) } "
			]

	  end

	  it "should generate variations of equivalent SPARQL queries" do
			gf = GraphFinder::GraphFinder.new(@apgp, @frame)
	  	expect(gf.sparql_queries).to eql(@queries)
	  end

	  it "should generate variations of equivalent SPARQL queries" do
			gf = GraphFinder::GraphFinder.new(@apgp)
	  	expect(gf.sparql_queries).to eql(@gp)
	  end

	end

	context "for normal input" do
	  before do
			@apgp = {
				:nodes=>{
					"v2"=>{},
					"v1"=>{:text=>"rivers", :term=>"<http://dbpedia.org/ontology/River>", :annotation=>"owl:Class"},
					"v5"=>{:text=>"Gunsan", :term=>"<http://dbpedia.org/resource/Gunsan>", :annotation=>"owl:NamedIndividual"},
				},
				:edges=>[
					{:subject=>"v2", :object=>"v1", :text=>nil, :annotation=>"owl:Property", :term=>"SORTAL"},
					{:subject=>"v2", :object=>"v5", :text=>"flow through", :annotation=>"owl:Property", :term=>"http://dbpedia.org/ontology/city"}
				]
			}

			@template = "SELECT ?v2 WHERE { _BGP_ }"
	  end

	  it "should generate variations of equivalent SPARQL queries" do
			gf = GraphFinder::GraphFinder.new(@apgp, @template)
	  	expect(gf.sparql_queries).to eql(@queries)
	  end
	end

end
