#!/usr/bin/env ruby
module GraphFinder; end unless defined? GraphFinder

GraphFinder::DEFAULT_TEMPLATE = 'SELECT * WHERE { _BGP_ }'
GraphFinder::SORTAL_PREDICATES = ["rdf:type", "rdfs:Class"]

# Generate variations of a graph pattern using the triple variation operations.
class << GraphFinder

  # This method takes as arguments
  # - an anchored pseudo graph pattern (apgp),
  # - a SPARQL template (template), and
  # - optionally a hash of option specifications (options).
  # The marker, _BGP_, in the template will be replaced by various
  # BGP patterns generated by this method.
  # At the moment the template is supposed to have only one BGP.
  # The apgp is supposed to be a structural repesentation of the BGP.
  # From the apgp, many variations of the BGP will be generated, and
  # they will replace the BGP to produce variations of SPARQL queries.
  def sparqlator (apgp, template = nil, options = {})
    raise ArgumentError, "An anchored PGP needs to be passed" if apgp.nil?

    options ||= {}
    @apgp = apgp
    @template = template || DEFAULT_TEMPLATE
    @ignore_predicates = options[:ignore_predicates] || []
    @sortal_predicates = options[:sortal_predicates] || GraphFinder::SORTAL_PREDICATES
    max_hop = options[:max_hop] || 2

    index_edges(@apgp)

    @bgps = gen_bgps(apgp, max_hop)
    # sparql = compose_sparql(bgps, @apgp)
  end

  def sparql_queries
    @bgps.map{|bgp| compose_sparql(bgp, @template, @apgp)}
  end

  def each_solution
    @bgps.each do |bgp|
      sparql = compose_sparql(bgp, @apgp)
      begin
        result = @endpoint.query(sparql)
      rescue => detail
        sleep(2)
        next
        # print detail.backtrace.join("\n")
      end 
      result.each_solution do |solution|
        yield(solution)
      end
      sleep(2)
    end
  end

  def each_sparql_and_solution(proc_sparql = nil, proc_solution = nil)
    @bgps.each do |bgp|
      sparql = compose_sparql(bgp, @apgp)
      proc_sparql.call(sparql) unless proc_sparql.nil?

      begin
        result = @endpoint.query(sparql)
      rescue => detail
        sleep(2)
        next
        # print detail.backtrace.join("\n")
      end 
      result.each_solution do |solution|
        proc_solution.call(solution) unless proc_solution.nil?
      end
      sleep(2)
    end
  end

  private

  # It generates bgps by applying variation operations to the apgp.
  # The option _max_hop_ specifies the maximum number of hops to be searched.
  def gen_bgps (apgp, max_hop = 1)
    bgps = generate_split_variations(apgp[:edges], max_hop)
    # bgps = generate_inverse_variations(bgps)
    # bgps = generate_instantiation_variations(bgps, apgp)
    bgps
  end

  def generate_initial_bgp(apgp)

    agpg[:edges].each do |e|
    end

  end

  def generate_split_variations(connections, max_hop)
    bgps = []

    split_number = connections.select{|c| c[:term] != 'SORTAL'}.length

    # split and make bgps
    split_schemes = (1 .. max_hop).collect{|e| e}.repeated_permutation(split_number).to_a

    split_schemes.each do |split_scheme|
      # TODO
      split_scheme.unshift(1) if split_number < connections.length
      bgps << generate_split_bgp(connections, split_scheme)
    end

    bgps
  end

  def generate_split_bgp(connections, split_scheme)
    bgp = []
    connections.each_with_index do |c, i|
      x_variables = (1 ... split_scheme[i]).collect{|j| ("x#{i}#{j}").to_s}

      if c[:term] == 'SORTAL'
        p_variables = ['s' + c[:object].to_s]
      else
        p_variables = (1 .. split_scheme[i]).collect{|j| ("p#{i}#{j}").to_s}
      end

      # terms including x_variables and the initial and the final terms
      terms = [c[:subject], x_variables, c[:object]].flatten

      # triple patterns
      tps = (0 ... p_variables.length).collect{|k| [terms[k], p_variables[k], terms[k + 1]]}
      bgp += tps
    end
    bgp
  end

  # make variations by inversing each triple pattern
  def generate_inverse_variations (bgps)
    rbgps = []

    bgps.each do |bgp|
      [false, true].repeated_permutation(bgp.length) do |inverse_scheme|
        rbgps << bgp.map.with_index {|tp, i| inverse_scheme[i]? tp.reverse : tp}
      end
    end

    rbgps
  end

  # make variations by instantiating terms
  def generate_instantiation_variations(bgps, apgp)
    iids = {}
    apgp[:nodes].each do |id, node|
      iid = class?(id, apgp) ? 'i' + id.to_s : nil
      iids[id] = iid unless iid.nil?
    end

    ibgps = []
    bgps.each do |bgp|

      [false, true].repeated_permutation(iids.keys.length) do |instantiate_scheme|
        # id of the terms to be instantiated
        itids = iids.keys.keep_if.with_index{|t, i| instantiate_scheme[i]}

        # initialize the instantiated bgp with the triple patterns for term instantiation
        ibgp = itids.collect{|t| [iids[t], 's' + t.to_s, t.to_s]}

        # add update triples
        bgp.each{|tp| ibgp << tp.map{|e| itids.include?(e)? iids[e] : e}}

        ibgps << ibgp
      end
    end

    ibgps
  end

  def class?(term, apgp)
    if apgp[:nodes][term][:annotation] == 'owl:Class'
      return true
    else
      return false
    end
  end

  def index_edges(apgp)
    edge_index = {}
    apgp[:edges].each do |e|
      edge_index["#{e[:subject]}-#{e[:object]}"] = e
    end

    apgp[:edge_index] = edge_index
  end


  # def class?(term)
  #   if /^http:/.match(term)
  #     sparql = "SELECT ?p WHERE {?s ?p <#{term}> FILTER (str(?p) IN (#{@sortal_predicates.map{|s| '"'+s+'"'}.join(', ')}))} LIMIT 1"
  #     result = @endpoint.query(sparql)
  #     return true if result.length > 0
  #   end
  #   return false
  # end


  def compose_sparql(bgps, template, apgp)
    nodes = apgp[:nodes]

    # get the variables
    variables = bgps.flatten.uniq - nodes.keys

    # initialize the body of the query
    body = ''

    # stringify the bgps
    body += bgps.map{|tp| tp.map{|e| (nodes[e.to_sym].nil? || nodes[e.to_sym].empty?) ? '?' + e : "#{nodes[e.to_sym][:term]}"}.join(' ')}.join(' . ') + ' .'

    ## constraints on x-variables (including i-variables)
    x_variables = variables.dup.keep_if {|v| v[0] == 'x' or v[0] == 'i'}

    # x-variables to be bound to IRIs
    # body += " FILTER (" + x_variables.map{|v| "isIRI(#{'?'+v})"}.join(" && ") + ")" if x_variables.length > 0

    # x-variables to be bound to different IRIs
    x_variables.combination(2) {|c| body += " FILTER (#{'?'+c[0]} != #{'?'+c[1]})"} if x_variables.length > 1

    ## constraintes on p-variables
    p_variables = variables.dup.keep_if{|v| v[0] == 'p'}

    # initialize exclude predicates
    ex_predicates = []

    # filter out ignore predicates
    ex_predicates += @ignore_predicates

    # filter out sotral predicates
    ex_predicates += @sortal_predicates

    unless ex_predicates.empty?
      p_variables.each {|v| body += %| FILTER (?#{v} NOT IN (#{ex_predicates.map{|s| s}.join(', ')}))|}
    end

    ## constraintes on s-variables
    s_variables = variables.dup.keep_if{|v| v[0] == 's'}

    # s-variables to be bound to sortal predicates
    s_variables.each {|v| body += %| FILTER (?#{v} IN (#{@sortal_predicates.map{|s| s}.join(', ')}))|}

    template.gsub(/_BGP_/, body)
  end

  def stringify_term (t)
    if (t.class == RDF::URI)
      %|<#{t.to_s}>|
    elsif (t.class == RDF::Literal)
      if (t.datatype.to_s == "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString")
        %|"#{t.to_s}"@en|
      else
        t.to_s
      end
    else
      %|?#{t}|
    end
  end

end