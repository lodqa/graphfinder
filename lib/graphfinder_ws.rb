#!/usr/bin/env ruby
require 'sinatra/base'
require 'rest_client'
require 'erb'
require 'graphfinder'
require 'json'

class GraphFinderWS < Sinatra::Base
	configure do
		set :root, File.dirname(__FILE__).gsub(/lib/, '/')
		set :protection, :except => :frame_options
		set :server, 'thin'
	end

	before do
		@params = JSON.parse request.body.read, :symbolize_names => true if request.body && request.content_type && request.content_type.downcase == 'application/json'
	end

	get '/' do
		erb :index
	end

	post '/okbqa/queries' do
		template = params[:template]
		disambiguation = params[:disambiguation]
		apgp, frame = GraphFinder::okbqa_wrapper(template, disambiguation)
		gp = GraphFinder::GraphFinder.new(apgp, frame)

		content_type :json
		gp.sparql_queries.to_json
	end

end
