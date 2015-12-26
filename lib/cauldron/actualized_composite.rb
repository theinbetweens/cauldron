module Cauldron

  class ActualizedComposite

    # Might include the insert point here too
    def initialize(composite,examples)
      @composite, @examples = composite, examples
    end

    def histories
      @examples.collect do |example|
        @composite.record(example)
      end
    end

  end

end