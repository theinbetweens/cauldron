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
        #grandchild_node
      end
      #root_node << Tree::TreeNode.new("CHILD1", "Child1 Content") << Tree::TreeNode.new("GRANDCHILD1", "GrandChild1 Content")
      #root_node << Tree::TreeNode.new("CHILD2", "Child2 Content")
      #root_node
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
      # results = [
      #   [composite.operators.length,0]
      # ]
      # if composite.operators.collect(&:first).count {|x| x.branch? }
      #   branches = composite.operators.collect(&:first).select {|x| x.branch? }
      #   branches.each do |x|
      #     results << [composite.operators.length, 1]
      #   end
      # end
      # results
    end

  end

end