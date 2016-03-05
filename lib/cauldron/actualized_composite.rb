module Cauldron

  class ActualizedComposite

    attr_reader :examples, :composite

    # Might include the insert point here too
    def initialize(composite,examples)
      @composite, @examples = composite, examples
    end

    def histories
      results = @examples.collect do |example|
                  @composite.record(example)
                end                
      Cauldron::Histories.new(results)
    end

    def extend_solution
      builder = Builder.new(composite)
      builder.insertable_operators(examples)
    end

    def solution?(problems)
      # TODO Should not need to 
      composite.solution?(examples)
    end

    def to_ruby
      composite.to_ruby(examples.scope)
    end    

  end

end