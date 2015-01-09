require 'spec_helper'

describe GraphFinderWS, "index" do
	context "the path: get /" do
	  it "should respond with 'ok' for 'get'" do
	    get '/'
	    expect(last_response).to be_ok
		end
	end

	context "the path: post /queries" do
		before do
			@apgp = {
				:nodes=>{
					"v2"=>{},
					"v1"=>{:text=>"rivers", :term=>"<http://dbpedia.org/ontology/River>", :annotation=>"owl:Class"},
					"v5"=>{:text=>"Gunsan", :term=>"<http://dbpedia.org/resource/Gunsan>", :annotation=>"owl:NamedIndividual"},
					"v3"=>{:text=>"flow through", :term=>"<http://dbpedia.org/ontology/city>", :annotation=>"owl:Property"},
					"v4"=>{:text=>nil, :term=>"<rdf:type>", :annotation=>"owl:Property"}
				},
				:edges=>[
					{:subject=>"v2", :object=>"v1", :text=>nil, :annotation=>"owl:Property", :term=>"rdf:type"},
					{:subject=>"v2", :object=>"v5", :text=>"flow through", :annotation=>"owl:Property", :term=>"http://dbpedia.org/ontology/city"}
				]
			}

			@template = "SELECT ?v2 WHERE { _BGP_  }"
		end

	  it "should respond with 'ok' for 'post'" do
	    post '/queries', {apgp:@apgp, template:@template}.to_json
	    expect(last_response).to be_ok
		end
	end

end