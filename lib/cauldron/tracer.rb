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
      object.function(example.arguments.first)

      History.new(object.results)
    #rescue => e
      # binding.pry
      # Sorcerer.source(sexp, indent: true) 
      # var0 = [5,7]
    end

    def record(line, depth, total_line, point, entry)
      #h = Hash[*entry.flatten] 
      h = Hash[*entry.flatten(1)]
      h.merge!(:line => line)
      h.merge!(:depth => depth)
      h.merge!(:total_line => total_line)
      h.merge!(:point => point)
      h = h.reject {|key,value| key.to_s.match /^placeholder/ }
      @results << h
      #@results << #entry # TODO Only want the trace to have on result so it should probably be in the initilaize call only
    end

    def self.substitue_tracking
      %q{
      record("line", "depth", "total_lines", "point")
      }
    end

    def self.tracking(line, depth, total_line, point)
      a = %Q{
        record(#{line}, #{depth}, #{total_line}, #{point}, local_variables.reject { |foo|
          foo == :_
        }.collect { |bar|
          [bar, eval(bar.to_s)]
        })
      }   
      Ripper::SexpBuilder.new(a).parse
    end

  end

end