module Cauldron

  class Tracer

    attr_reader :sexp, :results

    def initialize(sexp)
      @sexp = sexp
      @results = []
    end

    def process(params)
      object = Tracer.new(sexp)
      object.instance_eval(Sorcerer.source(sexp, indent: true))
      #object.instance_eval("def foo(x); x +6; end")
      object.function(params)
      object.results
    end

    def record(entry)
      @results << Hash[*entry.flatten] 
      #@results << #entry # TODO Only want the trace to have on result so it should probably be in the initilaize call only
    end

  end

end