
#class TopologicalStatements
#  include TSort
#   
#  def initialize
#    @dependencies = {}
#  end
#  
#  def add_dependency(task,*relies_on)
#    @dependencies[task] = relies_on
#  end
#  
#  def tsort_each_node(&block)
#    @dependencies.each_key(&block)
#  end
#  
#  def tsort_each_child(node,&block)
#    deps = @dependencies[node]
#    deps.each(&block) if deps
#  end
#  
#end

# See http://www.ruby-doc.org/stdlib/libdoc/tsort/rdoc/classes/TSort.html#M009366
class TopologicalStatements < Hash
  include TSort
   
  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end

  
end