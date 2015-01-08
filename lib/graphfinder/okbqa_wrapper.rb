#!/usr/bin/env ruby
require 'sparql'

module GraphFinder; end unless defined? GraphFinder

class << GraphFinder
  # for OKBQA interface
  def okbqa_wrapper (template, disambiguation)
    raise ArgumentError, "Both template and disambiguation need to be supplied." if template.nil? || disambiguation.nil?

    entities = {}
    template[:slots].each{|s| entities[s[:var]] = s unless s[:annotation] =~ /Property$/}
    disambiguation[:entities].each{|e| entities[e[:var]].merge!(e)}

    properties = {}
    template[:slots].each{|s| properties[s[:var]] = s if s[:annotation] =~ /Property$/}

    striples = []
    triples  = []

    query = template[:query].gsub(/ +/, ' ')
    sse = SPARQL.parse query
    sxp = SXP.read sse.to_sxp
    sxp_flat = sxp.flatten
    (0 .. sxp_flat.length - 2).each do |i|
      if sxp_flat[i] == :triple
        striples << sxp_flat[i+1 .. i+3].join(' ')
        triples  << {subject:sxp_flat[i+1][1..-1], predicate:sxp_flat[i+2][1..-1], object:sxp_flat[i+3][1..-1]}
      end
    end

    frame = query
    striples.each_with_index do |t, i|
      if i == 0
        frame.gsub!(/#{t.gsub(/\?/, '\?')} ?\./, '_BGP_')
      else
        frame.gsub!(/#{t.gsub(/\?/, '\?')} ?\./, '')
      end
    end

    nodes = {}
    triples.each do |t|
      nodes[t[:subject]] = {}
      nodes[t[:object]] = {}
    end
    entities.each{|k, v| nodes[k] = {text:v[:form], term:"<#{v[:value]}>", annotation:v[:annotation]}}

    edges = triples.map{|t| p = t[:predicate]; {subject:t[:subject], object:t[:object], text:properties[p][:form], annotation:properties[p][:annotation]}}

    [{nodes:nodes, edges:edges}, frame]
  end
end