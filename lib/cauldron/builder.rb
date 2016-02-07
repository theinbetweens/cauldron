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

    # def insert_points
    #   results = [
    #     [composite.operators.length,0]
    #   ]
    #   composite.operators.each do |x|
    #     if x.content.branch?
    #       results << [1, 1]
    #     end
    #   end
    #   results
    # end

    def trace(params)
      tracked_composite = composite.insert_tracking(params)
      tracked_composite.process(params)
    end

    def insertable_operators(examples)

      actualized_composite = ActualizedComposite.new(composite, examples)

      h = actualized_composite.histories
      # TODO - Test the opperates here - and save errors

      # 1. SHOULD IT BE VALID?
      # 2. IS IT VALID
      # 3 - Save the error
      # 4 - Update code

      # Get the history
      # ---------------

      self.class.available_statement_types.inject([]) do |total,x|
        total += x.instances(h, composite, examples, h.insert_points)
        total 
      end
    end

    def self.available_statement_types
      # TODO Not very effient to regenerate the opperators
      #[ArrayCollect]+StatementGenerator.new.build(
      StatementGenerator.new.build(
        ['A','B', 'AC'],
        [:collect]
      )+Cauldron::StatementGenerator.new.build('string',[:chop])      
      # [ArrayCollect]+StatementGenerator.new.build(
      #     ['A','B', 'AC'],
      #     [:collect]
      #   )+Cauldron::StatementGenerator.new.build('string',[:chop])
    end

  end

end