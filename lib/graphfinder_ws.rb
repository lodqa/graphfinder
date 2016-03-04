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
		set :show_exceptions => false
	end

	before do
		if request.content_type && request.content_type.downcase == 'application/json'
			body = request.body.read
			begin
				json_params = JSON.parse body unless body.empty?
			rescue => e
				@error_message = 'ill-formed JSON string'
			end
			params.merge!(json_params) unless json_params.nil?
		end
	end

	get '/' do
		erb :index
	end

	post '/queries' do
		begin
			raise ArgumentError, @error_message if @error_message

			p params
			puts "-----"

			apgp = params["apgp"]
			frame = params["frame"]
			gp = GraphFinder::Sparqlator.new(apgp, frame)

			content_type :json
			gp.sparql_queries.to_json

		rescue ArgumentError => e
			status 400
			content_type :json
			{message:e.message}.to_json
		end
	end

	post '/okbqa/queries' do
		template = params["template"]
		disambiguation = params["disambiguation"]
		apgp, frame = GraphFinder::okbqa_wrapper(template, disambiguation)
		gp = GraphFinder::GraphFinder.new(apgp, frame)

		content_type :json
		gp.sparql_queries.to_json
	end

end
