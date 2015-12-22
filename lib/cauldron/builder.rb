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

    def insert_points
      results = [
        [composite.operators.length,0]
      ]
      composite.operators.each do |x|
        if x.content.branch?
          results << [1, 1]
        end
      end
      results
    end

    def trace(params)
      tracked_composite = composite.insert_tracking(params)
      tracked_composite.process(params)
    end

  end

end