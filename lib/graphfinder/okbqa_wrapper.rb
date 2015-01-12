#!/usr/bin/env ruby
require 'sparql'

module GraphFinder; end unless defined? GraphFinder

class << GraphFinder
  # for OKBQA interface
  def okbqa_wrapper (template, disambiguation)
    raise ArgumentError, "Both template and disambiguation need to be supplied." if template.nil? || disambiguation.nil?

    slots = {}

    template["slots"].each do |s|
      p = s["p"]
      p = "form" if s["p"] == "verbalization"
      p = "type" if s["p"] == "is"

      slots[s["s"]] = {} if slots[s["s"]].nil?
      slots[s["s"]][p] = s["o"]
    end

    entities = []
    properties = []
    slots.each do |k, v|
      if v["type"] =~ /Property$/ then
        properties << k
      else
        entities << k
      end
    end

    disambiguation["entities"].each{|e| slots[e["var"]].merge!(e)}
    disambiguation["classes"].each{|c| slots[c["var"]].merge!(c)}
    disambiguation["properties"].each{|p| slots[p["var"]].merge!(p)}

    striples = []
    triples  = []

    query = template["query"].gsub(/ +/, ' ')
    sse = SPARQL.parse query
    sxp = SXP.read sse.to_sxp
    sxp_flat = sxp.flatten
    (0 .. sxp_flat.length - 2).each do |i|
      if sxp_flat[i] == :triple
        striples << sxp_flat[i+1 .. i+3].join(' ')
        triples  << {
          "subject" => sxp_flat[i+1].to_s.gsub!(/^\?/, ''),
          "predicate" => sxp_flat[i+2].to_s.gsub!(/^\?/, ''),
          "object" => sxp_flat[i+3].to_s.gsub!(/^\?/, '')
        }
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
    frame.gsub!(/ +/, ' ')

    nodes = {}
    triples.each do |t|
      nodes[t["subject"]] = {}
      nodes[t["object"]] = {}
    end
    entities.each do |id|
      v = slots[id]
      nodes[id] = {"text" => v["form"], "term" => termify(v["value"]), "type" => v["type"]}
    end

    relations = {}
    triples.each do |t|
      p = t["predicate"]
      relation = {"subject" => t["subject"], "object" => t["object"]}
      relation["text"] = slots[p]["form"] unless slots[p]["form"].nil?
      relation["type"] = slots[p]["type"] unless slots[p]["type"].nil?
      unless slots[p]["value"].nil?
        if slots[p]["value"] == 'SORTAL'
          relation["type"] = 'gf:Sortal'
        else
          relation["term"] = termify(slots[p]["value"])
        end
      end
      relations[p] = relation
    end

    [{"nodes" => nodes, "relations" => relations}, frame]
  end

  def termify (exp)
    if exp =~ /^https?:/
      "<#{exp}>"
    else
      exp
    end
  end

end