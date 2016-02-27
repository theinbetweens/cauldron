module Cauldron

  class Builder

    attr_reader :composite

    def initialize(composite)
      @composite = composite
    end

    def tree
      root_node = Tree::TreeNode.new("ROOT", "Root Content")
      line_count = 0
      composite.operators.each do |x|
        child_node = Tree::TreeNode.new('CHILD-'+line_count.to_s)
        root_node << child_node
        line_count += 1
      end
    end

    # def trace(params)
    #   tracked_composite = composite.insert_tracking(params)
    #   tracked_composite.process(params)
    # end

    $HISTORY_COUNT = 0

    # NOTE: returns an array of new actualized composites extending the current composite
    def insertable_operators(examples)
      actualized_composite = ActualizedComposite.new(composite.clone_solution, examples)
      h = actualized_composite.histories
      self.class.available_statement_types.inject([]) do |total,x|
        total += x.instances(h, composite, examples, h.insert_points)
        total 
      end
    end

    def self.available_statement_types
      # TODO Not very effient to regenerate the opperators
      StatementGenerator.new.build(
        ['A','B', 'AC'],
        [:collect]
      )+Cauldron::StatementGenerator.new.build('string',[:chop])
    end

  end

end