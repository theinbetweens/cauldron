module Cauldron

  class ActualizedComposite

    attr_reader :examples, :composite

    # Might include the insert point here too
    def initialize(composite,examples)
      @composite, @examples = composite, examples
    end

    def histories
      @examples.collect do |example|
        @composite.record(example)
      end
    end

    def extend_solution
      builder = Builder.new(composite)
      #binding.pry
      builder.insertable_operators(examples)
    end

  end

end