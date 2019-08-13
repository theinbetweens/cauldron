# frozen_string_literal: true

module Cauldron
  class ExampleSet
    attr_reader :examples

    def initialize(examples)
      @examples = examples
    end

    def variables
      args = examples.first.arguments
      (0...args.length).collect { |x| 'var' + x.to_s }
    end

    def all?(&block)
      examples.all?(&block)
    end

    def collect(&block)
      examples.collect(&block)
    end

    # TODO: Might drop - limit access
    def each_with_index(&block)
      examples.each_with_index(&block)
    end

    def scope
      sexp = Ripper::SexpBuilder.new(examples.first.params.to_s).parse
      Cauldron::Scope.new(eval(Sorcerer.source(sexp)))
    end
  end
end
