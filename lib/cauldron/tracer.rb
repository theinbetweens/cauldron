module Cauldron

  class Tracer

    attr_reader :sexp, :results

    def initialize(sexp)
      @sexp = sexp
      @results = []
    end

    def process(example)
      object = Tracer.new(sexp)
      object.instance_eval(Sorcerer.source(sexp, indent: true))
      #object.instance_eval("def foo(x); x +6; end")

      #object.function(params)
      #object.function(*example.arguments)
      object.function(example.arguments.first)

      History.new(object.results)
    end

    def record(line, depth, total_line, entry)
      #h = Hash[*entry.flatten] 
      h = Hash[*entry.flatten(1)]
      h.merge!(:line => line)
      h.merge!(:depth => depth)
      h.merge!(:total_line => total_line)
      
      @results << h
      #@results << #entry # TODO Only want the trace to have on result so it should probably be in the initilaize call only
    end

  end

end