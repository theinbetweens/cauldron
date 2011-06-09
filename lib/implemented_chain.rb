# This represents a chain that doesn't contain any theory variables.  All the variables
# have been replaced with intrinsic/real values.
#
class ImplementedChain
  
  # 
  #
  # 
  def initialize(nodes)
    @nodes = nodes
  end
  
  def each(&block)
    @nodes.each(&block)
  end  
  
  # TODO  Note sure how I feel about this direct access
  def [](index)
    return @nodes[index]
  end  
  
  def length
    return @nodes.length
  end  
  
  def describe(tab=0)
    return @nodes.inject('') {|total,x| total += x.describe}
  end
  
  def write(tab=0)
    return @nodes.inject('') {|total,x| total += x.write}
  end  
  
end